---
slug: always
title: always — FxDart 101
description: FxDart always 튜토리얼 - 인자를 무시하고 언제나 고정된 값을 반환하는 함수를 만드는 법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>always</code>
section: 10
crumb: always
prev: identity.html
prevLabel: identity
next: tap.html
nextLabel: tap
---
  <p class="hero-sub">인자를 무시하고 언제나 같은 고정값을 반환하는 함수를 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>always(a)</code>는 <code>a</code>를 클로저에 담아, 무엇을 인자로
    받든 버리고 매번 <code>a</code>를 반환하는 함수를 돌려줍니다.
    파라미터가 선택적이라는 점이 핵심인데, 덕분에 <em>단항</em> 콜백이
    필요한 어느 자리에나 그대로 들어맞습니다 — 매퍼, <code>orElse</code>
    핸들러, 폴백 분기 등 — 매번 <code>(_) => a</code>를 직접 쓸 필요가
    없습니다.
  </p>
  <p>
    <a href="identity.html"><code>identity</code></a>의 상수 버전이라고 보면
    됩니다. <code>identity</code>는 입력을 그대로 통과시키고,
    <code>always</code>는 입력을 버립니다. 둘 다 비동기 변형이나 체인
    형태가 없는 평범한 동기 함수입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>선택적 인자에 주목하세요 — <code>greet(123)</code>도 여전히
    <code>'hi'</code>를 반환하며, 그래서 <code>map</code> 콜백으로 쓸 수 있습니다:</p>
  {{playground:0}}

  <h2>데모 2 · 디스패치 테이블의 상수 폴백</h2>
  <p>
    <code>always</code>는 <code>orElse</code> 인자로 쓰기에 딱 맞습니다.
    특히 <a href="cases.html"><code>cases</code></a>에서 그렇습니다 —
    매칭되지 않은 값을 들여다볼 필요가 없는 고정 기본값이니까요:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>always</code>를 사용해 이 리스트의 모든 점수를 문자열
    <code>'graded'</code>로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="identity.html"><code>identity</code></a> — 대신 인자를 그대로 통과시킴 ·
    <a href="cases.html"><code>cases</code></a> — orElse 자리에 always와 자주 짝을 이루는 디스패치 테이블 ·
    <a href="when.html"><code>when</code></a> — 값을 받아 값을 내놓는 조건부 변환 ·
    <a href="memoize.html"><code>memoize</code></a> — 상수가 아니라 계산된 값을 캐싱
  </div>
