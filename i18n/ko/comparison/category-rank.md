---
slug: category-rank
title: 이번 달 카테고리 순위 — Dart vs FxDart
description: 지출을 그룹핑·합산·순위 매기기 — 순수 Dart의 groupListsBy와 비교자 뒤집기 vs FxDart의 groupedBy → sortByDesc 체인 하나.
heading: 이번 달 카테고리 순위
order: 51
tier: 3
functions: groupedBy, map, sumBy, sortByDesc, take
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    한 달치 가계부 거래 내역이 주어질 때, <strong>총지출 상위 세
    카테고리</strong>를 큰 순서대로 매기고, 각 카테고리를 합계 금액과 구매
    건수와 함께 출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    과제는 하나의 생각입니다 — 그룹핑, 합산, 순위, 상위 셋 — 그리고
    FxDart 버전은 하나의 체인입니다. <code>groupedBy</code>가
    <code>(key:, items:)</code> 레코드를 내놓으므로 카테고리별 합계는
    <code>map</code> 한 단계 거리이고, <code>sortByDesc</code>가 키 기준
    "큰 것부터"를 말합니다. 순수 Dart는 같은 생각을 <code>Map</code>
    사이로 쪼갭니다. <code>package:collection</code>의
    <code>groupListsBy</code>가 플루언트 체인을 끊고, 내림차순은 비교자
    피연산자 뒤집기
    <code>(a,&nbsp;b)&nbsp;=&gt;&nbsp;b…compareTo(a…)</code>가 됩니다 —
    조용한 버그의 고전적인 서식지이자, FxDart 쪽이 키를 결코 부호 반전하지
    않는 이유입니다.
  </p>
  <p>
    솔직히 말하면 <code>package:collection</code>은 그룹핑을 잘 커버하고,
    일회성 리포트라면 네이티브 버전도 괜찮습니다. 체인의 값어치는
    리포트가 자랄수록 드러납니다 — 단계가 하나 늘 때마다(필터 하나, 두
    번째 순위 기준 하나) 또 한 번의 <code>entries</code> 왕복 대신
    파이프라인이 연장됩니다.
  </p>
