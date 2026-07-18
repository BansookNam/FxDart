---
slug: cases
title: cases — FxDart 101
description: FxDart cases 튜토리얼 — 술어와 매퍼로 이루어진 디스패치 테이블을 만들고, 선택적인 기본값도 지정합니다. 라이브 플레이그라운드 포함.
heading: <code>cases</code>
section: 10
crumb: cases
prev: throwIf.html
prevLabel: throwIf
next: add.html
nextLabel: add
---
  <p class="hero-sub">술어와 매퍼로 이루어진 디스패치 테이블을 만듭니다. 기본값도 선택적으로 지정할 수 있습니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>cases</code>는 <code>(predicate, mapper)</code> 쌍의 목록으로
    매처를 만듭니다. 각 쌍을 순서대로 시도해서, 술어가 참을 반환하는
    첫 번째 쌍의 매퍼를 적용해 결과를 만듭니다.
    <code>if</code>/<code>else if</code> 연쇄를 함수형으로 대체하는
    도구이며, <code>map</code>과도 잘 어울립니다 — 반환값이 그대로
    넘길 수 있는 평범한 단항 함수 <code>T -&gt; R</code>이기 때문입니다.
  </p>
  <p>
    <strong>이 형태는 FxTS와 의도적으로 다릅니다.</strong> FxTS의
    <code>cases</code>는 가변 인자를 받습니다. <code>[predicate, mapper]</code>
    쌍 하나하나가 개별 인자이고, 마지막에 함수 하나를 그대로 넘기면
    기본값 역할을 하며, TypeScript는 오버로드된 제네릭으로 각 인자 개수를
    일일이 타이핑합니다. Dart에는 가변 제네릭도, 인자 개수별 오버로드도
    없어서 "쌍 인자를 몇 개든" 받으면서 제대로 된 타입 검사까지
    유지할 방법이 없습니다. 그래서 FxDart 버전은 대신
    <code>List</code> 하나를 받습니다. 그 안에는 <code>(predicate, mapper)</code>
    <strong>레코드</strong>, 즉 Dart의 튜플 타입이 들어갑니다. 여기에 더해,
    기본값이 또 하나의 쌍으로 오해되지 않도록
    별도의 명명 매개변수 <code>orElse</code>를 둡니다.
  </p>
  <p>
    아무것도 매치되지 않고 <code>orElse</code>도 주어지지 않으면
    <code>cases</code>는 <code>value</code> 자체를 반환하려 합니다 —
    이는 <code>T</code>가 마침 <code>R</code>도 만족할 때에만 호출 지점에서
    컴파일되며, 그렇지 않으면 런타임에 <code>StateError</code>를 던집니다.
    실무에서는 술어가 모든 경우를 빠짐없이 다룬다고 확신할 수 있는 게
    아니라면 항상 <code>orElse</code>를 넘기세요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 성적 처리 파이프라인</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 각 크기를 <code>'small'</code>(&lt;10),
    <code>'medium'</code>(&lt;30), <code>'large'</code>로 분류해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="when.html"><code>when</code></a> / <a href="unless.html"><code>unless</code></a> — 술어 하나, 결과 타입은 동일 ·
    <a href="throwError.html"><code>throwError</code></a> — 매치 실패가 치명적이어야 할 때 흔히 쓰는 orElse ·
    <a href="always.html"><code>always</code></a> — 상수 orElse ·
    <a href="matches.html"><code>matches</code></a> — case에 끼워 넣을 수 있는 술어
  </div>
