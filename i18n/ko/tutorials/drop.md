---
slug: drop
title: drop — FxDart 101
description: FxDart drop 튜토리얼: 지연 파이프라인에서 앞쪽 n개의 값을 건너뛰는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>drop</code>
section: 5
crumb: drop
prev: takeUntilInclusive.html
prevLabel: takeUntilInclusive
next: dropRight.html
nextLabel: dropRight
---
  <p class="hero-sub">앞쪽 <code>length</code>개의 값을 건너뛰는 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>drop</code>은 <code>take</code>의 반대입니다. 앞쪽
    <code>length</code>개의 값을 버리고 그 뒤의 값을 모두 내보냅니다. 물론
    지연 평가라서 파이프라인에서 실제로 값을 끌어당기기 전까지는 아무것도
    건너뛰지 않으며, 정해진 개수만 세고 나면 나머지는 그대로 흘려보내기
    때문에 무한 소스에서도 문제없이 동작합니다.
  </p>
  <p>
    <code>Fx</code> 체인에서는 <code>drop</code>을 <code>skip</code>이라는
    이름으로도 쓸 수 있습니다. Dart의 <code>Iterable.skip</code> 명명을 그대로
    따른 것입니다(FxDart의 <code>Fx</code>는 이미 <code>Iterable</code>을
    확장하므로 두 이름 모두 같은 연산자로 이어집니다).
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 앞쪽 헤더 2줄을 버려 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="take.html"><code>take</code></a> — 반대로 앞쪽 n개만 남깁니다 ·
    <a href="dropRight.html"><code>dropRight</code></a> — 뒤쪽에서 버립니다 ·
    <a href="dropWhile.html"><code>dropWhile</code></a> — 술어로 버립니다 ·
    <a href="slice.html"><code>slice</code></a> — 임의의 인덱스 구간
  </div>
