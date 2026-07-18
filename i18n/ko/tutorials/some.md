---
slug: some
title: some — FxDart 101
description: FxDart some 튜토리얼: 원소 중 하나라도 술어를 만족하는지 검사하고 첫 번째로 맞는 값에서 단축 평가하는 방법을 동기와 비동기 모두에서 다룹니다.
heading: <code>some</code>
section: 8
crumb: some
prev: every.html
prevLabel: every
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">원소 중 하나라도 술어를 만족하면 true — 빈 이터러블이면 false입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>some</code>은 <code>every</code>를 거울에 비춘 함수입니다. 왼쪽에서
    오른쪽으로 훑다가 조건을 만족하는 값을 찾는 순간 단축 평가하며 곧바로
    <code>true</code>를 반환합니다. 끝까지 찾지 못하면 — 빈 이터러블도 여기에
    해당하는데, 이는 <code>every</code>와 정반대의 공허참 사례입니다 —
    전부 확인한 뒤에야 <code>false</code>를 반환합니다.
  </p>
  <p>
    <code>every</code>와 달리 <code>Fx</code>는 <em>직접</em>
    <code>.some()</code> 체인 메서드를 정의합니다(Dart의
    <code>Iterable</code>에 <code>some</code>이 내장되어 있지 않으므로
    <code>Iterable</code>만으로는 커버되지 않기 때문입니다 — 가장 비슷한 것은
    <code>any</code>인데, 이름만 다를 뿐 하는 일은 같습니다).
  </p>

  <h2>데모 1 · 기본과 단축 평가</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>some</code>으로 장바구니에 10보다 비싼 항목이 있는지 확인해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="every.html"><code>every</code></a> — "전부 만족하는가"에 대응하는 짝 ·
    <a href="includes.html"><code>includes</code></a> — <code>some</code>의 특수화된 형태 ·
    <a href="find.html"><code>find</code></a> — bool이 아니라 일치하는 원소 자체를 얻기 ·
    <a href="predicates.html"><code>predicates</code></a> — <code>some</code>과 함께 쓰기 좋은 미리 만들어진 술어들
  </div>
