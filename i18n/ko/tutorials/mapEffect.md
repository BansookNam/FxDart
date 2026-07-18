---
slug: mapEffect
title: mapEffect — FxDart 101
description: FxDart mapEffect 튜토리얼: 부수 효과를 위해 쓰는 map을 라이브 플레이그라운드와 함께 살펴봅니다.
heading: <code>mapEffect</code>
section: 3
crumb: mapEffect
prev: map.html
prevLabel: map
next: flatMap.html
nextLabel: flatMap
---
  <p class="hero-sub">map과 완전히 동일합니다 — 함수의 진짜 목적이 부수 효과일 때 쓰는 명명 규칙입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    소스를 열어 보면 <code>mapEffect</code>는 말 그대로
    <code>B mapEffect(f, iterable) =&gt; map(f, iterable);</code>입니다 —
    같은 함수, 같은 지연 평가, 같은 시그니처죠. 오직 호출 지점에서
    <em>의도</em>를 드러내기 위해 존재합니다. 콜백의 반환값보다 그 과정에서
    벌어지는 일(로그 기록, DB 저장, 카운터 증가)이 더 중요하다면
    <code>mapEffect</code>를, 반환값 자체가 목적이라면 <code>map</code>을
    쓰세요.
  </p>
  <p>
    단순한 별칭이므로 <code>map</code>에 대해 알고 있는 모든 것이 그대로
    적용됩니다. 지연 평가되고, 비동기 쪽에서는
    <code>.concurrent(n)</code>과 조합되며, 자체적인 에러 처리 같은 것도
    없습니다. 동작상 어느 쪽을 골라야 할 이유는 없습니다 — 이 파이프라인을
    다음에 읽을 사람(대개는 자기 자신)을 위한 가독성 신호일 뿐입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>콜백이 부수 효과를 기록하면서 변환된 값도 반환합니다 —
    <code>map</code>과 모양은 같지만 호출 지점에서의 의도가 다릅니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  <p>
    <code>mapEffectAsync</code>는 <code>mapAsync</code>와 완전히 같은 엔진
    위에서 돌아가므로 <code>.concurrent(n)</code>도 똑같이 병렬화해
    줍니다 — "처리하고 저장하는" 파이프라인에 요긴합니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>mapEffect</code>로 각 금액에 대해
    <code>'billing $&lt;dollars&gt;'</code> 줄을 <code>print</code>하면서
    센트를 달러로 변환해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="map.html"><code>map</code></a> — mapEffect가 그대로 위임하는 함수 ·
    <a href="peek.html"><code>peek</code></a> — 값을 전혀 바꾸지 않고 들여다보기 ·
    <a href="flatMap.html"><code>flatMap</code></a> — map + 평탄화 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
