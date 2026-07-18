---
slug: identity
title: identity — FxDart 101
description: FxDart identity 튜토리얼: 인자를 그대로 돌려주는 함수와, 그것이 기본 콜백으로 왜 유용한지 살펴봅니다.
heading: <code>identity</code>
section: 10
crumb: identity
prev: matches.html
prevLabel: matches
next: always.html
nextLabel: always
---
  <p class="hero-sub">인자를 그대로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>identity</code>는 라이브러리에서 가장 단순한 함수이면서 가장
    유용한 함수 중 하나입니다. 값을 받아 그대로 돌려줄 뿐이죠. 그 자체만
    보면 아무 쓸모 없어 보입니다. 진가는 어떤 API가 <em>함수를 요구하는데</em>
    정작 아무것도 변환하고 싶지 않을 때 드러납니다 —
    <code>groupBy</code>/<code>sortBy</code>의 기본 키 함수, 디스패치
    테이블의 자리 채우기 분기, 조건부 파이프라인에서 "아무것도 하지 않는"
    쪽 같은 경우입니다.
  </p>
  <p>
    <code>identity</code>는 제네릭이므로(<code>T identity&lt;T&gt;(T a)</code>)
    직접 <code>(x) => x</code>를 쓰지 않아도 단항 함수가 필요한 자리라면
    어디든 들어맞습니다. 비동기 변형도, 체인 형태도 없습니다 — 값을 받아
    값을 내놓는, 그냥 넘겨 주는 용도의 평범한 함수입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>직접 호출하는 경우와, "값 자체를 기준으로 그룹화"가 딱 필요한
    그룹화 연산의 키 함수로 쓰는 경우입니다.</p>
  {{playground:0}}

  <h2>데모 2 · "아무것도 하지 않는" 분기로</h2>
  <p>
    문자열 변환을 모아 둔 디스패치 테이블에서 한 항목만 의도적으로 아무
    일도 하지 않게 하는 예입니다 — 손으로 쓴 no-op 람다 대신
    <code>identity</code>가 그 자리를 깔끔하게 채웁니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>sortBy</code>는 키 함수를 받습니다. <code>identity</code>를
    키 함수로 넘겨 이 단어 리스트를 문자열 자연 순서로 정렬해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="always.html"><code>always</code></a> — 그대로 통과시키는 대신 상수를 반환합니다 ·
    <a href="tap.html"><code>tap</code></a> — 그대로 통과시키되, 먼저 부수 효과를 실행합니다 ·
    <a href="cases.html"><code>cases</code></a> — 술어를 사용하는 디스패치 테이블입니다 ·
    <a href="sortBy.html"><code>sortBy</code></a> — 키 함수가 흔히 쓰이는 자리입니다
  </div>
