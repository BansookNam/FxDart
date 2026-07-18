---
slug: flatMap
title: flatMap — FxDart 101
description: FxDart flatMap 튜토리얼: 각 원소를 이터러블로 매핑한 뒤 한 단계 평탄화합니다. 라이브 플레이그라운드 포함.
heading: <code>flatMap</code>
section: 3
crumb: flatMap
prev: mapEffect.html
prevLabel: mapEffect
next: flat.html
nextLabel: flat
---
  <p class="hero-sub">각 원소를 이터러블로 매핑한 다음 결과를 한 단계 평탄화합니다 — <code>Iterable.expand</code>와 동일한 계약입니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>flatMap</code>은 <code>map</code> 뒤에 한 단계 평탄화를 붙인 것입니다.
    각 원소가 결과의 <em>컬렉션</em>으로 바뀌고, 그 컬렉션들이 이어 붙여져
    하나의 평평한 지연 시퀀스가 됩니다. "입력 하나에 출력 여럿"이 필요할 때
    쓰는 도구입니다 — 문장을 단어로 쪼개거나, 사용자를 주문 목록으로 펼치거나,
    범위를 쌍으로 바꾸는 식이죠.
  </p>
  <p>
    <strong>FxTS와 다른 점:</strong> FxTS에서는 콜백이 일반 값과 이터러블을
    섞어서 반환해도 <code>flatMap</code>이 <code>DeepFlat</code> 타입 마법으로
    무엇을 평탄화할지 알아냅니다. Dart에는 그런 조건부 타입이 없기 때문에,
    Dart 포팅판은 <code>f</code>가 <em>항상</em>
    <code>Iterable&lt;B&gt;</code>를 반환하도록 요구합니다 —
    <a href="https://api.dart.dev/stable/dart-core/Iterable/expand.html"><code>Iterable.expand</code></a>와
    똑같습니다. 입력 하나당 값 하나만 내보내려면 원소가 하나인 리스트
    (<code>[x]</code>)를, 아무것도 내보내지 않으려면 빈 리스트를 반환하세요.
  </p>
  <p>
    비동기 쪽에서는 <code>flatMapAsync</code>의 내부 상태 머신이 pull 사이사이에
    "지금 어느 하위 이터러블을 소진하는 중인지"를 추적해야 하므로 상류를
    <em>직렬로</em> 소비합니다. 여기에 <code>.concurrent(n)</code>을 감싸면
    이미 준비된 항목을 끌어오는 속도만 빨라질 뿐, 콜백 안에서 일어나는
    <code>await</code> 자체는 빨라지지 않습니다. 원소마다 비동기 작업을
    동시에 처리하고 싶다면 그 작업을 먼저
    <code>.map(...).concurrent(n)</code> 단계에서 수행한 뒤, 이미 완료된
    리스트들을 <code>.flatMap((list) =&gt; list)</code>로 평탄화하세요 —
    데모 2를 보세요.
  </p>

  <h2>데모 1 · 기본</h2>
  <p>콜백은 반드시 <code>Iterable</code>을 반환해야 합니다 — 여기서는 원소 2개짜리
    리스트와 <code>String.split</code> 호출을 씁니다:</p>
  {{playground:0}}

  <h2>데모 2 · 비동기, 동시성을 제대로 얻는 방법</h2>
  <p>
    느린 <code>await</code>는 <code>.map(...).concurrent(n)</code> 단계에 두고,
    <code>flatMap</code>은 그 결과를 동기적으로 평탄화하게 하세요:
  </p>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>flatMap</code>으로 각 문장을 단어로 쪼개어
    하나의 평평한 단어 리스트를 만들어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="map.html"><code>map</code></a> — 평탄화 없이 변환 ·
    <a href="flat.html"><code>flat</code></a> — 이미 중첩된 이터러블을 평탄화 ·
    <a href="mapEffect.html"><code>mapEffect</code></a> — 부수 효과를 위한 map ·
    <a href="concurrent.html"><code>concurrent</code></a> — 병렬 평가
  </div>
