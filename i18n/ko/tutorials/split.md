---
slug: split
title: split — FxDart 101
description: FxDart split 튜토리얼 — 문자 이터러블을 구분자 기준으로 나눕니다. 라이브 플레이그라운드 포함.
heading: <code>split</code>
section: 5
crumb: split
prev: chunk.html
prevLabel: chunk
next: append.html
nextLabel: append
---
  <p class="hero-sub">한 글자짜리 문자열들의 이터러블을 구분자 문자 기준으로 나눕니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>split</code>은 FxTS의 문자 단위 <code>split</code>을 그대로
    옮긴 것이고, 그 사실이 시그니처에 드러납니다. 이 함수는
    <code>String</code>을 아예 받지 않습니다 — 한 글자짜리 문자열들의
    <code>Iterable&lt;String&gt;</code>을 받아 한 글자씩 훑으면서,
    <code>sep</code>과 같은 문자를 만날 때까지 조각을 모읍니다. Dart에서
    그런 문자 이터러블을 얻는 관용적인 방법은
    <code>myString.split('')</code>입니다(Dart 자체의
    <code>String.split</code>에 빈 패턴을 주면 문자열이 개별 문자로
    쪼개집니다).
  </p>
  <p>
    끝에 구분자가 오면 출력 끝에 빈 문자열이 하나 생기는데, 이는
    FxTS의 동작과 같습니다 — <code>'a,b,'</code>는
    <code>('a', 'b')</code>가 아니라 <code>('a', 'b', '')</code>로
    나뉩니다. <code>split</code>에는 <code>Fx</code> 체인 형태가 없으니
    최상위 함수(또는 <code>splitAsync</code>)를 직접 호출하세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>split</code>으로 <code>csv</code>를 <code>'|'</code> 기준으로
    나눠 색 이름들을 뽑아내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="chunk.html"><code>chunk</code></a> — 구분자 대신 고정 크기로 묶기 ·
    <a href="unicodeToArray.html"><code>unicodeToArray</code></a> — 사람이 인식하는 문자 단위로 제대로 된 문자 배열 얻기 ·
    <a href="join.html"><code>join</code></a> — 반대 연산
  </div>
