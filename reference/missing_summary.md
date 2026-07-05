# Summarise missingness patterns

Returns a data.frame with counts and proportions by missingness
mechanism.

## Usage

``` r
missing_summary(x)
```

## Arguments

- x:

  A informative_na vector.

## Value

A data.frame with columns: `mechanism` (factor), `n` (int), `proportion`
(double).

## Examples

``` r
x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 3L))
missing_summary(x)
#>   mechanism n proportion
#> 1  Observed 2       0.50
#> 2      MCAR 1       0.25
#> 3       MAR 0       0.00
#> 4      MNAR 1       0.25
```
