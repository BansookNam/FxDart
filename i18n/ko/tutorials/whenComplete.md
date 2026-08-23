---
slug: whenComplete
title: whenComplete — FxDart 101
description: FxDart whenComplete 튜토리얼: 부수 효과를 peek하고, 갈아타지 않고 handleError하고, 완료나 취소에서 finalize하기 — FxEvents 체인에 머문 채로 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>peek</code>, <code>whenComplete</code> &amp; <code>handleError</code>
section: 14
crumb: whenComplete
prev: fxEventsCreate.html
prevLabel: fxEventsCreate
next: sampleOn.html
nextLabel: sampleOn
---
  <p class="hero-sub">부수 효과, 에러마다 계속하기, finalize 훅 — <code>.stream</code>으로 체인을 벗어나지 않고.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    풀 레이어의 <code><a href="peek.html">peek</a></code>는 값이
    pull될 때 관찰합니다. 이벤트 레이어의
    <code>peek</code>는 푸시 스트림에서 같은 개념에 같은 단어입니다:
    부수 효과를 실행하고, 이벤트는 그대로 통과시킵니다. 선택적
    <code>onError</code> / <code>onDone</code> 훅이 나머지 두 알림을
    덮습니다. 콜백이 throw하면 에러 이벤트가 되고 체인은 계속됩니다
    — peek가 실패한 그 이벤트는 다시 내보내지지 않습니다. fxdart
    이벤트 레이어, Rx의 <code>tap</code> /
    <code>doOn*</code>을 따랐습니다.
  </p>
  <p>
    <code>handleError</code>는 에러마다 계속하는 형태입니다:
    맞는 에러(<code>test</code>를 생략하면 모든 에러)가
    <code>onError</code>를 실행하고 스트림은 계속 갑니다. 소스를
    취소하고 갈아타는
    <code><a href="onErrorResume.html">onErrorResume</a></code>이
    아닙니다. 잡음을 기록하거나 삼킬 때는 handleError를, 연결을
    버릴 때는 onErrorResume를 쓰세요. <code>whenComplete</code>는
    Rx의 <code>finalize</code>입니다: 콜백은 완료에서, 에러에서,
    또는 취소에서 <strong>정확히 한 번</strong> 실행됩니다. throw해도
    체인은 여전히 정리됩니다.
  </p>
  <p>
    체인은 이제 <code>endWith</code>, <code>ifEmpty</code>,
    <code>uniq</code>, <code>takeRight</code>,
    <code>takeWhile</code>에서도 <code>.stream</code>으로 떨어지지
    않습니다 — 이제 <code>FxEvents</code> 메서드입니다.
    <code>uniq</code>는 전역입니다(인접이 아님): 본 값의 집합이
    한없이 자라므로, 오래 사는 피드에 묶이지 않은
    <code>uniq</code>는 메모리 누수입니다. 연속 반복만 걸러야 할
    때는 <code>uniqAdjacent</code>를 쓰세요.
  </p>
  <p>
    fxdart 이벤트 레이어, Rx의 <code>tap</code>,
    갈아타지 않는 모양의 <code>catchError</code>, 그리고
    <code>finalize</code>를 따랐습니다. 이미 같은 뜻을 가진 곳에서는
    풀 레이어 이름이 이깁니다: <code>peek</code>이지
    <code>tap</code>이 아니고, <code>takeRight</code>이지
    <code>takeLast</code>가 아니고, <code>uniq</code>이지
    <code>distinct</code>가 아닙니다.
  </p>

  <h2>데모 1 · 부수 효과로서의 peek</h2>
  {{playground:0}}

  <h2>데모 2 · endWith, 그리고 ifEmpty</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 완료에서, 그리고 취소에서 <code>whenComplete</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="peek.html"><code>peek</code></a> — 값이 pull될 때 관찰하는 풀 레이어의 원본 ·
    <a href="onErrorResume.html"><code>onErrorResume</code></a> — 버리고 갈아타기; <code>handleError</code>는 계속하는 형태 ·
    <a href="tap.html"><code>tap</code></a> — 스트림이 아니라 값 하나의 데이터-퍼스트 부수 효과
  </div>
