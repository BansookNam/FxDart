---
slug: toList
title: toList — FxDart 101
description: FxDart toList 튜토리얼: 지연 평가 체인을 List로 실체화하는 종결 연산자를 동기와 비동기 양쪽에서 다룹니다.
heading: <code>toList</code>
section: 1
crumb: toList
prev: pipe1.html
prevLabel: pipe1
next: each.html
nextLabel: each
---
  <p class="hero-sub">지연 이터러블을 실체화합니다 — 모든 값을 끌어당겨 List로 모읍니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>toList</code>는 가장 많이 쓰이는 <strong>종결 연산자</strong>입니다.
    그 시점까지 계획에 불과했던 체인을 실제로 실행시키는 것이 바로 이 함수입니다.
    <code>.toList()</code>를 호출하면 이터러블에 남아 있는 모든 값을 순서대로
    끌어당겨 진짜 <code>List&lt;T&gt;</code>에 담습니다. 상류의 모든 것 —
    <code>.map()</code>, <code>.filter()</code>, <code>.take()</code> — 은
    <code>toList</code>가 값을 요청했기 때문에 비로소 실행됩니다.
  </p>
  <p>
    뒤집어 말하면 <code>toList</code>는 무한하거나 크기가 정해지지 않은 소스에
    <em>직접</em> 호출해서는 안 되는 연산자이기도 합니다(끝이 없는
    <code>range</code>, <code>cycle</code>, 개수가 아주 큰 <code>repeat</code>).
    영원히 값을 끌어당기려 들기 때문입니다. 먼저 <code>take(n)</code>으로 범위를
    한정한 다음, 그 결과에 <code>toList</code>를 호출하세요.
  </p>
  <p>
    비동기 버전인 <code>toListAsync</code>(또는 <code>FxAsync</code> 체인에서의
    <code>.toList()</code>)는 원소를 끌어당길 때마다 await하며
    <code>Future&lt;List&lt;T&gt;&gt;</code>를 반환합니다. 상류에
    <code>.concurrent(n)</code>을 함께 쓰면 개별 await가 겹쳐 실행되지만,
    최종 리스트는 여전히 원래 순서대로 돌아옵니다.
  </p>

  <h2>데모 1 · 기본과 지연 평가</h2>
  <p>백만 개 중에서 <code>take(3)</code>이 통과시킨 3개에 대해서만
    <code>map</code>이 실제로 실행되는 것을 확인해 보세요.</p>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  <p>
    <code>FxAsync</code> 체인에서의 <code>.toList()</code>는 모든 원소를
    await한 뒤 리스트 전체를 한 번에 돌려줍니다. 상류에
    <code>.concurrent(n)</code>을 추가하면 개별 대기 시간이 서로 겹칩니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 아주 큰 범위에서 앞쪽 4개의 제곱을 List로 실체화해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="each.html"><code>each</code></a> — List 대신 부수 효과를 위한 종결 연산자 ·
    <a href="consume.html"><code>consume</code></a> — 결과를 아예 버리는 종결 연산자 ·
    <a href="fx.html"><code>fx</code></a> — toList가 종결시키는 그 체인 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
