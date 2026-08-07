---
slug: share
title: share — FxDart 101
description: FxDart share 튜토리얼: 여러 리스너가 이벤트 체인 한 번의 실행을 함께 쓰기, 그리고 스트림에서 바로 LiveValue 만들기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>share</code> &amp; <code>LiveValue.from</code>
section: 14
crumb: share
prev: onErrorResume.html
prevLabel: onErrorResume
next: liveValue.html
nextLabel: LiveValue
---
  <p class="hero-sub">체인 한 번의 실행, 여러 리스너 — 그리고 늦게 온 사람을 위해 최신 값을 기억하는 버전.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이 섹션의 모든 연산자는 자기만의
    <code>StreamController</code>를 만들므로, 돌려주는 체인은
    <strong>단일 구독</strong>입니다: 두 번 리슨하면 두 번째 리스너는
    <code>StateError</code>를 받습니다. 그 기본값은 의도적입니다 —
    체인을 차갑게 유지해 누군가 소비하기 전까지 아무것도 실행되지 않게
    하고, 리스너별 상태를 정직하게 지킵니다. 하지만 그것은 위젯 둘이
    같은 debounce·throttle·switchMap 피드를 두 번 만들지 않고는 함께
    볼 수 없다는 뜻이기도 합니다.
  </p>
  <p>
    <code>share()</code>가 그것을 해결합니다. <strong>첫</strong>
    리스너에서 연결하고 그때부터 모든 리스너에게 방송하므로, 몇 명이
    보고 있든 상류의 일은 한 번만 일어납니다. debounce 타이머, 소켓,
    비싼 map — 구독자마다 하나가 아니라 전부 하나씩입니다.
  </p>
  <p>
    분명히 말해 둘 한계가 하나 있습니다. Rx의 <code>share</code>에는
    없는 한계거든요. Rx는 리스너 수가 0으로 돌아갔다가 다시 오르면
    재구독하지만, 여기서는 <strong>불가능합니다</strong>. 상류 체인이
    단일 구독이라 내어 줄 두 번째 실행이 없기 때문입니다. 그래서 마지막
    리스너가 떠나면 소스는 취소되고 공유 스트림은 영영 닫힙니다 — 그
    뒤에 오는 리스너는 새 실행이 아니라 이미 닫힌 스트림을 받습니다.
    첫 이벤트 전에 모든 리스너를 붙이거나, 하나를 살려 두세요.
  </p>
  <p>
    <code>share()</code>는 <em>기억</em>하지도 않습니다: 이벤트가 지나간
    뒤에 도착한 리스너는 그냥 놓친 것입니다. 늦게 온 쪽이 현재 상태를
    알아야 할 때 — 대부분의 UI가 그렇습니다 —
    <code><a href="liveValue.html">LiveValue</a></code>가 답이고,
    <code>LiveValue.from(source)</code>과
    <code>LiveValue.seededFrom(seed, source)</code>이 스트림에서 바로
    하나를 만듭니다. 이들은 <strong>뜨겁습니다</strong>: 구독이 즉시
    열리므로 아무도 리슨하기 전에 도착한 값도 <code>value</code>를
    갱신하고, <code>close()</code>는 소스를 취소합니다. 선택적 시드가
    아니라 이름 붙은 생성자인 것은 널 가능한 <code>T</code>도 null로
    시드할 수 있게 하기 위해서입니다. fxdart 이벤트 레이어, Rx의
    <code>share</code>와 <code>shareValue</code>를 따랐습니다.
  </p>

  <h2>데모 1 · 왜 리스너 하나가 기본값인가</h2>
  {{playground:0}}

  <h2>데모 2 · 한 번의 실행, 두 리스너</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 스트림에서 바로 만든 <code>LiveValue</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="liveValue.html"><code>LiveValue</code></a> — 기억하는 공유: 늦은 구독자가 현재 값을 먼저 받음 ·
    <a href="tee.html"><code>tee</code></a> — 한 번의 순회에 독자 둘, 버퍼 없이 — 풀 쪽의 답 ·
    <a href="fork.html"><code>fork</code></a> — 한 소스에 독립적인 풀 커서 둘, 버퍼를 대가로
  </div>
