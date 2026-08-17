---
slug: theory
title: Functional Programming Theory — FxDart 101
description: A textbook of the ideas behind FxDart — monads, functors, laws, laziness and typed errors — written for working Dart developers, with every listing runnable in the browser.
heading: Functional Programming Theory
---
## How to read this book

This is the theory companion to FxDart 101. The tutorials answer *how do I
call this function*; this book answers *why does the function have that
shape*, and *what does the shape guarantee*.

It is written for a working Dart developer. That means three things.

**No prerequisites beyond Dart.** No Haskell, no category theory, no
mathematics past the idea that a function maps inputs to outputs. Where a
concept has a formal definition, you get it — but after you have already
used the thing it names.

**Every listing runs.** Code marked with a **▶ Run** button compiles with the
real Dart compiler and executes in this page. The first run downloads the
compiler runtime and takes a few seconds; after that it is instant. Claims
about *what a program prints* are meant to be checked, not believed.

**Honesty over advocacy.** Some of these ideas pay for themselves in the
first hour. Some are elegant and, in Dart, not worth the friction — Dart
cannot express several of them at all, and where that is the case this book
says so and shows what FxDart does instead.

### Turning pages

Use the arrows, the ← and → keys, or **Contents** to jump to a chapter. Each
chapter ends with exercises; the solutions are on the following spread, so
you can think before you turn.

> **Notation.** `A`, `B` are ordinary types (`int`, `User`). `M<A>` is a
> value of type `A` sitting inside some structure `M` — `List<A>`,
> `Future<A>`, `Either<E, A>`. A function written `A → M<B>` takes a plain
> value and returns one that is inside the structure. That single shape is
> what most of Part I is about.
