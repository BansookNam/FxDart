---
slug: values
title: values — FxDart 101
description: FxDart values 튜토리얼: Map의 값을 체인에 바로 흘려보낼 수 있는 지연 Iterable로 얻습니다.
heading: <code>values</code>
section: 2
crumb: values
prev: keys.html
prevLabel: keys
next: map.html
nextLabel: map
---
  <p class="hero-sub">Map의 값을 평범한 지연 Iterable로 — fx()로 감싸 바로 체이닝할 수 있습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>values(map)</code>는 <code>keys</code>의 쌍둥이입니다. Dart의
    <code>map.values</code>를 얇게 감싼 것이지만, 객체 관련 함수 어휘와
    일관된 이름을 붙여 <code>fx(keys(map))</code>,
    <code>fx(entries(map))</code> 옆에 <code>fx(values(map))</code>를
    나란히 두었을 때 자연스럽게 읽히도록 했습니다.
    <code>map.values</code> 자체가 그렇듯 이미 지연 뷰이므로, 별도의
    버퍼링은 일어나지 않습니다.
  </p>
  <p>
    돌려주는 값이 평범한 <code>Iterable&lt;V&gt;</code>이기 때문에 지금까지
    배운 체인 연산자를 그대로 쓸 수 있습니다 — <code>V</code>가
    <code>num</code>이라면 숫자 종결 연산자(<code>sum()</code>,
    <code>average()</code>, <code>min()</code>, <code>max()</code>)까지
    포함해서요. 그래서 <code>values</code>는 Map의 데이터를 집계할 때
    가장 자연스러운 출발점이 됩니다. 가격을 합산하거나, 점수를 평균 내거나,
    가장 최근 타임스탬프를 찾는 식으로 말이죠.
  </p>
  <p>
    여기가 <code>map</code> 자체로 들어가기 직전의 마지막 정거장입니다 —
    다음 강의이자, 앞으로 <code>values</code>나 <code>entries</code>를 비롯한
    어떤 소스가 건네주는 값이든 원하는 모양으로 바꾸기 위해 끊임없이
    꺼내 쓰게 될 연산자입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · Map의 값 집계하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>values</code>로 평균 점수를 구해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="keys.html"><code>keys</code></a> — Map의 키 ·
    <a href="entries.html"><code>entries</code></a> — 키와 값을 쌍으로 함께 ·
    <a href="map.html"><code>map</code></a> — 체인의 모든 값을 원하는 모양으로 ·
    <a href="sum.html"><code>sum · average · min · max</code></a> — 위에서 사용한 숫자 종결 연산자
  </div>
