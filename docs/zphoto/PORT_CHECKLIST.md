# zphoto — GIMP → Rust Port Checklist

Tracks the port of GIMP (vendored reference: `vendor/gimp`, v3.3.1) into `zphoto-core`
(engine) + `zphoto` (GUI). Status: ✅ done · 🚧 in progress · ⬜ not started · N/A out of scope.

The engine is GUI-agnostic (mirrors GIMP's `app/core` vs GTK split). Every capability is
reached through the one command surface (`Engine::invoke`) so the Tauri app, the C ABI, and
Rust callers behave identically.

## Foundations (`app/core`, `libgimpcolor`, `libgimpbase`)

| GIMP | zphoto-core | Status |
| --- | --- | --- |
| `GimpImage` (canvas + layer stack) | `model::Image` | ✅ |
| `GimpLayer` / `GimpDrawable` | `model::Layer` | ✅ (paint attrs: opacity, offset, visible) |
| `GimpImageBaseType` (RGB/GRAY/INDEXED) | `model::BaseType` | 🚧 enum exists; only RGB pixels real |
| Pixel / colour | `model::Rgba` (8-bit) | ✅ |
| Image mode convert (RGB / grayscale / indexed median-cut, optional dither) | `image.convert` (indexed mode does median-cut palette + nearest-colour, or Floyd–Steinberg `dither` to diffuse the quantization error — smooth gradients instead of banding) | ✅ |
| Canvas Size (resize without scaling) | `image.resize_canvas` | ✅ |
| Reveal All (grow canvas to all layer content) | `image.reveal_all` (PS Image ▸ Reveal All; expands the canvas to the union of every layer's bounds so off-canvas content becomes visible, shifting all layers to the new origin) | ✅ |
| Crop to selection | `image.crop_to_selection` | ✅ |
| Crop to content / autocrop (trim uniform border) | `image.crop_to_content` (GIMP Image ▸ Crop to Content / PS Image ▸ Trim) | ✅ |
| Crop layer to content (trim a single layer's transparent border) | `layer.crop_to_content` (GIMP Layer ▸ Crop to Content) | ✅ |
| Matting: Defringe + Remove Black/White Matte | `layer.defringe` / `layer.remove_matte` (PS Layer ▸ Matting; defringe recolours each soft edge pixel from its nearest opaque neighbour within `width`; remove-matte un-multiplies a white/black background out of the semi-transparent edges `c=(c−matte·(1−α))/α`) | ✅ |
| Content-Aware Scale (seam carving, width + height shrink) | `layer.content_aware_carve` (PS Content-Aware Scale; min-energy seam removal, both dims via transpose) | ✅ |
| Auto-Align Layers (translation registration) | `layer.auto_align` (PS Edit ▸ Auto-Align Layers, translation only; brute-force ±`max_shift` search for the shift that best registers a layer onto a `reference` by min mean-absolute luma diff, with a non-overlap penalty so maximal overlap wins, then nudges the layer offset) | ✅ |
| Align Layers (Move-tool align buttons) | `layer.align` (PS Layer ▸ Align / Move-tool align; aligns every layer in `layers` to the first (anchor)'s rectangle along `edge` — left/right/hcenter/top/bottom/vcenter) | ✅ |
| Distribute Layers (even edge/centre spacing) | `layer.distribute` (PS Layer ▸ Distribute / Move-tool distribute; spaces 3+ layers evenly along `edge` — left/hcenter/right/top/vcenter/bottom — extremes fixed, middles equidistant) | ✅ |
| Distribute Spacing (equal gaps between layers) | `layer.distribute_spacing` (PS Layer ▸ Distribute ▸ Horizontal/Vertical spacing; equalizes the *gaps* between consecutive layers along `axis`, accounting for each layer's own size — distinct from edge-position distribute) | ✅ |
| Auto-Blend Layers (focus stacking) | `image.auto_blend` (PS Edit ▸ Auto-Blend Layers, focus-stack mode; per canvas pixel keeps the colour from whichever visible layer is sharpest there — largest Laplacian of luma — collapsing a focus stack into one all-in-focus layer) | ✅ |
| Photomerge (panorama stitch) | `image.photomerge` (PS File ▸ Automate ▸ Photomerge; lays the `second` image to the right of the first, brute-force finds the horizontal overlap (±2px vertical) that best matches, builds a widened canvas and linearly feathers the seam — returns a new panorama image) | ✅ |
| Merge to HDR / Exposure Fusion | `image.merge_hdr` (PS File ▸ Automate ▸ Merge to HDR Pro, fused à la Mertens; collapses a bracketed-exposure layer stack into one image, averaging each pixel weighted by well-exposedness — a Gaussian on luma peaking at mid-grey — so clipped shadows/highlights contribute little) | ✅ |
| Image Stack Modes (per-pixel statistics) | `image.stack_mode` (PS Layer ▸ Smart Objects ▸ Stack Mode; collapses the layer stack by a per-pixel per-channel statistic — `mean`/`median`/`max`/`min`/`range`/`sum`/`stddev`; median is the classic transient remover / burst denoiser) | ✅ |
| Contact Sheet (thumbnail grid) | `image.contact_sheet` (PS File ▸ Automate ▸ Contact Sheet II; tiles aspect-fit, centred thumbnails of an `images` list into a `cols`×`rows` grid of `cell`-px cells with `padding`/`background` on a fresh canvas) | ✅ |
| Content-Aware Fill (inpaint a selection from its surroundings) | `layer.content_aware_fill` (PS Edit ▸ Fill ▸ Content-Aware; Laplace diffusion) | ✅ |
| Fill ▸ History (fill a selection from a history state) | `fill.history` (PS Edit ▸ Fill ▸ Contents: History; fills the whole selection from a history snapshot `state` steps back — the instant whole-region counterpart of the History Brush) | ✅ |
| Content-Aware Move (relocate a selection + heal the hole) | `layer.content_aware_move` (PS Content-Aware Move tool; captures the selection, `content_aware_fill` heals the vacated source, then pastes the captured pixels at `(dx, dy)`) | ✅ |
| Red Eye removal | `op.red_eye` (PS Red Eye tool; a red-dominant pixel (`red / max(g,b) > threshold`, not near-black) is rebuilt from the non-red channels `(g+b)/2` and `darken`-ed into a dark neutral pupil; skin/whites untouched, scope with a selection) | ✅ |
| Higher precision (16/32-bit, float) — `GimpPrecision` | `image.convert` `8bit`/`16bit`/`32bit` → `model::BitDepth`; pixels stored as `model::RgbaF` (f32 working space), snapped to the depth grid after every command (`Layer::quantize_to`); 16-bit PSD encode/decode | ✅ |
| Tiled buffer (`GeglBuffer`) | flat `Vec<Rgba>` | ⬜ tiling optimization later |
| Image registry / ids | `Engine.images` | ✅ |
| Image duplicate (independent copy under a fresh id) | `image.duplicate` (GIMP Image ▸ Duplicate / PS Image ▸ Duplicate) | ✅ |
| Error envelope | `error::Error` + `to_envelope` | ✅ |

## Projection & compositing (`gimp_projection`, layer modes)

| GIMP | zphoto-core | Status |
| --- | --- | --- |
| Flatten / projection | `Image::render` (W3C separable blend) | ✅ |
| Layer opacity + per-pixel alpha | `render` honours both | ✅ |
| Layer modes (normal/multiply/screen/overlay/darken/lighten/add/subtract/difference) | `LayerMode` + compositor | ✅ |
| Layer modes — extended (color-dodge/burn, hard/soft-light, exclusion, divide, grain-extract/merge, linear-burn) | `LayerMode` (W3C separable + GIMP grain/divide) | ✅ |
| Layer modes — commercial light (vivid-light, linear-light, pin-light, hard-mix) | `LayerMode` + `vivid_light` (PS light-group blends) | ✅ |
| Layer modes — non-separable (hue, saturation, color, luminosity) | `LayerMode` + `blend_rgb` (W3C SetLum/SetSat) | ✅ |
| Layer mode — Dissolve (stochastic) | `LayerMode::Dissolve` + compositor (each pixel painted fully or not at all, probability = effective coverage, via a deterministic per-pixel hash — the grainy transition; not a per-channel blend) | ✅ |
| Paint mode — Behind / Clear | `PaintMode::Behind` (PS Behind; the brush colour fills only the layer's transparent areas, existing opaque pixels stay on top — paint composited *under* the destination). `clear` maps to the Eraser (PS Clear = erase). | ✅ |
| Layer modes — non-separable whole-pixel (darker-color, lighter-color) | `LayerMode` + `blend_rgb` (luminance min/max; full PS 28-mode set) | ✅ |
| Layer attrs (opacity/visible/name/offset/mode), duplicate, reorder | `layer.set`/`layer.duplicate`/`layer.reorder` | ✅ |
| Merge Down (composite a layer into the one below) | `layer.merge_down` (GIMP Layer ▸ Merge Down / PS Ctrl+E) | ✅ |
| Merge Group (flatten a group to one raster layer) | `layer.merge_group` (GIMP Merge Layer Group / PS Merge Group) | ✅ |
| Move layer into a group (build groups incrementally) | `layer.move_to_group` | ✅ |
| Adjustment layers (non-destructive, applied to the composite below) | `layer.add_adjustment` + `model::Adjustment` (invert/desaturate/equalize/brightness-contrast/gamma/exposure/channel-mixer/selective-color/color-lookup/hue-sat/posterize/levels/curves/vibrance/black-white/threshold/gradient-map/photo-filter/color-balance + non-destructive filters: gaussian-blur/box-blur/sharpen/unsharp-mask); opacity-blended, save/load round-trip (PS adjustment layers + smart filters) | ✅ |
| Smart Objects + Smart Filters (non-destructive stack) | `Layer.smart_source` + `Layer.smart_filters` + `model::SmartFilter` (`layer.smart_convert`/`smart_filter`/`smart_reset`/`smart_rasterize`/`smart_replace` (Replace Contents — swaps the embedded source with another image's render and re-renders the filter stack over it); PS Smart Objects — the layer embeds its untouched source and a replayable `filter.*`/`op.*` stack re-rendered over it, so filters stay editable; one undo step per smart filter (re-render is snapshot/record-suppressed via `smart_depth`), base64 source + stack survive project save/load) | ✅ |
| Fill Layers (non-destructive solid/gradient/pattern) | `Layer.fill` + `model::FillLayer` (`layer.fill_layer`/`layer.set_fill`; PS Layer ▸ New Fill Layer — a layer whose pixels are *generated* from a re-editable **Solid** / **Gradient** (linear or radial) / **Pattern** (a registered `pattern` tile, embedded) descriptor; `set_fill` regenerates while preserving the mask/opacity/mode; descriptor saved in the project format) | ✅ |
| Clipping masks (clip a layer to the one below) | `Layer.clipped` + clip-base tracking in render (`layer.set {clipped}`; PS clipping mask, save/load round-trip) | ✅ |
| Blend If (blending-options luminance gates) | `Layer.blend_if` + `model::BlendIf` (`layer.blend_if {channel, this, under}`; PS Layer Style ▸ Blending Options ▸ Blend If — each pixel's alpha scaled by the four-stop "This Layer" + "Underlying" tone ramps on gray/R/G/B, Alt-drag feather via split stops; gated in the raster composite, save/load round-trip) | ✅ |
| Fill Opacity + Knockout (blending options) | `Layer.fill_opacity` + `Layer.knockout` + `model::Knockout` (`layer.set {fill_opacity, knockout}`; PS Layer Style ▸ Blending Options ▸ Fill / Knockout — fill opacity scales only the painted pixel contribution, a Deep/Shallow knockout punches the backdrop alpha in the layer's shape, so `fill 0` + `knockout deep` = the cut-out effect; save/load round-trip) | ✅ |
| Masks on adjustment + group layers (scope the effect) | `mask_at` in the adjustment/group render branches (paint a mask to limit an adjustment/group to part of the image; the #1 PS workflow) | ✅ |
| Layer via Copy (selected pixels to a new layer) | `layer.from_selection` (PS Ctrl+J) | ✅ |
| Layer via Cut (move selected pixels to a new layer) | `layer.via_cut` (PS Ctrl+Shift+J) | ✅ |
| Paste Into (paste a source masked to the selection) | `layer.paste_into` (PS Edit ▸ Paste Into; adds the `source` image's pixels as a new layer with its mask set to the current selection, so the paste shows only inside the selection) | ✅ |
| Edit ▸ Clear (erase the selection to transparent) | `op.clear` (Delete key; selection-aware, coverage-blended) | ✅ |
| Layer effect: drop shadow | `layer.drop_shadow` (soft, offset, tinted) + Layer menu | ✅ |
| Layer effect: stroke (outline the layer's opaque content) | `layer.stroke` (PS Layer Style ▸ Stroke; outside/inside/center, round profile) | ✅ |
| Layer effect: outer glow (soft coloured halo) | `layer.outer_glow` (PS Layer Style ▸ Outer Glow; spread + blur, inserted below) | ✅ |
| Layer effect: color overlay (tint content with a solid colour) | `layer.color_overlay` (PS Layer Style ▸ Color Overlay; clipped to alpha, opacity-blended) | ✅ |
| Layer effect: gradient overlay (fill content with a gradient) | `layer.gradient_overlay` (PS Layer Style ▸ Gradient Overlay; any shape/N-stop, clipped to alpha, opacity-blended) | ✅ |
| Layer effect: pattern overlay (tile a pattern over content) | `layer.pattern_overlay` (PS Layer Style ▸ Pattern Overlay; two-colour checker at `size`, canvas-keyed, clipped to alpha, opacity-blended) | ✅ |
| Layer effect: satin (interior sheen from shape) | `layer.satin` (PS Layer Style ▸ Satin; symmetric difference of the ±`(dx,dy)`-offset shape → contour band that hugs edges and clears the deep interior, `color`/`opacity`, clipped to alpha) | ✅ |
| Layer effect: inner shadow (shadow inside the content edges) | `layer.inner_shadow` (PS Layer Style ▸ Inner Shadow; offset-inverted-alpha, blur, clipped to shape) | ✅ |
| Layer effect: inner glow (glow along the inside edges) | `layer.inner_glow` (PS Layer Style ▸ Inner Glow; inner-ring band = alpha − erode, blur) | ✅ |
| Layer effect: bevel & emboss (light the alpha as a height field) | `layer.bevel_emboss` (PS Layer Style ▸ Bevel & Emboss; alpha-gradient · light direction → highlight/shadow) | ✅ |
| Layer groups | `Layer.children` (GimpGroupLayer) + recursive render + `layer.group`/`layer.ungroup`; group opacity/visible/mode, project save/load round-trip, and ops/fill/set reach nested layers (recursive `layer_mut`) | ✅ |
| Layer Comps (named visibility/appearance snapshots) | `comp.capture`/`comp.apply`/`comp.list`/`comp.delete` + `model::LayerCompState` (PS Layer Comps panel; snapshots every layer's + nested child's visibility/opacity/offset/mode under a name, re-applied by id) | ✅ |
| Layer masks (add white/black/alpha/from-selection, invert, apply, remove) | `layer.*_mask` + render honours mask + Layer menu | ✅ |
| Layer mask Properties: Feather + Density | `layer.mask_feather` (PS mask Properties ▸ Feather; separable box-blurs the mask by `radius` — soft edge, non-destructive) + `layer.mask_density` (▸ Density; scales mask strength `mask·d + 255·(1−d)`, so `d`<1 lets masked areas show through partially) | ✅ |
| Vector Mask (path-driven, re-editable) | `Layer.vector_mask` + `layer.vector_mask` (PS Layer ▸ Vector Mask ▸ Current Path; rasterizes a stored path into the layer mask and keeps the path id live so editing the path + re-applying re-rasterizes; path id saved in the project format) | ✅ |

## File I/O (`app/file`, `app/xcf`, `plug-ins/common/file-*`)

| GIMP | zphoto-core | Status |
| --- | --- | --- |
| Load PNG / JPEG | `codec::decode_rgba` + `image.open` | ✅ |
| Open PNG/JPEG/BMP/GIF/TIFF/WebP | `image` crate (auto-detect) | ✅ |
| Save PNG/JPEG/BMP/TIFF/GIF | `image.save` + File menu | ✅ |
| PSD export (Photoshop document) | `image.save` format `psd` — flattened, or `layered:true` for editable layers (per-layer rect/channels/blend-mode/opacity/name + composite preview), RLE/PackBits-compressed by default (`rle:false` for raw); spec-correct, opens in Photoshop | ✅ |
| PSD import (open layered .psd) | `image.open` auto-detects `8BPS` → `codec::decode_psd` (raw + RLE/PackBits, 8-bit RGB) reconstructs the layer stack (rect/pixels/blend-mode/opacity/name/**visibility**/**clipping** + layer masks via the `-2` channel); round-trips the writer | ✅ |
| Native layered project save/load (layers+pixels+masks+modes+paths) | `project.save` / `project.load` (JSON + base64 RGBA; the round-trippable format `image.save` PNG can't be) | ✅ |
| XCF (GIMP native format) read + write, flat + layered + masks | `image.save` xcf (`encode_xcf`/`encode_xcf_layered`, `layered:true` — per-layer bounds/offsets/mode/opacity/name **+ 1-bpp mask channels**) + `image.open` → `decode_xcf` (uncompressed v0). Writer↔reader round-trips stack order, modes, opacity, masks, pixels exactly. GIMP-open + RLE not verified in CI | 🚧 |

## Operations / filters (`app/operations`, `plug-ins`, GEGL)

| GIMP | zphoto-core | Status |
| --- | --- | --- |
| Bucket fill (whole drawable) | `Layer::fill` + `layer.fill` | ✅ |
| Crop / scale canvas | `Image::crop` / `Image::scale` (`image.crop`/`image.scale`, `method`: nearest \| bilinear \| bicubic Catmull-Rom, default bilinear) | ✅ |
| Flip H/V, rotate 90/180/270 | `Image::flip_*`/`rotate` (`image.flip`/`image.rotate`) | ✅ |
| Arbitrary image rotation / straighten (any angle, canvas grows) | `image.rotate_arbitrary` (GIMP Image ▸ Transform ▸ Arbitrary Rotation) | ✅ |
| Perspective Crop (extract + rectify a quad) | `image.perspective_crop` (PS Perspective Crop tool; the 4 `corners` quad is rectified into a fresh `width`×`height` canvas via the rect→quad homography, removing keystone distortion — distinct from axis-aligned `image.crop` and in-place `layer.perspective`) | ✅ |
| Colour ops: invert, brightness/contrast, levels, gamma, threshold, desaturate | `ops` module (`op.*`) | ✅ |
| Colour ops: hue/sat, posterize, sepia, exposure, auto-contrast, curves (smooth monotone-cubic, like PS, or `smooth:false` linear) | `ops` module (`op.*`) | ✅ |
| Curves / Levels on the Alpha channel | `op.curves` / `op.levels` with `channel:"alpha"` (`ops::Channel::A`; remaps the transparency channel — edit a layer's alpha curve, leaving RGB intact, unlike RGB/All) | ✅ |
| Colour ops: vibrance, equalize, color balance, temperature | `ops` module (`op.*`) | ✅ |
| Black & White (channel-weighted mono + Tint) | `op.black_white` (PS Image ▸ Adjustments ▸ Black & White; `r`/`g`/`b` channel weights → monochrome, plus an optional `tint_hue`/`tint_sat` that colourises the result — the Tint checkbox; also a non-destructive adjustment layer) | ✅ |
| Channel Mixer (full RGB 3×3 + per-channel constant + monochrome) | `op.channel_mixer` (PS Image ▸ Adjustments ▸ Channel Mixer; each output channel = `rr·R + rg·G + rb·B + const`, all 9 weights + `const_r`/`const_g`/`const_b` offsets, `monochrome` mode) | ✅ |
| Color Balance (faithful 3-range: shadows/midtones/highlights × CR/MG/YB, preserve-luminosity) | `op.color_balance_tonal` (port of GIMP `gimpoperationcolorbalance.c`) | ✅ |
| Colorize (single hue/sat over per-pixel luma + lightness) | `op.colorize` (port of GIMP `gimpoperationcolorize.c`; = PS Hue/Sat "Colorize") | ✅ |
| Semi-Flatten (composite partial alpha over a bg, make opaque) | `op.semi_flatten` (port of GIMP `gimpoperationsemiflatten.c`, Layer ▸ Transparency) | ✅ |
| Threshold Alpha (harden soft alpha to a 1-bit mask) | `op.threshold_alpha` (port of GIMP `gimpoperationthresholdalpha.c`, Layer ▸ Transparency) | ✅ |
| Color to Alpha (key out a colour, un-mix RGB) | `op.color_to_alpha` (GIMP Colors ▸ Color to Alpha `gegl:color-to-alpha`) | ✅ |
| Photo Filter (warming/cooling cast, density, preserve luminosity) | `op.photo_filter` (PS Image ▸ Adjustments ▸ Photo Filter) | ✅ |
| Shadows/Highlights (global or radius local-adaptation) | `op.shadows_highlights` (PS Image ▸ Adjustments ▸ Shadows/Highlights; lifts shadows / recovers highlights — `radius` 0 weights by each pixel's luma (global), `radius`>0 by the Gaussian-blurred *local* tone so a dark pixel in a bright area lifts less, recovering local contrast) | ✅ |
| HDR Toning (Local Adaptation + Highlight Compression methods) | `op.hdr_toning` (PS Image ▸ Adjustments ▸ HDR Toning; `method` "local" splits luma into a `radius`-blurred base + detail, compresses the base toward mid-grey by `compress` and rescales colour — local detail retained; `method` "highlight_compression" is a global operator attenuating each pixel by `1/(1+compress·l²)` so blown highlights pull back into range while shadows hold) | ✅ |
| Lab colour adjustment (L/a/b axis shifts) | `op.lab` (editing in PS Lab mode; converts each pixel sRGB↔CIE L\*a\*b\* (D65) and shifts `lightness` ±100 on L, `a` ±128 on green↔red, `b` ±128 on blue↔yellow — true luminance + opponent-colour axes, distinct from hue/sat) | ✅ |
| Selective Color (per-band CMYK shift) | `op.selective_color` (PS Image ▸ Adjustments ▸ Selective Color; one named band reds/yellows/greens/cyans/blues/magentas/whites/neutrals/blacks × `c`/`m`/`y`/`k` deltas, `relative` or absolute, weighted by band membership) | ✅ |
| Clarity (midtone local contrast) | `op.clarity` (PS/Camera Raw ▸ Clarity; wide-radius compare-to-blur added back by `amount`, midtone-weighted `1−(2l−1)²` to spare shadows/highlights) | ✅ |
| Texture (fine local contrast) | `op.texture` (PS/Camera Raw ▸ Texture; tight-radius local contrast, no midtone weighting — crisps fine detail, vs clarity's broad midtone push) | ✅ |
| Dehaze (haze removal) | `op.dehaze` (PS/Camera Raw ▸ Dehaze; per-channel contrast stretch around mid-grey + saturation boost, scaled by `amount`; negative adds haze) | ✅ |
| Whites / Blacks (tone endpoints) | `op.whites` / `op.blacks` (PS/Camera Raw ▸ Whites/Blacks; push the highlight endpoint by `amount`·luma² / the shadow endpoint by `amount`·(1−luma)² — each end moves independently) | ✅ |
| Camera Raw Filter (Basic panel) | `op.camera_raw` (PS Filter ▸ Camera Raw Filter; runs temperature/tint → exposure/contrast → highlights/shadows/whites/blacks → texture/clarity/dehaze → vibrance/saturation in CR order, each stage skipped at 0, composing the existing + new tone ops) | ✅ |
| Split Toning / Color Grading (separate shadow + highlight tints) | `op.split_tone` (Lightroom/PS Split Toning) | ✅ |
| Auto White Balance (gray-world cast removal) | `op.auto_white_balance` (GIMP Colors ▸ Auto / PS Auto Color neutralization) | ✅ |
| Set Gray Point (neutral eyedropper) | `op.gray_point` (PS Levels/Curves neutral eyedropper; scales each channel by `gray/channel` so a sampled `color` that should be neutral becomes grey, removing the cast — anchored to a known-neutral pixel, unlike gray-world auto white balance) | ✅ |
| Auto Levels / Auto Tone (per-channel range stretch) | `op.auto_levels` (PS Auto Levels / Auto Tone; per-channel endpoint stretch) | ✅ |
| Auto Color (endpoint stretch + midtone neutralization) | `op.auto_color` (PS Image ▸ Auto Color; stretches each channel's endpoints **and** pulls each channel's normalized mean to a common neutral target via a per-channel gamma — removes a midtone cast, unlike the endpoint-only Auto Levels or the gain-only gray-world balance) | ✅ |
| Replace Color (fuzzy recolour near a target) | `op.replace_color` (PS Image ▸ Adjustments ▸ Replace Color) | ✅ |
| Color Lookup / 3D LUT (apply a colour cube, film looks) | `op.color_lookup` (PS Color Lookup adjustment; trilinear `n×n×n` cube; loads `.cube` files via `cube_text`) | ✅ |
| Match Color (transfer a reference's colour statistics) | `op.match_color` (PS Image ▸ Adjustments ▸ Match Color; Reinhard mean/std transfer) | ✅ |
| Match Histogram (exact per-channel distribution specification) | `op.match_histogram` (CDF mapping to a reference image; more precise than mean/std) | ✅ |
| Apply Image (blend another image with any blend mode) | `op.apply_image` (PS Image ▸ Apply Image; `source`/`mode`/`opacity`, all 28 modes via `LayerMode::blend_pixel`) | ✅ |
| Calculations (channel math → selection) | `op.calculations` (PS Image ▸ Calculations; blends two composite channels `channel_a`/`channel_b` (red/green/blue/gray) with any blend `mode` into a grayscale result stored as the new selection — the channel-math mask route) | ✅ |
| Displace (warp pixels by a map image's brightness) | `op.displace` (PS/GIMP Distort ▸ Displace; `map`/`amount`/`amount_y`) | ✅ |
| Bump Map (light the layer using a map as a height field) | `op.bump_map` (GIMP Map ▸ Bump Map; `map`/`azimuth`/`elevation`/`depth`) | ✅ |
| Ordered (Bayer) dithering to N levels | `op.dither` (4×4 Bayer; GIF/retro colour banding) | ✅ |
| Bitmap mode (1-bit: threshold / pattern / diffusion) | `op.bitmap` (PS Image ▸ Mode ▸ Bitmap; reduces luma to pure black/white by `method` — `threshold` (50%), `pattern` (Bayer screen), or `diffusion` (Floyd–Steinberg error diffusion)) | ✅ |
| Multi-stop Gradient Map (map luma through N colours) | `op.gradient_map_multi` (Colors ▸ Map ▸ Gradient Map; LUT-style grading) | ✅ |
| Duotone mode (mono/duo/tri/quadtone inks) | `op.duotone` (PS Image ▸ Mode ▸ Duotone; reproduces the greyscale with 1–4 custom `inks` via a subtractive printing model — white paper, each ink absorbs per channel at a shadow-weighted density, overprinting multiplicatively — distinct from the additive `gradient_map` LUT) | ✅ |
| Desaturate — 5 modes (lightness/luma/luminance/average/value) | `op.desaturate {mode}` (port of GIMP `gimpoperationdesaturate.c`; default stays luma) | ✅ |
| Hue-Saturation — full per-range (R/Y/G/C/B/M + master, overlap, achromatic) | `op.hue_saturation_full` (faithful port of GIMP `gimpoperationhuesaturation.c`) | ✅ |
| Blur (gaussian/box), sharpen, edge (Sobel), emboss | `filter` module (`filter.*`) | ✅ |
| Edge-Detect: Laplace (2nd-derivative magnitude) | `filter.laplace` (GIMP Edge-Detect ▸ Laplace) | ✅ |
| Edge-Detect: Difference of Gaussians (band-pass) | `filter.difference_of_gaussians` (GIMP Edge-Detect ▸ DoG) | ✅ |
| Median (denoise) + motion blur | `filter.median` / `filter.motion_blur` + Filter menu | ✅ |
| Dust & Scratches (threshold-gated despeckle) | `filter.dust_and_scratches` (PS Noise ▸ Dust & Scratches; replaces a pixel by the window median only when it exceeds `threshold` — removes specks, preserves sub-threshold detail, unlike plain `median`) | ✅ |
| Reduce Noise (edge-preserving bilateral) | `filter.reduce_noise` (PS Noise ▸ Reduce Noise; a true bilateral filter — spatial Gaussian × colour-range Gaussian whose σ grows with `strength` — smooths flat noise while a large colour difference keeps edges crisp; smooth range falloff, distinct from `surface_blur`'s hard threshold) | ✅ |
| Radial blur (spin + zoom) | `filter.radial_blur` (PS/GIMP Blur ▸ Radial Blur; `mode` spin/zoom, `cx`/`cy` centre, `amount`, `samples`; bilinear, edge-clamped) | ✅ |
| Lens blur (bokeh disc / polygonal iris) | `filter.lens_blur` (PS Blur ▸ Lens Blur; `radius` disc kernel so bright points bloom into uniform bokeh, plus an **iris** option — `blades`≥3 makes a regular-polygon aperture rotated by `rotation`, for the characteristic polygonal bokeh of a real lens) | ✅ |
| Lens blur with Depth Map (variable DoF) | `op.lens_blur_depth` (PS Blur ▸ Lens Blur + Depth Map; per-pixel disc radius = `\|depth − focal\| / 255 · max_radius` from a separate `depth` image — the focal plane stays sharp, bokeh grows with depth) | ✅ |
| Smart Sharpen (tone-faded unsharp) | `filter.smart_sharpen` (PS Sharpen ▸ Smart Sharpen; unsharp `amount`/`radius` attenuated toward tonal extremes by `fade` — midtones sharpened, shadows/highlights spared) | ✅ |
| Smart Sharpen — Remove Motion Blur (directional) | `filter.smart_sharpen_motion` (PS Smart Sharpen, Remove: Motion Blur; directional unsharp whose blur reference is a `motion_blur` of `length` along `angle` — counteracts motion blur, distinct from the isotropic Gaussian smart-sharpen) | ✅ |
| Average blur (mean fill) | `filter.average` (PS Blur ▸ Average; fills the layer with its single mean colour, selection-scoped by the dispatcher) | ✅ |
| Polar Coordinates (rect ↔ polar remap) | `filter.polar_coordinates` (PS/GIMP Distort ▸ Polar Coordinates; `mode` to_polar/to_rect — "tiny planet" wrap + unwrap; shared bilinear sampler) | ✅ |
| Waves / pond ripples (concentric radial displacement) | `filter.waves` (PS Distort ▸ ZigZag pond-ripples / GIMP Distorts ▸ Waves; `amplitude`/`wavelength`/`phase`/`cx`/`cy`, radial sine offset — distinct from linear `ripple`) | ✅ |
| Ocean Ripple (noise-driven water distortion) | `filter.ocean_ripple` (PS Distort ▸ Ocean Ripple; coherent value-noise vector field displaces pixels ±`magnitude` at `scale` — synthesized map, unlike `displace`; `seed`) | ✅ |
| Spherize (bulge/pinch + Normal/Horizontal/Vertical) | `filter.spherize` (PS Distort ▸ Spherize; power-curve lens remap in a centred `radius` circle — `amount>0` bulges, `<0` pinches; `axis` "both" (sphere), "horizontal" or "vertical" (1-axis cylinder, the PS Mode option)) | ✅ |
| Cartoon (dark-edge inking) | `filter.cartoon` (GIMP Artistic ▸ Cartoon; darkens pixels below their Gaussian-blurred local average → black contours, `radius`/`pct_black`) | ✅ |
| Photocopy (grayscale lineart) | `filter.photocopy` (GIMP Artistic ▸ Photocopy; ratio-to-local-average thresholding → black edges on white paper, neutral grey out, `radius`/`pct_black`) | ✅ |
| Graphic Pen (directional ink hatching) | `filter.graphic_pen` (PS Sketch ▸ Graphic Pen; diagonal ink bands at `spacing`/`angle` whose width tracks darkness → shadows fill with strokes, highlights stay bare; `ink`/`paper`) | ✅ |
| Colored Pencil (coloured hatching) | `filter.colored_pencil` (PS Artistic ▸ Colored Pencil; same hatch as graphic_pen but strokes keep the source hue, `paper` between — shared `on_hatch` helper) | ✅ |
| Crosshatch (crossed darkening strokes) | `filter.crosshatch` (PS Brush Strokes ▸ Crosshatch; two crossed hatch sets at `angle`/`angle+90°` multiply the source by `1−n·strength` — shadows fill, highlights bare, hue kept; shared `on_hatch`) | ✅ |
| Dark Strokes (directional contrast strokes) | `filter.dark_strokes` (PS Brush Strokes ▸ Dark Strokes; black strokes darken shadows + white strokes lighten highlights, band widens away from mid-grey — bidirectional, vs crosshatch's darken-only; shared `on_hatch`) | ✅ |
| Sprayed Strokes (1-D directional spray) | `filter.sprayed_strokes` (PS Brush Strokes ▸ Sprayed Strokes; coherent value-noise displaces each pixel ±`length` *along* `angle` only — 1-D, vs ocean_ripple's 2-D field; `scale`/`seed`) | ✅ |
| Accented Edges (edge brighten/darken) | `filter.accented_edges` (PS Brush Strokes ▸ Accented Edges; luma Sobel × `intensity` blends edges toward white (`brightness≥0.5`) or black, keeping the image — unlike `edge` which replaces it) | ✅ |
| Ink Outlines (crisp thresholded pen lines) | `filter.ink_outlines` (PS Brush Strokes ▸ Ink Outlines; darkens by `darkness` where luma Sobel exceeds `threshold`, image preserved elsewhere — hard threshold gives sharp lines, unlike `accented_edges`' continuous blend) | ✅ |
| Stamp (smoothed 2-tone) | `filter.stamp` (PS Sketch ▸ Stamp; desaturate → Gaussian blur `smoothness` → hard threshold `level` into `light`/`dark` — pre-blur dissolves sub-scale specks, unlike per-pixel `op.threshold`) | ✅ |
| Bas Relief (two-colour carved relief) | `filter.bas_relief` (PS Sketch ▸ Bas Relief; directional emboss relief mapped onto a `dark`→`light` gradient — coloured carving, distinct from grey `emboss`) | ✅ |
| Charcoal (edge strokes on paper) | `filter.charcoal` (PS Sketch ▸ Charcoal; luma Sobel × `amount` blends `paper`→`charcoal` along edges — two-tone sketch, flats stay bare paper) | ✅ |
| Chrome (metallic reflection banding) | `filter.chrome` (PS Sketch ▸ Chrome; desaturate → blur `smoothness` → reflection curve `\|sin(π·detail·v)\|` folds tones into bright/dark bands) | ✅ |
| Torn Edges (ragged 2-tone) | `filter.torn_edges` (PS Sketch ▸ Torn Edges; threshold at `level` jittered ±`roughness` per pixel → frayed `light`/`dark` boundary, flats stay solid; `seed`) | ✅ |
| Reticulation (clumpy film grain) | `filter.reticulation` (PS Sketch ▸ Reticulation; threshold tone against coherent value-noise (cell ≈ `density`) → dark tones get dense clumped black grain, distinct from `mezzotint` speckle; `seed`) | ✅ |
| Softglow (dreamy highlight bloom) | `filter.softglow` (GIMP Artistic ▸ Softglow; sigmoidal highlight curve → Gaussian blur → screen-blend; `radius`/`brightness`/`sharpness` — distinct from additive `glow`) | ✅ |
| Wind / Stagger (directional edge streaks) | `filter.wind` (PS Stylize ▸ Wind; bleeds bright-edge colour downwind with falloff; `direction`/`strength`/`threshold` + `method` — "wind" (uniform) or "stagger" (alternates streak direction every row, the shaky look)) | ✅ |
| Glowing Edges / Neon (coloured edge glow) | `filter.glowing_edges` (PS Stylize ▸ Glowing Edges / GIMP Edge-Detect ▸ Neon; per-channel Sobel × `intensity` → edges glow in the original hue on black, distinct from grey `edge`) | ✅ |
| Trace Contour (per-channel iso-level outlines, Lower/Upper edge) | `filter.trace_contour` (PS Stylize ▸ Trace Contour; dark line per channel where the value crosses `level`, on white; `edge` "lower" inks the below-level side of each crossing, "upper" the at/above side — a 1px shift) | ✅ |
| Tiles (offset tile grid, Fill Empty Area With) | `filter.tiles` (PS Stylize ▸ Tiles; `tile_size`/`max_offset` shift each tile by a deterministic offset; `fill` for the gaps — "color" (`bg`), "inverse" (inverted original), or "unaltered" (original shows through)) | ✅ |
| Chromatic aberration (R/B channel split) | `filter.chromatic_aberration` (lens fringing; GIMP Lens Distortion colour shift) | ✅ |
| Lens distortion (barrel / pincushion radial remap) | `filter.lens_distortion` (GIMP Distorts ▸ Lens Distortion; `amount` + `edge`) | ✅ |
| Lens Correction (distortion + CA + vignette) | `filter.lens_correction` (PS Filter ▸ Lens Correction; one pass of geometric `distortion`/`edge` (via `lens_distortion`), `chromatic` aberration recombination, and `vignette` *removal* — brightening each pixel by `1 + vignette·r²` to lift darkened corners) | ✅ |
| Whirl & pinch (swirl + radial pull within a circle) | `filter.whirl_pinch` (GIMP Distorts ▸ Whirl and Pinch; `whirl`/`pinch`/`radius`) | ✅ |
| ZigZag (Pond Ripples / Around Center styles) | `filter.zigzag` (PS Distort ▸ ZigZag; ridge field `amount·sin(2π·ridges·r/maxr)` applied as a radial displacement (`pond`/out — dropped-pebble rings) or a `style:"around"` tangential one (oscillating rotational swirl, distinct from the monotonic `whirl_pinch`); `amount` 0 is identity) | ✅ |
| Oilify / oil painting (neighbourhood mode filter) | `filter.oilify` (GIMP Artistic ▸ Oilify) | ✅ |
| Kuwahara (edge-preserving painterly smoothing) | `filter.kuwahara` (lowest-variance quadrant mean; keeps edges crisp) | ✅ |
| Surface Blur / Selective Gaussian (edge-preserving smooth) | `filter.surface_blur` (PS Blur ▸ Surface Blur / GIMP Selective Gaussian) | ✅ |
| Smart Blur (Normal / Edge-Only / Overlay modes) | `filter.smart_blur` (PS Blur ▸ Smart Blur; an edge-preserving `surface_blur` base then `mode` — `normal` keeps the blur, `edge_only` renders its white-on-black luma edges, `overlay` inks those edges back over the blur) | ✅ |
| Distort: ripple + spread | `filter.ripple` / `filter.spread` + Filter menu | ✅ |
| Enhance: high pass (frequency separation / sharpening) | `filter.high_pass` (orig − gaussian + 128; PS Other ▸ High Pass / GIMP Enhance ▸ High Pass) | ✅ |
| Enhance: unsharp mask with threshold (amount/radius/threshold) | `filter.unsharp_mask` (PS Sharpen ▸ Unsharp Mask / GIMP Enhance ▸ Sharpen) | ✅ |
| Generic: dilate / erode (greyscale value morphology) | `filter.dilate` / `filter.erode` (square element; GIMP Generic ▸ Dilate/Erode) | ✅ |
| Maximum / Minimum with Roundness (Preserve option) | `filter.maximum` / `filter.minimum` (PS Filter ▸ Other ▸ Maximum/Minimum; `round` selects a circular structuring element — Roundness — vs the default square `dilate`/`erode`) | ✅ |
| Other convolutions (custom kernel) | `filter.convolve` (arbitrary odd-square kernel + divisor + offset, GIMP Convolution Matrix) | ✅ |
| Blur ▸ Blur / Blur More | `filter.blur` / `filter.blur_more` (PS Blur ▸ Blur / Blur More; fixed [1,2,1]/4 smoothing, ×1 and ×3) | ✅ |
| Blur ▸ Sharpen More / Sharpen Edges | `filter.sharpen_more` / `filter.sharpen_edges` (PS Sharpen ▸ Sharpen More = ×3 sharpen; Sharpen Edges = sharpen feathered by the luma Sobel so flats stay put) | ✅ |
| Noise ▸ Despeckle | `filter.despeckle` (PS Noise ▸ Despeckle; 1px Gaussian blended in by `1 − edge-weight` — flats smooth, edges kept, the tonal inverse of `sharpen_edges`) | ✅ |
| Stylize ▸ Diffuse (Normal / Darken / Lighten) | `filter.diffuse` (PS Stylize ▸ Diffuse; each pixel ← a random ±1px neighbour — `mode` "normal", or "darken"/"lighten" which only take the candidate when it's darker/lighter than the original; palette preserved; `seed`) | ✅ |
| Stylize ▸ Extrude (Blocks / Pyramids) | `filter.extrude` (PS Stylize ▸ Extrude; `size` tiles filled with their mean + a `depth` shade — `type` "blocks" (top-left-lit diagonal bevel) or "pyramids" (centre-bright, edge-dark taper)) | ✅ |
| Other ▸ Offset | `filter.offset` (PS Other ▸ Offset, Wrap Around; `dx`/`dy` shift wrapping off-edge pixels back in — seamless-tile alignment, no content lost) | ✅ |
| Other ▸ HSB/HSL | `filter.hsb_hsl` (PS Other ▸ HSB/HSL; reads the RGB bytes as hue/sat/lightness and writes back the colour they denote, reusing `ops::hsl_to_rgb`) | ✅ |
| Pixelate ▸ Facet | `filter.facet` (PS Pixelate ▸ Facet; each pixel ← whichever 3×3 neighbour is nearest the local mean, snapping similar pixels into flat patches — distinct from `oilify` mode and `pixelate` grid) | ✅ |
| Blur Gallery ▸ Tilt-Shift | `filter.tilt_shift` (PS Blur Gallery ▸ Tilt-Shift; a sharp horizontal band at `center`/`range` ramps to a `radius` blur above + below — blur-once-then-feather via shared `focus_blur`) | ✅ |
| Blur Gallery ▸ Iris Blur | `filter.iris_blur` (PS Blur Gallery ▸ Iris Blur; an elliptical `cx`/`cy`/`rx`/`ry` focus region stays sharp, ramping to `radius` blur outside) | ✅ |
| Blur Gallery ▸ Field Blur | `filter.field_blur` (PS Blur Gallery ▸ Field Blur; a monotonic top→bottom blur gradient `from`→`to` of the `radius` blur) | ✅ |
| Distort ▸ Shear | `filter.shear` (PS Distort ▸ Shear; each row displaced by `amount·sin(2π·freq·y/h)`, `wrap` or clamp, bilinear) | ✅ |
| Distort ▸ Wave (Sine / Triangle / Square) | `filter.wave` (PS Distort ▸ Wave; 2-D displacement on both axes at once with a `waveform` type — `sine` (smooth), `triangle` (linear ramps), or `square` (hard ±amplitude jumps) — distinct from 1-D `ripple` and radial `waves`) | ✅ |
| Distort ▸ Glass | `filter.glass` (PS Distort ▸ Glass; a value-noise height field's *gradient* (sampled at a `smoothness` step, `scale`) displaces pixels by `distortion` — refracted-pane look, vs `ocean_ripple`'s value-as-vector; `seed`) | ✅ |
| Distort ▸ Diffuse Glow | `filter.diffuse_glow` (PS Distort ▸ Diffuse Glow; a blurred highlight mask (luma above `clear`) screen-blends toward white by `glow`, plus monochromatic `grain`; `seed`) | ✅ |
| Render ▸ Flame | `filter.flame` (PS Render ▸ Flame, rising-fire field; 4-octave turbulence × a bottom-hot ramp drives a black→red→orange→yellow→white palette, additively composited; `intensity`/`seed`) | ✅ |
| Render ▸ Picture Frame | `filter.picture_frame` (PS Render ▸ Picture Frame, plain bevel; a `width`-px `color` border with the outer ring lit / inner ring shadowed, interior untouched) | ✅ |
| Artistic ▸ Paint Daubs | `filter.paint_daubs` (PS Artistic ▸ Paint Daubs; oilify `size` dabs then a `sharpness` unsharp — the `{oilify + sharpen}` member, vs dry-brush posterize / fresco contrast) | ✅ |
| Artistic ▸ Palette Knife | `filter.palette_knife` (PS Artistic ▸ Palette Knife; median `size` smear flattened by `facet` — `{median + facet}`, vs cutout `{median + posterize}` / watercolor `{median + edge-darken}`) | ✅ |
| Artistic ▸ Rough Pastels | `filter.rough_pastels` (PS Artistic ▸ Rough Pastels; a 1px oilify pastel base embossed by `texturizer` canvas weave (`scale`/`depth`) — `{oilify + texturizer}`, vs underpainting `{median + texturizer}`) | ✅ |
| Brush Strokes ▸ Angled Strokes | `filter.angled_strokes` (PS Brush Strokes ▸ Angled Strokes; shadows darkened along `angle`, highlights lightened along `angle+90°`, both gated by the shared `on_hatch` screen at `spacing`; `strength`) | ✅ |
| Brush Strokes ▸ Spatter | `filter.spatter` (PS Brush Strokes ▸ Spatter; each pixel resampled from a random 2-D offset within `radius` — ragged airbrush spray, vs 1-D angle-locked `sprayed_strokes`; `seed`) | ✅ |
| Brush Strokes ▸ Sumi-e | `filter.sumi_e` (PS Brush Strokes ▸ Sumi-e; a `blur` wet-ink bleed then edges (luma Sobel) flooded toward black by `darkness` — thick dark contours, soft flats) | ✅ |
| Texture ▸ Grain | `filter.grain` (PS Texture ▸ Grain; monochromatic `grain_type` 0 Regular / 1 Clumped (value-noise) / 2 Sprinkles, scaled by `amount`; `seed` — vs colour `noise` / highlight-sparing `film_grain`) | ✅ |
| Sketch ▸ Chalk & Charcoal | `filter.chalk_charcoal` (PS Sketch ▸ Chalk & Charcoal; three-tone map — highlights→`chalk`, shadows→`charcoal`, midtones→grey paper) | ✅ |
| Sketch ▸ Conté Crayon | `filter.conte_crayon` (PS Sketch ▸ Conté Crayon; the chalk_charcoal three-tone in `fg`/`bg` crayon colours then a `texturizer` canvas weave — textured cousin of Chalk & Charcoal) | ✅ |
| Sketch ▸ Halftone Pattern | `filter.halftone_pattern` (PS Sketch ▸ Halftone Pattern, dot; a two-tone `ink`/`paper` newspaper screen, dot radius ∝ `1−luma` per `cell` — distinct from the CMYK `halftone`) | ✅ |
| Sketch ▸ Note Paper | `filter.note_paper` (PS Sketch ▸ Note Paper; tones split at `level` into light paper / dark recess, both sprinkled with monochromatic `grain` — vs the clean `stamp` threshold; `seed`) | ✅ |
| Sketch ▸ Plaster | `filter.plaster` (PS Sketch ▸ Plaster; luma pooled around `level` by a sigmoid, smoothed by `smoothness`, then lit as a height field via `emboss` — grey relief, vs `bas_relief`'s gradient carving) | ✅ |
| Sketch ▸ Water Paper | `filter.water_paper` (PS Sketch ▸ Water Paper; a vertical `fiber` motion blur runs colour along the grain, then a value-noise blotch (`contrast`) mottles brightness — soaked-fibre look; `seed`) | ✅ |
| Video ▸ De-Interlace | `filter.deinterlace` (PS Filter ▸ Video ▸ De-Interlace; discards one field — `eliminate` "odd"/"even" — rebuilding those scanlines by `method` "interpolate" (mean of the rows above/below) or "duplicate" (copy the row above)) | ✅ |
| Video ▸ NTSC Colors | `filter.ntsc_colors` (PS Filter ▸ Video ▸ NTSC Colors; clamps each channel into the broadcast-legal studio-swing range [16,235]) | ✅ |
| Coverage note: PS near-duplicates already covered | Shape Blur → `lens_blur` (disc); Spin Blur → `radial_blur` spin; Path Blur → `motion_blur`; Pinch → `spherize` (negative); Render ▸ Tree out of scope (L-system generator) | N/A |
| Progress streaming for long ops | (event sink, like sibling engines) | ⬜ |

## Selections, paths, tools (`app/core` selection, `app/paint`, `app/tools`)

| GIMP | zphoto-core | Status |
| --- | --- | --- |
| Selection mask / channels | `Image::selection` + `select.*`; all ops/fill/paint honour it | ✅ (rect/ellipse) |
| Selection: Reselect (restore last deselected) | `select.reselect` (PS Select ▸ Reselect; `select.all`/`select.none` stash the active selection into `Image::prev_selection`, reselect brings it back) | ✅ |
| Selection: Transform Selection (scale/move the marquee) | `select.transform` (PS Select ▸ Transform Selection; scales the selection mask by `sx`/`sy` about its bbox centre and translates by `dx`/`dy` — moves the marching ants without touching pixels, bilinear-sampled) | ✅ |
| Selection: magic-wand (fuzzy) + polygon lasso | `select.wand` + `select.polygon`, both with GUI tools | ✅ |
| Selection: Quick Selection (brush-grow) | `select.quick` (PS Quick Selection tool; each brush point floods a contiguous region within `tolerance` of its colour and adds it to the selection — dragging grows over similar connected areas, unlike the single-click wand or the raw-coverage Quick Mask brush) | ✅ |
| Selection: Similar (global colour extend) | `select.similar` (PS Select ▸ Similar; extends the selection to every pixel within `tolerance` of any selected colour across the whole image — non-contiguous, vs the contiguous `select.grow`/`select.wand`) | ✅ |
| Selection: Focus Area (sharpness-based) | `select.focus_area` (PS Select ▸ Focus Area, classic sharpness core; selects the in-focus pixels — luma Laplacian magnitude above `threshold` — so crisp subjects are picked and soft/blurred areas left out) | ✅ |
| Selection: color range (+ Localized Color Clusters) | `select.color_range` (PS Select ▸ Color Range; global colour select within `tolerance`, or `range`>0 for Localized Color Clusters — also requires pixels within `range` px of the `(x,y)` sample, so only the nearby cluster of the colour is taken) | ✅ |
| Selection: tonal range (highlights/midtones/shadows) | `select.tonal_range` (PS Select ▸ Color Range ▸ Highlights/Midtones/Shadows; a soft luma-band selection — `highlights` ramps toward white, `shadows` toward black, `midtones` peaks at mid-grey) | ✅ |
| Selection: Skin Tones | `select.skin_tones` (PS Select ▸ Color Range ▸ Skin Tones; soft selection of the skin band — hue near ~22° falling off by ±~43° with moderate saturation, excluding greys and out-of-band hues) | ✅ |
| Selection: boolean modes (add/subtract/intersect a region) | `mode` arg on rect/rounded_rect/ellipse/polygon/wand/color_range (PS Shift/Alt selection combine) | ✅ |
| Selection: rounded rectangle (corner radius) | `select.rounded_rect` (quarter-circle corners; UI/button shapes) | ✅ |
| Selection: load a channel as mask (luminosity masking) | `select.from_channel` (r/g/b/alpha/luma → selection; PS Load Selection from Channel) | ✅ |
| Selection: save / load named channels (alpha channels) | `select.save` / `select.load` (`Image.channels`; PS Save/Load Selection; persisted in the project format) | ✅ |
| Channels: spot colour channels (extra inks) | `channel.spot_add`/`channel.spot_fill`/`channel.spot_list`/`channel.spot_remove` + `model::SpotChannel` (PS Channels panel ▸ New Spot Channel; a named ink `color` + canvas coverage map, `spot_fill` inks the current selection, overprinted on the composite at render regardless of layer alpha) | ✅ |
| Channels: Split / Merge Channels | `image.split_channels` (decompose into three greyscale R/G/B channel images, returns their ids) + `image.merge_channels {red,green,blue}` (recombine three greyscale sources by luma into one RGB image) — PS Channels panel ▸ Split/Merge | ✅ |
| Selection: feather / grow / shrink / border / smooth / contrast | `select.grow` / `select.shrink` (circular morphology) + `select.feather` (separable Gaussian) + `select.border` (grow − shrink band) + `select.smooth` (median on the mask) + `select.contrast` (Select & Mask ▸ Contrast — steepens the mask transition by `amount`, hardening a feathered edge, the inverse of feather) | ✅ |
| Quick Mask (paint a selection + rubylith preview) | `select.paint` (PS Quick Mask brush; circular `radius` stroke sets coverage to `value`, 255 adds / 0 subtracts, materializing an empty mask to paint from scratch) + `image.quickmask` (50% red overlay on the unselected areas, encoded like `image.render`) | ✅ |
| Stroke Selection (outline the selection edge, inside/center/outside) | `layer.stroke_selection` (PS Edit ▸ Stroke; `location` places the `width` band inside / centred on / outside the selection edge) | ✅ |
| Filters: noise, pixelate, vignette | `filter.noise/pixelate/vignette` (Add Noise takes `monochromatic` — same delta on all channels for grey film grain that preserves hue, vs independent colour noise — and `gaussian` for the Box–Muller mid-clustered distribution vs the default flat uniform) | ✅ |
| Halftone Pattern (Dot / Line / Circle screen) | `filter.halftone` (single luma screen scaled by cell darkness; `pattern` "dot" (disc), "line" (thickness-modulated bar), or "circle" (concentric rings) — the PS Sketch ▸ Halftone Pattern Type) | ✅ |
| Color Halftone (per-channel angled dot screens) | `filter.color_halftone` (PS Pixelate ▸ Color Halftone; screens each RGB channel into `size`-spaced dots, each rotated to its own `angle_r`/`angle_g`/`angle_b` so the offset dots recombine into the comic colour-dot look) | ✅ |
| Crystallize (Voronoi cells) | `filter.crystallize` (PS Pixelate ▸ Crystallize; jittered seed per `cell_size` cell, each pixel takes its nearest seed's colour → flat crystalline tessellation) | ✅ |
| Stained Glass (Voronoi panes + lead) | `filter.stained_glass` (PS Texture ▸ Stained Glass; Voronoi cells flat-filled by seed colour with `border`-coloured lead lines between panes; shared `voronoi_seed` with crystallize) | ✅ |
| Patchwork (beveled average-colour quilt) | `filter.patchwork` (PS Texture ▸ Patchwork; `tile_size` average-colour tiles with a top-left-raised / bottom-right-recessed `relief` bevel — 3-D quilt, distinct from flat `pixelate`) | ✅ |
| Mosaic Tiles (grout grid over content) | `filter.mosaic_tiles` (PS Texture ▸ Mosaic Tiles; `grout`-coloured `grout_width` grid at `tile_size` with a 1px bevel — tile content preserved, unlike Stained Glass's flattening or `fill.grid`'s repaint) | ✅ |
| Craquelure (cracked-surface network) | `filter.craquelure` (PS Texture ▸ Craquelure; dark grooves along the contour lines of a coherent value-noise field split into `density` bands — organic crack network, content preserved between cracks; `scale`/`depth`/`seed`) | ✅ |
| Texturizer (procedural canvas emboss) | `filter.texturizer` (PS Texture ▸ Texturizer/Canvas; synthesizes a woven height field `sin(x·f)+sin(y·f)` at `scale` period and embosses it by `depth` — relief is generated, unlike `bump_map`'s external map) | ✅ |
| Underpainting (textured base coat) | `filter.underpainting` (PS Artistic ▸ Underpainting; median `coverage` simplifies into broad strokes then `texturizer` embosses a canvas weave — reuses median + texturizer) | ✅ |
| Sponge (blotchy saturation) | `filter.sponge` (PS Artistic ▸ Sponge; coherent value-noise drives a per-pixel saturation boost `1+amount·blotch` — patches soak pigment unevenly, neutral grey untouched; `scale`/`seed`) | ✅ |
| Smudge Stick (tone-weighted directional smear) | `filter.smudge_stick` (PS Artistic ▸ Smudge Stick; averages along the `angle` stroke over `(1−luma)·length` — shadows smear, highlights stay sharp) | ✅ |
| Dry Brush (dabs + reduced palette) | `filter.dry_brush` (PS Artistic ▸ Dry Brush; oilify `brush` dabs then posterize to `levels` — shares the `posterize_u8` step with cutout/poster-edges but simplifies via oilify not median) | ✅ |
| Fresco (dabs + contrast) | `filter.fresco` (PS Artistic ▸ Fresco; oilify `brush` dabs then push each channel from mid-grey by `contrast` — same oilify base as dry-brush, contrast curve instead of posterize) | ✅ |
| Poster Edges (posterize + inked edges) | `filter.poster_edges` (PS Artistic ▸ Poster Edges; posterize to `levels` flat steps then darken edges by `edge_intensity` × luma Sobel — comic/poster look combining posterize + edge) | ✅ |
| Cutout (simplified paper-cut shapes) | `filter.cutout` (PS Artistic ▸ Cutout; median radius `edge_simplicity` merges small detail, then posterize to `levels` flat colours — distinct from `op.posterize` which keeps every speck) | ✅ |
| Watercolor (pooled washes + wet edges) | `filter.watercolor` (PS Artistic ▸ Watercolor; median `detail` pools colour into washes then darkens wash boundaries by `edge_dark` × luma Sobel — continuous colour, the `{median+edge-darken}` combo vs cutout/poster-edges) | ✅ |
| Neon Glow (luminance-tinted neon) | `filter.neon_glow` (PS Artistic ▸ Neon Glow; desaturate + blur `glow_size` → recolour as luma × `color` × `brightness` — single neon hue on black, distinct from colour-keeping `softglow`/`glow`) | ✅ |
| Film Grain (highlight-protected grain) | `filter.film_grain` (PS Artistic ▸ Film Grain; monochromatic `grain` that fades above the `highlight` luma threshold — shadows/mids textured, highlights clean, distinct from flat `noise`) | ✅ |
| Plastic Wrap (specular contour shine) | `filter.plastic_wrap` (PS Artistic ▸ Plastic Wrap; smoothed-luma relief `\|∂luma\|·detail` → white specular screen-blended over the image — shiny shrink-wrap along contours, flats untouched) | ✅ |
| Fragment (4-way diagonal ghosting) | `filter.fragment` (PS Pixelate ▸ Fragment; averages four `offset`-diagonal copies — `mean(src(x±d,y±d))`; flats unchanged, dots split into four quarter-strength ghosts) | ✅ |
| Pointillize (source-coloured stipple) | `filter.pointillize` (PS Pixelate ▸ Pointillize; one jittered dot per `cell_size` cell coloured by the source centre, `bg` showing through the gaps) | ✅ |
| Mezzotint (dots / lines / strokes) | `filter.mezzotint` (PS Pixelate ▸ Mezzotint; per-channel pure 0/255 grain whose density follows the tone, with a `pattern` correlation — `dots` (per-pixel), `lines` (per-row → horizontal lines), or `strokes` (short horizontal runs); `seed`) | ✅ |
| Render: lens flare (central glow + ghosting halos) | `filter.lens_flare` (PS Render ▸ Lens Flare; `x`/`y`/`intensity`) | ✅ |
| Paint core (brush / pencil / eraser strokes) | `paint` module + `paint.stroke`; canvas drag in GUI | ✅ |
| Gradient (linear/radial/angular/reflected/diamond, 2-colour or N-stop, repeat/reflect modes) + bucket fill (flood, tolerance) | `fill` module (`fill.gradient` with `kind`/`stops`/`repeat`/`fill.bucket`) + GUI tools | ✅ |
| Render: checkerboard pattern (two-colour, cell size, selection-aware) | `fill.checkerboard` (port of GIMP `gimp:checkerboard`, Render ▸ Pattern) | ✅ |
| Render: grid (spacing x/y, line width, colour; overlays content) | `fill.grid` (GIMP Render ▸ Pattern ▸ Grid) | ✅ |
| Pattern fill (tile an RGBA pattern, seamless, selection-aware) | `fill.pattern` (PS Pattern fill / GIMP Fill with pattern; accepts inline data or a registered `pattern` name) | ✅ |
| Define Pattern (named pattern registry) | `pattern.define`/`pattern.list`/`pattern.delete` (PS Edit ▸ Define Pattern; captures the selection bounding box, or whole layer, into the engine pattern registry that `fill.pattern { pattern: name }` tiles) | ✅ |
| Define Brush Preset (named brush tips) | `brush.define`/`brush.stamp`/`brush.list`/`brush.delete` (PS Edit ▸ Define Brush Preset; captures the selection bbox as a grayscale tip — coverage = 255−luma so dark paints fully — and `brush.stamp { brush, x, y, size, color }` stamps it scaled + centred onto a layer) | ✅ |
| Pattern Maker (seamless texture from a sample) | `op.pattern_maker` (PS Filter ▸ Pattern Maker; samples the selection bbox and fills the layer by mirror/ping-pong tiling so every tile meets its own reflection — seamless, vs a straight `fill.pattern` whose sample edges can clash) | ✅ |
| Render: clouds / solid noise (fractal value noise) | `fill.clouds` (PS Render ▸ Clouds / GIMP Render ▸ Noise ▸ Solid Noise; `scale`/`octaves`/`seed`) | ✅ |
| Render: fibers (woven vertical-fibre texture) | `fill.fibers` (PS Render ▸ Fibers; anisotropic value noise — thin across x, stretched along y by `strength` — blends `color1`↔`color2`, `variance`/`seed`) | ✅ |
| Render: plasma (colourful turbulence) | `fill.plasma` (GIMP Render ▸ Noise ▸ Plasma; independent per-channel fractal noise → colourful turbulence, `scale`/`turbulence`/`seed`, distinct from grey `clouds`) | ✅ |
| Render: difference clouds (marbling) | `fill.difference_clouds` (PS Render ▸ Difference Clouds; renders clouds and difference-blends onto existing pixels — on black = clouds, on white = inverted, repeated = marbled veins) | ✅ |
| Render: lighting effects (spotlight) | `filter.lighting_effects` (PS Render ▸ Lighting Effects spotlight subset; light field peaks at `lx`/`ly`, linear falloff to `radius`, plus `ambient` — lit near the lamp, shadowed away; `brightness`) | ✅ |
| Paint: clone stamp + smudge | `paint.clone` / `paint.smudge` + GUI tools | ✅ |
| Paint: Spot Healing Brush (auto-source) | `paint.spot_heal` (PS Spot Healing Brush; each dab is inpainted from the mean of the ring just outside the brush — removes a blemish from its surroundings, no manual source unlike `paint.heal`) | ✅ |
| Paint: History Brush (paint from an earlier state) | `paint.history` (PS History Brush; brushes this layer's pixels from a snapshot `state` steps back — default 1 = the last edit's prior state — so a region can be reverted by hand) | ✅ |
| Paint: Pattern Stamp (brush a registered pattern) | `paint.pattern` (PS Pattern Stamp tool; tiles a registered `pattern` within the brush stroke, anchored to the canvas origin so it lines up with a pattern fill — source is the tiled pattern, unlike clone) | ✅ |
| Paint: Color Replacement brush (recolor, keep luma) | `paint.color_replacement` (PS Color Replacement tool; within the stroke, pushes each pixel's hue & saturation toward the target `color` while keeping the pixel's own luminance — texture/shading survive; a brush, unlike the global `op.colorize`) | ✅ |
| Paint: Background Eraser (colour-aware erase) | `paint.background_eraser` (PS Background Eraser; within the stroke, erases only pixels within `tolerance` of the target `color` (alpha reduced by dab coverage) and keeps dissimilar foreground pixels — wipes a background while leaving the subject, unlike the plain eraser) | ✅ |
| Magic Eraser (one-click erase to transparency) | `layer.magic_eraser` (PS Magic Eraser; clicking at `(x,y)` clears the matching colour to transparent within `tolerance` — `contiguous` flood-fills the connected region like the wand, else every matching pixel on the layer) | ✅ |
| Paint: Mixer Brush (wet-paint colour blending) | `paint.mixer` (PS Mixer Brush; carries a running colour along the stroke and blends a loaded reservoir `color` into it — `paint = lerp(carried, color, mix)` deposited by `flow·coverage`, then the carried colour picks up the canvas by `wet`; `mix` 0 = smear, 1 = paint reservoir — the wet-mix `smudge` lacks) | ✅ |
| Paint: dodge / burn | `paint.dodge` / `paint.burn` + GUI tools | ✅ |
| Paint: sponge (local saturate / desaturate) | `paint.sponge` (PS/GIMP Sponge tool; `mode` saturate\|desaturate) | ✅ |
| Paint: blur / sharpen brush (local focus tools) | `paint.blur` / `paint.sharpen` (toward / away from 3×3 mean) | ✅ |
| Liquify: forward-warp brush (push pixels along the drag) | `paint.warp` (PS Liquify Forward Warp / GIMP Warp Transform) | ✅ |
| Liquify: push-left brush (push perpendicular to the drag) | `paint.push` (PS Liquify Push Left; same warp but the displacement is rotated 90° left of the stroke — smears sideways to reshape edges, distinct from forward warp) | ✅ |
| Liquify: bloat / pucker brushes (local magnify / shrink) | `paint.bloat` / `paint.pucker` (PS Liquify Bloat & Pucker) | ✅ |
| Liquify: twirl brush (local clockwise / CCW rotation) | `paint.twirl` (PS Liquify Twirl; `angle`/`clockwise`) | ✅ |
| Paint: heal (mean-match) | `paint.heal` + GUI tool | ✅ |
| Paths / vectors | `model::Path` store + `path.add` (polyline **or** cubic Bézier) / `path.list` / `path.to_selection` / `path.from_selection` (Moore-trace a selection into a path) / `path.stroke` (anti-aliased; Bézier flattened to a polyline) | ✅ |
| Transform: arbitrary layer rotate (bilinear) | `layer.rotate` (Free Rotate) + Layer menu | ✅ |
| Transform: per-layer scale (bilinear) + flip H/V | `layer.scale` / `layer.flip` + Layer menu | ✅ |
| Transform: shear / skew (affine) | `layer.shear` (affine special case of `layer.perspective`; GIMP Shear / PS Skew) | ✅ |
| Transform: perspective (4-corner homography) | `layer.perspective` (projective warp, bilinear) | ✅ |
| Transform: Warp (freeform grid mesh) | `layer.warp` (PS Edit ▸ Transform ▸ Warp; a `cols`×`rows` grid with `points` destination vertices, each cell warped by its own quad→quad homography + backward bilinear sample — piecewise-perspective mesh, distinct from single-quad `perspective` and pin-based `puppet_warp`) | ✅ |
| Transform: Puppet Warp (multi-pin mesh deform) | `layer.puppet_warp` (PS Edit ▸ Puppet Warp; `pins` of `[from_x, from_y, to_x, to_y]` drag the image via an inverse-distance-weighted displacement field, `from == to` pins anchor a region to localize the warp; same canvas, bilinear backward-sample — distinct from 4-corner `perspective` and brush-based liquify) | ✅ |
| Text layers (vector font rasterizer, multi-line, L/C/R alignment, tracking + leading) | `text` module (ab_glyph + bundled Orbitron) + `text.add` (`align`/`tracking`/`leading`) + Layer menu | ✅ |
| Type on a path (glyphs along a vector path, rotated to tangent) | `text.on_path` (PS/GIMP Type on a Path; flattens the path + rotated glyph blit) | ✅ |
| Warp Text (preset-shape envelope + upper/lower bias) | `layer.warp_text` (PS Type ▸ Warp Text; per-column vertical envelope scaled by `bend` — `arc`/`arch`/`flag`/`wave`/`bulge`/`rise` (linear slant)/`fish` (pointed) — with a `bias` of `both` (symmetric), `upper` (top edge curves, bottom anchored) or `lower` (the Arc/Shell Upper-vs-Lower variants); backward bilinear sample; works on the rasterized text layer or any layer) | ✅ |
| Tools (move, transform, text) | move/marquee/brush/eraser/wand/lasso/gradient/bucket/text in GUI | ✅ |
| Undo / redo history | `edit.undo`/`edit.redo` (bounded snapshots) | ✅ |
| Fade last operation (blend result with the pre-op state) | `edit.fade` (PS Edit ▸ Fade; opacity lerp toward the last undo snapshot) | ✅ |
| Actions (record / replay command macros) | `action.record`/`action.stop`/`action.play`/`action.list`/`action.get`/`action.load`/`action.delete` (PS Actions panel; `invoke` captures every recordable command into a named macro, replays it verbatim or retargeted onto another image, with a replay-recursion guard; `get`/`load` serialize the step list for a host to persist as `.atn`-style files) | ✅ |

## GUI (`zphoto` app, `zgui-core`)

| Concern | zphoto | Status |
| --- | --- | --- |
| App shell (⌘K palette, settings, splash) | `ZGui.appShell` in `app.js` | ✅ |
| Open image (file picker → decode → display) | `zphoto-view.js` + `image.open`/`render` | ✅ |
| Canvas display of the real composite | `drawCanvas` via `image.render` | ✅ |
| Layers panel | `zphoto-view.js` table | ✅ basic |
| New image / add layer / fill | toolbar + palette | ✅ |
| Save/export dialog | — | ⬜ |
| Tools UI (selection, brush, transform) | — | ⬜ |
| Eyedropper (colour pick) + Histogram (bins + mean/median/std/min/max) | `image.pick` / `image.histogram` + GUI tool & modal chart | ✅ |
| Colour Sampler points (Info-panel markers) | `sampler.add`/`sampler.list`/`sampler.delete`/`sampler.clear` (PS Info-panel colour samplers; persistent `(x,y)` markers that report the live composite colour under each) | ✅ |
| Annotations (Note tool) | `note.add`/`note.list`/`note.delete`/`note.clear` (PS Note tool; `(x,y,text)` notes anchored on the document) | ✅ |
| GUI Polish Gate (G1–G4 / R1–R10) | see `README.md` | 🚧 scaffold only |

## Command surface today

`capabilities` · `image.new` · `image.open` · `image.save` · `image.list` · `image.get`
· `image.render` · `image.crop` · `image.scale` · `image.delete` · `layer.add` · `layer.list`
· `layer.remove` · `layer.fill` · `layer.set` · `layer.duplicate` · `layer.reorder`
· `op.invert` · `op.desaturate` · `op.gamma` · `op.threshold` · `op.brightness_contrast`
· `op.levels` · `edit.undo` · `edit.redo` · `edit.history`

Next up: curves, neighbourhood ops (gaussian blur / sharpen), hue-saturation, then selections.
