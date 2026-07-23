---
slug: minBy
title: minBy — FxDart 101
description: FxDart minBy 튜토리얼 — 키가 가장 작은 원소를 단 한 번의 순회로 찾습니다. 정렬 없이, 비어 있으면 null. 라이브 플레이그라운드 포함.
heading: <code>minBy</code>
section: 7
crumb: minBy
prev: maxBy.html
prevLabel: maxBy
next: size.html
nextLabel: count
---
  <p class="hero-sub">키가 가장 작은 원소 — 한 번의 순회, 정렬 없이, 비어 있으면 <code>null</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>minBy</code>는 <code><a href="maxBy.html">maxBy</a></code>의
    거울상입니다. 단 한 번의 O(n) 순회로 가장 작은 키를 가진
    <em>원소</em>를 반환합니다. <code>sortBy(key).head()</code>라면
    값 하나를 읽으려고 파이프라인 전체를 정렬할 것입니다.
  </p>
  <p>
    동작 규약은 <code>maxBy</code>와 정확히 일치합니다. 키는
    <code><a href="sortBy.html">sortBy</a></code>처럼
    (<code>Comparable.compare</code>) 비교되고, 동점일 때는 먼저 만난
    <strong>첫</strong> 원소를 유지하며, 빈 파이프라인은
    <code>null</code>을 반환합니다 — 숫자용
    <code><a href="min.html">min</a></code>이 반환하는
    <code>infinity</code>가 아닙니다. 되돌아갈 "영 원소"가 없기
    때문입니다.
  </p>

  <h2>데모 1 · 기본 사용법, 빈 경우 &amp; 동점</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 가장 빠른 주자를 한 번의 호출로 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="maxBy.html"><code>maxBy</code></a> — 거울상 ·
    <a href="min.html"><code>min</code></a> — 원소가 아니라 키 자체가 필요할 때 ·
    <a href="head.html"><code>head</code></a> — 같은 널 허용 규약
  </div>
