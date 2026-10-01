## Checklist

Zmax releases are versioned in Semantic Versioning: `vMAJOR.MINOR.PATCH`, for
example `v0.4.49`. In these instructions we'll use `<tag>` as a placeholder for
the tag being published. Pushing a `v*` tag is what triggers
`.github/workflows/release.yml`.

* Merge the PR with the release updates. That branch should:
    * Update the version:
        * Update the `workspace.package.version` key in `Cargo.toml` to match the tag
          without its leading `v`. Bugfix releases increment the patch number.
        * Run `cargo check` and commit the resulting change to `Cargo.lock`
    * Add changelog notes to `CHANGELOG.md`
    * Add new `<release>` entry in `contrib/Zmax.appdata.xml` with release information according to the [AppStream spec](https://www.freedesktop.org/software/appstream/docs/sect-Metadata-Releases.html)
* Tag and push
    * Switch to main and pull
    * `git tag -s -m "<tag>" -a <tag> && git push origin <tag>` (note the `-s` which signs the tag)
* Wait for the Release CI to finish
    * It will automatically turn the git tag into a GitHub release when it uploads artifacts
* Edit the new release
    * Use `<tag>` as the title
    * Link to the changelog and release notes
* Merge the release notes PR
* Download the macos and linux binaries and update the `sha256`s in the [homebrew formula]
    * Use `sha256sum` on the downloaded `.tar.xz` files to determine the hash
* Link to the release notes in this-week-in-rust
    * [Example PR](https://github.com/rust-lang/this-week-in-rust/pull/3300)
* Post to reddit
    * [Example: the r/rust subreddit](https://www.reddit.com/r/rust/)

[homebrew formula]: https://github.com/MenkeTechnologies/homebrew-menketech/blob/main/Formula/zmax.rb

## Changelog Curation

The changelog is currently created manually by reading through commits in the
log since the last release. GitHub's compare view is a nice way to approach
this. For example, when creating the v0.4.49 release notes, this compare link
may be used

```
https://github.com/MenkeTechnologies/zmax/compare/v0.4.48...main
```

Either side of the triple-dot may be replaced with an exact revision, so if
you wish to incrementally compile the changelog, you can tackle a weeks worth
or so, record the revision where you stopped, and use that as a starting point
next week:

```
https://github.com/MenkeTechnologies/zmax/compare/7706a4a0d8b67b943c31d0c5f7b00d357b5d838d...main
```

A work-in-progress commit for a changelog might look like
[this example](https://github.com/MenkeTechnologies/zmax/commit/831adfd4c709ca16b248799bfef19698d5175e55).

Not every PR or commit needs a blurb in the changelog. Each release section
tends to have a blurb that links to a GitHub comparison between release
versions for convenience:

> As usual, the following is a summary of each of the changes since the last
> release. For the full log, check out the git log.

Typically, small changes like dependencies or documentation updates, refactors,
or meta changes like GitHub Actions work are left out.
