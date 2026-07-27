---
slug: concurrent-profile-fetch
title: 프로필 10개를 세 개씩 가져오기 — Dart vs FxDart
description: 동기 준비 과정이 그대로 제한된 동시성으로 이어집니다 — filter와 sort 다음에 toAsync + map + concurrent(3)를 잇는 방식과 직접 만든 워커 풀을 비교합니다.
heading: 프로필 10개를 세 개씩 가져오기
order: 41
tier: 4
functions: filter, sortBy, toAsync, map, concurrent, join
domain: users
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    열두 개의 계정으로 이루어진 디렉터리에서 <strong>활성</strong> 계정만
    골라 id 순으로 정렬한 뒤, (가상의) API에서 각 프로필을 가져오세요 —
    <strong>동시에 진행 중인 요청이 세 개를 넘지 않아야</strong> 하며,
    결과는 원래 순서대로 나와야 합니다. 가짜 fetch 함수는 겹쳐서 실행된
    요청 수를 세고, 두 버전 모두 관측된 최댓값을 출력해 제한이 지켜졌음을
    증명합니다. 데이터는 아래 코드에 있습니다.
  </p>
  <p>
    이는 비동기 섹션 전체를 대표하는 형태입니다: 동기 파이프라인
    (<code>filter</code> → <code>sortBy</code>)이 <code>toAsync</code>로
    비동기 영역에 들어선 뒤에도 계속 이어집니다 — fetch를 실행하는
    <code>map</code>, 이를 제한하는 <code>concurrent(3)</code>, 형식을
    맞추는 또 하나의 <code>map</code>, 마무리하는 <code>join</code>까지.
    리스트에서 리포트까지 하나의 체인입니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart는 동기 절반(<code>where</code> + <code>sortedBy</code>)은
    잘 처리하지만, 비동기 경계에 이르면 어휘가 바닥납니다: 순서를
    유지하면서 동시성을 제한하려면 직접 만든 워커 풀 — 공유 커서, 미리
    크기를 정한 결과 슬롯, 워커들을 기다리는 <code>Future.wait</code> —
    이 필요합니다. 그 풀은 실제 프로덕션에서 흔한 보일러플레이트이며,
    작업을 두 개의 방언으로 쪼갭니다: 준비 과정을 위한 유려한 체인과,
    fetch를 위한 명령형 배관 작업. FxDart 버전에서는 정책이 끝까지
    선언적으로 유지됩니다 — <code>concurrent(3)</code>이 워커 풀 전체를
    대신하며, 제한값을 바꾸거나 없애는 일은 함수의 구조가 아니라 숫자
    하나만 건드리면 됩니다.
  </p>
