---
slug: price-or-fallback
title: 프로모 가격, 없으면 정가 — RxDart vs FxDart
description: 프로모 가격이 있으면 그 가격, 없으면 정가 — 내부 스트림으로 하는 항목별 복구 vs 호출 바로 옆의 try/catch.
heading: 프로모 가격, 없으면 정가
order: 33
tier: 3
functions: fx, toAsync, map, ifEmpty
domain: orders
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    8월 프로모 가격표에 대고 구매 주문 두 건의 견적을 내세요. 비동기
    조회는 프로모 가격이 없는 SKU에 대해 <strong>던집니다</strong> —
    그런 라인은 정가로 폴백해야 하고, 모든 라인이 견적에 나타나야
    합니다. 라인이 없는 주문은 <code>(no lines to quote)</code> 한 줄로
    견적됩니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    스트림은 값과 에러를 <em>별도 채널</em>로 실어 나르고, 에러 채널은
    파이프라인 전체의 소유입니다. <code>asyncMap</code> 뒤에 놓인
    <code>onErrorReturnWith</code>가 실패를 보았을 때쯤이면, 그것을
    일으킨 라인은 이미 사라지고 없을 것입니다 — 에러 이벤트는 에러를
    실어 나르지, 요소를 실어 나르지 않으니까요. 관용적인 RxDart 복구는
    모든 조회에 자기만의 <em>내부</em> 스트림을 주는 것입니다 —
    <code>flatMap</code>으로 <code>Rx.fromCallable</code>에 들어가서 —
    그러면 각 실패는 자기만의 한 항목짜리 스트림에만 종결적이고, 그
    안에서는 라인이 아직 스코프에 있어 폴백할 수 있습니다.
  </p>
  <p>
    pull 모델에는 사이로 떨어질 두 번째 채널이 없습니다. 조회는
    <code>map</code> 콜백 안의 <code>await</code>이므로, 복구는 평범한
    Dart 제어 흐름입니다: 호출 바로 옆에서 타입 있는
    <code>StateError</code>를 잡아 정가를 반환하면 됩니다 — 요소, 그
    폴백, 에러 처리가 모두 같은 네 줄 안에 삽니다. 감싸기도 재병합도
    없고, 실패는 파이프라인에 아예 닿지 않습니다.
  </p>
  <p>
    비어 있는 두 번째 주문은 양쪽에서 같은 방식으로 착지합니다 —
    <code>defaultIfEmpty</code>, FxDart가 Rx에서 가져온 연산자입니다.
    본 경기에 대한 판정은 FxDart에게 갑니다: 항목별 에러 복구가 pull
    모델에서는 한 문장이고, push 모델에서는 하나의 공사입니다.
  </p>
