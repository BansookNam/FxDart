---
slug: matches
title: matches — FxDart 101
description: FxDart matches 튜토리얼 — isMatch를 커링해 filter에 바로 넘길 수 있는 술어 형태로 만듭니다.
heading: <code>matches</code>
section: 9
crumb: matches
prev: isMatch.html
prevLabel: isMatch
next: identity.html
nextLabel: identity
---
  <p class="hero-sub">커링된 <code>isMatch</code> — 패턴을 한 번 묶어 두고 재사용 가능한 술어를 돌려받습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>isMatch(target, pattern)</code>은 두 인자를 한꺼번에 받아야 해서
    <code>filter</code>, <code>find</code>, <code>every</code>처럼 인자 하나짜리
    <code>bool Function(A)</code>를 원하는 자리에 넘기기가 불편합니다.
    <code>matches(pattern)</code>은 패턴을 클로저로 감싸 바로 그 형태를
    반환합니다.
    <code>matches(pattern)(target) == isMatch(target, pattern)</code>이 성립하죠.
    술어를 한 번 만들어 두고 파이프라인 전체에서 재사용하세요.
  </p>
  <p>
    Dart에서는 범용 커링을 타입 추론으로 표현할 수 없기 때문에, FxDart는 이렇게
    두 인자 함수마다 커링 형태를 따로 제공합니다 — 왜 범용 버전이 없는지
    궁금하다면 deprecated된 최상위 <code>curry</code>를 보세요 — 대신 이처럼
    목적에 맞게 만든 커링 형태는 아주 잘 동작합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · filter/find에 그대로 끼워 넣기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>matches</code>로 <code>{'active': true}</code>에 대한 술어를 만들어 <code>users</code>를 걸러 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="isMatch.html"><code>isMatch</code></a> — 이 함수가 커링하는 두 인자 버전 ·
    <a href="filter.html"><code>filter</code></a> — 가장 자주 끼워 넣게 되는 자리 ·
    <a href="find.html"><code>find</code></a> — 첫 번째로 일치하는 값만 얻기 ·
    <a href="predicates.html"><code>predicates</code></a> — 곧바로 쓸 수 있는 다른 검사 함수들
  </div>
