# Changelog
All notable changes to this project will be documented in this file.

## [Unreleased]

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
