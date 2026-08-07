---
slug: mapValues
title: mapValues, mapKeys, mapEntries — FxDart 101
description: FxDart mapValues 튜토리얼: Map의 값·키·엔트리 전체를 변환하는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>mapValues</code>와 친구들
section: 9
crumb: mapValues
prev: props.html
prevLabel: props
next: evolve.html
nextLabel: evolve
---
  <p class="hero-sub">맵의 값 전체, 키 전체, 또는 <code>(키, 값)</code> 엔트리 전체를 변환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    9장의 나머지는 맵에서 <em>골라내거나</em>(<a href="pick.html"><code>pick</code></a>,
    <a href="omit.html"><code>omit</code></a>,
    <a href="pickBy.html"><code>pickBy</code></a>,
    <a href="omitBy.html"><code>omitBy</code></a>) 일부를 읽습니다.
    이 셋은 맵을 <em>변환</em>합니다. <code>mapValues</code>는 값마다 콜백을
    돌리고 키는 건드리지 않으며, <code>mapKeys</code>는 그 반대,
    <code>mapEntries</code>는 <code>(키, 값)</code> 레코드를 통째로 받아 새
    레코드를 돌려줍니다.
  </p>
  <p>
    그 레코드는 <code>pickBy</code>, <code>omitBy</code>,
    <a href="fromEntries.html"><code>fromEntries</code></a>가 이미 쓰는 것과
    같은 모양입니다. 그래서 넷이 아무 변환 없이 이어집니다 — 하나로 거르고
    다른 하나로 변환하면 됩니다. <code>mapEntries</code>는 나머지 둘을
    일반화한 형태라서, <code>e.$1</code>과 <code>e.$2</code>를 맞바꾸면
    한 번의 호출로 맵이 뒤집힙니다.
  </p>
  <p>
    <code>mapValues</code>는 키를 건드리지 않으므로 엔트리를 잃을 일이
    없습니다. <code>mapKeys</code>와 <code>mapEntries</code>는 다릅니다.
    콜백이 두 키를 같은 결과로 보내면 순회 순서상 <strong>마지막</strong>
    것이 이깁니다. 맵 리터럴에서 키가 겹쳤을 때와 똑같습니다. 그 밖에는
    삽입 순서가 유지되며, 새 키가 처음 나타난 자리를 따릅니다.
  </p>
  <p>
    <code>filter</code>나 <code>filterWithKey</code>는 일부러 두지
    않았습니다. <code>pickBy</code>와 <code>omitBy</code>가 이미 레코드를
    통째로 받으므로, 한쪽을 무시하는 것이 곧 다른 한쪽으로 거르는
    방법입니다 — 두 번째 데모를 보세요.
  </p>
  <p>
    바로 옆의 <a href="evolve.html"><code>evolve</code></a>와 비교해
    보세요. 그쪽은 <em>지정한</em> 키의 값만 변환하고 나머지는 그대로
    통과시킵니다. <code>mapValues</code>는 모든 값이 같은 처리를 받는
    경우입니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 키 충돌, 그리고 곁들이는 필터</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 이름은 그대로 두고 점수를 등급 문자로 바꿔 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="evolve.html"><code>evolve</code></a> — 지정한 키의 값만 변환 ·
    <a href="pickBy.html"><code>pickBy</code></a> / <a href="omitBy.html"><code>omitBy</code></a> — 같은 레코드 모양의 키 인식 필터 ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — 레코드로 맵 만들기 ·
    <a href="compactObject.html"><code>compactObject</code></a> — null 값 걷어내기
  </div>
