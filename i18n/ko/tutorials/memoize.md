---
slug: memoize
title: memoize — FxDart 101
description: FxDart memoize 튜토리얼 — 인자를 키로 단항 함수의 결과를 캐싱합니다. 동기와 비동기 모두 지원하며 라이브 플레이그라운드 포함.
heading: <code>memoize</code>
section: 10
crumb: memoize
prev: juxt.html
prevLabel: juxt
next: negate.html
nextLabel: negate
---
  <p class="hero-sub">단항 함수의 결과를 인자를 키로 캐싱합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>memoize(f)</code>는 <code>f</code>를 캐시로 감쌉니다. 특정 인자로
    처음 호출되면 <code>f</code>를 실행하고 그 결과를 기억해 두었다가,
    이후 <code>==</code>로 같은 인자가 들어오면 <code>f</code>를 다시 호출하지
    않고 캐시된 결과를 즉시 반환합니다. <code>f</code>가 비싸고(무거운 계산이나
    네트워크 호출) 같은 입력으로 반복 호출될 가능성이 높을 때 꺼내 쓰면 됩니다.
  </p>
  <p>
    FxDart의 <code>memoize</code>는 <strong>단항 전용</strong>이며 인자의
    <code>==</code>/<code>hashCode</code>를 캐시 키로 사용합니다. FxTS 버전은
    가변 인자를 받아 <code>WeakMap</code> 기반 캐시로 전체 인자 목록을 키로
    삼지만, Dart에는 이에 대응하는 수단이 없습니다(가변 제네릭이 없고, 임의의
    객체에 대해 <code>WeakMap</code> 방식의 약한 키를 쓸 수 없습니다). 따라서
    인자가 여러 개인 함수는 하나의 복합 키(레코드가 잘 맞습니다)로 묶어
    메모이즈해야 합니다.
  </p>
  <p>
    <code>R</code>에 제약이 없으므로 <code>f</code>는 <code>Future</code>를
    반환해도 됩니다 — 비동기 연산을 메모이즈하면 <em>Future 자체</em>가
    캐싱되므로, 두 번째 호출은 작업을 다시 실행하지 않고 이미 완료된 future를
    즉시 반환합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 조회 메모이즈하기</h2>
  <p>
    <code>fetchUser(1)</code>의 두 번째 호출은 캐시된, 이미 완료된
    <code>Future</code>를 반환합니다 — 150ms를 기다리지 않습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이 "느린" 세제곱 함수를 <code>memoize</code>로 감싸서
    <code>3</code>으로 두 번 호출해도 실제 계산은 한 번만 일어나게 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — 위에서 느린 비동기 호출을 흉내 내는 데 사용 ·
    <a href="debounce.html"><code>debounce</code></a> — 캐싱 대신 호출 빈도를 제한하기 ·
    <a href="identity.html"><code>identity</code></a> — 감쌀 수 있는 가장 단순한 함수 ·
    <a href="always.html"><code>always</code></a> — 상수값이라 캐싱이 필요 없는 경우
  </div>
