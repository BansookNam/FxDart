---
slug: top-expenses
title: 가장 큰 지출 상위 3건 — Dart vs FxDart
description: 이번 달 거래 중 금액이 가장 큰 세 건 — package:collection의 sortedBy + take와 FxDart의 sortBy + take를 비교합니다.
heading: 가장 큰 지출 상위 3건
order: 1
tier: 1
functions: sortBy, take
alsoLink: chunk, scan
domain: transactions
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    한 달치 지출 중 <strong>가장 큰 세 건</strong>을 판매자와 금액으로,
    큰 금액부터 순서대로 출력하세요. 데이터는 아래 코드에 있으며, 두
    버전 모두 <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 차이가 없습니다 — 페이지 위의 코드는 무승부입니다. 양쪽 모두
    부호를 반전한 키로 정렬해 내림차순을 얻고 앞의 세 개를 취합니다.
    <code>package:collection</code>의 <code>sortedBy</code>는 FxDart의
    <code>sortBy</code>만큼이나 직접적입니다(Dart 코어의
    <code>List.sort</code>만 단독으로 쓰면 제자리에서 변형되고 명시적인
    비교자가 필요하지만, <code>collection</code>은 표준적인
    의존성입니다). 나열된 코드에서 실질적인 차이는 그 어휘가 어디에
    있느냐뿐입니다 — 패키지의 확장 메서드냐, 아니면 <code>scan</code>,
    <code>chunk</code>, 비동기 변형까지 함께 제공하는 체인의 한 단계냐.
    어느 쪽을 골라도 떳떳합니다.
  </p>
  <p>
    나열된 코드는 무승부지만 시계는 아닙니다. 100만 행에서 아래 막대는
    FxDart가 약 2.6배 빠릅니다(200 ms 대 521 ms). 더 영리한 빅오 때문이
    아닙니다 — 양쪽 모두 리스트를 복사한 뒤 안정적인 O(n log n) 병합
    정렬을 돌립니다. 차이는 비교 한 번의 비용입니다.
  </p>
  <p>
    네이티브 <code>sortedBy</code>는 collection의
    <code>mergeSortBy</code>입니다. <em>행</em>을 정렬하면서 키 추출
    함수를 <em>비교할 때마다</em> 호출합니다. 100만 행이면
    <code>(t) => -t.amount</code>를 약 2,000만 번 호출합니다. 키 타입은
    제네릭 <code>K extends Comparable</code> — 여기서는
    <code>num</code> — 이라 그 키는 전부 힙에 박싱된
    <code>double</code>이고, 가상 <code>compareTo</code>를 거쳐
    비교됩니다.
  </p>
  <p>
    FxDart의 <code>sortBy</code>는 먼저 추출합니다. 리스트를 한 번 훑어
    모든 키가 <code>double</code>임을 보고 <code>Float64List</code>에
    씁니다. 그다음 키와 행을 <em>함께</em>, 순차적으로 병합합니다. 비교
    한 번은 타입 배열에서 꺼낸 기계 double 두 개이고, 이 데이터에서는
    VM 비교를 씁니다(금액이 보통의 유한 양수라 NaN이나
    <code>-0.0</code>이 없어 느린 <code>compareTo</code> 경로로 떨어지지
    않습니다). 행마다 추출 한 번, 박싱 없음, 디스패치 없음, 인덱스로
    키를 쫓아다니는 일도 없습니다. 예전 <code>sortBy</code>는 인덱스
    목록을 <code>List.sort</code>로 정렬하는 데코레이트였습니다. 그건
    사라졌습니다. 지금 병합은 구조적으로 안정적입니다 — 키가 같은 행은
    이제 양쪽 모두 입력 순서를 지킵니다.
  </p>
  <p>
    한계도 정직하게 말하면 이렇습니다: 키가 전부 <code>double</code>,
    <code>int</code>, <code>String</code> 중 하나로 균일하지 않으면
    <code>sortBy</code>는 제네릭 비교자로 되돌아가고 이 이점은
    사라집니다. 100만 행에서 메모리는 비슷합니다(약 123 MB 대 130 MB)
    — 양쪽 모두 행 복사본과 스크래치 버퍼를 붙들고 있습니다. 이 예제는
    금액이 모두 달라서, 안정성은 출력되는 세 줄에는 드러나지 않습니다.
  </p>
