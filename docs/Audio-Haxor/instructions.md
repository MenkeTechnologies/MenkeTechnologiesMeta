# ALS Generator Spec

Generate Ableton Live Set (.als) files. ALS = gzipped XML.

## UI Wizard (New Tab: "ALS Generator")

Multi-step wizard for project generation:

### Step 1: Project Basics
```
┌─────────────────────────────────────────────────────────────┐
│  ● Step 1: Basics   ○ Step 2: Sound   ○ Step 3: Preview   ○ Step 4: Generate │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Genre:         [Techno_____▼]                              │
│                 ○ Techno    (120-140 BPM, hypnotic/driving) │
│                 ○ Schranz   (145-165 BPM, distorted/intense)│
│                 ○ Trance    (130-160 BPM, melodic/euphoric) │
│                                                             │
│  Hardness:      Regular ●━━━━━━━━━━━━━━○ Hard               │
│                         0.0           1.0                   │
│                                                             │
│  BPM:           [138___]  (auto-set by genre, editable)     │
│                                                             │
│  ┌─ Key ───────────────────────────────────────────────┐   │
│  │  Root Note:  [A_____▼]                              │   │
│  │  Mode:       [Aeolian_▼]      ☐ Atonal              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Global Vibe Keywords:                                      │
│  [Industrial] [Dark] [Underground] [Driving] [+]            │
│                                                             │
│                                          [ Next → ]         │
└─────────────────────────────────────────────────────────────┘
```

### Step 2: Sound Design
```
┌─────────────────────────────────────────────────────────────┐
│  ○ Step 1: Basics   ● Step 2: Sound   ○ Step 3: Preview   ○ Step 4: Generate │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Define the character of each element:                      │
│                                                             │
│  ┌─ DRUMS ─────────────────────────────────────────────┐   │
│  │  Kick:   [rumble▼]   ○tight ○punchy ●rumble ○909    │   │
│  │  Clap:   [snappy▼]   ●snappy ○fat ○layered ○reverb  │   │
│  │  Hats:   [crispy▼]   ●crispy ○dark ○organic ○16th   │   │
│  │  Perc:   [tribal▼]   ●tribal ○glitchy ○minimal      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ BASS ──────────────────────────────────────────────┐   │
│  │  Sub:    [deep▼]     ●deep ○punchy ○808 ○distorted  │   │
│  │  Mid:    [arped▼]    ○rolling ●arped ○acid ○reese   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ MELODICS ──────────────────────────────────────────┐   │
│  │  Lead:   [edgy▼]     ●edgy ○smooth ○supersaw ○acid  │   │
│  │  Pad:    [creepy▼]   ●creepy ○lush ○warm ○ethereal  │   │
│  │  Atmos:  [dark▼]     ●dark ○cosmic ○dreamy ○glitchy │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ FX & VOX ──────────────────────────────────────────┐   │
│  │  FX:     [big▼]      ●big ○subtle ○whoosh ○reverse  │   │
│  │  Vocal:  [glitch▼]   ●glitch ○chopped ○ethereal     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ TRACK COUNTS & CHARACTER ────────────────────────────┐ │
│  │                                                        │ │
│  │  Drum Loops:     [3___] ○━━━━●━━━━○        1-8         │ │
│  │       Character: Clean ○━━━━━━●━━○ Distorted           │ │
│  │                  (tight, punchy)  (saturated, gritty)  │ │
│  │                                                        │ │
│  │  Bass Loops:     [2___] ○━━━━●━━━━○        1-4         │ │
│  │       Character: Clean ○━━━━●━━━━○ Distorted           │ │
│  │                  (deep, round)    (gritty, aggressive) │ │
│  │                                                        │ │
│  │  Lead Loops:     [2___] ○━━━━●━━━━○        1-6         │ │
│  │       Character: Smooth ○━━━━━●━━○ Aggressive          │ │
│  │                  (clean, soft)    (edgy, harsh)        │ │
│  │                                                        │ │
│  │  Pad Loops:      [2___] ○━━━━●━━━━○        1-4         │ │
│  │       Character: Warm ○━━━━━●━━━━○ Dark                │ │
│  │                  (lush, soft)     (cold, eerie)        │ │
│  │                                                        │ │
│  │  FX Tracks:      [6___] ○━━━━━●━━━○        2-20        │ │
│  │       Character: Subtle ○━━━━━●━━○ Intense             │ │
│  │                  (gentle sweeps)  (big impacts)        │ │
│  │                                                        │ │
│  │  Vocal Tracks:   [0___] ○●━━━━━━━━○        0-6         │ │
│  │       Character: Ethereal ○━━━━●━○ Chopped             │ │
│  │                  (airy, smooth)   (glitchy, stutter)   │ │
│  │                                                        │ │
│  │  ─────────────────────────────────────────────────     │ │
│  │  Estimated Total:  ~35 tracks                          │ │
│  │                                                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│                              [ ← Back ]  [ Next → ]         │
└─────────────────────────────────────────────────────────────┘
```

### Step 3: Preview Key Samples
```
┌─────────────────────────────────────────────────────────────┐
│  ○ Step 1: Basics   ○ Step 2: Sound   ● Step 3: Preview    │
│                                       ○ Step 4: Generate    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Preview & approve the main samples (kick, bass, lead):     │
│                                                             │
│  ┌─ KICK ──────────────────────────────────────────────┐   │
│  │  ▶ TechKick_Rumble_128_01.wav          [✓] [✗] [↻] │   │
│  │    ░░░░░░░░░░░░░░░░░░░░  0:00 / 0:02               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ SUB BASS ──────────────────────────────────────────┐   │
│  │  ▶ Deep_Sub_A_138BPM.wav               [✓] [✗] [↻] │   │
│  │    ████████░░░░░░░░░░░░  0:03 / 0:08               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ MID BASS ──────────────────────────────────────────┐   │
│  │  ▶ Arped_Bass_Am_140.wav               [✓] [✗] [↻] │   │
│  │    ░░░░░░░░░░░░░░░░░░░░  0:00 / 0:04               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ MAIN LEAD ─────────────────────────────────────────┐   │
│  │  ▶ Edgy_Lead_Synth_Am_138.wav          [✓] [✗] [↻] │   │
│  │    ░░░░░░░░░░░░░░░░░░░░  0:00 / 0:06               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ MAIN PAD ──────────────────────────────────────────┐   │
│  │  ▶ Creepy_Pad_Evolve_Am.wav            [✓] [✗] [↻] │   │
│  │    ░░░░░░░░░░░░░░░░░░░░  0:00 / 0:12               │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [✓] = Accept   [✗] = Reject (pick another)   [↻] = Shuffle│
│                                                             │
│  All other samples (hats, perc, fx, etc.) auto-selected.   │
│                                                             │
│                              [ ← Back ]  [ Next → ]         │
└─────────────────────────────────────────────────────────────┘
```

**Preview elements (user can accept/reject):**
- Kick
- Sub bass
- Mid bass  
- Main lead (main_riff)
- Main pad

**Auto-selected (no preview needed):**
- Hats, claps, rides, perc, shakers
- Accessory leads, secondary pads
- FX (risers, downers, crashes, fills)
- Vocals, atmos

### Step 4: Generate
```
┌─────────────────────────────────────────────────────────────┐
│  ○ Step 1: Basics   ○ Step 2: Sound   ○ Step 3: Preview    │
│                                       ● Step 4: Generate    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─ Summary ───────────────────────────────────────────┐   │
│  │  Genre:     Tech-Trance (0.65)                      │   │
│  │  Hardness:  Regular (0.2)                           │   │
│  │  BPM:       138                                     │   │
│  │  Key:       A Aeolian                               │   │
│  │  Vibe:      Industrial, Dark, Underground           │   │
│  │                                                     │   │
│  │  Kick: rumble   Bass: arped    Lead: edgy          │   │
│  │  Pad: creepy    Vocal: glitch  FX: big             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─ Approved Samples ──────────────────────────────────┐   │
│  │  Kick:     TechKick_Rumble_128_01.wav              │   │
│  │  Sub:      Deep_Sub_A_138BPM.wav                   │   │
│  │  Mid Bass: Arped_Bass_Am_140.wav                   │   │
│  │  Lead:     Edgy_Lead_Synth_Am_138.wav              │   │
│  │  Pad:      Creepy_Pad_Evolve_Am.wav                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Project Name (auto-generated):                             │
│  [ Industrial Descent - 20260414_2345_____________ ] [🔄]  │
│                                                             │
│  Output:  [~/Desktop_______________________] [Browse...]    │
│                                                             │
│  ┌─ Estimated Project ─────────────────────────────────┐   │
│  │  Duration:    ~7 min (224 bars @ 138 BPM)          │   │
│  │  Tracks:      ~85 tracks                            │   │
│  │  Sections:    Intro → Build → Break → Drop1 →      │   │
│  │               Drop2 → Fadedown → Outro              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│                              [ ← Back ]  [ Generate ALS ]   │
│                                                             │
│  ┌─ Progress (shown during generation) ────────────────┐   │
│  │  ████████████░░░░░░░░░░░░░  45%                    │   │
│  │  Building arrangement...                            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Post-Generation Success
```
┌─────────────────────────────────────────────────────────────┐
│                         ✓ Success!                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Project created:                                           │
│  ~/Desktop/Industrial Descent - 20260414_2345.als           │
│                                                             │
│  ┌─ Stats ─────────────────────────────────────────────┐   │
│  │  Duration:    6:42                                  │   │
│  │  Tracks:      87                                    │   │
│  │  Samples:     142                                   │   │
│  │  Size:        2.3 MB                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [ Open in Ableton ]  [ Show in Finder ]  [ New Project ]  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Inputs:**
| Field | Type | Default | Notes |
|-------|------|---------|-------|
| BPM | number | 128 | Auto-adjusts based on genre/hardness |
| Root Note | dropdown | "A" | C, C#, D, D#, E, F, F#, G, G#, A, A#, B |
| Mode | dropdown | "Aeolian" | Ionian, Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian |
| Atonal | checkbox | false | When checked, disables Root Note + Mode, skips key matching |
| Genre | slider | 0.5 | 0.0=techno, 1.0=trance |
| Hardness | slider | 0.0 | 0.0=regular, 1.0=hard |
| Output | path | ~/Desktop | Configurable via settings |
| Keywords | multi-select | [] | Global keywords for vibe/mood |
| Element Keywords | per-element | {} | Keywords per element type (see below) |

**Keywords (pick many to guide generation):**

User can select many keywords to affect sample selection and project character. Keywords are matched against sample filenames in DB.

```rust
const ALL_KEYWORDS: &[&str] = &[
    // Character/Vibe
    "Industrial", "Warehouse", "Underground", "Dark", "Light", "Driving", "Minimal", 
    "Raw", "Mechanical", "Hypnotic", "Pulse", "Nocturnal", "Eclipse", "Deep", 
    "Groovy", "Progressive", "Euphoria", "Aurora", "Celestial", "Ascend", 
    "Ethereal", "Uplifting", "Epic", "Melodic", "Melancholic", "Aggressive", 
    "Dreamy", "Intense", "Cosmic", "Mystical", "Psychedelic", "Trippy",
    
    // Energy
    "Peak", "Rolling", "Chill", "Explosive", "Relentless", "Building", "Pumping",
    "Banging", "Hard", "Soft", "Subtle", "Massive", "Big", "Huge",
    
    // Texture/Sound
    "Acid", "Analog", "Digital", "Organic", "Gritty", "Clean", "Distorted", 
    "Lush", "Glitch", "Glitchy", "Boomy", "Punchy", "Fat", "Warm", "Cold",
    "Crispy", "Crunchy", "Saturated", "Lo-Fi", "Hi-Fi", "Filtered", "Resonant",
    "Metallic", "Woody", "Synthetic", "Acoustic", "Electric", "Fizzy", "Buzzy",
    
    // Style
    "909", "808", "303", "TB303", "Roland", "Moog", "Modular", "FM", "Wavetable",
    "Granular", "Reese", "Hoover", "Stab", "Pluck", "Arp", "Sequence",
    
    // Setting/Time
    "Night", "Dawn", "Dusk", "Midnight", "Afterhours", "Festival", "Club", 
    "Rave", "Desert", "Beach", "Forest", "Space", "Void", "Urban",
    
    // Mood
    "Happy", "Sad", "Angry", "Peaceful", "Chaotic", "Tense", "Relaxed",
    "Energetic", "Lazy", "Frantic", "Calm", "Violent", "Gentle",
];

// UI behavior:
// - Display as tag cloud or searchable multi-select
// - User picks as many as they want
// - Selected keywords used for:
//   1. Sample query: boost samples whose names contain any keyword
//      WHERE name REGEXP '(industrial|glitch|distorted|boomy)'
//   2. Project naming: pick from selected keywords
//   3. Sample variety: prefer samples matching different keywords for variety
```

**Element-Specific Keywords:**

Simple descriptors per element — user picks style for each:

```
┌─────────────────────────────────────────────────────────────┐
│  Kick:    [rumble▼]    tight | punchy | boomy | rumble |   │
│                        snappy | 909 | 808 | distorted      │
│                                                             │
│  Bass:    [arped▼]     offbeat | arped | rolling | wobble | │
│                        acid | reese | sub | plucky          │
│                                                             │
│  Lead:    [edgy▼]      edgy | smooth | plucky | supersaw |  │
│                        acid | stab | arp | aggressive       │
│                                                             │
│  Pad:     [creepy▼]    creepy | lush | warm | cold | airy | │
│                        evolving | dark | ethereal           │
│                                                             │
│  Vocal:   [glitch▼]    glitch | chopped | ethereal | male | │
│                        female | stutter | whisper | robotic │
│                                                             │
│  Atmos:   [dark▼]      dark | cosmic | industrial | dreamy |│
│                        glitchy | ambient | textural         │
│                                                             │
│  FX:      [big▼]       big | subtle | whoosh | laser |      │
│                        reverse | glitch | tape | explosive  │
│                                                             │
│  Perc:    [tribal▼]    tribal | glitchy | organic | shaker |│
│                        metallic | woody | minimal           │
└─────────────────────────────────────────────────────────────┘
```

```rust
const ELEMENT_KEYWORDS: &[(&str, &[&str])] = &[
    ("kick",  &["tight", "punchy", "boomy", "rumble", "snappy", "909", "808", "distorted", "deep", "clicky"]),
    ("bass",  &["offbeat", "arped", "rolling", "wobble", "acid", "reese", "sub", "plucky", "growl", "hoover"]),
    ("lead",  &["edgy", "smooth", "plucky", "supersaw", "acid", "stab", "arp", "aggressive", "bright", "dark"]),
    ("pad",   &["creepy", "lush", "warm", "cold", "airy", "evolving", "dark", "ethereal", "thick", "shimmer"]),
    ("vocal", &["glitch", "chopped", "ethereal", "male", "female", "stutter", "whisper", "robotic", "ahhh", "spoken"]),
    ("atmos", &["dark", "cosmic", "industrial", "dreamy", "glitchy", "ambient", "textural", "evolving", "space"]),
    ("fx",    &["big", "subtle", "whoosh", "laser", "reverse", "glitch", "tape", "explosive", "sweep", "impact"]),
    ("perc",  &["tribal", "glitchy", "organic", "shaker", "metallic", "woody", "minimal", "busy", "crispy"]),
];

// Example selections:
// "rumble kick, arped bass, edgy lead, glitch vox, creepy pads"
// → queries samples matching these descriptors in filenames
```

**Track count & character inputs:**

```rust
// Per-element: count + character slider
struct ElementConfig {
    count: u32,
    character: f32,  // 0.0 = clean/smooth/subtle, 1.0 = distorted/aggressive/intense
}

struct TrackConfig {
    drums: ElementConfig,   // count: 1-8,  character: clean → distorted
    bass: ElementConfig,    // count: 1-4,  character: clean → distorted  
    leads: ElementConfig,   // count: 1-6,  character: smooth → aggressive
    pads: ElementConfig,    // count: 1-4,  character: warm → dark
    fx: ElementConfig,      // count: 2-20, character: subtle → intense
    vocals: ElementConfig,  // count: 0-6,  character: ethereal → chopped
}

// Character affects which keywords are used in sample queries
fn get_character_keywords(element: &str, character: f32) -> Vec<&'static str> {
    match element {
        "drums" => {
            if character < 0.3 {
                vec!["clean", "tight", "punchy", "acoustic", "natural"]
            } else if character < 0.7 {
                vec!["punchy", "warm", "analog", "processed"]
            } else {
                vec!["distorted", "saturated", "gritty", "crushed", "industrial", "hard"]
            }
        }
        "bass" => {
            if character < 0.3 {
                vec!["clean", "deep", "round", "smooth", "sub"]
            } else if character < 0.7 {
                vec!["warm", "fat", "analog", "reese"]
            } else {
                vec!["distorted", "gritty", "aggressive", "acid", "growl", "scream"]
            }
        }
        "leads" => {
            if character < 0.3 {
                vec!["smooth", "soft", "mellow", "warm", "gentle"]
            } else if character < 0.7 {
                vec!["bright", "sharp", "supersaw", "plucky"]
            } else {
                vec!["aggressive", "edgy", "harsh", "screech", "distorted", "acid"]
            }
        }
        "pads" => {
            if character < 0.3 {
                vec!["warm", "lush", "soft", "airy", "gentle", "dreamy"]
            } else if character < 0.7 {
                vec!["evolving", "textured", "ambient", "atmospheric"]
            } else {
                vec!["dark", "cold", "eerie", "creepy", "haunting", "sinister"]
            }
        }
        "fx" => {
            if character < 0.3 {
                vec!["subtle", "gentle", "soft", "small", "short"]
            } else if character < 0.7 {
                vec!["medium", "standard", "normal"]
            } else {
                vec!["intense", "big", "massive", "huge", "explosive", "powerful"]
            }
        }
        "vocals" => {
            if character < 0.3 {
                vec!["ethereal", "airy", "smooth", "soft", "whisper", "angelic"]
            } else if character < 0.7 {
                vec!["processed", "vocoder", "pitched", "harmonized"]
            } else {
                vec!["chopped", "glitch", "stutter", "sliced", "mangled", "robotic"]
            }
        }
        _ => vec![]
    }
}

struct TrackCounts {
    drum_loops: u32,    // 1-8
    bass_loops: u32,    // 1-4
    lead_loops: u32,    // 1-6
    pad_loops: u32,     // 1-4
    fx_tracks: u32,     // 2-20
    vocal_tracks: u32,  // 0-6
}

impl TrackCounts {
    fn total(&self) -> u32 {
        self.drum_loops + self.bass_loops + self.lead_loops + 
        self.pad_loops + self.fx_tracks + self.vocal_tracks
    }
    
    fn default() -> Self {
        Self {
            drum_loops: 3,
            bass_loops: 2,
            lead_loops: 2,
            pad_loops: 2,
            fx_tracks: 6,
            vocal_tracks: 0,
        }
        // Total: ~15 tracks
    }
    
    fn full_production() -> Self {
        Self {
            drum_loops: 8,
            bass_loops: 4,
            lead_loops: 6,
            pad_loops: 4,
            fx_tracks: 20,
            vocal_tracks: 6,
        }
        // Total: ~48 tracks
    }
}

// How drum_loops breaks down internally:
// drum_loops=3 might become: 1 kick loop, 1 hat loop, 1 perc loop
// drum_loops=8 might become: 2 kick loops, 2 clap loops, 2 hat loops, 1 ride, 1 perc

fn distribute_drum_loops(count: u32) -> DrumDistribution {
    match count {
        1 => DrumDistribution { kicks: 1, claps: 0, hats: 0, rides: 0, percs: 0 },
        2 => DrumDistribution { kicks: 1, claps: 0, hats: 1, rides: 0, percs: 0 },
        3 => DrumDistribution { kicks: 1, claps: 1, hats: 1, rides: 0, percs: 0 },
        4 => DrumDistribution { kicks: 1, claps: 1, hats: 1, rides: 0, percs: 1 },
        5 => DrumDistribution { kicks: 1, claps: 1, hats: 2, rides: 0, percs: 1 },
        6 => DrumDistribution { kicks: 1, claps: 1, hats: 2, rides: 1, percs: 1 },
        7 => DrumDistribution { kicks: 2, claps: 1, hats: 2, rides: 1, percs: 1 },
        _ => DrumDistribution { kicks: 2, claps: 2, hats: 2, rides: 1, percs: 1 }, // 8+
    }
}

fn distribute_bass_loops(count: u32) -> BassDistribution {
    match count {
        1 => BassDistribution { sub: 1, mid: 0, top: 0 },
        2 => BassDistribution { sub: 1, mid: 1, top: 0 },
        3 => BassDistribution { sub: 1, mid: 1, top: 1 },
        _ => BassDistribution { sub: 1, mid: 2, top: 1 }, // 4+
    }
}

fn distribute_fx_tracks(count: u32) -> FxDistribution {
    // Prioritize: crashes > risers > impacts > downers > fills > glitches
    FxDistribution {
        crashes: (count / 4).max(1),
        risers: (count / 3).max(1),
        impacts: count / 5,
        downers: count / 6,
        fills: count / 7,
        glitches: count / 8,
        whooshes: count / 10,
    }
}
```

**Generation behavior:**
- All inputs disabled during generation
- Progress spinner shown on Generate button
- Could take significant time (querying DB, parsing templates, building XML, gzipping)
- On completion: toast notification with file path
- On error: toast with error message, re-enable inputs

**Project scope — NO TOY PROJECTS:**
- Generate **real, production-ready projects** with **30-150 tracks**
- Full arrangement: **6-8 minutes** (192-256 bars at 128-140 BPM)
- Complete intro → buildup → breakdown → drop → drop 2 → outro
- Every track category populated with appropriate samples
- All FX (crashes, risers, downers, fills) placed at correct bar positions
- Filter automation on relevant tracks
- Proper grouping and routing (buses, sends)
- Multiple variations/layers per category:
  ```
  DRUMS:   kick, kick roll, kick fx, clap, clap fx, closed hat, open hat, 
           ride, ride 2, perc 1-4, shakers 1-3, top loops 1-3
  BASS:    sub, mid bass 1-2, bass pad, acid bass
  LEADS:   lead 1-4, pluck 1-2, stab 1-4, arp 1-2
  PADS:    pad 1-3, atmos 1-4, strings, choir
  FX:      crash 1-2, riser 1-3, downer 1-2, impact 1-2, sweep 1-2,
           snare roll, fill 1-4, white noise, fx stabs 1-4
  VOX:     vocal chop 1-4, vocal atmos 1-2, ahhh 1-4
  ```
- This is NOT a starting point — it's a near-complete track skeleton that user refines

**Project Name (Auto-generated):**

Generated algorithmically from inputs + sample characteristics:

```rust
fn generate_project_name(bpm: u32, key: Option<&str>, genre: f32, hardness: f32) -> String {
    let mut rng = rand::thread_rng();
    
    // Genre prefix
    let genre_words: &[&str] = if genre < 0.3 {
        &["Industrial", "Warehouse", "Underground", "Dark", "Driving"]
    } else if genre < 0.7 {
        &["Hypnotic", "Pulse", "Nocturnal", "Eclipse", "Synth"]
    } else {
        &["Euphoria", "Aurora", "Celestial", "Ascend", "Ethereal"]
    };
    let genre_word = genre_words.choose(&mut rng).unwrap();
    
    // Hardness modifier
    let hard_words: &[&str] = if hardness >= 0.5 {
        &["Acid", "Rave", "Peak", "Intense", "Raw"]
    } else {
        &["Deep", "Smooth", "Flowing", "Drift", "Wave"]
    };
    let hard_word = hard_words.choose(&mut rng).unwrap();
    
    // Key-based word
    let key_word = match key {
        Some(k) if k.contains("Minor") => {
            ["Shadow", "Void", "Descent", "Abyss", "Night"].choose(&mut rng).unwrap()
        }
        Some(k) if k.contains("Major") => {
            ["Rise", "Light", "Dawn", "Horizon", "Sky"].choose(&mut rng).unwrap()
        }
        _ => ["Abstract", "Signal", "Pulse", "System", "Code"].choose(&mut rng).unwrap()
    };
    
    // Combine with timestamp
    let patterns = [
        format!("{genre_word} {key_word}"),
        format!("{hard_word} {genre_word}"),
        format!("{key_word} {bpm}"),
        format!("{genre_word} {hard_word} {key_word}"),
    ];
    let name = patterns.choose(&mut rng).unwrap();
    let timestamp = chrono::Local::now().format("%Y%m%d_%H%M");
    
    format!("{name} - {timestamp}")
}

// Examples:
// "Industrial Shadow - 20260414_2230"
// "Euphoria Rise - 20260414_2231"  
// "Acid Hypnotic Void - 20260414_2232"
// "Deep Celestial - 20260414_2233"
```

**Key inputs (2 dropdowns):**

```
┌─────────────────────────────────────────────────────────────┐
│  Root Note:     [C_________▼]                               │
│  Mode:          [Aeolian (Minor)_▼]   ☐ Atonal              │
└─────────────────────────────────────────────────────────────┘
```

**Root Note options:**
```
C, C#, D, D#, E, F, F#, G, G#, A, A#, B
```

**Mode options (7 diatonic modes):**
```
| Mode       | Character                          | Common in          |
|------------|------------------------------------|--------------------|
| Ionian     | Major scale; happy, bright         | Pop, uplifting     |
| Dorian     | Minor + raised 6th; jazzy, hopeful | Tech-house, deep   |
| Phrygian   | Minor + lowered 2nd; dark, exotic  | Psytrance, dark    |
| Lydian     | Major + raised 4th; dreamy, float  | Ambient, ethereal  |
| Mixolydian | Major + lowered 7th; bluesy        | Funk, groove       |
| Aeolian    | Natural minor; sad, melancholic    | Trance, techno     |
| Locrian    | Diminished; tense, unstable        | Experimental       |
```

**Display format:** `{Root} {Mode}` → e.g., "A Aeolian", "F# Phrygian", "C Lydian"

**Mapping to sample query:**

Modes share notes with their relative major. Calculate the relative major/minor for DB query:

```rust
// Semitone offsets from mode root to relative major root
const MODE_TO_RELATIVE_MAJOR: &[(&str, i32)] = &[
    ("Ionian", 0),      // C Ionian = C Major (same root)
    ("Dorian", -2),     // D Dorian = C Major (D - 2 semitones = C)
    ("Phrygian", -4),   // E Phrygian = C Major (E - 4 semitones = C)
    ("Lydian", -5),     // F Lydian = C Major (F - 5 semitones = C)
    ("Mixolydian", -7), // G Mixolydian = C Major (G - 7 semitones = C)
    ("Aeolian", -9),    // A Aeolian = C Major (A - 9 semitones = C) OR A Minor
    ("Locrian", -11),   // B Locrian = C Major (B - 11 semitones = C)
];

const NOTES: &[&str] = &["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

fn mode_to_query_key(root: &str, mode: &str) -> String {
    let root_idx = NOTES.iter().position(|&n| n == root).unwrap() as i32;
    let offset = MODE_TO_RELATIVE_MAJOR.iter()
        .find(|(m, _)| *m == mode)
        .map(|(_, o)| *o)
        .unwrap_or(0);
    
    let relative_major_idx = ((root_idx + offset) % 12 + 12) % 12;
    let relative_major = NOTES[relative_major_idx as usize];
    
    // Return relative major for query
    // Also valid: relative minor (3 semitones up from major)
    format!("{} Major", relative_major)
}

// Examples:
// "D Dorian"    → "C Major"
// "E Phrygian"  → "C Major"  
// "A Aeolian"   → "C Major" (or "A Minor" - same notes)
// "F# Dorian"   → "E Major"
// "C Ionian"    → "C Major"
// "G Mixolydian"→ "C Major"

// For sample query, match EITHER relative major OR relative minor (same notes):
fn get_compatible_keys(root: &str, mode: &str) -> Vec<String> {
    let relative_major = mode_to_query_key(root, mode);
    let major_root_idx = NOTES.iter().position(|&n| relative_major.starts_with(n)).unwrap();
    let minor_root_idx = (major_root_idx + 9) % 12; // relative minor is 9 semitones up
    let relative_minor = format!("{} Minor", NOTES[minor_root_idx]);
    
    vec![relative_major, relative_minor]
}

// "D Dorian" → ["C Major", "A Minor"] (both have same notes, query either)
```

**BPM auto-calculation:**
```
base_bpm = lerp(128, 138, genre)  # 128 at techno, 138 at trance
if hardness >= 0.5:
    base_bpm += lerp(12, 22, hardness)  # +12-22 for hard styles
```

## Templates

Local copies in `docs/templates/` (gitignored):

```
TECHNO (12 templates):
  techno_template.als              # Zforce/Tekforce - custom production
  techno_1_Another_History.als     # Ida Engberg style
  techno_2_Chroma.als              # Joseph Capriati style
  techno_3_Country.als             # Ramon Tapia style
  techno_4_Dark_Dreams.als         # Pavel Petrov style
  techno_5_Let_Me.als              # Matador style
  techno_6_Lights_on_Wall.als      # Marco Bailey style
  techno_7_Lost_Sea.als            # Monika Kruse style
  techno_8_Mr_Smith.als            # Ramiro Lopez style
  techno_9_DARK_BRAIN.als          # Sven Vath style
  techno_10_The_Clouds.als         # Oliver Huntemann style

TRANCE (11 templates):
  trance_template.als              # Metta & Glyde Vol 7
  trance_1_MG_Vol5.als             # Metta & Glyde Vol 5
  trance_2_MG_Vol4.als             # Metta & Glyde Vol 4
  trance_3_MG_Vol3.als             # Metta & Glyde Vol 3
  trance_4_MG_RGEN_Vol1.als        # Metta & Glyde Regenerate Vol 1
  trance_5_MG_RGEN_Vol2.als        # Metta & Glyde Regenerate Vol 2
  trance_6_Allen_Watts_Vol5.als    # Allen Watts Uplifting Vol 5
  trance_7_Asteroid_Vol1.als       # Asteroid Trance Vol 1
  trance_8_Harshil_Kamdar_Vol1.als # Harshil Kamdar (Stock FX only)
  trance_9_MG_TechTrance_Vol1.als  # Metta & Glyde Tech-Trance Vol 1
  trance_10_MG_TechTrance_Vol2.als # Metta & Glyde Tech-Trance Vol 2
```

## Sample Database

```
SAMPLE_DB = "/Users/wizard/Library/Application Support/com.menketechnologies.audio-haxor/audio_haxor.db"

-- Relevant columns in audio_samples table:
-- name          TEXT    (filename, use for category regex matching)
-- path          TEXT    (absolute path to file)
-- format        TEXT    (must be 'wav')
-- bpm           REAL    (detected BPM, nullable)
-- key_name      TEXT    (e.g. "C Minor", "F# Major", nullable)
```

## ALS XML Structure

### Time Units
Ableton uses **beats** not bars. At 4/4:
```
bar_to_beat(bar) = (bar - 1) * 4
beat_to_bar(beat) = (beat / 4) + 1

Bar 1   = Beat 0
Bar 32  = Beat 124
Bar 64  = Beat 252
Bar 96  = Beat 380
Bar 128 = Beat 508
Bar 192 = Beat 764
```

### Tempo
```xml
<Tempo>
  <Manual Value="140" />
</Tempo>
```

### AudioClip Placement
```xml
<AudioClip Id="UNIQUE_ID" Time="124">
  <CurrentStart Value="124" />
  <CurrentEnd Value="128" />
  <Loop>
    <LoopStart Value="0" />
    <LoopEnd Value="4" />
    <LoopOn Value="true" />
  </Loop>
  <SampleRef>
    <FileRef>
      <RelativePath Value="Samples/Imported/kick.wav" />
      <Path Value="/absolute/path/to/kick.wav" />
      <Type Value="2" />
    </FileRef>
  </SampleRef>
</AudioClip>
```

### Track Naming Patterns (from 23 templates)

**Most common track names across all templates (frequency):**
```
DRUMS:        kick (20), clap/claps (18), hat (8), ride/rides (22), perc/percu (18), 
              snare (10), shakers (6), cymbal (7), top (11)
BASS:         bass (8), sub/sub bass (13), bass pad (4), lows (4)
LEADS:        lead/leads (16), stab (7), synth/synt (5), acid (8)
PADS:         pad (6), atmos (12), strings (4)
FX:           fx (15), crash (10), impact (5), riser (5), fill (6), 
              snare roll (5), reverse (5), noise (3)
VOX:          vox/vocal (14)
LOOPS:        loop (14), top loop (3), drum loop (4)
```

**Trance-specific patterns:**
```
KICK:         kick, kick roll, kick fx, kick hat, kick/bass group
BASS:         sub bass, bass pad, mid bass, psy bass, acid driver, off beat sub
LEADS:        lead 1-6, lead midi, pluck, arp, topline, chord stab, acid seq
PADS:         pad 1-2, soft swell, cello, atmo, strings, choir
FX:           crash 1-2, cymbal, reverse cymbal, down sweep, riser, snare roll, fill, 
              trance sweep, stab fx, atmo sweep, impact, big white noise
VOCALS:       vocal fx, stutter vox, ahhh, choir, vocal atmosphere
ACID:         acid 1-7, acid stab, acid pluck, acid fx stabs
```

**Techno-specific patterns:**
```
DRUMS:        dr kik, dr clap, dr ride, dr perc, dr break, drums, top, top 2-3
BASS:         bs, bs sub, bs mid, bs loop, rolling bass, percu bass
LEADS:        ld, ld 1-2, ld acc, stab 0-2, saw, saw stab, melod
PADS:         pd, pd 1, atmos, atmos 2-3, ambiencia
FX:           fx 1-2, fxs, fxs2, fx up, fx down, noise, rumble, groove
HATS:         hat, hat 2-4, hat closed, hat c, hat r, delay hat
PERC:         perc, percu, percu 2, shakers 1-4
```

**Bus/routing patterns (techno):**
```
BUSES:        bus main, bus lo, bus hi, bus music, bus kik, bus dr, bus fx lo/hi,
              bus bs, bus ld, bus pd, bus vox, bus nobass, bus support, bus premaster
SENDS:        A-Return (reverb), parallel compression buses
SIDECHAIN:    sc, kik sc, sidechain trigger
```

## Genre Slider (Continuum)

The `genre` slider (0.0-1.0) controls a **blend**, not a binary choice:

```
genre = 0.0 (pure techno)
├── Use techno template as base
├── BPM: 128 (or 140-150 if hardness >= 0.5)
├── Key: optional/atonal
├── Tracks: minimal melodics, heavy drums/perc/fx
├── Samples: percussive, industrial, dark
└── More Drum Racks, fewer synth plugins

genre = 0.5 (tech-trance hybrid)
├── Merge tracks from both templates
├── BPM: 134 (midpoint)
├── Key: soft preference for matching
├── Tracks: balanced drums + melodics
└── Mix of samples and plugins

genre = 1.0 (pure trance)
├── Use trance template as base
├── BPM: 138 (or 140-150 if hardness >= 0.5)
├── Key: REQUIRED for bass + melodics
├── Tracks: heavy melodics, pads, leads, vocals
├── Samples: atmospheric, euphoric, melodic
└── More Spire/Kontakt, stacked synths for leads
```

**Interpolation rules:**
- Track count for category X = lerp(techno_count, trance_count, genre)
- BPM = lerp(128, 138, genre) + (hardness >= 0.5 ? 12-22 : 0)
- Key strictness = genre (0=ignore, 1=require)
- Sample selection weights shift toward melodic as genre increases

## Arrangement Overview (6-8 min, 192-256 bars)

### Visual Overview
```
BAR:    1    16   32   48   64   80   96   112  128  144  160  176  192  208  224
        |----|----|----|----|----|----|----|----|----|----|----|----|----|----|
SECTION:|<--- INTRO --->|<- BUILD ->|<-- BREAKDOWN -->|<- DROP 1 ->|<- DROP 2 ->|
        |               |           |                 |            |            |
        |               |           |                 |<-- FADEDOWN -->|<- OUTRO ->| END
        
ENERGY: ▁▂▃▄▅▆▅▃▁▂▃▄▅▆▇█▇█▇▆▅▄▃▂▁
        low     build  low  build    PEAK      PEAK   fade        out
```

### Section Summary
| Section | Bars | Duration | Purpose |
|---------|------|----------|---------|
| Intro | 1-32 | ~1 min | DJ mix-in, build elements gradually |
| Buildup | 32-64 | ~1 min | Add bass, tension, riser to breakdown |
| Breakdown | 64-96 | ~1 min | Emotional peak, drums out, melody exposed |
| Drop 1 | 96-128 | ~1 min | Full energy, main hook |
| Drop 2 | 128-160 | ~1 min | Variation, 2nd riff, peak intensity |
| Fadedown | 160-192 | ~1 min | Strip melodics gradually, energy decreasing |
| Outro | 192-224 | ~1 min | DJ mix-out, drums only → silence |

### Detailed Arrangement (8-bar phrases)

```
BAR   BEAT   SECTION         ELEMENTS                                    ENERGY
──────────────────────────────────────────────────────────────────────────────
1     0      intro           +kick                                       ▂
9     32     intro           +closed_hat, +top_loop                      ▃
17    64     intro           +perc, +shakers                             ▃
25    96     intro           +clap, +open_hat, +ride                     ▄
32    124    buildup         +sub_bass, +mid_bass, +atmos                ▅
40    156    buildup         +vocal_chop, +pad(filtered)                 ▅
48    188    buildup         +riser_1(8bar), filter_rising               ▆
56    220    buildup         +snare_roll, riser_continues                ▆
──────────────────────────────────────────────────────────────────────────────
64    252    breakdown       -ALL_DRUMS, +pad(full), +main_riff(filtered)▃
72    284    breakdown       +atmos_sweep, +vocal_atmos, filter_opening  ▃
80    316    breakdown       +strings/choir, tension_building            ▄
88    348    breakdown       +riser_2(8bar), +snare_roll, nearly_open    ▅
──────────────────────────────────────────────────────────────────────────────
96    380    drop1           +ALL_DRUMS, main_riff(OPEN), +crash, +impact█
104   412    drop1           +stabs, +acid, +fill(bar103)                █
112   444    drop1           variation, +fx_hits                         ▇
120   476    drop1           +fill(bar119), tension_for_drop2            ▇
──────────────────────────────────────────────────────────────────────────────
128   508    drop2           +2nd_riff, +lead_2, +crash, +impact         █
136   540    drop2           +plucks, +arps, peak_energy                 █
144   572    drop2           all_elements, maximum_layers                █
152   604    drop2           +downer_hint, energy_plateau                ▇
──────────────────────────────────────────────────────────────────────────────
160   636    fadedown        -leads, +downer, +crash                     ▆
168   668    fadedown        -2nd_riff, -stabs, filter_closing           ▅
176   700    fadedown        -main_riff, -arps                           ▄
184   732    fadedown        -pads, -atmos, bass+drums_only              ▄
──────────────────────────────────────────────────────────────────────────────
192   764    outro           -sub_bass, -mid_bass, +crash                ▃
200   796    outro           -open_hat, -ride                            ▃
208   828    outro           -clap, -perc                                ▂
216   860    outro           -shakers, -top_loop                         ▂
224   892    outro           -closed_hat, kick_only                      ▁
232   924    END             -kick, silence or reverb_tail               ▁
```

### Element Placement Rules

**Drums (bars 1-64, 96-224):**
- Kick: bars 1-64, 96-224 (out during breakdown)
- Hats: bars 9-64, 96-208
- Clap: bars 25-64, 96-208
- Perc: bars 17-64, 96-200
- Ride: bars 25-64, 96-200

**Bass (bars 32-192):**
- Sub: bars 32-64, 96-192
- Mid bass: bars 32-64, 96-184

**Melodics (bars 40-176):**
- Main riff: bars 64-176 (filtered 64-96, open 96-176)
- 2nd riff: bars 128-168
- Pads: bars 40-64, 64-96 (breakdown), 96-160
- Leads: bars 96-160

**FX placement:**
- Crash: every 8-16 bars on beat 1 (phrase starts)
- Riser: 8 bars before major transitions (56-64, 88-96)
- Downer: start of outro sections (160, 192)
- Fill: 1-2 bars before drops (bar 95, 127)
- Impact: beat 1 of drops (96, 128)
- Snare roll: last 4-8 bars of buildups (56-64, 88-96)

## FX Rules

```
crash:  beat_1 of bar [1,9,17,25,32,64,96,112,128,160] (phrase starts)
riser:  ends_on beat_1, duration 4-8 bars, place before [64,96]
downer: starts_on beat_1, duration 2-4 bars, place at [128]
fill:   1-4 bar drum_dropout before beat_1 of [104,120] (every 16 bars in drops)
```

## Filter Automation (in scope for v1)

### Accessory Leads & Pads
Low-pass filter automation on accessory elements:

**Tracks to automate:**
- Accessory leads (lead 2-4)
- Pads (pad 1-3)
- Atmos tracks
- Strings/choir

**Buildup (bars 32-64):** Filter opens as tension builds
```
bar 32: cutoff = 400 Hz (filtered, muffled)
bar 64: cutoff = 20000 Hz (fully open for breakdown reveal)
```

**Fadedown (bars 160-192):** Filter closes as energy decreases
```
bar 160: cutoff = 20000 Hz (open)
bar 192: cutoff = 400 Hz (filtered, fading away)
```

### Main Riff
Separate filter automation for the main melodic hook:

**Breakdown (bars 64-96):** Main riff filters UP (the big reveal)
```
bar 64: cutoff = 200 Hz (very filtered, teasing the melody)
bar 96: cutoff = 20000 Hz (WIDE OPEN for drop impact)
```

**Drop 2 / Fadedown (bars 144-176):** Main riff filters DOWN
```
bar 144: cutoff = 20000 Hz (full open)
bar 176: cutoff = 400 Hz (filtered out before removal)
```

Implementation: Add `<AutomationEnvelope>` to tracks with breakpoints at these bars.

## Track Categories

```
DRUMS     = [kick, clap, closed_hat, open_hat, ride, perc]  # key_sensitive=false, one-shots or loops
BASS      = [sub_bass, mid_bass]                            # key_sensitive=true
MELODIC   = [lead, pad]                                     # key_sensitive=true
ATMOS     = [atmos]                                         # key_sensitive=true, pads/vocals/glitch fx with reverb/delay
FX        = [riser, downer, crash, fill]                    # key_sensitive=false
VOX       = [vocal]                                         # key_sensitive=sometimes
```

## Sample Types

**Loops** (name contains "loop"):
- Place directly on timeline as AudioClip
- Ready to use, pre-composed patterns
- Preferred for drums when available

**One-shots** (kicks, claps, crashes, hats without "loop"):
- Must be loaded into Drum Rack
- Triggered via MIDI pattern
- More work but more control

**Strategy:** Prefer loops for v1, fall back to one-shots + Drum Rack when no loops available.

## Riffs (main_riff, 2nd_riff)

The main and 2nd riffs are the **identity of the track** — cannot use random samples.

**v1 approach:** Query for `lead` samples, user may need to swap/curate
**v2 approach:** Create placeholder MIDI tracks with Serum2/Spire loaded, user writes the riff

For trance (genre >= 0.5): Leads often use stacked MIDI synths for power
For techno (genre < 0.5): Leads can be samples or MIDI, more flexibility

## Sample Query

```rust
// Helper: Convert key like "A Minor" to filename patterns ["Am", "Amin", "A_min", "A-min"]
// 
// IMPORTANT: Bare note names (e.g., "F", "C#") with no quality indicator DEFAULT TO MINOR
// because most electronic/trance/techno music is in minor keys.
// Examples:
//   "RY_ELYSIUM_SERUM_LEAD LOOP_002_F_132bpm" → F = F minor
//   "Full On Lead Loop 8 C# 140 BPM" → C# = C# minor
//
fn key_to_filename_patterns(key: &str) -> Vec<String> {
    // key format: "A Minor", "C Major", "F# Minor", "Bb Major"
    let parts: Vec<&str> = key.split_whitespace().collect();
    let root = parts[0];  // "A", "C", "F#", "Bb"
    let quality = parts.get(1).unwrap_or(&"Major");
    
    // Normalize root for filenames: "F#" -> "F#" or "Fs", "Bb" -> "Bb" or "Bf"
    let root_variants = vec![
        root.to_string(),
        root.replace("#", "s"),   // F# -> Fs (some packs use this)
        root.replace("b", "f"),   // Bb -> Bf (rare)
    ];
    
    let mut patterns = vec![];
    for r in &root_variants {
        if quality.to_lowercase() == "minor" {
            // Minor key patterns
            patterns.push(format!("{}m", r));        // Am, Cm, F#m
            patterns.push(format!("{}min", r));      // Amin, Cmin
            patterns.push(format!("{}_min", r));     // A_min
            patterns.push(format!("{}-min", r));     // A-min
            patterns.push(format!("{} min", r));     // "A min"
            patterns.push(format!("{} Minor", r));   // "A Minor" (rare)
            // ALSO match bare note — defaults to minor in electronic music
            // e.g., "_F_" in "LOOP_002_F_132bpm" = F minor
            // Use word boundaries: underscore, space, or start/end
            patterns.push(format!("_{}_", r));       // _F_, _C#_
            patterns.push(format!(" {} ", r));       // " F ", " C# "
            patterns.push(format!("[{}]", r));       // [F], [C#] (bracket notation)
        } else {
            // Major key patterns — ONLY match explicit major indicators
            // Bare notes default to minor, so don't match "C" for C Major
            patterns.push(format!("{}maj", r));      // Cmaj, Amaj
            patterns.push(format!("{}_maj", r));     // C_maj
            patterns.push(format!("{}-maj", r));     // C-maj
            patterns.push(format!("{} maj", r));     // "C maj"
            patterns.push(format!("{} Major", r));   // "C Major" (rare)
            patterns.push(format!("{}M", r));        // CM, AM (uppercase M = major)
        }
    }
    patterns
}

// Genre enum with specific characteristics
// Sources: 
//   - https://www.vipzone-samples.com/en/trance-vs-techno/
//   - https://definitionofhardtechno.com/blogs/news/modern-schranz-pack
enum Genre {
    Techno,   // 120-140 BPM, repetitive beats, industrial sounds, hypnotic rhythm
    Schranz,  // 145-165 BPM, distorted kicks + separate drives/rumbles, relentless
    Trance,   // 130-160 BPM, uplifting melodies, emotional, euphoric
}

impl Genre {
    fn default_bpm(&self) -> u32 {
        match self {
            Genre::Techno => 132,
            Genre::Schranz => 155,
            Genre::Trance => 140,
        }
    }
    
    fn bpm_range(&self) -> (u32, u32) {
        match self {
            Genre::Techno => (120, 140),   // Per vipzone-samples
            Genre::Schranz => (145, 165),  // Per definitionofhardtechno
            Genre::Trance => (130, 160),   // Per vipzone-samples (uplifting on higher end)
        }
    }
    
    fn keywords(&self) -> &[&str] {
        match self {
            Genre::Techno => &[
                "techno", "tech", "warehouse", "berlin", "underground", "minimal",
                "hypnotic", "driving", "industrial", "modular", "analogue", "detroit"
            ],
            Genre::Schranz => &[
                "schranz", "hard techno", "hardtechno", "industrial", "distorted",
                "aggressive", "relentless", "pounding", "gabber", "rave",
                "145", "150", "155", "160", "165", "dirty", "saturated", "abrasive",
                // Pioneers (German scene)
                "o.b.i", "chris liebing", "stigmata", "arkus p", "robert natus", 
                "viper xxl", "leo laker", "sven wittekind", "dj rush", "boris s",
                // Modern artists
                "klangkuenstler", "pet duo", "a.n.i", "nikolina", "noise not war",
                // Labels
                "elektrabel", "schranz total"
            ],
            Genre::Trance => &[
                "trance", "uplifting", "progressive", "euphoric", "psy", "goa",
                "melodic", "epic", "anthem", "emotional", "vocal", "classic",
                "armin", "tiesto", "above beyond"
            ],
        }
    }
    
    fn description(&self) -> &str {
        match self {
            Genre::Techno => "Repetitive beats, industrial sounds, hypnotic rhythm. More focused on creating a powerful and relentless energy than emotional melodies.",
            Genre::Schranz => "The 'dirty' sound — it scrapes, saturates, distorts. Born from Chris Liebing describing abrasive textures: 'that schranzt'. NOT about speed, about GRAIN. Kicks + separate drives/rumbles. Balance: too much distortion = groove disappears; too little = loses edge.",
            Genre::Trance => "Uplifting melodies, emotional resonance, euphoria. Rich chord progressions, arpeggios, atmospheric soundscapes. Traditional song structure with buildup and climax.",
        }
    }
    
    fn key_strictness(&self) -> KeyStrictness {
        match self {
            Genre::Techno => KeyStrictness::Prefer,    // Key optional, atonal OK
            Genre::Schranz => KeyStrictness::Ignore,   // Atonal, distorted, key irrelevant
            Genre::Trance => KeyStrictness::Require,   // Must match key for melodics
        }
    }
    
    fn bass_type(&self) -> &str {
        match self {
            Genre::Techno => "rolling",      // Rolling sub + mid bass
            Genre::Schranz => "drive",       // Separate drives/rumbles that complement kick
            Genre::Trance => "melodic",      // Melodic sub + offbeat mid
        }
    }
}

// === SCHRANZ PRODUCTION STRUCTURE ===
// Based on O.B.I. & Noise Not War's "Modern Schranz Signature Pack" methodology
//
// Schranz is NOT just "kick = bassline". It's about BALANCE between:
// - Kicks: Sharp, cutting, distorted but controlled
// - Bass/Drives: Separate rumbling low-end, rolls, and drives that complement the kick
// - Groove: Repetition, shuffled hats, industrial textures
//
// Key insight: "Too much distortion and the groove disappears; too little and the track loses its edge"
//
// Schranz track structure:
// 1. KICKS - The sharp transient, often layered (kick + drive + roll + rumble)
// 2. BASS/DRIVES - Separate from kick! Deep rumbling low-end, drives that fill between kicks
// 3. DRUM LOOPS - Shuffled hats, percussive rhythms, industrial textures
// 4. SYNTHS - Rave stabs, haunting sequences, melodic schranz themes
// 5. RAP VOCALS - Shouts, ad-libs, rhythmic vocal loops (145-165 BPM)
//
struct SchranzConfig {
    kicks: u32,                 // 1-3, main kicks (sharp, cutting)
    drives: u32,                // 1-3, drive/rumble loops (separate from kick!)
    rolls: u32,                 // 0-2, kick rolls for fills
    drum_loops: u32,            // 2-4, shuffled hats, industrial percs
    synths: u32,                // 1-3, rave stabs, sequences
    melodic_themes: u32,        // 0-2, melodic schranz themes
    rap_vocals: u32,            // 0-2, shouts, ad-libs
    distortion_level: f32,      // 0.5-1.0, balance between grit and groove
}

// Pseudocode - actual implementation in Rust
fn select_samples(target_bpm: u32, target_key: Option<&str>, genre: Genre, hardness: f32, 
                  global_keywords: &[&str], element_keywords: &HashMap<&str, &str>) {
    // genre:    Techno, Schranz, or Trance
    // hardness: 0.0=regular, 1.0=hard (Schranz is always hard)
    // target_key: e.g. "C Minor", "F# Minor", or None for atonal
    // global_keywords: user-selected vibe keywords ["Industrial", "Dark", etc.]
    // element_keywords: per-element keywords {"kick": "rumble", "bass": "arped", etc.}
    // CONSTRAINT: format must be 'wav' (Ableton warp works best with WAV)
    
    // IMPORTANT: directory column contains sample pack/folder names which are useful
    // for matching keywords and style. Match keywords against BOTH name AND directory.
    // e.g., directory="/Users/wizard/Samples/Loopmasters_Trance_Essentials/Kicks/"
    //       contains "Loopmasters", "Trance", "Essentials", "Kicks" as implicit metadata
    
    // Categories that are one-shots (no BPM in filename expected)
    let ONE_SHOTS = [
        // Drums
        "kick", "clap", "closed_hat", "open_hat",
        // Melodic hits
        "stab", "pluck",
        // FX (most are one-shots)
        "fx_crash", "fx_impact", "fx_explosion", "fx_whoosh", "fx_laser", 
        "fx_reverse", "fx_sub_drop", "fx_misc",
        // Atmos
        "noise", "texture",
        // Vocal
        "vocal_adlib",
    ];
    
    // Categories that need key matching (when target_key provided)
    let KEY_SENSITIVE = [
        // Bass
        "sub_bass", "mid_bass",
        // Melodic
        "lead", "pad", "arp", "pluck", "stab", "acid",
        // Atmos (sometimes)
        "atmos",
        // Vocal
        "vocal", "vocal_phrase",
    ];
    
    // Categories where loops are preferred (place directly on timeline)
    let PREFER_LOOPS = [
        // Drums
        "kick", "clap", "closed_hat", "open_hat", "ride", "perc",
        // Bass
        "mid_bass",
        // Melodic
        "arp", "acid",
        // FX (rhythmic/timed)
        "fx_glitch", "fx_fill", "fx_riser", "fx_downer", "fx_swell",
        // Vocal
        "vocal_chop",
    ];
    
    let patterns = hashmap! {
        "kick"       => r"(?i)kick|kik|bd",
        "clap"       => r"(?i)clap|clp|snare|snr",
        "closed_hat" => r"(?i)closed|chh|ch[_-]",
        "open_hat"   => r"(?i)open|ohh|oh[_-]",
        "ride"       => r"(?i)ride|rd[_-]",
        "perc"       => r"(?i)perc|tom|conga|bongo|shaker|rim|click|tambourine",
        
        // === SCHRANZ-SPECIFIC ===
        // Schranz has SEPARATE kick and bass/drive elements (not the same!)
        // Kicks: sharp, cutting transients
        // Drives/Rumbles: deep low-end that complements but is separate from kick
        "schranz_kick"   => r"(?i)schranz.*kick|kick.*schranz|hard.*techno.*kick",
        "schranz_drive"  => r"(?i)drive|rumble|roll|schranz.*bass|low.*end",
        "schranz_roll"   => r"(?i)kick.*roll|roll.*kick|schranz.*roll",
        
        // === BASS ===
        "sub_bass"   => r"(?i)sub|808|bass.*sub|low.*end",
        "mid_bass"   => r"(?i)bass|reese|hoover|wobble",
        
        // === MELODIC ===
        "lead"       => r"(?i)lead|ld[_-]|synth|riff",
        "pad"        => r"(?i)pad|string|chord|evolve",
        "arp"        => r"(?i)arp|sequence|seq[_-]|pattern",
        "pluck"      => r"(?i)pluck|pizz|picked|marimba|key",
        "stab"       => r"(?i)stab|brass|chord.*hit|organ",
        "acid"       => r"(?i)acid|303|squelch|resonant|tb",
        
        // === ATMOS ===
        "atmos"      => r"(?i)atmos|ambient|drone|soundscape|background",
        "texture"    => r"(?i)texture|foley|field|organic|nature",
        "noise"      => r"(?i)noise|white|pink|static|hiss|crackle",
        "tape"       => r"(?i)tape|vinyl|lo-?fi|cassette|saturate|warm",
        
        // === FX (hierarchy) ===
        // FX > Transitions
        "fx_riser"   => r"(?i)riser|rise|sweep.*up|uplifter|build.*up|tension|ascend",
        "fx_downer"  => r"(?i)downer|down|fall|sweep.*down|drop|descend",
        "fx_swell"   => r"(?i)swell|grow|bloom|expand",
        // FX > Impacts
        "fx_crash"   => r"(?i)crash|cymbal|china|splash",
        "fx_impact"  => r"(?i)impact|hit|slam|boom|thud|punch",
        "fx_explosion" => r"(?i)explo|burst|detonate|blast",
        // FX > Rhythmic
        "fx_fill"    => r"(?i)fill|roll|buildup|break|snare.*roll",
        "fx_glitch"  => r"(?i)glitch|stutter|chop|slice|granular|buffer|digital|bit",
        // FX > Tonal
        "fx_whoosh"  => r"(?i)whoosh|swish|swoosh|air|breath",
        "fx_laser"   => r"(?i)laser|zap|beam|pew|sci-?fi|blaster",
        "fx_reverse" => r"(?i)reverse|rev[_-]|backwards|reversed",
        // FX > Misc
        "fx_sub_drop" => r"(?i)sub.*drop|808.*drop|bass.*drop|low.*drop",
        "fx_white_noise" => r"(?i)white.*noise|noise.*sweep|filtered.*noise",
        "fx_vocal"   => r"(?i)fx.*vox|vocal.*fx|processed.*vocal|vocal.*chop",
        "fx_misc"    => r"(?i)fx|effect|sfx|transition|cinematic",
        
        // === VOCAL ===
        "vocal"      => r"(?i)vox|vocal|voice|spoken|chant|acapella",
        "vocal_chop" => r"(?i)vocal.*chop|chop.*vocal|vox.*chop|slice.*vocal",
        "vocal_phrase" => r"(?i)vocal.*phrase|phrase|spoken|speech|word",
        "vocal_adlib" => r"(?i)adlib|shout|scream|yeah|hey|oh",
    };
    
    for (category, base_pattern) in patterns {
        // Build query with multi-factor scoring:
        // 1. Base category pattern (e.g., "kick|kik|bd")
        // 2. GENRE MATCH — highest priority! Sample/pack names contain genre info
        // 3. Element keyword if selected (e.g., "rumble" for kick)
        // 4. Global keywords (e.g., "industrial", "dark")
        // 5. BPM and key matching
        
        let element_kw = element_keywords.get(category);  // e.g., "rumble"
        
        // Genre keywords to match in sample name and directory
        // These appear in sample names like "Trance_Lead_Am.wav" or dirs like "/Loopmasters_Techno/"
        let TECHNO_KEYWORDS: &[&str] = &[
            "techno", "tech", "warehouse", "berlin", "underground", "minimal",
            "hypnotic", "driving", "peak", "industrial", "modular", "analogue"
        ];
        let SCHRANZ_KEYWORDS: &[&str] = &[
            "schranz", "hardtechno", "hard techno", "hard-techno", "industrial",
            "distorted", "gabber", "rave", "pounding", "relentless", "crushing",
            "150", "155", "160", "elektrabel", "chris liebing", "frank kvitta",
            "sven wittekind", "amok", "commander tom"
        ];
        let TRANCE_KEYWORDS: &[&str] = &[
            "trance", "uplifting", "progressive", "euphoric", "psy", "goa",
            "melodic", "epic", "anthem", "emotional", "vocal", "classic"
        ];
        
        // Hardness keywords — pack names like "Hard_Techno_Essentials" or "Hardstyle_Kicks"
        let HARD_KEYWORDS: &[&str] = &[
            "hard", "hardcore", "hardstyle", "industrial", "gabber", "distorted",
            "aggressive", "dark", "raw", "acid", "peak", "rave", "schranz",
            "crushing", "pounding", "relentless"
        ];
        let SOFT_KEYWORDS: &[&str] = &[
            "soft", "deep", "minimal", "ambient", "chill", "mellow", "smooth",
            "warm", "lush", "gentle", "subtle", "atmospheric", "downtempo"
        ];
        
        // === SAMPLE PACK MANUFACTURERS / LABELS ===
        // These are strong signals for genre + hardness. Match against directory.
        // Format: (pattern, genre_score, hardness_score)
        //   genre_score:    -1.0 = techno, +1.0 = trance, 0.0 = neutral
        //   hardness_score: -1.0 = soft,   +1.0 = hard,   0.0 = neutral
        let MANUFACTURER_SIGNALS: &[(&str, f32, f32)] = &[
            // === HARD DANCE / HARD TRANCE LABELS ===
            ("Tidy",              0.7,  0.9),   // Tidy Trax — "world's #1 Hard Dance label", hard house/trance
            ("Full On",           0.9,  0.5),   // Full On — psy/uplifting trance
            ("Vandit",            0.9,  0.3),   // Paul van Dyk's label — trance
            ("Armada",            0.7,  0.0),   // Armada Music — trance/progressive
            ("Anjuna",            0.8,  0.0),   // Anjunabeats — trance/progressive
            ("FSOE",              0.9,  0.3),   // Future Sound of Egypt — uplifting
            ("Blackhole",         0.8,  0.2),   // Black Hole Recordings — trance
            ("Grotesque",         0.8,  0.4),   // RAM's label — trance
            ("WAO138",            0.9,  0.6),   // Aly & Fila — uplifting/tech
            ("Kearnage",          0.9,  0.7),   // Bryan Kearney — tech trance
            ("Subculture",        0.8,  0.5),   // John O'Callaghan — tech trance
            ("Outburst",          0.8,  0.6),   // Mark Sherry — tech trance
            ("VII",               0.8,  0.4),   // Simon Patterson — tech trance
            ("Pure Trance",       0.9,  0.3),   // Solarstone — pure trance
            ("Damaged",           0.7,  0.8),   // Jordan Suckley — hard trance
            
            // === SCHRANZ / HARD TECHNO LABELS ===
            // Schranz = "dirty", saturated, abrasive grain (Chris Liebing origin)
            // genre_score: -1.0 (techno side) with hardness 1.0
            //
            // Sample pack companies
            ("Definition of Hard Techno", -1.0, 1.0), // O.B.I. & Noise Not War packs
            ("definitionofhardtechno", -1.0, 1.0),
            //
            // Schranz pioneers (German scene, late 90s/2000s)
            ("Chris Liebing",    -1.0,  0.95),  // Coined "schranzt", Stigmata label
            ("Stigmata",         -1.0,  0.95),  // Chris Liebing's label
            ("Arkus P",          -1.0,  1.0),   // OG schranz
            ("Robert Natus",     -1.0,  1.0),   // OG schranz
            ("Viper XXL",        -1.0,  1.0),   // OG schranz
            ("Leo Laker",        -1.0,  1.0),   // OG schranz
            ("Sven Wittekind",   -1.0,  1.0),   // OG schranz
            ("DJ Rush",          -1.0,  0.9),   // Hard techno/schranz
            ("Boris S",          -1.0,  1.0),   // "This is not religious"
            ("Frank Kvitta",     -1.0,  1.0),
            //
            // Modern schranz artists
            ("O.B.I.",           -1.0,  1.0),   // Modern schranz pioneer
            ("Noise Not War",    -1.0,  1.0),   // Modern schranz
            ("Klangkuenstler",   -1.0,  0.95),  // "Emo schranz", big productions
            ("Pet Duo",          -1.0,  0.95),  // Modern German scene
            ("A.N.I",            -1.0,  1.0),   // Modern schranz
            ("Nikolina",         -1.0,  0.95),  // Modern schranz
            ("TRIPTYKH",         -1.0,  1.0),
            //
            // Labels
            ("Elektrabel",       -1.0,  1.0),   // Chris Liebing's hard techno label
            ("Schranz Total",    -1.0,  1.0),   // Classic schranz label
            ("Schranz",          -1.0,  1.0),   // Generic keyword
            ("Hardtechno",       -1.0,  1.0),
            ("Hard Techno",      -1.0,  1.0),
            ("Amok",             -1.0,  1.0),
            ("Nachtstrom",       -1.0,  0.95),  // German hard techno
            ("MB Elektronics",   -1.0,  0.9),
            
            // === TECHNO LABELS ===
            ("Drumcode",         -0.9,  0.5),   // Adam Beyer — techno
            ("Filth on Acid",    -0.8,  0.7),   // Reinier Zonneveld — hard techno
            ("Exhale",           -0.7,  0.7),   // Amelie Lens — hard techno
            ("KNTXT",            -0.8,  0.6),   // Charlotte de Witte — techno
            ("Possession",       -0.7,  0.85),  // Industrial techno
            ("Perc Trax",        -0.8,  0.8),   // Perc — industrial techno
            ("Mord",             -0.9,  0.85),  // Bas Mooy — hard techno
            ("Planet Rhythm",    -0.8,  0.5),   // Glenn Wilson — techno
            ("Soma",             -0.7,  0.3),   // Slam — techno
            ("Tresor",           -0.8,  0.3),   // Berlin techno
            ("Ostgut Ton",       -0.9,  0.4),   // Berghain — techno
            ("CLR",              -0.9,  0.7),   // Chris Liebing — techno/schranz crossover
            ("Tronic",           -0.7,  0.4),   // Christian Smith — techno
            ("Bedrock",          -0.6,  0.2),   // John Digweed — progressive/techno
            ("Cocoon",           -0.7,  0.3),   // Sven Väth — techno
            ("Minus",            -0.8,  0.2),   // Richie Hawtin — minimal techno
            ("M_nus",            -0.8,  0.2),   // Richie Hawtin — minimal techno
            
            // === SAMPLE PACK COMPANIES ===
            ("Loopmasters",       0.0,  0.0),   // Neutral — all genres
            ("Splice",            0.0,  0.0),   // Neutral — all genres
            ("Sample Magic",      0.0,  0.0),   // Neutral — all genres
            ("Vengeance",         0.0,  0.3),   // EDM/harder sounds
            ("Black Octopus",     0.0,  0.0),   // Various genres
            ("Ghosthack",         0.0,  0.2),   // EDM focused
            ("Industrial Strength", -0.5, 0.9), // Hard techno/industrial
            ("Singomakers",       0.0,  0.0),   // Various genres
            ("Function Loops",    0.0,  0.0),   // Various genres
            ("Producer Loops",    0.0,  0.0),   // Various genres
            ("Zenhiser",         -0.3,  0.3),   // Techno focused
            ("Freshly Squeezed",  0.5,  0.5),   // Trance/hard dance
            ("Mutekki",          -0.6,  0.4),   // Tech house/techno
            ("Toolroom",         -0.4,  0.2),   // Tech house/techno
            ("Revealed",          0.3,  0.4),   // Big room/EDM
            ("Spinnin",           0.2,  0.2),   // EDM/progressive
            
            // === ARTIST PACKS ===
            ("Allen Watts",       0.9,  0.5),   // Tech trance
            ("Bryan Kearney",     0.9,  0.7),   // Tech trance
            ("Simon Patterson",   0.8,  0.5),   // Tech trance  
            ("John Askew",        0.8,  0.7),   // Tech trance
            ("Sean Tyas",         0.8,  0.5),   // Tech trance
            ("Will Atkinson",     0.8,  0.6),   // Tech trance
            ("Adam Ellis",        0.9,  0.4),   // Uplifting trance
            ("ReOrder",           0.9,  0.4),   // Uplifting trance
            ("Sneijder",          0.8,  0.6),   // Tech trance
            ("Factor B",          0.9,  0.3),   // Uplifting trance
            ("Adam Beyer",       -0.9,  0.5),   // Techno
            ("Charlotte de Witte", -0.8, 0.7),  // Hard techno
            ("Amelie Lens",      -0.7,  0.7),   // Hard techno
            ("Reinier Zonneveld", -0.8, 0.7),   // Hard techno
            ("UMEK",             -0.7,  0.5),   // Techno
            ("Enrico Sangiuliano", -0.7, 0.5), // Techno
            ("Spartaque",        -0.8,  0.6),   // Hard techno
            ("Alignment",        -0.8,  0.8),   // Hard techno
            ("DYEN",             -0.7,  0.6),   // Melodic techno
            ("Afterlife",        -0.5,  0.2),   // Melodic techno
            ("Tale of Us",       -0.5,  0.1),   // Melodic techno
        ];
        
        // NOTE: Match against both `name` AND `directory` columns
        // The directory contains sample pack/folder names which are useful metadata
        // e.g., directory="/Samples/Loopmasters_Trance_Essentials/Kicks/" has genre info
        let mut query = format!(
            "SELECT path, name, key_name, directory FROM audio_samples 
             WHERE (name REGEXP '{}' OR directory REGEXP '{}') AND format = 'WAV'",
            base_pattern, base_pattern
        );
        
        // Add element-specific keyword boost (match against name OR directory)
        if let Some(kw) = element_kw {
            // e.g., "%rumble%" matches "Rumble_Kick.wav" OR "/Rumble_Pack/kicks/"
            query += &format!(" AND (name LIKE '%{}%' OR directory LIKE '%{}%')", kw, kw);
        }
        
        // BPM matching — parse from filename, NOT from bpm column (mostly empty)
        // Common patterns: "Bass_Loop_140_Am.wav", "Kick[138]_hard.wav", "Lead 145 bpm.wav"
        if !ONE_SHOTS.contains(&category) {
            // Match samples with target BPM ±5 in filename
            // Regex: look for 3-digit number 120-160 in name
            let bpm_lo = target_bpm.saturating_sub(5);
            let bpm_hi = target_bpm + 5;
            let bpm_patterns: Vec<String> = (bpm_lo..=bpm_hi)
                .map(|b| format!("name LIKE '%{}%'", b))
                .collect();
            query += &format!(" AND ({})", bpm_patterns.join(" OR "));
        }
        
        // Key matching — parse from filename, NOT from key_name column (mostly empty)
        // Common patterns in filenames:
        //   "Am", "Cm", "F#m", "Bbm" = minor keys
        //   "Amin", "Cmin", "Fmin"   = minor keys (spelled out)
        //   "C", "G", "Amaj", "Cmaj" = major keys
        //   "A Minor", "C Major"     = full names (rare)
        // Examples: "BassLoop_Reeeeze_142_Cm_PL", "Synth Chord Pad Cosmic Fmin", "Keys[80] Am Descolado"
        //
        // Key filename patterns to match target key (e.g., target = "A Minor"):
        //   root = "A", minor patterns = ["Am", "Amin", "A min", "A minor", "A-min"]
        //   For "C Major": ["C", "Cmaj", "C maj", "C major", "C-maj"] (but NOT "Cm"!)
        if let Some(key) = target_key {
            if KEY_SENSITIVE.contains(&category) {
                // Parse target key into root + quality
                // key format: "A Minor", "C Major", "F# Minor", etc.
                let key_patterns = key_to_filename_patterns(key);
                // key_patterns = ["Am", "Amin", "A_min", "A-min", "A min"] for "A Minor"
                
                if genre >= 0.5 {  // Trance: require key match in filename
                    let key_conditions: Vec<String> = key_patterns.iter()
                        .map(|p| format!("name LIKE '%{}%'", p))
                        .collect();
                    query += &format!(" AND ({})", key_conditions.join(" OR "));
                }
                // Techno: handled in ORDER BY below (prefer but don't require)
            }
        }
        
        // === MULTI-FACTOR SCORING ORDER BY ===
        // Priority: genre_match > hardness_match > key_match > global_keywords > random
        // Sample/pack names contain critical style info — weight heavily!
        let mut order_clauses: Vec<String> = vec![];
        
        // 1. GENRE MATCH (highest weight) — "Trance_Vol_99" or "Berlin_Techno_Pack"
        let genre_kws = if genre >= 0.5 { TRANCE_KEYWORDS } else { TECHNO_KEYWORDS };
        let genre_pattern = genre_kws.join("|");
        order_clauses.push(format!(
            "CASE WHEN name REGEXP '(?i){}' OR directory REGEXP '(?i){}' THEN 0 ELSE 10 END",
            genre_pattern, genre_pattern
        ));
        
        // 2. HARDNESS MATCH (very high weight) — "Hard_Techno_Essentials" vs "Deep_Minimal"
        let hardness_kws = if hardness >= 0.5 { HARD_KEYWORDS } else { SOFT_KEYWORDS };
        let hardness_pattern = hardness_kws.join("|");
        order_clauses.push(format!(
            "CASE WHEN name REGEXP '(?i){}' OR directory REGEXP '(?i){}' THEN 0 ELSE 8 END",
            hardness_pattern, hardness_pattern
        ));
        
        // 3. KEY MATCH (for techno — prefer but don't require)
        // Match key patterns in filename (not key_name column)
        if let Some(key) = target_key {
            if KEY_SENSITIVE.contains(&category) && genre < 0.5 {
                let key_patterns = key_to_filename_patterns(key);
                let key_regex = key_patterns.join("|");
                order_clauses.push(format!(
                    "CASE WHEN name REGEXP '(?i){}' THEN 0 ELSE 5 END", key_regex
                ));
            }
        }
        
        // 4. Global keywords (user-selected vibe like "industrial", "euphoric")
        if !global_keywords.is_empty() {
            let kw_pattern = global_keywords.join("|");
            order_clauses.push(format!(
                "CASE WHEN name REGEXP '(?i){}' OR directory REGEXP '(?i){}' THEN 0 ELSE 3 END",
                kw_pattern, kw_pattern
            ));
        }
        
        // 5. Random tiebreaker for variety
        order_clauses.push("RANDOM()".to_string());
        
        query += &format!(" ORDER BY {}", order_clauses.join(", "));
        
        // Execute and yield results...
    }
```

## Trance vs Techno vs Schranz Production Research

Sources:
- https://www.vipzone-samples.com/en/trance-vs-techno/
- https://definitionofhardtechno.com/blogs/news/modern-schranz-pack
- https://deeptechmagazine.com/features/schranz-techno-under-steroids/
- https://blog.landr.com/trance-music-production/

### Comparison Table

| Aspect | Trance | Techno | Schranz |
|--------|--------|--------|---------|
| **BPM** | 130-160 | 120-140 | 145-165 |
| **Focus** | Melody, emotion | Rhythm, hypnosis | Aggression, texture |
| **Structure** | ABAB (breakdown/drop) | Linear, continuous | Linear, relentless |
| **Kick** | Clean, punchy | Rumble kick (reverb tail) | Distorted, layered |
| **Bass** | Offbeat, rolling | Sidechained to kick | SEPARATE drives/rumbles |
| **Kick/Bass Relation** | Separate elements | Often processed together | Separate but complementary |
| **Key Matching** | Required for melodics | Preferred, atonal OK | Often atonal |
| **Breakdowns** | Long, emotional | Minimal/none | Minimal |
| **Melody** | Central, uplifting | Sparse, repetitive | Optional ("emo schranz") |
| **Distortion** | Minimal | Some saturation | Heavy, controlled |
| **Vocals** | Ethereal, emotional | Rare | Rap/shouts (optional) |

---

### 1. TRANCE PRODUCTION

**Core Philosophy:** Melody-driven, emotional, euphoric. Traditional song structure with tension and release.

**Kick & Bass:**
- Four-on-the-floor kick (130-160 BPM)
- "Rolling" or "offbeat" bassline — bass notes hit BETWEEN kick hits
- Kick provides steady rhythm, bass adds movement
- Sub bass typically clean and round

**Structure (ABAB):**
```
INTRO → BREAKDOWN (A) → BUILD-UP → CLIMAX/DROP (B) → BREAKDOWN 2 → BUILD-UP 2 → DROP 2 → OUTRO
```
- **Breakdown:** Strip drums, focus on pads, chords, atmosphere, emotional peak
- **Build-up:** Gradually reintroduce percussion, increase tension (risers, snare rolls)
- **Climax/Drop:** All elements converge, euphoric release

**Melodic Elements:**
- Rich chord progressions (I-V-vi-IV, ii-V-I)
- Arpeggios (16th note patterns common)
- Simple, memorable, emotional leads
- Scales: Major, Minor, Lydian
- Extended chords (7ths, 9ths) for depth
- Suspended chords for tension

**Key Production Techniques:**
- Subtractive arrangement (build full loop, subtract for sections)
- Layered synths for leads
- Heavy use of pads and atmospheric sounds
- Filter automation (LP sweeps during buildups)
- Reverb-heavy vocals and pads

**Typical Arrangement (~7-8 min, 224+ bars):**
```
SECTION          BARS    ELEMENTS
Intro            1-32    Kick, hats, atmospheric pads
Enticement       32-64   +bass, +claps, +arps, energy building
Breakdown 1      64-96   -drums, +pads, +vocals, emotional peak
Build-up         88-96   +riser, +snare roll, filter sweep
Drop/Climax      96-128  Full energy, main melodic hook
Breakdown 2      128-160 Second emotional section
Build-up 2       152-160 Tension rebuild
Drop 2           160-192 Return with variation
Outro            192-224 Strip to beat, DJ-friendly exit
```

---

### 2. TECHNO PRODUCTION

**Core Philosophy:** Rhythm-focused, hypnotic, driving. Linear structure, repetitive grooves.

**Kick & Bass:**
- Heavy, punchy kick with "rumble" sub layer
- Kick and bass often processed TOGETHER as one unit
- Sidechain compression essential for "pumping" effect
- Rolling basslines that complement kick

**The "Rumble" Technique:**
1. Copy kick to new channel
2. Add heavy reverb to kick
3. Apply aggressive EQ (HPF/LPF) and saturation
4. Transform reverb tail into sub-bass rumble
5. Group kick + rumble, compress together as one unit

**Structure (Linear):**
```
INTRO → DEVELOPMENT → VARIATION → DEVELOPMENT → OUTRO
```
- No dramatic breakdowns like trance
- Subtle variations and transitions
- Continuous hypnotic groove
- Elements added/removed gradually over 8-16 bar phrases

**Sound Design:**
- Industrial sounds, metallic textures
- Sparse melodic elements
- Repetitive motifs
- Dark, gritty atmosphere
- Atonal OK (key less strict than trance)

**Key Production Techniques:**
- Phase alignment between kick and bass (check in mono)
- EQ carving (cut kick ~150Hz to let bass through, or vice versa)
- Dynamic EQ triggered when both play
- Saturation to "glue" kick and bass
- High-pass filter at ~35Hz on both

**Typical Arrangement (~6-7 min, 192+ bars):**
```
SECTION          BARS    ELEMENTS
Intro            1-32    Kick, minimal hats, atmosphere
Build            32-64   +bass, +perc, +FX, filter opening
Peak/Drop        64-96   Full drums, synth stabs, driving
Variation        96-128  Modulation, subtle changes, +/- elements
Peak 2           128-160 Return to full energy, variation
Outro            160-192 Strip elements, filter closing
```

---

### 3. SCHRANZ PRODUCTION

**Core Philosophy:** "Dirty" sound — scrapes, saturates, distorts. Balance between aggression and control. NOT about speed, about GRAIN and texture.

**Origin (Chris Liebing, 1997-1999):**
> "That schranzt" — describes abrasive, saturated textures
> "I always loved how the English managed to sound so dirty"
> "Too much distortion and the groove disappears; too little and the track loses its edge"

**Kick & Bass (SEPARATE elements!):**
- **Kicks:** Sharp, cutting transients (NOT the bassline)
- **Drives/Rumbles:** SEPARATE low-end elements that complement kick
- **Rolls:** Kick rolls for fills and transitions
- Kick layering: kick + drive + roll + rumble as SEPARATE tracks

**From O.B.I. & Noise Not War methodology:**
```
1. KICKS (1-3)        — Sharp transients, distorted but controlled
2. DRIVES (1-3)       — Rumbling low-end, SEPARATE from kick
3. ROLLS (0-2)        — Kick rolls for fills
4. DRUM LOOPS (2-4)   — Shuffled hats, industrial percs
5. SYNTHS (1-3)       — Rave stabs, haunting sequences
6. MELODIC THEMES     — Optional, "emo schranz" has emotional elements
7. RAP VOCALS (0-2)   — Shouts, ad-libs (145-165 BPM)
```

**Sound Design:**
- Multi-stage saturation (tape sat for drums, clipping, parallel compression)
- EQ between distortion stages to manage frequency buildup
- Heavy compression on kick layers
- Sidechain bass to kick for pumping
- "Galloping" rhythm patterns (kick on every beat with snare/perc placements)

**Key Production Techniques:**
- Layer multiple kick samples, compress "ultra hard"
- Balance distortion carefully (too much = no groove)
- VA (Virtual Analog) EQ for tight low end
- Transition techniques beyond standard risers
- Industrial textures, metallic percussion

**Typical Arrangement (~6-7 min, 192+ bars):**
```
SECTION          BARS    ELEMENTS
Intro            1-32    Kick, drives, minimal hats
Build            32-64   +percs, +stabs, +FX, intensity rising
Peak             64-96   Full assault, all layers active
Variation        96-128  Slight variation, maintain relentlessness
Peak 2           128-160 Return full energy
Outro            160-192 Strip to kick + drive, DJ-friendly exit
```

---

### Tension/Energy Techniques (All Genres)

**All genres use 8-bar phrases.** Changes happen on phrase boundaries.

**Tension builders:**
- Filter automation (LP cutoff rising)
- Riser FX (white noise, pitched sweeps)
- Snare rolls (increasing density)
- Pitch automation on hats/rides
- Reverb/delay send increases

**Release triggers:**
- Crash on beat 1 of new section
- Filter fully open
- All elements return
- Kick drop (silence before impact)

---

### Sample Selection Keywords by Genre

**Trance:** 
`uplifting, euphoric, melodic, anthem, emotional, epic, progressive, vocal, arpeggiated, supersaw, lush, ethereal, dreamy`

**Techno:** 
`hypnotic, driving, industrial, minimal, warehouse, berlin, underground, dark, rolling, rumble, modular, analogue`

**Schranz:** 
`schranz, hard techno, distorted, industrial, aggressive, relentless, pounding, rave, saturated, dirty, abrasive, gabber`

## Key Rules

```rust
match genre {
    Genre::Trance => {
        // REQUIRE key match for bass + melodic elements
        // Uplifting: 1/16 arp riffs, root changes every 2 bars, pads follow chords
        // Offbeat bassline (bass hits BETWEEN kicks)
        // Clean, punchy kick
        // Dramatic breakdowns with emotional content
        key_strictness: KeyStrictness::Require,
        default_bpm: 140,
        bass_type: "offbeat",  // Bass notes between kick hits
        kick_bass_relation: "separate",
    },
    Genre::Techno => {
        // Key preferred but atonal acceptable
        // Rolling bassline sidechained to kick
        // Kick + rumble often processed together
        // Linear structure, minimal breakdowns
        key_strictness: KeyStrictness::Prefer,
        default_bpm: 132,
        bass_type: "rolling",  // Sidechained to kick
        kick_bass_relation: "together",  // Often processed as one unit
    },
    Genre::Schranz => {
        // Atonal, distorted, key mostly irrelevant
        // Kick and bass/drives are SEPARATE elements
        // "Too much distortion = no groove; too little = loses edge"
        // Balance aggression with control
        key_strictness: KeyStrictness::Ignore,
        default_bpm: 155,
        bass_type: "drive",  // Separate drives/rumbles, NOT kick
        kick_bass_relation: "separate",  // Distinct kick vs drive tracks
        distortion: true,
    },
}
```

## Plugin Fallback

When samples insufficient for trance melodics (pitch stretching artifacts):
- Use Serum2 or Spire for bass/pad/lead
- Generate MIDI in target_key
- Effects: Ableton stock plugins

## Sample Analysis Stage (Pre-processing)

Before generation can work efficiently, all WAV samples must be analyzed and categorized.
Store parsed metadata in normalized SQLite tables for lightning-fast indexed queries.

### Schema

```sql
-- =============================================================================
-- LOOKUP TABLES (populated once, rarely change)
-- =============================================================================

-- Manufacturers/Labels (Tidy Trax, Loopmasters, Drumcode, etc.)
CREATE TABLE sample_pack_manufacturers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,           -- "Tidy Trax", "Loopmasters", "Drumcode"
    genre_score REAL DEFAULT 0.0,        -- -1.0 (techno) to +1.0 (trance)
    hardness_score REAL DEFAULT 0.0,     -- -1.0 (soft) to +1.0 (hard)
    website TEXT,                        -- "https://www.tidytrax.co.uk"
    description TEXT,                    -- "World's #1 Hard Dance label"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_manufacturer_name ON sample_pack_manufacturers(name);
CREATE INDEX idx_manufacturer_genre ON sample_pack_manufacturers(genre_score);
CREATE INDEX idx_manufacturer_hardness ON sample_pack_manufacturers(hardness_score);

-- Sample Packs (Tidy - Bits & Pieces Vol 1, Drumcode Techno Vol 3, etc.)
CREATE TABLE sample_packs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,           -- "Tidy - Bits & Pieces Vol 1"
    manufacturer_id INTEGER REFERENCES sample_pack_manufacturers(id),
    genre_score REAL,                    -- Override manufacturer score if different
    hardness_score REAL,                 -- Override manufacturer score if different
    default_bpm INTEGER,                 -- Pack's default BPM (e.g., 140 for Tidy)
    website TEXT,                        -- Product page URL
    description TEXT,                    -- From web lookup
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pack_name ON sample_packs(name);
CREATE INDEX idx_pack_manufacturer ON sample_packs(manufacturer_id);
CREATE INDEX idx_pack_genre ON sample_packs(genre_score);
CREATE INDEX idx_pack_hardness ON sample_packs(hardness_score);

-- Categories (kick, fx_riser, lead, vocal_chop, etc.)
CREATE TABLE sample_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,           -- "kick", "fx_riser", "lead"
    parent_id INTEGER REFERENCES sample_categories(id),  -- For hierarchy (fx -> fx_riser)
    is_oneshot BOOLEAN DEFAULT FALSE,
    is_key_sensitive BOOLEAN DEFAULT FALSE,
    is_loop_preferred BOOLEAN DEFAULT FALSE,
    pattern TEXT NOT NULL                -- Regex pattern: "(?i)kick|kik|bd"
);

CREATE INDEX idx_category_name ON sample_categories(name);
CREATE INDEX idx_category_parent ON sample_categories(parent_id);

-- =============================================================================
-- SAMPLE ANALYSIS (populated by background job)
-- =============================================================================

CREATE TABLE sample_analysis (
    sample_id INTEGER PRIMARY KEY REFERENCES audio_samples(id),
    
    -- Parsed from filename
    parsed_bpm INTEGER,                  -- e.g., 138 from "Loop_138_Am.wav"
    parsed_key TEXT,                     -- e.g., "A Minor" from "Am", "Amin", "_A_"
    
    -- Foreign keys for fast joins (no string matching at query time!)
    category_id INTEGER REFERENCES sample_categories(id),
    pack_id INTEGER REFERENCES sample_packs(id),
    
    -- Confidence and flags
    category_confidence REAL,            -- 0.0-1.0
    is_loop BOOLEAN,                     -- name contains "loop"
    
    -- Timestamps
    analyzed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Composite indexes for common query patterns
CREATE INDEX idx_analysis_category ON sample_analysis(category_id);
CREATE INDEX idx_analysis_bpm ON sample_analysis(parsed_bpm);
CREATE INDEX idx_analysis_key ON sample_analysis(parsed_key);
CREATE INDEX idx_analysis_pack ON sample_analysis(pack_id);
CREATE INDEX idx_analysis_loop ON sample_analysis(is_loop);

-- THE MONEY QUERY: category + bpm + key + genre/hardness via pack
CREATE INDEX idx_analysis_category_bpm ON sample_analysis(category_id, parsed_bpm);
CREATE INDEX idx_analysis_category_key ON sample_analysis(category_id, parsed_key);
CREATE INDEX idx_analysis_category_bpm_key ON sample_analysis(category_id, parsed_bpm, parsed_key);
```

### Example Queries (Lightning Fast with Indexes)

```sql
-- Find kick loops at 138 BPM from hard trance packs
SELECT s.path, s.name, a.parsed_bpm, p.name as pack_name
FROM audio_samples s
JOIN sample_analysis a ON s.id = a.sample_id
JOIN sample_categories c ON a.category_id = c.id
LEFT JOIN sample_packs p ON a.pack_id = p.id
LEFT JOIN sample_pack_manufacturers m ON p.manufacturer_id = m.id
WHERE c.name = 'kick'
  AND a.is_loop = TRUE
  AND a.parsed_bpm BETWEEN 135 AND 141
  AND (p.genre_score > 0.5 OR m.genre_score > 0.5)      -- Trance-leaning
  AND (p.hardness_score > 0.5 OR m.hardness_score > 0.5) -- Hard
ORDER BY COALESCE(p.hardness_score, m.hardness_score, 0) DESC
LIMIT 10;

-- Find leads in A Minor from any pack
SELECT s.path, s.name, a.parsed_key, p.name as pack_name
FROM audio_samples s
JOIN sample_analysis a ON s.id = a.sample_id
JOIN sample_categories c ON a.category_id = c.id
LEFT JOIN sample_packs p ON a.pack_id = p.id
WHERE c.name = 'lead'
  AND a.parsed_key = 'A Minor'
ORDER BY a.category_confidence DESC
LIMIT 20;
```

### Pack Detection During Analysis

```rust
fn detect_pack(directory: &str) -> Option<(PackId, ManufacturerId)> {
    // 1. Check cache first (most directories map to same pack)
    if let Some(cached) = PACK_CACHE.get(directory) {
        return Some(cached);
    }
    
    // 2. Try to match known pack names from directory path
    //    "/Users/.../Producer loops/Tidy - Bits & Pieces Vol 1/Leads/..."
    //    -> extract "Tidy - Bits & Pieces Vol 1"
    //    -> lookup in sample_packs table
    
    // 3. Try to match manufacturer from directory
    //    "/Users/.../Loopmasters/Techno Essentials/..."
    //    -> "Loopmasters" -> lookup in sample_pack_manufacturers
    
    // 4. Cache result for this directory prefix
    PACK_CACHE.insert(directory_prefix, result);
    
    result
}
```

**Analysis rules:**

```rust
fn analyze_sample(name: &str, directory: &str) -> SampleAnalysis {
    // 1. Parse BPM from filename (look for 3-digit 80-180 range)
    let parsed_bpm = extract_bpm(name);  // "Loop_138_Am" -> Some(138)
    
    // 2. Parse key from filename (default bare notes to minor)
    let parsed_key = extract_key(name);  // "Am", "_F_", "Cmin" -> Some("A Minor"), Some("F Minor"), etc.
    
    // 3. Match category from patterns (check name first, then directory)
    let (category, confidence) = match_category(name, directory);
    
    // 4. Extract genre/hardness signals from name + directory keywords
    let mut genre_signals = extract_genre_signals(name, directory);    // ["techno", "berlin"]
    let mut hardness_signals = extract_hardness_signals(name, directory); // ["hard", "raw"]
    
    // 5. Check manufacturer/label signals (strong indicators!)
    //    e.g., "Tidy" in path = tech trance + hard
    let (mfr_genre, mfr_hardness) = extract_manufacturer_signals(directory);
    // mfr_genre:    -1.0 (techno) to +1.0 (trance)
    // mfr_hardness: -1.0 (soft) to +1.0 (hard)
    
    // 6. Determine flags
    let is_loop = name.to_lowercase().contains("loop");
    let is_oneshot = ONE_SHOTS.contains(&category);
    let is_key_sensitive = KEY_SENSITIVE.contains(&category);
    
    SampleAnalysis { 
        parsed_bpm, parsed_key, category, confidence, 
        is_loop, is_oneshot, is_key_sensitive, 
        genre_signals, hardness_signals,
        manufacturer_genre_score: mfr_genre,      // -1.0 to +1.0
        manufacturer_hardness_score: mfr_hardness // -1.0 to +1.0
    }
}

fn extract_manufacturer_signals(directory: &str) -> (f32, f32) {
    // Check directory path against known manufacturers/labels
    // Returns (genre_score, hardness_score)
    //   genre_score:    -1.0 = techno, +1.0 = trance, 0.0 = neutral
    //   hardness_score: -1.0 = soft,   +1.0 = hard,   0.0 = neutral
    //
    // Example: "/Users/wizard/.../Tidy - Bits & Pieces Vol 1/..." 
    //   -> matches "Tidy" -> (0.8, 0.7) = tech trance, hard
    //
    let dir_lower = directory.to_lowercase();
    for (pattern, genre, hardness) in MANUFACTURER_SIGNALS {
        if dir_lower.contains(&pattern.to_lowercase()) {
            return (*genre, *hardness);
        }
    }
    (0.0, 0.0)  // No manufacturer match
}

// === FUTURE: Web Lookup for Unknown Sample Packs ===
// 
// For sample packs not in MANUFACTURER_SIGNALS, we could:
// 1. Extract pack name from directory path
//    e.g., "/Producer loops/Tidy - Bits & Pieces Vol 1/" -> "Tidy Bits Pieces"
// 2. Search web for "{pack_name} sample pack"
// 3. Parse genre/style from product page description
//    e.g., https://www.tidytrax.co.uk/product/tidy-bits-pieces-studio-pack-1/
//    -> "Hard House, Hard Trance, Hard Dance", "Harder Generation", "140 BPM"
// 4. Cache results in a `sample_pack_metadata` table
//
// This is v2 functionality — for now, rely on MANUFACTURER_SIGNALS lookup
// and keyword matching from directory path.

fn extract_bpm(name: &str) -> Option<u32> {
    // Regex: find 2-3 digit number in typical BPM range
    // Examples:
    //   "Loop_138_Am.wav"                           -> 138
    //   "Kick[140]_hard.wav"                        -> 140
    //   "Lead 145 bpm.wav"                          -> 145
    //   "Tidy1 - Lead Loop 10 - PT3 - 140 BPM - Bm" -> 140
    //   "RY_ELYSIUM_LEAD LOOP_002_F_132bpm"         -> 132
    //
    // Patterns:
    //   "_138_", "[140]", " 145 "     — number with delimiters
    //   "132bpm", "128BPM", "140 BPM" — explicit BPM marker
    //   "- 140 -", "- 138 BPM -"      — dash delimiters (common in pro packs)
    //
    // Range: 80-180 (covers downtempo to hardstyle)
    let re = Regex::new(r"(?x)
        [_\[\s-](\d{2,3})[_\]\s-]     |  # delimited: _138_, [140], -140-
        (\d{2,3})\s*[Bb][Pp][Mm]         # explicit: 132bpm, 140 BPM
    ").unwrap();
    // Return first match in valid range 80-180
}

fn extract_key(name: &str) -> Option<String> {
    // Examples:
    //   "BassLoop_Reeeeze_142_Cm_PL"                -> C Minor
    //   "Tidy1 - Lead Loop 10 - PT3 - 140 BPM - Bm" -> B Minor
    //   "Full On Lead Loop 8 C# 140 BPM"            -> C# Minor (bare note defaults to minor)
    //   "Synth Chord Pad Cosmic Fmin"               -> F Minor
    //   "E-Piano Motion CMaj9"                      -> C Major
    //   "RY_ELYSIUM_LEAD LOOP_002_F_132bpm"         -> F Minor (bare _F_ defaults to minor)
    //
    // Priority order (most specific first):
    // 1. Explicit minor: "Am", "Amin", "A min", "A Minor", "A-min"
    // 2. Explicit major: "Amaj", "A maj", "A Major", "AM" (uppercase M)
    // 3. Bare note (defaults to minor): "_A_", " A ", "- A -", "- A."
    // Handle sharps/flats: "F#m", "Bbm", "C#", "Eb"
    //
    // Note: Bare notes like "C#" or "_F_" default to MINOR (most electronic music is minor)
}

fn match_category(name: &str, directory: &str) -> (String, f32) {
    // Check all category patterns against name first (higher confidence)
    // Fall back to directory matching (lower confidence)
    // Return best match with confidence score
}

fn extract_genre_signals(name: &str, directory: &str) -> Vec<String> {
    let combined = format!("{} {}", name, directory).to_lowercase();
    let mut signals = vec![];
    for kw in TECHNO_KEYWORDS { if combined.contains(kw) { signals.push(kw.to_string()); } }
    for kw in TRANCE_KEYWORDS { if combined.contains(kw) { signals.push(kw.to_string()); } }
    signals
}
```

**Background Job Architecture:**

Analysis runs as a background job since there are 1.5M+ samples:

```rust
// Background job state
struct AnalysisJob {
    id: Uuid,
    status: JobStatus,           // Pending, Running, Paused, Completed, Failed
    total_samples: u64,
    analyzed_count: u64,
    skipped_count: u64,          // Already analyzed, non-WAV, etc.
    failed_count: u64,
    started_at: Option<DateTime>,
    completed_at: Option<DateTime>,
    error: Option<String>,
}

enum JobStatus {
    Pending,
    Running,
    Paused,
    Completed,
    Failed,
}

// Job management
impl AnalysisJob {
    fn start(&mut self) {
        self.status = JobStatus::Running;
        self.started_at = Some(Utc::now());
        
        // Spawn background thread
        std::thread::spawn(move || {
            self.run_analysis();
        });
    }
    
    fn run_analysis(&mut self) {
        // Query unanalyzed WAV samples in batches
        let batch_size = 1000;
        loop {
            let samples = query_unanalyzed_samples(batch_size);
            if samples.is_empty() { break; }
            
            for sample in samples {
                if self.status == JobStatus::Paused { 
                    // Wait for resume
                    while self.status == JobStatus::Paused { 
                        std::thread::sleep(Duration::from_millis(100)); 
                    }
                }
                
                match analyze_sample(&sample.name, &sample.directory) {
                    Ok(analysis) => {
                        insert_analysis(sample.id, analysis);
                        self.analyzed_count += 1;
                    }
                    Err(e) => {
                        log::warn!("Failed to analyze {}: {}", sample.name, e);
                        self.failed_count += 1;
                    }
                }
                
                // Emit progress event to UI every 100 samples
                if self.analyzed_count % 100 == 0 {
                    emit_progress_event(self);
                }
            }
            
            // Commit batch to DB
            commit_batch();
        }
        
        self.status = JobStatus::Completed;
        self.completed_at = Some(Utc::now());
        emit_completion_event(self);
    }
    
    fn pause(&mut self) { self.status = JobStatus::Paused; }
    fn resume(&mut self) { self.status = JobStatus::Running; }
    fn cancel(&mut self) { self.status = JobStatus::Failed; self.error = Some("Cancelled".into()); }
}

fn query_unanalyzed_samples(limit: u32) -> Vec<Sample> {
    // Get WAV samples not yet in sample_analysis
    "SELECT s.id, s.name, s.directory 
     FROM audio_samples s
     LEFT JOIN sample_analysis a ON s.id = a.sample_id
     WHERE s.format = 'WAV' AND a.sample_id IS NULL
     LIMIT ?"
}
```

**UI for analysis job:**
```
┌─────────────────────────────────────────────────────────────┐
│  Sample Analysis                                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Status: Running                                            │
│  Progress: ████████████░░░░░░░░░░░░░░░  456,789 / 1,555,035 │
│                                         (29.4%)             │
│                                                             │
│  Analyzed:  456,789                                         │
│  Skipped:   12,345                                          │
│  Failed:    23                                              │
│                                                             │
│  Elapsed:   12:34                                           │
│  ETA:       ~30 min                                         │
│                                                             │
│                    [ Pause ]  [ Cancel ]                    │
└─────────────────────────────────────────────────────────────┘
```

**When to run:**
- Automatically after sample library scan completes
- User can trigger manually from Settings > Sample Analysis
- Runs incrementally (only analyzes new/unanalyzed samples)
- Persists progress — can resume after app restart
- Low priority thread to not block UI

**Tauri events:**
- `analysis:started` — job started
- `analysis:progress` — periodic updates (every 100 samples)
- `analysis:completed` — job finished
- `analysis:failed` — job failed with error

**Query simplification after analysis:**

```rust
// BEFORE: Parse at query time (slow, complex)
fn select_samples(...) {
    query += " AND name LIKE '%138%' OR name LIKE '%139%' ...";  // BPM parsing
    query += " AND name LIKE '%Am%' OR name LIKE '%Amin%' ...";  // Key parsing
}

// AFTER: Query pre-analyzed data (fast, simple)
fn select_samples(target_bpm: u32, target_key: Option<&str>, ...) {
    let query = "
        SELECT s.path, s.name, a.parsed_bpm, a.parsed_key, a.category
        FROM audio_samples s
        JOIN sample_analysis a ON s.id = a.sample_id
        WHERE a.category = ?
          AND a.parsed_bpm BETWEEN ? AND ?
          AND a.parsed_key IN (?, ?)
          AND a.genre_signals LIKE ?
        ORDER BY ...
    ";
}
```

## Implementation Steps

1. **Analyze samples** → populate `sample_analysis` table
2. Parse template `.als` (gunzip → XML)
3. Query `sample_analysis` for each category
4. Clone template track structure
5. Insert `<AudioClip>` elements at beat positions per arrangement
6. Update `<Tempo>` to target BPM
7. Gzip XML → write `.als`
8. Open in Ableton Live

## Output

**Location:** `~/Desktop` by default, configurable via settings.

**Sample references:** Link samples in-place (no copying). User can run "File > Collect All and Save" in Ableton to bundle.

**Warp mode:** Beats for all samples.

**Track grouping & colors:** Group tracks by category, each group gets its own color:
```
DRUMS   = Color X (kick, clap, hat, ride, perc, etc.)
BASS    = Color Y (sub, mid bass)
LEADS   = Color Z (lead, riff, stab)
PADS    = Color W (pad, atmos, strings)
FX      = Color V (riser, downer, crash, fill)
VOX     = Color U (vocal)
```
All tracks/clips within a group inherit the group's color.

**Plugin presets:** Factory presets for Spire/Serum2 when using MIDI fallback.

`.als` file with:
- Tracks grouped: Drums, Bass, Leads, Pads, FX, Vox
- Samples at bar positions per arrangement
- Project BPM set
- Opens directly in Ableton Live

---

## AI Agent Implementation Checklist

Summary of what an AI agent needs to implement:

### 1. UI Layer (Tauri + HTML/JS)
- [ ] New tab: "ALS Generator"
- [ ] 4-step wizard: Basics → Sound → Preview → Generate
- [ ] Inputs: BPM, Root Note, Mode, Atonal, Genre slider, Hardness slider
- [ ] Global keyword picker (tag cloud/multi-select)
- [ ] Per-element keyword dropdowns (kick, bass, lead, pad, vocal, atmos, fx, perc)
- [ ] **Track count + character per element**:
  - Drums: count (1-8) + character (clean → distorted)
  - Bass: count (1-4) + character (clean → distorted)
  - Leads: count (1-6) + character (smooth → aggressive)
  - Pads: count (1-4) + character (warm → dark)
  - FX: count (2-20) + character (subtle → intense)
  - Vocals: count (0-6) + character (ethereal → chopped)
- [ ] Character slider affects sample query keywords
- [ ] Estimated total tracks display (sum of counts)
- [ ] Sample preview player (play/pause, accept/reject/shuffle) for key samples
- [ ] Progress bar during generation
- [ ] Output path picker (default ~/Desktop)
- [ ] Post-generation: success dialog with Open/Finder/New buttons

### 2. Database Schema (SQLite)
- [ ] `sample_pack_manufacturers` table — labels/companies with genre/hardness scores
- [ ] `sample_packs` table — individual packs with FK to manufacturer
- [ ] `sample_categories` table — hierarchical categories with regex patterns
- [ ] `sample_analysis` table — per-sample parsed data with FKs to categories/packs
- [ ] Composite indexes for fast queries: `(category_id, parsed_bpm, parsed_key)`
- [ ] Seed manufacturers table with ~70 known labels (Tidy, Drumcode, Loopmasters, etc.)
- [ ] Seed categories table with all patterns (kick, fx_riser, lead, etc.)

### 3. Sample Analysis Background Job (Rust)
- [ ] `AnalysisJob` struct with status, progress, counts
- [ ] Background thread for analysis (low priority, non-blocking)
- [ ] Batch processing (1000 samples at a time)
- [ ] `extract_bpm(name)` — parse BPM from filename (80-180 range)
- [ ] `extract_key(name)` — parse key from filename (bare notes default to minor)
- [ ] `match_category(name, directory)` — match against category patterns, return category_id
- [ ] `detect_pack(directory)` — match directory against packs/manufacturers, return pack_id
- [ ] Directory prefix caching for fast pack detection
- [ ] Pause/resume/cancel support
- [ ] Progress persistence (resume after app restart)
- [ ] Tauri events: `analysis:started`, `analysis:progress`, `analysis:completed`, `analysis:failed`
- [ ] Auto-start after sample library scan completes
- [ ] UI: progress bar, pause/cancel buttons, stats (analyzed/skipped/failed)
- [ ] Settings: manual trigger, re-analyze all button

### 3. Backend Logic (Rust)
- [ ] `generate_project_name()` — auto-generate name from inputs
- [ ] `mode_to_query_key()` — convert root+mode to relative major/minor for DB query
- [ ] `select_samples()` — query `sample_analysis` table (not raw filename parsing)
- [ ] Sample preview via existing audio engine
- [ ] Template selection based on genre slider (blend techno/trance templates)

### 5. ALS Generation (Rust)
- [ ] Parse template .als (gunzip → XML)
- [ ] Clone track structure from template
- [ ] Create AudioClip elements at correct beat positions per arrangement
- [ ] Set project tempo
- [ ] Add filter automation envelopes to specified tracks
- [ ] Group tracks by category with colors
- [ ] Reference samples by absolute path (no copying)
- [ ] Set warp mode to Beats
- [ ] Gzip XML → write .als file

### 6. Arrangement Logic
- [ ] 224+ bars (6-8 min)
- [ ] Sections: Intro (1-32) → Buildup (32-64) → Breakdown (64-96) → Drop1 (96-128) → Drop2 (128-160) → Fadedown (160-192) → Outro (192-224)
- [ ] 8-bar phrase structure
- [ ] Element entry/exit points per detailed arrangement table
- [ ] FX placement (crash on phrase starts, risers before transitions, etc.)
- [ ] Filter automation (main riff: up during breakdown, down during fadedown; accessory: up during buildup, down during fadedown)

### 7. Key Data
- [ ] Templates in `docs/templates/` (23 templates, gitignored)
- [ ] Sample DB at `/Users/wizard/Library/Application Support/com.menketechnologies.audio-haxor/audio_haxor.db`
- [ ] Normalized schema: `sample_pack_manufacturers`, `sample_packs`, `sample_categories`, `sample_analysis`
- [ ] Foreign keys for fast indexed joins (no string matching at query time)
- [ ] Only use WAV format samples (`format = 'WAV'`)
- [ ] BPM/key parsed at analysis time, stored with FK to category and pack

### 8. Constraints
- [ ] 30-150 tracks per project (NOT a toy project)
- [ ] Full arrangement with all sections
- [ ] All inputs disabled during generation
- [ ] Progress feedback during generation
- [ ] Support atonal mode (skip key matching)
- [ ] Prefer loop samples over one-shots
- [ ] User previews/approves: kick, sub, mid bass, main lead, main pad

### 9. Multi-Arrangement Mode
- [ ] Option to generate multiple arrangements (songs) in a single `.als` file
- [ ] User specifies count (e.g., 1-10 arrangements per project)
- [ ] Arrangements placed sequentially in arrangement view (Song 1 at bar 1, Song 2 starts after Song 1 ends, etc.)
- [ ] Each arrangement is a complete song (intro → outro) with its own sample selection
- [ ] Markers/locators added at each song boundary for easy navigation
- [ ] Use case: batch-generate variations, DJ sets, or album sketches in one project file
