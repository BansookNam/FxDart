---
slug: uniqAdjacent
title: uniqAdjacent — FxDart 101
description: FxDart uniqAdjacent 튜토리얼: 인접한 중복만 제거하기 — 커지는 seen 집합 없이 상태 변화를 감지하는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>uniqAdjacent</code>
section: 4
crumb: uniqAdjacent
prev: uniqBy.html
prevLabel: distinctBy
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">바로 앞 원소와 같은 원소를 버립니다 — <em>인접한</em> 중복만 사라지고, seen 집합은 쌓이지 않습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="uniq.html">uniq</a></code>는 "이 값을 <em>언젠가</em>
    본 적이 있는가?"에 답합니다 — 지금까지 본 모든 값을 집합에 담아
    둡니다. <code>uniqAdjacent()</code>는 다른 질문에 답합니다.
    "값이 <em>바뀌었는가</em>?" 각 원소를 바로 앞 원소와만 비교하므로
    <code>[1, 1, 2, 2, 1]</code>은 <code>(1, 2, 1)</code>이 됩니다 —
    마지막 <code>1</code>은 살아남는데, 현재 구간의 반복이 아니라
    <em>새로운 구간</em>이기 때문입니다.
  </p>
  <p>
    그래서 반복 구간(run)을 접는 데 딱 맞는 연산자입니다. 매 틱마다 같은
    상태를 다시 보고하는 상태 피드, 평평하게 유지되는 센서 값, 같은
    레벨을 반복하는 로그 스트림 같은 것들입니다. seen 집합이 없으므로
    시퀀스가 아무리 길어도 메모리는 일정하게 유지됩니다 —
    <code>uniq</code>라면 한없이 커졌을 끝없는 소스에서도 안전합니다.
    <code>uniqAdjacentBy(key)</code>는 유도한 키로 비교하며,
    <code><a href="uniqBy.html">uniqBy</a></code>를 그대로 따릅니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다) — Rx는
    <code>distinctUntilChanged</code>, Dart 스트림은
    <code>Stream.distinct</code>라고 부릅니다. 비동기 키 콜백은 한 번에
    한 원소씩 실행되지만(비교 자체가 본질적으로 순서에 묶여 있습니다),
    상류는 여전히
    <code><a href="concurrent.html">concurrent</a></code> 아래에서
    병렬로 평가됩니다.
  </p>

  <h2>데모 1 · 반복 구간은 접고, 되돌아온 값은 남기기</h2>
  {{playground:0}}

  <h2>데모 2 · 키 기준 상태 변화</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 센서의 구역(zone)이 바뀌는 순간만 보고해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="uniq.html"><code>uniq</code></a> — seen 집합을 쓰는 전역 중복 제거 ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — 키 기준 전역 중복 제거 ·
    <a href="pairwise.html"><code>pairwise</code></a> — 변화의 양쪽이 모두 필요할 때
  </div>
