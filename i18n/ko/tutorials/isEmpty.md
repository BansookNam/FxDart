---
slug: isEmpty
title: isEmpty — FxDart 101
description: FxDart isEmpty 튜토리얼 — null, 문자열, 컬렉션을 아우르는 값 기반 비어 있음 검사를 filter에 바로 넘길 수 있는 술어로 활용해 봅니다.
heading: <code>isEmpty</code>
section: 8
crumb: isEmpty
prev: includes.html
prevLabel: includes
next: every.html
nextLabel: every
---
  <p class="hero-sub">값 기반 비어 있음 검사입니다. <code>null</code>, <code>''</code>, 그리고 빈 컬렉션에 대해 true를 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이것은 <strong>결코</strong> <code>Iterable.isEmpty</code>와 같은 것이
    아닙니다 — 모든 <code>List</code>, <code>Set</code>, <code>Fx</code> 체인에서
    이미 거저 얻는 그 게터 말입니다.
    그 게터는 이터러블에만 있어서, <code>null</code>에 대해서는 예외가 나거나
    아예 쓸 수조차 없습니다. FxTS의 <code>isEmpty</code>는 <em>어떤</em>
    값이든 받아서 더 넓은 질문에 답합니다. 실용적인 의미에서 이 값은
    "아무것도 아닌" 것인가? <code>null</code>, 빈 <code>String</code>, 그리고
    빈 <code>Iterable</code>/<code>Map</code>/<code>Set</code>에 대해
    <code>true</code>를 반환하고, 그 밖의 모든 값에는 <code>false</code>를
    반환합니다. 숫자와 불리언도 여기 포함되며, 결코 "비어 있다"고 보지 않습니다.
  </p>
  <p>
    인자가 <code>Object?</code> 하나뿐이라서, 별도의 람다로 감쌀 필요 없이
    <code>filter</code>나 <code>reject</code>를 비롯해 술어 자리를 요구하는
    어디에든 tear-off로 그대로 넘길 수 있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · filter에 바로 넘기는 tear-off로</h2>
  <p>
    잡다한 값들을 모아 놓고, <code>isEmpty</code>가 비어 있다고 보는 것만
    남깁니다(출력된 빈 문자열은 쉼표 사이의 빈 자리로 나타납니다):
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>isEmpty</code>로 <code>comment</code>가 비어 있으면 <code>'no comment'</code>를, 아니면 댓글 자체를 출력해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="compact.html"><code>compact</code></a> — 이터러블에서 null 제거하기 ·
    <a href="compactObject.html"><code>compactObject</code></a> — Map에서 null 제거하기 ·
    <a href="predicates.html"><code>predicates</code></a> — filter에 바로 쓸 수 있는 타입 검사 모음 ·
    <a href="includes.html"><code>includes</code></a> — 이웃한 포함 여부 검사
  </div>
