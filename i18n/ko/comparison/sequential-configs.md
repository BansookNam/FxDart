---
slug: sequential-configs
title: 원격 설정 세 개를 순서대로 불러오기 — Dart vs FxDart
description: 순차 비동기 fetch — 순수 Dart의 평범한 await-in-loop 대 FxDart의 toAsync + map, 단어 하나 차이로 동시성 제한 버전이 됩니다.
heading: 원격 설정 세 개를 순서대로 불러오기
order: 10
tier: 1
functions: toAsync, map
domain: general
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    (가상의) API에서 원격 설정 섹션 세 개 — <code>features</code>,
    <code>limits</code>, <code>theme</code> — 를 <strong>하나씩,
    순서대로</strong> 불러온 다음, 불러온 값을 각각 출력하세요. 가짜
    fetch는 고정된 15ms가 걸립니다; 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    세 번의 순차적인 await만 놓고 보면, 네이티브 <code>for</code>
    루프로 충분합니다 — 이걸 쓰겠다고 라이브러리가 필요한 사람은 없고,
    이야기가 여기서 끝난다면 무승부일 것입니다. FxDart가 이기는
    지점은 그다음에 코드가 어떻게 바뀌는가입니다:
    <code>toAsync().map(fetchConfig)</code>는 기본적으로 순차 실행되는
    지연 비동기 파이프라인이며, 설정이 세 개가 아니라 서른 개가 되는
    날, <code>.concurrent(8)</code>을 붙이기만 하면 같은 체인이 순서를
    유지하는 제한된 워커 풀로 바뀝니다 — 다른 곳은 아무것도 건드리지
    않습니다. 네이티브 루프에는 이런 다이얼이 없습니다; 다시 작성해야
    합니다. 그 결말은
    <a href="bounded-concurrency.html">두 개씩 프로필 가져오기</a>를
    참고하세요.
  </p>
