

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Extract default arguments for a function into the global environment
#'
#' @inheritParams get_default_args
#'
#' @examples
#' \dontrun{
#' # Put all the default arguments for 'rnorm' into the global environment
#' default_args_to_global_env(function_name = 'rnorm')
#' }
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
default_args_to_global_env <- function(function_name, package_name=NULL) {
  default_args <- get_default_args(function_name, package_name)

  for (i in seq_along(default_args)) {
    x     <- names(default_args)[i]
    value <- default_args[[i]]
    if (is.call(value)) {
      value <- eval(value, envir = .GlobalEnv)
    }
    message("Assigning: ", x, " <- ", deparse(value))
    assign(x, value, .GlobalEnv)
  }

}