---
slug: fromEntries
title: fromEntries — FxDart 101
description: FxDart fromEntries 튜토리얼: (key, value) 레코드 엔트리로 Map을 만듭니다. entries()의 역방향 연산입니다.
heading: <code>fromEntries</code>
section: 9
crumb: fromEntries
prev: predicates.html
prevLabel: predicates
next: omit.html
nextLabel: omit
---
  <p class="hero-sub"><code>(key, value)</code> 레코드의 이터러블로 <code>Map</code>을 만듭니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이 섹션은 FxTS의 객체 유틸리티를 포팅한 것으로, 가장 먼저 이해해야 할
    것은 대응 관계입니다. TypeScript의 일반 객체는 전반적으로 Dart의
    <code>Map</code>이 되고, TS의 <code>[key, value]</code> 엔트리 튜플은
    Dart의 <code>(K, V)</code> 레코드가 됩니다. <code>fromEntries</code>는
    그중 생성하는 쪽입니다. 레코드로 이루어진 이터러블을 넘기면 이를 접어
    <code>Map</code>으로 만들며, 키가 겹치면 나중 값이 앞선 값을 덮어씁니다 —
    반복문으로 직접 맵을 만들 때와 똑같습니다.
  </p>
  <p>
    <a href="entries.html"><code>entries</code></a>(반대 방향, 즉
    <code>Map</code> → 레코드)와 자연스럽게 짝을 이루며,
    <a href="zip.html"><code>zip</code></a>과도 잘 어울립니다. zip은 나란한 두
    리스트를 <code>fromEntries</code>가 원하는 레코드 형태로 정확히 만들어 줍니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 중복 키, 그리고 <code>entries</code>와의 왕복 변환</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>fromEntries</code>로 <code>pairs</code>를 <code>Map</code>으로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="entries.html"><code>entries</code></a> — 반대 방향 ·
    <a href="zip.html"><code>zip</code></a> — 나란한 두 리스트로 엔트리 만들기 ·
    <a href="omit.html"><code>omit</code></a> — 만들어진 Map에서 키 제거 ·
    <a href="pick.html"><code>pick</code></a> — 일부 키만 남기기
  </div>
