# GUI Script Actions — Global Catalog

Every scriptable **GUI-Script action** (automation-bus verb) exposed by every MenkeTechnologies
GUI app. This is the surface a stryke script drives over the [GUI Automation Bus](GUI_AUTOMATION_BUS.md):
`App::open("<app>")->verbs()` returns an app's engine verbs, and every app additionally inherits the
shared **appShell** verbs from `zgui-core`.

**3860 actions** across **14 apps** + 15 shared appShell verbs. Generated `2026-07-12` from each
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
| [`zphoto`](#zphoto) | 533 | `zphoto-core/src` | Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions, smart objects |
| [`zcontainer`](#zcontainer) | 218 | `zcontainer-core/src` | Docker Desktop + Lens-style container / Kubernetes manager — containers, images, volumes, compose, analyze, kube |
| [`zstation`](#zstation) | 36 | `zstation-core/src` | Station-style multi-app workspace — boards, tiles, panes |
| [`zwire`](#zwire) | 161 | `zwire-host/src/zbus.rs` | Chromium-superset browser — tabs, windows, tab-groups, downloads, reading list, power |
| [`traderview`](#traderview) | 1726 | `traderview/frontend/js/zg-automation.js` | TradingView-style charting/trading terminal — the ⌘K palette catalog registered as bus verbs (view tiles + shortcut actions) |
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

## zphoto

Photoshop + Illustrator-style raster & vector editor — layers, filters, paths, actions, smart objects  
**533 verbs** · source `zphoto-core/src` · call as `App::open("zphoto")->call("<verb>", %args)`

**`action`** (7)

```
action.delete
action.get
action.list
action.load
action.play
action.record
action.stop
```

**`brush`** (4)

```
brush.define
brush.delete
brush.list
brush.stamp
```

**`channel`** (4)

```
channel.spot_add
channel.spot_fill
channel.spot_list
channel.spot_remove
```

**`comp`** (4)

```
comp.apply
comp.capture
comp.delete
comp.list
```

**`edit`** (7)

```
edit.copy_merged
edit.cut
edit.fade
edit.history
edit.paste
edit.redo
edit.undo
```

**`fill`** (15)

```
fill.bucket
fill.checkerboard
fill.clouds
fill.difference_clouds
fill.fibers
fill.gradient
fill.grid
fill.history
fill.maze
fill.pattern
fill.plasma
fill.reaction_diffusion
fill.sinus
fill.spiral
fill.tree
```

**`filter`** (137)

```
filter.accented_edges
filter.angled_strokes
filter.antialias
filter.average
filter.bas_relief
filter.bloom
filter.blur
filter.blur_more
filter.box_blur
filter.cartoon
filter.chalk_charcoal
filter.charcoal
filter.chromatic_aberration
filter.chrome
filter.color_halftone
filter.colored_pencil
filter.conte_crayon
filter.convolve
filter.craquelure
filter.crosshatch
filter.crystallize
filter.cubism
filter.curve_bend
filter.cutout
filter.dark_strokes
filter.deinterlace
filter.despeckle
filter.difference_of_gaussians
filter.diffuse
filter.diffuse_glow
filter.dilate
filter.dry_brush
filter.dust_and_scratches
filter.edge
filter.emboss
filter.erode
filter.extrude
filter.facet
filter.field_blur
filter.film_grain
filter.flame
filter.fractal_explorer
filter.fractal_trace
filter.fragment
filter.fresco
filter.gaussian_blur
filter.glass
filter.glow
filter.glowing_edges
filter.gradient_flare
filter.grain
filter.graphic_pen
filter.guided
filter.halftone
filter.halftone_pattern
filter.high_pass
filter.hsb_hsl
filter.hurl
filter.ink_outlines
filter.iris_blur
filter.kaleidoscope
filter.kuwahara
filter.laplace
filter.lens_blur
filter.lens_correction
filter.lens_distortion
filter.lens_flare
filter.lighting_effects
filter.long_shadow
filter.maximum
filter.median
filter.mezzotint
filter.minimum
filter.mosaic_tiles
filter.motion_blur
filter.neon_glow
filter.nl_means
filter.noise
filter.note_paper
filter.ntsc_colors
filter.ocean_ripple
filter.offset
filter.oilify
filter.old_photo
filter.paint_daubs
filter.palette_knife
filter.patchwork
filter.path_blur
filter.photocopy
filter.picture_frame
filter.pixel_sort
filter.pixelate
filter.plaster
filter.plastic_wrap
filter.pointillize
filter.polar_coordinates
filter.poster_edges
filter.predator
filter.radial_blur
filter.reduce_noise
filter.reticulation
filter.ripple
filter.rough_pastels
filter.shape_blur
filter.sharpen
filter.sharpen_edges
filter.sharpen_more
filter.shear
filter.smart_blur
filter.smart_sharpen
filter.smart_sharpen_motion
filter.smudge_stick
filter.softglow
filter.spatter
filter.spherize
filter.sponge
filter.sprayed_strokes
filter.spread
filter.stained_glass
filter.stamp
filter.sumi_e
filter.surface_blur
filter.texturizer
filter.tiles
filter.tilt_shift
filter.torn_edges
filter.trace_contour
filter.underpainting
filter.unsharp_mask
filter.vignette
filter.water_paper
filter.watercolor
filter.wave
filter.waves
filter.whirl_pinch
filter.wind
filter.zigzag
```

**`image`** (36)

```
image.auto_blend
image.color_table
image.contact_sheet
image.convert
image.count
image.crop
image.crop_to_content
image.crop_to_selection
image.delete
image.depth_merge
image.duplicate
image.flatten
image.flip
image.get
image.histogram
image.list
image.measure
image.merge_channels
image.merge_hdr
image.merge_visible
image.new
image.open
image.palette
image.perspective_crop
image.photomerge
image.pick
image.quickmask
image.render
image.resize_canvas
image.reveal_all
image.rotate
image.rotate_arbitrary
image.save
image.scale
image.split_channels
image.stack_mode
```

**`layer`** (65)

```
layer.add
layer.add_adjustment
layer.add_mask
layer.align
layer.apply_mask
layer.auto_align
layer.bevel_emboss
layer.blend_if
layer.color_overlay
layer.content_aware_carve
layer.content_aware_fill
layer.content_aware_move
layer.crop_to_content
layer.defringe
layer.distribute
layer.distribute_spacing
layer.drop_shadow
layer.duplicate
layer.fill
layer.fill_layer
layer.flip
layer.frequency_separation
layer.from_selection
layer.from_visible
layer.gradient_overlay
layer.group
layer.inner_glow
layer.inner_shadow
layer.invert_mask
layer.liquify
layer.list
layer.magic_eraser
layer.mask_density
layer.mask_feather
layer.merge_down
layer.merge_group
layer.move_to_group
layer.offset
layer.outer_glow
layer.paste_into
layer.pattern_overlay
layer.perspective
layer.puppet_warp
layer.remove
layer.remove_mask
layer.remove_matte
layer.reorder
layer.rotate
layer.satin
layer.scale
layer.set
layer.set_fill
layer.shear
layer.smart_convert
layer.smart_filter
layer.smart_rasterize
layer.smart_replace
layer.smart_reset
layer.stroke
layer.stroke_selection
layer.ungroup
layer.vector_mask
layer.via_cut
layer.warp
layer.warp_text
```

**`note`** (4)

```
note.add
note.clear
note.delete
note.list
```

**`op`** (73)

```
op.apply_image
op.auto_color
op.auto_contrast
op.auto_dodge_burn
op.auto_levels
op.auto_white_balance
op.bitmap
op.black_white
op.blacks
op.bleach_bypass
op.brightness_contrast
op.bump_map
op.camera_raw
op.channel_mixer
op.channel_swap
op.chroma_clarity
op.clahe
op.clarity
op.clear
op.color_balance
op.color_balance_tonal
op.color_blind_sim
op.color_lookup
op.color_to_alpha
op.color_wheels
op.colorize
op.cross_process
op.curves
op.dehaze
op.desaturate
op.displace
op.dither
op.duotone
op.equalize
op.exposure
op.gamma
op.gradient_map
op.gradient_map_multi
op.gray_point
op.harmonize
op.hdr_toning
op.hue_curve
op.hue_saturation
op.hue_saturation_full
op.invert
op.isoluminant
op.lab
op.lens_blur_depth
op.levels
op.match_color
op.match_histogram
op.photo_filter
op.posterize
op.rarity_vibrance
op.red_eye
op.replace_color
op.retinex
op.selective_color
op.semi_flatten
op.sepia
op.shadows_highlights
op.solarize
op.split_tone
op.temperature
op.texture
op.threshold
op.threshold_alpha
op.tonal_hue_shift
op.tone_equalizer
op.value_invert
op.velvia
op.vibrance
op.whites
```

**`paint`** (20)

```
paint.airbrush
paint.art_history
paint.background_eraser
paint.burn
paint.clone
paint.color_replacement
paint.heal
paint.history
paint.ink
paint.mixer
paint.pattern
paint.perspective_clone
paint.pucker
paint.push
paint.sharpen
paint.smudge
paint.sponge
paint.spot_heal
paint.stroke
paint.twirl
```

**`path`** (6)

```
path.add
path.delete
path.from_selection
path.list
path.stroke
path.to_selection
```

**`pattern`** (3)

```
pattern.define
pattern.delete
pattern.list
```

**`project`** (2)

```
project.load
project.save
```

**`sampler`** (4)

```
sampler.add
sampler.clear
sampler.delete
sampler.list
```

**`select`** (31)

```
select.all
select.border
select.color_range
select.contrast
select.ellipse
select.feather
select.focus_area
select.foreground
select.from_channel
select.grow
select.invert
select.load
select.magnetic
select.none
select.paint
select.polygon
select.quick
select.rect
select.reselect
select.rounded_rect
select.save
select.shrink
select.similar
select.single_column
select.single_row
select.skin_tones
select.smooth
select.texture
select.tonal_range
select.transform
select.wand
```

**`text`** (3)

```
text.add
text.mask
text.on_path
```

**`vec`** (108)

```
vec.add_anchors
vec.align
vec.arc
vec.artboard.add
vec.average
vec.blend
vec.blob
vec.brush
vec.cleanup
vec.clip
vec.compound
vec.compound_release
vec.convert_anchor
vec.convert_to_shape
vec.crop
vec.crop_marks
vec.crystallize
vec.divide
vec.duplicate
vec.ellipse
vec.envelope_mesh
vec.erase
vec.expand
vec.extrude
vec.eyedropper
vec.fit
vec.flare
vec.free_distort
vec.get
vec.gradient_freeform
vec.gradient_mesh
vec.grid
vec.group
vec.guide.add
vec.hide
vec.image.place
vec.join
vec.knife
vec.layer.add
vec.line
vec.liquify_warp
vec.live_paint_fill
vec.lock
vec.merge
vec.object.add_fill
vec.object.blend
vec.object.blur
vec.object.delete
vec.object.drop_shadow
vec.object.feather
vec.object.glow
vec.object.move_anchor
vec.object.reorder
vec.object.style
vec.object.transform
vec.offset_path
vec.opacity_mask
vec.outline
vec.outline_stroke
vec.path.add
vec.pathfinder
vec.polar_grid
vec.polygon
vec.pucker_bloat
vec.puppet
vec.recolor
vec.rect
vec.reflect
vec.region_at
vec.remove_anchors
vec.repeat_grid
vec.repeat_mirror
vec.repeat_radial
vec.reshape
vec.reverse
vec.revolve
vec.rotate3d
vec.roughen
vec.round_corners
vec.save
vec.scallop
vec.scissors
vec.scribble
vec.select_same
vec.simplify
vec.smooth
vec.spiral
vec.split_grid
vec.star
vec.symbol.adjust
vec.symbol.define
vec.symbol.place
vec.symbol.spray
vec.text
vec.text_case
vec.text_set
vec.text_thread
vec.text_to_outlines
vec.text_wrap
vec.transform_again
vec.transform_each
vec.trim
vec.tweak
vec.twist
vec.ungroup
vec.warp
vec.wrinkle
vec.zigzag
```

---

## zcontainer

Docker Desktop + Lens-style container / Kubernetes manager — containers, images, volumes, compose, analyze, kube  
**218 verbs** · source `zcontainer-core/src` · call as `App::open("zcontainer")->call("<verb>", %args)`

**`analyze`** (56)

```
analyze.affinity.match
analyze.bake.parse
analyze.bundle.scan
analyze.cgroup.parse
analyze.cni.parse
analyze.compose.convert
analyze.compose.lint
analyze.compose.parse
analyze.compose.profiles.resolve
analyze.compose.topology
analyze.cost.estimate
analyze.crd.parse
analyze.cron.parse
analyze.cve.aggregate
analyze.dockerfile.lint
analyze.dockerfile.optimize
analyze.dockerfile.parse
analyze.dockerignore.eval
analyze.env.resolve
analyze.fieldselector.match
analyze.healthcheck.model
analyze.helm.template
analyze.hpa.recommend
analyze.image.layers
analyze.imageref.parse
analyze.imagetag.policy
analyze.ingress.routes
analyze.k8s.lint
analyze.k8s.parse
analyze.k8s.schema.validate
analyze.k8s.score
analyze.kubeconfig.parse
analyze.kustomize.render
analyze.limitrange.simulate
analyze.manifest.diff
analyze.netpol.reachability
analyze.oci.chainid.compute
analyze.oci.image.parse
analyze.owner.graph
analyze.podsecurity.admission
analyze.portmap.parse
analyze.provenance.parse
analyze.quantity.parse
analyze.rbac.analyze
analyze.registry.auth.parse
analyze.resources.sum
analyze.sbom.summarize
analyze.schedule.binpack
analyze.seccomp.lint
analyze.secret.entropy
analyze.selector.match
analyze.storage.bind
analyze.sysctl.analyze
analyze.volume.parse
analyze.vpa.recommend
analyze.webhook.analyze
```

**`docker`** (108)

```
docker.builder.prune
docker.builds.inspect
docker.builds.list
docker.builds.logs
docker.builds.remove
docker.compose.down
docker.compose.list
docker.compose.logs
docker.compose.ps
docker.compose.restart
docker.compose.start
docker.compose.stop
docker.compose.up
docker.config.create
docker.config.inspect
docker.config.remove
docker.configs.list
docker.container.archive.get
docker.container.archive.put
docker.container.attach
docker.container.commit
docker.container.diff
docker.container.exec
docker.container.export
docker.container.files
docker.container.healthcheck
docker.container.inspect
docker.container.kill
docker.container.logs
docker.container.logs.follow
docker.container.pause
docker.container.remove
docker.container.rename
docker.container.resize
docker.container.restart
docker.container.start
docker.container.stats
docker.container.stats.follow
docker.container.stop
docker.container.top
docker.container.unpause
docker.container.update
docker.container.wait
docker.containers.list
docker.context.use
docker.contexts.list
docker.daemon.start
docker.daemon.status
docker.daemon.stop
docker.engine.pause
docker.engine.resume
docker.events.follow
docker.hub.repo
docker.hub.repos
docker.hub.search
docker.hub.tags
docker.image.build
docker.image.distribution
docker.image.history
docker.image.inspect
docker.image.load
docker.image.prune
docker.image.pull
docker.image.push
docker.image.remove
docker.image.run
docker.image.save
docker.image.scan
docker.image.tag
docker.images.list
docker.logs.buffer
docker.metrics.history
docker.network.connect
docker.network.create
docker.network.disconnect
docker.network.inspect
docker.network.prune
docker.network.remove
docker.networks.list
docker.ping
docker.registry.login
docker.registry.logout
docker.scan.available
docker.secret.create
docker.secret.inspect
docker.secret.remove
docker.secrets.list
docker.service.inspect
docker.service.logs.follow
docker.service.remove
docker.service.scale
docker.services.list
docker.stats
docker.swarm.inspect
docker.swarm.node.inspect
docker.swarm.nodes.list
docker.swarm.tasks.list
docker.system.df
docker.system.info
docker.system.prune
docker.topology
docker.volume.backup
docker.volume.create
docker.volume.inspect
docker.volume.prune
docker.volume.remove
docker.volume.restore
docker.volumes.list
```

**`k8s`** (52)

```
k8s.apply.yaml
k8s.configmaps.list
k8s.crds.list
k8s.cronjob.trigger
k8s.cronjobs.list
k8s.daemonsets.list
k8s.deployments.list
k8s.events.list
k8s.generic.list
k8s.helm.history
k8s.helm.install
k8s.helm.releases.list
k8s.helm.repo.add
k8s.helm.repo.list
k8s.helm.repo.remove
k8s.helm.repo.update
k8s.helm.rollback
k8s.helm.search
k8s.helm.uninstall
k8s.helm.upgrade
k8s.helm.values
k8s.ingresses.list
k8s.jobs.list
k8s.namespaces.list
k8s.node.drain
k8s.nodes.list
k8s.pod.cp
k8s.pod.debug
k8s.pod.exec
k8s.pod.logs
k8s.pod.logs.follow
k8s.pod.portforward
k8s.pods.list
k8s.pvcs.list
k8s.pvs.list
k8s.replicasets.list
k8s.resource.apply
k8s.resource.delete
k8s.resource.diff
k8s.resource.events
k8s.resource.get
k8s.resource.patch
k8s.resource.restart
k8s.resource.scale
k8s.rollout.history
k8s.rollout.status
k8s.rollout.undo
k8s.secrets.list
k8s.services.list
k8s.statefulsets.list
k8s.top.nodes
k8s.top.pods
```

**`vm`** (2)

```
vm.resources.get
vm.resources.set
```

---

## zstation

Station-style multi-app workspace — boards, tiles, panes  
**36 verbs** · source `zstation-core/src` · call as `App::open("zstation")->call("<verb>", %args)`

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

**`layout`** (1)

```
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

## traderview

TradingView-style charting/trading terminal — the ⌘K palette catalog registered as bus verbs (view tiles + shortcut actions)  
**1726 verbs** · source `traderview/frontend/js/zg-automation.js` · call as `App::open("traderview")->call("<verb>", %args)`

**`(top-level)`** (1726)

```
action:abc_pattern_run
action:absorption_run
action:accounts_focus_name
action:accounts_overview_refresh
action:acf_run
action:active_share_run
action:ad_normality_run
action:ad_oscillator_run
action:add_bookmark
action:adf_test_run
action:adl_run
action:ai_save
action:alert_rules_focus_new
action:alligator_demo
action:alligator_run
action:alma_run
action:almgren_chriss_frontier
action:almgren_chriss_run
action:alphatrend_run
action:american_option_price
action:amihud_run
action:anchored_momentum_run
action:arch_lm_run
action:aroon_run
action:asi_run
action:atr_channel_run
action:atr_cone_run
action:atr_trailing_stop_run
action:backtest_presets_focus_name
action:backtest_run
action:balance_of_power_run
action:bartlett_run
action:bb_osc_run
action:bb_pb_run
action:bbd_run
action:bbw_run
action:bbwp_run
action:beta_run
action:beta_shrink_run
action:bg_test_run
action:bid_ask_vol_run
action:bipower_variation_run
action:black_litterman_run
action:block_bootstrap_run
action:boards_focus_name
action:bocpd_detect
action:bollinger_squeeze_run
action:bond_duration_build
action:bond_duration_run
action:bootstrap_pnl_run
action:borrow_rate_run
action:bp_test_run
action:breadth_refresh
action:breadth_thrust_run
action:buying_power_run
action:carry_score_run
action:chandelier_stop_demo
action:chandelier_stop_run
action:charts_refresh
action:choppiness_run
action:clear_recents
action:clusters_correlation_run
action:clusters_trade_features_run
action:cohort_tilt_run
action:command_palette
action:commission_optimizer_run
action:community_focus_title
action:copy_symbol
action:copy_view_id
action:copy_view_url
action:cost_basis_opt
action:cost_basis_run
action:cov_denoiser_run
action:csv_wizard_upload
action:cup_and_handle_demo
action:cup_and_handle_detect
action:currency_exposure_run
action:cusum_autofit
action:cusum_detect
action:cycle_locale
action:cypher_pattern_demo
action:cypher_pattern_run
action:daily_loss_limit_run
action:darkpool_rank
action:dashboard_refresh
action:dashboards_focus_new
action:dashboards_toggle_edit
action:deflated_sharpe_compute
action:deflated_sharpe_sweep
action:demark_pivots_run
action:demarker_demo
action:demarker_run
action:developer_focus_name
action:developer_generate
action:discipline_refresh
action:dividend_calendar_run
action:drawdown_throttle_run
action:dtw_warp
action:earnings_cal_poll
action:earnings_cal_refresh
action:economy_load
action:edit_copy
action:edit_cut
action:edit_paste
action:edit_redo
action:edit_select_all
action:edit_undo
action:effective_spread_run
action:escape
action:execution_scheduler_run
action:focus_search
action:footprint_demo
action:footprint_run
action:forecast_run
action:forward_vol_run
action:futures_roll_run
action:fx_option_price
action:go_home
action:goal_tracker_run
action:goals_focus_name
action:greeks_profile_compute
action:ha_reversal_demo
action:ha_reversal_run
action:hawkes_run
action:heatmap_dow_hour_run
action:help
action:herfindahl_run
action:hotkeys_capture
action:hotkeys_focus_name
action:hurst_estimate
action:implementation_shortfall_run
action:import_pick_file
action:import_upload
action:intraday_heatmap_build
action:intraday_heatmap_demo
action:iv_backtest_demo
action:iv_backtest_run
action:iv_rank_compute
action:iv_rank_demo
action:iv_solver_solve
action:journal_focus_body
action:journal_refresh
action:journal_save
action:kagi_run
action:kalman_beta_run
action:kelly_compute_dynamic
action:kelly_compute_static
action:kyles_lambda_run
action:liquidity_analyze
action:liquidity_demo
action:live_refresh
action:live_scanner_connect
action:live_scanner_toggle_voice
action:margin_call_run
action:margin_runway_run
action:marginal_var_run
action:market_impact_analyze
action:market_impact_demo
action:market_profile_demo
action:market_profile_run
action:mc_trades_run
action:microprice_compute
action:momentum_crash_run
action:monte_carlo_run
action:mood_refresh
action:murrey_math_demo
action:murrey_math_run
action:nav_accounts
action:nav_after_hours
action:nav_back
action:nav_budget
action:nav_calendar
action:nav_catalysts
action:nav_categorize
action:nav_charts
action:nav_dashboard
action:nav_dashboards
action:nav_expenses
action:nav_file_taxes
action:nav_goals
action:nav_halts
action:nav_journal
action:nav_live
action:nav_note_templates
action:nav_purchases
action:nav_receipts
action:nav_reports
action:nav_reviews
action:nav_risk_gate
action:nav_scanner
action:nav_search
action:nav_tags
action:nav_trades
action:nav_watchlists
action:nav_webull
action:new_trade_add
action:obi_compute
action:open_charts_for_symbol
action:open_earnings_for_symbol
action:open_new_tab
action:open_news_for_symbol
action:open_options_for_symbol
action:open_research_for_symbol
action:open_settings
action:open_type_run
action:optimal_f_compute
action:option_payoff_recalc
action:order_flow_classify
action:order_flow_demo
action:order_staleness_demo
action:order_staleness_evaluate
action:pair_trade_analyze
action:paper_submit
action:pattern_discovery_run
action:per_symbol_slippage_demo
action:per_symbol_slippage_run
action:portfolio_allocator_run
action:pyramid_run
action:range_bar_run
action:range_expansion_demo
action:range_expansion_run
action:rebalance_compute
action:rebalance_focus_targets
action:regime_detector_run
action:regime_equity_run
action:reload
action:replay_refresh
action:research_action
action:risk_on_off_run
action:risk_parity_run
action:risk_parity_solver_run
action:risk_reward_run
action:risk_save
action:roll_spread_run
action:round_levels_run
action:rr_butterfly_run
action:screener_run
action:second_order_greeks_run
action:series_smoother_run
action:setups_by_setup_run
action:signal_decomposition_run
action:spread_tracker_demo
action:spread_tracker_run
action:stop_loss_backtest_run
action:strategy_alerts_evaluate_now
action:strategy_alerts_focus_name
action:stress_test_demo
action:stress_test_run
action:tax_loss_harvest_run
action:three_bar_reversal_demo
action:three_bar_reversal_run
action:three_line_break_run
action:tick_bar_run
action:time_in_force_run
action:time_in_force_snap_now
action:toggle_crt
action:toggle_favorite
action:toggle_neon
action:toggle_theme
action:top_signals_refresh
action:trade_plan_checklist_run
action:trades_new
action:trades_refresh
action:triple_screen_run
action:var_calculator_compute
action:var_estimator_run
action:vasicek_simulate
action:vix_term_structure_run
action:vol_smile_fit
action:vol_stop_close_run
action:volume_at_price_run
action:volume_bar_run
action:vpin_compute
action:vpin_demo
action:vwap_slippage_analyze
action:vwap_slippage_demo
action:wash_sale_run
action:watchlists_focus_add
action:watchlists_refresh
action:webull_refresh
action:weighted_midprice_run
action:yield_curve_pca_run
action:yield_curve_run
view:529-roth
view:abc-inventory-analysis
view:abc-pattern
view:able-account
view:about
view:absorption
view:absorption-ratio
view:accountable-plan
view:accounting-rate-of-return
view:accounts
view:accounts-overview
view:accrual-ratio
view:accrued-interest
view:acf
view:acquirers-multiple
view:active-share
view:activity-based-costing
view:ad-normality
view:ad-oscillator
view:additional-medicare-tax
view:adf-test
view:adjusted-sharpe-ratio
view:adl
view:after-hours
view:after-repair-value
view:after-tax-cash-flow
view:after-tax-return
view:age-allocation
view:ai
view:alert-rules
view:alerts
view:algo
view:alligator
view:allowance-doubtful
view:alma
view:almgren-chriss
view:alphatrend
view:altman-z-double-prime
view:altman-z-score
view:american-option
view:amihud
view:amt-calc
view:anchored-momentum
view:annuity-pv-fv
view:appraisal-ratio
view:apr-apy
view:arch-lm
view:arms-index-trin
view:aroon
view:arpu
view:asi
view:asset-coverage-ratio
view:asset-disposal
view:atr-channel
view:atr-cone
view:atr-position-size
view:atr-stop
view:atr-trailing-stop
view:augusta-rule
view:auto-loan
view:average-correlation
view:average-daily-range
view:average-order-value
view:backdoor-roth
view:backlog-coverage
view:backtest
view:backtest-presets
view:backup-withholding
view:balance-of-power
view:balloon-payment
view:band-of-investment
view:bank-reconciliation
view:barista-fire
view:bartlett-variance
view:batting-average
view:bb-squeeze
view:beneish-m-score
view:beta
view:beta-shrinkage
view:bid-ask-volume-ratio
view:bill-calendar
view:bill-of-sale
view:billable-utilization
view:bipower-variation
view:biz-categorizer
view:black-litterman
view:blended-debt
view:block-bootstrap
view:board-resolution
view:boards
view:bocpd
view:bollinger-band-distance
view:bollinger-band-width
view:bollinger-bandwidth-percentile
view:bollinger-oscillators
view:bollinger-percent-b
view:bond-amortization
view:bond-convexity
view:bond-dirty-price
view:bond-duration
view:bond-equivalent-yield
view:bond-ladder
view:bond-market
view:bond-pricing
view:bond-roll-down
view:bond-tent
view:bond-yield-curve
view:bonus-grossup
view:book-to-bill
view:book-value
view:book-value-per-share
view:bootstrap-pnl
view:borrow-rate-indicator
view:box-spread
view:breadth
view:breadth-divergence
view:breadth-thrust
view:break-even
view:break-even-ratio
view:break-even-roas
view:break-premium
view:breakeven-after-costs
view:breakeven-occupancy
view:breakeven-rent
view:breakeven-win-rate
view:breusch-godfrey
view:breusch-pagan
view:brier-score
view:brinson
view:broker-compare
view:brokers
view:brrrr
view:budget
view:budget-variance
view:buffett-indicator
view:bundle-discount
view:burke-ratio
view:burn-multiple
view:burn-rate
view:business-compare
view:businesses
view:butterfly-spread
view:buyback-yield
view:buying-power
view:cac-payback-months
view:calendar
view:calendar-spread
view:callable-oas
view:cam-reconciliation
view:camarilla-pivots
view:candle-strength-index
view:cap-rate-spread
view:cap-table
view:capacity-utilization
view:cape-indicator
view:cape-valuation
view:capex-per-unit
view:capex-to-sales
view:capital-gains-tax
view:capital-intensity
view:capital-loss-carryover
view:capitalization-ratio
view:capm
view:capture-ratio
view:car-affordability
view:car-tco
view:carhart-4
view:carry-score
view:carry-trade-return
view:cash-adjusted-pe
view:cash-break-even
view:cash-conversion-cycle
view:cash-conversion-efficiency
view:cash-conversion-ratio
view:cash-discount-apr
view:cash-flow-adequacy
view:cash-flow-coverage
view:cash-flow-forecast
view:cash-flow-margin
view:cash-flow-per-door
view:cash-flow-statement
view:cash-flow-to-capex
view:cash-on-cash-return
view:cash-out-refinance
view:cash-return-on-assets
view:catalyst-correlations
view:catalysts
view:categorize
view:cd-ladder
view:cd-penalty
view:cdar
view:cease-desist
view:centered-smoothed-momentum
view:cfroi
view:chaikin-oscillator
view:chande-dynamic-momentum
view:chande-kroll-stop
view:chande-momentum-oscillator
view:chande-trend-index
view:chande-volatility-index
view:chandelier-exit
view:chandelier-stop
view:charitable-planner
view:charts
view:cholesky
view:choppiness
view:chowder-number
view:churn-rate
view:clean-energy-25d
view:closing-cost-estimate
view:closing-statement
view:clusters-correlation
view:clusters-trade-features
view:coast-fire
view:cohort-tilt
view:collar
view:college-529
view:commercial-lease
view:commission-agreement
view:commission-optimizer
view:commodities
view:common-sense-ratio
view:community
view:compare
view:compound-interest
view:conditional-sharpe
view:confluence
view:confluence-autotrade
view:congressional-trading
view:conservation-easement
view:consumer-surplus
view:contractor-1099
view:contractor-agreement
view:contribution-margin
view:contribution-per-constraint
view:conversion-cost
view:convertible-note
view:cornish-fisher-var
view:correlation
view:cost-average-down
view:cost-basis
view:cost-of-debt-aftertax
view:cost-of-goods-manufactured
view:cost-of-hire
view:cost-of-preferred
view:cost-seg
view:cov-denoiser
view:coverdell-esa
view:covered-call
view:cpi-rent-adjustment
view:cppi-floor
view:crack-spread
view:crat
view:crate-browser
view:credit-card-payoff
view:credit-spread
view:credit-utilization
view:cross-broker-wash
view:cross-price-elasticity
view:cross-rate
view:crossover-rate
view:crut
view:crypto
view:crypto-liquidation
view:crypto-markets
view:crypto-staking
view:csv-wizard
view:cup-and-handle
view:currency-exposure
view:current-yield
view:custom-indicators
view:customer-concentration
view:cusum
view:cypher-pattern
view:d-ratio
view:daf
view:daily-loss-limit
view:darkpool
view:dashboard
view:dashboards
view:days-cash-on-hand
view:days-payable-outstanding
view:days-sales-outstanding
view:days-working-capital
view:dca-simulator
view:dcf
view:dcfsa
view:de-minimis-safe-harbor
view:debt-avalanche
view:debt-paydown-yield
view:debt-snowball
view:debt-to-assets
view:debt-to-capital
view:debt-to-ebitda
view:debt-to-equity
view:debt-to-income
view:debt-yield
view:decline-curve-arps
view:decumulation-mc
view:default-probability
view:defensive-interval-ratio
view:defined-benefit
view:deflated-sharpe
view:degree-financial-leverage
view:degree-operating-leverage
view:degree-total-leverage
view:demand-for-payment
view:demark-pivots
view:demarker
view:deposit-interest
view:deposit-to-rent
view:depreciation
view:depreciation-recapture
view:depreciation-schedule
view:developer
view:development-spread
view:disability-insurance-needs
view:disabled-access
view:discipline
view:disclosures
view:discretionary-income
view:diversification-ratio
view:dividend-aristocrats
view:dividend-calendar
view:dividend-capture
view:dividend-coverage
view:dividend-coverage-reit
view:dividend-discount-model
view:dividend-growth-rate
view:dividend-payback-period
view:dividend-payout-ratio
view:dividend-per-share
view:dividend-tracker
view:dividend-yield
view:dollar-bar
view:dollar-break-even
view:doubling-time-exact
view:down-payment-savings-time
view:downside-deviation
view:drawdown-cutoff
view:drawdown-recovery-time
view:drawdown-throttle
view:drip-simulator
view:dscr
view:dtw
view:dupont-roe
view:duration-gap
view:early-payment-discount
view:earnest-money-receipt
view:earnings-cal
view:earnings-call-live
view:earnings-growth-rate
view:earnings-iv
view:earnings-per-share
view:earnings-power-value
view:earnings-quality
view:earnings-revisions
view:earnings-surprise
view:earnings-yield
view:earnings-yield-spread
view:earnout
view:ebitda-coverage
view:ebitda-margin
view:economic-calendar
view:economic-production-quantity
view:economic-vacancy
view:economic-value-added
view:economy
view:education-credits
view:effective-duration
view:effective-gross-income
view:effective-gross-rent
view:effective-number-bets
view:effective-rent
view:effective-rental-rate
view:effective-spread
view:effective-tax-rate
view:efficiency-ratio-bank
view:efficient-frontier
view:emergency-fund
view:employee-writeup
view:endowment-spending
view:enterprise-value
view:envelope-budget
view:equipment-rental
view:equity-buildup
view:equity-multiple
view:equity-multiplier
view:equivalent-annual-cost
view:equivolume
view:esg
view:espp-calc
view:estate-tax
view:estimate
view:estimates-dashboard
view:etf-overlap
view:etf-profile
view:ev-credit
view:ev-ebitda
view:ev-to-ebit
view:ev-to-fcf
view:ev-to-gross-profit
view:ev-to-sales
view:ev-vs-ice
view:excess-social-security
view:execution-scheduler
view:expected-net-worth
view:expected-value-bet
view:expense-calendar
view:expense-dashboard
view:expense-drag
view:expense-recovery-ratio
view:expense-reimbursement
view:expenses
view:exports
view:fafsa-efc
view:fat-fire
view:favorites
view:fbar-8938
view:fcf-conversion
view:fcf-margin
view:fcf-per-share
view:fcf-yield
view:fcff-fcfe
view:fda-calendar
view:fear-greed
view:fed-model
view:fi-number
view:fica-tip-credit
view:fifty-percent-rule
view:fifty-thirty-twenty
view:file-browser
view:file-taxes
view:filings-browser
view:fill-quality
view:fill-rate
view:film-181
view:final-paycheck
view:financial-independence-ratio
view:financial-ratios
view:finnhub-aggregate
view:finnhub-pattern
view:finnhub-search
view:finnhub-sr
view:fire-calculator
view:first-year-withdrawal
view:fix-and-flip
view:fixed-asset-coverage
view:fixed-asset-turnover
view:fixed-charge-coverage
view:fixed-income
view:fixed-ratio-sizing
view:flexible-budget
view:flip-holding-cost
view:food-cost-percentage
view:footprint
view:forecast
view:foreign-tax-credit
view:forex
view:forex-988
view:forex-rates
view:forward-pe
view:forward-rate
view:forward-vol
view:free-cash-flow
view:freelance-rate
view:funds-from-operations
view:futures-roll
view:futures-tick-value
view:fx-option
view:gain-to-pain
view:gamma-pin-zone
view:gamma-squeeze
view:garman-klass-volatility
view:geometric-return
view:gift-card-breakage
view:gift-tax
view:gini-coefficient
view:glide-path
view:global-dscr
view:gmroi
view:goal-funding
view:goal-tracker
view:goals
view:gold-silver-ratio
view:golden-stars
view:goodwill-impairment
view:goodwill-ratio
view:graham-number
view:grat
view:greeks-profile
view:grm
view:gross-burn
view:gross-income-multiplier
view:gross-margin-return-on-labor
view:gross-margin-stability
view:gross-profit-method
view:gross-profit-per-employee
view:gross-profitability
view:gross-rent-yield
view:gross-scheduled-income
view:gross-spread
view:grover-score
view:growing-perpetuity
view:guaranty
view:guyton-klinger
view:ha-reversal
view:halts
view:hamada-equation
view:hawkes
view:heatmap
view:heatmap-dow-hour
view:heloc
view:herfindahl
view:high-low-method
view:historic-rehab
view:historical-market-cap
view:historical-volatility
view:holding-period-return
view:holdover-rent
view:home-maintenance
view:home-office
view:home-sale-exclusion
view:hotkeys
view:house-hacking
view:household-employment-tax
view:hsa-max
view:hsa-triple-tax
view:htb-ranker
view:hull-moving-average
view:human-capital
view:hurst
view:hysa-compare
view:i-bond
view:ibond-calculator
view:ilit
view:imbalance-bar
view:implementation-shortfall
view:implied-growth-rate
view:import
view:income-1099
view:income-elasticity
view:income-statement
view:income-tax-estimator
view:incremental-roic
view:index-constituents
view:inflation-calculator
view:inherited-ira-rmd
view:insider-clusters
view:insider-finnhub
view:insider-sentiment
view:insider-stream
view:inspection-checklist
view:installment-method
view:installment-sale
view:institutional-13f
view:interest-coverage
view:interest-rate-parity
view:interest-tax-shield
view:intraday-heatmap
view:inventory-carrying-cost
view:inventory-costing
view:inventory-eoq
view:inventory-shrinkage
view:inventory-to-sales
view:inventory-to-working-capital
view:inventory-turnover
view:invested-capital-turnover
view:invoice-factoring
view:invoice-generator
view:ipo-calendar
view:ipo-lockups
view:irmaa
view:iron-butterfly
view:iron-condor
view:iso-exercise
view:iv-backtest
view:iv-cone
view:iv-rank
view:iv-solver
view:iv-surface
view:iv-term
view:jensen-alpha
view:job-costing
view:journal
view:k-ratio
view:kagi
view:kalman-beta
view:kanban-card-count
view:kappa-ratio
view:kelly
view:keltner-channel
view:keyboard-shortcuts
view:kiddie-tax
view:kyles-lambda
view:labor-cost-ratio
view:land-contract
view:land-residual-value
view:landlord-notice
view:late-fee
view:lead-paint-disclosure
view:lean-fire
view:learning-curve
view:lease-assignment
view:lease-buyout
view:lease-generator
view:lease-option
view:lease-payment
view:lease-renewal
view:lease-termination
view:lease-vs-buy-car
view:leasing-commission
view:leverage
view:life-insurance-needs
view:lifestyle-inflation
view:lihtc
view:like-kind-exchange
view:liquid-net-worth
view:liquidity
view:liquidity-ratios
view:live
view:live-dashboard
view:live-feed
view:live-scanner
view:llc-operating-agreement
view:loan-apr
view:loan-constant
view:loan-sizing-dscr
view:loan-to-cost
view:loan-to-deposit-ratio
view:loan-to-value
view:lobbying
view:log-viewer
view:loss-recovery
view:loss-to-lease
view:lower-of-cost-market
view:ltcg-harvesting
view:ltv-cac
view:lump-sum-vs-dca
view:m2-measure
view:machine-hour-rate
view:macrs-depreciation
view:magic-formula
view:mail
view:maintenance-capex-ratio
view:management-fee
view:margin-analysis
view:margin-call
view:margin-call-price-short
view:margin-interest
view:margin-of-safety
view:margin-runway
view:marginal-propensity-consume
view:marginal-risk-contribution
view:marginal-var
view:market-gamma
view:market-impact
view:market-profile
view:market-status
view:market-value-added
view:markup-chain
view:markup-margin
view:marriage-penalty
view:martin-ratio
view:max-contracts-margin
view:maximum-adverse-excursion
view:mc-trades
view:meal-deduction
view:mega-backdoor-roth
view:mentorship
view:merton-default
view:microprice
view:mileage-log
view:minimum-variance-weight
view:mirr
view:mlp-k1
view:modified-dietz-return
view:momentum-crash
view:money-flow-index
view:monte-carlo
view:mood
view:mortgage-affordability
view:mortgage-amortization
view:mortgage-interest-deduction
view:mortgage-payoff-vs-invest
view:mortgage-points
view:mortgage-recast
view:mortgage-refinance
view:mtm-election
view:multi-broker
view:multi-product-breakeven
view:multichart
view:murrey-math
view:mutual-fund
view:nda
view:net-cash-per-share
view:net-charge-off
view:net-debt-ebitda
view:net-debt-to-equity
view:net-debt-to-fcf
view:net-interest-margin
view:net-net-working-capital
view:net-profit-margin
view:net-promoter-score
view:net-revenue-retention
view:net-worth-to-income
view:net-worth-tracker
view:new-trade
view:news
view:news-event
view:news-sentiment
view:niit-calculator
view:noi-growth
view:noi-per-sqft
view:nol-tracker
view:nopat-margin
view:normalized-eps
view:note-templates
view:notice-of-entry
view:notional-exposure
view:npv-irr
view:nso-exercise
view:nua-strategy
view:offer-letter
view:office
view:oi-change
view:omega-ratio
view:one-percent-rule
view:open-type
view:operating-cash-flow-ratio
view:operating-cash-flow-to-debt
view:operating-cycle
view:operating-expense-per-unit
view:operating-expense-ratio
view:operating-margin
view:opex-escalation
view:optimal-f
view:option-breakeven
view:option-grant
view:option-intrinsic-extrinsic
view:option-payoff
view:options
view:order-book-imbalance
view:order-flow
view:order-staleness
view:overhead-absorption
view:overhead-rate
view:overtime-pay
view:owner-compensation-ratio
view:owner-earnings
view:owner-earnings-yield
view:pair-trade-calc
view:pairs
view:pairs-coint
view:paper
view:paper-rebalance
view:paper-tax-loss-harvest
view:parking-income
view:parkinson-volatility
view:partial-disposition
view:passive-loss
view:pattern-day-trader
view:pattern-discovery
view:pay-stub
view:payables-turnover
view:payback-period
view:paycheck-401k
view:payoff-ratio
view:payroll-burden-rate
view:payroll-tax-employer
view:pdf
view:pead
view:peg-ratio
view:pegy-ratio
view:pension-funded-status
view:pension-lump-vs-annuity
view:pension-survivor
view:per-symbol-slippage
view:percent-complete-revenue
view:percentage-rent
view:perfect-order-rate
view:permanent-portfolio
view:perp-funding
view:perpetual-inventory
view:personal-balance-sheet
view:personal-cash-flow
view:pet-addendum
view:physical-vacancy
view:piotroski-f-score
view:pip-value
view:piti-payment
view:plans
view:plowback-ratio
view:pmi-removal
view:portfolio-allocator
view:portfolio-beta
view:portfolio-expected-return
view:portfolio-exposure
view:portfolio-heat-total
view:portfolio-longevity
view:position-heat
view:position-size-percent-risk
view:preferred-return
view:preferred-stock
view:premarket
view:prepaid-expense-amortization
view:pretax-margin
view:pretax-roa
view:price-elasticity
view:price-markdown
view:price-per-door
view:price-per-square-foot
view:price-per-unit
view:price-target
view:price-target-blend
view:price-to-book
view:price-to-cash-flow
view:price-to-ebitda
view:price-to-ffo
view:price-to-nav
view:price-to-rent
view:price-to-sales
view:price-to-tangible-book
view:prime-cost
view:probability-of-profit
view:process-costing
view:profit-factor
view:profit-first
view:profit-on-cost
view:promissory-note
view:property-tax
view:property-value-from-noi
view:prorated-rent
view:prospect-ratio
view:pslf-tracker
view:pto-balance
view:pto-policy
view:purchase-agreement
view:purchase-order
view:purchases
view:purchasing-power-erosion
view:purchasing-power-parity
view:put-call-parity
view:pyramid
view:qbi-199a
view:qcd-tracker
view:qlac
view:qoz-tracker
view:qsbs-1202
view:quarterly-tax
view:r-dist
view:r-multiple
view:rachev-ratio
view:range-bar
view:range-expansion
view:rd-credit
view:rd-intensity
view:real-dividend-growth
view:real-estate
view:real-estate-cap-rate
view:real-raise
view:real-return
view:rebalance
view:rebalancing-bands
view:receipts
view:receivables-aging
view:receivables-turnover
view:recommendation-sectors
view:regime-detector
view:regime-equity
view:reinvestment-rate
view:renovation-rent-premium
view:rent-affordability
view:rent-escalation
view:rent-growth-cagr
view:rent-increase-notice
view:rent-per-bedroom
view:rent-per-sqft
view:rent-receipt
view:rent-roll
view:rent-to-income
view:rent-vs-buy
view:rent-vs-sell
view:rental-application
view:rental-arbitrage
view:rental-noi
view:rental-payback
view:rental-rules
view:rental-total-return
view:rental-yield-on-cost
view:reorder-point
view:repeat-purchase-rate
view:replacement-cost
view:replacement-ratio
view:replacement-reserve
view:replay
view:reporting-time-pay
view:reports
view:research
view:residency-daycount
view:residual-income-model
view:retail-inventory-method
view:retainage
view:retirement-max
view:return-moments
view:return-on-assets
view:return-on-capital-employed
view:return-on-tangible-equity
view:revenue-breakdown
view:revenue-per-employee
view:revenue-per-share
view:revenue-retention
view:revenue-run-rate
view:reverse-mortgage
view:reversion-value
view:reviews
view:revpash
view:rights-offering
view:risk
view:risk-gate
view:risk-on-off
view:risk-parity
view:risk-parity-solver
view:risk-reward
view:rmd-calculator
view:roic
view:roll-spread
view:roll-yield
view:rolling-correlation
view:romi
view:roommate-agreement
view:roommate-rent-split
view:roth-bracket-fill
view:roth-contribution
view:roth-conversion-ladder
view:roth-ladder
view:roth-vs-trad-401k
view:round-levels
view:royalty
view:rr-butterfly
view:rrg
view:rsu-grant
view:rsu-vest-tracker
view:rule-of-114
view:rule-of-115
view:rule-of-16
view:rule-of-20
view:rule-of-25
view:rule-of-40
view:rule-of-69-3
view:rule-of-70
view:rule-of-72
view:rule-of-72-inverse
view:rule-of-78
view:rvol-accel
view:saas-magic-number
view:saas-quick-ratio
view:safe
view:safety-stock
view:sales-per-square-foot
view:sales-tax
view:sales-volume-variance
view:salt-cap
view:savers-credit
view:savings-rate
view:savings-waterfall
view:scale-in-average
view:scanner-backtest
view:scanners
view:scorp-calc
view:screener
view:sde-valuation
view:se-health-deduction
view:search
view:sec-1256
view:second-income
view:second-order-greeks
view:section-1014
view:section-1015
view:section-102
view:section-1031
view:section-1033
view:section-1035
view:section-1041
view:section-1042
view:section-105
view:section-1058
view:section-1059
view:section-106
view:section-1092
view:section-119
view:section-1202
view:section-121
view:section-1212
view:section-1231
view:section-1233
view:section-1234
view:section-1239
view:section-1244
view:section-1245
view:section-1245-1250
view:section-1248
view:section-125
view:section-1250
view:section-1259
view:section-127
view:section-1273
view:section-1276
view:section-129
view:section-1291
view:section-1295
view:section-1296
view:section-1296-pfic
view:section-1297
view:section-1298
view:section-132
view:section-134
view:section-1341
view:section-1361
view:section-1362
view:section-1366
view:section-1368
view:section-1374
view:section-1377
view:section-1400z
view:section-1402
view:section-1411
view:section-1445
view:section-1446f
view:section-152
view:section-162a1
view:section-162c
view:section-162f
view:section-162l
view:section-162m
view:section-163j
view:section-164
view:section-165
view:section-165c3
view:section-165d
view:section-165g
view:section-168
view:section-168g
view:section-168k
view:section-170
view:section-172
view:section-174
view:section-179
view:section-179d
view:section-195
view:section-197
view:section-199a
view:section-2010c
view:section-2032
view:section-2055
view:section-2056
view:section-21-cdcc
view:section-213
view:section-219
view:section-221
view:section-23
view:section-24
view:section-24-ctc
view:section-245a
view:section-248
view:section-250
view:section-2503
view:section-2518
view:section-25a
view:section-25c
view:section-25d
view:section-25e
view:section-263-tpr
view:section-263a
view:section-263c
view:section-269
view:section-269a
view:section-274
view:section-280c
view:section-280e
view:section-280f
view:section-280g
view:section-302
view:section-303
view:section-304
view:section-305
view:section-30c
view:section-30d
view:section-311
view:section-318
view:section-32
view:section-32-eic
view:section-332
view:section-336
view:section-338
view:section-351
view:section-351-721
view:section-355
view:section-357
view:section-362
view:section-367a
view:section-367d
view:section-368
view:section-36b
view:section-38
view:section-382
view:section-401a9
view:section-401k-hardship
view:section-408a
view:section-408d3
view:section-409a
view:section-41
view:section-412
view:section-414
view:section-414v
view:section-415
view:section-416
view:section-42
view:section-421
view:section-444
view:section-446
view:section-4501
view:section-451
view:section-457
view:section-45l
view:section-45q
view:section-45v
view:section-45w
view:section-45x
view:section-460
view:section-461
view:section-461l
view:section-467
view:section-469
view:section-47
view:section-471
view:section-472
view:section-475
view:section-475f
view:section-48
view:section-481
view:section-481a
view:section-482
view:section-483
view:section-48c
view:section-4940
view:section-4941
view:section-4942
view:section-4943
view:section-4944
view:section-4945
view:section-4958
view:section-4960
view:section-4972
view:section-4973
view:section-4974
view:section-4975
view:section-4980d
view:section-4980h
view:section-51
view:section-511
view:section-529
view:section-530
view:section-59a
view:section-6011
view:section-6015
view:section-6033
view:section-6038
view:section-6038a
view:section-6038b
view:section-6038d
view:section-6039
view:section-6041
view:section-6045
view:section-6045a
view:section-6045b
view:section-6048
view:section-6049
view:section-6050w
view:section-6051
view:section-6072
view:section-6111
view:section-6112
view:section-6159
view:section-6166
view:section-6213
view:section-6221
view:section-6321
view:section-6325
view:section-6330
view:section-6331
view:section-6404
view:section-6502
view:section-6601
view:section-6651
view:section-6654
view:section-6655
view:section-6662
view:section-6663
view:section-6664
view:section-6672
view:section-6694
view:section-6695
view:section-67
view:section-6700
view:section-6707a
view:section-6724
view:section-691
view:section-707
view:section-71-alimony
view:section-7122
view:section-72p
view:section-72t
view:section-731
view:section-7345
view:section-736
view:section-743
view:section-7430
view:section-7491
view:section-7508a
view:section-752
view:section-754
view:section-7701b
view:section-7701o
view:section-7702
view:section-7702a
view:section-7811
view:section-7872
view:section-7874
view:section-79
view:section-83
view:section-86
view:section-871
view:section-871a
view:section-871m
view:section-877a
view:section-882
view:section-884
view:section-894
view:section-897
view:section-901
view:section-901j
view:section-904
view:section-911
view:section-951
view:section-951a
view:section-956
view:section-962
view:section-988
view:section-989
view:sector-heatmap
view:sector-rotation
view:sector-rotation-strategy
view:sector-timing
view:sectors
view:security-deposit-itemization
view:sell-through-rate
view:seller-disclosure
view:seller-financing
view:seller-net-sheet
view:sentiment
view:sentiment-velocity
view:sep-ira
view:sequence-of-returns
view:sequencer
view:serenity-ratio
view:series-smoother
view:service-cost-allocation
view:settings
view:setups-by-setup
view:severance
view:sga-ratio
view:shareholder-yield
view:shares
view:sharpe-ratio
view:short-interest
view:signal-decomposition
view:simple-ira
view:sinking-fund
view:sizing
view:slat
view:social-security-age
view:solar-payback
view:solo-401k
view:sortino-ratio
view:sp500-predict
view:span-margin
view:spark-spread
view:spia
view:split-shift-premium
view:splits-history
view:spousal-ira
view:spread-tracker
view:springate-score
view:sqn
view:squeeze-alerts
view:squeeze-scanner
view:ss-pia
view:ss-taxation
view:standard-cost-variance
view:standard-pivots
view:standard-vs-itemized
view:state-tax
view:statement-of-account
view:stock-compensation
view:stock-split
view:stock-subscription
view:stock-to-flow
view:stop-loss-backtest
view:stop-loss-best-of
view:storage-revenue
view:str-loophole
view:str-revenue
view:straddle
view:strangle
view:strategy-alerts
view:strategy-tools
view:stress-test
view:stretch-ira
view:stryke-hooks
view:student-loan-interest-deduction
view:student-loan-payoff
view:sublease
view:subscriptions
view:supply-chain
view:sustainable-growth-rate
view:symbol-changes
view:table-turnover
view:tags
view:take-home-paycheck
view:take-rate
view:tangible-book-value
view:tangible-common-equity
view:tape
view:tape-replay
view:target-costing
view:target-profit-units
view:tax-aware-rebalance
view:tax-bracket-optimizer
view:tax-equivalent-yield
view:tax-loss-harvest
view:tax-lots
view:tax-workshop
view:tbill-yield
view:tenant-income-qualification
view:tenant-turnover
view:texas-ratio
view:three-bar-reversal
view:three-fund-portfolio
view:three-line-break
view:throughput-accounting
view:ti-allowance
view:tick-bar
view:time-in-force
view:time-value-money
view:time-weighted-return
view:timesheet
view:tips-bond
view:tips-breakeven
view:toast-history
view:top-news
view:top-signals
view:total-payout-ratio
view:total-shareholder-return
view:trade-compare
view:trade-efficiency
view:trade-expectancy
view:trade-plan-checklist
view:trades
view:traditional-ira-deduction
view:trailing-stop-percent
view:travel-per-diem
view:treynor-ratio
view:trial-balance
view:triangular-arbitrage
view:triple-net-total
view:triple-screen
view:true-hourly-wage
view:tts-qualification
view:tts-scorer
view:turnover-cost-drag
view:tutorial
view:twap
view:two-asset-portfolio
view:two-percent-rule
view:two-stage-ddm
view:unlevered-beta
view:unusual-options
view:uoa-stream
view:upside-potential-ratio
view:uspto-patents
view:vacation-home-breakeven
view:valuation-multiples
view:valuation-tools
view:var-calculator
view:var-estimator
view:variable-overhead-variance
view:vasicek
view:velocity-of-money
view:vertical-spread
view:viral-coefficient
view:vix-implied-move
view:vix-term-structure
view:vol
view:vol-smile
view:vol-stop-close
view:vol-surface
view:volume-at-price
view:volume-bar
view:vpin
view:vrp
view:vwap-slippage
view:wacc
view:wage-converter
view:wage-garnishment
view:walk-forward
view:warrant
view:warranty-liability
view:wash-sale
view:wash-sale-tracker
view:watchlists
view:wealth-index
view:webhooks
view:webull
view:weighted-average-maturity
view:weighted-midprice
view:wholesale-spread
view:win-loss-ratio
view:win-streak-probability
view:work-in-progress
view:workers-comp-premium
view:working-capital
view:working-capital-turnover
view:years-to-fi
view:yield-curve
view:yield-curve-pca
view:yield-on-cost
view:yield-to-call
view:yield-to-maturity
view:yield-to-worst
view:zero-based-budget
view:zmijewski-score
view:ztranslator
```

---

## Notes

- **Dispatch-core apps** (`zphoto`, `zcontainer`, `zstation`) expose their engine verbs as a multi-file
  `"ns.verb" => handler` match dispatch in their `-core` (not a single `commands.rs` list); the count is
  the distinct namespaced dispatch keys, reachable over the bus via each app's `*_invoke` bridge.
- **Forward-only apps** (`ztranslator`, `Audio-Haxor`) have no namespaced verb dispatch — their core is a
  typed-function library and the bus forwards to the webview's `ZGui.automation` surface; only the appShell
  verbs are enumerated here.
- Each app's `bus.rs` is a **hybrid** handler: engine verbs route straight to the `-core` engine;
  `appshell.*` and any `ZGui.automation`-registered verb forward to the webview. `call` accepts any
  registered verb even if discovery does not list it (e.g. zwire's `browser.*` executor).
- Counts are derived at generation time from the verb source; they move as the apps evolve.
