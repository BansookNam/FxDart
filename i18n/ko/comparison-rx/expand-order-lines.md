---
slug: expand-order-lines
title: 주문을 라인 단위로 펼치기 — RxDart vs FxDart
description: 네 건의 주문을 열 개의 order/sku 라인 아이템으로 펼치기 — Stream.expand와 fxdart flatMap은 일대다를 가리키는 같은 단어이고, 소스 순서를 지킵니다.
heading: 주문을 라인 단위로 펼치기
order: 9
tier: 1
functions: fx, flatMap, map
domain: orders
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    어제의 주문 네 건에는 각각 두세 개의 라인 아이템이 있습니다. 이를
    <code>order/sku</code> 줄들의 리스트 하나로 펼치고 — 모든 아이템이
    자기 주문 id 아래, 소스 순서대로 — 줄 수를 출력하세요. 데이터는 아래
    코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    일대다 펼치기는 두 모델 모두의 기반암이고, 동기 페이로드라면 두
    표기는 같은 단어입니다: <code>Stream.expand</code>와 FxDart의
    <code>flatMap</code>은 둘 다 <em>요소에서 이터러블로</em>를 받아,
    조각들을 소스 순서대로 이어 붙이고, 결과를 포맷용 <code>map</code>에
    넘깁니다. 두 패널은 줄과 줄이 나란히 평행합니다.
  </p>
  <p>
    흥미로운 갈림길은 무대 바로 바깥에 있습니다. 각 주문의 라인들이
    <em>비동기적으로</em> 도착한다면, Rx 쪽은 RxDart의
    <code>flatMapIterable</code>이나 <code>flatMap</code>으로 올라가야
    합니다 — 내부 <em>스트림</em>들, 그리고 병합 순서가 진짜 문제가
    됩니다(연결(concat)하지 않는 한 완료 순서대로 뒤섞입니다). pull
    파이프라인 위 FxDart의 비동기 <code>flatMap</code>은 구조상 소스
    순서를 유지합니다. 하지만 그것은 티어 4의 이야기입니다; 이 인메모리
    작업에서는 양쪽 모두 펼치기를 직접적으로 표현하고 — Rx 패널은 RxDart
    연산자조차 필요 없습니다, 코어 <code>Stream</code>이 실어 나르니까요
    — 남는 흔적은 async main뿐입니다. 무승부입니다.
  </p>
