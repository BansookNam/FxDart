---
slug: spaceBy
title: spaceBy — FxDart 101
description: FxDart spaceBy 튜토리얼: 하나도 버리지 않고 버스트의 속도 조절하기, delay로 스트림 미루기, sample로 시계에 맞춰 최신 값 읽기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>delay</code>, <code>spaceBy</code> &amp; <code>sample</code>
section: 14
crumb: spaceBy
prev: groupsBy.html
prevLabel: groupsBy
next: debounceOn.html
nextLabel: debounceOn
---
  <p class="hero-sub">이벤트를 시간축에서 옮기는 세 가지 방법: 전부 미루거나, 넓게 펼치거나, 고정된 시계로 최신 것만 읽거나.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    속도 제한은 언제나 무언가를 대가로 치르고, 진짜 질문은 <em>무엇을</em>
    치르느냐입니다. <code><a href="throttle.html">throttle</a></code>과
    <code><a href="debounce.html">debounce</a></code>는
    <strong>이벤트</strong>로 치릅니다: 창마다 하나를 남기고 나머지를
    버리는데, 이벤트가 연속적인 무언가의 표본이고 오래된 것이 쓸모없을
    때 옳습니다. <code>spaceBy(gap)</code>는 대신 <strong>시간</strong>으로
    치릅니다: 모든 이벤트가 살아남아 큐에 들어가고 <code>gap</code>마다
    하나씩 풀려납니다. 각 이벤트가 잃어서는 안 되는 개별 명령일 때 —
    100ms에 한 번만 허용하는 API로 보낼 메시지 여섯 개 — 옳습니다.
  </p>
  <p>
    그 거래에는 날카로운 모서리가 있습니다. <code>spaceBy</code>는
    버리지 않고 큐에 쌓으므로, <code>gap</code>보다 빠르게 영원히
    생산하는 소스는 무한히 자라는 큐를 만듭니다. 이것은
    <em>버스트</em>를 위한 것입니다 — 한꺼번에 도착했고 전부 통과해야
    하는 묶음 — 진짜로 끝없는 입력을 위한 것이 아닙니다. 그럴 때는
    throttle의 손실성이 오히려 기능입니다.
  </p>
  <p>
    <code>delay(duration)</code>은 셋 중 가장 단순합니다: 스트림 전체가
    고정된 양만큼 밀리고, 간격은 그대로이며, 아무것도 버려지지
    않습니다. 닫기는 마지막으로 미뤄진 이벤트가 도착하기를 기다리므로
    끝에서 잃는 것이 없고, 에러는 즉시 전달됩니다 — 붙들어 둘 가치가
    있는 것은 데이터뿐이니까요.
  </p>
  <p>
    <code>sample(period)</code>는 시계가 내장된
    <code><a href="sampleOn.html">sampleOn</a></code>입니다 —
    <code>period</code>마다 최신 값, 새로운 것이 없으면 침묵. 소스가
    상태 같은 피드(위치, 온도, 스크롤 오프셋)이고 소비자가 자기 갱신
    주기를 가질 때 꺼내 쓰세요. fxdart 이벤트 레이어, Rx의
    <code>delay</code>, <code>interval</code>, <code>sampleTime</code>을
    따랐습니다.
  </p>

  <h2>데모 1 · 버스트를 손실 없이 조절하기</h2>
  {{playground:0}}

  <h2>데모 2 · 미루기, 그리고 시계로 읽기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 전송 속도와 보고 속도를 한 체인에.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="throttle.html"><code>throttle</code></a> — 손실이 있는 대응물: 창마다 하나, 즉시 ·
    <a href="debounce.html"><code>debounce</code></a> — 버스트가 끝나기를 기다렸다가 마지막 값 취하기 ·
    <a href="chunkOn.html"><code>chunkEvery</code></a> — 역시 모든 이벤트를 지키되, 펼치는 대신 묶기
  </div>
