---
slug: prop
title: prop — FxDart 101
description: FxDart prop 튜토리얼 - Map의 키 하나를 tear-off로 넘기기 좋은 함수로 읽고, 없으면 null을 반환합니다.
heading: <code>prop</code>
section: 9
crumb: prop
prev: pickBy.html
prevLabel: pickBy
next: props.html
nextLabel: props
---
  <p class="hero-sub"><code>Map</code>에서 키에 해당하는 값을 반환하며, 없으면 <code>null</code>을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>prop('name', user)</code> 자체가 하는 일은 Dart에서
    <code>user['name']</code>이 이미 하는 일과 정확히 같습니다 — 키가 없으면
    어느 쪽이든 <code>null</code>입니다. 그런데도 이것이 함수로 존재하는
    이유는 조합 가능성 때문입니다. <code>map[key]</code>는 연산자일 뿐
    여기저기 넘길 수 있는 값이 아니지만, <code>(m) => prop('name', m)</code>은
    <code>map</code>이나 <code>juxt</code>, <code>evolve</code>의 콜백처럼
    <code>Function(Map)</code>이 필요한 곳이라면 어디든 넘길 수 있는 평범한
    단항 함수입니다.
  </p>
  <p>
    맵 <em>리스트</em> 전체에서 필드 하나를 뽑아내는 것이 목적이라면
    <a href="pluck.html"><code>pluck</code></a>을 쓰세요 — 키가 이미 지정된
    <code>prop</code>을 컬렉션 전체에 map 하는 일을 호출 한 번으로 해 줍니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · tear-off로 쓰기, 그리고 <code>pluck</code>과의 비교</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>prop</code>으로 <code>'theme'</code>을 읽고, 없으면 <code>'light'</code>가 되도록 해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="props.html"><code>props</code></a> — 여러 키를 한 번에 읽기 ·
    <a href="pluck.html"><code>pluck</code></a> — 리스트 전체에 map 한 <code>prop</code> ·
    <a href="pick.html"><code>pick</code></a> — 여러 키를 Map 형태로 남기기 ·
    <a href="evolve.html"><code>evolve</code></a> — 값을 제자리에서 변환
  </div>
