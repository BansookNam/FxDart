---
slug: fxSubscriptions
title: FxSubscriptions — FxDart 101
description: FxDart FxSubscriptions 튜토리얼: 여러 스트림 구독을 한 자루에 담아 함께 취소·일시정지·재개하기 — dispose 한 줄 — 을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>FxSubscriptions</code>
section: 14
crumb: FxSubscriptions
prev: liveValue.html
prevLabel: LiveValue
---
  <p class="hero-sub">함께 취소되는 구독 자루 — 스트림마다 필드 하나가 아니라 정리는 호출 한 번.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    여러 스트림을 듣는 객체는 오직 한 가지 이유로 모든 구독을 살려
    둡니다: 나중에 다시 취소하려고요. 그 결과가 익숙한 널 가능 필드
    더미입니다. 각각 맨 위에 선언되고, 각각 <code>initState</code>에서
    할당되고, 각각 <code>dispose</code>에서 취소되고 — 그리고 누수는
    언제나 누군가 세 번째 목록에 추가하기를 잊은 그 하나입니다.
  </p>
  <p>
    <code>FxSubscriptions</code>는 그것을 객체 하나로 접습니다.
    <code>add</code>는 구독을 자루에 넣고 <strong>그것을
    돌려주므로</strong> 문장이 아니라 식으로 읽히고,
    <code>cancelAll()</code>이 그 전부를 끝냅니다. 정리는 한 줄이
    됩니다: <code>Future&lt;void&gt; dispose() =&gt; subs.cancelAll();</code>
  </p>
  <p>
    <code>pauseAll()</code>과 <code>resumeAll()</code>은 더 부드러운
    버전으로, 배선을 해체하지 않은 채 일만 멈춰야 할 때를 위한
    것입니다 — 화면이 백그라운드로 가거나 탭이 포커스를 잃을 때요.
    일시정지된 구독은 버리지 않고 버퍼에 담으므로 그 틈에서 잃는 것이
    없습니다.
  </p>
  <p>
    자루는 취소를 기다리기 <em>전에</em> 비워지므로, 기다리는 동안 두
    번째 <code>cancelAll()</code>이 무언가를 두 번 취소할 수 없고, 같은
    객체가 그 뒤로 새 세대의 구독을 담을 수 있습니다. fxdart 이벤트
    레이어, Rx의 <code>CompositeSubscription</code>을 따랐습니다.
  </p>
  <p>
    <code><a href="stopOn.html">stopOn</a></code>과 자연스럽게 짝을
    이룹니다: <code>stopOn</code>은 무언가가 <em>일어나서</em> 체인이
    끝나야 할 때, <code>FxSubscriptions</code>는 그것들을 소유하던 것이
    <em>사라져서</em> 여러 체인이 끝나야 할 때 쓰세요.
  </p>

  <h2>데모 1 · dispose 한 줄</h2>
  {{playground:0}}

  <h2>데모 2 · 해체하지 않고 멈추기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>addAll</code>, 그리고 취소 후 자루 재사용.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="stopOn.html"><code>stopOn</code></a> — 소유자의 생명주기가 아니라 이벤트가 조종하는 정리 ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — 그 <code>listen</code>이 이 자루에 담을 구독을 건네주는 체인 ·
    <a href="liveValue.html"><code>LiveValue</code></a> — 자기 <code>close()</code>를 가지며, 이 자루에 담기지 않음
  </div>
