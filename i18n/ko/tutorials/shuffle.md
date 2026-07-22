---
slug: shuffle
title: shuffle — FxDart 101
description: FxDart shuffle 튜토리얼: 재현 가능한 순서를 위한 시드를 옵션으로 받는 Fisher-Yates 셔플, 동기와 비동기 모두를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>shuffle</code>
section: 12
crumb: shuffle
next: createSeededRandom.html
nextLabel: createSeededRandom
---
  <p class="hero-sub">원소 순서를 뒤섞은 새 리스트를 반환합니다 — 시드를 넘기면 결과를 재현할 수 있습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>shuffle</code>은 <code>iterable</code>의 원소에 Fisher-Yates 셔플을
    적용해 완전히 새로운 <code>List&lt;T&gt;</code>를 반환합니다 —
    입력은 절대 변경되지 않습니다. 시드 없이 호출하면
    <code>dart:math</code>의 <code>Random</code>을 사용하므로 호출할 때마다
    순서가 달라집니다. 카드 덱을 섞거나 퀴즈 문항을 무작위로 배치할 때
    기대하는 그대로입니다.
  </p>
  <p>
    <code>int</code> 타입의 <code>seed</code>를 넘기면 시드 기반 PRNG로
    전환됩니다(FxTS가 쓰는 것과 같은 Mulberry32 계열 생성기를 Dart로
    포팅했습니다). 그래서 <em>같은 시드는 언제나 같은 순서를 만들어냅니다</em> —
    어떤 실행에서든, 어떤 머신에서든 마찬가지입니다. 이 결정성 덕분에
    시드 셔플은 재현 가능한 테스트 픽스처, 오늘의 시드를 가진 모두가 같은
    배치를 보게 되는 "일일 챌린지" 퍼즐, 무작위 시뮬레이션의 결정적 리플레이
    같은 곳에 유용합니다.
  </p>
  <p>
    <code>shuffleAsync</code>는 <code>*Async</code> 짝입니다. 내부적으로
    <code>toListAsync</code>를 통해 <code>FxAsyncIterable</code>을 먼저
    구체화한 다음 그 결과를 섞기 때문에, 같은 시드를 주면 시드 기반 비동기
    셔플은 동기 버전과 완전히 동일한 순서를 만들어냅니다.
  </p>

  <h2>데모 1 · 시드로 얻는 결정성</h2>
  <p>같은 시드라면 언제나 같은 순서입니다. 시드가 다르면 순서도 달라지지만,
    그 순서 역시 재현 가능합니다:</p>
  {{playground:0}}

  <h2>데모 2 · shuffleAsync는 동기와 같은 순서를 내고, 원소는 하나도 잃지 않습니다</h2>
  <p>
    소스가 동기든 비동기든 같은 시드면 순서가 동일합니다 — 그리고 입력의
    모든 원소는 순서만 바뀐 채 그대로 남아 있습니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이 턴 순서에 시드를 주어, 매번 무작위로 바뀌는 대신 앱을 재시작해도
    재현되도록 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="throttle.html"><code>throttle</code></a> — 콜백에 대한 호출 빈도 제한 ·
    <a href="debounce.html"><code>debounce</code></a> — 조용해질 때까지 기다리는 빈도 제한 ·
    <a href="toAsync.html"><code>toAsync</code></a> — shuffleAsync에 쓰도록 리스트를 끌어올리기 ·
    <a href="sort.html"><code>sort</code></a> — 정반대의 발상: 결정적인 순서
  </div>
