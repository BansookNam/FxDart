---
slug: zipWith
title: zipWith — FxDart 101
description: FxDart zipWith 튜토리얼: 두 이터러블을 zip하면서 각 쌍을 함수로 한 번에 결합합니다. 라이브 플레이그라운드 포함.
heading: <code>zipWith</code>
section: 6
crumb: zipWith
prev: zip.html
prevLabel: zip
next: zipWithIndex.html
nextLabel: zipWithIndex
---
  <p class="hero-sub">두 이터러블을 zip하면서 각 쌍을 함수로 결합하는 것을 한 번에 처리합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>zipWith</code>는 <code>zip</code> 뒤에 그 쌍들에 대한
    <code>map</code>을 붙인 것과 정확히 같습니다 — 실제로 FxDart의 구현도
    <code>map((r) => f(r.$1, r.$2), zip(...))</code>입니다. 중간의
    <code>(A, B)</code> 레코드는 필요 없고 결합한 결과만 원할 때
    꺼내 쓰세요. 나란히 놓인 두 리스트를 곱하거나, 이름과 나이를 하나의
    라벨로 포맷하는 식으로 말이죠.
  </p>
  <p>
    <code>zip</code>과 마찬가지로 두 입력 중 짧은 쪽에서 멈추며, 비동기
    형태인 <code>zipWithAsync</code>는 <code>zipAsync</code>의 쌍마다 병렬로
    끌어오는 동작을 그대로 물려받습니다. <code>zipWith</code>에는
    <code>Fx</code> 체인 형태가 없으므로 최상위 함수를 직접 호출하세요
    (또는 <code>.zip(other).map((r) => f(r.$1, r.$2))</code>로 직접
    만들어도 됩니다).
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>zipWith</code>로 쌍마다 품목 합계
    (<code>price * quantity</code>)를 계산해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="zip.html"><code>zip</code></a> — 이 함수가 기반으로 삼는, 쌍만 만드는 버전 ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — 증가하는 인덱스와 짝짓기 ·
    <a href="map.html"><code>map</code></a>
  </div>
