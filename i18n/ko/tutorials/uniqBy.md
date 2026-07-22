---
slug: uniqBy
title: uniqBy — FxDart 101
description: FxDart uniqBy 튜토리얼: 계산된 키를 기준으로 중복을 제거하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>distinctBy</code>
section: 4
crumb: distinctBy
prev: uniq.html
prevLabel: uniq
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">값의 동등성이 아니라 키 함수가 정하는 기준으로 중복을 제거합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>uniqBy</code>는 <code>uniq</code>의 일반화된 형태입니다. 원소 전체를
    비교하는 대신 각 원소를 <code>f</code>에 통과시켜, 서로 다른 키마다 그
    키를 처음 만들어 낸 원소만 남깁니다. "고객당 한 행", "타입당 이벤트 하나"
    같은 요구나 임의의 필드 또는 계산된 값으로 중복을 없앨 때 쓰는 도구이며,
    <code>uniq</code> 자체도 결국 <code>uniqBy((a) =&gt; a, iterable)</code>일
    뿐입니다.
  </p>
  <p>
    <code>uniq</code>와 마찬가지로 지연 평가되고 순서를 보존합니다. 각 키에
    대해 가장 먼저 등장한 원소가 살아남고, 이미 본 키를 담는 내부
    <code>Set&lt;B&gt;</code>는 값을 끌어당길 때마다 조금씩 커집니다.
  </p>
  <p>
    비동기 규칙도 <code>uniq</code>와 같습니다. 동시성은 상류의
    fetch(<code>.map(...).concurrent(n)</code>)에 두고, 이미 해소되어 순서가
    정해진 스트림에 <code>uniqBy</code>/<code>uniqByAsync</code>를
    적용하세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 상류의 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>uniqBy</code>로 각 <code>'type'</code>의 첫 이벤트만
    남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="uniq.html"><code>uniq</code></a> — 값의 동등성으로 중복 제거 ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — 계산된 키로 다른 이터러블과 비교해 제거 ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — 계산된 키로 다른 이터러블과 공유되는 것만 남기기 ·
    <a href="../tutorials/groupBy.html"><code>groupBy</code></a> — 원소를 모두 남기고 키별로 묶기
  </div>
