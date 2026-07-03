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
  - name: release/v2.0
    label: "v2.0"
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

::: tiefchangelog
:::
