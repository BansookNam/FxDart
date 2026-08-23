---
slug: groupsBy
title: groupsBy — FxDart 101
description: FxDart groupsBy 튜토리얼: 키가 열릴 때마다 살아 있는 GroupedEvents — 키와 이벤트 스트림 — lastFor로 그룹을 닫기까지 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>groupsBy</code>
section: 14
crumb: groupsBy
prev: windowOn.html
prevLabel: windowOn
next: spaceBy.html
nextLabel: spaceBy
---
  <p class="hero-sub">열리는 대로의 살아 있는 그룹: 키, 그리고 그 키를 공유하는 이후 값의 내부 스트림.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    풀 레이어의 <code><a href="groupBy.html">groupBy</a></code>는
    터미널입니다: 전부를 당기고 <code>Map</code>을 건넵니다.
    <code>groupsBy</code>는 살아 있는 버전입니다. 각 키의 첫 값이
    <code>GroupedEvents</code>를 내보냅니다 — 그 <code>key</code>와
    내부 <code>events</code> 스트림의 레코드 — 그리고 같은 키의 이후
    값은 그 내부로 전달됩니다. 그룹은 소스가 닫힌 뒤가 아니라, 열리는
    대로 <strong>처음 본 키 순서</strong>로 나타납니다.
  </p>
  <p>
    그것은 중첩된 <code>FxEvents</code> 아이디어로
    <code><a href="windowOn.html">window*</a></code>와 같고, 시간이
    아니라 값으로 키를 답니다. 위젯은 그룹이 나타나는 순간 그 내부에
    구독해 이후 값이 도착하는 대로 볼 수 있고, 묶음을 기다릴 필요가
    없습니다.
  </p>
  <p>
    <code>lastFor</code>가 있으면, <code>lastFor(key)</code>의 첫
    이벤트(또는 완료)가 <strong>그 그룹을 완료</strong>합니다. 같은
    키의 이후 값은 새 그룹을 엽니다 — 사용자마다의 유휴 타임아웃,
    방마다의 "세션 종료" 신호. <code>lastFor</code>가 없으면 그룹은
    소스가 완료될 때까지 (또는 에러가 날 때까지 — 살아 있는 그룹마다
    에러를 낸 뒤 바깥에) 열려 있습니다.
  </p>
  <p>
    바깥을 취소하면 살아 있는 그룹은 조용히 완료됩니다. window 가족이
    따르는 것과 같은 RxJS 9 규칙입니다. fxdart 이벤트 레이어, Rx의
    <code>groupBy</code>를 따랐습니다.
  </p>

  <h2>데모 1 · 열리는 대로의 그룹</h2>
  {{playground:0}}

  <h2>데모 2 · lastFor로 그룹 닫기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: SKU를 부서 접두사로 묶기.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — 풀 레이어에서 키 달린 <code>Map</code>으로의 같은 묶기 ·
    <a href="groupedBy.html"><code>groupedBy</code></a> — 풀 레이어 그룹을 체인 가능한 <code>(key, items)</code> 레코드로 ·
    <a href="windowOn.html"><code>window*</code></a> — 개수, 트리거, 시계로 회전하는 살아 있는 내부
  </div>
