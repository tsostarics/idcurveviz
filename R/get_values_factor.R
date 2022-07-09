#' Curve point calculation function factory
#'
#' Creates a function that can be used to calculate values of a polynomial
#' with a given link function.
#'
#' @param betas Numeric vector of polynomial term coefficients
#' @param intercept Intercept for the polynomial, must be length 1
#' @param link Link function to use
#'
#' @return Function to calculate probabilities of given x values
.get_values_factory <- function(betas, link = plogis) {
  function(.x, .link = link)
    .link(
      vapply(.x,
             \(x)
             { sum(vapply(seq_along(betas), \(i) { betas[i] * x^(i-1L) }, 1.0)) },
             1.0
      )
    )
}

.get_values_factory_freeintercept <- function(betas, intercept = 0, link = plogis) {
  function(.x, .intercept = intercept, .link = link)
    .link(
      vapply(.x,
             \(x)
             { sum(vapply(seq_along(betas), \(i) { betas[i] * x^i }, 1.0)) },
             1.0
      ) + .intercept
    )
}
