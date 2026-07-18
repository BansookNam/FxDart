---
slug: predicates
title: predicates — FxDart 101
description: FxDart의 타입 술어 모음 - isNull, isBoolean, isNumber, isString, isDate, isList, isMap 등을 filter에 그대로 넘길 수 있는 tear-off 함수로 제공합니다.
heading: <code>predicates</code>
section: 8
crumb: predicates
prev: some.html
prevLabel: some
next: fromEntries.html
nextLabel: fromEntries
---
  <p class="hero-sub"><code>filter</code>, <code>takeWhile</code> 같은 함수에 tear-off로 넘기기 좋도록 준비해 둔 작은 타입/값 검사 모음입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    평범한 Dart 코드라면 그냥 <code>a is String</code>이라고 쓰면 됩니다 —
    그게 관용적인 방식이고, 여기 있는 함수들이 그것을 대체하지도 않습니다.
    이 함수들이 존재하는 이유는 하나입니다. Dart의 <code>is</code> 연산자는
    일급 함수 값으로 tear-off 할 수 없는데, <code>filter</code>,
    <code>takeWhile</code>, <code>find</code> 같은 함수들은 모두
    <code>bool Function(A)</code>를 원하기 때문입니다.
    <code>filter(isString, mixedList)</code>가
    <code>filter((a) => a is String, mixedList)</code>보다 읽기 좋다는 것,
    이 페이지의 요점은 그게 전부입니다.
  </p>
  <p>
    <code>isNil</code>은 FxTS의 "<code>null</code> 또는
    <code>undefined</code>인가" 검사를 그대로 옮긴 것입니다. Dart는 둘을
    <code>null</code> 하나로 합쳐 두었으므로, <code>isNull</code>과 완전히
    동일합니다. 오직 FxTS와의 이름 대응을 위해 남겨 둔 이름이 세 개 더 있고
    <code>@Deprecated</code>로 표시되어 있습니다. <code>isUndefined</code>
    (Dart에는 <code>undefined</code>가 없으니 그냥 <code>isNull</code>입니다),
    <code>isArray</code> (JS의 <code>Array</code> → Dart의 <code>List</code>이니
    <code>isList</code>입니다), <code>isObject</code> (JS의 평범한 객체 →
    Dart의 <code>Map</code>이니 <code>isMap</code>입니다). 새로 쓰는 코드에서는
    deprecated 되지 않은 이름을 쓰세요. 별칭들은 포팅된 호출부가 그대로
    컴파일되도록 남겨 둔 것입니다.
  </p>

  <h2>데모 1 · filter에 바로 넘기는 tear-off</h2>
  {{playground:0}}

  <h2>데모 2 · <code>isNil</code>과 deprecated 별칭들</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>isNotNull</code>로 <code>row</code>에서 <code>null</code>을 걸러내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="filter.html"><code>filter</code></a> — 이 함수들이 주로 쓰이는 자리 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — 타입이 아니라 값을 보는 검사 ·
    <a href="compact.html"><code>compact</code></a> — 이터러블에서 null을 제거 ·
    <a href="matches.html"><code>matches</code></a> — 타입이 아니라 형태를 보는 술어
  </div>
