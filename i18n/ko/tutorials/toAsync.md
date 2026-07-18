---
slug: toAsync
title: toAsync — FxDart 101
description: FxDart toAsync 튜토리얼: 평범한 Iterable을 FxAsyncIterable로 끌어올리고 pull 기반 비동기 모델을 이해하는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>toAsync</code>
section: 11
crumb: toAsync
next: asyncVariants.html
nextLabel: async variants
---
  <p class="hero-sub">값이든 Future든, 평범한 Iterable을 FxDart 비동기 파이프라인의 출발점인 FxAsyncIterable로 끌어올립니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    FxDart의 모든 비동기 파이프라인은 <code>toAsync</code>에서 시작합니다.
    평범한 <code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code> — 값의 리스트든,
    Future의 리스트든, 둘이 섞여 있든 — 를 받아서 모든 <code>*Async</code>
    연산자와 <code>FxAsync</code> 체인이 이해하는 타입인
    <code>FxAsyncIterable</code>로 감쌉니다. 원소가 <code>Future</code>인 경우에는
    끌어당기는 시점에 자동으로 await됩니다.
  </p>
  <p>
    <code>FxAsyncIterable</code>은 <strong>pull 기반</strong>입니다. 종결
    연산자(<code>toArrayAsync</code>, <code>eachAsync</code>,
    <code>FxAsync</code> 체인의 <code>.toArray()</code> 등)가
    <code>next()</code>를 호출하기 전까지는 아무것도 실행되지 않고, 한 번에 한
    단계씩만 진행됩니다 — 평범한 <code>Iterable</code>과 똑같되 비동기라는
    점만 다릅니다. 이는 Dart의 <code>Stream</code>과 의도적으로 갈라지는
    지점입니다. 스트림은 <em>push</em> 기반이라, 일단 값을 내보내기 시작하면
    스스로 페이스를 정하며, 하류 소비자가 "이 중 3개를 한 번에 평가해 달라"고
    말할 방법이 없습니다. FxDart의
    <code>next([Concurrent? concurrent])</code> 프로토콜이 바로 그 역채널을
    더해 줍니다. <code>concurrent(n)</code> 같은 하류 연산자가 매 pull마다
    마커를 <em>상류</em>로 실어 보내 소스에게 <code>n</code>개를 병렬로 실행하라고
    요청할 수 있습니다. 스트림에는 이에 해당하는 훅이 없으며, FxDart가
    <code>Stream</code> 위에 얹는 대신 자체 비동기 이터러블을 정의한 이유도
    오로지 이것입니다.
  </p>
  <p>
    날것의 <code>Iterable&lt;FutureOr&lt;T&gt;&gt;</code>에는 최상위 함수
    <code>toAsync(iterable)</code>을, 이미 만들어 둔 <code>Fx</code> 체인을
    <code>FxAsync</code> 체인으로 전환할 때는 체인 메서드
    <code>fx(iterable).toAsync()</code>를 쓰세요. 둘 다 지연 평가되므로,
    파이프라인을 구성하는 것만으로는 무엇도 실행되지 않고 누군가 값을 끌어당겨야
    비로소 움직입니다.
  </p>

  <h2>데모 1 · 값, Future, 그리고 체인 형태</h2>
  <p><code>toAsync</code>는 평범한 값도, Future도, 둘이 섞인 것도 받습니다 —
    체인 형태는 이미 있는 <code>Fx</code>에서 같은 일을 합니다.</p>
  {{playground:0}}

  <h2>데모 2 · pull 기반 모델이 중요한 이유</h2>
  <p>
    Dart에서 <code>Future</code>는 await하는 시점이 아니라 생성되는 즉시
    실행을 시작합니다. 그래서 리스트 리터럴 안에서 미리 만들어진 Future 세 개는
    <code>toAsync</code>가 손대기도 전에 이미 함께 달리고 있습니다. 반면
    <code>mapAsync</code>(또는 체인의 <code>.map</code>)는 원소를 실제로
    <em>끌어당길 때</em> 비로소 원소마다 새 Future를 하나씩 만듭니다 —
    <code>concurrent(n)</code>을 붙이지 않는 한, 지연 평가로 하나씩 말이죠.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 아래 리스트를 필터링해서 합격 점수(&gt;= 60)만 결과에 남도록
    해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="asyncVariants.html"><code>*Async</code> 명명 규칙</a> — mapAsync, filterAsync, … ·
    <a href="streams.html">Stream 브리지</a> — fromStream, fxStream, toStream ·
    <a href="concurrent.html"><code>concurrent</code></a> — 역채널이 실제로 동작하는 모습 ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — 비동기 데모 만들기
  </div>
