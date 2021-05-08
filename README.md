# CreditMetrics

[![CI](https://github.com/kasperrisager/CreditMetrics.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/kasperrisager/CreditMetrics.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/kasperrisager/CreditMetrics.jl/branch/master/graph/badge.svg?token=XAY2JOUIQI)](https://codecov.io/gh/kasperrisager/CreditMetrics.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://kasperrisager.github.io/CreditMetrics.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://kasperrisager.github.io/CreditMetrics.jl/dev)

Package for efficient simulation and analysis in the CreditMetrics model of
portfolio credit risk.

The package provides utilities for credit portfolio risk models where the migration between rating classes are governed by a Gaussian copula model. These models are often used by banks for credit risk Economic Capital models and the Incremental Risk Charge. This is in a sense more general than CreditMetrics, and a change of name is under consideration.

Focus is on providing high performance across the different model variations, and making the model specification abstract enough that it is also amenable to analytical approximations.

Examples of use can be found in the examples folder.

This package is very much in its infancy. It presently covers single-period calculations for individual counterparties, and documentation and unit test is lagging a little behind. The end goal is to have an industrial strength package that can be used by academics and practitioners alike, and be used immediately in models that require internal or regulatory approval.


