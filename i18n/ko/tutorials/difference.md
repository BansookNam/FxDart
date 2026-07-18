---
slug: difference
title: difference — FxDart 101
description: FxDart difference 튜토리얼 — 한 이터러블에는 없고 다른 이터러블에만 있는 원소를 골라내는 방법을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>difference</code>
section: 4
crumb: difference
prev: uniqBy.html
prevLabel: uniqBy
next: differenceBy.html
nextLabel: differenceBy
---
  <p class="hero-sub">첫 번째 이터러블에 없는 두 번째 이터러블의 원소를 반환합니다 — 인자 순서가 중요합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    시그니처를 주의 깊게 보세요. <code>difference(iterable1, iterable2)</code>는
    <strong><code>iterable2</code></strong>를 순회하면서
    <em>오직</em> <code>iterable1</code>에 없는 원소만 내보냅니다
    (<code>uniq</code>처럼 중복은 제거됩니다). <code>iterable1</code>은
    오직 포함 여부를 검사하는 집합으로만 쓰입니다 — 그 자신의 원소는
    결과에 절대 나타나지 않으며, 내부의 중복도 아무 영향이 없습니다.
    이 순서는 대칭이 아닙니다. 인자를 바꾸면 완전히 다른(그리고 대개
    길이도 다른) 결과가 나옵니다. 기억하기 좋은 방법은
    <code>iterable1</code>을 "제외 목록", <code>iterable2</code>를
    "걸러 낼 목록"으로 생각하는 것입니다.
  </p>
  <p>
    내부 구현은 <code>differenceBy((a) =&gt; a, iterable1, iterable2)</code>입니다 —
    값 동등성 대신 계산된 키로 비교해야 한다면
    <a href="differenceBy.html"><code>differenceBy</code></a>를 참고하세요.
  </p>
  <p>
    <code>difference</code>에는 체인 메서드가 없습니다. data-first 함수(그리고
    그 비동기 짝)로만 존재합니다. 비동기 쪽에서는
    <code>.concurrent(n)</code>이 붙인 동시성 표시가
    <strong><code>iterable2</code></strong>에 적용됩니다 —
    <code>iterable1</code>의 제외 집합은 결과가 흘러나오기 전에 항상
    먼저 전부 소진됩니다.
  </p>

  <h2>데모 1 · 기본과 인자 순서</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>difference</code>로 <code>allTasks</code> 중 아직
    <code>completed</code>에 없는 작업을 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="differenceBy.html"><code>differenceBy</code></a> — 계산된 키로 비교하는 같은 동작 ·
    <a href="intersection.html"><code>intersection</code></a> — 반대로 공통 원소만 남기기 ·
    <a href="uniq.html"><code>uniq</code></a> — 이터러블 하나에서 중복 제거 ·
    <a href="../tutorials/includes.html"><code>includes</code></a> — 이터러블 하나에 포함되는지 검사
  </div>
