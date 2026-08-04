---
slug: price-lookup-fallback
title: 폴백이 있는 동시 가격 조회 — Dart vs FxDart
description: 실시간 가격을 한 번에 세 개씩 조회하고, 누락된 SKU는 카탈로그 가격으로 대체합니다 — concurrent + null 병합 map과 워커 풀을 비교합니다.
heading: 폴백이 있는 동시 가격 조회
order: 33
tier: 4
functions: toAsync, map, concurrent, filter, size, sumBy
domain: orders
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    여섯 줄짜리 주문에 가격을 매기세요. 각 SKU는 실시간 가격 서비스에서
    조회하되 — 동시에 최대 <strong>세 건까지만 진행</strong> — 이
    서비스는 일부 SKU를 갖고 있지 않아 그 경우 <code>null</code>을
    반환하며, 해당 줄은 항목에 실려 있는 카탈로그 정가로 대체합니다.
    가격이 매겨진 각 줄을 순서대로(폴백 여부 표시와 함께) 출력하고,
    폴백 건수, 주문 합계, 관측된 최대 동시성을 출력하세요. 모든 데이터는
    아래 코드에 있습니다.
  </p>
  <p>
    FxDart 체인은 <code>concurrent(3)</code> 아래에서 조회를 수행한
    다음, 두 번째 <code>map</code>이 평범한 <code>??</code>로 폴백을
    적용합니다 — 복구 정책은 제한된 fetch 다음에 오는 또 하나의
    파이프라인 단계일 뿐입니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    폴백 자체는 두 버전 모두에서 쉽습니다 — <code>??</code>는 Dart의
    문법입니다. 순수 Dart에 없는 것은 그 앞 단계입니다: 입력 순서를
    유지하며 한 번에 세 건씩 조회하려면 워커 풀 관용구(공유 커서, 미리
    크기를 정한 슬롯, <code>Future.wait</code>)가 강제되고, 폴백 로직은
    워커 본문 안에 파묻혀 가장 보기 힘들고 테스트하기 힘든 곳에
    자리잡게 됩니다. FxDart 버전에서는 fetch와 복구가 하나의 체인
    안에서 분리된, 눈에 보이는 두 단계입니다 — <code>concurrent(3)</code>이
    제한을 담당하고, 다음 <code>map</code>이 정책을 담당합니다 — 그리고
    요약 줄(폴백을 위한 <code>filter</code> + <code>size</code>, 합계를
    위한 <code>sumBy</code>)은 사이트 전체가 가르치는 것과 같은 어휘를
    재사용합니다.
  </p>
