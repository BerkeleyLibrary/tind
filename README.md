# BerkeleyLibrary::TIND

[![Build Status](https://github.com/BerkeleyLibrary/tind/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/BerkeleyLibrary/tind/actions/workflows/build.yml)
[![Gem Version](https://img.shields.io/gem/v/berkeley_library-tind.svg)](https://rubygems.org/gems/berkeley_library-tind)

Utility gem for working with the TIND DA digital archive.

## Installation

In your Gemfile:

```ruby
gem 'berkeley_library-tind'
```

In your code:

```ruby
require 'berkeley_library/tind'
```

## Configuration

To access the TIND API, you will need to set:

1. the base URL for your TIND installation (e.g. `https://digicoll.lib.berkeley.edu/`)
2. the TIND API key (see the "[API Token Generator](https://docs.tind.io/article/2xaplzx9cn-api-token-generator)"
   article on [`docs.tind.io`](https://docs.tind.io). TIND's code and
   docs are inconsistent in their use of "token" and "key". The UI calls
   it a "key", so that's the term we use here.)

These can be set directly, via accessors in the `BerkeleyLibrary::TIND::Config` module;
if they are not set, a value will be read from the environment, and if no
value is present in the environment and Rails is loaded, from the Rails
application configuration (`Rails.application.config`).

| Value         | Config    | ENV                 | Rails            |
| ---           | ---         | ---                 | ---              |
| TIND base URI | `:base_uri` | `LIT_TIND_BASE_URL` | `:tind_base_uri` |
| API key       | `:api_key`  | `LIT_TIND_API_KEY`  | `:tind_api_key`  |

**Note:** The TIND base URI can be set either as a string or as a `URI`
object, but will always be returned as a `URI` object, and an invalid
string setting will raise `URI::InvalidURIError`.

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
passed to the `tind-export` command. If both an explicit option and an environment
variable are set for either, the explicit option takes precedence.




## Transforming TIND Record

### Transforming Class:
1. BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND    (Transforming one Alma record => One TIND record)
2. BerkeleyLibrary::TIND::Mapping::AlmaMultipleTIND  (Transforming one Alma record => Multiple TIND records)

### Source of TIND fields

1. Mapped from an Alma record (automatically)

2. Derived from collection information, mms_id, and date (automatically)

    - 336$a
    - 852$c
    - 980$a
    - 982$a,$b
    - 991$a - (optional)
    - 902$d
    - 901$m
    - 85641$u,$y

3. Added at the time of transforming TIND record (fields of a collection or it's record)

    - FFT
    - 035$a
    - 998$a
    - ...



### Example

1. Setup collection information
   
   - 336:  type of resource
   - 852:  collection's repository name
   - 980:  collection's 980 value
   - 982:  collection's short name and long name
   - 991:  collection' restricted name (optional)

``` ruby

def setup_collection
  BerkeleyLibrary::TIND::Mapping::AlmaBase.collection_parameter_hash = {
    '336' => ['Image'],
    '852' => ['East Asian Library'],
    '980' => ['pre_1912'],
    '982' => ['Pre 1912 Chinese Materials - short name', 'Pre 1912 Chinese Materials - long name'],
    '991' => []
  }
  
  # BerkeleyLibrary::TIND::Mapping::AlmaBase.is_035_from_mms_id = true  

  # Flag on getting Alma record using Barcode
  BerkeleyLibrary::TIND::Mapping::AlmaBase.is_barcode = true           
end
```

2. Praparing additional fields

    Adding field using:
    -  field methods from module:  BerkeleyLibrary::TIND::Mapping::TindField
    -  Or the original method from Ruby Marc when field method found in above module  
        ::MARC::DataField.new(tag, indicator1, indicator, [code1, value1], [code2, value2] ...)

```ruby

def additional_tind_fields_1
  txt = 'v001_0064'
  url = 'https://digitalassets.lib.berkeley.edu/pre1912ChineseMaterials/ucb/ready/991032333019706532/991032333019706532_v001_0064.jpg'
  fft = BerkeleyLibrary::TIND::Mapping::TindField.f_fft(url, txt)

  f = ::MARC::DataField.new('998', ' ', ' ', ['a', 'fake-value'])
  [fft] << f
end

def additional_tind_fields_2
  txt = 'v001_0065'
  url = 'https://digitalassets.lib.berkeley.edu/pre1912ChineseMaterials/ucb/ready/991032333019706532/991032333019706532_v001_0065.jpg'
  fft = BerkeleyLibrary::TIND::Mapping::TindField.f_fft(url, txt)
  [fft]
end
```

3. Transforming one Alma record => One TIND record

```ruby
setup_collection

# id can be  1)mms_id;  2)Millennium no ; or 3)Barcode
id = 'C084093187'

alma_tind = BerkeleyLibrary::TIND::Mapping::AlmaSingleTIND.new
tind_record = alma_tind.record(id, additional_tind_fields_1)

```


4. Or transforming one Alma record => Multiple TIND records
``` ruby
setup_collection

# id can be  1)mms_id;  2)Millennium no ; or 3)Barcode
# id = '991085821143406532'
id = 'C084093187'

alma_tind = BerkeleyLibrary::TIND::Mapping::AlmaMultipleTIND.new(id)
tind_record_1 = alma_tind.record(additional_tind_fields_1)
tind_record_2 = alma_tind.record(additional_tind_fields_2)

```
