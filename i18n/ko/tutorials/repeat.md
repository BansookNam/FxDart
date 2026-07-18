---
slug: repeat
title: repeat — FxDart 101
description: FxDart repeat 튜토리얼: 같은 값을 n번 지연 평가로 만들어 냅니다.
heading: <code>repeat</code>
section: 2
crumb: repeat
prev: range.html
prevLabel: range
next: cycle.html
nextLabel: cycle
---
  <p class="hero-sub">같은 값을 n번 만들어 냅니다 — 패딩과 짝짓기에 쓰기 좋은, 지연 평가되는 유한 소스입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>repeat(n, value)</code>는 <code>value</code>를 정확히
    <code>n</code>번 만들어 낸 뒤 멈춥니다 — 이 섹션의 다른 생성기들과
    마찬가지로 유한하고 지연 평가됩니다. 매번 <em>같은</em> 값
    (원시 타입이 아니라면 같은 객체 참조)을 반복한다는 점에 유의하세요.
    반복마다 새로운 값이 필요하다면 <code>repeat</code>이 팩토리 함수를
    호출해 주기를 기대하지 말고, 결과에 <code>map</code>을 거는 식으로
    따로 만들어 내야 합니다.
  </p>
  <p>
    다른 것과 짝지을 때 가장 쓸모가 있습니다. 길이가 정해지지 않은 시퀀스와
    <code>zip</code>해서 모든 원소에 상수 라벨을 붙이거나,
    <code>fx(...).join()</code>으로 고정 폭 구분선 문자열을 만들 수 있습니다.
    <code>repeat(0, value)</code>는 빈 이터러블을 얻는 지극히 정상적인
    사용법입니다.
  </p>
  <p>
    값 하나가 아니라 <em>시퀀스</em> 전체를 반복하고 싶다면 — 게다가 정해진
    <code>n</code>번이 아니라 무한히 계속하고 싶다면 — 다음에 다룰
    <code>cycle</code>이 그 역할을 합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 상수를 가변 길이 시퀀스와 짝짓기</h2>
  <p>
    <code>repeat</code>은 매번 똑같은 값을 만들어 냅니다 —
    <code>zip</code>과 함께 쓰면 길이가 정해지지 않은 시퀀스에 상수를
    붙일 수 있습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>repeat</code>을 사용해 값 7이 5개 들어 있는
    <code>List&lt;int&gt;</code>를 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="range.html"><code>range</code></a> — 증가하거나 감소하는 정수의 지연 시퀀스 ·
    <a href="cycle.html"><code>cycle</code></a> — 시퀀스 전체를 무한히 반복 ·
    <a href="zip.html"><code>zip</code></a> — repeat과 자주 함께 쓰이는 짝짓기 ·
    <a href="fx.html"><code>fx</code></a> — repeat을 보통 감싸는 체인
  </div>
