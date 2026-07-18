---
slug: zipWithIndex
title: zipWithIndex — FxDart 101
description: FxDart zipWithIndex 튜토리얼: 각 요소를 0부터 시작하는 인덱스와 짝지어 주며, 라이브 플레이그라운드가 함께 제공됩니다.
heading: <code>zipWithIndex</code>
section: 6
crumb: zipWithIndex
prev: zipWith.html
prevLabel: zipWith
next: transpose.html
nextLabel: transpose
---
  <p class="hero-sub">각 요소를 (0부터 시작하는) 인덱스와 짝지어 <code>(index, value)</code>로 만듭니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>zipWithIndex</code>는 암묵적인 카운터와 <code>zip</code>하는
    것이라고 보면 됩니다. 각 요소는 <code>0</code>부터 올라가는
    <code>(index, value)</code> 쌍으로 나옵니다. 손으로 쓰던
    <code>for (var i = 0; i &lt; list.length; i++)</code> 루프를
    지연 파이프라인에서 대체하는 방법이죠 — 따로 관리할 카운터 변수가 없고,
    체인의 나머지 부분과 자연스럽게 조합됩니다.
  </p>
  <p>
    증가하는 카운터 하나만 추적하면 되기 때문에
    <code>zipWithIndex</code>는 지연 평가를 유지하며, 유한한 소스뿐
    아니라 무한한 소스에서도 똑같이 잘 동작합니다. 비동기 형태도
    요소가 완료되는 대로 같은 방식으로 번호를 매깁니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 각 주자를 (0부터 시작하는) 완주 순위와 짝지어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="zip.html"><code>zip</code></a> — 두 이터러블을 짝지어 묶습니다 ·
    <a href="zipWith.html"><code>zipWith</code></a> — 묶으면서 한 번에 결합합니다 ·
    <a href="entries.html"><code>entries</code></a> — Map의 키와 값을 짝지어 줍니다
  </div>
