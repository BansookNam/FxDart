---
slug: curried
title: curried &amp; uncurried — FxDart 101
description: Tutorial de curried en FxDart: currificación totalmente tipada mediante getters de extensión, el reemplazo nativo de Dart para curry de FxTS, con un playground en vivo.
heading: <code>.curried</code> &amp; <code>.uncurried</code>
section: 10
crumb: curried &amp; uncurried
prev: unicodeToList.html
prevLabel: unicodeToList
next: toAsync.html
nextLabel: toAsync
---
  <p class="hero-sub">Currificación totalmente tipada como getters de extensión: el reemplazo nativo de Dart para el <code>curry</code> de FxTS.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Currificar convierte una función de varios argumentos en una cadena de
    funciones unarias: <code>add(1, 2)</code> pasa a ser
    <code>add.curried(1)(2)</code>. La ganancia es la <strong>aplicación
    parcial</strong>: fijar el primer argumento produce una función nueva, que
    es justo la forma que esperan callbacks como <code>map</code> y
    <code>filter</code>.
  </p>
  <p>
    FxTS lo ofrece como función, <code>curry(f)</code>, apoyándose en dos cosas
    que Dart no tiene: reflexión de aridad en tiempo de ejecución
    (<code>fn.length</code>) y tipos condicionales recursivos. FxDart, en
    cambio, declara una extensión por aridad (2–5), todas exponiendo el mismo
    getter <code>curried</code>, y deja que el compilador elija la correcta a
    partir del tipo <em>estático</em> de la función. El despacho por aridad que
    FxTS hace en tiempo de ejecución ocurre aquí en tiempo de compilación, y el
    resultado está totalmente tipado, sin ni un solo cast:
    <code>add.curried(1)</code> <em>es</em> un <code>int Function(int)</code>.
  </p>
  <p>
    <code>.uncurried</code> es la operación inversa: aplana una cadena de
    funciones unarias de vuelta a una única función de varios argumentos.
    Cuando la cadena está anidada más de dos niveles, gana la aridad
    coincidente más profunda; aplica una extensión de forma explícita
    (<code>Uncurry2(f).uncurried</code>) para aplanar menos niveles. La
    historia completa del diseño — incluido por qué el getter se llama
    <code>curried</code> y no <code>curry</code> — está en
    <a href="https://github.com/BansookNam/FxDart/blob/main/WHY_CURRIED.md">WHY_CURRIED.md</a>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Aplicación parcial en un pipeline</h2>
  <p>
    Una función binaria currificada encaja directamente en <code>map</code>, sin
    necesidad de un closure envoltorio:
  </p>
  {{playground:1}}

  <h2>Demo 3 · Ida y vuelta con <code>uncurried</code></h2>
  <p>
    Los closures currificados a mano se aplanan de vuelta a la forma data-first, y
    <code>curried</code> / <code>uncurried</code> son inversas exactas:
  </p>
  {{playground:2}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>.curried</code> para construir una función
    <code>clampTo100</code> a partir del <code>clamp</code> de abajo, y luego mapéala sobre la lista.</p>
  {{playground:3}}

  <div class="callout">
    <strong>Nota:</strong> la cadena es estrictamente unaria — la aplicación
    mixta de FxTS <code>add(1, 2)(3)</code> no tiene equivalente. Los parámetros
    con nombre u opcionales y los valores tipados como <code>Function</code> a
    secas no encajan con las extensiones; ahí escribe un closure. El stub de
    nivel superior <code>curry</code>, ya obsoleto, solo sigue ahí para guiar
    hasta aquí a quien migre desde FxTS.
  </div>

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pipe.html"><code>pipe</code></a> — composición, el principal consumidor de funciones aplicadas parcialmente ·
    <a href="identity.html"><code>identity</code></a> &amp; <a href="always.html"><code>always</code></a> — otras utilidades sobre la forma de las funciones ·
    <a href="apply.html"><code>apply</code></a> — despliega una lista en argumentos posicionales
  </div>
