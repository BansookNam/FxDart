---
slug: curried
title: curried &amp; uncurried — FxDart 101
description: FxDart curried 튜토리얼: 확장 게터로 구현한 완전한 타입의 커링 — FxTS curry를 대신하는 Dart다운 방식을 라이브 플레이그라운드와 함께 배웁니다.
heading: <code>.curried</code> &amp; <code>.uncurried</code>
section: 10
crumb: curried &amp; uncurried
prev: unicodeToArray.html
prevLabel: unicodeToArray
next: toAsync.html
nextLabel: toAsync
---
  <p class="hero-sub">확장 게터로 제공하는 완전한 타입의 커링 — FxTS <code>curry</code>를 대신하는 Dart다운 방식입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    커링은 인자가 여러 개인 함수를 단항 함수의 연쇄로 바꿉니다.
    <code>add(1, 2)</code>가 <code>add.curried(1)(2)</code>가 되는 식입니다.
    이렇게 얻는 것이 <strong>부분 적용</strong>입니다 — 첫 인자를 고정하면
    새 함수가 나오고, 이는 <code>map</code>이나 <code>filter</code> 같은
    함수가 원하는 콜백 형태와 정확히 일치합니다.
  </p>
  <p>
    FxTS는 이를 <code>curry(f)</code>라는 함수로 제공하는데, 여기에는 Dart에
    없는 두 가지가 쓰입니다. 런타임 항수 리플렉션(<code>fn.length</code>)과
    재귀적 조건부 타입입니다. 그래서 FxDart는 항수(2–5)마다 확장을 하나씩
    선언하고 모두 동일한 <code>curried</code> 게터를 노출한 뒤, 함수의
    <em>정적</em> 타입을 보고 컴파일러가 알맞은 것을 고르게 합니다.
    FxTS가 런타임에 하던 항수 분기가 컴파일 타임에 일어나는 셈이며,
    그 결과는 캐스트 하나 없이 완전한 타입을 유지합니다.
    <code>add.curried(1)</code>은 그 자체로 <em>진짜</em>
    <code>int Function(int)</code>입니다.
  </p>
  <p>
    <code>.uncurried</code>는 그 역입니다. 단항 함수의 연쇄를 다시 하나의
    다인자 함수로 펼칩니다. 연쇄가 두 단계보다 깊게 중첩된 경우에는 가장
    깊게 일치하는 항수가 선택되므로, 더 적은 단계만 펼치려면 확장을 명시적으로
    적용하면 됩니다(<code>Uncurry2(f).uncurried</code>). 게터 이름이 왜
    <code>curry</code>가 아니라 <code>curried</code>인지를 포함한 설계 전반의
    이야기는
    <a href="https://github.com/BansookNam/FxDart/blob/main/WHY_CURRIED.md">WHY_CURRIED.md</a>에 있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 파이프라인에서의 부분 적용</h2>
  <p>
    커링된 이항 함수는 래퍼 클로저 없이 <code>map</code>에 그대로
    들어갑니다:
  </p>
  {{playground:1}}

  <h2>데모 3 · <code>uncurried</code>로 왕복하기</h2>
  <p>
    직접 작성한 커링 클로저도 data-first 형태로 되돌릴 수 있으며,
    <code>curried</code>와 <code>uncurried</code>는 정확한 역함수 관계입니다:
  </p>
  {{playground:2}}

  <h2>직접 해 보기</h2>
  <p>연습: 아래 <code>clamp</code>에 <code>.curried</code>를 써서
    <code>clampTo100</code> 함수를 만들고, 리스트에 map으로 적용해 보세요.</p>
  {{playground:3}}

  <div class="callout">
    <strong>참고:</strong> 연쇄는 철저히 단항입니다 — FxTS의 혼합 적용
    <code>add(1, 2)(3)</code>에 해당하는 것은 없습니다. 명명된 매개변수나
    선택적 매개변수, 그리고 타입이 그냥 <code>Function</code>인 값은
    확장에 매칭되지 않으니 그런 곳에는 클로저를 쓰세요. deprecated된
    최상위 <code>curry</code> 스텁은 FxTS 마이그레이션을 이쪽으로
    안내하기 위해서만 남아 있습니다.
  </div>

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="pipe.html"><code>pipe</code></a> — 부분 적용된 함수의 주된 소비자인 합성 ·
    <a href="identity.html"><code>identity</code></a> &amp; <a href="always.html"><code>always</code></a> — 함수 형태를 다루는 다른 도우미들 ·
    <a href="apply.html"><code>apply</code></a> — 리스트를 위치 인자로 펼쳐 넘깁니다
  </div>
