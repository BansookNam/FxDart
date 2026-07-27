---
slug: live-search
title: 키 입력 스트림 위의 실시간 검색 — Dart vs FxDart
description: 키 입력 스트림을 중복 제거된 백엔드 검색으로 바꿉니다 — fromStream + filter + uniq + take + map과 guard 절이 있는 await-for를 비교합니다.
heading: 키 입력 스트림 위의 실시간 검색
order: 49
tier: 4
functions: streams, filter, uniq, take, map, head
alsoLink: debounce
domain: general
verdict: fxdart
async: true
---
  <h2>요구사항</h2>
  <p>
    검색창이 모든 키 입력을 Dart <code>Stream</code>으로 내보냅니다 —
    사용자가 <em>darts</em>를 입력해 가는 과정이며, 일부 값은 키 자동
    반복으로 중복됩니다(아래 코드에 고정된 시퀀스). 이를 백엔드 검색으로
    바꾸세요: 두 글자 미만인 쿼리는 건너뛰고, 같은 쿼리는 두 번 검색하지
    않으며, 검색된 쿼리 네 개가 되면 멈추고, 각 쿼리를 히트 수 및 최상위
    히트와 함께 출력하고, 실제로 이루어진 백엔드 호출 수도 출력하세요.
  </p>
  <p>
    <code>fxStream</code>을 쓰면 키 입력 스트림이 파이프라인이 되고, 각
    규칙이 연산자 하나가 됩니다: 길이 하한에는 <code>filter</code>, 중복
    제거에는 <code>uniq</code>, 예산 제한에는 <code>take(4)</code>, 그
    다음 <code>map</code>이 검색을 수행합니다. <code>take</code>가 검색
    단계보다 앞에 있고 체인이 풀 기반(pull-based)이므로, 정확히 네 번의
    백엔드 호출만 일어나고 스트림의 나머지는 전혀 소비되지 않습니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    네이티브 <code>await for</code> 루프는 간결합니다 — 하지만 규칙들이
    어디로 갔는지 보세요: 길이 하한과 중복 제거가 하나의
    <code>continue</code> 조건식(<code>q.length &lt; 2 ||
    !seen.add(q)</code>, 조건문 안에 변경을 몰래 끼워 넣는 방식)을
    공유하고, 예산 제한은 <code>break</code>가 붙은 카운터 검사입니다. 세
    가지 정책이 두 개의 guard 절 안에 압축되어 있으니, 네 번째 규칙을
    추가하려면 그것들을 다시 풀어헤쳐야 합니다. 파이프라인은 규칙마다
    이름 붙은 연산자 하나씩을, 적용되는 순서 그대로 씁니다. 그리고 같은
    체인이 실제 위젯의 텍스트 변경 스트림도 수정 없이 그대로 받아들일
    것입니다. 한 가지 솔직한 단서를 덧붙이자면: fxdart의
    <code>debounce</code>는 스트림 연산자가 아니라 함수 호출 유틸리티여서,
    시간 기준으로 잦은 스트림을 조용하게 만드는 것은 여기서 보여준 네
    규칙과는 다른 도구입니다.
  </p>
