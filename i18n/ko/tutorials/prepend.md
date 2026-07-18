---
slug: prepend
title: prepend — FxDart 101
description: FxDart prepend 튜토리얼 - 지연 평가되는 이터러블 앞에 값 하나를 덧붙이는 법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>prepend</code>
section: 6
crumb: prepend
prev: append.html
prevLabel: append
next: concat.html
nextLabel: concat
---
  <p class="hero-sub">값 하나를 먼저 내보낸 다음, 원본의 모든 값을 내보냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>prepend</code>는 <code>append</code>를 뒤집은 것입니다. 먼저
    <code>a</code>를 내보내고, 그다음부터는 원본으로 넘어갑니다. 실제로 값을
    끌어당기기 전까지 원본은 손대지 않으므로, 원본이 아무리 크거나 계산
    비용이 크더라도 앞에 붙이는 비용은 저렴합니다 — 복사도, 인덱스를 밀어내는
    작업도 없이 그저 값 하나가 앞에 더해질 뿐입니다.
  </p>
  <p>
    <code>prependAsync</code>는 <code>a</code>로 <code>Future</code>도 받습니다.
    이 값은 첫 번째로 값을 끌어오는 시점에, 실제 원본에 닿기 전에 먼저 await 됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, future 값과 함께</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: steps 맨 앞에 <code>'mix'</code>를 붙여 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="append.html"><code>append</code></a> — 대신 끝쪽에 값을 추가 ·
    <a href="concat.html"><code>concat</code></a> — 두 이터러블 전체를 이어 붙임 ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
