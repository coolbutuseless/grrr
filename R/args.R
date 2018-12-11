
#-----------------------------------------------------------------------------
#' Get the complete list of all formal arguments for the given function.
#'
#' @param function_name string. name of function.
#' @param package_name string. name of package to fetch function from.
#'                     if NULL, use current environment. default: NULL
#'
#' @return NULL if there are no default arguments for the given function
#'
#' @export
#-----------------------------------------------------------------------------
get_formal_args <- function(function_name, package_name=NULL) {
  if (is.null(package_name)) {
    func <- get(function_name)
  } else {
    func <- get(function_name, envir = asNamespace(package_name))
  }
  if (is.function(func)) {
    res <- formals(func)
    if (length(res) == 0) {
      res <- NULL
    }
  } else {
    res <- NULL
  }

  res
}



#-----------------------------------------------------------------------------
#' Get the default arguments for the given function.
#'
#' @inheritParams get_formal_args
#'
#' @return NULL if there are no default arguments for the given function
#'
#' @export
#-----------------------------------------------------------------------------
get_default_args <- function(function_name, package_name=NULL) {
  formal_args  <- get_formal_args(function_name, package_name)
  if (is.null(formal_args)) { return(NULL) }
  formal_args  <- as.list(formal_args)
  default_args <- formal_args[formal_args != '']

  if (length(default_args) == 0) {
    NULL
  } else {
    default_args
  }
}



#-----------------------------------------------------------------------------
#' Get all functions which include a default argument for a given list of 'arg_names'
#'
#' @inheritParams find_functions_with_args
#'
#' @return named list of formal arguments multiple functions. The name of each
#'         list element in the list is the function name.
#'
#' @importFrom dplyr "%>%"
#' @import purrr
#' @export
#-----------------------------------------------------------------------------
find_functions_with_default_args <- function(package_name, arg_names=NULL) {
  names_in_package <- ls(envir = asNamespace(package_name))

  funcs_with_default_args <- names_in_package %>%
    purrr::map(get_default_args, package_name=package_name) %>%
    purrr::set_names(names_in_package) %>%
    purrr::discard(is.null)

  if (!is.null(arg_names)) {
    funcs_with_default_args <- funcs_with_default_args %>%
      purrr::keep(~any(names(.x) %in% arg_names))
  }

  funcs_with_default_args <- names(funcs_with_default_args)


  complete_formals <- funcs_with_default_args %>%
    purrr::map(get_formal_args, package_name=package_name) %>%
    purrr::set_names(funcs_with_default_args)


  complete_formals
}



#-----------------------------------------------------------------------------
#' Get all functions which have at least one formal argument matching list of 'arg_names'
#'
#' @param package_name string
#' @param arg_names character vector of names of arguments to look for. If NULL, then all
#'                  functions (and their default formal args are returned).  (default: NULL)
#'
#' @return named list of formal arguments for multiple functions. The name of each
#'         list element is the function name.
#'
#' @import purrr
#' @export
#-----------------------------------------------------------------------------
find_functions_with_args <- function(package_name, arg_names=NULL) {
  names_in_package <- ls(envir = asNamespace(package_name))

  funcs_with_args <- names_in_package %>%
    purrr::map(get_formal_args, package_name=package_name) %>%
    purrr::set_names(names_in_package)

  if (!is.null(arg_names) && length(arg_names) > 0) {
    purrr::keep(funcs_with_args, ~any(names(.x) %in% arg_names))
  } else {
    funcs_with_args
  }
}

