---
slug: unique-visitors
title: 고유 방문자, 첫 방문만 남기기 — RxDart vs FxDart
description: 방문 로그를 피드 전체에 걸쳐 중복 제거하고 각 사용자의 첫 방문만 남기기 — equals+hashCode가 필요한 distinctUnique와 키 함수 하나면 되는 uniqBy를 비교합니다.
heading: 고유 방문자, 첫 방문만 남기기
order: 5
tier: 1
functions: fx, uniqBy, map
domain: users
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    오늘의 방문 로그에는 네 계정의 방문 여덟 건이 있습니다. 각 사용자의
    <strong>첫</strong> 방문만 남기고 — 인접 항목만이 아니라 로그 전체에
    걸쳐 중복을 제거해서 — 누가, 언제 처음 왔는지, 그리고 고유 방문자
    수를 출력하세요. 데이터는 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    이것은 FxDart 연산자에 대응하는 RxDart의 가장 훌륭한 짝 중 하나입니다.
    순수 <code>Stream.distinct</code>는 <em>인접한</em> 이벤트만
    비교하므로(FxDart의 <code>uniqAdjacent</code>가 같은 아이디어입니다),
    RxDart는 <code>distinctUnique</code>를 추가합니다: 스트림 전체에 걸친
    중복 제거, 첫 등장 유지 — 정확히 <code>uniqBy</code>의 계약입니다.
    둘 다 스트림이 사는 동안 seen 집합을 유지하고, 둘 다 도착 순서를
    보존하며, ana의 09:40과 11:48 재방문은 양쪽에서 똑같이 사라집니다.
  </p>
  <p>
    남는 차이는 인체공학이지 의미론이 아닙니다. "같은 방문자"는
    <code>uniqBy</code>에서는 키 함수 하나 —
    <code>(v) =&gt; v.user</code> — 인 반면,
    <code>distinctUnique</code>는 짝이 맞는 <code>equals</code> +
    <code>hashCode</code> 쌍, 즉 서로 합의해야 하는 클로저 두 개를
    요구합니다. 이것은 가벼운 불편이지 모델 격차가 아니고, async main은
    고정 데이터 위 스트림의 늘 있는 오버헤드입니다. 판정: 무승부 — 전역
    중복 제거 연산자는 양쪽 모두에 존재하고 같은 방식으로 동작합니다.
  </p>
