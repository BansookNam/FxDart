---
slug: sortBy
title: sortBy — FxDart 101
description: FxDart sortBy 튜토리얼 — 추출한 키를 기준으로 오름차순 정렬하며 항상 새 리스트를 반환합니다. 라이브 플레이그라운드 포함.
heading: <code>sortBy</code>
section: 7
crumb: sortBy
prev: sort.html
prevLabel: sort
next: partition.html
nextLabel: partition
---
  <p class="hero-sub">비교자를 손으로 작성하는 대신, 추출한 키를 기준으로 오름차순 정렬합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>sortBy</code>는 <code><a href="sort.html">sort</a></code>의
    편의 버전입니다. <code>(a, b) =&gt; a.age.compareTo(b.age)</code>를
    직접 쓰는 대신 <code>sortBy</code>에 키 추출 함수 —
    <code>(a) =&gt; a['age']</code> — 를 넘기면, 비교자를 대신 만들어
    줍니다. 언제나 오름차순이고, 언제나 추출한 키를
    <code>Comparable.compare</code>로 비교합니다. 내부적으로는 말
    그대로 <code>sort((a, b) =&gt; compare(f(a), f(b)), iterable)</code>입니다.
  </p>
  <p>
    <code>sort</code>의 보장은 하나도 빠짐없이 그대로 적용됩니다.
    결과는 언제나 <strong>새</strong> 리스트이며, 입력을 변경하지
    않습니다. 체인 형태의 미묘한 점도 똑같습니다 — 동기
    <code>Fx</code> 체인에서 <code>.sortBy(f)</code>는 또 다른
    <code>Fx&lt;T&gt;</code>를 반환하므로 실체화하려면 여전히
    <code><a href="../101/index.html">.toArray()</a></code>가 필요하고,
    <code>FxAsync</code> 체인에서 <code>.sortBy(f)</code>는 이미
    <code>Future&lt;List&lt;T&gt;&gt;</code>를 반환하는 종결 연산자입니다.
  </p>
  <p>
    내림차순이나 다중 키 정렬이 필요하다면 비교자를 명시하는
    <code>sort</code>로 내려가세요. <code>sortBy</code>는 "추출한 키
    하나로 오름차순"이라는 흔한 경우만 다룹니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 — 이미 종결 연산자</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 사람들을 <strong>나이순</strong>으로, 어린 사람이 먼저 오도록 정렬해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="sort.html"><code>sort</code></a> — 이 함수가 기반으로 삼는 비교자 방식 ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — 전체 순위 대신 극값 하나만 필요할 때 ·
    <a href="pluck.html"><code>pluck</code></a> — 정렬 없이 같은 키만 뽑아내기
  </div>
