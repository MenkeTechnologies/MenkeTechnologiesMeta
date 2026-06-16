# ALS Generation Findings

Comprehensive findings from reverse-engineering Ableton Live Set (.als) files for programmatic generation.

## File Format

- **Compression**: ALS files are gzip-compressed XML
- **Decompress**: `gunzip -c file.als > file.xml`
- **Compress**: Use `flate2::write::GzEncoder` with `Compression::default()`

## Version Compatibility

### Live 12 vs Live 11
- Live 12 uses `<MainTrack>`, Live 11 uses `<MasterTrack>`
- Live 12 can open Live 11 files (backward compatible)
- Templates analyzed: 3 Live 12, 20+ Live 11, 2 Live 10

### Version Header
```xml
<Ableton MajorVersion="5" MinorVersion="12.0_12300" SchemaChangeCount="1" 
         Creator="Ableton Live 12.3.7" Revision="...">
```

- `MinorVersion` is internal build number, not user-facing version
- `12.0_12300` = Live 12.3.x series
- `11.0_433` = Live 11.0.x series

## Critical ID Management

### NextPointeeId
```xml
<NextPointeeId Value="300000" />
```
- **MUST be higher than ALL IDs in the file**
- Error if too low: "NextPointeeId is too low: X must be bigger than Y"
- Safe strategy: Set to max_used_id + 100000

### ID Types That Must Be Unique
1. `Pointee Id="X"` - Device/parameter references
2. `AutomationTarget Id="X"` - Automation lane targets  
3. `ModulationTarget Id="X"` - Modulation routing
4. `AudioTrack Id="X"` / `GroupTrack Id="X"` - Track identifiers

### ID Types That Can Repeat (Scoped)
- `ClipSlot Id="X"` - Scoped per track
- `AutomationLane Id="X"` - Scoped per track
- `TrackSendHolder Id="X"` - Scoped per track
- `Scene Id="X"` - Global but sequential 0,1,2...

### ID Offset Strategy for Track Duplication
```rust
// Original template IDs range ~700 to ~10800 (span of ~10000)
// Need offsets > 11000 apart to avoid collisions
const OFFSET_PER_TRACK: u32 = 20000;

// Track 1 (original): IDs 0-10800
// Track 2: IDs 20000-30800  
// Track 3: IDs 40000-50800
// etc.
```

## Track Structure

### Track Types
```xml
<Tracks>
    <GroupTrack Id="X">...</GroupTrack>
    <AudioTrack Id="X">...</AudioTrack>
    <MidiTrack Id="X">...</MidiTrack>
    <ReturnTrack Id="X">...</ReturnTrack>
</Tracks>
```

### Track Order for Groups
Groups must appear BEFORE their child tracks:
```xml
<Tracks>
    <GroupTrack Id="100000"><!-- Drums --></GroupTrack>
    <AudioTrack Id="0"><!-- Kick, TrackGroupId=100000 --></AudioTrack>
    <AudioTrack Id="20000"><!-- Snare, TrackGroupId=100000 --></AudioTrack>
    <GroupTrack Id="100001"><!-- Synths --></GroupTrack>
    <AudioTrack Id="60000"><!-- Bass, TrackGroupId=100001 --></AudioTrack>
    <ReturnTrack Id="2">...</ReturnTrack>
</Tracks>
```

### Group Membership
```xml
<TrackGroupId Value="100000" />  <!-- Parent group's Id, -1 = no group -->
<LinkedTrackGroupId Value="-1" />
```

### GroupTrack vs AudioTrack Structure
| Element | GroupTrack | AudioTrack |
|---------|------------|------------|
| `<Slots>` with `<GroupTrackSlot>` | ✓ | ✗ |
| `<MainSequencer>` | ✗ | ✓ |
| `<DeviceChain>` | ✓ | ✓ |
| `<FreezeSequencer>` | ✓ | ✓ |

**Key insight**: Cannot convert AudioTrack to GroupTrack by renaming tags - internal structure differs.

## Track Naming

```xml
<Name>
    <EffectiveName Value="Kick" />  <!-- Computed by Ableton -->
    <UserName Value="Kick" />        <!-- User-defined, takes precedence -->
    <Annotation Value="" />
    <MemorizedFirstClipName Value="" />
</Name>
```

- Set BOTH `EffectiveName` and `UserName` for name to display
- `UserName` is what Ableton shows when set

## Colors

- Colors are numeric values (0-69 in Ableton's palette)
- Common colors: 3 (red), 14 (orange), 26 (purple), 41 (default gray)
- Set ALL `<Color Value="X" />` in a track to match (track + devices)
- Clip colors should match track color for visual consistency

```rust
// Replace ALL colors in a track
let color_re = Regex::new(r#"<Color Value="\d+" />"#)?;
track = color_re.replace_all(&track, format!(r#"<Color Value="{}" />"#, color)).to_string();
```

## AudioClip Structure

### Position and Length (in beats, 4 beats = 1 bar)
```xml
<AudioClip Id="240000" Time="0">  <!-- Time = start position in beats -->
    <CurrentStart Value="0" />     <!-- Same as Time -->
    <CurrentEnd Value="16" />      <!-- End position (4 bars = 16 beats) -->
    <Loop>
        <LoopStart Value="0" />
        <LoopEnd Value="16" />     <!-- Loop length in beats -->
        <LoopOn Value="true" />
        <OutMarker Value="16" />
    </Loop>
```

### Position Calculation
```rust
let beats_per_bar = 4;
let start_beat = (start_bar - 1) * beats_per_bar; // bar 1 = beat 0
let length_beats = length_bars * beats_per_bar;   // 4 bars = 16 beats
let end_beat = start_beat + length_beats;

// Bar 1 = Time="0"
// Bar 5 = Time="16" (4 bars × 4 beats = 16)
```

### Sample Reference
```xml
<SampleRef>
    <FileRef>
        <RelativePathType Value="0" />
        <RelativePath Value="" />
        <Path Value="/absolute/path/to/sample.wav" />
        <Type Value="1" />  <!-- 1 = Ableton Core Library, 2 = External -->
        <LivePackName Value="" />
        <LivePackId Value="" />
        <OriginalFileSize Value="520572" />
        <OriginalCrc Value="0" />
    </FileRef>
    <DefaultDuration Value="88200" />   <!-- In samples -->
    <DefaultSampleRate Value="44100" />
</SampleRef>
```

### Clip Insertion Point
AudioClips go inside `<Sample><ArrangerAutomation><Events>`:
```xml
<Sample>
    <ArrangerAutomation>
        <Events>
            <AudioClip Id="X" Time="0">...</AudioClip>
            <AudioClip Id="Y" Time="16">...</AudioClip>
        </Events>
    </ArrangerAutomation>
</Sample>
```

## XML Escaping

**Critical**: File paths and names must be XML-escaped:
```rust
fn xml_escape(s: &str) -> String {
    s.replace('&', "&amp;")
     .replace('<', "&lt;")
     .replace('>', "&gt;")
     .replace('"', "&quot;")
     .replace('\'', "&apos;")
}

// "/path/Piano & Keys/file.wav" -> "/path/Piano &amp; Keys/file.wav"
```

Error if not escaped: "not well-formed (invalid token)"

## Template Embedding Strategy

Best approach: Embed real templates from working Ableton projects:
```rust
const EMPTY_PROJECT_TEMPLATE: &[u8] = include_bytes!("empty_project_template.als.gz");
const GROUP_TRACK_TEMPLATE: &str = include_str!("../src/group_track_template.xml");
```

This ensures:
- Correct XML structure
- All required elements present
- Proper element ordering

## Genre-Specific Patterns

### BPM Ranges
| Genre | BPM Range |
|-------|-----------|
| Techno | 128-138 |
| Trance | 138-140 |
| Schranz | 150-160 |

### Track Counts (from template analysis)
| Genre | Audio | MIDI | Groups | Returns |
|-------|-------|------|--------|---------|
| Techno | 11-35 | 4-14 | 1-6 | 2-4 |
| Trance | 31-67 | 12-33 | 9-26 | 1-5 |
| Schranz | 16-17 | 0-2 | 4-6 | 0-4 |

### Common Group Names

All three genres use the same group hierarchy (Drums, Bass, Melodics/Leads, Pads, FX, Atmosphere/Vocals). Content and track count differ by genre, but the organizational structure is consistent.

- **Techno**: Drums (Kick, Clap, Hat, Ride, Perc), Bass (Sub, Mid Bass), Leads (Synth, Stab, Saw), Pads (Pad, Atmos, Strings), FX (Riser, Crash, Impact, Down), Atmosphere (Atmo, Vox)
- **Trance**: Drums (Kick, Clap, Hat, Cymbal, Fill), Bass (Sub, Bass Pad, Mid Bass), Leads (Lead 1-4, Pluck, Arp, Chord Stab, Acid), Pads (Pad 1-3, Strings, Choir), FX (Riser, Down, Impact, Crash, Sweep, Snare Roll), Atmosphere (Atmo, Vox)
- **Schranz**: Drums (Kick, Clap, Hat, Perc), Bass (Rumble Sub, Drive), Melodics (Synth Stab, Synth Loop), FX (Riser, Hits, Atmos)

## Common Errors and Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| "NextPointeeId is too low" | NextPointeeId < max ID | Increase NextPointeeId |
| "non-unique Pointee IDs" | Duplicate IDs across tracks | Use larger ID offsets |
| "not well-formed (invalid token)" | Unescaped & < > in paths | XML-escape all strings |
| "needs version X.X.X or newer" | MinorVersion format wrong | Use known working format |
| "List index out of range, ContentLanes" | Missing required elements | Copy from working template |

## File References

Templates analyzed:
- `docs/templates/` - 26 .als files (gzipped)
- `docs/templates_xml/` - Decompressed XML versions
- `src-tauri/src/empty_project_template.als.gz` - Embedded empty project
- `src-tauri/src/group_track_template.xml` - Embedded GroupTrack structure

## Code Location

- `src-tauri/src/als_generator.rs` - Main generation module
- `src-tauri/examples/generate_toy_project.rs` - Working example with groups and clips
