---
slug: apply
title: apply — FxDart 101
description: FxDart apply 튜토리얼 - List에 모아 둔 인자로 함수를 호출하는 법을 라이브 플레이그라운드와 함께 다룹니다.
heading: <code>apply</code>
section: 10
crumb: apply
prev: tap.html
prevLabel: tap
next: juxt.html
nextLabel: juxt
---
  <p class="hero-sub">인자가 담긴 List를 위치 파라미터로 넘겨 함수를 호출합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>apply</code>는 호출에 넘길 인자들이 개별 변수로 흩어져 있지 않고
    이미 <code>List</code>에 모여 있을 때를 위한 함수입니다(입력에서
    파싱했거나, 설정에서 모았거나,
    <a href="juxt.html"><code>juxt</code></a>가 만들어 낸 경우처럼) —
    그 인자들로 임의의 함수를 호출해야 할 때 씁니다. 내부적으로는 Dart의
    <code>Function.apply</code>를 얇게 감싸고 결과를 <code>R</code>로
    캐스팅한 것입니다.
  </p>
  <p>
    <code>f</code>의 타입이 그냥 <code>Function</code>이기 때문에
    <code>apply</code>는 본질적으로 동적입니다 — Dart는 인자 개수나 타입을
    <code>f</code>의 시그니처와 대조해 컴파일 타임에 검사할 수 없고, 런타임에만
    확인합니다. 정말로 동적인 인자 목록을 다룰 때만 꺼내 쓰고, 그 밖의
    경우에는 함수를 직접 호출하세요.
  </p>
  <p>
    관련은 있지만 별개의 주제로 <em>커링</em>이 있습니다 — 함수의 일부 인자를
    미리 채워 두는 것이죠. FxTS에는 완전한 제네릭 <code>curry</code>가 있지만
    Dart의 타입 시스템에는 임의의 인자 개수를 다룰 방법이 없어서, FxDart는
    마이그레이션 보조용으로 <code>@Deprecated</code> 처리된 2인자
    <code>curry</code> 스텁만 제공합니다. 클로저를 직접 작성하는 편이 낫습니다:
    <code>(b) => f(a, b)</code>.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 동적 호출 디스패치하기</h2>
  <p>
    핸들러마다 인자 개수가 다르고 인자는 런타임 <code>List</code>로 들어오는
    간단한 커맨드 디스패처입니다:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 아래 <code>greet</code>를 인자 목록
    <code>['Kim', 'Hello']</code>와 함께 <code>apply</code>로 호출해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="juxt.html"><code>juxt</code></a> — 동적 인자 목록이 만들어지는 대표적인 출처 ·
    <a href="tap.html"><code>tap</code></a> — 값을 바꾸지 않고 부수 효과만 실행 ·
    <a href="cases.html"><code>cases</code></a> — 이름 대신 술어로 디스패치 ·
    <a href="pipe.html"><code>pipe</code></a> — 동적 조합, apply와 같은 트레이드오프
  </div>
