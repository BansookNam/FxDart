---
slug: zip
title: zip — FxDart 101
description: FxDart zip 튜토리얼: 두 개(또는 세 개)의 이터러블에서 원소를 하나씩 짝지어 레코드로 묶습니다. 라이브 플레이그라운드 포함.
heading: <code>zip</code>
section: 6
crumb: zip
prev: concat.html
prevLabel: concat
next: zipWith.html
nextLabel: zipWith
---
  <p class="hero-sub">두 이터러블의 원소를 짝지어 레코드로 묶고, 짧은 쪽이 끝나면 멈춥니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>zip</code>은 두 이터러블을 나란히 훑으면서 한 단계마다 쌍 하나를
    내보내고, 어느 한쪽이 소진되는 순간 멈춥니다. FxTS가 TS 튜플을
    반환하는 자리에서 FxDart는 Dart의 <strong>레코드</strong>
    <code>(A, B)</code>를 반환하므로, 배열 인덱스 대신
    <code>.$1</code>/<code>.$2</code>나 패턴 매칭으로 결과를 분해합니다.
    Dart에는 가변 제네릭이 없기 때문에 인자 개수마다 함수가 따로 있습니다.
    이터러블 두 개는 <code>zip</code>, 세 개는 <code>zip3</code>입니다.
  </p>
  <p>
    <code>zipAsync</code>는 양쪽의 <code>next()</code> 호출을 어느 쪽도
    await하기 <em>전에</em> 먼저 걸어 둡니다 — 즉 쌍마다 두 소스를 순차가
    아니라 병렬로 끌어옵니다. 원소당 100ms가 걸리는 소스 두 개를 zip해도
    쌍당 200ms가 아니라 약 100ms만 듭니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 쌍마다 병렬로 끌어오기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>names</code>와 <code>ages</code>를 zip해서
    <code>(name, age)</code> 레코드로 묶어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="zipWith.html"><code>zipWith</code></a> — 짝짓기와 결합을 한 번에 ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — 증가하는 인덱스와 짝짓기 ·
    <a href="transpose.html"><code>transpose</code></a> — 임의 개수의 행을 zip ·
    <a href="concat.html"><code>concat</code></a> — 짝짓는 대신 이어 붙이기
  </div>
