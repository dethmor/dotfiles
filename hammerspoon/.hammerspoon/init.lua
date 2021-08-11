WEST  = 1 << 0
EAST  = 1 << 1
NORTH = 1 << 2
SOUTH = 1 << 3


local function movestep(f)
   return function()
      local win = hs.window.focusedWindow()
      local frm = win:frame()
      local px = 50
      if (f == WEST)  then frm.x = frm.x - px end
      if (f == EAST)  then frm.x = frm.x + px end
      if (f == NORTH) then frm.y = frm.y - px end
      if (f == SOUTH) then frm.y = frm.y + px end
      win:setFrame(frm)
   end
end


local function resizestep(f)
   return function()
      local win = hs.window.focusedWindow()
      local frm = win:frame()
      local px = 50
      if (f == WEST)  then frm.w = frm.w - px end
      if (f == EAST)  then frm.w = frm.w + px end
      if (f == NORTH) then frm.h = frm.h - px end
      if (f == SOUTH) then frm.h = frm.h + px end
      win:setFrame(frm)
   end
end


local function center()
   return function()
      hs.window.focusedWindow():centerOnScreen()
   end
end


local function teleport(f)
   return function()
      local win = hs.window.focusedWindow()
      local frm = win:frame()
      local scr = win:screen():frame()
      if (f == WEST)  then frm.x = 0 end
      if (f == EAST)  then frm.x = scr.w - frm.w end
      if (f == NORTH) then frm.y = 0 end
      if (f == SOUTH) then frm.y = scr.h - frm.h end
      print(f)
      win:setFrame(frm)
   end
end


local function snap(f)
   return function()
      local win = hs.window.focusedWindow()
      local frm = win:frame()
      local scr = win:screen():frame()
      if (f == WEST) then
         frm.x = 0
         frm.y = 0
         frm.w = scr.w * 0.5
         frm.h = scr.h
      end
      if (f == EAST) then
         frm.x = scr.w * 0.5
         frm.y = 0
         frm.w = scr.w * 0.5
         frm.h = scr.h
      end
      if (f == NORTH) then
         frm.x = 0
         frm.y = 0
         frm.w = scr.w
         frm.h = scr.h * 0.5
      end
      if (f == SOUTH) then
         frm.x = 0
         frm.y = scr.h * 0.5
         frm.w = scr.w
         frm.h = scr.h * 0.5
      end
      win:setFrame(frm)
   end
end

local function run(app)
   return function()
      hs.application.open(app)
   end
end

hs.application.enableSpotlightForNameSearches(true)


local keys = {
   { {"cmd", "shift"},         "H",      movestep(WEST) },
   { {"cmd", "shift"},         "L",      movestep(EAST) },
   { {"cmd", "shift"},         "K",      movestep(NORTH) },
   { {"cmd", "shift"},         "J",      movestep(SOUTH) },

   { {"cmd", "shift", "ctrl"}, "H",      resizestep(WEST) },
   { {"cmd", "shift", "ctrl"}, "L",      resizestep(EAST) },
   { {"cmd", "shift", "ctrl"}, "K",      resizestep(NORTH) },
   { {"cmd", "shift", "ctrl"}, "J",      resizestep(SOUTH) },

   { {"cmd", "shift"},         "G",      center() },

   { {"cmd", "shift"},         "Y",      teleport(WEST) },
   { {"cmd", "shift"},         "U",      teleport(EAST) },
   { {"cmd", "shift"},         "M",      teleport(NORTH) },
   { {"cmd", "shift"},         "N",      teleport(SOUTH) },

   { {"cmd", "shift", "ctrl"}, "Y",      snap(WEST) },
   { {"cmd", "shift", "ctrl"}, "U",      snap(EAST) },
   { {"cmd", "shift", "ctrl"}, "M",      snap(NORTH) },
   { {"cmd", "shift", "ctrl"}, "N",      snap(SOUTH) },

   { {"cmd", "shift"},         "Return", run("Terminal.app") },
}


for _, v in pairs(keys) do
   hs.hotkey.bind(v[1], v[2], v[3], nil, v[3])
end
