---
slug: zip3
title: zip3 — FxDart 101
description: FxDart zip3 튜토리얼: zip의 세 이터러블 버전 — (A, B, C) 레코드를 내놓고 가장 짧은 입력에서 멈춥니다. 라이브 플레이그라운드 포함.
heading: <code>zip3</code>
section: 6
crumb: zip3
prev: zip.html
prevLabel: zip
next: zipWith.html
nextLabel: zipWith
---
  <p class="hero-sub">세 개의 이터러블을 나란히 걷습니다 — 입력이 하나 더 붙은 <a href="zip.html"><code>zip</code></a>.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>zip3</code>는 이터러블이 하나 더 붙은
    <a href="zip.html"><code>zip</code></a>입니다.
    <a href="zip.html"><code>zip</code></a> 페이지가 설명하는 내용은 그대로
    적용됩니다 — 한 걸음에 레코드 하나, 지연 평가, 그리고 입력 중
    <em>어느 하나라도</em> 떨어지는 순간 멈추므로 결과 길이는 셋 중 가장
    짧은 것을 따릅니다. 원소 타입은 Dart 레코드 <code>(A, B, C)</code>이니
    인덱스가 아니라 패턴 매칭으로 분해하세요.
  </p>
  <p>
    별도의 함수로 존재하는 이유는 Dart에 가변 제네릭이 없기 때문입니다.
    이터러블의 리스트를 받는 단일 <code>zip</code>은 입력별 타입을 지워야
    하는데, <code>(A, B, C)</code>야말로 이 결과를 쓸모 있게 만드는
    핵심이니까요. <a href="tee.html"><code>tee</code></a> 옆에
    <code>tee3</code>가 있는 것과 같은 이유입니다.
  </p>
  <p>
    알아 둘 비대칭이 하나 있습니다. <code>zip</code>에는 체인 메서드가
    있지만(<code>fx(a).zip(b)</code>) <code>zip3</code>에는 없습니다 —
    체인의 수신자는 하나인데 <code>zip3</code>는 대등한 셋을 필요로 하니까요.
    최상위 함수로 호출한 뒤 결과를 <code>fx()</code>로 감싸 이어 가세요.
    데모의 마지막 줄이 그 방식입니다. <code>zip3Async</code>가 비동기
    버전이고, <code>zipAsync</code>와 마찬가지로 셋의 <code>next()</code>를
    모두 발행한 뒤에 기다리므로, 레코드마다 소스들을 차례로가 아니라
    병렬로 끌어당깁니다.
  </p>

  <h2>데모 · 입력 셋, 한 걸음에 레코드 하나</h2>
  {{playground:0}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="zip.html"><code>zip</code></a> — 두 이터러블 버전, 그리고 전체 설명 ·
    <a href="zipWith.html"><code>zipWith</code></a> — 짝짓는 대신 결합하기 ·
    <a href="transpose.html"><code>transpose</code></a> — 개수 제한 없는 이터러블, 대신 원소 타입이 같아야 함
  </div>
