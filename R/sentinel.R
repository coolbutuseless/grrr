

#-----------------------------------------------------------------------------
#' Set a sentinel to output a message when a default argument is used in a function
#'
#' This is a concrete example of how \code{update_function_arguments()} can be
#' used to figure out where default arguments are being called from.
#'
#' @inheritParams update_function_arguments
#' @param argument_name Name of default argument which should have sentinel
#'
#' @examples
#' \dontrun{
#' # Get a sentinel warning everytime data.frame() is called without the user
#' # explicitly setting a 'stringsAsFactors' argument
#' set_sentinel_on_default_arg('data.frame', 'stringsAsFactors', package_name = 'base')
#' }
#'
#' @export
#-----------------------------------------------------------------------------
set_sentinel_on_default_arg <- function(function_name, argument_name, package_name = NULL, envir = parent.frame()) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Get current default args for the desired function
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  default_args <- get_default_args(function_name, package_name)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Check that the argument that the user wants to place a sentinel
  # on is actually a default argument for this function
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (!argument_name %in% names(default_args)) {
    warning("Not doing anything because function '", function_name, "' has no default argument for '", argument_name, "'")
    return()
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Construct the sentinel argument so that it
  #  - outputs a message on the function and default argument that was used
  #  - a short listing of the call stack
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  new_arg = bquote({
    message("Using default argument for '", .(argument_name), "' in function '", .(function_name), "':\n\t>>  ",
            paste(
              lapply(sys.calls(), deparse, width.cutoff = 500),
              collapse = " \n\t>>  ")
    );
    .(default_args[[argument_name]])
  })

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Construct a list of args to use with 'update_function_arguments'
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  arg_list        <- list(function_name, package_name, envir, new_arg)
  names(arg_list) <- c('function_name', 'package_name', 'envir', argument_name)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set the default argument to the sentinel
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  do.call(update_function_arguments, arg_list)

  invisible()
}