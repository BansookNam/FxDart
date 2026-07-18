---
slug: scan
title: scan — FxDart 101
description: FxDart scan 튜토리얼: 초깃값이 있든 없든 동작하는 지연 누적 연산. 라이브 플레이그라운드 포함.
heading: <code>scan</code>
section: 3
crumb: scan
prev: flat.html
prevLabel: flat
next: peek.html
nextLabel: peek
---
  <p class="hero-sub">지연 평가되는 누적 연산 — <code>reduce</code>와 비슷하지만 마지막 값만이 아니라 중간 값을 모두 내보냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>scan</code>은 중간 단계를 그대로 드러내는
    <code>reduce</code>/<code>fold</code>입니다. 이터러블을 최종 값 하나로
    접어 버리는 대신, 초깃값 자체를 첫 값으로 포함해 누적된 <em>모든</em>
    중간 결과를 내보냅니다. 첫 값이 초깃값이라는 점이 중요합니다 —
    <code>scan(f, 0, [1, 2, 3])</code>은 세 개가 아니라 네 개의 값
    (<code>0</code>, 그리고 누적 합 세 개)을 만들어 냅니다.
  </p>
  <p>
    <code>scan1</code>은 초깃값이 없는 변형으로, FxTS의
    <code>scan(f, iterable)</code> 오버로드(seed 인자가 없는 형태)를
    옮겨 온 것입니다. 이터러블의 첫 원소를 초기 누적값으로 삼아 곧바로
    내보낸 뒤 나머지를 계속 접어 나갑니다 — <code>reduce</code>와
    <code>fold</code>의 관계와 같습니다. 빈 이터러블에서는
    <code>scan1</code>이 초깃값으로 삼을 첫 원소가 없으므로 아무것도
    내보내지 않습니다. <code>scan1</code>에는 체인 메서드가 없다는 점에
    유의하세요(<code>Fx</code>/<code>FxAsync</code>에는 <code>scan</code>만
    있습니다). data-first 형태로 호출하세요:
    <code>scan1(f, iterable)</code>.
  </p>
  <p>
    둘 다 지연 평가됩니다. 값을 끌어당기기 전까지는 아무것도 실행되지
    않습니다. 비동기 쪽에서는 <code>scanAsync</code>/<code>scan1Async</code>가
    여전히 순서대로 한 단계씩 접어 나가므로(각 단계가 이전 결과를 필요로
    하므로) <code>.concurrent(n)</code>이 폴딩 자체를 병렬화하지는
    못합니다. 다만 누적 함수 자체가 가볍기만 하다면 상류의 fetch 단계는
    동시에 실행되게 할 수 있습니다. 데모 2를 참고하세요.
  </p>

  <h2>데모 1 · 기본 — scan과 scan1</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 상류의 동시성</h2>
  <p>
    폴딩 자체는 순차적으로 남지만, 거기에 값을 공급하는 fetch는
    그럴 필요가 없습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>scan</code>으로 <code>0</code>에서 시작하는 걸음 수의
    누적 합계를 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="../tutorials/reduce.html"><code>reduce</code>/<code>fold</code></a> — 최종 값 하나로 접기 ·
    <a href="flat.html"><code>flat</code></a> — 중첩된 이터러블 평탄화 ·
    <a href="peek.html"><code>peek</code></a> — 변환 없이 들여다보기 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
