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
    덜어냅니다. <code>takeRight</code>와 마찬가지로 소스 전체를 보기 전에는
    어떤 원소가 "마지막"인지 알 방법이 없으므로,
    <code>dropRight</code>는 값을 하나라도 내보내기 전에 소스를 리스트로
    <strong>구체화</strong>합니다. 크기를 아는 배치에서 끝에 붙은 푸터나
    센티널만 빼고 싶을 때 딱 맞는 도구지만, 소스가 유한해야 합니다.
  </p>
  <p>
    <code>dropRightAsync</code>도 같은 제약을 그대로 갖습니다. 값을 만들어
    내기 시작하려면 상류 전체를 먼저 await 해야 합니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 (소스 전체를 먼저 버퍼링해야 합니다)</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 뒤쪽 푸터 2줄을 버려 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="drop.html"><code>drop</code></a> — 대신 앞쪽에서 버립니다 ·
    <a href="takeRight.html"><code>takeRight</code></a> — 버리는 대신 뒤쪽 n개를 남깁니다 ·
    <a href="reverse.html"><code>reverse</code></a> — 이 함수도 소스를 구체화합니다
  </div>
