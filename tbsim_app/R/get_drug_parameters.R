#' Read drug parameters
#'
#' @export
get_drug_parameters <- function(drug_id, type = "built-in", user = NULL) {
  descr <- list(
    name = "",
    KaMean = "mean absorption rate (oral)",
    KaStdv = "coefficient of variation of Ka",
    KeMean = "mean coefficient of elimination (total, single dose)",
    KeStdv=	"coefficient of variation of Ke",
    KeMult="auto-induction multiplier for Ke (maximum)",
    KeTime="time to reach max auto-induction level of Ke",
    V1Mean="mean effective volume (V/F)",
    V1Stdv="coefficient of variation of V1",
    highAcetFactor=	"multiplier factor of Ke for individuals with inherited traits",
    IOfactor=	"factor of drug concentration inside vs outside macrophages*",
    GRfactor=	"factor of drug concentration inside vs outside granuloma*",
    EC50k	= "EC50 (half maximal concentration) for bacterial killing",
    EC50g	= "EC50 (half maximal concentration) for bact. growth inhibition",
    ak = "Hill curve factor for bactericidal effects",
    ag =	"Hill curve factor for bacteriostatic effects",
    ECStdv =	"coefficient of variation for EC50k and EC50g parameters",
    mutationRate = "rate of mono-resistant bacterial mutation",
    kill_e0	= "extracellular bacterial kill rate before Drug Day 0",
    kill_e1	= "extracellular bacterial kill rate on Drug Day 0 to 2",
    kill_e2	= "extracellular bacterial kill rate on Drug Day 3 to 14",
    kill_e3	= "extracellular bacterial kill rate on Drug Day 15+	",
    kill_i0	= "intracellular kill rate before Drug Day 0",
    kill_i1	= "intracellular kill rate on Drug Day 0 to 2",
    kill_i2	= "intracellular kill rate on Drug Day 3 to 14",
    kill_i3	= "intracellular kill rate on Drug Day 15+",
    killIntra = "ability to kill intracellular bacteria",
    killExtra	= "ability to kill extracellular bacteria",
    growIntra	= "ability to inhibit intracellular bacterial growth",
    growExtra	= "ability to inhibit extracellular bacterial growth",
    factorFast = "Ke factor for individuals with rapid acetylation of IHN",
    factorSlow = "Ke factor for individuals with slow acetylation of IHN",
    multiplier = "multiplier for drug concentration inside vs. outside granuloma**",
    rise50 = "half time for drug diffusion into granuloma**",
    fall50 = "half time for drug diffusion out from granuloma**",
    decayFactor =	"rate of drug concentration decay from inside macrophages**"
  )
  units <- list(
    name = "",
    KaMean = "1/hr",
    KaStdv	=	"",
    KeMean= "1/hr",
    KeStdv=	"",
    KeMult= "",
    KeTime= "days",
    V1Mean= "L",
    V1Stdv= "",
    highAcetFactor=	"",
    IOfactor=	"",
    GRfactor=	"",
    EC50k	= "mg/L",
    EC50g	= "mg/L",
    ak = "",
    ag =	"",
    ECStdv =	"",
    mutationRate = "1/hr",
    kill_e0	=  "1/hr",
    kill_e1	= "1/hr",
    kill_e2	= "1/hr",
    kill_e3	= "1/hr",
    kill_i0	="1/hr",
    kill_i1	= "1/hr",
    kill_i2	= "1/hr",
    kill_i3	="1/hr",
    killIntra = "true/false",
    killExtra	= "true/false",
    growIntra	= "true/false",
    growExtra	= "true/false",
    factorFast = "",
    factorSlow =  "",
    multiplier = "",
    rise50 = "hr",
    fall50 =  "hr",
    decayFactor =	"1/hr"
  )
  if(!is.null(user)) {
    dat <- data.frame(parameter = c(), value = c())
    if(is.null(drug_id) || length(drug_id) == 0) {
    } else {
      if(type == "built-in") {
        folder <- paste0(system.file(package="TBsim"), "/config")
      } else {
        folder <- paste0("/data/tbsim/", user, "/drugs")
      }
      file <- paste0(drug_id, ".txt")
      if(file.exists(paste0(folder, "/", file))) {
        info <- tb_read_init(
          folder = folder,
          file = file
        )
        dat <- data.frame(
            parameter = as.character(names(info)),
            value = as.character(unlist(info)),
          row.names = NULL)
        dat$description <- descr[as.character(dat$parameter)]
        dat$unit <- units[as.character(dat$parameter)]
      }
    }
    dat <- dat[dat$parameter != "folder",]
    return(dat)
  }
}
