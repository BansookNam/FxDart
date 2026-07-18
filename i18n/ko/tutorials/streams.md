---
slug: streams
title: Stream bridges — FxDart 101
description: FxDart의 Stream 브리지 — fromStream, fxStream, toStream()으로 Dart의 Stream과 FxAsyncIterable 사이를 자유롭게 오갑니다. 라이브 플레이그라운드 포함.
heading: Stream bridges
section: 11
crumb: Stream bridges
next: concurrent.html
nextLabel: concurrent
---
  <p class="hero-sub">fromStream, fxStream, .toStream() — Dart의 Stream과 FxDart의 FxAsyncIterable 사이를 자유롭게 오갑니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>fromStream</code>은 단일 구독이든 브로드캐스트든 어떤
    <code>Stream</code>이라도 <code>FxAsyncIterable</code>로 바꿔 줍니다.
    덕분에 소켓이나 파일, 위젯의 이벤트 스트림 등 Dart가
    <code>Stream</code>으로 건네주는 모든 데이터 위에서 FxDart의 연산자
    전체(<code>map</code>, <code>filter</code>, <code>concurrent</code>, …)를
    쓸 수 있습니다. <code>fxStream(stream)</code>도 같은 일을 하지만,
    날것의 <code>FxAsyncIterable</code> 대신 체이닝 가능한
    <code>FxAsync</code>를 바로 반환합니다 — <code>fx</code>와
    <code>fxAsync</code>에 대응하는 비동기 버전인 셈입니다.
  </p>
  <p>
    반대 방향으로는 <code>.toStream()</code>이
    <code>FxAsyncIterable</code>(또는 <code>FxAsync</code> 체인)을 끝까지
    돌리면서 그 값들을 평범한 <code>Stream</code>으로 다시 내보냅니다 —
    다른 API(예컨대 <code>StreamBuilder</code>)가 이를 요구할 때
    유용합니다. 한 가지 주의할 점은
    <code>toStream()</code>이 언제나 <strong>순차적으로</strong>
    값을 끌어당기며, 상류의 <code>concurrent(n)</code>을 무시한다는
    것입니다 — 병렬 처리가 실제로 일어나길 원한다면
    <code>concurrent</code>나 <code>concurrentPool</code>을 체인에
    <em>먼저</em> 적용한 다음 <code>.toStream()</code>을 호출하세요.
    스트림 변환 자체는 병렬성을 더해 주지 않습니다.
  </p>

  <h2>데모 1 · fromStream과 fxStream</h2>
  <p>둘 다 <code>Stream.fromIterable</code>을 감싸므로, 기존 스트림을
    FxDart 연산자에 그대로 흘려보낼 수 있습니다.</p>
  {{playground:0}}

  <h2>데모 2 · 유한한 주기 스트림으로 왕복하기</h2>
  <p>
    <code>Stream.periodic</code>은 스스로 끝나지 않으므로
    <code>.take(n)</code>으로 데모를 유한하게 만듭니다. 후반부는 반대
    방향을 보여 줍니다 — <code>FxAsync</code> 체인을 구성한 다음
    <code>.toStream()</code>으로 다시 평범한 <code>Stream</code>으로
    내보내는 것입니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이 스트림에서 10 이상인 값만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — 스트림 대신 평범한 Iterable을 끌어올리기 ·
    <a href="asyncVariants.html">비동기 변형</a> — *Async 명명 규칙 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 실제 병렬 처리를 원하면 toStream() 이전에 적용 ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — 완료 순서 방식의 변형
  </div>
