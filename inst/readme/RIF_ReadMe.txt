<name>RIF			: drug 'name', must be same as used in therapy file
<KaMean>1.81		: Ka (absorption coeficient) mean
<KaStdv>0.48		: Ka standard error
<KeMean>0.18		: Ke (elimination coeficient) mean
<KeStdv>0.34		: Ke standard error
<V1Mean>49.6		: Volume (V/F)mean
<V1Stdv>0.24		: Volume standard error
<KeMult>2.02		: Ke multiplier for maximum auto-induction
<KeTime>17.0		: Time [days] to reach max auto-induction
<highAcetFactor>1.0	: Ke multiplier for high vs. low acetylator
<IOfactor>3.7		: Concentration multiplier for inside vs. outside of
					: macrophages
<GRfactor>0.11		: Concentration multiplier for inside vs. outside of
					: granuloma (applies when 'isGradualDiffusion' = 0)
<EC50k>5.0			: EC50 for bacterial killing
<EC50g>1.5			: EC50 for bacterial growth inhibition
<ak>0.79			: 
<ag>0.36			: 
<ECStdv>0.1			: standard error for EC50k and EC50g
<mutationRate>3.7e-10: Bacterial mutation rate [1/h] for mono-resistance
				    : Note the bact kill rates have dimension [1/h]
					: i.e., different from the 'log10/day' used at times
<kill_e0>0.0		: extracellular kill rate days < 0  [1/h]
<kill_e1>0.5		: extracellular kill rate days 0-2  [1/h]
<kill_e2>0.4		: extracellular kill rate days 3-14 [1/h]
<kill_e3>0.4		: extracellular kill rate days 15+  [1/h]
<kill_i0>0.0		: intracellular kill rate days < 0  [1/h]
<kill_i1>0.5		: intracellular kill rate days 0-2  [1/h]
<kill_i2>0.4		: intracellular kill rate days 3-14 [1/h]
<kill_i3>0.4		: intracellular kill rate days 15+  [1/h]
<killIntra>1		:
<killExtra>1		:
<growIntra>1		:
<growExtra>1		:
<factorFast>1.0		:
<factorSlow>1.0		: 
					: Next 4 parameters apply when 'isGradualDiffusion'=1
<multiplier>0.11	: multiplier for drug concentration in granuloma
<rise50>5			: half time for drug diffusion into granuloma [h]
<fall50>5			: half time for drug diffusion out from granuloma [h]
<decayFactor>0.3	: speed of concentration decline in macrophages
					  0= follows extra-macrophage PK
					  1= follows extra-macrophage PK
