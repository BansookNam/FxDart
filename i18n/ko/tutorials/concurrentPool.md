---
slug: concurrentPool
title: concurrentPool — FxDart 101
description: FxDart concurrentPool 튜토리얼: 고정 크기 풀로 요청을 진행시키면서 완료 순서대로 결과를 내보내는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>concurrentPool</code>
section: 11
crumb: concurrentPool
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">concurrent와 같지만 결과를 완료 순서대로 내보냅니다 — 먼저 끝난 것이 먼저 나옵니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>concurrentPool(n)</code>은 <code>concurrent(n)</code>과 똑같이 상류
    소스에 대해 최대 <code>n</code>개의 요청을 진행 상태로 유지합니다. 다만
    결과를 돌려주는 순서가 시작한 순서가 아니라 <strong>완료</strong> 순서라는
    점이 다릅니다. 워커 풀을 떠올리면 됩니다. 슬롯이 하나 비는 즉시 대기 중인
    다음 항목이 그 자리에 투입되고, 먼저 끝난 것이 먼저 나옵니다. FxTS의
    <code>concurrentPool</code>과 동일한 동작이며, 어떤 결과가 어떤 입력에서
    나왔는지는 중요하지 않고 그저 준비되는 대로 결과에 반응하고 싶을 때
    (예: 각 fetch가 도착할 때마다 진행 목록을 갱신할 때) 적합합니다. 순서를
    지키려고 가장 느린 항목을 기다릴 필요가 없습니다.
  </p>
  <p>
    하류의 요구 마커에 의해 구동되는 <code>concurrent</code>와 달리,
    <code>concurrentPool</code>은 <strong>적극적으로 풀을 가득 채웁니다</strong>.
    첫 pull부터 소비자가 몇 개를 기다리든 상관없이 최대 <code>n</code>개의
    요청을 계속 진행 상태로 유지합니다. 그래서 <code>.toArray()</code>나
    <code>.each()</code>처럼 한 번에 하나씩만 당겨 가는 종결 연산자도 온전한
    중첩 실행 효과를 얻으며, 결과는 끝나는 순서대로 보게 됩니다.
  </p>

  <h2>데모 1 · 완료 순서</h2>
  <p>항목 1이 가장 느리고(300ms) 항목 2가 가장 빠릅니다(100ms). 결과는
    <code>.toArray()</code>에서 곧바로 빠른 것부터 나옵니다.</p>
  {{playground:0}}

  <h2>데모 2 · concurrent와의 비교</h2>
  <p>지연 시간도 같고 풀 크기도 3으로 같습니다. 차이는 오직 결과가 도착하는
    순서뿐입니다.</p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 풀 크기가 1인 이 코드는 항목을 시작 순서대로 하나씩 처리합니다.
    3으로 올려 세 개가 동시에 경쟁하게 만들고, 출력 순서가 완료 순서로
    바뀌는 것을 확인해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — 순서를 보존하는 변형 ·
    <a href="toAsync.html"><code>toAsync</code></a> — 이 동작이 기반으로 삼는 pull 기반 모델 ·
    <a href="streams.html">Stream 브리지</a> — toStream() 앞에 concurrentPool 적용하기 ·
    <a href="debounce.html"><code>debounce</code></a> — 콜백에 대한 호출 빈도 제한
  </div>
