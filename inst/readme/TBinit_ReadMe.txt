<batchMode>0			: 0=interactive mode, 1=batch mode (no menu
						  prompts)
<nTime>360				: total simulation duration (Days), 
						  if drug administration is beyond nTime
						  this will trigger a warning message
<nIterations>1000		: number of iterations in bootstrap process,
						  should be > 100, and generally < 1000
<nPatients>1000			: number of patients per population
						  [size 1000 x 4 drugs => ~6GB on 64bit Intel i5]
<nPopulations>1			: number of distinct patient populations
						  to generate. If >1 then bootstrap is OFF
<nThreads>4				: concurrent processing threads
						  for parallel program execution
<therapyStart>180		: time point for drug administration start
<disease>5				: disease configuration option, do not change
<kMax>24				: time steps per day (hourly), do not change
<isSavePatientResults>0	: =1 then will save selected simulation
						  data for EACH patient. Note: adds significant processing overhead
<isSavePopulationResults>1 : =1 enables saving of simulation
						     results summary statistics 
<isSaveAdhDose>0		: =1 save adherence and dosing metrics
<isSaveConc>0			: =1 save PK concentration metrics
<isSaveConcKill>0		: =1 save PK kill and growth factors [0..1]
<isSaveImmune>0			: =1 save Immune system metrics (12 values)
<isSaveMacro>0			: =1 save Macrophage metrics (3 types)
<isSaveBact>0			: =1 save Bacteria (wild-type strains)
<isSaveBactRes>0		: =1 save Resistant bacteria strain metrics
<isSaveOutcome>1		: =1 save population Outcome metrics
<isSaveEffect>0			: =1 save drug kill effect metrics
<isAdherence>1			: =1 calculate adherence vector
<isDrugDose>1			: =1 calculate drug dose vector
<isConcentration>1		: =1 calculate drug PK vector
<isSolution>1			: =1 calculate PD and immune system vector
<isOutcome>1			: =1 calculate population therapy outcome
<isDrugEffect>0			: =1 calculate drug kill effects
<isResistance>1			: =1 bacterial resistance enabled
<isGranuloma>1			: =1 granuloma dynamics enabled 
<isImmuneKill>1			: =1 immune system killing enabled
<isPersistance>0		: =1 bacterial persistance state (set to 1)
<isClearResist>0		: =1 then resistant bacteria is cleared
						  when falls below defined threshold
<isGranImmuneKill>0		: =1 immune killing inside granuloma
<isGranulomaInfec>1		: =1 macrophages in granuloma get infected
<isGradualDiffusion>1	: =1 dynamic drug diffusion into granuloma
						  based on parameters rise50, fall50, and
						  multiplier.
						  =0 immediate drug diffusion into granuloma
						  based on parameter GRfactor
<persistTime>7			: time span for persistance status
<dataFolder>C:\\WorkFiles\\UCSF_MTB\\TB_10262014\\DataFiles\\
<initialValueStdv>0.20	: standard error applied for variance
						  for starting parameters for ODE system
<parameterStdv>0.20		: standard error applied for variance of
						  immune system variables
<timeStepStdv>0.05		: standard error applied at each time step
<adherenceType1>0		: adherence during intensive therapy period
<adherenceType2>0		: adherence during continuation therapy
<adherenceSwitchDay>240	: day for switch between adh type 1 and 2
<adherenceMean>1.0		: mean population patient adherence
<adherenceStdv>0.0001	: standard error for patient adherence
<adherenceStdvDay>0.0001: variance in patient adhenrence per day step
<shareLowAcetylators>0.50: share in population with low acetylators (INH)
<immuneMean>1.0			: average patient immune system status [0..1]
<immuneStdv>0.001		: standard error variance for immune status
<granulomaGrowth>0.01	: relative bacterial growth rate in granuloma
<granulomaKill>1.0		: drug PD effectiveness inside granuloma
<granulomaGrowthInh>1.0	: reduced growth inhibition by drugs in
						  granuloma (defined as 1/factor)
<granulomaFormation>1e-4: rate for granuloma formation, which is 
						  multiplied with bacterial load
<granulomaInfectionRate>0.05: factor defining rate of macrophage 
						      infection inside granuloma [0..1]
<granulomaBreakup>0		: =1 then granuloma breakup is active
<bactThreshold>1.0		: limit to filter out low levels of bacteria
<bactThresholdRes>1.0	: limit to filter out low levels of resistant bact
<growthLimit>0.01		: limit for considered non-persisting bacteria
<freeBactLevel> 1.0		: max bacteria level outside of granuloma to
						  be considered Cleared TB
<latentBactLevel>1000.0	: max bacteria threshold outside of granuloma to
						  be considered Latent TB
<infI>100				: initial bacterial in compartment 1 [CFU/ml]
<infII>0				: initial bacterial in compartment 2 [CFU/ml]
<infIII>0				: initial bacterial in compartment 3 [CFU/ml]
<infIV>0				: initial bacterial in compartment 4 [CFU/ml]
<resistanceRatio>5.0e-10: ratio of naturally occuring resistant strains
<resistanceFitness>0.8	: relative fitness of mono-drug resistant bacteria
<drugFile>PZA.txt		: list of individual drug files to load
<drugFile>INH.txt		:
<drugFile>RPT.txt		:
<drugFile>RIF.txt		:
<drugFile>MOX.txt		:
<drugFile>EMB.txt		:
<drugFile>RPT2.txt		:
<drugFile>RPT3.txt		:
<therapyFile>standardTB4.txt	: list of therapy files to load
<therapyFile>standardTB4_9mo.txt
<therapyFile>standardTB4_7mo.txt
<therapyFile>standardTB4_5mo.txt
<therapyFile>standardTB4_4mo.txt
<therapyFile>standardTB4_3wk.txt
<therapyFile>standardTB4_2wk.txt
<therapyFile>standardTB4_1wk.txt
<therapyFile>noDrugs.txt
<therapyFile>Rifaquin2_5.txt
<therapyFile>Rifaquin3_5.txt
<therapyFile>Rifaquin3_5_2xV.txt
<therapyFile>REMOX_ETHarm.txt
<therapyFile>REMOX_INHarm.txt
<therapyFile>S31_PH.txt
<therapyFile>S31_PHM.txt
<therapyFile>REMOX_INHarmMOX2X.txt
<therapyFile>6HR.txt
<therapyFile>6EHRZ.txt
<therapyFile>6H3R3Z3.txt
<therapyFile>6E3H3R3Z3.txt
<therapyFile>2EHR-7HR.txt
<therapyFile>2EHRZ-6HR.txt
<therapyFile>2HRZ-4H3R3.txt
<therapyFile>2E3H3R3Z3-6EH.txt
<therapyFile>2EHRZ-6EH.txt
<therapyFile>ElSadr1998_6mo.txt
<therapyFile>ElSadr1998_9mo.txt
<therapyFile>Combs1990_6mo.txt
<therapyFile>Combs1990_9mo.txt
<therapyFile>Perrins1995_6mo.txt
<therapyFile>Perrins1995_12mo.txt
<therapyFile>Sharifi2006_6mo.txt
<therapyFile>Sharifi2006_4mo.txt
<therapyFile>Felten_grpA.txt
<therapyFile>Felten_grpB.txt
<therapyFile>Algeria_6mo.txt
<therapyFile>Algeria_4mo.txt
<defaultTherapy>0			: default therapy at launch of program
<adherenceFile>adh1.txt		: adherence pattern files to load
<adherenceFile>adh2.txt		:
<adherenceFile>adh3.txt		:
