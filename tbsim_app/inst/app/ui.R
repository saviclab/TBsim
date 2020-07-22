
library(shiny)
library(shinydashboard)
library(shinythemes)
library(shinyTable)
library(shinyBS)
library(shinyjs)

insertElement <- function(file) {
  file <- paste0("./elements/", file, ".html")
  txt <- readChar(file, nchars=file.info(file)$size)
  html <- HTML(txt)
  return(html)
}

shinyUI(
  # Sidebar with a slider input for number of bins
  dashboardPage(skin = "green", # green is modified to match InsightRX corporate style
    dashboardHeader(
      title =
        HTML("TBsim")
        #HTML("<img height=20 align='left' style='margin-top: 15px' src='images/ucsf-logo-white.png'></img>&nbsp;"),
        #tags$li(class='dropdown',
        #  googleAuthUI(id = "loginButton")
        #)
    ),
    dashboardSidebar(
      sidebarMenu(
        menuItem("About", tabName = "tabAbout",selected=TRUE),
        menuItem("Single patient", tabName = "tabSimSingle", selected=FALSE),
        menuItem("Populations", tabName = "tabSimPopulation"),
        menuItem("Drugs", tabName = "tabDrugsLibrary"),
        menuItem("Documentation", tabName = "tabDocumentation",
          menuSubItem("QSP model structure", tabName="tabModelStructure"),
          menuSubItem("TB regimens", tabName="tabDrugRegimenDoc")
        ),
        menuItem("Source Code", icon = icon("github"), href = "https://github.com/saviclab/TBsim"),
        #menuItem(htmlOutput("userInfo", inline=TRUE), tabName = "userInfo", icon = icon("user")),
        div(class="float-disclaimer",
          tags$head(tags$link(rel="shortcut icon", href="favicon.ico")),
          p("© UCSF 2017")
        )
      )
    ),
    dashboardBody(
      useShinyjs(),
      tags$head(
        tags$script(src = "message-handler.js"),
        tags$script(src = "sweetalert.min.js"),
        tags$script(src = "custom.js"),
        tags$link(rel = "stylesheet", type = "text/css", href = "sweetalert.css"),
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),

      ## hidden elements for Client-->Server messaging
      HTML('<input type="text" id="single_selected_id" name="single_selected_id" style="display: none;">'),
      HTML('<input type="text" id="population_selected_id" name="population_selected_id" style="display: none;">'),
      bsModal("editSimSettingsModal", "Simulation settings", trigger = "editSimSettings", size = "large",
        tabsetPanel(
          tabPanel(title = "Bacteria",
            fluidRow(
              column(width=6,
                textInput("bactThreshold", "Bacterial threshold", value = 1),
                textInput("bactThresholdRes", "Bacterial threshold (resistant)", value = 1),
                textInput("growthLimit", "Growth limit", value = 0.01),
                textInput("resistanceRatio", "Resistance ratio", value = 5.0e-10),
                textInput("resistanceFitness", "Resistance fitness", value = 0.8),
                textInput("isPersistance", "Persistance status: ", value = 0),
                textInput("persistTime", "Time span for persistance status (days)", value = 7),
                checkboxInput("isClearResist", "Clear resistant bacteria", FALSE)
              ),
              column(width=6,
                textInput("freeBactLevel", "Free bacteria level (CFU/mL)", value = 1),
                textInput("latentBactLevel", "Latent bacteria level (CFU/mL)", value = 1000),
                textInput("infI", "Initial bacterial load population 1 (CFU/mL)", value = 100),
                textInput("infII", "Initial bacterial load population 2 (CFU/mL)", value = 0),
                textInput("infIII", "Initial bacterial load poplation 3 (CFU/mL)", value = 0),
                textInput("infIV", "Initial bacterial load population 4 (CFU/mL)", value = 0)
              )
            )
          ),
          tabPanel(title = "Immune system",
            fluidRow(
              column(width=6,
                checkboxInput("isGranuloma", "Granuloma", TRUE),
                checkboxInput("isGranImmuneKill", "Granuloma immune kill", FALSE),
                checkboxInput("isGranulomaInfec", "Granuloma infection", TRUE),
                checkboxInput("isGradualDiffusion", "Gradual diffusion", TRUE)
              ),
              column(width=6,
                textInput("immuneMean", "Immune system mean", value = 1),
                textInput("immuneStdv", "Immune system CV", value = 0.001)
              )
            )
          ),
          tabPanel(title = "Variability",
            fluidRow(
              column(width=6,
                textInput("initialValueStdv", "Initial values CV", value = 0.20),
                textInput("parameterStdv", "Parameters CV", value = 0.20)
              )
            )
          ),
          tabPanel(title = "Simulations",
              textInput("therapyStart", "Timepoint for drug administration start", value = 180),
              textInput("nTime", "Total length of simulation", value = 365),
              textInput("nPopulations", "Number of populations", value = 1),
              textInput("simSeed", "Seed", value = 12345)
              # textInput("nIterations", "Number of iterations", value = 100)
            )
          )
      ),
      bsModal("editAdherenceModal", "Adherence settings", trigger = "editAdherenceSingle",
            fluidRow(
              column(width=12,
                selectInput( "adherenceType", "Adherence type", choices = c("Full", "MEMS", "Random draw", "Switched"), selected = "Full")
              )
            ),
            fluidRow(
              conditionalPanel(
                condition = "input.adherenceType == 'Switched'",
                column(width=4,
                  selectInput("adherenceType1", "Adherence intensive period", choices = c("Full", "Random draw"), selected = "Full")
                ),
                column(width=4,
                  selectInput("adherenceType2", "Adherence continuation period", choices = c("Full", "Random draw"), selected = "Full")
                ),
                column(width=4,
                  textInput("adherenceSwitchDay", "Day for switch adherence type", value = 240)
                )
              )
            ),
            fluidRow(
              conditionalPanel(
                condition = "input.adherenceType == 'Random draw' || (input.adherenceType == 'Switched' && (input.adherenceType1 == 'Random draw' || input.adherenceType2 == 'Random draw'))",
                column(width=4,
                  textInput("adherenceMean", "Mean population adherence", value = 1.0)
                ),
                column(width=4,
                  textInput("adherenceStdv", "Adherence SD", value = 0.0001)
                ),
                column(width=4,
                  textInput("adherenceStdvDay", "Adherence per day SD", value = 0.0001)
                )
              )
            ),
            fluidRow(
              conditionalPanel(
                condition = "input.adherenceType == 'MEMS'",
                column(width=6,
                  selectInput("useMemsFile", "Use MEMS datafile", choices = c("None uploaded yet"), selected = "None uploaded yet")
                ),
                column(width=6,
                  fileInput('memsFile', 'Upload new MEMS File',
                  accept=c('text/csv',
    								 'text/comma-separated-values,text/plain',
    								 '.csv'))
                ),
                conditionalPanel(
                  condition = "window.globals.mems_file_parsing == 1",
                  column(6),
                  column(6,
                    helpText("Parsing MEMS data... ")
                  )
                )
              )
          )
      ),
      bsModal("editDrugRegimenModal", "Edit drug regimen", trigger = "editDrugRegimensSingle", size = "large",
        div(
          p('Please create and customize new drug regimens below.',
            'To add addtional periods of drug treatment, right-click on the table and select "Add new row".')
        ),
        br(),
        div(id = "editRegimenTableDiv",
          textInput("editRegimenNewDescription", "Description", value = "Custom regimen #1"),
          br(),
          rHandsontableOutput("editRegimenTable", width='100%'),
          br()
        ),
        hr(),
        div(width='100%',
          actionButton("editRegimenCancel", "Cancel", icon=icon("remove"), width="33%"),
          actionButton("editRegimenReset", "Reset",  icon=icon("trash"), width="33%"),
          actionButton("editRegimenSaveAsNew", "Save regimen",  icon=icon("save"),width="33%")
        )
      ),
      bsModal("newDrugModal", "New drug", trigger = "newDrug",
        textInput("newDrugAbbr", "Abbreviation"),
        textInput("newDrugName", "Drug name"),
        selectInput("selectNewDrugTemplate", "Duplicate from:", names(drugDefinitions)),
        actionButton("saveNewDrug", "Save", icon = icon("save"))
      ),
      tabItems(
        tabItem(
          tabName = "tabAbout",
          fluidRow(
            box(
              width = 8,
              status = "primary",
              title = "Welcome",
              p("Welcome to the UCSF TBsim tool developed by Savic Labs in support of the CPTR program funded by the Bill and Melinda Gates Foundation. This tool allows simulations of the timecourse of drug concentrations, drug actions, bacterial dynamics, and host response during drug treatment of TB. All simulations are based on a quantitative systems pharmacology (QSP) model based on data from non-clinical and clinical trials and literature."),
              p("Some notes on use of this app:"),
              tags$ul(
                tags$li("Interfaces for either basic or advanced usage are provided, which can be switched at any time from the selector in the top-right corner. The 'Advanced' mode allows any setting to be altered, e.g. any of the QSP model parameters and all drug sensitivity and pharacokinetic parameters. The 'Basic' interface allows for more simple investigations, with standard drug regimens."),
                tags$li("Various existing standard-of-care drug regimens are included, while the user can also create custom regimens to evaluate their predicted outcome."),
                tags$li("The dashboard for population simulations allows simulations for multiple patients and to calculate expected outcome. Since population simulations are computationally intensive, these analyses are submitted to a job queue. We kindly request you to login via Google to use this functionality. ")
              ),
              br(),
              tags$b(tags$i("Please note that this tool is a research tool for TB experts. Do not use this tool to inform individual treatment decisions.")),
              br(),
              br(),
              fluidRow(
                column(width = 3, align='center',
                  HTML("<img height=25 align='center' style='margin-top: 15px; margin-right: 25px;' src='images/ucsf_grey.png'></img>&nbsp;")
                ),
                column(width = 3, align='center',
                  HTML("<img height=28 align='center' style='margin-top: 15px; margin-right: 25px;' src='images/cptr_grey.png'></img>&nbsp;")
                ),
                column(width = 3, align='center',
                  HTML("<img height=25 align='center' style='margin-top: 15px; margin-right: 25px;' src='images/bmgf_grey.png'></img>&nbsp;")
                ),
                column(width = 3, align='center',
                  HTML("<img height=25 align='center' style='margin-top: 15px; margin-right: 25px;' src='images/insightrx_grey.png'></img>&nbsp;")
                )
              ),
              br()
            ),
            box(
              width = 4,
              status = "primary",
              title = "Contact",
              p("Please contact us at tbsim@ucsf.edu for more more information about this tool.")
            )
          )
        ),
        tabItem(tabName = "tabSimSingle",
          fluidRow(
              conditionalPanel(
                condition = "!window.globals.single_plots_available",
                box(
                  width = 8,
                  status= "primary",
                  title="Single patient simulation",
                  p("Simulations for single patients should not be used for research purposes. They are solely meant for illustrative purposes, i.e. to gain deeper understanding of the underlying QSP model."),
                  p("Please select regimen and settings for simulation from the panel on the right, and start simulation."),
                  br()
                )
              ),
              conditionalPanel(
                condition = "window.globals.single_plots_available == 2",
                box(
                  width = 8,
                  status = "info",
                  title = NULL,
                  HTML("<center><img style='margin: 100px' src='images/spinner.gif'></img></center>")
                )
              ),
              conditionalPanel(
                condition = "window.globals.single_plots_available == 1",
                tabBox(
                  width = 8,
                  title = "",
                  tabPanel("PK",
                     value = "singlePharmacokineticsTab",
                     splitLayout(cellWidths = c("49%", "49%"),
                       plotOutput("plotDose", height="170px"),
                       plotOutput("plotAdherence", height="170px")
                     ),
                     br(),
                     div(
                       id='divTimeSlider',
                       sliderInput("pkTimeSliderSingle", "Show concentration profiles for week #:", min = 1, max = 26, value = 0, step = 1, width="100%")
                     ),
                     plotOutput("plotPK", height="450px")
                  ),
                  tabPanel("Bacterial load",
                     wellPanel(
                       p("Plots of bacterial load, total (upper plot) and split by physiological compartment (lower plots). The grey area indicates the drug treatment period.")
                     ),
                     plotOutput("plotBact", height="300px"),
                     plotOutput("plotBactSplit", height="300px")
                  ),
                  #tabPanel("Resistance",
                  #   wellPanel(
                  #     p("The plots below show the bacterial resistance dynamics for the various drugs used in the regimen. The total number of resistant bacteria per drug is shown below. The grey area indicates the drug treatment period.")
                  #   ),
                  #   plotOutput("plotBactRes", height="300px"),
                  #   wellPanel(
                  #     p("The plot below shows the resistant bacteria per drug, split by physiological site.")
                  #   ),
                  #   plotOutput("plotBactResSplit", height="300px")
                  #  #  p(class='info-text', "Resistant populations < 1 CFU/mL are shown as 1 CFU/mL.")
                  #),
                  tabPanel("Bactericidal effect",
                     wellPanel(
                       p("The relative bactericidal effect shown in the plot below indicates the relative bacterical kill rate the drugs and immune system achieve (the total is always 100%). Please note that the absolute kill rate of bacteria (in terms of CFU/mL) will also depend on the the absolute number of bacteria present at that timepoint."),
                       p("The grey area indicates the drug treatment period.")
                     ),
                     plotOutput("plotEffect", height="300px"),
                     wellPanel(
                       p("EC50 kill factor shown below indicates the relative bacterical kill rate the drug achieves compared to the maximal kill the drug can achieve at high concentration of the drug.")
                     ),
                     plotOutput("plotKill", height="350px")
                  ),
                  tabPanel("Immune system", id = "immune_panel_single",
                      wellPanel(
                        p("The plots below show various regulating cells and factors in the immune system. The plots also show the infection phase (t < 0) included in the simulation, the dashed line indicates drug treatment start (t = 0)."),
                        p("The grey area indicates the drug treatment period.")
                      ),
                      splitLayout(cellWidths = c("49%", "49%"),
                        plotOutput("plotImmuneCytoLung", height="250px"),
                        plotOutput("plotImmuneTLung", height="250px")
                      ),
                      splitLayout(cellWidths = c("49%", "49%"),
                        plotOutput("plotImmuneCytoLymph", height="250px"),
                        plotOutput("plotImmuneTHelper", height="250px")
                      ),
                      splitLayout(cellWidths = c("49%", "49%"),
                        plotOutput("plotImmuneCytoDendr", height="250px"),
                        plotOutput("plotImmuneTNaive", height="250px")
                      )
                  ),
                  tabPanel(" ", icon=icon("list"),
                    br(),
                    wellPanel(
                      p("Below are the settings that were used for this simulation.")
                    ),
                    tableOutput("simTherapy"),
                    tableOutput("simSummary")
                  )
                )
              ),
              tabBox(
                width = 4,
                title = "",
                tabPanel(
                  "Sim",
                   value = "singleSimSettingsTab",
                   fluidRow(
                     column(
                       width=12,
                       br(),
                       actionButton("simRefreshSingle", "Start simulation", icon=icon('play'), width = "80%"),
                       actionButton("simResetSingle", "", icon=icon("trash"), width="18%"),
                       hr(),
                       textInput("singleRunDescription", "Simulation description: "),
                       div(style="display: inline-block;vertical-align:top; width: 71%;",
                         selectInput("drugRegimenSingle", "Regimen: ", names(regimenList))
                       ),
                       div(style="display: inline-block;vertical-align:top; width: 28%; padding-top: 24px",
                         actionButton("editDrugRegimensSingle", "", icon=icon("pencil"), class="narrow"),
                         actionButton("duplicateDrugRegimensSingle", "", icon=icon("copy"), class="narrow"),
                         actionButton("deleteDrugRegimensSingle", "", icon=icon("trash"), class="narrow")
                       ),
                       p("To change the default regimens, please duplicate the regimen first.", class='help'),
                       tags$hr(),
                       tabsetPanel(
                         tabPanel(
                           "Basic settings",
                           selectInput("patientTypeSingle", "Patient type: ", c("Typical", "Random"), width='98%'),
                           p("'Typical' patient: using population parameters; 'Random': parameters drawn from distributions.", class='help')
                         ),
                         tabPanel(
                           "Advanced settings",
                           value = "singleAdvancedTab",
                           actionButton("editSimSettings", "Simulation settings", width="49%"),
                           actionButton("editAdherenceSingle", "Adherence settings", width="49%"),
                           hr(),
                           selectInput("isImmuneKillSingle", "Killing by immune system: ", c("Yes", "No"), width='98%'),
                           selectInput("isResistanceSingle", "Can bacterial develop resistance: ", c("Yes", "No"), width='98%')
                         )
                       )
                     )
                   )
                 ),
                tabPanel(
                  "Output (0)",
                   value = "singleResultsTab",
                   fluidRow(
                      column(
                         width = 12,
                         br(),
                         tabPanel(
                           title="",
                           actionButton("singlePatientLoadResults", "Show results", icon=icon("arrow-left"), width="50%"),
                           actionButton("singlePatientRefreshResults", " ", icon=icon("refresh"), width="10%"),
                           actionButton("singlePatientDeleteResults", " ", icon=icon("trash"), width="10%"),
                           downloadButtonPDF("reportSingle", "PDF"),
                           downloadButtonData("downloadDataSingle", "")
                         ),
                         br(),
                         DT::dataTableOutput("singlePatientResultsTable"),
                         br(),
                         conditionalPanel(
                           condition="$('#loginButton-googleAuthUi > a').hasClass('btn-default') === false",
                           p(class="info-text", "Results will only be stored for the current session. If you want to store results persistently, please log in with your Google account.")
                         )
                      )
                   )
                )
              )
          )
        ),
        tabItem(tabName = "tabSimPopulation",
            fluidRow(
              conditionalPanel(
                condition = "!window.globals.population_plots_available",
                box(
                  width = 8,
                  status= "primary",
                  title="Population simulation",
                  p("Please select regimen and settings for the population simulation from the panel on the right, and start simulation or submit to queue."),
                  br()
                )
              ),
              conditionalPanel(
                condition = "window.globals.population_plots_available == 2",
                box(
                  width = 8,
                  status = "info",
                  title = NULL,
                  HTML("<center><img style='margin: 100px' src='images/spinner.gif'></img></center>")
                )
              ),
              conditionalPanel(
                condition="window.globals.population_plots_available == 1",
                tabBox(
                     width = 8,
                     title = "",
                     tabPanel("Outcome ",
                        value = "popOutcomeTab",
                        fluidRow(
                          column(
                            width = 12,
                            conditionalPanel(
                              condition="globals.population_quick_sim == 1",
                              wellPanel(
                                p("Note: this simulation was performed in fast mode, so only outcome data is available. For recording data on PK, bacterial load, and immunology, please switch off fast mode.")
                              )
                            ),
                            textOutput('outcome'),
                            conditionalPanel(
                              condition="globals.population_bootstrap == 1",
                              textOutput('outcome_ci')
                            ),
                            plotOutput("plotOutcome", height="260px"),
                            br(),
                            p("'Cleared TB' is defined as the percentage of patients in which the bacterial outside of granulomas is lower than a given treshold (default = 1 CFU/mL, but customizable using <freeBactLevel> parameter).", class='help'),
                            conditionalPanel(
                              condition="globals.population_bootstrap == 1",
                              p("The shaded ribbon around the median outcome represents the 95% confidence interval of the median.", class='help')
                            )
                          )
                        )
                     ),
                     tabPanel("PK",
                        value = 'popPharmacokineticsTab',
                        splitLayout(cellWidths = c("49%", "49%"),
                          plotOutput("plotDosePop", height="170px"),
                          plotOutput("plotAdherencePop", height="170px")
                        ),
                        conditionalPanel(
                          condition="globals.population_quick_sim == 0",
                          div(
                            id='divTimeSliderPop',
                            sliderInput("pkTimeSliderPop", "Show concentration profiles for week #:", min = 1, max = 26, value = 0, step = 1, width="100%")
                          )
                        ),
                        plotOutput("plotPKPop", height="450px")
                     ),
                     tabPanel("Bacterial load",
                        value = 'popBacterialLoadTab',
                        plotOutput("plotBactPop", height="200px"),
                        plotOutput("plotBactSplitPop", height="300px")
                     ),
                     #tabPanel("Resistance",
                     #   value = 'popResistanceTab',
                     #   wellPanel(
                     #     p("The plots below show the bacterial resistance dynamics for the various drugs used in the regimen. The total number of resistant bacteria per drug is shown below."),
                     #     p("The grey area indicates the drug treatment period.")
                     #   ),
                     #   plotOutput("plotBactResPop", height="200px"),
                     #   wellPanel(
                     #     p("The plot below shows the resistant bacteria per drug, split by physiological site.")
                     #   ),
                     #   plotOutput("plotBactResSplitPop", height="300px")
                     #),
                     tabPanel("Bactericidal effect",
                        value = 'popEffectTab',
                        wellPanel(
                          p("The relative bactericidal effect shown in the plot below indicates the relative bacterical kill rate the drugs and immune system achieve (the total is always 100%). Please note that the absolute kill rate of bacteria (in terms of CFU/mL) will also depend on the the absolute number of bacteria present at that timepoint."),
                          p("The grey area indicates the drug treatment period.")
                        ),
                        plotOutput("plotEffectPop", height="300px"),
                        wellPanel(
                          p("EC50 kill factor shown below indicates the relative bacterical kill rate the drug achieves compared to the maximal kill the drug can achieve at high concentration of the drug.")
                        ),
                        plotOutput("plotKillPop", height="350px")
                     ),
                     tabPanel("Immune system",
                       value = 'popImmuneTab',
                       wellPanel(
                         p("The plots below show various regulating cells and factors in the immune system. The plots also show the infection phase (t < 0) included in the simulation, the dashed line indicates drug treatment start (t = 0)."),
                         p("The grey area indicates the drug treatment period.")
                       ),
                       splitLayout(cellWidths = c("49%", "49%"),
                        plotOutput("plotImmuneCytoLungPop", height="250px"),
                        plotOutput("plotImmuneTLungPop", height="250px")
                       ),
                       splitLayout(cellWidths = c("49%", "49%"),
                         plotOutput("plotImmuneCytoLymphPop", height="250px"),
                         plotOutput("plotImmuneTHelperPop", height="250px")
                       ),
                       splitLayout(cellWidths = c("49%", "49%"),
                         plotOutput("plotImmuneCytoDendrPop", height="250px"),
                         plotOutput("plotImmuneTNaivePop", height="250px")
                       )
                   ),
                   tabPanel("", icon=icon("list"),
                     br(),
                     wellPanel(
                       p("Below are the settings that were used for this simulation.")
                     ),
                     tableOutput("simTherapyPop"),
                     tableOutput("simSummaryPop")
                   )
                )
              ),
              tabBox(
                width = 4,
                tabPanel(
                    "Sim",
                    br(),
                    actionButton("simSubmitPop", "Start simulation", icon = icon("play"), width = "80%"),
                    actionButton("simResetPop", "", icon=icon("trash"), width="18%"),
                    hr(),
                    conditionalPanel(
                      condition='input.isQuickSim && input.nPatients > 200',
                      p(class="info-text", "Note: for 'quick simulations', the number of simulated patients will be capped at 200.")
                    ),
                    textInput("jobDescription", "Simulation description: ", width="100%"),
                    div(style="display: inline-block;vertical-align:top; width: 71%;",
                      selectInput("drugRegimen", "Regimen: ", names(regimenList), selected = defaultRegimen)
                    ),
                    div(style="display: inline-block;vertical-align:top; width: 28%; padding-top: 24px",
                      actionButton("editDrugRegimensPopulation", "", icon=icon("pencil"), class="narrow"),
                      actionButton("duplicateDrugRegimensPopulation", "", icon=icon("copy"), class="narrow"),
                      actionButton("deleteDrugRegimensPopulation", "", icon=icon("trash"), class="narrow")
                    ),
                    p("To change the default regimens, please duplicate the regimen first.", class='help'),
                    hr(),
                    tabsetPanel(
                      tabPanel(
                        "Basic settings",
                        checkboxInput("isQuickSim", "Fast mode (only outcome %)", value = TRUE),
                        conditionalPanel(
                          condition="$('#loginButton-googleAuthUi > a').hasClass('btn-default') === true || globals.local_server",
                          checkboxInput("isBootstrap", "Perform bootstrap (slower)", value = FALSE)
                        ),
                        sliderInput("nPatients", "Patients",
                                min = 100,
                                max = 1000,
                                value = 200,
                                step = 25, width='100%'),
                        sliderInput("nIterations", "Simulations",
                                min = 25,
                                max = 1000,
                                value = 100,
                                step = 25, width='100%')
                    ),
                    tabPanel(
                       "Advanced",
                       value = "populationAdvancedTab",
                       actionButton("editSimSettingsPop", "Simulation settings", width="49%"),
                       actionButton("editAdherencePopulation", "Adherence settings", width="49%"),
                       hr(),
                       selectInput("isImmuneKillPop", "Killing by immune system: ", c("Yes", "No"), width="100%"),
                       selectInput("isResistancePop", "Bacterial resistance: ", c("Yes", "No"), width="100%")
                      #  hr(),
                      #  selectInput("patientTypeSingle", "Patient type: ", c("Typical", "Random"), width='98%'),
                      #  p("'Typical' patient: using population parameters; 'Random': parameters drawn from distributions.", class='help'),
                      #  hr(),
                      #  selectInput("isImmuneKillSingle", "Killing by immune system: ", c("Yes", "No"), width='98%'),
                      #  selectInput("isResistanceSingle", "Can bacterial develop resistance: ", c("Yes", "No"), width='98%')
                    )
                  )
                ),
                tabPanel("Output (-)",
                  value = "populationResultsTab",
                  br(),
                  actionButton("loadResults", "Show", icon = icon("arrow-left")),
                  # actionButton("compareResults", "", icon = icon("arrows-h")),
                  actionButton("populationRefreshResults", "", icon = icon("refresh")),
                  actionButton("deleteResults", "", icon = icon("trash")),
                  downloadButtonPDF("reportPopulation", "PDF"),
                  downloadButtonData("downloadDataPopulation", ""),
                  DT::dataTableOutput("queueResultsTable")
               ),
               tabPanel(
                  "Queue (0)",
                  value = "populationQueueTab",
                  br(),
                  actionButton("killJob", "Kill job", icon = icon("hand-stop-o")),
                  actionButton("refreshJobQueue", "Refresh", icon = icon("refresh")),
                  DT::dataTableOutput("qstatTable")
               )
              )
            )
        ),
        tabItem(tabName = "tabDrugsLibrary",
          fluidRow(
             box(title = "Drug library", width=4, status="primary",
               actionButton("newDrug", "New", icon = icon('plus')),
               actionButton("deleteDrug", "Delete", icon = icon('trash')),
               actionButton("refreshDrugs", "", icon = icon('refresh')),
               hr(),
               DT::dataTableOutput("drugLibList")
             ),
             box(title = textOutput("drugParamsTitle"), width=8, status="primary",
               actionButton("saveDrugParams", "Save", icon = icon('save')),
               hr(),
               rHandsontableOutput("drugParamsTable", width='100%')
             )
          )
        ),
        tabItem(tabName = "tabDrugRegimenDoc",
          fluidRow(
            box(title = "TB drug regimens", width=9, status="primary",
              br(),
              p("For initial empiric treatment of TB, start patients on a 4-drug regimen: isoniazid, rifampin, pyrazinamide, and either ethambutol or streptomycin. Once the TB isolate is known to be fully susceptible, ethambutol (or streptomycin, if it is used as a fourth drug) can be discontinued."),
              p("Patients with TB who are receiving pyrazinamide should undergo baseline and periodic serum uric acid assessments, and patients with TB who are receiving long-term ethambutol therapy should undergo baseline and periodic visual acuity and red-green color perception testing. The latter can be performed with a standard test, such as the Ishihara test for color blindness."),
              p("After 2 months of therapy (for a fully susceptible isolate), pyrazinamide can be stopped. Isoniazid plus rifampin are continued as daily or intermittent therapy for 4 more months. If isolated isoniazid resistance is documented, discontinue isoniazid and continue treatment with rifampin, pyrazinamide, and ethambutol for the entire 6 months. Therapy must be extended if the patient has cavitary disease and remains culture-positive after 2 months of treatment."),
              hr(),
              img(src="images/tb_regimens_natrev.png", class='doc-img', align="center"),
              br(),
              p("Table from: Pai M et al. Nat Rev Dis Primers, 2016.", class='help')
            )
          )
        ),
        tabItem(tabName = "tabDrugsRegimenDoc",
          fluidRow(
            box(title = "Drug regimens", width=9, status="primary",
              br(),
              hr()
            )
          )
        ),
        tabItem(tabName = "tabModelStructure",
          fluidRow(
             conditionalPanel(condition="globals.docsView == 'docsPK'",
                box(title = "Pharmacokinetics", width=9, status="primary",class='center',
                  img(src="images/regimenPK.emf.png", class='doc-img')
                )
             ),
             conditionalPanel(condition="globals.docsView == 'docsBact'",
                box(title = "Bacterium infection", width=9, status="primary",class='center',
                  img(src="images/infectionBug.emf.png", class='doc-img')
                )
             ),
             conditionalPanel(condition="globals.docsView == 'docsImmune'",
                box(title = "Immune response", width=9, status="primary",class='center',
                  img(src="images/immuneHost.emf.png", class='doc-img')
                )
             ),
             conditionalPanel(condition="globals.docsView == 'docsFull'",
                box(title = "Full QSP model", width=9, status="primary", class='center',
                  img(src="images/fullQSP.emf.png", class='doc-img')
                )
             ),
             box(title = "Model structure", width=3, status="primary",
               br(),
               actionButton("docsPK", HTML("<img src='images/regimen.emf.png' width='50'></img><br><font size='-1'>Pharmacokinetics</font>"), width="100%"),
               actionButton("docsBact", HTML("<img src='images/bug.emf.png' width='50'></img><br><font size='-1'>Bacterium infection</font>"), width="100%"),
               actionButton("docsImmune", HTML("<img src='images/host.emf.png' width='50'></img><br><font size='-1'>Host / immune response</font>"), width="100%"),
               actionButton("docsFull", HTML("<img src='images/hostBugRegimen.emf.png' width='75'></img><br><font size='-1'>Full QSP model</font>"), width="100%")
             )
          )
        ),
        tabItem(tabName = "tabAdvancedSingle",
          fluidRow(
            box(
              status = "primary",
              br()
            ),
            tabBox(
              title = "Advanced",
              tabPanel("Bacterial growth", br()),
              tabPanel("Immune system", br()),
              tabPanel("Miscellaneous", br())
            )
          )
        ),
        tabItem(
          tabName = "tabAdvancedPopulation",
          br()
        ),
        tabItem(
          tabName = "tabSettings",
          box(
            title = "Settings",
            status = "primary",
            br()
          )
        )
      )
    )
  )
)
