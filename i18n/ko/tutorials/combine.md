---
slug: combine
title: combine — FxDart 101
description: FxDart combine 튜토리얼: CombineSpec으로 조종하는 하나의 결합자 — combineLatest 식, withLatestFrom 식, zipAll, withLatestFromAll — 을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>combine</code> &amp; <code>CombineSpec</code>
section: 14
crumb: combine
prev: waitAll.html
prevLabel: waitAll
next: stopOn.html
nextLabel: stopOn
---
  <p class="hero-sub">"누가 트리거하는가"와 "누가 이미 말했어야 하는가"를 위한 하나의 결합자 — 그리고 <code>zipAll</code>과 <code>withLatestFromAll</code>.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="combineLatest.html">combineLatest</a></code>,
    <code><a href="withLatestFrom.html">withLatestFrom</a></code>,
    <code><a href="waitAll.html">zip</a></code>의 차이는 누가
    방출을 일으킬 수 있는지, 그리고 모든 쪽이 이미 말했는지를
    요구하는지입니다. <code>combine</code>이 통합 형태입니다:
    <code>CombineSpec</code>의 리스트, 각각은
    <code>source</code>와 플래그 둘. 최상위 함수이지
    <code>FxEvents.combine</code>이 아닙니다 — Dart는 다른
    파일에서 <code>FxEvents</code>에 정적 멤버를 추가할 수
    없습니다.
  </p>
  <p>
    <code>causesEmit: true</code> (기본값)는 이 소스의 이벤트가
    출력을 만들 수 있다는 뜻입니다. 모든
    <code>requireFirst</code> 스펙이 값을 가진 뒤에.
    모두 true인 스펙은
    <code>FxEvents.combineLatestAll</code>입니다.
    <code>causesEmit: false</code>는 이 소스가 컨텍스트뿐이라는
    뜻입니다: 칸은 갱신하지만 스스로는 방출을 일으키지 않습니다
    — 그것이 <code>withLatestFrom</code>입니다.
    <code>requireFirst: true</code> (기본값)는 이 소스가 최소 한
    번 값을 만들기 전까지 모든 방출을 보류하고,
    <code>false</code>는 말할 때까지 칸을 <code>null</code>로
    둡니다. 결과는 모든 소스가 닫혔을 때 닫힙니다.
  </p>
  <p>
    옆에 결합자가 둘 더 있습니다.
    <code>FxEvents&lt;Stream&lt;T&gt;&gt;</code>의
    <code>zipAll</code>은 아우터가 완료될 때까지 모든 내부
    스트림을 모은 뒤 인덱스로 짝짓습니다 — 그때까지 내부는
    구독조차 되지 않습니다.
    <code>withLatestFromAll</code>은 N항
    <code>withLatestFrom</code>입니다: 소스 이벤트마다 다른
    모든 쪽의 최신과 결합하고, 다른 쪽이 모두 말하기 전에 온
    소스 이벤트는 버립니다. fxdart 이벤트 레이어, Rx의
    <code>combineLatest</code> / <code>withLatestFrom</code> /
    <code>zipAll</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 양쪽이 트리거한다</h2>
  {{playground:0}}

  <h2>데모 2 · 컨텍스트만 — causesEmit: false</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 스트림의 스트림에 대한 <code>zipAll</code>, 그리고 소스에 대한 <code>withLatestFromAll</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — 양쪽이 트리거, 모두 true인 CombineSpec ·
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — 한쪽만, causesEmit: false 스펙 ·
    <a href="waitAll.html"><code>waitAll</code></a> — zip, combineLatestAll, concat
  </div>
