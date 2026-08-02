---
slug: pipeline-into-stream
title: 파이프라인이 스트림 소비자로 이어질 때 — RxDart vs FxDart
description: 순서를 지키는 mapConcurrent fetch가 결과를 toStream으로 스트림 소비자에게 넘깁니다 — 반대 방향으로 건넌 다리.
heading: 파이프라인이 스트림 소비자로 이어질 때
order: 50
tier: 4
functions: fx, toAsync, mapConcurrent, chunk, streams
domain: orders
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    주문 상태 다섯 건을 가져오되 동시 진행 요청은 최대 두 개, 결과는
    소스 순서대로 — 그런 다음 결과를 둘씩 배치로 묶어 각 배치를
    출력하는 하류 소비자에게 넘기세요. 조회 지연은 코드에 고정되어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    RxDart는 끝에서 끝까지 스트림으로 달립니다:
    <code>maxConcurrent: 2</code>를 단 <code>flatMap</code>이 fetch에
    제한을 걸고 <code>bufferCount(2)</code>가 결과를 둘씩 짝짓습니다.
    단서 하나가 가운데에 삽니다: 동시 <code>flatMap</code>은
    <em>완료</em> 순서로 내보내므로, 이 패널이 소스 순서로 출력되는
    것은 지연들이 우연히 그 순서로 완료되기 때문입니다 — 동시성
    아래에서의 재정렬은 푸시 모델의 기본값이고, 일반적으로 소스
    순서를 지키려면 모아서 정렬해야 합니다.
  </p>
  <p>
    FxDart 패널은 이전 예제의 다리를 반대 방향으로 건넌 것입니다.
    가져오는 절반은 풀 파이프라인이고 —
    <code>mapConcurrent(2, …)</code>는 지연이 어떻게 굴든 구조적으로
    순서를 지킵니다 — <code>chunk(2)</code>(FxDart의
    <code>bufferCount</code>)가 결과를 둘씩 짝짓고,
    <code>toStream()</code>이 배치들을 임의의 스트림 소비자에게
    넘깁니다. 여기서 그 소비자는 출력만 하지만, RxDart 앱이라면
    브리지된 스트림 위에서 Rx 연산자들로 계속 이어 갈 수 있습니다:
    생산자는 누가 소비하는지 신경 쓰지 않습니다. 그 분업이 곧
    판정입니다: 제한 있고, 순서 있고, 타입 있는 일은 풀 파이프라인에서
    하고, 그것을 <code>Stream</code>으로 노출한 뒤, 푸시 어휘(버퍼링,
    디바운싱, UI 바인딩)가 더 잘 맞는 곳부터는 푸시 세계가 이어받게
    하세요. 무승부 — 다리가 곧 요점입니다.
  </p>
