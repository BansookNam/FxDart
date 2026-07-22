---
slug: findIndex
title: findIndex — FxDart 101
description: FxDart findIndex 튜토리얼: 지연 평가와 단축 평가로 첫 일치 원소의 위치를 찾고, 없으면 -1을 받는 방법을 익힙니다.
heading: <code>indexWhere</code>
section: 8
crumb: indexWhere
prev: find.html
prevLabel: find
next: includes.html
nextLabel: includes
---
  <p class="hero-sub">술어가 true인 첫 번째 원소의 인덱스를 반환하며, 없으면 <code>-1</code>을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>findIndex</code>는 <code>find</code>의 형제입니다. 지연 평가와
    단축 평가로 훑는 방식은 똑같지만, 일치한 값 자체가 아니라 그것이
    <em>어디에</em> 있었는지를 알려 줍니다. "찾지 못했음"을 나타내는 값이
    다르다는 점에 주의하세요 — 여기서는 <code>int</code> 타입의
    <code>-1</code>이며, 자바스크립트의
    <code>Array.prototype.findIndex</code>를 따른 것입니다. 모두
    <code>null</code>을 쓰는 <code>head</code>/<code>find</code>/<code>nth</code>와
    의도적으로 대비되는 선택입니다. 인덱스에는 "불가능한 값"이 자연스럽게
    존재하므로, FxDart는 <code>int?</code> 반환 타입을 새로 만들기보다
    이 지점에서는 FxTS의 관례를 그대로 따릅니다.
  </p>
  <p>
    내부적으로는 각 원소를 인덱스와 짝지은 뒤(<code>zipWithIndex</code> 사용)
    <code>f</code>를 통과하는 첫 번째 원소에서 멈춥니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 단축 평가와 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>findIndex</code>로 큐에서 bob의 위치를 찾고, 없으면 <code>-1</code>을 받아 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="find.html"><code>find</code></a> — 같은 탐색, 값을 반환 ·
    <a href="includes.html"><code>includes</code></a> — 그저 "있는가?"만 확인 ·
    <a href="nth.html"><code>nth</code></a> — 그 반대: 인덱스를 넣고 값을 받기 ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — 내부 동작을 떠받치는 함수
  </div>
