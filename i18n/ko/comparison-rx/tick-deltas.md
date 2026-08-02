---
slug: tick-deltas
title: 틱 사이의 변화량 — RxDart vs FxDart
description: 각 가격 틱을 직전 틱과 나란히 — 두 라이브러리 모두 pairwise, 스트림 쪽은 리스트 쌍, pull 쪽은 타입 있는 레코드.
heading: 틱 사이의 변화량
order: 13
tier: 2
functions: fx, pairwise, map
domain: sensors
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    가격 틱 일곱 개에서 여섯 개의 <strong>변화량</strong>을 출력하세요:
    각 틱을 직전 틱 옆에 놓고, 부호 있는 변화를 소수점 두 자리로(변화
    없는 틱은 <code>+0.00</code>을 출력합니다). 데이터는 아래 코드에
    있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    다르지 않습니다. 그것도 설계상으로요: <code>pairwise</code>는 FxDart가
    Rx<em>로부터</em> 이식해 온 연산자 중 하나입니다. "각 값을 바로 앞의
    값과 함께"는 값이 push되든 pull되든 똑같이 자연스럽기 때문입니다.
    양쪽 모두 상태 값 하나를 유지하고, 첫 틱에는 아무것도 내보내지 않고,
    n&nbsp;−&nbsp;1개의 쌍을 만듭니다. 판정은 무승부이고, 흥미로운
    부분은 "쌍"이 무엇인가에 관한 작은 타이핑 차이입니다.
  </p>
  <p>
    RxDart의 <code>pairwise</code>는 요소 두 개짜리
    <code>List&lt;double&gt;</code>을 내보냅니다 — <code>p.first</code>와
    <code>p.last</code>는 정직하지만, 길이가 2라는 불변식은 타입이 아니라
    문서에 삽니다. FxDart의 것은 Dart 레코드
    <code>(double, double)</code>을 내보냅니다: <code>p.$1</code>과
    <code>p.$2</code>가 존재하는 필드의 전부이고, 컴파일러가 그것을
    압니다. 이것은 모델 차이라기보다 언어 세대의 산물입니다 — RxDart의
    API가 동결될 때 레코드는 존재하지 않았습니다 — 하지만 불변식을 타입
    속으로 밀어 넣는 pull 라이브러리의 습관을 잘 보여 줍니다. 모델
    자체에 관해서라면: 여기서는 고를 것이 없습니다.
  </p>
