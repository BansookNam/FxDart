---
slug: concurrent
title: concurrent — FxDart 101
description: FxDart concurrent 튜토리얼: 순서를 유지한 채 비동기 원소 n개를 한 번에 평가하는 방법과 동시성 마커 모델을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>concurrent</code>
section: 11
crumb: concurrent
next: concurrentPool.html
nextLabel: concurrentPool
---
  <p class="hero-sub">비동기 파이프라인의 원소를 최대 n개까지 한 번에 평가하면서도, 결과는 소스 순서 그대로 도착합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>concurrent(n)</code>은 "여러 비동기 단계를 병렬로 실행하되 결과 순서는
    유지하고 싶다"는 요구에 대한 FxDart의 답입니다. 동작의 핵심은
    <strong>동시성 마커</strong> 모델이며, 이는
    <code>FxAsyncIterator.next([Concurrent? concurrent])</code>에 내장되어
    있습니다. <code>.concurrent(3)</code>을 호출하면,
    이 연산자를 거치는 모든 pull이 <code>Concurrent(3)</code> 마커를
    <em>상류</em>로 한 단계씩 전달하면서 값을 만들어 내는 쪽에게 "하나씩 말고
    한 번에 3개를 평가하라"고 알립니다. 상류 연산자(보통은 지연 평가되는
    <code>map</code>)는 이 마커를 보고, Future 하나를 await한 뒤 그다음 것을
    시작하는 대신 자기 소스의 <code>next()</code>를 중간에 기다리지 않고 세 번
    호출합니다. 그 결과 Future 세 개가 동시에 진행됩니다. 각각이 완료되는 대로
    <code>concurrent</code>는 결과를 버퍼에 담아 두고, <em>호출자</em>에게는 원래
    순서대로만 값을 내보냅니다. 그래서 뒤쪽 항목이 앞쪽보다 먼저 끝나더라도
    결과는 언제나 입력 순서와 일치합니다.
  </p>
  <p>
    이것이 <code>toAsync</code> 강의에서 언급했던 역채널입니다. Dart의
    <code>Stream</code>은 나중에 상류 소스에게 "한 번에 3개를 달라"고 요청할
    방법이 없습니다. <code>Stream</code>은 자기 페이스대로 값을 밀어내기
    때문입니다. FxDart의 pull 기반
    <code>next()</code> 프로토콜은 매 pull마다 그 요청을 상류로 실어 나르며,
    이것이 바로 <code>concurrent(n)</code>을 가능하게 하는 기반입니다.
  </p>
  <p>
    <code>n</code>은 무엇에 병목이 걸리는지에 따라 조절하세요. REST API라면
    동시 요청 5~10개 정도는 견딜 수 있고, 로컬 CPU 바운드 작업이라면
    <code>n</code>을 코어 수에 가깝게 두는 편이 좋습니다. <code>n = 1</code>은
    순차적으로 await하는 것과 같으며, 이는 <code>concurrent</code>를 아예 쓰지
    않았을 때의 동작과 정확히 같습니다.
  </p>

  <h2>데모 1 · 순차 실행과 concurrent(3) 비교, 시간 측정</h2>
  <p>각각 200ms가 걸리는 항목 6개입니다. 순차 실행은 약 1200ms가 걸리지만,
    한 번에 3개씩 요청하면 약 400ms로 줄어듭니다.</p>
  {{playground:0}}

  <h2>데모 2 · 완료 순서가 달라도 결과 순서는 유지됩니다</h2>
  <p>
    여기서는 항목 2가 항목 1보다 먼저 끝나지만(100ms 대 300ms),
    <code>concurrent(3)</code>은 여전히 소스 순서대로 결과를 돌려줍니다.
    정반대로 동작하는 <a href="concurrentPool.html"><code>concurrentPool</code></a>과
    비교해 보세요.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이 파이프라인은 각각 200ms가 걸리는 항목 6개를 순차적으로
    (<code>n = 1</code>) 처리합니다. <code>n</code>을 올려 가며 경과 시간이
    줄어드는 것을 확인해 보세요. <code>3</code>으로, 그다음 <code>6</code>으로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — 완료 순서로 내보내는 변형 ·
    <a href="toAsync.html"><code>toAsync</code></a> — 이 동작이 기반으로 삼는 pull 기반 모델 ·
    <a href="asyncVariants.html">async 변형</a> — *Async 명명 규칙 ·
    <a href="map.html"><code>map</code></a> — concurrent와 가장 자주 함께 쓰이는 연산자
  </div>
