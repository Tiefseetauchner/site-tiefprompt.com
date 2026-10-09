---
title: "Voice Activation"
description: "Control the teleprompter with your voice"
---

# Voice Activation

{{ anchor: '03Features/07VoiceActivation.md' }}

Voice Activation allows users to control the teleprompter using their voice. When enabled, the prompter will only scroll when it detects sound above a certain threshold. This feature is particularly useful for hands-free operation, ensuring that the teleprompter responds to the user's voice commands.

Note that **any** noise detected above the threshold will trigger the prompter to scroll, not just the user's voice. Therefore, it is important to set the sensitivity appropriately to avoid unintended scrolling.

You may also use an external microphone to improve voice detection accuracy by selecting the appropriate audio device from the dropdown menu in the Scroll Settings screen.

::: callout-info
Due to labels being the phone's name on some devices, it may be necessary to manually select the correct audio input to ensure accurate voice detection. The ID of the audio device is displayed in brackets after the label to allow users to identify the correct device.
:::

Note that if an audio device is removed, it will show up as "Unknown Device" in your dropdown and will not be functional until it is reconnected and selected again.

::: callout-warn
If an audio device is connected while the Scroll Settings screen is active, it may not be immediately recognized. You may need to leave and reenter the screen for detection to work, as the audio devices are not reloaded periodically.
:::