local codes = {}

print("please provide the prefix code file")

local prefixFileName = io.read()

local prefixFile = io.open(prefixFileName,"r")

if prefixFile == nil then 
	io.write("couldn't find file "..prefixFileName.."\n")
	os.exit()
end

while true do
	local line = prefixFile:read()
	if line == nil then break end
	local symbolAndCode = {}
	for substring in line:gmatch("[^\t]+") do 
		table.insert(symbolAndCode, substring)
	end
	table.insert(codes,{symbol = symbolAndCode[1], code = symbolAndCode[2]});
end

io.close(prefixFile)

for i = 1, #codes do
	codes[i].symbol = string.char(tonumber(codes[i].symbol))
end



print("please provide the compressed file")

local fileName = io.read()

local file = io.open(fileName,"r")

if file == nil then 
	io.write("couldn't find file "..fileName.."\n")
	os.exit()
end


function getSymbolFromCode(code)
	for i = 1,#codes do
		if codes[i].code == code then 
			return codes[i].symbol
		end
	end
	return nil
end


local decompressed = io.open("decompressed.txt","w");

function decodeCompressedFile(file, codes)
    local encodedString = file:read("*a") 
    local decodedString = ""
    local currentCode = ""

    for i = 1, #encodedString do
        currentCode = currentCode .. encodedString:sub(i, i)
        local symbol = getSymbolFromCode(currentCode)
        if symbol then
            decodedString = decodedString .. symbol
            currentCode = ""
        end
    end

    return decodedString
end

local decodedString = decodeCompressedFile(file, codes)

decompressed:write(decodedString)
io.close(decompressed)
io.close(file)
