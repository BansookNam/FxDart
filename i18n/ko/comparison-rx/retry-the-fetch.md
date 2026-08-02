---
slug: retry-the-fetch
title: 불안정한 fetch 재시도하기 — RxDart vs FxDart
description: 두 번 실패한 뒤 성공하는 fetch — Rx.retry는 스트림 팩토리를 재구독하고, fxdart retry는 Future를 다시 실행합니다. 양쪽 다 호출 하나.
heading: 불안정한 fetch 재시도하기
order: 27
tier: 3
functions: fx, retry
domain: general
verdict: tie
async: true
---
  <h2>요구사항</h2>
  <p>
    매니페스트 엔드포인트는 페이로드를 내주기 전에 정확히 두 번
    연결을 리셋합니다. 총 세 번의 시도 예산 안에서 성공할 때까지
    재시도한 뒤, 페이로드와 몇 번 만에 성공했는지를 출력하세요. 실패
    주입은 결정적이며 코드에 들어 있습니다; 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 다르지 않습니다 — 양쪽 다 호출 하나이고, 그것이 이 쌍의
    요점입니다. 차이는 각 모델에서 "다시 시도한다"가 무엇을
    <em>의미하는가</em>입니다. RxDart에서 오류를 낸 스트림은 죽은
    것이므로, <code>Rx.retry</code>는 <strong>팩토리</strong>를 받아
    재구독합니다: 재시도란 다시 listen하는 것이고, 개수 인자는 첫
    시도 이후의 <em>재시도</em> 횟수입니다(여기서는 <code>2</code>,
    총 세 번 시도). FxDart에서 불안정한 것은 <code>Future</code>를
    반환하는 함수이므로, <code>retry</code>는 그냥 그것을 다시
    호출합니다 — <code>attempts</code>는 총 예산(<code>3</code>)이고,
    예산이 소진되면 마지막 오류가 원래 스택 트레이스와 함께 다시
    던져집니다.
  </p>
  <p>
    진짜 무승부입니다. 모양이 갈라지는 것은 재시도 대상이 자랄
    때뿐입니다: 그것이 다중 값 파이프라인이 되면 RxDart는 같은 팩토리
    관용구를 유지하는 반면, FxDart는 터미널을 감싸거나
    (<code>retry(3, () => fxAsync(…).toList())</code>) 요소별 재시도로
    옮겨 갑니다 — 두 예제 뒤에 나오는, 그 자체로 하나의 쌍입니다.
  </p>
