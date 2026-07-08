---
title: Changelog
description: Every release of TiefPrompt, newest first.
# The left rail. Any changelog file without a `branch:` front matter lands here.
main_branch: main
# Branches that fork off the main rail. `label` is the chip at the branch tip,
# `from` is the rail it forks from (defaults to main_branch), `color` overrides
# the palette. Branches used in files but not listed here still render.
branches:
  - name: main
    color: \#2dd4d4
  - name: release/v1.0
    label: "v1.0"
    from: main
# Milestones ride the timeline, anchored to a version (on that version's rail).
# For now they're hand curated; later they can come from repo-scraped releases.
milestones:
  - version: "1.0.0"
    label: "TiefPrompt 1.0 — the first stable release"
  - version: "0.1.0"
    label: "First public release"
---

# Changelog

Every release of TiefPrompt, newest first. Pick a version for the full notes.

::: {.row .g-4}

:::: {.col-12 .col-md-6}

::::: tiefchangelog
:::::

::::

:::: {.col-12 .col-md-6}

::::: {.cl-aside}

:::::: {.card .m-1}

::::::: {.card-body}

## What is TiefPrompt?

An extraordinarily simple, open source, cross-platform teleprompter.

- Play/pause, 0.1×–20× speed, and a countdown before scrolling
- Adjustable font, alignment, and Markdown rendering
- Mirror the text horizontally or vertically for a glass rig
- Reading indicator, margins, custom colors & light/dark themes
- Save named scripts, import/export settings as JSON
- Fully custom keyboard shortcuts, keeps the screen awake

:::::::: {.d-flex .flex-wrap .gap-2}
[Get on F-Droid](https://f-droid.org/packages/io.github.tiefseetauchner.tiefprompt/){.btn .btn-primary .btn-sm}
[App Store](https://apps.apple.com/us/app/tiefprompt/id6749463142){.btn .btn-outline-secondary .btn-sm}

::::::::

:::::::

::::::

:::::: {.card .m-1}

::::::: {.card-body}

## Versioning Scheme? Why so complicated :(

I chose to make the versioning complicated because this is a serious hobby project.

Meaning I don't want to worry about breaking someone's prod while giving the GitHub users the best, newest features.

- **0.x** - the "still figuring it out" years. One line, no promises.
- **x.0.0** - stable releases that initiate a feature freeze.
- **x.0.z** - all the stable patches following the x.0 release, meaning bugfixes but no new features.
- **x.y.z** - when x =/= 0, this is a **feature** release, meaning it got new features (like the redesign) that don't go into stable.

Why? Because...\
Well. Because.\
I want to keep the stable branch stable enough, while giving feature release branch enjoyers their features in a somewhat stable release. That means you can download the latest and greatest, or the "I just want this s\*\*\* to work" version.

I realize this is complicated, and you don't have to care, but I do so. You've got this funky branch here! :)

:::::::

::::::

:::::

::::

:::