
import os

test_drugs=[
    "Immune.txt"
    ]

test_vars=[
    "sM",
    "a4",
    "w",
    "k4",
    "s8",
    "k2",
    "c9",
    "k3",
    "f3",
    "s3",
    "c8",
    "mu_r",
    "mu_a",
    "k17",
    "k14",
    "c4",
    "mu_i",
    "a8",
    "a23",
    "mu_IL12L",
    "sg",
    "c1",
    "s4",
    "a5",
    "c5",
    "mu_IFN",
    "a14",
    "s6",
    "f6",
    "a16",
    "a17",
    "a18",
    "d7",
    "mu_IL1",
    "a11",
    "a12",
    "mu_IL4",
    "d6",
    "a2",
    "c15",
    "mu_Tp",
    "k6",
    "f1",
    "f7",
    "s1",
    "k7",
    "f2",
    "s2",
    "mu_T1",
    "mu_T2",
    "a2",
    "k15",
    "k18",
    "a19",
    "N",
    "Ni",
    "d1",
    "mu_IL12LN",
    "sT",
    "d2",
    "lambda1",
    "mu_T",
    "d4",
    "d5",
    "rho",
    "theta",
    "scale",
    "mu_MDC",
    "d12",
    "sIDC",
    "d8",
    "d9",
    "d1",
    "d11",
    "mu_IDC",
    "Bemax",
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

