---
slug: nth
title: nth — FxDart 101
description: FxDart nth 튜토리얼: 특정 인덱스의 원소를 안전하게 꺼내고 범위를 벗어나면 null을 얻는 방법을 라이브 플레이그라운드와 함께 알아봅니다.
heading: <code>elementAtOrNull</code>
section: 8
crumb: elementAtOrNull
prev: last.html
prevLabel: last
next: find.html
nextLabel: find
---
  <p class="hero-sub">주어진 인덱스의 원소를 반환하고, 인덱스가 범위를 벗어나면 <code>null</code>을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>nth</code>는 이터러블을 순회하다가 <code>index</code>에 도달하는 즉시
    멈추므로, 언제나 <code>index + 1</code>개만 꺼냅니다 — 거대한 지연
    시퀀스에서도 저렴하고, 인덱싱 한 번 하자고 전체를 <code>List</code>로
    구체화하는 것보다 훨씬 저렴합니다. 음수 인덱스나 끝을 넘어선 인덱스는
    그냥 <code>null</code>을 내놓습니다. 일부 언어의 배열 인덱싱과 달리 여기에는
    끝에서부터 되감는 동작이 없습니다 — 인덱스는 유효한 음이 아닌 위치여야 합니다.
  </p>
  <p>
    <code>nth</code>에는 체인 메서드가 없습니다 — 최상위 함수(또는 그 비동기
    쌍둥이)를 임의의 <code>Iterable</code>이나 <code>Fx</code> 체인에 직접
    호출하세요. <code>Fx</code>는 <em>그 자체가</em> <code>Iterable</code>이기 때문입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 지연 평가 &amp; 비동기</h2>
  <p>인덱스 3을 가져올 때 100만 개짜리 범위에서 단 4개만 꺼내 온다는 사실을 <code>peek</code> 카운터로 확인합니다.</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>nth</code>로 은메달리스트(인덱스 1)를 출력하거나, 없으면 <code>'unclaimed'</code>를 출력해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="head.html"><code>head</code></a> — <code>nth(0, ...)</code>의 축약형 ·
    <a href="last.html"><code>last</code></a> — 마지막 원소 ·
    <a href="find.html"><code>find</code></a> — 인덱스 대신 술어로 찾기 ·
    <a href="slice.html"><code>slice</code></a> — 구간 전체를 꺼내기
  </div>
