---
slug: debounceOn
title: debounceOn — FxDart 101
description: FxDart debounceOn 튜토리얼: 선택자가 정하는 시간 — 값마다 스트림이 잠잠한 창이 되는 debounce, delay, throttle — Duration 형태가 아니라 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>debounceOn</code>, <code>delayOn</code> &amp; <code>throttleOn</code>
section: 14
crumb: debounceOn
prev: spaceBy.html
prevLabel: spaceBy
next: retryOn.html
nextLabel: retryOn
---
  <p class="hero-sub">선택자가 정하는 시간: 값마다 언제 내보낼지를 정하는 스트림을 고릅니다 — Duration 없이 debounce, delay, throttle.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    Duration 형태는 이미
    <code><a href="debounce.html">debounce</a></code>,
    <code><a href="throttle.html">throttle</a></code>,
    <code><a href="spaceBy.html">delay</a></code>에 있습니다 — 고정된
    시계, 모든 값에 같은 대기. <code>xOn</code> 가족은 그 시계를
    <strong>선택자</strong>에 넘깁니다: 값마다 스트림을 만들고, 그
    스트림의 첫 이벤트가 값이 나갈 순간입니다. 300ms 대신 포커스가
    떠나는 순간을 기다리고, 긴 검색어는 더 길게 디바운스하고, 타이머가
    아니라 버튼이 눌릴 때 붙든 값을 풀어 주세요.
  </p>
  <p>
    <code>debounceOn(selector)</code>는 그 스트림을 잠잠한 창으로 쓰는
    트레일링 디바운스입니다. 더 새로운 값은 이전 내부를
    <strong>중단</strong>하고 새것을 시작하며, 내부의 첫 next가 대기
    중인 값을 내보내고, next 없이 완료된 내부는 그 값을
    <strong>버립니다</strong>. 소스가 닫힐 때 아직 대기 중인 값은
    흘려보내져, Duration
    <code><a href="debounce.html">debounce</a></code>와 같습니다.
  </p>
  <p>
    <code>delayOn(selector)</code>는 <em>모든</em> 값을 자기 내부가
    발화할 때까지 붙듭니다 — 중단이 없으므로, 선택자가 순서를 바꾸면
    값도 순서를 바꿉니다. Rx의 <code>delayWhen</code>과 같습니다. 닫기는
    아직 끝나지 않은 내부를 기다리고, 에러는 즉시 전달됩니다 — 붙들어
    둘 가치가 있는 것은 데이터뿐이니까요.
  </p>
  <p>
    <code>throttleOn(selector)</code>는 내부 창마다 이벤트를 최대 하나
    내보냅니다: <code>leading</code>(기본 켜짐, 스트림 형태 throttle과
    같음)은 창의 첫 값을 지키고, <code>trailing</code>은 내부가 발화할
    때 — 또는 창 한가운데 소스가 닫힐 때 — 본 가장 새로운 값을
    지킵니다. fxdart 이벤트 레이어, Rx의 선택자 형태
    <code>debounce</code>, <code>delayWhen</code>,
    <code>throttle</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 버스트, 선택자가 발화할 때 풀기</h2>
  {{playground:0}}

  <h2>데모 2 · 알림 스트림이 가라고 할 때까지 붙들기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 내부 창마다 스크롤 오프셋 하나, 리딩 엣지.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="debounce.html"><code>debounce</code></a> — Duration 형태, 그리고 콜백 래퍼 ·
    <a href="throttle.html"><code>throttle</code></a> — Duration 형태, leading과 trailing ·
    <a href="spaceBy.html"><code>delay</code></a> — 고정된 시계로 스트림 전체를 밀기
  </div>
