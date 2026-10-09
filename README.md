# AddOnPeaks

[Čeština](README.cs.md) · **English**

A small World of Warcraft (retail) addon that shows which addons cause the biggest single-frame CPU spikes, for example during world entry.

It reads the per-addon profiler metrics from `C_AddOnProfiler` and shows the top 15 addons in a small window.

![AddOnPeaks window in game](docs/screenshot.webp)

## Usage

| Command | Effect |
|---|---|
| `/aop` | Opens the window with the top 15 addons and saves the full table to `AddOnPeaksDB` |
| `/aop hide` | Hides the window |

The window columns:

- **Peak ms**: the highest single-frame time since the last UI reload (red >= 100 ms, yellow >= 20 ms)
- **Last ms**: time in the most recent frame
- **>50ms**: number of frames where the addon took more than 50 ms

When you log out, the full table is also saved to `SavedVariables` (`WTF\Account\<account>\SavedVariables\AddOnPeaks.lua`).

## Tip: measure world entry

Profiler metrics reset on every UI reload. To measure world entry, reload first, then log in and enter the world, then run `/aop`.

## Installation

1. Download **`AddOnPeaks-<version>.zip`** from the [Releases page](https://github.com/DanielDocekal/AddOnPeaks/releases/latest).
2. Extract the ZIP. It contains one folder, `AddOnPeaks`.
3. Copy that `AddOnPeaks` folder into:

   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```

4. Restart the game or log out and back in, then enable the addon in the addon list.

If you use WowUp or another addon manager, do not install this addon through it unless it is listed there. A manual copy is the normal way for this addon.

### Building the ZIP yourself

Run `build.ps1` from the repository root. It creates `dist\AddOnPeaks-<version>.zip`.

## Requirements

- World of Warcraft retail, interface version 120100 (patch 12.1.x)

## Notes

- Blizzard's own addons cannot be measured by the profiler.
- The profiler only shows values for addons that are loaded.

## License

MIT, see [LICENSE](LICENSE).
