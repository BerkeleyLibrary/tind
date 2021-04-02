# 0.2.1 (2021-04-02)

- `bin/tind-export` script now supports passing an environment file on the command line with the
  `-e` option; `-e` with no arguments reads from `.env` in the current working directory.
- Table metrics (font size, line height, max column width etc.) can now be customized
  with environment variables (see [`UCBLIT::TIND::Export::Config`](lib/ucblit/tind/export/config.rb))

# 0.2.0 (2021-03-31)

- Columns in exported OpenOffice / LibreOffice that should not be edited are now marked
  in red but **not** protected.
- API key configuration has moved from `UCBLIT::TIND::API` to `UCBLIT::TIND::Config`.

# 0.1.0 (2021-03-12)

- Initial prerelease
