---
slug: monthly-ledger-report
title: 전체 월간 가계부 리포트 — Dart vs FxDart
description: 가계부로부터 하나의 리포트 문자열을 만듭니다 — 총액, 카테고리별 내역, 상위 판매자를 세 개의 fxdart 파이프라인과 루프 및 중간 맵으로 각각 비교합니다.
heading: 전체 월간 가계부 리포트
order: 34
tier: 4
functions: filter, sumBy, groupBy, map, sortBy, take, zipWithIndex, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    한 달치 가계부 거래 내역(데이터는 코드에 있음)으로부터 세 구간을 가진
    하나의 리포트 문자열을 만드세요: <strong>총 지출액</strong>(수입은
    제외), 지출액순으로 정렬된 <strong>카테고리별 내역</strong>, 그리고
    번호가 매겨진 목록 형태의 <strong>상위 3개 판매자</strong>. 두 버전
    모두 <em>예상 출력</em> 아래에 표시된 리포트를 정확히 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    FxDart에서는 리포트의 각 구간이 같은 형태를 가집니다:
    <code>groupBy</code> → 그룹별 <code>sumBy</code> → 내림차순
    <code>sortBy</code> — 그리고 <code>take</code>와
    <code>zipWithIndex</code>가 인덱스 변수 없이도 판매자 구간을 번호
    매겨진 top-3 목록으로 바꿉니다. 네이티브 버전은 이 단계들을 각각
    다른 방언으로 표현해야 합니다: 합계마다 초기값을 가진
    <code>fold</code>, 부정된 키를 쓰는
    <code>sortedBy&lt;num&gt;</code>, 한 구간에는 컬렉션-for, 다른
    구간에는 인덱스가 있는 <code>for</code> 루프. 리포트는 양쪽 모두
    구간별로 자라나지만, 한쪽만 파이프라인 단계를 덧붙이며 자라고 다른
    한쪽은 모양이 제각각인 중간 변수를 쌓으며 자랍니다.
  </p>
