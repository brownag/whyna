# Extract missingness predicates

These functions extract logical masks indicating which values have a
specific missingness type (MCAR, MAR, or MNAR).

## Usage

``` r
is_observed(x)

is_mcar(x)

is_mar(x)

is_mnar(x)

is_ignorable(x)
```

## Arguments

- x:

  A informative_na vector.

## Value

A logical vector of the same length as x.

## Examples

``` r
x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 3L))
is_mcar(x)   # TRUE where type == 1L
#> [1] FALSE  TRUE FALSE FALSE
is_mar(x)    # TRUE where type == 2L
#> [1] FALSE FALSE FALSE FALSE
is_mnar(x)   # TRUE where type == 3L
#> [1] FALSE FALSE FALSE  TRUE
```
