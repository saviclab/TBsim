import subprocess
import time
import multiprocessing
import os
import csv_gen as cg
import argparse

test_drugs=[
    "PZA_02.txt"
    ]

test_vars=[
    "nTime",
    ]

#test_params=[
#    180.,
#    181.,
#    182.,
#    183.,
#    184,
#    ]
test_params=list(range(10,400,5))
test_params=[float(i) for i in test_params]


def build_params(drug):
    param_list=[]
    for var in test_vars:
        for param in test_params:
            param_list.append([drug,var,param])
    return param_list

def total_mem():
    mem=os.popen('free -t -m').readlines()
    mem_line=""    
    for line in mem:
        if "Mem:" in line:
            mem_line=line
    mem_line=mem_line.split(' ')
    real_mem=[]    
    for chars in mem_line:
        if chars != "":
            real_mem.append(chars)
    return float(real_mem[3])/1000

def check_total_running(active):
    time.sleep(0.2)
    mem_footprint = 10#4.5*2 #memort footprint of TBsim    
    proc = subprocess.Popen('ps -A | grep TBsim', stdout=subprocess.PIPE,shell=True)
    proc.wait()
    tmp = proc.stdout.read()
    total=len(str(tmp.decode("utf-8")).split('\n'))
    mem_avail=total_mem()
    if total < multiprocessing.cpu_count()/2 and mem_footprint < mem_avail:
        return True
    else:
        return False

def analyze_drug(drug):
    print("Analyzing:",drug,"                     ")
    #time.sleep(4)
    verbose=False
    param_list=build_params(drug)
    #print(param_list)
    active=[]
    aleternate=0
    cpus=int(multiprocessing.cpu_count())
    for params,i in zip(param_list,range(len(param_list))):
        circle=True
        while(circle):
            if(check_total_running(active)):
                circle=False
                print(" ".join(["python","worker.py",params[0],params[1],str(params[2])]),"                            ")
                p=subprocess.Popen(" ".join(["python","worker.py",params[0],params[1],str(params[2])]),shell=True)
                active.append(p)
            else:
                proc = subprocess.Popen('ps -A | grep TBsim', stdout=subprocess.PIPE,shell=True)
                proc.wait()                
                #time.sleep(0.25)
                tmp = proc.stdout.read()
                total=len(str(tmp.decode("utf-8")).split('\n'))-1
                if verbose:
                    for tick in range(10):
                        if aleternate==0:
                            aleternate=1
                            print(" [\]", i/len(param_list)*100," percent complete [",total,"/",cpus,"] cpus utilized        \r")
                        elif aleternate==1:
                            aleternate=2
                            print(" [|]",i/len(param_list)*100," percent complete [",total,"/",cpus,"] cpus utilized        \r")
                        elif aleternate==2:
                            aleternate=3
                            print(" [/]",i/len(param_list)*100," percent complete [",total,"/",cpus,"] cpus utilized        \r")
                        elif aleternate==3:
                            aleternate=0
                            print(" [-]",i/len(param_list)*100," percent complete [",total,"/",cpus,"] cpus utilized       \r")
                        time.sleep(0.35)
                else: time.sleep(0.2)

    circle=True
    time.sleep(3)
    while(circle):
        proc = subprocess.Popen('ps -A | grep TBsim', stdout=subprocess.PIPE,shell=True)
        time.sleep(1.00)
        tmp = proc.stdout.read()
	
        #print(len(str(tmp.decode("utf-8")).split('\n')))
        total=len(str(tmp.decode("utf-8")).split('\n'))
        if total==1:
            circle=False
    #subprocess.Popen(" ".join(["python","csv_gen.py"]),shell=True)

if __name__=="__main__":
    parser = argparse.ArgumentParser(description='Sensitivity analysis on drug regimen.')
    parser.add_argument('run_name', metavar='d', type=str,
                    help='drug name')
    #print(parser)
    args = parser.parse_args()
    if args.run_name != None:
        test_drugs=[args.run_name]
    for drug in test_drugs:
        if not os.path.exists(drug.split('.')[0]):
            os.makedirs(drug.split('.')[0])
        analyze_drug(drug)
    print("Extracting data from...")
    df=[["DRUG","VARIABLE","DOSE","EBA_DAYS","Therapy_Start","DAY","BacterialLoad"]]
    for drug in test_drugs:
        print("\t"+drug)
        param_list=cg.build_params(test_vars,test_params,drug)
        df=cg.extract_rows(df,param_list,drug)
    f=open("results_"+df[2][0]+"_"+str(int(float(df[2][2])))+"_"+str(int(float(df[2][3])))+".csv",'w')
    for row in df:
        tmp=[row[0],row[1],str(row[2]),str(row[3]),str(row[4]),str(row[5]),str(row[6])]
        f.write(",".join(tmp)+"\n")
    f.close()

