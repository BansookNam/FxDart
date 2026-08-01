---
slug: ifEmpty
title: ifEmpty — FxDart 101
description: FxDart ifEmpty와 defaultIfEmpty 튜토리얼: 결과가 비어 버린 파이프라인을 위한 지연 대체 값을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>ifEmpty</code>
section: 6
crumb: ifEmpty
prev: fork.html
prevLabel: fork
next: reduce.html
nextLabel: reduce
---
  <p class="hero-sub">파이프라인이 비어 있는 것으로 판명되면 대체 소스로 전환합니다 — 반복 시점에, 지연 방식으로 결정됩니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    아무것도 만들지 않을 <em>수도</em> 있는 파이프라인은 보통 우회를
    강요합니다. 구체화하고, <code>isEmpty</code>를 검사하고, 분기하는
    식입니다. 그러면 체인이 끊기고 — 더 나쁘게는 — 의도한 시점보다 먼저
    파이프라인이 실행됩니다. <code>ifEmpty(fallback)</code>은 그 분기를
    파이프라인 자체에 접어 넣습니다. 값은 손대지 않고 그대로 통과하며,
    소스가 아무것도 내놓지 않은 채 끝났을 때만 대체 이터러블이
    이어받습니다. 그 외의 경우에는 대체 함수가 <em>호출</em>조차 되지
    않습니다 — 양방향으로 지연 평가됩니다.
  </p>
  <p>
    <code>defaultIfEmpty(value)</code>는 값 하나짜리 축약형입니다.
    자리 표시용 행, 빈 보고서의 <code>0</code>, "결과 없음" 표시 같은
    것들입니다. 둘 다 체인의 어느 위치에서든 조합할 수 있는데, 이는
    공격적인 필터링 뒤에서 중요해집니다 — 비어 있는지 여부는 원래
    소스가 아니라 이 지점에 도달한 것들로 결정되기 때문입니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다). Rx의
    <code>switchIfEmpty</code> / <code>defaultIfEmpty</code>를
    따랐습니다. 비동기 형태는 비동기 대체 체인과 <code>Future</code>
    기본값을 받으며,
    <code><a href="concurrent.html">concurrent</a></code>와 조합됩니다.
  </p>

  <h2>데모 1 · 빈 보고서를 위한 기본값</h2>
  {{playground:0}}

  <h2>데모 2 · 대체 소스, 그 외에는 손대지 않음</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 대체 검색어를 갖춘 검색을 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="filter.html"><code>filter</code></a> — 체인이 비게 되는 가장 흔한 이유 ·
    <a href="concat.html"><code>concat</code></a> — 조건 없이 덧붙이기 ·
    <a href="head.html"><code>head</code></a> — 값 하나에 대해서는 대체 값 대신 <code>null</code>
  </div>
