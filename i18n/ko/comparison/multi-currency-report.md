---
slug: multi-currency-report
title: 다중 통화 지출 리포트 — Dart vs FxDart
description: 고정 환율로 여행 가계부를 USD로 정규화한 다음 그룹화, 순위화, 요약합니다 — 리포트 줄마다 파이프라인 하나 쓰는 방식과 fold/reduce 보일러플레이트를 비교합니다.
heading: 다중 통화 지출 리포트
order: 31
tier: 4
functions: map, groupBy, sumBy, sortBy, uniq, maxBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    여행 가계부(데이터는 코드에 있음)에는 EUR, GBP, JPY, USD 금액이
    섞여 있습니다. 코드에 있는 고정 환율로 모두 USD로 환산한 뒤 다음
    항목을 리포트하세요: 지출액순으로 정렬된 카테고리별 총액, 사용된
    통화 목록, 가장 큰 단일 지출(원래 금액 포함), 그리고 총합계. 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 리포트를 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    먼저 정규화하는 것 — 각 거래를 <code>(tx, usd)</code> 쌍으로
    <code>map</code>하는 것 — 은 이후의 모든 질문이 하나의 리스트 위에서
    돌아가게 해 줍니다: 내역에는 <code>groupBy</code> +
    <code>sumBy</code> + <code>sortBy</code>, 통화 목록에는
    <code>uniq</code>, 요약 줄에는 <code>maxBy</code>와
    <code>sumBy</code>. 리포트의 각 줄은 자신의 집계 방식을 이름으로
    드러내는 짧은 파이프라인 하나입니다. 네이티브 버전은 똑같은 동작을
    하지만 그 어휘가 없습니다: 모든 합계는 초기값을 가진
    <code>fold</code>이고, 최댓값은 직접 작성한 <code>reduce</code>
    비교자이며, 통화 목록에는 <code>toSet().toList()..sort()</code>
    조합이 필요합니다. 어려운 부분은 없습니다 — 다만 코드량이 더 많고,
    그 코드가 의미를 덜 말해 줄 뿐입니다.
  </p>
