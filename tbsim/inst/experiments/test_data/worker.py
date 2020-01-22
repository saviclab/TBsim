import argparse
import os
import shutil
import subprocess

def check_output_exists(work_dir):
    looking_for=os.path.join(work_dir,"outcome.txt")
    if os.path.isfile(looking_for):
        return True
    else:
        return False

def create_work_dir(drug,var,param):
    work_dir=os.path.join(drug.split('.')[0],'_'.join([var,str(param)]))
    if not os.path.exists(work_dir):
        os.makedirs(work_dir)
        os.chdir(work_dir)

def copy_data(data_dir,work_dir):
    for f in os.listdir(data_dir):
        if not os.path.isfile(os.path.join(work_dir,f)):
            shutil.copy2(os.path.join(data_dir,f),work_dir)
            #print(os.path.join(data_dir,f))

def change_parameter(work_dir,drug,var,param):
    f=open(os.path.join(work_dir,"TBinit.txt"),'r')
    contents=f.readlines()
    f.close()
    for i in range(len(contents)):
        #print(contents[i])
        if "".join(["<",var,">"]) in contents[i]:
            pattern="".join(["<",var,">"])
            new_num=str(int(param))
            #print(new_num)
            #new_num=str(float(param)*float(contents[i].split(">")[1].split('\n')[0]))
            contents[i]=pattern+new_num+'\n'
    f=open(os.path.join(work_dir,"TBinit.txt"),'w')
    f.writelines(contents)
    f.close()

    f=open(os.path.join(work_dir,"TBinit.txt"),'r')
    contents=f.readlines()
    f.close()
    for i in range(len(contents)):
        if "<dataFolder>" in contents[i]:
            pattern="<dataFolder>"
            new_dir=work_dir+'/'
            contents[i]=pattern+new_dir+'\n'
        if "<therapyStart>" in contents[i]:
            pattern="<therapyStart>"
            new_val=str(int(param)-int(drug.split('_')[2]))
            contents[i]=pattern+new_val+'\n'
    f=open(os.path.join(work_dir,"TBinit.txt"),'w')
    f.writelines(contents)
    f.close()

def run_experiment(data_dir,work_dir,drug,var,param):
    subprocess.Popen(os.path.join(data_dir.split("config")[0],"TBsim")+" ./ TBinit.txt > output.txt",shell=True,cwd=work_dir)
    pass
def stages(drug,var,param):
    data_dir=os.path.join(os.getcwd(),"config/")
    work_dir=os.path.abspath(os.path.join(drug.split('.')[0],'_'.join([var,str(param)])))
    if check_output_exists(work_dir):
        return 0
    create_work_dir(drug,var,param)
    copy_data(data_dir,work_dir)
    change_parameter(work_dir,drug,var,param)
    run_experiment(data_dir,work_dir,drug,var,param)

def main():
    parser = argparse.ArgumentParser(description='Sensitivity analysis on drug regimen.')
    parser.add_argument('drug', metavar='d', type=str,
                    help='drug name')
    parser.add_argument('var', metavar='v', type=str,
                    help='test_var name')
    parser.add_argument('param', metavar='p', type=float,
                    help='test_param name')
    args = parser.parse_args()
    #print(args)
    drug=args.drug
    param=args.param
    var=args.var
    #print(drug,var,param)
    stages(drug,var,param)

if __name__ == "__main__":
    main()



