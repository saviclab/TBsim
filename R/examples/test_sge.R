tb_run_sim (sim1, jobscheduler = TRUE)
sge$qstat(filter = list(name = "run100.mod", state="qw"),
          exact = TRUE)
