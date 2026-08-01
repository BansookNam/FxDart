---
slug: attach
title: attach — FxDart 101
description: FxDart attach 튜토리얼 — 각 값을 그 값에서 유도한 결과와 짝지어, 입력이 결과 곁에 남습니다. 라이브 플레이그라운드 포함.
heading: <code>attach</code>
section: 3
crumb: attach
prev: pluck.html
prevLabel: pluck
next: filter.html
nextLabel: filter
---
  <p class="hero-sub">각 값을 거기서 유도한 것과 짝짓기 — 입력이 결과 곁에 남습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="map.html">map</a></code>은 각 값을 결과로 대체합니다 —
    그리고 하류에서 <em>입력</em>이 다시 필요해지는 순간(대체 값으로
    쓰려고, 라벨을 붙이려고, 로그를 남기려고) 손으로 레코드를 조립하는
    자신을 발견하게 됩니다:
    <code>.map((x)&nbsp;async&nbsp;=&gt;&nbsp;(x,&nbsp;await&nbsp;f(x)))</code>.
    <code>attach(f)</code>는 그 관용구를 연산자로 만든 것입니다.
    <code>(값, f(값))</code> 쌍을 지연 방식으로 내놓습니다.
  </p>
  <p>
    진가는 비동기 체인에서 드러납니다. 품목마다 가격을 조회하면 쌍이
    품목을 (없을 수도 있는) 가격 옆에 붙잡아 두므로, 대체 값
    <code>r.$2&nbsp;??&nbsp;r.$1.listPrice</code>도 "그게 어느 SKU였지?"
    라벨도 여전히 손 닿는 곳에 있습니다. 비동기 형태는
    <code>mapAsync</code> 위에 만들어져 병렬 안전합니다 — 뒤에
    <code><a href="concurrent.html">concurrent(n)</a></code>을 붙이면
    조회가 <em>n</em>개씩 동시에 실행됩니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다). 유도한 값만
    필요하면 계속 <code>map</code>을 쓰고, 입력을 키로 삼은 조회 테이블이
    필요하다면 그것은
    <code><a href="indexBy.html">indexBy</a></code>입니다.
  </p>

  <h2>데모 1 · 입력이 map을 살아남습니다</h2>
  {{playground:0}}

  <h2>데모 2 · 대체 값이 있는 비동기 조회</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 각 검색어를 그 검색 결과 곁에 붙잡아 두세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="map.html"><code>map</code></a> — 입력을 보내도 될 때 ·
    <a href="zip.html"><code>zip</code></a> — <em>별개의</em> 두 시퀀스 짝짓기 ·
    <a href="concurrent.html"><code>concurrent</code></a> — attach 뒤에서 비동기 팬아웃 제한하기
  </div>
