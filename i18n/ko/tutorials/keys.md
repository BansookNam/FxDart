---
slug: keys
title: keys — FxDart 101
description: FxDart keys 튜토리얼: Map의 키를 체인에 바로 흘려보낼 수 있는 지연 Iterable로 얻습니다.
heading: <code>keys</code>
section: 2
crumb: keys
prev: entries.html
prevLabel: entries
next: values.html
nextLabel: values
---
  <p class="hero-sub">Map의 키를 평범한 지연 Iterable로 — fx()로 감싸 바로 체이닝할 수 있습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>keys(map)</code>은 Dart의 <code>map.keys</code>를 FxTS 스타일로
    얇게 감싼 것입니다 — 객체 관련 함수 어휘(<code>entries</code>,
    <code>keys</code>, <code>values</code>)를 일관되게 읽히도록 하고
    <code>fx()</code>에 자연스럽게 끼워 넣기 위해 존재하죠. Dart의
    <code>Map.keys</code>는 이미 지연 뷰이므로 <code>keys</code>가 별도의
    버퍼링을 더하지는 않습니다 — 동일한 지연
    <code>Iterable&lt;K&gt;</code>를 그대로 건네줄 뿐입니다.
  </p>
  <p>
    <code>map.keys</code>에 <code>.where()</code>/<code>.toList()</code>를
    직접 붙이는 대신, 나머지 체인 어휘로 Map의 키 집합을 필터링하거나
    변환하거나 모으고 싶을 때 꺼내 쓰세요 — 둘은 동등하지만
    <code>fx(keys(map))</code>은 <code>fx(values(map))</code>,
    <code>fx(entries(map))</code> 옆에 나란히 두었을 때 훨씬 자연스럽게
    읽힙니다.
  </p>
  <p>
    키와 값이 <em>함께</em> 필요하다면 <code>entries</code>를 쓰세요 —
    <code>keys</code>와 <code>values</code>를 따로 꺼내면 두 호출 사이에
    원본 Map이 변경됐을 때 서로 짝이 맞는다는 보장이 없습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 키로 Map 필터링하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>keys</code>와 <code>sort</code>로 아이템 이름을
    알파벳순으로 정렬한 목록을 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="entries.html"><code>entries</code></a> — 키와 값을 쌍으로 함께 ·
    <a href="values.html"><code>values</code></a> — Map의 값 ·
    <a href="pick.html"><code>pick</code></a> — 키의 부분집합으로 새 Map 만들기 ·
    <a href="fx.html"><code>fx</code></a> — keys의 결과가 흘러 들어가는 체인
  </div>
