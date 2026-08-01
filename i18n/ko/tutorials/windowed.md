---
slug: windowed
title: windowed — FxDart 101
description: FxDart windowed 튜토리얼: 시퀀스 위를 미끄러지는 슬라이딩 윈도우 — 이동 평균, 겹치는 배치, 연속 구간 감지 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>windowed</code>
section: 5
crumb: windowed
prev: chunk.html
prevLabel: chunk
next: pairwise.html
nextLabel: pairwise
---
  <p class="hero-sub">연속된 원소 <code>size</code>개짜리 슬라이딩 윈도우로, 각 윈도우는 직전 윈도우보다 <code>step</code>개 뒤에서 시작합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="chunk.html">chunk</a></code>는 시퀀스를
    <em>겹치지 않는</em> 조각으로 자릅니다. 조각이 겹쳐야 하는 순간 —
    이동 평균, "한도를 넘긴 연속 세 번의 측정값", 각 원소를 이웃과 함께
    보는 모든 질문 — 경계를 조심스레 따지는 인덱스 루프를 손으로 짜게
    됩니다. <code>windowed(size)</code>는 그 루프를 지연 연산자로 만든
    것입니다. 연속된 원소 <code>size</code>개씩을 담은
    <code>List</code>를 내놓으며, 윈도우 사이는
    <code>step</code>(기본값 1)만큼 앞으로 미끄러집니다.
  </p>
  <p>
    두 개의 손잡이로 온 가족을 커버합니다. <code>step</code>은 윈도우의
    간격을 정합니다. <code>step&nbsp;&lt;&nbsp;size</code>는 서로 겹치게,
    <code>step&nbsp;==&nbsp;size</code>는 <code>chunk</code>와 똑같이
    타일처럼 깔리게, <code>step&nbsp;&gt;&nbsp;size</code>는 사이를 띄워
    샘플링하게 만듭니다. <code>partial:&nbsp;true</code>는 꼬리의 짧은
    윈도우를 버리는 대신 남겨 둡니다 — 실제로
    <code>chunk(n)</code>은
    <code>windowed(n, step:&nbsp;n, partial:&nbsp;true)</code>
    <em>그 자체</em>이며, 둘은 하나의 구현을 공유합니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다) — 이름은
    Kotlin의 <code>windowed</code>에서 왔고, RxDart 독자에게는
    <code>bufferCount(size, startEvery)</code>로 익숙할 것입니다. 다른
    모든 fxdart 연산자처럼 지연 평가됩니다. 윈도우는 pull 한 번에 하나씩
    구체화되므로, 끝없는 소스와도
    <code><a href="concurrent.html">concurrent</a></code>와도
    잘 조합됩니다.
  </p>

  <h2>데모 1 · 이동 평균</h2>
  {{playground:0}}

  <h2>데모 2 · step과 partial 손잡이</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 지출 한도를 넘긴 3일 연속 구간을 찾아 표시해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="chunk.html"><code>chunk</code></a> — 겹치지 않는 특수 사례 ·
    <a href="pairwise.html"><code>pairwise</code></a> — 정확히 2개짜리 윈도우, 레코드 형태 ·
    <a href="scan.html"><code>scan</code></a> — 고정 윈도우 없이 누적 상태 유지
  </div>
