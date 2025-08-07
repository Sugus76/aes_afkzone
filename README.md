# aes_afkzone

This RedM resource, `aes_afkzone`, allows server administrators to create designated "AFK Zones" where players can go idle to receive rewards. The script features a custom UI, invincibility for AFK players, automated blips, and Discord webhook logging.

## Features

* **AFK Zones**: Create multiple polygonal zones on the map where players can enter to start an AFK session.
* **Rewards System**: Players receive configurable rewards (items and quantities) after a set amount of time within a zone.
* **UI Integration**: The script includes a custom user interface that displays a countdown timer and the rewards to be received.
* **Blips**: Configurable map blips are automatically created for each AFK Zone, making them easy for players to find.
* **Player Protection**: While in an active AFK state, the player is made invincible and cannot use weapons. The character is also made semi-transparent.
* **Auto-Deletion of Entities**: The script automatically removes horses and carriages from within an active AFK Zone to prevent them from cluttering the area.
* **Discord Webhook Logging**: All rewards distributed to players are logged to a configurable Discord webhook, providing a record of activity.
* **Commands**: Players can use the in-game commands `/startJob` and `/cancelJob` to begin or end their AFK session.
* **Localization**: The UI and in-game notifications are in Thai, but can be easily translated.

## Core Mechanics

### Zone Management

AFK Zones are defined in `config.lua` using a polygon shape and a vertical range (`minZ` and `maxZ`). The script continuously checks the player's position to detect if they are inside a zone.

### Player Interaction

When a player enters a zone, a "press `R` to start AFK" prompt appears. If they press `R`, the AFK process begins:
* The AFK UI, including a countdown timer, appears.
* The player's character becomes semi-transparent (`Config.PlayerAlpha`).
* The player is made invincible.
* The player is disarmed and blocked from using certain controls.
* A cooldown loop starts, which will trigger a reward when it finishes.

If the player leaves the zone or presses `X` while AFK, the session is cancelled, the UI disappears, and their character returns to normal.

### Reward Distribution

Rewards are defined per zone in `config.lua`. When the timer finishes, a server-side event is triggered. This event uses the `exports.vorp_inventory:addItem` function to give the player the configured items and then logs the transaction to a Discord webhook.

***

## File Structure

* `fxmanifest.lua`: Defines resource metadata, game compatibility, and file locations.
* `config.lua`: Customizable settings for the script, including debug mode, the webhook URL, cooldown timers, player transparency, and the details of each AFK Zone.
* `client/client.lua`: Handles all client-side logic, such as UI rendering, player position checks, blip creation, input handling, and player state management.
* `server/server.lua`: Manages server-side logic for reward distribution and Discord webhook logging.
* `html/`: Contains the UI files:
    * `index.html`: The HTML structure of the UI.
    * `style.css`: The CSS for UI styling and animations.
    * `script.js`: The front-end logic for showing/hiding UI elements, updating the timer, and handling messages from the Lua script.
    * `img/`: Contains images for items displayed in the UI.

***

# aes_afkzone

ทรัพยากร RedM นี้มีชื่อว่า `aes_afkzone` ซึ่งช่วยให้ผู้ดูแลเซิร์ฟเวอร์สามารถสร้าง "โซน AFK" ที่กำหนดไว้ล่วงหน้าเพื่อให้ผู้เล่นที่ไปอยู่นิ่ง ๆ สามารถรับรางวัลได้ สคริปต์นี้มาพร้อมกับ UI ที่กำหนดเอง, การทำให้ผู้เล่น AFK อยู่ยงคงกระพัน, Blip อัตโนมัติ และการบันทึกข้อมูลไปยัง Discord webhook

## คุณสมบัติ

* **AFK Zones**: สร้างโซนรูปทรงหลายเหลี่ยมบนแผนที่หลายโซนเพื่อให้ผู้เล่นเข้าไปเริ่มการ AFK ได้
* **ระบบรางวัล**: ผู้เล่นจะได้รับรางวัลที่กำหนดไว้ (ไอเท็มและจำนวน) หลังจากอยู่ในโซนเป็นระยะเวลาหนึ่ง
* **การรวม UI**: สคริปต์นี้มีอินเทอร์เฟซผู้ใช้ที่กำหนดเองซึ่งแสดงตัวจับเวลาถอยหลังและรางวัลที่จะได้รับ
* **Blip**: Blip บนแผนที่ที่สามารถตั้งค่าได้จะถูกสร้างขึ้นโดยอัตโนมัติสำหรับแต่ละโซน AFK ทำให้ผู้เล่นหาได้ง่าย
* **การป้องกันผู้เล่น**: ขณะที่อยู่ในสถานะ AFK ผู้เล่นจะอยู่ยงคงกระพันและไม่สามารถใช้อาวุธได้ ตัวละครยังถูกทำให้โปร่งแสงเล็กน้อยด้วย
* **การลบสิ่งของอัตโนมัติ**: สคริปต์จะลบม้าและเกวียนออกจากโซน AFK โดยอัตโนมัติเพื่อป้องกันไม่ให้พื้นที่รก
* **การบันทึก Webhook ของ Discord**: รางวัลทั้งหมดที่มอบให้แก่ผู้เล่นจะถูกบันทึกไปยัง Discord webhook ที่กำหนดไว้ เพื่อเป็นบันทึกกิจกรรม
* **คำสั่ง**: ผู้เล่นสามารถใช้คำสั่งในเกม `/startJob` และ `/cancelJob` เพื่อเริ่มหรือยกเลิกเซสชัน AFK ของพวกเขา
* **การแปลภาษา**: UI และการแจ้งเตือนในเกมเป็นภาษาไทย แต่สามารถแปลเป็นภาษาอื่นได้ง่าย

## กลไกหลัก

### การจัดการโซน

โซน AFK ถูกกำหนดไว้ใน `config.lua` โดยใช้รูปร่างหลายเหลี่ยมและช่วงความสูง (`minZ` และ `maxZ`) สคริปต์จะตรวจสอบตำแหน่งของผู้เล่นอย่างต่อเนื่องเพื่อดูว่าพวกเขาอยู่ในโซนหรือไม่

### การโต้ตอบของผู้เล่น

เมื่อผู้เล่นเข้าสู่โซน จะมีข้อความแจ้งให้ "กด `R` เพื่อเริ่ม AFK" ปรากฏขึ้น หากพวกเขากด `R` กระบวนการ AFK จะเริ่มขึ้น:
* UI AFK รวมถึงตัวจับเวลาถอยหลังจะปรากฏขึ้น
* ตัวละครของผู้เล่นจะกลายเป็นโปร่งแสงเล็กน้อย (`Config.PlayerAlpha`)
* ผู้เล่นจะอยู่ยงคงกระพัน
* ผู้เล่นจะถูกปลดอาวุธและถูกบล็อกจากการควบคุมบางอย่าง
* การวนซ้ำการนับถอยหลังจะเริ่มขึ้น ซึ่งจะมอบรางวัลเมื่อเสร็จสิ้น

หากผู้เล่นออกจากโซนหรือกด `X` ขณะที่ AFK เซสชันจะถูกยกเลิก, UI จะหายไป และตัวละครของพวกเขาจะกลับสู่ปกติ

### การแจกจ่ายรางวัล

รางวัลถูกกำหนดไว้สำหรับแต่ละโซนใน `config.lua` เมื่อตัวจับเวลาเสร็จสิ้น อีเวนต์ฝั่งเซิร์ฟเวอร์จะถูกเรียกใช้ อีเวนต์นี้จะใช้ฟังก์ชัน `exports.vorp_inventory:addItem` เพื่อมอบไอเท็มที่กำหนดไว้ให้กับผู้เล่น จากนั้นจะบันทึกธุรกรรมไปยัง Discord webhook

***

## โครงสร้างไฟล์

* `fxmanifest.lua`: กำหนดเมตาดาต้าของสคริปต์, ความเข้ากันได้ของเกม, และตำแหน่งไฟล์
* `config.lua`: การตั้งค่าที่สามารถปรับแต่งได้สำหรับสคริปต์ รวมถึงโหมดดีบัก, URL ของ webhook, ตัวจับเวลา, ความโปร่งใสของผู้เล่น และรายละเอียดของแต่ละโซน AFK
* `client/client.lua`: จัดการตรรกะทั้งหมดฝั่งไคลเอนต์ เช่น การแสดงผล UI, การตรวจสอบตำแหน่งผู้เล่น, การสร้าง blip, การจัดการอินพุต และการจัดการสถานะผู้เล่น
* `server/server.lua`: จัดการตรรกะฝั่งเซิร์ฟเวอร์สำหรับการแจกจ่ายรางวัลและการบันทึก webhook ของ Discord
* `html/`: มีไฟล์สำหรับ UI:
    * `index.html`: โครงสร้าง HTML ของ UI
    * `style.css`: CSS สำหรับการจัดสไตล์และแอนิเมชันของ UI
    * `script.js`: ตรรกะฝั่งฟรอนต์เอนด์สำหรับการแสดง/ซ่อนองค์ประกอบ UI, การอัปเดตตัวจับเวลา และการจัดการข้อความจากสคริปต์ Lua
    * `img/`: มีรูปภาพสำหรับไอเท็มที่แสดงใน UI
