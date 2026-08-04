---
slug: skip-warmup-readings
title: 예열 구간 판독값 건너뛰기 — RxDart vs FxDart
description: 프로브의 앞쪽 낮은 판독값은 버리고 그 뒤는 전부 남기기 — skipWhile과 dropWhile은 같은 단방향 게이트이고, 연산자마저 코어에 있습니다.
heading: 예열 구간 판독값 건너뛰기
order: 9
tier: 1
functions: fx, dropWhile, map
domain: sensors
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    온도 프로브는 예열되는 동안 낮게 읽힙니다. 20.0&nbsp;°C 미만의
    <strong>앞쪽</strong> 판독값들을 버리고, 첫 실측 판독 이후의 모든 값 —
    진짜 데이터인 이후의 하락까지 포함해서 — 을 포맷해 출력하고, 몇 개의
    판독값이 살아남았는지 출력하세요. 데이터는 아래 코드에 있으며, 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    다르지 않습니다. 그리고 그것이 이 페이지의 발견입니다.
    <code>skipWhile</code>과 <code>dropWhile</code>은 같은 단방향
    게이트입니다: 술어가 성립하는 동안 버리고, 첫 실패에서 영구히 열리고,
    다시는 닫히지 않습니다 — 예열 후의 18.7&nbsp;°C 하락이 양쪽 모두에서
    살아남는 이유입니다. 이것은 값이 아니라 <em>시퀀스 위치</em>에 대한
    게이트이고, 두 모델 모두 그것을 부르는 이름을 갖고 있습니다.
  </p>
  <p>
    주목할 점: 이 작업에서 RxDart 패널은 순수 <code>dart:async</code>입니다
    — <code>skipWhile</code>, <code>map</code>, <code>toList</code>가 모두
    코어 <code>Stream</code>에 실려 있으므로, 여기서는 RxDart의 import가
    아무것도 벌어들이지 못합니다. 이것이 반대편에서 바라본 티어 1 겹침의
    모습입니다: 공유 어휘가 플랫폼 자체에 사는 경우도 있습니다. 남는 것은
    전달 모델뿐입니다 — pull 체인이 평범한 값으로 반환하는 것을 수집하기
    위한 <code>async</code> main과 <code>await</code>, 이벤트 루프는
    필요하지도 않은데 말이죠. 무승부입니다.
  </p>
