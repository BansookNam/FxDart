---
slug: topBy
title: topBy — FxDart 101
description: FxDart topBy와 bottomBy 튜토리얼 — 전체를 정렬한 뒤 k개를 자르는 대신, 키 기준 상위·하위 k개를 한 번의 순회로 정렬된 상태로 얻습니다. 동점은 먼저 본 원소가 이깁니다. 라이브 플레이그라운드 포함.
heading: <code>fxTopBy</code> · <code>fxBottomBy</code>
section: 7
crumb: topBy
prev: quantile.html
prevLabel: quantile
next: size.html
nextLabel: count
---
  <p class="hero-sub">상위 3개, 가장 싼 5개 — 나머지는 정렬하지 않고, 한 번의 순회로, 이미 정렬된 채로.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    순위표를 읽는 흔한 방법은 <code>sortByDesc(f, xs).take(k)</code>입니다.
    입력 전체를 정렬하고, <code>k</code>개를 남기고, 나머지는 버립니다.
    <code>fxTopBy(k, f, xs)</code>는 같은 <code>k</code>개 원소를
    <strong>한 번의 순회</strong>로 반환하며, 이 순회는
    <code>k</code> 크기의 경계만 유지합니다 — 메모리는 입력이 아니라 <code>k</code>에 비례하고, 경계
    밖의 원소는 붙잡아 두지 않습니다. <code>fxBottomBy(k, f, xs)</code>는
    그 거울상으로, 키가 가장 작은 <code>k</code>개를 작은 것부터
    반환합니다.
  </p>
  <p>
    결과에는 두 번째 순회가 필요 없습니다. <strong>정렬되어</strong>
    있고 — <code>topBy</code>는 내림차순, <code>bottomBy</code>는
    오름차순 — <strong>동점은 먼저 본 원소가 이깁니다</strong>. 나중에 온
    원소의 키가 경계의 가장 약한 키와 같기만 하면 그것을 밀어내지 못하고,
    결과 안의 같은 키들은 입력 순서를 유지합니다.
    <code>k &lt;= 0</code>이면 빈 리스트, 입력 길이를 넘는
    <code>k</code>는 모든 원소를 정렬해 반환합니다. 키는
    <code><a href="sortBy.html">sortBy</a></code>와 똑같이 비교되므로
    어떤 <code>Comparable</code>이든 됩니다.
  </p>
  <p>
    경계는 삽입으로 유지되므로 최악의 경우 <code>O(n·k)</code>입니다. 큰
    입력에서 작은 <code>k</code>를 고를 때 쓰는 도구이고,
    <code>k</code>가 입력 길이에 가까워지면 정렬하세요. 동기 체인의
    <code>fx(xs).topBy(k, f)</code>는 <em>단계</em>라서
    <code>Fx</code>를 반환하므로 체인을 계속 이어 갈 수 있습니다. 반면
    <code>FxAsync.topBy</code>와 <code>fxTopByAsync</code> 계열은
    <code>Future&lt;List&gt;</code>로 체인을 끝내며, 키 함수는 동기
    그대로입니다. fxdart 확장 기능입니다(FxTS에는 없습니다) — Python의
    <code>heapq.nlargest</code>와 같은 모양입니다.
  </p>

  <h2>데모 1 · 순서, 동점과 k</h2>
  {{playground:0}}

  <h2>데모 2 · 체인에서, 동기와 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 정렬 후 자르는 코드를 호출 하나로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="sortByDesc.html"><code>sortByDesc</code></a> — 전체 순서가 필요할 때 ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — <code>k</code>가 1일 때 ·
    <a href="quantile.html"><code>quantile</code></a> — 앞쪽 <code>k</code>개가 아니라 한 위치
  </div>
