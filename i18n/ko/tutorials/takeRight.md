---
slug: takeRight
title: takeRight — FxDart 101
description: FxDart takeRight 튜토리얼 — 유한한 이터러블에서 뒤의 n개 값만 남깁니다. 라이브 플레이그라운드 포함.
heading: <code>takeRight</code>
section: 5
crumb: takeRight
prev: take.html
prevLabel: take
next: takeWhile.html
nextLabel: takeWhile
---
  <p class="hero-sub">소스에서 뒤의 <code>length</code>개 값을 담은 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>takeRight</code>는 <code>take</code>를 거울에 비친 함수입니다.
    앞의 <code>length</code>개가 아니라 뒤쪽 값을 돌려줍니다. 다만 한 가지 함정이 있습니다 — "뒤쪽" 값이 무엇인지
    알려면 <code>takeRight</code>는 먼저 모든 원소를 봐야 합니다. 값을
    하나라도 내보내기 전에 소스 전체를 리스트로
    <strong>구체화</strong>하기 때문에, 대부분의 FxDart 연산자와 달리
    무한 시퀀스에서는 동작하지 않습니다.
  </p>
  <p>
    비동기 버전에도 같은 제약이 있습니다. <code>takeRightAsync</code>는
    꼬리 부분을 돌려주기 전에 상류 전체를 (모든 원소를 await 하며)
    소진합니다. 소스가 유한하고 버퍼링해도 될 만큼 작다는 것을 알 때에만
    쓰세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 (소스 전체를 먼저 버퍼링해야 합니다)</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 마지막 점수 3개만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="take.html"><code>take</code></a> — 뒤의 n개 대신 앞의 n개 ·
    <a href="dropRight.html"><code>dropRight</code></a> — 뒤의 n개를 버리기 ·
    <a href="reverse.html"><code>reverse</code></a> — 이쪽도 소스를 구체화합니다 ·
    <a href="slice.html"><code>slice</code></a> — 임의의 인덱스 구간
  </div>
