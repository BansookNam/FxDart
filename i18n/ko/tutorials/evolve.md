---
slug: evolve
title: evolve — FxDart 101
description: FxDart evolve 튜토리얼: Map에서 지정한 값만 키별로 변환하고 나머지는 그대로 둡니다.
heading: <code>evolve</code>
section: 9
crumb: evolve
prev: props.html
prevLabel: props
next: compactObject.html
nextLabel: compactObject
---
  <p class="hero-sub">지정한 값만 키별 변환 함수에 통과시키고, <code>Map</code>의 나머지는 그대로 둡니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>evolve</code>는 "레시피" 맵 — 키에서 변환 함수로의 매핑 — 과
    데이터 맵을 받아, 레시피에 등장하는 키의 값은 대응하는 함수를 거치고
    나머지 키는 그대로 복사되는 새 맵을 만들어 냅니다.
  </p>
  <p>
    시그니처가 일부러 느슨하다는 점에 주목하세요. 두 맵 모두 값 타입이
    <code>Object?</code>인데, 동적 타입이던 FxTS 원본을 그대로 반영한
    것입니다. 즉 변환 함수는 <code>Object?</code>를 받게 되고, 타입에
    특화된 작업을 하려면 먼저 캐스팅해야 합니다(<code>v as String</code>,
    <code>v as int</code>, …). 하나의 맵 안에서 값 타입마다 다른 변환을
    적용할 수 있는 유연함에 대한 작은 대가인 셈입니다. 데이터의 모양을
    미리 알고 있고 키마다 다른 처리가 필요하지 않다면, 대개는 평범한
    <code>{...map, 'key': f(map['key'])}</code> 전개가 더 Dart다운
    표현입니다. 레시피 자체가 데이터일 때(예: 한 번 만들어 두고 여러
    맵에 재사용할 때) <code>evolve</code>를 꺼내 쓰세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 원시 문자열 필드 파싱하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>evolve</code>로 <code>'price'</code> 필드를 두 배로 만들고 <code>'title'</code>은 그대로 두어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="prop.html"><code>prop</code></a> — 값 하나를 꺼내 읽습니다 ·
    <a href="omitBy.html"><code>omitBy</code></a> — 변환하는 대신 엔트리를 버립니다 ·
    <a href="compactObject.html"><code>compactObject</code></a> — 특수한 목적의 정리 과정 ·
    <a href="resolveProps.html"><code>resolveProps</code></a> — 변환 대신 await하는 비동기 사촌
  </div>
