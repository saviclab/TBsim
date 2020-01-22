import subprocess
import time
import multiprocessing
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
    return float(real_mem[1])/1000

def check_total_running(active):
    mem_footprint = 0.4*1 #memort footprint of TBsim    
    proc = subprocess.Popen('ps -A | grep TBsim', stdout=subprocess.PIPE,shell=True)
    proc.wait()
    tmp = proc.stdout.read()
    total=len(str(tmp.decode("utf-8")).split('\n'))
    mem_avail=total_mem()
    if total < multiprocessing.cpu_count()/2 and total*mem_footprint < mem_avail:
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
                print(" ".join(["python","worker_imm.py",params[0],params[1],str(params[2])]),"                            ")
                p=subprocess.Popen(" ".join(["python","worker_imm.py",params[0],params[1],str(params[2])]),shell=True)
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
    subprocess.Popen(" ".join(["python","csv_gen2.py"]),shell=True)

if __name__=="__main__":
    for drug in test_drugs:
        if not os.path.exists(drug.split('.')[0]):
            os.makedirs(drug.split('.')[0])
        analyze_drug(drug)

