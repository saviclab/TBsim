

tb_write_init <- function (obj,
                           folder = "",
                           type = "drug",
                           file = NULL) {
  if (!is.null(file)) {
    fname <- paste(folder, "/", file, sep="")
  } else {
    fname <- paste(folder, "/",type, ".txt", sep="")
  }
  txt <- c()
  if (type == "init") {
    drugs <- obj$drugs
    therapy <- obj$therapy
    obj$drugs <- NULL
    obj$therapy <- NULL
    obj$nDrugs <- length(drugs)
    obj$nTherapy <- length(therapy)
  }
  if (type == "therapy") {
    regimen <- obj$regimen
    obj$regimen <- NULL
    obj$nRecords <- length(regimen[,1])
    fname <- paste(folder, "/", obj$name, ".txt", sep="")
  }
  if (type == "drug") {
    fname <- paste(folder, "/", obj$name, ".txt", sep="")
  }
  if (type == "adherence") {
  }
  for (i in seq(obj)) {
    txt <- c(txt, paste("<", names(obj)[i], ">", obj[i], sep=""))
  }
  if (type == "init") {
    for (i in seq(drugs)) {
      txt <- c(txt, paste("<drugFile>", paste(drugs[[i]]$name,".txt", sep=""), sep=""))
    }
    for (i in seq(therapy)) {
      txt <- c(txt, paste("<therapyFile>", paste(therapy[[i]]$name, ".txt", sep=""), sep=""))
    }
  }
  if (type == "therapy") {
    for (i in seq(regimen[,1])) {
      txt <- c(txt, paste("<drug>", paste(unlist(regimen[i,]), collapse='|'), '|', sep=""))
    }
  }
  if (length(txt)>0) {
    conn <- file(fname)
    writeLines(text = txt, conn)
    close(conn)
  }
}

tb_create_adherence <- function () { # create adherence object
  adh <- list()
  return (adh)
}

tb_create_therapy <- function ( # create therapy object
  predefined = NULL, # choose from predefined: standard, no_drugs,
  name = "ther",
  description = "",
  regimen = NULL) {
  def <- list()
  def$standard <- list (name = "standard",
                        description = "R600/I300/P1500 x 2mo + R600/I300 x 4mo",
                        regimen = data.frame(
                          rbind(c("RIF", 600, 180, 240, 1), # drug / dose / t_start (days) / t_stop / ?
                                c("RIF", 600, 241, 360, 1),
                                c("INH", 300, 180, 240, 1),
                                c("INH", 300, 241, 360, 1),
                                c("PZA", 1500, 180, 240, 1))) )
  def$lowDrugs <-  list (name = "subther",
                         description = "R600/I300 x 2mo + R300 x 4mo",
                         regimen = data.frame(
                           rbind(c("RIF", 600, 180, 240, 1),
                                 c("RIF", 300, 241, 360, 1),
                                 c("INH", 300, 180, 240, 1))) )
  def$highDoseRIF <-  list (name = "high_rif",
                            description = "R1200/I300 x 2mo + R600/I300 x 4mo",
                            regimen = data.frame(rbind(c("RIF", 1200, 180, 240, 1),
                                                       c("RIF", 600, 241, 360, 1),
                                                       c("INH", 300, 180, 240, 1),
                                                       c("INH", 300, 241, 360, 1))) )
  def$weeklyRPT <-  list (name = "rif_weekly",
                          description = "RPT600w/I300/P1500 x 2mo + RPT600w/I300 x 4mo",
                          regimen = data.frame(
                            rbind(c("RPT", 600, 180, 240, 1),
                                  c("RPT", 600, 241, 360, 1),
                                  c("INH", 300, 180, 240, 1),
                                  c("INH", 300, 241, 360, 1),
                                  c("PZA", 1500, 180, 240, 1))) )
  def$noDrugs <-  list (name = "no_drug",
                        description = "No drug",
                        regimen = data.frame() )

  if (!is.null(predefined)) {
    if (predefined %in% names(def)) {
      therapy <- def[[predefined]]
    } else {
      cat (paste("Error: predefined therapy", predefined, "not found!\nChoose from: [", paste(names(def), collapse=' '),"]\n"))
      return(0)
    }
  } else {
    therapy <- as.list(args(tb_create_therapy))
  }
  upd <- as.list(match.call())[-1]
  for (i in seq(upd)) {
    therapy[[names(upd)[i]]] <- upd[[i]]
  }
  colnames(therapy$regimen) <- c("drug", "dose", "t_start", "t_stop", "use")
  return (therapy[-length(therapy)])
}

tb_create_drug <- function ( # create drug object
  name = "RIF",
  predefined = NULL, # choose from predefined: RIF / RPT / PZA / INH
  KaMean = 1.51,KaStdv= 0.73,
  KeMean = 0.2,KeStdv = 0.28,
  V1Mean = 56.1, V1Stdv= 0.22,
  KeMult = 2.02, KeTime = 14.0,
  highAcetFactor = 1.0, IOfactor = 4.0,
  EC50k = 7.6, EC50g = 1.9,
  ak = 1.2, ag = 0.36, ECStdv = 0.05,
  mutationRate = 8.33e-12,
  kill_e0 = 0.0, kill_e1 = 0.5, kill_e2 = 0.5, kill_e3 = 0.4,
  kill_i0 = 0.0, kill_i1 = 0.5, kill_i2 = 0.5, kill_i3 = 0.4,
  killIntra = 1, killExtra = 1,
  growIntra = 1, growExtra = 1,
  persisting = 0) {
  def <- list()
  def$RIF <- list (name = "RIF",
                   KaMean = 1.51, KaStdv= 0.73,
                   KeMean = 0.2, KeStdv = 0.28,
                   V1Mean = 56.1, V1Stdv= 0.22,
                   KeMult = 2.02, KeTime = 14.0,
                   highAcetFactor = 1.0, IOfactor = 4.0,
                   EC50k = 7.6, EC50g = 1.9,
                   ak = 1.2, ag = 0.36, ECStdv = 0.05,
                   mutationRate = 8.33e-12,
                   kill_e0 = 0.0, kill_e1 = 0.5, kill_e2 = 0.5, kill_e3 = 0.4,
                   kill_i0 = 0.0, kill_i1 = 0.5, kill_i2 = 0.5, kill_i3 = 0.4,
                   killIntra = 1, killExtra = 1,
                   growIntra = 1, growExtra = 1,
                   persisting = 0)
  def$RPT <- list (name = "RPT",
                   KaMean = 1.61, KaStdv= 0.13,
                   KeMean = 0.05, KeStdv = 0.2,
                   V1Mean = 60.6, V1Stdv= 0.13,
                   KeMult = 2.0, KeTime = 14.0,
                   highAcetFactor = 1.0, IOfactor = 24.0,
                   EC50k = 7.6, EC50g = 0.5,
                   ak = 1.2, ag = 0.36, ECStdv = 0.05,
                   mutationRate = 8.33e-12,
                   kill_e0 = 0.0, kill_e1 = 0.75, kill_e2 = 0.75, kill_e3 = 0.6,
                   kill_i0 = 0.0, kill_i1 = 0.75, kill_i2 = 0.75, kill_i3 = 0.6,
                   killIntra = 1, killExtra = 1,
                   growIntra = 1, growExtra = 1,
                   persisting = 0)
  def$INH <- list (name = "INH",
                   KaMean = 2.28, KaStdv= 0.58,
                   KeMean = 0.26, KeStdv = 0.2,
                   V1Mean = 79, V1Stdv= 0.11,
                   KeMult = 1.0, KeTime = 1.0,
                   highAcetFactor = 2.07, IOfactor = 0.0,
                   EC50k = 0.062, EC50g = 100000,
                   ak = 1.1, ag = 1.0, ECStdv = 0.05,
                   mutationRate = 8.33e-10,
                   kill_e0 = 0.0, kill_e1 = 0.7, kill_e2 = 0.4, kill_e3 = 0.2,
                   kill_i0 = 0.0, kill_i1 = 0.0, kill_i2 = 0.0, kill_i3 = 0.0,
                   killIntra = 0, killExtra = 1,
                   growIntra = 0, growExtra = 0,
                   persisting = 0)
  def$PZA <- list (name = "PZA",
                   KaMean = 3.56, KaStdv= 0.52,
                   KeMean = 0.07, KeStdv = 0.14,
                   V1Mean = 35.0, V1Stdv= 0.1,
                   KeMult = 1.0, KeTime = 1.0,
                   highAcetFactor = 1.0, IOfactor = 1.1,
                   EC50k = 100, EC50g = 50,
                   ak = 1.1, ag = 0.5, ECStdv = 0.05,
                   mutationRate = 4.1667e-8,
                   kill_e0 = 0.0, kill_e1 = 0.0, kill_e2 = 0.1, kill_e3 = 0.1,
                   kill_i0 = 0.0, kill_i1 = 0.0, kill_i2 = 0.1, kill_i3 = 0.1,
                   killIntra = 1, killExtra = 1,
                   growIntra = 1, growExtra = 1,
                   persisting = 1)
  if (!is.null(predefined)) {
    if (predefined %in% names(def)) {
      drug <- def[[predefined]]
    } else {
      cat (paste("Error: predefined drug", predefined, "not found!\nChoose from: [", paste(names(def), collapse=' '),"]\n"))
      return()
    }
  } else {
    drug <- as.list(args(tb_create_drug))
  }
  upd <- as.list(match.call())[-1]
  for (i in seq(upd)) {
    drug[[names(upd)[i]]] <- upd[[i]]
  }
  return (drug[-length(drug)])
}

tb_create_init <- function ( # create init object
  nTime = 600,
  nPatients = 10,
  disease = 5,
  kMax = 24,
  isCalcMa = 1,
  isResistance = 1,
  isImmuneKill = 1,
  persistTime = 7,
  folder = "",
  initialValueStdv = 0.20,
  parameterStdv = 0.2,
  timeStepStdv = 0.05,
  adherenceMean = 0.99,
  adherenceStdv = 0.001,
  adherenceStdvDay = 0.1,
  defaultTherapy = 0,
  drugs = NULL,
  therapy = NULL) {
  init <- as.list(args(tb_create_init))
  upd <- as.list(match.call())[-1]
  for (i in seq(names(upd))) {
    init[[names(upd)[i]]] <- upd[[names(upd)[i]]]
  }
  if (!is.null(drugs)) {
    init$drugs <- drugs
  }
  if (!is.null(therapy)) {
    init$therapy <- therapy
  }
  init$folder <- paste(init$folder, "/output/", sep="")
  return (init[-length(init)])
}

tb_write_init_files <- function ( # create a folder with the initialization files and an output folder
  init = NULL,
  force = FALSE
) {
  ## create folder structure
  folder <- gsub("/output/$","", init$folder)
  sim <- list(folder = folder)

  if (!file.exists(folder)) {
    dir.create(folder)
  } else {
    if (!force) {
      cat ("Warning: specified folder already exists (use 'force = TRUE' to override).\n")
    }
  }
  if (file.exists(folder)) {
    conf_folder <- paste(folder,"/config", sep="")
    out_folder <- paste(folder,"/output", sep="")
    if (!file.exists(conf_folder)) { dir.create(conf_folder) }
    if (!file.exists(out_folder)) { dir.create(out_folder) }
  } else {
    cat("Error: could not create specified folder\n")
    return()
  }

  ## write init files
  tb_write_init(init, type="init", folder=paste(folder,"/config", sep=""))
  drugs   <- init$drugs
  therapy <- init$therapy
  for (i in seq(drugs)) {
    tb_write_init(drugs[[i]], type="drug", folder=paste(folder,"/config", sep=""))
  }
  for (i in seq(therapy)) {
    tb_write_init(therapy[[i]], type="therapy", folder=paste(folder,"/config", sep=""))
  }
  ## tb_write_init(adherence, type="adherence", folder=paste(init$folder,"/config", sep=""))

  return (sim)
}

tb_sim <- function ( # start a simulation
  sim = NULL,
  bin_path = "",
  verbose) {
  args <- paste("--init init.txt --init_folder ", sim$folder, "/config/", sep="")
  if (verbose) {
    args <- paste(args, "--verbose")
  }
  ## some checks
  if (!(file.exists(sim$folder) & sim$folder != "")) {
    cat ("Error: folder does not exist!\n")
    return()
  }
  if (Sys.info()['sysname'] == 'Windows') {
    shell.exec(paste("tbsim", args))
  }
  else if (Sys.info()['sysname'] == 'Darwin') {
    if (bin_path == "") { bin_path <- "." }
    system(paste(bin_path,"/tbsim ", args, sep=""))
  } else {
    if (bin_path == "") { bin_path <- "." }
    system(paste (bin_path,"/tbsim ", args, sep=""))
  }
}

# ## Functions for importing results
# tb_read_results <- function (obj = NULL, folder = "") {
#     if (!is.null(obj)) {
#         folder <- obj$folder
#     }
#     out_folder <- paste(obj$folder, "/output", sep="")
# #    conc <- dir(out_folder, "conc")
# #    tab <- readLines(paste(out_folder, "/", conc[1], sep=""))
#
#     be_files <- dir(out_folder, "Be_")
#     tab <- read.table(file=paste(out_folder, "/", be_files[1], sep="")
# }

## Plotting functions
