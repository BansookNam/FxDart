---
slug: averageBy
title: averageBy — FxDart 101
description: FxDart averageBy 튜토리얼 — 모든 원소에 대한 키의 평균을 map + average 한 단계로 구합니다. 라이브 플레이그라운드 포함.
heading: <code>averageBy</code>
section: 7
crumb: averageBy
prev: average.html
prevLabel: average
next: min.html
nextLabel: min
---
  <p class="hero-sub">모든 원소에 대한 키의 평균 — <code>map</code> + <code>average</code>를 한 단계로, 비어 있으면 <code>NaN</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>averageBy</code>는 by-key 계열
    (<code><a href="sumBy.html">sumBy</a></code> ·
    <code><a href="maxBy.html">maxBy</a></code> ·
    <code><a href="minBy.html">minBy</a></code>)을 완성합니다. 각
    원소에서 숫자 키를 뽑아내 키들의 평균을 구하며, 누적 합과 개수를
    함께 추적하는 단 한 번의 순회로 처리합니다.
  </p>
  <p>
    동작 규약은 <code><a href="average.html">average</a></code>와
    같습니다. 빈 파이프라인은 <code>double.nan</code>을 반환하며
    (<code>0 / 0</code>을 계산한 결과입니다), 결코 <code>0</code>이
    아닙니다 — 입력이 비어 있을 수 있다면 <code>result.isNaN</code>으로
    확인하세요. 결과는 항상 <code>double</code>입니다.
  </p>

  <h2>데모 1 · 기본 사용법 &amp; 빈 경우</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 키</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 읽은 책들의 페이지 수만 한 번의 호출로 평균 내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="average.html"><code>average</code></a> — 파이프라인이 이미 숫자를 담고 있을 때 ·
    <a href="sumBy.html"><code>sumBy</code></a> — 분자에 해당하는 사촌 ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — 계열의 나머지
  </div>
