---
slug: countBy
title: countBy — FxDart 101
description: FxDart countBy 튜토리얼: 계산된 키별로 원소가 몇 개씩 대응되는지 집계하는 방법을 라이브 플레이그라운드와 함께 배웁니다.
heading: <code>countBy</code>
section: 7
crumb: countBy
prev: indexBy.html
prevLabel: indexBy
next: foldBy.html
nextLabel: foldBy
---
  <p class="hero-sub">계산된 키별로 원소가 몇 개씩 대응되는지 집계합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>countBy</code>는
    <code><a href="groupBy.html">groupBy</a></code>,
    <code><a href="indexBy.html">indexBy</a></code>와 함께 삼총사를 완성합니다.
    파이프라인 전체를 끌어당기며 원소마다 키를 계산한다는 발상은 같지만,
    이번에는 원소를 전혀 보관하지 않고 키별 카운터만 증가시킵니다.
    결과는 <code>Map&lt;K, int&gt;</code>, 즉 각 키를 만들어 낸 원소가
    몇 개인지입니다.
  </p>
  <p>
    이 셋은 같은 그룹화에 대해 서로 다른 질문에 답한다고 생각하면 됩니다.
    <code>groupBy</code>는 "이 키에 해당하는 원소를 전부 달라",
    <code>indexBy</code>는 "이 키의 마지막 원소를 달라",
    <code>countBy</code>는 "이 키를 가진 원소가 몇 개냐"입니다.
    집계만 필요하다면 <code>countBy</code>가
    <code>groupBy(...).map((k, v) =&gt; MapEntry(k, v.length))</code>보다
    저렴합니다. 중간 리스트를 전혀 할당하지 않기 때문입니다.
  </p>
  <p>
    그리고 대신 여러분이 짰을 반복문보다도 저렴합니다. 누구나 떠올릴
    <code>counts[k] = (counts[k] ?? 0) + 1</code>은 원소마다 해시 맵을
    <strong>두 번</strong> 건드립니다. 읽으려고 한 번, 다시 쓰려고 한 번.
    그리고 하는 일이 세는 것뿐일 때 맵은 사실상 비용의 전부입니다.
    <code>countBy</code>는 맵 안에 세워 둔 가변 셀에 세므로, 맵은 원소마다가
    아니라 <em>서로 다른 키마다</em> 한 번 쓰입니다 — 백만 원소에서 손으로 짠
    반복문보다 약 <strong>1.5배 빠르고</strong>, 그 격차는 키가 몇 개일 때부터
    수만 개일 때까지 유지됩니다.
    <a href="../DartComparison/top-log-level.html">가장 잦은 로그 레벨</a>이
    그 숫자를 처음부터 끝까지 따라갑니다.
  </p>
  <p>
    늘 그렇듯 종결 연산자입니다 — <code>countBy</code>가 값을 끌어당기기 전까지 상류에서는 아무 일도 일어나지 않습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 각 후보가 몇 표를 받았는지 세어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — 개수 대신 모든 원소를 보관합니다 ·
    <a href="indexBy.html"><code>indexBy</code></a> — 개수 대신 마지막 원소를 보관합니다 ·
    <a href="size.html"><code>size</code></a> — 키 없이 전체 개수만 셉니다
  </div>
