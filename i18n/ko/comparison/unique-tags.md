---
slug: unique-tags
title: 모든 게시물의 태그를 정렬해 모으기 — Dart vs FxDart
description: 게시물 태그를 하나의 정렬된 중복 없는 리스트로 평탄화합니다 — 순수 Dart의 expand + toSet + sort와 FxDart의 flatMap + uniq + sort를 비교합니다. 코드는 무승부, 시계는 1.5배 차이입니다.
heading: 모든 게시물의 태그를 정렬해 모으기
order: 12
tier: 2
functions: flatMap, uniq, sort
domain: general
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    각 블로그 게시물은 태그 리스트를 가지고 있습니다. 사이트의 태그
    색인을 만드세요: 모든 게시물의 태그를 하나의 시퀀스로 평탄화하고,
    중복을 제거하고, 알파벳순으로 정렬한 뒤, 쉼표로 구분된 한 줄로
    출력합니다. 데이터는 아래 코드에 있으며, 두 버전 모두 <em>예상
    출력</em> 아래에 표시된 줄을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    코드만 보면 거의 차이가 없습니다. <code>expand</code>는 Dart판
    <code>flatMap</code>이고, <code>toSet()</code>이 중복을 제거하며,
    캐스케이드 <code>..sort()</code>가 마무리합니다 — 이 체인은 정직하고
    관용적인 Dart이며 흠잡을 데가 없습니다. FxDart는 같은 세 단계를 이름
    붙은 체인 링크(<code>flatMap → uniq → sort</code>)로 표현하는데, 이는
    요구사항을 조금 더 그대로 읽히게 하고, 순서를 보존하는
    <code>uniq</code>를 <code>Set</code>을 선택한 부수 효과가 아니라
    명시적인 단계로 드러냅니다. 코드로서는 무승부입니다.
  </p>
  <p>
    하지만 시계는 무승부가 아닙니다. 아래 벤치마크 막대에서 FxDart는 게시물
    100만 건 기준으로 순수 Dart 체인의 <strong>1.47배 속도</strong>를
    냅니다 — 108.0 ms 대 73.5 ms — 그리고 이 비율은 작은 규모까지 그대로
    유지됩니다(N=10,000에서 1.36배, N=100에서 1.29배). 그 두 규모가 그래도
    <em>속도 동일</em> 배지를 다는 이유는 절대 격차가 이 사이트의 체감
    기준선인 0.6 ms 아래이기 때문입니다. 양쪽이 하는 일은 완전히 같습니다.
    태그 문자열 300만 개를 평탄화 이터레이터로 끌어내고, 해시 집합에 넣어
    서로 다른 값 500개만 남기고, 500개짜리 정렬을 한 번 합니다. 알고리즘에
    다른 점은 없습니다.
  </p>
  <p>
    격차 전부는 <code>dart:core</code>의 <code>ExpandIterator</code>가 가진
    필드 하나에서 나옵니다. 이 이터레이터는 첫 콜백 호출을 미루려고 내부
    이터레이터 슬롯을 <code>const EmptyIterator&lt;Never&gt;()</code>
    센티널로 초기화합니다. 그 결과 태그 하나를 내보낼 때마다 실행되는 뜨거운
    줄 — <code>_currentExpansion!.moveNext()</code> — 이 루프가 도는 동안
    수신자 클래스를 <em>두 가지</em> 보게 됩니다. 그것만으로도 AOT는 내부
    <code>List</code> 이터레이터를 인라인하지 못하고, 300만 번의 내부 전진이
    전부 간접 호출이 됩니다. FxDart의 <code>flatMap</code>은 평범한
    <code>Iterator&lt;B&gt;?</code> 하나만 들고 있고 거기에는 진짜 내부
    이터레이터만 들어가며 "아직 열린 것이 없음"은 <code>null</code>로
    표현합니다. 그래서 같은 호출 지점이 단형(monomorphic)으로 남아
    인라인됩니다.
  </p>
  <p>
    추측이 아니라 측정한 결과입니다. 평탄화 단계<em>만</em> 바꿔서 FxDart의
    <code>flatMap</code>에 순수 Dart 쪽의
    <code>toSet().toList()..sort()</code>를 이어 붙이면 이미 78 ms가 됩니다.
    반대로 반대쪽만 바꿔서 core의 <code>expand</code>를 <code>uniq</code>와
    <code>sort</code>에 물리면 108 ms 그대로입니다. <code>ExpandIterator</code>를
    벤치마크 안에 그대로 베껴 놓고 센티널만 바꾸면(빈 이터레이터 초기값 →
    <code>null</code>) 그것만으로 105 ms에서 77 ms로 내려갑니다. 나머지 차이,
    즉 core가 <code>_current</code>를 널 허용 필드로 두고 캐스트로 읽는 부분은
    측정 가능한 비용이 없었습니다. 각 변형은 별도 바이너리로 AOT 컴파일했습니다.
    한 프로그램에 모아 넣으면 모든 <code>moveNext</code> 호출 지점이 다형이 되어
    측정하려는 효과 자체가 사라지기 때문입니다.
  </p>
  <p>
    기억해 둘 단서가 둘 있습니다. 이것은 SDK의 구현 세부사항이지 법칙이
    아닙니다. <code>ExpandIterator</code>가 그 센티널을 버리는 날
    <code>expand</code>는 FxDart를 따라잡고, 이 페이지는 두 열 모두 다시
    무승부가 됩니다. 그리고 <code>Set</code>에 바로 넣는 손으로 짠 중첩
    <code>for</code> 루프는 43 ms로 양쪽 모두를 이깁니다 — 이터레이터
    프로토콜을 통째로 버리는 것이 여기서는 여전히 가장 빠릅니다. 이 측정이
    반박하는 것은 이름 붙은 파이프라인을 쓰면 관용적인 core 체인보다 속도를
    손해 본다는 통념입니다. 여기서는 오히려 이득입니다.
  </p>
