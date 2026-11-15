---
slug: mapCatching
title: mapCatching — FxDart 101
description: FxDart mapCatching 튜토리얼 — 원소마다 에러를 그 자리에서 복구해 잘못된 행 하나가 파이프라인을 끝내지 않게 합니다. 동기와 비동기 모두, 타입 있는 에러는 건드리지 않습니다.
heading: <code>fxMapCatching</code>
section: 11
crumb: mapCatching
prev: retry.html
prevLabel: retry
next: timeout.html
nextLabel: timeout
---
  <p class="hero-sub">원소마다의 실패를 값으로 대체하는 <code>map</code> — 잘못된 행 하나가 순회를 끝내지 않습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    콜백이 예외를 던지는 <code><a href="map.html">map</a></code>은 그
    원소에서 파이프라인 전체를 끝냅니다. 만 개 중 잘못된 행이 하나만 있어도
    9,999개의 결과가 아니라 예외를 받게 됩니다.
    <code>mapCatching(f, onError)</code>는 각 원소에 <code>f</code>를
    실행하고, 예외가 나면 에러와 스택 트레이스를 <code>onError</code>에
    넘겨 그 반환값을 <em>실패한 원소의 자리에</em> 내보냅니다. 다음 원소는
    아무 일도 없었던 것처럼 매핑됩니다. 지연 평가를 유지하며,
    <code>Fx</code>에서는 동기 체인에 그대로 머뭅니다 — 기다릴 것이 없기
    때문입니다.
  </p>
  <p>
    <code><a href="retry.html">mapRetry</a></code> 옆에 놓이며, 둘은 실패한
    원소에 대한 두 가지 대답입니다. <code>mapRetry</code>는 그 원소를
    <em>다시</em> 실행하고, <code>mapCatching</code>은 포기하고 대체합니다.
    비동기 형태인 <code>fxMapCatchingAsync</code> /
    <code>fxAsync(…).mapCatching</code>은 <code>f</code>와
    <code>onError</code> 모두 await할 수 있고, 병렬 안전한
    <code>fxMapAsync</code> 위에 만들어졌으므로
    <code><a href="concurrent.html">concurrent(n)</a></code> 아래에서 진행
    중인 각 원소가 따로 복구되고 순서도 유지됩니다. RxDart는 이를
    <code>onErrorReturnWith</code>라고 씁니다. fxdart
    <a href="fxEvents.html">푸시 스트림</a>에서 이웃하는 연산자는
    <a href="onErrorResume.html"><code>onErrorReturn</code></a>(에러마다
    고정된 값 하나로 대체)과
    <a href="attempt.html"><code>attempt</code></a>(에러를 대체하지 않고
    <code>Left</code>로 보존)입니다.
  </p>
  <p>
    <strong>절대</strong> 복구되지 않는 것이 하나 있습니다. 라이브러리 자체의
    raise 신호입니다. <code>bind</code>, <code>ensure</code>, 혹은 중첩된
    빌더에서 나온 <code>r.raise(…)</code>가 <code>f</code>를 가로지르면 다시
    던져지므로, 바깥의 <a href="raise.html"><code>fxEither</code></a> /
    <a href="nullable.html"><code>fxNullable</code></a> 블록을 여전히
    단락합니다. 이것을 복구하면 타입 있는 에러가 사라진 에러로 바뀝니다.
    raise 블록 안의 지연 파이프라인이 늘 그렇듯, 블록 안에서 구체화
    (<code>toList()</code>)하세요. fxdart 확장 기능입니다(FxTS에는 없습니다).
  </p>

  <h2>데모 1 · 잘못된 행 하나를 그 자리에서 복구</h2>
  {{playground:0}}

  <h2>데모 2 · concurrent 아래의 비동기, 그리고 통과하는 raise</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>try</code>/<code>catch</code> 루프를 연산자 하나로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="retry.html"><code>retry</code></a> — 대체하는 대신 그 원소를 다시 실행 ·
    <a href="onErrorResume.html"><code>onErrorReturn</code></a> — 푸시 스트림에서의 같은 발상 ·
    <a href="eitherPipelines.html">타입 있는 에러</a> — 실패를 살펴볼 수 있는 값으로 남겨야 할 때
  </div>
