# Techno Arrangement Rules

Production rules for generating professional-sounding techno arrangements.

## Song Structure (224 bars / 7 min at 128 BPM)

| Section | Bars | Duration | Purpose |
|---------|------|----------|---------|
| **INTRO** | 1-32 | 1 min | Minimal, DJ-friendly entry |
| **BUILD** | 33-64 | 1 min | Add elements every 8 bars |
| **BREAKDOWN** | 65-96 | 1 min | Kick/bass OUT, melodics featured |
| **DROP 1** | 97-128 | 1 min | Full energy, main hook |
| **DROP 2** | 129-160 | 1 min | Variation, peak energy |
| **FADEDOWN** | 161-192 | 1 min | Strip elements every 8 bars |
| **OUTRO** | 193-224 | 1 min | Mirror intro for DJ mixing |

## The 8-Bar Rule

**Every 8 bars, something must change.** Either:
- **Add** an element (intro, build sections)
- **Remove** an element (fadedown, outro sections)
- **Vary** an element (different fill, FX, filter sweep)

## Element Entry Points

### Intro (1-32)
| Bar | Add |
|-----|-----|
| 1 | KICK, ATMOS, CRASH |
| 9 | CLAP |
| 17 | HAT |
| 25 | PERC, RISER starts |

### Build (33-64)
| Bar | Add |
|-----|-----|
| 33 | BASS, RIDE, SUB DROP |
| 41 | SYNTH 1 (filtered), PERC 2 |
| 49 | PAD |
| 57 | ARP, RISER 2 |

### Breakdown (65-96)
- **OUT**: KICK, CLAP, HAT, PERC, BASS
- **IN**: PAD (featured), MAIN SYNTH (bar 81), filtered melodics
- **Tension build**: Risers, sweeps, snare rolls bars 89-96

### Drop 1 (97-128)
| Bar | Add |
|-----|-----|
| 97 | Everything back IN, IMPACT, SUB DROP |
| 105 | SYNTH 2 |
| 113 | Additional layers |
| 121 | Variation elements |

### Fadedown (161-192) - Remove Every 8 Bars
| Bar | Remove |
|-----|--------|
| 169 | HAT 2, ARP 2 |
| 177 | RIDE, PERC 2, HAT |
| 185 | SYNTH 2, SYNTH 3 |
| 193 | Start outro |

### Outro (193-224) - Mirror Intro
| Bar | Remove |
|-----|--------|
| 193 | Most melodics |
| 201 | BASS starts thinning |
| 209 | PERC |
| 217 | Down to KICK + ATMOS |

## Fill Rules

### Fill Lengths
- **1 beat** (0.25 bars): Quick accent fills
- **2 beats** (0.5 bars): Medium energy transitions  
- **4 beats** (1 bar): Major section transitions

### Fill Placement
Fills go on the **last beat(s)** of a bar, right before a phrase boundary:
- 1-beat fill at bar 16 = beats 63-64 (last beat of bar 16)
- 2-beat fill at bar 24 = beats 93-96 (last 2 beats)
- 4-beat fill at bar 32 = beats 125-128 (full last bar)

### Fill Gap Rule
**ALL main elements must drop out during fills:**
- KICK, CLAP, HAT, PERC, RIDE
- BASS, SUB
- All SYNTHS, PADS, ARPS

**Only FX continue through fills:**
- Risers, sweeps, noise
- Crashes, impacts
- Atmosphere

### Sample Length Must Match Gap
- 1-beat gap → use 1-beat fill sample
- 2-beat gap → use 2-beat fill sample
- 4-beat gap → use 4-beat fill sample

The warp marker `SecTime` must match the gap duration:
```
1 beat at 128 BPM = 60/128 = 0.46875 seconds
2 beats = 0.9375 seconds
4 beats = 1.875 seconds
```

## Tension Building (Pre-Drop)

8 bars before DROP 1 (bars 89-96) need maximum tension:

### Layer These Elements
1. **RISER 1** (8 bars) - main long riser
2. **RISER 2** (8 bars) - secondary layer
3. **RISER 3** (4 bars, 93-96) - short accent
4. **SNARE ROLL** (8 bars) - building intensity
5. **NOISE** (8 bars) - white noise sweep
6. **SWEEP UP** (8 bars) - filter sweep
7. **REVERSE** (2 bars, 95-96) - reverse crash suck

### Pre-Drop Silence
Consider a **1-beat silence** right before the drop (beat 383-384) where everything cuts, then IMPACT + full arrangement hits on beat 384.

## FX Placement

### Crashes
Every 8 bars on the downbeat:
- Bars 1, 9, 17, 25, 33, 41, 49, 57, 65, 73, 81, 89, 97...

### Impacts
On major section starts:
- Bar 1 (track start)
- Bar 33 (build)
- Bar 65 (breakdown)
- Bar 97 (DROP 1)
- Bar 129 (DROP 2)
- Bar 161 (fadedown)
- Bar 193 (outro)

### Hits (Accents)
Offset from crashes - every 8 bars on bar 5, 13, 21, 29...:
- Creates rhythmic interplay with crashes

### Sweeps
**Sweep UP**: Before transitions (4-8 bars before new section)
**Sweep DOWN**: After big moments (post-drop, post-impact)

### Downlifters
After energy peaks:
- Bar 65-72 (into breakdown)
- Bar 97-104 (post-drop settle)
- Bar 161-168 (into fadedown)
- Bar 193-200 (into outro)

## Volume Levels

| Track Type | Level |
|------------|-------|
| KICK | 0 dB |
| All other tracks | -12 dB |

Kick at unity ensures it cuts through; everything else mixed relative to it.

## Sample Selection for Techno

### Exclude These Keywords
- `disco`, `nudisco`, `nu_disco`
- `funky`, `funk`
- `house`, `edm`, `pop`
- `tropical`, `bright`

### Prefer These Keywords
- `techno`, `dark`, `industrial`
- `acid`, `minimal`
- `hard`, `driving`

## Track Count Target

Professional techno arrangement: **35-45 tracks**

### Drums (8-10 tracks)
KICK, CLAP, HAT, HAT 2, PERC, PERC 2, RIDE, FILL 1B, FILL 2B, FILL 4B

### Bass (2 tracks)
BASS, SUB

### Melodics (8 tracks)
MAIN SYNTH, SYNTH 1, SYNTH 2, SYNTH 3, PAD, PAD 2, ARP, ARP 2

### FX (15-20 tracks)
RISER 1-3, DOWNLIFTER, CRASH, IMPACT, HIT, SWEEP UP, SWEEP DOWN, SWEEP UP 2, SWEEP DOWN 2, NOISE, NOISE 2, SNARE ROLL, REVERSE, SUB DROP, ATMOS, ATMOS 2, VOX

## Locators

Add arrangement locators for navigation:
- INTRO (bar 1)
- BUILD (bar 33)
- BREAKDOWN (bar 65)
- DROP 1 (bar 97)
- DROP 2 (bar 129)
- FADEDOWN (bar 161)
- OUTRO (bar 193)

## Fill Variation Strategy

Use **multiple fill tracks with different samples** to avoid repetition:

### Staggered Fill Pattern
Instead of one fill track per length, create A/B/C/D variants:

| Track | Positions | Purpose |
|-------|-----------|---------|
| FILL 1A | 16, 104, 168 | 1-beat fills, sample A |
| FILL 1B | 56, 136, 216 | 1-beat fills, sample B |
| FILL 2A | 24, 72, 120, 184 | 2-beat fills, sample A |
| FILL 2B | 40, 88, 152, 208 | 2-beat fills, sample B |
| FILL 4A | 32, 96, 160 | 1-bar fills (major transitions) |
| FILL 4B | 48, 112, 176 | 1-bar fills, sample B |
| FILL 4C | 64, 128, 192 | 1-bar fills, sample C |
| FILL 4D | 80, 144 | 1-bar fills, sample D |

### Reverse FX Alternation
| Track | Positions |
|-------|-----------|
| REVERSE 1 | 16, 48, 80, 112, 144, 176 |
| REVERSE 2 | 32, 64, 96, 128, 160, 192 |

This creates unpredictability - listener never hears the same fill twice in a row.

## Bar/Beat Timing (CRITICAL)

### Fill Gap Alignment

The fill must play **IN the gap**, not before it:

```
WRONG: Main elements end at bar 31, fill at bar 31-32
       Gap is bar 32-33, but fill plays bar 31-32 (1 bar early!)

RIGHT: Main elements end at bar 32, fill at bar 32-33
       Gap IS bar 32-33, fill plays exactly in the gap
```

### Correct Timing Formula

For a 4-beat (1 bar) fill at phrase boundary bar 33:
- Main elements: end at **bar 32** (beat 124)
- Fill plays: **bar 32-33** (beats 124-128)
- Next phrase starts: **bar 33** (beat 128)

For a 2-beat fill at phrase boundary bar 25:
- Main elements: end at **bar 24.5** (beat 94)
- Fill plays: **bar 24.5-25** (beats 94-96)
- Next phrase starts: **bar 25** (beat 96)

For a 1-beat fill at phrase boundary bar 17:
- Main elements: end at **bar 16.75** (beat 63)
- Fill plays: **bar 16.75-17** (beats 63-64)
- Next phrase starts: **bar 17** (beat 64)

### Common Mistake

If you see a 1-bar gap with nothing in it before the fill, your fills are 1 bar early. The fill should occupy that empty space.
