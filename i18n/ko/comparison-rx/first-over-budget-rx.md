---
slug: first-over-budget-rx
title: 예산을 넘는 첫 거래 — RxDart vs FxDart
description: 100을 넘는 첫 거래를 찾고 멈추기 — Rx firstWhere는 구독을 취소하고, fxdart find는 끌어오기를 멈춥니다. 양쪽 모두 8건 중 4건만 검사합니다.
heading: 예산을 넘는 첫 거래
order: 1
tier: 1
functions: fx, find
domain: transactions
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    이번 주 카드 피드를 도착 순서대로 훑어 예산 100을 넘는
    <strong>첫</strong> 거래를 보고하고 — 그 뒤로는 더 찾지 마세요.
    검색이 짧게 끊겼음을 증명하기 위해, 실제로 검사한 거래 수도
    출력합니다. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    여기서는 양쪽 모두, 각자의 방언으로, 진짜 지연 평가입니다. RxDart의
    <code>firstWhere</code>는 첫 일치에서 future를 확정하고
    <strong>구독을 취소합니다</strong> — 남은 네 건의 거래는 결코 전달되지
    않습니다. FxDart의 <code>find</code>는 그저 <strong>끌어오기를
    멈춥니다</strong> — 남은 네 건의 거래는 결코 요구되지 않습니다. 취소와
    수요는 같은 경제성을 가리키는 두 모델 각각의 단어이고,
    "Examined 4 of 8" 줄은 양쪽에서 동일하게 나옵니다.
  </p>
  <p>
    배울 점이 있는 차이는 <em>카운트가 어디에 사는가</em>입니다.
    스트림에는 "사이"가 있습니다: <code>doOnData</code>가 연산자 사이의
    파이프를 톡톡 두드리므로, rx 술어는 순수하게 남고 탭이 트래픽을
    관찰합니다. pull 체인에는 사이가 없습니다 — 수요의 순간이 곧 술어
    호출 그 자체이므로, FxDart 쪽은 술어 안에서 셉니다. 어느 표기가 더
    낫다고 할 수 없습니다; 각각 push와 pull에 고유한 관찰 관용구입니다.
    판정: 무승부 — 연산자 하나씩, 그리고 둘 다 정확히 옳은 순간에
    멈춥니다.
  </p>
