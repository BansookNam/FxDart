---
slug: chunk
title: chunk — FxDart 101
description: FxDart chunk 튜토리얼 — 지연 이터러블을 고정 크기 리스트로 묶어 배치 처리합니다. 라이브 플레이그라운드 포함.
heading: <code>chunk</code>
section: 5
crumb: chunk
prev: slice.html
prevLabel: slice
next: split.html
nextLabel: split
---
  <p class="hero-sub">각각 최대 <code>size</code>개의 연속된 원소를 담은 리스트들의 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>chunk</code>는 평평한 시퀀스를 고정 크기 그룹으로 묶습니다 —
    카드를 패로 나누거나, 결과 집합을 페이지로 자르거나, 하위 API에
    <code>n</code>개씩 묶어 작업을 보내는 식입니다. 리스트를 하나 내보내기
    전에 딱 <code>size</code>개만 버퍼링하므로, 아주 큰 소스에서도
    지연 평가와 제한된 메모리 사용을 유지합니다. 소스가 딱 나누어떨어지지
    않는 경우, 개수가 모자랄 수 있는 것은 마지막 청크뿐입니다.
  </p>
  <p>
    비동기 버전인 <code>chunkAsync</code>는 청크 하나를 만들기 전에
    <code>size</code>개를 await합니다 — 상류에
    <code>.concurrent(n)</code>을 함께 쓰면 청크 하나 분량의 비동기 작업을
    동시에 처리할 수 있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>10개를 3씩 묶으면 마지막 청크가 짧게 남습니다.</p>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 카드를 3장씩 패로 나눠 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="slice.html"><code>slice</code></a> — 반복 배치 대신 임의의 구간 하나 ·
    <a href="split.html"><code>split</code></a> — 고정 크기 대신 구분자 기준으로 묶기 ·
    <a href="transpose.html"><code>transpose</code></a> — 이미 청크로 나뉜 데이터의 행과 열 뒤집기
  </div>
