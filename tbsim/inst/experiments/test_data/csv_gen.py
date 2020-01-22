
import os


def extract_rows(df,param_list,drug):
    target_data=[]
    for param in param_list:
        header_1=False
        header_2=False
        header_3=False
        once=True
        if os.path.isfile(os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),"bactTotals.txt")):
            with open(os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),"bactTotals.txt"),'r') as f:
                for line in f:
                    if once:
                        if "<type>total" in line or header_1==True:
                            header_1=True
                            if "<compartment>0" in line or header_2==True:
                                header_2=True
                                if "<stat>median" in line or header_3==True:
                                    #print("HERE",header_1,header_2,header_3,once)
                                    header_3=True
                                    if "<data>" in line:
                                        header_1=False
                                        header_2=False
                                        header_3=False
                                        once=False
                                        target_data=line.split('\t')
                    if "<data>" in line:
                        header_1=False
                        header_2=False
                        header_3=False
            with open(os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),"TBinit.txt"),'r') as f:
                for line in f:
                    if "<therapyFile>" in line:
                        therapy_file=line.split(">")[1].split("\r\n")[0]
                    if "<therapyStart>" in line:
                        therapy_start=line.split(">")[1].split("\n")[0]
            with open(os.path.join(drug.split('.')[0],"_".join([str(param[1]),str(param[2])]),therapy_file),'r') as f:
                for line in f:
                    if "<drug>" in line:
                        therapy_dose=line.split("|")[1]
            
            # drug | variable | Dose | EBA_DAYS | TherapyStart | Day | Bacterial Load            
            for t in range(len(target_data)-1):
                if t!=0:
                    df.append([drug.split('.')[0].split('_')[1],
                        param[1],
                        therapy_dose,
                        drug.split('_')[2],
                        therapy_start,
                        t,
                        target_data[t]])
                else:
                    df.append([drug.split('.')[0].split('_')[1],
                        param[1],
                        therapy_dose,
                        drug.split('_')[2],
                        therapy_start,
                        t,
                        target_data[t].split('>')[1]])
                    
        else:
            print("FAILURE:",os.path.join(drug.split('.')[0].split('_')[1],"_".join([str(param[1]),str(param[2])]),"outcome.txt"))
    return(df)

def build_params(test_vars,test_params,drug):
    param_list=[]
    for var in test_vars:
        for param in test_params:
            param_list.append([drug,var,param])
    return param_list



def main():
    print("Extracting data from...")
    df=[["DRUG","VARIABLE","nTime","DAY","BacterialLoad"]]
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

