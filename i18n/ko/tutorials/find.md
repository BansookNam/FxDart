---
slug: find
title: find — FxDart 101
description: FxDart find 튜토리얼: 술어와 일치하는 첫 원소를 지연 평가와 단축 평가로 찾고, 없으면 null을 받는 방법을 익힙니다.
heading: <code>firstWhereOrNull</code>
section: 8
crumb: firstWhereOrNull
prev: nth.html
prevLabel: nth
next: findIndex.html
nextLabel: findIndex
---
  <p class="hero-sub">술어가 true인 첫 번째 원소를 반환하며, 없으면 <code>null</code>을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>find</code>는 <code>head</code>와 <code>filter</code>를 하나로
    합친 모습입니다 — 실제로 구현도 정확히 그렇습니다:
    <code>head(filter(f, iterable))</code>. 이 결합 덕분에 지연 평가와
    단축 평가가 가능합니다. 원소를 하나씩 끌어와 <code>f</code>로 검사하고,
    일치하는 것을 찾는 즉시 멈춥니다. 그보다 뒤에 있는 원소는 전혀
    건드리지 않습니다.
  </p>
  <p>
    <code>head</code>와 마찬가지로, 찾지 못했을 때는 FxTS의
    <code>undefined</code>가 아니라 <code>null</code>을 반환합니다.
    data-first 형태, 비동기 버전, 그리고 동기와 비동기 체인 양쪽의
    메서드로 모두 제공됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 단축 평가와 비동기</h2>
  <p>백만 개의 원소 중 단 6개만 검사합니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>find</code>로 <code>qty &gt; 0</code>인 첫 항목을 찾고, 없으면 <code>null</code>을 받아 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="findIndex.html"><code>findIndex</code></a> — 같은 탐색, 위치를 반환 ·
    <a href="filter.html"><code>filter</code></a> — 첫 번째가 아니라 일치하는 모든 원소 ·
    <a href="head.html"><code>head</code></a> — <code>find</code>를 이루는 재료 ·
    <a href="matches.html"><code>matches</code></a> — 형태 비교용으로 미리 만들어진 술어
  </div>
