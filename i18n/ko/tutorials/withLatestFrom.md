---
slug: withLatestFrom
title: withLatestFrom — FxDart 101
description: FxDart withLatestFrom 튜토리얼: 각 소스 이벤트에 다른 스트림의 최신 값을 도장 찍기 — 컨텍스트 조회를 위한 한쪽 방향 결합 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>withLatestFrom</code>
section: 14
crumb: withLatestFrom
prev: combineLatest.html
prevLabel: combineLatest
next: switchMap.html
nextLabel: switchMap
---
  <p class="hero-sub"><em>소스</em> 이벤트가 올 때마다, 그 이벤트와 다른 스트림의 최신 값에 대한 <code>combine</code> 결과를 내보냅니다 — 다른 쪽은 트리거가 아니라 컨텍스트입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    요청이 발화하면 <em>바로 그 순간</em> 유효했던 설정 버전을 함께
    실어야 합니다. 주문이 들어오면 <em>지금 이 순간</em>의 환율로 가격을
    매겨야 합니다. 두 스트림이 관여하지만 둘은 대등하지 않습니다:
    한쪽이 이끌고, 다른 쪽은 참조됩니다.
    <code>withLatestFrom(other, combine)</code>이 그 비대칭을
    표현합니다 — 각 소스 이벤트는
    <code>combine(event, latestOfOther)</code>를 내보내고,
    <code>other</code>의 이벤트는 기억된 값을 갱신할 뿐
    <strong>아무것도</strong> 내보내지 않습니다.
  </p>
  <p>
    이 한쪽 방향성이 양쪽 모두 트리거하는
    <code><a href="combineLatest.html">combineLatest</a></code>와의 차이
    전부입니다. 이렇게 물어서 고르세요: 설정 갱신이 <em>그 자체로</em>
    출력을 만들어야 하나요? 그렇다면 <code>combineLatest</code>, 설정이
    요청이 마침 발화할 때에만 의미가 있다면
    <code>withLatestFrom</code>입니다.
  </p>
  <p>
    가장자리를 솔직하게 짚어 둡니다. <code>other</code>가 아직 아무것도
    만들어 내기 전에 발화한 소스 이벤트는 <strong>버려집니다</strong> —
    도장 찍을 최신 값이 없기 때문입니다(그 손실이 곤란하다면
    <code>other</code>에 <code>startWith</code> 시드를 주세요). 수명은
    소스를 따릅니다: 소스가 닫히면 체인이 닫히고, <code>other</code>의
    닫힘은 그냥 무시됩니다 — 컨텍스트 쪽의 라이브 피드가 파이프라인을
    붙들어 두는 일은 없습니다. fxdart 이벤트 계층이며, Rx의 같은 이름
    연산자를 따랐습니다.
  </p>

  <h2>데모 1 · 요청에 현재 설정 도장 찍기</h2>
  {{playground:0}}

  <h2>데모 2 · 다른 쪽은 트리거하지도, 막지도 않는다</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 각 주문을 그 순간의 환율로 가격 매기기.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — 양쪽 모두 트리거 ·
    <a href="sampleOn.html"><code>sampleOn</code></a> — 결합 없이 트리거-와-최신 아이디어 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — 컨텍스트 쪽에 시드를 주는 <code>startWith</code>
  </div>
