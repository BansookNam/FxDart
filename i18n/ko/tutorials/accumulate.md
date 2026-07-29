---
slug: accumulate
title: 에러 누적 — FxDart 101
description: FxDart 에러 누적 튜토리얼: zipOrAccumulate, 누적 분기를 쓰는 accumulate, mapOrAccumulate, bindNel과 toEitherNel — 첫 실패만이 아니라 모든 실패를 모읍니다.
heading: 에러 누적 — <code>zipOrAccumulate</code> &amp; 친구들
section: 13
crumb: accumulation
prev: nonEmptyList.html
prevLabel: NonEmptyList
next: eitherPipelines.html
nextLabel: Either × pipelines
---
  <p class="hero-sub">
    검증에는 첫 번째 에러가 아니라 <em>모든</em> 에러가 필요합니다. 여기
    있는 연산들은 모든 분기를 실행하고 실패를
    <code>NonEmptyList</code>로 이어 붙입니다 — 별도의
    <code>Validated</code> 타입을 대체하는 Arrow 2.x의 방식입니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>either&lt;Nel&lt;E&gt;, _&gt;(...)</code> 안에서 — 에러 타입이
    <code>NonEmptyList</code>인 모든 스코프에서 — 스코프는 누적 어휘를
    갖게 됩니다:
  </p>
  <ul>
    <li><code>r.zipOrAccumulate2..5(branches…, combine)</code> — 서로
      독립적인 분기 N개를 실행하고, 모든 실패를 보고하고, 성공들을
      합칩니다.</li>
    <li><code>r.accumulate((acc) { … })</code> — 일반형입니다.
      <code>acc.accumulating(block)</code>으로 분기를 실행한 뒤 각 결과의
      <code>.value</code>를 읽습니다. 하나라도 실패했다면 값을 읽는
      순간(또는 블록 끝에 도달하는 순간) <em>전체</em> 에러 목록이
      raise됩니다.</li>
    <li><code>r.mapOrAccumulate(items, transform)</code> — 컬렉션 전체를
      fail-slow로 검증합니다.</li>
    <li><code>r.bindNel(eitherNel)</code> — <code>EitherNel</code>을
      풀어내면서 그 안의 모든 에러를 한꺼번에 raise합니다.
      <code>someEither.toEitherNel()</code>은 fail-fast 값을 누적 스코프로
      이어 줍니다.</li>
  </ul>
  <p>
    계약은 Arrow의 것 그대로입니다. 모든 분기가 실행되고(에러는 분기
    순서대로 이어 붙습니다), raise 대신 <em>throw</em>한 분기는 누적보다
    우선하며, 첫 에러가 난 뒤로는 성공 결과를 더 이상 보관하지 않습니다 —
    남은 에러를 모으기 위해 순회만 계속할 뿐입니다.
  </p>

  <h2>데모 1 · zipOrAccumulate2</h2>
  {{playground:0}}

  <h2>데모 2 · accumulate — 일반형</h2>
  {{playground:1}}

  <h2>데모 3 · mapOrAccumulate, bindNel &amp; toEitherNel</h2>
  {{playground:2}}

  <h2>직접 해 보기</h2>
  <p>
    연습: <code>signup</code>의 두 분기를 완성해서 두 번째 호출이
    <em>두</em> 실패를 모두 보고하도록 만들어 보세요.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="nonEmptyList.html"><code>NonEmptyList</code></a> — 에러를 실어 나르는 그릇 ·
    <a href="eitherPipelines.html">Either × 파이프라인</a> — <code>fx()</code> 체인 위에서 동시성과 함께 하는 fail-slow 검증 ·
    <a href="raise.html"><code>either</code> &amp; Raise</a> — 이 기능이 확장하는 fail-fast 스코프 ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
