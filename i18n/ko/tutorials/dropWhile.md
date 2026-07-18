---
slug: dropWhile
title: dropWhile — FxDart 101
description: FxDart dropWhile 튜토리얼: 술어가 참인 동안 값을 건너뛰고 그 뒤를 모두 내보내는 방법을 라이브 플레이그라운드와 함께 익힙니다.
heading: <code>dropWhile</code>
section: 5
crumb: dropWhile
prev: dropRight.html
prevLabel: dropRight
next: dropUntil.html
nextLabel: dropUntil
---
  <p class="hero-sub">술어가 true를 반환하는 동안 값을 건너뛰고, 그 뒤로는 술어에 맞든 아니든 모두 내보냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>dropWhile</code>은 <code>takeWhile</code>을 뒤집은 함수입니다.
    술어가 참인 동안은 원소를 건너뛰다가, 술어가 거짓이 되는 원소를 만나는
    순간부터 "전부 내보내기" 모드로 완전히 전환합니다. 이 전환은 되돌릴 수
    없습니다. <code>dropWhile</code>이 한 번 값을 흘려보내기 시작하면,
    뒤에 술어에 맞는 원소가 다시 나오더라도 다시 버리지 않습니다.
  </p>
  <p>
    개수를 미리 셀 수 없는 가변 길이의 앞부분을 잘라낼 때 꺼내 쓰세요.
    공백처럼 앞에 붙는 토큰, 헤더 행, 지표 스트림의 예열 구간 같은
    경우입니다. <code>Fx</code> 체인에서는 <code>Iterable.skipWhile</code>에
    맞춘 <code>skipWhile</code>이라는 이름으로도 쓸 수 있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  <p><code>3</code>에서 버리기가 멈춘 뒤로는 술어에 맞는 값
    (끝에 있는 <code>2</code>)도 다시 버려지지 않고 그대로 남습니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 온도가 25 미만인 동안은 버리고, 그 뒤로는 모두
    남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="takeWhile.html"><code>takeWhile</code></a> — 정반대 동작 ·
    <a href="dropUntil.html"><code>dropUntil</code></a> — 술어에 맞은 원소까지 버립니다 ·
    <a href="drop.html"><code>drop</code></a> — 정해진 개수만큼 버립니다 ·
    <a href="filter.html"><code>filter</code></a> — 앞부분만이 아니라 어디서든 맞는 값을 버립니다
  </div>
