/**
  OSP-MultiLathe Post Processor

  Copyright (c) 2025-2026 MachinistFTW

  This post processor is free software: you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This post processor is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this post processor. If not, see <https://www.gnu.org/licenses/>.
*/

description = "OSP-MultiLathe";
vendor = "OKUMA";
vendorUrl = "http://www.okuma.com";
legal = "Copyright (c) 2025-2026 MachinistFTW - GPL v3";
certificationLevel = 2;
minimumRevision = 45909;

if (typeof supportedFeatures != "undefined") {
  supportedFeatures |= FEATURE_TOOL_CALL_CYCLE;
}

longDescription = "OSP-MultiLathe post processor for Okuma OSP-P300 and P500 control. Supports all single turret configurations.";

extension = "min";
programNameIsInteger = false;
setCodePage("ascii");

capabilities = CAPABILITY_MILLING | CAPABILITY_TURNING;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(0.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(90);
allowHelicalMoves = true;
allowedCircularPlanes = (1 << PLANE_ZX) | (1 << PLANE_XY) | (1 << PLANE_YZ);
allowSpiralMoves = false;
allowFeedPerRevolutionDrilling = true;
highFeedrate = (unit == IN) ? 100 : 2500;

// user-defined properties
properties = {
  type1_M: {
    title      : "Type M — Live tooling",
    description: "Enable if your machine has live tooling (M-tool spindle). Required for drilling/tapping with driven tools.",
    group      : "Machine Type",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  type2_Y: {
    title      : "Type Y — Y-axis",
    description: "Enable if your machine has a Y-axis. Requires Type M (live tooling).",
    group      : "Machine Type",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  type3_W: {
    title      : "Type W — Sub-spindle",
    description: "Enable if your machine is a W type with a sub-spindle. Leave disabled if your machine has a tailstock (center).",
    group      : "Machine Type",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  type4_TD: {
    title      : "Type TD — ATC Tool Change",
    description: "Enable for machines using TD tool change format (ATC magazine). Includes Okuma Multus and other multi-tasking machines.",
    group      : "Machine Type",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  writeMachine: {
    title      : "Write machine",
    description: "Output the machine settings in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  writeTools: {
    title      : "Write tool list",
    description: "Output a tool list in the header of the code.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  showSequenceNumbers: {
    title      : "Show sequence numbers",
    description: "Controls when N-word sequence numbers appear in the output.",
    group      : "formats",
    type       : "enum",
    values     : [
      {title:"None", id:"none"},
      {title:"All", id:"all"},
      {title:"Tool change only", id:"toolChange"},
      {title:"Operation change", id:"operationChange"}
    ],
    value: "toolChange",
    scope: "post"
  },
  sequenceNumberStart: {
    title      : "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    scope      : "post"
  },
  sequenceNumberIncrement: {
    title      : "Sequence number increment",
    description: "The amount by which the sequence number is incremented.",
    group      : "formats",
    type       : "integer",
    value      : 1,
    scope      : "post"
  },
  separateWordsWithSpace: {
    title      : "Separate words with space",
    description: "Adds spaces between G-code words.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  useRadius: {
    title      : "Radius arcs (L)",
    description: "If yes, arcs use L (radius) format. If no, arcs use I/K (center) format.",
    group      : "preferences",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  maximumSpindleSpeed: {
    title      : "Max spindle speed (main)",
    description: "Maximum main spindle speed for G50 clamp.",
    group      : "Options",
    type       : "integer",
    range      : [0, 999999999],
    value      : 2500,
    scope      : "post"
  },
  maximumSubSpindleSpeed: {
    title      : "Max spindle speed (sub)",
    description: "Maximum sub-spindle speed for G50 clamp. Only used when Type W is enabled.",
    group      : "Options",
    type       : "integer",
    range      : [0, 999999999],
    value      : 3500,
    scope      : "post"
  },
  optNCTailStock: {
    title      : "NC Tail Stock",
    description: "Enable if your machine has an NC-controlled tailstock.",
    group      : "Options",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  optSuperNurbs: {
    title      : "Super Nurbs / Hyper Surface",
    description: "Enable Super Nurbs (Hyper Surface) smoothing for high-speed contouring.",
    group      : "Options",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  optHelicalMilling: {
    title      : "Helical Milling (X-Y-Z)",
    description: "Output true helical G02/G03 arcs in XYZ milling. Disable to linearize into line segments. Requires Type Y.",
    group      : "Options",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  optHelicalContour: {
    title      : "Helical Contour (X-C-Z)",
    description: "Output true helical G102/G103 arcs in XCZ polar contour mode. Disable to linearize into line segments. Requires Type M.",
    group      : "Options",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  optWorkOffsets: {
    title      : "Work Offsets (G15 H#)",
    description: "Enable work offset support using G15 H# commands.",
    group      : "Options",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  warnSpindleTap: {
    title      : "Warn on spindle tapping (G77/G78)",
    description: "Show a warning when tapping uses G77/G78 (main spindle float-tap) instead of G178/G179 (live tool). Disable to suppress the warning.",
    group      : "Options",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  drillingRetractMode: {
    title      : "Drilling retract mode",
    description: "M-tool drilling cycle approach format. IK (standard): I for radial, K for axial approach distance. R: absolute retract position — verify machine support before use.",
    group      : "preferences",
    type       : "enum",
    values     : [
      {title:"IK (Standard)", id:"IK"},
      {title:"R", id:"R"}
    ],
    value      : "IK",
    scope      : "post"
  },
  showNotes: {
    title      : "Show notes",
    description: "Writes operation notes as comments in the output.",
    group      : "formats",
    type       : "boolean",
    value      : true,
    scope      : "post"
  },
  homePositionX: {
    title      : "X home position (diameter)",
    description: "Safe home X position in diameter.",
    group      : "homePositions",
    type       : "spatial",
    value      : 10,
    scope      : "post"
  },
  homePositionZ: {
    title      : "Z home position",
    description: "Safe home Z position.",
    group      : "homePositions",
    type       : "spatial",
    value      : 10,
    scope      : "post"
  },
};

// wcs definition — Okuma lathes typically use a single zero offset
wcsDefinitions = {
  useZeroOffset: false,
  wcs          : [
    {name:"Standard", format:"#", range:[1, 1]}
  ]
};

var permittedCommentChars = " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,=_-/";

// formats
var gFormat = createFormat({prefix:"G", decimals:0});
var mFormat = createFormat({prefix:"M", decimals:0});
var spatialFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL});
var xFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL, scale:2}); // diameter mode
var zFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL});
var rFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL});
var feedFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL});
var pitchFormat = createFormat({decimals:6, type:FORMAT_REAL});
var toolFormat = createFormat({decimals:0, minDigitsLeft:4});
var tool6Format = createFormat({decimals:0, minDigitsLeft:6}); // 6-digit for nose-R comp: RRTTOO
var tdPositionFormat = createFormat({decimals:0, minDigitsLeft:2});
var tdToolFormat = createFormat({decimals:0, minDigitsLeft:4});
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:2, type:FORMAT_REAL});
var dwellFormat = createFormat({prefix:"F", decimals:2, type:FORMAT_REAL});
var oFormat = createFormat({decimals:0, minDigitsLeft:4});
var baFormat = createFormat({decimals:2, type:FORMAT_REAL});

var yFormat = createFormat({decimals:(unit == MM ? 3 : 4), type:FORMAT_REAL});
var wFormat = createFormat({decimals:(unit == MM ? 3 : 4), forceDecimal:true});
var cFormat = createFormat({decimals:3, type:FORMAT_REAL, scale:DEG});

// output variables
var xOutput = createOutputVariable({prefix:"X"}, xFormat);
var xMillOutput = createOutputVariable({prefix:"X"}, spatialFormat); // G272 radial mode — no diameter doubling
var yOutput = createOutputVariable({prefix:"Y"}, yFormat);
var zOutput = createOutputVariable({prefix:"Z"}, zFormat);
var wOutput = createOutputVariable({prefix:"W"}, wFormat);
var cOutput = createOutputVariable({prefix:"C"}, cFormat);
var feedOutput = createOutputVariable({prefix:"F"}, feedFormat);
var pitchOutput = createOutputVariable({prefix:"F", control:CONTROL_FORCE}, pitchFormat);
var sOutput = createOutputVariable({prefix:"S", control:CONTROL_FORCE}, rpmFormat);
var sbOutput = createOutputVariable({prefix:"SB=", control:CONTROL_FORCE}, rpmFormat);
var maxSpeedOutput = createOutputVariable({prefix:"S", control:CONTROL_FORCE}, rpmFormat);
var eOutput = createOutputVariable({prefix:"E", control:CONTROL_FORCE}, secFormat);
var baOutput = createOutputVariable({prefix:"BA=", control:CONTROL_FORCE}, baFormat);

// circular output — Okuma uses I/K for center-point arcs
var iOutput = createOutputVariable({prefix:"I", control:CONTROL_NONZERO}, spatialFormat);
var jOutput = createOutputVariable({prefix:"J", control:CONTROL_NONZERO}, spatialFormat);
var kOutput = createOutputVariable({prefix:"K", control:CONTROL_NONZERO}, spatialFormat);

// modal groups
var gMotionModal = createOutputVariable({}, gFormat);
var gPlaneModal = createOutputVariable({onchange:function () {gMotionModal.reset();}}, gFormat);
var gFeedModeModal = createOutputVariable({}, gFormat);
var gSpindleModeModal = createOutputVariable({}, gFormat);
var gAbsIncModal = createOutputVariable({}, gFormat);
var gCycleModal = createOutputVariable({}, gFormat);
var gMachiningModeModal = createOutputVariable({}, gFormat);

// state tracking
var sequenceNumber;
var showSequenceNumbers;
var optionalSection = false;
var forceSpindleSpeed = false;
var previousMaximumSpeed = 0;
var lastSpindleMode = undefined;
var lastSpindleSpeed = 0;
var lastSpindleDirection = undefined;
var forceCoolant = false;
var skipThreading = false;
var pendingRadiusCompensation = -1;
var saveShowSequenceNumbers;
var forceYAxisMode = false;
var forceCAxisMode = false;

var MACHINING_DIRECTION_AXIAL = 0;
var MACHINING_DIRECTION_RADIAL = 1;
var MACHINING_DIRECTION_INDEXING = 2;

function isRadialDrillMode() {
  return machineState.liveToolIsActive &&
    !machineState.usePolarMode &&
    (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL);
}

function toMachineCoords(_x, _y, _z) {
  var global = currentSection.workPlane.multiply(new Vector(_x, _y, _z));
  return {x: global.y / 2, z: global.z};
}

var machineState = {
  isTurningOperation  : undefined,
  liveToolIsActive    : false,
  feedPerRevolution   : undefined,
  currentSpindle      : 0,
  cAxisIsEngaged      : false,
  yAxisIsEngaged      : false,
  pendingM960         : false,
  pendingFeedMode     : undefined,
  pendingCoolant      : undefined,
  usePolarMode        : false,
  useYAxisMode        : false,
  feedIsDPM           : false,
  machiningDirection  : undefined,
  yAxisCAngle         : 0,
  toolIsLoaded          : false,
  skipSection           : false,
  stockTransferIsActive : false,
  subSpindleChuckPosition : 0,
  currentWorkOffset     : -1,
  bAxisAngle            : undefined,
  slantMachiningActive  : false,
  manualNCPosition      : 0
};

function hasLiveTooling() {
  return getProperty("type1_M") || getProperty("type4_TD");
}

function hasYAxis() {
  return getProperty("type2_Y") || getProperty("type4_TD");
}

function hasSubSpindle() {
  return getProperty("type3_W");
}

function isTD() {
  return getProperty("type4_TD");
}

function formatToolTD(pp, toolNumber) {
  return "TD=" + tdPositionFormat.format(pp) + tdToolFormat.format(toolNumber);
}

function getPositionNumber(tool, section) {
  if (machineState.manualNCPosition > 0) {
    return machineState.manualNCPosition;
  }

  var isSubSpindle = (machineState.currentSpindle == 1);

  if (tool.isTurningTool()) {
    var orientation = 0;
    if (hasParameter("operation:toolOrientation")) {
      orientation = getParameter("operation:toolOrientation");
    }
    if (orientation >= 45) {
      return isSubSpindle ? 7 : 1;
    } else {
      return isSubSpindle ? 11 : 5;
    }
  }

  var fwd = section.workPlane.forward;
  if (Math.abs(fwd.z) > 0.9) {
    return isSubSpindle ? 7 : 1;
  }
  if (Math.abs(fwd.z) < 0.1) {
    return isSubSpindle ? 11 : 5;
  }

  return isSubSpindle ? 7 : 1;
}

function getBAxisAngle(tool, section) {
  var pp = getPositionNumber(tool, section);

  if (pp >= 13) {
    return undefined;
  }

  if (tool.isTurningTool()) {
    var orientation = 0;
    if (hasParameter("operation:toolOrientation")) {
      orientation = getParameter("operation:toolOrientation");
    }
    if (orientation == 0 || orientation == 90) {
      return undefined;
    }
    // BA measured from spindle face (BA=0). Standard OD position is BA=90.
    // toolOrientation is the offset from the 90° base position.
    return 90 - orientation;
  }

  var fwd = section.workPlane.forward;
  if (Math.abs(fwd.z) > 0.9 || Math.abs(fwd.z) < 0.1) {
    return undefined;
  }

  // BA=0 at spindle face (along Z), BA=90 at OD (perpendicular to Z)
  var fwdPerp = Math.sqrt(fwd.x * fwd.x + fwd.y * fwd.y);
  var ba = Math.atan2(fwdPerp, fwd.z) * 180 / Math.PI;

  return ba;
}

function needsSlantMachining(section) {
  if (!isTD()) { return false; }
  var tool = section.getTool();
  if (tool.isTurningTool()) { return false; }
  var fwd = section.workPlane.forward;
  return (Math.abs(fwd.z) > 0.1 && Math.abs(fwd.z) < 0.9);
}

function writeSlantMachiningOn(angle) {
  writeBlock("G127", "B" + baFormat.format(angle));
  machineState.slantMachiningActive = true;
  gMotionModal.reset();
}

function writeSlantMachiningOff() {
  writeBlock(gFormat.format(126));
  machineState.slantMachiningActive = false;
}

function getMaxSpindleSpeed() {
  var prop = (machineState.currentSpindle == 1) ? "maximumSubSpindleSpeed" : "maximumSpindleSpeed";
  return getProperty(prop);
}

function getMachiningDirection(section) {
  var forward = section.isMultiAxis() ? section.getGlobalInitialToolAxis() : section.workPlane.forward;
  if (isSameDirection(forward, new Vector(0, 0, 1))) {
    return MACHINING_DIRECTION_AXIAL;
  } else if (Vector.dot(forward, new Vector(0, 0, 1)) < 1e-7) {
    return MACHINING_DIRECTION_RADIAL;
  } else {
    return MACHINING_DIRECTION_INDEXING;
  }
}

function getC(x, y) {
  return Math.atan2(y, x);
}

function getModulus(x, y) {
  return Math.sqrt(x * x + y * y);
}

function getCClosest(x, y, _c) {
  if (!xFormat.isSignificant(x) && !yFormat.isSignificant(y)) {
    return _c;
  }
  var c = getC(x, y);
  if (c < 0) {
    c += Math.PI * 2;
  }
  if (c > (Math.PI * 2 - 1e-4)) {
    c -= Math.PI * 2;
  }
  return c;
}

function toPolar(x, y) {
  return {
    xr: getModulus(x, y),
    cc: getCClosest(x, y, cOutput.getCurrent())
  };
}

function isHoleMillingCycle() {
  if (!hasParameter("operation:cycleType")) { return false; }
  var ct = getParameter("operation:cycleType");
  return ct == "thread-milling" || ct == "bore-milling" || ct == "circular-pocket-milling";
}

function rotateXY(x, y) {
  var theta = machineState.yAxisCAngle;
  if (theta == 0) { return {x: x, y: y}; }
  var cosT = Math.cos(theta);
  var sinT = Math.sin(theta);
  return {x: x * cosT + y * sinT, y: -x * sinT + y * cosT};
}

function getPolarFeed(feed, xr, hasX, hasZ, hasC) {
  var cOnly = !hasX && !hasZ && hasC;
  if (cOnly != machineState.feedIsDPM) {
    forceFeed();
    machineState.feedIsDPM = cOnly;
  }
  var rawFeed = (cOnly && xr > 0) ? feedOutput.format(feed * 180 / (Math.PI * xr)) : getFeed(feed);
  var fm = rawFeed ? flushFeedMode() : undefined;
  return (rawFeed && fm) ? (rawFeed + " " + fm) : rawFeed;
}

function flushPrePositionBuffer(cc) {
  cOutput.reset();
  writeBlock(gMotionModal.format(0), cOutput.format(cc));
  for (var i = 0; i < machineState.prePositionBuffer.length; i++) {
    writeln(machineState.prePositionBuffer[i]);
  }
  machineState.prePositionBuffer = [];
  machineState.cPrePositionPending = false;
  gMotionModal.reset();
}

function engageCAxis() {
  if (!machineState.cAxisIsEngaged || machineState.yAxisIsEngaged) {
    if (!machineState.cAxisIsEngaged && !machineState.yAxisIsEngaged && lastSpindleSpeed > 0) {
      gSpindleModeModal.reset();
      sOutput.reset();
      writeBlock(gSpindleModeModal.format(97), sOutput.format(lastSpindleSpeed), mFormat.format(5));
      forceSpindleSpeed = true;
    }
    writeBlock(gMachiningModeModal.format(271));
    machineState.cAxisIsEngaged = true;
    machineState.yAxisIsEngaged = false;
    machineState.pendingM960 = true;
    gMotionModal.reset();
  }
}

function flushM960() {
  if (machineState.pendingM960) {
    machineState.pendingM960 = false;
    return mFormat.format(960);
  }
  return undefined;
}

function flushFeedMode() {
  if (machineState.pendingFeedMode) {
    var result = machineState.pendingFeedMode;
    machineState.pendingFeedMode = undefined;
    return result;
  }
  return undefined;
}

function flushCoolant() {
  if (machineState.pendingCoolant !== undefined) {
    var coolant = machineState.pendingCoolant;
    machineState.pendingCoolant = undefined;
    setCoolant(coolant);
  }
}

function disengageCAxis() {
  if (machineState.cAxisIsEngaged || machineState.yAxisIsEngaged) {
    writeBlock(gMachiningModeModal.format(270));
    machineState.cAxisIsEngaged = false;
    machineState.yAxisIsEngaged = false;
    gMotionModal.reset();
  }
}

function engageYAxis() {
  if (!machineState.yAxisIsEngaged) {
    if (!machineState.cAxisIsEngaged && !machineState.yAxisIsEngaged && lastSpindleSpeed > 0) {
      gSpindleModeModal.reset();
      sOutput.reset();
      writeBlock(gSpindleModeModal.format(97), sOutput.format(lastSpindleSpeed), mFormat.format(5));
      forceSpindleSpeed = true;
    }
    writeBlock(gMachiningModeModal.format(272));
    machineState.yAxisIsEngaged = true;
    machineState.cAxisIsEngaged = true;
    gMotionModal.reset();
  }
}



function validateMachineConfig() {
  if (getProperty("type2_Y") && !getProperty("type1_M") && !getProperty("type4_TD")) {
    error(localize("Type Y (Y-axis) requires Type M (live tooling). Enable Type M or disable Type Y."));
  }
}

function formatSequenceNumber() {
  if (sequenceNumber > 99999) {
    sequenceNumber = getProperty("sequenceNumberStart");
  }
  var seqno = "N" + sequenceNumber;
  sequenceNumber += getProperty("sequenceNumberIncrement");
  return seqno;
}

function writeBlock() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  var seqno = "";
  var opskip = "";
  if (showSequenceNumbers == "all") {
    seqno = formatSequenceNumber();
  }
  if (optionalSection) {
    opskip = "/";
  }
  writeWords(opskip, seqno, text);
  if (showSequenceNumbers == "toolChange" || showSequenceNumbers == "operationChange") {
    showSequenceNumbers = "none";
  }
}

function writeBlockWithSeqno() {
  var text = formatWords(arguments);
  if (!text) {
    return;
  }
  var seqno = formatSequenceNumber();
  writeWords(seqno, text);
}

function formatComment(text) {
  return "(" + String(filterText(String(text).toUpperCase(), permittedCommentChars)).replace(/[()]/g, "") + ")";
}

function writeComment(text) {
  writeln(formatComment(text));
}

function forceXYZ() {
  xOutput.reset();
  xMillOutput.reset();
  yOutput.reset();
  zOutput.reset();
  cOutput.reset();
}

function forceFeed() {
  feedOutput.reset();
}

function forceAny() {
  forceXYZ();
  forceFeed();
}

function forceModals() {
  gMotionModal.reset();
  gPlaneModal.reset();
  gAbsIncModal.reset();
  gFeedModeModal.reset();
  gSpindleModeModal.reset();
}

function getFeed(f) {
  var result = feedOutput.format(f);
  if (result) {
    var fm = flushFeedMode();
    if (fm) {
      result += " " + fm;
    }
  }
  return result;
}

function formatFeedMode(mode) {
  if (mode == FEED_PER_REVOLUTION) {
    machineState.feedPerRevolution = true;
    return gFeedModeModal.format(95);
  } else {
    machineState.feedPerRevolution = false;
    return gFeedModeModal.format(94);
  }
}

var currentCoolantMode = COOLANT_OFF;

function setCoolant(coolant) {
  var coolantCodes = getCoolantCodes(coolant);
  if (Array.isArray(coolantCodes)) {
    for (var c in coolantCodes) {
      writeBlock(coolantCodes[c]);
    }
    return undefined;
  }
  return coolantCodes;
}

function getCoolantCodes(coolant) {
  if (coolant == currentCoolantMode && !forceCoolant) {
    return undefined;
  }
  forceCoolant = false;

  var m = [];

  if (isTD()) {
    if (coolant == COOLANT_OFF) {
      if (currentCoolantMode != COOLANT_OFF) {
        m.push(mFormat.format(262));
      }
      currentCoolantMode = COOLANT_OFF;
      return m;
    }
    if (currentCoolantMode != COOLANT_OFF) {
      m.push(mFormat.format(262));
    }
    switch (coolant) {
    case COOLANT_FLOOD:
      m.push(mFormat.format(263));
      break;
    case COOLANT_THROUGH_TOOL:
      m.push(mFormat.format(175));
      break;
    case COOLANT_AIR:
    case COOLANT_MIST:
      m.push(mFormat.format(51));
      break;
    default:
      warning(localize("Coolant type not supported, using flood coolant."));
      m.push(mFormat.format(263));
      break;
    }
    currentCoolantMode = coolant;
    return m;
  }

  if (coolant == COOLANT_OFF) {
    if (currentCoolantMode != COOLANT_OFF) {
      m.push(mFormat.format(9));
    }
    currentCoolantMode = COOLANT_OFF;
    return m;
  }

  if (currentCoolantMode != COOLANT_OFF) {
    m.push(mFormat.format(9));
  }

  if (coolant != COOLANT_FLOOD && coolant != COOLANT_THROUGH_TOOL && coolant != COOLANT_MIST) {
    warning(localize("Coolant type not supported, using flood coolant."));
  }
  m.push(mFormat.format(8));

  currentCoolantMode = coolant;
  return m;
}

function startSpindle(enableCSS) {
  var isLiveTool = machineState.liveToolIsActive;
  var _spindleSpeed;
  var spindleMode;

  gSpindleModeModal.reset();

  if (isLiveTool) {
    if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
      error(localize("Constant surface speed (G96) is not supported with live tooling."));
      return;
    }
    _spindleSpeed = spindleSpeed;
    var spindleDir = mFormat.format(tool.clockwise ? 13 : 14);
    writeBlock(sbOutput.format(_spindleSpeed), spindleDir);
    lastSpindleMode = tool.getSpindleMode();
    lastSpindleSpeed = _spindleSpeed;
    lastSpindleDirection = tool.clockwise;
    return;
  }

  var spindleDir = mFormat.format(tool.clockwise ? 3 : 4);
  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getMaxSpindleSpeed()) : getMaxSpindleSpeed();

  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    if (enableCSS) {
      _spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1 / 1000.0 : 1 / 12.0);
      spindleMode = 96;
    } else {
      var initialPosition = getFramePosition(currentSection.getInitialPosition());
      if (xFormat.getResultingValue(initialPosition.x) == 0) {
        _spindleSpeed = maximumSpindleSpeed;
      } else {
        _spindleSpeed = Math.min((tool.surfaceSpeed * ((unit == MM) ? 1000.0 : 12.0) / (Math.PI * Math.abs(initialPosition.x * 2))), maximumSpindleSpeed);
      }
      spindleMode = 97;
    }
  } else {
    _spindleSpeed = spindleSpeed;
    if (_spindleSpeed > maximumSpindleSpeed) {
      warning(localize("Tool " + tool.number + " requests S" + rpmFormat.format(_spindleSpeed) +
        " but max spindle speed is " + rpmFormat.format(maximumSpindleSpeed) +
        ". Speed clamped to S" + rpmFormat.format(maximumSpindleSpeed) + "."));
      _spindleSpeed = maximumSpindleSpeed;
    }
    spindleMode = 97;
  }

  writeBlock(gSpindleModeModal.format(spindleMode), sOutput.format(_spindleSpeed), spindleDir);

  lastSpindleMode = tool.getSpindleMode();
  lastSpindleSpeed = _spindleSpeed;
  lastSpindleDirection = tool.clockwise;
}

function writeRetract() {
  if (arguments.length == 0) {
    error(localize("No axis specified for writeRetract()."));
    return;
  }
  var words = [];
  for (var i = 0; i < arguments.length; ++i) {
    switch (arguments[i]) {
    case X:
      xOutput.reset();
      words.push(xOutput.format(getProperty("homePositionX")));
      break;
    case Z:
      zOutput.reset();
      words.push(zOutput.format(getProperty("homePositionZ")));
      break;
    default:
      error(localize("Bad axis specified for writeRetract()."));
      return;
    }
  }
  if (words.length > 0) {
    writeBlock(gMotionModal.format(0), words);
  }
}

function onOpen() {
  validateMachineConfig();

  if (getProperty("useRadius")) {
    maximumCircularSweep = toRad(90);
  }

  showSequenceNumbers = getProperty("showSequenceNumbers");
  sequenceNumber = getProperty("sequenceNumberStart");

  if (!getProperty("separateWordsWithSpace")) {
    setWordSeparator("");
  }

  if (highFeedrate <= 0) {
    error(localize("You must set 'highFeedrate' because axes are not synchronized for rapid traversal."));
    return;
  }

  // Program number
  if (programName) {
    var programId = parseInt(programName, 10);
    if ((programId >= 1) && (programId <= 9999)) {
      writeln("O" + oFormat.format(programId));
    }
  }

  // Spindle control declaration — must come before comments on W-type machines
  if (hasSubSpindle() || isTD()) {
    writeBlock(gFormat.format(140));
  }
  machineState.currentSpindle = 0;

  // Program comment
  if (programComment) {
    writeComment(programComment);
  }

  // Date
  var d = new Date();
  writeComment("DATE - " + (d.getMonth() + 1) + "/" + d.getDate() + "/" + d.getFullYear());

  // Machine info
  if (getProperty("writeMachine")) {
    var vendor = machineConfiguration.getVendor();
    var model = machineConfiguration.getModel();
    var mDescription = machineConfiguration.getDescription();
    if (vendor || model || mDescription) {
      writeComment("MACHINE - " + vendor + " " + model);
      if (mDescription) {
        writeComment("  " + mDescription);
      }
    }
  }

  // Tool list
  if (getProperty("writeTools")) {
    var zRanges = {};
    if (is3D()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var zRange = section.getGlobalZRange();
        var tool = section.getTool();
        if (zRanges[tool.number]) {
          zRanges[tool.number].expandToRange(zRange);
        } else {
          zRanges[tool.number] = zRange;
        }
      }
    }

    var toolPositions = {};
    if (isTD()) {
      var numberOfSections = getNumberOfSections();
      for (var i = 0; i < numberOfSections; ++i) {
        var section = getSection(i);
        var sTool = section.getTool();
        if (toolPositions[sTool.number] === undefined) {
          toolPositions[sTool.number] = getPositionNumber(sTool, section);
        }
      }
    }

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var toolId;
        if (isTD()) {
          var pp = toolPositions[tool.number] !== undefined ? toolPositions[tool.number] : 1;
          toolId = formatToolTD(pp, tool.number);
        } else {
          toolId = "T" + toolFormat.format(tool.number);
        }
        var toolText = toolId + " " +
          (tool.diameter != 0 ? "D=" + spatialFormat.format(tool.diameter) + " " : "") +
          (tool.isTurningTool() ? "NR=" + spatialFormat.format(tool.noseRadius) : "CR=" + spatialFormat.format(tool.cornerRadius)) +
          (zRanges[tool.number] ? " - ZMIN=" + spatialFormat.format(zRanges[tool.number].getMinimum()) : "") +
          " - " + getToolTypeName(tool.type);
        writeComment(toolText);
      }
    }
  }

  // Safe startup
  writeBlock(gAbsIncModal.format(90));

  // G50 max spindle speed clamp
  var mTool = getSection(0).getTool();
  var maxSpeed = (mTool.maximumSpindleSpeed > 0) ? Math.min(mTool.maximumSpindleSpeed, getMaxSpindleSpeed()) : getMaxSpindleSpeed();
  if (maxSpeed > 0) {
    writeBlock(gFormat.format(50), maxSpeedOutput.format(maxSpeed));
    previousMaximumSpeed = maxSpeed;
  }

  // Cancel tool nose compensation and rapid to home
  writeBlock(gFormat.format(40));
  writeBlock(gMotionModal.format(0), "X" + xFormat.format(getProperty("homePositionX")), "Z" + zFormat.format(getProperty("homePositionZ")));
}

function onComment(message) {
  writeComment(message);
}

function onSectionSpecialCycle() {
  var strategy = hasParameter("operation-strategy") ? getParameter("operation-strategy") : "";
  var isToolCall = (strategy == "turningToolCall");
  if (strategy.indexOf("SecondarySpindle") >= 0 && !hasSubSpindle()) {
    error(localize("Sub-spindle cycle requires Type W to be enabled."));
    return;
  }
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      if (isToolCall) {
        var seqMode = getProperty("showSequenceNumbers");
        if (seqMode == "toolChange" || seqMode == "operationChange") {
          showSequenceNumbers = seqMode;
          writeBlockWithSeqno(formatComment(comment));
          showSequenceNumbers = "none";
        } else {
          writeComment(comment);
        }
      } else {
        writeComment(comment);
      }
    }
  }
}

function onSection() {
  machineState.isTurningOperation = (currentSection.getType() == TYPE_TURNING);
  machineState.liveToolIsActive = false;
  machineState.usePolarMode = false;
  machineState.useYAxisMode = false;
  machineState.cPrePositionPending = false;
  machineState.machiningDirection = undefined;

  if (!machineState.isTurningOperation) {
    machineState.machiningDirection = getMachiningDirection(currentSection);
    var toolIsLive = tool.isLiveTool && tool.isLiveTool();

    if (!currentSection.isMultiAxis() && isDrillingCycle()) {
      if (toolIsLive) {
        if (!hasLiveTooling()) {
          error(localize("Live tool drilling requires live tooling. Enable the 'Type M' or 'Type TD' property."));
          return;
        }
        machineState.liveToolIsActive = true;
        if (machineState.machiningDirection == MACHINING_DIRECTION_AXIAL) {
          if (forceYAxisMode) {
            if (!hasYAxis()) {
              error(localize("Cannot force G272: this machine does not have Y-axis capability."));
              return;
            }
            machineState.useYAxisMode = true;
          } else if (!forceCAxisMode && isHoleMillingCycle() && hasYAxis()) {
            machineState.useYAxisMode = true;
          }
        }
      }
    } else if (currentSection.isMultiAxis()) {
      var isWrapped = currentSection.polarMode != undefined && currentSection.polarMode != POLAR_MODE_OFF;
      if (isWrapped) {
        if (forceYAxisMode) {
          error(localize("Cannot force G272 on wrapped toolpath. Wrapped operations require C-axis polar interpolation (G271)."));
          return;
        }
        if (!hasLiveTooling()) {
          error(localize("Wrapped milling requires live tooling. Enable the 'Type M' or 'Type TD' property."));
          return;
        }
        machineState.liveToolIsActive = true;
        machineState.usePolarMode = true;
      } else {
        warning(localize("Multi-axis simultaneous toolpaths (4/5-axis) are not supported. Skipping operation."));
        machineState.skipSection = true;
        return;
      }
    } else if (currentSection.getType() == TYPE_MILLING) {
      if (!hasLiveTooling()) {
        error(localize("Milling operations require live tooling. Enable the 'Type M' or 'Type TD' property."));
        return;
      }
      machineState.liveToolIsActive = true;
      if (machineState.machiningDirection == MACHINING_DIRECTION_AXIAL) {
        if (forceYAxisMode) {
          if (!hasYAxis()) {
            error(localize("Cannot force G272: this machine does not have Y-axis capability."));
            return;
          }
          machineState.useYAxisMode = true;
        } else if (forceCAxisMode) {
          machineState.usePolarMode = true;
        } else if (isHoleMillingCycle() && hasYAxis()) {
          machineState.useYAxisMode = true;
        } else {
          machineState.usePolarMode = true;
        }
      } else if (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL) {
        if (forceCAxisMode) {
          error(localize("Cannot force G271 on radial operation. Radial milling requires Y-axis (G272)."));
          return;
        }
        if (!hasYAxis()) {
          error(localize("Radial milling requires a Y-axis (G272). This machine does not have Y-axis capability." +
            " Use 'Wrap' machining type in Fusion for C-axis substitution, or enable the Y-axis property."));
          return;
        }
        machineState.useYAxisMode = true;
      } else {
        if (forceCAxisMode) {
          error(localize("Cannot force G271 on indexing operation. Indexing milling requires Y-axis (G272)."));
          return;
        }
        if (!hasYAxis()) {
          error(localize("This milling operation requires a Y-axis. Use 'Wrap' machining type in Fusion" +
            " for C-axis substitution, or enable the Y-axis property."));
          return;
        }
        machineState.useYAxisMode = true;
      }
    } else {
      warning(localize("Unsupported milling operation type. Skipping operation."));
      skipRemainingSection();
      return;
    }
  }

  // TD slant machining (G127) requires Y-axis mode (G272)
  if (needsSlantMachining(currentSection)) {
    machineState.useYAxisMode = true;
    machineState.usePolarMode = false;
  }

  forceYAxisMode = false;
  forceCAxisMode = false;

  var forceSectionRestart = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  var insertToolCall = isToolChangeNeeded("number", "compensationOffset") || forceSectionRestart || !machineState.toolIsLoaded;

  // End previous section if tool change needed
  if (!isFirstSection() && insertToolCall) {
    onCommand(COMMAND_COOLANT_OFF);
    writeRetract(X);
    writeRetract(Z);

    onCommand(COMMAND_OPTIONAL_STOP);
    gMotionModal.reset();
  }

  // Spindle switching (G140/G141)
  var requestedSpindle = currentSection.spindle;
  if (requestedSpindle == 1 && !hasSubSpindle()) {
    error(localize("Operation targets sub spindle but Type W is not enabled."));
    return;
  }
  if (requestedSpindle != machineState.currentSpindle) {
    machineState.currentSpindle = requestedSpindle;
    if (!isTD()) {
      writeBlock(gFormat.format(requestedSpindle == 1 ? 141 : 140));
    }
    var newMaxSpeed = getMaxSpindleSpeed();
    writeBlock(gFormat.format(50), maxSpeedOutput.format(newMaxSpeed));
    previousMaximumSpeed = newMaxSpeed;
    forceSpindleSpeed = true;
    forceModals();
  }

  // Blank line and operation comment
  writeln("");
  if (hasParameter("operation-comment")) {
    var comment = getParameter("operation-comment");
    if (comment) {
      var seqMode = getProperty("showSequenceNumbers");
      if (seqMode == "toolChange" || seqMode == "operationChange") {
        showSequenceNumbers = seqMode;
        writeBlockWithSeqno(formatComment(comment));
        showSequenceNumbers = "none";
      } else {
        writeComment(comment);
      }
    }
  }

  machineState.compensationType = hasParameter("operation:compensationType") ? getParameter("operation:compensationType") : "computer";

  if (machineState.compensationType == "control") {
    writeComment("CUTTER COMP CONTROL TYPE");
  } else if (machineState.compensationType == "wear") {
    writeComment("CUTTER COMP WEAR TYPE");
  } else if (machineState.compensationType == "inverseWear") {
    writeComment("CUTTER COMP REVERSE WEAR TYPE - DIRECTION FLIPPED");
  }

  // Feed mode — defer to first feed line
  if (insertToolCall) {
    forceModals();
  }
  machineState.pendingFeedMode = formatFeedMode(currentSection.feedMode);

  // G50 max spindle speed — re-output if changed
  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getMaxSpindleSpeed()) : getMaxSpindleSpeed();
  if ((maximumSpindleSpeed > 0) && (currentSection.getTool().getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
    if (rpmFormat.areDifferent(maximumSpindleSpeed, previousMaximumSpeed)) {
      writeBlock(gFormat.format(50), maxSpeedOutput.format(maximumSpindleSpeed));
      previousMaximumSpeed = maximumSpindleSpeed;
    }
  }

  // Notes
  if (getProperty("showNotes") && hasParameter("notes")) {
    var notes = getParameter("notes");
    if (notes) {
      var lines = String(notes).split("\n");
      var r1 = new RegExp("^[\\s]+", "g");
      var r2 = new RegExp("[\\s]+$", "g");
      for (line in lines) {
        var comment = lines[line].replace(r1, "").replace(r2, "");
        if (comment) {
          writeComment(comment);
        }
      }
    }
  }

  // Tool change
  if (insertToolCall) {
    if (tool.number == 0) {
      error(localize("Tool number cannot be 0."));
      return;
    }

    gMotionModal.reset();
    if (getProperty("showSequenceNumbers") == "toolChange") {
      showSequenceNumbers = "toolChange";
    }

    if (isTD()) {
      if (machineState.manualNCPosition >= 13) {
        writeBlock(mFormat.format(0));
        writeComment("SET P" + machineState.manualNCPosition + " OFFSET FOR TOOL " + tool.number);
      }

      var pp = getPositionNumber(tool, currentSection);
      writeBlock(formatToolTD(pp, tool.number), mFormat.format(323));

      var ba = getBAxisAngle(tool, currentSection);
      if (ba !== undefined) {
        writeBlock(baOutput.format(ba), gFormat.format(52));
      }
      machineState.bAxisAngle = ba;
      machineState.manualNCPosition = 0;

      if (!isLastSection()) {
        var nextSection = getNextSection();
        var nextTool = nextSection.getTool();
        if (nextTool.number != tool.number) {
          writeBlock("/" + "MT=" + tdToolFormat.format(nextTool.number) + tdPositionFormat.format(1));
        }
      }
    } else {
      var compensationOffset = tool.compensationOffset;
      if (compensationOffset == 0) {
        compensationOffset = tool.number;
      }
      var toolCall = "T" + tool6Format.format(compensationOffset * 10000 + tool.number * 100 + compensationOffset);
      writeBlock(toolCall);
    }
    machineState.toolIsLoaded = true;

    if (getProperty("optWorkOffsets") && currentSection.workOffset > 0) {
      writeBlock("G15 H" + currentSection.workOffset);
      machineState.currentWorkOffset = currentSection.workOffset;
    }

    if (tool.comment) {
      writeComment(tool.comment);
    }
  }

  // Machining mode — reset modal on tool change so G270/G271/G272 is explicit at each new tool
  if (insertToolCall) {
    gMachiningModeModal.reset();
    machineState.cAxisIsEngaged = false;
    machineState.yAxisIsEngaged = false;
  }
  machineState.yAxisCAngle = 0;
  if (machineState.useYAxisMode) {
    engageYAxis();
    if (machineState.machiningDirection == MACHINING_DIRECTION_AXIAL) {
      var initPos = getFramePosition(currentSection.getInitialPosition());
      var theta = Math.atan2(initPos.y, initPos.x);
      machineState.yAxisCAngle = theta;
      if (Math.abs(theta) > 1e-6) {
        cOutput.reset();
        writeBlock(gMotionModal.format(0), cOutput.format(theta));
      }
    }
  } else if (machineState.liveToolIsActive && !machineState.isTurningOperation) {
    engageCAxis();
  } else {
    if (machineState.cAxisIsEngaged || machineState.yAxisIsEngaged) {
      disengageCAxis();
    } else {
      writeBlock(gMachiningModeModal.format(270));
    }
  }

  // Coolant — defer to just before first feed move
  if (insertToolCall) {
    machineState.pendingCoolant = tool.coolant;
  }

  // Spindle
  var spindleChanged = insertToolCall || forceSpindleSpeed || isSpindleSpeedDifferent();
  if (spindleChanged) {
    forceSpindleSpeed = false;
    startSpindle(false);
  }

  // Polar mode — activate after spindle and before positioning
  if (machineState.usePolarMode) {
    writeBlock(mFormat.format(146));
    if (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL) {
      writeBlock(gFormat.format(119));
      cOutput.reset();
      gMotionModal.reset();
    } else {
      machineState.pendingM960 = true;
      gMotionModal.reset();
    }
  }

  // Y-axis mode — M146 unclamp for milling contouring
  if (machineState.useYAxisMode) {
    writeBlock(mFormat.format(146));
    gMotionModal.reset();
  }

  // Position to initial point
  forceAny();
  gMotionModal.reset();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (machineState.useYAxisMode) {
    var rot = rotateXY(initialPosition.x, initialPosition.y);
    writeBlock(gMotionModal.format(0), xMillOutput.format(rot.x), yOutput.format(rot.y), zOutput.format(initialPosition.z));
  } else if (machineState.usePolarMode) {
    var polar = toPolar(initialPosition.x, initialPosition.y);
    writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    if (xFormat.isSignificant(polar.xr)) {
      writeBlock(gMotionModal.format(0), xOutput.format(polar.xr), cOutput.format(polar.cc), flushM960());
    } else {
      writeBlock(gMotionModal.format(0), xOutput.format(polar.xr), flushM960());
      machineState.cPrePositionPending = true;
      machineState.prePositionBuffer = [];
    }
  } else if (isRadialDrillMode()) {
    var mach = toMachineCoords(initialPosition.x, initialPosition.y, initialPosition.z);
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), xOutput.format(mach.x));
    writeBlock(gMotionModal.format(0), zOutput.format(mach.z));
  } else if (insertToolCall || (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    writeBlock(gMotionModal.format(0), xOutput.format(initialPosition.x));
  }

  // Slant machining for inclined 3+2 operations
  if (needsSlantMachining(currentSection) && machineState.bAxisAngle !== undefined) {
    writeSlantMachiningOn(machineState.bAxisAngle);
  }

  // Enable SFM after initial positioning
  if (spindleChanged && tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    startSpindle(true);
  }

}

function onDwell(seconds) {
  if (seconds > 9999.99) {
    warning(localize("Dwelling time is out of range."));
  }
  writeBlock(gFormat.format(4), dwellFormat.format(seconds));
}

function onRadiusCompensation() {
  var comp = radiusCompensation;
  if (machineState.compensationType == "inverseWear") {
    if (comp == RADIUS_COMPENSATION_LEFT) {
      comp = RADIUS_COMPENSATION_RIGHT;
    } else if (comp == RADIUS_COMPENSATION_RIGHT) {
      comp = RADIUS_COMPENSATION_LEFT;
    }
  }
  pendingRadiusCompensation = comp;
}

function onRapid(_x, _y, _z) {
  if (machineState.skipSection) { return; }
  if (machineState.useYAxisMode) {
    var rot = rotateXY(_x, _y);
    var x = xMillOutput.format(rot.x);
    var y = yOutput.format(rot.y);
    var z = zOutput.format(_z);
    if (x || y || z) {
      writeBlock(gMotionModal.format(0), x, y, z);
    }
    return;
  }
  if (machineState.usePolarMode) {
    var polar = toPolar(_x, _y);
    if (machineState.cPrePositionPending) {
      if (xFormat.isSignificant(polar.xr)) {
        flushPrePositionBuffer(polar.cc);
        var x = xOutput.format(polar.xr);
        var z = zOutput.format(_z);
        if (x || z) {
          writeBlock(gMotionModal.format(0), x, z, flushM960());
        }
      } else {
        var x = xOutput.format(polar.xr);
        var z = zOutput.format(_z);
        if (x || z) {
          var text = formatWords(gMotionModal.format(0), x, z, flushM960());
          if (text) {
            machineState.prePositionBuffer.push(text);
          }
        }
      }
      return;
    }
    var x = xOutput.format(polar.xr);
    var c = cOutput.format(polar.cc);
    var z = zOutput.format(_z);
    if (x || c || z) {
      if (pendingRadiusCompensation >= 0) {
        error(localize("Radius compensation mode cannot be changed at rapid traversal."));
        return;
      }
      writeBlock(gMotionModal.format(0), x, c, z, flushM960());
    }
    return;
  }

  if (isRadialDrillMode()) {
    var mach = toMachineCoords(_x, _y, _z);
    _x = mach.x;
    _z = mach.z;
  }
  var x = xOutput.format(_x);
  var z = zOutput.format(_z);
  if (x || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, z);
  }
}

function onLinear(_x, _y, _z, feed) {
  if (machineState.skipSection) { return; }
  flushCoolant();
  if (isSpeedFeedSynchronizationActive()) {
    var threadPitch = getParameter("operation:threadPitch");
    var threadsPerInch = 1.0 / threadPitch;
    var startXYZ = getCurrentPosition();
    var deltaX = spatialFormat.getResultingValue(_x - startXYZ.x);
    // Okuma alarm 2250: first G33 block must have both X and Z
    xOutput.reset();
    zOutput.reset();
    writeBlock(
      gMotionModal.format(33),
      xOutput.format(_x),
      zOutput.format(_z),
      iOutput.format(deltaX),
      pitchOutput.format(1 / threadsPerInch),
      flushFeedMode()
    );
    forceFeed();
    return;
  }

  if (machineState.useYAxisMode) {
    var rot = rotateXY(_x, _y);
    var x = xMillOutput.format(rot.x);
    var y = yOutput.format(rot.y);
    var z = zOutput.format(_z);
    if (x || y || z) {
      if (pendingRadiusCompensation >= 0) {
        var effectiveComp = pendingRadiusCompensation;
        pendingRadiusCompensation = -1;
        var plane = (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL) ? gPlaneModal.format(19) : gPlaneModal.format(17);
        if (plane) {
          writeBlock(plane);
        }
        switch (effectiveComp) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(gMotionModal.format(1), gFormat.format(41), x, y, z, getFeed(feed));
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(gMotionModal.format(1), gFormat.format(42), x, y, z, getFeed(feed));
          break;
        default:
          writeBlock(gMotionModal.format(1), gFormat.format(40), x, y, z, getFeed(feed));
        }
      } else {
        writeBlock(gMotionModal.format(1), x, y, z, getFeed(feed));
      }
    }
    return;
  }

  if (machineState.usePolarMode) {
    var polar = toPolar(_x, _y);
    if (machineState.cPrePositionPending) {
      if (xFormat.isSignificant(polar.xr)) {
        flushPrePositionBuffer(polar.cc);
      } else {
        var x = xOutput.format(polar.xr);
        var z = zOutput.format(_z);
        if (x || z) {
          var rawFeed = getFeed(feed);
          var fm = rawFeed ? flushFeedMode() : undefined;
          var f = (rawFeed && fm) ? (rawFeed + " " + fm) : rawFeed;
          var text = formatWords(gMotionModal.format(101), x, z, f, flushM960());
          if (text) {
            machineState.prePositionBuffer.push(text);
          }
        }
        return;
      }
    }
    var x = xOutput.format(polar.xr);
    var c = cOutput.format(polar.cc);
    var z = zOutput.format(_z);
    if (x || c || z) {
      var f = getPolarFeed(feed, polar.xr, x, z, c);
      if (pendingRadiusCompensation >= 0) {
        var effectiveComp = pendingRadiusCompensation;
        pendingRadiusCompensation = -1;
        switch (effectiveComp) {
        case RADIUS_COMPENSATION_LEFT:
          writeBlock(gMotionModal.format(101), gFormat.format(17), gFormat.format(41), x, c, z, f, flushM960());
          break;
        case RADIUS_COMPENSATION_RIGHT:
          writeBlock(gMotionModal.format(101), gFormat.format(17), gFormat.format(42), x, c, z, f, flushM960());
          break;
        default:
          writeBlock(gMotionModal.format(101), gFormat.format(40), x, c, z, f, flushM960());
        }
      } else {
        writeBlock(gMotionModal.format(101), x, c, z, f, flushM960());
      }
    }
    return;
  }

  if (isRadialDrillMode()) {
    var mach = toMachineCoords(_x, _y, _z);
    _x = mach.x;
    _z = mach.z;
  }
  var x = xOutput.format(_x);
  var z = zOutput.format(_z);
  if (x || z) {
    if (pendingRadiusCompensation >= 0) {
      var effectiveComp = pendingRadiusCompensation;
      pendingRadiusCompensation = -1;
      var planeCode = gPlaneModal.format(18);
      if (planeCode) {
        writeBlock(planeCode);
      }
      switch (effectiveComp) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(1), gFormat.format(41), x, z, getFeed(feed));
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(1), gFormat.format(42), x, z, getFeed(feed));
        break;
      default:
        writeBlock(gMotionModal.format(1), gFormat.format(40), x, z, getFeed(feed));
      }
    } else {
      writeBlock(gMotionModal.format(1), x, z, getFeed(feed));
    }
  }
}

function onRapid5D(_x, _y, _z, _a, _b, _c) {
  if (machineState.skipSection) { return; }
  if (!machineState.usePolarMode) {
    error(localize("Multi-axis simultaneous toolpath is not supported by the post."));
    return;
  }
  var polar = toPolar(_x, _y);
  var x = xOutput.format(polar.xr);
  var c = cOutput.format(polar.cc);
  var z = zOutput.format(_z);
  if (x || c || z) {
    if (pendingRadiusCompensation >= 0) {
      error(localize("Radius compensation mode cannot be changed at rapid traversal."));
      return;
    }
    writeBlock(gMotionModal.format(0), x, c, z, flushM960());
  }
}

function onLinear5D(_x, _y, _z, _a, _b, _c, feed) {
  if (machineState.skipSection) { return; }
  if (!machineState.usePolarMode) {
    error(localize("Multi-axis simultaneous toolpath is not supported by the post."));
    return;
  }
  flushCoolant();
  var polar = toPolar(_x, _y);
  var x = xOutput.format(polar.xr);
  var c = cOutput.format(polar.cc);
  var z = zOutput.format(_z);
  if (x || c || z) {
    var f = getPolarFeed(feed, polar.xr, x, z, c);
    if (pendingRadiusCompensation >= 0) {
      var effectiveComp = pendingRadiusCompensation;
      pendingRadiusCompensation = -1;
      switch (effectiveComp) {
      case RADIUS_COMPENSATION_LEFT:
        writeBlock(gMotionModal.format(101), gFormat.format(17), gFormat.format(41), x, c, z, f, flushM960());
        break;
      case RADIUS_COMPENSATION_RIGHT:
        writeBlock(gMotionModal.format(101), gFormat.format(17), gFormat.format(42), x, c, z, f, flushM960());
        break;
      default:
        writeBlock(gMotionModal.format(101), gFormat.format(40), x, c, z, f, flushM960());
      }
    } else {
      writeBlock(gMotionModal.format(101), x, c, z, f, flushM960());
    }
  }
}

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (machineState.skipSection) { return; }
  flushCoolant();
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  if (isSpeedFeedSynchronizationActive()) {
    error(localize("Speed-feed synchronization is not supported for circular moves."));
    return;
  }

  if (machineState.usePolarMode) {
    if (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL) {
      if (isHelical()) {
        linearize(tolerance);
        return;
      }
      var start = getCurrentPosition();
      var xrStart = getModulus(start.x, start.y);
      var xrEnd = getModulus(x, y);
      if (Math.abs(xrStart - xrEnd) > spatialFormat.getMinimumValue()) {
        linearize(tolerance);
        return;
      }
      if (isFullCircle() || toDeg(getCircularSweep()) > (180 + 1e-9)) {
        var r = getCircularRadius();
        var sweep = getCircularSweep();
        var rPart = xrStart;
        var cStart = getCClosest(start.x, start.y, cOutput.getCurrent());
        var cCenter = Math.atan2(cy, cx);
        if (cCenter < 0) { cCenter += Math.PI * 2; }
        var dZ = start.z - cz;
        var dC = cStart - cCenter;
        while (dC > Math.PI) { dC -= Math.PI * 2; }
        while (dC < -Math.PI) { dC += Math.PI * 2; }
        var dS = rPart * dC;
        var startAngle = Math.atan2(dS, dZ);
        var midAngle = clockwise ? (startAngle - Math.PI) : (startAngle + Math.PI);
        var midZ = cz + r * Math.cos(midAngle);
        var midCRad = cCenter + r * Math.sin(midAngle) / rPart;
        var midCartX = rPart * Math.cos(midCRad);
        var midCartY = rPart * Math.sin(midCRad);
        var midC = getCClosest(midCartX, midCartY, cOutput.getCurrent());
        cOutput.reset();
        writeBlock(
          gMotionModal.format(clockwise ? 132 : 133),
          zOutput.format(midZ),
          cOutput.format(midC),
          "L" + rFormat.format(r),
          getFeed(feed)
        );
        var endC = getCClosest(x, y, midC);
        cOutput.reset();
        writeBlock(
          gMotionModal.format(clockwise ? 132 : 133),
          zOutput.format(z),
          cOutput.format(endC),
          "L" + rFormat.format(r),
          getFeed(feed)
        );
        return;
      }
      var cc = getCClosest(x, y, cOutput.getCurrent());
      cOutput.reset();
      writeBlock(
        gMotionModal.format(clockwise ? 132 : 133),
        zOutput.format(z),
        cOutput.format(cc),
        "L" + rFormat.format(getCircularRadius()),
        getFeed(feed)
      );
      return;
    }
    var directionCode = clockwise ? 102 : 103;
    var arcStart = getCurrentPosition();
    if (!xFormat.isSignificant(getModulus(arcStart.x, arcStart.y)) || !xFormat.isSignificant(getModulus(x, y))) {
      linearize(tolerance);
      return;
    }
    if (isHelical()) {
      if (!getProperty("optHelicalContour")) {
        linearize(tolerance);
        return;
      }
    }
    if (machineState.feedIsDPM) {
      forceFeed();
      machineState.feedIsDPM = false;
    }
    if (isFullCircle() || toDeg(getCircularSweep()) > (180 + 1e-9)) {
      var start = getCurrentPosition();
      var r = getCircularRadius();
      var sweep = getCircularSweep();
      var startAngle = Math.atan2(start.y - cy, start.x - cx);
      var midAngle = clockwise ? (startAngle - Math.PI) : (startAngle + Math.PI);
      var midX = cx + r * Math.cos(midAngle);
      var midY = cy + r * Math.sin(midAngle);
      var midZ = start.z + (z - start.z) * (Math.PI / sweep);
      var midPolar = toPolar(midX, midY);
      xOutput.reset();
      cOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(midPolar.xr),
        cOutput.format(midPolar.cc),
        zOutput.format(midZ),
        "L" + rFormat.format(r),
        getFeed(feed)
      );
      var endC = getCClosest(x, y, midPolar.cc);
      xOutput.reset();
      cOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(getModulus(x, y)),
        cOutput.format(endC),
        zOutput.format(z),
        "L" + rFormat.format(r),
        getFeed(feed)
      );
      return;
    }
    var polar = toPolar(x, y);
    xOutput.reset();
    cOutput.reset();
    writeBlock(
      gMotionModal.format(directionCode),
      xOutput.format(polar.xr),
      cOutput.format(polar.cc),
      zOutput.format(z),
      "L" + rFormat.format(getCircularRadius()),
      getFeed(feed)
    );
    return;
  }

  if (machineState.useYAxisMode) {
    var start = getCurrentPosition();
    var directionCode = clockwise ? 2 : 3;
    var rotEnd = rotateXY(x, y);
    var rotIJ = rotateXY(cx - start.x, cy - start.y);
    if (isFullCircle()) {
      if (getProperty("useRadius")) { linearize(tolerance); return; }
      switch (getCircularPlane()) {
      case PLANE_XY:
        xMillOutput.reset();
        yOutput.reset();
        writeBlock(gMotionModal.format(directionCode), iOutput.format(rotIJ.x, 0), jOutput.format(rotIJ.y, 0), getFeed(feed), gPlaneModal.format(17));
        break;
      case PLANE_YZ:
        yOutput.reset();
        zOutput.reset();
        writeBlock(gMotionModal.format(directionCode), jOutput.format(rotIJ.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed), gPlaneModal.format(19));
        break;
      default:
        linearize(tolerance);
      }
    } else if (getProperty("useRadius")) {
      var r = getCircularRadius();
      if (toDeg(getCircularSweep()) > (180 + 1e-9)) { linearize(tolerance); return; }
      switch (getCircularPlane()) {
      case PLANE_XY:
        xMillOutput.reset();
        yOutput.reset();
        writeBlock(gMotionModal.format(directionCode), xMillOutput.format(rotEnd.x), yOutput.format(rotEnd.y), zOutput.format(z), "L" + rFormat.format(r), getFeed(feed), gPlaneModal.format(17));
        break;
      case PLANE_YZ:
        yOutput.reset();
        zOutput.reset();
        writeBlock(gMotionModal.format(directionCode), xMillOutput.format(rotEnd.x), yOutput.format(rotEnd.y), zOutput.format(z), "L" + rFormat.format(r), getFeed(feed), gPlaneModal.format(19));
        break;
      default:
        linearize(tolerance);
      }
    } else {
      switch (getCircularPlane()) {
      case PLANE_XY:
        xMillOutput.reset();
        yOutput.reset();
        writeBlock(gMotionModal.format(directionCode), xMillOutput.format(rotEnd.x), yOutput.format(rotEnd.y), zOutput.format(z), iOutput.format(rotIJ.x, 0), jOutput.format(rotIJ.y, 0), getFeed(feed), gPlaneModal.format(17));
        break;
      case PLANE_YZ:
        yOutput.reset();
        zOutput.reset();
        writeBlock(gMotionModal.format(directionCode), xMillOutput.format(rotEnd.x), yOutput.format(rotEnd.y), zOutput.format(z), jOutput.format(rotIJ.y, 0), kOutput.format(cz - start.z, 0), getFeed(feed), gPlaneModal.format(19));
        break;
      default:
        linearize(tolerance);
      }
    }
    return;
  }

  var start = getCurrentPosition();
  var directionCode = clockwise ? 2 : 3;

  if (isHelical()) {
    if (machineState.liveToolIsActive && !getProperty("optHelicalMilling")) {
      linearize(tolerance);
      return;
    }
  }

  if (isFullCircle()) {
    if (getProperty("useRadius")) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_ZX:
      zOutput.reset();
      xOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        iOutput.format(cx - start.x),
        kOutput.format(cz - start.z),
        getFeed(feed),
        gPlaneModal.format(18)
      );
      break;
    case PLANE_XY:
      xOutput.reset();
      yOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        iOutput.format(cx - start.x, 0),
        jOutput.format(cy - start.y, 0),
        getFeed(feed),
        gPlaneModal.format(17)
      );
      break;
    case PLANE_YZ:
      yOutput.reset();
      zOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        jOutput.format(cy - start.y, 0),
        kOutput.format(cz - start.z, 0),
        getFeed(feed),
        gPlaneModal.format(19)
      );
      break;
    default:
      linearize(tolerance);
    }
  } else if (getProperty("useRadius")) {
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      linearize(tolerance);
      return;
    }
    switch (getCircularPlane()) {
    case PLANE_ZX:
      zOutput.reset();
      xOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(x),
        zOutput.format(z),
        "L" + rFormat.format(r),
        getFeed(feed),
        gPlaneModal.format(18)
      );
      break;
    case PLANE_XY:
      xOutput.reset();
      yOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(x),
        yOutput.format(y),
        zOutput.format(z),
        "L" + rFormat.format(r),
        getFeed(feed),
        gPlaneModal.format(17)
      );
      break;
    case PLANE_YZ:
      yOutput.reset();
      zOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(x),
        yOutput.format(y),
        zOutput.format(z),
        "L" + rFormat.format(r),
        getFeed(feed),
        gPlaneModal.format(19)
      );
      break;
    default:
      linearize(tolerance);
    }
  } else {
    switch (getCircularPlane()) {
    case PLANE_ZX:
      zOutput.reset();
      xOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(x),
        zOutput.format(z),
        iOutput.format(cx - start.x),
        kOutput.format(cz - start.z),
        getFeed(feed),
        gPlaneModal.format(18)
      );
      break;
    case PLANE_XY:
      xOutput.reset();
      yOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(x),
        yOutput.format(y),
        zOutput.format(z),
        iOutput.format(cx - start.x, 0),
        jOutput.format(cy - start.y, 0),
        getFeed(feed),
        gPlaneModal.format(17)
      );
      break;
    case PLANE_YZ:
      yOutput.reset();
      zOutput.reset();
      writeBlock(
        gMotionModal.format(directionCode),
        xOutput.format(x),
        yOutput.format(y),
        zOutput.format(z),
        jOutput.format(cy - start.y, 0),
        kOutput.format(cz - start.z, 0),
        getFeed(feed),
        gPlaneModal.format(19)
      );
      break;
    default:
      linearize(tolerance);
    }
  }
}

function onCyclePath() {
  saveShowSequenceNumbers = showSequenceNumbers;
  var verticalPasses;
  if (cycle.profileRoughingCycle == 0) {
    verticalPasses = false;
  } else if (cycle.profileRoughingCycle == 1) {
    verticalPasses = true;
  } else {
    error(localize("Unsupported passes type."));
    return;
  }
  var pendingFM = flushFeedMode();
  if (pendingFM) {
    writeBlock(pendingFM);
  }
  showSequenceNumbers = "none";
  redirectToBuffer();
  feedOutput.reset();
  var cycleId = getCurrentSectionId() + 1;
  writeBlock("NC" + cycleId + " " + (verticalPasses ? "G82" : "G81"));
  gMotionModal.reset();
  xOutput.reset();
  zOutput.reset();
}

function onCyclePathEnd() {
  writeBlock(gFormat.format(80));
  showSequenceNumbers = saveShowSequenceNumbers;
  var cyclePath = String(getRedirectionBuffer()).split(EOL);
  closeRedirection();
  for (line in cyclePath) {
    if (cyclePath[line] == "") {
      cyclePath.splice(line);
    }
  }

  switch (cycleType) {
  case "turning-canned-rough":
    var cycleId = getCurrentSectionId() + 1;
    writeBlock(gFormat.format(85), "NC" + cycleId +
        " D" + spatialFormat.format(cycle.depthOfCut) +
        " U" + xFormat.format(Math.abs(cycle.xStockToLeave)) +
        " W" + spatialFormat.format(Math.abs(cycle.zStockToLeave))
    );
    break;
  default:
    error(localize("Unsupported turning canned cycle."));
  }

  for (var i = 0; i < cyclePath.length; ++i) {
    if (i == 0) {
      writeln(cyclePath[i]);
    } else {
      writeBlock(cyclePath[i]);
    }
  }
}

function writeDrillingCycle(cycleCode, x, z, params) {
  var isLive = machineState.liveToolIsActive;
  var isRadial = isLive && (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL);

  xOutput.reset();
  zOutput.reset();

  if (isLive && getProperty("drillingRetractMode") == "R") {
    var rPos = cycle.retract;
    if (isRadial) {
      rPos = rPos * 2;
    }
    if (rPos == 0) {
      error(localize("Drilling R mode: R=0 causes Okuma alarm 2266. Check cycle heights."));
      return;
    }
    var words = [
      gCycleModal.format(cycleCode),
      "R" + spatialFormat.format(rPos)
    ];
    for (var i = 0; i < params.length; ++i) {
      words.push(params[i]);
    }
    writeBlock.apply(null, words);
  } else {
    if (isRadial) {
      writeBlock(gMotionModal.format(0), xOutput.format(cycle.clearance / 2));
      var rapto = cycle.clearance - cycle.retract;
      var approachLetter = "I";
    } else {
      var rapto = getCurrentPosition().z - cycle.retract;
      var approachLetter = "K";
    }
    var words = [
      gCycleModal.format(cycleCode),
      xOutput.format(x),
      zOutput.format(z),
      conditional(rapto != 0, approachLetter + spatialFormat.format(rapto))
    ];
    for (var i = 0; i < params.length; ++i) {
      words.push(params[i]);
    }
    writeBlock.apply(null, words);
  }
}

function writeSubSpindleGrab() {
  writeBlock(mFormat.format(185), mFormat.format(247), formatComment("L/R INTERLOCK RELEASE"));
  writeBlock(mFormat.format(249), formatComment("SUB CHUCK OPEN"));
  writeBlock(gFormat.format(4), dwellFormat.format(cycle.dwell));
  if (cycle.stopSpindle) {
    writeBlock(mFormat.format(5));
  } else {
    writeBlock(gSpindleModeModal.format(97), sOutput.format(cycle.spindleSpeed), mFormat.format(3));
    writeBlock(mFormat.format(151), formatComment("SYNC SPINDLES"));
  }
  gMotionModal.reset();
  wOutput.reset();
  writeBlock(gMotionModal.format(0), wOutput.format(cycle.feedPosition));
  writeBlock(gFeedModeModal.format(94));
  gMotionModal.reset();
  wOutput.reset();
  writeBlock(gMotionModal.format(1), wOutput.format(cycle.chuckPosition), "F" + feedFormat.format(cycle.feedrate));
  writeBlock(mFormat.format(248), formatComment("SUB CHUCK CLAMP"));
  writeBlock(gFormat.format(4), dwellFormat.format(cycle.dwell));
  machineState.stockTransferIsActive = true;
  machineState.subSpindleChuckPosition = cycle.chuckPosition;
}

function writeSubSpindlePull() {
  if (!machineState.stockTransferIsActive) {
    error(localize("Part must be grabbed before a pull operation."));
    return;
  }
  writeBlock(mFormat.format(84), formatComment("MAIN CHUCK OPEN"));
  writeBlock(gFormat.format(4), dwellFormat.format(cycle.dwell));
  writeBlock(gFeedModeModal.format(94));
  gMotionModal.reset();
  wOutput.reset();
  var pullPosition = machineState.subSpindleChuckPosition + cycle.pullingDistance;
  writeBlock(gMotionModal.format(1), wOutput.format(pullPosition), "F" + feedFormat.format(cycle.feedrate));
  writeBlock(mFormat.format(83), formatComment("MAIN CHUCK CLAMP"));
  writeBlock(gFormat.format(4), dwellFormat.format(cycle.dwell));
}

function writeSubSpindleReturn() {
  if (cycle.unclampMode == "unclamp-primary") {
    writeBlock(mFormat.format(84), formatComment("MAIN CHUCK OPEN"));
  } else if (cycle.unclampMode == "unclamp-secondary") {
    writeBlock(mFormat.format(249), formatComment("SUB CHUCK OPEN"));
  }
  writeBlock(gFormat.format(4), dwellFormat.format(cycle.dwell));
  gMotionModal.reset();
  wOutput.reset();
  writeBlock(gMotionModal.format(0), wOutput.format(cycle.feedPosition));
  writeBlock(mFormat.format(150), formatComment("UNSYNC SPINDLES"));
  writeBlock(mFormat.format(184), mFormat.format(246), formatComment("L/R INTERLOCK ON"));
  machineState.stockTransferIsActive = false;
}

function onCycle() {
  switch (cycleType) {
  case "tool-call":
    gMachiningModeModal.reset();
    writeBlock(gMachiningModeModal.format(270));
    if (isTD()) {
      var pp = getPositionNumber(tool, currentSection);
      writeBlock(formatToolTD(pp, tool.number), mFormat.format(323));
      var ba = getBAxisAngle(tool, currentSection);
      if (ba !== undefined) {
        writeBlock(baOutput.format(ba), gFormat.format(52));
      }
    } else {
      var compensationOffset = tool.compensationOffset;
      if (compensationOffset == 0) {
        compensationOffset = tool.number;
      }
      writeBlock("T" + tool6Format.format(compensationOffset * 10000 + tool.number * 100 + compensationOffset));
    }
    gMotionModal.reset();
    writeRetract(X);
    if (cycle.toolCallPosition !== undefined) {
      zOutput.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(cycle.toolCallPosition));
    }
    writeBlock(mFormat.format(1));
    machineState.toolIsLoaded = false;
    break;
  case "secondary-spindle-grab":
    writeSubSpindleGrab();
    break;
  case "secondary-spindle-pull":
    writeSubSpindlePull();
    break;
  case "secondary-spindle-return":
    writeSubSpindleReturn();
    break;
  }
}

function onCyclePoint(x, y, z) {
  flushCoolant();
  var tol = spatialFormat.getMinimumValue();
  if (!machineState.liveToolIsActive && !machineState.isTurningOperation &&
      (Math.abs(x) > tol || Math.abs(y) > tol)) {
    warning(localize("Dead-tool drilling at off-center position (X=" + spatialFormat.format(x) +
      " Y=" + spatialFormat.format(y) + "). Dead tools can only drill at centerline (X0 Y0)." +
      " Set this tool as a live tool to drill off-center holes. Skipping operation."));
    machineState.skipSection = true;
    return;
  }
  if (isRadialDrillMode()) {
    var mach = toMachineCoords(x, y, z);
    x = mach.x;
    z = mach.z;
  }
  switch (cycleType) {
  case "thread-turning":
    if (skipThreading) {
      return;
    }
    var numberOfThreads = 1;
    if ((hasParameter("operation:doMultipleThreads") && (getParameter("operation:doMultipleThreads") != 0))) {
      numberOfThreads = getParameter("operation:numberOfThreads");
    }
    if (isLastCyclePoint()) {
      var threadHeight = getParameter("operation:threadDepth");
      var firstDepthOfCut = cycle.firstPassDepth ? cycle.firstPassDepth : threadHeight - Math.abs(getCyclePoint(0).x - x);
      var cuttingAngle = 0;
      if (hasParameter("operation:infeedAngle")) {
        cuttingAngle = getParameter("operation:infeedAngle");
      }

      var threadInfeedMode = "constant";
      if (hasParameter("operation:infeedMode")) {
        threadInfeedMode = getParameter("operation:infeedMode");
      }
      var threadCuttingMode = 32;
      var infeedModeCode = 73;
      if (threadInfeedMode == "reduced") {
        threadCuttingMode = 32;
        infeedModeCode = 75;
      } else if (threadInfeedMode == "constant") {
        threadCuttingMode = 32;
        infeedModeCode = 73;
      } else if (threadInfeedMode == "alternate") {
        threadCuttingMode = 33;
        infeedModeCode = 75;
      } else {
        error(localize("Unsupported infeed mode."));
        return;
      }

      gCycleModal.reset();
      xOutput.reset();
      zOutput.reset();
      writeBlock(
        gCycleModal.format(71),
        xOutput.format(x),
        zOutput.format(z),
        cuttingAngle != 0 ? "B" + zFormat.format(cuttingAngle * 2) : "",
        "D" + xFormat.format(firstDepthOfCut),
        "H" + xFormat.format(threadHeight),
        iOutput.format(cycle.incrementalX),
        numberOfThreads > 1 ? "Q" + numberOfThreads : "",
        feedOutput.format(cycle.pitch),
        flushFeedMode(),
        mFormat.format(threadCuttingMode),
        mFormat.format(infeedModeCode)
      );
      skipThreading = (numberOfThreads != 0);
      gMotionModal.reset();
    }
    return;

  case "drilling":
    if (isFirstCyclePoint()) {
      writeDrillingCycle(machineState.liveToolIsActive ? 181 : 74, x, z, [
        "D" + spatialFormat.format(cycle.depth + cycle.retract - cycle.stock),
        getFeed(cycle.feedrate)
      ]);
    }
    break;

  case "counter-boring":
    if (isFirstCyclePoint()) {
      var P = !cycle.dwell ? 0 : cycle.dwell;
      writeDrillingCycle(machineState.liveToolIsActive ? 182 : 74, x, z, [
        "D" + spatialFormat.format(cycle.depth + cycle.retract - cycle.stock),
        P > 0 ? eOutput.format(P) : "",
        getFeed(cycle.feedrate)
      ]);
    }
    break;

  case "deep-drilling":
    if (isFirstCyclePoint()) {
      var P = !cycle.dwell ? 0 : cycle.dwell;
      var deepParams = [
        "D" + spatialFormat.format(cycle.incrementalDepth),
        "L" + spatialFormat.format(cycle.incrementalDepth)
      ];
      if (P > 0) {
        deepParams.push(eOutput.format(P));
      }
      deepParams.push(getFeed(cycle.feedrate));
      writeDrillingCycle(machineState.liveToolIsActive ? 183 : 74, x, z, deepParams);
    }
    break;

  case "chip-breaking":
    if (isFirstCyclePoint()) {
      var P = !cycle.dwell ? 0 : cycle.dwell;
      writeDrillingCycle(machineState.liveToolIsActive ? 183 : 74, x, z, [
        "D" + spatialFormat.format(cycle.incrementalDepth),
        cycle.accumulatedDepth > 0 ? "L" + spatialFormat.format(cycle.accumulatedDepth) : "",
        conditional(P > 0, eOutput.format(P)),
        getFeed(cycle.feedrate)
      ]);
    }
    break;

  case "tapping":
  case "right-tapping":
  case "left-tapping":
    if (isFirstCyclePoint()) {
      var reverseTap = tool.type == TOOL_TAP_LEFT_HAND;
      if (!machineState.liveToolIsActive) {
        if (getProperty("warnSpindleTap")) {
          warning(localize("Tapping with G77/G78 (main spindle float-tap). Feedrate override is locked to 100% during cycle. Disable 'Warn on spindle tapping' to suppress this warning."));
        }
        writeDrillingCycle(reverseTap ? 78 : 77, x, z, [
          getFeed(cycle.feedrate)
        ]);
      } else {
        writeDrillingCycle(reverseTap ? 179 : 178, x, z, [
          getFeed(cycle.feedrate)
        ]);
      }
    }
    break;

  case "tapping-with-chip-breaking":
    if (isFirstCyclePoint()) {
      var reverseTap = tool.type == TOOL_TAP_LEFT_HAND;
      if (!machineState.liveToolIsActive) {
        if (getProperty("warnSpindleTap")) {
          warning(localize("Tapping with G77/G78 (main spindle float-tap). Chip-breaking is not available in this mode. Disable 'Warn on spindle tapping' to suppress this warning."));
        }
        writeDrillingCycle(reverseTap ? 78 : 77, x, z, [
          getFeed(cycle.feedrate)
        ]);
      } else {
        writeDrillingCycle(reverseTap ? 179 : 178, x, z, [
          "L" + spatialFormat.format(cycle.incrementalDepth),
          getFeed(cycle.feedrate)
        ]);
      }
    }
    break;

  case "reaming":
  case "boring":
    if (isFirstCyclePoint()) {
      var P = !cycle.dwell ? 0 : cycle.dwell;
      writeDrillingCycle(machineState.liveToolIsActive ? 189 : 74, x, z, [
        "D" + spatialFormat.format(cycle.depth + cycle.retract - cycle.stock),
        conditional(P > 0, eOutput.format(P)),
        getFeed(cycle.feedrate)
      ]);
    }
    break;

  case "fine-boring":
    if (isFirstCyclePoint()) {
      if (machineState.liveToolIsActive) {
        var P = !cycle.dwell ? 0 : cycle.dwell;
        var isRadialBore = (machineState.machiningDirection == MACHINING_DIRECTION_RADIAL);
        var boreLetter = isRadialBore ? "I" : "K";
        if (isRadialBore) {
          writeBlock(gMotionModal.format(0), xOutput.format(cycle.clearance / 2));
          var rapto = cycle.clearance - cycle.retract;
        } else {
          var rapto = getCurrentPosition().z - cycle.retract;
        }
        var shiftAmount = cycle.shift ? cycle.shift : 0;
        xOutput.reset();
        zOutput.reset();
        gCycleModal.reset();
        writeBlock(
          gCycleModal.format(296),
          xOutput.format(x),
          zOutput.format(z),
          conditional(rapto != 0, boreLetter + spatialFormat.format(rapto)),
          getFeed(cycle.feedrate),
          conditional(shiftAmount > 0, "HS=" + spatialFormat.format(shiftAmount)),
          conditional(P > 0, eOutput.format(P))
        );
      } else {
        expandCyclePoint(x, y, z);
      }
    }
    break;

  case "stop-boring": {
    var P = !cycle.dwell ? 0 : cycle.dwell;
    var stopCode = machineState.liveToolIsActive ? 12 : 5;
    var startCode = machineState.liveToolIsActive ?
      (tool.clockwise ? 13 : 14) : (tool.clockwise ? 3 : 4);
    var isRadialBore = isRadialDrillMode();

    if (!isFirstCyclePoint()) {
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(x));
    }
    if (isRadialBore) {
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(cycle.retract / 2));
      gMotionModal.reset();
      xOutput.reset();
      writeBlock(gMotionModal.format(1), xOutput.format(x), getFeed(cycle.feedrate));
    } else {
      zOutput.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(cycle.retract));
      gMotionModal.reset();
      zOutput.reset();
      writeBlock(gMotionModal.format(1), zOutput.format(z), getFeed(cycle.feedrate));
    }
    if (P > 0) {
      writeBlock(gFormat.format(4), eOutput.format(P));
    }
    writeBlock(mFormat.format(stopCode));
    gMotionModal.reset();
    if (isRadialBore) {
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(cycle.clearance / 2));
    } else {
      zOutput.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(cycle.clearance));
    }
    writeBlock(mFormat.format(startCode));
    machineState.customCycleExpanded = true;
    break;
  }

  case "back-boring": {
    var P = !cycle.dwell ? 0 : cycle.dwell;
    var startCode = machineState.liveToolIsActive ?
      (tool.clockwise ? 13 : 14) : (tool.clockwise ? 3 : 4);
    var stopCode = machineState.liveToolIsActive ? 12 : 19;
    var isRadialBore = isRadialDrillMode();
    var shiftX = x + cycle.shift;

    function writeOrient() {
      if (machineState.liveToolIsActive) {
        writeBlock(mFormat.format(229));
        cOutput.reset();
        writeBlock(gMotionModal.format(0), cOutput.format(0));
      } else {
        writeBlock(mFormat.format(19));
      }
    }

    if (!isFirstCyclePoint()) {
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(x));
    }
    if (isRadialBore) {
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(cycle.clearance / 2));
      writeOrient();
      writeBlock(gMotionModal.format(0), zOutput.format(shiftX));
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(x));
      writeBlock(gMotionModal.format(0), zOutput.format(z));
      writeBlock(mFormat.format(startCode));
      gMotionModal.reset();
      xOutput.reset();
      writeBlock(gMotionModal.format(1), xOutput.format(x + cycle.backBoreDistance), getFeed(cycle.feedrate));
      if (P > 0) {
        writeBlock(gFormat.format(4), eOutput.format(P));
      }
      writeOrient();
      gMotionModal.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(shiftX));
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(cycle.clearance / 2));
      writeBlock(gMotionModal.format(0), xOutput.format(x));
      writeBlock(mFormat.format(startCode));
    } else {
      zOutput.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(cycle.clearance));
      writeOrient();
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(shiftX));
      zOutput.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(z));
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(x));
      writeBlock(mFormat.format(startCode));
      gMotionModal.reset();
      zOutput.reset();
      writeBlock(gMotionModal.format(1), zOutput.format(z + cycle.backBoreDistance), getFeed(cycle.feedrate));
      if (P > 0) {
        writeBlock(gFormat.format(4), eOutput.format(P));
      }
      writeOrient();
      gMotionModal.reset();
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(shiftX));
      zOutput.reset();
      writeBlock(gMotionModal.format(0), zOutput.format(cycle.clearance));
      xOutput.reset();
      writeBlock(gMotionModal.format(0), xOutput.format(x));
      writeBlock(mFormat.format(startCode));
    }
    machineState.customCycleExpanded = true;
    break;
  }

  default:
    expandCyclePoint(x, y, z);
  }
}

function onCycleEnd() {
  if (cycleType == "secondary-spindle-grab" ||
      cycleType == "secondary-spindle-pull" ||
      cycleType == "secondary-spindle-return" ||
      cycleType == "tool-call") {
    return;
  }
  if (!cycleExpanded && !machineState.customCycleExpanded) {
    writeBlock(gCycleModal.format(machineState.liveToolIsActive ? 180 : 80));
    gMotionModal.reset();
  }
  machineState.customCycleExpanded = false;
  skipThreading = false;
}

function onSectionEndSpecialCycle() {
  forceAny();
  gFeedModeModal.reset();
}

function onParameter(name, value) {
  if (name == "action") {
    var upper = String(value).toUpperCase();
    if (upper.indexOf("G272") >= 0) {
      forceYAxisMode = true;
      forceCAxisMode = false;
    } else if (upper.indexOf("G271") >= 0) {
      forceCAxisMode = true;
      forceYAxisMode = false;
    } else if (isTD()) {
      var pMatch = upper.match(/P(\d+)/);
      if (pMatch) {
        var pNum = parseInt(pMatch[1], 10);
        if (pNum >= 13 && pNum <= 20) {
          machineState.manualNCPosition = pNum;
        } else {
          error(localize("Manual NC position override must be P13-P20. Got: P") + pNum);
          return;
        }
      } else {
        error(localize("Invalid Manual NC action for TD machine: must include G271, G272, or P13-P20. Got: ") + value);
        return;
      }
    } else {
      error(localize("Invalid Manual NC action: must include G271 or G272. Got: ") + value);
      return;
    }
    writeComment(value);
  }
}

function onSpindleSpeed(spindleSpeed) {
  if (rpmFormat.areDifferent(spindleSpeed, sOutput.getCurrent()) || forceSpindleSpeed) {
    startSpindle(true);
    forceSpindleSpeed = false;
  }
}

function onCommand(command) {
  switch (command) {
  case COMMAND_COOLANT_OFF:
    setCoolant(COOLANT_OFF);
    break;
  case COMMAND_COOLANT_ON:
    setCoolant(tool.coolant);
    break;
  case COMMAND_STOP:
    writeBlock(mFormat.format(0));
    forceSpindleSpeed = true;
    forceCoolant = true;
    break;
  case COMMAND_OPTIONAL_STOP:
    writeBlock(mFormat.format(1));
    forceSpindleSpeed = true;
    forceCoolant = true;
    break;
  case COMMAND_END:
    writeBlock(mFormat.format(2));
    break;
  case COMMAND_STOP_SPINDLE:
    writeBlock(mFormat.format(machineState.liveToolIsActive ? 12 : 5));
    forceSpindleSpeed = true;
    break;
  case COMMAND_ORIENTATE_SPINDLE:
    if (machineState.liveToolIsActive) {
      writeBlock(mFormat.format(229));
      cOutput.reset();
      writeBlock(gMotionModal.format(0), cOutput.format(0));
    } else {
      writeBlock(mFormat.format(19));
    }
    forceSpindleSpeed = true;
    break;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_SPINDLE_CLOCKWISE:
    writeBlock(mFormat.format(machineState.liveToolIsActive ? 13 : 3));
    break;
  case COMMAND_SPINDLE_COUNTERCLOCKWISE:
    writeBlock(mFormat.format(machineState.liveToolIsActive ? 14 : 4));
    break;
  case COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    writeBlock(mFormat.format(147));
    break;
  case COMMAND_UNLOCK_MULTI_AXIS:
    writeBlock(mFormat.format(146));
    break;
  case COMMAND_BREAK_CONTROL:
    break;
  case COMMAND_TOOL_MEASURE:
    break;
  default:
    onUnsupportedCommand(command);
  }
}

function onPassThrough(text) {
  var commands = String(text).split(",");
  for (text in commands) {
    writeBlock(commands[text]);
  }
}

function onSectionEnd() {
  if (machineState.skipSection) {
    machineState.skipSection = false;
    forceAny();
    return;
  }
  if (machineState.usePolarMode) {
    machineState.usePolarMode = false;
    machineState.feedIsDPM = false;
    gMotionModal.reset();
    gPlaneModal.reset();
    writeBlock(mFormat.format(147));
  }

  if (machineState.slantMachiningActive) {
    writeSlantMachiningOff();
  }

  if (machineState.liveToolIsActive && !machineState.isTurningOperation) {
    writeBlock(mFormat.format(12));
    sbOutput.reset();
    machineState.liveToolIsActive = false;
    forceSpindleSpeed = true;
  }

  // Switch G96→G97 only at tool changes or program end — safe to stay in G96 between same-tool ops
  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    var needG97 = isLastSection();
    if (!needG97) {
      var nextSection = getNextSection();
      var nextTool = nextSection.getTool();
      needG97 = (tool.number != nextTool.number) || (tool.compensationOffset != nextTool.compensationOffset) || (nextSection.spindle != machineState.currentSpindle);
    }
    if (needG97) {
      startSpindle(false);
    }
  }

  machineState.yAxisCAngle = 0;
  forceAny();
  gPlaneModal.reset();
  gFeedModeModal.reset();
  skipThreading = false;
}

function onClose() {
  optionalSection = false;

  onCommand(COMMAND_STOP_SPINDLE);
  setCoolant(COOLANT_OFF);

  writeln("");

  // Retract to home
  gMotionModal.reset();
  writeRetract(X);
  writeRetract(Z);

  // Cancel compensation
  writeBlock(gFormat.format(40));

  writeln("");
  writeBlock(mFormat.format(30));
}

