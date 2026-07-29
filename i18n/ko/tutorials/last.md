---
slug: last
title: lastOrNull — FxDart 101
description: FxDart lastOrNull: 이터러블의 마지막 원소를 얻습니다. 비어 있으면 null을 반환하며, 체인 게터에 얽힌 함정도 함께 짚습니다.
heading: <code>lastOrNull</code>
section: 8
crumb: lastOrNull
prev: head.html
prevLabel: head
next: nth.html
nextLabel: nth
---
  <p class="hero-sub">이터러블의 마지막 원소를 반환합니다. 비어 있으면 <code>null</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>lastOrNull</code>은 이터러블 전체를 훑으면서 가장 마지막에 본
    값을 돌려줍니다 — 아무것도 못 봤다면 <code>null</code>입니다.
    <code>lastOrNull</code>은 Dart다운 이름이고
    (<code>Iterable.lastOrNull</code>과 짝을 이룹니다), fxdart는 FxTS식
    표기인 <code>last</code>도 함께 받아들입니다 — 둘은 같은 연산자입니다.
    <code>head</code>와 달리 지름길은 없습니다. 지연 이터러블은 끝까지
    끌어당겨 보기 전에는 어디서 끝나는지 알 수 없으므로,
    <code>lastOrNull</code>은 모든 원소를 소비해야 합니다. 상류 파이프라인이
    지연으로 구성돼 있더라도 <code>O(n)</code>인 이유입니다.
  </p>
  <p>
    <strong>동기 체인에서 주의하세요:</strong> <code>Fx</code>는
    <code>Iterable</code>을 확장하므로 <code>fx(iterable).lastOrNull</code>은
    Dart가 물려준 <code>Iterable.lastOrNull</code> <em>게터</em>로
    해석됩니다(괄호 없음) — 이 게터는 <em>실제로</em> null 안전해서 빈
    이터러블에서 <code>null</code>을 반환합니다. 함정은 바로 옆에 있는 "OrNull"이 없는
    <code>.last</code> 게터입니다. <code>fx(&lt;int&gt;[]).last</code>는
    <code>null</code>을 반환하는 대신 <code>StateError</code>를 던집니다.
    <code>.lastOrNull</code>이나 최상위 <code>lastOrNull(iterable)</code>
    함수를 쓰세요. <em>비동기</em> 체인에서 <code>.lastOrNull()</code>은
    메서드라 괄호가 붙습니다.
  </p>

  <h2>데모 1 · 기본, 그리고 체인 게터의 함정</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 — 여기서는 체인 형태가 null 안전합니다</h2>
  <p><code>FxAsync</code>는 자체 <code>.lastOrNull()</code> 메서드를 정의하므로, 비동기 체인에서는 위의 게터 함정이 적용되지 않습니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>lastOrNull</code>을 써서 마지막 로그 줄을 출력하고, 로그가 하나도 없으면 <code>'no logs yet'</code>을 출력해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="head.html"><code>head</code></a> — O(1)로 얻는 반대쪽 끝 ·
    <a href="nth.html"><code>nth</code></a> — 원하는 인덱스 꺼내기 ·
    <a href="find.html"><code>find</code></a> — 술어에 처음 걸리는 값 ·
    <a href="reverse.html"><code>reverse</code></a> — 시퀀스 전체 뒤집기
  </div>
