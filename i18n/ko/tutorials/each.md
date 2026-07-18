---
slug: each
title: each — FxDart 101
description: FxDart each 튜토리얼: 지연 체인의 모든 원소에 대해 부수 효과를 위한 함수를 실행합니다. 동기와 비동기 모두 다룹니다.
heading: <code>each</code>
section: 1
crumb: each
prev: toArray.html
prevLabel: toArray
next: consume.html
nextLabel: consume
---
  <p class="hero-sub">원소마다 함수를 한 번씩 실행합니다. 오로지 부수 효과를 위한 연산자입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>each</code>는 <code>toArray</code>와 마찬가지로 종결 연산자입니다 —
    호출하는 순간 체인 전체를 통해 모든 값을 끌어당깁니다. 차이는 그 값들을
    가지고 무엇을 하느냐입니다. <code>List</code>로 모으는 대신 값마다
    <code>f</code>를 실행하고 <code>void</code>를 반환합니다. 출력이나 로깅,
    데이터베이스 쓰기처럼 효과를 일으키는 것이 목적이고 값 자체는 다시 받을
    필요가 없을 때 쓰면 됩니다.
  </p>
  <p>
    Dart에 원래 있는 <code>Iterable.forEach</code>의 FxTS 버전 쌍둥이라고
    보면 됩니다 — 발상은 같지만 나머지 FxTS API와 일관된 이름을 가져서
    체인 어휘와 자연스럽게 어울립니다.
  </p>
  <p>
    <code>eachAsync</code>(또는 <code>FxAsync</code> 체인의
    <code>.each()</code>)는 모든 원소에 대해 <code>f</code>를 await하되,
    원소가 도착한 순서를 엄격히 지킵니다 — 개별 호출 중 일부가 더 빨리
    끝날 수 있더라도 <code>each</code>는 언제나 한 번에 하나씩 순차로
    처리합니다. 겹쳐서 실행하고 싶다면 <code>.each()</code> 앞의 상류에
    <code>.concurrent(n)</code>을 추가하세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 엄격한 순서 보장</h2>
  <p>
    각 원소가 <em>서로 다른</em> 시간만큼 잠들더라도
    <code>eachAsync</code>는 여전히 1, 2, 3 순서로 처리합니다 — 순서가
    뒤바뀌는 일은 없습니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>each</code>로 주문마다 영수증 한 줄을 출력하면서
    누적 합계를 계산해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="toArray.html"><code>toArray</code></a> — 대신 List로 모으는 종결 연산자 ·
    <a href="consume.html"><code>consume</code></a> — 결과를 버리고 중간에 멈출 수도 있는 종결 연산자 ·
    <a href="peek.html"><code>peek</code></a> — 발상은 같지만 지연 평가(종결 연산자가 아님) ·
    <a href="fx.html"><code>fx</code></a> — each가 마무리하는 그 체인
  </div>
