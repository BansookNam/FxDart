---
slug: bracket-the-session
title: 열림과 닫힘 마커 — RxDart vs FxDart
description: 세션 피드를 OPEN/CLOSE 줄로 감싸기 — 스트림의 startWith와 endWith vs pull 체인의 prepend와 append.
heading: 열림과 닫힘 마커
order: 14
tier: 2
functions: fx, prepend, append
domain: logs
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    세션 리포트는 한 사용자의 이벤트를 순서대로 나열하되, 첫 이벤트 앞에
    <code>== SESSION OPEN ==</code> 줄을, 마지막 이벤트 뒤에
    <code>== SESSION CLOSE ==</code> 줄을 놓아 감쌉니다. 이벤트 네 건은
    아래 코드에 있으며, 두 버전 모두 <em>예상 출력</em> 아래에 표시된
    줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    거의 어디서도 다르지 않습니다: 이것은 어휘 패리티입니다. RxDart의
    <code>startWith</code>는 소스의 첫 방출 전에 값 하나를 주입하고
    <code>endWith</code>는 소스가 완료된 뒤 하나를 주입합니다; FxDart의
    <code>prepend</code>와 <code>append</code>는 pull 체인 위의 같은 두
    단어로, 첫 pull이 소스에 닿기 전에, 그리고 소스가 마른 뒤에 마커를
    내놓습니다. 연산자 하나씩, 대칭적인 이름, 양쪽 모두에서
    일급입니다.
  </p>
  <p>
    주목할 만한 유일한 모델 차이는 닫힘 마커가 <em>언제</em> 존재할 수
    있는가입니다. push 쪽에서 <code>endWith</code>는 done 이벤트를
    기다려야 합니다 — 마커의 위치는 스트림 라이프사이클에 관한
    사실입니다. pull 쪽에서 <code>append</code>는 소스가 소진되고 나면
    이터레이터가 내놓는 그다음 값일 뿐입니다; 관찰할 라이프사이클은 없고
    수요만 있습니다. 유한한 인메모리 피드에서 이 구별은 보이지 않으므로,
    이 판은 무승부입니다 — 파이프라인의 나머지가 이미 살고 있는 모델을
    고르세요.
  </p>
