---
slug: shareReplay
title: shareReplay — FxDart 101
description: FxDart shareReplay 튜토리얼: ReplayValue와 CompletionValue, 그리고 늦은 리스너가 이력을 보게 하는 connectable shareReplay — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>shareReplay</code>, <code>ReplayValue</code> &amp; <code>CompletionValue</code>
section: 14
crumb: shareReplay
prev: share.html
prevLabel: share
next: liveValue.html
nextLabel: LiveValue
---
  <p class="hero-sub">기억하는 멀티캐스트: 유계 재생 버퍼, 닫힐 때의 마지막 값, 그리고 소스를 둘 다로 감싸는 체인 연산자.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="share.html">share</a></code>는 한 번의 실행을 여러
    리스너에게 방송한 뒤 잊습니다. 이벤트가 지나간 뒤에 도착한
    리스너는 놓친 것입니다. <code>ReplayValue</code>는 기억하는
    서브젝트입니다: <code>add</code>는 <code>size</code>(기본값 1,
    <code>null</code>은 무한)와 <code>maxAge</code>로 잘린 버퍼에
    덧붙이고, 모든 <strong>늦은 구독자는 보관된 버퍼를 먼저
    재생받은</strong> 다음 라이브 갱신에 올라탑니다. 에러는 보관되지
    않습니다. <code>close</code> 뒤에도 늦은 리스너는 버퍼를 받은
    다음 종료됩니다. fxdart 이벤트 레이어, Rx의
    <code>ReplaySubject</code>를 따랐습니다.
  </p>
  <p>
    <code>CompletionValue</code>는 다른 기억입니다:
    <code>add</code>는 기억만 하고, 마지막 값은
    <strong>닫힐 때</strong> 나옵니다 — 열려 있는 동안은 아무것도,
    그다음 그 값과 종료. 닫힌 뒤의 늦은 리스너도 같습니다.
    <code>addError</code>는 기억된 값이 아니라 에러로 즉시
    완료합니다. Rx의 <code>AsyncSubject</code>입니다. 다음 쪽의
    <code><a href="liveValue.html">LiveValue</a></code>는 동기
    <code>.value</code> 읽기를 가진 현재-값 서브젝트입니다 —
    getter가 없는 size 1의 ReplayValue입니다.
  </p>
  <p>
    <code>connectable()</code>은 수동 형태입니다:
    <code>ConnectableEvents</code>를 돌려주고, 그
    <code>events</code> 피드는 <code>connect()</code> 전까지 소스를
    구독하지 않습니다. 그 전에 붙인 리스너는 기다리고, 늦은
    리스너는 이미 나간 값을 놓칩니다. <code>refCount()</code>는 첫
    리스너에서 연결하고 마지막에서 끊으며, 소스가 두 번째 리슨을
    허용하면 다시 연결합니다. <code>shareReplay</code>가 흔한
    표기입니다: <code>ReplayValue</code>를 통한 멀티캐스트, 첫
    리스너에서 연결, 늦은 리스너는 이력을 봅니다.
    <code>resetOnCancel</code>(기본값 <code>true</code>)는 마지막
    리스너가 떠나면 새 버퍼를 시작하고,
    <code>false</code>는 소스를 영영 연결해 둡니다.
  </p>
  <p>
    fxdart 이벤트 레이어, Rx의 <code>ReplaySubject</code>,
    <code>AsyncSubject</code>, <code>ConnectableObservable</code>,
    그리고 <code>shareReplay</code>를 따랐습니다.
  </p>

  <h2>데모 1 · 늦은 구독자가 버퍼를 본다</h2>
  {{playground:0}}

  <h2>데모 2 · CompletionValue는 닫힐 때 내보낸다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>fromIterable</code> 위의 <code>shareReplay</code>, 리스너 둘.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="share.html"><code>share</code></a> — 기억 없는 멀티캐스트; 늦은 리스너는 이미 지나간 것을 놓침 ·
    <a href="liveValue.html"><code>LiveValue</code></a> — 동기 <code>.value</code>를 가진 현재-값 서브젝트 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — 이 서브젝트들의 <code>.live</code>가 그 체인
  </div>
