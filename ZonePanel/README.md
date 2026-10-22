# Zone Panel V8.5 [Pro] — আপডেট করা সংস্করণ

এই ফোল্ডারে দুটো স্ক্রিপ্ট আছে:

| ফাইল | কোথায় রাখবেন |
|---|---|
| `Zone_Panel_V8.5_Server.server.lua` | ServerScriptService (Script) |
| `Zone_Panel_V8.5_Client.client.lua` | StarterPlayerScripts (LocalScript) |

আগের সব DataStore, MemoryStore আর MessagingService-এর নাম আগের মতোই রাখা হয়েছে।
তাই অ্যাডমিন লিস্ট, ব্যান, মিউট, নোট, ওয়ার্নিং, সেটিংস, হিস্টরি — কিছুই রিসেট হবে না।
নতুন যোগ হয়েছে শুধু একটা: `AdminPanelTimeouts_v1` (admin timeout সেভ রাখার জন্য)।

---

## প্রথমে যা করতে হবে

1. **পুরনো Groq API key বাতিল করুন।** আগের স্ক্রিপ্টে key খোলা অবস্থায় ছিল।
   https://console.groq.com/keys থেকে সেই key টা Delete করে দিন। নতুন স্ক্রিপ্টে AI নেই, তাই নতুন key লাগবে না।
2. **নতুন Discord webhook বানান।** পুরনো webhook URL টাও খোলা অবস্থায় ছিল।
   Discord-এ পুরনো webhook Delete করে নতুন একটা বানান। তারপর সার্ভার স্ক্রিপ্টের উপরে `WEBHOOK_URL = ""`-এর ভেতরে পেস্ট করুন।
3. **Voice mute চালাতে হলে:** Game Settings → Communication → **Use Audio API** চালু করুন।
4. Game Settings → Security → **Allow HTTP Requests** চালু থাকতে হবে (webhook-এর জন্য)।
5. Roblox ban (`BanAsync`) শুধু পাবলিশ করা গেমে কাজ করে। Studio-তে কাজ না করলে প্যানেল নিজের সাধারণ ban ব্যবহার করে আর আপনাকে জানিয়ে দেয়।

## সেটিংস (সার্ভার স্ক্রিপ্টের উপরে)

```lua
WEBHOOK_URL = ""                     -- Discord webhook (অ্যাডমিনরা প্যানেল থেকে বদলাতে বা বন্ধ করতে পারবে না)
WEBHOOK_SEND_INTERVAL = 2.5          -- কত সেকেন্ড পর পর webhook পাঠাবে
ANNOUNCE_DISPLAY_SECONDS = 15        -- ঘোষণা স্ক্রিনে কত সেকেন্ড থাকবে (ডিফল্ট)
ANNOUNCE_DISPLAY_MIN_SECONDS = 3     -- প্যানেলের Seconds বক্সে সর্বনিম্ন
ANNOUNCE_DISPLAY_MAX_SECONDS = 120   -- প্যানেলের Seconds বক্সে সর্বোচ্চ
PENDING_WARNING_DELAY_SECONDS = 120  -- অফলাইন ওয়ার্নিং জয়েনের কত সেকেন্ড পরে দেখাবে
BAN_SPAM_LIMIT = 5                   -- কতগুলো ban করলে...
BAN_SPAM_WINDOW_SECONDS = 120        -- ...কত সেকেন্ডের মধ্যে...
BAN_SPAM_TIMEOUT_MINUTES = 30        -- ...কত মিনিটের timeout হবে
ADMIN_TIMEOUT_MAX_MINUTES = 1440     -- timeout সর্বোচ্চ কত মিনিট
```

ক্লায়েন্ট স্ক্রিপ্টের উপরে:

```lua
PANEL_OPEN_KEY = Enum.KeyCode.LeftAlt   -- PC-তে প্যানেল খোলার কী (মোবাইলের বাটন আগের মতো)
```

---

## কী কী বদলানো হয়েছে

### সুরক্ষা
- **গেমের আসল মালিক** (game owner): কেউ কোনো কমান্ড দিয়েই তাকে টার্গেট করতে পারবে না, Owner rank-ও না।
- **Owner rank**: নিচের rank-এর কেউ তাদের উপর কমান্ড চালাতে পারবে না। এক Owner-rank আরেক Owner-rank-এর উপরও পারবে না। শুধু আসল মালিক পারবেন।
- এই নিয়ম সব জায়গায় খাটে: প্যানেল, চ্যাট কমান্ড (`:` / `;`), কমান্ড বার, `all` / `others` / `global`, আর অন্য সার্ভার থেকে পাঠানো কমান্ড।
- প্যানেলের সরাসরি পথেও এখন rank চেক হয়। আগে নিচের rank-এর কেউ remote দিয়ে উপরের rank-এর কমান্ড পাঠাতে পারত।

### নতুন কমান্ড
| কমান্ড | কে পারবে | কাজ |
|---|---|---|
| `usec <player>` / `ultimatesecurity` | Owner | প্লেয়ারকে Ultimate Security দেয়। শুধু Owner-রা তার উপর কমান্ড চালাতে পারবে। সেভ হয় না; সার্ভার ছাড়লে শেষ। নামের পাশে 🛡 দেখায়। |
| `unusec <player>` / `unultimatesecurity` | Owner | Ultimate Security তুলে নেয় |
| `timeout <player> <minutes> <reason>` | Owner | অ্যাডমিনকে timeout দেয়। প্যানেল খুললে শুধু "You are timed out" আর কাউন্টডাউন দেখাবে। কোনো কমান্ড, চ্যাট কমান্ড, admin chat বা সেটিংস কাজ করবে না। সেভ থাকে, তাই rejoin করলে বা অন্য সার্ভারে গেলেও চলতে থাকে। |
| `untimeout <player>` | Owner | timeout তুলে নেয় |
| `vmute <player>` / `voicemute` | Moderator+ | ভয়েস মিউট। কেউ তার কথা শুনবে না, সে অন্যদের শুনতে পাবে। সার্ভার ছাড়লে বা `vunmute` দিলে শেষ। |
| `vunmute <player>` / `voiceunmute` | Moderator+ | ভয়েস আনমিউট |

- Custom rank editor-এ VoiceMute / VoiceUnmute টিক দেওয়ার অপশন আছে। Owner-only কমান্ড (usec, timeout) সেখানে আসে না।
- চ্যাট/কমান্ড বারে `ban <player> <minutes> <reason>`: মিনিট না দিলে স্থায়ী ban।
- `tempmute <player> <minutes> <reason>`: মিনিট হিসেবে নেয়। আগে এটা সেকেন্ড ধরে নিত।

### Ban (hybrid)
- **স্থায়ী ban** (মিনিট খালি) → Roblox-এর অফিশিয়াল ban (`Players:BanAsync`, alt অ্যাকাউন্টসহ)।
- **সময়সীমা দেওয়া ban** → আগের মতো প্যানেলের নিজের ban।
- Ban ট্যাবে দুটোই দেখায়, ধরন লেবেলসহ: `Roblox (Permanent)` বা `Timed (until …)`। যেকোনো জায়গা থেকে Unban দুটোই তুলে দেয়।
- **Ban spam সুরক্ষা**: কোনো অ্যাডমিন ১২০ সেকেন্ডে ৫টা ban করলে তার নিজের ৩০ মিনিটের timeout হয়ে যায়। Owner-দের জানানো হয় আর webhook-এ মেসেজ যায়। Owner-দের উপর এটা খাটে না।

### Webhook
- একটাই `WEBHOOK_URL` সার্ভার স্ক্রিপ্টে থাকে। Settings থেকে webhook অপশন সরানো হয়েছে।
- **প্রতিটা কমান্ড** যায়: কে চালাল, কার উপর, কোন কমান্ড, কারণ বা মান, সময় আর সার্ভার। timeout, usec আর ban spam-ও যায়।
- মেসেজগুলো একটা queue-তে জমা হয়। একসাথে ১০টা পর্যন্ত পাঠায়। Discord rate limit (429) এলে অপেক্ষা করে আবার পাঠায়। সার্ভার বন্ধ হওয়ার আগে বাকিগুলো পাঠিয়ে দেয়।

### ঘোষণা (Announcements)
- ঘোষণা এখন ডিফল্টে ১৫ সেকেন্ড থাকে (`ANNOUNCE_DISPLAY_SECONDS`)। প্যানেলের **Seconds** বক্সে ৩–১২০ সেকেন্ড দেওয়া যায়।
- **This server / Global** বাটন আছে। ডিফল্ট This server। চ্যাট কমান্ড `:announce` আগের মতো Global।
- ঘোষণা, ভোট (প্রশ্ন + দুই অপশন), Admin Abuse Timer-এর নাম আর restart/update মেসেজ এখন Roblox TextService দিয়ে ফিল্টার হয়। ফিল্টার কাজ না করলে মেসেজ যায় না, আর অ্যাডমিন error দেখে।

### কমান্ড বার (`;`)
- সাজেশনে ক্লিক করলে বার আর বন্ধ হয় না বা লেখা মুছে যায় না। বার বন্ধ হয় শুধু Enter (চালানো), Escape বা বারের বাইরে ক্লিক করলে।
- আপনার rank যেগুলো চালাতে পারে সব কমান্ডের সাজেশন আসে। শুরুতে মিললে আগে আসে, মাঝখানে মিললেও আসে।
- প্লেয়ারের Name বা DisplayName-এর যেকোনো অংশ লিখলেই সাজেশন আসে, মাথার ছবিসহ।
- ↑/↓ দিয়ে বাছাই, Tab দিয়ে বসানো, Enter দিয়ে চালানো। ৮টা পর্যন্ত দেখায়, স্ক্রল করা যায়।
- কমান্ড লেখার পর নিচে দেখায় আর কী লিখতে হবে। যেমন: `ban <player> <minutes> <reason>`।

### অন্য পরিবর্তন
- PC-তে প্যানেল খোলে শুধু `PANEL_OPEN_KEY` (ডিফল্ট LeftAlt) দিয়ে। F, E, Insert, RightControl, Home আর RightAlt সরানো হয়েছে।
- **Invisible** এখন মাথার উপরের GUI (BillboardGui/SurfaceGui), Fire/Smoke/Sparkles, লাইট আর নামও লুকায়। যেগুলো চালু ছিল শুধু সেগুলো বন্ধ করে, আর Visible দিলে শুধু সেগুলোই আবার চালু করে।
- **অফলাইন ওয়ার্নিং** জয়েনের ২ মিনিট পরে দেখায়, যাতে লোডিং স্ক্রিনের মধ্যে হারিয়ে না যায়। দেখানোর পরেই মোছা হয়। প্লেয়ার আগে চলে গেলে পরের জয়েনে দেখাবে।
- শুধু ইংরেজি ভাষা রাখা হয়েছে। Language অপশন সরানো হয়েছে।

### বাগ ফিক্স
- প্যানেল খোলা থাকলে প্রতি ফ্রেমে glow আবার আঁকা হতো (অকারণে CPU খরচ)। এখন শুধু খোলা/বন্ধ, থিম বদল বা Glow সেটিং বদলালে চলে।
- সময়সীমা দেওয়া মিউট সার্ভারে রিজয়েন করলে একটা ভুল (`scheduleMuteExpiry` nil) হতো। ঠিক করা হয়েছে।
- ক্লায়েন্টে Disco চালালে error হতো (`ZONE_DISCO_STATE` কোথাও ডিফাইন করা ছিল না)। ঠিক করা হয়েছে।

### সরানো হয়েছে
- Zone AI (AI ট্যাব, API key, Groq/Gemini কল) আর স্বয়ংক্রিয় চ্যাট অনুবাদ
- Coin Adder
- Event সিস্টেম (Taco / Meteor / Fireworks)। Disco আছে।
- BTools / UnBTools (F3X)
- Nickname কমান্ড (HideName / ShowName আছে)

> Staff (admin) chat আগে থেকেই TextService দিয়ে ফিল্টার হতো। সেখানে কোনো পরিবর্তন লাগেনি।
> লাইসেন্স চেক (`require(9428572121)`) যেমন ছিল তেমনই রাখা হয়েছে।

---

## টেস্ট করার তালিকা (পাবলিশ করা সার্ভারে)
- [ ] ২টা অ্যাকাউন্ট দিয়ে: Moderator হয়ে Owner-কে kick/kill/bring করার চেষ্টা করুন। আটকানো উচিত।
- [ ] `usec` দিন, তারপর অন্য অ্যাডমিন দিয়ে কমান্ড চালান। আটকানো উচিত, আর 🛡 দেখা উচিত।
- [ ] `timeout name 2`: প্যানেলে কাউন্টডাউন আসে কিনা, rejoin করলেও থাকে কিনা, আর ২ মিনিট পরে খুলে যায় কিনা।
- [ ] `vmute`: ভয়েস চালু থাকা ২টা অ্যাকাউন্ট লাগবে।
- [ ] মিনিট ছাড়া ban দিলে Roblox ban হয় কিনা (Ban ট্যাবে `Roblox (Permanent)`), আর Unban কাজ করে কিনা।
- [ ] Discord-এ কমান্ডগুলো আসছে কিনা।
