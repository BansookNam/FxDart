---
slug: audit-with-outcomes
title: 감사 로그에 값과 실패를 함께 — RxDart vs FxDart
description: 여덟 줄의 설정을 파싱하는데 셋이 실패하는 상황에서 값과 실패 수를 출력하기 — 에러를 데이터로 되밀반입하는 쪽 vs 평범한 partition.
heading: 감사 로그에 값과 실패를 함께
order: 22
tier: 2
functions: fx, map, partition
domain: logs
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    배포 감사가 <code>key=value</code> 설정 여덟 줄을 파싱하는데, 그중 세
    줄은 값을 파싱할 수 없습니다. 리포트에는 <em>양쪽</em> 절반이 모두
    필요합니다: 성공적으로 파싱된 각 <code>key = value</code>를 출력한
    뒤, 실패 건수를 출력하세요. 줄들은 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 출력을 내야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    스트림 모델은 에러를 별도의 대역 외 채널로 실어 나릅니다 — 그리고 그
    채널은 종결적입니다: <code>FormatException</code> 하나가 구독 전체를
    끝내며, 멀쩡한 다섯 줄을 함께 데려가 버립니다. 값<em>과</em> 실패를
    모두 지키려면, RxDart 쪽은 모든 줄에 자기만의 내부 스트림을
    주고(<code>Rx.fromCallable</code>) 에러가 빠져나가기 전에 데이터로
    바꿔야 합니다 — 여기서는 <code>onErrorReturn(null)</code>,
    <code>null</code>이 "이 줄은 실패"를 대신합니다. 이것이 던지는 함수에
    대해 이 모델이 허용하는 가장 가벼운 표기이고(더 무거운
    <code>materialize</code> 경로는 완전한 알림 객체를 실체화합니다),
    오직 모델이 여러분 대신 내린 결정을 되돌리기 위해서만 존재합니다:
    에러는 애초에 값이 아니었던 것입니다. (두 패널이 같은 던지는
    <code>parse</code>를 공유하는 것은 의도적입니다 — null을 반환하는
    파서였다면 두 모델 모두 결과를 평범한 데이터로 유지할 수 있습니다;
    던짐이 전제이고, 그에 대해 각자가 무엇을 해야 하는가가 이
    비교입니다.)
  </p>
  <p>
    pull 쪽은 애초에 실패를 채널에 올리지 않습니다. 같은 던짐이 로컬
    <code>try</code>/<code>catch</code> 하나 거리에서 다시 평범한 값 —
    nullable 레코드 — 이 되므로, 요구사항 전체가 <code>map</code> 다음
    <code>partition</code>입니다: 한 번의 패스, 두 개의 리스트, 양쪽 절반
    모두 똑같이 일급. 이것이 FxDart의 더 넓은 타입 있는 에러 입장의
    형태입니다(그 <code>Either</code> 파이프라인은 더 풍부한 에러 타입을
    가진 같은 아이디어입니다). 실패가 예외적인 종료가 아니라 리포트의
    일부라면, 실패를 데이터로 유지하는 쪽이 이깁니다 — 판정은 FxDart에게
    갑니다.
  </p>
