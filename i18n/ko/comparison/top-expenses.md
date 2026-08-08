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
    거의 차이가 없습니다 — 이번 예제는 무승부입니다. 양쪽 모두 부호를
    반전한 키로 정렬해 내림차순을 얻고 앞의 세 개를 취합니다.
    <code>package:collection</code>의 <code>sortedBy</code>는 FxDart의
    <code>sortBy</code>만큼이나 직접적입니다(Dart 코어의
    <code>List.sort</code>만 단독으로 쓰면 제자리에서 변형되고 명시적인
    비교자가 필요하지만, <code>collection</code>은 표준적인
    의존성입니다). 실질적인 차이는
    그 어휘가 어디에 있느냐뿐입니다 — 패키지의 확장 메서드냐, 아니면
    <code>scan</code>, <code>chunk</code>, 비동기 변형까지 함께 제공하는
    체인의 한 단계냐. 어느 쪽을 골라도 떳떳합니다.
  </p>
  <p>
    코드는 무승부지만 시계는 아닙니다. 아래 벤치마크 막대에서 FxDart는 같은
    데이터를 1.5~1.8배 빠르게 처리하는데, 이는 더 영리한 알고리즘 때문이
    아닙니다 — 양쪽 모두 O(n log n) 비교 정렬을 돌립니다. 차이는 비교
    한 번의 비용에 있습니다. <code>sortedBy</code>는 원소를 직접 정렬하면서
    키 추출 함수를 <em>비교할 때마다</em> 호출합니다. 100만 행이면
    <code>(t) => -t.amount</code>를 1,960만 번 호출하고, FxDart는 100만
    번입니다. 게다가 키 타입이 제네릭 파라미터라 그 키는 전부 힙에 박싱된
    <code>double</code>이고, 가상 <code>compareTo</code>를 거쳐 비교됩니다.
    FxDart는 대신 데코레이트합니다 — 키를 한 번씩만 뽑고, 모든 키가
    <code>double</code>임을 확인한 뒤 <code>Float64List</code>로 옮기고,
    인덱스 목록을 정렬한 다음 그 순열대로 되읽습니다. 그 뒤로 비교는 타입
    배열에서 꺼낸 기계 double 두 개일 뿐입니다 — 할당도, 디스패치도
    없습니다.
  </p>
  <p>
    두 가지 절약 중 실제로 값을 하는 쪽은 언박싱입니다. 벤치마크 머신에서
    100만 행, AOT 컴파일로 측정하면: 똑같은 데코레이트-정렬-언데코레이트를
    <em>박싱된</em> 키로 돌리면 1051 ms로, <code>sortedBy</code>의 522 ms보다
    오히려 느립니다 — 비교마다 힙 객체 두 개를 역참조하고 가상
    <code>compareTo</code>를 디스패치하는 비용이 그대로인 데다, 인덱스 순열이
    임의 접근까지 더하기 때문입니다. 여기서 키 배열만
    <code>Float64List</code>로 바꾸면 337 ms로 떨어집니다. 키를 한 번만
    뽑는 것 자체는 거의 공짜이고, 키를 박싱하지 않는 것이 이득의 전부입니다.
    한계도 정직하게 말하면 이렇습니다: 키가 전부 <code>double</code>,
    <code>int</code>, <code>String</code> 중 하나로 균일하지 않으면
    <code>sortBy</code>는 제네릭 비교자로 되돌아가고 이 이점은 사라집니다.
  </p>
  <p>
    그리고 이 속도는 공짜가 아니라 사서 얻은 것입니다. 데코레이트 방식은
    정점에서 배열 네 개를 동시에 살려 둡니다 — 복사한 원소, 키, 인덱스 순열,
    결과. 병합 정렬은 복사본에 절반 크기 스크래치 버퍼만 있으면 되고, 그래서
    메모리 막대는 반대로 기웁니다(100만 행에서 183 MB 대 126 MB). 다른
    비용은 안정성입니다. <code>sortedBy</code>는 안정 병합 정렬이지만
    FxDart는 인덱스를 <code>List.sort</code>에 넘기고 이쪽은 안정적이지
    않습니다 — 키가 같은 행이 네이티브 쪽에서는 입력 순서를 지키지만 FxDart
    쪽에서는 뒤섞여 나올 수 있습니다. 이 예제는 금액이 모두 다르고 세 줄만
    출력하니 드러나지 않지만, 동점이 있는 리더보드라면 드러납니다.
  </p>
