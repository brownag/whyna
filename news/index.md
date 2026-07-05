# Changelog

## whyna 0.1.0

- [`why_na()`](http://humus.rocks/whyna/reference/new_informative_na.md)
  now preserves the input vector’s type instead of promoting to double.
  For example, `why_na(c(1L, NA))` now yields an integer-valued whyna
  vector instead of double. Supported types include:
  - Atomics: logical, integer, double, character, complex
  - Classed: Date, POSIXct, difftime, factor
- `vec_ptype2()` and `vec_cast()` methods in both directions for all
  supported types. Promotes compatible types (e.g., int + dbl -\> dbl)
  and errors on incompatibilities (e.g., chr + dbl).
- [`sentinel_recode()`](http://humus.rocks/whyna/reference/sentinel_recode.md):
  New `ptype` argument allows recoding sentinel codes within any
  supported value type (not just double). Default is
  [`double()`](https://rdrr.io/r/base/double.html) for backward
  compatibility.
