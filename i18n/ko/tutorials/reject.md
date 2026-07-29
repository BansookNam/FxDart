---
slug: reject
title: whereNot — FxDart 101
description: FxDart whereNot 튜토리얼: 술어가 걸러 내는 원소만 남기는, where를 거울에 비춘 연산자를 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>whereNot</code>
section: 4
crumb: whereNot
prev: filter.html
prevLabel: filter
next: compact.html
nextLabel: compact
---
  <p class="hero-sub">술어가 false를 반환하는 원소만 남깁니다 — where를 거울에 비춘 함수입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>whereNot</code>은
    <code>where((a) =&gt; !f(a), iterable)</code>로 구현되어 있습니다 —
    오로지 가독성을 위해 존재합니다. <code>list.whereNot(isInvalid)</code>가
    <code>list.where((a) =&gt; !isInvalid(a))</code>보다 훨씬 자연스럽게 읽히고,
    술어에 이미 긍정형의 분명한 이름이 붙어 있다면 더욱 그렇습니다.
    <code>whereNot</code>이 Dart다운 이름이고, fxdart는 FxTS식 표기인
    <code>reject</code>도 함께 받습니다 — 같은 연산자입니다. 호출 지점에
    부정을 쓰지 않아도 되는 쪽으로 <code>where</code>와
    <code>whereNot</code> 중에서 고르면 됩니다.
  </p>
  <p>
    <code>where</code>의 동작은 그대로 이어집니다. 지연 평가되고, 비동기
    형태는 <code>whereAsync</code>의 전용 동시성 경로를 물려받으므로
    <code>.concurrent(n)</code>은 실제로 술어 <code>n</code>개를 병렬로
    평가하면서도 결과는 원래 순서대로 반환합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>whereNot</code>으로 <code>'info: ok'</code> 줄을 걸러 내고
    에러만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="filter.html"><code>filter</code></a> — reject가 위임하는 함수 ·
    <a href="compact.html"><code>compact</code></a> — null만 콕 집어 제거 ·
    <a href="uniq.html"><code>uniq</code></a> — 중복 제거 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
