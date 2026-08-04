---
slug: empty-report-default
title: 빈 리포트를 위한 기본 한 줄 — RxDart vs FxDart
description: 일치하는 항목이 없는 카테고리로 필터링해도 무언가는 출력하기 — 스트림의 defaultIfEmpty와 pull 체인의 ifEmpty, 두 모델에 담긴 같은 아이디어.
heading: 빈 리포트를 위한 기본 한 줄
order: 7
tier: 1
functions: fx, filter, ifEmpty, map
domain: transactions
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    지출 리포트가 이번 달 거래를 <code>travel</code> 카테고리로
    필터링합니다 — 그런데 한 건도 없습니다. 빈 리포트는 아무것도
    출력하지 않는 대신 <em>no travel spending</em> 한 줄을 출력해야
    합니다. 데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em>
    아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 다르지 않습니다 — 그것도 같은 자리에서요. "비어 있음에는 폴백이
    필요하다"는 두 모델이 정확히 같은 지점에서 부딪히는 문제입니다 —
    하류 단계는, 파이프라인이 그 경우 무엇을 내보낼지 말해 주지 않는 한
    <em>필터링되어 아무것도 없음</em>과 <em>처음부터 아무것도 없었음</em>을
    구별할 수 없습니다 — 그리고 두 라이브러리 모두 연산자 하나로
    답합니다. RxDart의 <code>defaultIfEmpty</code>는 소스가 이벤트 없이
    완료되면 기본값을 주입합니다; FxDart의
    <code>defaultIfEmpty</code>(0.7.2에서 추가, Rx 어휘에서 공개적으로
    빌려왔으며, 지연된 전체-이터러블 형태로
    <code>ifEmpty(() =&gt; fallback)</code>이 있습니다)는 첫 pull이
    아무것도 찾지 못하면 그것을 내놓습니다.
  </p>
  <p>
    잔여 차이는 이 파트에서 늘 보던 그것입니다: 스트림 버전은 <em>완료를
    기다려야만</em> 자신이 비어 있음을 알 수 있으므로 고정 리스트 위에서
    프로그램 전체가 비동기로 가고, pull 버전은 첫 수요에서 동기적으로
    비어 있음을 발견합니다. 그 비용은 실재하지만 여기서는 작고, 연산자
    패리티가 이야기의 본론입니다 — 진짜 무승부이자, 두 라이브러리가
    경쟁하기보다 아이디어를 주고받는 좋은 예입니다.
  </p>
