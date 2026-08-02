---
slug: combine-form-fields
title: 폼이 유효해지면 제출 버튼 켜기 — RxDart vs FxDart
description: 최신 이메일·비밀번호 값을 결합해 제출 버튼을 구동 — Rx.combineLatest2 vs scan으로 접는, 손수 병합한 태그 스트림.
heading: 폼이 유효해지면 제출 버튼 켜기
order: 43
tier: 4
functions: fx, streams, scan, filter
domain: users
verdict: rxdart
async: true
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
    이것은 <em>소스별 최신 값</em> 상태입니다 — 푸시 모델을 정의하는
    결합자입니다. <code>Rx.combineLatest2</code>는 각 필드의 가장 새
    값을 붙들고, 둘 다 말할 때까지 기다렸다가, 어느 쪽에서든 변경이
    있을 때마다 그 쌍을 다시 내보냅니다. 폼 로직이 요구사항 그대로
    읽히고, 출력 네 줄이 선언 하나에서 흘러나옵니다.
  </p>
  <p>
    풀 파이프라인은 <em>하나의</em> 시퀀스를 소비하므로, FxDart 쪽은
    <code>combineLatest</code>가 공짜로 얻는 것을 먼저 다시 지어야
    합니다: 두 필드를 태그 붙은 이벤트의 단일 스트림으로
    병합하고(손수 쓴 컨트롤러와 그것의 구독-둘 닫기 장부 정리까지),
    <code>fxStream</code>으로 브리지한 뒤, <code>scan</code>으로
    태그들을 (email, password) 상태 레코드로 접고,
    <code>filter</code>로 아직 값을 내지 않은 필드가 있는 상태를
    걸러 냅니다. 폴드 자체는 정직하고, 타입이 있고, 읽기 좋습니다 —
    하지만 이것은 연산자의 사용이 아니라 연산자의 재구현입니다. 이런
    반응형 UI 상태야말로 RxDart의 존재 이유이고, 판정은 이론의 여지
    없이 RxDart의 것입니다.
  </p>
