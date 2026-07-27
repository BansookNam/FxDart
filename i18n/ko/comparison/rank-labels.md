---
slug: rank-labels
title: 리더보드 순위 라벨 — Dart vs FxDart
description: 정렬된 리더보드에 1부터 n까지 번호를 매깁니다 — Dart 3의 indexed 레코드와 FxDart의 zipWithIndex + map을 비교합니다.
heading: 리더보드 순위 라벨
order: 9
tier: 1
functions: zipWithIndex, map
alsoLink: fx
domain: users
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    리더보드는 이미 점수 내림차순으로 정렬되어 있습니다. 선수마다 순위
    라벨을 하나씩 출력하세요 — <strong>1부터 시작하는 순위, 이름,
    점수</strong>. 데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상
    출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이름만 다를 뿐입니다. Dart 3의 <code>indexed</code>는 FxDart의
    <code>zipWithIndex</code>와 정확히 같은 <code>(index, element)</code>
    레코드를 만들어내므로, 두 <code>map</code> 콜백은 글자 하나까지
    동일합니다 — 깔끔한 무승부이며, Dart 코어 라이브러리가 따라잡고
    있음을 보여주는 좋은 예입니다(레코드와 <code>indexed</code>가
    나오기 전에는 네이티브 쪽이 수동 카운터였습니다). 이미
    <code>fx</code> 체인 안에 있다면 <code>zipWithIndex</code>를
    쓰세요 — 이는 비동기 체인에도 존재합니다 — 그 외의 모든 곳에서는
    <code>indexed</code>를 쓰세요.
  </p>
