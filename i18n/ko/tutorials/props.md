---
slug: props
title: props — FxDart 101
description: FxDart props 튜토리얼 - Map의 여러 키를 한 번에 List로 읽고, 없는 키는 null이 됩니다.
heading: <code>props</code>
section: 9
crumb: props
prev: prop.html
prevLabel: prop
next: evolve.html
nextLabel: evolve
---
  <p class="hero-sub"><code>Map</code>에서 여러 키에 해당하는 값들을 <code>List</code>로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>props</code>는 <code>prop</code>을 여러 키에 한 번에, 순서대로 적용한
    것입니다. 키 목록과 맵을 넘기면 요청한 키마다 자리 하나씩을 가진
    <code>List&lt;V?&gt;</code>가 돌아옵니다.
    <a href="pick.html"><code>pick</code></a>과 달리 없는 키가 결과에서
    빠지지 않습니다 — 그 자리에 <code>null</code>이 들어가므로, 출력
    <code>List</code>의 길이는 항상 <code>propKeys</code>와 같습니다. 이렇게
    위치가 보장되기 때문에 Dart의 리스트 구조 분해 패턴과 특히 잘 어울립니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 결과를 구조 분해하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>props</code>로 <code>row</code>에서 <code>['first', 'last']</code>를 <code>List</code>로 뽑아내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="prop.html"><code>prop</code></a> — 한 번에 키 하나씩 ·
    <a href="pick.html"><code>pick</code></a> — 결과를 Map 형태로 돌려주는 대응 함수 ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — 다시 Map으로 만들기 ·
    <a href="evolve.html"><code>evolve</code></a> — 선택한 값들을 제자리에서 변환
  </div>
