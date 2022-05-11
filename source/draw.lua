import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'constants'

local gfx = playdate.graphics

local initMargin = 8
local margin = 6
local cellLength = 32


--row,col are 0-indexed!
local function drawBlankCell(row, col, letter) 
    local rOffset = initMargin + (margin + cellLength) * row
    local cOffset = initMargin + (margin + cellLength) * col
    gfx.setColor( gfx.kColorBlack )
    gfx.drawRoundRect(cOffset,rOffset,cellLength,cellLength,3)
    if letter ~= "" then
        gfx.drawTextAligned(letter, (cOffset + cellLength/2), rOffset + (cellLength/4), kTextAlignment.center)
    end
end

--row,col are 0-indexed!
local function drawInvertedCell(row, col, letter) 
  drawBlankCell(row, col, letter)
  local rOffset = initMargin + (margin + cellLength) * row + 1
  local cOffset = initMargin + (margin + cellLength) * col + 1
  gfx.setColor( gfx.kColorXOR )
  gfx.fillRect(cOffset,rOffset,cellLength-2,cellLength-2)
  gfx.setColor( gfx.kColorBlack )
end

--row,col are 0-indexed!
local function drawPatternedCell(row, col, letter) 
  local rOffset = initMargin + (margin + cellLength) * row
  local cOffset = initMargin + (margin + cellLength) * col
  gfx.setColor( gfx.kColorBlack )
  gfx.drawRect(cOffset,rOffset,cellLength,cellLength)
  gfx.setPattern(kMaybePattern)
  gfx.fillRect(cOffset + 1,rOffset + 1,cellLength - 2,cellLength - 2)
 
  --clear the middle of the pattern to make letter readable
  gfx.setColor( gfx.kColorWhite )
  local lw,lh = gfx.getTextSize(letter)
  local maskX = cOffset + cellLength/2 - lw/2 - 1
  local maskY = rOffset + cellLength/2 - lh/2
  --Log(letter, maskX, maskY, lw, lh)
  gfx.fillRect(maskX, maskY, lw + 2, lh)

  gfx.setColor( gfx.kColorBlack )
  if letter ~= "" then
      gfx.drawTextAligned(letter, (cOffset + cellLength/2), rOffset + (cellLength/4), kTextAlignment.center)
  end
end

local drawFnTable = {
        [kSample.unknown] = drawBlankCell,
		[kSample.maybe] = drawPatternedCell,
		[kSample.right] = drawInvertedCell,
	}

function DrawDemo()
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0,0,400,240)

    drawFnTable[kSample.unknown](0,0,"A")
    drawFnTable[kSample.unknown](0,1,"B")
    drawFnTable[kSample.unknown](0,2,"C")
    drawFnTable[kSample.unknown](0,3,"D")
    drawFnTable[kSample.unknown](0,4,"E")

    drawFnTable[kSample.maybe](1,0,"1")
    drawFnTable[kSample.maybe](1,1,"2")
    drawFnTable[kSample.maybe](1,2,"3")
    drawFnTable[kSample.maybe](1,3,"4")
    drawFnTable[kSample.maybe](1,4,"5")

    drawFnTable[kSample.right](2,0,"Ⓐ")
    drawFnTable[kSample.right](2,1,"Ⓑ")
    drawFnTable[kSample.right](2,2,"A")
    drawFnTable[kSample.right](2,3,"_A_")
    drawFnTable[kSample.right](2,4,"*A*")

end
