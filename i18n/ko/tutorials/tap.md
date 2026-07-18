---
slug: tap
title: tap — FxDart 101
description: FxDart tap 튜토리얼: 값에 부수 효과를 실행하고 그 값을 그대로 돌려주는 data-first 함수를 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>tap</code>
section: 10
crumb: tap
prev: always.html
prevLabel: always
next: apply.html
nextLabel: apply
---
  <p class="hero-sub">부수 효과를 위해 값을 인자로 함수를 호출한 뒤, 그 값을 그대로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>tap</code>은 data-first입니다. <code>tap(f, value)</code>는
    <code>f(value)</code>를 실행하고 — 보통 <code>print</code>나 로그 호출,
    그 밖의 부수 효과입니다 — <code>value</code>를 손대지 않은 채
    그대로 돌려줍니다. 존재 이유는 <em>값이 속한 표현식을 망가뜨리지 않고</em>
    값을 들여다보기 위해서입니다. 어떤 값이든 <code>tap</code>으로 감싸기만
    하면 주변 코드는 전혀 바꿀 필요가 없습니다.
  </p>
  <p>
    <code>tap</code>은 한 번에 값 하나를 다룹니다. 사촌 격인
    <a href="peek.html"><code>peek</code></a>는 파이프라인 버전으로,
    <code>Iterable</code>의 원소가 끌려 나올 때마다 부수 효과를 실행합니다.
    커링된 재사용 가능한 "로거"가 필요하다면 <code>f</code>를 직접 클로저로
    잡으면 됩니다. 아래처럼 <code>(v) => tap(f, v)</code> 형태입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · pipe 안에서 로깅하기</h2>
  <p>
    <code>tap</code>을 클로저로 감싸면 재사용 가능한 "커링된" 로거가 되고,
    이를 <code>pipe</code> 체인에 끼워 넣어 데이터 흐름을 바꾸지 않은 채
    중간 값을 들여다볼 수 있습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>tap</code>을 사용해 <code>map</code> 콜백을 지나는 각 값을
    10이 곱해지기 전에 출력해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="peek.html"><code>peek</code></a> — tap의 파이프라인 버전 ·
    <a href="pipe1.html"><code>pipe1</code></a> / <a href="pipe.html"><code>pipe</code></a> — 값을 함수들에 차례로 흘려보냅니다 ·
    <a href="identity.html"><code>identity</code></a> — 부수 효과 없이 그대로 통과시킵니다 ·
    <a href="apply.html"><code>apply</code></a> — 동적인 인자 목록으로 함수를 호출합니다
  </div>
