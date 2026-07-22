---
slug: index
title: FxDart — Programação funcional para Dart
description: FxDart é uma biblioteca de programação funcional para Dart, portada do FxTS: avaliação preguiçosa, iteração assíncrona concorrente e composição em pipeline.
---
  <p class="hero-logo"><img src="{{root}}assets/logo-web.png" width="960" height="294"
      alt="FxDart"></p>
  <h1>Programação funcional para Dart,<br>com laziness e concorrência embutidas.</h1>
  <p class="hero-sub">
    FxDart é um port em Dart do <a href="https://github.com/marpple/FxTS">FxTS</a> —
    uma biblioteca para compor <strong>pipelines preguiçosos</strong> sobre dados síncronos e assíncronos,
    onde transformar seis requisições sequenciais de 1 segundo em um lote concorrente de 2 segundos
    é uma única chamada de método.
  </p>

  {{playground:0}}
  <p class="dim">▲ Isto está ao vivo — edite o código e pressione <strong>Executar</strong>.
    Ele compila com o compilador Dart de verdade e executa no seu navegador.</p>

  <h2>O que é FxDart?</h2>
  <p>
    FxDart traz o modelo de programação do FxTS para Dart: um kit de ~120 funções
    pequenas e componíveis para transformar coleções e dados assíncronos.
    Três ideias o definem:
  </p>
  <ul>
    <li><strong>Avaliação preguiçosa</strong> — operadores como <code>map</code>,
      <code>filter</code> e <code>take</code> montam um pipeline, mas não fazem
      trabalho algum até que um operador terminal (<code>toList</code>, <code>each</code>,
      <code>reduce</code>…) puxe valores por ele. Processar um range de um milhão
      de elementos com <code>.take(3)</code> calcula exatamente 3 resultados.</li>
    <li><strong>Um modelo para sync e async</strong> — os mesmos nomes de operadores
      funcionam sobre <code>Iterable</code>s comuns e sobre <code>FxAsyncIterable</code>,
      a sequência assíncrona baseada em pull do FxDart (com pontes para <code>Stream</code> nos
      dois sentidos).</li>
    <li><strong>Concorrência declarativa</strong> — <code>concurrent(n)</code>
      pede ao pipeline <em>upstream</em> que avalie <code>n</code> itens por
      vez, mantendo os resultados em ordem. É o recurso mais marcante do FxTS,
      portado fielmente para Dart.</li>
  </ul>

  <h2>Por que precisamos disso?</h2>
  <p>
    Dart já tem <code>Iterable</code> e <code>Stream</code>. O FxDart conquista
    seu espaço onde eles se esgotam:
  </p>
  <table>
    <tr><th>Problema</th><th>Dart puro</th><th>FxDart</th></tr>
    <tr>
      <td>Limitar chamadas de API concorrentes a <em>n</em>, mantendo a ordem</td>
      <td>Filas manuais, <code>Completer</code>s, controle minucioso</td>
      <td><code>.map(fetch).concurrent(3)</code></td>
    </tr>
    <tr>
      <td>Pipelines de transformação assíncronos</td>
      <td><code>Stream</code> é baseado em push; misturar <code>await</code>, backpressure e laziness fica intrincado</td>
      <td>Cadeia baseada em pull — cada valor só é calculado quando pedido</td>
    </tr>
    <tr>
      <td>Manipulação de dados (group, index, count, partition, zip, chunk…)</td>
      <td>Loops escritos à mão toda vez</td>
      <td>Uma função nomeada e bem testada por conceito</td>
    </tr>
    <tr>
      <td>Transformações de várias etapas legíveis</td>
      <td>Chamadas aninhadas ou variáveis intermediárias</td>
      <td>Cadeias <code>fx()</code> da esquerda para a direita, totalmente tipadas</td>
    </tr>
  </table>

  <h2>Prós &amp; Contras</h2>
  <div class="proscons">
    <div class="box pros">
      <h3>✓ Prós</h3>
      <ul>
        <li><strong>Laziness de graça</strong> — pipelines fazem short-circuit; só os valores pedidos são calculados.</li>
        <li><strong>Concorrência que preserva a ordem</strong> com um único operador: <code>concurrent(n)</code> / <code>concurrentPool(n)</code> na ordem de conclusão.</li>
        <li><strong>Cadeias totalmente tipadas</strong> — <code>fx()</code> mantém a inferência de ponta a ponta; operadores síncronos são funções comuns sobre <code>Iterable</code>s nativos, então tudo interopera com Dart comum.</li>
        <li><strong>Funções pequenas e focadas</strong> — ~120 operadores cobrindo transform / filter / slice / combine / aggregate / object / util.</li>
        <li><strong>Semântica testada em produção</strong> — comportamento portado do FxTS junto com mais de 850 de seus testes.</li>
        <li><strong>Zero dependências</strong> — Dart puro.</li>
      </ul>
    </div>
    <div class="box cons">
      <h3>✗ Contras</h3>
      <ul>
        <li><strong>Sem currying data-last</strong> — Dart não tem sobrecarga de funções, então o estilo <code>pipe</code> curried do FxTS vira cadeias; o <code>pipe()</code> dinâmico perde os tipos estáticos.</li>
        <li><strong>Uma segunda abstração assíncrona</strong> — <code>FxAsyncIterable</code> existe porque <code>Stream</code> não consegue expressar o canal de retorno da concorrência; a ponte é fácil, mas é mais um conceito a aprender.</li>
        <li><strong>Curva de aprendizado</strong> — pensar em pipelines preguiçosos é diferente de loops imperativos.</li>
        <li><strong>Nem sempre o mais rápido</strong> — em hot loops minúsculos, um <code>for</code> escrito à mão pode superar a composição de operadores; o FxDart otimiza para clareza e trabalho I/O-bound.</li>
        <li><strong>Algumas APIs do TS não portam literalmente</strong> — elas ganham grafias nativas do Dart: <code>curry</code> vira o getter de extensão tipado <a href="tutorials/curried.html"><code>.curried</code></a>, com os nomes antigos mantidos como stubs deprecados para migração.</li>
      </ul>
    </div>
  </div>

  <h2>Uma amostra de concorrência</h2>
  <p>Seis requisições falsas de 300&nbsp;ms cada — sequencialmente ~1,8&nbsp;s, com
    <code>concurrent(3)</code> cerca de 0,6&nbsp;s. Tente mudar o número:</p>
  {{playground:1}}

  <h2>Comece a aprender</h2>
  <div class="grid">
    <a class="card" href="101/index.html">
      <h3>FxDart 101 →</h3>
      <p>Um curso guiado: aulas, demos ao vivo e um playground para cada função.</p>
    </a>
    <a class="card" href="tutorials/map.html">
      <h3>Primeira aula: map →</h3>
      <p>Comece pelo operador mais fundamental.</p>
    </a>
    <a class="card" href="https://github.com/bansooknam/fxDart">
      <h3>Instalar →</h3>
      <p>Coloque o fxdart no seu pubspec e explore o código-fonte.</p>
    </a>
  </div>
