---
slug: fx
title: fx — FxDart 101
description: FxDart fx 튜토리얼: 지연 체인 모델인 fx, fxAsync, fxStream과 종결 연산자가 값을 끌어당기기 전까지 아무것도 실행되지 않는 이유를 살펴봅니다.
heading: <code>fx</code>
section: 1
crumb: fx
next: pipe.html
nextLabel: pipe
---
  <p class="hero-sub">시퀀스를 지연 평가되는 체인 가능한 파이프라인으로 감쌉니다 — 타입이 살아 있는 FxDart의 심장부입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    이 코스의 모든 내용은 결국 하나의 개념, <strong>체인</strong>으로 모입니다.
    <code>fx(iterable)</code>은 임의의 <code>Iterable&lt;T&gt;</code>를
    <code>Fx&lt;T&gt;</code>로 감쌉니다 — <code>.map()</code>,
    <code>.filter()</code>, <code>.take()</code>처럼 FxTS 스타일의 메서드가
    달려 있는 객체입니다. 이 호출들은 하나같이 지연 계산을 조금씩 더 얹은
    <em>새로운</em> <code>Fx</code>를 반환할 뿐, 아직 아무것도 실행하지
    않습니다. <code>Fx</code>가 실제로 일을 시작하는 시점은
    <strong>종결 연산자</strong>를 호출할 때입니다 — <code>toArray()</code>,
    <code>each()</code>, <code>consume()</code>, <code>reduce()</code> 등이
    체인 전체를 통해 값을 하나씩, 종결 지점에서 소스까지 거슬러 끌어당깁니다.
  </p>
  <p>
    이 지연 평가 덕분에 FxDart는 아주 크거나 무한한 시퀀스
    (<code>range</code>, <code>cycle</code>, <code>repeat</code>) 위에서도
    안전하게 체인을 이어 갈 수 있습니다. 하류의 무언가가 — 보통은
    <code>take(n)</code>이 — 실제로 몇 개를 끌어당길지 정해 주기만 하면,
    상류 단계는 딱 그만큼만 실행됩니다.
  </p>
  <p>
    <code>fx</code>는 체인의 <em>동기</em> 쪽 절반입니다. 비동기 짝으로는
    <code>FxAsyncIterable</code>(<code>toAsync</code>,
    <code>fromStream</code>, 혹은 <code>*Async</code> 계열 함수에서 얻는 것)을
    감싸는 <code>fxAsync</code>, 그리고 Dart의 <code>Stream</code>을 바로
    감싸는 단축 함수 <code>fxStream</code>이 있습니다. 둘 다
    <code>FxAsync&lt;T&gt;</code> 체인을 반환하며, 이 체인의 메서드는
    <code>Future</code>를 반환하는 함수도 받아들이고, 종결 연산자는 모두
    <code>await</code>할 수 있는 <code>Future</code>를 반환합니다. 체인 중간에
    동기에서 비동기로 넘어가려면 <code>.toAsync()</code>를 쓰면 됩니다.
  </p>
  <p>
    그냥 <code>map(f, iterable)</code> 같은 최상위 함수를 호출하면 될 텐데
    왜 이런 게 필요할까요? Dart로는 FxTS의 TypeScript처럼 가변 인자
    <code>pipe</code>에 타입을 붙일 수 없기 때문입니다(다음 강의 참고).
    <code>fx()</code> 체이닝은 그 대신 FxDart가 완전한 타입과 자동 완성이
    살아 있는 파이프라인을 얻는 방법입니다.
  </p>

  <h2>데모 1 · 종결 연산자 전까지는 아무것도 실행되지 않습니다</h2>
  <p>체인을 만든 직후에는 <code>calls</code>가 0에 머물러 있다가,
    <code>toArray()</code>가 실제로 값 5개를 끌어당기는 순간 올라가는 것을 보세요.</p>
  {{playground:0}}

  <h2>데모 2 · fxAsync와 fxStream</h2>
  <p>
    <code>fxAsync</code>는 <code>FxAsyncIterable</code>(여기서는
    <code>toAsync</code>로 만든 것)을 감싸고, <code>fxStream</code>은
    <code>Stream</code>을 바로 감쌉니다. 둘 다 같은 체인 메서드를 비동기
    버전으로 제공합니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 60점 이상인 점수만 남기고, 보너스 점수로 두 배를 한 뒤,
    앞의 2개 결과만 가져오는 체인을 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="pipe.html"><code>pipe</code></a> — 동적 타입 방식의 대안입니다 ·
    <a href="toArray.html"><code>toArray</code></a> — 가장 흔히 쓰는 종결 연산자입니다 ·
    <a href="each.html"><code>each</code></a> — 부수 효과를 위한 종결 연산자입니다 ·
    <a href="consume.html"><code>consume</code></a> — 결과를 버리는 종결 연산자입니다
  </div>
