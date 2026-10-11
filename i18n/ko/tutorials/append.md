---
slug: append
title: append — FxDart 101
description: FxDart append 튜토리얼: 지연 평가되는 이터러블 끝에 값 하나를 덧붙이는 법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>append</code>
section: 6
crumb: append
prev: split.html
prevLabel: split
next: prepend.html
nextLabel: prepend
---
  <p class="hero-sub">원본의 모든 값을 내보낸 다음, 마지막에 값 하나를 더 내보냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>append</code>는 지연 시퀀스 뒤에 값 하나를 붙이는 가장 간단한
    방법입니다. 아무것도 미리 만들지 않습니다. 원본을 그대로 흘려보내다가
    원본이 소진되면 <code>a</code>를 한 번 내보냅니다. 원본은 값을 요청할 때만
    계산되므로, 계산 비용이 큰 원본이어도 문제없습니다. 추가된 값은 실제로
    가장 마지막에 만들어집니다.
  </p>
  <p>
    비동기 쪽에서는 <code>a</code> 자체가 <code>Future</code>일 수 있습니다.
    <code>fxAppendAsync</code>는 상류가 끝난 뒤에야 이를 await하므로, 느린
    "마무리" 값이 있어도 그 앞의 값 흐름을 미리 막지 않습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, future 값과 함께</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: steps 끝에 <code>'cool'</code>을 덧붙여 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="prepend.html"><code>prepend</code></a> — 대신 앞쪽에 값을 추가 ·
    <a href="concat.html"><code>concat</code></a> — 두 이터러블 전체를 이어 붙임 ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
