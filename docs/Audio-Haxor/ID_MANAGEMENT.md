# ID Management in ALS Files

Ableton Live requires globally unique IDs across the entire document. Duplicate IDs cause "Non-unique list ids" errors.

## ID Types

### 1. Element IDs

Every XML element with an `Id` attribute must have a unique value:

```xml
<AudioTrack Id="14">
<AudioClip Id="66" Time="0">
<AutomationEnvelope Id="0">
<WarpMarker Id="0" SecTime="0" BeatTime="0" />
```

### 2. Pointee IDs

Global reference IDs for automation targets. Referenced by `<PointeeId Value="X" />`:

```xml
<Pointee Id="19721" />
<!-- Later referenced as: -->
<PointeeId Value="19721" />
```

### 3. Automation Target IDs

Used by `<AutomationTarget>` and `<ModulationTarget>` elements:

```xml
<AutomationTarget Id="16128">
    <LockEnvelope Value="0" />
</AutomationTarget>
```

### 4. NextPointeeId

Document-level tracker for next available Pointee ID:

```xml
<NextPointeeId Value="100000" />
```

**Must be set higher than any allocated ID** to prevent conflicts when Ableton assigns new IDs.

## ID Allocator Pattern

```rust
use std::collections::HashSet;
use std::sync::atomic::{AtomicU32, Ordering};
use std::sync::Mutex;

struct IdAllocator {
    next_id: AtomicU32,
    used_ids: Mutex<HashSet<u32>>,
}

impl IdAllocator {
    fn new(start: u32) -> Self {
        Self {
            next_id: AtomicU32::new(start),
            used_ids: Mutex::new(HashSet::new()),
        }
    }
    
    /// Allocate a new unique ID
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
    
    /// Reserve an ID (mark as used without allocating)
    fn reserve(&self, id: u32) {
        self.used_ids.lock().unwrap().insert(id);
    }
    
    /// Get the highest allocated ID
    fn max_allocated(&self) -> u32 {
        self.next_id.load(Ordering::SeqCst)
    }
}
```

## Usage Pattern

### 1. Parse Template and Reserve Existing IDs

```rust
fn reserve_template_ids(template_xml: &str, allocator: &IdAllocator) {
    let id_re = Regex::new(r#"Id="(\d+)""#).unwrap();
    for cap in id_re.captures_iter(template_xml) {
        let id: u32 = cap[1].parse().unwrap();
        allocator.reserve(id);
    }
}
```

### 2. Replace IDs When Duplicating Tracks

When duplicating a track template, ALL Id attributes must be replaced:

```rust
fn replace_all_ids(track_xml: &str, allocator: &IdAllocator) -> String {
    let id_re = Regex::new(r#"Id="(\d+)""#).unwrap();
    
    id_re.replace_all(track_xml, |_caps: &regex::Captures| {
        format!(r#"Id="{}""#, allocator.alloc())
    }).to_string()
}
```

### 3. Set NextPointeeId

After all IDs are allocated, set NextPointeeId higher than max:

```rust
let next_pointee = allocator.max_allocated() + 1000;
// Replace in XML: <NextPointeeId Value="{next_pointee}" />
```

## Exception: Small Internal IDs

Some elements with small IDs (0, 1, 2, etc.) are scoped within their parent and don't cause global conflicts:

- `<RemoteableTimeSignature Id="0">` - inside TimeSignature
- `<WarpMarker Id="0">` / `<WarpMarker Id="1">` - inside WarpMarkers
- `<AutomationLane Id="0">` - inside AutomationLanes

These can be left as-is when duplicating tracks.

## ID Ranges

Organize IDs by type to avoid conflicts:

| Range | Purpose |
|-------|---------|
| 0-999 | Reserved/small internal IDs |
| 1000-9999 | GroupTrack IDs |
| 10000-19999 | AudioTrack IDs |
| 20000-29999 | MidiTrack IDs |
| 30000-49999 | AudioClip IDs |
| 50000-69999 | Pointee IDs |
| 70000-89999 | AutomationTarget IDs |
| 90000+ | Generated IDs |

## Common Errors

### "Non-unique list ids"

**Cause:** Two or more elements have the same Id attribute value.

**Fix:** Use ID allocator with HashSet to guarantee uniqueness.

### "Required attribute 'Value' missing"

**Cause:** Element like `<RelativePath />` missing Value attribute.

**Fix:** Use `<RelativePath Value="" />` instead.

### Tracks not appearing

**Cause:** Track IDs collide with existing tracks in template.

**Fix:** Reserve all template IDs before generating new content.

## Testing ID Uniqueness

```rust
fn validate_unique_ids(xml: &str) -> Result<(), String> {
    let id_re = Regex::new(r#"Id="(\d+)""#).unwrap();
    let mut seen: HashSet<u32> = HashSet::new();
    
    for cap in id_re.captures_iter(xml) {
        let id: u32 = cap[1].parse().map_err(|e| format!("Parse error: {}", e))?;
        
        // Skip small IDs that are locally scoped
        if id < 10 {
            continue;
        }
        
        if seen.contains(&id) {
            return Err(format!("Duplicate ID: {}", id));
        }
        seen.insert(id);
    }
    
    Ok(())
}
```

## Template-Based Generation Flow

1. Load base template XML
2. Create IdAllocator starting at 100000
3. Reserve all IDs from template
4. For each new track:
   a. Clone track template section
   b. Replace all Id attributes with fresh allocations
   c. Insert into Tracks section
5. Set NextPointeeId to max_allocated + 1000
6. Write and compress as .als
