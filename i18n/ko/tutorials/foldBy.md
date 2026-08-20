---
slug: foldBy
title: foldBy — FxDart 101
description: FxDart foldBy 튜토리얼: 그룹을 만들지 않고 한 번의 순회로 키별 값을 접는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>foldBy</code>
section: 7
crumb: foldBy
prev: countBy.html
prevLabel: countBy
next: countWhere.html
nextLabel: countWhere
---
  <p class="hero-sub">한 번의 순회로 키별 값을 접습니다 — 그룹 없이 집계만.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>foldBy</code>는 <code><a href="fold.html">fold</a></code>를 소스
    전체에 한 번이 아니라 키마다 한 번씩 실행하는 것입니다. 각
    원소가 자기 키를 고르고, 그 값이 해당 키의 누적값에 접혀 들어갑니다.
    그래서 결과는 원소가 아니라 답의
    <code>Map&lt;K, Acc&gt;</code>입니다.
  </p>
  <p>
    이 함수가 존재하는 이유는 이것이 <em>하지 않는</em> 일에 있습니다.
    <code><a href="groupBy.html">groupBy</a></code> 다음에 그룹마다 접는
    방식은 먼저 키마다 <code>List</code>를 만들어야 합니다. 답은
    <strong>키 개수</strong>에 비례하는데, 할당은 <strong>입력</strong>에
    비례하는 셈입니다. 카테고리별 합계만 원한다면 그 리스트들은 만들어졌다가
    그대로 버려집니다. <code>foldBy</code>는 손으로 짠 반복문처럼 결과 맵에
    곧바로 누적합니다.
  </p>
  <pre><code>// 손으로 짠다면 이렇게
for (final t in txns) {
  totals[t.category] = (totals[t.category] ?? 0) + t.amount;
}

// 같은 일에 이름을 붙인 것
foldBy((Tx t) =&gt; t.category, 0.0, (sum, t) =&gt; sum + t.amount, txns);</code></pre>
  <p>
    카테고리 다섯 개에 걸친 백만 건의 거래에서, 먼저 그룹으로 묶는 방식은
    손으로 짠 반복문의 <strong>2.7배</strong>가 듭니다. <code>foldBy</code>는
    <strong>0.91배</strong>입니다 — 바로 옆의 반복문보다 조금 <em>빠르고</em>,
    반올림 착시가 아닙니다. 반복문은 맵을 읽고 다시 쓰므로 거래마다 카테고리를
    두 번 해시합니다. <code>foldBy</code>는 맵 안에 세워 둔 가변 셀에
    누적하므로, 맵은 거래마다가 아니라 <em>카테고리마다</em> 한 번 쓰입니다.
    <a href="../DartComparison/index.html">Dart vs FxDart</a> 예제 중 여럿이
    바로 이 이유로 이 함수로 옮겨 갔습니다.
  </p>
  <p>
    다만 그 차이를 과대 해석하지는 마세요. 여기서 폴드 콜백은 덧셈 하나라
    맵이 작업의 대부분입니다. 누산기가 무거워지면 절약은 그대로지만 콜백
    자신의 비용에 묻힙니다 — 맨 아래 레코드에 관한 메모를 보세요.
    <code>foldBy</code>에 손을 뻗는 이유는 뜻하는 바를 그대로 말해 주기
    때문이고, 반복문보다 조금 빠른 것은 논거가 아니라 덤입니다.
  </p>
  <p>
    키는 <strong>처음 등장한 순서</strong>로 나옵니다.
    <code>groupBy</code>와 마찬가지입니다. FxTS 포팅이 아니라, Kotlin의
    <code>groupingBy().fold()</code>에서 온 형태입니다.
  </p>

  <div class="callout">
    <strong>seed는 팩토리가 아니라 값입니다.</strong> <code>fold</code>에서와
    똑같이 <code>seed</code>는 <em>모든</em> 키의 시작점으로 쓰이는 하나의
    값입니다. 새 값으로 접어 나가는 숫자나 문자열이라면 문제없습니다.
    하지만 리스트·집합·맵 같은 <strong>가변</strong> seed는 모든 키가 공유하며
    모두가 그것을 변경하게 됩니다. 그룹마다 가변 구조에 누적해야 한다면
    <code><a href="groupBy.html">groupBy</a></code>를 쓰세요.
  </div>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해보기</h2>
  <p>
    연습: 데모는 첫 글자별로 <strong>단어 수</strong>를 셉니다. 이것을 첫
    글자별 <strong>글자 수</strong> 합계로 바꿔서, <code>fig</code>와
    <code>fx</code>가 <code>{f: 5}</code>가 되도록 해보세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>쓰지 말아야 할 때:</strong> 실행 중인 값이 두 개 필요한 누적값 —
    평균은 합계<em>와</em> 개수가 모두 필요합니다 — 은 그것들을 레코드에
    담아 옮겨야 하고, 레코드는 원소마다 할당됩니다. 그러면 피하려던 그룹핑보다
    비용이 더 큽니다. 그럴 때는 <code>groupBy</code>를 쓰세요.
  </div>

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — 접지 않고 원소를 그대로 모읍니다 ·
    <a href="countBy.html"><code>countBy</code></a> — 카운터를 쓰는 <code>foldBy</code>에 이름을 붙인 것 ·
    <a href="fold.html"><code>fold</code></a> — 누적값 하나에 대한 같은 폴드 ·
    <a href="groupedBy.html"><code>groupedBy</code></a> — 체인 안에 머무는 그룹핑
  </div>
