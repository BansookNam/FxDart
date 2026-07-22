---
slug: flat
title: flat — FxDart 101
description: FxDart flat 튜토리얼: 중첩된 이터러블을 원하는 깊이만큼 평탄화하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>flattened</code>
section: 3
crumb: flattened
prev: flatMap.html
prevLabel: flatMap
next: scan.html
nextLabel: scan
---
  <p class="hero-sub">중첩된 이터러블을 지정한 깊이만큼 평탄화합니다 — 문자열은 건드리지 않습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>flat</code>은 중첩된 이터러블 구조를 훑으면서 안쪽 원소를 바깥
    시퀀스에 이어 붙입니다. <code>depth</code> 단계까지 내려가며,
    기본값은 <code>1</code>입니다. <code>Iterable</code>이기만 하면
    "평탄화 대상"으로 보지만, <em>단</em> <code>String</code>만은 예외입니다 —
    그래서 <code>flat(['ab', ['cd']])</code>는 <code>'ab'</code>를 글자
    단위로 쪼개지 않고 그대로 둡니다.
  </p>
  <p>
    <strong>왜 <code>Iterable&lt;dynamic&gt;</code>이며, 왜 그래도 괜찮은가:</strong>
    TypeScript의 <code>flat</code>에는 "N단계를 평탄화한 뒤의 원소 타입"을
    표현할 수 있는 <code>DeepFlat</code> 조건부 타입이 있습니다. Dart의
    타입 시스템에는 이에 대응하는 장치가 없습니다 — 입력이 어떤 모양으로
    중첩되어 있는지는 런타임에야 알 수 있으므로 정적 원소 타입을 안전하게
    계산할 방법이 없습니다. 성립하지 않는 제네릭으로 거짓말을 하는 대신,
    Dart 포팅판은 이를 솔직히 인정하고 <code>Iterable&lt;dynamic&gt;</code>을
    반환합니다. 평탄화하려는 데이터의 모양을 알고 있고 타입이 붙은 결과를
    원한다면 <a href="flatMap.html"><code>flatMap</code></a>을 쓰세요.
    <code>flatMap((row) =&gt; row, matrix)</code>라고 쓰면 정확히 한 단계
    깊이의 균일한 데이터를 타입이 유지된 채로 평탄화할 수 있습니다.
  </p>
  <p>
    FxTS의 <code>flat</code>과 마찬가지로 <code>flatAsync</code>도 값이
    도착한 시점에 이미 <em>동기</em> <code>Iterable</code>인 중첩만 파고듭니다 —
    중첩 컬렉션 안에 들어 있는 <code>Future</code>를 await하지는 않습니다.
    중첩된 리스트들을 병렬로 가져오고 싶다면 상류에
    <code>.map(...).concurrent(n)</code> 단계를 두고, 이미 완료된 결과들을
    <code>.flat()</code>으로 이어 붙이면 됩니다.
  </p>

  <h2>데모 1 · 기본 사용법과 깊이</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  <p>
    (이미 중첩되어 있는) 결과들을 동시에 가져온 다음, 완료된 리스트들을
    평탄화합니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>flat()</code>으로 <code>scoreGroups</code>를 한 단계
    평탄화해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="flatMap.html"><code>flatMap</code></a> — 타입이 유지되는 map + 평탄화를 한 번에 ·
    <a href="map.html"><code>map</code></a> — 평탄화 없이 변환만 ·
    <a href="scan.html"><code>scan</code></a> — 단계별 누적 연산 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
