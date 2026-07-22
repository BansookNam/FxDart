---
slug: consume
title: consume — FxDart 101
description: FxDart consume 튜토리얼: 값을 수집하지 않고 지연 체인의 부수 효과만 강제로 실행하는 방법과 선택적인 개수 제한을 다룹니다.
heading: <code>consume</code>
section: 1
crumb: consume
prev: each.html
prevLabel: each
next: range.html
nextLabel: range
---
  <p class="hero-sub">체인을 통해 값을 끌어당긴 뒤 그대로 버립니다 — 부수 효과만을 위한 연산자이며, 개수를 제한할 수도 있습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>consume</code>은 가장 단순한 종결 연산자입니다. 체인을 통해 값을
    끌어당기면서 상류에 있는 <code>peek</code>이나 <code>mapEffect</code>
    단계의 부수 효과를 실행하지만, 값을 수집하거나 전달하지 않고 전부
    버립니다. 파이프라인의 목적 자체가 부수 효과이고 <code>toList</code>로
    <code>List</code>를 만드는 것이 그저 낭비되는 할당일 뿐일 때 쓰면
    됩니다.
  </p>
  <p>
    선택 인자 <code>n</code> 덕분에 무한하거나 아주 큰 소스와도 잘 어울립니다.
    <code>consume(5)</code>는 정확히 5개의 값만 끌어당기고 멈추므로, 바탕이
    되는 이터러블이 (상한 없는 <code>range</code>, <code>cycle</code>, 개수가
    엄청난 <code>repeat</code>처럼) 끝없이 이어지더라도 문제가 없습니다.
    유한한 이터러블을 끝까지 비우려면 <code>n</code>을 생략하세요.
  </p>
  <p>
    <code>consumeAsync</code>(또는 <code>FxAsync</code> 체인의
    <code>.consume()</code>)도 같은 방식으로 동작하며, 끌어당긴 값의 부수
    효과를 차례로 await합니다. 어차피 버릴 결과 리스트를 수집하는 비용을
    치르지 않고 비동기 <code>peek</code>/로깅 파이프라인을 실제로 실행시키고
    싶을 때 유용합니다.
  </p>

  <h2>데모 1 · 무한 소스에 상한 두기</h2>
  <p>
    <code>range(1000000)</code>은 전부 끌어당기면 사실상 끝나지 않지만,
    <code>consume(5)</code>는 5개를 처리한 뒤 멈춥니다.
  </p>
  {{playground:0}}

  <h2>데모 2 · 비동기 부수 효과, 결과 리스트 없이</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 사실상 무한한 <code>repeat()</code>에서 앞의 3개 값만 consume 하고,
    끌어당길 때마다 로그를 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="each.html"><code>each</code></a> — 마찬가지로 f를 실행하는 종결 연산자, 다만 n 제한은 없음 ·
    <a href="toList.html"><code>toList</code></a> — 대신 결과를 수집하는 종결 연산자 ·
    <a href="cycle.html"><code>cycle</code></a> — consume과 자주 짝을 이루는 무한 소스 ·
    <a href="peek.html"><code>peek</code></a> — consume이 주로 강제 실행시키는 지연 부수 효과 단계
  </div>
