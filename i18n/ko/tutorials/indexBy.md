---
slug: indexBy
title: indexBy — FxDart 101
description: FxDart indexBy 튜토리얼 — 계산된 키로 모든 원소를 Map에 색인하고 나중 값이 이기는 동작을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>indexBy</code>
section: 7
crumb: indexBy
prev: groupBy.html
prevLabel: groupBy
next: countBy.html
nextLabel: countBy
---
  <p class="hero-sub">계산된 키로 모든 원소를 <code>Map&lt;K, A&gt;</code>에 색인합니다 — 키가 겹치면 나중 값이 이깁니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>indexBy</code>는 <code><a href="groupBy.html">groupBy</a></code>의
    형제입니다. 파이프라인 전체를 끌어당기며 원소마다 키를 계산한다는
    발상은 같지만, 키마다 <em>리스트</em>를 모으는 대신 값을
    <strong>하나만</strong> 유지합니다. 즉
    <code>Map&lt;K, List&lt;A&gt;&gt;</code>가 아니라
    <code>Map&lt;K, A&gt;</code>입니다.
  </p>
  <p>
    그래서 중복은 쌓이지 않고 덮어씁니다. 두 원소가 같은 키를 만들어 내면
    <strong>나중에</strong> 처리된 쪽(즉 이터러블에서 뒤에 오는 쪽)이
    맵에 남습니다. 앞으로 훑어 나가며 <code>result[key(a)] = a</code>를
    반복하면 자연스럽게 나오는 동작이고, FxTS와도 일치합니다. 키가 유일하다는
    사실을 알고 있고(데이터베이스 ID처럼) 일일이 뒤져야 하는 리스트 대신
    <code>O(1)</code> 조회를 바로 쓰고 싶을 때
    <code>indexBy</code>를 꺼내 쓰면 됩니다.
  </p>
  <p>
    키가 겹칠 것을 예상하고 모든 값을 남기고 싶다면 대신
    <code>groupBy</code>를 쓰세요. 아무것도 버리지 않습니다.
  </p>

  <h2>데모 1 · 기본, 그리고 나중 값이 이기는 동작</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 사용자를 <strong>id 기준으로</strong> 색인해서 바로 조회할 수 있게 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — 덮어쓰지 않고 중복을 모두 유지 ·
    <a href="countBy.html"><code>countBy</code></a> — 값을 남기는 대신 개수를 세기 ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — 키/값 쌍에서 곧바로 Map 만들기
  </div>
