---
slug: spaced-out-calls
title: 100 ms마다 호출 하나 — RxDart vs FxDart
description: 최소 100 ms 간격의 핑 다섯 번, 단조 Stopwatch로 증명 — rx interval vs 순차 풀 체인의 매퍼 안에 넣은 평범한 delay.
heading: 100 ms마다 호출 하나
order: 39
tier: 4
functions: fx, toAsync, map
alsoLink: streams
domain: general
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    속도 제한이 있는 엔드포인트에 핑 다섯 번을 보내되, 각 호출은 이전
    호출보다 최소 <strong>100&nbsp;ms</strong> 뒤에 시작해야 합니다.
    모든 호출의 시작을 단조 <code>Stopwatch</code>에 기록하고, 다섯
    개의 응답을 출력한 뒤, 모든 간격이 제한을 지켰을 때만
    <code>spaced: true</code>를 출력하세요. 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    페이싱은 시간에 관한 일이므로 스트림이 이길 것이라 기대할 수
    있습니다 — 그리고 실제로 RxDart에는 그것을 가리키는 단어가
    있습니다: <code>interval</code>이 각 이벤트를 핑에 닿기 전에
    100&nbsp;ms씩 붙들어 두고, 배압이 전체를 순차로 유지합니다.
    연산자 하나, 요구사항 충족.
  </p>
  <p>
    하지만 풀 파이프라인은 기본이 순차이고, 그것이 페이싱을 민망할
    만큼 단순한 일로 바꿉니다: 지연을 <em>매퍼 안에</em> 넣으세요. 각
    풀이 100&nbsp;ms 기다렸다가 호출합니다 — 이번 풀이 끝나기 전에는
    다음 풀이 시작될 수 없으므로 간격은 구조적이고, 연산자는 필요
    없습니다. Stopwatch 검증은 양쪽 모두 <code>spaced: true</code>를
    출력합니다. 양쪽에 단서 하나씩 붙은 무승부라 부르겠습니다:
    RxDart는 개념에 명시적으로 이름을 붙이고, 이는 다른 시간
    연산자들로 가득한 파이프라인에서 더 잘 읽힙니다; FxDart는 그것을
    요구의 한 줄짜리 귀결로 얻지만, 이 과제가 엄격히 직렬인 호출을
    원하기 때문일 뿐입니다 — 자기 일정대로 도착하는 이벤트(진짜
    이벤트 스트림)의 간격 조절에는 다리의 스트림
    쪽(<code>fxStream</code>)과 RxDart의 시간 어휘로 손을 뻗으세요.
  </p>
