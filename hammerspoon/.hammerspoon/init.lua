local function move(x, y)
   return function()
      local win = hs.window.focusedWindow()
      local f = win:frame()
      f.x = f.x + x
      f.y = f.y + y
      win:setFrame(f)
   end
end


local function resize(w, h)
   return function()
      local win = hs.window.focusedWindow()
      local f = win:frame()
      f.w = f.w + w
      f.h = f.h + h
      win:setFrame(f)
   end
end


local keys = {
   -- move
   { {"cmd", "shift"},         "H",      move(-40,   0) },
   { {"cmd", "shift"},         "J",      move(  0,  40) },
   { {"cmd", "shift"},         "K",      move(  0, -40) },
   { {"cmd", "shift"},         "L",      move( 40,   0) },

   -- resize
   { {"cmd", "ctrl", "shift"}, "H",      resize(-40,   0) },
   { {"cmd", "ctrl", "shift"}, "J",      resize(  0,  40) },
   { {"cmd", "ctrl", "shift"}, "K",      resize(  0, -40) },
   { {"cmd", "ctrl", "shift"}, "L",      resize( 40,   0) },
}


for _, v in pairs(keys) do
   hs.hotkey.bind(v[1], v[2], v[3], nil, v[3])
end
