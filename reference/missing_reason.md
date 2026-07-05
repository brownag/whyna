# Return missingness type as a factor

Return missingness type as a factor

## Usage

``` r
missing_reason(x)
```

## Arguments

- x:

  A informative_na vector.

## Value

A factor with levels "Observed", "MCAR", "MAR", "MNAR".

## Examples

``` r
x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 3L))
missing_reason(x)
#> [1] Observed MCAR     Observed MNAR    
#> Levels: Observed MCAR MAR MNAR
```
