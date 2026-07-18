---
slug: pickBy
title: pickBy — FxDart 101
description: FxDart pickBy 튜토리얼: (키, 값) 술어에 맞는 Map 엔트리만 남깁니다.
heading: <code>pickBy</code>
section: 9
crumb: pickBy
prev: omitBy.html
prevLabel: omitBy
next: prop.html
nextLabel: prop
---
  <p class="hero-sub">술어에 맞는 엔트리만 남긴 <code>Map</code>의 복사본을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>pickBy</code>는 <code>omitBy</code>를 그대로 뒤집은 함수이며,
    호출 방식도 똑같습니다. 술어는 엔트리마다 <code>(K, V)</code> 레코드
    하나를 받으므로 키는 <code>e.$1</code>, 값은 <code>e.$2</code>로
    꺼내 씁니다. 술어가 <code>true</code>를 반환한 엔트리만 결과에
    남습니다.
  </p>
  <p>
    설정 값이나 기능 플래그가 담긴 맵에서 "지금 필요한 것들"만
    골라낼 때 자주 씁니다 — 활성화된 플래그, 특정 접두사가 붙은 키,
    임계값을 넘는 값처럼요. 엔트리를 하나씩 도는 반복문을 직접 쓸
    필요가 없습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 키를 기준으로 걸러내기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>pickBy</code>로 값이 <code>true</code>인 엔트리만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="omitBy.html"><code>omitBy</code></a> — 그 반대: 술어로 제거합니다 ·
    <a href="pick.html"><code>pick</code></a> — 고정된 키 목록으로 남깁니다 ·
    <a href="matches.html"><code>matches</code></a> — 모양 비교용으로 바로 쓸 수 있는 술어 ·
    <a href="compactObject.html"><code>compactObject</code></a> — "null을 걷어내는" 용도로 특수화된 pickBy
  </div>
