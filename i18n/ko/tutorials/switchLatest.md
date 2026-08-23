---
slug: switchLatest
title: switchLatest — FxDart 101
description: FxDart switchLatest 튜토리얼: 스트림의 스트림을 최신 내부만 남겨 평탄화하기 — flattenMerge, flattenConcat, exhaustLatest, concatEager와 함께 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>switchLatest</code>, <code>flattenMerge</code> 및 관련 함수
section: 14
crumb: switchLatest
prev: mergeMap.html
prevLabel: mergeMap
next: mergeScan.html
nextLabel: mergeScan
---
  <p class="hero-sub">스트림의 스트림을 평탄화합니다: 최신만 남기거나, 전부 실행하거나, 순서대로 재생하거나, 여분을 무시하거나 — 그리고 <code>concatEager</code>로 나중 소스를 즉시 시작합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이벤트가 이미 <em>내부 스트림</em>인 경우가 있습니다 — 세션마다
    소켓 하나, 이미 만들어진 요청. 쓸 매퍼는 없고, 질문은 평탄화 정책
    하나뿐입니다. 이 항등 형태들이 그것입니다:
    <code>switchLatest</code>는
    <code><a href="switchMap.html">switchMap</a>((s) =&gt; s)</code>,
    <code>flattenMerge</code>는
    <code><a href="mergeMap.html">mergeMap</a></code>,
    <code>flattenConcat</code>는 <code>concatMap</code>,
    <code>exhaustLatest</code>는 <code>exhaustMap</code>.
    <code>FxEvents</code>의 <code>FxEvents</code>는
    <code>.map((e) =&gt; e.stream).switchLatest()</code>로
    평탄화합니다.
  </p>
  <p>
    <code>switchLatest</code>는 가장 새로운 내부 스트림만
    비춥니다: 새것이 오면 이전 것을 진행 도중에
    <strong>취소</strong>합니다. 오래된 내부가 무가치해질 때
    쓰세요 — 현재 탭의 피드, 현재 쿼리의 결과. 체인은 아우터가
    닫히고 <em>그리고</em> 마지막 내부가 완료됐을 때 닫힙니다.
  </p>
  <p>
    나머지 셋이 정책 표의 나머지입니다.
    <code>flattenMerge</code>는 모든 내부를 한꺼번에 실행하고
    (<code>concurrent: n</code>으로 한도);
    <code>flattenConcat</code>는 각각을 완료까지 재생한 뒤 다음을
    시작합니다; <code>exhaustLatest</code>는 첫 번째를 지키고,
    하나가 도는 동안 도착한 내부를 무시합니다.
  </p>
  <p>
    <code>concatEager</code>는
    <code><a href="waitAll.html">FxEvents.concat</a></code>의
    형제입니다. 둘 다 소스 순서로 내보내지만, concat은 현재 것이
    완료될 때까지 다음 소스를 <em>구독</em>하지 않습니다 — 콜드인
    나중 소스는 시작조차 하지 않은 상태입니다.
    <code>concatEager</code>는 모든 소스를 즉시 구독하고 나중
    이벤트를 자기 차례까지 버퍼에 담습니다. 요청은 지금 시작하고
    응답은 여전히 순서대로 재생하는 방법이 그것입니다. fxdart
    이벤트 레이어, Rx의 <code>switchAll</code>,
    <code>mergeAll</code>, <code>concatAll</code>,
    <code>exhaustAll</code>, <code>concatEager</code>를
    따랐습니다.
  </p>

  <h2>데모 1 · switchLatest — 최신 내부가 이긴다</h2>
  {{playground:0}}

  <h2>데모 2 · flattenConcat 대 switchLatest</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>concatEager</code> 대 concat — 나중 소스가 즉시 시작됩니다.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — switchLatest의 매핑 형태 ·
    <a href="mergeMap.html"><code>mergeMap</code></a> — mergeMap, concatMap, exhaustMap ·
    <a href="waitAll.html"><code>FxEvents.concat</code></a> — <code>concatEager</code>의 나중에-구독하는 형제
  </div>
