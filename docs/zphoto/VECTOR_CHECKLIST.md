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
| Arc tool | `vec.arc {cx,cy,rx,ry,start,end}` — open elliptical-arc sweep sampled to anchors | ✅ |
| Spiral tool | `vec.spiral {cx,cy,r,winds,decay}` — logarithmic spiral winding inward, 24 anchors/turn | ✅ |
| Rectangular Grid tool | `vec.grid {x,y,width,height,rows,cols}` — lattice of `rows+1`×`cols+1` open divider lines | ✅ |
| Flare tool | `vec.flare {cx,cy,radius,rays,ex,ey}` — a lens-flare group: radial centre glow + `rays` spokes + 3 halo rings along the axis (distinct from the raster `filter.lens_flare`) | ✅ |
| Symbol Sprayer (Symbolism) | `vec.symbol.spray {symbol,count,x,y,width,height,seed}` — scatter seeded-random instances of a symbol (position + 0.7–1.3× scale) into one grouped symbol set | ✅ |
| Symbolism tools (Shifter / Sizer / Spinner / Screener) | `vec.symbol.adjust {group,mode,amount,seed}` — seeded per-instance jitter of a symbol-set group: `shift` (translate), `size` (scale), `spin` (rotate), `screen` (opacity) | ✅ |
| Pen tool (cubic Bézier anchors + handles) | `vec.path.add {anchors:[{point,in,out}],closed}` | ✅ |
| Direct Selection (move anchors) | `vec.object.move_anchor {object,sub,index,x,y}` — drag a path's anchor (point + both handles) in document space; editor `A` tool | ✅ |
| Pencil / freeform polyline | `vec.path.add {points:[[x,y]…]}` | ✅ |
| Compound paths (holes via fill rule) | multi-`SubPath` `PathGeom` + `fill_rule`; `vec.compound {objects}` (Make) merges objects into one even-odd path (donor transforms baked) | ✅ |
| Path ▸ Simplify | `vec.simplify {object,tolerance}` — Ramer–Douglas–Peucker anchor reduction | ✅ |
| Path ▸ Join | `vec.join {object}` — close a single open contour, or weld multiple contours end-to-start into one | ✅ |
| Path ▸ Average | `vec.average {object,axis}` — move anchors to their mean (both / horizontal / vertical) | ✅ |
| Path ▸ Add Anchor Points | `vec.add_anchors {object}` — de Casteljau midpoint split per segment (curve unchanged) | ✅ |
| Path ▸ Remove Anchor Points | `vec.remove_anchors {object}` — drop alternate anchors, keep endpoints | ✅ |
| Round Corners / live corners | `vec.round_corners {object,radius}` — fillet sharp corners with a Bézier arc | ✅ |
| Distort ▸ Zig Zag | `vec.zigzag {object,size,ridges}` — alternating perpendicular ridges per segment | ✅ |
| Distort ▸ Pucker & Bloat | `vec.pucker_bloat {object,amount}` — offset segment midpoints from the centroid (bloat/pucker) | ✅ |
| Distort ▸ Twist | `vec.twist {object,angle}` — swirl anchors around the centroid, distance-scaled | ✅ |
| Place raster image | `vec.image.place {x,y,width,height,pw,ph,pixels}` → `ObjectKind::Image` — sampled quad under the transform; SVG `<image>` import/export | ✅ |
| Brushes (scatter / pattern / art) | `vec.brush {path,template,spacing,rotate}` — copies of a template along a path at arc-length intervals, optional tangent rotation | ✅ |
| Blob brush | `vec.blob {points,radius,fill}` — outlines a freehand centreline into one filled path (round caps/joins); `blobBrush` editor tool. (Shaper gesture-recognition is editor UI) | ✅ |

## Appearance — fill & stroke
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Solid fill (RGB) | `Paint::Solid`; `fill:[r,g,b]`/`"#rrggbb"` | ✅ |
| Fill rule (non-zero / even-odd) | `fill_rule` | ✅ |
| Stroke: width, color | `stroke:{color,width}` | ✅ |
| Stroke caps (butt/round/square) | `cap` | ✅ |
| Stroke joins (miter/round/bevel) | `join` — real miter (4× limit), bevel, and round joins | ✅ |
| Dashed strokes | `dash:[…]` | ✅ |
| Object opacity | `opacity`; layer `opacity` | ✅ |
| Variable-width strokes (Width tool) | stroke `width_profile` — width tapers along arc length (trapezoid segments + round joins) | ✅ |
| Arrowheads | stroke `arrow_start`/`arrow_end` — filled triangle along the end tangent (open paths) | ✅ |
| Linear / radial gradients | `Paint::Linear/Radial` (stops, render + SVG `<linearGradient>`/`<radialGradient>`) | ✅ |
| Gradient on stroke | stroke `paint` accepts a gradient (same sampler) | ✅ |
| Gradient transform (independent of object) | gradient `transform` places it independently of the object (Gradient tool) | ✅ |
| Pattern fills | `Paint::Pattern` — tiled raster swatch (base64 RGBA), canvas-origin anchored; SVG exports a real <pattern> with the tile as an embedded PNG | ✅ |
| Gradient Mesh | `Paint::Mesh` (`fill:{type:"mesh",rows,cols,colors,x,y,w,h}`) — bilinear colour grid; exporters use avg-colour fallback | ✅ |
| Freeform Gradient | `Paint::Freeform` (`fill:{type:"freeform",stops:[{point,color,radius?}]}` / `vec.gradient_freeform`) — colour stops at arbitrary points, per-pixel inverse-distance (Shepard) blend; avg-colour export fallback | ✅ |
| Appearance panel (multiple fills/effects) | `vec.object.add_fill` — stacked extra fills over the base; effects stack via the effects list | ✅ |
| Recolor Artwork (Edit Colors) | `vec.recolor {from,to,tolerance}` — remap a solid colour across the doc, recursive | ✅ |
| Eyedropper (copy appearance) | `vec.eyedropper {source,targets}` — paint one object's fill/stroke/opacity/blend onto the rest of the selection (last-clicked is the source) | ✅ |

## Transform & arrange
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Move / Scale / Rotate / Shear (Shear=skew) | `vec.object.transform {translate/scale/rotate/skew/matrix}` | ✅ |
| Group / Ungroup | `vec.group` / `vec.ungroup` | ✅ |
| Delete object | `vec.object.delete` | ✅ |
| Z-order (bring forward/send back) | `vec.object.reorder {to: front/back/forward/backward}` | ✅ |
| Lock / Unlock | `vec.lock {object,locked}` — toggles the object's `locked` flag | ✅ |
| Hide / Show | `vec.hide {object,visible}` — toggles the object's `visible` flag | ✅ |
| Object ▸ Expand | `vec.expand {object}` — bake the object transform into anchor/handle geometry, reset to identity | ✅ |
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
| Shape Builder tool | covered by `vec.pathfinder`/`vec.divide`/`vec.merge` (interactive region-pick is editor UI) | N/A |
| Live Paint (Bucket + hit-test) | `vec.divide` makes the regions; `vec.region_at {object,x,y}` hit-tests the region under a point and `vec.live_paint_fill {object,x,y,color}` recolours it (winding/even-odd point-in-fill) | ✅ |
| Outline Stroke | `vec.outline_stroke` — stroke region (caps/dashes/width) traced into a filled compound path | ✅ |
| Offset Path | `vec.offset_path {distance}` — grow/shrink via mask morphology + trace | ✅ |

## Type
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Point type | `vec.text` → `ObjectKind::Text` (bundled font via the `text` module), SVG `<text>` | ✅ |
| Type on a path | `vec.text {on_path:{points}}` → `text::render_on_path`; SVG exports a real <textPath> | ✅ |
| Area type (wrapping in a shape) | `vec.text {area_width}` — word-wrap to box width via font metrics | ✅ |
| Character / paragraph styling (size, align, tracking, leading) | `size`/`align`/`tracking`/`leading` on the text object — tracking (letter-spacing) + leading (line-spacing) applied in the renderer and exposed in the Type options bar | ✅ |
| Type rotation / shear (full affine) | point/area type warped through the full object transform (axis-aligned keeps the crisp fast path) | ✅ |
| Create outlines (text → paths) | `vec.text_to_outlines` — rasterize glyphs + trace to a filled compound path | ✅ |

## Masks, blends, effects
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Clipping mask | `vec.clip` — clipping group (topmost object clips the rest to its shape) | ✅ |
| Opacity mask | `vec.opacity_mask` — mask luminance×alpha scales the target alpha; exports a real SVG luminance <mask> | ✅ |
| Blend modes (per object) | `vec.object.blend {mode}` — all 45 raster `LayerMode`s, blended in isolation then composited | ✅ |
| Blend tool (interpolate shapes) | `vec.blend {a,b,steps}` — anchor-matched tween of geometry + fill colour, grouped | ✅ |
| Effects (drop shadow, blur, feather, distort) | `vec.object.drop_shadow`/`blur`/`feather` (Stylize) + `vec.zigzag`/`twist`/`pucker_bloat`/`roughen`/`round_corners` (Distort & Transform) — rasterized/geometric non-destructive effects | ✅ |
| Effect ▸ Warp (Arc/Arch/Bulge/Flag/Wave/Rise/Fish/Inflate) | `vec.warp {object,style,bend}` — parametric envelope displacement of anchors+handles over the path's bbox (bend −1..1, 0=identity) | ✅ |
| Effect ▸ Distort ▸ Tweak | `vec.tweak {object,h,v}` — seeded jitter of every anchor **and its handles** by independent ±h/±v (vs Roughen's point-only) | ✅ |
| Effect ▸ Distort ▸ Free Distort | `vec.free_distort {object,corners}` — bilinear map of the path's bbox onto an arbitrary 4-point quad | ✅ |
| Effect ▸ Convert to Shape (Rectangle/Rounded/Ellipse) | `vec.convert_to_shape {object,shape,radius}` — replace geometry with a bbox-fitted primitive | ✅ |
| Object ▸ 3D ▸ Extrude & Bevel | `vec.extrude {object,depth,angle}` — 2.5-D extrusion as a group: back face + per-edge wall quads + front face, shaded by depth | ✅ |
| Object ▸ 3D ▸ Revolve | `vec.revolve {object,segments,axis_offset}` — orthographic surface of revolution: `segments` shaded meridian strips (front-x `axis_x + r·cos θ`, facing `\|sin θ\|`), drawn back-to-front | ✅ |
| Object ▸ Path ▸ Split Into Grid | `vec.split_grid {object,rows,cols}` — replace the path with a group of rows×cols rect cells tiling its bbox | ✅ |
| Effect ▸ Stylize ▸ Scribble | `vec.scribble {object,spacing,angle}` — replace fill with a back-and-forth sweep polyline (moved onto the stroke) at `spacing`/`angle` | ✅ |
| Object ▸ Path ▸ Clean Up | `vec.cleanup {object}` — drop stray points / empty contours (subpaths with <2 anchors); returns the count removed | ✅ |
| Object ▸ Path ▸ Reverse Path Direction | `vec.reverse {object}` — reverse anchor order + swap in/out handles per anchor (flips compound-path winding) | ✅ |
| Scissors tool | `vec.scissors {object,sub,index}` — cut a contour at an anchor: opens a closed path there, or splits an open path into two | ✅ |
| Knife tool | `vec.knife {object,x0,y0,x1,y1}` — straight cut: a closed contour crossed at two edges splits into two closed contours (corner approximation of curves) | ✅ |
| Object ▸ Transform ▸ Transform Each | `vec.transform_each {objects,scale,rotate,dx,dy}` — apply the transform to each object about its **own** bbox centre | ✅ |
| Type ▸ Change Case | `vec.text_case {object,mode}` — UPPER / lower / Title / Sentence case on a Text object | ✅ |
| Type re-edit (content + size) | `vec.text_set {object,content?,size?}` — edit a Text object in place, keeping position/align/tracking/leading | ✅ |
| Duplicate object | `vec.duplicate {object,dx,dy}` — clone with a fresh id, offset, inserted as a sibling above the original | ✅ |
| Object ▸ Repeat ▸ Radial | `vec.repeat_radial {object,count,radius}` — `count` copies around a circle about the bbox centre, grouped | ✅ |
| Object ▸ Repeat ▸ Grid | `vec.repeat_grid {object,rows,cols,dx,dy}` — a lattice of stepped copies, grouped | ✅ |
| Object ▸ Repeat ▸ Mirror | `vec.repeat_mirror {object,axis}` — original + a copy reflected across the right (`v`) or bottom edge | ✅ |
| Select ▸ Same (Fill/Stroke/Opacity/Blend) | `vec.select_same {object,attr}` — returns the ids of top-level objects matching the reference's attribute (drives multi-select) | ✅ |
| Effect ▸ 3D ▸ Rotate | `vec.rotate3d {object,angle,axis}` — orthographic foreshorten of one dimension by `|cos angle|` about the bbox centre | ✅ |
| Object ▸ Create Trim Marks | `vec.crop_marks {object}` — a printer's-marks object (8 corner ticks, stroked black) inserted as a sibling | ✅ |
| Anchor Point / Convert tool | `vec.convert_anchor {object,sub,index,kind}` — make one anchor `corner` (zero handles) or `smooth` (Catmull-Rom tangent handles) | ✅ |
| Smooth tool | `vec.smooth {object,amount}` — give every interior anchor Catmull-Rom handles scaled by `amount`, turning a corner polyline into a smooth path through the points | ✅ |
| Symbols / instances | `vec.symbol.define` + `vec.symbol.place` — template registry, placed instances (snapshot) | ✅ |
| Image Trace (raster → vector) | `vec.trace {image,threshold}` B&W + `{mode:"color",levels}` — posterize + trace each colour region | ✅ |

## File I/O
| Illustrator | zphoto | Status |
| --- | --- | --- |
| Render vector → raster layers | `vec.render` → raster `Image` (one layer per vector layer) | ✅ |
| SVG export | `vec.save {format:"svg"}` | ✅ |
| SVG import | `vec.open {svg}` — `<g>`/`<path>`(M/L/C/Z)/`<rect>`(+`rx`)/`<ellipse>`/`<circle>`/`<line>`/`<polygon>`/`<polyline>`/`<image>`/`<use>`+`<defs>` + fill/stroke (+ cap/join/dasharray) + element & `<g>` `transform=`; full round-trip: paths, shapes, gradients, text | ✅ |
| AI/PDF import (PDF container) | `vec.open {pdf}` — parses content-stream path ops (q/Q/cm CTM + m/l/c/v/y/h/re/rg/RG/g/G/k/K/sc/scn/f/S + BT/Tj text; full-file MediaBox) + inflates FlateDecode streams (real-world AI/PDF) | ✅ |
| PDF export | `vec.save {format:"pdf"}` — path ops + image XObjects (any affine) + linear+radial gradient shadings + editable text (Helvetica) | ✅ |
| AI export | `vec.save {format:"ai"}` — PDF container Illustrator opens (`.ai` is PDF-compatible) | ✅ |
| EPS import | `vec.open {eps}` — PostScript path parser (moveto/lineto/curveto/setrgbcolor/fill/stroke + concat CTM) | ✅ |
| EPS export | `vec.save {format:"eps"}` — PostScript path output + raster `colorimage` + gradient `shfill` + editable text (findfont/show) | ✅ |
| Raster export (PNG/JPEG/…) | via `vec.render` + raster `image.save` | ✅ |
| Native vector project (JSON) | `vec.save {format:"json"}` serializes the full `VectorDocument` losslessly; `vec.open {json}` reopens it (fresh doc id) — editable round-trip | ✅ |

## Rendering
| Capability | zphoto | Status |
| --- | --- | --- |
| Anti-aliased fill (non-zero + even-odd) | scanline, 4× vertical SSAA + exact horizontal span coverage | ✅ |
| Anti-aliased stroke | stroke-to-fill outline (round caps/joins) | ✅ |
| Affine-correct stroke width scaling | average device scale | ✅ |
| Nested group transforms / opacity | recursive `render_object` | ✅ |
