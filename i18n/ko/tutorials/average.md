---
slug: average
title: average — FxDart 101
description: FxDart average 튜토리얼 — 파이프라인이 만들어 내는 모든 숫자의 평균을 구하고, 비어 있으면 NaN을 반환합니다. 라이브 플레이그라운드 포함.
heading: <code>average</code>
section: 7
crumb: average
prev: sumBy.html
prevLabel: sumBy
next: min.html
nextLabel: min
---
  <p class="hero-sub">파이프라인이 만들어 내는 모든 숫자의 평균 — 하나도 없으면 <code>NaN</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>average</code>는 파이프라인 전체를 한 번 순회하면서 누적 합과
    누적 개수를 함께 추적한 뒤 나누는 종결 연산자입니다. 평범한
    <code>int</code> 리스트에 대해서도 항상 <code>double</code>을
    반환합니다.
  </p>
  <p>
    꼭 기억해 둘 동작이 하나 있습니다. <code>average</code>는
    <strong>비어 있는</strong> 이터러블에 대해 <code>double.nan</code>을 반환합니다 —
    예외를 던지거나 <code>0</code>으로 대체하는 것이 아니라
    <code>0 / 0</code>을 계산한 결과입니다. FxTS의 동작을 그대로
    따릅니다. 파이프라인이 비어 있을 수 있다면, 숫자 기본값을 가정하지
    말고 <code>result.isNaN</code>으로 명시적으로 확인하세요.
  </p>
  <p>
    <code><a href="sum.html">sum</a></code>과 마찬가지로 체인 형태는
    <code>Fx&lt;num&gt;</code> / <code>FxAsync&lt;num&gt;</code> 확장으로
    제공됩니다. 따라서 체인의 원소 타입이 숫자임을 컴파일러가 알 수 있을
    때에만 사용할 수 있습니다.
  </p>

  <h2>데모 1 · 기본 사용법 &amp; 빈 경우</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <strong>합격</strong> 점수(&gt;= 60)만 골라 평균을 내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="sum.html"><code>sum</code></a> — 평균을 구할 때의 분자 ·
    <a href="size.html"><code>size</code></a> — 평균을 구할 때의 분모 ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — 나머지 숫자 종결 연산자
  </div>
