---
slug: reduceLazy
title: reduceLazy — FxDart 101
description: FxDart reduceLazy 튜토리얼: 여러 이터러블에 반복해서 적용할 수 있는 재사용 가능한 리듀서 함수를 만드는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>reduceLazy</code>
section: 7
crumb: reduceLazy
prev: fold.html
prevLabel: fold
next: sum.html
nextLabel: sum
---
  <p class="hero-sub">fold의 시드와 결합 함수를 커링해 재사용 가능한 리듀서 함수로 만들어 줍니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>reduceLazy</code>는 스스로 무언가를 접지 않습니다 —
    <strong>리듀서를 만들어 냅니다</strong>. 결합 함수와 시드를 건네면
    <code>Iterable&lt;A&gt; Function</code> 타입의 평범한 함수가 돌아오고,
    시드와 결합 함수를 매번 다시 적지 않고도 원하는 만큼 여러 번, 서로 다른
    이터러블에 얼마든지 호출할 수 있습니다.
  </p>
  <p>
    내부적으로는 <code><a href="fold.html">fold</a></code>를 감싼 얇은 껍데기일
    뿐입니다. <code>reduceLazy(f, seed)</code>는
    <code>(iterable) =&gt; fold(seed, f, iterable)</code>을 반환합니다.
    <code>fold</code>와 비교하면 인자 순서가 뒤집혀 있다는 점에 주목하세요 —
    여기서는 <code>(f, seed)</code>인데, 이터러블을 일부러 나중으로 미뤄 두는
    FxTS의 커링 스타일을 따른 것입니다.
  </p>
  <p>
    이것은 (여기서 더 커링되지 않는) 평범한 Dart 함수라서 <code>Fx</code> 체인
    메서드나 <code>*Async</code> 대응 함수는 없습니다 — 다만 반환된 함수는
    <code>Iterable&lt;A&gt;</code>를 구현한 것이면 무엇이든 받으며, 여기에는
    <code>Fx&lt;A&gt;</code>도 포함됩니다. 즉 체인의 <code>.to(...)</code>에
    그대로 넣을 수 있습니다.
  </p>

  <h2>데모 1 · 재사용 가능한 합산기</h2>
  {{playground:0}}

  <h2>데모 2 · 서로 다른 리스트에 재사용하기</h2>
  <p>"어떻게 결합할지"를 한 번만 정의해 두고 어디서나 재사용하는 것이 핵심입니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>reduceLazy</code>로 <strong>최댓값</strong>을 찾는 재사용 가능한 리듀서를 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="fold.html"><code>fold</code></a> — 이 함수가 감싸는 시드 있는 리듀서 ·
    <a href="reduce.html"><code>reduce</code></a> — 시드 없는 종결 연산자 ·
    <a href="pipe.html"><code>pipe</code></a> — 이런 함수들을 파이프라인으로 조합 ·
    <a href="memoize.html"><code>memoize</code></a> — 재사용 가능한 함수를 만드는 또 다른 방법
  </div>
