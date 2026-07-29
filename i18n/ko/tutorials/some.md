---
slug: some
title: any — FxDart 101
description: FxDart any 튜토리얼: 원소 중 하나라도 술어를 만족하는지 검사하고 첫 번째로 맞는 값에서 단락하는 방법을 동기와 비동기 모두에서 다룹니다.
heading: <code>any</code>
section: 8
crumb: any
prev: every.html
prevLabel: every
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">원소 중 하나라도 술어를 만족하면 true — 빈 이터러블이면 false입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>any</code>가 Dart다운 이름이고, fxdart는 FxTS식 표기인
    <code>some</code>도 함께 받습니다 — 같은 연산자입니다. 이 함수는
    <code>every</code>를 거울에 비춘 함수입니다. 왼쪽에서 오른쪽으로 훑다가
    조건을 만족하는 값을 찾는 순간 단락하며 곧바로 <code>true</code>를
    반환합니다. 끝까지 찾지 못하면 — 빈 이터러블도 여기에 해당하는데, 이는
    <code>every</code>와 정반대의 공허참 사례입니다 — 전부 확인한 뒤에야
    <code>false</code>를 반환합니다.
  </p>
  <p>
    동기 체인의 <code>.any(f)</code>는 Dart의 <code>Iterable</code>에서
    그대로 온 것이라 — <code>Fx</code>가 상속합니다 — 따로 정의할 필요가
    없습니다. 비동기 체인과 data-first 형태의
    <code>any(f, iterable)</code>는 fxdart가 제공하며, FxTS식 표기인
    <code>some</code>도 모든 자리에서 그대로 동작합니다.
  </p>

  <h2>데모 1 · 기본과 단락 평가</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>any</code>로 장바구니에 10보다 비싼 항목이 있는지 확인해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="every.html"><code>every</code></a> — "전부 만족하는가"에 대응하는 짝 ·
    <a href="includes.html"><code>includes</code></a> — <code>any</code>의 특수화된 형태 ·
    <a href="find.html"><code>find</code></a> — bool이 아니라 일치하는 원소 자체를 얻기 ·
    <a href="predicates.html"><code>predicates</code></a> — <code>any</code>와 함께 쓰기 좋은 미리 만들어진 술어들
  </div>
