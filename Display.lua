local Util = WarpDeplete.Util

function WarpDeplete:InitDisplay()
  local frameBackgroundAlpha = 0

  self.frames.root.texture = self.frames.root:CreateTexture(nil, "BACKGROUND")
  self.frames.root.texture:SetColorTexture(0, 0, 0, frameBackgroundAlpha)

  -- Deaths text
  self.frames.root.deathsText = self.frames.root:CreateFontString(nil, "ARTWORK")

  -- Timer text
  self.frames.root.timerText = self.frames.root:CreateFontString(nil, "ARTWORK")

  -- Key details text
  local keyDetailsText = self.frames.root:CreateFontString(nil, "ARTWORK")
  self.frames.root.keyDetailsText = keyDetailsText

  local barFrameTexture = self.frames.bars:CreateTexture(nil, "BACKGROUND")
  barFrameTexture:SetColorTexture(0, 0, 0, frameBackgroundAlpha)
  self.frames.bars.texture = barFrameTexture

  -- +3 bar
  local bar3 = self:CreateProgressBar(self.frames.bars)

  local bar3Text = bar3.bar:CreateFontString(nil, "ARTWORK")
  bar3.text = bar3Text
  self.bar3 = bar3

  -- +2 bar
  local bar2 = self:CreateProgressBar(self.frames.bars)
  local bar2Text = bar2.bar:CreateFontString(nil, "ARTWORK")
  bar2.text = bar2Text
  self.bar2 = bar2

  -- +1 bar
  local bar1 = self:CreateProgressBar(self.frames.bars)
  local bar1Text = bar1.bar:CreateFontString(nil, "ARTWORK")
  bar1.text = bar1Text
  self.bar1 = bar1

  -- Forces bar
  local forces = self:CreateProgressBar(self.frames.bars)
  local forcesText = forces.bar:CreateFontString(nil, "ARTWORK")
  forces.text = forcesText

  local forcesOverlayBar = CreateFrame("StatusBar", nil, forces.frame)
  forces.overlayBar = forcesOverlayBar
  self.forces = forces

  -- Objectives
  local objectiveTexts = {}

  for i = 1, 5 do
    local objectiveText = self.frames.root:CreateFontString(nil, "ARTWORK")
    objectiveTexts[i] = objectiveText
  end

  self.frames.root.objectiveTexts = objectiveTexts

  self:UpdateLayout()

  self.frames.root:SetMovable(self.isUnlocked)
  self.frames.root:SetScript("OnMouseDown", function(frame, button)
    if self.isUnlocked and button == "LeftButton" and not frame.isMoving then
      frame:StartMoving()
      frame.isMoving = true
    end
  end)

  self.frames.root:SetScript("OnMouseUp", function(frame, button)
    if button == "LeftButton" and frame.isMoving then
      frame:StopMovingOrSizing()
      frame.isMoving = false

      local frameAnchor, _, _, frameX, frameY = self.frames.root:GetPoint(1)
      self.db.profile.frameAnchor = frameAnchor
      self.db.profile.frameX = frameX
      self.db.profile.frameY = frameY
    end
  end)

  self.frames.root:SetScript("OnHide", function(frame)
    if frame.isMoving then
      frame:StopMovingOrSizing()
      frame.isMoving = false
    end
  end)

  -- Disable mouse for the entire frame
  self.frames.root:EnableMouse(false)
end

function WarpDeplete:CreateProgressBar(frame)
  local result = {}
  local progress = 0

  local barFrame = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  result.frame = barFrame

  local bar = CreateFrame("StatusBar", nil, barFrame)
  bar:SetValue(0)
  bar:SetMinMaxValues(0, 1)
  result.bar = bar

  function result:SetLayout(color, width, height, xOffset, yOffset)
    local r, g, b = Util.hexToRGB(color)

    barFrame:SetSize(width, height)
    barFrame:SetPoint("LEFT", xOffset, yOffset)
    barFrame:SetBackdrop({
      bgFile = WarpDeplete.LSM:Fetch("statusbar", "ElvUI Blank"),
      edgeFile = WarpDeplete.LSM:Fetch("border", "Square Full White"),
      edgeSize = 1,
      insets = { top = 1, right = 1, bottom = 1, left = 1 }
    })
    barFrame:SetBackdropColor(0, 0, 0, 0.5)
    barFrame:SetBackdropBorderColor(0, 0, 0, 1)

    bar:SetPoint("CENTER", 0, 0)
    bar:SetSize(width - 2, height - 2)
    bar:SetStatusBarTexture(WarpDeplete.LSM:Fetch("statusbar", "ElvUI Blank"))
    bar:SetStatusBarColor(r, g, b)
  end

  return result
end

function WarpDeplete:UpdateLayout()
  -- Retrieve values from profile config
  local deathsFontSize = self.db.profile.deathsFontSize
  local timerFontSize = self.db.profile.timerFontSize
  local keyDetailsFontSize = self.db.profile.keyDetailsFontSize
  local objectivesFontSize = self.db.profile.objectivesFontSize

  local bar1FontSize = self.db.profile.bar1FontSize
  local bar2FontSize = self.db.profile.bar2FontSize
  local bar3FontSize = self.db.profile.bar3FontSize
  local forcesFontSize = self.db.profile.forcesFontSize

  local timerBarOffsetX = self.db.profile.timerBarOffsetX
  local timerBarOffsetY = self.db.profile.timerBarOffsetY

  local barFontOffsetX = self.db.profile.barFontOffsetX
  local barFontOffsetY = self.db.profile.barFontOffsetY

  local barWidth = self.db.profile.barWidth
  local barHeight = self.db.profile.barHeight
  local barPadding = self.db.profile.barPadding

  local framePadding = self.db.profile.framePadding
  local barFramePaddingTop = self.db.profile.barFramePaddingTop
  local barFramePaddingBottom = self.db.profile.barFramePaddingBottom

  local verticalOffset = self.db.profile.verticalOffset
  
  local barFrameHeight =
    -- Add max font height for timer bars
    math.max(bar1FontSize, bar2FontSize, bar3FontSize) +
    2 + -- Account for status bar borders
    (barPadding / 2) + -- Account for padding between bars
    forcesFontSize -- Add forces font size

  local frameHeight = deathsFontSize + verticalOffset +
    timerFontSize + verticalOffset +
    keyDetailsFontSize + barFramePaddingTop +
    barFrameHeight + barFramePaddingBottom +
    objectivesFontSize * 5 + verticalOffset * 4 +
    framePadding * 2

  self.frames.root:SetWidth(barWidth + framePadding * 2)
  self.frames.root:SetHeight(frameHeight)
  self.frames.root:SetPoint(
    self.db.profile.frameAnchor,
    self.db.profile.frameX,
    self.db.profile.frameY
  )

  self.frames.root.texture:SetAllPoints(self.frames.root)

  local r, g, b

  local currentOffset = 0 - framePadding

  -- Deaths text
  local deathsText = self.frames.root.deathsText
  deathsText:SetFont(self.LSM:Fetch("font", "Expressway"), deathsFontSize, "OUTLINE")
  deathsText:SetJustifyH("RIGHT")
  deathsText:SetTextColor(1, 1, 1, 1)
  deathsText:SetPoint("TOPRIGHT", -framePadding - 4, currentOffset)

  currentOffset = currentOffset - (deathsFontSize + verticalOffset)

  -- Timer text
  local timerText = self.frames.root.timerText
  timerText:SetFont(self.LSM:Fetch("font", "Expressway"), timerFontSize, "OUTLINE")
  timerText:SetJustifyH("RIGHT")
  timerText:SetTextColor(1, 1, 1, 1)
  timerText:SetPoint("TOPRIGHT", -framePadding, currentOffset)

  currentOffset = currentOffset - (timerFontSize + verticalOffset)

  -- Key details text
  local keyDetailsText = self.frames.root.keyDetailsText
  keyDetailsText:SetFont(self.LSM:Fetch("font", "Expressway"), keyDetailsFontSize, "OUTLINE")
  keyDetailsText:SetJustifyH("RIGHT")
  r, g, b = Util.hexToRGB("#B1B1B1")
  keyDetailsText:SetTextColor(r, g, b, 1)
  keyDetailsText:SetPoint("TOPRIGHT", -framePadding - 3, currentOffset)

  currentOffset = currentOffset - (keyDetailsFontSize + barFramePaddingTop)

  -- Bars frame
  self.frames.bars:SetWidth(barWidth)
  self.frames.bars:SetHeight(barFrameHeight)
  self.frames.bars:SetPoint("TOPRIGHT", -framePadding, currentOffset)

  self.frames.bars.texture:SetAllPoints()

  -- Bars
  local barPixelAdjust = 0.5

  -- +3 bar
  local bar3Width = barWidth / 100 * 60
  self.bar3:SetLayout("#979797", bar3Width, barHeight, 0,
    timerBarOffsetY - barPixelAdjust)
  self.bar3.text:SetFont(self.LSM:Fetch("font", "Expressway"), bar3FontSize, "OUTLINE")
  self.bar3.text:SetJustifyH("RIGHT")
  self.bar3.text:SetTextColor(1, 1, 1, 1)
  self.bar3.text:SetPoint("BOTTOMRIGHT", -barFontOffsetX, barFontOffsetY)

  -- +2 bar
  local bar2Width = barWidth / 100 * 20 - timerBarOffsetX
  self.bar2:SetLayout("#979797", bar2Width, barHeight,
    bar3Width + timerBarOffsetX, timerBarOffsetY - barPixelAdjust)
  self.bar2.text:SetFont(self.LSM:Fetch("font", "Expressway"), bar2FontSize, "OUTLINE")
  self.bar2.text:SetJustifyH("RIGHT")
  self.bar2.text:SetTextColor(1, 1, 1, 1)
  self.bar2.text:SetPoint("BOTTOMRIGHT", -barFontOffsetX, barFontOffsetY)

  -- +1 bar
  local bar1Width = barWidth / 100 * 20 - timerBarOffsetX
  self.bar1:SetLayout("#979797", bar1Width, barHeight,
    bar3Width + bar2Width + timerBarOffsetX * 2, timerBarOffsetY - barPixelAdjust)
  self.bar1.text:SetFont(self.LSM:Fetch("font", "Expressway"), bar1FontSize, "OUTLINE")
  self.bar1.text:SetJustifyH("RIGHT")
  self.bar1.text:SetTextColor(1, 1, 1, 1)
  self.bar1.text:SetPoint("BOTTOMRIGHT", -barFontOffsetX, barFontOffsetY)

  -- Forces bar
  self.forces:SetLayout("#bb9e22", barWidth, barHeight, 0, -timerBarOffsetY)
  self.forces.text:SetFont(self.LSM:Fetch("font", "Expressway"), forcesFontSize, "OUTLINE")
  self.forces.text:SetJustifyH("RIGHT")
  self.forces.text:SetTextColor(1, 1, 1, 1)
  self.forces.text:SetPoint("TOPRIGHT", -barFontOffsetX, -barFontOffsetY)

  r, g, b = Util.hexToRGB("#ff5515")
  self.forces.overlayBar:SetMinMaxValues(0, 1)
  self.forces.overlayBar:SetValue(0)
  self.forces.overlayBar:SetPoint("LEFT", 0, 0)
  self.forces.overlayBar:SetSize(barWidth - 2, barHeight - 2)
  self.forces.overlayBar:SetStatusBarTexture(self.LSM:Fetch("statusbar", "ElvUI Blank"))
  self.forces.overlayBar:SetStatusBarColor(r, g, b, 0.7)

  currentOffset = currentOffset - (barFrameHeight + barFramePaddingBottom)

  -- Objectives
  local objectivesOffset = 4
  for i = 1, 5 do
    local objectiveText = self.frames.root.objectiveTexts[i]
    objectiveText:SetFont(self.LSM:Fetch("font", "Expressway"), objectivesFontSize, "OUTLINE")
    objectiveText:SetJustifyH("RIGHT")
    objectiveText:SetTextColor(1, 1, 1, 1)
    objectiveText:SetPoint("TOPRIGHT", -framePadding, currentOffset)

    currentOffset = currentOffset - (objectivesFontSize + objectivesOffset)
  end
end

-- Expects value in seconds
function WarpDeplete:SetTimerLimit(limit)
  self.timerState.limit = limit
  self.timerState.plusTwo = limit * 0.8
  self.timerState.plusThree = limit * 0.6

  self.timerState.remaining = limit - self.timerState.current
  self:UpdateTimerDisplay()
end

-- Expects value in seconds
function WarpDeplete:SetTimerRemaining(remaining)
  self.timerState.remaining = remaining
  self.timerState.current = self.timerState.limit - remaining
  self:UpdateTimerDisplay()
end

-- Expects value in seconds
function WarpDeplete:SetTimerCurrent(time)
  self.timerState.remaining = self.timerState.limit - time
  self.timerState.current = time
end

function WarpDeplete:UpdateTimerDisplay()
  local percent = self.timerState.current / self.timerState.limit
  local bars = {self.bar1, self.bar2, self.bar3}
  local timeLimits = {self.timerState.limit, self.timerState.plusTwo, self.timerState.plusThree}

  local timerText = Util.formatTime(self.timerState.current) ..
    " / " .. Util.formatTime(self.timerState.limit)

  self.frames.root.timerText:SetText(timerText)

  for i = 1, 3 do
    local timeRemaining = timeLimits[i] - self.timerState.current

    local barValue = Util.getBarPercent(i, percent)
    local timeText = Util.formatTime(math.abs(timeRemaining))

    if i == 1 and timeRemaining < 0 then
      timeText = "|c00FF2A2E-".. timeText .. "|r"
    end

    if i ~= 1 and timeRemaining <= 0 then
      timeText = ""
    end

    bars[i].bar:SetValue(barValue)
    bars[i].text:SetText(timeText)
  end
end

function WarpDeplete:SetForcesTotal(totalCount)
  self.forcesState.totalCount = totalCount
  self.forcesState.pullPercent = self.forcesState.pullCount / totalCount

  local currentPercent = self.forcesState.currentCount / totalCount
  if currentPercent > 1.0 then currentPercent = 1.0 end
  self.forcesState.currentPercent = currentPercent

  self.forcesState.completed = false
  self.forcesState.completedTime = 0
  self:UpdateForcesDisplay()
end

-- Expects direct forces value
function WarpDeplete:SetForcesPull(pullCount)
  self.forcesState.pullCount = pullCount
  self.forcesState.pullPercent = pullCount / self.forcesState.totalCount
  self:UpdateForcesDisplay()
end

-- Expects direct forces value
function WarpDeplete:SetForcesCurrent(currentCount)
  if self.forcesState.currentCount < self.forcesState.totalCount and
    currentCount >= self.forcesState.totalCount
  then
    self.forcesState.completed = true
    self.forcesState.completedTime = self.timerState.current
  end

  self.forcesState.currentCount = currentCount

  local currentPercent = self.forcesState.currentCount / self.forcesState.totalCount
  if currentPercent > 1.0 then currentPercent = 1.0 end
  self.forcesState.currentPercent = currentPercent

  self:UpdateForcesDisplay()
end

function WarpDeplete:UpdateForcesDisplay()
  -- clamp pull progress so that the bar won't exceed 100%
  local pullPercent = self.forcesState.pullPercent
  if self.forcesState.pullPercent + self.forcesState.currentPercent > 1 then
    pullPercent = 1 - self.forcesState.currentPercent
  end

  self.forces.overlayBar:SetValue(pullPercent - 0.005)
  self.forces.overlayBar:SetPoint("LEFT", 1 + self.db.profile.barWidth * self.forcesState.currentPercent, 0)
  self.forces.bar:SetValue(self.forcesState.currentPercent)

  self.forces.text:SetText(
    Util.formatForcesText(
      self.forcesState.pullCount,
      self.forcesState.currentCount,
      self.forcesState.totalCount,
      self.forcesState.completed and self.forcesState.completedTime or nil
    )
  )

  self:UpdatePrideGlow()
end

function WarpDeplete:UpdatePrideGlow()
  local percentBeforePull = self.forcesState.currentPercent
  local currentPrideFraction = (percentBeforePull % 0.2)
  local prideFractionAfterPull = currentPrideFraction + self.forcesState.pullPercent
  local shouldGlow = percentBeforePull < 1.0 and prideFractionAfterPull >= 0.2

  -- Already in the correct state
  if shouldGlow == self.forcesState.prideGlowActive then return end

  self.forcesState.prideGlowActive = shouldGlow
  local glowColor = "#CB091E"

  if shouldGlow then
    local glowR, glowG, glowB = Util.hexToRGB(glowColor)
    self.Glow.PixelGlow_Start(
      self.forces.bar, -- frame
      {glowR, glowG, glowB, 1}, -- color
      16, -- line count
      0.13, -- frequency
      18, -- length
      2, -- thiccness
      1.5, -- x offset
      1.5, -- y offset
      false, -- draw border
      "pride", -- tag
      0 -- draw layer
    )
  else
    self.Glow.PixelGlow_Stop(self.forces.bar, "pride")
  end
end

-- Expect death count as number
function WarpDeplete:SetDeaths(count)
  local deathText = Util.formatDeathText(count)
  self.frames.root.deathsText:SetText(deathText)
end

-- Expects objective list in format {{name: "Boss1", time: nil}, {name: "Boss2", time: 123}}
-- Completion time is nil if not completed, or completion time in seconds from start
function WarpDeplete:SetObjectives(objectives)
  self.objectivesState = objectives
  self:UpdateObjectivesDisplay()
end

function WarpDeplete:UpdateObjectivesDisplay()
  local completionColor = Util.removeHexPrefix("#00FF24")

  -- Clear existing objective list
  for i = 1, 5 do
    self.frames.root.objectiveTexts[i]:SetText("")
  end

  for i, boss in ipairs(self.objectivesState) do
    local objectiveStr = boss.name

    if boss.time ~= nil then
      local completionTimeStr = Util.formatTime(boss.time)
      objectiveStr = "|cFF" .. completionColor .. "[" .. completionTimeStr .. "] " .. objectiveStr .. "|r"
    end

    self.frames.root.objectiveTexts[i]:SetText(objectiveStr)
  end
end

-- Expects level as number and affixes as string array, e.g. {"Tyrannical", "Bolstering"}
function WarpDeplete:SetKeyDetails(level, affixes)
  self.keyDetailsState.level = level
  self.keyDetailsState.affixes = affixes

  self:UpdateKeyDetailsDisplay()
end

function WarpDeplete:UpdateKeyDetailsDisplay()
  local affixesStr = Util.joinStrings(self.keyDetailsState.affixes or {}, " - ")
  local keyDetails = ("[%d] %s"):format(self.keyDetailsState.level, affixesStr)
  self.frames.root.keyDetailsText:SetText(keyDetails)
end