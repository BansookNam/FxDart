---
slug: concat
title: concat — FxDart 101
description: FxDart concat 튜토리얼: 두 개의 지연 이터러블을 앞뒤로 이어 붙이는 방법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>concat</code>
section: 6
crumb: concat
prev: prepend.html
prevLabel: prepend
next: zip.html
nextLabel: zip
---
  <p class="hero-sub">첫 번째 이터러블을 모두 내보낸 뒤, 이어서 두 번째 이터러블을 지연 평가로 내보냅니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>concat</code>은 두 이터러블을 새 리스트로 복사하지 않고 앞뒤로
    이어 붙입니다. 양쪽 모두 완전히 지연 평가되므로, 파이프라인이 첫 번째
    소스의 끝을 실제로 지나가지 않는 한 두 번째 이터러블은 전혀 건드리지
    않습니다. 따라서 비용이 큰 소스나 무한 소스를 첫 번째로 두고 뒤에 다른
    소스를 붙여도, 첫 번째 소스가 가진 것보다 많이 요구하지 않는 한
    안전합니다.
  </p>
  <p>
    <code>concatAsync</code>는 <code>take</code>나 <code>concat</code>의 다른
    async 형제들처럼 그대로 통과시키는 연산자입니다. 내부에서 어느 쪽도
    직렬화하지 않기 때문에, 하류의 <code>concurrent(n)</code>은 현재 활성화된
    쪽에 대해 여전히 pull을 겹쳐서 수행할 수 있습니다.
  </p>

  <h2>데모 1 · 기본과 지연 평가</h2>
  <p>두 번째 이터러블은 부수 효과가 있는 제너레이터입니다. <code>take(2)</code>가
    첫 번째 리스트만으로 충족되기 때문에 아예 실행되지 않는 것을 확인해 보세요.</p>
  {{playground:0}}

  <h2>데모 2 · 비동기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>morning</code>과 <code>evening</code>을 이어 붙여
    하나의 일정으로 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="append.html"><code>append</code></a> — 뒤에 값 하나만 추가 ·
    <a href="prepend.html"><code>prepend</code></a> — 앞에 값 하나만 추가 ·
    <a href="zip.html"><code>zip</code></a> — 이어 붙이는 대신 원소끼리 짝지어 묶기
  </div>
