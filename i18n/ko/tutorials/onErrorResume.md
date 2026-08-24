---
slug: onErrorResume
title: onErrorResume — FxDart 101
description: FxDart onErrorResume 튜토리얼: 에러마다 값으로 대체하기, 대체 스트림으로 갈아타기, retry로 스트림 전체를 다시 만들기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>onErrorReturn</code>, <code>onErrorResume</code> &amp; <code>retry</code>
section: 14
crumb: onErrorResume
prev: retryOn.html
prevLabel: retryOn
next: attempt.html
nextLabel: attempt
---
  <p class="hero-sub">복구의 세 깊이: 에러마다 값으로 때우거나, 소스를 버리고 대체물로 갈아타거나, 스트림 전체를 버리고 다시 만들거나.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    푸시 쪽에서 에러는 다르게 행동하고, 그 차이가 사람들을 넘어뜨립니다.
    풀 파이프라인에서 예외는 순회를 끝냅니다 — 실패 하나, 그리고
    아무것도 없음. Dart <code>Stream</code>에서 에러는 그저 또 하나의
    <strong>이벤트</strong>입니다: 전달되고, 구독은 계속됩니다. 스트림
    하나가 에러 열 개와 값 마흔 개를 내보내고도 정상적으로 닫힐 수
    있습니다.
  </p>
  <p>
    그래서 <code>onErrorReturn(value)</code>은 한 번의 구조가 아니라
    <em>에러마다의 대체</em>입니다. 모든 에러가 하나의
    <code>value</code> 이벤트가 되고 스트림은 계속 갑니다 — 나쁜 판독이
    자리표시자가 되고 피드는 살아남아야 하는 불안정한 센서에 맞습니다.
  </p>
  <p>
    <code>onErrorResume(f)</code>이 한 번의 전환입니다.
    <strong>첫</strong> 에러에서 소스는 그 자리에서 취소되고,
    <code>f</code>가 그 에러로부터 만든 스트림이 영원히 넘겨받습니다 —
    네트워크 실패 시 캐시로 가는 수입니다. 원래 소스의 것은 더 이상
    보이지 않고, <code>f</code> 자신이 던진 에러는 삼켜지지 않고
    전달됩니다.
  </p>
  <p>
    <code>FxEvents.retry(factory, [count])</code>는 한 층 위에서
    작동합니다. 스트림의 에러를 때우는 것이 아니라 <strong>스트림을 다시
    만듭니다</strong>. 에러가 나면 실패한 시도를 버리고
    <code>factory()</code>를 다시 불러 새 구독을 얻습니다 — 실패한 것이
    연결 자체일 때 맞는 모양입니다. 예산은 <em>재</em>구독을 세므로
    <code>count: 2</code>는 최대 세 번의 시도를 허용하고, 다 쓰면 마지막
    에러를 전달하고 스트림을 닫습니다. 어떤 시도가 이미 내보낸 이벤트는
    되돌려지지 않으므로, 팩토리는 다시 재생 가능한 것을 만들어야 합니다.
  </p>
  <p>
    fxdart 이벤트 레이어, Rx의 <code>onErrorReturn</code>,
    <code>onErrorResume</code>, <code>Rx.retry</code>를 따랐습니다.
    복구할 대상이 아니라 <em>모델링</em>하고 싶은 실패라면, 풀 쪽의
    <code><a href="either.html">Either</a></code>와
    <code><a href="raise.html">Raise</a></code>가 그것을 타입 있는 값으로
    만들어 줍니다 — <a href="either.html">타입 있는 에러</a>를 보세요.
  </p>

  <h2>데모 1 · 에러마다 값 하나</h2>
  {{playground:0}}

  <h2>데모 2 · 소스를 버리고 대체물로</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 불안정한 스트림 다시 만들기, 예산이 있을 때와 없을 때.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="retry.html"><code>retry</code></a> — 백오프 훅과 원소 단위 범위를 가진 풀 레이어의 원본 ·
    <a href="either.html"><code>Either</code></a> — 복구할 이벤트가 아니라 타입 있는 값으로서의 에러 ·
    <a href="race.html"><code>race</code></a> — 먼저 에러를 낸 후보가 그 에러로 이김
  </div>
