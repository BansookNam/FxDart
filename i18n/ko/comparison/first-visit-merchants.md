---
slug: first-visit-merchants
title: 첫 방문 순서로 보는 판매자 목록 — Dart vs FxDart
description: 순서를 유지하는 중복 제거 — 순수 Dart의 seen-set 루프와 FxDart의 map + uniq를 비교합니다.
heading: 첫 방문 순서로 보는 판매자 목록
order: 4
tier: 1
functions: map, uniq
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    한 달치 거래 내역에서 각 판매자를 <strong>한 번씩만</strong>,
    <strong>처음 방문한</strong> 순서대로 나열하세요 — 재방문이 있어도
    그 판매자를 목록 뒤쪽으로 옮기면 안 됩니다. 데이터는 아래 코드에
    있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    솔깃한 네이티브 한 줄짜리 해법은 <code>toSet().toList()</code>이고,
    실제로도 맞는 결과를 출력합니다. Dart의 기본 세트가 삽입 순서를
    유지하기 때문입니다. 하지만 <code>Iterable.toSet</code>의 계약은
    순서를 전혀 보장하지 않으므로, <em>요구사항</em>이 첫 방문
    순서인 코드가 여기에 기대서는 안 됩니다. 정직한 네이티브 버전은
    두 개의 컬렉션과 <code>if</code> 하나를 쓰는 seen-set 루프입니다.
    FxDart의 <code>uniq</code>는 그 보장 자체를 이름에 담고 있습니다:
    각 원소의 첫 등장을 계약에 따라 지연 평가로 유지하며,
    <code>map</code> 뒤에 체인 한 단계로 붙습니다.
  </p>
