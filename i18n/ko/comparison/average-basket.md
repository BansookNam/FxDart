---
slug: average-basket
title: 100달러 초과 주문의 평균값 — Dart vs FxDart
description: 고액 주문의 평균 총액을 구합니다 — package:collection을 사용한 where/map/average와 FxDart의 filter + averageBy를 비교합니다.
heading: 100달러 초과 주문의 평균값
order: 4
tier: 1
functions: filter, averageBy
domain: orders
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    한 무더기의 상점 주문 중에서 총액이 <strong>100달러를 초과하는</strong>
    것만 골라 그 <strong>평균값</strong>을 통화 형식으로 출력하세요. 데이터는
    아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    솔직히 말하면: 별로 차이가 없습니다 — 무승부입니다. 순수 Dart 코어만
    쓴다면 fold-and-count(또는 데이터를 두 번 순회하며 합을 길이로 나누는
    방식)가 필요하겠지만, <code>package:collection</code>의
    <code>.average</code>가 그 간극을 메워줘서 결국
    <code>where → map → average</code>와 <code>filter → averageBy</code>의
    비교가 됩니다. FxDart는 키 함수를 직접 받음으로써 중간의 <code>map</code>
    단계를 생략하고, <code>averageBy</code>는 투영된 iterable에 대한 확장
    프로퍼티 대신 한 단어로 표현됩니다 — 승리라기보다는 어휘의 차이입니다.
    둘 다 읽기에 무리가 없습니다.
  </p>
