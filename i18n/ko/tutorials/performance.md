---
slug: performance
title: 빠른 파이프라인 작성하기 — FxDart 101
description: 어떤 FxDart 형태가 빠르고 왜 그런지 — 종결 연산자, filter 순서, groupBy 대신 foldBy, 그리고 지연 평가가 비용이 되는 순간을 라이브 플레이그라운드와 함께 다룹니다.
heading: 빠른 파이프라인 작성하기
section: 1
crumb: performance
prev: consume.html
prevLabel: consume
next: range.html
nextLabel: range
---
  <p class="hero-sub">라이브러리는 어떤 형태를 빠르게 만들 수는 있어도, 그 형태를 대신 골라 주지는 못합니다. 값을 하는 형태들을 모았습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <a href="../DartComparison/index.html">Dart vs FxDart</a> 비교의 모든 예제는
    손으로 짠 명령형 반복문을 기준으로 측정되며, 대부분은 그와 같거나 비슷한
    수준에 도달합니다. 체인이 더 느린 경우, 원인은 알고리즘인 적이 거의
    없습니다 — 양쪽은 같은 일을 합니다 — 그리고 거의 언제나 넷 중
    하나입니다. 원소마다 지불하는 단계 경계, 원소마다 일어나는 할당, 필요보다
    자주 실행되는 콜백, 그리고 두 번 이상 순회되는 상류입니다.
  </p>

  <h3>1. 종결 연산자로 끝내세요</h3>
  <p>
    <a href="toList.html"><code>toList</code></a> 같은 종결 연산자는 체인
    전체를 보기 때문에, 원소를 하나씩 꺼내 쓰는 소비자는 쓸 수 없는 경로를
    택할 수 있습니다. <code>List</code> 소스 위에서
    <code>map(f).toList()</code>와 <code>filter(p).toList()</code>는 복사를
    SDK 자체의 일괄 채우기에 넘기는데, 이 경로는 패키지 코드가 어쩔 수 없이
    지불해야 하는 원소별 타입 검사를 하지 않습니다. 같은 체인을
    <code>for</code>-in으로 직접 당기면서 모으면 그 경로를 통째로 포기하게
    됩니다.
  </p>

  <h3>2. map보다 filter를 먼저</h3>
  <p>
    단계는 여러분이 쓴 순서대로 실행되고, <code>filter</code>를 통과한 원소는
    그 뒤의 모든 단계 비용을 치릅니다. 값싼 검사를 앞에, 비싼 변환을 뒤에 두는
    것은 공짜로 할 수 있으면서 종종 가장 큰 이득입니다.
  </p>

  <h3>3. 재료가 아니라 답을 요청하세요</h3>
  <p>
    <a href="groupBy.html"><code>groupBy</code></a>는 키마다
    <code>List</code>를 만듭니다 — <strong>입력</strong>에 비례하는 할당이죠 —
    그런데 원하던 것이 키별 합계뿐이었다면 그 리스트들은 만들어졌다가 그대로
    버려집니다. <a href="foldBy.html"><code>foldBy</code></a>는 결과 맵에 곧장
    누적하고, <a href="countBy.html"><code>countBy</code></a>는 카운터 버전에
    이름을 붙여 둔 것입니다. 정말로 구성원이 필요할 때만
    <code>groupBy</code>를 쓰세요.
  </p>
  <p>
    이 둘은 연산자가 여러분이 직접 썼을 루프보다 빠른 드문 경우이기도
    합니다. 누구나 떠올릴 그 한 줄,
    <code>counts[k] = (counts[k] ?? 0) + 1</code>은 원소마다 해시 맵을
    <strong>두 번</strong> 건드립니다. 읽으려고 한 번, 다시 쓰려고 한 번.
    그리고 세는 작업에서는 맵이 사실상 비용의 전부입니다. 두 연산자는
    대신 맵 안에 세워 둔 가변 셀에 누적하므로, 맵은 원소마다가 아니라
    <em>서로 다른 키마다</em> 한 번 쓰입니다 — 백만 행을 세면 약 1.5×이고,
    <a href="../DartComparison/top-log-level.html">가장 잦은 로그 레벨</a>이
    직접 루프에 뒤처지지 않고 앞서는 이유입니다.
  </p>

  <h3>4. 지연 체인은 순회할 때마다 다시 실행됩니다</h3>
  <p>
    지연 평가란 체인이 결과가 아니라 레시피라는 뜻입니다. 두 번 순회하면
    상류도 두 번 실행됩니다. 답을 두 번 이상 쓴다면 한 번만 구체화하세요 —
    <a href="toList.html"><code>toList</code></a>로, 또는 중복 제거 자체가
    간직할 대상이라면
    <a href="uniqStrict.html"><code>uniqStrict</code></a>로 말이죠.
  </p>

  <h3>그래도 지연 평가가 벌어 주는 것</h3>
  <p>
    이 중 무엇도 지연 체인을 쓰지 말라는 이야기가 아닙니다. filter 뒤의
    <code>take</code>나 <code>head</code>는 필요한 만큼 모이는 즉시 소스를
    멈춥니다 — 그 일은 아예 일어나지 않습니다 — 그리고 이것은 어떤 즉시 평가
    파이프라인도 흉내 낼 수 없는 종류의 절약입니다. 지연 평가는 원소마다 조금
    비용을 치르고, 전부를 아낄 수 있습니다.
  </p>

  <div class="callout">
    <strong>레코드는 공짜가 아닙니다.</strong> 레코드를 만들어 내는 단계 —
    <a href="zip.html"><code>zip</code></a>,
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a>,
    <a href="pairwise.html"><code>pairwise</code></a>, 또는 튜플로 가는
    <code>map</code> — 는 원소마다 하나씩 할당하며, 레코드는 재사용할 수
    없습니다. 바로 다음 단계가 그중 대부분을 버린다면, 파이프라인이 인덱스나
    값 하나만 들고 갈 수는 없는지 생각해 보세요.
    <a href="withIndex.html"><code>mapWithIndex</code></a>가 존재하는 이유가
    바로 <code>zipWithIndex().map(...)</code>이 원소마다 쌍을 할당하지 않아도
    되게 하기 위해서입니다.
  </div>

  <h2>데모 1 · 종결 연산자와 filter 순서</h2>
  {{playground:0}}

  <h2>데모 2 · groupBy 대신 foldBy, 그리고 두 번째 순회의 값</h2>
  {{playground:1}}

  <h2>직접 해보기</h2>
  <p>연습: 이 코드는 readings를 두 번 순회하고, 만들자마자 버리는 리스트를
    하나 만듭니다. 종결 연산자 하나로 끝나는 단일 체인으로 고쳐 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 문서:</strong>
    <a href="toList.html"><code>toList</code></a> — 대부분의 빠른 경로가 걸려 있는 종결 연산자 ·
    <a href="foldBy.html"><code>foldBy</code></a> — 그룹 없이 집계하기 ·
    <a href="uniqStrict.html"><code>uniqStrict</code></a> — 한 번 중복 제거하고 여러 번 쓰기 ·
    <a href="withIndex.html"><code>mapWithIndex</code></a> — 레코드 없이 인덱스 얻기
  </div>
