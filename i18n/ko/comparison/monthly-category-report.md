---
slug: monthly-category-report
title: 지출액순으로 정렬한 월간 카테고리 리포트 — Dart vs FxDart
description: 가계부를 한 달로 필터링하고 카테고리별로 합산해 순위를 매깁니다 — 순수 Dart의 루프와 가변 맵을 FxDart의 filter + groupBy + sortBy와 비교합니다.
heading: 지출액순으로 정렬한 월간 카테고리 리포트
order: 29
tier: 3
functions: filter, groupBy, map, sortBy, join, foldByOrSkip
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    6월에서 7월로 넘어가는 가계부에서 2026년 7월 지출 리포트를 만드세요:
    7월 거래만 남기고, 카테고리별로 합산하여, 카테고리당 한 줄씩
    <strong>지출액이 큰 순서대로</strong> 출력하세요. 데이터는 아래 코드에
    있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄을 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 <code>groupBy</code>가 없으므로, 루프가 가변 맵 안에서
    그룹화와 합산을 동시에 처리합니다 — 코드는 간결하지만 네 가지
    요구사항(7월만, 카테고리별, 합산, 순위)이 하나의 본문 안에 뒤섞여
    있습니다. FxDart 체인은 이를 눈에 보이는 네 단계로 유지합니다:
    <code>filter</code>로 해당 월을 거르고, <code>groupBy</code>로
    카테고리를 나누고, <code>map</code>으로 각 그룹을 합계로 바꾸고,
    <code>sortBy</code>로 내림차순 정렬한 다음 — <code>join</code>이
    리포트 형식을 만듭니다. 요구사항을 하나 더 추가하는 일(예: 최소
    합계 조건)은 체인에 한 단계를 더하는 것으로 끝나지만, 루프에서는
    이미 복잡한 본문 안에 또 하나의 분기를 더하는 일이 됩니다.
  </p>

  <h2>FxDart의 두 가지 표현</h2>
  <p>
    아래 벤치마크에는 <strong>세 번째 막대</strong>가 있습니다 — 다른 한
    페이지에만 있는 것입니다. 위의 체인이 기본으로 쓸 형태입니다:
    <code>filter</code>와 <code>foldBy</code>가 각각 하나의 질문에 답하는 두
    단계입니다. 다만 이 형태가 못 하는 것이 하나 있습니다: 자기 술어를
    인라인하지 못합니다. <code>filter</code>는 지연 단계라 술어를
    이터레이터의 필드에 담아 두는데, AOT 컴파일러는 필드 너머를 보지
    못합니다 — 거래 하나마다 실제 간접 호출을 내고 그 본문은 주변 루프에
    녹아들지 못합니다. <code>foldBy</code>는 그렇지 않습니다. 즉시(strict)
    연산자라 콜백이 매개변수이고 인라인됩니다.
  </p>
  <p>
    <a href="../tutorials/foldByOrSkip.html"><code>foldByOrSkip</code></a>은
    FxDart 패널의 <code>main</code> 위에 있으며, 그 판정을 키 안으로
    옮깁니다. 키가 <code>null</code>이면 그 행을
    건너뛰므로 콜백 하나가 선택과 분류를 겸하고, 그 콜백은 인라인될 만큼
    작은 본문의 매개변수입니다. 거래 100만 건에서 두 번째 막대와 세 번째
    막대의 차이가 그것이고, 첫 번째가 손으로 쓴 루프입니다.
  </p>
  <p>
    기본은 체인으로 쓰십시오 — 무관한 두 질문은 두 단계로 나뉘어야 읽힙니다.
    파이프라인이 뜨거운 경로에 있고 프로파일이 그 술어를 지목할 때
    <code>foldByOrSkip</code>을 꺼내면 됩니다.
  </p>
