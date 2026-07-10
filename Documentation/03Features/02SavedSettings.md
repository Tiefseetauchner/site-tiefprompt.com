---
title: "Saved Settings"
description: "How settings profiles work under the hood: scope, naming, and import/export behavior"
---

# Saved Settings

{{ anchor: '03Features/02SavedSettings.md' }}

For instructions on where to click, see {{ autolink: '02Usage/06SavedSettings.md' }}. This article instead covers what actually happens when you save, apply, import or export a settings profile ("restore point").

## What's in a Profile

A saved profile is a full snapshot of the app's settings: theme mode, app accent color, prompter background/text colors, and the entire {{ autolink: '02Usage/03DisplaySettings.md' }} / {{ autolink: '02Usage/04TextSettings.md' }} configuration -- plus a private copy of your current {{ autolink: '02Usage/05Keybindings.md' }}, cloned into its own record at save time rather than linked to your live bindings. Saving a profile captures all of this at once -- there's no way to save, say, only your Text Settings.

Deliberately excluded: anything script-related. No script content, script id, or scroll position is ever part of a profile.

## Applying a Profile

Restoring a profile overwrites your current settings and swaps your active keybindings for the profile's cloned copy. It never touches your open script, scroll position, or anything else about your current session -- restoring settings and editing a script are entirely separate concerns.

## Naming

Profiles are identified by the name you give them when saving, but names aren't required to be unique. If you save two profiles with the same name, you'll simply end up with two separate entries that happen to share a label -- they're distinguished internally by id and creation time. The only validation on the name field is that it can't be empty.

## Import and Export

Exporting writes a profile -- settings, keybindings, and a schema version -- to a file you choose, which you can move to another device and import from there.

Importing is a two-step process. The file is first picked and validated, then, once valid, you're asked to name it (pre-filled if the file already had a name) and only then it's saved as a new profile. Importing never silently overwrites an existing profile or auto-applies itself -- it always lands as an additional saved profile that you restore explicitly afterward.

::: callout-warn
Validation checks for an **exact match** on schema version, not "version or newer" -- a file exported from a newer but otherwise compatible version of TiefPrompt is rejected outright, not just when it's genuinely incompatible.
:::
