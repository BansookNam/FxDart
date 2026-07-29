---
slug: sparse-timeseries
title: 희소한 시계열의 빈틈 채우기 — Dart vs FxDart
description: 거래가 없는 날은 0.00이 되고, 이어서 합계가 있는 주간 행이 만들어집니다 — 하나의 흐름으로서의 range + groupBy + chunk 대 카운팅 루프와 슬라이스.
heading: 희소한 시계열의 빈틈 채우기
order: 35
tier: 4
functions: groupBy, range, map, sumBy, chunk, zipWithIndex, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    7월 1일부터 14일까지의 거래(데이터는 코드에 있음)는 일부 날짜에만
    존재합니다. <strong>빈틈 없는</strong> 일별 시계열을 만드세요 —
    거래가 없는 날은 <code>0.00</code>으로 집계합니다 — 그런 다음
    이를 각각 7개의 일별 값과 주간 합계를 가지는 두 개의 주간 행으로
    출력하세요. 두 버전 모두 <em>예상 출력</em> 아래의 블록을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    빈틈 채우기는 파이프라인을 데이터가 아니라 <em>달력</em>이 이끌게
    한다는 뜻입니다: <code>range(1, 15)</code>가 모든 날짜를 생성하고,
    <code>groupBy</code>가 "그날 무슨 일이 있었는지"에 답하며,
    <code>sumBy</code>는 비어 있을 수도 있는 그룹에 대해서도 조용한
    날의 0.00을 공짜로 만들어냅니다. 주간 집계는 그다음
    <code>chunk(7)</code> + <code>zipWithIndex</code>로 이루어집니다 —
    행 레이블 이상의 어떤 인덱스 계산도 없이 빈틈 없는 시계열을
    재구성합니다. 네이티브 Dart는 카운팅 <code>for</code> 루프로
    빈틈 없는 시계열을 얻고, <code>package:collection</code>의
    <code>slices</code>/<code>indexed</code>로 집계를 얻습니다 —
    동작은 하지만, 그룹 합산 단계는 두 번 다 시드가 있는
    <code>fold</code>이고, 두 단계가 하나의 눈에 보이는 흐름으로
    합쳐지지 않습니다.
  </p>
