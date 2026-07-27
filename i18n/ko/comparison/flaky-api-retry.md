---
slug: flaky-api-retry
title: Poll a flaky API until first success — Dart vs FxDart
description: Retry-until-ready as a lazy pipeline — range + toAsync + map + dropWhile + head vs an imperative polling loop with a break.
heading: Poll a flaky API until first success
order: 42
tier: 4
functions: range, toAsync, map, peek, dropWhile, head
domain: general
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    내보내기 작업의 상태 엔드포인트는 결정적으로 불안정합니다: 처음
    네 번의 폴링은 <code>pending</code>을 응답하고, 다섯 번째는
    <code>ready</code>를 응답합니다. 최대 열 번까지 폴링하면서 모든
    폴링 기록을 로그로 남기고, 첫 성공에서 멈추고, 어느 시도가
    성공했는지와 실제로 몇 번 폴링했는지를 보고하세요. 무작위성은
    없습니다: 실패 횟수는 아래 코드에 고정되어 있으므로, 두 버전
    모두 실행할 때마다 같은 결과를 출력합니다.
  </p>
  <p>
    FxDart 버전은 재시도를 데이터로 씁니다: <code>range(1, 11)</code>이
    폴링 일정이고, <code>map</code>이 전송이고, <code>peek</code>이
    로그를 기록하고, <code>dropWhile</code> + <code>head</code>가 성공
    정책입니다. 체인이 지연 평가되고 값을 한 번에 하나씩만 끌어오기
    때문에, <code>head</code>가 폴링을 멈추게 합니다 — 실제로는 다섯
    번의 요청만 이루어집니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    솔직히 말하면: <code>break</code>를 쓴 네이티브 <code>for</code>
    루프는 짧고, 이걸 틀렸다고 할 사람은 없습니다. 차이는 각 부분이
    어디에 사는가입니다. 루프 안에서는 시도 횟수 예산, 로깅, 성공
    판정이 모두 제어 흐름 속에 뒤엉켜 있어서, 하나를 바꾸려면 본문
    전체를 다시 읽어야 합니다. 파이프라인에서는 각 관심사가 이름
    붙은 자기만의 단계이므로, 정책을 바꾸는 일(첫 성공 → 세 번째
    성공, 변환 추가, 예산 확장)은 한 줄만 고치면 됩니다. 그리고
    "승자 이후에는 폴링하지 않는다"는 지연 평가 보장은 FxDart에서
    구조적으로 성립하는 반면, 루프에서는 <code>break</code>가 올바른
    위치에 있는지에 달려 있습니다.
  </p>
