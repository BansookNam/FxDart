---
slug: top-category-average
title: 거래당 평균 지출이 가장 높은 카테고리 — Dart vs FxDart
description: 지출을 그룹화해 거래당 가장 비싼 카테고리를 찾습니다 — 순수 Dart에서 collection의 groupBy + maxBy 중첩 호출과 하나의 FxDart 체인을 비교합니다.
heading: 거래당 평균 지출이 가장 높은 카테고리
order: 18
tier: 2
functions: groupBy, map, maxBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    날짜, 카테고리, 금액을 가진 한 달치 지출 내역이 주어질 때,
    <strong>거래당 평균 금액이 가장 높은 카테고리</strong>를 찾아, 그
    평균을 소수점 둘째 자리까지 포맷하여 출력하세요. 데이터는 아래
    코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 <code>groupBy</code>도 <code>maxBy</code>도 없습니다.
    <code>package:collection</code>이 둘 다 제공하지만, 체인의 한
    단계가 아니라 최상위 함수로 제공합니다. 그래서 네이티브 버전은
    안에서 바깥으로 읽어야 합니다: <code>groupBy(</code>… 의 엔트리들에
    대한 <code>map</code>을 <code>maxBy(</code>…로 감싸는 식이죠 — 세
    단계짜리 생각 하나를 위해 세 가지 관용구(함수 호출, 메서드 체인,
    함수 호출)를 오가야 합니다. FxDart는 읽는 순서를 데이터 흐름과 똑같이
    유지합니다: 거래를 <code>groupBy</code>로 묶고, 각 그룹을
    <code>map</code>으로 <code>(category, average)</code>로 바꾸고,
    평균을 <code>maxBy</code>로 고릅니다. 알고리즘은 같지만, 문장은
    왼쪽에서 오른쪽으로 흐릅니다.
  </p>
