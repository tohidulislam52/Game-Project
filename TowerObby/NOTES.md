# Tower Obby — Design Notes

A Roblox tower obby. First milestone: the **complete UI and the shop system**.

- **Nothing gets built until the user says "এখন বানাও" (build it now).** Until then this file only collects notes.
- The user's own UI kit is kept in [`Original/ui_kit.rbxmx`](Original/ui_kit.rbxmx). **All UI we build must use this kit**: its button images, frame images and button animations.
- Status markers: ✅ approved · ❓ open question · 💡 proposal waiting for approval

---

## 1. Requirements (from the user)

_None yet — the user is still sharing ideas._

---

## 2. UI kit study (`Original/ui_kit.rbxmx`)

### 2.1 Structure

```
UI_Pack (ScreenGui, ZIndexBehavior = Sibling, ResetOnSpawn = true)
├── PreloadButtonAssets (LocalScript)   preloads every image + sound with ContentProvider:PreloadAsync
├── MegaPack (Frame, full screen)       the catalog: every button and frame once
│   ├── 20 square icon buttons          (ImageButton, Size {0.0565,0},{0.1266,0})
│   ├── 21 wide label buttons           (ImageButton, Size {0.1243,0},{0.1266,0})
│   └── Frame1 … Frame5                 (ImageLabel panels, Size {0.1412,0},{0.2848,0})
└── ShowCase (Frame, full screen)       a demo layout: 3 big frames + buttons, each with a coloured UIShadow glow
```

Each ImageButton contains:
- `ButtonIconScript` (LocalScript): the hover/click/idle animation (see 2.3).
- `Decal`: its Texture is the button's particle image. A Decal does not draw in a GUI; it only keeps the asset referenced.

### 2.2 How the art works
- **All buttons and frames are images.** The label text ("Shop", "Rebirth" …) is baked into the image. To show dynamic text (prices, counts, item names) we must place our own `TextLabel` on top.
- Images have a transparent background (`BackgroundTransparency = 1`).
- Frames use `ScaleType = Stretch` with no 9-slice, so they distort if stretched to a different shape → keep their shape with `UIAspectRatioConstraint`.
- Sizes are scale-only and the kit has **no `UIAspectRatioConstraint`**, so square icons stop being square on wide or tall screens → add one when we use them.
- ShowCase glow: `UIShadow` (BlurRadius 20, Transparency 0.5–0.8, ShowBehindParent) in white, blue `(0,170,255)`, red `(255,0,0)`, orange `(255,85,0)` or purple `(85,0,255)`. Some glows have a `UIGradient` (black→white→black colour, transparent at one end).

### 2.3 The 5 animation styles

All styles share: a `UIScale` for scaling, `HoverSound` + `ClickSound` + `IdleSound` created in the button, an idle "breathing" pulse every ~6–10 s, and `Activated` for clicks (so they work on touch and gamepad too). Sound IDs: hover/idle `136108770017536`, click `122835655736085`.

| Style | Used by | Hover | Click | Idle |
|---|---|---|---|---|
| **A Burst** | square icons (Shop, Rebirth, Gem's, Settings, Pets, Codes, Back, Forward, Delete, Correct, Plus, Minus, Money, Super Gem's) | scale 1.055 + "magnet": button follows the mouse up to 6 px (RenderStepped, exp smoothing) | scale 0.90 → 1.09 → 1.04 → back (spring), 12 particles of the icon's image fly out in a ring (0.5 s) | 1.018 → 0.995 → 1 |
| **B Burst + Tilt** | square "premium" icons (Robux, Gift, WheelSpin, Trade, Luck, Mouse) | scale 1.07, magnet 8 px + tilt 3° | scale 0.875, 14-particle burst + 5-particle micro burst, staggered | same pulse, softer |
| **C Bubble** | wide labels (Shop, Rebirth, Gem's, Codes, Pets, Settings, Inventory, Bag Pack, Money, Back, Forward, Delete, Correct) | TweenService: scale 1.04, lift 2 px, tilt −0.4°, 3 bubbles rise | scale 0.93, push down 2 px, 12 bubbles rise from the bottom edge, then spring back | scale 1.01 + lift 1 px, slow sine |
| **D Premium Bubble** | wide premium labels (Robux, WheelSpin, Gift, Trade, Luck) | scale 1.045 + 3–5 bubbles | scale 0.91, three waves of bubbles (5 + 7 + 4), bigger lift (4 px); `AnimationGeneration` cancels stale tweens | random small bubble groups |
| **E Ripple** | Update Log, What's Added | white glow outline (UIStroke) fades in, one ring | 3 white rings expand **from the click point** + 12 white streak particles | faint ring + scale 1.012 pulse |

Each particle/bubble image is a small version of the button's icon (column "Effect particle image" below).

### 2.4 Things to fix when we build with the kit (no changes made yet)
1. **59 copies of 480–1040 line scripts.** Changing one value means editing every copy. 💡 Turn the 5 styles into **one `ButtonFX` ModuleScript** with presets (`"Burst"`, `"BurstTilt"`, `"Bubble"`, `"PremiumBubble"`, `"Ripple"`), applied to every button by a tag or attribute. Same look, one place to tune it.
2. Styles A and B each open a **`RenderStepped` connection per button** that is never disconnected (a closed menu keeps running it). The module should run one loop only for buttons currently hovered, and disconnect on destroy.
3. **Idle sound on every button every 6–10 s.** With 8–10 HUD buttons on screen that is a sound almost every second. ❓ Keep the idle sound, or keep only the visual pulse?
4. The `while` idle loop keeps running while the button is hidden (`Visible = false`). It should skip hidden buttons.
5. Hover effects need a mouse; on phones only the click animation shows (fine, just noted).

### 2.5 Every element in the kit (MegaPack)

| Name | Type | Image ID | Animation style | Effect particle image |
|---|---|---|---|---|
| Rebirth | Square icon | 115325120904186 | A Burst | 73663005164552 |
| Shop | Square icon | 79189567200992 | A Burst | 135804309692238 |
| Mouse | Square icon | 120918127409954 | B Burst+Tilt | 96160646700358 |
| Robux | Square icon | 131198923284739 | B Burst+Tilt | 134734003678221 |
| Forward | Square icon | 71765598424688 | A Burst | 82816180109392 |
| Back | Square icon | 80495145019472 | A Burst | 94575482748360 |
| Gem's | Square icon | 78249669263695 | A Burst | 92628551554815 |
| Code's | Square icon | 74993576301387 | A Burst | 73552063953074 |
| Delete | Square icon | 104731637166575 | A Burst | 85924614506626 |
| Gift | Square icon | 82293274582736 | B Burst+Tilt | 74034821318674 |
| Setting's | Square icon | 79312800758069 | A Burst | 114371893357657 |
| Pet's | Square icon | 110467625627559 | A Burst | 119884033550057 |
| Money | Square icon | 134033317054407 | A Burst | 103442007980360 |
| Correct | Square icon | 116455359000189 | A Burst | 106427777463441 |
| Super Gem's | Square icon | 78098471983751 | A Burst | 85387955042762 |
| Plus | Square icon | 70751880810147 | A Burst | 117887290906009 |
| Minus | Square icon | 118462228948753 | A Burst | 126185390548906 |
| WheelSpin | Square icon | 108607068483395 | B Burst+Tilt | 133449971610824 |
| Trade | Square icon | 135952953888549 | B Burst+Tilt | 74315143119360 |
| Luck | Square icon | 134443950151679 | B Burst+Tilt | 98051473530755 |
| Back | Wide label | 133321613198850 | C Bubble | 120624533933389 |
| Delete | Wide label | 126199909421060 | C Bubble | 125736259123294 |
| Correct | Wide label | 137652172839461 | C Bubble | 90381660940146 |
| Forward | Wide label | 73460904721476 | C Bubble | 91896537853337 |
| Inventory | Wide label | 119963621120331 | C Bubble | 123615211721249 |
| Bag Pack | Wide label | 130843686712036 | C Bubble | 123615211721249 |
| Robux | Wide label | 75730579249181 | D Premium Bubble | 111618439943749 |
| WheelSpin | Wide label | 126091452202940 | D Premium Bubble | 121657620859761 |
| Gift | Wide label | 91995081088792 | D Premium Bubble | 82245534076245 |
| Trade | Wide label | 86221260122283 | D Premium Bubble | 134746970554349 |
| Money | Wide label | 101558165672828 | C Bubble | 101093482235249 |
| Luck | Wide label | 71185215827539 | D Premium Bubble | 111082385422912 |
| Rebirth | Wide label | 122271314890881 | C Bubble | 110011178140123 |
| Shop | Wide label | 95705000553415 | C Bubble | 120415133302584 |
| Gem's | Wide label | 129479735876075 | C Bubble | 81274757853826 |
| Super Gem's | Wide label | 108708296046837 | C Bubble | 101434410779846 |
| Code's | Wide label | 108468478600761 | C Bubble | 74110488072850 |
| Pet's | Wide label | 111647672177103 | C Bubble | 128616077930951 |
| Setting's | Wide label | 89960202252554 | C Bubble | 110028519824090 |
| Update Log | Wide label | 80211059329972 | E Ripple | - |
| What's Added | Wide label | 140023089743613 | E Ripple | - |
| Frame4 | Frame panel | 85710516229772 | - | - |
| Frame3 | Frame panel | 88163224055084 | - | - |
| Frame2 | Frame panel | 76886101386757 | - | - |
| Frame1 | Frame panel | 123725587383568 | - | - |
| Frame5 | Frame panel | 133725841617476 | - | - |

Note: I can read IDs, sizes and scripts from the file, but **I cannot see the images themselves**. ❓ A screenshot of MegaPack and ShowCase in Studio would tell me what each frame looks like (colour, where its title bar and close button sit, where text fits).
