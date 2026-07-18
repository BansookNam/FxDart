---
slug: groupBy
title: groupBy — FxDart 101
description: FxDart groupBy 튜토리얼: 계산된 키를 기준으로 모든 원소를 Map of List 형태의 버킷에 담는 방법을 라이브 플레이그라운드와 함께 배웁니다.
heading: <code>groupBy</code>
section: 7
crumb: groupBy
prev: join.html
prevLabel: join
next: indexBy.html
nextLabel: indexBy
---
  <p class="hero-sub">계산된 키를 기준으로 모든 원소를 <code>Map&lt;K, List&lt;A&gt;&gt;</code>에 나눠 담습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>groupBy</code>는 파이프라인 전체를 끌어당긴 뒤, <code>f</code>가
    각 값에 대해 반환한 키를 기준으로 값을 버킷에 나눠 담는 종결
    연산자입니다. <code><a href="filter.html">filter</a></code>와 달리 모든
    원소가 그대로 유지되며 — 버려지는 것은 하나도 없고 — 단지 버킷 단위로
    재배치될 뿐입니다.
  </p>
  <p>
    FxTS 버전은 평범한 JS 객체를 반환하지만, Dart에는 임의의 계산된 키를
    갖는 익명 객체 리터럴이 없기 때문에 FxDart는 대신
    <code>Map&lt;K, List&lt;A&gt;&gt;</code>를 반환합니다. 이 섹션 전반에서
    쓰이는 TS 객체 → Dart Map 변환 방식 중 하나입니다
    (<code><a href="indexBy.html">indexBy</a></code>와
    <code><a href="countBy.html">countBy</a></code>도 마찬가지입니다).
  </p>
  <p>
    버킷 안에서의 순서도 의미가 있습니다. 원소는 소스에 등장한 상대 순서
    그대로 각 리스트에 들어갑니다. 그리고 종결 연산자이므로, 상류
    파이프라인이 평범한 리스트든 지연 평가되는
    <code>map</code>/<code>filter</code> 단계의 체인이든 동작은 완전히
    동일합니다 — <code>groupBy</code>가 값을 끌어당기는 그 시점에 비용을
    한 번 치를 뿐입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 단어들을 <strong>길이별로</strong> 그룹화해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="indexBy.html"><code>indexBy</code></a> — 리스트 대신 키마다 값 하나만 담습니다 ·
    <a href="countBy.html"><code>countBy</code></a> — 원소를 모으는 대신 키별 개수를 셉니다 ·
    <a href="partition.html"><code>partition</code></a> — 정확히 두 개의 버킷으로 나눕니다
  </div>
