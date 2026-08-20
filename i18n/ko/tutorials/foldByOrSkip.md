---
slug: foldByOrSkip
title: foldByOrSkip — FxDart 101
description: FxDart foldByOrSkip 튜토리얼 — 필터와 키별 접기를 컴파일러가 인라인할 수 있는 하나의 즉시 호출로. 실행 가능한 플레이그라운드 포함.
heading: <code>foldByOrSkip</code>
section: 7
crumb: foldByOrSkip
prev: foldBy.html
prevLabel: foldBy
next: countWhere.html
nextLabel: countWhere
---
  <p class="hero-sub"><code>foldBy</code>처럼 키별로 접되, 키가 <code>null</code>이면 그 원소를 건너뜁니다 — 콜백 하나가 선택과 분류를 겸합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>foldByOrSkip(key, seed, f, xs)</code>는
    <code><a href="filter.html">filter</a></code> +
    <code><a href="foldBy.html">foldBy</a></code>를 하나의 즉시(strict)
    호출로 쓴 것입니다. <code>foldBy</code>가 보장하는 것은 그대로입니다 —
    <code>seed</code>는 키마다 시작점이지 키를 가로질러 누적되지 않고, 키는
    처음 등장한 순서로 나오며, 맵은 원소당 한 번만 조회됩니다. 한 가지
    비틀림은 키 함수입니다: <code>null</code>을 반환하면 "이 원소는
    건너뛴다"는 뜻으로,
    <code><a href="takeUniqBy.html">takeUniqBy</a></code>가 쓰는 것과 같은
    <code>filter_map</code> 형태입니다.
  </p>
  <p>
    기본은 <code>filter(...).foldBy(...)</code>로 쓰십시오. 이름 붙은 두
    단계가 두 질문을 겸하는 콜백 하나보다 잘 읽히고, 여기서는 그 두 질문이
    대개 무관합니다 — 날짜 범위와 카테고리는 같은 생각이 아닙니다. 이
    연산자가 존재하는 이유는 하나뿐이며, 그게 무엇인지 아는 편이 좋습니다.
  </p>

  <h2>존재 이유: 컴파일러가 볼 수 없는 술어</h2>
  <p>
    <code>filter</code>는 <em>지연</em> 단계라 술어를 이터레이터의 필드에
    담아 둡니다. AOT 컴파일러는 필드 너머를 보지 못하므로 그 술어는 결코
    인라인되지 않습니다 — 원소마다 실제 간접 호출을 내고, 본문이 주변 루프에
    녹아들지도 못합니다. <code>foldBy</code>에는 그 문제가 없습니다. 즉시
    연산자라 콜백이 매개변수이고 호출부에 인라인됩니다. 앞에 붙은 필터가
    비용입니다.
  </p>
  <p>
    <code>foldByOrSkip</code>은 그 판정을 매개변수인 키 안으로 옮깁니다.
    거래 100만 건, 12개월 중 한 달만 남기는 조건, AOT 기준:
  </p>
  <table>
    <thead><tr><th>표현</th><th>시간</th></tr></thead>
    <tbody>
      <tr><td><code>filter().foldBy()</code></td><td>14.5 ms</td></tr>
      <tr><td><code>foldByOrSkip(…)</code></td><td><strong>12.6 ms</strong></td></tr>
      <tr><td>손으로 쓴 루프</td><td>11.3 ms</td></tr>
    </tbody>
  </table>
  <p>
    두 표현과 두 막대 모두
    <a href="../DartComparison/monthly-category-report.html">월별 카테고리
    리포트</a> 페이지에 있습니다 — 같은 파이프라인을 쓰는 두 방식의 차이가
    그 페이지가 말하려는 바라서, 막대를 둘이 아니라 셋 싣는 두 페이지 중
    하나입니다.
  </p>

  <h2>데모 1 · 7월의 카테고리별 지출</h2>
  {{playground:0}}

  <h2>데모 2 · seed, 건너뛰기, 그리고 fold가 보는 것</h2>
  {{playground:1}}

  <h2>직접 해보기</h2>
  <p>연습: 고장 난 행을 빼고 센서별 최고 측정값 구하기.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="foldBy.html"><code>foldBy</code></a> — 이 연산자가 딛고 선 접기 ·
    <a href="filter.html"><code>filter</code></a> — 흡수한 단계 ·
    <a href="takeUniqBy.html"><code>takeUniqBy</code></a> — <code>filter</code> + <code>uniqBy</code> + <code>take</code>에 대한 같은 발상 ·
    <a href="performance.html">성능</a> — 콜백 바닥값이 어디서 오는지
  </div>
