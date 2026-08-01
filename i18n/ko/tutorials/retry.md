---
slug: retry
title: retry — FxDart 101
description: FxDart retry와 mapRetry 튜토리얼: 불안정한 효과를 백오프와 함께, 원소 단위 또는 파이프라인 단위로, 병렬 안전하게 다시 실행하는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>retry</code>
section: 11
crumb: retry
prev: concurrentPool.html
prevLabel: concurrentPool
next: timeout.html
nextLabel: timeout
---
  <p class="hero-sub">불안정한 효과를 성공할 때까지 다시 실행합니다 — 최대 <code>attempts</code>번, 실패 사이에 선택적 백오프를 두고서.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    실제 파이프라인은 실제 서비스를 호출하고, 실제 서비스는 가끔
    실패합니다. 손으로 짠 답은 <code>try</code>/<code>catch</code>와
    카운터, <code>Future.delayed</code>를 갖춘 <code>for</code> 루프 —
    프로젝트마다 복사되면서 매번 미묘하게 달라지는 코드입니다.
    <code>retry(attempts, f)</code>는 그 루프를 한 번으로 정리한
    것입니다. <code>f</code>를 실행하고, 에러가 나면 다시 실행하되 총
    <code>attempts</code>번까지만 실행합니다. 예산이 다 떨어지면
    <em>마지막</em> 에러가 원래 스택 트레이스와 함께 다시 던져집니다.
    <code>delay</code> 훅은 실패 횟수(<code>1, 2, …</code>)를 받으므로
    백오프는 한 줄이면 됩니다:
    <code>delay: (failed)&nbsp;=&gt;&nbsp;Duration(seconds:&nbsp;failed)</code>.
  </p>
  <p>
    <code>mapRetry(attempts, f)</code>는 같은 아이디어를 원소 단위로 적용한
    것입니다. 모든 호출이 각자의 재시도 예산을 갖는
    <code><a href="map.html">map</a></code>입니다. 병렬 안전한
    <code>mapAsync</code> 위에 만들어져 있어서
    <code><a href="concurrent.html">concurrent(n)</a></code> 아래에서는
    진행 중인 각 원소가 <em>독립적으로</em> 재시도합니다 — 느리고
    불안정한 항목 하나가 다시 실행되는 동안 이웃들은 그대로 지나가고,
    순서는 여전히 보존됩니다. 파이프라인 전체를 재시도하려면 대신
    종단을 감싸세요:
    <code>retry(3, ()&nbsp;=&gt;&nbsp;fxAsync(…).toList())</code> —
    부분 결과는 버려지고 파이프라인은 새 이터레이터에서 처음부터 다시
    실행됩니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다). Rx의
    <code>retry</code>/<code>retryWhen</code>을 따르되, "재구독"이
    "이터러블을 다시 만든다"를 뜻하는 pull 모델에 맞춰 다시
    설계했습니다. 재시도가 소진된 뒤의 <em>타입이 있는</em> 실패 처리는
    결과를
    <code><a href="eitherPipelines.html">eitherCatching</a></code>에
    넘기세요.
  </p>

  <h2>데모 1 · 불안정한 fetch, 백오프와 함께</h2>
  {{playground:0}}

  <h2>데모 2 · concurrent 아래의 mapRetry</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 불안정한 행이 있어도 임포트가 살아남게 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="timeout.html"><code>timeout</code></a> — 각 pull이 걸릴 수 있는 시간에 한도 두기 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 진행 중인 원소마다 재시도가 독립적으로 유지됨 ·
    <a href="eitherPipelines.html">타입 있는 에러</a> — 실패가 예외가 아니라 값이어야 할 때
  </div>
