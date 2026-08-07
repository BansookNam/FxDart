---
slug: predicateOps
title: 술어 조합자 — FxDart 101
description: FxDart 술어 조합자 튜토리얼: and, or, xor, negate, contramap으로 이름 붙은 술어를 조합하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: 술어 조합자
section: 10
crumb: and · or · xor · contramap
prev: not.html
prevLabel: not
next: when.html
nextLabel: when
---
  <p class="hero-sub">람다를 중첩하는 대신 이름 붙은 술어로 조건을 짭니다 — <code>and</code>, <code>or</code>, <code>xor</code>, <code>negate</code>, <code>contramap</code>.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    라이브러리의 거르는 연산자는 모두 술어를 받습니다.
    <a href="filter.html"><code>filter</code></a>,
    <a href="reject.html"><code>reject</code></a>,
    <a href="takeWhile.html"><code>takeWhile</code></a>,
    <a href="dropWhile.html"><code>skipWhile</code></a>,
    <a href="countWhere.html"><code>countWhere</code></a>,
    <a href="partition.html"><code>partition</code></a>이 그렇습니다.
    <code>isEven</code>, <code>isPositive</code>, <code>isBlank</code>처럼
    조건에 이름을 붙였다면, 그것들을 합칠 때마다 매개변수 타입을 다시 적은
    새 람다를 치를 이유는 없습니다. 이 조합자들이 그 자리를 메웁니다.
  </p>
  <p>
    <code>bool Function(T)</code> 위의 확장이라서, 이미 손에 쥔 술어라면
    무엇이든 이 메서드들이 붙습니다. 최상위 함수든, 티어오프든, 변수에 담은
    클로저든, 다른 조합자의 결과든 상관없습니다. 각 조합자는 새 술어를
    돌려주며, <em>그</em> 술어가 실행되기 전까지는 아무것도 호출하지
    않습니다.
  </p>
  <p>
    <code>and</code>와 <code>or</code>는 <code>&amp;&amp;</code>,
    <code>||</code>와 똑같이 단락합니다. 왼쪽에서 이미 결론이 나면 오른쪽
    술어는 건너뜁니다 — 비싼 쪽이 오른쪽일 때 의미가 있습니다.
    <code>xor</code>는 단락할 것이 없으므로 항상 양쪽을 부릅니다.
  </p>
  <p>
    <code>contramap</code>은 낯설면서 쓸모 있는 쪽입니다. 결과가 아니라
    <em>인자</em>를 변환합니다 — <em>contra</em>가 가리키는 바가 그것입니다.
    덕분에 <code>int</code>에 대한 술어가, <code>int</code>로 바꿀 수 있는
    무엇에 대한 술어가 됩니다.
    <code>isEven.contramap&lt;String&gt;((s) =&gt; s.length)</code>는
    <code>isEven</code> 쪽에 문자열 이야기를 한마디도 넣지 않고 문자열
    길이를 검사합니다.
  </p>
  <p>
    <code>.negate</code>는 최상위
    <a href="negate.html"><code>negate</code></a>를 확장 게터로 옮겨 놓은
    것입니다 — 같은 함수를 반대편에서 부르는 셈이죠. 호출 지점에서 더 잘
    읽히는 쪽을 쓰면 됩니다. <code>isBlank.or(isShort).negate</code>는
    왼쪽에서 오른쪽으로 읽히지만, <code>negate(...)</code>는 식 전체를 호출
    안쪽으로 밀어 넣습니다.
  </p>

  <h2>데모 1 · and, or, xor, negate</h2>
  {{playground:0}}

  <h2>데모 2 · contramap, 그리고 단락</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 비어 있지도 짧지도 않은 행만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="negate.html"><code>negate</code></a> — <code>.negate</code>의 최상위 형태 ·
    <a href="not.html"><code>not</code></a> — 술어가 아니라 bool 값 하나를 뒤집습니다 ·
    <a href="filter.html"><code>filter</code></a> / <a href="reject.html"><code>whereNot</code></a> — 조합한 술어가 보통 놓이는 자리 ·
    <a href="predicates.html"><code>predicates</code></a> — 함께 조합할 내장 타입 술어들
  </div>
