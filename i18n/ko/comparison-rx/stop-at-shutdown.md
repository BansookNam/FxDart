---
slug: stop-at-shutdown
title: 종료 마커까지, 마커 포함 — RxDart vs FxDart
description: SHUTDOWN까지의 모든 이벤트를 마커 포함해 남기고 낙오자들은 버리기 — takeWhileInclusive vs takeUntilInclusive, 같은 절단의 두 표기.
heading: 종료 마커까지, 마커 포함
order: 23
tier: 2
functions: fx, takeUntilInclusive, map
domain: logs
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    오늘 밤 이벤트 피드에는 <code>SHUTDOWN</code> 마커가 있습니다; 그
    뒤의 모든 것은 다음 실행에 속하므로 리포트에 나타나면 안 됩니다.
    마커까지의 — 마커를 <em>포함한</em> — 모든 이벤트를 남기고 각각을
    <code>event:</code> 줄로 출력하세요. 피드는 아래 코드에 있으며, 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 <code>takeWhile</code>에는 이 작업에서 하나 차이(off-by-one)
    문제가 있습니다: 술어를 깨뜨리는 요소가 정확히 아직 원하는 그
    요소입니다. 두 라이브러리 모두 포함형 수정판을 싣고 있는데, 서로
    반대편 끝에서 표기합니다 — RxDart의 <code>takeWhileInclusive</code>는
    <em>마커가 아닌 동안</em> 계속 가고, FxDart의
    <code>takeUntilInclusive</code>(FxTS의 <code>takeUntil</code>을 Dart의
    명확성을 위해 개명한 것)는 <em>마커에서</em> 멈춥니다. 같은 절단,
    뒤집힌 술어.
  </p>
  <p>
    두 모델은 그다음에 벌어지는 일에도 합의합니다. 마커를 내보낸 뒤
    RxDart는 상류 구독을 취소하므로, 낙오자 이벤트 두 건은 결코 전달되지
    않습니다; FxDart는 그저 끌어오기를 멈추므로, 그것들은 결코 생산되지
    않습니다. 파트&nbsp;1의 예산 검색에서처럼, 취소와 수요는 같은
    경제성을 가리키는 두 모델의 단어이고 — 하류의 무엇도 어느 모델이
    아래에 있었는지 구별할 수 없습니다. 무승부, 그리고 둘 사이에 코드를
    옮길 때 알아 두면 좋은 번역 쌍입니다.
  </p>
