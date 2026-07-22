---
slug: sort
title: sort — FxDart 101
description: FxDart sort 튜토리얼 — 비교자를 기준으로 정렬하며 입력을 변경하지 않고 항상 새 리스트를 반환합니다. 라이브 플레이그라운드 포함.
heading: <code>sort</code>
section: 7
crumb: sort
prev: countBy.html
prevLabel: countBy
next: sortBy.html
nextLabel: sortBy
---
  <p class="hero-sub">비교자로 정렬한 완전히 새로운 리스트를 반환합니다 — 입력은 절대 변경하지 않습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>sort</code>는 Dart의 표준 비교자를 받습니다 —
    <code>a</code>가 <code>b</code>보다 앞이면 음수, 뒤면 양수,
    동등하면 0을 반환하는 그 함수입니다 — 그리고 정렬된 결과를 만들어
    냅니다. JavaScript(그리고 FxTS)의
    <code>Array.prototype.sort</code>와 결정적으로 다른 점은
    FxDart의 <code>sort</code>가 <strong>입력을 절대 변경하지 않는다</strong>는
    것입니다. 언제나 새 <code>List</code>를 할당하며
    (<code>List.of(iterable)..sort(f)</code>),
    원본 이터러블은 그대로 남습니다. FxTS는 나중에 원본을 변경하는
    <code>sort</code>에 대해 변경을 일으키지 않는 대안으로
    <code>toSorted</code>를 추가했지만,
    FxDart에서 <code>toSorted</code>는 그저 별칭입니다 —
    <code>sort</code>가 이미 원본을 건드리지 않으니 구분할 이유가
    없기 때문입니다.
  </p>
  <p>
    <strong>체인</strong> 형태에는 짚고 넘어갈 만한 미묘한 점이
    하나 있습니다. 동기 <code>Fx</code> 체인에서 <code>.sort(f)</code>는
    또 다른 <code>Fx&lt;T&gt;</code>를 반환합니다 —
    <code>List&lt;T&gt;</code>가 아닙니다. <code>Fx</code>가 계속 체이닝할 수 있도록 내부의 정렬된
    리스트를 감싸기 때문입니다. 여전히
    <code><a href="../101/index.html">.toList()</a></code> 같은 종결
    연산자를 거쳐야 구체적인 <code>List</code>를 얻을 수 있습니다.
    <strong>비동기</strong> 체인에는 이런
    사정이 없습니다. <code>FxAsync.sort(f)</code>는 그 자체가 종결
    연산자로서 <code>Future&lt;List&lt;T&gt;&gt;</code>를 바로 반환하는데,
    파이프라인 전체를 먼저 <code>await</code>해야 하는 연산에서
    <code>FxAsync</code>가 자기 자신을 반환할 수는 없기 때문입니다.
  </p>
  <p>
    비교자를 직접 작성하는 대신 추출한 키를 기준으로 정렬하고 싶다면
    <code><a href="sortBy.html">sortBy</a></code>를 쓰세요.
  </p>

  <h2>데모 1 · 기본 사용법, 원본 불변, 그리고 toSorted</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 — 이미 종결 연산자</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 숫자를 <strong>내림차순</strong>으로 정렬해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="sortBy.html"><code>sortBy</code></a> — 비교자 대신 추출한 키로 정렬 ·
    <a href="reverse.html"><code>reverse</code></a> — 비교 없이 순서만 뒤집기 ·
    <a href="partition.html"><code>partition</code></a> — 술어로 두 리스트로 나누기
  </div>
