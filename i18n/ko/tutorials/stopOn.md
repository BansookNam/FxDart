---
slug: stopOn
title: stopOn — FxDart 101
description: FxDart stopOn 튜토리얼: 다른 스트림이 발화하면 이벤트 체인을 끝내고, startOn으로 열기 — 라이브 피드를 위한 취소 게이트 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>stopOn</code> &amp; <code>startOn</code>
section: 14
crumb: stopOn
prev: waitAll.html
prevLabel: waitAll
next: chunkOn.html
nextLabel: chunkOn
---
  <p class="hero-sub">두 번째 스트림이 조종하는 두 개의 게이트: <code>stopOn</code>은 트리거가 발화하면 체인을 닫고, <code>startOn</code>은 엽니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    푸시 체인에는 자연스러운 끝이 없습니다. 풀 파이프라인은 소비자가
    묻기를 멈추면 멈추지만, 라이브 피드 — 소켓, 센서,
    <code>Stream.periodic</code> — 는 무언가가 <em>취소</em>할 때까지
    계속 생산합니다. 그걸 잊는 것이 전형적인 누수입니다: 화면은
    폐기되었고, 위젯은 사라졌는데, 구독은 여전히 깨어 있고, 여전히
    할당하고, 여전히 시체를 향해 <code>setState</code>를 호출합니다.
  </p>
  <p>
    <code>stopOn(trigger)</code>은 종료를 "기억해서 취소해야 하는
    변수"가 아니라 체인의 일부로 만듭니다. <code>trigger</code>의 첫
    이벤트가 출력을 닫고 <strong>두</strong> 구독을 모두 취소합니다 —
    소스의 것과 트리거의 것 모두. 트리거가 무엇을 실어 나르는지는 전혀
    읽지 않고 발화했다는 사실만 보므로, 타입은
    <code>Stream&lt;void&gt;</code>이고 어떤 스트림이든 쓸 수 있습니다.
  </p>
  <p>
    <code>startOn(trigger)</code>은 거울상입니다: 트리거가 한 번
    발화할 때까지 소스 이벤트는 <strong>버려지고</strong>, 그 후로는
    영원히 통과합니다. "준비될 때까지 기다리는" 게이트입니다 — 세션이
    로드되기 전의 탭에는 반응하지 마세요. 값을 앞에 덧붙이는
    <code><a href="fxEvents.html">startWith</a></code>와는 무관하다는
    점에 유의하세요. 두 이름은 가깝게 붙어 있지만 상당히 다른 것을
    뜻합니다.
  </p>
  <p>
    <code>…On</code> 접미사는 "트리거 스트림이 조종한다"는 이벤트
    레이어의 관례로,
    <code><a href="sampleOn.html">sampleOn</a></code>,
    <code><a href="chunkOn.html">chunkOn</a></code>과 공유합니다.
    fxdart 이벤트 레이어, Rx의 <code>takeUntil</code>과
    <code>skipUntil</code>을 따랐습니다 — 이름이 다른 이유는
    <code>Fx.takeUntil</code>이 풀 쪽에서 이미 술어 기반
    <code>takeUntilInclusive</code>를 뜻하기 때문입니다. 한 라이브러리
    안에서 한 이름이 두 가지를 뜻할 수는 없습니다.
  </p>

  <h2>데모 1 · 끄는 스위치</h2>
  {{playground:0}}

  <h2>데모 2 · 켜는 스위치</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 두 게이트로 만드는 세션 윈도.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fxSubscriptions.html"><code>FxSubscriptions</code></a> — 정리의 나머지 절반: 여러 구독을 한 번에 취소 ·
    <a href="sampleOn.html"><code>sampleOn</code></a> — 같은 트리거 관례, 멈추는 대신 읽기 위해 ·
    <a href="race.html"><code>race</code></a> — 누가 먼저 말하는지가 결정하는 취소
  </div>
