---
slug: consecutive-over-limit
title: 한계를 세 번 연속 초과한 측정값 — Dart vs FxDart
description: CO2 측정값이 세 시간 연속으로 1000 ppm을 넘는 구간을 모두 찾습니다 — 순수 Dart의 인덱스 루프와 FxDart의 zip + drop으로 만든 슬라이딩 윈도우를 비교합니다.
heading: 한계를 세 번 연속 초과한 측정값
order: 24
tier: 3
functions: zip, drop, filter, map, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    하루치 시간별 CO2 측정값이 주어집니다.
    <strong>세 시간 연속으로 1000 ppm을 넘는</strong> 모든 구간을
    찾아내세요 — 이는 환기 장치가 세 시간 내내 따라잡지 못했다는
    뜻입니다 — 그리고 각 구간을 헤더 줄 아래에 시작–종료 시각 범위로
    출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart 코어에는 슬라이딩 윈도우가 없으므로, 네이티브 버전은
    <code>i + 2 &lt; length</code> 경계와 세 번의 수동 조회를 가진
    인덱스 루프가 됩니다 — 맞기는 하지만, 그 안의 모든 조각이 읽는
    사람이 직접 확인해야 하는 부기 작업입니다. FxDart 버전은 윈도우
    자체를 <em>데이터</em>로 만듭니다: 리스트를 자기 자신과 하나씩,
    둘씩 밀어서(<code>drop(1)</code>, <code>drop(2)</code>)
    <code>zip</code>하면, 각 원소가 (현재값, 다음값, 다다음값) 삼중항이
    됩니다 — 인덱스는 어디에도 없습니다. <code>zip</code>이 가장 짧은
    입력에서 멈추는 성질이 바로 루프가 경계 조건으로 인코딩했던
    "윈도우가 완전히 들어맞아야 한다"는 규칙 그 자체입니다. 윈도우를
    4시간으로 넓히는 일은 <code>zip</code> 줄 하나를 더 추가하는
    것일 뿐, 산술식을 다시 검토할 필요가 없습니다.
  </p>
