---
slug: rate-limited-import
title: 속도 제한이 있는 배치 임포트 — Dart vs FxDart
description: 거래 9건을 3건씩 배치로, 한 번에 한 배치씩 임포트하며 누적 합계를 계산합니다 — chunk + concurrent(1) + scan과 순차 루프를 비교합니다.
heading: 속도 제한이 있는 배치 임포트
order: 46
tier: 4
functions: chunk, toAsync, map, concurrent, delay, scan, drop, sumBy
domain: transactions
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    가계부 거래 9건(아래 코드에 있음)을 <strong>세 건씩 배치로, 한
    번에 한 호출씩</strong>만 받는 임포트 엔드포인트로 보내세요 —
    엄격하게 순차적이며 절대 겹치지 않습니다. 각 배치가 끝날 때마다
    배치 크기, 금액, 지금까지 임포트된 누적 합계를 기록하세요. 배치
    요약을 순서대로 출력한 다음, 최대 동시 진행 카운터(반드시 1이어야
    합니다)를 통해 속도 제한이 지켜졌음을 증명하세요.
  </p>
  <p>
    FxDart에서는 정책 전체가 체인입니다: <code>chunk(3)</code>이 배치
    크기를 정하고, <code>concurrent(1)</code>이 속도를 정하며,
    <code>scan</code>이 응답들을 거치며 누적 합계를 실어 나릅니다
    (<code>drop(1)</code>은 scan의 초기값을 버립니다). 엔드포인트
    자체는 <code>delay</code>로 지연을 시뮬레이션하고
    <code>sumBy</code>로 배치 합계를 계산합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    공정하게 말하자면: 엄격하게 순차적인 임포트는 평범한
    <code>for</code> 루프가 무리 없이 다루는 유일한 동시성 정책이며,
    네이티브 버전도 읽기 좋습니다 —
    <code>package:collection</code>의 <code>slices</code>가 배치 분할까지
    해결해 줍니다. 다만 누적 합계는 이미 손으로 이어 나가는 가변
    상태이고(<code>n++</code> 옆에 <code>running += amount</code>),
    <code>scan</code>은 이를 선언적인 한 단계로 바꿔줍니다. 그리고 이
    루프의 단순함은 막다른 길이기도 합니다: 엔드포인트가 언젠가 두
    배치의 동시 진행을 허용하게 되면, FxDart 버전은 <code>1</code>을
    <code>2</code>로 바꾸기만 하면 되지만, 루프는 다른 비동기 예제에
    나온 워커 풀로 변해야 합니다. 체인은 정책을 선언하고, 루프는 정책을
    코드로 구현합니다.
  </p>
