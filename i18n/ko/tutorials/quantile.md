---
slug: quantile
title: quantile — FxDart 101
description: FxDart quantile과 quantileBy 튜토리얼 — 입력 전체를 정렬하지 않고 quickselect로 O(n)에 중앙값이나 백분위수를 구합니다. 라이브 플레이그라운드 포함.
heading: <code>fxQuantile</code> · <code>fxQuantileBy</code>
section: 7
crumb: quantile
prev: minBy.html
prevLabel: minBy
next: size.html
nextLabel: count
---
  <p class="hero-sub">중앙값, p95, 혹은 어떤 백분위수든 — 전부 정렬하지 않고 선형 시간에 찾아냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    백분위수를 읽는 흔한 방법은 사본을 정렬한 뒤 인덱싱하는 것입니다:
    <code>sorted[((n - 1) * q).round()]</code>. 위치 하나를 읽으려고
    <code>O(n log n)</code>을 쓰는 셈입니다.
    <code>fxQuantile(q, xs)</code>는 같은 값을
    <strong>quickselect</strong>로 반환합니다. quickselect는 그 한 위치가
    확정될 때까지만 분할하므로 평균 <code>O(n)</code>이며, 세 값의 중앙값
    피벗 덕분에 실제로 흔한 모양인 이미 정렬된 입력과 역순 입력도 선형으로
    처리됩니다. 입력은 절대 재배열되지 않고, 작업은 사본에서 일어납니다.
  </p>
  <p>
    순위는 <em>nearest rank</em> 방식입니다. 정렬된 입력의
    <code>((n - 1) * q).round()</code> 인덱스에 있는 값입니다. 따라서
    <code>q = 0</code>은 최솟값, <code>1</code>은 최댓값,
    <code>0.5</code>는 중앙값이며 — 길이가 짝수이면 가운데 두 값 중 큰
    쪽입니다. 보간은 하지 않습니다. 답은 언제나 입력 중 하나입니다. 빈
    입력은 <code>null</code>을 반환하고, <code>[0, 1]</code> 범위를 벗어난
    <code>q</code>는 <code>ArgumentError</code>를 던집니다.
  </p>
  <p>
    <code>fxQuantileBy(q, f, xs)</code>는 숫자 키로 순위를 매기고
    <em>원소</em>를 반환합니다 — 중앙값 가격이 아니라 중앙값 가격의 상품을.
    <code>f</code>는 원소마다 한 번 실행됩니다. 체인에서는
    <code>fx(numbers).quantile(q)</code>와
    <code>fx(items).quantileBy(q, f)</code>입니다. fxdart 확장 기능입니다(FxTS에는
    없습니다).
  </p>

  <h2>데모 1 · 중앙값과 백분위수</h2>
  {{playground:0}}

  <h2>데모 2 · quantileBy는 원소를 반환</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 정렬 후 인덱싱하는 코드를 호출 하나로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="minBy.html"><code>minBy</code></a> · <a href="maxBy.html"><code>maxBy</code></a> — 양 끝을 한 번의 순회로 ·
    <a href="sortBy.html"><code>sortBy</code></a> — 전체 순서가 필요할 때 ·
    <a href="averageBy.html"><code>averageBy</code></a> — 중앙값 대신 평균
  </div>
