---
slug: per-row-retry
title: 불안정한 행을 각각 따로 재시도하기 — RxDart vs FxDart
description: 불안정한 임포트 행 여섯 개, 행마다 두 번 시도, 세 개 동시 진행 — flatMap은 완료 순서로 내보내고, concurrent 아래의 mapRetry는 소스 순서를 지킵니다.
heading: 불안정한 행을 각각 따로 재시도하기
order: 31
tier: 3
functions: fx, toAsync, retry, concurrent
domain: orders
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    불안정한 엔드포인트를 통해 행 여섯 개를 임포트합니다: 짝수 행은
    성공하기 전에 정확히 한 번 실패합니다. <strong>각 행에 자기만의
    재시도 예산</strong> 두 번을 주고, 한 번에 최대 세 행씩 실행하며,
    결과를 <strong>소스 순서대로</strong> 성공한 시도 횟수와 함께
    출력하세요. 실패 주입과 행별 지연은 결정적이며 코드에 들어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    회복탄력성 절반은 양쪽이 같은 방식으로 표현합니다: 행마다 재시도
    래퍼를 씌워, 불안정한 행 하나가 다시 도는 동안 이웃 행들은 그대로
    지나갑니다. RxDart는 이를 <code>maxConcurrent:&nbsp;3</code>과
    함께 행마다 재시도하는 내부 스트림으로의 <code>flatMap</code>으로
    쓰고, FxDart는 <code>concurrent(3)</code> 아래의
    <code>mapRetry(2,&nbsp;…)</code>로 씁니다 — 진행 중인 각 요소가
    자기만의 독립적인 예산을 지니는 형태입니다.
  </p>
  <p>
    차이는 반대쪽 끝에서 무엇이 나오는가입니다.
    <code>flatMap</code>은 내부 스트림들을 <em>완료</em> 순서로
    병합합니다 — 그것이 이 연산자의 계약이므로 — 세 행이 동시에
    진행되고 지연이 제각각이면 결과는 뒤섞여 도착합니다. 소스 순서를
    되찾으려면 모든 결과에 행 id를 태그로 붙이고 <code>toList</code>
    뒤에 정렬해야 합니다. 순서를 지켜 주는 RxDart 연산자인
    <code>concatMap</code>은 동시성을 포기하는 대가로 그렇게 합니다 —
    한 번에 한 행씩. 풀 모델에서는 순서 있는 동시성이 기본
    모드입니다: <code>concurrent(3)</code>은 세 개의 풀을 한꺼번에
    평가하되 구조적으로 소스 순서대로 내놓으므로, 태그 붙일 것도
    정렬할 것도 없습니다.
  </p>
  <p>
    판정은 FxDart — 순서가 이야기의 핵심입니다. "N개씩, 각각
    독립적으로 재시도, 순서대로"는 풀 모델에서는 체인 하나이고, 푸시
    모델에서는 병합한 뒤 다시 줄 세우는 우회책입니다.
  </p>
