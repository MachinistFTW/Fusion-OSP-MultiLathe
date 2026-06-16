# OSP-MultiLathe

A unified Autodesk Fusion 360 post processor for Okuma lathes running the OSP-P300 and OSP-P500 control. One post scales from basic 2-axis turning through mill-turn to multi-tasking Multus machines — configured by properties, not separate files.

## Supported Machines

Enable the properties that match your machine:

| Property | Description |
|----------|-------------|
| **Type M** | Live tooling (M-tool spindle) |
| **Type Y** | Y-axis |
| **Type W** | Sub-spindle |
| **Type Multus** | Multi-tasking / ATC magazine |

Examples: LB3000, LB3000 M, LB3000 MY, LB3000 MYW, Multus B300C, Multus B300W — and anything in between.

## Current Status

**Phase 1 — Basic Lathe** (in progress)
- 2-axis turning (face, rough, finish, groove, thread)
- Centerline drilling (drill, peck, bore, ream, tap)
- G50 max spindle speed clamp
- G96/G97 CSS and direct RPM
- G95/G94 feed per rev and feed per min
- G71 compound threading / G33 simple threading
- 6-digit tool format for nose-R compensation
- Program header with tool list and comments

**Planned phases:**
- Phase 2: Type M — C-axis, live tooling, M-tool compound cycles (G181–G190)
- Phase 3: Type Y — Y-axis milling, helical interpolation
- Phase 4: Type W — Sub-spindle, part transfer, cutoff
- Phase 5: Multus — ATC (TD command), B-axis, 5-axis

## Installation

1. Download `OSP-MultiLathe.cps`
2. In Fusion 360: **Utilities > Post Processor > Import**
3. Select the file — it appears in your post library
4. When posting, configure the machine type properties to match your machine

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).

Free to use, modify, and redistribute. If you redistribute (including selling as part of a service), you must include the source and the same license. See the license for full terms.

## Author

[@MachinistFTW](https://github.com/MachinistFTW))
