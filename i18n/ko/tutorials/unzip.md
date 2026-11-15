---
slug: unzip
title: unzip — FxDart 101
description: FxDart unzip 튜토리얼 — 쌍의 iterable을 한 번의 순회로 리스트 두 개로 나눕니다. zip의 역연산입니다. 라이브 플레이그라운드 포함.
heading: <code>fxUnzip</code>
section: 6
crumb: unzip
prev: zipWith.html
prevLabel: zipWith
next: zipWithIndex.html
nextLabel: indexed
---
  <p class="hero-sub">쌍이 들어가고 리스트 두 개가 나옵니다 — <code>zip</code>의 역연산을 한 번의 순회로.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="zip.html">zip</a></code>이 두 iterable을 짝지어 준다면,
    <code>fxUnzip(pairs)</code>는 그 짝을 다시 풉니다. 반환값은 레코드
    <code>(lefts, rights)</code>입니다 — 입력을 한 번 순회하면서 나란히 채운
    <code>List</code> 두 개이므로, 보통은 구조 분해 선언으로 받습니다:
    <code>final (names, scores) = fxUnzip(pairs);</code>. 같은 쌍 위에
    <code>map</code>을 두 번 거는 긴 버전은 입력을 두 번 순회합니다.
  </p>
  <p>
    왕복은 길이만 빼면 성립합니다. <code>fxUnzip(fxZip(a, b))</code>는
    <code>a</code>와 <code>b</code>를 돌려주되 둘 중 짧은 쪽 길이로 잘린
    상태입니다. 나머지는 <code>zip</code>이 이미 버렸기 때문입니다. 빈 입력은
    빈 리스트 두 개를 돌려줍니다. 섹션 6의 대부분과 달리 <code>unzip</code>은
    <strong>즉시 평가</strong>이며, 그럴 수밖에 없습니다. 지연 평가
    버전이라면 소스 하나 위에 iterable 두 개를 돌려줘야 하고,
    어느 한쪽을 다 꺼내는 순간 다른 쪽이 아직 도달하지 못한 값을 모두 버퍼에
    담아야 합니다(<code><a href="fork.html">fork</a></code>가 치르는
    비용입니다).
  </p>
  <p>
    <code>fxUnzipAsync</code>는 쌍의 <code>FxAsyncIterable</code>을 끝까지
    소비해 같은 레코드의 <code>Future</code>를 돌려줍니다. 체인에서는
    <code>.unzip()</code>입니다 — <code>Fx&lt;(A, B)&gt;</code>와
    <code>FxAsync&lt;(A, B)&gt;</code>에 대한 확장이므로
    <code>zip</code>, <code><a href="attach.html">attach</a></code>,
    <code><a href="pairwise.html">pairwise</a></code>가 만드는 것 같은
    위치 기반 쌍의 체인에서만 나타납니다. Dart 고유의 추가 기능입니다(FxTS에는
    <code>unzip</code>이 없습니다). Kotlin과 Rust도 같은 이름을 씁니다.
  </p>

  <h2>데모 1 · 쌍을 리스트 두 개로</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 체인 마무리</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 점들을 한 번의 순회로 나눠 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="zip.html"><code>zip</code></a> — 반대 방향 ·
    <a href="zipWith.html"><code>zipWith</code></a> — 짝짓기와 결합을 한 번에 ·
    <a href="partition.html"><code>partition</code></a> — 술어로 나눈 리스트 두 개 ·
    <a href="attach.html"><code>attach</code></a> — 풀어낼 쌍을 만듭니다
  </div>
