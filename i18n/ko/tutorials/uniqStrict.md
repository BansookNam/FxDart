---
slug: uniqStrict
title: uniqStrict — FxDart 101
description: FxDart uniqStrict 튜토리얼: 지연이 아니라 즉시 중복을 제거해 List로 받는 방법과 그 거래가 언제 이득인지를 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>uniqStrict</code>
section: 4
crumb: uniqStrict
prev: uniqBy.html
prevLabel: distinctBy
next: uniqAdjacent.html
nextLabel: uniqAdjacent
---
  <p class="hero-sub">이터러블 전체를 그 자리에서 중복 제거해 <code>List</code>로 돌려줍니다 — <code>distinct</code>의 즉시 실행 버전입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>uniqStrict</code>가 내놓는 원소와 순서는
    <a href="uniq.html"><code>distinct</code></a> 뒤에 <code>toList()</code>를
    붙인 것과 정확히 같습니다. 다른 것은 그 일이 <em>언제</em> 일어나는지,
    그리고 누가 그것을 멈출 수 있는지입니다.
    <code>uniqByStrict</code>는 <a href="uniqBy.html"><code>distinctBy</code></a>에
    대해 같은 거래를 합니다. 계산된 키로, 즉시 중복을 제거합니다.
  </p>
  <p>
    지연 체인은 순회할 때마다 상류를 다시 실행합니다.
    <code>distinct(...)</code>를 두 번 순회하면 소스도 두 번 걸어갑니다.
    즉시 실행 버전은 호출 시점에 한 번만 걸어가고 <code>List</code>를
    돌려줍니다. 그러니 인덱싱하거나, 길이를 재거나, 두 번 이상 훑을 결과라면
    <em>n</em>번이 아니라 한 번의 순회로 끝납니다. 데모 2가 콜백 호출 횟수를
    세어 이 점을 눈으로 보여줍니다.
  </p>
  <p>
    대가는 하류에서 일을 중간에 끊을 수 없다는 것입니다.
    <code>distinct(xs).take(3)</code>은 서로 다른 값 3개가 나오는 순간
    <code>xs</code>를 그만 당깁니다. 반면
    <code>uniqStrict(xs).take(3)</code>은 <code>xs</code> 전체를 먼저 중복
    제거한 다음 3개를 가져갑니다. 즉시 실행 버전을 조기 종료하는 소비자 앞에
    두지 마세요. 무한 이터러블에는 절대 쓰지 마세요 — 끝나지 않습니다.
  </p>
  <div class="callout">
    <strong>기본은 지연입니다.</strong> <code>distinct(...).toList()</code>는
    이미 중복 제거와 누적을 한 번의 순회로 처리하므로, 지연이라서 손해를 보고
    있지 않습니다. 중복 제거된 <code>List</code> 자체가 필요할 때, 또는 그것을
    두 번 이상 순회할 때만 <code>uniqStrict</code>를 꺼내세요.
  </div>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 언제 이득이고, 무엇을 잃는가</h2>
  {{playground:1}}

  <h2>직접 해보기</h2>
  <p>연습: <code>uniqByStrict</code>로 방문자별 첫 방문만 남기되, 다시
    순회하지 않고 인덱싱할 수 있는 <code>List</code>로 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="uniq.html"><code>distinct</code></a> — 지연 방식의 기본값 ·
    <a href="uniqBy.html"><code>distinctBy</code></a> — 계산된 키로 중복 제거 ·
    <a href="uniqAdjacent.html"><code>uniqAdjacent</code></a> — 인접한 중복만 제거 ·
    <a href="toList.html"><code>toList</code></a> — 어떤 체인이든 구체화
  </div>
