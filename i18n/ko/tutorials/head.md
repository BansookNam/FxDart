---
slug: head
title: head — FxDart 101
description: FxDart head 튜토리얼: 예외를 던지는 대신 null을 반환하며 이터러블의 첫 원소를 안전하게 가져오는 방법을 라이브 플레이그라운드와 함께 배웁니다.
heading: <code>firstOrNull</code>
section: 8
crumb: firstOrNull
prev: partition.html
prevLabel: partition
next: last.html
nextLabel: last
---
  <p class="hero-sub">이터러블의 첫 원소를 반환하며, 비어 있으면 <code>null</code>을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>head</code>는 이터러블의 맨 앞에서 원소를 정확히 하나만 끌어와
    돌려줍니다 — 원소가 없다면 <code>null</code>입니다. 빈 배열에
    <code>undefined</code>를 반환하는 FxTS의 <code>head</code>에 대한
    FxDart의 답이라 할 수 있습니다. Dart에는 <code>undefined</code>가 없기
    때문에, API의 이 영역에서 "없을 수도 있는" 결과는 전부
    <code>null</code>로 수렴합니다. 따라서 자연스러운 사용 방식은
    <code>head(list) ?? fallback</code>입니다.
  </p>
  <p>
    <code>head</code>는 <code>moveNext()</code>를 한 번만 호출하므로,
    아주 크거나 심지어 무한한 지연 파이프라인 위에서 호출해도 비용이 거의
    들지 않습니다. 필요한 원소 하나를 넘어서는 상류 작업은 전혀 실행되지
    않습니다.
  </p>
  <p>
    data-first 형태(<code>head(iterable)</code>),
    <code>FxAsyncIterable</code>을 위한 비동기 형태, 그리고 동기와 비동기
    체인 양쪽의 체인 메서드(<code>fx(iterable).head()</code>)로 제공됩니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>빈 값이 들어가면 <code>null</code>이 나옵니다 — 예외도, <code>orElse</code> 콜백도 필요 없습니다.</p>
  {{playground:0}}

  <h2>데모 2 · 지연 평가와 비동기 단축 평가</h2>
  <p>
    아래의 100만 개짜리 범위에서도 끌어당겨지는 원소는 단 하나뿐입니다.
    비동기 예제에서는 체인이 <em>첫 번째</em> <code>delay(...)</code>만
    기다리고 두 번째는 거들떠보지도 않습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>head</code>를 사용해 첫 번째 점수를 출력하되, 리스트가
    비어 있으면 <code>0</code>이 출력되게 해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="last.html"><code>last</code></a> — 반대쪽 끝에서 같은 일을 합니다 ·
    <a href="nth.html"><code>nth</code></a> — 임의의 인덱스를 가져옵니다 ·
    <a href="find.html"><code>find</code></a> — 술어에 처음 부합하는 원소를 찾습니다 ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — 값 기반으로 비어 있는지 확인합니다
  </div>
