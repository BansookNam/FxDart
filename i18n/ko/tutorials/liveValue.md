---
slug: liveValue
title: LiveValue — FxDart 101
description: FxDart LiveValue 튜토리얼: 구독자를 거느린 현재 값 — 늦게 온 구독자는 최신 값부터 재생받고 이어서 라이브 갱신을 받습니다 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>LiveValue</code>
section: 14
crumb: LiveValue
prev: race.html
prevLabel: race
---
  <p class="hero-sub">구독자를 거느린 살아 있는 "현재 값": 늦게 온 구독자는 즉시 최신 값을 받고, 그 뒤의 모든 갱신을 이어 받습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    평범한 <code>Stream</code>에는 기억이 없습니다: 늦게 구독하면 다음
    이벤트가 올 때까지 아무것도 받지 못하고, 상태 — 현재 사용자, 현재
    온도, 현재 줌 — 에서 이것은 새 화면마다 빈 채로 시작한다는 뜻이
    됩니다. <code>LiveValue&lt;T&gt;</code>는 이벤트 소스로 구현한
    상태입니다: 현재 값을 보관하고, <code>add</code>가 값을 갱신하며
    구독자에게 알리고, 모든 <strong>늦은 구독자는 최신 값을 먼저
    재생받은</strong> 다음 라이브 갱신에 올라탑니다. 공백도, 빈 시작도,
    "다음 틱을 기다리세요"도 없습니다.
  </p>
  <p>
    API는 의도적으로 작습니다. 빈 채로(<code>LiveValue()</code>) 또는
    시드와 함께(<code>LiveValue.seeded(value)</code>) 생성합니다.
    <code>.value</code>로 동기적으로 읽는데 — 아무것도 설정된 적이
    없으면 <code>StateError</code>를 던지니 <code>.hasValue</code>를
    확인하거나 시드를 주세요. 상태인 척하는 조용한 <code>null</code>은
    없습니다. 구독은 <code>.live</code>를 통해 하는데 이것은
    <code><a href="fxEvents.html">FxEvents</a></code> 체인이고(map하고,
    debounce하고, 결합할 수 있습니다), 같은 피드의 평범한 Stream 뷰가
    필요하면 <code>.stream</code>입니다.
  </p>
  <p>
    <code>close()</code>는 피드를 끝냅니다: 구독자들의 스트림이 닫히고,
    이후의 <code>add</code>는 던집니다 — 다만 닫힌
    <code>LiveValue</code>도 늦은 구독자에게는 마지막 값을 재생해 준
    뒤에 그 스트림을 닫습니다. Rx를 아신다면, 이것은
    <code>BehaviorSubject</code>를 그 본질적 동작만 남기고 줄인
    것입니다. fxdart 이벤트 계층이며, FxTS의 일부가 아닙니다.
  </p>

  <h2>데모 1 · 늦은 구독자는 최신 값에서 시작한다</h2>
  {{playground:0}}

  <h2>데모 2 · value, hasValue, 그리고 close</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 라이브 상태로부터 레이블 피드 파생하기.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — <code>.live</code>는 이 체인을 그대로 말함 ·
    <a href="combineLatest.html"><code>combineLatest</code></a> — 두 라이브 피드로부터 상태 파생하기 ·
    <a href="streams.html">Stream 다리</a> — 피드를 pull 세계로 옮기기
  </div>
