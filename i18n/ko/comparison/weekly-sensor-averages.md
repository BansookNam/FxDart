---
slug: weekly-sensor-averages
title: 일별 측정값으로 구하는 주간 평균 — Dart vs FxDart
description: 21개의 일별 측정값을 3개의 주간 평균으로 접습니다 — 순수 Dart의 인덱스 연산과 sublist, FxDart의 chunk + averageBy + zipWithIndex를 비교합니다.
heading: 일별 측정값으로 구하는 주간 평균
order: 25
tier: 3
functions: chunk, map, averageBy, zipWithIndex, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    온도 센서가 3주 동안(21개 값) 하루에 하나씩 측정값을 기록했습니다.
    <strong>7일 단위 주간 평균</strong>을 1부터 번호를 매겨 한 줄씩
    보고하세요. 데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상
    출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    "7개씩 묶기"는 순수 Dart에 표현할 방법이 없어서, 네이티브 버전은
    카운팅 루프를 돌며 <code>sublist(w * 7, w * 7 + 7)</code>로 매주를
    잘라냅니다 — 읽는 사람이 다시 검증해야 하는 인덱스 연산이고, 마지막
    주가 짧으면 깨집니다. FxDart의 <code>chunk(7)</code>은
    그룹화를 한 단어로 표현하며(짧은 마지막 그룹도 알아서 처리합니다),
    <code>averageBy</code>가 reduce 후 나누는 과정을 대신하고,
    <code>zipWithIndex</code>는 루프 카운터를 빌리는 대신 주 번호를
    파이프라인 안으로 가져옵니다.
  </p>
