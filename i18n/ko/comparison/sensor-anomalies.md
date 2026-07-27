---
slug: sensor-anomalies
title: 센서와 측정값 짝짓고 이상치 찾기 — Dart vs FxDart
description: 두 개의 병렬 리스트를 결합해 고온 측정값에 표시합니다 — 순수 Dart의 인덱스 루프(core에는 zip이 없음) 대 FxDart의 zip + filter + map.
heading: 센서와 측정값 짝짓고 이상치 찾기
order: 17
tier: 2
functions: zip, filter, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    텔레메트리 API가 <strong>병렬 리스트</strong> 두 개를 반환합니다:
    센서 이름과 최신 온도 측정값이며, 위치로 서로 대응됩니다. 이를
    짝지어, <strong>90.0°C</strong>를 초과하는 측정값만 남기고, 리스트
    순서대로 이상치마다 경고 줄 하나를 출력하세요. 데이터는 아래
    코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 <code>zip</code>이 없습니다.
    <code>package:collection</code>이 <code>IterableZip</code>을
    제공하지만, 이는 같은 타입의 이터러블끼리 묶는 용도라 —
    <code>List&lt;String&gt;</code>과 <code>List&lt;double&gt;</code>을
    짝지으면 둘 다 <code>Object</code>로 격하되어 조건문에 캐스팅이
    끼어들게 됩니다 — 그래서 실무에서는 Dart 개발자들이 여기 나온
    인덱스 루프를 대신 씁니다. 이 루프는 올바르게 동작하지만, 짝짓기가
    위치 기반 장부 관리(<code>sensors[i]</code>, <code>readings[i]</code>)
    안에 갇혀 있어 다른 곳으로 넘기거나 더 필터링할 수 있는 결과물을
    만들어내지 않습니다. FxDart의 <code>zip</code>은 타입이 있는
    <code>(String, double)</code> 레코드 쌍을 내보내므로, 이상치 검사와
    포맷팅이 실제 값 위에서 동작하는 평범한 체인 단계로 남습니다.
  </p>
