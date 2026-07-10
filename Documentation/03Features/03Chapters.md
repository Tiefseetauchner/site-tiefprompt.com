---
title: "Chapters"
description: "How chapter detection and current-chapter tracking work, and why they depend on Markdown rendering"
---

# Chapters

{{ anchor: '03Features/03Chapters.md' }}

## Markdown Is a Hard Requirement

Your script text is parsed into a Markdown structure on every edit regardless of settings, but chapter positions are only ever collected while the Markdown renderer is actually on screen -- which only happens when Markdown rendering is enabled in {{ autolink: '02Usage/03DisplaySettings.md' }}. With Markdown rendering off, no chapter positions are ever recorded and the feature is completely inert, not just less polished. This is why the "Show Current Chapter" toggle is greyed out until Markdown rendering is switched on -- the UI reflects a real dependency, not an arbitrary restriction.

## What Counts as a Chapter

Every heading in your script -- any level, from a top-level heading down to the smallest one -- becomes a chapter marker. There's no way to mark only top-level headings as chapters; all heading levels are treated identically.

## Tracking the Current Chapter

As you scroll, TiefPrompt walks through the chapters in the order they appear in your script and keeps track of the last one whose position you've scrolled past. In practice this means the chapter indicator always shows the most recent heading above your current reading position, updating continuously as you scroll through the script.

## Turning It Off

Disabling Markdown rendering or the "Show Current Chapter" toggle doesn't just hide the chapter indicator -- it actively clears the tracked chapter state for as long as either is off. Turning either back on starts chapter tracking fresh rather than resuming from a stale position.
