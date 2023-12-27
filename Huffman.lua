local gd = require("gd")

local imageHeight = 1080
local imageWidth = 1920


local img = gd.create(imageWidth,imageHeight)


io.write("please provide an input file\n")

local inputFileName = io.read()

local inputFile = io.open(inputFileName)

if inputFile == nil then 
	io.write("couldn't find file "..inputFileName.."\n")
	os.exit()
end

local symbols = {}

while true do
	local currentSymbol = inputFile:read(1)
	if currentSymbol == nil then break end
	local alreadyEntered = false
	for i = 1,#symbols do 
		if symbols[i].symbol == currentSymbol then
			symbols[i].frequency = symbols[i].frequency + 1
			alreadyEntered = true
			break
		end
	end
	if not alreadyEntered then 
		table.insert(symbols, {symbol = currentSymbol , frequency = 1})
	end
end


table.sort(symbols, function (a,b) return a.frequency > b.frequency end)


repeat
	local leftChar = symbols[#symbols]
	local rightChar = symbols[#symbols - 1]
	local merged = {
		frequency = leftChar.frequency + rightChar.frequency,
		leftChild = leftChar,
		rightChild = rightChar
	}
	table.remove(symbols,#symbols)
	table.remove(symbols,#symbols)
	table.insert(symbols,merged)
	table.sort(symbols, function (a,b) return a.frequency > b.frequency end)
until #symbols == 1

local root = symbols[1]

function generatePrefixCodes() 
	local codes = {}
	function generatePrefixCodeHelper(node,currentCode)
		if node.symbol ~= nil then
			table.insert(codes, {symbol = tostring(string.byte(node.symbol)), code = currentCode})
			return
		end
		generatePrefixCodeHelper(node.rightChild, currentCode .."1")
		generatePrefixCodeHelper(node.leftChild, currentCode .."0")
	end
	generatePrefixCodeHelper(root,"")
	table.sort(codes, function (a,b) return #a.code < #b.code end)
	return codes
end

local codes = generatePrefixCodes()


local prefixCodeFile = io.open( inputFileName.."_prefixes.txt","w+")

print("Symbol\tcode")
for i = 1, #codes do
	print(codes[i].symbol .. "\t" .. codes[i].code)
	prefixCodeFile:write(codes[i].symbol.. "\t" .. codes[i].code.."\n")
end

io.close(prefixCodeFile)

inputFile:seek("set",0)

local outputFile = io.open(inputFileName.."_compressed.txt","w+")

function getCodeFromSymbol(symbol)
	for i = 1,#codes do
		if codes[i].symbol == symbol then 
			return codes[i].code
		end
	end
end

while true do
	local symbol = inputFile:read(1)
	if symbol == nil then break end
	outputFile:write(getCodeFromSymbol(tostring(string.byte(symbol))));
end

--drawing the huffman tree

local white = img:colorAllocate(255, 255, 255)
local black = img:colorAllocate(0, 0, 0)

local red = img:colorAllocate(255,0,0)
local green = img:colorAllocate(0,255,0)


function drawTree()
	function drawTreeHelper(node,x,y,size,color,depth)
		img:filledEllipse(x,y,size,size,color)
		img:string(gd.FONT_MEDIUM , x-10 , y-20, tostring(node.frequency),black) 
		if node.symbol ~= nil then
			img:string(gd.FONT_MEDIUM , x , y, node.symbol,black)
			return
		end
	
		local dx_factor = 5/depth 
        	local dx = (size) * dx_factor
		drawTreeHelper(node.rightChild, x+dx, y+85, size*0.80, green, depth+1)
		img:line(x,y,x+dx,y+80, green);
		drawTreeHelper(node.leftChild, x-dx, y+85, size*0.80, red, depth+1)
		img:line(x,y,x-dx,y+80, red);
	end
	drawTreeHelper(root,imageWidth/2, 100, 75 , black,1)
end


img:filledRectangle(0,0 , imageWidth, imageHeight, white)

drawTree()

io.close(inputFile)
img:png(inputFileName.."output.png")
