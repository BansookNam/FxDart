---
slug: delay
title: delay &amp; sleep — FxDart 101
description: FxDart delay와 sleep 튜토리얼 — 이 사이트의 모든 비동기 데모를 떠받치는 두 가지 기본 재료를 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>delay</code> &amp; <code>sleep</code>
section: 10
crumb: delay &amp; sleep
prev: comparisons.html
prevLabel: gt · gte · lt · lte
next: unicodeToList.html
nextLabel: unicodeToList
---
  <p class="hero-sub">잠시 기다렸다가 값을 내놓거나(delay), 그냥 기다리기만 합니다(sleep).</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>delay(wait, value)</code>는 <code>wait</code>가 지난 뒤
    <code>value</code>로 완료되는 <code>Future</code>를 반환합니다.
    <code>sleep(wait)</code>은 반환할 값이 없다는 점만 다릅니다 — 그저
    주어진 시간이 지나면 완료됩니다. 둘 다 <code>Future.delayed</code>를
    얇게 감싼 것이며, 느린 작업을 흉내 낼 때 가장 먼저 꺼내 쓰게 되는
    도구입니다. 네트워크 호출, 데이터베이스 쿼리처럼 시간이 걸리고
    결국 결과를 내놓는(또는 내놓지 않는) 모든 작업 말입니다.
  </p>
  <p>
    이 두 함수는 이 튜토리얼 사이트 전반의 거의 모든 비동기 데모를
    떠받치는 뼈대입니다. <code>mapAsync</code>, <code>concurrent</code>,
    <code>debounce</code>, <code>throttle</code>을 <code>Stopwatch</code>와
    함께 보여 주면서 병렬로 실행됐다거나 속도가 제한됐다는 것을 증명하는
    장면이 나오면, 실제로 기다리는 일을 하고 있는 것은 언제나
    <code>delay</code> 아니면 <code>sleep</code>입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 동시 작업 흉내 내기</h2>
  <p>
    각각 150ms가 걸리는 "요청" 세 개를 동시에 실행하면, 전체 묶음은
    450ms보다 한참 짧은 시간에 끝납니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>delay</code>로 <code>'pong'</code>을 반환하는 100ms짜리
    "fetch"를 흉내 내 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="memoize.html"><code>memoize</code></a> — 지연된 Future를 캐시해 한 번만 기다리게 만듭니다 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 여러 delay를 병렬로 실행 ·
    <a href="debounce.html"><code>debounce</code></a> / <a href="throttle.html"><code>throttle</code></a> — 기다림 위에 세운 속도 제한 ·
    <a href="toAsync.html"><code>toAsync</code></a> — 평범한 Iterable을 비동기 파이프라인으로
  </div>
