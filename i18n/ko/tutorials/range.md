---
slug: range
title: range — FxDart 101
description: FxDart range 튜토리얼: 위로도 아래로도 셀 수 있는 정수의 지연 시퀀스를 만들어 체인에 흘려보내는 방법을 익힙니다.
heading: <code>range</code>
section: 2
crumb: range
prev: consume.html
prevLabel: consume
next: repeat.html
nextLabel: repeat
---
  <p class="hero-sub">시작값(포함)부터 끝값(미포함)까지 원하는 간격으로 증가하는 정수의 지연 시퀀스입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>range</code>는 <code>sync*</code> 제너레이터를 사용해 필요할 때마다
    정수를 만들어 냅니다 — 미리 할당해 두는 것은 없습니다. 인자를 하나만 주면
    <code>range(4)</code>는 <code>0, 1, 2, 3</code>을 세고(즉 <code>0</code>부터
    <code>start</code> 직전까지), 두 개를 주면 <code>range(1, 4)</code>는
    <code>1, 2, 3</code>을 셉니다. 세 번째 인자는 간격을 정하는데,
    <em>음수</em> 간격을 주면 거꾸로 셀 수도 있습니다. 예를 들어
    <code>range(4, 1, -1)</code>은 <code>4, 3, 2</code>를 냅니다.
  </p>
  <p>
    지연 평가되기 때문에 <code>range(1000000)</code>을 만드는 비용은 사실상
    없습니다 — 백만 개의 정수는 하류(보통 <code>.take(n)</code>)에서 실제로
    끌어당길 때만 생성됩니다. 그래서 <code>range</code>는 지연 평가를 보여 줄 때
    가장 먼저 꺼내 드는 소스이며, 실제 컬렉션을 먼저 만들지 않고도 "앞의 N개"가
    필요할 때 쓰기 좋은 대체 수단입니다.
  </p>
  <p>
    FxTS의 <code>range</code>도 숫자에 대한 유한 제너레이터인데, 이 포팅 역시
    같은 계약을 유지합니다 — 여기에는 무한 형태가 없습니다(그건
    <code>cycle</code>의 몫입니다). 끝없이 이어지는 카운터가 필요하다면
    <code>range</code>를 <code>cycle</code>, <code>take</code>와 함께 쓰세요.
  </p>

  <h2>데모 1 · 올라가기, 내려가기, 간격 두고 세기</h2>
  {{playground:0}}

  <h2>데모 2 · 체인 속의 지연 평가</h2>
  <p>
    <code>range(1000000)</code>은 미리 아무것도 만들지 않습니다 —
    <code>take(4)</code>가 요구하는 원소 4개만 실제로
    <code>map</code>을 거칩니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>range</code>의 간격 인자를 써서 2부터 10까지(10 포함)의
    짝수를 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="repeat.html"><code>repeat</code></a> — 고정된 값을 n번 반복 ·
    <a href="cycle.html"><code>cycle</code></a> — 시퀀스 전체를 무한히 반복 ·
    <a href="take.html"><code>take</code></a> — 범위에서 얼마나 끌어올지 제한 ·
    <a href="fx.html"><code>fx</code></a> — range를 대개 감싸게 되는 체인
  </div>
