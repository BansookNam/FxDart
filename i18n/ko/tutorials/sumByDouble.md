---
slug: sumByDouble
title: sumByDouble — FxDart 101
description: FxDart sumByDouble과 sumByInt 튜토리얼 — 결과가 이미 double이나 int로 타입이 정해진 선택자 합계. 동기와 비동기 모두 지원하며 라이브 플레이그라운드 포함.
heading: <code>sumByDouble</code> · <code>sumByInt</code>
section: 7
crumb: sumByDouble
prev: sumBy.html
prevLabel: sumBy
next: average.html
nextLabel: average
---
  <p class="hero-sub">결과 타입이 이미 정해진 <code>sumBy</code>입니다 — 캐스트 없이 <code>double</code>이나 <code>int</code>로.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="sumBy.html">sumBy</a></code>는 <code>num</code>을
    반환합니다. 선택자가 어느 쪽 숫자든 반환할 수 있기 때문입니다. 섞인
    열에는 그게 맞지만, 타입이 정해진 열에는 번거롭습니다.
    <code>double</code> 필드에 저장된 금 시세나 <code>int</code> 필드에
    저장된 개수는 합계를 낼 때마다 <code>.toDouble()</code>이나
    <code>.toInt()</code>가 필요합니다. <code>sumByDouble(f)</code>와
    <code>sumByInt(f)</code>는 이미 그 타입을 반환하는 선택자를 받아 타입을
    그대로 돌려줍니다.
  </p>
  <p>
    하는 일도 조금 더 적습니다. <code>sumBy</code>는 <code>int</code>
    누적값으로 시작했다가 정수가 아닌 값이 처음 들어오는 순간
    <code>double</code>로 바꾸므로, 원소마다 타입 검사 비용이 듭니다. 이
    둘은 처음부터 맞는 누적값으로 시작해 더하기만 합니다. 더하는 순서는
    같은 왼쪽에서 오른쪽으로의 순회이므로 <code>sumByDouble</code>은
    <code>sumBy</code>와 정확히 똑같이 반올림됩니다. 빈 입력은 타입을 유지한
    채 <code>0.0</code>과 <code>0</code>을 반환합니다.
  </p>
  <p>
    fxdart 확장 기능입니다(FxTS에는 없습니다). camelCase 단어가 세 개이므로
    명명 규칙에 따라 최상위 형태에 <code>fx</code> 접두사가 붙지 않습니다.
  </p>

  <h2>데모 1 · 캐스트 없이</h2>
  {{playground:0}}

  <h2>데모 2 · 빈 입력과 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 타입이 정해진 합계를 써서 두 캐스트를 모두 없애 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="sumBy.html"><code>sumBy</code></a> — 섞인 열을 위한 <code>num</code> 형태 ·
    <a href="sum.html"><code>sum</code></a> — 숫자 자체의 합 ·
    <a href="averageBy.html"><code>averageBy</code></a> — 선택자의 평균
  </div>
