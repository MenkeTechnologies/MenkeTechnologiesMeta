# Clip Timing Reference

Technical reference for beat/bar positioning and warp markers in Ableton ALS files.

## Beat vs Bar Conversion

Ableton uses **beats** internally, not bars.

```
4/4 time signature:
- 4 beats = 1 bar
- 16 beats = 4 bars
- 64 beats = 16 bars
```

### Bar to Beat Conversion

```rust
fn bar_to_beat(bar: f64) -> f64 {
    (bar - 1.0) * 4.0  // bar 1 = beat 0
}

fn beat_to_bar(beat: f64) -> f64 {
    (beat / 4.0) + 1.0
}
```

### Common Positions

| Bar | Beat | Description |
|-----|------|-------------|
| 1 | 0 | Song start |
| 17 | 64 | After 16-bar intro |
| 33 | 128 | After 32 bars |
| 65 | 256 | Breakdown start |
| 97 | 384 | Drop 1 |
| 129 | 512 | Drop 2 |
| 161 | 640 | Fadedown |
| 193 | 768 | Outro |
| 224 | 892 | 7-minute mark at 128 BPM |

## Fractional Bar Positions

For beat-level precision (fills, etc.), use fractional bars:

| Position | Bars | Meaning |
|----------|------|---------|
| 15.75 | 15¾ | Beat 4 of bar 15 (last beat) |
| 16.0 | 16 | Beat 1 of bar 16 (downbeat) |
| 23.5 | 23½ | Beat 3 of bar 23 |
| 31.25 | 31¼ | Beat 2 of bar 31 |

### Gap Calculations

```
1 beat gap:  end at bar.75, start at bar+1
2 beat gap:  end at bar.5, start at bar+1
4 beat gap:  end at bar, start at bar+1 (full bar gap)
```

Example - 1 beat fill at bar 16:
- Main element ends: 15.75 (beat 63)
- Fill plays: 15.75 to 16.0 (beat 63-64)
- Main element resumes: 17.0 (beat 64)

## Warp Markers

Warp markers define how samples are time-stretched to match project tempo.

### Basic Structure

```xml
<WarpMarkers>
    <WarpMarker Id="0" SecTime="0" BeatTime="0" />
    <WarpMarker Id="1" SecTime="{sample_duration}" BeatTime="{target_beats}" />
</WarpMarkers>
```

### SecTime Calculation

`SecTime` = actual audio duration in seconds that maps to `BeatTime`.

For clips shorter than the sample, calculate based on clip length:

```rust
// At 128 BPM:
// 1 beat = 60/128 = 0.46875 seconds
// 2 beats = 0.9375 seconds
// 4 beats = 1.875 seconds

fn beats_to_seconds(beats: f64, bpm: f64) -> f64 {
    (beats * 60.0) / bpm
}
```

### Short Clip Warp

When clip is shorter than sample, warp must match clip length:

```rust
let clip_length_beats = end_beat - start_beat;
let sample_loop_beats = sample.loop_bars() * 4.0;

let warp_sec = if clip_length_beats < sample_loop_beats {
    // Clip is shorter - warp to clip length
    beats_to_seconds(clip_length_beats, PROJECT_BPM)
} else {
    // Clip uses full sample
    sample.duration_secs
};
```

### Example Warp Values at 128 BPM

| Clip Length | Beats | SecTime |
|-------------|-------|---------|
| 1 beat | 1 | 0.46875 |
| 2 beats | 2 | 0.9375 |
| 1 bar | 4 | 1.875 |
| 2 bars | 8 | 3.75 |
| 4 bars | 16 | 7.5 |
| 8 bars | 32 | 15.0 |
| 16 bars | 64 | 30.0 |

## Loop Settings

### LoopOn and LoopEnd

```xml
<Loop>
    <LoopStart Value="0" />
    <LoopEnd Value="{loop_beats}" />
    <StartRelative Value="0" />
    <LoopOn Value="true" />
    <OutMarker Value="{loop_beats}" />
    <HiddenLoopStart Value="0" />
    <HiddenLoopEnd Value="{loop_beats}" />
</Loop>
```

### Loop Capping

When clip is shorter than sample, cap loop to clip length:

```rust
let loop_beats = if clip_length_beats < sample_loop_beats {
    clip_length_beats  // Cap to clip
} else {
    sample_loop_beats  // Use sample's natural loop
};
```

This prevents the sample from playing beyond the clip boundary.

## Clip Boundaries

### CurrentStart and CurrentEnd

```xml
<AudioClip Id="X" Time="{start_beat}">
    <CurrentStart Value="{start_beat}" />
    <CurrentEnd Value="{end_beat}" />
```

- `Time` = clip position on timeline
- `CurrentStart` = where clip content starts (usually same as Time)
- `CurrentEnd` = where clip content ends

### Inclusive vs Exclusive

End beat is **exclusive** - clip plays UP TO but not including end beat:
- `CurrentStart="0" CurrentEnd="4"` plays beats 0, 1, 2, 3 (bar 1)
- `CurrentStart="0" CurrentEnd="64"` plays bars 1-16

## BPM and Duration Relationships

### Duration from BPM

```rust
fn duration_secs_from_bars(bars: u32, bpm: f64) -> f64 {
    (bars as f64 * 4.0 * 60.0) / bpm
}

// At 128 BPM:
// 1 bar = 1.875 sec
// 4 bars = 7.5 sec
// 16 bars = 30 sec
// 32 bars = 60 sec (1 min)
```

### Bars from Duration

```rust
fn bars_from_duration(duration_secs: f64, bpm: f64) -> f64 {
    (duration_secs * bpm) / (4.0 * 60.0)
}

// Round to common loop lengths:
fn round_to_loop_bars(bars: f64) -> u32 {
    match bars {
        b if b < 0.75 => 1,   // < 3/4 bar -> 1 bar
        b if b < 1.5 => 1,    // < 1.5 bars -> 1 bar
        b if b < 3.0 => 2,    // < 3 bars -> 2 bars
        b if b < 6.0 => 4,    // < 6 bars -> 4 bars
        b if b < 12.0 => 8,   // < 12 bars -> 8 bars
        _ => 16,              // else 16 bars
    }
}
```

## Arrangement Duration

### Full Track Calculations

| Bars | Beats | Minutes at 128 BPM |
|------|-------|-------------------|
| 32 | 128 | 1:00 |
| 64 | 256 | 2:00 |
| 96 | 384 | 3:00 |
| 128 | 512 | 4:00 |
| 160 | 640 | 5:00 |
| 192 | 768 | 6:00 |
| 224 | 896 | 7:00 |
| 256 | 1024 | 8:00 |

### Formula

```rust
fn bars_to_minutes(bars: u32, bpm: f64) -> f64 {
    (bars as f64 * 4.0) / bpm  // bars * beats_per_bar / beats_per_minute
}

fn minutes_to_bars(minutes: f64, bpm: f64) -> u32 {
    ((minutes * bpm) / 4.0) as u32
}
```

## Time Attribute Special Value

`Time="-63072000"` is used for initial/default automation values - represents a point far before the song starts. Always include this for automation events to set the default state.

## Warp Marker BPM Fix

### Problem
Sample metadata often has incorrect BPM (e.g., 999 BPM shown in Ableton). This happens when:
- Database has wrong/missing BPM
- Sample was recorded at different tempo
- Metadata is corrupted

### Solution
**Always calculate `warp_sec` from target beats at project BPM**, not from sample metadata:

```rust
// CORRECT: Force sample to project tempo
let warp_sec = (loop_beats * 60.0) / PROJECT_BPM;

// WRONG: Trusting sample duration (may have wrong BPM)
let warp_sec = sample.duration_secs;  // Don't do this!
```

### How It Works
WarpMarker tells Ableton: "at `SecTime` seconds into the sample, we should be at `BeatTime` beats"

By calculating `SecTime` from our target beats and project BPM:
- Ableton stretches/compresses the sample to fit
- Result plays at correct tempo regardless of source BPM

### Values at 128 BPM
| Loop Length | Beats | warp_sec |
|-------------|-------|----------|
| 1 beat | 1 | 0.46875 |
| 2 beats | 2 | 0.9375 |
| 1 bar | 4 | 1.875 |
| 2 bars | 8 | 3.75 |
| 4 bars | 16 | 7.5 |
| 8 bars | 32 | 15.0 |
