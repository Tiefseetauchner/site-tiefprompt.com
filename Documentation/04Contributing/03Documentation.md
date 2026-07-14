---
title: "Documentation Guidelines"
description: "Documentation for writing documentation for TiefPrompt"
---

# Documentation Guidelines

{{ anchor: '04Contributing/03Documentation.md' }}

Documentation is not written inside the primary TiefPrompt repository, rather living in [site-tiefprompt.com](https://github.com/Tiefseetauchner/site-tiefprompt.com).

Documentation is written in Markdown. Conversion to the website and PDF is done via [TiefDownConverter](https://github.com/Tiefseetauchner/TiefDownConverter).

When adapting the documentation, you can run `./build.sh` to build the whole site (slow!) or just `tiefdownconverter convert -m Documentation` to convert only the documentation. Images have to be copied to `Documentation/resources`.

When adding a feature, you can add screenshots to the screnshot automation in `tiefprompt/integration_test/marketing`. If not, they will be added "magically" (by Tiefseetauchner). If you want, you can also extend the documentation with the feature.

Styling of the website happens in `site-tiefprompt.com/scss`. Javascript goes into `static_resources/js`. If you need to add something significant, better ask, this TiefDown project is a mess.
