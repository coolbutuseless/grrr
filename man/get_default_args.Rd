% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/args.R
\name{get_default_args}
\alias{get_default_args}
\title{Get the default arguments for the given function.}
\usage{
get_default_args(function_name, package_name = NULL)
}
\arguments{
\item{function_name}{string. name of function.}

\item{package_name}{string. name of package to fetch function from.
if NULL, use current environment. default: NULL}
}
\value{
NULL if there are no default arguments for the given function
}
\description{
Get the default arguments for the given function.
}
