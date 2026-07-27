---
slug: daily-ledger-close
title: Finale — DailyLedger monthly close — Dart vs FxDart
description: The finale: load ledger entries 3 at a time, then compute the July summary and category breakdown — the real DailyLedger app shapes, both ways.
heading: Finale — DailyLedger monthly close
order: 50
tier: 4
functions: toAsync, map, concurrent, filter, partition, sumBy, groupBy, sortBy, take
domain: transactions
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    개인 가계부의 월말 마감을 처리하세요. 열 개의 항목이 저장소에
    있고(아래 코드에 고정 데이터로 있습니다), id로 각 항목을
    불러오되 — 최대 <strong>세 개까지만 동시에 로드</strong>합니다,
    이는 최대 동시 실행 수 카운터로 증명됩니다 — 그런 다음
    2026년&nbsp;7월 마감을 계산합니다: 7월 항목만 남기고(하나는 6월에
    낀 예외입니다), 수입과 지출을 나누어 각각 합산한 뒤, 순액과 항목
    수를 포함한 상위 세 지출 카테고리를 출력합니다.
  </p>
  <p>
    여기 쓰인 형태들은 실제 앱에서 그대로 가져온 것입니다:
    <code>Entry</code> 모델, 수입/지출 분리(<code>filter</code> →
    <code>partition</code> → 각 절반에 <code>sumBy</code>), 카테고리
    분석(<code>groupBy</code> → 그룹별 <code>sumBy</code> →
    내림차순 <code>sortBy</code> → <code>take(3)</code>)은 DailyLedger의
    <code>monthSummary</code>와 <code>categoryBreakdown</code>
    파이프라인을 그대로 옮긴 것이며, 앞단의 비동기 로드 단계
    (<code>toAsync</code> → <code>map</code> → <code>concurrent(3)</code>)도
    마찬가지입니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    쉰 개의 예제를 지나오며 결국 모두가 하나로 수렴하는 패턴이
    이것입니다: 순수 Dart는 기능 하나에 세 가지 방언이 필요합니다 —
    그룹화를 위한 <code>package:collection</code> 헬퍼, 합계를 위한
    명시적 초기값이 있는 <code>fold</code>, 그리고 로드 단계에
    동시성 제한이 필요해지는 순간 직접 짜야 하는 워커 풀. 각 조각은
    그 자체로는 문제없지만, 합쳐지면 비즈니스 로직이 화면에서 가장
    찾기 어려운 것이 되어 버립니다. FxDart 버전은 로드 단계부터
    리포트까지 같은 어휘로 이어지며, 모든 단계가 순수한 파이프라인이기
    때문에 각각을 떼어내어 <em>항목이 들어가고 뷰 데이터가 나온다</em>는
    형태로 단위 테스트할 수 있습니다.
  </p>
  <p>
    이 파이프라인들은 데모용으로 꾸며낸 것이 아닙니다: 실제로
    <a href="{{root}}DailyLedger/">DailyLedger 데모 앱</a>이 대시보드를
    계산하는 방식 그대로입니다 — 같은 모델, 같은 연산자가 여러분의
    브라우저에서 실시간으로 동작합니다. 쉰 개의 비교가 단어들을
    보여줬다면, DailyLedger는 그 단어들이 만들어 가던 문장입니다.
  </p>
