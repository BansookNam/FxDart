---
slug: last-three-errors
title: 마지막 에러 세 건 — RxDart vs FxDart
description: ERROR 줄만 남겨 마지막 세 건을 출력하기 — takeLast는 done 이벤트를 기다리고, takeRight는 이터러블을 끝까지 소진합니다. 둘 다 정확히 세 개를 버퍼링합니다.
heading: 마지막 에러 세 건
order: 7
tier: 1
functions: fx, filter, takeRight
domain: logs
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    오늘 아침 서비스 로그에서 <code>ERROR</code> 줄만 남기고, 그중
    <strong>마지막 세 건</strong>을 오래된 것부터 출력하세요. 데이터는
    아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된
    줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    "마지막 세 건"에는 어떤 연산자도 피해 갈 수 없는 구조적 비용이
    있습니다: 끝을 보기 전까지는 어떤 요소가 마지막 세 건에 드는지 알 수
    없습니다. 그래서 양쪽 모두 <strong>버퍼링</strong>합니다 — 새 에러가
    밀고 들어올 때마다 가장 오래된 것이 밀려나는 세 칸짜리 윈도우 —
    그리고 둘 다 소스가 끝날 때에야 그것을 흘려보냅니다. RxDart의
    <code>takeLast</code>는 <em>done 이벤트</em>가 도착하기 전까지
    아무것도 내보내지 않고, FxDart의 <code>takeRight</code>는 이터러블이
    <em>소진</em>될 때까지 같은 윈도우를 유지합니다. 같은 알고리즘이
    "더 이상 요소가 없다"에 대한 각 모델의 단어에 맞춰져 있을 뿐입니다.
  </p>
  <p>
    그 상류에서 <code>where</code>와 <code>filter</code>는 서로 바꿔 쓸
    수 있습니다. 하나 적어 둘 만한 모델 노트: 끝나지 않는 스트림에서
    <code>takeLast</code>는 결코 아무것도 내보내지 않습니다 — "마지막 세
    건"은 끝나는 소스에서만 의미가 있고, 그것은 유한한 이터러블에게는
    본고장이지만 스트림에게는 특수한 경우입니다. 이 유한한 로그에서는
    둘 다 과제를 직접적으로 표현하므로, 판정은 무승부입니다.
  </p>
