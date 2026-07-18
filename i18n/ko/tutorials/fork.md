---
slug: fork
title: fork — FxDart 101
description: FxDart fork 튜토리얼: 소스를 한 번만 순회해 버퍼에 담고, 이를 여러 독립 리더로 분기합니다. 라이브 플레이그라운드 포함.
heading: <code>fork</code>
section: 6
crumb: fork
prev: reverse.html
prevLabel: reverse
next: reduce.html
nextLabel: reduce
---
  <p class="hero-sub">소스를 한 번만 순회해 버퍼에 담고, 이를 독립적이고 다시 읽을 수 있는 리더들로 분기합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    같은 Dart <code>Iterable</code> 객체를 두 번 순회하면 보통 소스도 두 번
    돌아갑니다 — <code>sync*</code> 제너레이터는 새 <code>.iterator</code>를
    요청할 때마다 처음부터 다시 시작하니까요. 값을 만드는 비용이 비쌀 때
    이는 낭비이거나 아예 잘못된 동작입니다. 네트워크 요청, 느린 계산,
    한 번만 읽을 수 있는 스트림이 그렇죠. <code>fork</code>가 이 문제를
    해결합니다. <code>fork(iterable)</code>을 <em>같은</em>
    <code>iterable</code> 객체로 호출할 때마다, 공유되며 지연 방식으로
    커지는 하나의 버퍼 위에 독립적인 커서가 만들어집니다. 몇 개의 fork가
    어떤 순서로 읽든 하부 소스는 정확히 한 번만 순회됩니다.
  </p>
  <p>
    공유는 넘겨받은 <code>iterable</code>의 동일성(내부적으로
    <code>Expando</code>를 사용)을 키로 하므로, 반드시 <em>같은 객체</em>를
    fork해야 합니다 — 겉보기에 똑같아 보이더라도 따로 만든 두 이터러블은
    안 됩니다. 각 fork는 자기 속도대로 소비할 수 있습니다. 한 fork가 앞서
    나가면 소스에서 새 값을 끌어와 공유 버퍼에 덧붙이고, 뒤처진 fork는
    이미 버퍼에 있는 값을 추가 비용 없이 다시 읽을 뿐입니다.
    <code>forkAsync</code>는 <code>FxAsyncIterable</code>에 대해 같은 방식으로
    동작하며, 여러 fork에서 동시에 발생한 하류 요구가 공유 비동기 소스를
    병렬로 끌어당기게 해 줍니다.
  </p>

  <h2>데모 1 · 소스 하나, 분기 둘, 카운터로 증명하기</h2>
  <p>
    <code>source()</code>는 값을 만들 때마다 <code>calls</code>를 증가시킵니다.
    <code>evens</code>와 <code>doubled</code>는 완전히 동일한
    <code>shared</code> 객체를 fork합니다 — 소스가 두 번 돌았다면
    <code>calls</code>는 5가 아니라 10이 되었을 겁니다:
  </p>
  {{playground:0}}

  <h2>데모 2 · 속도가 다른 fork들이 버퍼 하나를 공유합니다</h2>
  <p>
    분기 <code>a</code>가 앞서 달려 새 값 두 개를 끌어옵니다. 분기
    <code>b</code>가 처음 두 값을 요청하면 <code>a</code>가 이미 버퍼에 담아 둔
    값을 그대로 다시 읽습니다 — 두 fork 모두 아직 보지 못한 세 번째 값을
    <code>b</code>가 필요로 하기 전까지는 <code>source()</code> 호출이
    새로 일어나지 않습니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: 지금은 <code>readings</code>가 <code>fork</code> 없이 두 번
    순회되어 <code>sensor()</code>가 두 번 실행되고 <code>reads</code>가
    6이 됩니다. 각 소비자마다 <code>readings</code>를 fork해서 센서를
    한 번만 읽도록 만들어 보세요(<code>reads</code>는 3이 되어야 합니다).
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="peek.html"><code>peek</code></a> — 분기 없이 들여다보기 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 한 분기 안에서의 병렬 평가 ·
    <a href="memoize.html"><code>memoize</code></a> — 시퀀스 전체가 아니라 값 하나를 캐시
  </div>
