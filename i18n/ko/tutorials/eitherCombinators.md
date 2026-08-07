---
slug: eitherCombinators
title: Either 조합자 — FxDart 101
description: FxDart Either 조합자 튜토리얼: map2부터 map5까지, 그리고 alt, orElse, filterOrElse를 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>Either</code> 조합자
section: 13
crumb: Either combinators
prev: either.html
prevLabel: Either
next: raise.html
nextLabel: either &amp; Raise
---
  <p class="hero-sub">합치기, 대체하기, 검증하기 — <code>map2</code>…<code>map5</code>, <code>alt</code>, <code>orElse</code>, <code>filterOrElse</code>.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <a href="either.html"><code>Either</code></a> 자체가 주는 것은
    <code>map</code>, <code>flatMap</code>, <code>fold</code>입니다. 여기
    네 메서드는 자꾸만 <code>flatMap</code> 안에 <code>if</code>를 넣는
    모양으로 흘러가던 자리들을 덮습니다.
  </p>

  <h3><code>map2</code> … <code>map5</code> — 독립적인 결과 합치기</h3>
  <p>
    여러 <code>Either</code>가 함께 성공해야 할 때 — 이름 <em>그리고</em>
    나이 <em>그리고</em> 이메일을 파싱할 때 — <code>map2</code>가 그것들을
    합치고 <strong>가장 왼쪽</strong> 실패를 남깁니다. 합치는 콜백은 모든
    갈래가 <code>Right</code>일 때만 실행됩니다. 항수는 5까지로,
    <a href="accumulate.html"><code>zipOrAccumulate2..5</code></a>,
    <code>Curry2..Curry5</code>와 같은 상한입니다.
  </p>
  <p>
    여기서 "빠른 실패"는 작업이 아니라 <em>보고</em>에 대한 이야기입니다.
    각 갈래는 이미 계산해 둔 값이므로 전부 실행되었고, 첫 실패에서 멈추는
    것은 돌려받는 답 쪽입니다. 실패를 모두 알고 싶을 때 — 잘못된 필드 네
    개를 한 번에 표시하는 폼이라면 — 그것은
    <a href="accumulate.html">누적</a>이고, <code>EitherNel</code>을 돌려주며
    <code>accumulate</code> 스코프가 필요합니다. 메시지 하나가 옳은 답일 때
    <code>map2</code>를 집으세요.
  </p>

  <h3><code>alt</code>와 <code>orElse</code> — 대체하기</h3>
  <p>
    <code>alt</code>는 대체 사다리입니다. 이걸 해 보고, 실패하면 저걸 해
    봅니다. 대안이 콜백이라서 첫 성공 이후로는 아무것도 건드리지
    않습니다 — 캐시, 그다음 디스크, 그다음 네트워크 순으로, 실제로 닿은
    만큼만 값을 치릅니다. 실패 값은 버려집니다.
  </p>
  <p>
    <code>orElse</code>는 그 실패가 중요할 때의 같은 동작입니다. 핸들러가
    실패 값을 받고 다른 실패 타입을 돌려줄 수도 있어서, 한 오류 어휘를 다른
    어휘로 옮기는 통로이기도 합니다.
  </p>
  <p>
    <a href="raise.html"><code>recover</code></a>는 더 풍부한 형제입니다.
    핸들러를 새 raise 스코프 안에서 돌리므로, 핸들러는 <code>Either</code>를
    손으로 짓는 대신 평범한 Dart 코드를 쓰고 <code>r.raise</code>를 부릅니다.
    교체할 <code>Either</code>가 이미 있으면
    <code>alt</code>/<code>orElse</code>를, 핸들러가 실제로 할 일이 있으면
    <code>recover</code>를 쓰세요.
  </p>

  <h3><code>filterOrElse</code> — 그 자리에서 검증하기</h3>
  <p>
    술어에서 떨어진 <code>Right</code>를 <code>Left</code>로 강등시킵니다.
    두 번째 콜백이 <em>그 값으로부터</em> 그것을 지어내므로, 메시지가 무엇이
    잘못됐는지 짚을 수 있습니다. <code>Left</code>는 손대지 않고 통과하며
    술어는 아예 실행되지 않습니다. 이어 붙이면 처음 실패한 검사가 이깁니다.
  </p>
  <p>
    <code>Either</code> 값 쪽으로 옮겨 놓은
    <a href="raise.html"><code>Raise.ensure</code></a>입니다. 그쪽은
    <code>either { }</code> 빌더 안에서 같은 일을 합니다. 빌더 안이라면
    <code>ensure</code>를, 이미 손에 든 값에 대해서라면 이쪽을 쓰세요.
  </p>

  <h2>데모 1 · map2와 map3</h2>
  {{playground:0}}

  <h2>데모 2 · alt, orElse, filterOrElse</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 0..149를 벗어난 나이를 직접 정한 메시지로 거절해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="either.html"><code>Either</code></a> — 이들이 확장하는 타입 ·
    <a href="raise.html"><code>either</code> &amp; <code>Raise</code></a> — 빌더 스코프, <code>ensure</code>와 <code>recover</code> ·
    <a href="accumulate.html">누적</a> — 첫 실패가 아니라 모든 실패 ·
    <a href="eitherPipelines.html">Either × 파이프라인</a> — 체인을 통해 Either 나르기
  </div>
