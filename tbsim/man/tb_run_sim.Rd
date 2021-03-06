% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tb_run_sim.R
\name{tb_run_sim}
\alias{tb_run_sim}
\title{Run TBsim simulation}
\usage{
tb_run_sim(sim = NULL, bin = "TBsim", keep_bin = FALSE, run = TRUE,
  jobscheduler = FALSE, queue = "main.q", results_folder = "/data/tbsim",
  custom_drugs_folder = "/data/tbsim/drugs", submit_cmd = "qsub")
}
\arguments{
\item{sim}{sim simulation definition}

\item{bin}{binary file}

\item{keep_bin}{keep binary file after execution}

\item{run}{run the simulation?}

\item{jobscheduler}{submit to job scheduler?}

\item{submit_cmd}{job scheduler submit command to prepend}
}
\description{
Run TBsim simulation
}
