---
slug: nullable
title: nullable — FxDart 101
description: FxDart nullable 튜토리얼: nullable과 nullableAsync 빌더 — nullable 값을 일직선으로 풀어내는, Option 타입을 대신하는 nullable 우선 대안.
heading: <code>nullable</code>
section: 13
crumb: nullable
prev: raise.html
prevLabel: either &amp; Raise
next: nonEmptyList.html
nextLabel: NonEmptyList
---
  <p class="hero-sub">
    정보 없는 raise 스코프에서 블록을 실행합니다: 어디서든 단락이 일어나면
    블록 전체가 <code>null</code>로 평가됩니다. <code>Option</code> 타입을
    대신하는 nullable 우선 대안입니다.
  </p>

  {{signature}}

  <h2>강의</h2>
  <p>
    필요한 실패 정보가 <em>부재</em>뿐이라면 <code>Either</code>는
    과합니다 — Dart에는 이미 부재 전용 채널이 있으니까요: <code>T?</code>.
    <code>nullable</code>은
    <a href="raise.html"><code>either</code> 빌더</a>의 정보 없는
    쌍둥이입니다(Arrow의 <code>nullable&nbsp;{&nbsp;}</code>를 이식한
    것입니다). 스코프의 <code>r.bind(value)</code>가 nullable을 풀어내고,
    값이 <code>null</code>이면 블록 전체가 <code>null</code>을 반환합니다.
  </p>
  <p>
    <code>?.</code>과 <code>??</code>를 이어 붙이는 방식과 비교했을 때의
    이득은, <em>어느</em> 단계에서든 — 조회든, 파싱이든,
    <code>r.ensure(cond)</code>를 통한 조건 검사든 — 중첩 없이 빠져나올 수
    있고 중간 값들은 계속 승격된 non-null 상태로 남는다는 점입니다. FxDart가
    <code>Option</code>/<code>Maybe</code> 타입을 제공하지 않는 이유가
    이것입니다: <code>T?</code>에 이 빌더를 더하면 감싸는 비용 없이 그 역할이
    전부 채워집니다.
  </p>

  <h2>데모 1 · tryParse에 bind 걸기</h2>
  {{playground:0}}

  <h2>데모 2 · ?. 계단 없이 깊이 조회하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>
    연습: <code>lastSeen['lee']</code>는 존재하지만 <code>null</code>을 담고
    있고, <code>'park'</code>은 아예 없습니다 — <code>r.bind</code>는 둘 다
    부재로 취급합니다. 양쪽 모두 <code>null</code>이 출력되도록
    <code>describe</code>를 고쳐 보세요.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="raise.html"><code>either</code> 빌더</a> — 실패에 이유가 필요할 때 ·
    <a href="either.html"><code>Either</code></a> — <code>getOrNull()</code>이 nullable로 돌아가는 다리를 놓아 줍니다 ·
    <a href="compact.html"><code>nonNulls</code></a> — 파이프라인에서 null 걸러 내기 ·
    <a href="typedErrors.html">타입 있는 에러 — 전체 가이드</a>
  </div>
