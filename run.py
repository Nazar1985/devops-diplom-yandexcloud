import os
import subprocess
import json
import credentials as cr
import time
import sys


name_network = 'net'
name_subnet = 'packer-subnet-a'


def set_subnet_id(id):
    with open('trash/packer/centos-7-base.json', 'r') as file:
        data = json.load(file)

    data["builders"][0]["subnet_id"] = id

    with open('trash/packer/centos-7-base.json', 'w') as file:
        json.dump(data, file)


def create_network_packer(name_net):
    create_network_result = str(subprocess.check_output(f'yc vpc network create --name {name_net}', shell=True))

    if "id:" in create_network_result:
        print(f'---network {name_net} is done')
        return create_network_result[6:26]
    else:
        print('Error')


def create_subnet_packer(name_sub, name_net):
    create_subnet_result = str(subprocess.check_output(
        f'yc vpc subnet create --name {name_sub} --range 10.100.100.0/24 --network-name {name_net} '
        f'--description "for packer"', shell=True))

    if "id:" in create_subnet_result:
        print(f'---subnet {name_sub} is done')
        return create_subnet_result[6:26]
    else:
        print('Error')


def print_help():
    print("""
                !!!WRONG!!! You need enter eny parameters !!!
         ____________________________________________________________________
         -a - this key calls the commands:
               terraform init
               terraform validate
               terraform apply -var='centos-7-base={YC_IMAGE_ID}' 
                               -var='YC_FOLDER_ID={cr.YC_FOLDER_ID}' 
                               -var='YC_CLOUD_ID={cr.YC_CLOUD_ID}' 
                               --auto-approve
         -d - this key calls the commands:
              terraform destroy -var='centos-7-base={YC_IMAGE_ID}' 
                                -var='YC_FOLDER_ID={cr.YC_FOLDER_ID}' 
                                -var='YC_CLOUD_ID={cr.YC_CLOUD_ID}' 
                                --auto-approve
         /* disabled 
         -C - this key create network and subnet for create 
              build image file from ./package /centos-7-base.json
         -D - this key delete your image file
         disabled */
         
         -h - display this help
         ____________________________________________________________________             
         Parameter YC_IMAGE_ID  get before calls any commands terraform other 
         parameters imported from credentials.py "import credentials as cr". 
         You need self create file credentials.py like:
             YC_TOKEN = "..............................................."
             YC_CLOUD_ID = "....................................."
             YC_FOLDER_ID = "................................."
         ____________________________________________________________________
         You can set several parameters like:
         python3 run.py -C -a -d -D

         Sequence is of great importance
         ____________________________________________________________________                                  
                === Please! Enter any parameter! ===
        """)


def get_image_id():
    image_id = str(subprocess.check_output("yc compute image get --name centos-7-base", shell=True))
    if "id:" in image_id:
        print(f'---image_id {image_id[6:26]} is done')
        return image_id[6:26]
    else:
        print('Error')


def create_images():
    print("---create network for packer")
    id_network = create_network_packer(name_network)
    print("---create subnet for packer")
    id_subnet = create_subnet_packer(name_subnet, name_network)
    print("---change id subnet for packer")
    set_subnet_id(id_subnet)
    print("---begin validate")
    os.system("cd packer/ && packer validate centos-7-base.json")
    print("---begin build")
    build = os.system("cd packer/ && packer build centos-7-base.json")
    if build == 0:
        print("---builded")
    else:
        return 1
    print("---droped network and subnet")
    drop_subnet = os.system(f'yc vpc subnet delete --id {id_subnet}')
    drop_network = os.system(f'yc vpc network delete --id {id_network}')

    if drop_network == 0 and drop_subnet == 0:
        print("All deleted")
    elif drop_subnet == 0:
        print("Only subnet is deleted")
    elif drop_network == 0:
        print("Only network is deleted")
    else:
        print('OOps....')


def delete_image():
    os.system(f"yc compute image delete --name centos-7-base")


def apply():
    # YC_IMAGE_ID = get_image_id()  f"-var='centos-7-base={YC_IMAGE_ID}' "
    os.system("cd ./terraform && terraform init")
    os.system("cd ./terraform && terraform validate")
    os.system(f"cd ./terraform && terraform apply "
              f"-var='YC_FOLDER_ID={cr.YC_FOLDER_ID}' "
              f"-var='YC_CLOUD_ID={cr.YC_CLOUD_ID}' "
              f"--auto-approve")


def destroy():
    # YC_IMAGE_ID = get_image_id()   f"-var='centos-7-base={YC_IMAGE_ID}' "
    os.system(f"cd ./terraform && terraform destroy "
              f"-var='YC_FOLDER_ID={cr.YC_FOLDER_ID}' "
              f"-var='YC_CLOUD_ID={cr.YC_CLOUD_ID}' "
              f"--auto-approve")


if __name__ == "__main__":
    """1) нужно настроить проверку последовательности параметров, так как нельзя сначала вызвать -d а затем -a
       2) желательно настроить проверку какие команды уже выполнены этим скриптом, чтобы выводить ошибку
          при попытке удалить несуществующие ресурсы или создать ресурсы без image.
       3) необходимо разработать функцию, которая будет сканировать все ресурсы облака и затем их последовательно 
          удалять, если скрипт остановился с ошибкой на этапе build image или другом этапе.   
    """
    start = time.time()
    for param in sys.argv:
        if len(sys.argv) < 2:
            print_help()
            break
        elif param != 'run.py' and param != "-C" and param != "-a" and param != "-d" and param != "-D":
            print_help()
            break

        if param == "-C":
            # print("create_images()")     # for debug
            print('______///***=== beginning creating image ===***///______')
            create_images()
            print('______///***=== creating image completed ===***///______')
        if param == "-a":
            print('______///***=== beginning terraform apply ===***///______')
            # print("apply()")             # for debug
            apply()
            print('______///***=== terraform apply completed ===***///______')
        if param == "-d":
            print('______///***=== beginning terraform destroy ===***///______')
            # print("destroy()")           # for debug
            destroy()
            print('______///***=== terraform destroy completed ===***///______')
        if param == "-D":
            print('______///***=== beginning deleting image ===***///______')
            # print("delete_image()")      # for debug
            delete_image()
            print('______///***=== deleting image completed ===***///______')

    long = time.time() - start
    second = long % 60
    minutes = long // 60 % 60
    hours = long // 3600 % 24
    print('______///***=== GOOD JOB ===***///______')
    print(f"The script execution total time is {hours:.0f} hour {minutes:.0f} minutes {second:.0f} seconds")
