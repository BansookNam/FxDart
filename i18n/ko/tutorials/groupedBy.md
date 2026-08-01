---
slug: groupedBy
title: groupedBy — FxDart 101
description: FxDart groupedBy 튜토리얼 — 그룹을 체이닝 가능한 (key, items) 레코드로 받아 Map.entries 재진입 없이 그룹별 집계를 잇습니다. 라이브 플레이그라운드 포함.
heading: <code>groupedBy</code>
section: 7
crumb: groupedBy
prev: groupBy.html
prevLabel: groupBy
next: indexBy.html
nextLabel: indexBy
---
  <p class="hero-sub">그룹을 체이닝 가능한 <code>(key, items)</code> 레코드로 — 파이프라인을 떠나지 않고 그룹별 집계를 잇습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="groupBy.html">groupBy</a></code>는 터미널입니다.
    <code>Map</code>을 건네주는 순간 체인이 끝나고, "그룹별 합계를 내서
    정렬하고 상위 3개"를 원하는 순간 <code>kv.key</code> /
    <code>kv.value</code> 격식을 갖춰 <code>fx(map.entries)</code>로
    파이프라인에 재진입하게 됩니다. <code>groupedBy</code>는 같은 그룹핑을
    <strong>체이닝 가능한 뷰</strong>로 제공합니다. 각 그룹은 이름 있는
    레코드 <code>(key:&nbsp;…, items:&nbsp;…)</code>이므로 그룹별 집계,
    정렬, take가 바로 그 체인에서 이어지고 — 하류 코드는 위치 기반
    <code>$1</code> / <code>$2</code> 대신 <code>g.key</code> /
    <code>g.items</code>로 읽힙니다.
  </p>
  <p>
    그룹은 <code>groupBy</code>의 맵이 순회되는 것과 똑같이
    <strong>키를 처음 만난 순서</strong>로 나옵니다.
    <code><a href="sortBy.html">sortBy</a></code>처럼 첫 그룹을 내놓기
    전에 모든 값을 봐야 하므로 그룹핑 자체는 즉시 평가되고, 그 주변의
    체인은 계속 합성 가능합니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다(FxTS에는 대응물이 없습니다) — 키로
    조회할 맵이 필요하면 <code>groupBy</code>를, 그룹이 더 긴 파이프라인의
    중간 단계일 뿐이라면 <code>groupedBy</code>를 잡으세요.
  </p>

  <h2>데모 1 · 그룹 → 집계 → 순위, 체인 하나로</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>Map.entries</code>를 건드리지 않고 지출 1위 카테고리를 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — 같은 그룹핑을 키 있는 <code>Map</code>으로 ·
    <a href="countBy.html"><code>countBy</code></a> — 유일한 집계가 개수일 때 ·
    <a href="sortByDesc.html"><code>sortByDesc</code></a> — 순위 매기기의 자연스러운 다음 단계
  </div>
