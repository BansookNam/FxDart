---
slug: either
title: Either — FxDart 101
description: FxDart Either 튜토리얼: Left와 Right를 가진 sealed 결과 타입, 빠짐없는 switch, fold, map, flatMap, 그리고 Either.catching으로 throw된 예외 잡기.
heading: <code>Either</code>
section: 13
crumb: Either
prev: typedErrors.html
prevLabel: typed errors
next: raise.html
nextLabel: either &amp; Raise
---
  <p class="hero-sub">
    실패인 <code>Left(L)</code>이거나 성공인 <code>Right(R)</code>인 값 —
    타입 있는 에러 시스템의 경계 타입입니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>Either&lt;L, R&gt;</code>은 실패를 함수 <em>시그니처</em>의
    일부로 만듭니다. 던지거나(타입 시스템에는 보이지 않습니다)
    <code>null</code>을 반환하는(<em>왜</em> 실패했는지는 아무것도 말해
    주지 않습니다) 대신 <code>Left(error)</code>나
    <code>Right(value)</code>를 반환하는 것입니다. 이 클래스는
    <code>sealed</code>이므로 그 위의 <code>switch</code>는 빠짐없이
    다뤄야 하고 — 실패 케이스를 처리하라고 컴파일러가 일깨워 줍니다.
  </p>
  <p>
    메서드 집합은 Arrow 2.x가 엄선한 것과 같습니다. <code>fold</code>는
    양쪽을 하나의 값으로 접고, <code>map</code>/<code>mapLeft</code>는 한쪽만
    변환하고, <code>flatMap</code>은 앞 결과에 의존하는 실패 가능한 단계를
    이어 붙이고, <code>getOrNull</code>/<code>getOrElse</code>는 평범한
    Dart로 돌아가는 다리입니다. <code>Either</code>는 <em>경계에서</em>
    살아야 하는 타입입니다. 계산 안쪽에서는
    <a href="raise.html"><code>either</code> 빌더</a>를 쓰세요. 거기서는 각
    단계가 <code>flatMap</code> 피라미드가 아니라 일직선
    <code>r.bind</code> 한 줄입니다.
  </p>

  <h2>데모 1 · Left, Right, 그리고 빠짐없는 switch</h2>
  {{playground:0}}

  <h2>데모 2 · fold, map, mapLeft, flatMap</h2>
  {{playground:1}}

  <h2>데모 3 · 점 축약 표기(Dart ≥ 3.10)</h2>
  <p>
    <code>Either</code>는 <code>const</code> 팩토리
    <code>Either.left</code> / <code>Either.right</code>를 갖고 있어서 Dart
    3.10의 <em>점 축약 표기(dot shorthands)</em>가 이 타입으로 해석됩니다.
    문맥 타입이 이미 <code>Either</code>인 곳이라면 — 반환 위치, switch
    식의 한 갈래, <code>==</code>의 오른쪽 — 타입 이름을 생략하고
    <code>.left(error)</code> / <code>.right(value)</code>라고 쓸 수
    있습니다. <code>Left(…)</code> / <code>Right(…)</code>와 완전히 같은
    객체이고, 다만 문맥에서 추론될 뿐입니다.
  </p>
  {{playground:3}}

  <h2>직접 해 보기</h2>
  <p>
    예외와 타입 있는 에러는 엄격히 분리된 채로 남습니다. <em>throw된</em>
    예외는 타입 있는 에러 코드를 그대로 뚫고 전파됩니다. throw를
    <code>Either</code>로 잡으려면 <code>Either.catching</code>(실패 타입은
    <code>Object</code>)이나 <code>Either.catchingWith</code>(throw를 먼저
    자신의 실패 타입으로 변환)로 명시하세요. 연습: 실패하는 파싱이
    크래시 대신 <code>Left(bad input)</code>을 출력하도록 만들어 보세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="raise.html"><code>either</code> 빌더</a> — 일직선 코드로 Either 만들기 ·
    <a href="accumulate.html">에러 누적</a> — 첫 실패만이 아니라 모든 실패를 모으기 ·
    <a href="eitherPipelines.html">Either × 파이프라인</a> — 체인 위의 <code>rights</code>, <code>lefts</code>, <code>sequence</code> ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
