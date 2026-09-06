---
slug: fxPipe
title: fxPipe — FxDart 101
description: FxDart fxPipe 튜토리얼: 타입이 있는 왼쪽→오른쪽 함수 합성 — fxPipe3 또는 fxPipe(parse).then(normalise).then(score), 라이브 플레이그라운드와 함께.
heading: <code>fxPipe</code>
section: 10
crumb: fxPipe
prev: juxt.html
prevLabel: juxt
next: memoize.html
nextLabel: memoize
---
  <p class="hero-sub">타입이 있는 왼쪽→오른쪽 합성. 마지막 <code>.then</code>이 <em>곧</em> 함수입니다 — <code>.build()</code>는 없습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>pipe</code>는 값을 함수 리스트에 통과시키지만 그 리스트는
    <code>dynamic</code>입니다. <code>fxPipe</code>는 함수를 돌려주는
    타입이 있는 형태입니다:
  </p>
  <pre><code>final f = fxPipe3(parse, normalise, score);
f(line);
fx(lines).map(f);</code></pre>
  <p>
    각 <code>.then</code>이 지금까지의 체인을 돌려주므로 "끝내는"
    단계가 없습니다. 호출하거나 <code>map</code> /
    <code><a href="parallel.html">parallel</a></code>에 넘기세요.
    <code>fxPipe(parse)</code>는 곧 <code>parse</code>입니다 — 이름만
    시작을 표시합니다. <code>parse.then(normalise)</code>도 됩니다.
  </p>
  <p>
    <code>.parallel</code>을 두 번 호출하면 결과가 이 isolate로
    돌아왔다가 다시 나갑니다. 합성한 워커 하나는 홉을 한 번만 냅니다:
  </p>
  <pre><code>await fx(lines)
    .parallel(4, fxPipe3(parse, normalise, score), chunked: true)
    .toList();</code></pre>
  <p>
    결과가 <code>parallel</code> 워커일 때 각 단계는 보낼 수 있어야
    합니다. <code>juxt</code>는 반대
    방향입니다: 함수 여러 개, 입력 하나, 결과 리스트.
  </p>
  <p>
    <code>fxPipe2</code>..<code>fxPipe5</code>는 같은 단계를 클로저
    하나로 합칩니다. 뜨거운 <code>map</code>이나
    <code>parallel</code> 워커가 <code>.then</code>마다 중첩
    호출을 내지 않습니다. 인자는 5에서 끝입니다
    (<code>zipOrAccumulate2..5</code>와 같습니다). 그 이상은
    <code>.then</code>을 이어 붙이거나 합친 함수를 직접 쓰세요.
  </p>
  <p>
    <code>parallel</code>은 VM 전용이라, 아래 플레이그라운드는 같은
    합성 함수를 <code>map</code>으로 돌립니다.
  </p>

  <h2>데모 1 · parse, normalise, score</h2>
  <p>
    단계 세 개, 함수 하나. VM에서는 이것을 <code>parallel</code>에
    넘깁니다. 여기선 플레이그라운드에서 돕니다.
  </p>
  {{playground:0}}

  <h2>데모 2 · 맵 세 번과 같은 숫자</h2>
  <p>
    <code>fxPipe</code>는 새 연산자가 아니라 합성입니다.
    <code>map</code> 세 번과 합성 함수 하나가 같은 리스트를 찍습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: <code>parse</code> → <code>normalise</code> →
    <code>score</code>를 합성하고, 점수가 4 이상인 행만 남기세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="pipe.html"><code>pipe</code></a> — 같은 생각, 타입 없음, 값 위 ·
    <a href="juxt.html"><code>juxt</code></a> — 함수 여러 개, 입력 하나, 결과 리스트 ·
    <a href="map.html"><code>map</code></a> — 이 isolate에서의 같은 합성 ·
    <a href="parallel.html"><code>parallel</code></a> — 워커를 합성하면 홉을 아끼는 곳
  </div>
