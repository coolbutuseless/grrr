<!-- README.md is generated from README.Rmd. Please edit that file -->

# `grrr`: Remove default arguments <img src="man/figures/grrr.png" width = "15%" align="right"/>

`R` has some default arguments that can make programming with R annoying
- `stringsAsFactors = TRUE` immediately springs to mind.

This package can change default arguments in pre-existing functions to
be almost anything.

## Example 1: Change `mean` to use `na.rm = TRUE` by default

A call to `mean` will not remove `NA` values from the input i.e. `na.rm
= FALSE`.

We can switch this default to `na.rm = TRUE` so that `NA` values are
*always* removed:

``` r
grrr::update_function_arguments('mean.default', 'base', na.rm=TRUE)

mean(c(1, 3, 5, NA))
#> [1] 3
```

## Example 2: Change `quantile` to not have a default value for `na.rm`

A problem with changing the default value to be different, is that while
the code may work on your machine, it will still have the old behaviour
for any one else running the code.

A safer way to change the default value would be to remove it
altogether\!

This way, you are forced to explicitly set a good/sane default value
every time the function is called.

In the following call, the default value `na.rm` is removed, and thus an
error will occur anytime we use the function without explictly setting
the value.

``` r
grrr::update_function_arguments('quantile.default', 'stats', na.rm=)

quantile(1:10)
#> Error in quantile.default(1:10): argument "na.rm" is missing, with no default
```

## Example 3: Print warnings when defaults are used

The problem with unsetting the default value is that there may be
numerous places in packages that make use this assumption you’ve just
removed\! So you’ll end up with errors in places you can’t access to
fix.

In this example, the `stringsAsFactors` argument to `data.frame()` is
being changed to print a message if an explicit value isn’t given (but
it will still go ahead and use the default anyway).

This way, you’ll be notified when it happens, but no error will occur.

``` r
grrr::update_function_arguments(
  function_name    = 'data.frame', 
  package_name     = 'base', 
  stringsAsFactors = { message("Using default stringsAsFactors in data.frame()"); default.stringsAsFactors() } 
)
```

``` r
data.frame(x = 1:3, y = c('a', 'b', 'c'))
#> Using default stringsAsFactors in data.frame()
#>   x y
#> 1 1 a
#> 2 2 b
#> 3 3 c
```

# FAQ

## Why not just re-assign the function in the global namespace?

Because that won’t fix places which call the function explicitly e.g.
`stats::quantile()`

## Why not use `purrr::partial()`?

Because that won’t change the function where it lives.

# Warning

This package uses `unlockBinding()` and `assignInNamespace()` and messes
with the internals of other packages which is generally frowned upon.

Furthermore, `assignInNamespace()` actually has some checks to prevent
what I’m trying to do. So there is now `grrr::sudo_assignInNamespace()`
which drops some sanity checks. \#madness