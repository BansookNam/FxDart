---
slug: isMatch
title: isMatch — FxDart 101
description: FxDart isMatch 튜토리얼 — Map이나 리스트 패턴에 대한 깊은 부분 일치 검사를 살펴봅니다.
heading: <code>isMatch</code>
section: 9
crumb: isMatch
prev: resolveProps.html
prevLabel: resolveProps
next: matches.html
nextLabel: matches
---
  <p class="hero-sub">깊은 부분 일치 검사입니다. <code>target</code>이 <code>pattern</code>이 기술한 내용을 모두 담고 있습니까?</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>isMatch</code>는 <code>pattern</code>을 재귀적으로 훑으면서
    <code>target</code>이 그것을 "담고 있는지" 확인합니다. 규칙은 모양에 따라 다릅니다.
  </p>
  <p>
    <strong>Map</strong>은 부분 일치입니다. <code>pattern</code>의 모든 키가
    <code>target</code>에 존재하고 그 값도 재귀적으로 일치해야 하지만,
    <code>target</code>에는 패턴이 언급하지 않은 <em>추가</em> 키가 있어도
    괜찮습니다. <strong>리스트나 이터러블</strong>은 앞에서부터 짝을 지어
    비교하는데, 여기에 기억해 둘 만한 반전이 있습니다. 패턴은 타깃의
    <strong>접두사</strong>이기만 하면 됩니다. <code>[1, 2, 3]</code>은
    패턴 <code>[1, 2]</code>와는 일치하지만 <em>결코</em> 패턴
    <code>[1, 2, 3, 4]</code>와는 일치하지 않습니다. 패턴이 타깃보다 길 수는 없습니다.
    그 밖의 값(숫자, 문자열, 불리언 …)은 그냥 <code>==</code>로 비교합니다.
  </p>
  <p>
    규칙이 중첩되기 때문에 깊은 일치 검사는 거의 거저 얻습니다.
    <code>{'address': {'city': 'seoul'}}</code> 같은 패턴은, 훨씬 크고 깊게
    중첩된 <code>address</code> 값을 가진 사용자 map이라도 그 안 어딘가에
    <code>city</code>가 <code>'seoul'</code>이기만 하면 일치합니다.
  </p>

  <h2>데모 1 · Map 일치</h2>
  {{playground:0}}

  <h2>데모 2 · 리스트 접두사 일치, 그리고 그것으로 필터링하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>isMatch</code>로 <code>order</code>가 <code>{'status': 'shipped'}</code>와 일치하는지 확인해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="matches.html"><code>matches</code></a> — 이 함수를 커링해 filter에 바로 쓸 수 있게 만든 버전 ·
    <a href="pickBy.html"><code>pickBy</code></a> — 모양 기반 필터링에서 자주 함께 쓰는 함수 ·
    <a href="find.html"><code>find</code></a> — 처음으로 일치하는 원소 찾기 ·
    <a href="omitBy.html"><code>omitBy</code></a> — 술어로 항목 제거하기
  </div>
