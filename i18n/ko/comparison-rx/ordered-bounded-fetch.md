---
slug: ordered-bounded-fetch
title: 4개씩 가져오되 결과는 순서대로 — RxDart vs FxDart
description: fetch 여덟 건, 네 개 동시 진행, 소스 순서로 출력 — mapConcurrent는 구조적으로 순서를 지키고, flatMap(maxConcurrent)은 태그를 붙여 다시 정렬해야 합니다.
heading: 4개씩 가져오되 결과는 순서대로
order: 35
tier: 4
functions: fx, toAsync, mapConcurrent
domain: users
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    응답 시간이 제각각인 사용자 프로필 여덟 개를 가져오되, 동시에
    진행 중인 요청을 최대 <strong>4</strong>개로 유지하세요 — 그리고
    결과를 <strong>소스 순서대로</strong>(user 1 먼저) 출력하고,
    제한의 증거로 관측된 최대 동시 진행 수를 출력하세요. 지연은
    코드에 들어 있습니다; 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    동시성 제한은 양쪽 다 연산자 하나로 표현하고, 공유 카운터는 둘 다
    실제로 4개 동시 진행에 도달함을 보여 줍니다. 갈리는 지점은
    <em>순서</em>입니다. <code>flatMap(maxConcurrent: 4)</code>은
    병합입니다: 각 내부 결과를 완료되는 순간 내보내므로, 이 지연
    값들로는 user 7(10&nbsp;ms)이 user 1(80&nbsp;ms)보다 먼저
    출력됩니다. 요구사항을 맞추기 위해 RxDart 쪽은 모든 결과에 id를
    태그로 붙이고, 전부 모은 뒤, 나중에 정렬합니다 — 소스가 갖고
    있던 순서가 병합으로 파괴되어, 끝에서 손으로 다시 지어야 하는
    것입니다.
  </p>
  <p>
    <code>mapConcurrent(4, fetch)</code>는 애초에 순서를 잃지
    않습니다. 풀 파이프라인에서 동시성은 전달이 아니라
    <em>요구</em>의 속성입니다: 연산자는 겹치는 풀 네 개를 열어 두되
    결과를 요청된 순서대로 아래로 넘기며, 빨리 온 늦은 순번은 더 느린
    앞 순번들이 나갈 때까지 붙들어 둡니다. 제한-그리고-순서는 대부분의
    배치 작업이 실제로 원하는 모양이고 — 결과가 입력과 줄 맞고, 속도
    제한이 지켜지는 — 여기서는 재구성이 아니라 기본값입니다. 완료
    순서가 정말로 원하는 것일 때를 위한 것도 있습니다 — 다음 예제인
    <code>concurrentPool</code> — 하지만 그것은 선택해 들어가는
    변형이지, 되돌려야 하는 기본 동작이 아닙니다.
  </p>
