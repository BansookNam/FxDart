---
slug: intersection
title: intersection — FxDart 101
description: FxDart intersection 튜토리얼 — 한 이터러블의 원소 중 다른 이터러블에도 들어 있는 것만 남기는 방법을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>intersection</code>
section: 4
crumb: intersection
prev: differenceBy.html
prevLabel: differenceBy
next: intersectionBy.html
nextLabel: intersectionBy
---
  <p class="hero-sub"><code>difference</code>의 반대입니다. 두 번째 이터러블의 원소 중 첫 번째에도 들어 있는 것만 남깁니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>intersection(iterable1, iterable2)</code>은
    <code>difference</code>와 같은 인자 순서 규칙을 따릅니다. 결과는
    <strong><code>iterable2</code></strong>를 훑으면서
    <code>iterable1</code>에 <em>들어 있는</em> 원소를
    (<code>iterable2</code>의 순서대로, 중복은 제거해서) 남깁니다.
    <code>iterable1</code>은 오직 포함 여부를 확인하는 집합으로만
    쓰입니다. 두 인자를 바꿔도 집합론적으로는 같은 <em>값</em>이 나오지만,
    내보내는 원소의 출처가 바뀌므로 실제 순서(그리고 어느 컬렉션의 중복이
    합쳐지는지)는 달라집니다. 데모 1을 보세요.
  </p>
  <p>
    내부적으로는
    <code>intersectionBy((a) =&gt; a, iterable1, iterable2)</code>입니다.
    값 동등성이 아니라 계산된 키로 온전한 레코드 두 목록을 맞춰야 한다면
    <a href="intersectionBy.html"><code>intersectionBy</code></a>를
    바로 쓰세요.
  </p>
  <p>
    체인 메서드는 없으니 data-first 함수를 호출하세요. 비동기 쪽에서는
    <code>.concurrent(n)</code>의 동시성 표시가
    <code>iterable2</code>에 적용됩니다. <code>iterable1</code>은 포함
    여부 집합을 만들기 위해 미리 전부 소비합니다.
  </p>

  <h2>데모 1 · 기본과 인자 순서</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>intersection</code>으로 지원자의 기술 중 실제로
    요구되는 것이 무엇인지 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="difference.html"><code>difference</code></a> — 제외하는 쪽의 짝 ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — 대신 계산된 키로 맞추기 ·
    <a href="uniq.html"><code>uniq</code></a> — 이터러블 하나에서 중복 제거 ·
    <a href="../tutorials/includes.html"><code>includes</code></a> — 값 하나의 포함 여부 확인
  </div>
