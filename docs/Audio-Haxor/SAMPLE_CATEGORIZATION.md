# Sample Categorization Rules

Rules for categorizing audio samples into track types based on filename/path keywords.

## Global Genre Exclusions (Techno/Trance/Schranz)

These genres/styles should be **excluded from ALL sample queries** when generating techno, trance, or schranz tracks. They don't fit the aesthetic.

### World/Ethnic
```
samba, latin, bossa, salsa, reggae, reggaeton, afro, african,
world, ethnic, tribal, oriental, arabic, indian, asian, celtic,
flamenco, cumbia, bachata, merengue, calypso, caribbean
```

### Pop/Commercial
```
disco, nudisco, nu_disco, nu-disco, funky, funk, soul, motown,
pop, chart, commercial, radio, mainstream
```

### EDM/Festival (wrong energy for dark genres)
```
house, deep_house, tropical, future_house, big_room, festival,
progressive_house, electro_house, dutch, bounce, hardstyle
```

### Chill/Downtempo
```
lounge, chillout, chill, downtempo, ambient_pop, easy_listening,
lo-fi, lofi, bedroom, indie
```

### Hip-Hop/R&B
```
hip_hop, hiphop, hip-hop, trap, rnb, r&b, rap, boom_bap
```

### Rock/Band/Acoustic
```
rock, guitar, acoustic, folk, country, blues, jazz
```

### Cinematic/Orchestral
```
cinematic, film, movie, orchestral, classical, epic
```

### Wrong Character
```
organic, natural, live, vintage, retro, 80s, 70s, 60s,
happy, uplifting, euphoric, cheerful, bright, sunny
```

### Sample Pack Brands (known for non-electronic)
```
ghosthack, cymatics, splice_top, beatport_top
```

**Note**: For trance specifically, you may want to REMOVE `uplifting` and `euphoric` from the exclusion list since those are valid trance subgenres.

**Note**: `big_room`, `EDM`, `festival` are FINE for electronic music - don't exclude them.

## Cross-Category Exclusions (CRITICAL)

When querying samples, each category must EXCLUDE terms from other categories to prevent misclassification:

| Category | Must Exclude |
|----------|--------------|
| **KICK** | bass, sub, synth, melody, lead, pad, arp, chord, snare |
| **CLAP/SNARE** | kick, bass, sub, synth, melody, lead, pad, arp, chord, roll, fill |
| **HAT** | bass, sub, synth, melody, lead, pad, arp, chord, kick, ride |
| **PERC** | kick, snare, hat, bass, sub, synth, melody, lead, pad, arp, chord, full, drums_full, kit |
| **BASS** | kick, sub, drum, drums, hat, snare, clap, perc, ride, cymbal, tom, full, kit, synth, lead, pad, arp, melody |
| **SUB** | kick, drum, drums, hat, snare, clap, perc, ride, full, kit, synth, lead, pad, arp, melody |
| **SYNTH/LEAD** | pad, bass, sub, drum, drums, kick, hat, snare, clap, perc, ride, full, kit |
| **PAD** | drum, drums, stab, bass, sub, kick, hat, snare, clap, perc, ride, full, kit, lead, arp |
| **ARP** | pad, drum, drums, bass, sub, kick, hat, snare, clap, perc, ride, full, kit, lead |
| **FILL** | bass, synth, pad, lead, melody, loop, full, 8bar, 4bar, chord |

### Problem Examples

Without cross-exclusions, these misclassifications happen:
- `ZTTB_126_Drums_Full_11_a.wav` → matches "bass" query because path has other terms
- `DF-UT-125-Kit_03f-Bass-A.wav` → ambiguous, has both "Kit" and "Bass"
- Drum loops ending up on melodic tracks

## Category Hierarchy

```
DRUMS/
├── KICK
├── CLAP
├── HAT
├── HAT 2
├── PERC
├── PERC 2
├── RIDE
├── FILL 1B (1 beat)
├── FILL 2B (2 beats)
└── FILL 4B (4 beats)

BASS/
├── BASS
└── SUB

MELODICS/
├── MAIN SYNTH
├── SYNTH 1
├── SYNTH 2
├── SYNTH 3
├── PAD
├── PAD 2
├── ARP
└── ARP 2

FX/
├── RISER 1
├── RISER 2
├── RISER 3
├── DOWNLIFTER
├── CRASH
├── IMPACT
├── HIT
├── SWEEP UP
├── SWEEP DOWN
├── SWEEP UP 2
├── SWEEP DOWN 2
├── NOISE
├── NOISE 2
├── SNARE ROLL
├── REVERSE
├── SUB DROP
├── ATMOS
├── ATMOS 2
└── VOX
```

## Keyword Matching Rules

### DRUMS

| Track | Include | Exclude | Loop Required |
|-------|---------|---------|---------------|
| **KICK** | `kick`, `kick_loop` | `snare`, `bass`, `no_kick`, `no kick`, `nokick`, `without_kick`, `without kick` | Yes |
| **CLAP** | `clap`, `snare` | `kick`, `roll`, `build` | Yes |
| **HAT** | `hat`, `hihat`, `closed` | `open`, `ride` | Yes |
| **HAT 2** | `hat`, `open`, `hihat` | `closed` | Yes |
| **PERC** | `perc`, `percussion`, `shaker` | `kick`, `snare`, `hat` | Yes |
| **PERC 2** | `perc`, `conga`, `bongo`, `tom` | `kick`, `snare` | Yes |
| **RIDE** | `ride`, `cymbal` | `crash`, `hit` | Yes |
| **FILL 1B** | `fill`, `hit`, `shot`, `oneshot` | `loop`, `full`, `8bar`, `4bar` | No |
| **FILL 2B** | `fill`, `roll`, `flam` | `loop`, `full`, `8bar` | No |
| **FILL 4B** | `fill`, `break`, `drum_fill`, `tom_fill` | `loop`, `full`, `8bar`, `4bar` | No |

### BASS

| Track | Include | Exclude | Loop Required |
|-------|---------|---------|---------------|
| **BASS** | `bass`, `bassline` | `kick`, `sub` | Yes |
| **SUB** | `sub`, `808`, `low` | `kick` | Yes |

### MELODICS (Techno-specific excludes)

Common excludes for all melodics:
- `disco`, `nudisco`, `nu_disco`
- `funky`, `funk`
- `house`, `edm`, `pop`
- `tropical`, `bright`

| Track | Include | Exclude | Loop Required |
|-------|---------|---------|---------------|
| **MAIN SYNTH** | `lead`, `techno`, `dark`, `acid`, `industrial` | `pad`, `bass`, `drum` + common | Yes |
| **SYNTH 1** | `synth`, `acid`, `sequence`, `techno` | `pad`, `lead` + common | Yes |
| **SYNTH 2** | `lead`, `melody`, `synth_lead`, `dark` | `pad` + common | Yes |
| **SYNTH 3** | `stab`, `techno`, `industrial`, `hard` | `pad` + common | No |
| **PAD** | `pad`, `dark`, `ambient`, `drone` | `drum`, `stab`, `bright` + common | Yes |
| **PAD 2** | `pad`, `atmosphere`, `drone`, `dark` | `drum`, `kick`, `stab` + common | Yes |
| **ARP** | `arp`, `arpegg`, `sequence`, `techno` | `pad`, `drum` + common | Yes |
| **ARP 2** | `pluck`, `stab`, `arp`, `dark` | `pad`, `drum`, `chord` + common | Yes |

### FX

| Track | Include | Exclude | Loop Required |
|-------|---------|---------|---------------|
| **RISER 1** | `riser`, `uplifter` | `down`, `impact` | No |
| **RISER 2** | `build`, `riser`, `tension` | `down`, `impact` | No |
| **RISER 3** | `whoosh`, `sweep_up`, `upsweep` | `down` | No |
| **DOWNLIFTER** | `downlifter`, `downsweep`, `down_sweep`, `fall` | `up`, `riser` | No |
| **CRASH** | `crash`, `cymbal_crash` | `loop`, `ride` | No |
| **IMPACT** | `impact`, `boom`, `thud` | `loop`, `riser` | No |
| **HIT** | `hit`, `fx_hit`, `perc_shot` | `loop`, `riser`, `crash` | No |
| **SWEEP UP** | `sweep_up`, `upsweep`, `white_noise_up` | `down` | No |
| **SWEEP DOWN** | `sweep_down`, `downsweep`, `white_noise_down` | `up` | No |
| **SWEEP UP 2** | `sweep`, `riser`, `build` | `down`, `impact` | No |
| **SWEEP DOWN 2** | `fall`, `drop`, `down` | `up`, `sub` | No |
| **NOISE** | `noise`, `white_noise`, `hiss` | `drum`, `kick` | No |
| **NOISE 2** | `texture`, `noise`, `static` | `drum`, `kick`, `bass` | No |
| **SNARE ROLL** | `snare_roll`, `snare_build`, `snare_fill`, `roll` | `kick`, `hat` | No |
| **REVERSE** | `reverse`, `rev_crash`, `rev_cymbal`, `reversed` | `loop` | No |
| **SUB DROP** | `sub_drop`, `808_hit`, `sub_boom`, `low_impact` | `loop` | No |
| **ATMOS** | `atmos`, `atmosphere`, `ambient` | `drum`, `kick` | No |
| **ATMOS 2** | `texture`, `drone`, `soundscape` | `drum`, `kick` | No |
| **VOX** | `vox`, `vocal`, `voice` | `drum` | No |

## Kick Exclusion Rule

**Critical:** A drum loop labeled as "No Kick" must NOT be used as a kick track.

Exclude patterns for KICK:
- `no_kick`
- `no kick`
- `nokick`
- `without_kick`
- `without kick`
- `snare` (snare loops often have no kick)

## Loop vs Oneshot Detection

### Indicators of Loops
- Contains `_loop` in filename
- Duration matches typical loop lengths (1, 2, 4, 8, 16 bars)
- BPM in filename (e.g., `126bpm`, `128_bpm`)

### Indicators of Oneshots
- Contains `_shot`, `_hit`, `_oneshot`
- Very short duration (< 0.5 seconds)
- Located in "Oneshots" folder

### Usage by Category

| Category | Preferred Type |
|----------|----------------|
| Drums (rhythm tracks) | Loops |
| Bass | Loops |
| Melodics | Loops |
| Fills | Oneshots (short fills) or Loops (long fills) |
| FX (risers, impacts) | Oneshots |
| Atmosphere | Either |

## BPM Extraction

Extract BPM from filename patterns:
- `_126_` → 126 BPM
- `126bpm` → 126 BPM
- `140 BPM` → 140 BPM
- `155BPM` → 155 BPM

If no BPM in filename, calculate from duration and assumed loop length.

## Key Extraction

Extract musical key from filename:
- Single letter: `C`, `D`, `F`, `G`, `A`, `B`
- With accidental: `F#`, `G#`, `Bb`, `Eb`
- With quality: `Am`, `Cm`, `F Minor`, `G Sharp Minor`
- Atonal marker: `X` (no key)

## Genre-Specific Keywords

### Techno
- `techno`, `minimal`, `acid`, `industrial`
- `dark`, `driving`, `hard`

### Trance
- `trance`, `uplifting`, `psy`
- `euphoric`, `epic`

### Schranz
- `schranz`, `industrial`, `hardtechno`
- `rumble`, `drive`
- BPM typically 150-160

## Sample Pack Patterns

### Dave Parkinson (Trance)
```
DPTE {Category} - {Number} - {BPM} BPM - {Key}.wav
DPTE2 {Category} Loop - {Number} - {BPM} BPM - {Key}.wav
```

### ZTEKNO (Techno)
```
ZTAT_{BPM}_{Category}_{Type}_{Number}.wav
ZTAT_{Key}_{Category}_{Number}.wav
```

### Schranz Packs
```
DGR_SCH_TLS_{CATEGORY}_{NUMBER}.wav
DGR_SCH_TLS_{CATEGORY}_{BPM}BPM_{KEY}_{NUMBER}.wav
```

## Query Implementation

```rust
fn query_samples(
    include_patterns: &[&str],  // ANY of these must match
    exclude_patterns: &[&str],  // NONE of these can match
    require_loop: bool,          // Filter for loops only
    count: usize,                // How many samples to return
) -> Vec<SampleInfo>
```

The query is case-insensitive and searches the full file path.
