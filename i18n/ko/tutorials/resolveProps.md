---
slug: resolveProps
title: resolveProps — FxDart 101
description: FxDart resolveProps 튜토리얼: Map의 모든 값을 한 번에 await합니다. Future.wait의 맵 버전입니다.
heading: <code>resolveProps</code>
section: 9
crumb: resolveProps
prev: compactObject.html
prevLabel: compactObject
next: isMatch.html
nextLabel: isMatch
---
  <p class="hero-sub"><code>Map</code>의 모든 값을 await한 뒤 값이 모두 채워진 <code>Map</code>을 반환합니다 — <code>Future.wait</code>의 맵 버전입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>resolveProps</code>는 아주 구체적이면서도 흔한 형태의 문제를
    해결합니다. 값이 일반 값과 <code>Future</code>가 섞여 있는
    <code>Map</code>이 있고 — 예를 들어 필드 이름을 키로 삼은 여러 개의
    독립적인 API 호출 — 값이 전부 채워진 맵 전체를 하나의
    <code>Future</code>로 돌려받고 싶을 때입니다.
  </p>
  <p>
    내부 구현은 엔트리를 순회하면서 각 값을 차례로 <code>await</code>합니다.
    읽어 보면 <em>순차 실행</em>처럼 보이지만, 실제로는 전부 "한꺼번에"
    처리하는 것보다 느리지 않은 경우가 대부분입니다. Dart의
    <code>Future</code>는 await될 때가 아니라 <em>생성되는</em> 순간부터
    실행되기 때문입니다. 그래서 <code>delay(...)</code>나 이미 진행 중인
    요청을 값으로 넣어 맵을 만들었다면 — 이 함수를 쓰는 일반적인 방식이죠 —
    <code>resolveProps</code>가 맵을 받는 시점에는 이미 모두가 함께
    달리고 있습니다. 순차적인 <code>await</code> 루프는 작업 시작 시점을
    가로막는 것이 아니라, 대체로 이미 준비된 결과를 차례로 읽어 낼 뿐입니다.
    아래 데모에서 스톱워치로 이를 확인할 수 있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · Future들은 이미 겹쳐서 실행됩니다</h2>
  <p>100ms 지연이 세 개지만 전체가 300ms에 한참 못 미쳐 끝납니다 — 모두 함께 시작했기 때문입니다.</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>resolveProps</code>로 <code>requests</code>의 모든 값을 await해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="evolve.html"><code>evolve</code></a> — await 대신 변환을 하는 동기 버전 ·
    <a href="concurrent.html"><code>concurrent</code></a> — "함께 실행하기"의 이터러블 버전 ·
    <a href="delay.html"><code>delay &amp; sleep</code></a> — 데모의 Future를 만드는 데 사용 ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — Map을 처음부터 만들기
  </div>
