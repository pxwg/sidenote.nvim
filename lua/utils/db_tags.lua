local bm = require("utils.bookmark")
local M = {}

math.randomseed(os.time() + os.clock() * 1000000 + tonumber(tostring({}):sub(8)))
---
--- Generate a timestamp tag
--- @return number? timestamp tag
function M.generateTimestampTag()
  local date = os.date("*t")
  local random_number = math.random(10, 99)
  local out = string.format(
    "%02d%02d%02d%02d%02d%02d%02d",
    date.year % 100,
    date.hour,
    date.sec,
    date.min,
    random_number,
    date.month,
    date.day
  )
  print(tonumber(string.sub(out, 1, 9)))
  return tonumber(string.sub(out, 1, 9))
end

return M
