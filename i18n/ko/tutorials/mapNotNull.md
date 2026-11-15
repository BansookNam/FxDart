---
slug: mapNotNull
title: mapNotNull — FxDart 101
description: FxDart mapNotNull과 firstNotNullOf 튜토리얼 — 변환과 필터링을 지연 단계 하나로 처리하며, 콜백이 null을 반환하면 건너뜁니다. 라이브 플레이그라운드 포함.
heading: <code>mapNotNull</code> · <code>firstNotNullOf</code>
section: 3
crumb: mapNotNull
prev: attach.html
prevLabel: attach
next: filter.html
nextLabel: where
---
  <p class="hero-sub">변환과 필터링을 한 번에 — 콜백이 새 값을 반환하거나, 건너뛰려면 <code>null</code>을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    매핑 중 상당수는 <em>부분적</em>입니다. 숫자가 아닐 수도 있는 문자열을
    파싱하거나, 없을 수도 있는 키를 조회하는 경우죠. 이를 길게 풀어 쓰면
    작업을 한 번 실행해 검사하는 <code>where</code>와 그 작업을 다시 실행해
    값을 남기는 <code>map</code>이 되거나, 지연 단계 두 개를 쌓는
    <code>fxCompact(fxMap(f, xs))</code>가 됩니다.
    <code>mapNotNull(f, xs)</code>는 이 둘을 한 단계에서 처리합니다.
    <code>f</code>가 새 값을 반환하고, 결과가 <code>null</code>이면
    <em>이 원소를 건너뛴다</em>는 뜻입니다. <code>f</code>는 원소마다 한 번,
    그 원소를 꺼낼 때에만 실행됩니다.
  </p>
  <p>
    결과 타입 <code>B</code>는 <code>Object</code>로 한정되므로
    <code>mapNotNull(int.tryParse, xs)</code>는 <code>int?</code>가 아니라
    <code>Iterable&lt;int&gt;</code>입니다 — <code>null</code>이
    <em>null을 내보낸다</em>는 뜻이 될 일은 없습니다.
    <code>firstNotNullOf(f, xs)</code>는 같은 아이디어의 종결 연산입니다.
    <code>f</code>의 첫 번째 non-null 결과를 반환하고 거기서 멈추며, 모든
    결과가 <code>null</code>이면(또는 입력이 비어 있으면)
    <code>null</code>을 반환합니다.
    <code><a href="find.html">find</a></code>는 일치한 <em>원소</em>를
    반환하지만, <code>firstNotNullOf</code>는 투영한 값을 반환합니다 — 그 값을
    얻으려고 다시 호출할 필요가 없습니다.
  </p>
  <p>
    비동기 짝은 <code>mapNotNullAsync</code>와
    <code>firstNotNullOfAsync</code>이며, <code>f</code>는
    <code>Future</code>를 반환해도 됩니다. <code>mapNotNullAsync</code>는
    병렬에 안전한 <code>fxMapAsync</code> 위에 만들어져 있어서
    <code><a href="concurrent.html">concurrent(n)</a></code>을 붙이면 콜백이
    <em>n</em>개씩 동시에 실행됩니다. <code>firstNotNullOfAsync</code>는 원소를
    하나씩 꺼내고 첫 결과에서 소스를 취소합니다. 체인에서는
    <code>fx(xs).mapNotNull(f)</code>와
    <code>fx(xs).firstNotNullOf(f)</code>입니다. Dart 고유의 추가 기능입니다(FxTS에는
    없습니다) — Kotlin의 <code>mapNotNull</code>과
    <code>firstNotNullOfOrNull</code>, Rust의 <code>filter_map</code>에
    해당합니다.
  </p>

  <h2>데모 1 · 파싱되는 것만 파싱</h2>
  {{playground:0}}

  <h2>데모 2 · 빗나갈 수 있는 비동기 조회</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 모든 답을 두 번씩 파싱하는 일을 멈추세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="map.html"><code>map</code></a> — 모든 원소에 결과가 있을 때 ·
    <a href="filter.html"><code>where</code></a> — 원소를 바꾸지 않고 남길 때 ·
    <a href="compact.html"><code>nonNulls</code></a> — 이미 들어 있는 null을 버릴 때 ·
    <a href="find.html"><code>find</code></a> — 투영이 아니라 첫 번째로 일치한 원소
  </div>
