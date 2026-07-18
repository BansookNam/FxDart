---
slug: intersectionBy
title: intersectionBy — FxDart 101
description: FxDart intersectionBy 튜토리얼 — 다른 이터러블과 공유하는 계산된 키를 기준으로 원소를 남기는 방법을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>intersectionBy</code>
section: 4
crumb: intersectionBy
prev: intersection.html
prevLabel: intersection
next: compress.html
nextLabel: compress
---
  <p class="hero-sub">값 동등성 대신 계산된 키로 비교하는 <code>intersection</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <a href="differenceBy.html"><code>differenceBy</code></a>와 형태는 같고
    조건만 반대입니다. <code>intersectionBy(f, iterable1, iterable2)</code>는
    <strong><code>iterable2</code></strong>를 훑으면서
    <code>f</code>로 만든 키가 <em>존재하는</em> 원소만 남깁니다. 비교
    대상은 <code>iterable1</code>의 <code>f</code>-키이고, 그 키를 기준으로
    중복도 제거됩니다. <code>f</code>는 양쪽 이터러블에 모두 적용되므로 두
    이터러블은 같은 원소 타입 <code>A</code>를 공유해야 합니다. 비교 키 타입
    <code>B</code>만 <code>A</code>와 달라도 됩니다.
  </p>
  <p>
    식별용 필드를 공유하는 온전한 레코드 두 목록에 딱 맞는 함수입니다.
    "추천" SKU 목록과 상품 카탈로그, 활성 사용자 ID 목록과 전체 사용자
    객체 목록 같은 경우가 그렇습니다. <code>intersection</code> 자체가
    <code>intersectionBy((a) =&gt; a, iterable1, iterable2)</code>입니다.
  </p>
  <p>
    체인 메서드는 없습니다. data-first 함수나 그 비동기 짝을 호출하세요.
    <code>.concurrent(n)</code>의 동시성 표시는
    <code>intersectionAsync</code>와 똑같이
    <code>iterable2</code>에 적용됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>intersectionBy</code>를 <code>'sku'</code> 키 기준으로 써서
    할인 중인 상품을 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="intersection.html"><code>intersection</code></a> — 값 동등성으로 비교하는 버전 ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — 반대로 공통 계산 키를 가진 원소를 제외하기 ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — 키 기준으로 이터러블 하나에서 중복 제거 ·
    <a href="compress.html"><code>compress</code></a> — 나란한 불리언 마스크로 필터링
  </div>
