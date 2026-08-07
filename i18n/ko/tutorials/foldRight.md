---
slug: foldRight
title: foldRight — FxDart 101
description: FxDart foldRight 튜토리얼: 결합 법칙이 성립하지 않는 연산을 마지막 원소부터 접는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>foldRight</code>
section: 7
crumb: foldRight
prev: fold.html
prevLabel: fold
next: reduceLazy.html
nextLabel: reduceLazy
---
  <p class="hero-sub">마지막 원소부터 첫 원소까지 접습니다 — <code>fold</code>의 오른쪽 결합 짝입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>+</code>, <code>max</code>, 문자열 이어붙이기처럼 결합 법칙이
    성립하는 연산이라면 방향은 상관없고
    <a href="fold.html"><code>fold</code></a> 하나로 충분합니다. 그렇지 않은
    경우에는 방향이 답을 결정합니다. <code>fold</code>는 왼쪽부터 감싸므로
    <code>[1, 2, 3]</code>에 뺄셈을 적용하면
    <code>((0 - 1) - 2) - 3</code>이 되고, <code>foldRight</code>는
    오른쪽부터 감싸므로 <code>1 - (2 - (3 - 0))</code>이 됩니다.
  </p>
  <p>
    자연스러운 쓰임은 무언가를 <em>감싸는</em> 결과를 만들 때입니다. 중첩된
    구조, 데코레이터 사슬, 각 단계가 나머지 결과를 품어야 하는 연결 리스트
    같은 것들이죠. 왼쪽 fold로 쓰면 안팎이 뒤집힌 채로 나옵니다.
  </p>
  <p>
    리듀서는 Haskell <code>foldr</code>처럼 인자를 뒤집지 않고
    <code>fold</code>의 <code>(acc, 원소)</code> 순서를 그대로 지킵니다.
    같은 콜백이 양쪽 방향 모두에서 동작하므로, 고쳐 쓰지 않고 서로 바꿔 끼울
    수 있습니다.
  </p>
  <p>
    <code>foldRightWithIndex</code>가 알려주는 인덱스는 <strong>원본에서의
    위치</strong>입니다. 그래서 마지막 원소가 가장 큰 인덱스를 달고 먼저
    도착합니다 —
    <a href="withIndex.html"><code>foldWithIndex</code></a>가 같은 원소에
    줬을 바로 그 번호입니다. 거꾸로 도는 순회를 0, 1, 2로 다시 매기지
    <em>않은</em> 것은 의도적입니다. 연산자마다 다른 뜻을 갖는 인덱스보다는
    거꾸로 세는 인덱스가 낫습니다.
  </p>
  <p>
    둘 다 <code>fold</code>와 달리 엄격합니다. 뒤에서부터 걸으려면 끝이
    어디인지 알아야 하므로, <code>List</code>가 아닌 소스는 먼저 실체화되고
    <code>foldRightAsync</code>는 스트림을 모두 받아낸 뒤에 시작합니다.
    무한한 소스에는 절대 겨누지 마세요.
  </p>

  <h2>데모 1 · 방향이 답을 바꾼다</h2>
  {{playground:0}}

  <h2>데모 2 · 인덱스와 함께, 그리고 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 파이프라인을 바깥 단계부터 중첩된 호출로 그려 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fold.html"><code>fold</code></a> — 같은 축약을 왼쪽에서 ·
    <a href="reduce.html"><code>reduce</code></a> — 첫 원소를 씨앗으로 ·
    <a href="withIndex.html"><code>foldWithIndex</code></a> — 위치를 함께 받는 왼쪽 fold ·
    <a href="reverse.html"><code>reverse</code></a> — 뒤에서부터 걷는 또 하나의 방법
  </div>
