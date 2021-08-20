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


local function start(hint)
   return function()
      hs.application.launchOrFocus(hint)
   end
end


hs.application.enableSpotlightForNameSearches(true)


local keys = {
   { {"ctrl", "alt"},          "H",     movestep(WEST) },
   { {"ctrl", "alt"},          "L",     movestep(EAST) },
   { {"ctrl", "alt"},          "K",     movestep(NORTH) },
   { {"ctrl", "alt"},          "J",     movestep(SOUTH) },

   { {"ctrl", "alt"},          "LEFT",  resizestep(WEST) },
   { {"ctrl", "alt"},          "RIGHT", resizestep(EAST) },
   { {"ctrl", "alt"},          "UP",    resizestep(NORTH) },
   { {"ctrl", "alt"},          "DOWN",  resizestep(SOUTH) },

   { {"ctrl", "alt"},          "G",     center() },

   { {"ctrl", "alt", "shift"}, "H",     teleport(WEST) },
   { {"ctrl", "alt", "shift"}, "L",     teleport(EAST) },
   { {"ctrl", "alt", "shift"}, "K",     teleport(NORTH) },
   { {"ctrl", "alt", "shift"}, "J",     teleport(SOUTH) },

   { {"ctrl", "alt", "shift"}, "LEFT",  snap(WEST) },
   { {"ctrl", "alt", "shift"}, "RIGHT", snap(EAST) },
   { {"ctrl", "alt", "shift"}, "UP",    snap(NORTH) },
   { {"ctrl", "alt", "shift"}, "DOWN",  snap(SOUTH) },

   { {"cmd"},                  "`",     start("Terminal.app") },
}


for _, v in pairs(keys) do
   hs.hotkey.bind(v[1], v[2], v[3], nil, v[3])
end
