---
slug: sortByDesc
title: sortByDesc — FxDart 101
description: FxDart sortByDesc 튜토리얼 — 비교 가능한 어떤 키든 내림차순으로 정렬합니다. 숫자 부호 반전 트릭 없이. 라이브 플레이그라운드 포함.
heading: <code>sortByDesc</code>
section: 7
crumb: sortByDesc
prev: sortBy.html
prevLabel: sortBy
next: partition.html
nextLabel: partition
---
  <p class="hero-sub">비교 가능한 어떤 키든 내림차순으로 — 부호 반전 트릭은 은퇴했습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    순위표는 가장 큰 값이 먼저 오길 원하는데, 지금까지 유일한 한 줄짜리
    해법은 <code>sortBy((a)&nbsp;=&gt;&nbsp;-key)</code>였습니다 —
    <em>숫자에만</em> 통하는 트릭이죠. 날짜, 문자열, 그 밖의 모든
    <code>Comparable</code>에는 마이너스 부호가 없습니다.
    <code>sortByDesc</code>는 비교 방향만 뒤집은
    <code><a href="sortBy.html">sortBy</a></code>입니다. 같은 키 추출(키는
    원소당 정확히 한 번 계산), <code>double</code>/<code>int</code>/<code>String</code>
    키에 대한 같은 언박싱 고속 경로, 입력을 절대 변형하지 않는 같은
    계약을 공유합니다.
  </p>
  <p>
    이 연산자가 대체하는 고전적인 형태가 "상위 N" 순위입니다.
    <code>sortByDesc(key).take(n)</code>은 쓰인 그대로 읽히는 반면,
    오름차순 표기는 부호 반전<em>과</em> 그것을 설명하는 주석까지
    필요했습니다. 날짜의 "최신순"에는 이것이 유일한 직접적인 표기법입니다.
  </p>
  <p>
    Dart 고유의 추가 기능입니다 — 이름은 Kotlin의
    <code>sortedByDescending</code>을 따릅니다. 전체 순서가 아니라 가장 큰
    원소 하나만 필요하다면 정렬을 통째로 건너뛰세요.
    <code><a href="maxBy.html">maxBy</a></code>가 O(n)입니다.
  </p>

  <h2>데모 1 · 부호 반전 없는 순위</h2>
  {{playground:0}}

  <h2>데모 2 · 숫자로 흉내 낼 수 없는 키</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 아무것도 반전하지 않고 최신순으로 정렬해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="sortBy.html"><code>sortBy</code></a> — 오름차순 쌍둥이 ·
    <a href="maxBy.html"><code>maxBy</code></a> — 최상위 원소만 필요할 때 한 번의 순회 ·
    <a href="take.html"><code>take</code></a> — 모든 "상위 N"의 나머지 절반
  </div>
