---
slug: when
title: when — FxDart 101
description: FxDart when 튜토리얼: 술어가 참일 때만 변환을 적용하고 그 외에는 값을 그대로 통과시킵니다. 라이브 플레이그라운드 포함.
heading: <code>when</code>
section: 10
crumb: when
prev: not.html
prevLabel: not
next: unless.html
nextLabel: unless
---
  <p class="hero-sub">술어가 참이면 콜백을 적용하고, 그렇지 않으면 값을 그대로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>when(predicate, callback, value)</code>은 조건문 하나를 데이터로
    표현한 것입니다. <code>predicate(value)</code>가 참이면 결과는
    <code>callback(value)</code>이고, 그렇지 않으면 결과는 손대지 않은
    <code>value</code> 그 자체입니다. 변환이 필요한 원소만 바꾸고 나머지는
    그대로 두고 싶을 때 <code>map</code> 콜백 안에서 특히 읽기 좋습니다.
  </p>
  <p>
    FxTS 버전은 두 분기의 타입이 다를 때 반환 타입을 유니온
    <code>T | R</code>로 넓힐 수 있습니다. Dart에는 유니온 타입이 없으므로
    <code>callback</code> 분기와 그대로 통과시키는 분기가 같은 타입
    <code>T</code>를 공유해야 합니다 — 결과 타입이 정말로 달라야 한다면
    <a href="cases.html"><code>cases</code></a>를 쓰세요. 이쪽은
    <code>R</code>이 입력 타입과 달라도 됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 파이프라인에서 값 범위 제한하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>when</code>으로 양수인 가격만 두 배로 만들고,
    음수는 그대로 두어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="unless.html"><code>unless</code></a> — 조건이 반대인 when의 형제 ·
    <a href="cases.html"><code>cases</code></a> — 여러 개의 술어, 그리고 다른 결과 타입 ·
    <a href="not.html"><code>not</code></a> / <a href="negate.html"><code>negate</code></a> — 넘길 술어를 만들 때 ·
    <a href="map.html"><code>map</code></a> — when을 콜백으로 쓰게 되는 대표적인 자리
  </div>
