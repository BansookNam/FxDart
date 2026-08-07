---
slug: dropWhileRight
title: dropWhileRight — FxDart 101
description: FxDart dropWhileRight 튜토리얼: 술어를 만족하는 가장 긴 뒤쪽 구간을 잘라내는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>dropWhileRight</code>
section: 5
crumb: dropWhileRight
prev: dropWhile.html
prevLabel: skipWhile
next: dropUntil.html
nextLabel: dropUntil
---
  <p class="hero-sub">소스 <em>끝</em>에서 술어가 참인 가장 긴 구간을 버립니다 — 꼬리를 잘라내는 연산입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    잘라내기(trim) 연산자입니다. 뒤에 붙은 0들, 뒤에 남은 빈 줄, 꼬리에
    깔린 자리표시자 행 — 길이를 미리 세지 않고 끝에서 걷어내고 싶을 때
    씁니다. <a href="dropRight.html"><code>dropRight</code></a>로는 개수를
    알아야만 할 수 있는 일입니다.
  </p>
  <p>
    끝까지 이어지는 구간만 버립니다. 소스 중간에 있는 구간은 접미사가
    아니므로 그 자리에 그대로 남습니다 — 직관과 한 번 대조해 볼 만한
    지점입니다. <a href="filter.html"><code>filter</code></a>나
    <a href="reject.html"><code>reject</code></a>였다면 그것까지 지웠을
    테니까요.
  </p>
  <p>
    <a href="takeWhileRight.html"><code>takeWhileRight</code></a>와 달리 이쪽은
    흘려보냅니다. 조건에 맞는 구간은 접미사일 가능성이 있으므로 내보내지 않고
    붙들어 두었다가, 술어에서 <em>떨어지는</em> 첫 원소가 나타나 그 구간이
    접미사가 아니었음을 증명하는 순간 한꺼번에 풀어놓습니다. 그래서 메모리
    비용은 소스 길이가 아니라 가장 긴 구간의 길이이고, 소스가 열려 있는 동안
    값이 계속 흐릅니다.
  </p>
  <p>
    <code>List</code>라면 끝에서부터 거꾸로 훑어 구간을 찾으므로 술어는 그
    구간만 보게 되고, 그 밖의 소스라면 모든 원소를 순서대로 검사합니다.
    술어는 순수하게 유지하세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 분할</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 뒤에 붙은 0들을 잘라내고 나머지를 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="takeWhileRight.html"><code>takeWhileRight</code></a> — 같은 구간을 남기는 반대편 ·
    <a href="dropRight.html"><code>dropRight</code></a> — 개수로 잘라내는 뒤쪽 구간 ·
    <a href="dropWhile.html"><code>skipWhile</code></a> — 같은 발상을 앞에서 ·
    <a href="reject.html"><code>whereNot</code></a> — 끝이 아니라 어디서든 맞는 값을 지웁니다
  </div>
