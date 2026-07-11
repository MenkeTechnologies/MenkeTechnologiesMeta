# GUI Script Actions — Global Catalog

Every scriptable **GUI-Script action** (automation-bus verb) exposed by every MenkeTechnologies
GUI app. This is the surface a stryke script drives over the [GUI Automation Bus](GUI_AUTOMATION_BUS.md):
`App::open("<app>")->verbs()` returns an app's engine verbs, and every app additionally inherits the
shared **appShell** verbs from `zgui-core`.

**1347 actions** across **10 apps** + 15 shared appShell verbs. Generated `2026-07-11` from each
app's verb source at `origin/main` by `bin/gen-gui-actions.sh` — do not hand-edit.

| App | Engine verbs | Source of truth | Surface |
| --- |:--:| --- | --- |
| [`zcite`](#zcite) | 178 | `zcite/crates/zcite-core/src/commands.rs` | Zotero-style reference manager — library, collections, citations, PDF, sync |
| [`zreq`](#zreq) | 121 | `zreq-core/src/commands.rs` | Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket |
| [`zemail`](#zemail) | 174 | `zemail-core/src/commands.rs` | Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search |
| [`zftp`](#zftp) | 123 | `zftp-core/src/commands.rs` | Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync |
| [`zoffice`](#zoffice) | 96 | `zoffice-core/src/commands.rs` | LibreOffice-style office engine — writer/calc/impress over ODF/OOXML |
| [`zpdf`](#zpdf) | 309 | `zpdf-core/src/commands.rs` | Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact |
| [`zthrottle`](#zthrottle) | 54 | `zthrottle-core/src/commands.rs` | System monitor / process & network throttling |
| [`ztunnel`](#ztunnel) | 97 | `ztunnel-core/src/commands.rs` | Tunnelblick-style VPN client — OpenVPN / WireGuard config + control |
| [`zgo`](#zgo) | 19 | `zgo-core/src/syscommands.rs` | Alfred-style launcher — script-filter workflows and system commands |
| [`zwire`](#zwire) | 161 | `zwire-host/src/zbus.rs` | Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power |
| **appShell** (shared) | 15 | `zgui-core/webui/app-shell.js` | Terminal, file browser, hooks, palette, theme / CRT / neon toggles — on every app |

---

## appShell — shared verbs (present on every app)

```
appshell.crt.off
appshell.crt.on
appshell.crt.toggle
appshell.files.close
appshell.files.open
appshell.neon.off
appshell.neon.on
appshell.palette
appshell.settings
appshell.shortcuts
appshell.terminal.close
appshell.terminal.open
appshell.theme.dark
appshell.theme.light
appshell.theme.toggle
```

---

## zcite

Zotero-style reference manager — library, collections, citations, PDF, sync  
**178 verbs** · source `zcite/crates/zcite-core/src/commands.rs` · call as `App::open("zcite")->call("<verb>", %args)`

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

**`bib`** (10)

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

**`integrity`** (1)

```
integrity.check
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

---

## zreq

Postman-style API client — requests, collections, auth, codegen, gRPC/WebSocket  
**121 verbs** · source `zreq-core/src/commands.rs` · call as `App::open("zreq")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
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

---

## zemail

Thunderbird-style mail client — accounts, folders, messages, PGP/S-MIME, search  
**174 verbs** · source `zemail-core/src/commands.rs` · call as `App::open("zemail")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
```

**`account`** (4)

```
account.add
account.autoconfig
account.list
account.remove
```

**`address`** (2)

```
address.to_ascii
address.validate
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

**`message`** (34)

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
message.reading_time
message.remove_label
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

---

## zftp

Cyberduck-style transfer client — FTP/SFTP/WebDAV/S3/cloud, transfers, sync  
**123 verbs** · source `zftp-core/src/commands.rs` · call as `App::open("zftp")->call("<verb>", %args)`

**`(top-level)`** (1)

```
version
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

---

## zoffice

LibreOffice-style office engine — writer/calc/impress over ODF/OOXML  
**96 verbs** · source `zoffice-core/src/commands.rs` · call as `App::open("zoffice")->call("<verb>", %args)`

**`(top-level)`** (6)

```
diff
info
inspect
meta
open
pagesetup
```

**`base`** (3)

```
base.open
base.query
base.tables
```

**`calc`** (27)

```
calc.cells
calc.charts
calc.charts_detail
calc.charts_render
calc.comments
calc.conditional_formats
calc.csv
calc.edit_cell
calc.eval
calc.evaluate
calc.find
calc.formulas
calc.html
calc.markdown
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

**`impress`** (20)

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

**`writer`** (29)

```
writer.bookmark_text
writer.comment_details
writer.comments
writer.content_controls
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

---

## zpdf

Acrobat/Preview-style PDF engine — render, edit, annotate, forms, OCR, redact  
**309 verbs** · source `zpdf-core/src/commands.rs` · call as `App::open("zpdf")->call("<verb>", %args)`

**`(top-level)`** (309)

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

---

## zthrottle

System monitor / process & network throttling  
**54 verbs** · source `zthrottle-core/src/commands.rs` · call as `App::open("zthrottle")->call("<verb>", %args)`

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

**`bench`** (6)

```
bench.all
bench.contention
bench.cpu
bench.disk
bench.mem
bench.net
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

---

## ztunnel

Tunnelblick-style VPN client — OpenVPN / WireGuard config + control  
**97 verbs** · source `ztunnel-core/src/commands.rs` · call as `App::open("ztunnel")->call("<verb>", %args)`

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

**`multihop`** (2)

```
multihop.chain
multihop.validate
```

**`net`** (11)

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

---

## zgo

Alfred-style launcher — script-filter workflows and system commands  
**19 verbs** · source `zgo-core/src/syscommands.rs` · call as `App::open("zgo")->call("<verb>", %args)`

**`(top-level)`** (19)

```
darkmode
displaysleep
eject
ejectall
emptytrash
forcequit
hide
lock
logout
quit
quitall
restart
screensaver
showtrash
shutdown
sleep
togglemute
volumedown
volumeup
```

---

## zwire

Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power  
**161 verbs** · source `zwire-host/src/zbus.rs` · call as `App::open("zwire")->call("<verb>", %args)`

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

---

## Notes

- **Coreless bus apps** (`zphoto`, `zstation`, `ztranslator`, `zcontainer`) expose the shared appShell
  verbs plus their Tauri backend commands; they have no standalone Rust verb list, so only the appShell
  surface is enumerated here.
- Each app's `bus.rs` is a **hybrid** handler: engine verbs route straight to the `-core` engine;
  `appshell.*` and any `ZGui.automation`-registered verb forward to the webview. `call` accepts any
  registered verb even if discovery does not list it (e.g. zwire's `browser.*` executor).
- Counts are derived at generation time from the verb source; they move as the apps evolve.
