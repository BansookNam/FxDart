---
slug: throwIf
title: throwIf — FxDart 101
description: FxDart throwIf 튜토리얼: 조건이 맞으면 예외를 던지고 그렇지 않으면 값을 그대로 통과시키는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>throwIf</code>
section: 10
crumb: throwIf
prev: throwError.html
prevLabel: throwError
next: cases.html
nextLabel: cases
---
  <p class="hero-sub">술어가 참이면 예외를 던지고, 그렇지 않으면 값을 그대로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>throwIf(predicate, toError, value)</code>는 식 한가운데에 끼워 넣을 수
    있는 가드 절입니다. <code>predicate(value)</code>가 참이면
    <code>toError(value)</code>를 던지고, 아니면 <code>value</code>를 손대지 않고
    그대로 돌려줍니다. 덕분에 <code>map</code> 콜백 안에서 쓰기 좋습니다.
    파이프라인을 흘러가는 원소를 하나씩 검증하다가 잘못된 값이 나오는 순간
    바로 실패시킬 수 있기 때문입니다.
  </p>
  <p>
    본질적으로는 <a href="when.html"><code>when</code></a>에서 "then" 분기가
    값을 반환하는 대신 항상 예외를 던지는 형태입니다. 따라서 호출 지점을
    <code>try</code>/<code>catch</code>로 감싸야 실패를 관찰하거나 복구할 수
    있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 파이프라인 검증하기</h2>
  <p>
    각 나이는 map을 거치면서 검증되고, 첫 번째 위반이 발생하는 즉시
    <code>toArray()</code> 호출 전체가 중단됩니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 재고 수량을 합산하면서 <code>throwIf</code>로 재고가 0인 경우를
    막아 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="throwError.html"><code>throwError</code></a> — 조건 없이 항상 던지는 단독 함수 ·
    <a href="when.html"><code>when</code></a> — 예외 대신 다른 값으로 대체 ·
    <a href="cases.html"><code>cases</code></a> — 여러 술어로 분기 ·
    <a href="add.html"><code>add</code></a> — 위에서 리듀서로 사용한 함수
  </div>
