---
slug: entries
title: entries — FxDart 101
description: FxDart entries 튜토리얼: Map의 (키, 값) 쌍을 체이닝에 바로 쓸 수 있는 레코드의 지연 이터러블로 바꿉니다.
heading: <code>entries</code>
section: 2
crumb: entries
prev: cycle.html
prevLabel: cycle
next: keys.html
nextLabel: keys
---
  <p class="hero-sub">Map의 (키, 값) 쌍을 레코드로 내보냅니다 — Map을 체이닝하기 위한 진입점입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    Dart의 <code>Map</code>은 <code>Iterable</code>이 아닙니다.
    <code>List</code>와는 달라서 <code>fx(someMap)</code>을 바로 쓸 수
    없죠. <code>entries</code>가 그 다리 역할을 합니다. 맵의 각 키/값
    쌍을 <code>(K, V)</code> 레코드로 내보내서, 평범한 지연
    <code>Iterable</code>을 만들어 줍니다. 이건 <em>실제로</em>
    <code>fx()</code>로 감쌀 수 있고, 다른 것들처럼 체이닝하면 됩니다. JS 객체에 대해
    같은 일을 하는 FxTS의 <code>entries</code>를 그대로 옮긴 것입니다.
  </p>
  <p>
    쌍이 Dart 레코드이므로 <code>for</code> 루프에서 바로 구조 분해할 수
    있고 — <code>for (final (key, value) in entries(map))</code> —
    구조 분해가 불편한 경우에는
    <code>map</code>/<code>filter</code> 콜백 안에서 위치 필드
    <code>.$1</code>(키)과 <code>.$2</code>(값)로 접근하면 됩니다.
  </p>
  <p>
    <code>entries</code>도 여기 나오는 다른 것들처럼 지연 평가되지만,
    <code>Map</code>의 엔트리는 무한하지 않으므로 <code>take</code>로
    범위를 제한할 이유는 거의 없습니다 — 얼마나 끌어올지 조절하기보다는
    Map을 체이닝 가능한 형태로 바꾸는 쪽에 가깝습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · Map을 체이닝하기</h2>
  <p><code>entries(map)</code>을 <code>fx()</code>로 감싸서 Map의 내용을
    필터링하고 다시 빚어 보세요:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 점수가 담긴 Map을 "name: PASS/FAIL" 문자열로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="keys.html"><code>keys</code></a> — Map의 키만 ·
    <a href="values.html"><code>values</code></a> — Map의 값만 ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — 그 역방향: 쌍으로부터 다시 Map을 만듭니다 ·
    <a href="fx.html"><code>fx</code></a> — entries의 결과가 흘러 들어가는 체인
  </div>
