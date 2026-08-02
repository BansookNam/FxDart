---
slug: spend-by-category-rx
title: 카테고리별 지출 합계 — RxDart vs FxDart
description: 처음 등장한 순서의 카테고리별 합계 — GroupedStream들의 스트림을 접고 다시 병합해야 하는 쪽 vs 그냥 Map을 돌려주는 groupBy.
heading: 카테고리별 지출 합계
order: 15
tier: 2
functions: fx, groupedBy, map, sumBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    8월 거래 아홉 건을 <strong>카테고리별로</strong> 합산하고, 각
    카테고리가 명세서에 처음 등장한 순서대로 합계를 출력하세요. 데이터는
    아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된
    줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    그룹핑은 push 모델의 "모든 것은 스트림"이라는 약속이 비싸지는
    지점입니다. RxDart의 <code>groupBy</code>는 맵을 반환할 수 없습니다 —
    소스가 영영 끝나지 않을 수도 있으니까요 — 그래서 <em>스트림들의
    스트림</em>을 반환합니다: 새 키마다 <code>GroupedStream</code> 하나.
    합계를 꺼내려면 각 내부 스트림을 접고(<code>Future</code>), 그
    future를 다시 스트림으로 끌어올리고(<code>asStream</code>), 결과를
    <code>flatMap</code>으로 병합해야 합니다 — <code>sum</code> 하나를
    둘러싼 세 겹의 배관입니다. (실용적인 rx 사용자는 스트림 전체를 가변
    맵으로 접어 <code>groupBy</code>를 아예 피해 갈 수 있습니다 — 더
    짧지만, 이 예제가 다루는 연산자를 포기하는 것이고 그룹핑은 다시
    명령형이 됩니다.) 그리고 이 형태에는 날카로운 모서리가 있습니다:
    <code>flatMap</code> 대신 <code>asyncExpand</code>로 접으면 프로그램이
    데드락에 빠집니다. 그룹 합계를 기다리는 동안 외부 스트림을 일시
    정지시키는 것이, 어느 그룹이든 닫히기 전에 완료되어야 하는 소스를
    멈춰 버리기 때문입니다.
  </p>
  <p>
    FxDart의 데이터는 구조상 유한하므로, 그룹핑에 스트림들의 스트림이
    필요 없습니다: <code>groupedBy</code>가 처음 본 키 순서로 평범한
    <code>(key, items)</code> 레코드를 내놓고 체인은 계속 이어지며,
    <code>sumBy</code>가 그룹별 산수를 맡습니다. 아무것도 도착 중이지
    않으므로 아무것도 미뤄지지 않습니다. 살아 있는 무한 피드라면
    GroupedStream 설계가 옳은 선택입니다 — 하지만 이미 손안에 있는
    명세서라면 이것은 pull 형태의 작업이고, pull 버전은 그것을 세 줄로
    말합니다. 판정은 FxDart에게 갑니다.
  </p>
