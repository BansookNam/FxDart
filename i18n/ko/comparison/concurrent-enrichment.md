---
slug: concurrent-enrichment
title: 상위 판매자를 동시에 보강하기 — Dart vs FxDart
description: 상위 3개 판매자를 고른 뒤, 요청 속도 제한이 있는 API로 두 개씩 조회합니다 — 순수 Dart로 직접 만든 워커 풀과 FxDart의 concurrent(2)를 비교합니다.
heading: 상위 판매자를 동시에 보강하기
order: 23
tier: 3
functions: sortBy, take, toAsync, map, concurrent
domain: transactions
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    7월의 판매자별 지출 합계에서 <strong>상위 3개 판매자</strong>를 골라,
    (가상의) 판매자 디렉터리 API로 각각의 카테고리를 조회해 보강하세요 —
    다만 이 API는 요청 속도를 제한하므로, <strong>동시에 진행 중인 조회가
    두 개를 넘지 않아야</strong> 합니다. 모든 조회가 끝난 뒤 결과를 지출
    순서대로 출력하며, 가짜 조회 함수는 겹쳐서 실행된 요청 수를 세어 두
    버전 모두 제한이 지켜졌음을 증명합니다. 데이터는 아래 코드에 있으며,
    두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이 작업은 중간에 성격이 바뀝니다 — 동기적인 순위 매기기에서 속도
    제한이 있는 I/O로 — 그런데 코드의 성격도 함께 바뀌는 쪽은
    한 버전뿐입니다. FxDart에서는 그 경계가 체인의 한 단계일 뿐입니다:
    <code>sortBy</code> + <code>take</code>가 판매자를 고르고,
    <code>toAsync</code>가 비동기로 넘어가며, <code>map</code> +
    <code>concurrent(2)</code>가 조회를 순서대로 두 개씩 실행합니다.
    네이티브 Dart에는 "최대 두 개까지만 동시에"를 표현할 기본 도구가
    없습니다: <code>Future.wait</code>는 전부 한꺼번에 실행해 버리므로,
    제한이 걸린 절반은 직접 만든 워커 풀 — 공유 커서, 미리 크기를 정한
    결과 슬롯, 워커 퓨처 — 이 되어, 정작 그것이 뒷받침하는 두 줄짜리 순위
    매기기를 압도해버립니다. 제한값을 바꾸거나 아예 없애는 일은 체인에서는
    숫자 하나지만, 저 워커 풀 전체에서는 그렇지 않습니다.
  </p>
