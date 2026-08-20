---
slug: anomaly-context
title: 주변 맥락과 함께 보는 이상치 — Dart vs FxDart
description: 한계를 초과한 센서 측정값을 앞뒤 한 줄씩과 함께 보여줍니다 — zipWithIndex + flatMap + uniq로 이루어진 하나의 파이프라인과 중첩 루프로 만든 인덱스 집합을 비교합니다.
heading: 주변 맥락과 함께 보는 이상치
order: 42
tier: 4
functions: zipWithIndex, filter, flatMap, uniq, map, maxBy, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    온도 센서가 열 번의 측정값을 기록했습니다(데이터는 코드 안에 있음).
    <strong>80.0&nbsp;C를 초과하는</strong> 측정값마다 <code>!</code>
    표시를 붙여, <em>바로 앞뒤</em> 측정값과 함께 — <code>grep -C1</code>이
    맥락 줄을 보여주는 방식대로 — 출력하세요. 맥락 범위가 겹치는 경우 각
    측정값은 한 번만 나타나야 합니다. 마지막에는 최고 측정값을 출력합니다.
    두 버전 모두 <em>예상 출력</em> 아래에 표시된 블록을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    "적중할 때마다 윈도우로 확장하고, 겹치는 윈도우는 병합한다"는
    평탄화-후-중복제거 문제이며, FxDart는 그 표현 그대로 풀어냅니다:
    <code>zipWithIndex</code>가 위치를 유지하고, <code>filter</code>가
    이상치를 찾고, <code>flatMap</code>이 각 이상치를
    <code>[i-1, i, i+1]</code>로 확장하며, <code>uniq</code>가 겹치는
    부분을 병합합니다 — 측정값에서 출력 줄까지 끊김 없는 하나의
    표현식입니다. 네이티브 Dart에는 이런 용도의
    <code>flatMap</code>-투-<code>uniq</code> 관용구가 없으므로, 자연스러운
    버전은 중첩 <code>for</code> 루프 안에서 인덱스의
    <code>Set&lt;int&gt;</code>를 만들고, 정렬한 뒤, 두 번째 루프에서
    형식을 맞춥니다 — 알고리즘은 같지만 세 개의 가변 상태 단계로
    나뉘어 있습니다.
  </p>
