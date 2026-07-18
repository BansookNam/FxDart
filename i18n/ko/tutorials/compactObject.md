---
slug: compactObject
title: compactObject — FxDart 101
description: FxDart compactObject 튜토리얼: Map에서 값이 null인 키를 한 단계 깊이로 제거하는 방법을 알아봅니다.
heading: <code>compactObject</code>
section: 9
crumb: compactObject
prev: evolve.html
prevLabel: evolve
next: resolveProps.html
nextLabel: resolveProps
---
  <p class="hero-sub">값이 <code>null</code>인 키를 모두 제거한 <code>Map</code>의 복사본을 반환합니다 — 한 단계 깊이까지만.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>compactObject</code>는 <code>Map</code>을 위한
    <a href="compact.html"><code>compact</code></a>입니다 —
    <code>null</code>을 <code>Iterable</code>에서 걷어 내던 그 함수의
    Map 버전이라고 보면 됩니다. 폼 데이터나 일부만 채워진 레코드를 직렬화하기 전에 정리할 때 유용합니다 —
    아무도 채우지 않은 필드는 버리고 나머지는 그대로 둡니다.
  </p>
  <p>
    정리는 <strong>얕게</strong> 이루어집니다. 최상위 값만 검사하므로,
    두 단계 아래에 중첩된 <code>null</code>은 — 즉 그 자체가
    <code>Map</code>인 값 안에 들어 있는 것은 — 전혀 건드리지 않습니다. 재귀적으로 정리해야 한다면
    그 과정은 직접 작성해야 합니다(또는 바깥 맵을 조립하기 전에 중첩된 맵에
    <code>compactObject</code>를 한 번 더 호출하면 됩니다).
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 얕은 동작 확인하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>compactObject</code>로 <code>draft</code>에서 값이 null인 키를 제거해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="compact.html"><code>compact</code></a> — <code>Iterable</code> 버전 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — 값을 기준으로 하는 관련 검사 ·
    <a href="omitBy.html"><code>omitBy</code></a> — 이 함수가 특수화한 일반 술어 버전 ·
    <a href="evolve.html"><code>evolve</code></a> — 값을 제거하는 대신 변환하기
  </div>
