---
slug: sumBy
title: sumBy — FxDart 101
description: FxDart sumBy 튜토리얼 — 모든 원소의 키를 더합니다. map + sum을 한 단계로. 라이브 플레이그라운드 포함.
heading: <code>sumBy</code>
section: 7
crumb: sumBy
prev: sum.html
prevLabel: sum
next: average.html
nextLabel: average
---
  <p class="hero-sub">모든 원소의 키를 더합니다 — <code>map</code> + <code>sum</code>을 한 단계로, 비어 있으면 <code>0</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>sumBy</code>는 데이터 파이프라인에서 가장 흔한 두 단계 꼬리 —
    <code>.map((x) =&gt; x.field).sum()</code> — 를 하나의 종결 연산으로
    합칩니다. 키를 뽑아내면서 누적 합을 함께 fold하므로 중간 결과가
    실체화되지 않고, 의도("이 필드를 합산한다")가 투영 + 집계 두 단계가
    아니라 한 번의 호출로 표현됩니다.
  </p>
  <p>
    동작 규약은 <code><a href="sum.html">sum</a></code>과 같습니다. 빈
    파이프라인의 합은 <code>0</code>이고, <code>int</code> 키는 정수
    연산을 유지하지만 <code>double</code> 키가 하나라도 있으면 합이
    <code>double</code>로 승격됩니다.
  </p>
  <p>
    이것은 Dart 고유의 추가 기능입니다(FxTS는 숫자용 <code>sum</code>만
    제공합니다). <code><a href="maxBy.html">maxBy</a></code> /
    <code><a href="minBy.html">minBy</a></code>와 같은 계열이며,
    Kotlin에서는 <code>sumOf</code>라고 부릅니다.
  </p>

  <h2>데모 1 · 기본 사용법 &amp; 빈 경우</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 키</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 긴 단어들의 길이를 한 번의 호출로 합산해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="sum.html"><code>sum</code></a> — 파이프라인이 이미 숫자를 담고 있을 때 ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — 같은 by-key 계열 ·
    <a href="fold.html"><code>fold</code></a> — 이 함수가 특수화한 일반형
  </div>
