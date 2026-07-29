---
slug: stream-windowed-alerts
title: 센서 스트림에서 윈도우 단위 경고 감지하기 — Dart vs FxDart
description: 실제 Dart Stream을 고정 크기 윈도우로 나누어 경고를 발생시킵니다 — fromStream + chunk + averageBy와 await-for에서의 수동 버퍼 관리를 비교합니다.
heading: 센서 스트림에서 윈도우 단위 경고 감지하기
order: 44
tier: 4
functions: streams, chunk, map, averageBy, maxBy, filter
domain: sensors
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    보일러 온도 센서가 실제 Dart <code>Stream</code>으로 측정값을
    전달합니다 — 10&nbsp;ms마다 하나씩, 총 12개입니다(아래 코드의 고정
    데이터). 스트림을 <strong>4개씩 묶은 윈도우</strong>로 그룹화하고,
    각 윈도우의 평균과 최댓값을 보고하며, 평균이 75.00 이상인 윈도우에는
    <code>ALERT</code> 줄을 출력하세요.
  </p>
  <p>
    FxDart의 답은 스트림 브리지입니다: <code>fxStream</code>이
    <code>Stream</code>을 풀 기반(pull-based) 파이프라인으로 끌어올리고,
    그 다음부터는 윈도우 나누기가 그저 <code>chunk(4)</code>일 뿐입니다 —
    동기 예제에서 쓰인 것과 같은 연산자입니다 — 이어서 <code>map</code>이
    각 윈도우를 <code>averageBy</code>와 <code>maxBy</code>로 요약합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    Dart의 <code>Stream</code> API에는 윈도우 나누기 연산자가 없습니다.
    관용적인 선택지는 두 가지입니다: 가변 버퍼를 두는
    <code>await for</code> 루프 — 예시처럼 4개를 모으고, 내보내고,
    초기화하는 방식 — 아니면 그 똑같은 관리 작업을 커스텀
    <code>StreamTransformer</code>로 패키징하는 것인데, 이는 코드가
    줄어들기는커녕 오히려 늘어납니다. 어느 쪽이든 버퍼,
    플러시 조건, 초기화는 직접 유지보수해야 하고, 마지막 윈도우가
    가득 차지 않는 경계 사례도 직접 따져야 합니다. FxDart에서는
    <code>chunk(4)</code>가 리스트에서와 똑같이 스트림에서도 한 단어로
    끝납니다 — <code>Stream</code>에서 파이프라인으로 넘어가는 데 드는
    비용은 <code>fxStream</code> 호출 한 번뿐이고, 연산자 어휘 전체가
    함께 딸려 옵니다.
  </p>
