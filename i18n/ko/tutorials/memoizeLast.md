---
slug: memoizeLast
title: memoizeLast — FxDart 101
description: FxDart memoizeLast 튜토리얼 — 동일성(identity)을 키로 하는 한 칸짜리 캐시. 불변 상태에 대한 순수 함수를 위한 도구이며 라이브 플레이그라운드 포함.
heading: <code>fxMemoizeLast</code>
section: 10
crumb: memoizeLast
prev: memoize.html
prevLabel: memoize
next: negate.html
nextLabel: negate
---
  <p class="hero-sub">마지막 호출만 기억하고 — 반복 호출을 동일성으로, O(1)에 알아봅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="memoize.html">fxMemoize</a></code>는 지금까지 본 모든
    인자를 <code>==</code>/<code>hashCode</code>를 키로 보관합니다. 이는 앱이
    캐싱하고 싶어 하는 가장 흔한 대상, 즉 <strong>불변 상태</strong>에서
    파생된 값에는 맞지 않습니다. 변경이 일어날 때마다 새 상태 객체가
    만들어지므로, 상태에 대한 메모는 변경 하나당 항목이 하나씩 끝없이
    늘어납니다 — 게다가 호출마다 큰 상태를 해싱하는 비용이 아끼는 작업보다
    클 수도 있습니다.
  </p>
  <p>
    <code>fxMemoizeLast(f)</code>는 한 칸만 둡니다. 인자가 직전 호출의
    인자와 <code>identical</code>하면 직전 결과를 반환하고, 그 밖의 경우에는
    <code>f</code>를 실행해 칸을 교체합니다. 불변 상태라면 이게 정확히
    맞습니다. 같은 인스턴스는 아무것도 바뀌지 않았다는 뜻이고, 새 인스턴스는
    무언가 바뀌었을 수 있다는 뜻이며, 검사는 포인터 비교 한 번입니다. 같은
    상태 위에서 초당 60번 다시 빌드되는 위젯도 <code>f</code> 비용은 한 번만
    냅니다.
  </p>
  <p>
    값으로 비교하려면 <code>equals</code>를 넘기세요. 함수가 인자를 둘 이상
    받는다면 레코드 — 필드별로 비교되는 <code>(state, id)</code> — 를 키로
    삼을 때도 씁니다. 결과가 인자에만 의존하는 함수만 메모이즈하세요. 시계나
    변경 가능한 필드도 읽는 함수라면 칸에 남은 오래된 답을 내줄 것입니다.
    fxdart 확장 기능이며(FxTS에는 없습니다), reselect의 selector 메모를
    따랐습니다.
  </p>

  <h2>데모 1 · 같은 상태, 한 번의 실행</h2>
  {{playground:0}}

  <h2>데모 2 · 두 개의 인자, 그리고 fxMemoize와의 비교</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 같은 리스트에 대한 세 번의 호출이 함수를 한 번만 실행하게 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="memoize.html"><code>fxMemoize</code></a> — 모든 인자에 대한 캐시 ·
    <a href="onChange.html"><code>fxOnChange</code></a> — 값이 바뀌지 않은 콜백은 건너뛰기 ·
    <a href="identity.html"><code>fxIdentity</code></a>
  </div>
