---
slug: paginate-users
title: 사용자를 10명씩 페이지로 나누기 — Dart vs FxDart
description: 사용자 목록을 고정 크기 페이지로 나눕니다 — package:collection의 slices와 FxDart의 chunk + map을 비교합니다.
heading: 사용자를 10명씩 페이지로 나누기
order: 8
tier: 1
functions: chunk, map
alsoLink: concurrent
domain: users
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    사용자 열두 명을 <strong>10명씩 페이지</strong>로 나누고(마지막
    페이지는 더 짧을 수 있습니다) 각 페이지를 번호, 크기, 이름과 함께
    한 줄로 출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    순수 Dart에는 청크 분할 기능이 아예 없습니다 — 도움 없이는
    <code>sublist</code>를 도는 인덱스 루프에, 짧은 마지막 페이지를
    위한 <code>min</code> 가드까지 필요합니다. <code>package:collection</code>의
    <code>slices</code>가 이를 해결해 주며, 이미 이 패키지를 쓰고
    있다면 두 코드는 거의 쌍둥이입니다. FxDart의 강점은
    <code>chunk</code>가 추가 의존성이 필요 없고, 지연 평가되며(페이지는
    소비할 때 만들어집니다), 바로 같은 단계가 비동기 체인에서도
    동작한다는 점입니다 — <code>concurrent</code> 단계 앞에서 요청을
    배치로 묶는 것이 대표적인 용례입니다. 크지는 않지만 실질적인
    이점입니다.
  </p>
