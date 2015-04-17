#===========================================================================
# plotImmuneAll.R
# All forms of immune cells and signals
#
# John Fors, UCSF
# Oct 6, 2014
#===========================================================================
tb_plot_immune <- function(info, immune) {

  # read immune data file
  with (immune, {

    # build data frames
    df1 <- data.frame(times, IL10, IL4, IFN, IL12L)
    colnames(df1) <- c("Day", "IL10", "IL4", "IFN", "IL12L")

    df2 <- data.frame(times, IL12LN)
    colnames(df2) <- c("Day", "IL12LN")

    df3 <- data.frame(times, MDC, IDC)
    colnames(df3) <- c("Day", "MDC", "IDC")

    df4 <- data.frame(times, T1, T2)
    colnames(df4) <- c("Day", "T1", "T2")

    df5 <- data.frame(times, Tp, TpLN)
    colnames(df5) <- c("Day", "Tp", "TpLN")

    df6 <- data.frame(times, TLN)
    colnames(df6) <- c("Day", "TLN")

    rText <- "Resist. OFF"
    if (info$isResistance>0) { rText <-"Resist. ON"}
    iText <- "Immune OFF"
    if (info$isImmuneKill>0) { iText <- "Immune ON"}
    gText <- "Gran. OFF"
    if (info$isGranuloma>0) { gText <- "Gran. ON"}
    subTitle <- paste(info$nPatients, " pts; ", info$doseText, "; ", rText, "; ", gText, "; ", iText, sep="")

    # generate plots
    # Cytokines in Lung (IL4, IL10, IL12L, IFN)
    mainTitle <- "Cytokines in Lung"
    pl1 <- tb_plot_immune_spec(df1, c("time", "IL4", "IL10", "IL12L", "IFN"), mainTitle, subTitle, "pg/mL", drugStart)

    # Cytokines in Lymph Node (IL12LN)
    mainTitle <- "Cytokines in Lymph Node (IL12LN)"
    pl2 <- tb_plot_immune_spec(df2, c("time", "IL12LN"), mainTitle, subTitle, "pg/mL", drugStart)

    # Dendritic Cells, (IDC and MDC)
    mainTitle <- "Dendritic Cells (IDC and MDC)"
    pl3 <- tb_plot_immune_spec(df3, c("time", "IDC", "MDC"), mainTitle, subTitle, "Cells/mL", drugStart)

    # T cells (T1, T2)
    mainTitle <- "T cells in Lung (T1, T2)"
    pl4 <- tb_plot_immune_spec(df4, c("time", "T1", "T2"), mainTitle, subTitle, "Cells/mL", drugStart)

    # T helper cells (Tp, TpLN)
    mainTitle <- "T cells in Lung (Tp, TpLN)"
    pl5 <- tb_plot_immune_spec(df5, c("time", "Tp", "TpLN"), mainTitle, subTitle, "Cells/mL", drugStart)

    # Naive T cells (TLN)
    mainTitle <- "Naive T cells in Lymph (TLN)"
    pl6 <- tb_plot_immune_spec(df6, c("time", "TLN"), mainTitle, subTitle, "Cells/mL", drugStart)

    return(list(
      cytokines_lung = pl1,
      cytokines_lymph = pl2,
      cytokines_dendr = pl3,
      t_cells_lung = pl4,
      t_helper = pl5,
      t_naive = pl6
      ))
  })

}
