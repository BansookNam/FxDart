---
slug: paginated-products
title: 페이지네이션된 상품 목록 — Dart vs FxDart
description: 필터링하고 가격순으로 정렬한 뒤 2페이지를 잘라냅니다 — Dart에는 이미 skip/take가 있으므로 이번에는 진짜 무승부입니다.
heading: 페이지네이션된 상품 목록
order: 22
tier: 3
functions: filter, sortBy, drop, take, map
domain: orders
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    작은 상점의 카탈로그: 이름, 가격, 재고 여부. 재고가 있는 상품을
    가격 오름차순으로 정렬하고, 페이지당 세 개씩 <strong>2페이지</strong>를
    보여주세요 — 상품 하나에 한 줄씩. 데이터는 아래 코드에 있으며, 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 차이가 없습니다 — 이건 무승부이며, 이 점은 분명히 말할 가치가
    있습니다. 페이지네이션은 Dart의 <code>Iterable</code>이 이미 잘
    다루는 형태 그대로입니다: <code>skip</code>과 <code>take</code>는
    FxDart의 <code>drop</code>, <code>take</code>만큼이나 읽기 좋고,
    둘 다 지연 평가를 유지합니다. 네이티브 쪽의 유일한 걸림돌은 키
    기준 정렬입니다 — 순수 Dart는 비교자가 필요합니다
    (<code>package:collection</code>의 <code>sortedBy</code>가 이마저도
    해결해 줍니다). 나머지 코드베이스가 이미 FxDart의 어휘를 쓰고
    있을 때만 여기서 FxDart를 고르세요. 이 작업에서 순수 Dart는
    아무것도 잃지 않습니다.
  </p>
