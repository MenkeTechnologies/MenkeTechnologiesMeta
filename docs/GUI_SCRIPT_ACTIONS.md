# GUI Script Actions — Global Catalog

Every scriptable **GUI-Script action** (automation-bus verb) exposed by every MenkeTechnologies
GUI app — the exact surface `App::open("<app>")->verbs()` returns over the
[GUI Automation Bus](GUI_AUTOMATION_BUS.md): the LIVE runtime surface (appShell verbs +
per-app `opts.commands` + dynamically-registered verbs), read from each running app.

**2662 actions** across **15 apps**. Read from each app's live bus
surface by `bin/gen-gui-actions-live` — do not hand-edit. Requires every app open when generated.

| App | Verbs | Surface |
| --- |:--:| --- |
| [`zpdf`](#zpdf) | 682 | Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact |
| [`audio-haxor`](#audio-haxor) | 241 | Audio analyzer / DAW-project generator — spectrum, DSP, .als generation |
| [`zoffice`](#zoffice) | 228 | LibreOffice-style office engine — writer/calc/impress over ODF/OOXML |
| [`zemail`](#zemail) | 216 | Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search |
| [`zcite`](#zcite) | 209 | Zotero-style reference manager — library, collections, citations, PDF, sync |
| [`zftp`](#zftp) | 183 | Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync |
| [`zwire`](#zwire) | 161 | Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power |
| [`zreq`](#zreq) | 152 | Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket |
| [`zgo`](#zgo) | 144 | Alfred-style launcher — script-filter workflows and system commands |
| [`zphoto`](#zphoto) | 105 | Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions |
| [`ztunnel`](#ztunnel) | 100 | Tunnelblick-style VPN client — OpenVPN / WireGuard config + control |
| [`zthrottle`](#zthrottle) | 99 | System monitor / process & network throttling |
| [`ztranslator`](#ztranslator) | 65 | BOME-style MIDI/keyboard translator — presets, translators, rules, HID |
| [`zstation`](#zstation) | 52 | Station-style multi-app workspace — boards, tiles, panes |
| [`zcontainer`](#zcontainer) | 25 | Docker Desktop + Lens-style container / Kubernetes manager |

---

## zpdf

Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact  
**682 verbs** · live bus surface · call as `App::open("zpdf")->call("<verb>", %args)`

**`(top-level)`** (324)

```
accessibility_check
add_3d
add_background
add_barcode
add_bookmark
add_callout
add_data_matrix
add_goto_link
add_grid_overlay
add_header_footer
add_image
add_ink
add_launch_link
add_line_numbers
add_link
add_markup
add_measure
add_movie
add_named_action_link
add_named_destination
add_note
add_page_numbers
add_printer_marks
add_qr_code
add_remote_goto_link
add_rich_media
add_screen
add_sound
add_submit_button
add_text
add_text_with_font
add_thread
add_typed_signature
adjust_image
adjust_page
apply_actions
apply_redactions
assemble_pages
attach_file
attachments
auto_crop_margins
auto_link_urls
auto_outline
auto_tag
bates_number
binarize
booklet_order
build_toc_page
canonical_bytes
certify
clear_metadata
clear_recents
clear_signature
color_separations
compare
contact_sheet
content_fingerprint
convert_to_cmyk
copy_fidelity_audit
create_checkbox
create_choice_field
create_from_images
create_layer
create_ocmd
create_push_button
create_radio_group
create_signature_field
create_text_field
crop_page
decrypt
decrypt_pubkey
delete_annotation
delete_annotations_by_author
delete_annotations_by_type
delete_attachment
delete_bookmark
delete_field
delete_layer
delete_named_destination
delete_pages
deskew_page
detect_image_regions
detect_skew_angle
discard_search_index
discard_thumbnails
doc_js_names
document_id
downsample_images
draw_bezier
draw_line
draw_path
draw_rect
duplicate_pages
edit_text
encrypt
encrypt_aes256
encrypt_aes256_with_permissions
encrypt_pubkey
encrypt_pubkey_multi
erase_ink_at
export_comments_csv
export_comments_fdf
export_comments_xfdf
export_docx
export_fdf
export_html
export_markdown
export_page_svg
export_png
export_pptx
export_xfa
export_xfdf
export_xlsx
extract_attachment
extract_fonts
extract_images
extract_page_temp
extract_tables
extract_text
extract_text_in_region
extract_to
find_replace_text
flatten_annotations
flatten_form
flatten_layers
flatten_transparency
flip_page
form_fields
generate_thumbnails
has_acroform
has_permissions_dict
has_xfa
hidden_content_audit
highlight_search
image_alt_texts
import_comments_fdf
import_comments_xfdf
import_fdf
import_xfdf
ink_coverage
insert_blank_page
insert_pages
interleave
invert_colors
is_encrypted
is_signed
is_tagged
last_document
linearize
links
list_annotations
list_field_actions
list_fonts
list_inks
list_layers
list_output_intents
make_portfolio
make_searchable
mark_visual_differences
merge_file
move_bookmark
move_field
move_page
move_text
n_up
named_destinations
object_stats
ocr_page
ocr_page_words
open_pdf
optimize
outline
overlay_page
page_boxes
page_dimensions
page_size
page_text_runs
page_visual_difference
pdf_info
permissions
preflight
print_to_pdf
read_threads
readability_stats
reading_order
recalculate_fields
recent_documents
recompress_streams
redact_pii
redact_regex
redact_search
redaction_leak_audit
reflow
regenerate_document_id
remove_blank_pages
remove_doc_js
rename_bookmark
rename_field
rename_layer
render_page
reorder_pages
repair
replace_image
replace_pages
reset_form
resize_all_pages
resize_page
restyle_text
reverse_pages
revision_extract
revision_history
rotate_all
rotate_page
run_javascript
sanitize
save_pdf
scan_pii
search
set_all_annotation_flags
set_all_page_boxes
set_annotation_author
set_annotation_border
set_annotation_color
set_annotation_contents
set_annotation_flags
set_annotation_opacity
set_annotation_rect
set_annotation_subject
set_bookmark_action
set_bookmark_level
set_bookmark_style
set_bookmark_target
set_calculation_order
set_doc_js
set_document_action
set_document_language
set_field
set_field_alignment
set_field_appearance
set_field_calculation_js
set_field_colors
set_field_default_value
set_field_export_name
set_field_flags
set_field_format_js
set_field_keystroke_js
set_field_rich_value
set_field_tooltip
set_field_validate_js
set_image_alt_text
set_info_property
set_layer_locked
set_layer_usage
set_layer_visibility
set_metadata
set_open_action_page
set_outline
set_output_intent
set_page_action
set_page_box
set_page_duration
set_page_labels
set_page_layout
set_page_mode
set_page_transition
set_print_preset
set_reading_direction
set_tab_order
set_text_field_maxlen
set_text_field_options
set_trapped
set_user_unit
set_viewer_preference
set_xfa_datasets
set_xmp_metadata
sign
sign_image
sign_visible
signature_count
similarity_score
space_audit
split_by_bookmarks
split_by_count
split_by_ranges
split_by_size
split_by_text
split_odd_even
split_page_grid
split_scanned_images
stamp_image
structure_diff
stylize_page
suggest_filename
swap_pages
tag_pdf_ua
take_launch_file
to_grayscale
to_pdf_a
to_pdf_x
to_single_page
undo_annot
unembed_fonts
validate_fields
validate_pdf_a
validate_pdf_ua
vcs_bisect
vcs_blame
vcs_blame_lines
vcs_checkout
vcs_commit
vcs_diff
vcs_head
vcs_log
vcs_page_objects
verify_full
verify_redaction
verify_signatures
watermark_image
watermark_text
whiteout
word_diff
xfa_datasets
xfa_packets
xmp_metadata
```

**`appshell`** (358)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.recent:/Users/tommy/Desktop/A-80_OM.pdf
appshell.recent:/Users/tommy/Desktop/JacobMenke2026.pdf
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.zp.cmd_a11y_check
appshell.zp.cmd_add_3d
appshell.zp.cmd_add_bookmark
appshell.zp.cmd_add_dest
appshell.zp.cmd_add_image
appshell.zp.cmd_add_sound
appshell.zp.cmd_add_text
appshell.zp.cmd_add_video
appshell.zp.cmd_adjust_doc
appshell.zp.cmd_advance
appshell.zp.cmd_all_page_boxes
appshell.zp.cmd_alt_text
appshell.zp.cmd_alt_texts
appshell.zp.cmd_annot_author
appshell.zp.cmd_annot_border
appshell.zp.cmd_annot_delete
appshell.zp.cmd_annot_edit
appshell.zp.cmd_annot_flags
appshell.zp.cmd_annot_opacity
appshell.zp.cmd_annot_recolor
appshell.zp.cmd_annot_rect
appshell.zp.cmd_annot_subject
appshell.zp.cmd_annots_lock
appshell.zp.cmd_annots_print
appshell.zp.cmd_assemble
appshell.zp.cmd_attach_file
appshell.zp.cmd_attachments
appshell.zp.cmd_auto_crop
appshell.zp.cmd_auto_link
appshell.zp.cmd_auto_outline
appshell.zp.cmd_auto_tag
appshell.zp.cmd_background
appshell.zp.cmd_barcode
appshell.zp.cmd_bates
appshell.zp.cmd_binarize
appshell.zp.cmd_booklet
appshell.zp.cmd_bookmark_action
appshell.zp.cmd_bookmark_style
appshell.zp.cmd_build_toc
appshell.zp.cmd_calc_order
appshell.zp.cmd_callout
appshell.zp.cmd_canonical
appshell.zp.cmd_certify
appshell.zp.cmd_checkbox
appshell.zp.cmd_cleanup
appshell.zp.cmd_clear_metadata
appshell.zp.cmd_clear_sig
appshell.zp.cmd_compare
appshell.zp.cmd_contact_sheet
appshell.zp.cmd_convert_cmyk
appshell.zp.cmd_copy_fidelity
appshell.zp.cmd_create_from_images
appshell.zp.cmd_create_layer
appshell.zp.cmd_create_ocmd
appshell.zp.cmd_datamatrix
appshell.zp.cmd_decrypt_cert
appshell.zp.cmd_del_annots_author
appshell.zp.cmd_del_annots_type
appshell.zp.cmd_delete_attachment
appshell.zp.cmd_delete_bookmark
appshell.zp.cmd_delete_dest
appshell.zp.cmd_delete_field
appshell.zp.cmd_delete_layer
appshell.zp.cmd_deskew
appshell.zp.cmd_detect_images
appshell.zp.cmd_detect_skew
appshell.zp.cmd_discard_index
appshell.zp.cmd_discard_thumbs
appshell.zp.cmd_doc_action
appshell.zp.cmd_doc_flags
appshell.zp.cmd_doc_js
appshell.zp.cmd_doc_js_list
appshell.zp.cmd_document_id
appshell.zp.cmd_downsample
appshell.zp.cmd_dropdown
appshell.zp.cmd_duplicate_pages
appshell.zp.cmd_edit_text
appshell.zp.cmd_encrypt
appshell.zp.cmd_encrypt_aes
appshell.zp.cmd_encrypt_cert
appshell.zp.cmd_encrypt_multi
appshell.zp.cmd_encrypt_perms
appshell.zp.cmd_export_comments_xfdf
appshell.zp.cmd_export_dialog
appshell.zp.cmd_export_fdf
appshell.zp.cmd_export_svg
appshell.zp.cmd_export_xfa
appshell.zp.cmd_export_xfdf
appshell.zp.cmd_extract_attachment
appshell.zp.cmd_extract_fonts
appshell.zp.cmd_extract_images
appshell.zp.cmd_extract_tables
appshell.zp.cmd_field_align
appshell.zp.cmd_field_appearance
appshell.zp.cmd_field_calc
appshell.zp.cmd_field_colors
appshell.zp.cmd_field_default
appshell.zp.cmd_field_export
appshell.zp.cmd_field_flags
appshell.zp.cmd_field_format_js
appshell.zp.cmd_field_keystroke_js
appshell.zp.cmd_field_maxlen
appshell.zp.cmd_field_options
appshell.zp.cmd_field_rich_value
appshell.zp.cmd_field_tooltip
appshell.zp.cmd_field_validate_js
appshell.zp.cmd_find_replace
appshell.zp.cmd_fingerprint
appshell.zp.cmd_flatten_layers
appshell.zp.cmd_flatten_transparency
appshell.zp.cmd_flip_page
appshell.zp.cmd_goto_link
appshell.zp.cmd_grid_overlay
appshell.zp.cmd_header_footer
appshell.zp.cmd_hidden_audit
appshell.zp.cmd_highlight_search
appshell.zp.cmd_import_comments_xfdf
appshell.zp.cmd_import_fdf
appshell.zp.cmd_import_xfdf
appshell.zp.cmd_indent_bookmark
appshell.zp.cmd_info_prop
appshell.zp.cmd_ink_coverage
appshell.zp.cmd_insert_blank
appshell.zp.cmd_insert_pages
appshell.zp.cmd_interleave
appshell.zp.cmd_launch_link
appshell.zp.cmd_layer_usage
appshell.zp.cmd_layer_visibility
appshell.zp.cmd_line_numbers
appshell.zp.cmd_linearize
appshell.zp.cmd_list_annots
appshell.zp.cmd_list_field_actions
appshell.zp.cmd_list_fonts
appshell.zp.cmd_list_inks
appshell.zp.cmd_list_layers
appshell.zp.cmd_list_links
appshell.zp.cmd_list_output_intents
appshell.zp.cmd_lock_layer
appshell.zp.cmd_make_searchable
appshell.zp.cmd_measure
appshell.zp.cmd_move_bookmark_down
appshell.zp.cmd_move_bookmark_up
appshell.zp.cmd_move_field
appshell.zp.cmd_move_page
appshell.zp.cmd_named_action_link
appshell.zp.cmd_named_dests
appshell.zp.cmd_object_stats
appshell.zp.cmd_ocr_page
appshell.zp.cmd_ocr_words
appshell.zp.cmd_open_page
appshell.zp.cmd_optimize
appshell.zp.cmd_outdent_bookmark
appshell.zp.cmd_output_intent
appshell.zp.cmd_overlay_page
appshell.zp.cmd_page_action
appshell.zp.cmd_page_box
appshell.zp.cmd_page_boxes
appshell.zp.cmd_page_dimensions
appshell.zp.cmd_page_labels
appshell.zp.cmd_page_layout
appshell.zp.cmd_page_mode
appshell.zp.cmd_page_numbers
appshell.zp.cmd_permissions
appshell.zp.cmd_portfolio
appshell.zp.cmd_preflight
appshell.zp.cmd_print_pdf
appshell.zp.cmd_print_preset
appshell.zp.cmd_printer_marks
appshell.zp.cmd_push_button
appshell.zp.cmd_qr
appshell.zp.cmd_radio_group
appshell.zp.cmd_readability
appshell.zp.cmd_reading_direction
appshell.zp.cmd_reading_order
appshell.zp.cmd_recompress
appshell.zp.cmd_redact_pii
appshell.zp.cmd_redact_regex
appshell.zp.cmd_redact_search
appshell.zp.cmd_redaction_leak
appshell.zp.cmd_reflow
appshell.zp.cmd_regen_doc_id
appshell.zp.cmd_region_text
appshell.zp.cmd_remote_goto_link
appshell.zp.cmd_remove_blank
appshell.zp.cmd_remove_js
appshell.zp.cmd_rename_bookmark
appshell.zp.cmd_rename_field
appshell.zp.cmd_rename_layer
appshell.zp.cmd_render_cache
appshell.zp.cmd_render_jobs
appshell.zp.cmd_reorder_pages
appshell.zp.cmd_repair
appshell.zp.cmd_replace_image
appshell.zp.cmd_replace_pages
appshell.zp.cmd_reset_form
appshell.zp.cmd_resize_all
appshell.zp.cmd_resize_page
appshell.zp.cmd_retarget_bookmark
appshell.zp.cmd_revision_history
appshell.zp.cmd_rotate_all_ccw
appshell.zp.cmd_rotate_all_cw
appshell.zp.cmd_run_js
appshell.zp.cmd_sanitize
appshell.zp.cmd_save_pdfa
appshell.zp.cmd_save_pdfx
appshell.zp.cmd_scan_pii
appshell.zp.cmd_scan_split
appshell.zp.cmd_search
appshell.zp.cmd_separations
appshell.zp.cmd_set_language
appshell.zp.cmd_set_outline
appshell.zp.cmd_set_trapped
appshell.zp.cmd_set_xfa
appshell.zp.cmd_set_xmp
appshell.zp.cmd_sign
appshell.zp.cmd_sign_image
appshell.zp.cmd_sign_visible
appshell.zp.cmd_signature_field
appshell.zp.cmd_similarity
appshell.zp.cmd_single_page
appshell.zp.cmd_space_audit
appshell.zp.cmd_split_bookmarks
appshell.zp.cmd_split_count
appshell.zp.cmd_split_grid
appshell.zp.cmd_split_oddeven
appshell.zp.cmd_split_ranges
appshell.zp.cmd_split_size
appshell.zp.cmd_split_text
appshell.zp.cmd_structure_diff
appshell.zp.cmd_stylize
appshell.zp.cmd_submit_button
appshell.zp.cmd_suggest_name
appshell.zp.cmd_swap_pages
appshell.zp.cmd_tab_order
appshell.zp.cmd_tag_pdfua
appshell.zp.cmd_text_font
appshell.zp.cmd_thread
appshell.zp.cmd_threads
appshell.zp.cmd_thumbnails
appshell.zp.cmd_timestamp
appshell.zp.cmd_transition
appshell.zp.cmd_unembed_fonts
appshell.zp.cmd_user_unit
appshell.zp.cmd_validate_pdfa
appshell.zp.cmd_validate_pdfua
appshell.zp.cmd_verify_full
appshell.zp.cmd_verify_redaction
appshell.zp.cmd_verify_sigs
appshell.zp.cmd_viewer_pref
appshell.zp.cmd_visual_diff
appshell.zp.cmd_visual_diff_score
appshell.zp.cmd_watermark
appshell.zp.cmd_watermark_img
appshell.zp.cmd_whiteout
appshell.zp.cmd_word_diff
appshell.zp.cmd_xfa_datasets
appshell.zp.cmd_xfa_packets
appshell.zp.cmd_xmp
appshell.zp.crop_page
appshell.zp.decrypt
appshell.zp.delete_page
appshell.zp.draw_brush
appshell.zp.draw_eraser
appshell.zp.draw_gradient
appshell.zp.draw_rect
appshell.zp.draw_signature
appshell.zp.export_csv
appshell.zp.export_excel
appshell.zp.export_html
appshell.zp.export_image
appshell.zp.export_markdown
appshell.zp.export_ppt
appshell.zp.export_word
appshell.zp.expose
appshell.zp.extract_page
appshell.zp.goto_page
appshell.zp.guided_tour
appshell.zp.image_adjust
appshell.zp.impose_2up
appshell.zp.impose_4up
appshell.zp.impose_8up
appshell.zp.jump_outline
appshell.zp.mark_caret
appshell.zp.mark_highlight
appshell.zp.mark_ink
appshell.zp.mark_line
appshell.zp.mark_note
appshell.zp.mark_oval
appshell.zp.mark_polygon
appshell.zp.mark_polyline
appshell.zp.mark_rectangle
appshell.zp.mark_redact
appshell.zp.mark_squiggly
appshell.zp.mark_stamp
appshell.zp.mark_strikeout
appshell.zp.mark_textbox
appshell.zp.mark_underline
appshell.zp.merge_pdf
appshell.zp.mru_tab
appshell.zp.open_file_browser
appshell.zp.open_hooks_editor
appshell.zp.open_pdf
appshell.zp.open_recent_menu
appshell.zp.reader_mode
appshell.zp.reverse_order
appshell.zp.rotate_90
appshell.zp.save
appshell.zp.save_as
appshell.zp.save_grayscale
appshell.zp.save_inverted
appshell.zp.shortcuts_ref
appshell.zp.tab_bookmarks
appshell.zp.tab_compare
appshell.zp.tab_fields
appshell.zp.tab_insights
appshell.zp.tab_metadata
appshell.zp.tab_page
appshell.zp.tab_text
appshell.zp.tab_timeline
appshell.zp.toggle_terminal
appshell.zp.vcs_bisect
appshell.zp.vcs_blame
appshell.zp.vcs_commit
appshell.zp.vcs_history
appshell.zp.zoom_preset
```

## audio-haxor

Audio analyzer / DAW-project generator — spectrum, DSP, .als generation  
**241 verbs** · live bus surface · call as `App::open("audio-haxor")->call("<verb>", %args)`

**`app`** (241)

```
app.alsCancelGenerate
app.alsGenerate
app.alsOverrideDelete
app.alsOverridesClearAll
app.alsPickOutput
app.alsRandomizeSeed
app.alsStartAnalysis
app.alsStopAnalysis
app.applyCustomScheme
app.browseDir
app.browseSnapshotExportDir
app.buildXrefIndex
app.cancelSavePreset
app.checkUpdates
app.clearAbLoop
app.clearAllHistory
app.clearAllNotes
app.clearAppLog
app.clearFavorites
app.clearGlobalTag
app.clearRecentlyPlayed
app.clearSettingsSearch
app.clearSnapshotExportDir
app.collapsePlayer
app.confirmSavePreset
app.createSmartPlaylist
app.createTag
app.deleteCustomSchemes
app.exportAudio
app.exportDaw
app.exportFavorites
app.exportLogPdf
app.exportMidi
app.exportNotes
app.exportPdfs
app.exportPlugins
app.exportPresets
app.exportRecentlyPlayed
app.exportSettingsPdf
app.exportVideos
app.favCurrentTrack
app.fbBulkRenameApply
app.fbBulkRenameCancel
app.fbPreviewClose
app.fbTreeClose
app.fileAppDataDir
app.fileBulkClear
app.fileBulkDelete
app.fileBulkFavorite
app.fileBulkOpen
app.fileBulkRename
app.fileBulkScan
app.fileFav
app.fileHome
app.fileNavBack
app.fileNavFwd
app.fileNewFolder
app.fileQuickNav
app.fileTogglePreview
app.fileUp
app.filterAudioSamples
app.filterCrate
app.filterDawProjects
app.filterFavorites
app.filterFiles
app.filterMidi
app.filterNotes
app.filterNowPlaying
app.filterPdfs
app.filterPlugins
app.filterPresets
app.filterSettings
app.filterShortcuts
app.filterTags
app.filterVideos
app.findDuplicates
app.hidePlayer
app.hideTagBar
app.hideTerminal
app.importAudio
app.importDaw
app.importFavorites
app.importNotes
app.importPdfs
app.importPlugins
app.importPresets
app.importRecentlyPlayed
app.importVideos
app.killTerminal
app.moveTagBar
app.nextTrack
app.openCrateBuilder
app.openDataDir
app.openLogFile
app.openNextUpdate
app.openPrefsFile
app.openReleaseWizard
app.openUpdate
app.prevTrack
app.refreshCacheStats
app.resetAllScans
app.resetEq
app.resetFzfParams
app.resetShortcuts
app.resumeAll
app.resumeAudioScan
app.resumeDawScan
app.resumeMidiScan
app.resumePdfScan
app.resumePluginScan
app.resumePresetScan
app.resumeVideoScan
app.runBpmKeyLufsAnalysis
app.runContentDupScan
app.saveAudioScanDirs
app.saveBlacklist
app.saveCustomDirs
app.saveDawScanDirs
app.saveFolderWatchDirs
app.saveMidiScanDirs
app.savePdfScanDirs
app.savePresetScanDirs
app.saveSnapshotExportDir
app.saveVideoScanDirs
app.scanAll
app.scanAudioSamples
app.scanDawProjects
app.scanMidi
app.scanPdfs
app.scanPlugins
app.scanPresets
app.scanVideos
app.setAbA
app.setAbB
app.setEqHigh
app.setEqLow
app.setEqMid
app.setGain
app.setPan
app.setPlaybackSpeed
app.setSpeedMode
app.setVolume
app.settingAnalysisPause
app.settingAudioSort
app.settingAutoplayNextSource
app.settingBatchAnalysisThreads
app.settingBatchSize
app.settingBgJobThrottle
app.settingChannelBuffer
app.settingClearAllDatabases
app.settingClearAllHistory
app.settingClearAnalysisCache
app.settingClearKvrCache
app.settingContentDupHashThreads
app.settingDawSort
app.settingDefaultTypeFilter
app.settingFdLimit
app.settingFlushInterval
app.settingLogVerbosity
app.settingMaxRecent
app.settingMidiSort
app.settingPageSize
app.settingPdfSort
app.settingPluginSort
app.settingPresetSort
app.settingPruneOldScansKeep
app.settingResetAllUI
app.settingResetColumns
app.settingResetSectionOrder
app.settingResetTabOrder
app.settingSqliteReadPoolExtra
app.settingTagBarPosition
app.settingThreadMultiplier
app.settingToggleAutoAnalysis
app.settingToggleAutoCheckUpdatesOnStartup
app.settingToggleAutoContentDupScan
app.settingToggleAutoFingerprintCache
app.settingToggleAutoPdfMetadataOnStartup
app.settingToggleAutoPdfScanOnStartup
app.settingToggleAutoPlaySampleOnSelect
app.settingToggleAutoScan
app.settingToggleAutoUpdate
app.settingToggleAutoplayNext
app.settingToggleCrt
app.settingToggleExpandOnClick
app.settingToggleFolderWatch
app.settingToggleIncludeBackups
app.settingToggleIncrementalDirectoryScan
app.settingToggleNeonGlow
app.settingTogglePdfMetadataAutoExtract
app.settingTogglePruneOldScans
app.settingToggleSingleClickPlay
app.settingToggleTagBar
app.settingToggleTheme
app.settingTooltipHoverDelay
app.settingTrayTransportSource
app.settingUiLocale
app.settingVideoAudioRoute
app.settingVizFps
app.settingWfCacheMax
app.showDepGraph
app.showGenreRules
app.showHeatmapDash
app.showPlayer
app.showSavePreset
app.showSmartPlaylistEditor
app.showTerminal
app.showToastHistory
app.skipUpdate
app.stopAll
app.stopAudioPlayback
app.stopAudioScan
app.stopBpmKeyLufsAnalysis
app.stopContentDupScan
app.stopDawScan
app.stopMidiScan
app.stopPdfMetadataExtraction
app.stopPdfScan
app.stopPluginScan
app.stopPresetScan
app.stopVideoScan
app.switchTab
app.tagCurrentTrack
app.tlFindSamples
app.tlGenerateAll
app.tlGenerateKits
app.tlGenerateMidi
app.tlPickOutput
app.tlRandomizeSeed
app.toggleAudioLoop
app.toggleAudioPlayback
app.toggleDirs
app.toggleEqSection
app.toggleMono
app.toggleMute
app.togglePdf
app.toggleRegex
app.toggleReversePlayback
app.toggleSequencer
app.toggleShuffle
app.vizFullscreen
```

## zoffice

LibreOffice-style office engine — writer/calc/impress over ODF/OOXML  
**228 verbs** · live bus surface · call as `App::open("zoffice")->call("<verb>", %args)`

**`(top-level)`** (6)

```
diff
info
inspect
meta
open
pagesetup
```

**`appshell`** (125)

```
appshell.activity_timeline
appshell.base_catalog
appshell.base_run_query
appshell.calc_batch_edit
appshell.calc_chart_data
appshell.calc_column_stats
appshell.calc_comments
appshell.calc_cond_formats
appshell.calc_critical_path
appshell.calc_edit_cell
appshell.calc_eval
appshell.calc_export_formulas
appshell.calc_features
appshell.calc_formulas_view
appshell.calc_impact_map
appshell.calc_jump
appshell.calc_named_ranges
appshell.calc_overview
appshell.calc_pivots
appshell.calc_print_setups
appshell.calc_protections
appshell.calc_sheet_states
appshell.calc_sort
appshell.calc_tables
appshell.calc_validations
appshell.close_document
appshell.cmd_palette
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.doc_dashboard
appshell.doc_properties
appshell.draw_connectors
appshell.edit_doc_properties
appshell.engine_info
appshell.export_document
appshell.extract_plain_text
appshell.files
appshell.files.close
appshell.files.open
appshell.find_in_doc
appshell.gui-scripts
appshell.hooks
appshell.impress_add_slide
appshell.impress_chart_data
appshell.impress_edit_slide
appshell.impress_export_hyperlinks
appshell.impress_extract_text
appshell.impress_graphic_objects
appshell.impress_hyperlinks_view
appshell.impress_insert_slide
appshell.impress_layout_names
appshell.impress_layouts
appshell.impress_remove_slide
appshell.impress_shapes
appshell.impress_slide_size
appshell.impress_slide_tables
appshell.impress_speaker_notes
appshell.impress_storyboard
appshell.impress_text_analytics
appshell.impress_transitions
appshell.math_starmath
appshell.neon.off
appshell.neon.on
appshell.open_document
appshell.open_preferences
appshell.open_recent
appshell.page_setup
appshell.palette
appshell.reload_document
appshell.replace_in_doc
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.search_all_recent
appshell.settings
appshell.shortcuts
appshell.shortcuts_help
appshell.snippets
appshell.switch_base
appshell.switch_calc
appshell.switch_draw
appshell.switch_impress
appshell.switch_math
appshell.switch_writer
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.writer_blame
appshell.writer_bookmarks
appshell.writer_compare
appshell.writer_edit_paragraph
appshell.writer_edit_table_cell
appshell.writer_embedded_media
appshell.writer_export_comments
appshell.writer_export_hyperlinks
appshell.writer_field_codes
appshell.writer_footnotes
appshell.writer_form_fields
appshell.writer_formatting
appshell.writer_hyperlinks_view
appshell.writer_insert_paragraph
appshell.writer_list_formats
appshell.writer_merge
appshell.writer_revision_authors
appshell.writer_revisions_timeline
appshell.writer_sections
appshell.writer_settings
appshell.writer_structure
appshell.writer_style_catalog
appshell.writer_table_content
appshell.writer_text_analytics
appshell.writer_word_count
```

**`base`** (3)

```
base.open
base.query
base.tables
```

**`calc`** (30)

```
calc.cells
calc.charts
calc.charts_detail
calc.charts_render
calc.comments
calc.conditional_formats
calc.critical_path
calc.csv
calc.edit_cell
calc.eval
calc.evaluate
calc.find
calc.formulas
calc.html
calc.impact_map
calc.markdown
calc.merge3
calc.named_ranges
calc.open
calc.pdf
calc.pivot_tables
calc.print_setups
calc.render
calc.replace
calc.replace_lossless
calc.sheet_protections
calc.sheet_states
calc.sort
calc.tables
calc.validations
```

**`draw`** (8)

```
draw.connectors
draw.find
draw.html
draw.markdown
draw.open
draw.render
draw.replace
draw.svg
```

**`impress`** (21)

```
impress.charts_detail
impress.charts_render
impress.find
impress.graphic_objects
impress.html
impress.hyperlinks
impress.layout_names
impress.layouts
impress.markdown
impress.merge3
impress.open
impress.pdf
impress.render
impress.replace
impress.replace_lossless
impress.shapes
impress.slide_notes
impress.slide_size
impress.tables
impress.text
impress.transitions
```

**`math`** (3)

```
math.open
math.render
math.starmath
```

**`writer`** (32)

```
writer.blame
writer.bookmark_text
writer.comment_details
writer.comments
writer.content_controls
writer.edit_table_cell
writer.fields
writer.find
writer.footnotes
writer.html
writer.hyperlinks_text
writer.images
writer.inline_images
writer.links
writer.list_formats
writer.markdown
writer.merge3
writer.notes
writer.open
writer.pdf
writer.render
writer.replace
writer.replace_lossless
writer.revision_authors
writer.runs
writer.sections
writer.settings
writer.structure
writer.style_definitions
writer.table_grids
writer.tables
writer.text
```

## zemail

Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search  
**216 verbs** · live bus surface · call as `App::open("zemail")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`account`** (5)

```
account.add
account.autoconfig
account.list
account.remove
account.update
```

**`address`** (3)

```
address.known
address.to_ascii
address.validate
```

**`appshell`** (31)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`attachment`** (2)

```
attachment.parse_tnef
attachment.sniff
```

**`calendar`** (8)

```
calendar.expand_rrule
calendar.freebusy
calendar.parse_alarms
calendar.parse_invite
calendar.parse_journals
calendar.parse_todos
calendar.parse_vtimezone
calendar.rsvp
```

**`carddav`** (2)

```
carddav.fetch
carddav.put
```

**`compose`** (3)

```
compose.attachment_reminder
compose.mail_merge
compose.parse_mailto
```

**`contact`** (11)

```
contact.add
contact.export_group
contact.export_vcard
contact.export_vcard4
contact.find_duplicates
contact.gravatar
contact.import_vcard
contact.list
contact.merge
contact.parse_groups
contact.remove
```

**`crypto`** (1)

```
crypto.mime_structure
```

**`expire`** (1)

```
expire.due
```

**`export`** (2)

```
export.eml
export.mbox
```

**`filter`** (5)

```
filter.add
filter.list
filter.remove
filter.run
filter.to_sieve
```

**`folder`** (6)

```
folder.create
folder.delete
folder.digest
folder.inbox_load
folder.list
folder.rename
```

**`followup`** (1)

```
followup.due
```

**`gloda`** (1)

```
gloda.search
```

**`html`** (2)

```
html.sanitize
html.to_text
```

**`identity`** (3)

```
identity.baseline
identity.evaluate
identity.scan_folder
```

**`imap`** (12)

```
imap.build_search
imap.folders
imap.idle
imap.parse_bodystructure
imap.parse_command
imap.parse_envelope
imap.parse_fetch
imap.parse_response
imap.parse_thread
imap.search
imap.store_flags
imap.sync
```

**`import`** (3)

```
import.eml
import.maildir
import.mbox
```

**`jmap`** (4)

```
jmap.email_get
jmap.email_object
jmap.email_query
jmap.mailbox_get
```

**`junk`** (3)

```
junk.classify
junk.run
junk.train
```

**`key`** (3)

```
key.add
key.list
key.remove
```

**`list`** (6)

```
list.add_member
list.create
list.list
list.parse_headers
list.remove
list.virtual_folders
```

**`message`** (37)

```
message.action_items
message.add_label
message.attachment_safety
message.build_rfc5322
message.categorize
message.commitment_scan
message.delete
message.expire
message.find_duplicates
message.followup
message.forward_assemble
message.get
message.importance
message.junk
message.list
message.move
message.parse_dsn
message.parse_mdn
message.phishing_scan
message.pin
message.priority_rank
message.quote_audit
message.reading_time
message.reconstruct_thread
message.remove_label
message.roster_audit
message.save_draft
message.set_aside
message.set_flags
message.snooze
message.strip_quotes
message.thread_stats
message.thread_tree
message.threads
message.tracking_scan
message.unsnooze
message.unsubscribe
```

**`mime`** (8)

```
mime.arc_chain
mime.auth_results
mime.dkim_info
mime.encode_header
mime.flow_decode
mime.flow_encode
mime.qp_decode
mime.qp_encode
```

**`openpgp`** (5)

```
openpgp.decrypt
openpgp.encrypt
openpgp.gen_key
openpgp.sign
openpgp.verify
```

**`outbox`** (5)

```
outbox.due
outbox.list
outbox.queue
outbox.remove
outbox.schedule
```

**`policy`** (3)

```
policy.dmarc_eval
policy.dmarc_parse
policy.spf_parse
```

**`pop3`** (1)

```
pop3.fetch
```

**`profile`** (2)

```
profile.get
profile.save
```

**`schedule`** (1)

```
schedule.resolve
```

**`screener`** (4)

```
screener.approve
screener.list
screener.pending
screener.remove
```

**`search`** (6)

```
search.query
search.remove
search.run
search.run_saved
search.save
search.saved
```

**`sieve`** (1)

```
sieve.parse
```

**`signature`** (3)

```
signature.add
signature.list
signature.remove
```

**`smime`** (5)

```
smime.decrypt
smime.encrypt
smime.gen_cert
smime.sign
smime.verify
```

**`smtp`** (1)

```
smtp.send
```

**`snooze`** (1)

```
snooze.due
```

**`template`** (4)

```
template.add
template.list
template.remove
template.render
```

**`thread`** (3)

```
thread.mute
thread.muted
thread.unmute
```

**`vacation`** (3)

```
vacation.get
vacation.reply
vacation.set
```

**`vcard`** (1)

```
vcard.convert
```

**`vip`** (3)

```
vip.add
vip.list
vip.remove
```

## zcite

Zotero-style reference manager — library, collections, citations, PDF, sync  
**209 verbs** · live bus surface · call as `App::open("zcite")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`annotation`** (4)

```
annotation.add
annotation.list
annotation.remove
annotation.update
```

**`appshell`** (28)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
```

**`attachment`** (3)

```
attachment.index
attachment.snapshot
attachment.store_file
```

**`authors`** (1)

```
authors.index
```

**`backup`** (5)

```
backup.create
backup.delete
backup.list
backup.prune
backup.restore
```

**`bib`** (12)

```
bib.author_substitute
bib.bibliography
bib.citation
bib.cite_key
bib.cite_keys
bib.csl
bib.csl_document
bib.disambiguate
bib.sort_key
bib.style_diff
bib.style_fit
bib.styles
```

**`cite`** (2)

```
cite.document
cite.rtf_scan
```

**`cleanup`** (2)

```
cleanup.batch
cleanup.item
```

**`cluster`** (1)

```
cluster.related
```

**`collection`** (8)

```
collection.add
collection.add_item
collection.list
collection.merge
collection.remove
collection.remove_item
collection.rename
collection.tree
```

**`csl`** (1)

```
csl.validate
```

**`duplicates`** (5)

```
duplicates.fuzzy
duplicates.list
duplicates.merge
duplicates.merge_preview
duplicates.similarity
```

**`export`** (20)

```
export.biblatex
export.bibtex
export.coins
export.csl_json
export.csl_yaml
export.csv
export.endnote_tagged
export.endnote_xml
export.html
export.item_markdown
export.json_ld
export.marcxml
export.markdown
export.mods
export.ris
export.rtf
export.tsv
export.wikipedia
export.word_field
export.zotero_rdf
```

**`identifier`** (6)

```
identifier.add
identifier.canonicalize
identifier.detect
identifier.isbn_convert
identifier.lookup
identifier.validate
```

**`import`** (15)

```
import.biblatex
import.bibtex
import.crossref_json
import.csl_json
import.csv
import.datacite_json
import.dublin_core
import.endnote_tagged
import.endnote_xml
import.file
import.marcxml
import.mods
import.pubmed_xml
import.ris
import.zotero_rdf
```

**`inbox`** (1)

```
inbox.import
```

**`integrity`** (2)

```
integrity.check
integrity.roundtrip
```

**`item`** (24)

```
item.add
item.add_attachment
item.add_note
item.add_tag
item.convert_type
item.delete
item.duplicate
item.get
item.list
item.reading_stats
item.relate
item.related_graph
item.remove_note
item.remove_tag
item.restore
item.set_favorite
item.set_field
item.set_rating
item.set_reading
item.suggest_related
item.trash
item.unrelate
item.update
item.update_note
```

**`items`** (5)

```
items.add_tag
items.file
items.remove_tag
items.replace_field
items.trash
```

**`journal`** (1)

```
journal.abbreviate
```

**`libraries`** (6)

```
libraries.active
libraries.create
libraries.list
libraries.remove
libraries.rename
libraries.switch
```

**`library`** (5)

```
library.analytics
library.get
library.save
library.stats
library.timeline
```

**`locale`** (3)

```
locale.list
locale.ordinal
locale.term
```

**`names`** (3)

```
names.et_al
names.format
names.parse
```

**`network`** (3)

```
network.author_stats
network.coauthor
network.export
```

**`note`** (4)

```
note.add
note.list
note.remove
note.update
```

**`pdf`** (3)

```
pdf.extract_text
pdf.metadata
pdf.recognize
```

**`quality`** (2)

```
quality.assess
quality.audit
```

**`report`** (5)

```
report.field_completeness
report.key_collisions
report.language
report.orphans
report.year_coverage
```

**`schema`** (2)

```
schema.fields
schema.item_types
```

**`search`** (5)

```
search.quick
search.saved.add
search.saved.list
search.saved.remove
search.saved.run
```

**`tag`** (6)

```
tag.cloud
tag.delete
tag.list
tag.merge
tag.rename
tag.set_color
```

**`tex`** (4)

```
tex.aux
tex.bbl
tex.coverage
tex.extract_citations
```

**`text`** (4)

```
text.change_case
text.extract_identifiers
text.latex_to_unicode
text.unicode_to_latex
```

**`webdav`** (4)

```
webdav.delete
webdav.download
webdav.upload
webdav.verify
```

**`zotero`** (3)

```
zotero.pull
zotero.push
zotero.verify
```

## zftp

Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync  
**183 verbs** · live bus surface · call as `App::open("zftp")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (53)

```
appshell.Compare directories
appshell.Connect selected
appshell.Connect to server
appshell.Copy remote path
appshell.Disconnect selected
appshell.Discover LAN
appshell.Erasure disperse
appshell.Erasure reconstruct
appshell.Estimate transfer
appshell.Export bookmarks
appshell.Go to path
appshell.Import bookmarks
appshell.List directory
appshell.New folder
appshell.Preferences
appshell.Reload
appshell.Remove bookmark
appshell.Resolve name clashes
appshell.Session monitor
appshell.Swarm audit
appshell.Swarm replicate
appshell.Toggle terminal
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`archive`** (2)

```
archive.tar_index
archive.zip_index
```

**`azure`** (1)

```
azure.sign
```

**`b2`** (1)

```
b2.authorization
```

**`bandwidth`** (2)

```
bandwidth.fair_share
bandwidth.token_bucket
```

**`bookmark`** (9)

```
bookmark.add
bookmark.get
bookmark.import
bookmark.import_filezilla
bookmark.import_winscp
bookmark.list
bookmark.remove
bookmark.set_options
bookmark.update
```

**`checksum`** (2)

```
checksum.compute
checksum.verify_file
```

**`codec`** (2)

```
codec.base64_decode
codec.base64_encode
```

**`creds`** (6)

```
creds.clear
creds.delete
creds.load
creds.parse_netrc
creds.set
creds.store
```

**`dedup`** (1)

```
dedup.plan
```

**`delta`** (2)

```
delta.plan
delta.signature
```

**`dircache`** (1)

```
dircache.diff
```

**`discovery`** (1)

```
discovery.scan
```

**`edit`** (1)

```
edit.map
```

**`erasure`** (3)

```
erasure.disperse
erasure.plan
erasure.reconstruct
```

**`filter`** (5)

```
filter.apply
filter.expand
filter.glob_to_regex
filter.match
filter.parse_rules
```

**`fs`** (7)

```
fs.chmod
fs.delete
fs.list
fs.mkdir
fs.peek
fs.rename
fs.rename_plan
```

**`ftp`** (8)

```
ftp.build_eprt
ftp.build_port
ftp.fxp_port
ftp.parse_epsv
ftp.parse_feat
ftp.parse_mlsx
ftp.parse_pasv
ftp.parse_reply
```

**`ftps`** (1)

```
ftps.negotiate
```

**`gcs`** (2)

```
gcs.resumable_plan
gcs.resume_offset
```

**`integrity`** (1)

```
integrity.repair_plan
```

**`knownhosts`** (1)

```
knownhosts.verify
```

**`listing`** (1)

```
listing.parse
```

**`manifest`** (2)

```
manifest.build
manifest.verify
```

**`path`** (2)

```
path.normalize
path.split
```

**`perms`** (3)

```
perms.chmod
perms.chmod_recursive
perms.format
```

**`pool`** (2)

```
pool.acquire
pool.maintain
```

**`profile`** (4)

```
profile.decrypt
profile.encrypt
profile.get
profile.recent
```

**`proxy`** (3)

```
proxy.http_connect
proxy.parse_socks5_reply
proxy.socks5_connect
```

**`queue`** (1)

```
queue.schedule
```

**`retry`** (1)

```
retry.classify
```

**`s3`** (4)

```
s3.complete_multipart
s3.list_objects
s3.presign
s3.sign
```

**`scp`** (3)

```
scp.build_control
scp.parse_control
scp.walk
```

**`session`** (6)

```
session.clear_logs
session.connect
session.disconnect
session.list
session.logs
session.status
```

**`settings`** (2)

```
settings.get
settings.set
```

**`sftp`** (8)

```
sftp.build_ext_op
sftp.build_init
sftp.build_path_op
sftp.negotiate
sftp.parse_attrs
sftp.parse_extensions
sftp.parse_packet
sftp.parse_statvfs
```

**`sidecar`** (2)

```
sidecar.parse
sidecar.verify
```

**`ssh`** (2)

```
ssh.config_resolve
ssh.fingerprint
```

**`swarm`** (4)

```
swarm.audit
swarm.fetch
swarm.replicate
swarm.schedule
```

**`swift`** (1)

```
swift.temp_url
```

**`sync`** (4)

```
sync.compare
sync.plan
sync.resolve
sync.symlink_policy
```

**`transfer`** (10)

```
transfer.add
transfer.backoff
transfer.cancel
transfer.clear
transfer.estimate
transfer.list
transfer.multipart_plan
transfer.resume_check
transfer.segments
transfer.status
```

**`transport`** (1)

```
transport.info
```

**`tree`** (2)

```
tree.diff
tree.serialize
```

**`webdav`** (2)

```
webdav.parse_multistatus
webdav.propfind_body
```

## zwire

Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power  
**161 verbs** · live bus surface · call as `App::open("zwire")->call("<verb>", %args)`

**`(top-level)`** (62)

```
clipboard_get
clipboard_set
exec
fs_append
fs_list
fs_mkdir
fs_read
fs_rm
fs_stat
fs_tail
fs_walk
fs_watch
fs_write
get
hello
hook_fire
hooks_delete
hooks_events
hooks_get_script
hooks_list
hooks_save
hooks_script_path
hooks_set_enabled
hooks_set_script
hooks_test_run
hostinfo
hostlog
job_list
job_poll
job_result
job_start
kill
kv_del
kv_get
kv_keys
kv_merge
kv_set
meter_stream
notify
open
peer
peer_connect
peers
ping
ps
pty_kill
pty_resize
pty_spawn
pty_write
pub
stryke_lsp_send
stryke_lsp_start
stryke_lsp_stop
stryke_run
sub
sysinfo_once
sysinfo_start
sysinfo_stop
unsub
watch_list
watch_stop
which
```

**`browser`** (99)

```
browser.activate
browser.addHistoryUrl
browser.addReadingList
browser.allowSleep
browser.bookmarkFolder
browser.bookmarkTab
browser.cancelDownload
browser.centerWindow
browser.clearAllData
browser.clearCache
browser.clearCacheAndCookies
browser.clearCookies
browser.clearDownloads
browser.clearHistory
browser.clearPasswords
browser.closeDuplicates
browser.closeLeft
browser.closeOthers
browser.closeRight
browser.closeTab
browser.closeWindow
browser.collapseGroups
browser.deleteHistoryUrl
browser.detectLanguage
browser.disableExtension
browser.discardTab
browser.download
browser.duplicateTab
browser.enableExtension
browser.expandGroups
browser.extensionOptions
browser.firstTab
browser.fullscreenWindow
browser.goBack
browser.goForward
browser.gotoTab
browser.groupTabs
browser.home
browser.incognitoWindow
browser.keepAwake
browser.keepDisplayAwake
browser.lastTab
browser.launchApp
browser.maximizeWindow
browser.mergeWindows
browser.minimizeWindow
browser.moveTabFirst
browser.moveTabLast
browser.moveTabLeft
browser.moveTabRight
browser.moveWindowNextDisplay
browser.muteAll
browser.muteOthers
browser.muteTab
browser.newTab
browser.newWindow
browser.nextTab
browser.nextWindow
browser.notify
browser.open
browser.openDownload
browser.openTab
browser.pauseDownload
browser.pinAll
browser.pinTab
browser.prevTab
browser.prevWindow
browser.reload
browser.reloadAll
browser.reloadHard
browser.removeBookmark
browser.removeReadingList
browser.reopenTab
browser.restoreWindow
browser.resumeDownload
browser.retryDownload
browser.screenshot
browser.showDownload
browser.showDownloads
browser.snapBottom
browser.snapBottomLeft
browser.snapBottomRight
browser.snapLeft
browser.snapRight
browser.snapTop
browser.snapTopLeft
browser.snapTopRight
browser.sortTabs
browser.tabToNewWindow
browser.tmux
browser.ungroupTabs
browser.uninstallExtension
browser.unmuteAll
browser.unmuteTab
browser.unpinAll
browser.unpinTab
browser.zoomIn
browser.zoomOut
browser.zoomReset
```

## zwire

Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power  
**161 verbs** · live bus surface · call as `App::open("zwire")->call("<verb>", %args)`

**`(top-level)`** (62)

```
clipboard_get
clipboard_set
exec
fs_append
fs_list
fs_mkdir
fs_read
fs_rm
fs_stat
fs_tail
fs_walk
fs_watch
fs_write
get
hello
hook_fire
hooks_delete
hooks_events
hooks_get_script
hooks_list
hooks_save
hooks_script_path
hooks_set_enabled
hooks_set_script
hooks_test_run
hostinfo
hostlog
job_list
job_poll
job_result
job_start
kill
kv_del
kv_get
kv_keys
kv_merge
kv_set
meter_stream
notify
open
peer
peer_connect
peers
ping
ps
pty_kill
pty_resize
pty_spawn
pty_write
pub
stryke_lsp_send
stryke_lsp_start
stryke_lsp_stop
stryke_run
sub
sysinfo_once
sysinfo_start
sysinfo_stop
unsub
watch_list
watch_stop
which
```

**`browser`** (99)

```
browser.activate
browser.addHistoryUrl
browser.addReadingList
browser.allowSleep
browser.bookmarkFolder
browser.bookmarkTab
browser.cancelDownload
browser.centerWindow
browser.clearAllData
browser.clearCache
browser.clearCacheAndCookies
browser.clearCookies
browser.clearDownloads
browser.clearHistory
browser.clearPasswords
browser.closeDuplicates
browser.closeLeft
browser.closeOthers
browser.closeRight
browser.closeTab
browser.closeWindow
browser.collapseGroups
browser.deleteHistoryUrl
browser.detectLanguage
browser.disableExtension
browser.discardTab
browser.download
browser.duplicateTab
browser.enableExtension
browser.expandGroups
browser.extensionOptions
browser.firstTab
browser.fullscreenWindow
browser.goBack
browser.goForward
browser.gotoTab
browser.groupTabs
browser.home
browser.incognitoWindow
browser.keepAwake
browser.keepDisplayAwake
browser.lastTab
browser.launchApp
browser.maximizeWindow
browser.mergeWindows
browser.minimizeWindow
browser.moveTabFirst
browser.moveTabLast
browser.moveTabLeft
browser.moveTabRight
browser.moveWindowNextDisplay
browser.muteAll
browser.muteOthers
browser.muteTab
browser.newTab
browser.newWindow
browser.nextTab
browser.nextWindow
browser.notify
browser.open
browser.openDownload
browser.openTab
browser.pauseDownload
browser.pinAll
browser.pinTab
browser.prevTab
browser.prevWindow
browser.reload
browser.reloadAll
browser.reloadHard
browser.removeBookmark
browser.removeReadingList
browser.reopenTab
browser.restoreWindow
browser.resumeDownload
browser.retryDownload
browser.screenshot
browser.showDownload
browser.showDownloads
browser.snapBottom
browser.snapBottomLeft
browser.snapBottomRight
browser.snapLeft
browser.snapRight
browser.snapTop
browser.snapTopLeft
browser.snapTopRight
browser.sortTabs
browser.tabToNewWindow
browser.tmux
browser.ungroupTabs
browser.uninstallExtension
browser.unmuteAll
browser.unmuteTab
browser.unpinAll
browser.unpinTab
browser.zoomIn
browser.zoomOut
browser.zoomReset
```

## zreq

Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket  
**152 verbs** · live bus surface · call as `App::open("zreq")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`appshell`** (31)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`assert`** (1)

```
assert.run
```

**`asyncapi`** (1)

```
asyncapi.parse
```

**`cbor`** (2)

```
cbor.decode
cbor.encode
```

**`chunked`** (2)

```
chunked.decode
chunked.encode
```

**`codegen`** (1)

```
codegen.generate
```

**`collection`** (7)

```
collection.add
collection.diff
collection.get
collection.lint
collection.list
collection.remove
collection.update
```

**`conditional`** (2)

```
conditional.build
conditional.evaluate
```

**`cookie`** (5)

```
cookie.clear
cookie.list
cookie.parse
cookie.select
cookie.set
```

**`curl`** (1)

```
curl.explain
```

**`dataset`** (1)

```
dataset.parse
```

**`encoding`** (1)

```
encoding.convert
```

**`env`** (3)

```
env.dotenv.export
env.dotenv.parse
env.merge
```

**`environment`** (4)

```
environment.activate
environment.add
environment.list
environment.remove
```

**`export`** (4)

```
export.bruno
export.har
export.openapi
export.postman
```

**`formdata`** (2)

```
formdata.build
formdata.parse
```

**`globals`** (2)

```
globals.get
globals.set
```

**`graphql`** (3)

```
graphql.introspection_query
graphql.parse
graphql.schema.parse
```

**`grpc`** (1)

```
grpc.call
```

**`har`** (1)

```
har.analyze
```

**`hash`** (1)

```
hash.compute
```

**`history`** (3)

```
history.clear
history.list
history.replay
```

**`hmac`** (1)

```
hmac.compute
```

**`httpsig`** (2)

```
httpsig.sign
httpsig.verify
```

**`hypermedia`** (2)

```
hypermedia.parse
hypermedia.plan
```

**`import`** (7)

```
import.bruno
import.curl
import.har
import.httpie
import.insomnia
import.openapi
import.postman
```

**`jmespath`** (1)

```
jmespath.query
```

**`json`** (2)

```
json.diff
json.to_xml
```

**`jsonpath`** (1)

```
jsonpath.query
```

**`jsonschema`** (1)

```
jsonschema.validate
```

**`jwt`** (2)

```
jwt.decode
jwt.encode
```

**`msgpack`** (2)

```
msgpack.decode
msgpack.encode
```

**`negotiate`** (3)

```
negotiate.encoding
negotiate.language
negotiate.media
```

**`oauth2`** (1)

```
oauth2.token
```

**`openapi`** (2)

```
openapi.diff
openapi.mock
```

**`pkce`** (2)

```
pkce.generate
pkce.verify
```

**`proto`** (1)

```
proto.parse
```

**`protobuf`** (2)

```
protobuf.decode
protobuf.encode
```

**`ratelimit`** (1)

```
ratelimit.parse
```

**`request`** (6)

```
request.add
request.fuzz
request.get
request.remove
request.send
request.update
```

**`response`** (2)

```
response.clear
response.last
```

**`retry`** (1)

```
retry.plan
```

**`runner`** (1)

```
runner.run
```

**`schema`** (2)

```
schema.example
schema.infer
```

**`script`** (1)

```
script.lint
```

**`secret`** (1)

```
secret.scan
```

**`settings`** (4)

```
settings.get
settings.path
settings.reset
settings.update
```

**`sla`** (1)

```
sla.evaluate
```

**`soap`** (2)

```
soap.build
soap.parse
```

**`sse`** (1)

```
sse.parse
```

**`template`** (1)

```
template.render
```

**`urlencoded`** (2)

```
urlencoded.build
urlencoded.parse
```

**`vars`** (2)

```
vars.audit
vars.resolve
```

**`workspace`** (8)

```
workspace.create
workspace.current
workspace.delete
workspace.get
workspace.list
workspace.rename
workspace.save
workspace.switch
```

**`ws`** (1)

```
ws.exchange
```

**`wsframe`** (2)

```
wsframe.build
wsframe.parse
```

**`xml`** (1)

```
xml.to_json
```

## zgo

Alfred-style launcher — script-filter workflows and system commands  
**144 verbs** · live bus surface · call as `App::open("zgo")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`actions`** (1)

```
actions.list
```

**`base`** (1)

```
base.convert
```

**`bookmarks`** (1)

```
bookmarks.search
```

**`calc`** (2)

```
calc.eval
calc.vars
```

**`clipboard`** (5)

```
clipboard.add
clipboard.clear
clipboard.list
clipboard.remove
clipboard.search
```

**`codec`** (2)

```
codec.decode
codec.encode
```

**`color`** (3)

```
color.contrast
color.convert
color.palette
```

**`contacts`** (1)

```
contacts.search
```

**`cron`** (2)

```
cron.describe
cron.next
```

**`currency`** (1)

```
currency.convert
```

**`data`** (3)

```
data.csv_to_json
data.json_to_csv
data.json_to_yaml
```

**`date`** (2)

```
date.add
date.between
```

**`dictionary`** (1)

```
dictionary.define
```

**`feedback`** (2)

```
feedback.parse
feedback.render
```

**`file`** (3)

```
file.browse
file.filter
file.search
```

**`gen`** (7)

```
gen.lorem
gen.nanoid
gen.passphrase
gen.password
gen.strength
gen.ulid
gen.uuid
```

**`hash`** (4)

```
hash.algos
hash.compute
hash.file
hash.hmac
```

**`index`** (2)

```
index.scan
index.search
```

**`ip`** (1)

```
ip.calc
```

**`json`** (1)

```
json.format
```

**`jwt`** (1)

```
jwt.decode
```

**`keystroke`** (1)

```
keystroke.type
```

**`learn`** (2)

```
learn.rank
learn.record
```

**`list`** (1)

```
list.filter
```

**`match`** (4)

```
match.filter
match.minquery
match.stability
match.trajectory
```

**`math`** (1)

```
math.ratio
```

**`music`** (2)

```
music.command
music.nowplaying
```

**`num`** (5)

```
num.format
num.ordinal
num.percent
num.roman
num.spell
```

**`onepassword`** (1)

```
onepassword.search
```

**`process`** (1)

```
process.match
```

**`profile`** (2)

```
profile.get
profile.save
```

**`qr`** (1)

```
qr.payload
```

**`query`** (6)

```
query.classify
query.clear
query.list
query.parse
query.recent
query.record
```

**`rank`** (1)

```
rank.blend
```

**`regex`** (3)

```
regex.match
regex.replace
regex.test
```

**`runningapps`** (1)

```
runningapps.search
```

**`scriptfilter`** (1)

```
scriptfilter.run
```

**`search`** (3)

```
search.add
search.fallback
search.remove
```

**`snippet`** (8)

```
snippet.add
snippet.collection.add
snippet.collection.remove
snippet.expand
snippet.import
snippet.list
snippet.match
snippet.remove
```

**`spotlight`** (1)

```
spotlight.search
```

**`stryke`** (1)

```
stryke.run
```

**`system`** (2)

```
system.list
system.run
```

**`text`** (8)

```
text.diff
text.lines
text.metrics
text.phonetic
text.pipeline
text.readability
text.stats
text.transform
```

**`theme`** (3)

```
theme.add
theme.list
theme.remove
```

**`time`** (6)

```
time.convert
time.humanize
time.now
time.plan
time.zone
time.zones
```

**`trigger`** (6)

```
trigger.external
trigger.fallback
trigger.fileaction
trigger.hotkey
trigger.keyword
trigger.snippet
```

**`unicode`** (2)

```
unicode.char
unicode.lookup
```

**`units`** (1)

```
units.convert
```

**`url`** (1)

```
url.parse
```

**`utility`** (12)

```
utility.conditional
utility.counter
utility.delay
utility.expression
utility.file_conditional
utility.join
utility.json_config
utility.junction
utility.random
utility.replace
utility.split
utility.transform
```

**`var`** (1)

```
var.render
```

**`websearch`** (2)

```
websearch.list
websearch.url
```

**`workflow`** (7)

```
workflow.add
workflow.export
workflow.get
workflow.import
workflow.list
workflow.remove
workflow.run
```

## zphoto

Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions  
**105 verbs** · live bus surface · call as `App::open("zphoto")->call("<verb>", %args)`

**`appshell`** (105)

```
appshell.addLayer
appshell.addMaskFromSel
appshell.addMaskWhite
appshell.addText
appshell.applyMask
appshell.autoContrast
appshell.blackWhite
appshell.boxBlur
appshell.brightnessContrast
appshell.colorBalance
appshell.convertGray
appshell.convertIndexed
appshell.cropImage
appshell.cropToSel
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.curvesDlg
appshell.delActive
appshell.deleteImage
appshell.desaturate
appshell.dropShadow
appshell.dupActive
appshell.edge
appshell.emboss
appshell.equalize
appshell.exposure
appshell.files
appshell.files.close
appshell.files.open
appshell.fillLayer
appshell.flatten
appshell.flipH
appshell.flipLayerH
appshell.flipLayerV
appshell.flipV
appshell.gamma
appshell.gaussianBlur
appshell.glow
appshell.gradientMap
appshell.gui-scripts
appshell.histogram
appshell.hooks
appshell.hueSaturation
appshell.invert
appshell.invertMask
appshell.layerFromVisible
appshell.levelsDlg
appshell.median
appshell.mergeVisible
appshell.motionBlur
appshell.neon.off
appshell.neon.on
appshell.newImage
appshell.noiseF
appshell.offsetLayer
appshell.openImage
appshell.palette
appshell.pixelate
appshell.posterize
appshell.redo
appshell.removeMask
appshell.resizeCanvas
appshell.ripple
appshell.rotate180
appshell.rotate270
appshell.rotate90
appshell.rotateLayer
appshell.saveImage
appshell.saveJpeg
appshell.scaleImage
appshell.scaleLayer
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.selectAll
appshell.selectInvert
appshell.selectNone
appshell.sepia
appshell.settings
appshell.sharpen
appshell.shortcuts
appshell.solarize
appshell.spread
appshell.temperature
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.threshold
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
appshell.undo
appshell.valueInvert
appshell.vibrance
appshell.vignette
```

## ztunnel

Tunnelblick-style VPN client — OpenVPN / WireGuard config + control  
**100 verbs** · live bus surface · call as `App::open("ztunnel")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`config`** (16)

```
config.add
config.diff
config.duplicate
config.get
config.import
config.lint
config.lint_text
config.list
config.migrate
config.openvpn_format
config.parse
config.redact
config.remove
config.rename
config.set_options
config.wireguard_format
```

**`creds`** (2)

```
creds.clear
creds.set
```

**`dns`** (6)

```
dns.block_match
dns.bootstrap_plan
dns.leak_check
dns.parse_server
dns.query_wire
dns.split_horizon
```

**`feature`** (1)

```
feature.matrix
```

**`firewall`** (2)

```
firewall.mss_clamp
firewall.port_forward
```

**`ipsec`** (2)

```
ipsec.narrow_ts
ipsec.profile
```

**`log`** (1)

```
log.analyze
```

**`multihop`** (4)

```
multihop.chain
multihop.mtu_budget
multihop.rekey_schedule
multihop.validate
```

**`net`** (12)

```
net.cidr_aggregate
net.cidr_contains
net.ip_classify
net.ipv6_eui64
net.nat64
net.pmtu_discover
net.range_to_cidrs
net.subnet_info
net.subnet_split
net.tcp_meltdown
net.tunnel_mtu
net.ula
```

**`obfs`** (1)

```
obfs.catalog
```

**`openvpn`** (3)

```
openvpn.inline_blocks
openvpn.push_reply
openvpn.static_key_parse
```

**`platform`** (1)

```
platform.info
```

**`policy`** (2)

```
policy.app_decisions
policy.wifi_action
```

**`profile`** (3)

```
profile.export
profile.get
profile.import
```

**`proxy`** (1)

```
proxy.plan
```

**`route`** (2)

```
route.conflicts
route.coverage
```

**`servers`** (11)

```
servers.add
servers.failover_plan
servers.fastest
servers.favorite
servers.list
servers.ping
servers.quality
servers.rank_quality
servers.recommend
servers.remove
servers.select_strategy
```

**`settings`** (2)

```
settings.get
settings.set
```

**`split`** (3)

```
split.evaluate
split.evaluate_app
split.route_plan
```

**`stats`** (4)

```
stats.budget
stats.rollup
stats.session_summary
stats.uptime_sla
```

**`vpn`** (12)

```
vpn.autoconnect
vpn.can_transition
vpn.clear_logs
vpn.connect
vpn.connections
vpn.disconnect
vpn.killswitch_plan
vpn.killswitch_syntax
vpn.logs
vpn.network_changed
vpn.reconnect_schedule
vpn.status
```

**`wg`** (8)

```
wg.allowed_ips
wg.allowed_ips_dedup
wg.cookie_decision
wg.cookie_model
wg.genkey
wg.handshake_model
wg.noise_layout
wg.pubkey
```

## zthrottle

System monitor / process & network throttling  
**99 verbs** · live bus surface · call as `App::open("zthrottle")->call("<verb>", %args)`

**`(top-level)`** (2)

```
capabilities
version
```

**`alerts`** (4)

```
alerts.check
alerts.list
alerts.remove
alerts.set
```

**`appshell`** (42)

```
appshell.bench-cpu
appshell.bench-disk
appshell.bench-mem
appshell.bench-net
appshell.compare-baseline
appshell.copy-run-report
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.history-clear
appshell.hooks
appshell.keyboard-shortcuts
appshell.metric-alerts
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.run-all
appshell.run-contention
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.tmux-keys
appshell.tmux-layouts
appshell.toggle-statusbar
appshell.toggle-theme
```

**`bench`** (9)

```
bench.all
bench.contention
bench.cpu
bench.disk
bench.interference
bench.mem
bench.net
bench.recovery
bench.spectrum
```

**`drives`** (2)

```
drives.list
drives.set_target
```

**`history`** (3)

```
history.clear
history.get
history.list
```

**`ioreg`** (4)

```
ioreg.find
ioreg.fuse
ioreg.node
ioreg.watch
```

**`lsof`** (1)

```
lsof.snapshot
```

**`net`** (4)

```
net.conn_rate
net.flows
net.info
net.interfaces
```

**`proc`** (7)

```
proc.detail
proc.diff
proc.files
proc.history
proc.kill
proc.snapshot
proc.tree
```

**`storage`** (3)

```
storage.biggest
storage.delete
storage.scan
```

**`sys`** (18)

```
sys.battery
sys.conn_rate
sys.contention
sys.diskio
sys.disks
sys.export
sys.fans
sys.gpu
sys.history
sys.net
sys.overview
sys.power
sys.pressure
sys.processes
sys.pubip
sys.sensors
sys.smart
sys.users
```

## ztranslator

BOME-style MIDI/keyboard translator — presets, translators, rules, HID  
**65 verbs** · live bus surface · call as `App::open("ztranslator")->call("<verb>", %args)`

**`appshell`** (65)

```
appshell.addPreset
appshell.addTranslator
appshell.analyzer
appshell.bulkToggle
appshell.capture
appshell.code
appshell.conflicts
appshell.copySel
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.cutSel
appshell.delSel
appshell.dupSel
appshell.exportBmtp
appshell.feedback
appshell.files
appshell.files.close
appshell.files.open
appshell.grantAccess
appshell.gui-scripts
appshell.help
appshell.hooks
appshell.import
appshell.jsonView
appshell.loadJson
appshell.midiPorts
appshell.midiRef
appshell.neon.off
appshell.neon.on
appshell.new
appshell.palette
appshell.panic
appshell.pasteSel
appshell.presetJump
appshell.presetMgr
appshell.properties
appshell.refreshPorts
appshell.renameSel
appshell.routes
appshell.saveJson
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.sequencer
appshell.settings
appshell.shortcuts
appshell.showLog
appshell.showMonitor
appshell.start
appshell.stats
appshell.stop
appshell.terminal
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
appshell.verify
```

## zstation

Station-style multi-app workspace — boards, tiles, panes  
**52 verbs** · live bus surface · call as `App::open("zstation")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`board`** (10)

```
board.all
board.create
board.delete
board.get
board.list
board.recent
board.rename
board.reset
board.set_icon
board.switch
```

**`convoy`** (4)

```
convoy.go
convoy.list
convoy.remove
convoy.set
```

**`layout`** (2)

```
layout.arrange
layout.save
```

**`library`** (1)

```
library.search
```

**`log`** (2)

```
log.path
log.read
```

**`notes`** (4)

```
notes.add
notes.get
notes.remove
notes.update
```

**`notifications`** (1)

```
notifications.summary
```

**`prefs`** (2)

```
prefs.get
prefs.update
```

**`service`** (2)

```
service.catalog
service.get
```

**`settings`** (2)

```
settings.get
settings.update
```

**`tile`** (8)

```
tile.add
tile.bring_front
tile.remove
tile.send_back
tile.set_muted
tile.set_unread
tile.touch
tile.update
```

**`toast`** (3)

```
toast.append
toast.clear
toast.list
```

**`trail`** (4)

```
trail.list
trail.remove
trail.set
trail.step
```

**`wiring`** (6)

```
wiring.add
wiring.list
wiring.process
wiring.remove
wiring.set_enabled
wiring.update
```

## zcontainer

Docker Desktop + Lens-style container / Kubernetes manager  
**25 verbs** · live bus surface · call as `App::open("zcontainer")->call("<verb>", %args)`

**`appshell`** (25)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files
appshell.files.close
appshell.files.open
appshell.gui-scripts
appshell.hooks
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.scheme-arctic
appshell.scheme-crimson
appshell.scheme-cyberpunk
appshell.scheme-ember
appshell.scheme-matrix
appshell.scheme-midnight
appshell.scheme-toxic
appshell.scheme-vapor
appshell.settings
appshell.shortcuts
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
appshell.toggle-theme
```

