% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tuning_oracle.R
\name{oracle_tune_screeningtau}
\alias{oracle_tune_screeningtau}
\title{Tune screening tau for high dimensional infeasible (oracle)}
\usage{
oracle_tune_screeningtau(X, y, lambda, partition, factor = 1/4)
}
\arguments{
\item{X}{\code{n} by \code{d} matrix}

\item{y}{length \code{n} vector}

\item{lambda}{numeric}

\item{partition}{vector with values between 0 and 1}

\item{factor}{numeric}
}
\value{
numeric
}
\description{
Tune screening tau for high dimensional infeasible (oracle)
}
