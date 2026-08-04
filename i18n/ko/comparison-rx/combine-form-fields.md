---
slug: combine-form-fields
title: 폼이 유효해지면 제출 버튼 켜기 — RxDart vs FxDart
description: 최신 이메일·비밀번호 값을 결합해 제출 버튼을 구동 — Rx.combineLatest2 vs fxdart 이벤트 레이어의 combineLatest.
heading: 폼이 유효해지면 제출 버튼 켜기
order: 43
tier: 4
functions: fxEvents, combineLatest
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>요구사항</h2>
  <p>
    가입 폼에 필드가 두 개 있습니다. 이메일 필드는 <code>nam</code>,
    그다음 <code>nam@fx.dev</code>를 내보내고; 비밀번호 필드는
    <code>hunter2</code>, 그다음 <code>box-belt-42</code>를 내보냅니다
    — 고정된 교차 오프셋으로. 두 필드가 모두 값을 낸 뒤부터는 변경이
    있을 때마다 최신 값 쌍을 재평가하고(유효 = 이메일에 <code>@</code>
    포함, 비밀번호 8자 이상) 결합된 상태를 출력하세요 — 필드 이벤트 네
    건에서 세 줄이 나옵니다. 첫 변경은 비밀번호가 말하기 전에 도착하기
    때문입니다; 마지막으로 제출 버튼의 최종 상태로 마무리합니다. 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야
    합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    다르지 않습니다. <em>소스별 최신 값</em> 상태는 push 모델을
    정의하는 결합자이고, 두 패널 모두 그것을 한 줄로 선언합니다:
    각 필드의 가장 새 값을 붙들고, 둘 다 말할 때까지 기다렸다가, 어느
    쪽에서든 변경이 있을 때마다 그 쌍을 다시 내보낸다. RxDart는
    <code>Rx.combineLatest2(emails(), passwords(), ...)</code>라고 쓰고;
    fxdart는 <code>fxEvents(emails()).combineLatest(passwords(),
    ...)</code>라고 씁니다. 같은 대기 규칙, 어느 쪽에서든 같은 재방출,
    둘 다 닫히면 닫히는 같은 규칙 — fxdart 패널이 예전에 손으로 말던
    태그 병합-폴드는 사라졌습니다.
  </p>
  <p>
    fxdart의 이벤트 레이어는 정확히 이런 종류의 일을 위해
    Rx의 접근을 흡수했습니다: 평범한 <code>Stream</code> 위의 의도된
    래퍼 체인으로 — extension이 아니어서 rxdart든 다른 어떤 스트림
    라이브러리든 충돌 없이 공존합니다 — pull 파이프라인이 가질 수 없는
    최신 값 결합자들을 실어 나릅니다. 정직한 단서 하나는 그대로입니다:
    RxDart의 연산자 카탈로그는 fxdart의 이벤트 레이어보다 여전히 훨씬
    큽니다. 결합된 폼 상태가 타입 있는 요구 주도 작업 — 이를테면 타입
    있는 에러를 가진 검증된 제출 호출 — 을 구동해야 할 때는
    <code>.pull()</code>이 라이브 쌍들에서 <code>FxAsync</code>
    파이프라인으로 건너갑니다.
  </p>
