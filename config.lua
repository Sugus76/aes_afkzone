Config = {}

-- 🔧 DEBUG MODE
Config.Debug = false -- ✅ แสดง log ใน console สำหรับการตรวจสอบ / Display log in console for auditing

-- 🔧 DISHOOK
Config.WebhookURL = "https://discord.com/api/webhooks/1393324417840316600/G3XcW37H97aYDJDMD5Of3d3gA0qr77fi-0NJWjqZ-3IpOe3OWu6Wfwg6Hw8WXS7jrSo6"

-- ⏳ Cooldown ที่ใช้ร่วมกันทุกโซน (ลดลงเหลือ 30 วินาทีเพื่อทดสอบ) / Cooldown shared across all zones (reduced to 30 seconds for testing)
Config.DefaultCooldown = 1800

-- 🔆 ความใสของตัวละครเมื่อเข้าโซน (0 = มองไม่เห็น, 255 = ปกติ) / Character's transparency when entering the zone (0 = invisible, 255 = normal)
Config.PlayerAlpha = 180

-- ⏳ Cooldown ส่วนตัวหลังได้รับของจาก AFK (วินาที) (ลดลงเหลือ 60 วินาทีเพื่อทดสอบ) / Personal cooldown after receiving an item from AFK (sec) (reduced to 60 seconds for testing)
Config.PersonalCooldown = 60

-- 🔧 ชื่อไอเท็ม / Item name
Config.ItemNames = {
    ammoshotgunnormal = "กระสุนลูกซอง",
    ammoshotgunincendiary = "กระสุนไฟ"
}

-- 📦 โซน AFK ทั้งหมด / All AFK zones
Config.AFKZones = {
    {
        name = "saintdenis_afk",
        label = "Afk Saintdenis",
        center = vector3(2871.86, -1404.49, 60.27),
        points = {
            vector2(2848.119140625, -1366.1293945312),
            vector2(2830.9604492188, -1387.2060546875),
            vector2(2895.3071289062, -1442.5629882812),
            vector2(2911.95703125, -1420.6945800781)
        },
        minZ = 44.335384368896,
        maxZ = 70.00,
        blip = {
            sprite = -211556852,
            scale = 0.8
        },
        reward = {
            items = {
                { item = "ammoshotgunnormal", count = 1 },
                { item = "ammoshotgunincendiary", count = 1 }
            },
            notify = "Received the item from AFK."
        }
    },

    {
        name = "rhodes_afk",
        label = "Afk Rhodes",
        center = vector3(1343.9, -1375.63, 80.48),
        points = {
            vector2(1359.0399169922, -1388.16015625),
            vector2(1362.4105224609, -1369.6535644531),
            vector2(1328.3076171875, -1363.6478271484),
            vector2(1324.3635253906, -1381.8450927734)
        },
        minZ = 79.0,
        maxZ = 90.0,
        blip = {
            sprite = -211556852,
            scale = 0.8
        },
        reward = {
            items = {
                { item = "giftbox_blue", count = 1 },
                { item = "giftbox_green", count = 1 },
                { item = "giftbox_red", count = 1 }
            },
            notify = "Received the item from AFK."
        }
    }
}
