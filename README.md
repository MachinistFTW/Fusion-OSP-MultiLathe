# OSP-MultiLathe

A unified Autodesk Fusion 360 post processor for Okuma lathes running the OSP-P300 and OSP-P500 control. One post scales from basic 2-axis turning through mill-turn to multi-tasking machines — configured by properties, not separate files.

## Supported Machines

Enable the properties that match your machine:

| Property | Description |
|----------|-------------|
| **Type M** | Live tooling (M-tool spindle) |
| **Type Y** | Y-axis |
| **Type W** | Sub-spindle |
| **Type TD** | ATC tool change (TD command) — Multus and other multi-tasking machines |

Examples: LB3000, LB3000 M, LB3000 MY, LB3000 MYW, Multus B300, Multus B300W — and anything in between.

## Current Status

**Phase 1 — Basic Lathe** (complete)
- 2-axis turning (face, rough, finish, groove, thread)
- Centerline drilling (drill, peck, bore, ream, tap)
- G50 max spindle speed clamp
- G96/G97 CSS and direct RPM
- G95/G94 feed per rev and feed per min
- G71 compound threading / G33 simple threading
- 6-digit tool format for nose-R compensation
- Program header with tool list and comments

**Phase 2 — Type M Live-Tool Lathe** (complete)
- G270/G271 mode switching (modal, after tool call)
- M960 C-axis shortest direction positioning (deferred to first C move)
- M146/M147 C-axis clamp/unclamp for milling contouring
- SB speed address, M12/M13/M14 milling spindle control
- M-tool compound fixed cycles: G181–G190, G296 (drill, tap, ream, bore)
- G178/G179 synchronized tapping (chip-breaking and deep-hole peck supported)
- G101/G102/G103 face contour generation (C-axis interpolation)
- G119 side contour mode, G132/G133 radial arcs
- Polar mode for axial milling (wrap machining)
- G17/G18/G19 plane selection (just-in-time, at arcs and cutter comp)
- Radial drilling with proper coordinate transformation (local frame to machine X/Z)
- Helical XCZ linearization gate
- XY range check — errors on impossible moves instead of silent bad code
- Radial milling correctly errors when Y-axis is required (no silent undercut)

**Planned phases:**

**Phase 3 — Type Y Y-axis Lathe**
- G272 Y-axis machining mode
- True XYZ milling (3-axis radial contouring without C-axis substitution)
- Helical interpolation
- Y-axis off-center turning

**Phase 4 — Type W Sub-Spindle & Part Transfer**
- G140/G141 spindle selection
- G122/G123 W-axis commands
- M151/M150 synchronized spindle rotation
- M248/M249 sub-spindle chuck control
- Part transfer sequences
- Cutoff support
- Tailstock vs. sub-spindle option switch

**Phase 5 — Type TD — ATC / Multi-Tasking**
- TD tool command format (ATC magazine — Multus P300/P500 and other TD-style machines)
- M323/M423 tool change
- 3+2 positioning
- B-axis support (G148/G149)
- 5-axis simultaneous contouring

## Installation

1. Download `OSP-MultiLathe.cps`
2. In Fusion 360: **Utilities > Post Processor > Import**
3. Select the file — it appears in your post library
4. When posting, configure the machine type properties to match your machine

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).

Free to use, modify, and redistribute. If you redistribute (including selling as part of a service), you must include the source and the same license. See the license for full terms.

## Author

[@MachinistFTW](https://github.com/MachinistFTW)
