---
slug: compress
title: compress — FxDart 101
description: FxDart compress 튜토리얼: 이터러블을 나란히 놓인 불리언 리스트로 걸러 내는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>compress</code>
section: 4
crumb: compress
prev: intersectionBy.html
prevLabel: intersectionBy
next: ../tutorials/take.html
nextLabel: take
---
  <p class="hero-sub">나란히 놓인 불리언 리스트가 true인 위치의 원소만 남깁니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>compress</code>는 위치 기반 마스크입니다. <code>i</code>번 위치의
    <code>iterable</code> 원소는 <code>selectors[i]</code>가 <code>true</code>일
    때만 살아남습니다. 이미 알고 있는 두 함수만으로 그대로 만들어져 있습니다 —
    <code>map((r) =&gt; r.$2, filter((r) =&gt; r.$1, zip(selectors, iterable)))</code> —
    마스크와 데이터를 zip한 뒤 true인 쌍만 걸러 내고 값을 꺼내는 식입니다.
    그래서 길이가 어긋날 때의 동작도 <code>zip</code>에서 그대로 물려받습니다.
    <em>더 짧은</em> 쪽, 그러니까 <code>selectors</code>와 <code>iterable</code>
    중 하나가 먼저 소진되는 순간 순회가 멈추므로, 셀렉터 리스트가 짧으면 결과도
    조용히 잘려 나갑니다. 원소마다 술어를 다시 계산하는 <code>filter</code>와
    달리, 불리언 마스크를 미리 가지고 있거나 저렴하게 계산할 수 있을 때
    — 예를 들어 "어떤 퀴즈 답이 정답이었는가" 같은 경우에 — 꺼내 쓰면 됩니다.
  </p>
  <p>
    체인 메서드는 없습니다. data-first 함수나 비동기 버전을 직접 호출하거나,
    계속 체이닝하고 싶다면 결과를 <code>fx(...)</code> /
    <code>fxAsync(...)</code>로 감싸면 됩니다.
  </p>

  <h2>데모 1 · 기본 사용법과 길이 불일치</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>compress</code>로 정답만 남겨
    보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="filter.html"><code>filter</code></a> — 미리 만든 마스크 대신 술어로 거르기 ·
    <a href="../tutorials/zip.html"><code>zip</code></a> — compress가 기반으로 삼는 함수 ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — 다른 이터러블에 포함되는지로 거르기 ·
    <a href="../tutorials/partition.html"><code>partition</code></a> — 한 번의 순회로 남길 것과 버릴 것 나누기
  </div>
