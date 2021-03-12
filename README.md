# ucblit-tind

Utility gem for working with the TIND DA digital archive.

## Configuration

### TIND base URL

To access the TIND API, you will need to set the base URL for your TIND 
installation (e.g. `https://digicoll.lib.berkeley.edu/`).

By default, `ucblit-tind` will look for an environment variable, 
`$LIT_TIND_BASE_URL`. Alternatively, you can set it directly with a
call to `UCBLIT::TIND::Config#base_uri=`, or indirectly, in a Rails
application that uses this gem, by adding a `tind_base_uri` field to 
your Rails configuration, e.g. in `config/application.rb`.

### TIND API key

To access restricted collections, you will need an API key -- see the 
"[API Token Generator](https://docs.tind.io/article/2xaplzx9cn-api-token-generator)"
article on [`docs.tind.io`](https://docs.tind.io). (TIND's code and docs are
inconsistent in their use of "token" and "key". The UI calls it a "key", so
that's the term we use here.)

By default, `ucblit-tind` will look for an environment variable, 
`$LIT_TIND_API_KEY`. Alternatively, you can set it directly with a call to
`UCBLIT::TIND::API#api_key=`.

## Command-line tool: `tind-export`

The `tind-export` command allows you to list TIND collections, or to 
export a TIND collection from the command line. (If the gem is installed,
`tind-export` should be in your `$PATH`. If you've cloned the gem source,
you can invoke it with `bin/tind-export` from the project root directory.)

Examples:

1. list collections

   ```sh
   tind-export --list-collections
   ```

2. export a collection as an OpenOffice/LibreOffice spreadsheet

   ```sh
   tind-export -o lincoln-papers.ods 'Abraham Lincoln Papers'
   ```

3. export a collection as an OpenOffice/LibreOffice spreadsheet in exploded XML format,
   where `lincoln-papers` is a directory

   ```sh
   tind-export -f ODS -o lincoln-papers 'Abraham Lincoln Papers'
   ```

   (Note that OpenOffice itself and many other tools get confused by the extra text
   nodes in the pretty-printed files and won't read them properly; this feature
   is mostly for debugging.)

4. export a collection as CSV, to standard output

   ```sh
   tind-export -f CSV 'Abraham Lincoln Papers'
   ```

For the full list of options, type `tind-export --help`.
