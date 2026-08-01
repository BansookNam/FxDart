---
slug: pairwise
title: pairwise — FxDart 101
description: FxDart pairwise 튜토리얼: 각 원소를 다음 원소와 짝짓기 — 증감량, 전일 대비 변화, 간격 감지 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>pairwise</code>
section: 5
crumb: pairwise
prev: windowed.html
prevLabel: windowed
next: split.html
nextLabel: split
---
  <p class="hero-sub">각 원소를 그다음 원소와 짝짓습니다. <code>[a, b, c]</code>는 <code>((a, b), (b, c))</code>가 됩니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    "얼마나 <em>변했는가</em>?"라는 질문에는 한 번에 두 원소 — 이전 값과
    현재 값 — 가 필요한데, 보통의
    <code><a href="map.html">map</a></code>은 언제나 하나만 봅니다. 흔한
    우회로는 인덱스 루프(<code>list[i&nbsp;-&nbsp;1]</code>,
    off-by-one 위험 포함)이거나, 리스트를 한 칸 밀어 자기 자신과 zip하는
    것입니다. <code>pairwise()</code>는 그 아이디어를 연산자로 만든
    것입니다. <code>(이전, 현재)</code> 레코드를 지연 방식으로 내놓으며,
    원소 <em>n</em>개에서 쌍 <em>n&nbsp;−&nbsp;1</em>개가 나옵니다. 원소가
    두 개 미만이면 아무것도 내놓지 않습니다 — 만들 쌍이 없기 때문입니다.
  </p>
  <p>
    레코드 필드가 양쪽을 모두 손 닿는 곳에 둡니다.
    <code>p.$2&nbsp;-&nbsp;p.$1</code>이 증감량이고,
    <code>p.$2.compareTo(p.$1)</code>이 방향입니다. 이는 정확히
    2원소 리스트 대신 타입이 있는 레코드를 쓰는
    <code><a href="windowed.html">windowed(2)</a></code>입니다 — 이웃의
    범위가 둘을 넘어서면 <code>windowed</code>를 쓰세요.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다). RxDart의
    <code>pairwise</code>를 따랐습니다. 비동기 형태는 pull이 있기 전까지
    아무것도 계산하지 않으며
    <code><a href="concurrent.html">concurrent</a></code>와 조합됩니다.
  </p>

  <h2>데모 1 · 측정값 사이의 증감량</h2>
  {{playground:0}}

  <h2>데모 2 · 변화의 방향</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 타임스탬프 시퀀스에서 빈 간격을 찾아 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="windowed.html"><code>windowed</code></a> — 둘보다 큰 이웃 범위 ·
    <a href="zip.html"><code>zip</code></a> — <em>별개의</em> 두 시퀀스 짝짓기 ·
    <a href="scan.html"><code>scan</code></a> — 한 칸 뒤를 돌아보는 대신 상태를 들고 가기
  </div>
