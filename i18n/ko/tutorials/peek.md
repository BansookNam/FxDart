---
slug: peek
title: peek — FxDart 101
description: FxDart peek 튜토리얼: 파이프라인을 흐르는 원소를 변형하지 않고 들여다봅니다. 라이브 플레이그라운드 포함.
heading: <code>peek</code>
section: 3
crumb: peek
prev: scan.html
prevLabel: scan
next: pluck.html
nextLabel: pluck
---
  <p class="hero-sub">아무것도 바꾸지 않으면서 원소마다 함수를 실행합니다 — 파이프라인판 디버거 중단점입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>peek</code>은 <code>mapEffect</code>의 더 엄격한 사촌입니다.
    <code>mapEffect</code>는 값을 바꿀 수도 있지만(사실상 이름만 다른
    <code>map</code>입니다), <code>peek</code>의 콜백은
    <code>void</code>를 반환합니다 — 오직 들여다보는 것만 허용됩니다.
    들어간 원소는 전혀 손대지 않은 채 그대로 나옵니다. 디버깅 중에
    파이프라인 한가운데에 <code>print</code>나 지표 수집, 로그 한 줄을
    끼워 넣고 싶은데 오타 하나로 데이터가 조용히 바뀌는 사고는 피하고
    싶을 때 쓰면 됩니다.
  </p>
  <p>
    여기 나오는 다른 함수들과 똑같이 지연 평가됩니다. 콜백은 실제로 끌려 나온 원소마다
    정확히 한 번씩, 순서대로, 그 이전에는 절대 실행되지 않습니다.
  </p>
  <p>
    <code>peekAsync</code>는 <code>mapAsync</code> 위에 그대로 얹혀
    있으므로(<code>f</code>를 await한 뒤 원래 값을 다시 내보냅니다)
    <code>map</code>의 동시성 동작을 그대로 물려받습니다.
    <code>.concurrent(n)</code>을 붙이면 콜백 <code>n</code>개가 실제로
    병렬로 실행됩니다 — 내부 상태 기계가 순차적일 수밖에 없는
    <code>flatMap</code>이나 <code>scan</code>과는 다릅니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>들어간 값이 그대로 나옵니다 — <code>peek</code>은 관찰만
    합니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기, 진짜 동시성으로</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>peek</code>으로 각 가격에 대해
    <code>'checking price: $p'</code>를 값은 바꾸지 않은 채 출력한 다음,
    <code>fold</code>로 합계를 구해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="mapEffect.html"><code>mapEffect</code></a> — peek과 비슷하지만 변환할 수 있습니다 ·
    <a href="map.html"><code>map</code></a> — 원소마다 변환합니다 ·
    <a href="pluck.html"><code>pluck</code></a> — 각 맵에서 필드 하나를 뽑아냅니다 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
