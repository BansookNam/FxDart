---
slug: reverse
title: reverse — FxDart 101
description: FxDart reverse 튜토리얼: 유한한 이터러블을 뒤에서부터 순회합니다. 라이브 플레이그라운드 포함.
heading: <code>reverse</code>
section: 6
crumb: reverse
prev: transpose.html
prevLabel: transpose
next: fork.html
nextLabel: fork
---
  <p class="hero-sub">소스를 역순으로 반환합니다.</p>

  {{signature}}

  <h2>강의</h2>
  <p>
    <code>reverse</code>는 소스의 원소를 마지막부터 처음 순서로 내보냅니다.
    <code>takeRight</code>이나 <code>dropRight</code>과 마찬가지로 전체를
    보기 전에는 "마지막"이 무엇인지 알 방법이 없으므로,
    <code>reverse</code>는 값을 하나라도 내보내기 전에 소스 전체를 리스트로
    <strong>구체화</strong>합니다. 버퍼링이 가능한 유한 소스를 위한
    연산자이며, 무한한 소스에서는 절대 끝나지 않습니다.
  </p>
  <p>
    <code>reverseAsync</code>도 같은 규칙을 따릅니다. 상류의 모든 원소를
    먼저 await한 다음 뒤에서부터 되돌려 줍니다. 진짜 역순이 아니라 시퀀스의
    뒷부분만 필요하다면 <code>takeRight</code>을 쓰는 편이 낫습니다.
    이쪽도 구체화하기는 하지만, 적어도 순서대로 출력할 값이 모이는 즉시
    멈춥니다.
  </p>

  <h2>데모 1 · 기본</h2>
  {{playground:0}}

  <h2>데모 2 · 비동기 (소스 전체를 먼저 버퍼링해야 합니다)</h2>
  {{playground:1}}

  <h2>직접 해 보기</h2>
  <p>연습: 가장 최근 방문이 앞에 오도록 history를 뒤집어 보세요.</p>
  {{playground:2}}

  <div class="callout">
    <strong>관련 항목:</strong>
    <a href="takeRight.html"><code>takeRight</code></a> — 역시 구체화하지만 뒷부분만 필요 ·
    <a href="dropRight.html"><code>dropRight</code></a> ·
    <a href="sort.html"><code>sort</code></a> — 마찬가지로 새 리스트로 구체화
  </div>
