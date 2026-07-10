---
title: "Custom Fonts"
description: "How font uploads, family management, and font fallback behave"
---

# Custom Fonts

{{ anchor: '03Features/04CustomFonts.md' }}

## Families and Variants

A font family is a group of one or more variants, where a variant is a specific weight and style combination -- for example, a regular weight and a bold italic weight of the same typeface are two different variants of one family. Built-in fonts and the fonts you upload share this exact same structure; the only difference is that built-in fonts can't be edited or removed.

## Uploading Fonts

You can upload one or more `.ttf`/`.otf` files at once. Each file is read independently to extract its weight, italic flag, and embedded family name -- if a file has no embedded family name, its filename (without the extension) is used instead. Uploading several files at once processes each one as its own separate addition, not as a single batch, so the merge rules below apply individually to each file.

## How Uploads Merge Into Families

An upload never merges into a **built-in** family, even if the name matches exactly. If no custom family with that name exists yet, the upload becomes a new family; if one does exist and none of its variants share the incoming file's weight and style, the new variant is added to it.

::: callout-warn
Uploading a font named the same as a built-in family does **not** extend or replace that built-in font -- it creates a second, separate custom family with the same name. You'll end up with two same-named entries, not one merged one.
:::

::: callout-warn
If a variant with the same weight and style already exists in a family, the upload is rejected as a conflict -- and this currently surfaces as a raw error rather than a clean "this variant already exists" message.
:::

## Moving and Deleting Variants

You can move a variant from one custom family to another. Moving into a built-in family is not allowed, though in practice the family picker doesn't offer built-in families as a destination to begin with. If moving a variant out of a family leaves that family with no variants left, the now-empty family is automatically removed entirely.

## Silent Font Fallback

::: callout-warn
If the font currently selected in your settings no longer exists -- for example, its last remaining variant was deleted, or a restored settings profile references a font that isn't installed on this device -- TiefPrompt automatically switches to whatever font happens to be first in the combined built-in and custom font list, and saves that as your new selection. This isn't guaranteed to be a specific "safe" default font; it's simply whichever one sorts first, and there is **no on-screen notice** when this happens. If your font ever seems to have switched on its own, this fallback is almost certainly why.
:::
