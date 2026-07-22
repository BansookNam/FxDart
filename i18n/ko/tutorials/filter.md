---
slug: filter
title: filter — FxDart 101
description: FxDart filter 튜토리얼: 술어가 통과시킨 원소만 남기는 방법을 동기와 비동기 양쪽에서 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>where</code>
section: 4
crumb: where
prev: pluck.html
prevLabel: pluck
next: reject.html
nextLabel: reject
---
  <p class="hero-sub">술어가 true를 반환한 원소들로 이루어진 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>filter</code>는 <code>map</code>과 더불어 가장 기본이 되는
    변환 연산자입니다. 술어가 <code>true</code>를 반환한 원소만 남기고
    나머지는 버리며, 이 모든 과정은 지연 평가됩니다. 종결 연산자가 값을
    끌어당기기 전까지는 아무것도 실행되지 않습니다. 또한 <code>Fx</code>가
    <code>Iterable</code>을 확장하기 때문에 <code>.where(...)</code>도
    그대로 쓸 수 있습니다 — 체인에서는 <code>.filter(...)</code>의
    별칭일 뿐입니다.
  </p>
  <p>
    지연 평가되므로 <code>filter</code>를 <code>take</code>와 조합하면
    <code>take</code>를 충족하는 데 필요한 만큼만 술어가 호출됩니다 —
    데모 1을 참고하세요.
  </p>
  <p>
    <code>filterAsync</code>는 <code>mapAsync</code>의 구현을 재사용하지 않고
    자체 동시성 구현을 갖고 있습니다. <code>.concurrent(n)</code>을 붙이면
    술어 <code>n</code>개가 병렬로 평가되지만, 통과한 원소는 여전히 원래
    순서대로 하류로 내보내집니다 — 동시성은 처리량을 바꿀 뿐 결과를 바꾸지
    않습니다.
  </p>

  <h2>데모 1 · 기본과 지연 평가</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>filter</code>로 18세 이상만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="reject.html"><code>reject</code></a> — filter의 정반대 ·
    <a href="compact.html"><code>compact</code></a> — null을 걸러 내기 ·
    <a href="map.html"><code>map</code></a> — 남기고 버리는 대신 변환하기 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
