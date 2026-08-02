---
slug: combineLatest
title: combineLatest — FxDart 101
description: FxDart combineLatest 튜토리얼: 두 스트림 중 어느 쪽에서든 이벤트가 올 때마다 양쪽 최신 값을 결합하기 — 폼 검증식 파생 상태 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>combineLatest</code>
section: 14
crumb: combineLatest
prev: sampleOn.html
prevLabel: sampleOn
next: withLatestFrom.html
nextLabel: withLatestFrom
---
  <p class="hero-sub">어느 쪽에서든 이벤트가 올 때마다 양쪽 최신 값의 <code>combine</code> 결과를 내보냅니다 — 양쪽 모두 최소 한 번씩 말한 뒤부터.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    폼은 <em>현재</em> 사용자 이름과 <em>현재</em> 비밀번호가 둘 다
    통과할 때 유효합니다 — 독립적으로 타이핑되는 두 스트림, 그리고 어느
    쪽에서든 키 입력이 있을 때마다 옳아야 하는 하나의 파생 상태.
    <code>combineLatest(other, combine)</code>이 바로 그 모양입니다: 각
    쪽의 최신 값을 기억해 두고, <em>어느 쪽</em> 스트림에서든 이벤트가
    올 때마다 신선한 쌍에 대해 <code>combine</code>을 다시 실행합니다.
  </p>
  <p>
    규칙을 정확히 짚으면 이렇습니다. <strong>양쪽</strong> 모두 최소 한
    번씩 값을 만들어 내기 전에는 아무것도 내보내지 않습니다 — 반쪽만
    초기화된 쌍은 없습니다. 그 이후로는 이벤트 하나가 들어오면 정확히
    이벤트 하나가 나갑니다. 그리고 닫힌 쪽은 갱신을 멈추지만 그 마지막
    값은 계속 유효합니다: 결과는 <strong>양쪽</strong>이 모두 닫혔을
    때에만 닫힙니다.
  </p>
  <p>
    결합자는 <em>누가 트리거하는가</em>로 고르세요. 어느 쪽의 갱신이든
    상태를 다시 파생시켜야 한다면 이 연산자입니다. <em>소스</em>의
    이벤트만 발화해야 하고 — 다른 스트림은 최신 값만 참조되는 존재라면
    — 그것은
    <code><a href="withLatestFrom.html">withLatestFrom</a></code>입니다.
    pull 세계의 <code><a href="zip.html">zip</a></code>과 대비해 보세요.
    zip은 <em>n</em>번째와 <em>n</em>번째를 짝짓지만,
    <code>combineLatest</code>는 최신과 최신을 짝짓고 인덱스가 맞아
    떨어지기를 기다리지 않습니다. fxdart 이벤트 계층이며, Rx의 같은 이름
    연산자를 따랐습니다.
  </p>

  <h2>데모 1 · 두 필드로부터의 폼 검증</h2>
  {{playground:0}}

  <h2>데모 2 · 닫힌 쪽도 마지막 말은 남긴다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 두 센서로부터 하나의 표시 상태 만들기.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — 한쪽만: 소스 이벤트만 내보냄 ·
    <a href="zip.html"><code>zip</code></a> — pull 세계의 인덱스 정렬 짝짓기 ·
    <a href="liveValue.html"><code>LiveValue</code></a> — 필요한 것이 현재 값 그 자체일 때
  </div>
