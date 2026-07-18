---
slug: slice
title: slice — FxDart 101
description: FxDart slice 튜토리얼: 이터러블에서 [start, end) 인덱스 구간을 잘라내는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>slice</code>
section: 5
crumb: slice
prev: dropUntil.html
prevLabel: dropUntil
next: chunk.html
nextLabel: chunk
---
  <p class="hero-sub">인덱스 <code>start</code>(포함)부터 <code>end</code>(미포함) 사이의 값을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>slice</code>는 범용 인덱스 구간 연산자입니다. 위치가
    <code>[start, end)</code>에 해당하는 원소를 내보내며,
    <code>end</code>를 생략하면 "소스 끝까지"라는 뜻입니다.
    <code>drop</code>(<code>start</code>로)과
    <code>take</code>(<code>end</code>로)를 한 번에 아우르는 단일 연산자인 셈입니다.
  </p>
  <p>
    data-first 형태에서는 인자 순서에 주의하세요 — 대부분의 FxDart 함수와 달리
    <code>iterable</code>이 <strong>가운데</strong>에 옵니다:
    <code>slice(start, iterable, [end])</code>로, FxTS를 그대로 따랐습니다.
    체인 형태에서는 이터러블이 수신자이므로 이런 특이점이 없습니다:
    <code>fx(iterable).slice(start, end)</code>. 내부적으로
    <code>slice</code>는 소스를 한 번 훑으며 인덱스를 세는 것뿐이라
    지연 평가가 유지되고, <code>end</code>만 넘겨 준다면 무한 소스에서도
    문제없이 동작합니다.
  </p>

  <h2>데모 1 · 기본과 인자 순서</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>slice</code>로 인덱스 2부터 5 직전까지의 구간을
    잘라내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="drop.html"><code>drop</code></a> — slice에서 시작 인덱스 쪽만 담당 ·
    <a href="take.html"><code>take</code></a> — slice에서 개수/끝 쪽만 담당 ·
    <a href="chunk.html"><code>chunk</code></a> — 소스 전체를 고정 크기 구간으로 나누기
  </div>
