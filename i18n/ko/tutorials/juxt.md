---
slug: juxt
title: juxt — FxDart 101
description: FxDart juxt 튜토리얼 — 같은 값에 여러 함수를 적용해 결과를 한꺼번에 모으는 방법을 라이브 플레이그라운드로 익혀 봅니다.
heading: <code>juxt</code>
section: 10
crumb: juxt
prev: apply.html
prevLabel: apply
next: memoize.html
nextLabel: memoize
---
  <p class="hero-sub">리스트에 담긴 모든 함수를 같은 값에 적용하고 그 결과를 모읍니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    같은 입력을 받는 함수들의 리스트를 <code>juxt</code>에 넘기면, 그 입력을
    모든 함수에 통과시켜 결과를 순서대로 담은 <code>List</code>를 반환하는
    함수 하나를 돌려줍니다. 같은 코드를 반복하지 않고도 값 하나에서
    서로 독립적인 여러 관점을 뽑아내는 간결한 방법입니다.
  </p>
  <p>
    FxTS의 <code>juxt</code>는 가변 인자를 받고 인자 개수가 서로 다른 함수도
    받을 수 있습니다. Dart에는 가변 제네릭이 없어서 FxDart 버전은 항목마다
    단항 함수 <code>T -&gt; R</code> 하나씩만 받습니다 — 그래도 "이 값 하나에
    읽기 전용 투영 N개를 돌린다"는 흔한 경우를 감당하기에는 충분합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>dartdoc에 나오는 전형적인 예제입니다. 리스트의 최솟값과 최댓값을
    한 번에 계산합니다:</p>
  {{playground:0}}

  <h2>데모 2 · 여러 필드 투영하기</h2>
  <p>레코드 같은 <code>Map</code>에서 여러 필드를 한꺼번에 꺼냅니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>juxt</code>로 이 리스트의 <code>sum</code>과
    <code>average</code>를 한 번에 계산해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="apply.html"><code>apply</code></a> — 동적인 인자 목록으로 함수 호출하기 ·
    <a href="cases.html"><code>cases</code></a> — 전부 실행하는 대신 술어로 함수 하나 고르기 ·
    <a href="min.html"><code>min</code></a> / <a href="max.html"><code>max</code></a> — 위 데모에서 함께 쓴 함수 ·
    <a href="zip.html"><code>zip</code></a> — 하나가 아니라 두 시퀀스의 값을 결합하기
  </div>
