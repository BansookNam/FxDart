---
slug: top-expenses
title: 가장 큰 지출 상위 3건 — Dart vs FxDart
description: 이번 달 거래 중 금액이 가장 큰 세 건 — package:collection의 sortedBy + take와 FxDart의 sortBy + take를 비교합니다.
heading: 가장 큰 지출 상위 3건
order: 3
tier: 1
functions: sortBy, take
alsoLink: chunk, scan
domain: transactions
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    한 달치 지출 중 <strong>가장 큰 세 건</strong>을 판매자와 금액으로,
    큰 금액부터 순서대로 출력하세요. 데이터는 아래 코드에 있으며, 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 차이가 없습니다 — 이번 예제는 무승부입니다. 양쪽 모두 부호를
    반전한 키로 정렬해 내림차순을 얻고 앞의 세 개를 취합니다.
    <code>package:collection</code>의 <code>sortedBy</code>는 FxDart의
    <code>sortBy</code>만큼이나 직관적입니다(코어 <code>List.sort</code>
    만 쓰면 제자리에서 변형되고 명시적인 비교자가 필요하지만,
    <code>collection</code>은 표준적인 의존성입니다). 실질적인 차이는
    그 어휘가 어디에 있느냐뿐입니다 — 패키지의 확장 메서드냐, 아니면
    <code>scan</code>, <code>chunk</code>, 비동기 변형까지 함께 제공하는
    체인의 한 단계냐. 어느 쪽을 골라도 떳떳합니다.
  </p>
