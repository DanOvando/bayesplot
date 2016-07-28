library(bayesplot)
suppressPackageStartupMessages(library(rstanarm))
context("MCMC: nuts")

ITER <- 1000
CHAINS <- 3
fit <- stan_glm(mpg ~ wt + am, data = mtcars,
                iter = ITER, chains = CHAINS, refresh = 0)
np <- nuts_params(fit)
lp <- log_posterior(fit)

test_that("all mcmc_nuts_* (except energy) return gtable objects", {
  expect_gtable(mcmc_nuts_acceptance(np, lp))
  expect_gtable(mcmc_nuts_acceptance(np, lp, chain = CHAINS))

  expect_gtable(mcmc_nuts_treedepth(np, lp))
  expect_gtable(mcmc_nuts_treedepth(np, lp, chain = CHAINS))

  expect_gtable(mcmc_nuts_stepsize(np, lp))
  expect_gtable(mcmc_nuts_stepsize(np, lp, chain = CHAINS))

  expect_gtable(mcmc_nuts_divergence(np, lp))
  expect_gtable(mcmc_nuts_divergence(np, lp, chain = CHAINS))
})
test_that("all mcmc_nuts_* (except energy) error if chain argument is bad", {
  funs <- c("acceptance", "divergence", "treedepth", "stepsize")
  for (f in paste0("mcmc_nuts_", funs)) {
    expect_error(do.call(f, list(x=np, lp=lp, chain = CHAINS + 1)),
                 regexp = paste("only", CHAINS, "chains found"),
                 info = f)
    expect_error(do.call(f, list(x=np, lp=lp, chain = 0)),
                 regexp = "chain >= 1",
                 info = f)
  }
})

test_that("mcmc_nuts_energy returns a ggplot object", {
  p <- mcmc_nuts_energy(np, lp)
  expect_gg(p)
  expect_s3_class(p$facet, c("null", "facet"))

  p <- mcmc_nuts_energy(np, lp, merge_chains = FALSE)
  expect_gg(p)
  expect_s3_class(p$facet, c("wrap", "facet"))
  expect_equal(names(p$facet$facets), "Chain")
})
test_that("mcmc_nuts_energy throws correct errors", {
  expect_error(mcmc_nuts_energy(np, lp, chain = 1),
               "does not accept a 'chain' argument")
})