---
slug: mapAccum
title: mapAccum — FxDart 101
description: FxDart mapAccum 튜토리얼 — 입력 하나마다 값 하나를 내보내는 누적 연산, 즉 시드를 출력하지 않는 scan입니다. 라이브 플레이그라운드 포함.
heading: <code>fxMapAccum</code>
section: 3
crumb: mapAccum
prev: scan.html
prevLabel: scan
next: peek.html
nextLabel: peek
---
  <p class="hero-sub">들어온 값 하나마다 값 하나를 내보내는 누적 연산 — 시드가 빠진 <code>scan</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="scan.html">scan</a></code>은 시드를 먼저 내보내므로
    <code>n</code>개가 들어가면 <code>n + 1</code>개가 나옵니다. 시작 상태가
    장부의 기초 잔액처럼 답의 일부일 때는 그게 맞지만, 시작 상태가 첫
    원소가 접혀 들어갈 상태일 뿐이라면 틀린 답입니다. 그래서 수많은
    <code>scan</code> 호출이 끝에 <code>.drop(1)</code>을 달고 있습니다.
    <code>fxMapAccum(f, seed, xs)</code>는 그 모양을 연산자 하나로 만든
    것입니다. <code>f</code>로 <code>seed</code>에 각 값을 접어 넣고 중간
    누적값을 모두 내보내지만, 시드 자체는 절대 내보내지 않습니다.
    <code>n</code>개가 들어가면 <code>n</code>개가 나오고, 빈 입력은 아무것도
    내보내지 않습니다.
  </p>
  <p>
    인자 순서는 일부러 <code>fxScan</code>과 맞췄기 때문에 둘 사이를 오가는 데는
    단어 하나만 고치면 됩니다. 지연 평가이며, <code>f</code>는 꺼낸 원소마다
    정확히 한 번, 순서대로 실행됩니다. 누적값은 순회에 속하므로 두 번 순회하면
    두 번 모두 <code>seed</code>에서 시작합니다. 누적값 타입 <code>B</code>는
    원소 타입과 같을 필요가 없습니다 — 문자열을 경로로, 숫자를 레코드로 접을
    수 있습니다.
  </p>
  <p>
    <code>fxMapAccumAsync</code>에서는 <code>f</code>와 <code>seed</code>
    모두 <code>Future</code>여도 됩니다. 각 단계가 이전 단계를 필요로 하므로
    접기 자체는 직렬로 일어나지만, 데모 2처럼 상류 단계는 여전히
    <code><a href="concurrent.html">concurrent(n)</a></code>으로 실행할 수
    있습니다. 체인에서는 <code>fx(xs).mapAccum(f, seed)</code>입니다.
    fxdart 확장 기능입니다(FxTS에는 없습니다) — Rust의
    <code>Iterator::scan</code>, Haskell의 <code>mapAccumL</code>, RxDart의
    <code>scan</code>도 같은 <code>n</code>개의 값을 내보냅니다.
  </p>

  <h2>데모 1 · 시드를 뺀 scan</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 상류는 동시 실행</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 끝에 붙은 <code>drop(1)</code>을 없애 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="scan.html"><code>scan</code></a> — 같은 접기, 시드 포함 ·
    <a href="reduce.html"><code>reduce</code>/<code>fold</code></a> — 최종 값만 ·
    <a href="drop.html"><code>drop</code></a> — <code>mapAccum</code>이 덜어 주는 것 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 상류의 병렬 평가
  </div>
