# OSP-MultiLathe Backlog

Tracked issues, planned features, and investigation items. Items are grouped by category and roughly prioritized within each group.

---

## Bugs

- **C-axis unclamp in G272 (M146/M147)** — Y-axis-only operations (G272) output M146 (C-axis unclamp) when C is not actively used. C should remain clamped for pure Y-axis toolpaths. Only unclamp for G271 polar milling and C-axis contouring. Observed in LB3000MYW: N111 (thread mill in G272) has C unclamped incorrectly.

- **MY N108 linearized arcs** — Near the end of the toolpath, arcs are being linearized to G1 moves instead of output as G2/G3. Investigate why the post falls back to linearization.

- **Alarm 2543 on TD retract moves** — X20. Z10. max travel moves generate Alarm 2543 in TD mode. Cleared by using T#000 format during those moves. Need logic to determine which retract move gets the T#000 command.

---

## Investigated / Monitoring

- **XZC arc 0/360 boundary crossing (Alarm 2255)** — Lead-in/lead-out arcs near C=0 wrap from C~1 to C~359, creating a ~358 delta for a ~2 actual motion. Arc radius is too small for the apparent chord. **Trigger:** Any contour with a lead-in/out arc at C=0 (the +X axis on the part face). **G271 mode is NOT affected** — tested full circles, and semicircles at all quadrants with no alarms. The control resolves the boundary internally using G102/G103 CW/CCW direction. Alarm occurred in their manual XC conversion path (not G271), where C coordinates are computed directly. **Status:** G271 axial polar verified safe. G132/G133 radial path untested, may still be vulnerable. **Fix if needed:** Detect arcs where |endC - startC| > 180 AND short path < 30, then linearize. Test files: `2255TEST.cnc`, `00100.cnc` in VS Code Custom CNC files.

---

## Safety / Restart

- **G50 on every tool change** — Currently G50 only outputs when CSS (G96) is active AND max speed changed, or on spindle switches (G140/G141). G97 operations skip G50. For restart safety, G50 should output unconditionally after every T-command.

- **M210 during synchronized rotation** — M210 (ignore spindle orientation) after M151 during the sub-spindle grab sequence and all following both spindles grabbed paths. Without it during sync; causes alarm on restart.

---

## Cycles

- **Turning canned cycles (G86/G87/G88)** — G85 turning-canned-rough is working. Remaining: G86 (rough copy), G87 (finish turning), G88 (continuous thread). Investigate whether Fusion's CAM engine can drive these via `onCyclePath`. G84 (condition change) is an optional extension of G85.

- **G71 thread cycle parameter validation** — Verify D (depth/pass), H (first cut height), and I (taper radius) match Fusion's simulation. Run sim side-by-side with cycle output.

- **G33 redundant rapids** — G33 auto-returns to start; Fusion's inter-pass rapids are redundant. Safe but wasteful. Fix options: suppress rapids in G33 context, switch to G34, or rely on G71 compound cycle.

- **Break-through drilling cycle** — Currently expanded to G1. Could be a custom macro.

- **Guided deep drilling cycle** — Currently expanded to G1. Could be a custom macro.

---

## Milling / Contouring

- **Hole milling cutter compensation (G41/G42)** — Property-gated (`optHoleMillComp`). Thread mill and bore mill share a linear-entry/arc/exit pattern; circular pocket mill needs different handling (comp on finishing pass only). Detection: `isHoleMillingCycle() && tool.type == TOOL_MILLING_END_FLAT`. Removed from code for consistency — all hole milling comp ships together.

- **Arc endpoint correction after format rounding** — Rounding to output decimal resolution drifts endpoints off the true circle. Consider `CircularData` class that recomputes endpoints. Important for I/K center-point arc format. Evaluate whether format rounding causes measurable drift before enabling I/K.

- **Arc splitting unit tests** — L-mode splitting (full circles and >180 arcs into sub-180) and future I/K format need dedicated test cases. Fusion pre-splits arcs into <90 segments so current .cnc files don't exercise this.

- **Helical milling X-Y-Z** — Option property added, requires Type Y, logic TBD.

- **Helical contour X-C-Z** — Option property added, requires Type M, logic TBD.

---

## TD / ATC (Phase 5)

- **TD=05 (P05) position logic for mill tools** — Currently all mill tools route to P01. Radial mill tools should route to P05 (BA=90 base). Needs design work on detecting radial vs axial for position assignment.

---

## Manual NC Actions

- **SSV (M695/M694)** — Spindle Speed Variation for chatter suppression. Manual NC action sets a one-shot flag, post outputs M695 after spindle start, M694 at section end. Property-gated (default off).

- **Mic Check Finishing Mode** — Stops between finishing passes for measurement and offset adjustment.

- **expandCycle** — Per-operation override to force canned drilling cycles to expand to G1 linear moves. Useful when a canned cycle doesn't work for specific geometry.

---

## Coolant

- **Through-tool coolant OFF sequencing** — Turning off through-tool coolant may need both M102 (Spare M code command/Hardwire to HP unit) and M9 (flood OFF). Consider adding fill in the blank for HP unit commands.

- **Coolant configuration** — Through-spindle, high-pressure, air blow (M89/M88, M289/M288).

---

## Tool Management

- **Manual tool change handling** — When `tool.manualToolChange` is true, output M0 with a comment like "MANUAL TOOL CHANGE TO T####". Also M0 at program end for long tools that need manual removal.

- **Tool breakage detection** — Options for breakage detection codes.

---

## Machine Options

- **Tail Stock control** — IE:NC Tailstock, Tow-along: Option property added, logic TBD.

- **Super Nurbs / Hyper Surface smoothing** — Option property added, logic TBD.

- **Y-axis return to Y0 after off-center turning** — Machines with Y-axis off-center turning can leave Y at a non-zero position after the operation. The post should output G0 Y0. to return Y to a known zero after the tool runs. **Open question:** Can we safely output Y0 on ALL Y-axis machines at section end, or only on machines with the off-center turning option? If Y0 is harmless on machines without the option, it could be unconditional. If it causes issues (alarm, unexpected motion), it needs to be property-gated. Investigate before implementing.

- **Load monitoring integration** — VLMON[tool]=bitmask, M215/M216.

---

## Other

- **Verbose/debug comment mode** — Optional property that outputs a comment when non-common G/M codes are issued (G270, G271, G272, M146, M147, G119, etc.). Include toolpath type data at section start.

- **Parts catcher (M77/M76)** — Keyed to `cycle.usePartCatcher`.

- **Custom macro (CALL OO##) library**

- **Torque skip (G22/G29 PW=)** — Property-toggled, for stock transfer.
