---
slug: takeUniqBy
title: takeUniqBy — FxDart 101
description: FxDart takeUniqBy 튜토리얼 — 필터·중복 제거·개수 제한을 컴파일러가 인라인할 수 있는 하나의 즉시 호출로. 실행 가능한 플레이그라운드 포함.
heading: <code>takeUniqBy</code>
section: 4
crumb: takeUniqBy
prev: uniqAdjacent.html
prevLabel: uniqAdjacent
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">키가 새로운 원소를 앞에서부터 <em>count</em>개까지 리스트로 — 키가 <code>null</code>이면 그 원소를 건너뛰므로, 콜백 하나가 선택과 키 계산을 겸합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>takeUniqBy(3, key, xs)</code>는
    <code><a href="filter.html">filter</a></code> +
    <code><a href="uniqBy.html">uniqBy</a></code> +
    <code><a href="take.html">take</a></code>를 하나의 즉시(strict) 호출로 쓴
    것입니다. <code>List</code>를 반환하고, 호출하는 순간 실행되며, 개수가
    채워지는 즉시 멈춥니다 — 그 뒤의 원소는 아예 보지 않습니다. 한 가지
    비틀림은 콜백입니다: 키를 반환하되 <code>null</code>을 반환하면 "이
    원소는 건너뛴다"는 뜻입니다. <code>filter_map</code> 형태이고, 함수
    하나가 둘의 일을 하게 만드는 장치입니다.
  </p>
  <p>
    기본은 체인으로 쓰십시오. 이름 붙은 세 단계가 두 일을 겸하는 콜백
    하나보다 잘 읽히고, 지연 체인도 똑같이 단축 평가합니다. 이 연산자가
    존재하는 이유는 하나뿐이며, 그게 무엇인지 아는 편이 좋습니다.
  </p>

  <h2>존재 이유: 컴파일러가 볼 수 없는 콜백</h2>
  <p>
    지연 단계는 콜백을 <em>이터레이터의 필드</em>에 담아 둡니다. AOT
    컴파일러는 필드 너머를 보지 못하므로 그 클로저는 결코 인라인되지
    않습니다 — 원소마다 실제 간접 호출을 한 번씩 내고, 본문이 주변 루프에
    녹아들지도 못합니다. 단계가 둘이면 원소당 호출이 둘입니다. 관용적인
    FxDart 체인과 손으로 쓴 루프를 갈라놓는 것의 대부분이 이것입니다.
  </p>
  <p>
    <code>takeUniqBy</code>는 콜백을 호출자에 인라인될 만큼 작은 본문의
    <em>매개변수</em>로 받습니다. 그래서 컴파일러가 클로저 본문을 함께
    인라인합니다. 로그 100만 줄, AOT 기준 측정값:
  </p>
  <table>
    <thead><tr><th>표현</th><th>시간</th></tr></thead>
    <tbody>
      <tr><td><code>filter().uniqBy().take(3)</code></td><td>13.7 ms</td></tr>
      <tr><td><code>takeUniqBy(3, …)</code></td><td><strong>11.3 ms</strong></td></tr>
      <tr><td>손으로 쓴 루프</td><td>10.2 ms</td></tr>
    </tbody>
  </table>
  <p>
    두 표현과 두 막대 모두
    <a href="../DartComparison/recent-errors.html">최근 오류 메시지, 중복
    제거</a> 페이지에 있습니다 — 같은 파이프라인을 쓰는 두 방식의 차이가
    그 페이지가 말하려는 바라서, 유일하게 막대를 둘이 아니라 셋 싣습니다.
  </p>
  <p>
    정리하면: 파이프라인이 뜨거운 경로에 있고 프로파일이 이 콜백들을 지목할
    때 꺼내십시오. 그전에는 아닙니다. FxTS에 대응물이 없는 fxdart 확장이며,
    async 짝도 없습니다 — 이득이 인라인인데 async 기계장치가 그것을 압도하기
    때문입니다.
  </p>

  <h2>데모 1 · 가장 최근의 서로 다른 오류 3개</h2>
  {{playground:0}}

  <h2>데모 2 · null은 건너뛰고, count는 상한</h2>
  {{playground:1}}

  <h2>직접 해보기</h2>
  <p>연습: 특정 페이지에 처음 도달한 서로 다른 사용자 3명.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련:</strong>
    <a href="uniqBy.html"><code>uniqBy</code></a> — 이 연산자가 접어 넣은 지연 중복 제거 ·
    <a href="take.html"><code>take</code></a> — 접어 넣은 지연 개수 제한 ·
    <a href="uniqStrict.html"><code>uniqStrict</code></a> — 같은 계열의 다른 즉시 연산자 ·
    <a href="performance.html">성능</a> — 콜백 바닥값이 어디서 오는지
  </div>
