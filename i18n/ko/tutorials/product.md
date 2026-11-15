---
slug: product
title: product — FxDart 101
description: FxDart product와 productBy 튜토리얼 — 모든 숫자(또는 각 원소의 키)를 곱합니다. 빈 입력은 1, 정수는 정수 그대로, 동기와 비동기 모두. 라이브 플레이그라운드 포함.
heading: <code>fxProduct</code> · <code>fxProductBy</code>
section: 7
crumb: product
prev: sumByDouble.html
prevLabel: sumByDouble
next: average.html
nextLabel: average
---
  <p class="hero-sub">곱셈판 <code>sum</code> — 그리고 빈 입력은 <code>0</code>이 아니라 <code>1</code>입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>fxProduct(xs)</code>는 이터러블의 모든 숫자를 곱하고,
    <code>fxProductBy(f, xs)</code>는 각 원소의 숫자 키를 곱합니다 —
    <code>map</code> + <code>product</code>를 한 번의 순회로 처리하는,
    <code><a href="sumBy.html">sumBy</a></code>의 짝입니다. 둘 다
    종단 연산이라 입력 전체를 끌어와 <code>num</code> 하나를 반환합니다.
  </p>
  <p>
    빈 입력은 곱셈의 항등원인 <strong><code>1</code></strong>을
    반환합니다. 아무것도 없는 것의 <code>sum</code>이 <code>0</code>인
    것과 같은 이유입니다. 한쪽이 비어 있어도
    <code>product(xs + ys) == product(xs) * product(ys)</code>를 참으로
    유지하는 값은 이것뿐입니다. 만약 <code>0</code>이 돌아온다면, 배치를
    청크로 나눴을 때 빈 청크가 하나라도 있으면 전체 결과가 0이 되어
    버립니다.
  </p>
  <p>
    누적 방식은 <code>sum</code>과 같습니다. 모든 값이 <code>int</code>인
    동안 결과는 <code>int</code>이고, 처음 <code>double</code>이 나타나면
    그때까지의 누계를 시작값으로 <code>double</code>로 전환합니다 — 박싱된
    <code>num acc *= v</code>가 가질 값과 정확히 같습니다. 체인에서는
    <code>fx(numbers).product()</code>와
    <code>fx(items).productBy(f)</code>이며, 비동기 버전
    (<code>fxProductAsync</code>, <code>fxProductByAsync</code>, 그리고
    <code>FxAsync</code>의 같은 이름)은 <code>Future</code>를 반환하는 키
    함수도 받습니다. fxdart 확장 기능입니다(FxTS에는 <code>sum</code>은
    있지만 <code>product</code>는 없습니다).
  </p>

  <h2>데모 1 · 기본, 빈 입력과 int 대 double</h2>
  {{playground:0}}

  <h2>데모 2 · productBy와 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 곱하는 반복문을 호출 하나로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="sum.html"><code>sum</code></a> · <a href="sumBy.html"><code>sumBy</code></a> — 덧셈 쌍, 빈 입력은 <code>0</code> ·
    <a href="fold.html"><code>fold</code></a> — 그 밖의 모든 누적, 시작값은 직접 ·
    <a href="average.html"><code>average</code></a> — 다음 숫자 집계
  </div>
