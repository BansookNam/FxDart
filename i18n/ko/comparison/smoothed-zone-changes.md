---
slug: smoothed-zone-changes
title: 평활화된 구간 전환 — Dart vs FxDart
description: 이동 평균, 구간 런, 전환 알림 — 순수 Dart의 가변 상태를 든 인덱스 루프 세 개 vs FxDart의 windowed → uniqAdjacentBy → pairwise 체인.
heading: 평활화된 구간 전환
order: 43
tier: 4
functions: windowed, average, uniqAdjacent, pairwise, ifEmpty, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    온도 센서가 하루에 원시 판독값 12개를 보고합니다. 이를
    <strong>3-판독 이동 평균</strong>으로 평활화하고, 평활화된 값을
    구간으로 분류한 뒤(<code>cool</code> &lt; 20° ≤ <code>ok</code> &lt;
    25° ≤ <code>hot</code>), 모든 <strong>구간 전환</strong>을 보고하세요 —
    어느 구간에서 나와 어느 구간으로 들어갔는지, 그리고 양쪽의 평활값을
    함께 출력합니다. 전환이 없는 날은 아무것도 출력하지 않는 대신
    <em>stable</em> 한 줄을 출력합니다. 7월 이틀치 데이터는 코드에
    있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이 과제의 모든 단계는 <em>이웃한</em> 요소를 봐야 하는데, 바로
    거기서 순수 Dart의 어휘가 바닥납니다: 슬라이딩 윈도우도, 인접 중복
    제거도, 후속 값 짝짓기도 표준 라이브러리와
    <code>package:collection</code> 어디에도 없습니다
    (<code>slices</code>는 겹침 없이 타일링만 합니다). 그래서 네이티브
    버전은 각자 가변 상태를 든 인덱스 루프 세 개가 됩니다: 윈도우 합계,
    자기 꼬리와 비교하는 <code>runStarts</code> 리스트,
    전환 줄을 위한 <code>i&nbsp;-&nbsp;1</code> 되돌아보기 — 거기에
    stable 날을 위한 마지막 <code>isEmpty</code> 땜질까지.
  </p>
  <p>
    FxDart 체인은 다섯 단계를 데이터가 흐르는 순서대로 서술합니다:
    <code>windowed(3)</code> → 윈도우별 <code>average</code>,
    <code>uniqAdjacentBy(zone)</code>가 각 구간 런의 첫 평활값만 남기고,
    <code>pairwise</code>가 런 시작점들을 (from,&nbsp;to) 전환으로
    바꾸고, <code>ifEmpty</code>가 stable 날의 줄을 파이프라인 바깥의
    if 검사 대신 파이프라인 안에서 공급합니다. 각 조각은 독립적으로
    테스트할 수 있고, 윈도우 경계를 다시 구현하는 코드는 어디에도
    없습니다. 이 네 연산자는 Rx 윈도잉 계열의 풀(pull) 모델
    이식입니다.
  </p>
