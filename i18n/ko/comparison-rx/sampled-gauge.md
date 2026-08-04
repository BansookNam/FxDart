---
slug: sampled-gauge
title: 폴링 틱마다 게이지 샘플링하기 — RxDart vs FxDart
description: 각 폴링 틱 시점의 최신 게이지 값 읽기 — RxDart의 명시적 sample 트리거 스트림 vs fxdart 이벤트 레이어의 sampleOn.
heading: 폴링 틱마다 게이지 샘플링하기
order: 45
tier: 4
functions: fxEvents, sampleOn
domain: sensors
verdict: tie
async: true
noBenchmark: timing
---
  <h2>요구사항</h2>
  <p>
    압력 게이지가 50&nbsp;ms마다 하나씩 1..8의 측정값을 내보냅니다.
    대시보드는 세 번 폴링합니다 — 125, 275, 425&nbsp;ms 시점 — 그리고
    각 폴링은 그 순간의 <strong>최신</strong> 측정값을 보여 줘야
    합니다: 2, 5, 그다음 8. 스트림이 닫힌 뒤 폴링된 세 측정값을
    출력하세요. 두 스케줄 모두 코드에 시뮬레이션되어 있습니다; 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    다르지 않습니다. "이 순간의 최신 값"은 push 모델에만
    존재하는 개념이고 — 무언가가 알아서 도착한다는 것을 전제하기
    때문입니다 — 두 패널 모두 그것을 같은 연산자 하나짜리 문장으로
    표현합니다: 게이지 스트림을 폴링 스트림으로 샘플링한다. RxDart는
    <code>gauge().sample(polls())</code>라고 쓰고; fxdart는
    <code>fxEvents(gauge()).sampleOn(polls())</code>라고 씁니다. 양쪽
    모두 "지금 값이 무엇인가?" 상태는 연산자 안에 살고, 각 트리거는
    지난 트리거 이후의 가장 새로운 측정값을 내보내며, 샘플링되지 않은
    측정값은 그냥 버려집니다.
  </p>
  <p>
    pull 파이프라인에는 여전히 시계도 "현재 값"도 없습니다 — 그 거절은
    그대로입니다. 대신 fxdart는 전용 이벤트 레이어에서 Rx의
    접근을 흡수했습니다: <code>fxEvents</code>는 평범한
    <code>Stream</code> 위의 얇은 래퍼 체인으로(결코 extension이
    아니어서 어떤 것과도 충돌하지 않습니다), pull 쪽이 맡지 않으려 한
    push 본연의 동사들을 소유합니다. RxDart의 연산자 카탈로그는 여전히
    훨씬 큽니다; 이 동사만큼은 fxdart가 모국어로 말합니다. 그리고
    샘플링된 각 측정값이 진짜 하류 작업의 시작이라면,
    <code>.pull()</code>이 샘플들을 타입 있는 <code>FxAsync</code>
    파이프라인에 넘겨 요구에 따라 당겨지게 합니다.
  </p>
