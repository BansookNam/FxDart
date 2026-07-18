---
slug: dropUntil
title: dropUntil — FxDart 101
description: FxDart dropUntil 튜토리얼: 처음 술어에 맞는 원소까지 포함해 건너뛴 뒤 나머지를 내보내는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>dropUntil</code>
section: 5
crumb: dropUntil
prev: dropWhile.html
prevLabel: dropWhile
next: slice.html
nextLabel: slice
---
  <p class="hero-sub">술어에 맞을 때까지 값을 건너뛰고 — 맞은 원소까지 함께 버린 뒤 — 나머지를 내보냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>dropUntil</code>은 <code>takeUntilInclusive</code>에 대응하는
    drop 쪽 함수이며, 두 함수는 술어에 맞은 원소를 정반대로 다룹니다.
    <code>dropWhile</code>은 술어가 거짓이 되는 원소 <em>바로 앞에서</em>
    버리기를 멈추므로 그 원소는 결과에 남습니다. 반면
    <code>dropUntil</code>은 술어에 맞은 원소 <em>지점에서</em> 멈추면서 그
    원소까지 앞부분과 함께 버립니다. 오직 그 뒤에 오는 원소만 살아남습니다.
  </p>
  <p>
    구분자 역할을 하는 마커나 센티널을, 그것이 가르는 앞부분과 함께
    없애야 할 때 쓰세요. "<code>READY</code> 줄 다음부터 전부, 단
    <code>READY</code> 자체는 제외"인 경우입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p><code>dropWhile</code>과 비교해 보세요. 여기서는 술어에 맞은 원소
    (<code>3</code> / <code>'STOP'</code>)가 결과에 나타나지 않습니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>'READY'</code>까지 포함해서 그 앞을 모두 버려 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="dropWhile.html"><code>dropWhile</code></a> — 술어에 맞은 원소를 남깁니다 ·
    <a href="takeUntilInclusive.html"><code>takeUntilInclusive</code></a> — take 쪽 대응 함수 ·
    <a href="drop.html"><code>drop</code></a> — 정해진 개수만큼 버립니다
  </div>
