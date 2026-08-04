---
slug: unique-tags
title: 모든 게시물의 태그를 정렬해 모으기 — Dart vs FxDart
description: 게시물 태그를 하나의 정렬된 중복 없는 리스트로 평탄화합니다 — 순수 Dart의 expand + toSet + sort와 FxDart의 flatMap + uniq + sort를 비교합니다. 정직한 무승부입니다.
heading: 모든 게시물의 태그를 정렬해 모으기
order: 12
tier: 2
functions: flatMap, uniq, sort
domain: general
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    각 블로그 게시물은 태그 리스트를 가지고 있습니다. 사이트의 태그
    색인을 만드세요: 모든 게시물의 태그를 하나의 시퀀스로 평탄화하고,
    중복을 제거하고, 알파벳순으로 정렬한 뒤, 쉼표로 구분된 한 줄로
    출력합니다. 데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상
    출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 차이가 없습니다. <code>expand</code>는 Dart판
    <code>flatMap</code>이고, <code>toSet()</code>이 중복을 제거하며,
    캐스케이드 <code>..sort()</code>가 마무리합니다 — 그 한 줄짜리
    코드는 정직하고 관용적인 Dart이며 흠잡을 데가 없습니다. FxDart는
    같은 세 단계를 이름 붙은 체인 링크(<code>flatMap → uniq →
    sort</code>)로 표현하는데, 이는 요구사항을 조금 더 그대로 읽히게
    하고, 순서를 보존하는 <code>uniq</code>를 <code>Set</code>을
    선택한 부수 효과가 아니라 명시적인 단계로 드러냅니다. 여러분의
    코드베이스가 이미 쓰고 있는 쪽을 고르세요 — 이번 예제는
    무승부입니다.
  </p>
