---
slug: mergeMap
title: mergeMap — FxDart 101
description: FxDart mergeMap 튜토리얼: 이벤트를 내부 스트림으로 매핑해 전부 동시에, concatMap으로 순서대로, exhaustMap으로 먼저 온 것만 — 을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>mergeMap</code>, <code>concatMap</code> &amp; <code>exhaustMap</code>
section: 14
crumb: mergeMap
prev: switchMap.html
prevLabel: switchMap
next: race.html
nextLabel: race
---
  <p class="hero-sub">"지난 이벤트가 아직 실행 중인데 새 이벤트가 도착했다"에 대한 나머지 세 가지 답: 전부 실행하거나, 순서대로 실행하거나, 새 것을 무시하거나.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이벤트를 <em>내부 스트림</em> — 요청, 업로드, 질의 — 으로 매핑하면
    풀 파이프라인은 결코 답할 필요가 없는 질문 하나가 생깁니다: 지난
    내부 스트림이 끝나기 전에 다음 이벤트가 도착하면 어떻게 되는가?
    합리적인 정책은 정확히 넷뿐이고, 잘못 고르는 곳에서 대부분의
    리액티브 버그가 태어납니다.
    <code><a href="switchMap.html">switchMap</a></code>이 "마지막이
    이긴다"는 답이고, 이 셋이 나머지 셋입니다.
  </p>
  <p>
    <code>mergeMap(f)</code>는 모든 내부 스트림을
    <strong>한꺼번에</strong> 실행하고 그 출력을 도착 순서로
    엇섞습니다. 모든 결과가 중요하고 어느 것도 다른 것을 밀어내지 않을
    때 쓰세요 — 파일 셋 업로드, 서비스 셋으로 팬아웃.
    <code>concurrent: n</code>을 주면 한 번에 최대 <em>n</em>개만
    돌고 나머지는 큐에서 기다립니다. 팬아웃이 소켓 이백 개를 열지 않게
    하는 방법이 이것입니다.
  </p>
  <p>
    <code>concatMap(f)</code>는 <strong>엄격히 순서대로</strong>
    실행합니다. 각각이 완료된 뒤에야 다음이 시작합니다. 겹치는 것도
    버려지는 것도 없으므로 느린 내부 스트림 하나가 체인 전체를
    막습니다 — "이 편집들을 순서대로 적용하라"처럼 순서가 정확성
    조건일 때는 그것이 바로 요점입니다.
  </p>
  <p>
    <code>exhaustMap(f)</code>는 <strong>첫 번째</strong>를 지키고
    나머지를 무시합니다: 내부 스트림이 도는 동안 들어온 이벤트는 큐에
    쌓이지도, 취소되지도 않고 그냥 버려집니다. 이것이 중복 제출
    가드입니다. 요청이 아직 날아가는 중인 버튼을 두 번째로 눌러도 아무
    일도 일어나지 않습니다 — 그 요청이 <code>POST /orders</code>일 때
    정확히 원하는 동작이죠.
  </p>
  <p>
    fxdart 이벤트 레이어, Rx의 <code>flatMap</code>,
    <code>flatMap(maxConcurrent: 1)</code>, <code>exhaustMap</code>을
    따랐습니다. 첫 번째를 여기서 <code>mergeMap</code>이라 부르는 것은
    <code><a href="flatMap.html">flatMap</a></code>이 풀 쪽에서 이미
    이터러블 평탄화를 뜻하기 때문입니다.
  </p>

  <h2>데모 1 · mergeMap — 전부 한꺼번에</h2>
  {{playground:0}}

  <h2>데모 2 · exhaustMap — 중복 제출 가드</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>concatMap</code>의 순서, 그리고 한도가 걸린 팬아웃.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — 네 번째 정책: 최신이 이기고 나머지는 취소 ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — 풀 쪽의 한도 있는 팬아웃, 결과는 순서를 지킴 ·
    <a href="debounce.html"><code>debounce</code></a> — 더 나은 해법일 때가 많음: 내부 스트림이 되기 전에 여분의 이벤트를 막기
  </div>
