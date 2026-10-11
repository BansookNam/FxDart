---
slug: dropRight
title: dropRight — FxDart 101
description: FxDart dropRight 튜토리얼: 유한한 이터러블에서 뒤쪽 n개의 값을 덜어내는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>dropRight</code>
section: 5
crumb: dropRight
prev: drop.html
prevLabel: drop
next: dropWhile.html
nextLabel: dropWhile
---
  <p class="hero-sub">뒤쪽 <code>length</code>개의 값을 덜어낸 지연 이터러블을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>dropRight</code>는 앞이 아니라 뒤쪽 <code>length</code>개의 값을
    덜어냅니다. <code>takeRight</code>와 마찬가지로 앞을 내다보지 않고서는
    어떤 원소가 "마지막"인지 알 방법이 없으므로 소스가 유한해야 합니다. 그래도
    동기 버전은 지연 방식을 유지합니다. <code>List</code>라면 자르는 지점까지
    곧장 인덱스로 이동하고, 다른 이터러블이라면 <code>length</code>개짜리 작은
    버퍼를 들고 있다가 더 새로운 값이 <code>length</code>개 도착해야 비로소
    값 하나를 내보냅니다. 크기를 미리 아는 배치에서 끝에 붙은 푸터나
    센티널만 빼고 싶을 때 딱 맞는 도구입니다.
  </p>
  <p>
    <code>fxDropRightAsync</code>는 다릅니다. 값을 만들어 내기 시작하려면
    상류 전체를 리스트로 먼저 await 해야 합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 (소스 전체를 먼저 버퍼링해야 합니다)</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 뒤쪽 푸터 2줄을 버려 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="drop.html"><code>drop</code></a> — 대신 앞쪽에서 버립니다 ·
    <a href="takeRight.html"><code>takeRight</code></a> — 버리는 대신 뒤쪽 n개를 남깁니다 ·
    <a href="reverse.html"><code>reverse</code></a> — 소스 전체를 구체화합니다
  </div>
