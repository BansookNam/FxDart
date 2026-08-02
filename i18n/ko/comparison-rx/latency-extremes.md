---
slug: latency-extremes
title: 가장 빠른 요청과 가장 느린 요청 — RxDart vs FxDart
description: 엔드포인트 여덟 개를 비동기로 프로브해 최소·최대 지연을 출력하기 — 양쪽 모두 Future를 반환하는 축약, 각각 새 패스 한 번씩.
heading: 가장 빠른 요청과 가장 느린 요청
order: 20
tier: 2
functions: fx, toAsync, min, max
domain: logs
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    헬스체크가 비동기 <code>measure</code> 호출로 엔드포인트 여덟 개를
    프로브하고, 가장 빠른 지연과 가장 느린 지연을 밀리초로 보고합니다.
    고정된 샘플은 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 두 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    축약은 push와 pull이 수렴하는 곳입니다: 극값을 알려면 시퀀스 전체를
    봐야 하므로, <code>min</code>과 <code>max</code>는 둘 다 종결
    연산이고 둘 다 <code>Future</code>를 반환합니다. RxDart의 버전은
    <code>Comparable</code>이 아닌 요소를 위한 선택적 비교자도 받습니다;
    FxDart는 <code>min</code>과 <code>max</code>를 숫자 종결 연산으로
    유지하고 키 기반 경우는 <code>minBy</code>/<code>maxBy</code>로
    커버합니다. 평범한 정수 위에서 두 호출은 단어 하나까지 동일합니다 —
    FxDart 쪽은 먼저 <code>toAsync</code>로 pull들을 비동기 체인으로
    끌어올릴 뿐입니다.
  </p>
  <p>
    거울처럼 마주 보는 주름 하나는 <em>각</em> 축약이 소스를 소비한다는
    점입니다. Dart 스트림은 단일 구독이라, min을 묻고 나서 max를
    물으려면 구독 두 번이 필요합니다 — RxDart 쪽에
    <code>latencies()</code> 팩토리가 있는 이유입니다. FxDart 쪽도 같은
    이유로 같은 모양입니다: 종결 호출이 체인을 비우므로, 두 번째 축약은
    새 체인을 끌어옵니다. 따라서 둘 다 두 번 측정하고(먼저 리스트로
    수집하는 것이 공유되는 대안입니다), 어느 모델도 내세울 만한 우위가
    없습니다: 무승부, 주변 코드가 이미 흐르는 방향이 결정합니다.
  </p>
