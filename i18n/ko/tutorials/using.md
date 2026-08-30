---
slug: using
title: using — FxDart 101
description: FxDart using과 usingAsync 튜토리얼: 자원을 한 번의 지연 반복에 묶기 — 첫 pull에 획득하고 정확히 한 번 해제 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>using</code>
section: 11
crumb: using
prev: timeout.html
prevLabel: timeout
next: parallel.html
nextLabel: parallel
---
  <p class="hero-sub">자원을 한 번의 반복에 묶습니다. 첫 pull에 획득하고, 완료 시<em>든</em> 에러 시든 정확히 한 번 해제합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    파일, 소켓, 데이터베이스 커서 — 이들이 만들어 내는 값은 시퀀스지만,
    그 <em>수명</em>은 하나의 괄호(bracket)입니다. 열고, 읽고, 닫기 —
    <em>읽다가 예외가 던져져도 말입니다</em>. 지연 파이프라인 둘레에 그
    괄호를 쓰기는 어색한데, "반복이 끝나는 시점"이 소비자가 어디에 있느냐에
    달려 있기 때문입니다. <code>using(acquire, use, release)</code>는 그
    괄호를 반복 자체에 묶습니다. <code>acquire</code>는 첫 pull에
    실행되고(파이프라인을 만드는 시점이 아닙니다 — 지연 평가가
    보존됩니다), <code>use(resource)</code>가 원소들을 공급하며,
    <code>release(resource)</code>는 마지막 원소 뒤 또는 에러가 전파되기
    직전에 정확히 한 번 실행됩니다.
  </p>
  <p>
    비동기 형태인 <code>usingAsync</code>는 세 단계 모두 비동기일 수
    있게 하며
    <code><a href="concurrent.html">concurrent</a></code>와 조합됩니다 —
    겹쳐 진행 중인 pull이 있어도 해제는 여전히 정확히 한 번만
    일어납니다. <code>acquire</code> 자체가 실패하면 해제할 것이 없으므로
    에러는 그냥 전파됩니다.
  </p>
  <p>
    pull 모델에서 곧장 나오는 솔직한 주의 사항 하나. 반복을
    <em>중도 포기</em>하는 소비자 — <code>for-in</code> 안의
    <code>break</code>, 이터레이터를 그냥 버리는 것 — 는 끝에 도달하지
    않으므로 <code>release</code>가 실행될 수 없습니다.
    <code><a href="take.html">take</a></code>로 반복에 한도를 두거나
    (한도가 있는 파이프라인은 완료되고, 완료는 해제로 이어집니다),
    조기 종료가 계획이라면 <code>try</code>/<code>finally</code>로 자원을
    직접 관리하세요. Dart 고유의 추가 기능입니다(FxTS에는 대응물이
    없습니다). Rx의 <code>using</code>을 따랐습니다.
  </p>

  <h2>데모 1 · 지연 읽기 둘레의 괄호</h2>
  {{playground:0}}

  <h2>데모 2 · 에러 시 해제, 정확히 한 번</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 연결(connection)에 수명을 부여해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="take.html"><code>take</code></a> — 반복에 한도를 두어 완료(그리고 해제)를 보장하기 ·
    <a href="peek.html"><code>peek</code></a> — 수명을 소유하지 않고 값 관찰하기 ·
    <a href="retry.html"><code>retry</code></a> — 팩터리로 감싸면 시도마다 새로 획득
  </div>
