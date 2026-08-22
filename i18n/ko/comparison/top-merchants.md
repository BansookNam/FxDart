---
slug: top-merchants
title: 총지출 기준 상위 5개 판매자 — Dart vs FxDart
description: 가계부를 판매자별로 그룹화해 합계 순위를 매깁니다 — 순수 Dart의 groupListsBy + sortedBy와 FxDart의 groupedBy → sortByDesc → take 체인 하나를 비교합니다.
heading: 총지출 기준 상위 5개 판매자
order: 11
tier: 2
functions: groupedBy, sortByDesc, take
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
    순수 Dart에는 그룹화 기능이 아예 없어서 네이티브 버전은
    <code>package:collection</code>을 끌어와야 하고, 거기서 그룹화는 체인을
    <em>끊습니다</em>: <code>groupListsBy</code>가 <code>Map</code>을 돌려주니
    순위를 매기려면 중간 변수에 이름을 붙이고, <code>.entries</code>로 다시
    들어가서, 각 그룹을 타입 정보 없는 <code>kv.key</code> /
    <code>kv.value</code> 쌍으로 읽어야 하죠. 정렬에는 우회로가 두 개 더
    붙습니다: 명시적인 <code>&lt;num&gt;</code> 타입 인자(<code>double</code>은
    <code>Comparable&lt;num&gt;</code>이지
    <code>Comparable&lt;double&gt;</code>이 아니라서 추론이 실패합니다),
    그리고 <em>부호를 반전한</em> 키 — <code>sortedBy</code>가 오름차순만
    지원하기 때문입니다.
  </p>
  <p>
    FxDart에서는 네 단계가 하나의 체인의 네 고리가 되어, 요구사항이 말하는
    순서 그대로 위에서 아래로 흘러갑니다. <code>groupedBy</code>는 맵 대신
    <code>(key:, items:)</code> 그룹을 내보내며 파이프라인 안에 머물러서
    풀었다가 다시 감쌀 일이 없고, <code>sortByDesc</code>는 "내림차순"을 빼기
    기호로 인코딩하는 대신 이름으로 말합니다. 중간 변수도, 타입 인자를 챙기는
    번거로움도, 부호 반전 트릭도 없습니다 — 코드가 그냥 그룹화하고, 순위를
    매기고, 다섯 개를 가져오라고 말합니다.
  </p>
