---
slug: windowOn
title: windowOn — FxDart 101
description: FxDart windowOn 튜토리얼: 중첩된 살아 있는 스트림 — 개수로, 트리거로, 시계로 창을 나누고, 창이 닫히기 전에 값을 보기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>windowOn</code>, <code>windowCount</code> &amp; <code>windowEvery</code>
section: 14
crumb: windowOn
prev: chunkOn.html
prevLabel: chunkOn
next: groupsBy.html
nextLabel: groupsBy
---
  <p class="hero-sub">중첩된 살아 있는 스트림: 창이 닫히기 전에 값을 보고, 개수로, 트리거로, 시계로 회전합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="chunkOn.html">chunk</a></code>는 창이 닫히기를
    기다렸다가 <code>List</code>를 내보냅니다. <code>window*</code>
    가족은 창이 <strong>아직 열려 있는 동안</strong> 내보냅니다: 바깥
    스트림의 각 값이 중첩된 <code>FxEvents</code>이므로, 구독자는 닫히기
    전에 이벤트를 볼 수 있습니다 — 지금 이 분의 살아 있는 차트, 현재
    묶음의 누적. 그것이 전부이고, 반환 타입이
    <code>FxEvents&lt;FxEvents&lt;T&gt;&gt;</code>인 이유입니다.
  </p>
  <p>
    <code>windowCount(size)</code>는 <code>size</code>개 이벤트마다
    회전합니다; <code>startEvery</code>가 <code>size</code>보다 작으면
    겹치고, 크면 틈이 납니다. <code>windowOn(boundaries)</code>는
    listen 즉시 창을 열고 트리거 값마다 회전합니다 — 경계의 완료는
    무시되므로, 현재 창은 소스가 완료될 때까지 열려 있습니다.
    <code>windowEvery(span)</code>는 시계 형태이고,
    <code>every</code>는 그 주기로 겹치거나 틈을 내며,
    <code>maxSize</code>는 개수로 창을 일찍 닫습니다.
  </p>
  <p>
    수명은 RxJS 9를 따릅니다: <strong>바깥을 취소하면 살아 있는 내부는
    에러가 아니라 조용히 완료</strong>되어, 중첩 구독자가 깨끗이
    내려옵니다. 소스 에러는 여전히 살아 있는 내부마다 에러를 낸 뒤
    바깥에 냅니다. 그리고 내부가 스트림이므로, 마지막 값이 이전 창을
    채우며 새 창이 열리면 끝의 빈 창이 생길 수 있습니다 —
    <code>chunk*</code>는 그것을 건너뛰고, <code>window*</code>는
    건너뛰지 않습니다.
  </p>
  <p>
    <code>chunkToggle(openings, closeOf)</code>는
    <code>windowToggle</code>의 리스트 가족 대응물입니다: 열림마다
    버퍼가 시작되고, 그 열림의 <code>closeOf</code>에서 온 첫 이벤트가
    그것을 내보내며, 빈 버퍼는
    <code><a href="chunkOn.html">chunkOn</a></code>처럼 건너뜁니다.
    fxdart 이벤트 레이어, Rx의 <code>window</code>,
    <code>windowCount</code>, <code>windowTime</code>,
    <code>bufferToggle</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 둘씩 창</h2>
  {{playground:0}}

  <h2>데모 2 · 트리거로 회전</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 짧은 Duration을 걸친 살아 있는 내부.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="chunkOn.html"><code>chunk</code> / <code>chunkOn</code></a> — 같은 창을 리스트로, 닫힐 때 내보내기 ·
    <a href="windowed.html"><code>windowed</code></a> — 풀 레이어의 미끄러지는 리스트 ·
    <a href="groupsBy.html"><code>groupsBy</code></a> — 시간이 아니라 값으로 키를 단 살아 있는 내부
  </div>
