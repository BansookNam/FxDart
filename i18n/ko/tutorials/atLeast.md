---
slug: atLeast
title: atLeast — FxDart 101
description: FxDart atLeast와 atMost 튜토리얼 — 답에 필요한 만큼만 일치 항목을 세고 결정적인 원소에서 멈춥니다. 동기와 비동기 모두 지원.
heading: <code>atLeast</code> · <code>atMost</code>
section: 8
crumb: atLeast
prev: some.html
prevLabel: any
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">"적어도 n개 있는가?" — 전부 세는 대신 n번째 일치에서 멈춰 답합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>countWhere(f) &gt;= 2</code>는 읽기 좋지만, 두 번째 일치가 두 번째
    원소라 해도 입력 전체를 순회합니다.
    <code>atLeast(n, f)</code>는 같은 질문을 하되
    <code>n</code>번째 일치에서 멈춥니다. <code>atMost(n, f)</code>는
    <code>n + 1</code>번째에서 멈추는데, 바로 그 순간 답이
    <code>false</code>가 되기 때문입니다. 길거나 지연된 입력 — range, map을 거친
    파이프라인, 행들의 스트림 — 에서는 나머지를 끝내 당겨오지 않습니다.
  </p>
  <p>
    이미 있는 한정자(quantifier)를 확장한 것입니다.
    <code>atLeast(1, f)</code>는 <code><a href="some.html">any</a></code>이고
    <code>atMost(0, f)</code>는 <code>none</code>입니다. 경계값도 이 관계가
    성립하도록 정의되어 있습니다 — <code>n &lt;= 0</code>인
    <code>atLeast</code>는 <code>true</code>, 음수 <code>n</code>인
    <code>atMost</code>는 <code>false</code>이며, 둘 다 아무것도 읽지
    않습니다. 비동기 형태는 <code>any</code>처럼 결정적인 일치에서
    upstream을 취소합니다. fxdart 확장 기능입니다(FxTS에는 없습니다).
  </p>

  <h2>데모 1 · n번째 일치에서 멈추기</h2>
  {{playground:0}}

  <h2>데모 2 · atMost, 경계값, 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 투표용지를 전부 세지 않고 투표 결과를 판정해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="some.html"><code>any</code></a> — <code>atLeast(1, f)</code> ·
    <a href="every.html"><code>every</code></a> — 전칭 한정자 ·
    <a href="countWhere.html"><code>countWhere</code></a> — 정확한 개수가 필요할 때
  </div>
