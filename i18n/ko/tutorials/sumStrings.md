---
slug: sumStrings
title: sumStrings — FxDart 101
description: FxDart sumStrings 튜토리얼 — 이차 시간이 드는 fold 대신 Iterable.join으로 모든 문자열을 한 번에 이어 붙입니다. 라이브 플레이그라운드 포함.
heading: <code>fxSumStrings</code>
section: 7
crumb: sumStrings
prev: join.html
prevLabel: join
next: groupBy.html
nextLabel: groupBy
---
  <p class="hero-sub">문자열판 <code>sum</code> — 이차 시간 fold가 아니라 선형 시간으로 이어 붙입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>fxSumStrings(xs)</code>는 이터러블의 모든 문자열을 사이에 아무것도
    넣지 않고 이어 붙입니다. 빈 입력은 이어 붙이기의 항등원인
    <code>''</code>를 반환합니다. 아무것도 없는 것의 <code>sum</code>이
    <code>0</code>인 것과 같습니다. 인자가 하나뿐이라
    <code><a href="pipe.html">pipe</a></code>에 그대로 끼워 넣을 수
    있습니다.
  </p>
  <p>
    가장 떠올리기 쉬운 구현은
    <code>fold('', (acc, s) =&gt; acc + s, xs)</code>이고 — fxdart도 한때
    그렇게 했습니다. 하지만 Dart 문자열은 불변이라 <code>+</code>를 할
    때마다 누적값 전체를 새 문자열로 복사하므로, fold의 비용은 출력 길이의
    <em>제곱</em>으로 늘어납니다. <code>fxSumStrings</code>는
    <code>Iterable.join()</code>이며 각 조각을 한 번씩만 씁니다. 변경
    기록에 남은 측정치(10자 문자열 20,000개):
    <strong>74,620 µs → 343 µs</strong>.
  </p>
  <p>
    체인 멤버도, 비동기 버전도 없습니다. 동기 체인에서는
    <code>fx(xs).join()</code>이 같은 호출입니다 — <code>Fx.join</code>은
    기본 구분자가 <code>''</code>인 Dart의 <code>Iterable.join</code>이기
    때문입니다. <code>FxAsync</code>의 <code>join</code>은 기본값이
    <code>','</code>(FxTS의 기본값)이므로 빈 구분자를 명시하세요:
    <code>.join('')</code>.
  </p>

  <h2>데모 1 · 기본, 그리고 대체하는 fold</h2>
  {{playground:0}}

  <h2>데모 2 · 체인에서, 동기와 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이차 시간 fold를 호출 하나로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="join.html"><code>join</code></a> — 같은 일을 구분자와 함께 ·
    <a href="sum.html"><code>sum</code></a> — 숫자 버전 ·
    <a href="fold.html"><code>fold</code></a> — 이걸로 문자열을 잇지 말아야 하는 이유
  </div>
