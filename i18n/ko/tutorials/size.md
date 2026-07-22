---
slug: size
title: size — FxDart 101
description: FxDart size 튜토리얼: 파이프라인이 만들어내는 원소의 개수를 세는 방법을 라이브 플레이그라운드와 함께 다룹니다.
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
    <code>size</code>는 원소를 전부 훑으면서 개수를 세는 종결 연산자입니다 —
    지름길은 없습니다. 상류 파이프라인이 지연 계산되는
    <code>map</code>/<code>filter</code> 체인이라면 실제로 값을 끌어당기기
    전까지는 길이가 정해져 있지 않기 때문입니다. 즉 100만 개짜리
    <code>range</code>에 <code>filter</code>를 걸고 <code>size</code>를
    호출하면 정말로 100만 개를 모두 순회합니다. 다만 그 과정에서
    <code>List</code>를 만들지는 않습니다.
  </p>
  <p>
    어떤 원소 타입에서도 동작합니다 — 숫자 전용 종결 연산자
    (<code><a href="sum.html">sum</a></code>,
    <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>,
    <code><a href="average.html">average</a></code>)와 달리 <code>size</code>는
    이터러블 안에 무엇이 들었는지는 신경 쓰지 않고 몇 개인지만 봅니다.
  </p>
  <p>
    이미 구체적인 <code>List</code>를 들고 있다면 <code>.length</code>가
    공짜입니다 — <code>size</code>는 지연 체인의 결과를 먼저
    <code>List</code>로 구체화하지 않고서 개수만 세고 싶을 때, 즉
    <code><a href="../101/index.html">toList</a></code>를 부르고 싶지 않을 때
    꺼내 쓰는 도구입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <strong>재고 없음</strong>(값이 <code>== 0</code>)인 항목이 몇 개인지 세어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="average.html"><code>average</code></a> — 내부적으로 size와 같은 방식으로 개수를 셉니다 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — "하나라도 있나?"만 알면 될 때 더 저렴한 검사 ·
    <a href="../101/index.html">toList</a> — 세는 대신 구체화하기
  </div>
