---
slug: debounce
title: debounce — FxDart 101
description: FxDart debounce 튜토리얼 — 호출이 잠잠해질 때까지 함수 실행을 미루는 방법, leading 옵션과 cancel(), 그리고 라이브 플레이그라운드까지.
heading: <code>debounce</code>
section: 12
crumb: debounce
next: throttle.html
nextLabel: throttle
---
  <p class="hero-sub">마지막 호출 이후 wait만큼 지날 때까지 함수 호출을 미룹니다 — 연속된 호출 중 마지막 하나만 살아남습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>debounce</code>는 콜백을 감싸서, 짧은 시간에 몰린 반복 호출을
    하나의 호출로 합쳐 줍니다. 호출이 있을 때마다 <code>wait</code> 길이의
    타이머가 다시 시작되고, 감싼 <code>func</code>는 다른 호출 없이
    <code>wait</code>가 <em>온전히</em> 지났을 때 비로소 실행됩니다 — 그리고 마지막 호출에
    전달된 인자로 실행됩니다. "사용자가 타이핑을 멈춘 뒤에 검색한다"는
    전형적인 패턴이 바로 이것입니다.
  </p>
  <p>
    JS에서 FxTS는 반환된 함수에 <code>.cancel()</code> 메서드를 직접 붙입니다.
    Dart 함수는 추가 멤버를 가질 수 없기 때문에, FxDart는 대신
    <code>Debounced&lt;T&gt;</code>를 반환합니다 — <code>call(T arg)</code>
    메서드를 가진 클래스이며, Dart의 <code>call()</code> 관례 덕분에
    평범한 함수 호출 문법(<code>debounced(arg)</code>)으로 호출할 수 있고,
    대기 중인 실행을 버리는 <code>.cancel()</code>도 따로 제공합니다.
  </p>
  <p>
    기본값(<code>leading: false</code>)에서는 <strong>트레일링</strong>
    에지만 발화합니다 — 연속 호출이 끝나고 잠잠해진 뒤의 마지막 호출입니다.
    <code>leading: true</code>를 주면 대신 연속 호출 중 <strong>첫</strong>
    호출이 즉시 발화하고, 다음 잠잠해지는 구간이 올 때까지의 나머지 호출은
    모두 억제됩니다.
  </p>

  <h2>데모 1 · 트레일링 에지(기본 동작)</h2>
  <p>빠르게 이어진 세 번의 호출이 하나로 합쳐지고, 마지막 인자만 남습니다.</p>
  {{playground:0}}

  <h2>데모 2 · 리딩 에지와 cancel()</h2>
  <p>
    <code>leading: true</code>는 즉시 발화한 뒤 나머지 연속 호출을 억제하고,
    <code>.cancel()</code>은 대기 중인 트레일링 호출을 통째로 버립니다.
  </p>
  {{playground:1}}

  <h2>메서드 표기</h2>
  <p>
    콜백 쪽에서 같은 것을 메서드로 부를 수 있습니다.
    <code>saveDraft.fxDebounce(wait)</code>는
    <code>debounce(saveDraft, wait)</code>와 같고, 이름 붙은 인자도 그대로
    받습니다.
  </p>
  <pre><code>void saveDraft(String text) =&gt; _post(text);

final save = saveDraft.fxDebounce(const Duration(milliseconds: 300));
save('h');
save('he');
save('hello');   // only this one reaches _post</code></pre>
  <p>
    <code>fx</code> 접두사는 의도한 것입니다. 어느 라이브러리가 콜백을 감싸는지
    드러내고, 맨 이름은 프로젝트가 자기 함수 타입에 붙일 몫으로 남겨 둡니다 —
    <a href="fx.html"><code>fx</code></a>의 getter 표기와 같은 규칙입니다.
  </p>
  <h2>직접 해 보기</h2>
  <p>연습: <code>save</code>를 <code>debounce</code>로 감싸(wait는 100ms)
    아래 연속 호출 중 마지막 값만 살아남게 만들어 보세요.</p>
  {{playground:2}}

  <h2>이벤트 스트림에서</h2>
  <p>
    같은 아이디어가 이벤트 레이어에도 있습니다. 몰아치는 대상이 콜백이
    아니라 <code>Stream</code>이라면
    <code>fxEvents(s).debounce(window)</code>가 각 버스트의 트레일링 값을
    — <code>window</code> 동안 새 이벤트가 없을 때 — 내보내고, 스트림이
    닫힐 때 아직 대기 중인 값은 버려지지 않고 마지막에 방출됩니다. 이
    체인이 속한 곳은 <a href="fxEvents.html"><code>fxEvents</code></a>
    문서를 참고하세요.
  </p>
  {{playground:3}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="throttle.html"><code>throttle</code></a> — 잠잠해진 뒤가 아니라 일정 주기로 발화 ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — 타이밍 데모를 만드는 재료 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 비동기 파이프라인의 속도 제한 ·
    <a href="shuffle.html"><code>shuffle</code></a> — 시드를 지정하는 난수
  </div>
