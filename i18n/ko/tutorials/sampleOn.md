---
slug: sampleOn
title: sampleOn — FxDart 101
description: FxDart sampleOn 튜토리얼: 트리거 스트림이 발화할 때마다 소스의 최신 값을 내보내기 — 빠른 생산자와 느린 소비자의 분리 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>sampleOn</code>
section: 14
crumb: sampleOn
prev: whenComplete.html
prevLabel: whenComplete
next: combineLatest.html
nextLabel: combineLatest
---
  <p class="hero-sub">트리거 스트림이 발화할 때마다 소스의 최신 값을 내보냅니다 — 값은 소스가 정하고, 리듬은 트리거가 정합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    센서는 초당 이백 번 갱신되는데, 디스플레이는 육십 번 다시 그립니다.
    모든 갱신을 처리하는 것은 낭비입니다 — 소비자가 진짜 원하는 것은
    <em>자기 일정에 맞춘 최신 값</em>입니다.
    <code>sampleOn(trigger)</code>이 정확히 그 분리입니다: 소스 스트림이
    값을 공급하고, 트리거 스트림이 순간을 공급하며, 트리거 이벤트마다
    소스의 최신 값이 내보내집니다.
  </p>
  <p>
    두 가지 디테일이 이 연산자를 정직하게 만듭니다. 새로 도착한 것이
    없을 때 발화한 트리거는 <strong>침묵</strong>합니다 — 시계가
    똑딱였다는 이유만으로 같은 값을 연달아 두 번 보는 일은 없습니다.
    그리고 트리거 사이에 밀려난 값들은 <strong>큐에 쌓이지 않고
    버려집니다</strong>: 이것은 설계상 손실이 있는 연산자로, 최신
    판독값만 중요한 상태 성격의 스트림을 위한 것입니다.
  </p>
  <p>
    수명은 소스를 따릅니다: 소스가 닫히면 체인이 닫히고 트리거 구독은
    취소됩니다 — 끝없는 <code>Stream.periodic</code> 틱도 훌륭한 트리거가
    됩니다. 이웃과 비교해 보세요:
    <code><a href="throttle.html">throttle</a></code>은 소스 자신의
    이벤트에서 잰 고정 윈도우로 속도를 제한하고, <code>sampleOn</code>은
    일정을 통째로 두 번째 스트림에 넘깁니다. fxdart 이벤트 계층이며,
    Rx의 <code>sample</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 리듬은 트리거가 정한다</h2>
  {{playground:0}}

  <h2>데모 2 · 새것이 없으면 침묵, 소스와 함께 닫힘</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 프레임당 드래그 위치 하나.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="throttle.html"><code>throttle</code></a> — 소스 자신의 타이밍으로 속도 제한 ·
    <a href="debounce.html"><code>debounce</code></a> — 샘플링 대신 잠잠해지기를 기다림 ·
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — 같은 "최신 값" 아이디어지만 두 데이터 스트림을 결합
  </div>
