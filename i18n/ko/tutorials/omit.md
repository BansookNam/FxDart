---
slug: omit
title: omit — FxDart 101
description: FxDart omit 튜토리얼: 원본은 그대로 둔 채 지정한 키를 뺀 Map의 복사본을 얻는 방법을 알아봅니다.
heading: <code>omit</code>
section: 9
crumb: omit
prev: fromEntries.html
prevLabel: fromEntries
next: pick.html
nextLabel: pick
---
  <p class="hero-sub">지정한 키를 제외한 <code>Map</code>의 복사본을 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>omit</code>은 원본의 모든 항목을 그대로 담은 새 <code>Map</code>을
    만들되, 나열한 키만 <em>제외합니다</em> —
    원본 맵은 절대 변경되지 않습니다.
    <code>keysToOmit</code>에 넣었지만 실제로는 맵에 없는 키는
    그냥 무시되며, 제거 목록에 여분의 키가 섞여 있어도 오류가 나지 않습니다.
  </p>
  <p>
    민감 정보 제거나 직렬화에 흔히 쓰이는 도구입니다. 사용자 객체를 로깅하기 전에
    비밀번호 해시를 걷어 내거나, 응답을 보내기 전에 내부 필드를 빼는 식이죠.
    <code>map()</code>과 함께 쓰면 맵으로 이루어진 목록 전체를 한 번에
    가릴 수 있습니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 목록 전체에서 민감 정보 제거하기</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: <code>omit</code>으로 <code>config</code>에서 <code>'debug'</code> 키를 제거해 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 함수:</strong>
    <a href="pick.html"><code>pick</code></a> — 반대로, 일부 키만 남기기 ·
    <a href="omitBy.html"><code>omitBy</code></a> — 키 목록 대신 술어로 제거하기 ·
    <a href="compactObject.html"><code>compactObject</code></a> — 값이 null인 키 제거하기 ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — Map을 처음부터 만들기
  </div>
