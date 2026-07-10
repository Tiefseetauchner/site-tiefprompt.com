---
title: "Theming"
description: "The relationship between the app's theme, its accent color, and the separate prompter theme"
---

# Theming

{{ anchor: '03Features/06Theming.md' }}

Instructions for changing your theme and colors are covered in {{ autolink: '02Usage/01BasicConfig.md' }}. This article goes into why the prompter looks and behaves differently from the rest of the app.

## Two Separate Themes

TiefPrompt has two entirely independent themes: the **app theme**, used everywhere except the teleprompter screen, and the **prompter theme**, used only while you're actually reading a script. These aren't the same theme with a few overrides applied to one of them -- they're built completely separately, which is why changing your prompter's background and text colors never affects the rest of the app, and vice versa.

## Light, Dark, and System

The light/dark/system choice for the app theme is handled by the standard system-level mechanism for following your device's appearance -- TiefPrompt doesn't do any custom detection of its own, it simply hands the choice off and lets the platform resolve it.

## App Accent Color

In the app theme, your chosen accent color is the only color you can customize -- everything else (backgrounds, surfaces, borders, body text) is a fixed part of the app's light and dark looks and isn't user-adjustable. The accent color is used for both primary buttons/controls and secondary accents throughout the app.

Text and icons drawn on top of your accent color (for example, the label on a filled button) automatically switch between a dark or light color depending on how light or dark your chosen accent is, so button labels stay readable no matter what color you pick. This automatic contrast handling only applies within the app theme -- it has no effect on the prompter.

## Prompter Theme

The prompter's theme is built from a high-contrast dark base, with exactly three things layered on top: your app's accent color, and your explicitly chosen prompter background and text colors from {{ autolink: '02Usage/03DisplaySettings.md' }}. Unlike the app theme, there's no automatic contrast correction here -- if you pick a background and text color that are hard to read together, TiefPrompt won't adjust or warn you. The readability of your prompter text and background is entirely in your hands.
