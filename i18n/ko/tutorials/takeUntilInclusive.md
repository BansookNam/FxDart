---
slug: takeUntilInclusive
title: takeUntilInclusive — FxDart 101
description: FxDart takeUntilInclusive 튜토리얼 — 처음 조건에 맞는 원소까지 포함해서 값을 가져옵니다. 라이브 플레이그라운드 포함.
heading: <code>takeUntilInclusive</code>
section: 5
crumb: takeUntilInclusive
prev: takeWhile.html
prevLabel: takeWhile
next: drop.html
nextLabel: drop
---
  <p class="hero-sub">술어가 참이 될 때까지 값을 내보냅니다 — 조건에 맞은 원소도 포함됩니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>takeUntilInclusive</code>는 <code>takeWhile</code>과 아주 가까운
    사촌이지만, 의도된 차이가 하나 있습니다. 술어를 참으로 만든 원소까지
    내보낸 뒤에 멈춘다는 점입니다. <code>takeWhile</code>은 조건을
    만족하지 못한 원소 <em>앞에서</em> 멈추고,
    <code>takeUntilInclusive</code>는 조건에 맞은 원소 <em>뒤에서</em>
    멈춥니다. 조건에 맞은 원소 자체가 답의 일부일 때 쓰면 됩니다 —
    "첫 에러까지 포함해서 로그를 읽는다", "종료 표시까지 포함해서 단계를
    모은다" 같은 경우입니다.
  </p>
  <p>
    FxTS에서는 원래 이름이 <code>takeUntil</code>이었습니다. FxDart는
    FxTS와의 대응을 위해 <code>takeUntil</code>(그리고
    <code>takeUntilAsync</code>)을 <code>@Deprecated</code> 별칭으로
    남겨 두었지만, 새로 작성하는 코드는
    <code>takeUntilInclusive</code>를 바로 호출하세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 처음 나오는 <code>'ERROR'</code>까지 포함해서 로그 줄을
    가져와 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="takeWhile.html"><code>takeWhile</code></a> — 조건에 맞은 원소 앞에서 멈추며, 그 원소는 제외합니다 ·
    <a href="dropUntil.html"><code>dropUntil</code></a> — drop 쪽 대응 함수 ·
    <a href="take.html"><code>take</code></a> — 개수로 가져오기
  </div>
