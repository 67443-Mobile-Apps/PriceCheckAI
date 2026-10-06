## Building PriceCheck with AI tools

### Starting off - v1

We are building the PriceCheck app using an AI tool and some basic prompting. In my case, I used Claude Code (Opus 4.7), had it read `scan_by_location.json` and `wireframes.png` to get a basic idea of what I wanted.  Because Claude sometimes has issues with creating an Xcode project from scratch, I opened Xcode and built the initial (mostly empty) project and called it `PriceCheck` (later renamed to v1). It asked a few basic questions and it got off to building the app. The styling was horrific, so I asked it to make some styling changes. It did, but didn't follow my usual convention of style and theming materials to a separate `Theme.swift` file, so had to prompt it a third time to make that basic change. In the end, I got a decent enough prototype for this app.

---

### Building v2 with skills

To build a better version and to have it documented well enough to build on it further, I thought it'd be better to use skills. I had previously installed skills from [https://github.com/mattpocock/skills](https://github.com/mattpocock/skills). There are instructions for installation on GitHub, but I did it with `npx` using the following command: `npx skills@latest add mattpocock/skills --skill=grill-with-docs`. If you go this route, be sure to add Claude Code to the agent list (at the time I installed, it wasn't there by default; maybe different now, but worth the check).

With these skills installed, the one I chose for this project was `grill-with-docs` ([see https://github.com/mattpocock/skills/tree/main/skills/engineering](https://github.com/mattpocock/skills/tree/main/skills/engineering)). In Claude Code, I simply types `/grill-with-docs` and Claude gave me an extensive interview. From that it generated a glossary, and an ADR (Architectural Decision Record) for Swift Data. After that it walked me through an implementation plan and gave me an opportunity to make a few modifications. With this documentation in hand, building out the app was a relatively easy process -- one that could be done systematically in a step-by-step process with testing at every stage.

The `docs` directory contains the documentation artifacts and the `PriceCheck` directory has v2 of this app. (Again, I started the project in Xcode manually as Claude sometimes has issues at this step.)  I did build out an implementation plan for a React Native version, but haven't built it out yet.

