# Create an informative NA vector

Low-level constructor that creates a vctrs record with value and type
fields. Enforces immutability: values with type != 0L are forced to
their type's NA.

## Usage

``` r
new_informative_na(value = double(), type = integer())

why_na(x, type = NULL, ptype = NULL)
```

## Arguments

- value:

  A vector of values. Supported types: logical, integer, double,
  character, complex, Date, POSIXct, difftime, factor. Will coerce to
  double if omitted.

- type:

  An integer vector indicating missingness type. 0L = Observed, 1L =
  MCAR, 2L = MAR, 3L = MNAR.

- x:

  A vector (optional). If omitted, returns an empty double whyna. Type
  is preserved; use `ptype` for explicit casting.

- ptype:

  A prototype vector. If provided, `x` is cast to this type before
  construction.

## Value

A vctrs_rcrd of class informative_na.
