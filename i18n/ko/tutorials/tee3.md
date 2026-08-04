---
slug: tee3
title: tee3 — FxDart 101
description: FxDart tee3 튜토리얼: tee의 세 폴드 버전 — 소스를 한 번만 순회하며 세 개의 리덕션을 굴립니다. 라이브 플레이그라운드 포함.
heading: <code>tee3</code>
section: 6
crumb: tee3
prev: tee.html
prevLabel: tee
next: ifEmpty.html
nextLabel: ifEmpty
---
  <p class="hero-sub">한 번의 순회로 세 개의 폴드를 굴립니다 — 리덕션이 하나 더 붙은 <a href="tee.html"><code>tee</code></a>.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>tee3</code>는 폴드가 하나 더 붙은
    <a href="tee.html"><code>tee</code></a>입니다.
    <a href="tee.html"><code>tee</code></a> 페이지가 설명하는 내용은 그대로
    적용됩니다 — 다음 원소를 당기기 전에 각 원소가 모든 누산기를
    전진시키므로 소스는 정확히 한 번만 순회되고 버퍼링도 없으며, 누산기들은
    서로 독립적이고 타입이 같을 필요도 없고, 리더는 파이프라인이 아니라
    폴드여야 합니다. 그 이유와,
    <a href="fork.html"><code>fork</code></a>가 더 나은 선택인 경우는 그
    페이지를 먼저 읽어 보세요.
  </p>
  <p>
    Dart에는 가변 제네릭이 없어서 각 항수(arity)가 별도의 함수가 됩니다 —
    <a href="zip.html"><code>zip</code></a> 옆에 <code>zip3</code>가 있는 것과
    같은 이유입니다. 이름을 붙일 만한 경우는 둘과 셋까지이고, 그 이상이라면
    직접 만든 작은 레코드나 클래스로 접으면서 평범한
    <a href="fold.html"><code>fold</code></a>를 쓰세요.
  </p>

  <h2>데모 · 한 번 읽어서 얻는 합계, 최댓값, 개수</h2>
  <p>
    <code>sensor()</code>는 자기가 내놓은 값의 수를 셉니다. 따로 세 번
    순회했다면 <code>reads</code>는 18이 되지만, <code>tee3</code>는 6에서
    멈춥니다:
  </p>
  {{playground:0}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="tee.html"><code>tee</code></a> — 두 폴드 버전, 그리고 전체 설명 ·
    <a href="fork.html"><code>fork</code></a> — 버퍼를 대가로 한 독립 리더 ·
    <a href="fold.html"><code>fold</code></a> — 폴드 하나
  </div>
