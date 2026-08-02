---
slug: completion-order-pool
title: 가장 빠른 결과부터 — RxDart vs FxDart
description: 각 결과를 도착하는 순간 출력 — 완료 순서는 flatMap의 본래 동작이고, fxdart는 전용 concurrentPool 연산자로 이에 맞섭니다.
heading: 가장 빠른 결과부터
order: 36
tier: 4
functions: fx, toAsync, map, concurrentPool
domain: users
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    응답 시간이 서로 다른 사용자 조회 여섯 건을 한 번에 최대
    <strong>3</strong>개씩 실행하고, 결과를 <strong>완료
    순서</strong>로 보고하세요 — 입력의 어디에 있었든 가장 빠른
    조회가 먼저 출력됩니다. 지연은 순서가 안정되도록 선택되어
    있습니다(user 2, 그다음 1, 4, 3, 5, 6). 데이터는 코드에 들어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이것은 이전 예제의 거울상이고, 판정은 동점으로 뒤집힙니다. 완료
    순서란 병합이 곧 그것<em>인</em> 것입니다: RxDart의
    <code>flatMap(maxConcurrent: 3)</code>은 내부 스트림 세 개를
    구독하고 먼저 발화하는 쪽을 그대로 전달하므로, "빠른 것 먼저, 세
    개씩"은 이 연산자의 문자 그대로의 동작입니다 — 더할 것도, 되돌릴
    것도 없습니다.
  </p>
  <p>
    풀 파이프라인의 기본값은 그 반대 — 결과는 요구된 순서대로
    돌아옵니다 — 그래서 FxDart는 완료 순서를 이름 붙은 변형으로
    제공합니다: <code>concurrentPool(3)</code>은 풀 세 개를 열어 두고
    먼저 풀리는 쪽을 내놓습니다. 병합과 정확히 같습니다. 두 라이브러리
    모두 이 요구사항에 연산자 하나로 도달합니다; 유일한 진짜 차이는 각
    모델이 어떤 동작을 공짜로 얻고 어떤 동작에 이름을 붙여야 했는가
    입니다. 필요한 순서로 고르세요 — 결과가 입력과 줄 맞아야 하면
    <code>mapConcurrent</code>, 첫 결과까지의 지연이 더 중요하면
    <code>flatMap</code> / <code>concurrentPool</code>.
  </p>
