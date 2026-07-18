---
slug: join
title: join — FxDart 101
description: FxDart join 튜토리얼 — 파이프라인의 원소들을 하나의 문자열로 이어 붙이는 data-first 종결 연산자를 라이브 플레이그라운드로 익혀 봅니다.
heading: <code>join</code>
section: 7
crumb: join
prev: size.html
prevLabel: size
next: groupBy.html
nextLabel: groupBy
---
  <p class="hero-sub">모든 원소를 구분자로 이어 붙여 하나의 문자열로 만듭니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>join</code>은 종결 연산자입니다. 파이프라인 전체를 끌어당기면서
    각 원소에 <code>toString()</code>을 호출하고, 그 결과들을 사이사이
    <code>sep</code>을 넣어 이어 붙입니다.
  </p>
  <p>
    인자 순서에 주의하세요. 최상위의 data-first <code>join</code>은
    <strong>구분자를 먼저</strong> 받습니다: <code>join(', ', iterable)</code>.
    이는 FxTS의 관례(어디서나 data-first)를 따른 것으로, 이터러블을 수신자로
    받고 구분자를 유일한 인자로 받는 Dart 자체의
    <code>Iterable.join(separator)</code> 메서드와는 정반대입니다.
  </p>
  <p>
    이 차이는 체인 형태에도 미묘하게 스며듭니다. <strong>동기</strong>
    체인에서 <code>.join(...)</code>은 그냥 Dart 내장
    <code>Iterable.join</code>이고, 인자를 생략하면 기본 구분자가
    <code>''</code>(빈 문자열)입니다. 반면 <code>FxAsync.join</code>은
    FxDart에서 직접 구현했고 기본 구분자가 <code>','</code>입니다 —
    FxTS의 기본값을 그대로 따른 것입니다. 인자를 생략했을 때 두 체인이
    똑같이 동작하리라고 가정하지 마세요.
  </p>

  <h2>데모 1 · 기본 사용법과 두 가지 기본값</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 서로 다른 기본값</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 컬럼들을 <code>','</code>로 이어 붙여 하나의 CSV 헤더 행으로 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="sort.html"><code>sort</code></a> — 이어 붙이기 전에 원소 정렬하기 ·
    <a href="map.html"><code>map</code></a> — 이어 붙이기 전에 각 원소 포맷하기 ·
    <a href="size.html"><code>size</code></a> — 또 하나의 간단한 문자열·개수 종결 연산자
  </div>
