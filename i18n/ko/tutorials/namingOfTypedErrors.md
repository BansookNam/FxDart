---
slug: namingOfTypedErrors
title: 왜 "타입 있는 에러"인가 (Monad가 아니라) — FxDart 101
description: FxDart 타입 있는 에러의 이름에 담긴 이유: 왜 Monad라고 부르지 않는지, 왜 Arrow의 어휘를 선택했는지, 왜 raise라는 이름을 아껴 두었는지.
heading: 왜 이름이 "타입 있는 에러"인가요?
section: 13
crumb: naming
---
  <p class="hero-sub">
    <code>either</code> 뒤에 있는 이 기능은 다른 생태계에서 유명한 이름들을
    갖고 있습니다 — <a href="monad.html"><em>Monad</em></a>,
    <em>Railway-oriented programming</em>. 이 페이지는 FxDart가 왜 일부러
    그 어떤 이름도 쓰지 않는지 설명합니다. (모나드가 처음이라면
    <a href="monad.html">모나드 &amp; 컴프리헨션 블록</a>부터 보세요.)
  </p>

  <h2>왜 "Monad"가 아닌가요?</h2>
  <p>
    기능을 잘못 설명하는 이름이기 때문입니다. <code>Raise</code> 설계의
    핵심은 모나딕 스타일이 <em>아니라는</em> 것입니다 — 이 기능은
    <code>flatMap</code> 연쇄를 일직선 코드로 <strong>대체하기</strong> 위해
    존재합니다. <a href="typedErrors.html">타입 있는 에러 페이지</a>에서 본
    그대로입니다: <code>either((r) { ... })</code> 블록은 중첩
    <code>flatMap</code> 피라미드의 대안이지, 그것을 감싼 포장이 아닙니다.
  </p>
  <p>
    이 기능의 설계 원본인 Kotlin의 Arrow가 정확히 같은 결정을 거쳤습니다.
    Arrow 1.x에는 <code>Monad</code> 타입클래스와 고차 타입(HKT) 흉내,
    그리고 그에 딸린 Haskell 어휘가 있었습니다. Arrow 2.x는
    <strong>그 전부를 삭제했고</strong>, 핵심 연산의 이름조차 커뮤니티
    투표로 <code>shift</code> → <code>raise</code>로 바꿨습니다 — 이론이
    쓰는 단어 대신 사용자가 이해하는 단어를 고른 것입니다. 교훈은
    일반화됩니다: 원하는 독자에 맞춰 이름을 지으세요. FxDart의 독자는 평범한
    Dart 개발자이지 범주론자가 아닙니다.
  </p>
  <p>
    Dart 안에도 반면교사가 있습니다. 공개 API가 Haskell을 말하는 FP
    라이브러리들(<code>Monad2</code>, <code>HKT</code>,
    <code>Do</code> 표기법)은 타입 있는 에러의 혜택을 가장 크게 볼 바로 그
    개발자들을 겁먹게 합니다. "Monad"라는 제목의 페이지는 자기 독자를
    쫓아내는 동시에 — 이 API가 유일하게 아닌 바로 그것을 설명하게 됩니다.
  </p>

  <h2>왜 "타입 있는 에러"인가요?</h2>
  <ul>
    <li><strong>기능이 하는 일을 그대로 말합니다</strong> — 에러가 타입
      시스템을 지나쳐 던져지는 대신 타입 시스템에 실려 다닌다는 것.
      범주론이 이 모양을 뭐라고 부르는지가 아니라요.</li>
    <li><strong>Arrow 자신의 이름입니다.</strong> Arrow 문서의 해당 챕터
      제목이 문자 그대로 <em>Typed errors</em>입니다. Dart 대응물을 검색하는
      Kotlin 개발자가 정확한 단어로 도착하게 됩니다.</li>
    <li><strong>하우스 규칙을 따릅니다.</strong> FxDart의 이름 철학
      (<code>WHY_CURRIED.md</code>: "철자가 아니라 의미를 이식하라")은 이렇게
      말합니다: Haskell 이름이 아니라 Dart 이름 — <code>fmap</code>이 아니라
      <code>map</code>, 동사 <code>bind</code>가 아니라
      <code>flatMap</code>, <code>handleErrorWith</code>가 아니라
      <code>recover</code>.</li>
  </ul>

  <h2>왜 "raise"가 아닌가요?</h2>
  <p>
    <code>raise</code>는 정확하면서도 "멋진" 이름입니다 — 이 DSL의 실제
    이름이고, 여기의 튜토리얼 URL은 함수 이름을 따릅니다
    (<code>concurrent.html</code>, <code>fx.html</code>). 하지만 일부러 아껴
    두었습니다. 나중에 섹션&nbsp;13에 함수별 튜토리얼 페이지
    (<code>either.html</code>, <code>bind.html</code>, …)가 생기면, 개요
    페이지가 <code>raise.html</code>을 차지하고 있을 경우 미래의
    <code>raise</code> 함수 튜토리얼과 충돌합니다.
    <code>typedErrors.html</code>은 섹션 개요 페이지로서 영원히 안전합니다.
  </p>

  <h2>"Railway"는 어떤가요?</h2>
  <p>
    <em>Railway-oriented programming</em>은 같은 아이디어(성공 선로와 실패
    선로)를 가리키는 잘 알려진 비유입니다. 훌륭한 멘탈 모델이지만 — 페이지
    이름으로는 부적합합니다: 검색이 어렵고, Arrow의 어휘가 아니며, 이미 알고
    있어야만 도움이 되는 비유이기 때문입니다.
  </p>

  <div class="callout">
    <strong>원칙 한 줄.</strong> 이름은 API의 일부입니다. Dart 개발자가
    검색할 법한 단어로 그것이 무엇을 하는지 말해야 합니다 — <em>타입 있는
    에러</em> — 그것이 남몰래 어떤 추상화인지 인증하는 것이 아니라요.
  </div>