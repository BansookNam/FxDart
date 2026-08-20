---
slug: size
title: count — FxDart 101
description: FxDart count 튜토리얼: 파이프라인이 만들어내는 원소의 개수를 세는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>count</code>
section: 7
crumb: count
prev: minBy.html
prevLabel: minBy
next: join.html
nextLabel: join
---
  <p class="hero-sub">지연 파이프라인이 만들어내는 원소가 몇 개인지 셉니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>count</code>는 원소를 전부 훑으면서 개수를 세는 종결 연산자입니다 —
    지름길은 없습니다. 상류 파이프라인이 지연 계산되는
    <code>map</code>/<code>filter</code> 체인이라면 실제로 값을 끌어당기기
    전까지는 길이가 정해져 있지 않기 때문입니다. 즉 100만 개짜리
    <code>range</code>에 <code>filter</code>를 걸고 <code>count</code>를
    호출하면 정말로 100만 개를 모두 순회합니다. 다만 그 과정에서
    <code>List</code>를 만들지는 않습니다. <code>count</code>가 Dart다운
    이름이고, fxdart는 FxTS식 표기인 <code>size</code>도 함께 받습니다 —
    같은 연산자입니다.
  </p>
  <p>
    어떤 원소 타입에서도 동작합니다 — 숫자 전용 종결 연산자
    (<code><a href="sum.html">sum</a></code>,
    <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>,
    <code><a href="average.html">average</a></code>)와 달리 <code>count</code>는
    이터러블 안에 무엇이 들었는지는 신경 쓰지 않고 몇 개인지만 봅니다.
  </p>
  <p>
    동기 체인에서 <code>count</code>는 <em>바로</em> Dart에서 물려받은
    <code>Iterable.length</code> 게터입니다(괄호 없음).
    <code>Fx</code>가 <code>Iterable</code>이므로
    <code>fx(pipeline).length</code>가 체인을 훑으며 총 개수를 돌려줍니다.
    이름 붙은 연산자로 쓰는 편이 좋다면 최상위 <code>count(iterable)</code>를,
    <code>.count()</code>는 <em>비동기</em> 체인에서 쓰세요. 이미 구체적인
    <code>List</code>를 들고 있다면 <code>.length</code>가 공짜입니다 —
    <code>count</code>는 지연 체인의 결과를 <code>List</code>로 —
    <code><a href="../101/index.html">toList</a></code>를 거쳐 — 먼저
    구체화하지 않고 개수만 세고 싶을 때 꺼내 쓰는 도구입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <strong>재고 없음</strong>(값이 <code>== 0</code>)인 항목이 몇 개인지 세어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="average.html"><code>average</code></a> — 내부적으로 count와 같은 방식으로 개수를 셉니다 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — "하나라도 있나?"만 알면 될 때 더 저렴한 검사 ·
    <a href="../101/index.html">toList</a> — 세는 대신 구체화하기
  </div>
