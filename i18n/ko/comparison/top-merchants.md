---
slug: top-merchants
title: 총지출 기준 상위 5개 판매자 — Dart vs FxDart
description: 가계부를 판매자별로 그룹화해 합계 순위를 매깁니다 — 순수 Dart의 groupListsBy + sortedBy와 FxDart의 groupBy → sortBy → take 체인을 비교합니다.
heading: 총지출 기준 상위 5개 판매자
order: 11
tier: 2
functions: groupBy, sortBy, take
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    날짜, 판매자, 금액을 가진 한 달치 가계부 거래 내역이 주어질 때,
    <strong>가장 많이 지출한 판매자 다섯 곳</strong>을 찾으세요: 판매자별로
    그룹화하고, 각 그룹의 합계를 구하고, 합계를 내림차순으로 정렬한 뒤
    상위 다섯 개를 출력합니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 <code>groupBy</code>가 아예 없습니다 — 네이티브 버전은
    <code>groupListsBy</code>를 쓰려고 <code>package:collection</code>을
    끌어와야 하고, 작업 도중에 관용구를 바꿔야 합니다: 그룹화에는 확장
    메서드 하나, 순위 매기기에는 또 다른 확장 메서드(<code>sortedBy</code>,
    명시적인 <code>&lt;num&gt;</code> 타입 인자와 내림차순을 얻기 위한
    부호 반전 키가 필요합니다)를 써야 하죠. FxDart는 작업 전체를 하나의
    어휘로 유지합니다: <code>groupBy</code>가 맵을 만들고,
    <code>fx(map.entries)</code>가 <code>sortBy</code>와
    <code>take</code>로 체인을 이어갑니다. 해법의 형태는 같지만, 라이브러리
    하나, 파이프라인 하나로 끝나고 타입 인자를 챙기는 번거로움도 없습니다.
  </p>
