---
slug: fold
title: fold — FxDart 101
description: FxDart fold 튜토리얼: 초깃값을 명시해 접는 reduce로, 빈 입력에도 안전합니다. 라이브 플레이그라운드 포함.
heading: <code>fold</code>
section: 7
crumb: fold
prev: reduce.html
prevLabel: reduce
next: reduceLazy.html
nextLabel: reduceLazy
---
  <p class="hero-sub">초깃값을 받는 형태의 reduce입니다. 파이프라인이 비어 있어도 언제나 안전합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>fold</code>는 시작 값을 명시적으로 주는
    <code><a href="reduce.html">reduce</a></code>입니다. FxTS에서는 그저
    인자를 세 개 넘긴 <code>reduce</code>, 즉 <code>reduce(f, seed, iterable)</code>일
    뿐입니다. Dart는 인자 개수로 오버로드를 구분하지 못하므로 FxDart는 둘을
    나눴습니다. 초깃값 없는 형태는 <code>reduce</code>라는 이름을 그대로 쓰고,
    초깃값을 받는 형태는 <code>fold</code>로 이름을 바꿨습니다. Dart의
    <code>Iterable</code>이 바로 이 연산에 이미 쓰고 있는 이름이기도 합니다.
  </p>
  <p>
    인자 순서를 잘 봐 두세요. <code>fold(seed, f, iterable)</code>입니다 —
    초깃값이 먼저, 그다음 결합 함수, 마지막이 소스입니다. 체인 형태에서
    <code>Iterable.fold(initialValue, combine)</code>과 같은 순서죠. 함수가 먼저
    오는 FxTS의 <code>reduce(f, seed, iterable)</code>과는 다릅니다.
  </p>
  <p>
    초깃값을 항상 직접 넘기기 때문에 <code>fold</code>는 빈 이터러블에서도
    예외를 던지지 않고 초깃값을 그대로 반환합니다. 그래서 파이프라인에 원소가
    하나라도 있는지 확신할 수 없을 때 더 안전한 기본 선택지입니다.
    <code>reduce</code>와 마찬가지로 종결 연산자이므로,
    <code>fold</code>가 값을 끌어당기기 전까지 상류에서는 아무 일도 일어나지 않습니다.
  </p>

  <h2>데모 1 · 기본과 빈 입력</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, Map 만들어 나가기</h2>
  <p>초깃값이 숫자일 필요는 없습니다 — 여기서는 지연이 있는 파이프라인을 길이별 히스토그램으로 접습니다:</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>1000</code>에서 시작해 입금 내역을 <code>fold</code>로 접어 잔액을 계산해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="reduce.html"><code>reduce</code></a> — 초깃값이 없는 짝 ·
    <a href="reduceLazy.html"><code>reduceLazy</code></a> — 재사용 가능한 커링된 리듀서 ·
    <a href="sum.html"><code>sum</code></a> — 흔히 쓰는 fold를 특화한 함수 ·
    <a href="scan.html"><code>scan</code></a> — fold와 비슷하지만 중간값을 모두 지연 방출
  </div>
