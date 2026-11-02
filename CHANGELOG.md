# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

## [4.0.0] - Unreleased
### Changed
- **Breaking:** Require Rails >= 7.2 and Ruby >= 3.2.
- **Breaking:** Depend on `railties`, `actionpack` and `activesupport` instead of the `rails` meta gem.
- **Breaking:** Replace Timecop with `travel_to`. The `timecop` dependency is gone.
- **Breaking:** Rename `SpecViews::Directory#method` to `#http_method`.
- **Breaking:** Remove the asset manifest `spec_views_manifest.js` and the `spec_views/diff.js` precompile entry. Drop `//= link spec_views_manifest.js` from your manifest if you added it.
- Make the frozen time configurable with `config.spec_views.freeze_time`, `false` disables it.
- Only draw the UI routes in local environments.
- Serve the diff script from the UI controller, so the diff UI works with Sprockets, Propshaft or no asset pipeline. A Content Security Policy allowing `'self'` is sufficient.
- Respond with 404 for unknown views in the UI.
- Use `RSpec.current_example` instead of RSpec internals.
- Fix PDF matching of frozen response bodies.
- Fix mail extraction for objects without parts.
- Fix fallback spec type of views without meta data.

## [3.6.2] - 2026-09-22
### Added
- Add support for rails 8.0

## [3.6.1] - 2026-08-26
### Added
- Add support for rspec-rails 7.

## [3.6.0] - 2025-11-18
### Added
- Add diff preview for HTML matchings.

## [3.5.0] - 2024-05-13
### Added
- Add affix for multiple use in one request spec.

## [3.4.0] - 2023-11-16
### Added
- Add Reject All to remove all challengers with one click.

### Changed
- Fix presentation of controller/request spec name.

## [3.3.1] - 2023-11-09
### Changed
- Fix handling of response message encoding.

## [3.3.0] - 2023-10-31
### Added
- Add Batch Diff to accept identical changes with one click.

## [3.2.1] - 2023-01-20
### Changed
- Skip abandoned spec view directories.

## [3.2.0] - 2022-11-02
### Added
- Support for Rails 7, rspec-rails 6, and Ruby 3.

## [3.1.0] - 2022-08-08
### Changed
- Switch back to `last_run.txt` for better git integration.

## [3.0.0] - 2022-08-08
### Added
- Introduce match_html_fixture for feature specs.
- Introduce view_sanitizer.gsub to sanitize dynamic parts.

### Changed
- Replace `description.txt` and `last_run.txt` with combined and extended `meta.txt`.
- List challenged and outdated views first.

## [2.0.0] - 2022-07-26
### Added
- Introduce real RSpec matcher match_html_fixture (see [README](./README.md#installation)).
- Add request specs as prefered spec type.
- Save original spec description as text file, so the UI doesn't rely on filename-based descriptions anymore.
- Add mailer spec support.

### Changed
- Rename `render` into `it_renders` and add "renders" to the description automtically. `it_renders` cannot be used for PDF responses anymore.

## [1.1.1] - 2021-01-18
### Changed
- Remove digests from ICO files.
- Remove ModDate and ID from PDF files.
- Improve view selection screen layout.

## [1.1.0] - 2021-01-18
### Changed
- Fix .gitignore hint in [README](./README.md#installation) to allow different file extensions.
- Remove CreationDate-header before comparing PDFs.
- Improve [README's Usage section](./README.md#usage).

## [1.0.1] - 2021-01-17
### Added
- Add .gitignore hint to [README](./README.md#installation).
- Add missing timecop dependency.

### Changed
- Improve view selection screen layout.

## [1.0.0] - 2021-01-17
### Changed
- Switch to manual requiring of 'spec_views/support' (see [README](./README.md#installation)).
