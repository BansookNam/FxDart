---
slug: pipe
title: pipe — FxDart 101
description: FxDart pipe 튜토리얼: 값을 함수 목록에 좌에서 우로 통과시키는 동적 타입 합성과, 타입이 유지되는 대안인 fx() 체인을 살펴봅니다.
heading: <code>pipe</code>
section: 1
crumb: pipe
prev: fx.html
prevLabel: fx
next: pipe1.html
nextLabel: pipe1
---
  <p class="hero-sub">값을 함수 목록에 좌에서 우로 통과시킵니다 — 타입은 동적입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    FxTS에서 <code>pipe(x, f, g, h)</code>는 커링된, 타입이 완전히
    유지되는 파이프라인입니다. TypeScript는 오버로드와 제네릭 트릭을
    충분히 동원할 수 있어서 각 단계에서 흘러나오는 타입을 추론합니다.
    <strong>Dart는 이렇게 할 수 없습니다.</strong> 가변 인자 제네릭
    오버로드 같은 수단이 없기 때문에, FxDart의 <code>pipe</code>는
    이 절충을 솔직하게 드러냅니다. 평범한
    <code>List&lt;Function&gt;</code>을 받아 <code>dynamic</code> 값을
    순서대로 각 함수에 흘려보낼 뿐입니다. 각 함수는 앞 함수가 반환한
    값을 그대로 받으며, 그 사이에 정적 타입 검사는 없습니다.
  </p>
  <p>
    그래도 <code>pipe</code>는 잘 동작하고, 짧게 쓰고 버릴 변환이라면
    읽기도 좋습니다 — 다만 타입이 맞지 않는 단계는 <em>런타임</em>에야
    실패하고, 파이프라인 전체의 결과 타입도 그저 <code>dynamic</code>일
    뿐입니다. 목록 안의 어떤 단계가 <code>Future</code>를 반환하면
    <code>pipe</code>가 알아서 await한 뒤 다음 단계에 값을 넘기므로,
    동기 함수와 비동기 함수를 한 목록에 섞어 둘 수 있습니다.
  </p>
  <p>
    오래 두고 유지할 코드라면 <code>fx()</code> 체인을 쓰는 편이
    낫습니다. <code>fx(x).map(f).filter(g)</code>는 타입이 완전히
    유지되고, 자동 완성이 되며, 타입 불일치를 컴파일 시점에 잡아냅니다 —
    바로 이런 파이프라인의 타입 있는 대안입니다. <code>pipe</code>는
    단계 구성 자체가 동적일 때(예: 런타임에 만들어진 함수 목록에서
    조립할 때)나 빠르게 프로토타이핑할 때 꺼내 쓰세요.
    <code>pipeLazy</code>는 같은 개념을 지연시킨 것으로, 즉시 실행하는
    대신 나중에 호출할 함수를 반환합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>FxDart의 data-first 함수들로 조립한 짧은 파이프라인입니다.</p>
  {{playground:0}}

  <h2>데모 2 · 감추지 않은 단점</h2>
  <p>
    타입이 맞지 않는 단계도 컴파일은 멀쩡히 통과하고, 실제로 실행될 때
    비로소 터집니다 — <code>fx()</code> 체인은 정확히 이걸 막으려고
    있습니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 숫자 리스트를 필터 단계와 합계 단계에 통과시켜 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fx.html"><code>fx</code></a> — 타입이 유지되는 체인 대안 ·
    <a href="pipe1.html"><code>pipe1</code></a> — 동기/비동기를 모두 다루는 단일 파이프 단계 ·
    <a href="toList.html"><code>toList</code></a> — 파이프의 흔한 마지막 단계
  </div>
