---
slug: unicodeToArray
title: unicodeToArray — FxDart 101
description: FxDart unicodeToArray 튜토리얼: 이모지 같은 서로게이트 페어까지 올바르게 처리하면서 문자열을 사람이 인식하는 문자 단위로 나눕니다.
heading: <code>unicodeToArray</code>
section: 10
crumb: unicodeToArray
prev: delay.html
prevLabel: delay &amp; sleep
next: curried.html
nextLabel: curried &amp; uncurried
---
  <p class="hero-sub">서로게이트 페어를 올바르게 처리하면서 문자열을 사람이 인식하는 문자 단위로 나눕니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    Dart의 <code>String</code>은 문자가 아니라 UTF-16 <em>코드 유닛</em>의
    나열입니다. <code>s.split('')</code>은 코드 유닛 단위로 자르기 때문에
    평범한 ASCII/라틴 문자에는 문제가 없지만, 기본 다국어 평면(BMP)을 벗어난
    문자, 예컨대 대부분의 이모지에서는 결과가 어긋납니다. 그런 문자는
    <strong>서로게이트 페어</strong>(코드 유닛 두 개)로 표현되므로, 단순한
    split은 이모지 하나를 깨진 반쪽 두 개로 찢어 놓습니다.
  </p>
  <p>
    <code>unicodeToArray</code>는 문자열의 <code>.runes</code>, 즉 유니코드
    코드 포인트를 순회하면서 각각을 다시 한 글자짜리 <code>String</code>으로
    되돌려 이 문제를 해결합니다. 결과는 사람이 문자열을 읽을 때 실제로 보는
    문자들의 목록이며, UTF-16 유닛이 아니라 코드 포인트 단위로 나누는 FxTS의
    <code>unicodeToArray</code>와 동일하게 동작합니다.
  </p>

  <h2>데모 1 · 단순 split과 unicodeToArray 비교</h2>
  {{playground:0}}

  <h2>데모 2 · 뒤집기와 개수 세기를 제대로 하기</h2>
  <p>
    <code>unicodeToArray</code>를 바탕으로 하면, 단순 split으로 뒤집었을 때
    망가지던 이모지가 그대로 유지됩니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이 문자열에 사람이 인식하는 문자가 몇 개인지 세어 보세요
    (이모지가 포함되어 있습니다).</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="split.html"><code>split</code></a> — 평범한 문자 이터러블 기준으로 나누기 ·
    <a href="reverse.html"><code>reverse</code></a> — Iterable 뒤집기, 문자열에는 동일한 서로게이트 페어 주의가 필요합니다 ·
    <a href="countBy.html"><code>countBy</code></a> — 위에서 문자 개수를 집계할 때 사용 ·
    <a href="identity.html"><code>identity</code></a> — 위에서 집계 키로 사용
  </div>
