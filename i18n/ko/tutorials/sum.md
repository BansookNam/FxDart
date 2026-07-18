---
slug: sum
title: sum — FxDart 101
description: FxDart sum 튜토리얼 — 파이프라인이 만들어 내는 모든 숫자를 더합니다. 라이브 플레이그라운드 포함.
heading: <code>sum</code>
section: 7
crumb: sum
prev: reduceLazy.html
prevLabel: reduceLazy
next: average.html
nextLabel: average
---
  <p class="hero-sub">지연 파이프라인이 만들어 내는 모든 숫자를 더합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>sum</code>은 종결 연산자이며, 라이브러리에서 특수화된 fold 중
    가장 단순한 축에 속합니다. 내부적으로는 말 그대로
    <code>fold(0, (a, b) =&gt; a + b, iterable)</code>입니다. 다른 종결
    연산자와 마찬가지로 호출하는 순간 상류의 지연 파이프라인 전체를
    끌어당깁니다 — 그래서 <code>map</code>/<code>filter</code> 단계를
    아무리 길게 엮어도 <code>sum</code>이 실제로 필요로 하는 값만큼만
    비용을 치릅니다. 물론 여기서는 그게 전부입니다.
  </p>
  <p>
    시드가 <code>0</code>이므로 빈 이터러블의 합은 <code>0</code>입니다 —
    예외도, <code>NaN</code>도 없습니다. 이웃한
    <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>,
    <code><a href="average.html">average</a></code>와는 다른 점인데,
    이들은 각자 (의외의!) 빈 입력 동작이 따로 있으니 알아 둘 필요가
    있습니다.
  </p>
  <p>
    체인 형태는 확장 메서드
    <code>Fx&lt;num&gt;.sum()</code> / <code>FxAsync&lt;num&gt;.sum()</code>으로
    제공됩니다 — 체인의 원소 타입이 <code>num</code>(제네릭 공변성 덕분에
    <code>int</code>/<code>double</code>도 포함)임이 알려진 뒤에야
    나타납니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 리스트에서 <strong>짝수</strong>만 골라 더해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="average.html"><code>average</code></a> — 합을 개수로 나눈 값 ·
    <a href="fold.html"><code>fold</code></a> — sum이 특수화한 일반형 ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — 나머지 숫자 종결 연산자
  </div>
