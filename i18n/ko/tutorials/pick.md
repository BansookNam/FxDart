---
slug: pick
title: pick — FxDart 101
description: FxDart pick 튜토리얼: 지정한 키만 남긴 Map의 복사본을 반환하며, 없는 키는 결과에서도 그냥 빠집니다.
heading: <code>pick</code>
section: 9
crumb: pick
prev: omit.html
prevLabel: omit
next: omitBy.html
nextLabel: omitBy
---
  <p class="hero-sub">지정한 키만 남긴 <code>Map</code>의 복사본을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>pick</code>은 <code>omit</code>을 뒤집은 것입니다. 무엇을 뺄지
    나열하는 대신 무엇을 남길지 나열하죠. 요청한 키가 원본 맵에 없으면
    결과에서도 그냥 빠집니다 — <code>pick</code>은 <code>null</code>
    자리표시자를 채워 넣지 않으므로, 결과의 키 집합이
    <code>keysToPick</code>보다 작을 수 있습니다.
  </p>
  <p>
    큰 맵의 좁은 "뷰"가 필요할 때마다 쓰면 됩니다. 내부 레코드에서
    뽑아낸 공개 API 응답이라든지, 전체 행에서 뽑아낸 요약 행처럼요.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 리스트 전체를 가볍게 만들기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>pick</code>으로 <code>profile</code>에서 <code>'id'</code>와 <code>'email'</code>만 남겨 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="omit.html"><code>omit</code></a> — 그 반대: 일부 키만 제거합니다 ·
    <a href="pickBy.html"><code>pickBy</code></a> — 키 목록 대신 술어로 남깁니다 ·
    <a href="props.html"><code>props</code></a> — 여러 값을 List로 뽑아냅니다 ·
    <a href="prop.html"><code>prop</code></a> — 값 하나를 뽑아냅니다
  </div>
