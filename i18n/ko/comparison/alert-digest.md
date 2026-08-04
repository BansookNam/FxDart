---
slug: alert-digest
title: 서비스와 심각도별 로그 알림 다이제스트 — Dart vs FxDart
description: WARN과 ERROR 로그를 들여쓰기된 다이제스트로 표현합니다 — groupBy + flatMap + uniq를 이용한 중첩 그룹화와 세 겹의 중첩 루프 및 seen 집합을 비교합니다.
heading: 서비스와 심각도별 로그 알림 다이제스트
order: 39
tier: 4
functions: filter, countBy, groupBy, sortBy, flatMap, map, uniq, join
domain: logs
verdict: fxdart
async: false
---
  <h2>요구사항</h2>
  <p>
    서비스 로그 스트림(데이터는 코드 안에 있음)에서 <code>WARN</code>과
    <code>ERROR</code> 줄만 남겨 들여쓰기된 다이제스트로 표현하세요: 서비스는
    알림 개수로 정렬하고, 각 서비스 아래에는 심각도와 그 개수를, 각 심각도
    아래에는 <em>서로 다른</em> 메시지를 나열합니다. 헤더 줄에는 전체
    ERROR/WARN 합계가 표시됩니다. 두 버전 모두 <em>예상 출력</em> 아래에
    표시된 다이제스트를 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    들여쓰기된 다이제스트는 트리를 줄 단위로 평탄화한 것이며,
    <code>flatMap</code>은 정확히 그 평탄화 작업입니다: 바깥쪽의
    <code>groupBy</code> + <code>sortBy</code> + <code>flatMap</code>이
    서비스마다 헤더와 그 하위 항목을 내보내고, 안쪽의 <code>flatMap</code>이
    심각도마다 같은 일을 하며, <code>uniq</code>가 중복되는 메시지를
    그때그때 처리합니다. <code>countBy</code>는 헤더의 합계를 한 단어로
    구해줍니다. 네이티브 버전은 공유 <code>body</code> 리스트에 써넣는 세
    겹의 중첩 <code>for</code> 루프에, 직접 작성한 카운팅 맵과 중복 제거용
    <code>seen</code> 집합까지 더해집니다 — 트리 구조는 두 버전 모두에
    실제로 존재하지만, 그것을 코드의 들여쓰기만으로 읽어낼 수 있는 쪽은
    하나뿐입니다.
  </p>
