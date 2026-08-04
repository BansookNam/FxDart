---
slug: running-balance
title: 계좌 잔액 추이 — Dart vs FxDart
description: 매 거래 후의 잔액 — 순수 Dart의 가변 누산 루프 대 FxDart의 scan + map.
heading: 계좌 잔액 추이
order: 7
tier: 1
functions: scan, map
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    한 계좌가 7월에 <strong>$250.00</strong> 잔액으로 열리고, 부호가
    있는 거래 여섯 건을 겪습니다 — 급여 입금, 임대료와 식료품비 출금.
    통화 형식으로 한 단계마다 한 줄씩 출력하세요: 먼저 개시 잔액,
    그다음 <strong>각 거래 후의 잔액</strong>. 데이터는 아래 코드에
    있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 <code>fold</code>가 있지만, 이는 리스트를
    <em>최종</em> 잔액 하나로 축약할 뿐입니다 — 이 작업은 중간 단계
    잔액이 모두 필요한데, <code>scan</code>이 없습니다. 그래서 네이티브
    버전은 가변 <code>balance</code> 변수를 루프에 꿰어 넣는 방식으로
    돌아가고, 포맷팅이 누산 과정과 뒤섞입니다. FxDart의
    <code>scan</code>은 누적된 각 상태를 값으로 내보내며(시드가 먼저
    나오므로 개시 잔액 줄이 공짜로 딸려 옵니다), <code>map</code>은
    그 뒤에 별개의, 교체 가능한 단계로 포맷팅합니다. 누적 상태를
    변이가 아니라 파이프라인 단계로 다루는 것, 바로 이것이 여기서
    Dart에 없는 어휘입니다.
  </p>
