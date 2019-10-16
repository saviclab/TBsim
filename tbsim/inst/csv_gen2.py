
import os

test_drugs=[
    "TBinit.txt"
    ]

test_vars=[
    "nTime",
    "nIterations",
    "nPatients",
    "nPopulations",
    "therapyStart",
    "kMax",
    "persistTime",
    "initialValueStdv",
    "parameterStdv",
    "timeStepStdv",
    "adherenceSwitchDay",
    "adherenceMean",
    "adherenceStdv",
    "adherenceStdvDay",
    "shareLowAcetylators",
    "immuneMean",
    "immuneStdv",
    "granulomaGrowth",
    "granulomaKill",
    "granulomaGrowthInh",
    "granulomaFormation",
    "granulomaInfectionRate",
    "granulomaBreakup",
    "bactThreshold",
    "bactThresholdRes",
    "growthLimit",
    "freeBactLevel",
    "latentBactLevel",
    "infI",
    "infII",
    "infIII",
    "infIV",
    "resistanceRatio",
    "resistanceFitness",
    ]

test_params=[
    0.1,
    0.5,
    1.0,
    2.0,
    10.0,
    ]


def extract_rows(df,param_list,drug):
    for param in param_list:
        header_1=False
        header_2=False
        once=True
        if os.path.isfile(os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),"outcome.txt")):
            with open(os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),"outcome.txt"),'r') as f:
                for line in f:
                    if once:
                        if "AcuteTB" in line or header_1==True:
                            header_1=True
                            if "median" in line or header_2==True:
                                header_2=True
                                if "data" in line:
                                    header_1=False
                                    header_2=False
                                    once=False
                                    target_data=line.split('\t')[-2]
            # drug | variable | multiplier | sensitivity data 
            df.append([drug.split('.')[0],param[1],param[2],target_data])
        else:
            print("FAILURE:",os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),"outcome.txt"))
    return(df)

def build_params(drug):
    param_list=[]
    for var in test_vars:
        for param in test_params:
            param_list.append([drug,var,param])
    return param_list



def main():
    print("Extracting data from...")
    df=[["DRUG","VARIABLE","MULTIPLIER","MedianAcuteTB"]]
    for drug in test_drugs:
        param_list=build_params(drug)
        df=extract_rows(df,param_list,drug)
    f=open("sensitivity.csv",'w')
    for row in df:
        tmp=[row[0],row[1],str(row[2]),str(row[3])]
        f.write(",".join(tmp)+"\n")
    f.close()
if __name__ == "__main__":
    main()

