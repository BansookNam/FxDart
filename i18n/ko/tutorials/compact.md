---
slug: compact
title: nonNulls — FxDart 101
description: FxDart nonNulls 튜토리얼: null을 걸러 내면서 원소 타입까지 좁혀 주는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>nonNulls</code>
section: 4
crumb: nonNulls
prev: reject.html
prevLabel: reject
next: uniq.html
nextLabel: uniq
---
  <p class="hero-sub">null을 걸러 내는 동시에 원소 타입을 <code>T?</code>에서 <code>T</code>로 좁혀 줍니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>nonNulls</code>는 <code>Iterable&lt;A?&gt;</code>를 받아
    <code>Iterable&lt;A&gt;</code>를 반환합니다 — 모든 <code>null</code>이
    제거되고, 타입 체커도 그 사실을 압니다. 하류에서는 더 이상 null 검사를
    할 필요가 없습니다. <code>nonNulls</code>가 Dart다운 이름이고, fxdart는
    FxTS식 표기인 <code>compact</code>도 함께 받습니다 — 같은 연산자입니다.
    FxTS의 <code>compact</code>는 JS의 falsy 값 여섯 가지(<code>undefined</code>,
    <code>null</code>, <code>0</code>, <code>''</code>, <code>NaN</code>,
    <code>false</code>)를 모두 걸러 냅니다. Dart에는 "falsy"라는 단일 개념이
    없으므로, 이 포팅에서는 <code>null</code>만 제거합니다 — 의도적으로 범위를
    좁혀 동작을 예측하기 쉽게 만든 선택입니다.
  </p>
  <p>
    <a href="pluck.html"><code>pluck</code></a> 뒤나 <code>T?</code>를 반환하는
    조회 뒤에 자주 등장합니다. <code>nonNulls(pluck(key, records))</code> 한 번이면
    nullable이 아닌 깔끔한 리스트를 얻습니다.
  </p>
  <p>
    동기 체인에서 <code>.nonNulls</code>는 <strong><code>Iterable</code>에서
    물려받은 게터</strong>입니다 — 괄호 없이 쓰고
    (<code>fx(xs).nonNulls</code>), 반환값이 평범한
    <code>Iterable&lt;A&gt;</code>이므로 체이닝을 이어 가려면
    <code>fx(...)</code>로 다시 감싸세요. 비동기 게터는 없으므로 비동기
    파이프라인에서는 최상위 <code>nonNullsAsync(...)</code>(또는 FxTS 별칭인
    <code>compactAsync</code>)를 쓰고 <code>fxAsync(...)</code>로 감싸면 됩니다.
  </p>

  <h2>데모 1 · 기본 사용법과 타입 좁히기</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>nonNulls</code>로 <code>answers</code>에서 null을
    제거해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="pluck.html"><code>pluck</code></a> — nullable 값이 자주 나오는 출처 ·
    <a href="reject.html"><code>reject</code></a> — 임의의 술어로 제거 ·
    <a href="../tutorials/compactObject.html"><code>compactObject</code></a> — Map 키 기준의 대응 함수 ·
    <a href="uniq.html"><code>uniq</code></a> — 중복 제거
  </div>
