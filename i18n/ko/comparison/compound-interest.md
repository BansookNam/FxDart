---
slug: compound-interest
title: 복리 이자 테이블 — Dart vs FxDart
description: 연 5%의 연도별 잔액 테이블입니다 — 순수 Dart의 가변 누산 루프와 FxDart의 range + scan + map을 비교합니다.
heading: 복리 이자 테이블
order: 16
tier: 2
functions: range, scan, map
domain: general
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    <strong>1000달러, 연 5%</strong> 복리로 6년간 불어나는 연도별 잔액
    테이블을 출력하세요 — 0년차 시작 잔액부터 한 줄씩, 각 금액은 소수점
    둘째 자리까지 표시합니다. 상수는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    누적 잔액은 <em>누적 fold</em>이며, 순수 Dart 코어에는 이를 가리키는
    단어가 없습니다: <code>fold</code>는 최종값만 내놓으므로, 네이티브
    버전은 0년차 줄로 리스트를 초기화하고 <code>balance</code>를 변경하며
    값을 추가하는 루프로 돌아갑니다 — 복리 계산 규칙, 반복, 형식 지정이
    모두 하나의 본문 안에 뒤섞여 있습니다. FxDart의 <code>scan</code>은
    중간 잔액 각각을 파이프라인의 값으로 만들어줍니다: 시드는 0년차
    행이고, 복리 계산 규칙은 하나의 순수 함수이며, 형식 지정은 별도의
    <code>map</code> 단계입니다. 잔액이 처음으로 1200달러를 넘는 연도를
    알고 싶다면? 필터 하나를 체인에 이으면 됩니다 — 루프 버전은 대신
    플래그를 하나 더 늘려야 합니다.
  </p>
