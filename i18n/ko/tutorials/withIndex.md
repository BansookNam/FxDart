---
slug: withIndex
title: mapWithIndex와 친구들 — FxDart 101
description: FxDart mapWithIndex, filterWithIndex, flatMapWithIndex, foldWithIndex 튜토리얼: 원소의 위치를 두 번째 인자로 받는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>mapWithIndex</code>와 친구들
section: 6
crumb: …WithIndex
prev: zipWithIndex.html
prevLabel: indexed
next: transpose.html
nextLabel: transpose
---
  <p class="hero-sub">인덱스를 아는 네 연산자 — <code>map</code>, <code>filter</code>, <code>flatMap</code>, <code>fold</code>가 원소의 위치를 두 번째 인자로 받습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    위치를 얻는 방법은 이미 있었습니다.
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a>로 원소마다
    인덱스를 짝지은 뒤 그 쌍을 읽으면 됩니다. 쌍 자체가 필요할 때는 그게
    맞는 도구입니다. 그렇지 않을 때는 원소마다 레코드 하나를 치르고,
    콜백 본문을 이름 대신 <code>p.$1</code> / <code>p.$2</code>로 쓰게 됩니다.
  </p>
  <p>
    이 넷은 인덱스를 곧바로 받습니다. 할당할 것도, 꺼낼 것도 없고, 체인이
    하는 일이 그대로 읽힙니다.
  </p>
  <p>
    <strong>인덱스는 그 단계의 입력을 셉니다.</strong> 원본에서의 위치가
    아닙니다 — <a href="filter.html"><code>filter</code></a>가
    <code>mapWithIndex</code> 위에 있으면 살아남은 값들이
    0부터 다시 매겨집니다. 두 번 읽어야 할 쪽은
    <code>filterWithIndex</code>입니다. <em>버리는</em> 원소도 입력이므로
    그만큼 카운트가 올라갑니다. <code>flatMapWithIndex</code>는 내보낸 값이
    아니라 소스 원소를 세므로, 안쪽 이터러블이 다섯 개를 내놓아도 인덱스는
    하나만 올라갑니다.
  </p>
  <p>
    넷 모두 <code>…Async</code> 형태가 있고, 번호는
    <a href="concurrent.html"><code>concurrent</code></a> 아래에서도
    유지됩니다. 상류 pull은 겹쳐 실행되지만 해소는 여전히 순서대로 되므로,
    지연 시간이 어떻든 <em>n</em>번째 원소는 인덱스 <em>n</em>을 받습니다.
    카운터는 이터러블이 아니라 <em>순회</em>마다 살아 있어서, 체인을 다시
    돌리면 0부터 다시 시작합니다.
  </p>
  <p>
    <code>foldWithIndex</code>에는 Dart 쪽 주름이 하나 있습니다. 누산기
    람다에 타입을 적지 않으면 <code>Acc</code>가 <code>Object?</code>로
    추론되어 산술이 컴파일되지 않습니다. 여기서 새로 생긴 문제는 아니고 —
    Dart의 <code>Iterable.fold</code>도 똑같습니다 — 해법도 같습니다.
    <code>foldWithIndex&lt;int&gt;(…)</code>라고 적으면 됩니다.
  </p>

  <h2>데모 1 · mapWithIndex, 그리고 무엇을 대신하는가</h2>
  {{playground:0}}

  <h2>데모 2 · filter, flatMap, fold — 그리고 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 인덱스를 써서 완주자를 1st, 2nd, 3rd로 매겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="zipWithIndex.html"><code>indexed</code></a> — 쌍 자체가 필요할 때의 형태 ·
    <a href="map.html"><code>map</code></a> / <a href="filter.html"><code>filter</code></a> / <a href="flatMap.html"><code>flatMap</code></a> — 이들이 확장하는 연산자 ·
    <a href="fold.html"><code>fold</code></a> — 씨앗을 주는 축약 ·
    <a href="foldRight.html"><code>foldRight</code></a> — 같은 fold를 반대쪽에서
  </div>
