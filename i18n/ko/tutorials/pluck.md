---
slug: pluck
title: pluck — FxDart 101
description: FxDart pluck 튜토리얼: 맵의 리스트에서 특정 필드 하나만 뽑아내는 방법을 라이브 플레이그라운드와 함께 알아봅니다.
heading: <code>pluck</code>
section: 3
crumb: pluck
prev: peek.html
prevLabel: peek
next: filter.html
nextLabel: filter
---
  <p class="hero-sub">이터러블에 든 모든 맵에서 특정 키의 값을 뽑아냅니다 — "이 필드만 주세요"라는 흔한 요구를 한 줄로 해결합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>pluck</code>은 <code>map</code>을 아주 작게 특수화해 이름을
    붙인 함수입니다 — 내부는 말 그대로
    <code>map((a) =&gt; a[key], iterable)</code>입니다. "레코드 목록에서
    필드 하나 꺼내기"가 자기 이름을 가질 만큼 자주 등장하고, 호출부에서
    일회용 람다보다 읽기 좋기 때문에 존재합니다.
  </p>
  <p>
    반환 타입이 <code>Iterable&lt;V&gt;</code>가 아니라
    <code>Iterable&lt;V?&gt;</code>라는 점에 주목하세요.
    <code>Map</code> 조회는 키가 있다고 보장할 수 없으므로, 없는 키는
    예외를 던지는 대신 결과에서 <code>null</code>이 됩니다. 그 null을
    나중에 걷어내야 한다면
    <a href="compact.html"><code>compact</code></a>로 이어 붙이세요.
  </p>
  <p>
    <strong>체인 메서드는 없습니다</strong> — <code>pluck</code>은
    <code>Fx</code>/<code>FxAsync</code>에 붙지 않고, data-first 최상위
    함수만 존재합니다. 소스에 직접 호출하거나, 이어서 체인하고 싶다면 결과를
    <code>fx(...)</code>/<code>fxAsync(...)</code>로 감싸세요.
  </p>

  <h2>데모 1 · 기본 &amp; 없는 키</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기, 그리고 동시성</h2>
  <p>
    <code>pluckAsync</code>는 <code>mapAsync</code> 위에 바로 얹혀
    있으므로, 레코드를 먼저 동시에 가져온 뒤 필요한 값을 뽑아내면
    됩니다.
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>pluck</code>으로 상품 제목만 모은 리스트를
    만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="map.html"><code>map</code></a> — pluck이 특수화한 일반형 ·
    <a href="compact.html"><code>compact</code></a> — pluck이 만들어 낼 수 있는 null 걷어내기 ·
    <a href="../tutorials/prop.html"><code>prop</code></a> — 맵 하나를 다루는 pluck의 사촌 ·
    <a href="filter.html"><code>filter</code></a> — 조건에 맞는 원소만 남기기
  </div>
