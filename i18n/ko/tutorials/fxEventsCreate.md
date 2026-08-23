---
slug: fxEventsCreate
title: fxEventsCreate — FxDart 101
description: FxDart fxEventsCreate 튜토리얼: 값, Future, 생성기, create 콜백으로 이벤트 체인을 만들기 — 를 라이브 플레이그라운드와 함께 다룹니다.
heading: 생성자
section: 14
crumb: fxEventsCreate
prev: fxEvents.html
prevLabel: fxEvents
next: whenComplete.html
nextLabel: whenComplete
---
  <p class="hero-sub">이벤트 체인의 콜드 생성자: 값 하나, 빈 종료, Future, 생성기, create 콜백 — 이미 가지고 있던 Stream을 감쌀 필요가 없습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code><a href="fxEvents.html">fxEvents</a>(stream)</code>은 이미
    가진 스트림을 감쌉니다. 이 생성자들은 스트림
    <strong>그 자체</strong>입니다. 콜드로 유지됩니다: 감싸거나 이름
    붙이는 것만으로는 아무것도 듣지 않고, 종결 연산자
    (<code>toList</code>, <code>head</code>, <code>listen</code>)가
    이벤트를 흐르게 합니다. 체인의 나머지가 지키는 것과 같은
    정직함의 규칙입니다.
  </p>
  <p>
    간단한 것부터입니다. <code>FxEvents.value(x)</code>는
    <code>x</code>를 내보내고 닫습니다 — Rx의 <code>of</code>/<code>just</code>.
    <code>FxEvents.empty()</code>는 아무것도 없이 닫습니다.
    <code>FxEvents.never()</code>는 내보내지도 닫히지도 않습니다.
    리슨은 취소될 때까지 멈추므로, 언급만 하고 데모는 하지
    않습니다. <code>fromFuture</code>는 Future의 값(또는 에러)을
    내보내고 닫습니다. Future는 리스너가 도착하기 전에는 관찰되지
    않습니다. <code>generate(initial, condition, iterate)</code>는
    조건이 성립하는 동안 <code>initial, iterate(initial), …</code>를
    걷습니다 — 각 단계는 타이머 틱이라, 무한 생성기도 취소할 수
    있습니다.
  </p>
  <p>
    시간, 그다음 팩토리입니다. <code>FxEvents.timer(delay)</code>는
    지연 뒤에 <code>0</code>을 내보내고 닫습니다.
    <code>every</code>가 있으면 그 주기로 <code>1, 2, …</code>를
    이어 갑니다. <code>periodic</code>은 끝나지 않는 시계입니다
    (연산을 생략하면 틱 횟수) — 취소하세요.
    <code>toList</code>하지 마세요. <code>defer(factory)</code>는
    리슨마다 새 내부 스트림을 만듭니다 — 래퍼가 아니라 팩토리가; 체인
    자체는 단일 구독으로 남습니다. <code>using</code>은 리슨에서
    자원을 얻고, 그것을 미러링하고, 정확히 한 번 해제합니다 — 풀
    쪽 <code><a href="using.html">using</a></code>의 푸시 짝입니다.
    <code>fromPattern(add, remove)</code>는 전형적인
    <code>on</code>/<code>off</code> 다리입니다. 그리고
    <code>create(init)</code>는 <code>EventEmitter</code>와 함께
    <code>init</code>을 호출합니다: <code>add</code>,
    <code>addError</code>, <code>close</code>, 그리고 정리를 위한
    <code>onCancel</code>. <code>init</code>에서의 throw는 전달되고
    스트림은 닫힙니다.
  </p>
  <p>
    fxdart 이벤트 레이어, Rx의 <code>of</code>/<code>just</code>,
    <code>EMPTY</code>, <code>NEVER</code>, <code>from</code>,
    <code>interval</code>, <code>timer</code>, <code>defer</code>,
    <code>generate</code>, <code>fromEventPattern</code>,
    <code>using</code>, 그리고 <code>Observable</code> 생성자 /
    <code>create</code>를 따랐습니다.
  </p>

  <h2>데모 1 · value, empty, generate</h2>
  {{playground:0}}

  <h2>데모 2 · defer, 그리고 fromFuture</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 1, 2, 3을 내보낸 뒤 닫는 <code>create</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="fxEvents.html"><code>fxEvents</code></a> — 이미 가진 Stream을 감싸기 ·
    <a href="using.html"><code>using</code></a> — 풀 레이어의 원본: 첫 pull에서 획득, 한 번 해제 ·
    <a href="share.html"><code>share</code></a> — 체인 한 번의 실행에 리스너가 여럿 필요할 때
  </div>
