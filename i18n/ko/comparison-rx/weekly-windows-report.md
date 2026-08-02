---
slug: weekly-windows-report
title: 일별 시리즈에서 주간 합계 — RxDart vs FxDart
description: 21일치 지출을 주 번호가 붙은 세 개의 합계로 말아 올리기 — 카운터로 차출된 scan을 곁들인 bufferCount vs chunk + zipWithIndex.
heading: 일별 시리즈에서 주간 합계
order: 24
tier: 2
functions: fx, chunk, sumBy, map, zipWithIndex
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    3주치 일별 지출(8월 1–21일, 센트 단위로 저장)이 주당 한 줄로 말려
    올라갑니다: <code>week n: $total</code>, 합계는 소수점 두 자리 달러로
    환산합니다. 21개의 금액은 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 세 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    윈도잉 자체는 차이가 없습니다: <code>bufferCount(7)</code>과
    <code>chunk(7)</code>은 같은 고정 윈도우에 대한 동일한 관용구이고,
    21이 나누어떨어지지 않았다면 둘 다 짧은 꼬리 윈도우를 내보냈을
    것입니다. 작업은 윈도우에 <em>번호 매기기</em>에서 갈라집니다.
    RxDart에는 인덱스 연산자가 없으므로, 관용적인 수는
    <code>scan</code>을 카운터로 차출하는 것입니다 — 유일한 역할이 버퍼
    옆에 <code>week + 1</code>을 실어 나르는 것뿐인 누산기 레코드.
    동작은 하지만, 그 fold는 상태 연산자의 옷을 입은 구경꾼입니다.
  </p>
  <p>
    pull 쪽에는 그 목적을 위해 만들어진 단어가 있습니다:
    <code>zipWithIndex</code>가 각 청크를 그 위치와 지연 방식으로 짝짓고
    — 누산기는 어디에도 없습니다 — 같은 호흡에 <code>sumBy</code>가 각
    주의 센트를 달러로 접어 냅니다. 이것이 반복되는 티어 2 패턴입니다 —
    유한 데이터의 윈도잉은 두 모델 모두 잘하지만, 부기(인덱스, 키, 부분
    집계)가 윈도우와 만나는 바로 그 지점에서 pull 어휘가 더 넓습니다.
    용도 변경된 연산자 하나 대 의도된 연산자 하나: 판정은 FxDart에게
    갑니다.
  </p>
