---
slug: last
title: last — FxDart 101
description: FxDart last 튜토리얼: 이터러블의 마지막 원소를 얻습니다. 비어 있으면 null을 반환하며, 체인 게터에 얽힌 함정도 함께 짚습니다.
heading: <code>last</code>
section: 8
crumb: last
prev: head.html
prevLabel: head
next: nth.html
nextLabel: nth
---
  <p class="hero-sub">이터러블의 마지막 원소를 반환합니다. 비어 있으면 <code>null</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>last</code>는 이터러블 전체를 훑으면서 가장 마지막에 본 값을
    돌려줍니다 — 아무것도 못 봤다면 <code>null</code>입니다.
    <code>head</code>와 달리 지름길이 없습니다. 지연 이터러블은 끝까지
    끌어당겨 보기 전에는 어디서 끝나는지 알 수 없으므로,
    <code>last</code>는 모든 원소를 소비해야 합니다. 상류 파이프라인이
    지연으로 구성돼 있더라도 <code>O(n)</code>인 이유입니다.
  </p>
  <p>
    <strong>동기 체인에서 주의하세요:</strong> <code>Fx</code>는
    <code>Iterable</code>을 확장하는데 <code>Fx.last()</code> 오버라이드는
    없습니다 — 그래서 <code>fx(iterable).last</code>는 Dart 자체의
    <code>Iterable.last</code> <em>게터</em>로 해석되고, 빈 이터러블에서는
    <code>null</code>을 반환하는 대신 <code>StateError</code>를 던집니다.
    null 안전한 동작은 최상위 <code>last(iterable)</code> 함수(또는 자체
    오버라이드를 가진 <code>.last()</code>, 즉 <em>비동기</em> 체인 쪽)에만
    있습니다. 헷갈린다면 최상위 함수를 쓰세요.
  </p>

  <h2>데모 1 · 기본, 그리고 체인 게터의 함정</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 — 여기서는 체인 형태가 null 안전합니다</h2>
  <p><code>FxAsync</code>는 자체 <code>.last()</code>를 정의하므로, 비동기 체인에서는 위의 게터 함정이 적용되지 않습니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>last</code>를 써서 마지막 로그 줄을 출력하고, 로그가 하나도 없으면 <code>'no logs yet'</code>을 출력해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="head.html"><code>head</code></a> — O(1)로 얻는 반대쪽 끝 ·
    <a href="nth.html"><code>nth</code></a> — 원하는 인덱스 꺼내기 ·
    <a href="find.html"><code>find</code></a> — 술어에 처음 걸리는 값 ·
    <a href="reverse.html"><code>reverse</code></a> — 시퀀스 전체 뒤집기
  </div>
