
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `grrr`: A package for modifying default arguments <img src="man/figures/grrr.png" width = "15%" align="right"/>

[![Travis build
status](https://travis-ci.org/coolbutuseless/grrr.svg?branch=master)](https://travis-ci.org/coolbutuseless/grrr)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/coolbutuseless/grrr?branch=master&svg=true)](https://ci.appveyor.com/project/coolbutuseless/grrr)
![](https://img.shields.io/badge/CRAN-Never-blue.svg)

`R` has some default arguments that can make programming -
`stringsAsFactors = TRUE` immediately springs to mind.

This package offers a way modify default arguments in functions to be
almost anything, and as such is a *tool* for exploring:

  - how dependent are the core packages on these arguments being the
    default value
  - how to find places in your code (and in package code) where default
    arguments have been used.

## Features

The package offers three main features:

  - `default_args_to_global_env()` reads the default arguments from a
    function and places their values in the global environment. This is
    useful for debugging.
  - `update_function_arguments()` - for full control of overwriting
    default arguments in functions (even within packages\!)
  - `set_sentinel_on_default_arg()` - a wrapper around
    `update_function_arguments` to adjust a function to simplify notify
    you when it’s using a default argument.

## <span style="color: red;">Warning<span>

Use `grrr` at your own risk\! Changing default arguments for functions
within packages is an absolute minefield and *will* causes problems if
you aren’t careful.

## Installation

``` r
# install.packages("devtools")
devtools::install_github("coolbutuseless/grrr")
```

## Putting default args into the global environment

`default_args_to_global_env()` copies all of the default arguments for a
function into the global environment.

I find this handy when I’m debugging a function with a lot of default
arguments that I don’t want to manually copy/define in order to run bits
of code line-by-line in a function.

``` r
ls()
#> character(0)

myfun <- function(a = 1, b = 2, c = 3, d = 4, e = 5) {
  sum(c(a, b, c, d, e))
}

grrr::default_args_to_global_env(function_name = 'myfun')
#> Assigning: a <- 1
#> Assigning: b <- 2
#> Assigning: c <- 3
#> Assigning: d <- 4
#> Assigning: e <- 5

ls()
#> [1] "a"     "b"     "c"     "d"     "e"     "myfun"

a
#> [1] 1
```

## Change the value of a default argument to a function

`update_function_arguments()` will change the default values for an
argument to any function in the current environment, or within a
package.

E.g. in the following code, we change the builtin `rnorm()` function to
have `mean = 100` rather than the default of `mean = 0`

``` r
set.seed(1); stats::rnorm(5)
#> [1] -0.6264538  0.1836433 -0.8356286  1.5952808  0.3295078

# Change the default value for `mean` from `0` to `100`
grrr::update_function_arguments(function_name = 'rnorm', package_name = 'stats', mean = 100)

set.seed(1); stats::rnorm(5)
#> [1]  99.37355 100.18364  99.16437 101.59528 100.32951
```

We can also *remove* the default for `mean` altogether so that it has to
be specified every time the function is called

``` r
# Remove the default value for `mean` 
grrr::update_function_arguments(function_name = 'rnorm', package_name = 'stats', mean =)

set.seed(1); stats::rnorm(5)
```

    Error in stats::rnorm(5) : 
      argument "mean" is missing, with no default

<span style="color: red;">**You are strongly advised against doing
this**.</span>

  - While this may be the desired behaviour on your local machine, it
    will break every other script that assumes the default action.
  - This is going to cause an avalanche of failures for other functions
    (e.g. within packages where you can’t easily change the code) which
    assume that the original default value is being used.

## Debug usage: Print warnings and callstack when defaults are used

The best(?) usage for `grrr` will come from using it for debugging in
such a way that the default arguments are still used, but you can
discover *where* they are being used.

`set_sentinel_on_default_arg()` is a wrapper around
`update_function_arguments()` that will rewrite the default argument so
that it prints a message and call-stack whenever the function is called
without overriding the default.

E.g. to make `data.frame()` noisy so that the user is notified whenever
an attempt was made to use the function without explicitly setting
`stringsAsFactors`.  
The function will still use the default value - it will just be noisier
when it
does

``` r
grrr::set_sentinel_on_default_arg('data.frame', 'stringsAsFactors', package_name = 'base')

data.frame(x = 1:3, y = c('a', 'b', 'c'))
```

    Using default argument for 'stringsAsFactors' in function 'data.frame':
        >>  data.frame(x = 1:3, y = c("a", "b", "c"))
    
      x y
    1 1 a
    2 2 b
    3 3 c

## Another Warning for People Who Didn’t Read the First Warning

This package uses `unlockBinding()` and `assignInNamespace()` and messes
with the internals of other packages which is generally frowned upon.

Furthermore, `assignInNamespace()` actually has some checks to prevent
what I’m trying to do. Which is why `grrr` includes
`sudo_assignInNamespace()` which drops some sanity checks.

Because of these naughty things the package has to do, `grrr` will never
appear on CRAN.
