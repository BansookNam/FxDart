---
slug: nonEmptyList
title: NonEmptyList (Nel) — FxDart 101
description: FxDart NonEmptyList 튜토리얼: 비어 있을 수 없는 리스트를 위한 제로 비용 확장 타입 — head와 first가 전체 함수(total)라 실패하지 않으며, 누적된 에러를 실어 나릅니다.
heading: <code>NonEmptyList</code> · <code>Nel</code>
section: 13
crumb: NonEmptyList
prev: nullable.html
prevLabel: nullable
next: accumulate.html
nextLabel: accumulation
---
  <p class="hero-sub">
    원소를 최소 하나는 담고 있다고 정적으로 보장되는 리스트 — 누적 API가
    에러를 실어 나르는 그릇입니다. 제로 비용입니다: 런타임에 지워지는 확장
    타입(extension type)입니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    "검증 에러의 리스트"에는 어색한 경계 사례가 하나 있습니다.
    <em>비어 있는</em> 에러 리스트는 대체 무슨 뜻일까요?
    <code>NonEmptyList</code>(별칭 <code>Nel</code>)는 그 질문 자체를 타입
    시스템에서 지워 버립니다 — 이 값을 손에 쥐고 있다면 원소가 최소 하나는
    있으므로, <code>List.first</code>와 달리 <code>head</code>는 전체
    함수(total)이며 예외를 던질 수 없습니다.
    <a href="accumulate.html">에러 누적</a>에 필요한 것이 정확히
    이것입니다: <code>EitherNel&lt;E, A&gt;</code> =
    <code>Either&lt;Nel&lt;E&gt;, A&gt;</code>, 즉 <code>Left</code>는
    언제나 최소 하나의 에러를 실어 나릅니다.
  </p>
  <p>
    Arrow의 <code>value class NonEmptyList</code>에 대응하는 Dart 쪽
    짝입니다. <code>List</code> 위에 얹은 <em>확장 타입</em>이라 할당이 전혀
    없고 런타임에 지워지며, <code>implements Iterable</code>이므로 모든
    fxdart 파이프라인과 <code>for</code> 반복문이 이 값을 그대로 받습니다.
    불변식은 컴파일 타임의 규율로 지켜집니다: 생성은 오직
    <code>NonEmptyList.of(head, [tail])</code> 또는
    <code>NonEmptyList.orNull(list)</code>(빈 리스트에는 <code>null</code>을
    반환합니다 — 비어 있는지 확인하는 일은 경계에서 딱 한 번만 일어납니다)를
    통해서만 하세요. <code>list as Nel&lt;int&gt;</code> 같은 캐스트는 그
    검사를 우회하며, 책임은 온전히 사용자 몫입니다.
  </p>

  <h2>데모 1 · of, orNull, head &amp; tail</h2>
  {{playground:0}}

  <h2>데모 2 · map, +, 그리고 파이프라인</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: <code>summarize</code>를 완성해 보세요 — <code>null</code> 경우가
    이미 처리되어 있으므로 <code>nel.length</code>와 <code>nel.head</code>는
    실패할 수 없습니다.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="accumulate.html">에러 누적</a> — <code>Nel</code>이 모든 실패를 실어 나르는 곳 ·
    <a href="either.html"><code>Either</code></a> — <code>toEitherNel()</code>은 실패 하나를 원소 하나짜리 <code>Nel</code>로 끌어올립니다 ·
    <a href="head.html"><code>firstOrNull</code></a> — 이 타입이 전체 함수로 만들어 주는 nullable 우선 접근자 ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
