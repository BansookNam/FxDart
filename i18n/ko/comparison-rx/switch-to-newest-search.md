---
slug: switch-to-newest-search
title: 최신 검색만 중요할 때 — RxDart vs FxDart
description: 더 새 쿼리가 진행 중인 검색을 버립니다 — rxdart와 fxdart의 fxEvents 체인 양쪽 모두 같은 switchMap 연산자.
heading: 최신 검색만 중요할 때
order: 40
tier: 4
functions: fxEvents, switchMap
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>요구사항</h2>
  <p>
    사용자가 쿼리 세 개를 입력합니다 — <code>fx</code>, 40&nbsp;ms 뒤
    <code>fxdar</code>, 그리고 잠시 뒤 <code>fxdart</code>. 각 검색은
    150&nbsp;ms 걸리므로, 첫 검색이 아직 진행 중일 때 두 번째 쿼리가
    도착합니다: 첫 결과는 버려져야 하며, 결코 보이면 안 됩니다.
    살아남은 결과들만 출력한 뒤, 시작된 검색 수 vs 전달된 검색 수를
    출력하세요. 스케줄은 코드에 시뮬레이션되어 있습니다; 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이제는 다르지 않습니다. "더 새것이 옛것을 취소한다"는
    <em>구독</em>에 대한 진술인데, fxdart 0.7.3부터는
    <code>fxEvents</code> 레이어에도 구독이 있습니다: 그
    <code>switchMap</code>은 각 쿼리를 내부 검색 스트림으로 매핑하고,
    더 새 쿼리가 도착하는 순간 이전 것의 구독을 해지하므로, 뒤늦은
    결과에는 닿을 리스너가 남아 있지 않습니다. 세 검색이 시작되고, 두
    결과가 살아남고, 그 로직의 어느 것도 사용자 코드에 나타나지
    않습니다 — 어느 패널에서도요. 옛 FxDart 패널에 필요했던 손수 만든
    에포크 카운터와 완료 장부 정리는 사라졌습니다.
  </p>
  <p>
    fxdart 0.7.3은 정확히 이런 종류의 요구사항을 위해 Rx의 접근을
    흡수했습니다: <code>fxEvents</code>는 평범한 <code>Stream</code>
    위의 얇은 래퍼 체인으로 — 결코 extension이 아니어서 rxdart를
    포함해 다른 어떤 스트림 라이브러리와도 공존합니다. RxDart의 연산자
    카탈로그는 여전히 훨씬 큽니다; 살아남은 결과들에 진짜 값별 처리가
    필요해지면 <code>.pull()</code>로 타입 있는 pull 체인으로
    건너가세요. <code>switchMap</code>을 정의하는 사용 사례에서 두
    패널은 이제 연산자 대 연산자로 동등합니다: 무승부입니다.
  </p>
