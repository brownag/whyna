# Recode sentinel codes to whyna vector

Maps domain-specific sentinel codes (e.g., "-9999", "LOD",
"Null-broken") to a informative_na vector. Non-sentinel values are
parsed via `ptype`.

## Usage

``` r
sentinel_recode(x, map, ptype = double())
```

## Arguments

- x:

  A character or numeric vector containing raw data with sentinel codes.

- map:

  A named list mapping sentinel strings to mechanism types. Values must
  be "MCAR", "MAR", or "MNAR". Example:
  `list("-9999" = "MAR", "LOD" = "MNAR", "NULL-broken" = "MCAR")`.

- ptype:

  A prototype vector. Non-sentinel values in `x` are cast to this type.
  Default is [`double()`](https://rdrr.io/r/base/double.html) for
  backward compatibility; use
  [`integer()`](https://rdrr.io/r/base/integer.html),
  [`character()`](https://rdrr.io/r/base/character.html), or
  `as.Date(NA)` for other types.

## Value

A informative_na vector.

## Examples

``` r
raw <- c("12.5", "-9999", "LOD", "15.1", "NULL-broken")
x <- sentinel_recode(raw, list("-9999" = "MAR", "LOD" = "MNAR", "NULL-broken" = "MCAR"))
x
#> <informative_na<double>[5]>
#> [1] 12.5      <NA:MAR>  <NA:MNAR> 15.1      <NA:MCAR>
missing_summary(x)
#>   mechanism n proportion
#> 1  Observed 2        0.4
#> 2      MCAR 1        0.2
#> 3       MAR 1        0.2
#> 4      MNAR 1        0.2
```
