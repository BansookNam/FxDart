---
slug: maxBy
title: maxBy — FxDart 101
description: FxDart maxBy 튜토리얼 — 키가 가장 큰 원소를 단 한 번의 순회로 찾습니다. 정렬 없이, 비어 있으면 null. 라이브 플레이그라운드 포함.
heading: <code>maxBy</code>
section: 7
crumb: maxBy
prev: max.html
prevLabel: max
next: minBy.html
nextLabel: minBy
---
  <p class="hero-sub">키가 가장 큰 원소 — 한 번의 순회, 정렬 없이, 비어 있으면 <code>null</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>maxBy</code>는 "어떤 <em>원소</em>가 가장 큰 키를 갖는가?"에
    답합니다 — "가장 큰 숫자가 무엇인가?"가 아닙니다(그건
    <code><a href="max.html">max</a></code>입니다). 파이프라인을
    <strong>한 번</strong> 순회하면서 현재까지의 최선 원소를 유지하므로
    O(n)입니다. 반면 솔깃한 <code>sortBy(key).head()</code> 형태는
    O(n&nbsp;log&nbsp;n)을 치르고, 결코 필요하지도 않은 정렬된 리스트를
    실체화합니다.
  </p>
  <p>
    키는 <code><a href="sortBy.html">sortBy</a></code>가 비교하는
    방식(<code>Comparable.compare</code>)과 정확히 동일하게 비교되며,
    동점일 때는 먼저 만난 <strong>첫</strong> 원소가 이깁니다 — 그래서
    날짜순으로 정렬된 리스트에 <code>maxBy</code>를 적용하면 가장 큰
    값들 중 가장 이른 것을 얻습니다.
  </p>
  <p>
    빈 입력은 <code><a href="head.html">head</a></code>,
    <code><a href="last.html">last</a></code>처럼 <code>null</code>을
    반환합니다 — 여기서는 Dart의 널 허용 타입이 FxTS의
    <code>undefined</code>를 대신합니다. 이것은 Dart 고유의 추가
    기능이며(FxTS는 숫자용 <code>max</code>만 제공합니다), 이름은
    Kotlin의 <code>maxByOrNull</code> 형태를 따릅니다.
  </p>

  <h2>데모 1 · 기본 사용법, 빈 경우 &amp; 동점</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <strong>정렬 없이</strong> 가장 큰 지출을 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="minBy.html"><code>minBy</code></a> — 거울상 ·
    <a href="max.html"><code>max</code></a> — 원소가 아니라 키 자체가 필요할 때 ·
    <a href="sortBy.html"><code>sortBy</code></a> — 어차피 전체 정렬이 필요할 때
  </div>
