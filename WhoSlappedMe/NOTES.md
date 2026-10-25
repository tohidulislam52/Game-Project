# Who Slapped Me? — Design Notes

A party game for friends: one player sits in the front seat, the players behind vote on who slaps them,
and the front player has to guess who did it.

- The old prototype is kept in [`Original/who_slapped_me_original.rbxmx`](Original/who_slapped_me_original.rbxmx).
- **All in-game text, code and notes are in English** (user request).
- Status markers: ✅ approved · ❓ open question · 💡 proposal waiting for approval

---

## 1. Requirements (from the user) ✅

### R1. Players and seats
- **Minimum 3** players to start. Two players can never play.
- **Maximum 6**: 1 front seat + **5 back seats**. (Changed from 7.)

### R2. Join box and countdown
- No ProximityPrompt. Players join by **standing inside the join box**.
- As soon as someone stands in the box, a **15 second countdown** starts. Others must step in before it ends.
- Several players can stand in the box at the same time.

### R3. Joining a running game
- While the game has free seats, a player from outside can stand in the box and join.
- **Once the game has been full (6 players) even once, joining is closed for the rest of that game.**
  If someone dies after that, nobody can take the free seat. The box shows *"Game in progress — wait for the next game"*.
- A player who was eliminated cannot rejoin the same game (they wait for the next one).

### R4. Lottery: who sits in front
- A lottery runs among all joined players, shown with their **avatar pictures**.
- The winner of the lottery goes to the **front seat** (the one who gets slapped).

### R5. Vote: who slaps
- The slapper is **not** picked at random.
- Every back-seat player gets a **vote UI** with the avatar and name of every back-seat player.
- Players may **vote for themselves**.
- Most votes = slapper. A tie (for example everyone voted for themselves) = random pick among the tied players.

### R6. Seats are locked
- Seated players **cannot get up or jump** out of their seat while the game runs.
- Only the slapper is taken out: **teleported behind the front player**, and after the slap teleported back and seated again.
- **Sit animation**: the user will provide it — leave an empty slot in Config.

### R7. Power mini-game (slapper)
- 3 charges. Each charge is **one single sweep** of the needle (it does not loop forever, so the game is never stalled).
- The bar has zones: **green in the middle, yellow on both sides of it, red on the outside**.
- The player taps when the needle is in the middle. **If they never tap, it auto-taps at the end of the sweep** → lowest power.
- The screen shows **percentages** (e.g. `+20%`, `+30%`, `+40%`), not `1/3, 2/3, 3/3`.
- **Raise-hand animation** plays while the slapper is charging (hand held up). The user will provide it.
- **Slap animation** plays when the slap lands. The user will provide it.

### R8. Front player's view
- The front player is always locked in **first person**.
- The screen is **not black all the time**. It goes **black right before the slapper gets up and teleports behind them**,
  so the front player can never see who is coming.

### R9. Protect mini-game (front player)
- While the screen is black: a ring shrinks toward a circle with a "whoosh" sound. The slap lands exactly when the ring hits the circle.
  The player must press **BLOCK** at that moment. Ring speed is random every time. Only one press counts.
- Result: **PERFECT** = 70% less damage, **GOOD** = 40% less, **MISS** = full damage.
- **PERFECT block bonus:** two back-seat players **who did not slap** get crossed out on the guess screen.
- The front player must be **told this before the game** (rules screen / hint text): "Block perfectly to take less damage and get a clue."

### R10. Damage and health
- Damage depends on slap power, reduced by the block.
- **No automatic healing** for players in the game.
- **Slapped animation** on the front player when the slap lands. The user will provide it.
- **Hit particle effect** at the front player's head/cheek when the hand connects.

### R11. Guess
- After the slap the black screen goes away, and the front player sees the avatars and names of the back-seat players.
  - **Correct:** the slapper moves to the front seat, the front player moves to the slapper's back seat.
  - **Wrong:** nothing changes, the front player stays in front and the next round starts.

### R12. Elimination and winners
- A player whose health reaches **0** is eliminated (knock-out, not a real Roblox death — see D7).
- When **2 players** are left, the game ends and **both win**:
  **1st place = less damage taken**, **2nd place = more damage taken**.
- **Nothing is saved** (no DataStore).

### R13. Leaving must not break the game
- If any player leaves mid-game the game keeps running (see D6 for the exact rules).

---

## 2. Round flow

```
LOBBY      someone stands in the box → 15s countdown → 3+ players → start
  ↓        (6 players in the box → start after 3s)
LOTTERY    avatars spin like a slot machine → one goes to the front seat
  ↓
┌─ ROUND (repeats) ──────────────────────────────────────────────────────┐
│ 0. JOIN      players waiting in the box get a free back seat (R3)          │
│ 1. VOTE      back-seat players vote (10s) → slapper chosen (R5)            │
│ 2. BLACKOUT  front player's screen goes black (R8)                         │
│ 3. MOVE      slapper teleported behind the front player, raise-hand anim   │
│ 4. POWER     slapper does 3 one-sweep charges (R7)                         │
│ 5. PROTECT   ring shrinks, front player presses BLOCK (R9)                 │
│ 6. SLAP      slap anim + slapped anim + particle + sound + damage + 85%!   │
│ 7. RETURN    slapper teleported back and seated → THEN the screen opens    │
│ 8. GUESS     front player picks (15s), clue if PERFECT block (R11)         │
│ 9. REVEAL    wrong guess → replay + "It was X!" (ENABLE_REVEAL)            │
│10. CHECK     health 0 → knocked out. 2 left → game over (R12)              │
└────────────────────────────────────────────────────────────────────────┘
  ↓
WINNERS    1st / 2nd banner → everyone back to the lobby
```

> Step 7 order matters: the slapper must be back in their seat **before** the screen opens,
> otherwise the empty seat gives the answer away.

---

## 3. Design decisions (my proposals, approved by the user) ✅

| # | Decision |
|---|----------|
| D1 | **Power bar (R7):** one sweep left → right per charge, ~1.2s, a little faster each charge. Green = full value of the charge, yellow = half, red = minimum |
| D2 | **Protect (R9):** shrinking ring + whoosh sound. PERFECT/GOOD/MISS windows in Config |
| D3 | When the front player is knocked out → **new lottery** among the players still alive |
| D4 | One player can slap at most `MAX_SLAPS_IN_A_ROW` times in a row (Config, off by default) |
| D5 | Players who don't vote are not counted. Nobody votes → random |
| D6 | **Leaving mid-game:** slapper leaves → vote again · front player leaves → new lottery · other back player leaves → removed from lists, game continues · 2 alive → game over |
| D7 | **Knock-out instead of death:** KO effect, player is moved outside the arena, health restored, auto-heal turned back on |
| D8 | Auto-heal is turned off **only** for players in the game, and restored when they leave |
| D9 | The slapper is **teleported**, never walked, so footsteps can't give them away |
| D10 | Every phase has a timer (vote 10s, each charge one sweep, guess 15s) so an AFK player never stalls the game |
| D11 | Overhead health bar + name for everyone in the game |
| D12 | Sounds: slap (volume/pitch by power), whoosh, heartbeat during blackout, lottery/vote ticks, correct/wrong |
| D13 | Red hand-print decal on the cheek for a few seconds after a slap |
| D14 | Winner banner with avatars on everyone's screen |

---

## 4. More decisions (problems found in review, approved by the user) ✅

| # | Decision |
|---|----------|
| D15 | **Charge values:** the 3 charges are worth up to **30% + 30% + 40% = 100%**. Screen shows what each charge added and the total, e.g. `+30%` → `+15%` → `+40%` = **85% POWER** |
| D16 | **Leave Game button** for seated players (seats are locked). Leaving = eliminated. Resetting the character also counts as leaving |
| D17 | **PERFECT clue never gives the answer away:** at least 2 names always stay. 5 or 4 back → cross out 2 · 3 back → 1 · 2 back → no clue ("No clue with this few players") |
| D18 | **Winner tie** (same damage): fewer slaps taken wins. Still tied → both 1st |
| D19 | Players leave until **1** is left → that player wins alone. **0** left → back to lobby |
| D20 | Chat/voice can't be blocked by code — left as is (bluffing is part of the fun) |
| D21 | All animations must be uploaded by the **same user/group that owns the game**, or they only play in Studio. Empty animation IDs are skipped, the game still works |
| D22 | The slapper is teleported **behind the front player** (no pillar) |
| D23 | **Sudden death, step by step:** from round `SUDDEN_DEATH_ROUND` (12), damage goes up a little **every round** (+10% per round, max ×2). A banner shows "SUDDEN DEATH ×1.3" |
| D24 | **Power shown to everyone:** after the slap a big `85%!` pops up above the front player for back players and spectators |
| D25 | **Spectators** can't walk into the arena during a game (border walls). They stand at the border and watch. Joining a free seat is only possible through the join box (R3) |

---

## 5. Test features (each one has an on/off switch) 🧪

These are kept in **separate modules**, so turning the switch off disables them completely and they can be deleted later without touching the rest of the game.

| Switch in `Config.lua` | Default | What it does |
|------------------------|---------|--------------|
| `ENABLE_REVEAL` | `true` | After a **wrong guess**, everyone sees who really slapped: a short side-camera replay of the slap + "It was **X**!" with their avatar. (On a correct guess the swap already shows it) |
| `ENABLE_RULES_SCREEN` | `true` | Rules cards on first join (lottery, vote, block + clue, guess), and a "?" button to reopen them |
| `ENABLE_TITLES` | `true` | Titles above the head during the game: "Mind Reader" (2 correct guesses in a row), "Iron Cheek" (3 PERFECT blocks), "Silent Slapper" (slapped 2 times without getting caught). Cleared when the game ends |

### Ideas not used
| Idea | Status |
|------|--------|
| Bluff emotes for back players | ❌ Not wanted |

---

## 6. Config (defaults, all in `Config.lua`)

| Name | Default | Purpose |
|------|---------|---------|
| `MIN_PLAYERS` / `MAX_PLAYERS` | `3` / `6` | R1 |
| `JOIN_COUNTDOWN` / `FULL_COUNTDOWN` | `15` / `3` | R2 |
| `MAX_HEALTH` | `100` | |
| `MIN_SLAP_DAMAGE` / `MAX_SLAP_DAMAGE` | `5` / `40` | 0% / 100% power (at least 3 slaps to knock someone out) |
| `CHARGE_VALUES` | `{30, 30, 40}` | D15 |
| `ZONE_YELLOW_MULT` / `ZONE_RED_MULT` | `0.5` / `0.1` | How much of a charge yellow / red gives |
| `SWEEP_TIMES` | `{1.3, 1.1, 0.9}` | Seconds per sweep for each charge |
| `PROTECT_PERFECT` / `PROTECT_GOOD` | `0.7` / `0.4` | Damage reduction |
| `PERFECT_CLUE_COUNT` | `2` | Names crossed out (D17 limit applies) |
| `VOTE_TIME` / `GUESS_TIME` | `10` / `15` | Seconds |
| `MAX_SLAPS_IN_A_ROW` | `0` (off) | D4 |
| `SUDDEN_DEATH_ROUND` / `SUDDEN_DEATH_STEP` / `SUDDEN_DEATH_MAX` | `12` / `0.1` / `2` | D23 |
| `ENABLE_REVEAL` / `ENABLE_RULES_SCREEN` / `ENABLE_TITLES` | `true` | Section 5 |
| `ANIM_SIT` / `ANIM_RAISE_HAND` / `ANIM_SLAP` / `ANIM_SLAPPED` | `""` | Empty — user provides the IDs |
| `SOUNDS` | table | D12 |

## 7. Performance and security rules (everything is built this way)

| # | Rule |
|---|------|
| P1 | **The server decides everything:** who can vote, the vote result, the slapper, damage, whether the guess is right. Clients only send "which button I pressed" |
| P2 | Mini-games: the client sends only where the needle stopped / when BLOCK was pressed. The server turns that into damage with its own formula, clamps it, and rejects impossible timing |
| P3 | The slapper's identity is **never** sent to the front player's client before the reveal, so an exploiter reading remotes learns nothing. The clue list is built on the server |
| P4 | Join box uses a cheap position check every 0.25s, not `Touched` |
| P5 | No `while true do wait()` polling. The game is a state machine; each phase waits on a signal with a timeout |
| P6 | All effects (blackout, shake, ring, particles, sounds) run on the client. Particles and sounds are reused, not created each slap |
| P7 | Avatar pictures are fetched once per player and cached |
| P8 | Every remote: type checks, rate limit, and rejected when it's not that player's phase |
| P9 | All per-player connections are stored together and disconnected on leave — no memory leaks |
| P10 | Seat lock: jumping disabled and seat welds controlled by the server; restored when the player leaves |
| P11 | Layout like `BTToolsEvents`: `Config.lua`, separate ModuleScripts, one `Release/WhoSlappedMe.rbxmx` to insert in Studio |

---

## 8. Review of the old prototype

What the old file does: a ProximityPrompt joins up to 7 players. A random back player slaps with a looping power bar,
and the front player guesses. Correct guess = swap seats.

| # | Problem in the old file | Fixed by |
|---|------------------------|----------|
| B1 | The slapper played the animation from their own back seat, 8-14 studs away — the hand never touched anyone | R6 teleport |
| B2 | The animation ID must be owned by the game owner, otherwise it doesn't play in the live game | D21 |
| B3 | A round could start with 2 players → only one guess button, always correct | R1 |
| B4 | Anyone leaving cancelled the whole round and closed everyone's UI | D6 |
| B5 | Damage value was chosen by the client (an exploiter could always send max) | P1, P2 |
| B6 | Default health regen undid all damage; "strikes" were counted but never used | R10, D8 |
| B7 | Guess buttons showed the username, not the display name, and no avatar | R11 |
| B8 | No sounds, no hit effect, no hand-print | D12, D13, R10 |
| B9 | Waiting loop polled every 0.1s using one global table | P5 |
| B10 | UI template stored in Workspace (replicated to everyone for nothing) | P11 |
| B11 | Seats were not locked, players could jump out; seat swaps sometimes snapped onto the wrong seat | R6, P10 |
| B12 | Power bar looped forever until the player tapped | R7 |
| B13 | Camera shake did nothing when the camera wasn't locked; status text never hid | Rebuild |

---

## 9. Open questions ❓

| # | Question | My proposal |
|---|----------|-------------|
| Q1 | **Join box size and place.** The old `JoinPart` is 4×5×4 studs — too small for 6 people | A flat **12×12 pad** just outside the front border, glowing outline, countdown sign above it |
| Q2 | **Seat layout for 5 back seats.** Old layout was 2 rows of 3 | **One curved row of 5** behind the front seat, so every back player has the same distance and view |
| Q3 | **Sounds.** I can't check which Roblox sound IDs work in your game | Empty slots in `Config.SOUNDS` that you fill in; the game works silently until then |
| Q4 | **Map.** Rebuild with the old arena layout (floor, borders), or will you build your own map? | Rebuild the old layout. Code finds seats/box **by name**, so you can move or redesign parts freely later |
| Q5 | **Spectator board** (health of every player outside the arena) | Not needed — spectators watch from the border (D25). Overhead health bars (D11) are enough |

