---
slug: dedupe-paged-feed
title: 페이지 피드를 id로 중복 제거 — RxDart vs FxDart
description: 겹치는 세 페이지를 펼치고 각 상품 id를 도착 순서대로 한 번씩만 남기기 — expand + distinctUnique vs flatMap + uniqBy.
heading: 페이지 피드를 id로 중복 제거
order: 19
tier: 2
functions: fx, flatMap, uniqBy, map
domain: orders
verdict: tie
async: false
---
  <h2>요구사항</h2>
  <p>
    상품 피드가 경계가 겹치는 세 페이지로 도착해서, 일부 아이템은 두
    페이지에 나타납니다. 페이지들을 펼치고 각 아이템을 정확히 한 번씩만
    출력하세요 — 첫 등장이 이기고, 도착 순서를 유지하며, 숫자 id를 키로
    합니다. 페이지들은 아래 코드에 있으며, 두 버전 모두
    <em>예상 출력</em> 아래에 표시된 줄들을 출력해야 합니다.
  </p>

  {{output}}

  <h2>나란히 보기</h2>
  {{comparison}}

  <h2>차이가 나는 이유</h2>
  <p>
    흥미로운 사실은 중복이 어디에 앉아 있는가입니다. 페이지 경계가
    겹치므로, 반복된 id는 <em>다른 페이지</em>에서 도착합니다 — 페이지가
    펼쳐지고 나면 첫 등장 바로 옆에 있는 일이 없습니다. 바로 그것이 순수
    <code>Stream.distinct</code>가 조용히 틀리는 작업입니다: 인접
    전용이라, 이 피드에서는 모든 반복을 그대로 통과시켜 버릴 것입니다.
    여기의 중복 제거에는 피드 전체의 기억이 필요하고, 펼치기 자체는 두
    모델 모두에서 유창합니다 — 스트림에서는 <code>expand</code>, pull
    체인에서는 <code>flatMap</code>.
  </p>
  <p>
    고유 방문자 쌍에서처럼, 전역 중복 제거는 <code>distinctUnique</code>
    대 <code>uniqBy</code>입니다 — <code>equals</code>/<code>hashCode</code>
    쌍 대 키 함수 하나 — 그리고 인접-대-전역 이름 갈림은 상태 변경
    페이지가 짚어 주는 그것입니다. 양쪽 모두 같은 seen 키 집합을
    유지하고 첫 도착 순서를 보존하므로, 판정은 무승부입니다 — pull
    버전은 페이지들이 로컬 리스트에 앉아 있으므로 그저 동기로 남을
    뿐입니다.
  </p>
