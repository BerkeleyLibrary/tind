# 0.6.0 (2023-04-06)

- Adds `BerkeleyLibrary::TIND::Mapping` module to map MARC records from Alma to TIND.
- `BerkeleyLibrary::TIND::MARC::XMLWriter` now assumes that any object that response to `:write`
  and `:close` is suffiently `IO`-like to write to.

# 0.5.1 (2023-03-23)

- Fix an issue where `BerkeleyLibrary::TIND::MARC::XMLWriter` would drop fields with nonstandard tags (e.g. `FFT` fields)
  and would group and sort fields by tag instead of preserving the original order.

# 0.5.0 (2022-01-17)

- Adds a class `BerkeleyLibrary::TIND::MARC::XMLWriter` to write MARCXML in the format expected by the TIND batch uploader:

  - MARC leader is written to control field 000 as required by TIND
  - control fields (including the leader) use `\` (0x5c), not space (0x32), for unspecified positional
    values

  In addition, a `nil` or empty MARC leader is not written at all.
- Modifies `BerkeleyLibrary::TIND::MARC::XMLReader` to take into account the same peculiarities:
  control field 000 is read into the leader of the MARC record, and slashes in control field values
  (including the leader) are replaced with spaces.

# 0.4.3 (2022-01-26)

- Pins `berkeley_library-marc` to version 0.3.x (0.3.1 or higher).
- `BerkeleyLibrary::TIND::XMLReader#new` and `#read`: Fix issue with options/kwargs
  cross-compatibility between Ruby 2.7 and 3.x
- Adjusts `BerkeleyLibrary::TIND::MARC::XMLReader` to take advantage of proper `freeze:`
  option implementation in `berkeley_library-marc` 3.x.

# 0.4.2 (2021-09-23)

- Extract `BerkeleyLibrary::Util` module to [separate gem](https://github.com/BerkeleyLibrary/util)

# 0.4.1 (2021-08-26)

- Add explicit double splat to prevent
  `BerkeleyLibrary::TIND::Search.perform_single_search` from raising
  `ArgumentError` on Ruby 3+ due to positional / keyword ambiguity

# 0.4.0 (2021-08-19)

- Rename to `BerkeleyLibrary::TIND` in prep for move to GitHub

# 0.3.3 (2021-08-05)

- Send a custom `User-Agent` header to deal with new TIND firewall rules.

# 0.3.2 (2021-07-29)

- Loosen `spec.required_ruby_version` to support Ruby 3.x

# 0.3.1 (2021-05-17)

- `API#get` now raises an `APIException` with a simulated '404 Not Found'
  status if `UCBLIT::TIND::Config.base_uri` is not set, or is blank.

# 0.3.0 (2021-05-11)

- Extracts `MARCExtensions` into a separate gem, 
  [`ucblit-marc`](https://git.lib.berkeley.edu/lap/ucblit-marc).
  - *Note:* As of August 2021 this is now [berkeley_library-marc](https://rubygems.org/gems/berkeley_library-marc). 

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
  with environment variables (see [`UCBLIT::TIND::Export::Config`](lib/berkeley_library/tind/export/config.rb))

# 0.2.0 (2021-03-31)

- Columns in exported OpenOffice / LibreOffice that should not be edited are now marked
  in red but **not** protected.
- API key configuration has moved from `UCBLIT::TIND::API` to `UCBLIT::TIND::Config`.

# 0.1.0 (2021-03-12)

- Initial prerelease
