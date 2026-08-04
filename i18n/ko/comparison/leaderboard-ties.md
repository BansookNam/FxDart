---
slug: leaderboard-ties
title: 동점 순위가 있는 리더보드 — Dart vs FxDart
description: 동점 점수가 같은 순위를 공유하도록 선수 순위를 매깁니다 — 순수 Dart의 가변 rank/prevScore 상태와 FxDart의 sortBy + groupBy + zipWithIndex를 비교합니다.
heading: 동점 순위가 있는 리더보드
order: 24
tier: 3
functions: sortBy, groupBy, entries, zipWithIndex, flatMap
domain: users
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    여섯 선수의 점수로 리더보드를 출력하되, 높은 점수부터 먼저 표시하고
    <strong>동점 점수는 같은 순위를 공유</strong>하도록 하세요 — 밀집
    순위(dense ranking) 방식이라, 87점인 두 선수는 모두 2위가 되고 그다음
    점수는 3위가 됩니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    동점 순위는 네이티브 루프가 두 가지 가변 상태 — 현재
    <code>rank</code>와 이전 점수 — 를 함께 들고 다니게 만들고, 동점
    규칙은 <code>if</code> 문 안에 살아 있어서 그 정확성은 루프를 머릿속으로
    재생해 봐야 확인할 수 있습니다. FxDart 버전은 그 구조를 그대로
    선언합니다: <code>sortBy</code>로 내림차순 정렬하고,
    <code>groupBy</code>로 점수별 그룹을 만들고(순위 하나당 그룹 하나),
    <code>entries</code> + <code>zipWithIndex</code>로 그룹을 순회하며(그룹
    인덱스 = 순위), <code>flatMap</code>으로 각 그룹을 다시 선수 줄로
    펼칩니다. "동점 점수는 같은 순위를 공유한다"는 규칙은 루프에서 우연히
    나타나는 동작이 아니라 파이프라인의 구조 자체가 됩니다.
  </p>
