---
slug: latency-percentiles
title: 엔드포인트별 p50/p95 지연 시간 — Dart vs FxDart
description: 원본 요청 로그로부터 백분위수 표를 만듭니다 — 엔드포인트별 groupBy + sortBy + nth와 제자리 정렬을 쓰는 행 누적 루프를 비교합니다.
heading: 엔드포인트별 p50/p95 지연 시간
order: 40
tier: 4
functions: filter, groupBy, map, sortBy, nth, maxBy, join
domain: logs
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    원본 요청 로그(데이터는 코드에 있음)에서 실패한 요청을 제외하고,
    <strong>엔드포인트별 p50 및 p95 지연 시간</strong>을 계산하세요: 각
    엔드포인트의 지연 시간을 정렬한 뒤 인덱스
    <code>round((n-1) * q / 100)</code>의 값을 취합니다. p95가 가장 나쁜
    순서로 정렬된 표를 출력하고, 가장 나쁜 엔드포인트를 별도로 알려주세요.
    두 버전 모두 <em>예상 출력</em> 아래에 표시된 표를 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    백분위수는 "정렬한 다음 인덱싱"입니다 — FxDart에서는 이것이 그대로
    <code>sortBy</code> + <code>nth</code>이며, 각 엔드포인트 그룹을 통계
    행으로 바꾸는 <code>groupBy</code> → <code>map</code> 파이프라인 안에
    적용됩니다. 표를 순위별로 나열하고 가장 나쁜 엔드포인트를 찾는 부분도
    같은 행들을 <code>sortBy</code>와 <code>maxBy</code>로 재사용합니다.
    네이티브 버전은 같은 계산을 하지만 <code>for</code> 루프로 채우는
    가변 행 리스트, 제자리 <code>..sort()</code>, 원시 인덱스 접근, 최댓값을
    위한 <code>reduce</code> 비교자를 거칩니다. 둘 다 정확하지만, fxdart
    쪽은 "그룹화 → 요약 → 순위화"를 한 루프가 한꺼번에 처리하는 대신 눈에
    보이는 세 번의 붓질로 유지합니다.
  </p>
