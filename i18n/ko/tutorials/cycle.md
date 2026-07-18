---
slug: cycle
title: cycle — FxDart 101
description: FxDart cycle 튜토리얼: 시퀀스를 무한히 반복하는 소스 — 반드시 take와 함께 써야 하는 이유를 라이브 플레이그라운드와 함께 배웁니다.
heading: <code>cycle</code>
section: 2
crumb: cycle
prev: repeat.html
prevLabel: repeat
next: entries.html
nextLabel: entries
---
  <p class="hero-sub">시퀀스를 내보낸 뒤 그것을 계속 반복합니다 — 무한히. 항상 take처럼 개수를 제한하는 연산과 함께 쓰세요.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>cycle</code>은 <strong>무한</strong>합니다. 소스 시퀀스를 한 번
    흘려보내면서 값을 버퍼에 담아 두고, 그 다음부터는 그 버퍼를 영원히
    반복합니다. 이 섹션의 다른 함수들과 달리 <code>cycle</code>은 스스로
    끝나는 법이 없습니다 — 언제 멈출지 결정하는 무언가와 반드시 짝지어야
    하며, 대개는 <code>.take(n)</code>입니다. 중간에 아무 제한도 두지 않고
    <code>cycle(...)</code>에 곧바로 <code>toArray()</code>나
    <code>consume()</code>을 호출하면 영영 끝나지 않습니다.
  </p>
  <p>
    알아 둘 만한 특수한 경우가 하나 있습니다. <em>빈</em> 소스를 순환시키면
    원소 0개를 영원히 도는 대신 아무것도 내보내지 않습니다 — 즉
    <code>cycle([])</code>은 안전하며 그냥 빈 결과를 만듭니다.
  </p>
  <p>
    라운드 로빈 할당(더 긴 컬렉션을 map으로 순회하면서 작업자, 색상, 슬롯
    같은 작은 리스트를 돌려 쓰는 경우)이나, 짧은 비동기 시퀀스를 반복해
    폴링 루프를 흉내 내는 데 딱 맞는 구성 요소입니다. 비동기 버전인
    <code>cycleAsync</code>(또는 <code>FxAsync</code> 체인에서의
    <code>.cycle()</code>)도 같은 방식으로 버퍼링하고 반복하되, 매 회차를
    평소의 비동기 프로토콜로 끌어당깁니다.
  </p>

  <h2>데모 1 · 무한 시퀀스를 take로 제한하기</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 cycle, 역시 take로 제한</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 신호등 색을 순환시켜 앞의 8개를 가져와 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="range.html"><code>range</code></a> — 유한한 수 세기 시퀀스 ·
    <a href="repeat.html"><code>repeat</code></a> — 하나의 값을 정해진 횟수만큼 반복합니다 ·
    <a href="take.html"><code>take</code></a> — cycle에 거의 언제나 필요한 제한 ·
    <a href="concurrent.html"><code>concurrent</code></a> — 비동기 cycle의 작업을 겹쳐 실행합니다
  </div>
