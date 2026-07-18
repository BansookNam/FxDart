---
slug: reduce
title: reduce — FxDart 101
description: FxDart reduce 튜토리얼: 첫 번째 원소를 시드로 삼아 파이프라인을 값 하나로 접는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>reduce</code>
section: 7
crumb: reduce
prev: fork.html
prevLabel: fork
next: fold.html
nextLabel: fold
---
  <p class="hero-sub">첫 번째 원소를 시작 시드로 삼아 파이프라인을 값 하나로 접습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>reduce</code>는 <strong>종결</strong> 연산자입니다. <code>map</code>이나
    <code>filter</code>와 달리 호출하는 즉시 뒤에 있는 지연 파이프라인 전체에서
    모든 값을 끌어당겨 구체적인 결과 하나를 만들어 냅니다. 이런 종결 연산자를
    호출하기 전까지 상류에서는 아무것도 실행되지 않습니다.
  </p>
  <p>
    이것은 <em>시드가 없는</em> 형태입니다. 이터러블의 첫 번째 원소를 시작
    누산기로 삼은 뒤 나머지를 거기에 합쳐 나갑니다. 그래서 빈 이터러블에
    호출하는 것은 말이 되지 않고 — 시드로 삼을 첫 원소가 없으니까요 —
    <code>StateError</code>를 던집니다.
  </p>
  <p>
    FxTS는 인자 개수로 <code>reduce</code>의 시드 있는 형태와 없는 형태를
    오버로드합니다 — <code>reduce(f, iterable)</code> 대
    <code>reduce(f, seed, iterable)</code>처럼요. Dart에는 인자 개수 기반
    오버로딩이 없기 때문에, FxDart는 <code>reduce</code>를 시드 없는 형태로
    남기고 시드 있는 쪽은 <code><a href="fold.html">fold</a></code>로 이름을
    바꿨습니다 — Dart 자체의 <code>Iterable.fold</code> 명명과 맞춘 것입니다.
    시드가 있다면 <code>fold</code>를 쓰세요.
  </p>
  <p>
    동기 체인에서는 <code>Fx</code>가 <code>Iterable</code>을 확장하므로
    <code>.reduce(f)</code>는 그냥 Dart 내장 메서드입니다 — 계약도, 빈 입력에서
    <code>StateError</code>가 나는 것도 동일합니다. 비동기 체인에서는
    <code>FxAsync.reduce</code>가 별도로 구현되어 있으며 각 결합 단계마다
    await 합니다.
  </p>

  <h2>데모 1 · 기본 사용법 &amp; 빈 입력 에러</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  <p>
    <code>reduce</code>는 뒤에 있는 파이프라인 전체를 끌어당깁니다 —
    <code>.concurrent(n)</code> 단계까지 포함해서요. 이 단계는 상류 값을
    한 번에 <code>n</code>개씩 평가하고, <code>reduce</code>는 값이 순서대로
    도착하는 대로 결합합니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>reduce</code>로 리스트에서 <strong>가장 긴</strong> 단어를 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="fold.html"><code>fold</code></a> — 시드가 있는 짝 ·
    <a href="reduceLazy.html"><code>reduceLazy</code></a> — 재사용 가능한 커링된 리듀서 ·
    <a href="sum.html"><code>sum</code></a> — 숫자에 특화된 reduce ·
    <a href="concurrent.html"><code>concurrent</code></a> — 상류에서의 병렬 평가
  </div>
