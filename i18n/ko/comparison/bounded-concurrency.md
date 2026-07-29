---
slug: bounded-concurrency
title: 두 개씩 프로필 가져오기 — Dart vs FxDart
description: 순서를 지키는 동시성 제한 — 순수 Dart로 직접 만든 워커 풀과 FxDart의 toAsync + map + concurrent를 비교합니다.
heading: 두 개씩 프로필 가져오기
order: 20
tier: 2
functions: toAsync, map, concurrent
domain: users
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    (가상의) API에서 사용자 프로필 6개를 가져오되, <strong>동시에 진행 중인
    요청이 두 개를 넘지 않도록</strong> 하세요 — API에 요청 속도 제한이
    있습니다. 결과는 <strong>원래 순서대로</strong> 돌아와야 합니다. 제한이
    지켜졌는지 증명하기 위해, 가짜 fetch 함수는 겹쳐서 실행된 요청 수를
    세고 두 버전 모두 관측된 최댓값을 출력합니다.
  </p>
  <p>
    이것은 순수 Dart에 딱 맞는 기본 도구가 없는 작업입니다.
    <code>Future.wait</code>는 <em>전부</em> 한꺼번에 실행해 버리고,
    두 개씩 배치로 나누면 각 쌍에서 더 느린 쪽을 기다리느라 시간을
    낭비합니다. 제대로 하려면 워커 풀을 직접 작성해야 합니다 — 인덱스
    관리, 공유 커서, 미리 크기를 정한 결과 슬롯까지. FxDart의
    <code>.concurrent(2)</code>는 그 워커 풀을 단어 하나로 표현한 것입니다:
    요청이 하나 끝날 때마다 다음 요청이 시작되고, 순서는 그대로
    유지됩니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    두 버전은 같은 결과를 출력하지만, 차이는 무엇을 작성해야 했고
    앞으로 무엇을 유지보수해야 하는가에 있습니다. 네이티브 워커 풀은
    실제 프로덕션에서 흔히 보는 보일러플레이트이며, 미묘하게 틀리기도
    쉽습니다 — 공유 커서의 off-by-one 오류, 결과 리스트 크기를 미리
    잡지 않아 생기는 문제, 순서가 뒤바뀌는 문제 등. FxDart 버전에서는
    동시성 정책이 체인의 한 단계로 표현되므로, 제한값을 바꾸거나 아예
    없애려면 함수 전체 구조가 아니라 숫자 하나만 건드리면 됩니다.
  </p>
