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
│ 6. SLAP      slap anim + slapped anim + particle + sound + damage (R10)    │
│ 7. RETURN    slapper teleported back and seated → THEN the screen opens    │
│ 8. GUESS     front player picks (15s), clue if PERFECT block (R11)         │
│ 9. REVEAL    everyone sees who it was                                      │
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

## 4. Problems still left in the design ❓

| # | Problem | Proposal |
|---|---------|----------|
| Q1 | **What does "20% / 30% / 40%" mean?** | Proposal: the three charges are worth up to **30% + 30% + 40% = 100%** (later charges are harder and worth more). Screen shows what each charge added and the total, e.g. `+30%` → `+15%` → `+40%` = **85% POWER** |
| Q2 | **Seats are locked (R6), so how does a player leave on purpose?** Right now the only way would be leaving Roblox | A **Leave Game** button. Leaving = eliminated. Resetting the character also counts as leaving |
| Q3 | **PERFECT clue with few players.** Crossing out 2 names when only 2 or 3 players sit in the back gives the answer away | Always keep **at least 2 names** on the screen: 5 back → cross out 2, 4 back → 2, 3 back → 1, 2 back → no clue (show "No clue with this few players") |
| Q4 | **Winner tie:** both players have the same damage | Tie-breaker: fewer slaps taken wins. Still tied → both are 1st |
| Q5 | **Players leave until only 1 is left** (or 0) | 1 left → that player is the only winner. 0 left → reset to lobby |
| Q6 | **Text/voice chat** can tell the front player who slapped. Code can't fully stop it | Leave it — lying in chat is part of the fun (bluffing). Optional: hide chat bubbles in the arena |
| Q7 | **Animations must be owned by the game owner** (same user or group). Otherwise they only play in Studio | User uploads all 4 animations (sit, raise-hand, slap, slapped) from the account/group that owns the game |
| Q8 | **"Pillar":** the map has no pillar | Assumed **behind the front player**. Tell me if a pillar should be added |
| Q9 | **6-player games can be long.** Only the front player takes damage, and wrong guesses keep them there | Proposal I3 (sudden death) below |

---

## 5. New ideas 💡 (waiting for approval)

| # | Idea |
|---|------|
| I1 | **Reveal replay:** after the guess, everyone sees a short side-camera shot of the slap with "It was **X**!" — the funniest moment of the round |
| I2 | **Bluff emotes for back players:** while the front player is guessing, back players can press quick reactions (🤫 😏 👉) that show above their heads, to confuse the front player |
| I3 | **Sudden death:** after round 12 (Config), all damage ×1.5 so long games still end |
| I4 | **Rules screen** on first join: 4 short cards (lottery, vote, block + clue, guess). Can be reopened with a "?" button |
| I5 | **Titles during the game:** "Mind Reader" (2 correct guesses in a row), "Iron Cheek" (3 PERFECT blocks), "Silent Slapper" (slapped 2 times without getting caught) |
| I6 | **Spectator board** next to the arena: everyone outside can see each player's health and the current phase |
| I7 | **Slap power shown to everyone:** after the slap a big `85%!` pops up over the front player (for the back players and spectators) |

---

## 6. Config (defaults, all in `Config.lua`)

| Name | Default | Purpose |
|------|---------|---------|
| `MIN_PLAYERS` / `MAX_PLAYERS` | `3` / `6` | R1 |
| `JOIN_COUNTDOWN` / `FULL_COUNTDOWN` | `15` / `3` | R2 |
| `MAX_HEALTH` | `100` | |
| `MIN_SLAP_DAMAGE` / `MAX_SLAP_DAMAGE` | `5` / `40` | 0% / 100% power (at least 3 slaps to knock someone out) |
| `CHARGE_VALUES` | `{30, 30, 40}` | Q1 |
| `ZONE_YELLOW_MULT` / `ZONE_RED_MULT` | `0.5` / `0.1` | How much of a charge yellow / red gives |
| `SWEEP_TIMES` | `{1.3, 1.1, 0.9}` | Seconds per sweep for each charge |
| `PROTECT_PERFECT` / `PROTECT_GOOD` | `0.7` / `0.4` | Damage reduction |
| `PERFECT_CLUE_COUNT` | `2` | Names crossed out (Q3 limit applies) |
| `VOTE_TIME` / `GUESS_TIME` | `10` / `15` | Seconds |
| `MAX_SLAPS_IN_A_ROW` | `0` (off) | D4 |
| `ANIM_SIT` / `ANIM_RAISE_HAND` / `ANIM_SLAP` / `ANIM_SLAPPED` | `""` | Empty — user provides the IDs |
| `SOUNDS` | table | D12 |

---

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
| B2 | The animation ID must be owned by the game owner, otherwise it doesn't play in the live game | Q7 |
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
