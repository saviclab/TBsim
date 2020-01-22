import subprocess
import time
import multiprocessing
import os
test_drugs=[
    "PZA.txt",
    "INH.txt",
    "RIF.txt",
    "EMB.txt",
    ]

test_vars=[
    "KaMean",
    "KeMean",
    "V1Mean",
    "KeMult",
    "KeTime",
    "highAcetFactor",
    "IOfactor",
    "GRfactor",
    "EC50k",
    "EC50g",
    "ak",
    "ag",
    "mutationRate",
    "kill_e0",
    "kill_e1",
    "kill_e2",
    "kill_e3",
    "kill_i0",
    "kill_i1",
    "kill_i2",
    "kill_i3",
    "killIntra",
    "killExtra",
    "growIntra",
    "growExtra",
    "factorFast",
    "factorSlow",
    "multiplier",
    "rise50",
    "fall50",
    "decayFactor",
    ]

test_params=[
    0.1,
    0.5,
    1.0,
    2.0,
    10.0,
    ]

def build_params(drug):
    param_list=[]
    for var in test_vars:
        for param in test_params:
            param_list.append([drug,var,param])
    return param_list

def check_total_running(active):
    proc = subprocess.Popen('ps -A | grep TBsim', stdout=subprocess.PIPE,shell=True)
    time.sleep(0.25)
    tmp = proc.stdout.read()
    #print(len(str(tmp.decode("utf-8")).split('\n')))
    total=len(str(tmp.decode("utf-8")).split('\n'))

    if total>=multiprocessing.cpu_count()/2:
        return False
    else:
        return True

def analyze_drug(drug):
    print("Analyzing:",drug,"                     ")
    #time.sleep(4)
    verbose=False
    param_list=build_params(drug)
    #print(param_list)
    active=[]
    aleternate=0
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
                time.sleep(0.25)
                tmp = proc.stdout.read()
                total=len(str(tmp.decode("utf-8")).split('\n'))-1
                cpus=int(multiprocessing.cpu_count())
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
                else: time.sleep(0.35*10)

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
    subprocess.Popen(" ".join(["python","csv_gen.py"]),shell=True)

if __name__=="__main__":
    for drug in test_drugs:
        if not os.path.exists(drug.split('.')[0]):
            os.makedirs(drug.split('.')[0])
        analyze_drug(drug)

