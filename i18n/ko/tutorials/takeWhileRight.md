---
slug: takeWhileRight
title: takeWhileRight — FxDart 101
description: FxDart takeWhileRight 튜토리얼: 술어를 만족하는 가장 긴 뒤쪽 구간을 원본 순서 그대로 남기는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>takeWhileRight</code>
section: 5
crumb: takeWhileRight
prev: takeWhile.html
prevLabel: takeWhile
next: takeUntilInclusive.html
nextLabel: takeUntilInclusive
---
  <p class="hero-sub">소스 <em>끝</em>에서 술어가 참인 가장 긴 구간을, 원본 순서 그대로 남깁니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <a href="takeRight.html"><code>takeRight</code></a>가 마지막 <em>n</em>개를
    가져온다면, <code>takeWhileRight</code>는 <em>조건에 맞는</em> 마지막
    원소들을 가져옵니다 — 몇 개가 될지는 결과가 알려줍니다.
    <code>takeRight</code>에 대한 이 연산자의 관계는,
    <a href="takeWhile.html"><code>takeWhile</code></a>가
    <a href="take.html"><code>take</code></a>에 대해 갖는 관계와 같습니다 —
    개수를 받던 자리에 술어가 들어섭니다.
  </p>
  <p>
    맨 끝까지 이어지는 구간만 인정됩니다. 마지막 원소가 이미 조건에서
    떨어지면, 그 바로 앞에 아무리 긴 구간이 있었더라도 결과는 빕니다.
    "어디서든 가장 긴 구간"을 찾는 것이 아니라 접미사(suffix) 연산자인
    이유가 여기에 있습니다.
  </p>
  <p>
    결과는 뒤집히지 않고 <strong>원본 순서</strong>로 돌아옵니다. 그래서
    라이브러리의 다른 연산자와 그대로 이어지고,
    <a href="dropWhileRight.html"><code>dropWhileRight</code></a>와도 아귀가
    맞습니다 — 둘을 합치면 소스가 빠짐없이, 겹침도 없이 둘로 나뉩니다.
  </p>
  <p>
    소스가 끝나기 전에는 아무것도 내보낼 수 없습니다. 마지막 원소가 도착하기
    전까지는 어떤 원소가 접미사에 속하는지 알 수 없기 때문입니다.
    <code>List</code>라면 끝에서부터 거꾸로 훑어 그 구간을 찾으므로 술어는
    해당 구간만 보게 되고, 그 밖의 소스라면 모든 원소를 순서대로 검사하며
    현재 구간을 버퍼에 담습니다. 술어를 순수하게 유지하면 이 차이는
    드러나지 않습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 분할</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 30 이상인 뒤쪽 구간만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="dropWhileRight.html"><code>dropWhileRight</code></a> — 같은 구간을 버리는 반대편 ·
    <a href="takeRight.html"><code>takeRight</code></a> — 개수로 자르는 뒤쪽 구간 ·
    <a href="takeWhile.html"><code>takeWhile</code></a> — 같은 발상을 앞에서 ·
    <a href="filter.html"><code>filter</code></a> — 끝이 아니라 어디서든 맞는 값을 남깁니다
  </div>
