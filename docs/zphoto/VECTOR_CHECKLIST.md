# zphoto — Adobe Illustrator → Rust Vector Port Checklist

Vector graphics mode is a **separate engine** inside `zphoto-core` (module `src/vector.rs`,
command namespace `vec.*`) that renders into the existing raster [`Layer`] stack, so every raster
facility (opacity, blend modes, masks, project/PSD save, filters) applies to vector output. SVG is
the interchange format; AI (a PDF container) and SVG import route through `zpdf-core`.

Status: ✅ done · 🚧 in progress · ⬜ not started · N/A out of scope.

## Document & workspace
| Illustrator | zphoto | Status |
| --- | --- | --- |
| New document | `vec.new {width,height}` → `vector::VectorDocument` | ✅ |
| Layers panel (add, stack, visibility, opacity) | `vec.layer.add`; `VectorLayer{visible,opacity,objects}` | ✅ |
| Artboards (single primary) | `Artboard` (one created with the doc) | ✅ |
| Multiple artboards | `vec.artboard.add` + `vec.render {artboard}` — per-artboard region render/export | ✅ |
| Guides | `vec.guide.add` — non-printing horizontal/vertical document guides (rulers/grid are editor UI) | ✅ |

## Drawing & geometry
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Rectangle / Rounded Rectangle | `vec.rect {x,y,width,height,radius?}` | ✅ |
| Ellipse | `vec.ellipse {x,y,width,height}` | ✅ |
| Polygon | `vec.polygon {cx,cy,r,sides}` | ✅ |
| Star | `vec.star {cx,cy,r1,r2,points}` | ✅ |
| Line segment | `vec.line {x0,y0,x1,y1}` | ✅ |
| Pen tool (cubic Bézier anchors + handles) | `vec.path.add {anchors:[{point,in,out}],closed}` | ✅ |
| Pencil / freeform polyline | `vec.path.add {points:[[x,y]…]}` | ✅ |
| Compound paths (holes via fill rule) | multi-`SubPath` `PathGeom` + `fill_rule` | ✅ |
| Round Corners / live corners | `vec.round_corners {object,radius}` — fillet sharp corners with a Bézier arc | ✅ |
| Shaper / Blob brush | — | ⬜ |

## Appearance — fill & stroke
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Solid fill (RGB) | `Paint::Solid`; `fill:[r,g,b]`/`"#rrggbb"` | ✅ |
| Fill rule (non-zero / even-odd) | `fill_rule` | ✅ |
| Stroke: width, color | `stroke:{color,width}` | ✅ |
| Stroke caps (butt/round/square) | `cap` | ✅ |
| Stroke joins (miter/round/bevel) | `join` (miter/bevel render as round this phase) | 🚧 |
| Dashed strokes | `dash:[…]` | ✅ |
| Object opacity | `opacity`; layer `opacity` | ✅ |
| Variable-width strokes (Width tool) | stroke `width_profile` — width tapers along arc length (trapezoid segments + round joins) | ✅ |
| Arrowheads | stroke `arrow_start`/`arrow_end` — filled triangle along the end tangent (open paths) | ✅ |
| Linear / radial gradients | `Paint::Linear/Radial` (stops, render + SVG `<linearGradient>`/`<radialGradient>`) | ✅ |
| Gradient on stroke | stroke `paint` accepts a gradient (same sampler) | ✅ |
| Gradient transform (independent of object) | gradient `transform` places it independently of the object (Gradient tool) | ✅ |
| Pattern fills | `Paint::Pattern` — tiled raster swatch (base64 RGBA), canvas-origin anchored; SVG exports a real <pattern> with the tile as an embedded PNG | ✅ |
| Gradient Mesh | — | ⬜ |
| Appearance panel (multiple fills/effects) | — | ⬜ |

## Transform & arrange
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Move / Scale / Rotate / Shear (Shear=skew) | `vec.object.transform {translate/scale/rotate/skew/matrix}` | ✅ |
| Group / Ungroup | `vec.group` / `vec.ungroup` | ✅ |
| Delete object | `vec.object.delete` | ✅ |
| Z-order (bring forward/send back) | `vec.object.reorder {to: front/back/forward/backward}` | ✅ |
| Align / Distribute | `vec.align {mode: left/right/hcenter/top/bottom/vcenter/distribute-h/distribute-v}` (bbox-based) | ✅ |
| Reflect | `vec.reflect {axis: h/v}` about the bbox centre | ✅ |
| Transform Again | `vec.transform_again {object}` — re-apply the last transform delta | ✅ |

## Pathfinder & shape building
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Unite / Minus Front / Intersect / Exclude | `vec.pathfinder {op}` — region boolean → compound path (even-odd); exact for axis-aligned, `PF_SCALE`-traced for curves | ✅ |
| Divide | `vec.divide` — split overlaps into per-region paths (topmost colour), grouped | ✅ |
| Trim | `vec.trim` — each object keeps its visible part (minus objects above), strokes dropped | ✅ |
| Crop | `vec.crop` — clip lower objects to the topmost shape, discard the top | ✅ |
| Merge | `vec.merge` — trim hidden + unite same-colour regions | ✅ |
| Shape Builder tool | — | ⬜ |
| Outline Stroke | `vec.outline_stroke` — stroke region (caps/dashes/width) traced into a filled compound path | ✅ |
| Offset Path | `vec.offset_path {distance}` — grow/shrink via mask morphology + trace | ✅ |

## Type
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Point type | `vec.text` → `ObjectKind::Text` (bundled font via the `text` module), SVG `<text>` | ✅ |
| Type on a path | `vec.text {on_path:{points}}` → `text::render_on_path` | ✅ |
| Area type (wrapping in a shape) | `vec.text {area_width}` — word-wrap to box width via font metrics | ✅ |
| Character / paragraph styling (size, align, tracking, leading) | `size`/`align`/`tracking`/`leading` on the text object | 🚧 |
| Type rotation / shear (full affine) | point/area type warped through the full object transform (axis-aligned keeps the crisp fast path) | ✅ |
| Create outlines (text → paths) | `vec.text_to_outlines` — rasterize glyphs + trace to a filled compound path | ✅ |

## Masks, blends, effects
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Clipping mask | `vec.clip` — clipping group (topmost object clips the rest to its shape) | ✅ |
| Opacity mask | `vec.opacity_mask` — mask object's luminance×alpha scales the target's alpha | ✅ |
| Blend modes (per object) | `vec.object.blend {mode}` — all 45 raster `LayerMode`s, blended in isolation then composited | ✅ |
| Blend tool (interpolate shapes) | `vec.blend {a,b,steps}` — anchor-matched tween of geometry + fill colour, grouped | ✅ |
| Effects (drop shadow, blur, feather) | `vec.object.drop_shadow`/`blur`/`feather` — rasterized non-destructive effects; warp/distort reuse raster `filter.*` later | 🚧 |
| Symbols / instances | `vec.symbol.define` + `vec.symbol.place` — template registry, placed instances (snapshot) | ✅ |
| Image Trace (raster → vector) | `vec.trace {image,threshold}` — threshold ink + boundary trace → vector path (B&W; multi-colour later) | ✅ |

## File I/O
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Render vector → raster layers | `vec.render` → raster `Image` (one layer per vector layer) | ✅ |
| SVG export | `vec.save {format:"svg"}` | ✅ |
| SVG import | `vec.open {svg}` — `<g>`/`<path>`(M/L/C/Z)/`<rect>`/`<ellipse>`/`<circle>`/`<line>` + fill/stroke; full round-trip: paths, shapes, gradients, text | ✅ |
| AI import (PDF container) | via `zpdf-core` → content-stream path/fill ops | ⬜ |
| PDF export | `vec.save {format:"pdf"}` — minimal valid PDF, vector path operators (solid; text/gradient later) | ✅ |
| EPS export | `vec.save {format:"eps"}` — PostScript path output | ✅ |
| Raster export (PNG/JPEG/…) | via `vec.render` + raster `image.save` | ✅ |
| Native vector project (JSON) | `VectorDocument` is `serde`-serializable | 🚧 |

## Rendering
| Capability | zphoto | Status |
| --- | --- | --- |
| Anti-aliased fill (non-zero + even-odd) | scanline, 4× vertical SSAA + exact horizontal span coverage | ✅ |
| Anti-aliased stroke | stroke-to-fill outline (round caps/joins) | ✅ |
| Affine-correct stroke width scaling | average device scale | ✅ |
| Nested group transforms / opacity | recursive `render_object` | ✅ |
