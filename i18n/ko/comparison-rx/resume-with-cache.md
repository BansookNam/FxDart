---
slug: resume-with-cache
title: 소스가 죽으면 캐시로 이어가기 — RxDart vs FxDart
description: 라이브 피드가 업데이트 세 건 뒤에 죽습니다 — 캐시된 꼬리를 갈아 끼우는 onErrorResumeNext vs concat에 이어 붙이는 명시적 풀 루프.
heading: 소스가 죽으면 캐시로 이어가기
order: 34
tier: 3
functions: fx, concat, take, map
domain: orders
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    라이브 주문 피드가 업데이트 세 건을 전달한 뒤 연결이
    끊어집니다. 대시보드에는 여전히 처음 <strong>여섯</strong> 행이
    필요합니다: 라이브 피드가 전달해 낸 것은 모두 유지하고, 그다음은
    어젯밤의 캐시 스냅숏에서 이어가되 그 행들에
    <code>(from cache)</code> 표시를 붙이세요. 실패는 코드에
    결정적으로 주입되어 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이것은 오류 채널이 가장 빛나는 순간입니다. 복구 지점이
    <em>스트림 전체</em> 단위입니다 — "이 소스가 죽으면 시퀀스의
    나머지는 저 소스로 전환한다" — 푸시 오류 채널이 모델링하는 바로
    그 모양입니다. <code>onErrorResumeNext</code>는 요구사항 전체를
    연산자 하나로 말합니다: 값은 손대지 않고 통과하고, 첫 오류가
    구독을 진행 중에 복구 스트림으로 갈아 끼우며, 이미 전달된 세 건의
    업데이트는 안전하게 지나가 있습니다.
  </p>
  <p>
    풀 쪽에는 나중에 오류를 던지는 소스의 값들을 지켜 주는 연산자가
    없습니다 — 풀 파이프라인은 오류를 풀 지점에서 드러내고, 실패한
    <code>toList</code>는 그전에 온 것들을 버렸을 것입니다. 그래서
    경계를 직접 써 내려갑니다: <code>await for</code> 루프가 라이브
    행들을 모으고, <code>try</code>/<code>catch</code>가 실패에 이름을
    붙이고, <code>concat</code> + <code>map</code> +
    <code>take</code>가 캐시된 꼬리를 이어 붙입니다. 정직한 두세 줄이
    더 들 뿐 — 어휘 하나가 빠진 같은 복구입니다.
  </p>
  <p>
    우열을 가리기 어렵고, 우아함에서는 RxDart 쪽으로 살짝 기웁니다.
    양쪽 모두 여섯 행에서 멈추고, 어느 쪽도 페이지에 필요한 만큼을
    넘어 캐시를 읽지 않습니다: 한쪽에서는 <code>take</code>가 구독을
    취소하고, 다른 쪽에서는 그저 풀기를 멈춥니다.
  </p>
