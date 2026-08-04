---
slug: all-validation-errors
title: 모든 검증 오류 보고하기 — RxDart vs FxDart
description: 폼마다 첫 번째만이 아닌 모든 규칙 위반 — 동기 체인의 평범한 오류 값 vs 오류를 하나만 싣고 닫혀 버리는 오류 채널.
heading: 모든 검증 오류 보고하기
order: 25
tier: 3
functions: fx, map, partition
alsoLink: accumulate
domain: users
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    2026-08 배치의 가입 폼 다섯 건을 세 가지 규칙(이름 존재, 이메일에
    <code>@</code> 포함, 나이 18세 이상)으로 검사합니다. 한 폼이
    <strong>여러</strong> 규칙을 어길 수 있습니다 — 폼마다 어긴 규칙을
    전부 보고한 뒤, 통과한 폼들을 나열하세요. 데이터는 코드에 들어
    있습니다; 두 버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을
    출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    누적 검증은 Rx 오류 채널이 구조적으로 해낼 수 없는 일입니다.
    스트림 오류는 정확히 객체 하나를 싣고, 그것을 내보내는 순간
    스트림이 끝납니다 — 처음 어긴 규칙을 올리면 그 폼의 나머지
    실패도, 남은 폼들도 영영 보지 못합니다. 모든 복구
    연산자(<code>onErrorReturn</code>, <code>onErrorResumeNext</code>)는
    그 오류-하나-그리고-끝 모양을 위해 만들어져 있습니다. 그래서
    여기 보이는 동작하는 RxDart 버전은 조용히 오류 채널을 버립니다:
    각 폼을 <em>데이터</em> 채널 위의 실패 레코드로 매핑합니다 — 그
    시점에 스트림이 기여하는 것은 비동기 <code>main</code>과
    <code>toList</code> 하나뿐입니다.
  </p>
  <p>
    FxDart 쪽은 래퍼를 벗겨 낸 같은 아이디어입니다: 오류는 평범한
    값이므로, 동기 <code>map</code> + <code>partition</code>이 실패한
    폼들(오류 <em>전부</em>와 함께)과 유효한 폼들을 표현식 하나로
    내놓습니다. 그리고 FxDart는 오류를 어디서나 값으로 다루기 때문에
    이 패턴은 레코드를 넘어 확장됩니다: 타입 있는 오류 레이어가
    누적을 대신해 줍니다 — <code>zipOrAccumulate</code>는 모든 규칙을
    실행해 실패를 <code>NonEmptyList</code>로 이어 붙이고,
    <code>mapOrAccumulate</code>는 컬렉션 전체를 fail-slow로
    검증합니다. 그 완전한 버전은 <code>accumulate</code> 튜토리얼을
    보세요; 스트림 모델에는 손을 뻗을 상대가 없습니다.
  </p>
