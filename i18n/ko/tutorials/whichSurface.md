---
slug: whichSurface
title: 어느 표면? — FxDart 101
description: FxDart 결정 페이지: 일이 어느 표면에 속하는지 — 손에 든 데이터는 fx(), 한도가 있는 I/O는 concurrent, 시간은 fxEvents, 호출자가 다루는 실패는 Either.
heading: 어느 표면?
section: 1
crumb: which surface
next: fx.html
nextLabel: fx
---
  <p class="hero-sub">표면은 넷, import는 하나. 일의 표면을 고르고, 그 위에 머무르세요.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    FxDart는 트렌치코트 안의 라이브러리 네 개가 아닙니다. 실제 프로그램이
    이 일들을 가로지르기 때문에 한 패키지이고, 가로지를 때도 이름은
    그대로입니다. 실수는 함수 목록에서 시작하는 것입니다. 일에서
    시작하세요:
  </p>
  <table>
    <tr><th>일이…</th><th>여기서 시작</th><th>하지 말 것</th></tr>
    <tr>
      <td>데이터는 이미 손에 있고, 그중 일부만 필요</td>
      <td><code><a href="fx.html">fx(iterable)</a></code></td>
      <td>한 줄짜리 <code>map</code>/<code>where</code>/<code>take</code>를 감싸기</td>
    </tr>
    <tr>
      <td>아는 컬렉션 위의 I/O, 동시에 최대 <em>n</em>개, 순서는 유지</td>
      <td><code>.toAsync().map(f).concurrent(n)</code> 또는 <code><a href="mapConcurrent.html">.mapConcurrent(n, f)</a></code></td>
      <td><code>Future.wait(xs.map(f))</code></td>
    </tr>
    <tr>
      <td>값이 도착할 때 도착 (키 입력, 틱, 소켓)</td>
      <td><code><a href="fxEvents.html">fxEvents(stream)</a></code></td>
      <td><code>sleep</code>을 넣은 pull 파이프라인</td>
    </tr>
    <tr>
      <td>호출자가 실패를 다룸</td>
      <td>이미 있는 표면 위의 <code><a href="raise.html">either</a></code> / <code><a href="mapEither.html">mapEither</a></code> / <code><a href="attempt.html">attempt</a></code></td>
      <td>도메인 에러에 <code>throw</code>; 이유를 잃은 <code>null</code></td>
    </tr>
  </table>
  <p>
    이름이 충돌하면 pull이 이깁니다. <code>takeUntil</code>은 FxTS의
    술어이고, 이벤트 층의 짝은
    <code><a href="stopOn.html">stopOn</a></code>입니다.
    단어 하나, 뜻 하나. 이음새는 이름이 있습니다:
    <code>.toAsync()</code>는 데이터를 수요로 올리고,
    <code>.pull()</code>은 이벤트를 수요로 올리고,
    <code>.toStream()</code>은 반대 방향입니다.
  </p>

  <div class="callout">
    <strong>0.8.10 채널 규칙.</strong>
    <code>attempt</code>는
    <strong>다음</strong>
    <code><a href="retryOn.html">retryOn</a></code> /
    <code>retryOnError</code>, 앞이 아닙니다.
    그 연산자들은 에러 채널을 보고, 실패가 <code>Left</code>가 되면
    거기에는 재시도할 것이 남지 않습니다.
  </div>

  <p>
    표면을 가로지르는 일 두 가지는 제각기 튜토리얼입니다:
    <a href="job-search.html">디바운스 검색</a> (시간 → 최신 질의 승리 →
    타입 있는 파싱)과
    <a href="job-fetch.html">한도 있는 동시 fetch</a> (한도, 순서 유지,
    실패는 모두 보관). pull 입문은 여전히
    <a href="fx.html"><code>fx</code></a>에서 시작합니다.
  </p>

  <h2>데모 · 일 넷, 표면 넷</h2>
  <p>
    import는 같습니다. 각 블록은 표의 그 행에 속하는 가장 작은
    프로그램입니다:
  </p>
  {{playground:0}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="fx.html"><code>fx</code></a> — pull 체인 ·
    <a href="concurrent.html"><code>concurrent</code></a> — I/O 한도 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — push 체인 ·
    <a href="typedErrors.html">타입 있는 에러</a> — 값으로서의 실패 ·
    <a href="job-search.html">디바운스 검색</a> ·
    <a href="job-fetch.html">한도 있는 동시 fetch</a>
  </div>
