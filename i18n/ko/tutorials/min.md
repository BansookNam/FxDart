---
slug: min
title: min — FxDart 101
description: FxDart min 튜토리얼 — 파이프라인에서 가장 작은 숫자를 구하고, 비어 있으면 +무한대를, NaN이 섞이면 NaN을 반환합니다. 라이브 플레이그라운드 포함.
heading: <code>min</code>
section: 7
crumb: min
prev: average.html
prevLabel: average
next: max.html
nextLabel: max
---
  <p class="hero-sub">파이프라인에서 가장 작은 숫자 — 빈 입력과 <code>NaN</code> 입력에 대한 FxTS의 특이 동작까지 그대로입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>min</code>은 숫자 전용 종결 연산자이자 fold입니다. 내부적으로는
    <code>fold(double.infinity, ..., iterable)</code>로, <code>+infinity</code>에서
    시작하는 최솟값과 각 원소를 비교해 나갑니다.
  </p>
  <p>
    꼭 기억해 둘 동작이 두 가지 있습니다. "안전한" API에 익숙한 사람이라면
    놀랄 만한 동작이지만, <strong>FxTS를 충실히 옮긴</strong> 결과입니다.
  </p>
  <ul>
    <li>
      <strong>비어 있는</strong> 이터러블은 <code>double.infinity</code>를
      반환합니다 — <code>null</code>도, 에러도 아닙니다. 아무것도 그 값을
      이기지 못했으니 fold의 시드가 그대로 남은 것뿐입니다.
    </li>
    <li>
      이터러블 어디든 <code>NaN</code>이 하나라도 있으면 결과 전체가
      <strong>오염</strong>되어 <code>NaN</code>이 됩니다 — <code>NaN</code>과의
      비교는 언제나 거짓이므로, 한번 최솟값 자리에 들어오면(또는 후보로
      등장하면) 영원히 <code>NaN</code>으로 남습니다.
    </li>
  </ul>
  <p>
    "최솟값, 비어 있으면 <code>null</code>" 같은 의미가 필요하다면 직접
    <code>result.isInfinite</code>를 확인하거나,
    <code><a href="find.html">find</a></code> /
    <code><a href="reduce.html">reduce</a></code>에 직접 만든 비교 로직을 넘겨 쓰세요.
  </p>

  <h2>데모 1 · 기본 사용법, 빈 경우, NaN</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 상품들 중 <strong>가장 저렴한</strong> 가격을 찾아보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="max.html"><code>max</code></a> — 정반대 방향의 짝 ·
    <a href="sum.html"><code>sum</code></a> · <a href="average.html"><code>average</code></a> — 나머지 숫자 종결 연산자 ·
    <a href="find.html"><code>find</code></a> — null 안전한 "조건에 맞는 최솟값" 검색이 필요할 때
  </div>
