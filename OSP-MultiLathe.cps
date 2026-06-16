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
allowHelicalMoves = false;
allowedCircularPlanes = (1 << PLANE_ZX);
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
  type4_Multus: {
    title      : "Type Multus — Multi-tasking",
    description: "Enable if your machine is an Okuma Multus. Uses ATC tool change format (TD command).",
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
    value      : 3500,
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
  optNegativeNoseR: {
    title      : "Negative Nose R",
    description: "Enable if your machine supports negative nose radius compensation.",
    group      : "Options",
    type       : "boolean",
    value      : false,
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
    description: "Enable helical interpolation milling in XYZ. Requires Type Y.",
    group      : "Options",
    type       : "boolean",
    value      : false,
    scope      : "post"
  },
  optHelicalContour: {
    title      : "Helical Contour (X-C-Z)",
    description: "Enable helical contour interpolation in XCZ. Requires Type M.",
    group      : "Options",
    type       : "boolean",
    value      : false,
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
  optYOffCenterTurning: {
    title      : "Y Axis Off Center Turning",
    description: "Enable Y-axis offset turning. Requires Type Y.",
    group      : "Options",
    type       : "boolean",
    value      : false,
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
var fpmFormat = createFormat({decimals:(unit == MM ? 2 : 3), type:FORMAT_REAL});
var fprFormat = createFormat({type:FORMAT_REAL, decimals:(unit == MM ? 3 : 4), minimum:(unit == MM ? 0.001 : 0.0001)});
var pitchFormat = createFormat({decimals:6, type:FORMAT_REAL});
var toolFormat = createFormat({decimals:0, minDigitsLeft:4});
var tool6Format = createFormat({decimals:0, minDigitsLeft:6}); // 6-digit for nose-R comp: RRTTOO
var rpmFormat = createFormat({decimals:0});
var secFormat = createFormat({decimals:2, type:FORMAT_REAL});
var dwellFormat = createFormat({prefix:"F", decimals:2, type:FORMAT_REAL});
var taperFormat = createFormat({decimals:1, scale:DEG});
var integerFormat = createFormat({decimals:0});
var oFormat = createFormat({decimals:0, minDigitsLeft:4});

// output variables
var xOutput = createOutputVariable({prefix:"X"}, xFormat);
var zOutput = createOutputVariable({prefix:"Z"}, zFormat);
var feedOutput = createOutputVariable({prefix:"F"}, feedFormat);
var pitchOutput = createOutputVariable({prefix:"F", control:CONTROL_FORCE}, pitchFormat);
var sOutput = createOutputVariable({prefix:"S", control:CONTROL_FORCE}, rpmFormat);
var maxSpeedOutput = createOutputVariable({prefix:"S", control:CONTROL_FORCE}, rpmFormat);
var eOutput = createOutputVariable({prefix:"E", control:CONTROL_FORCE}, secFormat);

// circular output — Okuma uses I/K for center-point arcs
var iOutput = createOutputVariable({prefix:"I", control:CONTROL_NONZERO}, spatialFormat);
var kOutput = createOutputVariable({prefix:"K", control:CONTROL_NONZERO}, spatialFormat);

// modal groups
var gMotionModal = createOutputVariable({}, gFormat);
var gPlaneModal = createOutputVariable({onchange:function () {gMotionModal.reset();}}, gFormat);
var gFeedModeModal = createOutputVariable({}, gFormat);
var gSpindleModeModal = createOutputVariable({}, gFormat);
var gAbsIncModal = createOutputVariable({}, gFormat);
var gCycleModal = createOutputVariable({}, gFormat);

// state tracking
var sequenceNumber;
var showSequenceNumbers;
var optionalSection = false;
var forceSpindleSpeed = false;
var activeMovements;
var currentFeedId;
var tapping = false;
var previousMaximumSpeed = 0;
var lastSpindleMode = undefined;
var lastSpindleSpeed = 0;
var lastSpindleDirection = undefined;
var forceCoolant = false;
var retracted = false;
var skipThreading = false;

var machineState = {
  isTurningOperation  : undefined,
  liveToolIsActive    : false,
  feedPerRevolution   : undefined,
  currentSpindle      : 0
};

function hasLiveTooling() {
  return getProperty("type1_M") || getProperty("type4_Multus");
}

function hasYAxis() {
  return getProperty("type2_Y") || getProperty("type4_Multus");
}

function hasSubSpindle() {
  return getProperty("type3_W");
}

function isMultus() {
  return getProperty("type4_Multus");
}

function getMaxSpindleSpeed() {
  var prop = (machineState.currentSpindle == 1) ? "maximumSubSpindleSpeed" : "maximumSpindleSpeed";
  return getProperty(prop);
}

function validateMachineConfig() {
  if (getProperty("type2_Y") && !getProperty("type1_M") && !getProperty("type4_Multus")) {
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
  zOutput.reset();
}

function forceFeed() {
  currentFeedId = undefined;
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
  if (activeMovements) {
    var feedContext = activeMovements[movement];
    if (feedContext != undefined) {
      if (!feedFormat.areDifferent(feedContext.feed, feedContext.currentFeed || Number.POSITIVE_INFINITY)) {
        if (feedContext.id == currentFeedId) {
          return "";
        }
      }
    }
    currentFeedId = feedContext != undefined ? feedContext.id : undefined;
  }
  return feedOutput.format(f);
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

    var tools = getToolTable();
    if (tools.getNumberOfTools() > 0) {
      for (var i = 0; i < tools.getNumberOfTools(); ++i) {
        var tool = tools.getTool(i);
        var toolText = "T" + toolFormat.format(tool.number) + " " +
          (tool.diameter != 0 ? "D=" + spatialFormat.format(tool.diameter) + " " : "") +
          (tool.isTurningTool() ? "NR=" + spatialFormat.format(tool.noseRadius) : "CR=" + spatialFormat.format(tool.cornerRadius)) +
          (zRanges[tool.number] ? " - ZMIN=" + spatialFormat.format(zRanges[tool.number].getMinimum()) : "") +
          " - " + getToolTypeName(tool.type);
        writeComment(toolText);
      }
    }
  }

  // Spindle control declaration — must come before any G-code on W-type machines
  if (hasSubSpindle()) {
    writeBlock(gFormat.format(140));
  }
  machineState.currentSpindle = 0;

  // Safe startup
  writeBlock(gAbsIncModal.format(90));
  writeBlock(gPlaneModal.format(18));

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

function onSection() {
  machineState.isTurningOperation = (currentSection.getType() == TYPE_TURNING);
  machineState.liveToolIsActive = false;

  if (!machineState.isTurningOperation) {
    if (!hasLiveTooling()) {
      error(localize("Milling/drilling operations require live tooling. Enable the 'Type M' or 'Type Multus' property."));
      return;
    }
    if (!currentSection.isMultiAxis() && isDrillingCycle()) {
      machineState.liveToolIsActive = true;
    } else {
      warning(localize("Milling operations beyond drilling/tapping are not yet supported. Skipping operation."));
      skipRemainingSection();
      return;
    }
  }

  tapping = isTappingCycle();

  var forceSectionRestart = optionalSection && !currentSection.isOptional();
  optionalSection = currentSection.isOptional();

  var insertToolCall = isToolChangeNeeded("number", "compensationOffset") || forceSectionRestart;

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
    writeBlock(gFormat.format(requestedSpindle == 1 ? 141 : 140));
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

  // Feed mode
  if (insertToolCall) {
    forceModals();
  }
  var feedMode = formatFeedMode(currentSection.feedMode);

  // Turning plane
  writeBlock(gPlaneModal.format(18));
  writeBlock(feedMode);

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

    var compensationOffset = tool.compensationOffset;
    if (compensationOffset == 0) {
      compensationOffset = tool.number;
    }
    var toolCall;
    if (tool.isTurningTool()) {
      toolCall = "T" + tool6Format.format(compensationOffset * 10000 + tool.number * 100 + compensationOffset);
    } else {
      toolCall = "T" + toolFormat.format(tool.number * 100 + compensationOffset);
    }
    writeBlock(toolCall);

    if (tool.comment) {
      writeComment(tool.comment);
    }

    // Turn on coolant
    setCoolant(tool.coolant);
  }

  // Spindle
  var spindleChanged = insertToolCall || forceSpindleSpeed || isSpindleSpeedDifferent();
  if (spindleChanged) {
    forceSpindleSpeed = false;
    startSpindle(false);
  }

  // Position to initial point
  forceAny();
  gMotionModal.reset();

  var initialPosition = getFramePosition(currentSection.getInitialPosition());
  if (insertToolCall || retracted || (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED)) {
    gMotionModal.reset();
    writeBlock(gMotionModal.format(0), zOutput.format(initialPosition.z));
    writeBlock(gMotionModal.format(0), xOutput.format(initialPosition.x));
  }

  // Enable SFM after initial positioning
  if (spindleChanged && tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    startSpindle(true);
  }

  retracted = false;
  activeMovements = undefined;
}

function startSpindle(enableCSS) {
  var spindleDir = mFormat.format(tool.clockwise ? 3 : 4);
  var _spindleSpeed;
  var spindleMode;

  gSpindleModeModal.reset();

  var maximumSpindleSpeed = (tool.maximumSpindleSpeed > 0) ? Math.min(tool.maximumSpindleSpeed, getMaxSpindleSpeed()) : getMaxSpindleSpeed();

  if (tool.getSpindleMode() == SPINDLE_CONSTANT_SURFACE_SPEED) {
    if (enableCSS) {
      _spindleSpeed = tool.surfaceSpeed * ((unit == MM) ? 1 / 1000.0 : 1 / 12.0);
      spindleMode = 96;
    } else {
      // RPM mode for initial positioning — calculate RPM from CSS at initial X
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
      error(localize("Tool " + tool.number + " requests S" + rpmFormat.format(_spindleSpeed) +
        " but max spindle speed is " + rpmFormat.format(maximumSpindleSpeed) +
        ". Reduce the RPM in your operation or increase the max spindle speed property."));
      return;
    }
    spindleMode = 97;
  }

  writeBlock(gSpindleModeModal.format(spindleMode), sOutput.format(_spindleSpeed), spindleDir);

  lastSpindleMode = tool.getSpindleMode();
  lastSpindleSpeed = _spindleSpeed;
  lastSpindleDirection = tool.clockwise;
}

function onDwell(seconds) {
  if (seconds > 9999.99) {
    warning(localize("Dwelling time is out of range."));
  }
  writeBlock(gFormat.format(4), dwellFormat.format(seconds));
}

var pendingRadiusCompensation = -1;

function onRadiusCompensation() {
  pendingRadiusCompensation = radiusCompensation;
}

function onRapid(_x, _y, _z) {
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
  if (isSpeedFeedSynchronizationActive()) {
    // Single-pass threading via G33
    var threadPitch = getParameter("operation:threadPitch");
    var threadsPerInch = 1.0 / threadPitch;
    var startXYZ = getCurrentPosition();
    var deltaX = spatialFormat.getResultingValue(_x - startXYZ.x);
    writeBlock(
      gMotionModal.format(33),
      xOutput.format(_x),
      zOutput.format(_z),
      iOutput.format(deltaX),
      pitchOutput.format(1 / threadsPerInch)
    );
    forceFeed();
    return;
  }

  var x = xOutput.format(_x);
  var z = zOutput.format(_z);
  if (x || z) {
    if (pendingRadiusCompensation >= 0) {
      pendingRadiusCompensation = -1;
      writeBlock(gPlaneModal.format(18));
      switch (radiusCompensation) {
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

function onCircular(clockwise, cx, cy, cz, x, y, z, feed) {
  if (pendingRadiusCompensation >= 0) {
    error(localize("Radius compensation cannot be activated/deactivated for a circular move."));
    return;
  }

  if (isSpeedFeedSynchronizationActive()) {
    error(localize("Speed-feed synchronization is not supported for circular moves."));
    return;
  }

  var start = getCurrentPosition();
  var directionCode = clockwise ? 2 : 3;

  if (isFullCircle()) {
    if (getProperty("useRadius")) {
      linearize(tolerance);
      return;
    }
    zOutput.reset();
    xOutput.reset();
    writeBlock(
      gPlaneModal.format(18),
      gMotionModal.format(directionCode),
      iOutput.format(cx - start.x),
      kOutput.format(cz - start.z),
      getFeed(feed)
    );
  } else if (getProperty("useRadius")) {
    var r = getCircularRadius();
    if (toDeg(getCircularSweep()) > (180 + 1e-9)) {
      linearize(tolerance);
      return;
    }
    zOutput.reset();
    xOutput.reset();
    // Okuma uses L for arc radius (not R like Fanuc)
    writeBlock(
      gPlaneModal.format(18),
      gMotionModal.format(directionCode),
      xOutput.format(x),
      zOutput.format(z),
      "L" + rFormat.format(r),
      getFeed(feed)
    );
  } else {
    // I/K center-point format
    zOutput.reset();
    xOutput.reset();
    writeBlock(
      gPlaneModal.format(18),
      gMotionModal.format(directionCode),
      xOutput.format(x),
      zOutput.format(z),
      iOutput.format(cx - start.x),
      kOutput.format(cz - start.z),
      getFeed(feed)
    );
  }
}

var saveShowSequenceNumbers;

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
  feedOutput.disable();
  showSequenceNumbers = "none";
  redirectToBuffer();
  writeBlock("NAT" + getCurrentSectionId() + " " + (verticalPasses ? "G82" : "G81"));
  gMotionModal.reset();
  xOutput.reset();
  zOutput.reset();
}

function onCyclePathEnd() {
  writeBlock(gFormat.format(80));
  showSequenceNumbers = saveShowSequenceNumbers;
  feedOutput.enable();
  var cyclePath = String(getRedirectionBuffer()).split(EOL);
  closeRedirection();
  for (line in cyclePath) {
    if (cyclePath[line] == "") {
      cyclePath.splice(line);
    }
  }

  switch (cycleType) {
  case "turning-canned-rough":
    writeBlock(gFormat.format(85), "NAT" + getCurrentSectionId() +
        " D" + spatialFormat.format(cycle.depthOfCut) +
        " U" + xFormat.format(Math.abs(cycle.xStockToLeave)) +
        " W" + spatialFormat.format(Math.abs(cycle.zStockToLeave)) +
        " " + getFeed(cycle.cutfeedrate)
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

function onCycle() {
}

function writeDrillingCycle(cycleCode, x, z, params) {
  var rapto = cycle.clearance - cycle.retract;
  xOutput.reset();
  zOutput.reset();
  var words = [
    gCycleModal.format(cycleCode),
    xOutput.format(x),
    zOutput.format(z),
    conditional(rapto != 0, "K" + spatialFormat.format(rapto))
  ];
  for (var i = 0; i < params.length; ++i) {
    words.push(params[i]);
  }
  writeBlock.apply(null, words);
}

function onCyclePoint(x, y, z) {
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
      writeDrillingCycle(machineState.liveToolIsActive ? 183 : 74, x, z, [
        "D" + spatialFormat.format(cycle.incrementalDepth),
        "L" + spatialFormat.format(cycle.incrementalDepth),
        P > 0 ? eOutput.format(P) : "",
        getFeed(cycle.feedrate)
      ]);
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
      if (!machineState.liveToolIsActive) {
        error(localize("Tapping requires a live tool. G77/G78 spindle tapping is float-tap only and is not supported by this post. Use a live tool holder for tapping operations."));
        return;
      }
      var reverseTap = tool.type == TOOL_TAP_LEFT_HAND;
      writeDrillingCycle(reverseTap ? 179 : 178, x, z, [
        "D" + spatialFormat.format(cycle.depth + cycle.retract - cycle.stock),
        getFeed(cycle.feedrate)
      ]);
    }
    break;

  case "tapping-with-chip-breaking":
    if (!machineState.liveToolIsActive) {
      error(localize("Chip-breaking tapping requires a live tool. Spindle tapping is float-tap only and is not supported by this post."));
      return;
    }
    if (isFirstCyclePoint()) {
      var reverseTap = tool.type == TOOL_TAP_LEFT_HAND;
      writeDrillingCycle(reverseTap ? 179 : 178, x, z, [
        "D" + spatialFormat.format(cycle.incrementalDepth),
        "L" + spatialFormat.format(cycle.incrementalDepth),
        getFeed(cycle.feedrate)
      ]);
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

  default:
    expandCyclePoint(x, y, z);
  }
}

function onCycleEnd() {
  if (!cycleExpanded) {
    switch (cycleType) {
    case "drilling":
    case "counter-boring":
    case "deep-drilling":
    case "chip-breaking":
    case "tapping":
    case "right-tapping":
    case "left-tapping":
    case "tapping-with-chip-breaking":
    case "reaming":
    case "boring":
      // G0 cancels canned cycles on Okuma — no explicit G80/G180 needed for hole ops
      gCycleModal.reset();
      break;
    default:
      writeBlock(gCycleModal.format(machineState.liveToolIsActive ? 180 : 80));
      break;
    }
    gMotionModal.reset();
  }
  skipThreading = false;
}

function onParameter(name, value) {
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
    writeBlock(mFormat.format(5));
    forceSpindleSpeed = true;
    break;
  case COMMAND_ORIENTATE_SPINDLE:
    writeBlock(mFormat.format(19));
    forceSpindleSpeed = true;
    break;
  case COMMAND_START_SPINDLE:
    onCommand(tool.clockwise ? COMMAND_SPINDLE_CLOCKWISE : COMMAND_SPINDLE_COUNTERCLOCKWISE);
    return;
  case COMMAND_SPINDLE_CLOCKWISE:
    writeBlock(mFormat.format(3));
    break;
  case COMMAND_SPINDLE_COUNTERCLOCKWISE:
    writeBlock(mFormat.format(4));
    break;
  case COMMAND_ACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_DEACTIVATE_SPEED_FEED_SYNCHRONIZATION:
    break;
  case COMMAND_LOCK_MULTI_AXIS:
    break;
  case COMMAND_UNLOCK_MULTI_AXIS:
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

  forceAny();
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

// coolant support
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

  switch (coolant) {
  case COOLANT_FLOOD:
    m.push(mFormat.format(8));
    break;
  case COOLANT_THROUGH_TOOL:
    m.push(mFormat.format(8));
    break;
  case COOLANT_MIST:
    m.push(mFormat.format(8));
    break;
  default:
    warning(localize("Coolant type not supported, using flood coolant."));
    m.push(mFormat.format(8));
  }

  currentCoolantMode = coolant;
  return m;
}
