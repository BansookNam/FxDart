---
slug: retryOn
title: retryOn — FxDart 101
description: FxDart retryOn 튜토리얼: 에러나 완료에서 다시 구독하기 — 재시도 예산, 지연, 또는 시점을 정하는 알림 스트림 — 그리고 whenComplete 정리까지 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>retryOn</code>, <code>repeat</code> &amp; <code>whenComplete</code>
section: 14
crumb: retryOn
prev: debounceOn.html
prevLabel: debounceOn
next: onErrorResume.html
nextLabel: onErrorResume
---
  <p class="hero-sub">에러나 완료에서 다시 구독합니다 — 예산으로, 지연으로, 또는 다시 시도할 때를 정하는 알림 스트림으로.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    풀 레이어의 <code><a href="retry.html">retry</a></code>는 이터러블을
    다시 만듭니다. 푸시 쪽에서 같은 생각은
    <strong>재구독</strong>이고, 모양은 두 가지입니다. 하나는 팩토리로
    스트림을 다시 만드는 것이고 —
    <code><a href="onErrorResume.html">FxEvents.retry</a></code>, 이미
    다뤘습니다 — 한 번짜리 <code>StreamController</code>에 맞는
    수입니다. 다른 하나는 같은 스트림을 다시 듣는 것이고, 이 페이지가
    그것입니다: <code>retryOnError</code>, <code>retryOn</code>,
    <code>repeat</code>, <code>repeatOn</code>.
  </p>
  <p>
    다시 들으려면 소스가 그것을 허용해야 합니다.
    <code>Stream.multi</code>, <code>Stream.fromIterable</code>,
    브로드캐스트는 모두 되고, 이미 쓰인 단일 구독 컨트롤러는 두 번째
    listen에서 에러가 납니다. 소스가 한 번짜리일 때는
    <code><a href="onErrorResume.html">FxEvents.retry</a></code>
    (또는 <code>FxEvents.defer</code>)를 쓰세요.
  </p>
  <p>
    <code>retryOnError({count, delay})</code>는 에러에서 다시 구독합니다
    — <code>count</code>가 null이면 영원히, 아니면 그 횟수만큼의
    <em>재시도</em> (<code>count: 2</code>는 시도 세 번).
    <code>delay</code>가 있으면 각 재시도 전에 1부터 세는 재시도
    번호로 물어봅니다. 예산을 다 쓰면 마지막 에러를 전달하고 스트림을
    닫습니다.
  </p>
  <p>
    <code>retryOn(notifier)</code>은 Rx의 <code>retryWhen</code>입니다:
    에러는 <strong>전달되지 않고</strong> <code>notifier</code>로
    밀어 넣어지며, 그 스트림의 next가 다시 구독합니다. 알림 스트림이
    완료되면 에러 없이 결과가 완료되고, 알림 스트림의 에러는
    전달됩니다. <code>repeat</code> / <code>repeatOn</code>은 에러가
    아니라 <strong>완료</strong>에서 같은 쌍입니다 — 에러는 전달되고
    멈춥니다. <code>whenComplete</code>는 Rx <code>finalize</code>입니다:
    콜백은 완료, 에러, 취소에서 정확히 한 번 실행됩니다. fxdart 이벤트
    레이어, Rx의 <code>retryWhen</code>, <code>retry</code>,
    <code>repeat</code>, <code>repeatWhen</code>,
    <code>finalize</code>를 따랐습니다.
  </p>

  <h2>데모 1 · retryOnError, 지연과 함께</h2>
  {{playground:0}}

  <h2>데모 2 · 짧은 스트림을 두 번 반복</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: retryOn — 다시 구독할 때는 알림 스트림이 정합니다.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="onErrorResume.html"><code>FxEvents.retry</code></a> — 다시 들을 수 없는 소스를 위한 팩토리 형태 ·
    <a href="retry.html"><code>retry</code></a> — 백오프 훅과 원소 단위 범위를 가진 풀 레이어의 원본 ·
    <a href="timeout.html"><code>timeout</code></a> — 얼마나 자주가 아니라 한 번의 풀이 얼마나 걸릴 수 있는지를 제한
  </div>
