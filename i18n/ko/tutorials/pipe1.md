---
slug: pipe1
title: pipe1 — FxDart 101
description: FxDart pipe1 튜토리얼: 값에 함수 하나를 적용하되, 값이 Future라면 먼저 await합니다.
heading: <code>pipe1</code>
section: 1
crumb: pipe1
prev: pipe.html
prevLabel: pipe
next: toList.html
nextLabel: toList
---
  <p class="hero-sub">값에 함수 하나를 적용합니다. 값이 Future라면 먼저 await합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>pipe1</code>은 <code>pipe</code>가 내부적으로 사용하는 한 단계짜리
    빌딩 블록입니다. <code>a</code>에 <code>f</code>를 적용하되,
    <code>a</code>가 <code>Future</code>라면 먼저 await합니다.
    <code>a</code>가 평범한 값이면 <code>f</code>가 즉시 실행되고
    <code>pipe1</code>은 <code>f</code>가 반환한 값을 그대로 —
    <code>Future</code>로 감싸지 않고 동기적으로 — 돌려줍니다.
  </p>
  <p>
    핵심은 <code>f</code> 자신은 넘겨받은 값이 상류의 동기 작업에서 왔는지
    비동기 작업에서 왔는지 알 필요도, 신경 쓸 필요도 없다는 점입니다 —
    <code>pipe1</code>이 그 차이를 대신 흡수해 줍니다. 값이
    <em>때로는</em> <code>Future</code>가 되는 상황(예: 앞선 비동기 단계의
    결과)에서 다음 단계를 어느 쪽이든 똑같은 모습으로 쓰고 싶을 때
    유용합니다.
  </p>
  <p>
    한 단계만 처리하므로, 짧은 체인을 만들려면 <code>pipe1</code> 호출을
    중첩하면 되고, 단계가 두어 개를 넘어가면
    <code>List&lt;Function&gt;</code>을 받는 <code>pipe</code>를 쓰는 편이
    낫습니다.
  </p>

  <h2>데모 1 · 평범한 값(Future가 아닌 값)</h2>
  <p><code>Future</code>가 끼어들지 않으면 <code>pipe1</code>은
    <code>f(a)</code>를 그대로 호출하고 평범한 값을 반환합니다.</p>
  {{playground:0}}

  <h2>데모 2 · Future를 먼저 await하기</h2>
  <p>
    <code>a</code>가 <code>Future</code>라면 <code>pipe1</code>은
    <code>f</code>를 호출하기 전에 await합니다 — 이런 호출을 몇 개
    이어 붙이면 비동기 단계를 하나씩 조합할 수 있습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>pipe1</code>로 지연된 이름을 인사말로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="pipe.html"><code>pipe</code></a> — pipe1로 만들어진 다단계 파이프라인 ·
    <a href="fx.html"><code>fx</code></a> — 타입이 유지되는 체인 대안 ·
    <a href="delay.html"><code>delay &amp; sleep</code></a> — 위에서 쓴 비동기 헬퍼
  </div>
