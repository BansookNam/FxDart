---
slug: live-latest-value
title: 늦게 온 리더를 위한 라이브 현재 값 — RxDart vs FxDart
description: 늦게 접속한 대시보드도 현재 온도를 즉시 받습니다 — BehaviorSubject와 LiveValue 모두 최신 값을 리플레이한 뒤 라이브로 스트리밍합니다.
heading: 늦게 온 리더를 위한 라이브 현재 값
order: 39
tier: 4
functions: liveValue, fxEvents
domain: sensors
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    온도 피드가 고정 스케줄로 업데이트를 밀어 보냅니다. 대시보드는 첫
    세 업데이트가 이미 지나간 뒤에야 접속합니다 — 그래도
    <strong>현재</strong> 값(합류 시점의 최신인 19.1&nbsp;°C)을 즉시
    보여 준 뒤, 이후의 모든 업데이트를 보여 줘야 합니다. 스케줄은
    코드에 시뮬레이션되어 있습니다; 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이제는 다르지 않습니다. "누가 나타나든 리플레이되는 최신 값"은
    <em>공유된 멀티캐스트 상태</em>이고, fxdart 0.7.3부터는 fxdart에도
    그것을 위한 전용 객체가 있습니다: <code>LiveValue</code>는
    <code>BehaviorSubject</code>를 그것을 정의하는 동작만 남기고 줄인
    것입니다 — 센서가 쓰는 싱크, 읽을 수 있는 <code>.value</code>,
    그리고 늦게 온 구독자가 먼저 가장 최근 값을 받고 그다음 라이브
    업데이트를 받는 피드. 이제 두 패널 모두 "업데이트 넣기, 늦게
    구독하기, 수집하기"입니다; 옛 FxDart 패널에 필요했던 손수 캐시한
    변수와 여분의 캐싱 리스너는 사라졌습니다.
  </p>
  <p>
    이것이 fxdart 0.7.3의 이벤트 레이어가 push 쪽을 위해 Rx의 접근을
    흡수한 모습입니다: <code>LiveValue.live</code>는
    <code>fxEvents</code> 체인을 돌려주는데 — 평범한 브로드캐스트
    <code>Stream</code> 위의 얇은 래퍼라 rxdart를 포함해 어떤 것과도
    충돌하지 않습니다 — 값별 처리가 자라면 <code>.pull()</code>이 타입
    있는 pull 파이프라인으로 건너갑니다. RxDart의 subject 계열과
    연산자 카탈로그는 여전히 훨씬 큽니다; 최신-값-그다음-라이브
    자체에 관해서는 두 패널이 동등합니다: 무승부입니다.
  </p>
