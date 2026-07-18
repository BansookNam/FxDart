---
slug: partition
title: partition — FxDart 101
description: FxDart partition 튜토리얼: 술어를 기준으로 파이프라인을 (통과, 탈락) 레코드로 나눕니다. 라이브 플레이그라운드 포함.
heading: <code>partition</code>
section: 7
crumb: partition
prev: sortBy.html
prevLabel: sortBy
next: head.html
nextLabel: head
---
  <p class="hero-sub">술어 하나로 파이프라인을 두 개의 리스트로 한 번에 나눕니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>partition</code>은 파이프라인을 한 번만 순회하면서 술어를
    기준으로 모든 원소를 두 리스트 중 하나에 넣는 종결 연산자입니다.
    술어가 <code>true</code>를 반환한 원소는 첫 번째 리스트로, 나머지는
    두 번째 리스트로 갑니다.
    <code><a href="filter.html">filter</a></code>와
    <code><a href="reject.html">reject</a></code>를 따로 호출하는 것과
    같지만, 데이터를 한 번만 훑는다는 점이 다릅니다.
  </p>
  <p>
    FxTS는 두 개짜리 튜플 <code>[pass, fail]</code>을 반환합니다. Dart에는
    JS 배열 같은 튜플 타입이 없으므로 FxDart는 네이티브 Dart
    <strong>레코드</strong>를 씁니다: <code>(List&lt;A&gt;, List&lt;A&gt;)</code>.
    두 리스트는 <code>.$1</code>(통과)과 <code>.$2</code>(탈락)로 꺼내거나,
    패턴 매칭 문법으로 바로 구조 분해할 수 있습니다:
    <code>final (pass, fail) = partition(f, iterable);</code>. 이는 FxDart의
    다른 곳에서 <code><a href="zip.html">zip</a></code>과
    <code><a href="entries.html">entries</a></code>가 따르는 튜플-레코드
    규약과 동일합니다.
  </p>
  <p>
    이 섹션의 다른 종결 연산자와 마찬가지로, 상류의 지연 파이프라인
    전체를 끌어당깁니다. 동기든 비동기든 마찬가지입니다.
  </p>

  <h2>데모 1 · 기본과 구조 분해</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 점수를 <strong>합격</strong>(&gt;= 60)과 <strong>불합격</strong>(&lt; 60)으로 나눠 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="filter.html"><code>filter</code></a> · <a href="reject.html"><code>reject</code></a> — partition이 합쳐 놓은 두 갈래 ·
    <a href="groupBy.html"><code>groupBy</code></a> — 셋 이상의 그룹으로 묶기 ·
    <a href="sort.html"><code>sort</code></a> — 필요하다면 각 갈래 안에서 정렬하기
  </div>
