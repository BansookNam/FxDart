---
slug: price-drop-detection
title: 두 스냅숏 사이의 가격 하락 — Dart vs FxDart
description: 두 가격표 스냅숏을 비교해 저렴해진 항목을 보고합니다 — indexBy + filter + sortBy + head + sumBy와, 맵 리터럴 및 where/fold 체인을 비교합니다.
heading: 두 스냅숏 사이의 가격 하락
order: 33
tier: 4
functions: indexBy, filter, map, sortBy, head, sumBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    상점 가격표의 두 스냅숏(데이터는 코드 안에 있습니다): 6월과 7월.
    일부 항목은 저렴해졌고, 일부는 비싸졌으며, 하나는 단종되었고
    하나는 새로 추가되었습니다. <strong>가격이 하락한</strong> 모든
    항목을 — 이전 가격, 새 가격, 하락 폭과 함께 — 하락 폭이 큰 순서로
    정렬해 보고하고, 가장 큰 하락 하나와 총 절감액을 따로 강조하세요.
    두 버전 모두 <em>예상 출력</em> 아래의 보고서를 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이 작업 전체는 하나의 흐름입니다: 6월 데이터를 SKU로 색인하고,
    7월 항목 중 저렴해진 것만 남기고, 각각을 하락 폭과 짝지은 뒤,
    하락 폭으로 정렬합니다. FxDart는 각 동작마다 이름 붙은 단계를
    제공합니다 — 조회 테이블을 위한 <code>indexBy</code>, 파이프라인을
    위한 <code>filter</code> → <code>map</code> → <code>sortBy</code>,
    그리고 <code>head</code>와 <code>sumBy</code>가 같은 결과 리스트를
    재사용해 요약 줄을 만듭니다. 순수 Dart도 이를 표현할 수 있습니다 —
    색인을 위한 맵 리터럴, 체인을 위한 <code>where</code>/<code>map</code>/
    <code>sortedBy</code> — 하지만 그 어휘는 흩어져 있습니다:
    <code>sumBy</code> 대신 초기값을 가진 <code>fold</code>, 부호를
    반전한 키를 쓰는 <code>sortedBy&lt;num&gt;</code>, 그리고 "키로
    조회 테이블을 만들어줘"에 해당하는 이름은 아예 없습니다.
  </p>
