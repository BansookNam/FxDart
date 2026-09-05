---
slug: job-search
title: 디바운스 검색 — FxDart 101
description: 일 튜토리얼: 타이핑이 잦아들 때까지 기다리고, 최신 질의만 남기고, 타입 있는 에러로 파싱 — fxEvents, debounce, switchMap, mapEither.
heading: 디바운스 검색
section: 15
crumb: debounced search
prev: materialize.html
prevLabel: materialize
next: job-fetch.html
nextLabel: bounded concurrent fetch
---
  <p class="hero-sub">시간이 먼저, 그다음 최신 승리, 그다음 타입 있는 파싱. 체인 하나. RxDart와의 동점은 의도입니다 — 요점은 패키지를 하나 더 쓰지 않아도 된다는 것입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    검색 상자는 리스트가 아닙니다. 키 입력은 도착할 때 도착하고, 한 무리는
    마지막 질의로 접혀야 하며, 다음 질의가 도착했는데도 아직 떠 있는
    요청은 취소되어야 합니다 — 그렇지 않으면 느린 "da"가 빠른 "dart"를
    덮어씁니다. 그것은 <em>push</em> 일입니다:
    <code><a href="fxEvents.html">fxEvents</a></code> +
    <code><a href="debounce.html">debounce</a></code> +
    <code><a href="switchMap.html">switchMap</a></code>.
  </p>
  <p>
    같은 일의
    <a href="../RxDartComparison/debounced-search.html">RxDart 비교</a>는
    <strong>동점</strong>입니다. rxdart의
    <code>debounceTime</code>이 같은 발상입니다. 여기서 FxDart의 주장은
    속도가 아닙니다 — 기다림을 이길 수는 없습니다 — 이벤트 층이 pull
    파이프라인 및 타입 있는 에러와 같은 import에 있어서, 다음 단계
    (히트를 파싱하고, throw 대신 <code>Left</code>를 남기기)가 새
    라이브러리를 열지 않는다는 것입니다.
  </p>
  <p>
    <code><a href="mapEither.html">mapEither</a></code>는 전달된 각
    결과를 raise 스코프에서 돌립니다. 나쁜 페이로드는
    <code>Left</code>가 되고, 이후 질의는 그대로 도착합니다. 소스에
    <code><a href="attempt.html">attempt</a></code>를 두는 것은
    <em>throw</em>가 값이 되어야 할 때뿐입니다 — 체인이
    재시도도 한다면 <code>attempt</code>는
    <strong>다음</strong> <code>retryOn</code>, 앞이 아닙니다.
  </p>

  <h2>데모 1 · 타이핑이 잦아들 때까지</h2>
  <p>
    키 입력 일정은 시뮬레이션입니다: 한 무리, 멈춤, 질의 하나 더.
    <code>debounce(160ms)</code>는 두 번 방출합니다 —
    <code>fxd</code>와 <code>fxdart</code> — 비교 페이지와 같은
    계약입니다.
  </p>
  {{playground:0}}

  <h2>데모 2 · 최신 질의가 이기고, 그다음 타입 있는 파싱</h2>
  <p>
    <code>switchMap</code>은 질의마다 검색을 시작하고 이전 안쪽
    스트림을 취소합니다. <code>mapEither</code>는 빠진 히트를 throw가
    아니라 <code>Left</code>로 이름 붙입니다. 검색은 둘 다 시작되고,
    전달되는 결과는 최신뿐입니다.
  </p>
  {{playground:1}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="whichSurface.html">어느 표면</a> — 이것이 push인 이유 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> ·
    <a href="debounce.html"><code>debounce</code></a> ·
    <a href="switchMap.html"><code>switchMap</code></a> ·
    <a href="mapEither.html"><code>mapEither</code></a> ·
    <a href="job-fetch.html">한도 있는 동시 fetch</a> — I/O 일 ·
    <a href="../RxDartComparison/debounced-search.html">RxDart vs FxDart: debounce</a>
  </div>
