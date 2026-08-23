---
slug: fxEvents
title: fxEvents — FxDart 101
description: FxDart fxEvents 튜토리얼: 이벤트 계층 — 평범한 Dart Stream 위의 체이닝 가능한 래퍼로, map, where, merge, startWith와 pull() 다리를 갖춥니다 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>fxEvents</code>
section: 14
crumb: fxEvents
next: fxEventsCreate.html
nextLabel: fxEventsCreate
---
  <p class="hero-sub">평범한 Dart <code>Stream</code>을 체이닝 가능한 <code>FxEvents</code>로 감쌉니다 — FxDart push 세계로 들어가는 입구입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이 섹션 이전의 모든 것은 <em>pull</em>이었습니다: 파이프라인은 종결
    연산자가 다음 항목을 요구할 때까지 가만히 있습니다. 하지만 어떤
    문제는 본질적으로 <em>push</em>입니다 — 키 입력, 센서 판독값, 소켓
    메시지는 누가 요청했든 아니든 올 때가 되면 옵니다. 그것이 바로
    Dart의 <code>Stream</code>이 모델링하는 세계이고,
    <code>fxEvents(stream)</code>은 그 세계에 같은 체이닝 경험을
    제공합니다: <code>map</code>, <code>where</code>,
    <code>asyncMap</code>, <code>startWith</code>,
    <code>FxEvents.merge</code> — 그리고 이 섹션의 나머지가 다루는
    시간·결합 연산자들까지.
  </p>
  <p>
    알아 둘 만한 설계 결정들입니다. <code>FxEvents</code>는 얇은
    <strong>래퍼</strong>이며, 의도적으로 <code>Stream</code> 확장의
    집합이 아닙니다 — 그래서 그 연산자들이 같은 파일 안에서 rxdart나 다른
    어떤 스트림 라이브러리와도 절대 충돌하지 않습니다. 예외는 진입용
    <code>.fxEvents</code> getter 하나뿐이고, 다른 어디서도 쓰지 않는
    이름입니다. <code>.fx</code>와 나란히 놓고 비교한 표는
    <a href="streams.html">Stream 다리</a>에 있습니다. 체인은
    <strong>콜드</strong>로 유지됩니다: 감싸는 것만으로는 아무것도 듣지
    않고, 종결 연산자(<code>toList</code>, <code>head</code>,
    <code>listen</code>)만이 이벤트를 흐르게 합니다. 그리고 이것은 Rx에서
    영감을 받은 fxdart의 확장이지 FxTS의 일부가 아닙니다 — 아이디어는
    Rx에서 왔지만, 이름이 pull 계층과 겹칠 때는 pull 쪽 표기가 이깁니다.
    <code>uniqAdjacent</code>가 <code>distinctUntilChanged</code>를,
    <code>stopOn</code>이 <code>takeUntil</code>을, <code>head</code>가
    <code>first</code>를 대신합니다. 한 단어는 양쪽에서 한 가지를
    뜻합니다.
  </p>
  <p>
    두 개의 탈출구가 여러분을 가두지 않게 지켜 줍니다.
    <code>.stream</code>은 체인의 어느 지점에서든 Stream 기반 API를 위해
    평범한 <code>Stream</code>으로 되돌려 풉니다. 그리고
    <code>.pull()</code>은 타입 있는 pull 세계로 건너갑니다: 이벤트들이
    <code><a href="toAsync.html">FxAsync</a></code> 체인이 되어 그때부터는
    요청에 따라 pull됩니다 — 이벤트가 태어나는 가장자리에서는 push,
    수요를 통제하는 중심부에서는 pull입니다.
  </p>

  <h2>데모 1 · Stream 위의 콜드 체인</h2>
  {{playground:0}}

  <h2>데모 2 · merge, 그리고 pull 세계로 건너가기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 튀는 값이 섞인 센서 피드를 정리해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="streams.html">Stream 다리</a> — 경계의 pull 쪽, 그리고 <code>stream.fx</code>와 <code>stream.fxEvents</code>의 비교 ·
    <a href="debounce.html"><code>debounce</code></a> &amp; <a href="throttle.html"><code>throttle</code></a> — 둘 다 <code>FxEvents</code> 형태가 있음 ·
    <a href="liveValue.html"><code>LiveValue</code></a> — 이 체인의 현재-값 동반자
  </div>
