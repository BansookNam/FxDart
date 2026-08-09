---
slug: countWhere
title: countWhere — FxDart 101
description: FxDart countWhere 튜토리얼 — 조건에 맞는 값을 한 번의 순회로 셉니다. filter와 size를 융합했습니다. 라이브 플레이그라운드 포함.
heading: <code>countWhere</code>
section: 7
crumb: countWhere
prev: foldBy.html
prevLabel: foldBy
next: sort.html
nextLabel: sort
---
  <p class="hero-sub">몇 개나 일치할까요? 한 번의 순회, 숫자 하나 — <code>filter</code> + <code>size</code>를 융합했습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    "이 중 몇 개가 연체 / 세일 중 / 짝수인가?"는 자꾸
    <code>filter(pred).size()</code>로 쓰이곤 했습니다 — 개념상 폴드
    하나인 것에 체인 두 단계와 지연 중간 단계라니요.
    <code>countWhere(pred)</code>가 바로 그 폴드입니다. 파이프라인을 한 번
    순회하며 일치할 때마다 증가시키고 개수를 반환합니다. 도중에 아무것도
    구체화되지 않습니다.
  </p>
  <p>
    <em>키별</em> 개수(개수의 맵)가 필요하면
    <code><a href="countBy.html">countBy</a></code>를, 조건 하나의 개수가
    답의 전부라면 <code>countWhere</code>를 잡으세요. 비동기 쌍둥이는
    다른 모든 <code>*Async</code> 연산자처럼 원소마다 조건을 await합니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다 — Kotlin <code>count { }</code>의
    형태입니다.
  </p>

  <h2>데모 1 · 조건 하나, 숫자 하나</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>filter</code> 없이 대체 가격 사용 횟수를 세어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="countBy.html"><code>countBy</code></a> — 키별 개수 ·
    <a href="count.html"><code>size</code>/<code>count</code></a> — 전부 세기 ·
    <a href="filter.html"><code>filter</code></a> — 일치한 값 자체가 필요할 때
  </div>
