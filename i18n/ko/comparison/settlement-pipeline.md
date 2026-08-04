---
slug: settlement-pipeline
title: 일일 정산 마감 파이프라인 — Dart vs FxDart
description: 검증하고, 판매자별로 묶고, 2건씩 게시한 다음 보고합니다 — 동기에서 비동기로 넘어가는 체인 하나 대 groupListsBy와 워커 풀.
heading: 일일 정산 마감 파이프라인
order: 52
tier: 4
functions: reject, groupBy, map, sumBy, sortBy, toAsync, concurrent, partition
domain: transactions
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    하루를 마감하세요. 카드 거래 10건(아래 코드)에서:
    <code>failed</code> 거래는 버리고, 나머지를 판매자별로 묶은 뒤,
    각 판매자의 순합계를 구하세요(환불은 음수). 각 판매자의 정산
    내역을 은행 게이트웨이에 게시하되 — 동시 진행 중인 게시는
    <strong>최대 두 건</strong>, 결과는 판매자 순서대로 — 그런 다음
    보고서를 출력하세요: 판매자별 한 줄, 지급/수금 구분(한 판매자는
    환불이 결제액을 초과함), 총합계, 그리고 최대 동시 진행 건수
    증명.
  </p>
  <p>
    이것은 라이브러리 전체가 한 파이프라인에 담긴 예제입니다. 동기
    준비 단계: <code>reject</code> → <code>groupBy</code> → 그룹별
    <code>sumBy</code> → <code>sortBy</code>. <code>toAsync</code>로
    비동기 경계를 넘어, <code>concurrent(2)</code> 아래에서
    게시합니다. 보고서는 <code>partition</code>과 <code>sumBy</code>를
    다시 사용합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이 작업의 각 절반은 더 작은 예제에서 이미 등장했습니다; 여기서
    중요한 것은 그 둘이 만났을 때 무슨 일이 벌어지는가입니다. 네이티브
    Dart는 <code>package:collection</code>(<code>groupListsBy</code>,
    <code>sortedBy</code>)으로 준비 단계를 충분히 잘 처리합니다 —
    다만 그룹별 합계를 내는 것은 명시적 시드를 가진 <code>fold</code>
    이고, 지급 구분은 <code>where</code>를 두 번 통과시키는 것입니다.
    그런 다음 비동기 경계에 부딪히면 구조가 무너집니다: 제한된 게시는
    워커 풀이 필요하고, 슬롯과 커서를 가진 별도의 이름 붙은 함수가
    되어, 읽고 있던 파이프라인이 추적해야 하는 배관으로 바뀝니다.
    FxDart 버전은 원본 거래부터 게시된 정산 내역까지 끊김 없는 체인
    하나입니다 — 열네 줄로, 정책(무엇이 유효한지, 어떻게 묶는지,
    게이트웨이를 얼마나 세게 두드릴지)이 눈에 보이는 텍스트이고,
    메커니즘은 라이브러리의 몫입니다.
  </p>
