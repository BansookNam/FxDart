---
slug: separated
title: rights, lefts, separated로 가르기 — FxDart 101
description: FxDart separated 튜토리얼: 성공만 풀거나, 실패만 풀거나, Either 이벤트 체인을 양쪽 반으로 가르기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>rights</code>, <code>lefts</code> &amp; <code>separated</code>
section: 14
crumb: separated
prev: mapEither.html
prevLabel: mapEither
next: share.html
nextLabel: share
---
  <p class="hero-sub"><code>Either</code> 값의 이벤트 체인을 위한 Either 인식 연산자 — 한쪽만 풀거나, 양쪽을 한 번에 가릅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    체인이 <code>FxEvents&lt;Either&lt;L, R&gt;&gt;</code>가 되면 —
    <code><a href="attempt.html">attempt</a></code>나
    <code><a href="mapEither.html">mapEither</a></code>에서 —
    이 세 연산자는
    <code><a href="eitherPipelines.html">FxEitherOps</a></code>의
    푸시 쪽 짝입니다.
    <code>rights()</code>는 성공만, 풀어서 남기고;
    <code>lefts()</code>는 실패만, 풀어서 남기고;
    <code>separated()</code>는
    <code>(failures, successes)</code>로 가릅니다 —
    <code>Either</code> 모양의
    <code><a href="partition.html">partition</a></code>입니다.
  </p>
  <p>
    터미널은 여기 없습니다. <code>pull()</code>이 체인을
    <code>FxAsync</code>에 넘기고, 거기에는 이미
    <code>sequence()</code>와
    <code>flattenOrAccumulate()</code>가 있습니다. 이 연산자들은
    이벤트 레이어에 머물러, UI가 성공과 실패를 두 피드로
    들을 수 있게 합니다.
  </p>
  <p>
    <code>separated()</code>는 <code>partition</code>의 수명
    규칙을 물려받습니다. 레코드는 즉시 반환되고, 어느 쪽이든
    듣기 시작하면 소스가 시작되고, 양쪽을 취소하면 소스가
    취소되고, 아무도 듣지 않는 쪽에 속한 값은 버퍼되지 않고
    버려집니다.
  </p>
  <p>
    <code>partition</code>의 에러 팬아웃도 물려받습니다. 에러
    <em>이벤트</em>는 <code>Either</code>가 아니므로 지금 듣고
    있는 모든 쪽으로 갑니다 — 위쪽 실패 하나가 양쪽 반에
    나타납니다. 실패를 한 번만, <code>failures</code> 반의
    <code>Left</code>로 세려면 위쪽에 <code>attempt</code>를
    두세요.
  </p>

  <h2>데모 1 · rights와 lefts</h2>
  {{playground:0}}

  <h2>데모 2 · separated가 양쪽 반을 가릅니다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: 에러 이벤트는 양쪽 반으로 퍼지고, 위쪽
    <code>attempt</code>는 한 번만 셉니다.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="eitherPipelines.html">Either × 파이프라인</a> — 풀 쪽 쌍둥이, 그리고 <code>sequence</code>와 <code>flattenOrAccumulate</code> ·
    <a href="partition.html"><code>partition</code></a> — <code>separated()</code>의 술어 사촌 ·
    <a href="attempt.html"><code>attempt</code></a> — 에러 이벤트를 변환해 failures 반에서 한 번만 세기
  </div>
