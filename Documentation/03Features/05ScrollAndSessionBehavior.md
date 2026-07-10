---
title: "Scroll and Session Behavior"
description: "How scroll position is remembered, and how the always-present scratch script is managed"
---

# Scroll and Session Behavior

{{ anchor: '03Features/05ScrollAndSessionBehavior.md' }}

## Scroll Position Persistence

TiefPrompt remembers where you were reading in each script. Your position is saved a second after you stop scrolling, and -- separately -- at least once every 5 seconds even during a long, continuous scroll, so an unexpected crash or close never loses more than a few seconds of progress. This is only written to the script itself once it's an actual saved script; see {{ autolink: '03Features/01ScriptSaving.md' }} for when a script becomes permanent.

If a script has never had a position saved, opening it doesn't jump to the very top of the text -- it starts about half a screen height down, which lands the first line roughly centered in the reading area instead of pinned to the top edge.

## The Scratch Script

TiefPrompt always keeps exactly one "scratch" script around -- an always-available, ready-to-write-in script that doesn't show up in your Open File list. It's created automatically on first install, and every time the app starts, it checks that exactly one exists: if none exist, a new one is created; if one exists, it's loaded as-is.

::: callout-info
Because saving the scratch script (see {{ autolink: '03Features/01ScriptSaving.md' }}) creates a fresh replacement scratch script in the background without loading it immediately, it's possible -- in entirely normal use -- for more than one scratch script to briefly exist at once. If the app ever finds more than one at startup, it treats the extras as real, permanent scripts rather than deleting them, adds them to your visible script list, and creates one fresh scratch script to replace them. You'll see a warning if this happens, though no scripts are lost.
:::

Everything you type into the scratch script is saved automatically about half a second after you stop typing, with no explicit Save action needed -- but this never converts it into a permanent script or changes its creation date. Since scratch scripts are hidden from the Open File list, and that's the only place scripts can be deleted from, the scratch script can't be deleted directly -- only turned into a permanent script via Save, or replaced the next time the app reconciles a duplicate.
