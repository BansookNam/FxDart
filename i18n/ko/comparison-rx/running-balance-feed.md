---
slug: running-balance-feed
title: 입출금 피드의 누적 잔액 — RxDart vs FxDart
description: 입금과 출금의 피드를 누적 잔액으로 접기 — Rx의 scan과 fxdart의 scan, 양쪽 모두 이동 한 건당 누산 한 번.
heading: 입출금 피드의 누적 잔액
order: 2
tier: 1
functions: scan
domain: transactions
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    계좌가 0에서 시작해 일곱 번의 이동을 받습니다 — 입금은 양수, 출금은
    음수입니다. 각 이동 후의 잔액을 한 단계에 한 줄씩 출력하세요.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 다르지 않습니다. 누적 상태란 중간 단계를 드러낸 fold이고, 두
    라이브러리 모두 그 fold를 <code>scan</code>이라고 부릅니다 —
    RxDart는 스트림 트랜스포머로, FxDart는 같은 Rx 계보에서 이식된 지연
    연산자로. 양쪽 모두 이동 한 건당 누산 한 번, 순서 그대로입니다.
  </p>
  <p>
    눈에 보이는 차이는 박자의 세부 사항이지 모델 차이가 아닙니다.
    RxDart의 <code>scan</code>은 시드를 받아 이벤트당 값 하나를
    내보냅니다(누산기는 인덱스도 함께 받습니다). FxDart의 시드 있는
    <code>scan</code>은 FxTS를 따라 시드 자체를 먼저 내놓으므로, 패널은
    시드 없는 <code>scan1</code>을 사용합니다 — 0에서 시작하는 잔액이라면
    각 부분합이 <em>곧</em> 잔액이고, 두 박자는 정확히 맞아떨어집니다.
    그 밖에 남는 잔여물은 전달 방식뿐입니다: 스트림 버전은
    <code>async</code> main을 거쳐 수집하고, pull 버전은 동기 체인
    하나입니다. 공정한 무승부 — 양쪽 모두 요구사항을 연산자 하나로
    말합니다.
  </p>
