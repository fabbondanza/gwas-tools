#!/usr/bin/env Rscript
library(martini)
library(tidyverse)

load("${RGWAS}")
load("${RNET}")

# make a exploratory run to get the best parameters
params <- capture.output(
    cones <- scones.cv(gwas, net, score = "${SCORE}",
                        criterion = "${CRITERION}")
                        )

cat(params)

params <- tail(params, n = 2) %>% 
  lapply(strsplit, ' = ') %>% 
  unlist %>% .[c(F,T)] %>% 
  as.numeric() %>% 
  log10

# optimize the parameters
etas <- 10^seq(params[1] - 1.5, params[1] + 1.5, length.out = 10)
lambdas <- 10^seq(params[2] - 1.5, params[2] + 1.5, length.out = 10)

cones <- scones.cv(gwas, net,
                   score = "${SCORE}",
                   criterion = "${CRITERION}",
                   etas = etas,
                   lambdas = lambdas)
write_tsv(cones, 'cones.tsv')