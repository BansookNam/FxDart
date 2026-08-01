---
slug: timeout
title: timeout — FxDart 101
description: FxDart timeout 튜토리얼: 너무 오래 걸리는 pull을 실패시키기 — pull 모델에서의 항목별 시간 한도 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>timeout</code>
section: 11
crumb: timeout
prev: retry.html
prevLabel: retry
next: using.html
nextLabel: using
---
  <p class="hero-sub"><code>limit</code>보다 오래 걸리는 개별 pull을 <code>TimeoutException</code>으로 실패시킵니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    파이프라인의 반응성은 가장 느린 await만큼만 좋을 수 있습니다.
    <code>timeout(limit)</code>은 거기에 한도를 겁니다. 각 pull — 상류
    연산자를 몇 개 거치든, 항목 <em>하나</em>를 만들어 내는 작업 — 은
    <code>limit</code> 안에 끝나야 하고, 그러지 못하면 그 pull은
    <code>TimeoutException</code>으로 실패합니다. 빠른 항목은 건드리지
    않으며, 이 연산자 자체가 지연을 더하지도 않습니다.
  </p>
  <p>
    정확히 짚어 둘 만한 pull 모델의 의미론입니다. 이 한도가 재는 것은
    <strong>요청부터 항목까지의 시간</strong> — 하류가 요청한 순간부터
    항목이 도착하는 순간까지입니다. 항목 사이의 간격은 재지 않고(요청이
    없으면 간격도 없습니다), 파이프라인 전체를 제한하지도 않습니다
    (그것은 종단에 거는 <code>Future.timeout</code>의 몫입니다:
    <code>fxAsync(…).toList().timeout(…)</code>). RxDart의
    <code>timeout</code>은 push 스트림에서 이벤트 사이 간격을 감시합니다
    — 이름은 같지만 반대편에서 재는 것입니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다). 병렬
    안전합니다.
    <code><a href="concurrent.html">concurrent(n)</a></code> 아래에서는
    겹쳐 진행되는 각 pull이 자기만의 타이머를 갖고 있으므로, 다소 느린
    항목 <em>n</em>개가 겹쳐도 각각 개별적으로 통과합니다.
    <code><a href="retry.html">retry</a></code>와 짝을 이룹니다 —
    timeout은 "멈춰 있음"을 "실패함"으로 바꾸고, retry는 "실패함"을
    "다시 시도함"으로 바꿉니다.
  </p>

  <h2>데모 1 · 멈춤 잡아내기</h2>
  {{playground:0}}

  <h2>데모 2 · 파이프라인이 아니라 pull 단위</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 느린 피드에 한도를 걸고, 그다음 복구해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="retry.html"><code>retry</code></a> — 타임아웃이 발생한 뒤 할 일 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 겹치는 pull은 독립적으로 타임아웃됨 ·
    <a href="eitherPipelines.html">타입 있는 에러</a> — <code>TimeoutException</code>을 값으로 잡기
  </div>
