---
slug: createSeededRandom
title: createSeededRandom — FxDart 101
description: FxDart createSeededRandom 튜토리얼: 재현 가능한 셔플과 테스트를 위한 결정론적 시드 기반 PRNG를 라이브 플레이그라운드와 함께 배웁니다.
heading: <code>createSeededRandom</code>
section: 12
crumb: createSeededRandom
prev: shuffle.html
prevLabel: shuffle
---
  <p class="hero-sub">결정론적인 시드 기반 난수 생성기 — 재현 가능한 셔플을 떠받치는 엔진입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>createSeededRandom(seed)</code>는 <code>[0, 1)</code> 범위의
    의사 난수 double을 만들어 내는, 인자 없는 함수를 반환합니다. 생성되는
    수열은 시드에 의해 완전히 결정됩니다. 같은 시드로 만든 두 생성기는
    어떤 플랫폼에서든 정확히 같은 수를 같은 순서로 내놓습니다.
  </p>
  <p>
    FxTS 내부의 <code>seededRandom</code>(Mulberry32 계열 PRNG)을 포팅한
    것입니다. FxTS에서는 비공개지만 FxDart는 이를 공개합니다. 결정론적
    난수는 쓸모가 많기 때문입니다. 재현 가능한 테스트, 안정적인 데모
    데이터, 실패를 그대로 재생할 수 있는 속성 기반 퍼징 등
    "무작위지만 매번 동일해야 하는" 상황이라면 어디에나 어울립니다.
    <a href="shuffle.html"><code>shuffle</code></a>에 시드를 넘겼을 때
    내부에서 쓰는 것도 바로 이 함수입니다.
  </p>
  <p>
    <code>dart:math</code>의 <code>Random(seed)</code>와 달리, 이 수열은
    FxTS와 맺은 라이브러리 계약의 일부입니다 — 같은 시드라면 FxDart와
    FxTS의 시드 기반 <code>shuffle</code>은 같은 순서를 만들어 냅니다.
  </p>

  <h2>데모 1 · 같은 시드, 같은 수열</h2>
  {{playground:0}}

  <h2>데모 2 · 재현 가능한 뽑기와 셔플</h2>
  <p>
    생성기를 필요한 형태의 난수로 바꿔 쓰면 됩니다 — 여기서는 주사위
    굴리기와 시드 기반 <code>shuffle</code>입니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 같은 시드로 양쪽을 만들어 완전히 동일한 "무작위" 패
    두 벌을 나눠 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="shuffle.html"><code>shuffle</code></a> — 이 생성기 위에 올린 시드 기반 셔플 ·
    <a href="cycle.html"><code>cycle</code></a> &amp; <a href="repeat.html"><code>repeat</code></a> — 결정론적인 무한 소스
  </div>
