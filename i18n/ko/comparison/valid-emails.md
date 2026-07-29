---
slug: valid-emails
title: 정규화한 유효 이메일 상위 5개 — Dart vs FxDart
description: 다듬고, 소문자로 바꾸고, 유효성을 검사한 뒤 다섯 개를 취합니다 — 순수 Dart의 map/where/take와 FxDart의 map + filter + take를 비교합니다. 이 경우 순수 Dart도 똑같이 깔끔합니다.
heading: 정규화한 유효 이메일 상위 5개
order: 19
tier: 2
functions: map, filter, take
alsoLink: fx, groupBy, scan, zip, concurrent
domain: users
verdict: native
async: false
---
  <h2>요구사항</h2>
  <p>
    가입 입력값은 지저분합니다: 불필요한 공백, 뒤섞인 대소문자, 그리고
    이메일이 전혀 아닌 문자열 몇 개가 섞여 있습니다. 각 항목을
    정규화하고(다듬기, 소문자 변환), 그럴듯한 이메일만 남긴 뒤
    (<code>@</code>과 마침표를 포함), <strong>처음 다섯 개</strong>를
    출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상
    출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    차이가 없고, 그게 바로 요점입니다. <code>map</code>,
    <code>where</code>, <code>take</code>는 모든 Dart
    <code>Iterable</code>에 기본으로 딸려 있고, 지연 평가되며, 두
    버전은 <code>where</code>를 <code>filter</code>라고 부른다는 점만
    빼면 같은 파이프라인입니다. 이런 짧은 정규화-검증-자르기 체인에서는
    순수 Dart도 똑같이 명료합니다 — 이럴 때는 순수 Dart를 쓰세요.
    FxDart는 파이프라인에 Dart에 없는 어휘가
    필요할 때(<code>groupBy</code>, <code>scan</code>, <code>zip</code>,
    <code>concurrent</code> 등), 혹은 파일의 나머지 부분이 이미
    <code>fx</code>로 체인을 이루고 있을 때 진가를 발휘합니다. 이
    짧은 코드 하나만을 위해 의존성을 추가하는 것은 아무런 이득이
    없습니다.
  </p>
