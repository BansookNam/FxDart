---
slug: chunkOn
title: chunkOn — FxDart 101
description: FxDart chunkOn 튜토리얼: 개수로, 트리거 스트림으로, 시간 창으로 이벤트 묶기 — 수다스러운 스트림을 몇 번의 네트워크 호출로 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>chunk</code>, <code>chunkOn</code> &amp; <code>chunkEvery</code>
section: 14
crumb: chunkOn
prev: stopOn.html
prevLabel: stopOn
next: windowOn.html
nextLabel: windowOn
---
  <p class="hero-sub">이벤트를 리스트로 모읍니다 — 개수로, 트리거로, 또는 시계로 — 수다스러운 스트림이 몇 번의 묶인 호출이 되도록.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    묶기는 수다스러운 스트림이 얻을 수 있는 가장 값싼 성능 개선입니다.
    분석 이벤트 백 개는 하나씩 보내면 왕복 백 번이고, 오십 개씩 묶으면
    왕복 두 번입니다. 일의 양은 같고 비용은 다릅니다. 풀 레이어는
    <code><a href="chunk.html">chunk</a></code>로 개수로 묶고, 할 수
    있는 건 그것뿐입니다 — 풀 파이프라인에는 시계가 없으므로 "지난 2초
    동안 일어난 모든 것"은 물을 수 없는 질문입니다.
  </p>
  <p>
    푸시 쪽은 물을 수 있습니다. <code>chunk(count)</code>는 같은 고정
    크기 묶기이고, 소스가 닫힐 때 짧은 마지막 묶음을 흘려보내 아무것도
    남겨지지 않게 합니다. <code>chunkEvery(window)</code>는 대신
    <strong>시간</strong>으로 묶습니다: 지난 창 동안 도착한 것이 하나의
    리스트로 나옵니다. 그리고 <code>chunkOn(trigger)</code>은 그 결정을
    두 번째 스트림에 넘깁니다 — 사용자가 스크롤할 때, 프레임이 끝날 때,
    연결이 돌아올 때 묶으세요.
  </p>
  <p>
    시간 기반 두 형태는 모두 <strong>빈 창에서 침묵합니다</strong>.
    버퍼가 빈 채로 발화한 틱은 빈 리스트 대신 아무것도 내보내지 않으므로,
    하류 코드가 "아무 일도 없었다"는 뜻의 묶음을 걸러낼 일이 없습니다 —
    <code><a href="sampleOn.html">sampleOn</a></code>이 지키는 것과 같은
    정직함의 규칙입니다. 소스가 닫힐 때 아직 버퍼에 있는 것은 닫히기
    전에 흘려보냅니다.
  </p>
  <p>
    fxdart 이벤트 레이어, Rx의 <code>bufferCount</code>,
    <code>buffer</code>, <code>bufferTime</code>을 따랐습니다. 이
    가족은 풀 레이어의 <code>chunk</code>를 어근으로 유지합니다 —
    라이브러리의 양쪽 절반에서 하나의 개념에 하나의 이름 — 트리거에는
    <code>…On</code>, 시계에는 <code>…Every</code> 접미사를 붙여서요.
  </p>

  <h2>데모 1 · 시계로 묶기</h2>
  {{playground:0}}

  <h2>데모 2 · 개수로, 그리고 트리거로</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 클릭마다 리포트 하나 대신 창마다 요약 하나.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="chunk.html"><code>chunk</code></a> — Iterable을 개수로 묶는 풀 레이어의 원본 ·
    <a href="throttle.html"><code>throttle</code></a> — 창마다 전부가 아니라 하나만 원할 때 ·
    <a href="spaceBy.html"><code>spaceBy</code></a> — 버스트를 늦추는 다른 방법: 묶는 대신 늘이기
  </div>
