---
slug: every
title: every — FxDart 101
description: FxDart every 튜토리얼: 모든 원소가 술어를 만족하는지 검사하며 첫 실패에서 단축 평가합니다. 동기와 비동기 모두 다룹니다.
heading: <code>every</code>
section: 8
crumb: every
prev: isEmpty.html
prevLabel: isEmpty
next: some.html
nextLabel: some
---
  <p class="hero-sub">모든 원소가 술어를 만족할 때 true — 빈 이터러블이면 공허하게 참입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>every</code>는 왼쪽에서 오른쪽으로 훑다가 술어를 만족하지 못하는
    원소를 만나는 즉시 빠져나옵니다 — 단축 평가입니다. 나머지 이터러블은
    건드리지 않고 그 자리에서 <code>false</code>를 반환합니다. 실패하는
    원소가 하나도 없으면(원소 자체가 아예 없는 경우까지 포함해서)
    <code>true</code>를 반환합니다. 빈 이터러블은 "모든 원소가 X다"를
    공허하게 만족하기 때문입니다.
  </p>
  <p>
    동기 체인에는 전용 <code>Fx.every</code>가 없습니다 — 필요하지 않기
    때문입니다. <code>Fx</code>는 이미 Dart 자체의
    <code>Iterable.every</code>를 상속하고 있고, 그것이 정확히 이런 단축
    평가 동작을 갖습니다. 반면 비동기 체인은 각 술어 호출을
    <code>await</code>해야 하므로 자체 <code>.every()</code>를 정의합니다.
  </p>

  <h2>데모 1 · 기본과 단축 평가</h2>
  <p>peek 카운터가 4가 아니라 3에서 멈춥니다 — 첫 실패 지점에서 평가가 중단됩니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>every</code>로 전원이 통과했는지(점수 &gt;= 60) 확인해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="some.html"><code>some</code></a> — "하나라도 만족하는가"에 대응하는 짝 ·
    <a href="filter.html"><code>filter</code></a> — bool 대신 일치하는 원소를 모두 모읍니다 ·
    <a href="find.html"><code>find</code></a> — 처음 실패하거나 일치하는 원소를 얻습니다 ·
    <a href="predicates.html"><code>predicates</code></a> — <code>every</code>와 함께 쓰기 좋은 기성 술어들
  </div>
