# ucblit-tind

Utility gem for working with the TIND DA digital archive.

## Configuration

To access the TIND API, you will need to set:

1. the base URL for your TIND installation (e.g. `https://digicoll.lib.berkeley.edu/`)
2. the TIND API key (see the "[API Token Generator](https://docs.tind.io/article/2xaplzx9cn-api-token-generator)"
   article on [`docs.tind.io`](https://docs.tind.io). TIND's code and
   docs are inconsistent in their use of "token" and "key". The UI calls
   it a "key", so that's the term we use here.)

These can be set directly, via accessors in the `UCBLIT::TIND::Config` module;
if they are not set, a value will be read from the environment, and if no 
value is present in the environment and Rails is loaded, from the Rails
application configuration (`Rails.application.config`).

| Value         | `Config`    | ENV                 | Rails            |
| ---           | ---         | ---                 | ---              |
| TIND base URI | `:base_uri` | `LIT_TIND_BASE_URL` | `:tind_base_uri` |
| API key       | `:api_key`  | `LIT_TIND_API_KEY`  | `:tind_api_key`  |

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

For the full list of options, type `tind-export --help`. Note that you can set
the TIND base URL and API key either via the environment, as above, or as options
passed to the `tind-export` command.
