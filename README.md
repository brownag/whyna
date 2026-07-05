
<!-- README.md is generated from README.Rmd. Please edit that file -->

# whyna: Informative Missingness via vctrs

<!-- badges: start -->
<!-- badges: end -->

**whyna** implements typed/informative missingness in R, letting you
track *why* values are missing. Standard R treats all missing values as
identical `NA`s, losing critical information about the missingness
mechanism. This package introduces a custom vector class that stores
both the observed value (or `NA`) and the reason it’s missing, following
Rubin’s (1976) MCAR/MAR/MNAR framework.

## Installation

``` r
# Install from GitHub:
devtools::install_github("brownag/whyna")
```

## Why Informative Missingness?

In real data, missing values arise from different mechanisms, each with
distinct mathematical and inferential properties. Rubin’s (1976)
taxonomy formalizes these via the conditional probability of missingness
given the complete data.

**MCAR** (Missing Completely At Random)  
Missingness is independent of both observed and unobserved data. Safe to
delete; standard listwise deletion yields unbiased estimates.

**MAR** (Missing At Random)  
Missingness depends on observed data but not the unobserved value
itself. The mechanism is ignorable: valid inference requires only
maximum likelihood or multiple imputation (MI) methods, without
explicitly modelling the missingness process.

**MNAR** (Missing Not At Random)  
Missingness depends on the unobserved value itself. The mechanism is
non-ignorable: standard analysis methods introduce severe bias.
Sensitivity analysis or specialized methods (selection models,
pattern-mixture models) are required.

### Ignorability and Statistical Inference

A missingness mechanism is ignorable if the analyst can obtain valid
parameter estimates without explicitly modelling the missingness
process. This holds if and only if: 1. The data are MAR, and 2. The
missingness parameters are distinct from the data-generating parameters
(no cross-constraints).

Under ignorability, standard likelihood-based inference proceeds
normally. MNAR violates ignorability, forcing analysts to model the
missingness mechanism directly.

### A Critical Caveat: Three-Valued Logic

R uses three-valued logic: TRUE, FALSE, and NA (unknown). When NA
appears in a comparison, the result is NA because the truth value cannot
be determined.

``` r
NA > 65          # returns NA, not TRUE or FALSE
is.na(NA > 65)   # TRUE
```

This is correct behavior. The alternative—treating NA as an extreme
value (smallest or largest number)—produces silent errors. If NA were
treated as the maximum value, then `age > 65` would incorrectly include
all missing ages in the result set. If NA were the minimum value, it
would exclude them. The result silently reports something untrue.

R and whyna preserve three-valued logic. When you filter or compare, NA
propagates naturally, and you must explicitly handle it with `is.na()`
or `na.rm = TRUE`. This forces you to confront missing data rather than
accidentally corrupting your analysis.

## Quick Start

``` r
library(whyna)

measurements <- why_na(
  c(5.2, NA, 7.1, NA, 3.8),
  type = c(0L, 1L, 0L, 2L, 3L)  # 0=Observed, 1=MCAR, 2=MAR, 3=MNAR
)

measurements
#> <informative_na<double>[5]>
#> [1] 5.2       <NA:MCAR> 7.1       <NA:MAR>  <NA:MNAR>

# Extract missingness predicates
is_mcar(measurements)
#> [1] FALSE  TRUE FALSE FALSE FALSE

is_mar(measurements)
#> [1] FALSE FALSE FALSE  TRUE FALSE

is_mnar(measurements)
#> [1] FALSE FALSE FALSE FALSE  TRUE

# Get a summary factor
missing_reason(measurements)
#> [1] Observed MCAR     Observed MAR      MNAR    
#> Levels: Observed MCAR MAR MNAR
```

## Generalized Typed NA: Beyond Numeric Data

**whyna** now supports any vector type, not just doubles. Here’s an
example with character data where sentinel codes (like “LOD” for “limit
of detection”) and normal values coexist:

``` r
# Character example: lab measurement codes
lab_results <- c("42.5", "LOD", "38.2", "NULL-broken", "45.1")
measurements <- sentinel_recode(
  lab_results,
  map = list("LOD" = "MNAR", "NULL-broken" = "MCAR"),
  ptype = character()
)

measurements
#> <informative_na<character>[5]>
#> [1] 42.5      <NA:MNAR> 38.2      <NA:MCAR> 45.1
missing_reason(measurements)
#> [1] Observed MNAR     Observed MCAR     Observed
#> Levels: Observed MCAR MAR MNAR
```

Integer example with type preservation:

``` r
counts <- why_na(c(10L, NA, 5L, NA, 8L), c(0L, 1L, 0L, 2L, 0L))
counts  # Type is preserved: integer, not double
#> <informative_na<integer>[5]>
#> [1] 10        <NA:MCAR>  5        <NA:MAR>   8
```

## Realistic Case: Water Quality Monitoring

Suppose you’re analyzing dissolved oxygen (DO) measurements from 50
water samples:

``` r
library(whyna)
library(tibble)
#> 
#> Attaching package: 'tibble'
#> The following object is masked from 'package:whyna':
#> 
#>     data_frame
library(dplyr, warn.conflicts = FALSE)

# Simulated water quality dataset
set.seed(123)
n <- 50

water_data <- tibble(
  site_id = 1:n,
  do_value = c(rnorm(35, mean = 8, sd = 1), rep(NA_real_, 15)),
  do_type = c(rep(0L, 35), rep(1L, 5), rep(3L, 10)),
  site_type = sample(c("upstream", "downstream"), n, replace = TRUE),
  temperature = rnorm(n, mean = 15, sd = 3),
  ph = rnorm(n, mean = 7.5, sd = 0.5)
)

# Now create the typed missing-data vector
water_data <- water_data |>
  mutate(
    do = why_na(do_value, type = do_type)
  ) |>
  select(site_id, do, site_type, temperature, ph)

water_data
#> # A tibble: 50 × 5
#>    site_id        do site_type  temperature    ph
#>      <int> <why_dbl> <chr>            <dbl> <dbl>
#>  1       1  7.439524 downstream        16.1  7.21
#>  2       2  7.769823 upstream          13.5  7.80
#>  3       3  9.558708 upstream          14.0  6.69
#>  4       4  8.070508 upstream          11.9  7.47
#>  5       5  8.129288 upstream          11.8  7.76
#>  6       6  9.715065 downstream        15.9  7.65
#>  7       7  8.460916 downstream        16.3  7.55
#>  8       8  6.734939 upstream          15.2  7.18
#>  9       9  7.313147 downstream        17.8  7.08
#> 10      10  7.554338 downstream        21.2  6.99
#> # ℹ 40 more rows
```

### Analysis Workflow

**1. Describe missingness patterns**

``` r
water_data |>
  summarise(
    n_obs = sum(!is.na(do)),
    n_mcar = sum(is_mcar(do)),
    n_mar = sum(is_mar(do)),
    n_mnar = sum(is_mnar(do))
  )
#> # A tibble: 1 × 4
#>   n_obs n_mcar n_mar n_mnar
#>   <int>  <int> <int>  <int>
#> 1    35      5     0     10
```

**2. Filter by missingness mechanism for sensitivity analysis**

``` r
# Rows with observed data only
observed <- water_data |> filter(!is.na(do))
nrow(observed)
#> [1] 35

# Rows with observed or MCAR (safe to use)
trustworthy <- water_data |> filter(!is.na(do) | is_mcar(do))
nrow(trustworthy)
#> [1] 40

# Check for MNAR (biasing mechanism)
any(is_mnar(water_data$do))
#> [1] TRUE
```

**3. Stratified analysis by site type**

``` r
water_data |>
  group_by(site_type) |>
  summarise(
    n = n(),
    mean_do = mean(as.double(do), na.rm = TRUE),
    pct_mnar = 100 * mean(is_mnar(do)),
    .groups = "drop"
  )
#> # A tibble: 2 × 4
#>   site_type      n mean_do pct_mnar
#>   <chr>      <int>   <dbl>    <dbl>
#> 1 downstream    28    8.16     25  
#> 2 upstream      22    7.89     13.6
```

**4. Extract the complete-case subset (removes all missing, regardless
of type)**

``` r
complete <- water_data |> filter(!is.na(do))
nrow(complete)
#> [1] 35
head(complete)
#> # A tibble: 6 × 5
#>   site_id        do site_type  temperature    ph
#>     <int> <why_dbl> <chr>            <dbl> <dbl>
#> 1       1  7.439524 downstream        16.1  7.21
#> 2       2  7.769823 upstream          13.5  7.80
#> 3       3  9.558708 upstream          14.0  6.69
#> 4       4  8.070508 upstream          11.9  7.47
#> 5       5  8.129288 upstream          11.8  7.76
#> 6       6  9.715065 downstream        15.9  7.65
```

## API Reference

### Constructors

**`why_na(x, type = NULL)`** User-facing constructor. Auto-detects
missingness if `type` omitted.

``` r
why_na(c(1.5, NA, 2.3))
#> <informative_na<double>[3]>
#> [1] 1.5       <NA:MCAR> 2.3
```

**`informative_na(x, type = NULL)`** Alias for `why_na()` (verbose form,
identical behavior).

**`new_informative_na(value, type)`** Low-level constructor; strict
validation, for developers.

### Extraction & Predicates

**`is_mcar(x)`, `is_mar(x)`, `is_mnar(x)`** Logical masks indicating
which elements have a given missingness type.

``` r
x <- why_na(c(1, NA, 3, NA), c(0L, 1L, 0L, 2L))
is_mcar(x)
#> [1] FALSE  TRUE FALSE FALSE
is_mar(x)
#> [1] FALSE FALSE FALSE  TRUE
```

**`missing_reason(x)`** Returns a factor with levels: `Observed`,
`MCAR`, `MAR`, `MNAR`.

``` r
missing_reason(x)
#> [1] Observed MCAR     Observed MAR     
#> Levels: Observed MCAR MAR MNAR
```

**`is_observed(x)`, `is_ignorable(x)`** Additional predicates for
analysis workflows.

``` r
is_observed(x)
#> [1]  TRUE FALSE  TRUE FALSE
is_ignorable(x)
#> [1] TRUE TRUE TRUE TRUE
```

**`missing_summary(x)`** Quick overview of missingness patterns: returns
a data.frame with mechanism counts and proportions.

``` r
missing_summary(x)
#>   mechanism n proportion
#> 1  Observed 2       0.50
#> 2      MCAR 1       0.25
#> 3       MAR 1       0.25
#> 4      MNAR 0       0.00
```

### Data Ingestion

**`sentinel_recode(x, map)`** Maps domain-specific sentinel codes (e.g.,
`"-9999"`, `"LOD"`, `"NULL-broken"`) to a whyna vector. Numeric values
pass through as observed.

``` r
raw <- c("12.5", "-9999", "LOD", "15.1")
x <- sentinel_recode(raw, list("-9999" = "MAR", "LOD" = "MNAR"))
x
#> <informative_na<double>[4]>
#> [1] 12.5      <NA:MAR>  <NA:MNAR> 15.1
```

### Base R Integration

**`is.na(x)`** Returns `TRUE` for all missing entries (regardless of
type).

**`format(x)`, `print(x)`** Displays observed values numerically and
missing as `<NA:MCAR>`, etc.

**`c()`, `rbind()`** Combines with plain numeric vectors, upgrading to
`informative_na`.

``` r
x <- why_na(c(1.5, NA), c(0L, 1L))
y <- c(3.1, 4.2)
c(x, y)
#> <informative_na<double>[4]>
#> [1] 1.5       <NA:MCAR> 3.1       4.2
```

**Cast to `double`** Extracts the value field (lossy; discards type
information).

``` r
as.double(x)
#> [1] 1.5  NA
```

## Design Notes

- **Immutability of types**: When `type != 0L`, the `value` field is
  always `NA` of the appropriate type (e.g., `NA_integer_` for integer
  vectors, `NA_character_` for character, `<NA>` for factors).
- **Type preservation**: Input type is preserved in `why_na()`. Use the
  optional `ptype` argument for explicit casting.
- **vctrs foundation**: Built on `vctrs::new_rcrd()` for integration
  with tidyverse (dplyr, tibble).
- **No arithmetic**: Operations like `x + 1` return standard `NA` (not
  class-preserving). Types are preserved during subsetting but revert to
  standard NA under arithmetic operations.

## References

**Foundational Theory**

- Rubin, D. B. (1976). Inference and missing data. *Biometrika*, 63(3),
  581–592.
- Little, R. J. A., & Rubin, D. B. (2002). *Statistical analysis with
  missing data* (2nd ed.). Wiley.

**Practical Methods**

- Carpenter, J. R., & Kenward, M. G. (2013). *Multiple imputation and
  its application*. Wiley.
- van Buuren, S. (2018). *Flexible imputation of missing data* (2nd
  ed.). CRC Press.
- Heckman, J. J. (1979). Sample selection bias as a specification error.
  *Econometrica*, 47(1), 153–161.

## License

MIT License. See LICENSE file for details.

------------------------------------------------------------------------

**Questions?** File an issue or open a discussion. Contributions
welcome!
