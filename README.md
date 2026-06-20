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

**Phase 3 — Type Y Y-axis Lathe** (testing)
- G272 Y-axis machining mode — true XYZ milling without C-axis substitution
- Automatic Y-axis preference for hole milling operations (thread mill, bore mill, circular mill)
- Manual NC override — force G271 (C-axis) or G272 (Y-axis) per operation
- C-axis pre-positioning with coordinate rotation (minimizes Y travel for off-center features)
- Thread mill cutter compensation (G41/G42) in both G271 and G272 modes
- Dead-tool off-center drilling validation (prevents silent bad code)
- Radial and indexing milling require Y-axis — post errors instead of producing wrong geometry

**Planned phases:**

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

## When Does the Post Use Y-Axis vs C-Axis?

If your machine has a Y-axis (Type Y enabled), the post automatically decides which mode to use based on the operation. You can also override the choice with a Manual NC Action.

| Operation | Default Mode | Why |
|-----------|-------------|-----|
| Turning | G270 (turning) | No C or Y needed |
| Dead-tool drilling | G270 (turning) | Spindle rotates, tool is static — centerline only |
| Live-tool face drilling | G271 (C-axis) | C positions the hole, live tool drills |
| Thread mill, bore mill, circular mill | **G272 (Y-axis)** | Auto-preferred — better finish and cycle time |
| Face milling / face pocket | G271 (C-axis polar) | Polar interpolation handles axial surfaces well |
| Radial (OD) milling | **G272 (Y-axis)** | Required — C-axis substitution produces wrong geometry |
| Wrapped contour (polar) | G271 (C-axis) | Must use polar — cylindrical coordinates |

**Overriding the default:** Insert a **Manual NC > Action** before any axial operation in Fusion. Type `G272` or `G271` anywhere in the text (e.g., "FORCE G272", "USE G271"). The override applies to the next operation only — subsequent operations return to the default. The post validates the override and errors if the combination is invalid (e.g., G272 on a machine without Y-axis, or G271 on a radial operation).

## Safety Checks

The post includes several guards against silent bad code:

- **Dead-tool off-center:** If a dead (non-live) tool is programmed to drill at a position other than X0 Y0, the post stops with an error. Dead tools can only drill on centerline.
- **Radial milling without Y-axis:** Attempting 3-axis radial contouring on a machine without Y-axis produces an error instead of silently wrapping with C-axis (which would undercut/overcut).

## Warning

**All programs must be verified before use.** Wrong NC programs can result in severe damage to CNC machines, machined parts, and/or bodily injury. By using this post processor you accept all risks and agree that the author(s) are not liable for any damages, losses, injuries, or expenses resulting from its use.

Always review, dry-run, and simulate before running generated code on actual machinery.

## Installation

1. Download `OSP-MultiLathe.cps`
2. In Fusion 360: **Utilities > Post Processor > Import**
3. Select the file — it appears in your post library
4. When posting, configure the machine type properties to match your machine

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).

Free to use, modify, and redistribute. If you redistribute (including selling as part of a service), you must include the source and the same license. See the license for full terms.

## Support

Report issues using the [GitHub issue tracker](https://github.com/MachinistFTW/Fusion-OSP-MultiLathe/issues). For general Okuma programming questions, contact your local Okuma distributor.

## Author

[@MachinistFTW](https://github.com/MachinistFTW)
