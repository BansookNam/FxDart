---
slug: stock-after-moves
title: 이동마다의 재고 수준 — RxDart vs FxDart
description: 창고 입고와 출고를 누적 재고 수준으로 접고 백오더를 표시하기 — 양쪽 모두 scan, 시드를 재생하는 방식만 다릅니다.
heading: 이동마다의 재고 수준
order: 21
tier: 2
functions: fx, scan, map
domain: orders
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    한 SKU의 창고 원장이 부호 있는 이동들을 나열합니다 — 입고는 양수,
    출고는 음수 — 기초 재고 20에서 시작합니다. 기초 수준을 출력한 뒤, 각
    이동을 그 후의 수준과 함께 출력하고, 음수가 된 수준은 백오더로
    표시하세요. 이동들은 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    누적 상태는 두 방언 모두에서 <code>scan</code>입니다 — FxDart의 것은
    같은 Rx 아이디어의 FxTS 이식이므로, fold 자체는 동일합니다: 이동의
    라벨과 그 후의 수준을 실어 나르는 누산기 레코드. 눈에 보이는 유일한
    이음새는 시드입니다. FxDart의 <code>scan</code>은 시드를 첫 값으로
    내놓으므로, 기초 <code>start: 20</code> 줄이 체인에서 공짜로
    떨어집니다. RxDart의 <code>scan</code>은 첫 fold에서부터 내보내기
    시작하므로, 기초 수준은 <code>startWith</code>로 재생해야 합니다 —
    연산자 하나 추가, 고생이라 할 정도는 아닙니다.
  </p>
  <p>
    시드를 지나면 두 파이프라인은 같은 세 단어이고, 표시용
    <code>map</code>은 어느 쪽에서도 똑같이 잘 읽힙니다 — pull 버전은
    원장이 이미 메모리에 있으므로 그저 동기로 남고, 스트림 버전은 자기
    자신의 전달을 await합니다. 순서 있는 시퀀스 위의 누적 상태는 두 모델
    모두의 본고장입니다: 무승부, 둘 사이에 코드를 이식할 때 기억해 둘
    만한 유일한 토막 지식이 시드 방출 차이입니다.
  </p>
