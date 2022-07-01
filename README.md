
<!-- README.md is generated from README.Rmd. Please edit that file -->

# idcurveviz

<!-- badges: start -->
<!-- badges: end -->

Identification/2-alternative forced choice tasks are ubiquitous in
linguistics and psychology. However, it is often not immediately clear
how the identification function is affected by different effect sizes or
intercept values. This issue is compounded when higher-order polynomial
terms are added to the identification curve. The goal of `idcurveviz` is
to provide a set of easy-to-use functions that allow users to quickly
get an idea of how changing different terms affects the identification
curve.

## Installation

You can install the development version of idcurveviz like so:

``` r
devtools::install_github('tsostarics/idcurveviz')
```

## Examples

How does a given curve change with different intercept values?

``` r
library(idcurveviz)
# Polynomial terms given in order of appearance
# i.e., here corresponds to 2x^1 + .2x^2 + -.5x^3
plot_id_curve(betas = c(2, .2, -.5))
```

<img src="man/figures/README-example-1.png" width="100%" />

How does a given curve change along a continuum of intercepts?

``` r
plot_id_curve(betas = c(2, .2, -.5),
              intercepts = seq(-3, 3, by=.2))
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

How does a curve change as a cubic effect is added?

``` r
plot_interpolated_curves(from = c(2, 0, -5),
                         to = c(2, 0, 5),
                         nsteps = 10)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

How good of an approximation can we get with an evenly-spaced 5 step
continuum? What if we had more steps to our continuum?

``` r
plot_quantized_curve(betas = c(2, .2, -.1),
                     nsteps = 5) +
  add_quantized_curve(betas = c(2, .2, -.1),
                      nsteps = 7,
                      quant_color = 'purple')
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

Lastly, we might wonder what the identification function would look like
in a bivariate case with two continua that yield separate polynomials.

``` r
library(plotly)
plot_bivariate_surface(betas1 = c(2, 0, -1),
                       betas2 = c(-2, -.1, 0),
                       show_quantized_points = TRUE)
```

<img src="man/figures/plotlyfig.png" width="100%" />
