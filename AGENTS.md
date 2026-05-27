# **AGENTS.md - whyna**

## **Project Overview**
`whyna` is an R package that implements typed/informative missingness following Rubin's MCAR/MAR/MNAR framework. It uses `vctrs` record vectors to track *why* values are missing (Observed, MCAR, MAR, or MNAR) while maintaining compatibility with standard R workflows, `tibble`, and `dplyr`.

## **Core Commands**
* **Install**: `devtools::install()`
* **Load**: `devtools::load_all()`
* **Build**: `devtools::build()`
* **Check**: `devtools::check()`
* **Test All**: `devtools::test()`
* **Test Target**: `testthat::test_file("tests/testthat/test-api.R")`
* **Document**: `devtools::document()` (updates `NAMESPACE` and `man/`)

## **Project Architecture & Entry Points**
* **Directory Model**: R Package (Standard structure)
* **Core Logic**: `R/arch.R` (vctrs record definition and low-level constructors)
* **API Interface**: `R/api.R` (User-facing predicates and recoding tools)
* **Coercion/Casting**: `R/coercion.R` (vctrs ptype2 and cast methods for interoperability)
* **Printing**: `R/printing.R` (Custom format and print methods)

## **Code Style & Patterns**
* **vctrs Records**: The package centers around the `whyna_informative_na` class, a `vctrs_rcrd` with two fields:
    * `value` (double): The actual numeric value (forced to `NA_real_` if type != 0L).
    * `type` (integer): 0L = Observed, 1L = MCAR, 2L = MAR, 3L = MNAR.
* **Verification**: Use `devtools::check()` for full package validation.
* **Example Pattern**:
```r
# Creating an informative NA vector
x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 2L))

# Using predicates
is_mcar(x)    # [1] FALSE  TRUE FALSE FALSE
is_mar(x)     # [1] FALSE FALSE FALSE  TRUE
is_observed(x) # [1]  TRUE FALSE  TRUE FALSE

# Summarizing
missing_summary(x)
```

## **Non-Obvious System Behaviors**
* **Immutability of Missingness**: The `new_informative_na` constructor enforces that any value with a non-zero `type` is automatically forced to `NA_real_`.
* **S3 Method Registration**: Most interoperability (subsetting, concatenation, math) is handled via `vctrs` S3 methods in `R/coercion.R`.

## **System Boundaries & Operational Rules**
### **Always**
* Run `devtools::document()` after changing `@export` or `@import` tags in R files.
* Add unit tests in `tests/testthat/` for any new functionality.
* Ensure `devtools::check()` passes without errors or warnings before proposing changes.
### **Ask First**
* Changes to the underlying record structure (adding fields to the `vctrs_rcrd`).
* Adding new heavy dependencies to `DESCRIPTION`.
### **Never**
* Manually edit `NAMESPACE` or files in `man/` (they are managed by `roxygen2`).
* Use `attributes()` directly on `whyna` objects; use `vctrs` field accessors.

## **Secondary Documentation Index**
* `DESCRIPTION` - Metadata, authors, and dependencies.
* `NAMESPACE` - Exported functions and S3 methods (generated).
* `tests/testthat/` - Exhaustive examples of expected behavior.
