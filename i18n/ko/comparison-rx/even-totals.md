---
slug: even-totals
title: 유효한 짝수 금액 합산하기 — RxDart vs FxDart
description: 파싱 실패는 버리고, 짝수만 남겨 합산하기 — async main이 필요한 Stream 파이프라인과 같은 고정 리스트 위의 동기 pull 체인 하나를 비교합니다.
heading: 유효한 짝수 금액 합산하기
order: 1
tier: 1
functions: fx, compact, filter, sum
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    명세서 가져오기가 파싱된 금액 리스트를 만들었는데, 두 줄은 파싱에
    실패했습니다(<code>null</code>). 실패를 버리고 <strong>짝수</strong>
    금액만 남겨 그 합계를 출력하세요. 데이터는 아래 코드에 있으며, 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    파이프라인 자체는 거의 단어 하나까지 같습니다 —
    <code>whereNotNull → where → fold</code> 대
    <code>compact → filter → sum</code>. 다른 것은 그 <em>주변</em>의
    모든 것입니다. RxDart 쪽은 평범한 리스트를 <code>Stream</code>으로
    끌어올리고, 비동기로 전환하고, fold를 <code>await</code>해야 합니다 —
    스트림은 이벤트 루프가 도는 사이사이에만 값을 내놓기 때문입니다.
    모든 값이 이미 메모리에 앉아 있는데도 말이죠. FxDart 쪽은 동기
    표현식으로 남습니다: 값을 끌어오고, 합산하고, 끝.
  </p>
  <p>
    그것이 이 파트의 반복되는 주제입니다: <em>유한하고 이미 손에
    있는</em> 데이터에 대해, 스트림은 문제가 요구한 적 없는 전달
    메커니즘을 얹습니다. RxDart의 연산자 어휘는 훌륭하지만 —
    <code>whereNotNull</code>은 정확히 <code>compact</code>입니다 — 그
    아래의 모델은 모든 고정 데이터 과제에 비동기 세금을 물립니다.
    여기서는 답 전체가 숫자 하나이므로, 그 격식 — 리프트, async main,
    await된 fold — 이 두 프로그램의 차이 전부입니다. 이 페이지의 판정을
    실어 나르는 것이 바로 그 점이고, 같은 잔여물만 남는 뒤쪽 쌍들은
    무승부로 정리됩니다. 판정은 파트 4에서 뒤집힙니다 — 거기서는 값이
    정말 시간에 따라 도착하고, 바로 그 기계 장치가 핵심이 됩니다.
  </p>
