---
slug: max
title: max — FxDart 101
description: FxDart max 튜토리얼 — 파이프라인에서 가장 큰 숫자를 구하고, 비어 있으면 -무한대를, NaN이 섞이면 NaN을 반환합니다. 라이브 플레이그라운드 포함.
heading: <code>max</code>
section: 7
crumb: max
prev: min.html
prevLabel: min
next: size.html
nextLabel: size
---
  <p class="hero-sub">파이프라인에서 가장 큰 숫자 — <code>min</code>을 그대로 뒤집은 함수입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>max</code>는 <code><a href="min.html">min</a></code>과 방향만 반대일 뿐
    동작이 똑같습니다. 내부적으로는 <code>fold(-double.infinity, ..., iterable)</code>로,
    지금까지 본 값 중 가장 큰 값을 계속 들고 갑니다.
  </p>
  <p>
    FxTS를 그대로 따른 두 가지 특이 동작도 방향만 뒤집혀 동일하게 적용됩니다.
  </p>
  <ul>
    <li><strong>비어 있는</strong> 이터러블은 <code>null</code>이 아니라 <code>-double.infinity</code>를 반환합니다.</li>
    <li>어디든 <code>NaN</code>이 하나라도 있으면 결과가 <strong>오염</strong>되어 <code>NaN</code>이 됩니다 — <code>min</code>과 같은 이유로, <code>NaN</code>과의 비교는 언제나 거짓이기 때문입니다.</li>
  </ul>
  <p>
    다른 숫자 종결 연산자와 마찬가지로 체인 형태
    (<code>Fx&lt;num&gt;.max()</code> / <code>FxAsync&lt;num&gt;.max()</code>)는
    체인이 숫자를 담고 있다는 사실을 컴파일러가 알 수 있을 때에만 사용할 수 있습니다.
  </p>

  <h2>데모 1 · 기본 사용법, 빈 경우, NaN</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 목록에서 <strong>가장 높은</strong> 기온을 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="min.html"><code>min</code></a> — 정반대 방향의 짝 ·
    <a href="sum.html"><code>sum</code></a> · <a href="average.html"><code>average</code></a> — 나머지 숫자 종결 연산자 ·
    <a href="sortBy.html"><code>sortBy</code></a> — 극단값만 찾는 대신 순위를 매기고 싶을 때
  </div>
