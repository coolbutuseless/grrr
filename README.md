<!-- README.md is generated from README.Rmd. Please edit that file -->

# `grrr`: A package for modifying default arguments <img src="man/figures/grrr.png" width = "15%" align="right"/>

`R` has some default arguments that can make programming with R annoying
- `stringsAsFactors = TRUE` immediately springs to mind.

This package can modify default arguments in pre-existing functions to
be almost anything, and as such is a *tool* for exploring:

  - how dependent are the core packages on these arguments being the
    default value
  - how to find places in your code (and in package code) where default
    arguments have been used.

# <span style="color: red;">Warning<span>

Use `grrr` at your own risk\! Changing default arguments for the core
packages is an absolute minefield and *will* causes problems if you
aren’t careful.

The first 2 examples illustrate the basics of replacing default
arguments in core packages, although **you are strongly advised against
doing this** except for testing purposes.

The third example shows the reason I wrote `grrr`: i.e. have R print out
the callstack whenever a default argument is used, and keep processing
the function call using the default.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("coolbutuseless/grrr")
```

## Basic Usage 1: Change `mean` to use `na.rm = TRUE` by default

A call to `mean` will not remove `NA` values from the input i.e. `na.rm
= FALSE`.

We can switch this default to `na.rm = TRUE` so that `NA` values are
*always* removed:

``` r
# Change the default value for `na.rm` from `FALSE` to `TRUE`
grrr::update_function_arguments('mean.default', 'base', na.rm=TRUE)

mean(c(1, 3, 5, NA))
#> [1] 3
```

While this may be the desired behaviour on your local machine, it will
break every other script that assumes the default action\!

<span style="color: red;">**You are strongly advised against doing
this** except for testing
purposes.</span>

## Basic Usage 2: Change `quantile` to not have a default value for `na.rm`

A problem with changing the default value to be different, is that while
the code may work on your machine, it will still have the old behaviour
for any one else running the code.

A safer way to change the default value may be to remove it altogether\!

This way, users are forced to explicitly set a value every time the
function is called.

In the following call, the default value `na.rm` is removed, and thus an
error will occur anytime we use the function without explictly setting
the value.

``` r
# remove the default value for `na.rm`. i.e. force user to specify
grrr::update_function_arguments('quantile.default', 'stats', na.rm=)

quantile(1:10)
#> Error in quantile.default(1:10): argument "na.rm" is missing, with no default
```

While this may result in finding some errors you can fix, it is going to
cause an avalanche of failures for other functions (e.g. within
packages) which assume that the original default value is being used\!

<span style="color: red;">**You are strongly advised against doing
this** except for testing purposes.</span>

## Debug usage: Print warnings and callstack when defaults are used

The best(?) usage for `grrr` will come from using it for debugging in
such a way that the default arguments are still used, but you can
discover *where* they are being used.

In this example, the `stringsAsFactors` argument to `data.frame()` is
being changed to print a message if an explicit value isn’t given (but
it will still go ahead and use the default anyway).

This way, you will be notified when/where it happens, but no error will
occur.

``` r
# Print a message if 'stringsAsFactors' default is used
grrr::update_function_arguments(
  function_name    = 'data.frame', 
  package_name     = 'base', 
  stringsAsFactors = { 
    message("Using default 'stringsAsFactors = TRUE':\n\t>>  ",  
            paste(
              lapply(sys.calls(), deparse, width.cutoff = 500), 
              collapse = " \n\t>>  ")
    ); 
    default.stringsAsFactors() 
  }  
)
```

``` r
data.frame(x = 1:3, y = c('a', 'b', 'c'))
```

``` r
Using default 'stringsAsFactors = TRUE':
    >>  data.frame(x = 1:3, y = c("a", "b", "c"))

  x y
1 1 a
2 2 b
3 3 c
```

# FAQ

## Why not just re-assign the function in the global namespace?

Because that won’t fix places which call the function explicitly e.g.
`stats::quantile()`

## Why not use `purrr::partial()`?

Because that won’t change the function where it lives.

# <span style="color: red;">Another Warning<span>

This package uses `unlockBinding()` and `assignInNamespace()` and messes
with the internals of other packages which is generally frowned upon.

Furthermore, `assignInNamespace()` actually has some checks to prevent
what I’m trying to do. So there is now `grrr::sudo_assignInNamespace()`
which drops some sanity checks. \#madness
