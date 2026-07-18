---
slug: takeWhile
title: takeWhile — FxDart 101
description: FxDart takeWhile 튜토리얼: 술어가 참인 동안 값을 계속 가져오다가 멈추는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>takeWhile</code>
section: 5
crumb: takeWhile
prev: takeRight.html
prevLabel: takeRight
next: takeUntilInclusive.html
nextLabel: takeUntilInclusive
---
  <p class="hero-sub">술어가 true를 반환하는 동안 값을 내보내다가, 거짓이 되면 그대로 끝냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>take</code>가 개수를 센다면, <code>takeWhile</code>은 값을 검사합니다.
    원소를 하나씩 내보내다가 <em>즉시</em> 멈춥니다 —
    <code>f</code>가 false를 반환하는 바로 그 순간에 말이죠. 그 뒤에 조건에
    맞는 원소가 있더라도 아예 쳐다보지 않습니다.
    그래서 "데이터가 의미를 잃는 지점까지만 소비한다"는 상황에 잘 맞습니다.
    정렬된 스트림을 임계값까지 읽는다든지, 로그를 첫 이상 징후까지 읽는
    경우가 그렇습니다.
  </p>
  <p>
    지연 평가되며 첫 실패에서 단축 평가되기 때문에, 아주 크거나 무한한
    소스 위에서도 부담이 없습니다. 실제로 조건에 맞는 앞부분만 계산합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>맨 뒤의 <code>2</code>는 기회조차 얻지 못합니다 — 술어가 이미
    <code>7</code>에서 실패했기 때문입니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 온도가 25 미만으로 유지되는 동안만 값을 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="take.html"><code>take</code></a> — 술어가 아니라 개수로 가져옵니다 ·
    <a href="takeUntilInclusive.html"><code>takeUntilInclusive</code></a> — 조건에 맞은 원소까지 포함하고 멈춥니다 ·
    <a href="dropWhile.html"><code>dropWhile</code></a> — 정반대 동작 ·
    <a href="filter.html"><code>filter</code></a> — 앞부분만이 아니라 어디서든 맞는 값을 남깁니다
  </div>
