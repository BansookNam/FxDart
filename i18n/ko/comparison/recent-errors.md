---
slug: recent-errors
title: 최근 오류 메시지, 중복 제거 — Dart vs FxDart
description: 최신순 로그에서 가장 최근의 서로 다른 오류 3개를 추출합니다 — 순수 Dart의 seen-Set 루프와 break 대 FxDart의 filter + uniqBy + take를 비교합니다.
heading: 최근 오류 메시지, 중복 제거
order: 20
tier: 2
functions: filter, uniqBy, take
domain: logs
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    로그 저장소는 항목을 최신순으로 반환합니다. <strong>가장 최근의 서로
    다른 오류 메시지 세 개</strong>를 표시하세요: <code>ERROR</code> 항목만
    남기고, 이미 표시한 메시지의 반복은 제거하고, 세 개가 되면 멈춥니다.
    데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    Dart에는 "키 기준 distinct"가 없습니다 — 메시지 기준으로 중복을
    제거하려면 <code>Set</code>을 직접 관리해야 하므로, 네이티브 버전은
    세 가지 관심사가 얽힌 루프가 됩니다: 레벨 확인, <code>seen.add</code>
    트릭, 그리고 개수를 세는 <code>break</code>. 각각은 그 자체로는
    문제없지만, 함께 있으면 무엇을 남기는지 알기 위해 루프 전체를 읽어야
    합니다. FxDart는 이 세 가지 규칙을 체인의 세 단계 —
    <code>filter</code>, <code>uniqBy</code>, <code>take</code> — 로
    표현하며, 체인이 지연 평가되므로 세 번째 서로 다른 오류를 찾는 즉시
    로그 스캔을 멈춥니다. 손으로 작성한 <code>break</code>와 정확히
    동일하게 동작합니다.
  </p>
