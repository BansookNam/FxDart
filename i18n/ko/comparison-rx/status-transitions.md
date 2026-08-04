---
slug: status-transitions
title: 상태가 바뀔 때만 보고하기 — RxDart vs FxDart
description: 반복투성이 헬스 피드를 런당 한 줄로 접기 — Stream.distinct vs uniqAdjacent, 전역 사촌으로는 distinctUnique와 uniq.
heading: 상태가 바뀔 때만 보고하기
order: 15
tier: 2
functions: fx, uniqAdjacent, uniq, map
domain: logs
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    헬스체크 피드가 <code>ok, ok, warn, warn, ok, ok, ok</code>를
    보고합니다 — 대부분 반복입니다. <strong>런</strong>마다
    <em>status now</em> 한 줄씩(세 줄)을 출력한 뒤, 처음 본 순서로 모든
    고유 상태를 나열하는 <code>statuses seen:</code> 한 줄을 출력하세요.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    인접 중복 제거 — "값이 <em>바뀔 때</em> 알려 달라" — 는 어느
    모델에서든 기억해 둔 상태 값 하나이고, 두 쪽은 줄과 줄이
    쌍둥이입니다. 유일한 함정은 이름 짓기인데, 방향이 서로 반대로
    갈립니다. 스트림 쪽에서는 순수 <code>Stream.distinct</code>가
    <em>이미</em> 인접 전용입니다 — RxDart는 많은 이들이
    <code>distinct</code>일 거라 기대하는 전역 버전을 위해
    <code>distinctUnique</code>를 추가합니다. FxDart는 반대 방향으로
    이름을 짓습니다: <code>uniq</code>가 모든 컬렉션 라이브러리의
    <code>uniq</code>처럼 전역이고, <code>uniqAdjacent</code>가 인접성을
    소리 내어 말합니다.
  </p>
  <p>
    두 쌍 모두 위에 일부러 함께 실었습니다: 런 접기는
    <code>distinct</code>&nbsp;/&nbsp;<code>uniqAdjacent</code>로,
    어디서든-본-것 요약은
    <code>distinctUnique</code>&nbsp;/&nbsp;<code>uniq</code>로. 전역
    버전이 각 모델에서 치르는 비용을 눈여겨보세요 — 어느 쪽이든 자라나는
    "seen" 집합이지만, 스트림 쪽은 (잠재적으로 끝나지 않는) 구독의 수명
    동안 그것을 들고 있어야 합니다. RxDart가 전역 형태를 옵트인으로 만든
    이유입니다. 이런 유한한 피드에서 두 모델은 전혀 갈라지지 않습니다:
    무승부.
  </p>
