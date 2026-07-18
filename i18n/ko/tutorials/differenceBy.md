---
slug: differenceBy
title: differenceBy — FxDart 101
description: FxDart differenceBy 튜토리얼 — 계산된 키를 기준으로 다른 이터러블에 있는 원소를 제외하는 방법을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>differenceBy</code>
section: 4
crumb: differenceBy
prev: difference.html
prevLabel: difference
next: intersection.html
nextLabel: intersection
---
  <p class="hero-sub">값 동등성 대신 계산된 키로 비교하는 <code>difference</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>differenceBy(f, iterable1, iterable2)</code>는
    <a href="difference.html"><code>difference</code></a>와 완전히 동일한
    인자 순서 규칙을 따릅니다. 결과는
    <strong><code>iterable2</code>에서</strong> 나오며,
    <code>f</code>로 만든 키가 <em>결코</em> <code>iterable1</code>의
    <code>f</code>-키에 나타나지 않는 원소만 남습니다(결과 안의 중복은 제거됩니다).
    <code>f</code> 함수는 <em>양쪽</em> 이터러블에 모두 적용되므로,
    일부 언어의 <code>differenceBy</code>와 달리 두 인자는 같은 원소 타입
    <code>A</code>를 공유해야 합니다. 비교되는 것은 파생된 키 타입
    <code>B</code>뿐입니다.
  </p>
  <p>
    "제외 목록"과 "원본 목록"이 단순한 값이 아니라 온전한 레코드일 때
    꺼내 쓰게 되는 형태입니다. 차단된 사용자 객체 목록과 사용자 객체
    목록을 <code>id</code>로 맞추거나, 품절 상품 목록과 상품 카탈로그를
    <code>sku</code>로 맞추는 경우가 그렇습니다.
  </p>
  <p>
    <code>difference</code> 자체가 사실
    <code>differenceBy((a) =&gt; a, iterable1, iterable2)</code>입니다. 둘 다
    체인 메서드가 없으니 data-first 함수를 직접 호출하세요. 비동기 쪽에서는
    <code>differenceAsync</code>와 마찬가지로 동시성 표시가
    <code>iterable2</code>에 적용됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>differenceBy</code>를 <code>'sku'</code> 키 기준으로 써서
    아직 구매 가능한 상품을 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="difference.html"><code>difference</code></a> — 값 동등성으로 비교하는 버전 ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — 반대로 공통 키를 가진 원소만 남기기 ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — 키 기준으로 이터러블 하나에서 중복 제거 ·
    <a href="compress.html"><code>compress</code></a> — 나란한 불리언 마스크로 필터링
  </div>
