---
slug: transpose
title: transpose — FxDart 101
description: FxDart transpose 튜토리얼: 개수에 상관없이 여러 이터러블의 행을 열로 뒤집는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>transpose</code>
section: 6
crumb: transpose
prev: zipWithIndex.html
prevLabel: zipWithIndex
next: reverse.html
nextLabel: reverse
---
  <p class="hero-sub">행의 모음을 열의 모음으로 뒤집습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>transpose</code>는 <code>zip</code>을 이터러블 <em>개수에 제한 없이</em>
    일반화한 함수입니다. n번째 출력 리스트에는 아직 n번째 원소가 남아 있는 모든
    입력 행의 n번째 원소가 담깁니다. <code>zip</code>/<code>zip3</code>은 각 행을
    별도의 인자로 받지만(Dart에서 가변 인자 제네릭을 표현할 수 없기 때문입니다),
    <code>transpose</code>는 모든 행을 <strong>하나의</strong> 이터러블의
    이터러블로 받습니다 — <code>transpose([row1, row2, row3])</code> — 덕분에
    행 개수가 런타임에 결정되더라도 그대로 동작합니다.
  </p>
  <p>
    가장 짧은 입력이 바닥나는 순간 멈추는 <code>zip</code>과 달리,
    <code>transpose</code>는 <em>어느</em> 행이든 값이 남아 있는 한 계속
    진행합니다. 짧은 행은 뒤쪽 출력 리스트에 더 이상 기여하지 않을 뿐이며,
    그 결과 뒤쪽 리스트는 행 개수보다 짧아질 수 있습니다. 모든 행이 완전히
    소진되어야 비로소 멈춥니다.
  </p>

  <h2>데모 1 · 기본 &amp; 길이가 다른 행</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 행렬을 전치해 보세요(행이 열이 됩니다).</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="zip.html"><code>zip</code></a> — 행이 두 개인 특수한 경우 ·
    <a href="chunk.html"><code>chunk</code></a> — 평평한 소스를 먼저 행으로 묶기 ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
