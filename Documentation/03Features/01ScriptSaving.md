---
title: "Script Saving"
description: "How saving, overriding, and importing scripts actually behaves, including known rough edges"
---

# Script Saving

{{ anchor: '03Features/01ScriptSaving.md' }}

This article covers what happens when you press Save, Import, or navigate away from a script -- not where the buttons are, which is covered in {{ autolink: '02Usage/02PrompterScreen.md' }}.

## Saving the Scratch Script

Every install starts with one "scratch" script that's always open by default -- see {{ autolink: '03Features/05ScrollAndSessionBehavior.md' }} for how that script is created and maintained. Pressing Save while this scratch script is loaded always does a silent overwrite: the script becomes a permanent, regular script with no dialog or confirmation. A brand new scratch script is created in the background immediately after, but the screen stays on the script you just saved -- the new scratch script isn't loaded until the next time the app reconciles its script list (typically the next launch).

## Saving a Regular Script

Once a script is no longer the scratch script, pressing Save always opens a "New Script vs. Override Script" dialog -- every time, even if nothing has changed since the last save. There is no silent re-save path once a script is permanent.

**New Script** inserts a new, separate script and leaves the original untouched. **Override Script** updates the existing script in place.

::: callout-warn
Overriding a script resets its creation timestamp to now. The "created" date shown in the Open File list reflects the most recent override, not when the script was first written -- if you're expecting "created" to mean "first created," this can read as a bug.
:::

## The Unsaved-Changes Indicator

A plain `*` appears next to the Text field's label (not the title field, and nowhere in any app bar) whenever there are unsaved changes. This is a simple flag flipped on by any keystroke in either the title or text field -- there's no comparison against the original content, so typing something and then undoing back to the exact original text still shows as unsaved. The indicator only clears on a successful save or a fresh script load.

## Importing Scripts

Importing a `.txt` or `.md` file always creates a brand-new script, titled after the picked filename including its extension (e.g. `myscript.txt`). Titles aren't required to be unique, and there's no duplicate check -- importing the same file twice produces two scripts with identical titles, distinguishable only by their creation time.

## Leaving with Unsaved Changes

The behavior differs depending on how you navigate away. The **Select** button (to open a different script) checks for unsaved changes and shows a discard-confirmation dialog if you're dirty. The **Open File list**, however, deletes scripts immediately when you choose to delete one, with no confirmation dialog.

::: callout-warn
Deleting a script from the Open File list is immediate and final -- there's no confirmation dialog and no undo.
:::
