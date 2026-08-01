---
slug: eitherPipelines
title: Either × 파이프라인 — FxDart 101
description: 타입 있는 에러와 파이프라인의 융합을 다루는 FxDart 튜토리얼: rights, lefts, separated, fail-fast sequence, 그리고 동시성을 갖춘 fail-slow mapOrAccumulate.
heading: <code>Either</code> × 파이프라인
section: 13
crumb: Either × pipelines
prev: accumulate.html
prevLabel: accumulation
next: namingOfTypedErrors.html
nextLabel: the naming rationale
---
  <p class="hero-sub">
    타입 있는 에러가 FxDart의 지연·동시성 파이프라인과 융합됩니다 —
    Arrow에도, 다른 어떤 Dart FP 라이브러리에도 없는 부분입니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>Either</code> 값들의 체인은 Either를 이해하는
    <em>종결 연산자</em>를 갖게 됩니다. <code>rights()</code>와
    <code>lefts()</code>는 한쪽만 남기고, <code>separated()</code>는 양쪽을
    한 번에 나누며(<code>partition</code>과 같은 레코드 모양),
    <code>sequence()</code>는 전부 아니면 전무입니다 — 모든 성공을 리스트
    하나로 모으되 첫 <code>Left</code>에서 <em>즉시</em> 실패합니다.
    파이프라인이 지연 평가되므로 fail-fast는 말 그대로입니다.
    <code>sequence()</code>는 첫 실패에서 <em>당기기</em>를 멈추고, 그래서
    뒤쪽 원소는 아예 계산되지 않습니다.
  </p>
  <p>
    fail-slow 쌍둥이는 모든 <code>fx()</code>/비동기 체인에 있는
    <code>mapOrAccumulate(transform)</code>입니다. 모든 원소를 검증하고,
    모든 실패를 보존합니다. 비동기 체인에서는
    <code>concurrency:&nbsp;n</code>을 받아 FxDart의 나머지 기능과 똑같은
    <code>concurrent(n)</code> 백채널 위에서 동작합니다 — n개가 동시에
    진행되고, 결과는 순서대로 나오며, 각 원소는 자기만의 스코프에서
    실행되므로 한 원소의 실패가 다른 원소로 새어 나갈 수 없습니다.
  </p>
  <p>
    이들은 모두 설계상 <em>즉시 실행</em>이며, 그래서 지연 평가 × raise
    위험에서 벗어나는 공인된 탈출구이기도 합니다. raise 블록에서 지연
    파이프라인을 그대로 반환하지 마세요 — 대신 이 결과들 중 하나를
    반환하세요.
  </p>

  <h2>데모 1 · rights, lefts &amp; separated</h2>
  {{playground:0}}

  <h2>데모 2 · sequence — 말 그대로 fail-fast</h2>
  {{playground:1}}

  <h2>데모 3 · 동시성 fail-slow 검증</h2>
  {{playground:2}}

  <h2>데모 4 · flattenOrAccumulate와 비동기 추출 패밀리</h2>
  <p>
    이미 <code>Either</code>들을 <em>가지고</em> 있을 때, fail-slow 터미널은
    <code>mapOrAccumulate((r,&nbsp;v)&nbsp;=&gt;&nbsp;r.bind(v))</code> —
    항등 bind — 로 써야 했습니다. <code>flattenOrAccumulate()</code>(Arrow의
    이름 그대로)가 그 터미널입니다. 모든 성공을, 아니면 <em>모든</em> 실패를
    <code>Nel</code>로 돌려줍니다. 이것으로 삼총사가 완성됩니다 —
    <code>separated()</code>는 양쪽을 다 보존하고, <code>sequence()</code>는
    fail-fast, <code>flattenOrAccumulate()</code>는 fail-slow입니다. 그리고
    비동기 체인에도 이제 추출 패밀리 전체(<code>rights</code> /
    <code>lefts</code> / <code>separated</code> / <code>sequence</code> /
    <code>flattenOrAccumulate</code>)가 있어, 비동기 검증이 터미널 하나로
    카운트 배지를 채웁니다.
  </p>
  {{playground:4}}

  <h2>직접 해 보기</h2>
  <p>
    연습: 파싱된 것은 더하고, 파싱되지 않은 것은 보고해 보세요.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="accumulate.html">에러 누적</a> — 스코프 수준의 fail-slow 어휘 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 비동기 변형이 올라타는 백채널 ·
    <a href="partition.html"><code>partition</code></a> — <code>separated()</code>의 술어 사촌 ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
