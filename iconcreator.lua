--[[
															Icon Convertor/Remover
															======================

		This program leverages the free program 'Inkscape' for converting SVG files to PNG files. Installation is slightly more complex
		on OSX in that you have to install XQuartz then Inkscape. Note, when Inkscape starts it will ask where 'X11' is - currently it is
		in Utilities and is actually called XQuartz. Note also when it starts it may take a minute or so to start first time, when nothing
		actually seems to be happening. Windows has a typical windows installer, Linux is distro-dependent.

		Note this will not work unless you modify the applicationCommand below so it works - the examples are untested. If you have a
		working one please let me know.

		This is not a Corona application, so you need the command line lua from http://luabinaries.sourceforge.net
		Inkscape is at http://www.inkscape.org, XQuartz at http://xquartz.macosforge.org (Mac OSX only)
		
		Written by Paul Robson April 2014 (paul@robsons.org.uk)

		Information should be checked against http://docs.coronalabs.com/guide/distribution/buildSettings/index.html

		July 2014 changes:

			1) Validates iOS icon list against build.settings list, check they are the same.
			2) Generates the default launch images from launch.svg, centred in the appropriate size.

--]]

-- 	Standard Stub OOP create as a global.
_G.Base =  _G.Base or { new = function(s) local o = {} setmetatable(o,s) s.__index = s o:initialise() return o end, initialise = function() end }

--
--	Helper Class to convert SVG to PNG, uses Inkscape - but can be modified to use anything you wish.
--
SVGConverter = Base:new()

function SVGConverter:initialise()
	--
	--	This is for Mac OSX. 
	--
	self.applicationCommand = "/Applications/Inkscape.app/Contents/Resources/bin/inkscape"
	-- something like this for Windows : self.applicationCommand = "C:\\Program Files\\Inkscape\\bin\\inkscape.exe"
	-- something like this for Linux : /usr/bin/inkscape
end

function SVGConverter:createIcon(svgFilename,iconFilename,iconSize)
	local cmd = ("%s %s -e %s -w %d -h %d"):format(self.applicationCommand,svgFilename,iconFilename,iconSize,iconSize)
	local handle = assert(io.popen(cmd, 'r'))
	local output = handle:read('*all')
	handle:close()
end

---
---		Helper Class to add a border, uses ImageMagick
---	

BorderModifier = Base:new()

function BorderModifier:initialise() 
	--
	--	This is for Mac OSX.
	--
	self.applicationCommand = "convert"
end 

function BorderModifier:addBorder(pngFilename,borderWidth,borderHeight)
	local cmd = self.applicationCommand .. " " .. pngFilename .. " -bordercolor Black -border "..borderWidth.."x"..borderHeight.." "..pngFilename
	local handle = assert(io.popen(cmd, 'r'))
	local output = handle:read('*all')
	handle:close()
end 

---
---		ImageBuilder Class
---

AbstractImageBuilder = Base:new()

function AbstractImageBuilder:create()
	local cv = SVGConverter:new()
	local bm = BorderModifier:new()

	for iconName,iconSize in pairs(self:getIconList()) do 
		cv:createIcon("icon.svg",iconName,iconSize)
	end
	for iconName,iconSize in pairs(self:getLaunchImageList()) do 
		local squareSize = math.min(iconSize[1],iconSize[2])
		cv:createIcon("launch.svg",iconName,squareSize)
		bm:addBorder(iconName,(iconSize[1]-squareSize)/2,(iconSize[2]-squareSize)/2)
	end
end

function AbstractImageBuilder:delete()
	for iconName,_ in pairs(self:getIconList()) do 
		os.remove(iconName)
	end
	for iconName,_ in pairs(self:getLaunchImageList()) do 
		os.remove(iconName)
	end
end

---
---		Concrete Icon Builder Class for Android Devices
---
AndroidImageBuilder = AbstractImageBuilder:new()

function AndroidImageBuilder:getIconList()
	local iconList = {}
	-- Currently 5 icons are required.
	iconList["Icon-hdpi.png"] = 72
	iconList["Icon-mdpi.png"] = 48 
	iconList["Icon-ldpi.png"] = 36 
	iconList["Icon-xhdpi.png"] = 96 
	iconList["Icon-xxhdpi.png"] = 144
	return iconList
end

function AndroidImageBuilder:getLaunchImageList()
	local imageList = {}
	imageList["Default.png"] = { 320,480 }
	imageList["Default@2x.png"] = { 640,960 }
	imageList["Default-Portrait.png"] = { 768,1024 }
	imageList["Default-Landscape.png"] = { 1024,768 }
	return imageList
end 

---
---		Concrete Icon Builder Class for Apple Devices
---

AppleImageBuilder = AbstractImageBuilder:new()

function AppleImageBuilder:getIconList()
	local iconList = {}
	-- Currently 17 icons are required.

	iconList["Icon.png"] = 57 
	iconList["Icon@2x.png"] = 114
	iconList["Icon-60.png"] = 60 
	iconList["Icon-60@2x.png"] = 120

	iconList["Icon-60@3x.png"] = 180
	iconList["Icon-72.png"] = 72
	iconList["Icon-72@2x.png"] = 144
	iconList["Icon-76.png"] = 76 

	iconList["Icon-76@2x.png"] = 152
	iconList["Icon-Small-40.png"] = 40 
	iconList["Icon-Small-40@2x.png"] = 80
	iconList["Icon-Small-40@3x.png"] = 120

	iconList["Icon-Small-50.png"] = 50 
	iconList["Icon-Small-50@2x.png"] = 100
	iconList["Icon-Small.png"] = 29 
	iconList["Icon-Small@2x.png"] = 58

	iconList["Icon-Small@3x.png"] = 87

	dofile("build.settings")
	local r = settings
	assert(r ~= nil,"No build.settings")
	assert(r.iphone ~= nil and r.iphone.plist ~= nil,"No iphone.plist")
	local itable = r.iphone.plist.CFBundleIconFiles
	assert(itable ~= nil,"No CFBundleIconFiles")
	for _,icon in ipairs(itable) do 
		assert(iconList[icon] ~= nil,"Icon "..icon.." not generated")
	end
	local count = 0
	for _,_ in pairs(iconList) do count = count + 1 end 
	assert(count == #itable,"Different numbers of icons.")

	return iconList
end

function AppleImageBuilder:getLaunchImageList()
	local imageList = {}
	imageList["Default.png"] = { 320,480 }
	imageList["Default@2x.png"] = { 640,960 }
	imageList["Default-568h@2x.png"] = { 640,1136 }
	imageList["Default-Portrait.png"] = { 768,1024 }
	imageList["Default-Portrait@2x.png"] = { 1536,2048 }
	imageList["Default-Landscape.png"] = { 1024,768 }
	imageList["Default-Landscape@2x.png"] = { 2048,1536 }
	return imageList
end 

---
---		Main program
--- 

if #arg == 0 then
	print("Corona icon creator by Paul Robson (paul@robsons.org.uk)")
	print("  	Command line options -d (delete) -a (android) -i (iDevice/Apple) ")
	return
end

local builderList = {}
local deleteFlag = false

for _,a in ipairs(arg) do
	a = a:lower()
	if a == '-d' then deleteFlag = true
	elseif a == '-i' then builderList[#builderList+1] = AppleImageBuilder:new()
	elseif a == '-a' then builderList[#builderList+1] = AndroidImageBuilder:new()
	else print("Unknown command line option "..a)
	end
end

for _,builder in ipairs(builderList) do
	if deleteFlag then 	builder:delete()
	else 				builder:create()
	end
end

