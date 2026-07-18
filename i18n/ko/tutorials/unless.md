---
slug: unless
title: unless — FxDart 101
description: FxDart unless 튜토리얼: 술어가 거짓일 때만 변환을 적용하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>unless</code>
section: 10
crumb: unless
prev: when.html
prevLabel: when
next: throwError.html
nextLabel: throwError
---
  <p class="hero-sub">술어가 거짓일 때 콜백을 적용하고, 그렇지 않으면 값을 그대로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>unless</code>는 조건을 뒤집은 <a href="when.html"><code>when</code></a>입니다.
    <code>unless(predicate, callback, value)</code>는
    <code>callback(value)</code>를 실행하되,
    <code>predicate(value)</code>가 <strong>false</strong>일 때만 실행합니다.
    술어가 참이면 <code>value</code>를 손대지 않고 그대로 반환합니다. "이 조건이 이미 충족된 게
    아니라면 기본값을 채워 넣는다"라는 흐름으로 자연스럽게 읽히므로 검증,
    누락 데이터 보완, 예외 상황 정규화에 잘 맞습니다.
  </p>
  <p>
    <code>when</code>과 마찬가지로 Dart에서는 두 분기가 모두 같은 타입
    <code>T</code>를 반환해야 하며(유니온 반환 타입이 없습니다), 체인 형태도
    없습니다 — 평범한 data-first 함수입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 누락 데이터 보완하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>unless</code>로 아직 설정되지 않은 태그에
    <code>'general'</code>을 채워 넣어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="when.html"><code>when</code></a> — 조건이 반대인 unless의 짝 ·
    <a href="cases.html"><code>cases</code></a> — 술어 하나가 아니라 여러 개를 다루기 ·
    <a href="throwIf.html"><code>throwIf</code></a> — 값을 대체하는 대신 예외를 던지기 ·
    <a href="compact.html"><code>compact</code></a> — 값을 채우는 대신 누락된 값을 버리기
  </div>
