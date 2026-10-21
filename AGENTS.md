# AGENTS.md

Instructions for AI agents working on this repository.

## What this is

AddOnPeaks is a World of Warcraft (retail) addon written in Lua. It shows the addons with the highest single-frame CPU spikes, read from `C_AddOnProfiler`. Its main use is finding what makes world entry slow.

This repository is the source. The game loads it from `World of Warcraft\_retail_\Interface\AddOns\AddOnPeaks\`, which is a copy of this folder.

## Files

- `AddOnPeaks.toc`: addon manifest. `## Interface` must match the game client (currently `120100`). `## SavedVariables` lists `AddOnPeaksDB`.
- `AddOnPeaks.lua`: the whole addon (data collection, window, slash command, logout save).
- `README.md`: user documentation. Keep it in English.
- `CHANGELOG.md`: add an entry for each release.
- `LICENSE`: MIT. Do not change it without asking.

## Rules

- **Folder and TOC name must match.** The folder is `AddOnPeaks` and the TOC is `AddOnPeaks.toc`. The game does not load the addon otherwise.
- **Use the current API namespaces.** Use `C_AddOns.GetNumAddOns`, `C_AddOns.GetAddOnInfo` and `C_AddOnProfiler.GetAddOnMetric`. Legacy globals like `GetNumAddOns` may be missing on this client.
- **Do not commit game data.** `SavedVariables`, `WTF` and any saved `.lua` from the game must not go into git. `.gitignore` covers it.
- **Do not edit the in-game copy.** Change the source here, then copy it to the game folder. Keep both in sync.
- **Keep it small.** Avoid external libraries. Only use the default UI APIs.

## Testing

There are no automated tests. Test in the game:

1. Copy the `AddOnPeaks` folder to `World of Warcraft\_retail_\Interface\AddOns\`.
2. Use `/reload` after each change to Lua code.
3. Run `/aop` after entering the world and check the window.
4. Check the BugSack addon (if installed) for Lua errors.

Say clearly when a change was not tested in the game.

## Git

- Default branch: `main`.
- **Before starting work, run `git pull`.** Changes may have been pushed from another machine.
- **After finishing, commit and `git push`.** Changes that exist only on one machine are lost to the other.
- Commit messages: short imperative English, for example `Fix window layout`.
- The author is set in the local git config of this repository.
