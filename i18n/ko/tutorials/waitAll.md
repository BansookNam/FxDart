---
slug: waitAll
title: waitAll — FxDart 101
description: FxDart waitAll 튜토리얼: 모든 스트림이 닫히면 결과 하나, 그리고 zip·concat·combineLatestAll·mergeWith·raceWith — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>waitAll</code>, <code>zip</code> 및 관련 함수
section: 14
crumb: waitAll
prev: race.html
prevLabel: race
next: combine.html
nextLabel: combine
---
  <p class="hero-sub">여러 스트림을 하나로 합치기: 전부 기다리거나, 인덱스로 짝짓거나, 차례로 재생하거나, 경주시키거나.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>FxEvents.waitAll(sources)</code>는 스트림을 위한
    <code>Future.wait</code>입니다. 모든 소스가 닫히고 나면 정확히
    <strong>하나의</strong> 이벤트 — 각 소스의 <em>마지막</em> 값을
    소스 순서대로 담은 리스트 — 를 내보내고, 자신도 닫습니다. 대시보드
    사례가 그것입니다: 패널 셋이 각자 로드되고, 가장 느린 하나가
    들어오면 화면이 그려집니다. 한 번도 내보내지 않고 닫힌 소스가
    있으면 보고할 완전한 결과가 없으므로, 아무것도 내보내지 않습니다.
  </p>
  <p>
    <code>FxEvents.zip</code>은 소스를 <strong>인덱스</strong>로
    짝짓습니다: 모든 소스의 1번째끼리, 그다음 모든 소스의 2번째끼리,
    이렇게요. 앞서가는 소스는 가장 느린 소스가 따라올 때까지 버퍼에
    담기고, 닫힌 소스의 버퍼가 비는 순간 결과도 닫힙니다 — 더 이상 짝을
    만들 수 없으니까요. <code>zipWith</code>는 두 소스 형태이고,
    리스트 기반 정적 메서드와 달리 <em>서로 다른</em> 타입을 짝지을 수
    있습니다.
  </p>
  <p>
    <code>zip</code>과
    <code><a href="combineLatest.html">combineLatest</a></code>는 나란히
    두고 볼 가치가 있습니다. "두 스트림 합치기"의 두 절반인데 사람들이
    끊임없이 잘못 고르거든요. <strong>zip은 위치로 짝짓습니다</strong>:
    A의 3번째는 아무리 오래 걸려도 언제나 B의 3번째를 만납니다.
    <strong>combineLatest는 시간으로 짝짓습니다</strong>: 어느 쪽
    이벤트든 상대가 지금 쥐고 있는 값과 함께 다시 나가므로, 한 소스가
    여러 출력에 등장하고 다른 소스는 하나에도 못 낄 수 있습니다.
    <code>combineLatestAll</code>이 그 N항 형태입니다.
  </p>
  <p>
    나머지는 합치기가 아니라 차례 세우기입니다.
    <code>FxEvents.concat</code>은 각 소스를 완료까지 재생한 뒤 다음을
    시작합니다 — <code>followedBy</code>가 그 두 소스 형태이고, Dart
    자신의 <code>Iterable.followedBy</code>에서 이름을 땄습니다.
    <code>mergeWith</code>와 <code>raceWith</code>는
    <code><a href="race.html">FxEvents.merge</a></code>,
    <code><a href="race.html">FxEvents.race</a></code>의 인스턴스
    형태입니다. fxdart 이벤트 레이어, Rx의 <code>forkJoin</code>,
    <code>zip</code>, <code>combineLatestList</code>,
    <code>concat</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 모든 패널 기다리기</h2>
  {{playground:0}}

  <h2>데모 2 · 위치로, 또는 시간으로</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 차례 세우기 — concat, followedBy, raceWith, mergeWith.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — 시간 기준 짝짓기, UI 상태에는 보통 이쪽 ·
    <a href="race.html"><code>race</code></a> — 먼저 말하는 소스가 이기고 나머지는 취소 ·
    <a href="zip.html"><code>zip</code></a> — Iterable을 인덱스로 짝짓는 풀 레이어의 원본
  </div>
