---
slug: take
title: take — FxDart 101
description: FxDart take 튜토리얼 — 무한 소스를 포함한 어떤 지연 파이프라인에서도 앞의 n개 값만 가져옵니다. 라이브 플레이그라운드 포함.
heading: <code>take</code>
section: 5
crumb: take
prev: compress.html
prevLabel: compress
next: takeRight.html
nextLabel: takeRight
---
  <p class="hero-sub">소스에서 앞의 <code>length</code>개 값을 담은 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>take</code>는 지연 파이프라인을 유한하게 유지하는 장치입니다.
    <code>length</code>개를 내보낸 순간 소스에서 값을 끌어오는 것을
    멈추므로, 상류는 그 이상의 요청을 받지 않습니다. <code>range</code>,
    <code>repeat</code>, <code>cycle</code> 같은 FxDart 소스는 무한할 수
    있기 때문에, 파이프라인을 애초에 안전하게 실행할 수 있게 해 주는 것이
    <code>take</code>뿐인 경우도 많습니다.
  </p>
  <p>
    데이터 우선 함수(<code>take(n, iterable)</code>)와 체인
    메서드(<code>fx(iterable).take(n)</code>) 두 가지로 제공됩니다.
    비동기 쪽에서 <code>takeAsync</code>/<code>.take()</code>는 그대로
    통과시키는 역할만 합니다. 상류를 직렬화하지 않으므로, 체인 위쪽의
    <code>concurrent(n)</code>은 <code>take</code>가 필요한 만큼을 채울
    때까지 계속 겹쳐서 값을 끌어옵니다.
  </p>

  <h2>데모 1 · 기본 사용법, 그리고 무한 소스에서 가져오기</h2>
  <p><code>cycle</code>은 입력을 영원히 반복합니다 —
    <code>take</code>가 없으면 순회가 끝나지 않습니다.</p>
  {{playground:0}}

  <h2>데모 2 · 비동기, concurrent 아래에서도 여전히 겹쳐서 실행</h2>
  <p>
    여기서는 값을 4개만 끌어오지만, 상류의 <code>concurrent(3)</code>은
    여전히 3개씩 동시에 평가합니다 — <code>take</code>가 전체를 순차
    실행으로 만들지는 않습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 대기열에서 앞의 이름 3개만 가져와 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="takeRight.html"><code>takeRight</code></a> — 앞의 n개 대신 뒤의 n개 ·
    <a href="takeWhile.html"><code>takeWhile</code></a> — 술어로 가져오기 ·
    <a href="range.html"><code>range</code></a> · <a href="cycle.html"><code>cycle</code></a> — 무한 소스 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
