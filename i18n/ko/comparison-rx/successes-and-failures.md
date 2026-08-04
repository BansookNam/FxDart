---
slug: successes-and-failures
title: 성공과 실패 나누기 — RxDart vs FxDart
description: 비동기 검증 일곱 건, 두 건 실패 — 타입 있는 partition에 이어지는 항목별 try/catch vs 오류 채널을 다시 데이터로 되돌리는 내부 스트림들.
heading: 성공과 실패 나누기
order: 26
tier: 3
functions: fx, toAsync, map, partition
domain: orders
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    2026-08 임포트에서 온 주문 일곱 건이 비동기 검증을 거치는데, 그중
    두 건에서 오류가 던져집니다(배송 주소 누락, 알 수 없는 SKU).
    <strong>양쪽</strong> 결과를 모두 지키세요: 유효한 주문마다
    <code>ok:</code> 줄을 출력한 뒤, 실패 건수를 출력합니다. 데이터는
    코드에 들어 있습니다; 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    스트림에는 채널이 둘 있습니다 — 데이터와 오류 — 그리고 오류
    채널은 스트림 전체 단위의 의미론을 지닙니다: 검증 하나가 오류를
    던지면 주문 다섯 건이 처리되지 않은 채 파이프라인이 죽습니다.
    그래서 RxDart 쪽은 단순히 <code>asyncMap(validate)</code>을 할 수
    없습니다; <em>각</em> 검증을 자기만의 내부
    스트림(<code>Rx.fromCallable</code>)으로 감싸고, 그 내부 오류
    채널에서 <code>onErrorReturnWith</code>로 잡아, 실패를 데이터
    값으로 재인코딩한 뒤에야 다시 병합합니다. 복구는 동작하지만,
    이것은 채널 배관 공사입니다: 오류가 데이터 경로를 떠났다가 호위를
    받아 되돌아와야 했던 것입니다.
  </p>
  <p>
    FxDart 쪽은 실패를 별도 채널에 올리는 일이 애초에 없습니다.
    <code>map</code> 안의 try/catch 하나가 각 결과를 평범한 레코드 —
    <code>(id, error?)</code> — 로 바꾸고, 거기서부터
    <code>partition</code>은 평범한 술어 분할입니다. 이것이 오류에
    대한 풀 모델의 일반적인 태도입니다: 오류는 다른 모든 것과 같은
    타입 있는 파이프라인을 흐르는 <em>값</em>이므로, 성공과 실패를
    함께 지키는 데 아무 비용도 들지 않습니다. 결과의 성패가 중단이
    아니라 결과의 일부일 때는, 특권적인 오류 채널이 없는 모델 쪽이
    되돌릴 것이 적습니다.
  </p>
