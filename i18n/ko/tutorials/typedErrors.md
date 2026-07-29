---
slug: typedErrors
title: 타입 있는 에러 — FxDart 101
description: FxDart 타입 있는 에러 가이드: either 빌더, Raise 스코프, bind와 ensure, NonEmptyList 에러 누적, 파이프라인 융합 검증.
heading: 타입 있는 에러
section: 13
crumb: typed errors
---
  <p class="hero-sub">
    <strong>타입 있는</strong> 에러로 실패하는 일직선 코드를 작성하세요.
    FxDart 0.6 신기능 — Kotlin
    <a href="https://arrow-kt.io" rel="noopener">Arrow&nbsp;2.x</a>의 접근
    방식을 Dart로 이식했습니다.
  </p>

  {{signature}}

  <h2>Kotlin Arrow에서 Dart로</h2>
  <p>
    Kotlin Arrow의 <code>either { }</code> 블록은 실패할 수 있는 단계들의
    연쇄를 일직선 코드로 바꿔 줍니다 — 각 <code>.bind()</code>는 성공 값을
    풀어내거나, 실패와 함께 블록 전체를 단락시킵니다:
  </p>
  <pre class="code"><code>// Kotlin Arrow
fun getResult(): Either&lt;Failure, SuccessData&gt; = either {
    val user  = findUser(userId).bind()
    val order = findOrder(user.id).bind()
    val total = calculateTotal(order).bind()
    SuccessData(user, order, total)
}</code></pre>
  <p>FxDart 0.6은 Dart에서 같은 모양을 제공합니다:</p>
  <pre class="code"><code>// FxDart
Either&lt;Failure, SuccessData&gt; getResult() => either((r) {
  final user  = r.bind(findUser(userId));
  final order = r.bind(findOrder(user.id));
  final total = r.bind(calculateTotal(order));
  return SuccessData(user, order, total);
});</code></pre>
  <p>
    둘 다, 이렇게 쓸 수밖에 없었던 중첩 <code>flatMap</code> 피라미드를
    대체합니다:
  </p>
  <pre class="code"><code>// 이것을 대체합니다
Either&lt;Failure, SuccessData&gt; getResult() =>
    findUser(userId).flatMap((user) =>
        findOrder(user.id).flatMap((order) =>
            calculateTotal(order).map((total) =>
                SuccessData(user, order, total))));</code></pre>
  <p>
    Kotlin과의 차이 두 가지는 Dart의 현실입니다. Dart에는 람다 리시버가
    없으므로 스코프가 명시적 매개변수(<code>r</code>)로 전달되고,
    <code>inline</code>이 없으므로 비동기는 별도의 빌더
    (<code>eitherAsync</code>)를 사용합니다. 내부 구현은 flatMap 연쇄가
    <em>아닙니다</em>. Arrow와 마찬가지로, 실패한 <code>r.bind</code>는
    스코프 토큰이 달린 비공개 신호를 던지고 빌더가 경계에서 잡아냅니다 —
    그래서 이른 반환, 반복문, <code>if</code>가 블록 안에서 전부 그대로
    동작하고, 중첩된 빌더가 서로의 에러를 가로채는 일도 없습니다.
  </p>

  <h2>스코프 어휘</h2>
  <p>
    모든 것이 빌더가 건네주는 <code>r</code>에 달려 있습니다 —
    <code>r.</code>을 입력하면 전부 발견할 수 있습니다:
  </p>
  <pre class="code"><code>Either&lt;String, int&gt; parsePort(String raw) => either((r) {
  final n = r.ensureNotNull(int.tryParse(raw), () => '"$raw"는 숫자가 아닙니다');
  r.ensure(n &gt; 0 &amp;&amp; n &lt; 65536, () => '$n은 범위를 벗어났습니다');
  return n;
});

switch (parsePort('8080')) {
  case Right(:final value): print('$value 포트에서 대기 중');
  case Left(:final value):  print('잘못된 설정: $value');
}</code></pre>
  <ul>
    <li><code>r.bind(either)</code> / <code>r.bindAll(eithers)</code> —
      풀어내거나 단락합니다.</li>
    <li><code>r.ensure(cond, () => err)</code> — 타입 있는 에러 버전의
      <code>require</code>.</li>
    <li><code>r.ensureNotNull(x, () => err)</code> — non-null을 반환하며 null
      승격이 일어납니다.</li>
    <li><code>r.recover(block, onRaise)</code> — 중첩 스코프에서 raise된
      에러를 처리합니다.</li>
    <li><code>r.withError(transform, block)</code> — 다른 에러 타입을 이
      스코프에 맞게 변환합니다.</li>
    <li><code>r.raise(err)</code> — 에러를 직접 발생시키는 가장 기본적인
      방법입니다. 호출하는 순간 블록 실행이 그 자리에서 멈추고, 그 에러가
      곧바로 <code>Left</code>가 되어 반환됩니다. 반환 타입이
      <code>Never</code>이므로 "이 지점 이후의 코드는 절대 실행되지 않는다"는
      사실을 컴파일러도 알고 있습니다.</li>
  </ul>
  <p>
    <code>eitherAsync</code>는 비동기 쌍둥이이고(raise는 같은 await 체인
    안에서만), <code>nullable</code>/<code>nullableAsync</code>는
    <code>Either</code> 대신 <code>T?</code>를 돌려주는 nullable 우선
    쌍둥이입니다 — FxDart는 nullable 우선이므로 <code>Option</code> 타입은
    없습니다.
  </p>

  <h2>첫 실패만이 아니라 모든 실패를 모으기</h2>
  <p>
    검증에는 첫 번째 에러가 아니라 <em>모든</em> 에러가 필요합니다. 별도의
    <code>Validated</code> 타입을 대체하는 Arrow의 방식입니다:
  </p>
  <pre class="code"><code>final user = either&lt;Nel&lt;String&gt;, User&gt;((r) => r.accumulate((acc) {
  final name = acc.accumulating((r) => validateName(r, input));
  final age  = acc.accumulating((r) => validateAge(r, input));
  return User(name.value, age.value); // 모든 에러가 한 번에 보고됩니다
}));</code></pre>
  <p>
    <code>r.accumulate</code>는 모든 분기를 실행하고 실패 전부를
    <code>NonEmptyList</code>(<code>Nel</code>)로 이어 붙입니다 — 비어 있을
    수 없는 제로 비용 확장 타입입니다. 고정 인자 편의 함수
    <code>r.zipOrAccumulate2..5</code>가 흔한 경우를 담당하고,
    <code>r.mapOrAccumulate(items, transform)</code>는 컬렉션 전체를
    fail-slow로 검증합니다. <code>r.bindNel</code>은 한 분기가 여러 에러를
    한꺼번에 보태게 해 주고, <code>someEither.toEitherNel()</code>은
    fail-fast 값을 누적 스코프로 이어 줍니다.
  </p>

  <h2>파이프라인과의 융합</h2>
  <p>
    Arrow에도, 다른 Dart FP 라이브러리에도 없는 부분입니다. 타입 있는 에러가
    FxDart의 지연·동시성 파이프라인과 융합됩니다.
  </p>
  <pre class="code"><code>// 레코드 500건을 한 번에 8건씩 검증하고, 모든 실패를 순서대로 보존합니다.
final result = await fxStream(records)
    .mapOrAccumulate&lt;String, User&gt;((r, rec) async {
  final parsed = r.ensureNotNull(tryParse(rec), () => '잘못된 레코드: $rec');
  return await enrich(parsed);
}, concurrency: 8);</code></pre>
  <p>
    <code>rights()</code>, <code>lefts()</code>, <code>separated()</code>,
    <code>sequence()</code>(fail-fast — 첫 <code>Left</code>에서 업스트림
    당기기를 멈춤), <code>mapOrAccumulate()</code>(fail-slow)는
    <code>fx()</code>/비동기 체인의 즉시 실행 터미널입니다. 동시성 검증은
    FxDart의 다른 기능과 똑같이 <code>concurrent(n)</code> 백채널 위에서
    동작하며, 각 요소는 자기만의 스코프에서 실행되므로 한 요소의 실패가 다른
    요소로 새어 나갈 수 없습니다.
  </p>

  <h2>예외 vs raise된 에러</h2>
  <p>
    경계는 단호합니다. <em>raise된</em> 에러는 도메인의 타입 있는 실패이고,
    <em>throw된</em> 예외는 결함이므로 <code>either</code>를 그대로 뚫고
    전파됩니다. throw를 <code>Either</code>로 잡고 싶다면 명시적으로
    선언하세요:
  </p>
  <pre class="code"><code>final parsed = Either.catching(() => jsonDecode(raw));       // Either&lt;Object, dynamic&gt;
final typed  = Either.catchingWith(ParseFailure.new, () => jsonDecode(raw));</code></pre>

  <div class="callout">
    <strong>규칙 두 가지.</strong> (1) raise 블록에서 <em>지연</em>
    파이프라인을 그대로 반환하지 마세요 — <code>toList()</code>로 실체화하거나
    위의 즉시 실행 터미널을 사용하세요. 지연된 raise는
    <code>RaiseLeakedError</code>로 요란하게 실패합니다. (2) raise 블록 안에서
    맨몸 <code>catch</code>를 쓰지 마세요 — 단락 신호를 항상 통과시키는
    <code>catching</code>/<code>catchingAsync</code>를 사용하세요
    (신호는 <code>Error</code>이므로 <code>on Exception</code>은 이미
    안전합니다).
  </div>

  <p>
    왜 이 페이지의 이름에 <a href="monad.html"><em>Monad</em></a> 같은
    함수형 프로그래밍 용어 대신 <em>타입 있는 에러</em>를 썼는지
    궁금하신가요?
    <a href="namingOfTypedErrors.html">이름에 담긴 이유 →</a>
  </p>