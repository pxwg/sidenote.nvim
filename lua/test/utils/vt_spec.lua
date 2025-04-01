local assert = require("luassert")
local vt = require("uitls.vt")

describe("vt.wrap_text_to_fit_width", function()
  it("should correctly wrap Chinese text with specified width", function()
    local max_display_width = 134
    local text =
      "上士闻道，勤而行之；中士闻道，若存若亡；下士闻道，大笑之，不笑不足以为道。上士闻道，勤而行之；中士闻道，若存若亡；下士闻道，大笑之，不笑不足以为道。上士闻道，勤而行之；中士闻道，若存若亡；下士闻道，大笑之，不笑不足以为道"
    local expected_output = {
      "上士闻道，勤而行之；中士闻道，若存若亡；下士闻道，大笑之，不笑不足以为道。上士闻道，勤而行之；中士闻道，若存若亡；下士闻道，大笑之，不",
      "笑不足以为道。上士闻道，勤而行之；中士闻道，若存若亡；下士闻道，大笑之，不笑不足以为道",
    }

    local result = vt.wrap_text_to_fit_width(text, max_display_width)

    -- Test length matches
    assert.equals(#expected_output, #result)

    -- Test content of each line
    for i, line in ipairs(expected_output) do
      assert.equals(line, result[i])
    end
  end)

  it("should correctly wrap complex text with symbols and emojis", function()
    local max_display_width = 134
    local text =
      [[Hello世界！今󠄂天是2023-π/2≈5.15的奇妙日期🌍！在α坐标系中，用户@张三_Dev需要将€50转换为¥或$，同时计算∑(n²)从n=1到∞。Ω公司发布的📱App 2.0支持≤5Gbps传输，但需注意⚠️：温度阈值应保持25°C±3%！代码段if (x != y) { cout << "错误❌"; } 包含中文注释//这里要处理ASCII码32~126。数学公式∮E·da = Q/ε₀展示∇·E=ρ/ε₀的微分形式。购物清单📋：🍎×6（$4.99）、📘×3（¥59.8/本），总价≈$4.99×6 + 59.8×3 = $29.94 + ￥179.4。音乐播放列表🎵：《最伟大的作品》- 周杰倫（Jay Chou） feat. 郎朗，码率320kbps@48kHz。地址示例：北京市海淀区#36号院©2023，地图坐标39°54'27"N 116°23'17"E。特殊符号测试：★☆☯☢☣♬♔♛⚡🔥💻✅🔍🛑🚫⚖️🔄📶📡🔑🔓💡❗❓‼️⁉️➡️⬅️↙️↗️🔀🔁🔂⏩⏪⏫⏬🎦🔅🔆🕒🕘🕧🔢🔣🔤🅰️🆎🆑🆘🆚]]

    local expected_output = {
      [[Hello世界！今󠄂天是2023-π/2≈5.15的奇妙日期🌍！在α坐标系中，用户@张三_Dev需要将€50转换为¥或$，同时计算∑(n²)从n=1到∞。Ω公司发布的📱App ]],
      [[2.0支持≤5Gbps传输，但需注意⚠️：温度阈值应保持25°C±3%！代码段if (x != y) { cout << "错误❌"; } 包含中文注释//这里要处理ASCII码32~126。]],
      [[数学公式∮E·da = Q/ε₀展示∇·E=ρ/ε₀的微分形式。购物清单📋：🍎×6（$4.99）、📘×3（¥59.8/本），总价≈$4.99×6 + 59.8×3 = $29.94 + ]],
      [[￥179.4。音乐播放列表🎵：《最伟大的作品》- 周杰倫（Jay Chou） feat. 郎朗，码率320kbps@48kHz。地址示例：北京市海淀区#36号院©2023，地图]],
      [[坐标39°54'27"N 116°23'17"E。特殊符号测试：★☆☯☢☣♬♔♛⚡🔥💻✅🔍🛑🚫⚖️🔄📶📡🔑🔓💡❗❓‼️⁉️➡️⬅️↙️↗️🔀🔁🔂⏩⏪⏫⏬🎦🔅🔆🕒🕘🕧🔢🔣🔤🅰️🆎🆑🆘]],
      [[🆚]],
    }

    local result = vt.wrap_text_to_fit_width(text, max_display_width)

    -- Test length matches
    assert.equals(#expected_output, #result)

    -- Test content of each line
    for i, line in ipairs(expected_output) do
      assert.equals(line, result[i])
    end
  end)
end)
