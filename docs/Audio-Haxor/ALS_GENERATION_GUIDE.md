# ALS File Generation Guide

Reference documentation for programmatically generating Ableton Live Set (.als) files.
Based on analysis of 25 professional techno/trance/schranz templates (Ableton Live 10-12).

## File Format

ALS = **gzip-compressed XML**. Generation workflow:
1. Build XML document
2. Serialize to UTF-8 string
3. gzip compress
4. Write with `.als` extension

```rust
use flate2::write::GzEncoder;
use flate2::Compression;

fn write_als(xml: &str, path: &Path) -> Result<()> {
    let file = File::create(path)?;
    let mut encoder = GzEncoder::new(file, Compression::default());
    encoder.write_all(xml.as_bytes())?;
    encoder.finish()?;
    Ok(())
}
```

## Version Detection

**Critical for valid ALS files**: Use the installed Ableton version to ensure compatibility.

```rust
use std::process::Command;

/// Detect Ableton version from macOS app bundle
fn detect_ableton_version() -> (String, String) {
    let output = Command::new("defaults")
        .args(["read", "/Applications/Ableton Live 12 Suite.app/Contents/Info.plist", 
               "CFBundleShortVersionString"])
        .output()
        .ok();
    
    if let Some(out) = output {
        if out.status.success() {
            // Parse "12.3.7 (2026-03-30_c92a51f028)" -> "12.3.7"
            let version = String::from_utf8_lossy(&out.stdout);
            let version = version.split_whitespace().next().unwrap_or("12.0.0");
            let parts: Vec<&str> = version.split('.').collect();
            
            let major: u32 = parts.get(0).and_then(|s| s.parse().ok()).unwrap_or(12);
            let minor: u32 = parts.get(1).and_then(|s| s.parse().ok()).unwrap_or(0);
            let patch: u32 = parts.get(2).and_then(|s| s.parse().ok()).unwrap_or(0);
            
            // MinorVersion format: "12.0_12307" for Live 12.3.7
            let minor_version = format!("{}.0_{}", major, major * 10000 + minor * 100 + patch);
            let creator = format!("Ableton Live {}.{}.{}", major, minor, patch);
            
            return (minor_version, creator);
        }
    }
    
    // Fallback
    ("12.0_12000".to_string(), "Ableton Live 12.0".to_string())
}
```

**Version string mapping:**
| Ableton Version | MinorVersion | Creator |
|-----------------|--------------|---------|
| 10.1.30 | "10.0_10130" | "Ableton Live 10.1.30" |
| 11.0.12 | "11.0_11012" | "Ableton Live 11.0.12" |
| 11.1.6 | "11.0_11106" | "Ableton Live 11.1.6" |
| 12.3.7 | "12.0_12307" | "Ableton Live 12.3.7" |

## XML Root Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Ableton MajorVersion="5" MinorVersion="12.0_12307" Creator="Ableton Live 12.3.7" Revision="">
    <LiveSet>
        <!-- Project settings -->
        <NextPointeeId Value="100000" />
        <OverwriteProtectionNumber Value="2816" />
        <LomId Value="0" />
        <LomIdView Value="0" />
        
        <!-- Track container -->
        <Tracks>
            <!-- GroupTrack, AudioTrack, MidiTrack elements -->
        </Tracks>
        
        <!-- Master channel -->
        <MasterTrack>...</MasterTrack>
        
        <!-- Preview/cue channel -->
        <PreHearTrack>...</PreHearTrack>
        
        <!-- Pre-fader sends toggle -->
        <SendsPre>...</SendsPre>
        
        <!-- Session view scenes -->
        <Scenes>...</Scenes>
        
        <!-- Transport/playback settings -->
        <Transport>...</Transport>
        
        <!-- Global project settings -->
        <GlobalQuantisation Value="4" />
        <Grid>...</Grid>
        <ScaleInformation>...</ScaleInformation>
        <InKey Value="true" />
        <Locators>...</Locators>
        
        <!-- View state (can be minimal) -->
        <ChooserBar Value="0" />
        <Annotation Value="" />
        <SoloOrPflSavedValue Value="true" />
        <SoloInPlace Value="true" />
        <LatencyCompensation Value="2" />
        <GroovePool>...</GroovePool>
        <AutomationMode Value="true" />
    </LiveSet>
</Ableton>
```

### Version Compatibility

| Attribute | Description | Recommended |
|-----------|-------------|-------------|
| MajorVersion | Always "5" for Live 10-12 | "5" |
| MinorVersion | Live version identifier | "11.0_433" |
| Creator | Display string | "Ableton Live 11.0" |
| Revision | Git-like hash (optional) | "" |

**Note**: All 23 templates use `MajorVersion="5"`. MinorVersion varies (10.0_377 → 12.0_12300).
Target `11.0_433` for broad compatibility.

---

## ID Management

**Critical**: Ableton requires unique IDs throughout the document.

### ID Types

1. **Element IDs** (`Id` attribute): Unique per element type within parent
   ```xml
   <AudioTrack Id="14">
   <AudioClip Id="66" Time="0">
   <AutomationEnvelope Id="0">
   ```

2. **Pointee IDs**: Global reference IDs for automation targets
   ```xml
   <NextPointeeId Value="100000" />  <!-- Track next available -->
   <Pointee Id="19721" />
   <AutomationTarget Id="16128">
   ```

3. **Automation Target IDs**: Referenced by automation envelopes
   ```xml
   <EnvelopeTarget>
       <PointeeId Value="33904" />  <!-- References a Pointee -->
   </EnvelopeTarget>
   ```

### ID Generation Strategy

```rust
struct IdGenerator {
    next_element_id: u32,
    next_pointee_id: u32,
    next_automation_target_id: u32,
}

impl IdGenerator {
    fn new() -> Self {
        Self {
            next_element_id: 0,
            next_pointee_id: 10000,
            next_automation_target_id: 20000,
        }
    }
    
    fn next_element(&mut self) -> u32 {
        let id = self.next_element_id;
        self.next_element_id += 1;
        id
    }
    
    fn next_pointee(&mut self) -> u32 {
        let id = self.next_pointee_id;
        self.next_pointee_id += 1;
        id
    }
}
```

---

## Track Types

### AudioTrack (Audio Clips/Samples)

```xml
<AudioTrack Id="14">
    <LomId Value="0" />
    <LomIdView Value="0" />
    <IsContentSelectedInDocument Value="false" />
    <PreferredContentViewMode Value="0" />
    
    <TrackDelay>
        <Value Value="0" />
        <IsValueSampleBased Value="false" />
    </TrackDelay>
    
    <Name>
        <EffectiveName Value="Kick" />
        <UserName Value="Kick" />
        <Annotation Value="" />
        <MemorizedFirstClipName Value="" />
    </Name>
    
    <Color Value="14" />  <!-- 0-69: Ableton color palette -->
    
    <AutomationEnvelopes>
        <Envelopes />  <!-- Track-level automation -->
    </AutomationEnvelopes>
    
    <TrackGroupId Value="29" />  <!-- -1 if not in group, else GroupTrack Id -->
    <TrackUnfolded Value="true" />
    <DevicesListWrapper LomId="0" />
    <ClipSlotsListWrapper LomId="0" />
    <ViewData Value="{}" />
    
    <TakeLanes>
        <TakeLanes />
        <AreTakeLanesFolded Value="true" />
    </TakeLanes>
    
    <LinkedTrackGroupId Value="-1" />
    <SavedPlayingSlot Value="-1" />
    <SavedPlayingOffset Value="0" />
    <Freeze Value="false" />
    <VelocityDetail Value="0" />
    <NeedArrangerRefreeze Value="true" />
    <PostProcessFreezeClips Value="0" />
    
    <DeviceChain>
        <!-- See DeviceChain section -->
    </DeviceChain>
</AudioTrack>
```

### MidiTrack (MIDI/Instrument)

Same structure as AudioTrack, but with `<MidiTrack>` tag and MIDI-specific routing.

### GroupTrack (Folder/Bus)

```xml
<GroupTrack Id="29">
    <!-- Same header as AudioTrack -->
    <Name>
        <EffectiveName Value="Drums" />
        <UserName Value="Drums" />
    </Name>
    
    <!-- Tracks with TrackGroupId="29" are children -->
    
    <Slots>
        <GroupTrackSlot Id="0"><LomId Value="0" /></GroupTrackSlot>
        <!-- One slot per scene -->
    </Slots>
    
    <DeviceChain>...</DeviceChain>
</GroupTrack>
```

### ReturnTrack (Send/Bus)

```xml
<ReturnTrack Id="2">
    <Name>
        <EffectiveName Value="A-Reverb" />
        <UserName Value="Reverb" />
    </Name>
    <!-- Uses letter prefix: A-, B-, C-, D- -->
    <DeviceChain>
        <!-- Effect chain (reverb, delay, etc.) -->
    </DeviceChain>
</ReturnTrack>
```

---

## DeviceChain Structure

Every track has a DeviceChain containing routing, mixer, and arrangement:

```xml
<DeviceChain>
    <AutomationLanes>
        <AutomationLanes>
            <AutomationLane Id="0">
                <SelectedDevice Value="0" />
                <SelectedEnvelope Value="0" />
                <IsContentSelectedInDocument Value="false" />
                <LaneHeight Value="68" />
            </AutomationLane>
        </AutomationLanes>
        <AreAdditionalAutomationLanesFolded Value="false" />
    </AutomationLanes>
    
    <ClipEnvelopeChooserViewState>
        <SelectedDevice Value="0" />
        <SelectedEnvelope Value="0" />
        <PreferModulationVisible Value="true" />
    </ClipEnvelopeChooserViewState>
    
    <!-- Routing -->
    <AudioInputRouting>
        <Target Value="AudioIn/External/S0" />
        <UpperDisplayString Value="Ext. In" />
        <LowerDisplayString Value="1/2" />
    </AudioInputRouting>
    <MidiInputRouting>
        <Target Value="MidiIn/External.All/-1" />
        <UpperDisplayString Value="Ext: All Ins" />
        <LowerDisplayString Value="" />
    </MidiInputRouting>
    <AudioOutputRouting>
        <Target Value="AudioOut/Master" />  <!-- or AudioOut/GroupTrack -->
        <UpperDisplayString Value="Master" />
        <LowerDisplayString Value="" />
    </AudioOutputRouting>
    <MidiOutputRouting>
        <Target Value="MidiOut/None" />
        <UpperDisplayString Value="None" />
        <LowerDisplayString Value="" />
    </MidiOutputRouting>
    
    <Mixer>...</Mixer>
    
    <MainSequencer>
        <!-- Arrangement clips live here -->
    </MainSequencer>
    
    <FreezeSequencer>...</FreezeSequencer>
    
    <DeviceChain>
        <Devices>
            <!-- Effects: Eq8, AutoFilter, Compressor, etc. -->
        </Devices>
    </DeviceChain>
</DeviceChain>
```

### Mixer Section

```xml
<Mixer>
    <LomId Value="0" />
    <LomIdView Value="0" />
    <IsExpanded Value="true" />
    
    <On>  <!-- Track active toggle -->
        <LomId Value="0" />
        <Manual Value="true" />
        <AutomationTarget Id="16128">
            <LockEnvelope Value="0" />
        </AutomationTarget>
        <MidiCCOnOffThresholds>
            <Min Value="64" />
            <Max Value="127" />
        </MidiCCOnOffThresholds>
    </On>
    
    <ModulationSourceCount Value="0" />
    <ParametersListWrapper LomId="0" />
    <Pointee Id="19721" />
    
    <Sends>
        <TrackSendHolder Id="0">
            <Send>
                <LomId Value="0" />
                <Manual Value="0.0003162277571" />  <!-- -70dB (off) -->
                <MidiControllerRange>
                    <Min Value="0.0003162277571" />
                    <Max Value="1" />
                </MidiControllerRange>
                <AutomationTarget Id="16129">
                    <LockEnvelope Value="0" />
                </AutomationTarget>
                <ModulationTarget Id="16130">
                    <LockEnvelope Value="0" />
                </ModulationTarget>
            </Send>
            <Active Value="true" />
        </TrackSendHolder>
        <!-- One TrackSendHolder per ReturnTrack -->
    </Sends>
    
    <Speaker>  <!-- Output on/off -->
        <LomId Value="0" />
        <Manual Value="true" />
        <AutomationTarget Id="16133">
            <LockEnvelope Value="0" />
        </AutomationTarget>
    </Speaker>
    
    <SoloSink Value="false" />
    <PanMode Value="0" />
    
    <Pan>
        <LomId Value="0" />
        <Manual Value="0" />  <!-- -1 to 1 -->
        <MidiControllerRange>
            <Min Value="-1" />
            <Max Value="1" />
        </MidiControllerRange>
        <AutomationTarget Id="16134">
            <LockEnvelope Value="0" />
        </AutomationTarget>
        <ModulationTarget Id="16135">
            <LockEnvelope Value="0" />
        </ModulationTarget>
    </Pan>
    
    <Volume>
        <LomId Value="0" />
        <Manual Value="0.3162277937" />  <!-- -10dB, linear scale -->
        <MidiControllerRange>
            <Min Value="0.0003162277571" />  <!-- -70dB -->
            <Max Value="1.99526238" />        <!-- +6dB -->
        </MidiControllerRange>
        <AutomationTarget Id="16136">
            <LockEnvelope Value="0" />
        </AutomationTarget>
        <ModulationTarget Id="16137">
            <LockEnvelope Value="0" />
        </ModulationTarget>
    </Volume>
    
    <CrossFadeState>
        <LomId Value="0" />
        <Manual Value="1" />  <!-- 0=A, 1=center, 2=B -->
        <AutomationTarget Id="16138">
            <LockEnvelope Value="0" />
        </AutomationTarget>
    </CrossFadeState>
</Mixer>
```

#### Volume Scale (Linear to dB)

```rust
fn db_to_linear(db: f64) -> f64 {
    10.0_f64.powf(db / 20.0)
}

fn linear_to_db(linear: f64) -> f64 {
    20.0 * linear.log10()
}

// Common values:
// 0.0003162277571 = -70dB (effectively off)
// 0.1 = -20dB
// 0.3162277937 = -10dB
// 0.5 = -6dB
// 0.7079457844 = -3dB
// 1.0 = 0dB
// 1.4125375747 = +3dB
// 1.99526238 = +6dB
```

---

## MainSequencer (Arrangement View)

The MainSequencer contains arrangement clips:

```xml
<MainSequencer>
    <LomId Value="0" />
    <LomIdView Value="0" />
    <IsExpanded Value="true" />
    <On>
        <LomId Value="0" />
        <Manual Value="true" />
        <AutomationTarget Id="16139">
            <LockEnvelope Value="0" />
        </AutomationTarget>
    </On>
    
    <ClipSlotList>
        <!-- Session view slots (one per scene) -->
        <ClipSlot Id="0">
            <LomId Value="0" />
            <ClipSlot><Value /></ClipSlot>
            <HasStop Value="true" />
            <NeedRefreeze Value="true" />
        </ClipSlot>
    </ClipSlotList>
    
    <MonitoringEnum Value="1" />  <!-- 0=In, 1=Auto, 2=Off -->
    
    <Sample>
        <ArrangerAutomation>
            <Events>
                <!-- AudioClip elements for arrangement -->
                <AudioClip Id="66" Time="0">...</AudioClip>
                <AudioClip Id="67" Time="64">...</AudioClip>
            </Events>
        </ArrangerAutomation>
    </Sample>
    
    <VolumeModulationTarget Id="...">
        <LockEnvelope Value="0" />
    </VolumeModulationTarget>
    <!-- More modulation targets... -->
</MainSequencer>
```

---

## AudioClip Structure

```xml
<AudioClip Id="66" Time="0">  <!-- Time = start position in beats -->
    <LomId Value="0" />
    <LomIdView Value="0" />
    
    <CurrentStart Value="0" />      <!-- Clip start in beats -->
    <CurrentEnd Value="64" />       <!-- Clip end in beats -->
    
    <Loop>
        <LoopStart Value="0" />     <!-- Loop region start -->
        <LoopEnd Value="64" />      <!-- Loop region end -->
        <StartRelative Value="0" /> <!-- Offset into sample -->
        <LoopOn Value="true" />
        <OutMarker Value="64" />
        <HiddenLoopStart Value="0" />
        <HiddenLoopEnd Value="64" />
    </Loop>
    
    <Name Value="" />  <!-- Display name override -->
    <Annotation Value="" />
    <Color Value="14" />  <!-- 0-69 -->
    
    <LaunchMode Value="0" />         <!-- 0=Trigger, 1=Gate, 2=Toggle, 3=Repeat -->
    <LaunchQuantisation Value="0" /> <!-- Grid snap for launch -->
    
    <TimeSignature>
        <TimeSignatures>
            <RemoteableTimeSignature Id="0">
                <Numerator Value="4" />
                <Denominator Value="4" />
                <Time Value="0" />
            </RemoteableTimeSignature>
        </TimeSignatures>
    </TimeSignature>
    
    <Envelopes>
        <Envelopes />  <!-- Clip-level automation -->
    </Envelopes>
    
    <Legato Value="false" />
    <Ram Value="false" />
    <GrooveSettings>
        <GrooveId Value="-1" />
    </GrooveSettings>
    <Disabled Value="false" />
    <VelocityAmount Value="0" />
    
    <Grid>
        <FixedNumerator Value="1" />
        <FixedDenominator Value="16" />
        <GridIntervalPixel Value="20" />
        <Ntoles Value="2" />
        <SnapToGrid Value="true" />
        <Fixed Value="false" />
    </Grid>
    
    <FreezeStart Value="0" />
    <FreezeEnd Value="0" />
    <IsWarped Value="true" />
    <TakeId Value="1" />
    
    <SampleRef>
        <FileRef>
            <RelativePathType Value="3" />
            <RelativePath Value="Samples/kick.wav" />
            <Path Value="/absolute/path/to/kick.wav" />
            <Type Value="1" />
            <LivePackName Value="" />
            <LivePackId Value="" />
            <OriginalFileSize Value="123456" />
            <OriginalCrc Value="12345" />
        </FileRef>
        <LastModDate Value="1646408278" />  <!-- Unix timestamp -->
        <SourceContext />
        <SampleUsageHint Value="0" />
        <DefaultDuration Value="44100" />    <!-- Samples -->
        <DefaultSampleRate Value="44100" />
    </SampleRef>
    
    <Onsets>
        <UserOnsets />
        <HasUserOnsets Value="false" />
    </Onsets>
    
    <WarpMode Value="0" />
    <!-- 0=Beats, 1=Tones, 2=Texture, 3=Re-Pitch, 4=Complex, 5=Complex Pro -->
    
    <WarpMarkers>
        <WarpMarker Id="0" SecTime="0" BeatTime="0" />
        <WarpMarker Id="1" SecTime="0.5" BeatTime="1" />
    </WarpMarkers>
    
    <Sync Value="true" />
    <HiQ Value="true" />
    <Fade Value="true" />
    <Fades>
        <FadeInLength Value="0" />
        <FadeOutLength Value="0" />
        <ClipFadesAreInitialized Value="true" />
        <CrossfadeInState Value="0" />
        <FadeInCurveSkew Value="0" />
        <FadeInCurveSlope Value="0" />
        <FadeOutCurveSkew Value="0" />
        <FadeOutCurveSlope Value="0" />
        <IsDefaultFadeIn Value="true" />
        <IsDefaultFadeOut Value="true" />
    </Fades>
    
    <PitchCoarse Value="0" />  <!-- Semitones -->
    <PitchFine Value="0" />    <!-- Cents -->
    
    <SampleVolume Value="1" />  <!-- Clip gain (linear) -->
    <MarkerDensity Value="2" />
    <AutoWarpTolerance Value="4" />
    <TimeSignatureDenominator Value="4" />
    <TimeSignatureNumerator Value="4" />
</AudioClip>
```

### Positioning (Beats vs Bars)

**Ableton uses BEATS, not bars.** At 4/4:
- 4 beats = 1 bar
- Bar 32 = beat 128
- Bar 64 = beat 256

```rust
fn bars_to_beats(bars: f64) -> f64 {
    bars * 4.0
}

fn beats_to_bars(beats: f64) -> f64 {
    beats / 4.0
}
```

### WarpMarkers

Define tempo-sync points. Minimum two markers required:

```xml
<WarpMarkers>
    <WarpMarker Id="0" SecTime="0" BeatTime="0" />
    <WarpMarker Id="1" SecTime="2.0" BeatTime="4" />  <!-- 2 sec = 4 beats at 120 BPM -->
</WarpMarkers>
```

For tempo-matched samples, place markers at sample boundaries:

```rust
fn calculate_warp_markers(sample_duration_sec: f64, sample_beats: f64) -> Vec<WarpMarker> {
    vec![
        WarpMarker { sec_time: 0.0, beat_time: 0.0 },
        WarpMarker { sec_time: sample_duration_sec, beat_time: sample_beats },
    ]
}
```

---

## MidiClip Structure

```xml
<MidiClip Id="0" Time="0">
    <!-- Same header as AudioClip -->
    <CurrentStart Value="0" />
    <CurrentEnd Value="16" />
    <Loop>
        <LoopStart Value="0" />
        <LoopEnd Value="16" />
        <StartRelative Value="0" />
        <LoopOn Value="true" />
    </Loop>
    
    <Notes>
        <KeyTracks>
            <KeyTrack Id="0">
                <Notes>
                    <MidiNoteEvent 
                        Time="0"           <!-- Beat position -->
                        Duration="1"       <!-- Length in beats -->
                        Velocity="100"     <!-- 0-127 -->
                        VelocityDeviation="0"
                        OffVelocity="64"
                        Probability="1"    <!-- 0-1, note probability -->
                        IsEnabled="true"
                        NoteId="1" />
                </Notes>
                <MidiKey Value="60" />  <!-- MIDI note number (60 = C4) -->
            </KeyTrack>
            <KeyTrack Id="1">
                <Notes>
                    <MidiNoteEvent Time="0" Duration="1" Velocity="100" ... NoteId="2" />
                </Notes>
                <MidiKey Value="64" />  <!-- E4 -->
            </KeyTrack>
        </KeyTracks>
        
        <PerNoteEventStore>
            <EventLists />
        </PerNoteEventStore>
        
        <NoteIdGenerator>
            <NextId Value="3" />  <!-- Track next NoteId -->
        </NoteIdGenerator>
    </Notes>
    
    <BankSelectCoarse Value="-1" />
    <BankSelectFine Value="-1" />
    <ProgramChange Value="-1" />
</MidiClip>
```

### MIDI Note Numbers

```
C-1 = 0    C0 = 12   C1 = 24   C2 = 36   C3 = 48
C4 = 60 (Middle C)   C5 = 72   C6 = 84   C7 = 96
```

---

## Automation

### Track-Level Automation (Mixer Parameters)

```xml
<AutomationEnvelopes>
    <Envelopes>
        <AutomationEnvelope Id="0">
            <EnvelopeTarget>
                <PointeeId Value="33904" />  <!-- References Volume/Pan/etc Pointee -->
            </EnvelopeTarget>
            <Automation>
                <Events>
                    <!-- Boolean events (mute/on-off) -->
                    <BoolEvent Id="0" Time="-63072000" Value="true" />
                    <BoolEvent Id="1" Time="0" Value="true" />
                    <BoolEvent Id="2" Time="128" Value="false" />
                    <BoolEvent Id="3" Time="256" Value="true" />
                    
                    <!-- Float events (volume/pan/filter) -->
                    <FloatEvent Id="0" Time="-63072000" Value="0.5" />
                    <FloatEvent Id="1" Time="0" Value="0.5" />
                    <FloatEvent Id="2" Time="64" Value="1.0"
                        CurveControl1X="0.5" CurveControl1Y="0.0"
                        CurveControl2X="0.5" CurveControl2Y="1.0" />
                </Events>
                <AutomationTransformViewState>
                    <IsTransformPending Value="false" />
                    <TimeAndValueTransforms />
                </AutomationTransformViewState>
            </Automation>
        </AutomationEnvelope>
    </Envelopes>
</AutomationEnvelopes>
```

### Time Values

- `Time="-63072000"` = Initial/default value (way before song start)
- `Time="0"` = Beat 0 (bar 1)
- `Time="128"` = Beat 128 (bar 33)

### Curve Control (Bezier)

FloatEvents can have Bezier curve controls:
- `CurveControl1X/Y`: First control point (0-1 normalized)
- `CurveControl2X/Y`: Second control point (0-1 normalized)

Linear interpolation = no curve controls.

---

## Transport & Tempo

```xml
<Transport>
    <PhaseNudgeTempo Value="10" />
    <LoopOn Value="true" />
    <LoopStart Value="0" />        <!-- Loop start in beats -->
    <LoopLength Value="896" />     <!-- Loop length in beats -->
    <LoopIsSongStart Value="false" />
    <CurrentTime Value="0" />
    <PunchIn Value="false" />
    <PunchOut Value="false" />
    <MetronomeTickDuration Value="0" />
    <DrawMode Value="false" />
</Transport>
```

### Tempo (in MasterTrack Mixer)

```xml
<Tempo>
    <LomId Value="0" />
    <Manual Value="138" />  <!-- BPM -->
    <MidiControllerRange>
        <Min Value="60" />
        <Max Value="200" />
    </MidiControllerRange>
    <AutomationTarget Id="8">
        <LockEnvelope Value="0" />
    </AutomationTarget>
    <ModulationTarget Id="9">
        <LockEnvelope Value="0" />
    </ModulationTarget>
</Tempo>

<TimeSignature>
    <LomId Value="0" />
    <Manual Value="201" />  <!-- Encoded: 200 + numerator (201 = 4/4) -->
    <AutomationTarget Id="10">
        <LockEnvelope Value="0" />
    </AutomationTarget>
</TimeSignature>
```

---

## Common Devices (Effects)

### AutoFilter

```xml
<AutoFilter Id="0">
    <LomId Value="0" />
    <LomIdView Value="0" />
    <IsExpanded Value="true" />
    <On>
        <LomId Value="0" />
        <Manual Value="true" />
        <AutomationTarget Id="1000">
            <LockEnvelope Value="0" />
        </AutomationTarget>
    </On>
    <Pointee Id="1001" />
    
    <!-- Filter parameters -->
    <FilterType Value="0" />        <!-- 0=LP, 1=HP, 2=BP, 3=Notch -->
    <Frequency>
        <Manual Value="135" />      <!-- 20-135 Hz range mapped -->
        <AutomationTarget Id="1002" />
    </Frequency>
    <Resonance>
        <Manual Value="0.5" />      <!-- 0-1 -->
        <AutomationTarget Id="1003" />
    </Resonance>
</AutoFilter>
```

### Eq8

```xml
<Eq8 Id="0">
    <LomId Value="0" />
    <IsExpanded Value="true" />
    <On><Manual Value="true" /></On>
    <Pointee Id="2000" />
    
    <Bands.0>
        <ParameterA>
            <IsOn><Manual Value="true" /></IsOn>
            <Mode><Manual Value="1" /></Mode>      <!-- 0=LP48, 1=LP12, 2=HP48... -->
            <Freq><Manual Value="100" /></Freq>
            <Gain><Manual Value="0" /></Gain>      <!-- dB -->
            <Q><Manual Value="0.7" /></Q>
        </ParameterA>
    </Bands.0>
    <!-- Bands.1 through Bands.7 -->
</Eq8>
```

### Compressor

```xml
<Compressor2 Id="0">
    <Threshold><Manual Value="-20" /></Threshold>     <!-- dB -->
    <Ratio><Manual Value="4" /></Ratio>               <!-- 1:N -->
    <Attack><Manual Value="10" /></Attack>            <!-- ms -->
    <Release><Manual Value="100" /></Release>         <!-- ms -->
    <OutputGain><Manual Value="0" /></OutputGain>     <!-- dB -->
    <DryWet><Manual Value="1" /></DryWet>             <!-- 0-1 -->
</Compressor2>
```

---

## Genre-Specific Patterns (From 25 Templates)

### Genre Comparison Summary

| Attribute | Techno | Trance | Schranz |
|-----------|--------|--------|---------|
| **BPM** | 130-138 | 138-140 | 154-157 |
| **Typical BPM** | 130 | 140 | 155 |
| **Track count** | 21-49 | 61-109 | 17-23 |
| **Duration (beats)** | 780-1040 | 800-1168 | 832-944 |
| **Duration (bars)** | ~196-260 | ~200-292 | ~208-236 |
| **Structure** | Grouped | Heavily grouped | Grouped (same as techno) |
| **Melodic content** | Moderate | Heavy | None |
| **Effects/track** | 0.13 | 0.28 | 0.17 |
| **Return buses** | 2-3 (reverb/delay) | 3-4 (reverb/delay/comp) | 4 (glue/beef/OD/haas) |
| **Key signatures** | Mixed | Usually minor | Mostly atonal (X) |
| **Kick style** | Single | Single | Layered (solo+rumble) |
| **Pre-mixed loops** | Rare | Rare | Common (SCHRANZ_LOOP) |

### Techno Templates

| Metric | Range | Typical |
|--------|-------|---------|
| BPM | 130-138 | 130 |
| Tracks | 21-49 | 32 |
| Duration | 780-1040 beats | 896 beats (~224 bars) |

**Common track names:**
- Drums: KICK, CLAP, HAT, RIDE, PERC, SHAKER, SNARE ROLL
- Bass: BASS, LOWS, SUB
- Melodic: SAW, STAB, SYNTH, LEAD
- FX: FX, RISER, ATMOS, CYMBALS
- Returns: A-Reverb, B-Delay, C-Comp

### Trance Templates

| Metric | Range | Typical |
|--------|-------|---------|
| BPM | 138-140 | 140 |
| Tracks | 61-109 | 87 |
| Duration | 800-1168 beats | 960 beats (~240 bars) |

**Common track names:**
- Drums: Kick, Clap, Cymbal, Hat, Fill, Snare Roll
- Bass: Bass Pad, Sub
- Melodic: Lead, Acid, ARP, Pluck, Chord Stab, Pad
- Strings: Violin, Cello, Strings
- FX: Riser, Down, Sweep, Impact, Crash
- Atmosphere: Atmo, Atmosphere, Vox
- Returns: A-Reverb, B-Delay, Parallel Comp

### Schranz Templates

| Metric | Range | Typical |
|--------|-------|---------|
| BPM | 154-157 | 155 |
| Tracks | 17-23 | 20 |
| Duration | 832-944 beats | 888 beats (~222 bars) |

**Sample categories (from filenames):**
```
KICK types:
  - SOLO_KICK_LOOP     — clean kick pattern (no layers)
  - RUMBLE_KICK_LOOP   — kick + sub rumble layer
  - KICK (oneshot)     — single kick hit

BASS types:
  - RUMBLE_BASS_LOOP   — sub bass with distortion/rumble character

DRUM LOOPS:
  - SCHRANZ_LOOP       — pre-mixed aggressive full drum pattern
  - PERC_LOOP          — percussion pattern
  - HAT_LOOP           — hi-hat pattern
  - RIDE_LOOP          — ride cymbal pattern

SYNTHS:
  - SYNTH_SHOT         — short distorted stab (key in name: G#, A, A#, X=atonal)
  - SYNTH_LOOP         — synth pattern (X=atonal)

FX:
  - ATMOS_FX           — atmospheric texture (key: A or X=atonal)
  - PERC_SHOT          — percussion oneshot
```

**Key characteristics:**
- **Fewer tracks** (17-23 vs techno's 30-50, trance's 80-100) but same group hierarchy
- **Heavy reliance on pre-mixed loops** — SCHRANZ_LOOP is a complete drum pattern
- **Layered kick system**: SOLO_KICK + RUMBLE_KICK for punch + sub
- **Atonal synth stabs**: Many samples marked "X" (no key)
- **No melodic content**: No leads, pads, or chord progressions
- **BPM embedded in filenames**: 150, 154, 157, 158 BPM variants

**Return bus naming (aggressive processing chain):**
- A-Glue: GlueCompressor for parallel compression (glue the mix)
- B-Beef: Saturator for harmonic saturation (add weight)
- C-OD: Overdrive for aggressive distortion (edge/grit)
- D-Haas: Stereo widening via Haas effect (width)

**Effects per track (normalized):**
| Genre | Compression/Saturation per track |
|-------|----------------------------------|
| Techno | 0.13 |
| Schranz | 0.17 |
| Trance | 0.28 |

Schranz uses fewer individual effects but routes more aggressively through return buses.

**Sample filename pattern:**
```
RY_TRIPTYKH_VOL{1,2}_{CATEGORY}_{NUMBER}_{KEY_OR_BPM}.wav

Examples:
  RY_TRIPTYKH_VOL1_RUMBLE_KICK_LOOP_004_154bpm.wav
  RY_TRIPTYKH_VOL2_SYNTH_SHOT_008_G#.wav
  RY_TRIPTYKH_VOL1_ATMOS_FX_004_X.wav  (X = atonal)
```

### Track Grouping Patterns

```
Techno typical structure:
├── Drums (Group)
│   ├── Kick
│   ├── Clap
│   ├── Hat (Closed)
│   ├── Hat (Open)
│   ├── Ride
│   ├── Perc 1-2
│   └── Shakers
├── Bass (Group)
│   ├── Sub
│   └── Mid Bass
├── Leads (Group)
│   ├── Synth 1
│   ├── Synth 2
│   ├── Stab
│   └── Saw
├── Pads (Group)
│   ├── Pad
│   ├── Atmos
│   └── Strings
├── FX (Group)
│   ├── Riser
│   ├── Down
│   ├── Crash
│   ├── Impact
│   └── Snare Roll
├── Atmosphere (Group)
│   ├── Atmo 1
│   └── Vox
├── A-Reverb (Return)
├── B-Delay (Return)
├── C-Parallel Comp (Return)
└── Master

Trance typical structure:
├── Drums (Group)
│   ├── Kick
│   ├── Clap
│   ├── Hat
│   └── Cymbal
├── Bass (Group)
│   ├── Sub
│   └── Bass Pad
├── Leads (Group)
│   ├── Main Lead
│   ├── Lead 2
│   └── Pluck
├── Pads (Group)
│   ├── Pad 1
│   └── Strings
├── Acid (Group)
│   ├── Acid 1
│   └── Acid 2
├── FX (Group)
│   ├── Riser
│   ├── Down
│   ├── Impact
│   └── Crash
├── Atmosphere (Group)
│   ├── Atmo 1
│   └── Vox
├── A-Reverb (Return)
├── B-Delay (Return)
├── C-Parallel Comp (Return)
└── Master

Schranz typical structure (same group hierarchy as techno/trance):
├── Drums (Group)
│   ├── Kick              — sharp, cutting transient
│   ├── Kick Roll         — kick rolls for fills
│   ├── Clap              — clap/snare loops
│   ├── Hat               — hi-hats
│   ├── Ride              — ride cymbals
│   └── Perc              — percussion
├── Bass (Group)
│   ├── Drive 1           — rumble/drive (SEPARATE from kick)
│   ├── Drive 2           — second drive layer
│   └── Sub               — rumble sub bass
├── Melodics (Group)
│   ├── Synth Stab 1      — distorted stabs (often atonal)
│   ├── Synth Stab 2      — rave stabs
│   ├── Synth Loop         — synth patterns
│   └── Pad               — minimal pads (if any)
├── FX (Group)
│   ├── Riser             — builds/sweeps
│   ├── Impact            — impacts/crashes
│   ├── Atmos             — atmosphere/texture
│   └── Snare Roll        — fills
├── Atmosphere (Group)
│   ├── Atmo              — industrial textures
│   └── Vox               — rap vocals/shouts (optional)
├── A-Glue (Return)       — parallel compression
├── B-Beef (Return)       — saturation
├── C-OD (Return)         — overdrive
├── D-Haas (Return)       — stereo widening
└── Master

Key differences from techno (same structure, different content):
- KICK is 3-layer: punch + rumble + grit (separate tracks)
- BASS/DRIVES are separate from kick (not processed together)
- Melodic content mostly atonal stabs, rarely pads
- Higher BPM (150-160)
- More aggressive/distorted samples throughout
- Return buses focused on distortion/saturation instead of reverb/delay
```

---

## Minimal Working Example

```rust
fn generate_minimal_als() -> String {
    r#"<?xml version="1.0" encoding="UTF-8"?>
<Ableton MajorVersion="5" MinorVersion="11.0_433" Creator="audio_haxor" Revision="">
    <LiveSet>
        <NextPointeeId Value="10000" />
        <OverwriteProtectionNumber Value="2816" />
        <LomId Value="0" />
        <LomIdView Value="0" />
        <Tracks>
            <AudioTrack Id="0">
                <LomId Value="0" />
                <LomIdView Value="0" />
                <IsContentSelectedInDocument Value="false" />
                <PreferredContentViewMode Value="0" />
                <TrackDelay><Value Value="0" /><IsValueSampleBased Value="false" /></TrackDelay>
                <Name>
                    <EffectiveName Value="Kick" />
                    <UserName Value="Kick" />
                    <Annotation Value="" />
                    <MemorizedFirstClipName Value="" />
                </Name>
                <Color Value="14" />
                <AutomationEnvelopes><Envelopes /></AutomationEnvelopes>
                <TrackGroupId Value="-1" />
                <TrackUnfolded Value="true" />
                <DevicesListWrapper LomId="0" />
                <ClipSlotsListWrapper LomId="0" />
                <ViewData Value="{}" />
                <TakeLanes><TakeLanes /><AreTakeLanesFolded Value="true" /></TakeLanes>
                <LinkedTrackGroupId Value="-1" />
                <SavedPlayingSlot Value="-1" />
                <SavedPlayingOffset Value="0" />
                <Freeze Value="false" />
                <VelocityDetail Value="0" />
                <NeedArrangerRefreeze Value="true" />
                <PostProcessFreezeClips Value="0" />
                <DeviceChain>
                    <!-- Full DeviceChain structure required -->
                </DeviceChain>
            </AudioTrack>
        </Tracks>
        <MasterTrack>
            <!-- Full MasterTrack structure required -->
        </MasterTrack>
        <PreHearTrack>...</PreHearTrack>
        <SendsPre><Value /></SendsPre>
        <Scenes>
            <Scene Id="0">
                <FollowAction>
                    <FollowTime Value="4" />
                    <IsLinked Value="true" />
                    <LoopIterations Value="1" />
                    <FollowActionA Value="4" />
                    <FollowActionB Value="0" />
                    <FollowChanceA Value="100" />
                    <FollowChanceB Value="0" />
                    <JumpIndexA Value="0" />
                    <JumpIndexB Value="0" />
                    <FollowActionEnabled Value="false" />
                </FollowAction>
                <Name Value="" />
                <Annotation Value="" />
                <Color Value="-1" />
                <Tempo Value="120" />
                <IsTempoEnabled Value="false" />
                <TimeSignatureId Value="-1" />
                <LomId Value="0" />
                <ClipSlotsListWrapper LomId="0" />
            </Scene>
        </Scenes>
        <Transport>
            <PhaseNudgeTempo Value="10" />
            <LoopOn Value="true" />
            <LoopStart Value="0" />
            <LoopLength Value="128" />
            <LoopIsSongStart Value="false" />
            <CurrentTime Value="0" />
            <PunchIn Value="false" />
            <PunchOut Value="false" />
            <MetronomeTickDuration Value="0" />
            <DrawMode Value="false" />
        </Transport>
        <GlobalQuantisation Value="4" />
        <Grid>
            <FixedNumerator Value="1" />
            <FixedDenominator Value="16" />
            <GridIntervalPixel Value="20" />
            <Ntoles Value="2" />
            <SnapToGrid Value="true" />
            <Fixed Value="false" />
        </Grid>
        <ScaleInformation>
            <RootNote Value="0" />
            <Name Value="Major" />
        </ScaleInformation>
        <InKey Value="false" />
        <Locators><Locators /></Locators>
        <ChooserBar Value="0" />
        <Annotation Value="" />
        <SoloOrPflSavedValue Value="true" />
        <SoloInPlace Value="true" />
        <LatencyCompensation Value="2" />
        <GroovePool><LomId Value="0" /><Grooves /></GroovePool>
        <AutomationMode Value="true" />
    </LiveSet>
</Ableton>"#.to_string()
}
```

---

## Critical Implementation Findings

### ID Management (CRITICAL)

**Problem**: Ableton Live rejects files with "Non-unique list ids" error if any `Id="X"` attribute values are duplicated across the entire document.

**Solution**: Use a global ID allocator with a HashSet to guarantee uniqueness:

```rust
struct IdAllocator {
    next_id: AtomicU32,
    used_ids: Mutex<HashSet<u32>>,
}

impl IdAllocator {
    fn new(start: u32) -> Self { /* ... */ }
    
    fn alloc(&self) -> u32 {
        loop {
            let id = self.next_id.fetch_add(1, Ordering::SeqCst);
            let mut used = self.used_ids.lock().unwrap();
            if !used.contains(&id) {
                used.insert(id);
                return id;
            }
        }
    }
    
    fn reserve(&self, id: u32) {
        self.used_ids.lock().unwrap().insert(id);
    }
}
```

**Key rules**:
1. Reserve all IDs from the base template before generating new content
2. Allocate fresh IDs for EVERY `Id="X"` attribute when duplicating tracks/clips
3. Set `NextPointeeId` to `max_allocated_id + 1000` or higher
4. Small IDs (0-10) can be duplicated in certain internal structures (RemoteableTimeSignature, WarpMarker, etc.) - these are scoped and don't cause conflicts

### XML Attribute Requirements

**`<RelativePath>`**: Must have `Value=""` attribute, NOT self-closing `<RelativePath />`:
```xml
<!-- WRONG - causes "Required attribute 'Value' missing" error -->
<RelativePath />

<!-- CORRECT -->
<RelativePath Value="" />
```

### Track Ordering

GroupTracks must appear IMMEDIATELY BEFORE their child tracks in the `<Tracks>` section:
```xml
<Tracks>
    <GroupTrack Id="1000">...</GroupTrack>  <!-- DRUMS group -->
    <AudioTrack Id="2000">...</AudioTrack>  <!-- KICK (child of DRUMS) -->
    <AudioTrack Id="2001">...</AudioTrack>  <!-- SNARE (child of DRUMS) -->
    <GroupTrack Id="1001">...</GroupTrack>  <!-- SYNTHS group -->
    <AudioTrack Id="2002">...</AudioTrack>  <!-- BASS (child of SYNTHS) -->
    <AudioTrack Id="2003">...</AudioTrack>  <!-- No group (TrackGroupId="-1") -->
</Tracks>
```

### GroupTrack vs AudioTrack Structure

GroupTrack has fundamentally different internal structure - contains `<Slots>` instead of `<MainSequencer>`:
```xml
<GroupTrack Id="X">
    <!-- NO MainSequencer -->
    <Slots>
        <GroupTrackSlot Id="0"><LomId Value="0" /></GroupTrackSlot>
        <!-- ... -->
    </Slots>
</GroupTrack>
```

Child tracks link via `<TrackGroupId Value="X" />` where X is the GroupTrack's Id.

### Sample Types: Loops vs Oneshots

**Critical distinction** - samples must be handled differently based on type:

#### Loops (pre-made patterns)
- Already contain the full rhythmic pattern (e.g., a 4-bar drum loop)
- Use as-is: one `AudioClip` spanning the loop duration
- Set `LoopOn="true"` to repeat if needed
- Examples: "126_Kick_Loop_18.wav", "HiHat_Loop_06_150bpm.wav"

#### Oneshots (single hits)
- Single sound event with no inherent rhythm
- **Cannot be used raw for rhythmic parts** - will play once then silence
- Must be programmatically repeated to form a pattern:

```
Kick (4/4):     |X . . . |X . . . |X . . . |X . . . |  (every beat)
Snare/Clap:     |. . X . |. . X . |. . X . |. . X . |  (beats 2 & 4)
Hi-hat (8ths):  |X X X X |X X X X |X X X X |X X X X |  (every 8th note)
Hi-hat (16ths): |xxxxxxxx|xxxxxxxx|xxxxxxxx|xxxxxxxx|  (every 16th note)
```

**Implementation options for oneshots:**
1. **Multiple AudioClips** - create separate clip for each hit at correct beat positions
2. **MIDI + Sampler** - use MidiTrack with Simpler/Sampler device, place MIDI notes
3. **Pre-compose** - combine oneshots into loops externally before importing

#### FX / Transitional elements
- Oneshots work raw: risers, impacts, crashes, sweeps
- These are single events, not rhythmic patterns
- Place one `AudioClip` at the desired position

**Beat/note timing reference (4/4 time):**
| Division | Beats per bar | Beat duration |
|----------|---------------|---------------|
| Whole note | 1 | 4 beats |
| Half note | 2 | 2 beats |
| Quarter note | 4 | 1 beat |
| 8th note | 8 | 0.5 beats |
| 16th note | 16 | 0.25 beats |

### Sample References (External Files)

For external WAV files, use `Type="2"`:
```xml
<SampleRef>
    <FileRef>
        <RelativePathType Value="0" />
        <RelativePath Value="" />
        <Path Value="/absolute/path/to/sample.wav" />
        <Type Value="2" />
        <LivePackName Value="" />
        <LivePackId Value="" />
        <OriginalFileSize Value="123456" />
        <OriginalCrc Value="0" />
    </FileRef>
    <LastModDate Value="0" />
    <SourceContext>
        <SourceContext Id="0">
            <OriginalFileRef>
                <FileRef Id="0">
                    <!-- Same content as outer FileRef -->
                </FileRef>
            </OriginalFileRef>
            <BrowserContentPath Value="" />
            <LocalFiltersJson Value="" />
        </SourceContext>
    </SourceContext>
</SampleRef>
```

### XML Escaping

All paths and names must be XML-escaped:
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&apos;`

### Clip Positioning

Clips use beats (not bars) for positioning:
- `Time` attribute = start beat (0-indexed)
- `CurrentStart` = start beat
- `CurrentEnd` = end beat
- 4 beats = 1 bar
- Bar 1 = beat 0, Bar 5 = beat 16

### Color Consistency

When setting track color, replace ALL `<Color Value="X" />` elements within the track XML (including internal device colors) to maintain visual consistency.

### Track Name Display

Both `EffectiveName` AND `UserName` must be set for the name to display correctly:
```xml
<EffectiveName Value="KICK" />
<UserName Value="KICK" />
```

### Warp Markers for Tempo Warping

**Critical for proper sample playback at project tempo.** WarpMarkers tell Ableton how to stretch/compress samples to match BPM.

```xml
<WarpMarkers>
    <WarpMarker Id="0" SecTime="0" BeatTime="0" />
    <WarpMarker Id="1" SecTime="7.272721..." BeatTime="16" />
</WarpMarkers>
```

**Key rules:**
1. First marker anchors sample start: `SecTime="0"` `BeatTime="0"`
2. Second marker defines stretch target: `SecTime=actual_sample_duration` `BeatTime=target_loop_beats`
3. Calculate target beats from loop length: `loop_bars * 4` (e.g., 4-bar loop = 16 beats)

**Calculating loop_bars from sample duration:**
```rust
fn loop_bars(duration_secs: f64, bpm: f64) -> u32 {
    let beats = (duration_secs * bpm) / 60.0;
    let bars = beats / 4.0;
    
    // Round to common loop lengths
    match bars {
        b if b < 1.5 => 1,
        b if b < 3.0 => 2,
        b if b < 6.0 => 4,
        b if b < 12.0 => 8,
        _ => 16,
    }
}
```

**Getting accurate sample duration:**

Database duration values are often unreliable (zeros, wildly incorrect). Read duration directly from WAV header:
```rust
fn read_wav_duration(path: &str) -> Option<f64> {
    let mut file = File::open(path).ok()?;
    let mut header = [0u8; 44];
    file.read_exact(&mut header).ok()?;
    
    if &header[0..4] != b"RIFF" || &header[8..12] != b"WAVE" { return None; }
    
    // Parse fmt chunk for sample_rate, channels, bits_per_sample
    // Parse data chunk for data_size
    // duration = (data_size / bytes_per_sample / channels) / sample_rate
}
```

### Project BPM Setting

Set tempo in MasterTrack's Tempo element AND in automation events:
```xml
<Tempo>
    <Manual Value="128" />  <!-- BPM value -->
    <!-- ... -->
</Tempo>

<!-- Also update tempo automation if present -->
<FloatEvent Id="0" Time="-63072000" Value="128" />
<FloatEvent Id="1" Time="0" Value="128" />
```

### Mixer Visibility in Arrangement View

Hide the mixer in arrangement view with:
```xml
<MixerInArrangement Value="0" />  <!-- 0=hidden, 1=visible -->
```

### Track Routing to Groups

Child tracks inside groups route audio to the group track:
```xml
<AudioOutputRouting>
    <Target Value="AudioOut/GroupTrack" />
    <UpperDisplayString Value="Group" />
    <LowerDisplayString Value="" />
</AudioOutputRouting>
```

Tracks NOT in a group route to Master:
```xml
<AudioOutputRouting>
    <Target Value="AudioOut/Master" />
    <UpperDisplayString Value="Master" />
    <LowerDisplayString Value="" />
</AudioOutputRouting>
```

### Sample Cycling for Full Arrangements

When sample arrays are smaller than clip count needed, cycle through them:
```rust
fn cycle_samples(samples: &[SampleInfo], n: usize) -> Vec<SampleInfo> {
    if samples.is_empty() { return vec![]; }
    (0..n).map(|i| samples[i % samples.len()].clone()).collect()
}
```

Example: 8 samples → 48 clips = each sample used 6 times in sequence.

### Multi-Arrangement Mode

Generator supports placing multiple complete songs sequentially in one `.als` file:
- User specifies arrangement count (e.g., 3 songs)
- Each arrangement is a complete track (intro → outro)
- Arrangements placed end-to-end in arrangement view
- Locators/markers at each song boundary for navigation
- Use case: batch variations, DJ sets, album sketches

---

## Implementation Checklist

### Core Generation
- [x] XML builder with proper escaping
- [x] ID generator (element, pointee, automation target) - USE HASHSET!
- [x] gzip compression wrapper

### Track Generation
- [x] AudioTrack with full DeviceChain
- [ ] MidiTrack with full DeviceChain  
- [x] GroupTrack with slot count matching scenes
- [ ] ReturnTrack with effect chains
- [ ] MasterTrack with tempo/time signature

### Clip Generation
- [x] AudioClip with SampleRef
- [ ] MidiClip with KeyTracks/Notes
- [x] WarpMarker calculation (dynamic from sample duration)
- [x] Loop region configuration
- [x] LoopEnd based on actual sample loop length

### Mixer
- [x] Volume (linear scale conversion) — KICK at unity, other tracks attenuated
- [ ] Pan (-1 to 1)
- [x] Sends (per ReturnTrack) — category-aware Send A (Reverb) / Send B (Delay)
      amounts in `send_levels_for`. Kick/sub/bass stay dry; pads wettest; leads
      add delay. See `src-tauri/src/techno_generator.rs` helper.
- [x] Routing (Master/Group)
- [x] MixerInArrangement visibility toggle

### Bus Topology & Sidechain
- [x] Six group tracks: **KICKS** (own bus so the kick pulse drives the
      sidechain without feeding back), **DRUMS**, **BASS**, **BASS FX**,
      **MELODICS**, **FX**. Groups are skipped entirely when they have no
      children — track-count math is computed from `song1.*.iter().any(...)`,
      not hardcoded.
- [x] **Group-level sidechain** Compressor2 on **DRUMS / BASS / BASS FX /
      MELODICS**, keyed to `AudioIn/Track.<KICKS_group_id>/PostFxOut`. One
      compressor per bus (not per track) so ducking is uniform and avoids
      double compression. FX bus is deliberately un-sidechained so risers /
      impacts / crashes stay transient.
- Template: `src-tauri/src/group_sidechain_compressor_template.xml`
  (SideChain `OnOff` pre-enabled, Threshold ≈ -14 dB, Ratio 4:1,
  `__SC_SRC_ID__` placeholder substituted at emit time).

### Master Chain
- [x] **Eq8** on MainTrack with Band.0 as a 12 dB/oct HPF at **30 Hz** — subsonic
      rumble cleanup that doesn't cost any low-end warmth.
      Template: `src-tauri/src/master_eq8_hpf_template.xml`.
- [x] **Limiter** on MainTrack: Ceiling **-0.3 dB**, AutoRelease on, LinkChannels
      on, Lookahead on. Catches peaks without touching mix gain staging.
      Template: `src-tauri/src/master_limiter_template.xml`.
- Both devices are injected in front of the template's existing StereoGain
  (Utility) — HPF first, Limiter second, then Utility — so the chain order is
  rumble-cleanup → peak-catch → final trim.

### Automation
- [ ] BoolEvent for mutes
- [ ] FloatEvent for continuous params
- [ ] Bezier curve support
- [ ] Envelope-to-Pointee linking

### Arrangement
- [x] Beat/bar positioning
- [x] Clip placement by section
- [x] Full 6-minute arrangement (192 bars / 768 beats)
- [x] Sample cycling for long arrangements
- [ ] Overlap handling
- [x] Section markers (Locators)
- [x] Multi-arrangement mode (multiple songs per file)

---

## Sample Categorization Rules

### Filename/Path → Track Category Mapping

Based on analysis of professional sample packs (Dave Parkinson Trance, ZTEKNO Techno, Schranz Industrial).

#### DRUMS Group

| Track | Include Keywords | Exclude Keywords | Loop/Oneshot |
|-------|------------------|------------------|--------------|
| **KICK** | `kick`, `kick_loop` | `snare`, `&_bass`, `no_kick`, `no kick`, `nokick`, `without_kick`, `without kick` | Both |
| **CLAP** | `clap`, `snare`, `clap_loop`, `snare_loop` | `kick`, `build` | Both |
| **HAT** | `hat`, `hihat`, `chat`, `ohat`, `ride` | `kick`, `snare` | Both |
| **PERC** | `perc`, `percussion`, `shaker`, `conga`, `bongo`, `tom` | `kick`, `snare`, `hat` | Both |
| **DRUMS** (full) | `beat_loop`, `drum_loop`, `top_loop`, `breakbeat`, `drive` | - | Loops |

#### BASS Group

| Track | Include Keywords | Exclude Keywords | Loop/Oneshot |
|-------|------------------|------------------|--------------|
| **BASS** | `bass`, `sub`, `bassline`, `rumble` | `kick`, `drum` | Both |
| **KICK_&_BASS** | `kick_&_bass`, `kick_bass` | - | Loops (schranz) |

#### MELODICS Group

| Track | Include Keywords | Exclude Keywords | Loop/Oneshot |
|-------|------------------|------------------|--------------|
| **SYNTH** | `synth`, `synth_loop`, `acid`, `acid_line`, `arp`, `sequence`, `pluck`, `groove` | `pad`, `drum`, `shot` | Both |
| **LEAD** | `lead`, `lead_loop`, `melody` | `pad` | Both |
| **PAD** | `pad`, `pad_loop`, `chord`, `string` | `drum` | Loops |
| **STAB** | `stab`, `synth_shot`, `chord_stab` | `loop` | Oneshots |

#### FX Group

| Track | Include Keywords | Exclude Keywords | Loop/Oneshot |
|-------|------------------|------------------|--------------|
| **RISER** | `riser`, `uplifter`, `up_sweep`, `upsweep`, `build`, `snare_build`, `whoosh`, `white_noise`, `noise_fx` | `impact`, `crash`, `hit`, `down` | Oneshots |
| **HITS** | `impact`, `crash`, `hit`, `downlifter`, `down_sweep`, `downsweep`, `fx_shot`, `fx_hit` | `loop`, `riser`, `sweep_up` | Oneshots |
| **ATMOS** | `atmos`, `atmosphere`, `ambient`, `texture`, `drone`, `background_fx` | `drum`, `kick`, `snare` | Both |

#### VOX Group

| Track | Include Keywords | Exclude Keywords | Loop/Oneshot |
|-------|------------------|------------------|--------------|
| **VOX** | `vox`, `vocal`, `voice` | `drum` | Both |

### Filename Pattern Examples

**Trance (Dave Parkinson):**
```
DPTE Atmosphere - 001 - 140 BPM - F.wav       → ATMOS
DPTE Down Lifter - 001.wav                     → HITS (downlifter)
DPTE Up Sweep - 001 - 140 BPM.wav             → RISER
DPTE Impact - 001.wav                          → HITS
DPTE Snare Build - 001 - 140 BPM.wav          → RISER (build)
DPTE2 Lead Synth Loop - 001 - 140 BPM - A.wav → LEAD
DPTE2 Pad Loop - 001 - 140 BPM - C Minor.wav  → PAD
```

**Techno (ZTEKNO):**
```
ZTAT_126_CHat_Loop_1.wav                       → HAT (closed hat)
ZTAT_126_OHat_Loop_1.wav                       → HAT (open hat)
ZTAT_126_C_Acid_Line_1_Dry.wav                → SYNTH (acid)
ZTAT_126_A_Groove_1.wav                        → SYNTH (groove with key)
ZTAT_126_Background_Fx_1.wav                   → ATMOS
ZTAT_C_Stab_&_Chord_1.wav                      → STAB (oneshot)
ZTAT_126_Drums_Top_1_a.wav                     → DRUMS (top loop)
```

**Schranz (DGR_SCH_TLS):**
```
DGR_SCH_TLS_BEAT_LOOP_001.wav                  → DRUMS (full beat)
DGR_SCH_TLS_DRIVE_LOOP_155BPM_001.wav          → DRUMS (drive - schranz)
DGR_SCH_TLS_KICK_&_BASS_LOOP_001.wav           → KICK+BASS (layered)
DGR_SCH_TLS_RUBMLE_LOOP_001.wav                → BASS (rumble)
DGR_SCH_TLS_KICK_PUNCH_001.wav                 → KICK (punch layer)
DGR_SCH_TLS_RUMBLE_001.wav                     → BASS (sub oneshot)
DGR_SCH_TLS_LEAD_LOOP_155BPM_am_002.wav        → LEAD (with key)
DGR_SCH_TLS_STAB_001.wav                       → STAB
DGR_SCH_TLS_SYNTH_SHOT_001.wav                 → SYNTH (oneshot)
```

### Key Extraction from Filenames

Keys appear in filenames in various formats:
- Note letter: `C`, `D`, `F#`, `G#`, `A#`, `Bb`
- With quality: `Am`, `Cm`, `F Minor`, `G Sharp`
- Lowercase suffix: `_am`, `_bm`, `_cm` (minor implied)
- `X` = atonal (no key)

### BPM Extraction from Filenames

Common patterns:
- `_126_` or `_128_` embedded in name
- `140 BPM` or `140BPM` suffix
- `155bpm` suffix (lowercase)

### Wet/Dry Variants

Suffix `_Dry` or `_Wet` indicates effect processing level - ignore for categorization, treat as same sample with different mix.

### Genre-Specific Categories

| Genre | Unique Categories |
|-------|-------------------|
| Trance | `Uplifter`, `Down Lifter`, `Snare Build`, `Pluck`, `Acid` |
| Techno | `Groove`, `Top Loop`, `Background FX`, `CHat/OHat` |
| Schranz | `Drive`, `Rumble`, `Kick Punch`, `Kick & Bass` |

---

## Professional Arrangement Structure

Based on research of professional trance/techno tracks and arrangement guides.

### Standard Bar Structure (192 bars / 6 min at 128 BPM)

| Section | Bars | Beats | Cumulative | Description |
|---------|------|-------|------------|-------------|
| **INTRO** | 1-32 | 0-127 | 32 bars | Minimal - kick, sparse percussion, atmospheric |
| **BUILD 1** | 33-64 | 128-255 | 32 bars | Bass enters (bar 33), hats, layers build |
| **BREAKDOWN** | 65-96 | 256-383 | 32 bars | Kick OUT, bass OUT. Pads, filtered melody, tension |
| **DROP 1** | 97-128 | 384-511 | 32 bars | Everything IN. Full energy, main hook |
| **DROP 2** | 129-160 | 512-639 | 32 bars | Variation, maybe new element or 2nd melody |
| **FADEDOWN** | 161-176 | 640-703 | 16 bars | Energy decrease, strip elements |
| **OUTRO** | 177-192 | 704-767 | 16 bars | Mirror intro for DJ mixing |

**Total: 192 bars = 768 beats = 6 minutes at 128 BPM**

### Element Entry/Exit Points

| Element | Enters (bar) | Exits (bar) | Re-enters (bar) | Notes |
|---------|--------------|-------------|-----------------|-------|
| **KICK** | 1 | 65 (breakdown) | 97 (drop) | Out during breakdown |
| **BASS** | 33 | 65 (breakdown) | 97 (drop) | Enters after intro build |
| **HATS** | 17 | 65 (breakdown) | 97 (drop) | Add movement in intro |
| **PERC** | 33 | 65 (breakdown) | 97 (drop) | Layers with bass |
| **SYNTH/LEAD** | 33 (filtered) | 160 (fadedown) | - | Full at drop, filtered before |
| **PAD** | 65 | 96 | 129 | Prominent during breakdown |
| **RISER** | 57 (pre-breakdown) | 64 | 89-96 (pre-drop) | 8 bars before transitions |
| **CRASH** | - | - | 97, 129 | On drop entries |
| **ATMOS** | 1 | - | - | Throughout, vary intensity |

### Key Arrangement Rules

1. **Everything divisible by 8** - changes on bar 1, 9, 17, 25, 33, 65, 97, 129, etc.
2. **Add/remove one element every 8-16 bars** - keeps it evolving
3. **Breakdown = kick/bass OUT, pads/melody IN (filtered)**
4. **Riser 8 bars before drops** - bars 57-64 (pre-breakdown), 89-96 (pre-drop)
5. **Crash on phrase starts** - bars 1, 17, 33, 65, 97, 129, 161
6. **Intro/Outro mirror each other** - for DJ mixing
7. **16-bar rule** - make a change (add or remove element) every 16 bars minimum

### Section Energy Flow

```
Energy
  ^
  |                           ████████████████
  |                          █              ████████
  |              ████████████                       ██████
  |             █                                         ████
  |  ██████████                                               ████
  | █                                                             █████
  +-----------------------------------------------------------------> Bars
    1     32     64     96    128    160    176   192
  INTRO  BUILD  BREAKDOWN  DROP1   DROP2  FADE  OUTRO
```

### True Arrangement Logic (vs Linear Sample Placement)

**Wrong approach:** Place 48 different samples in a row on each track
- No arrangement structure
- No element entry/exit
- Just a wall of sound

**Correct approach:** Pick 1-2 loops per track, place according to structure
```rust
fn create_arrangement_clip(
    sample: &SampleInfo,
    entry_bar: u32,
    exit_bar: u32,
    loop_bars: u32,
) -> String {
    let start_beat = (entry_bar - 1) * 4;  // bar 1 = beat 0
    let end_beat = (exit_bar - 1) * 4;
    let clip_length = end_beat - start_beat;
    
    // Clip spans from entry to exit, loop_bars defines the internal loop length
    format!(r#"<AudioClip Time="{}" CurrentStart="{}" CurrentEnd="{}">
        <Loop>
            <LoopStart Value="0" />
            <LoopEnd Value="{}" />  <!-- loop_bars * 4 -->
            <LoopOn Value="true" />
        </Loop>
        ...
    </AudioClip>"#, start_beat, start_beat, end_beat, loop_bars * 4)
}
```

**Example: KICK track arrangement**
```
Bars:   1    17   33   49   65   81   97   113  129  145  161  177  192
        |----KICK-CLIP-1----|    |----KICK-CLIP-2----|----KICK-CLIP-3-|
                            ^^^^                      
                         BREAKDOWN                   
                         (no kick)                   
```

Place 3 clips:
1. `Time=0` to bar 64 (beat 256) - intro through build
2. `Time=384` (bar 97) to bar 160 (beat 640) - drop 1 & 2
3. `Time=640` (bar 161) to bar 192 (beat 768) - fadedown & outro

---

## File References

Template files analyzed:
- `docs/templates/*.als` (25 files)
- Decompressed XML: `docs/templates_xml/*.xml`

Genre breakdown:
- Techno: 12 templates (130-138 BPM, 21-197 tracks)
- Trance: 11 templates (138-140 BPM, 61-109 tracks)
- Schranz: 2 templates (154-157 BPM, 17-23 tracks)

Working examples:
- `src-tauri/examples/generate_techno_project.rs` - Full techno structure with ID allocator
- `src-tauri/examples/generate_toy_project.rs` - Simple test project
- `src-tauri/src/group_track_template.xml` - Embedded GroupTrack template
