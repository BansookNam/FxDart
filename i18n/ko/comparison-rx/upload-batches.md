---
slug: upload-batches
title: 4개씩 배치로 업로드하기 — RxDart vs FxDart
description: 대기 중인 파일 열 개, 요청당 최대 네 개 — 스트림의 bufferCount(4)와 pull 체인의 chunk(4), 짧은 마지막 배치는 양쪽 모두 같습니다.
heading: 4개씩 배치로 업로드하기
order: 11
tier: 2
functions: fx, chunk, map
domain: orders
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    파일 열 개가 업로드 대기열에 있고 API는 요청당 최대
    <strong>네 개</strong>를 받습니다. 대기열을 4개짜리 배치로
    묶고(마지막 배치는 짧습니다) 각 배치의 크기와 id를 출력하세요.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    겹치지 않는 배칭은 두 모델 모두의 핵심 어휘이고, 둘 다 한 단어로
    말합니다: <code>bufferCount(4)</code>는 이벤트 네 개를 모아
    <code>List</code>로 내보내고, <code>chunk(4)</code>는 수요 한 번에 값
    네 개를 <code>List</code>로 끌어옵니다. 둘 다 소스가 바닥나면 짧은
    꼬리 배치를 흘려보냅니다. 각 배치를 포맷하는 <code>map</code>은 그
    뒤로 글자 하나까지 동일합니다.
  </p>
  <p>
    모델들이 갈라지기 시작하는 곳은 이 예제의 프레임 바로 바깥입니다.
    스트림이 버퍼링하는 이유는 값이 자기 일정대로 도착하기 때문입니다 —
    <code>bufferCount</code>에는 시간 기반 형제들(<code>bufferTime</code>)도
    있는데, pull 파이프라인은 그것을 의도적으로 제공하지 않습니다.
    소비자가 도착을 통제하는 세계에서 "지난 1초 동안 도착한 것"은 의미가
    없기 때문입니다. pull 체인이 청크로 묶는 이유는 <em>소비자</em>가 네
    개씩의 수요를 원하기 때문입니다 — <code>chunk</code>가 하류의
    동시성과 곧바로 조합되는 이유이기도 합니다(다음 배치를 조립하는 동안
    각 배치를 전송하기). 열 개짜리 고정 대기열에서는 어느 쪽의 장점도
    발휘되지 않습니다: 무승부.
  </p>
