# 0.2.4 (2021-05-06)

- `API#get` now raises an `APIException` with a simulated '401 Unauthorized' status 
  if `UCBLIT::TIND::Config.api_key` is not set.

# 0.2.3 (2021-05-04)

- `UCBLIT::TIND::Export`:
  - new method `#exporter_for` returns a `UCBLIT::TIND::Exporter` but doesn't
    export immediately.
  - `#export` now raises `NoResultsError` if no records are returned.

- `UCBLIT::TIND::Exporter` exposes an `any_results?` method that returns false if
  there are no results to export.

# 0.2.2 (2021-05-03)

- `UCBLIT::TIND::API::Search` now gracefully returns an empty result when it gets the 500 Internal
  Server Error that TIND thinks is an acceptable empty search result, instead of raising an exception.

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
