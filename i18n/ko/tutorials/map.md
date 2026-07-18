---
slug: map
title: map — FxDart 101
description: FxDart map 튜토리얼: 지연 파이프라인의 각 원소를 동기·비동기로 변환하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>map</code>
section: 3
crumb: map
next: mapEffect.html
nextLabel: mapEffect
---
  <p class="hero-sub">각 원소를 함수에 통과시켜 만든 값들의 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>map</code>은 가장 기본이 되는 변환 연산자입니다. 모든 원소에
    함수를 적용하죠. FxDart에서는 <strong>지연 평가</strong>됩니다 —
    <code>map</code>을 호출하는 것만으로는 아무 일도 일어나지 않습니다.
    종결 연산자(<code>toArray</code>, <code>each</code>,
    <code>reduce</code> …)가 파이프라인에서 값을 끌어당길 때 비로소 함수가
    실행됩니다. 덕분에 필요한 만큼만 끌어당긴다면 엄청나게 큰 —
    심지어 무한한 — 시퀀스에도 <code>map</code>을 걸 수 있습니다.
  </p>
  <p>
    data-first 형태(<code>map(f, iterable)</code>)와 체인
    메서드(<code>fx(iterable).map(f)</code>) 두 가지로 쓸 수 있습니다. 둘 다
    동일한 지연 결과를 반환합니다.
  </p>

  <h2>데모 1 · 기본과 지연 평가</h2>
  <p>100만 개 중에서 <code>take(3)</code>이 끌어당기는 3개에 대해서만
    매핑 함수가 실행되는 것을 확인해 보세요:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  <p>
    <code>mapAsync</code>(또는 <code>.toAsync().map(...)</code>)는 비동기
    함수를 받습니다. 그대로 두면 원소를 하나씩 순서대로 await 하지만,
    <code>concurrent(n)</code>을 붙이면 상류가 한 번에 <code>n</code>개씩
    평가합니다 — 결과는 여전히 순서대로 도착합니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>map</code>으로 이 Map 리스트를
    <code>"KIM (32)"</code> 같은 형식의 이름 문자열 리스트로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="mapEffect.html"><code>mapEffect</code></a> — map과 같지만 부수 효과임을 드러냅니다 ·
    <a href="flatMap.html"><code>flatMap</code></a> — map + 평탄화 ·
    <a href="peek.html"><code>peek</code></a> — 변환하지 않고 들여다보기 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
