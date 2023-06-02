#!/bin/bash
set -euo pipefail

path_terraform_vars="/home/terraform.tfvars"  # path to the theraform file with variables "terraform.tfvars"
path_ansible_vars="/home/vars.yml"            # path to the ansible file with variables "vars.yml"
projects_directory="/home/$SUDO_USER/nodes"   # directory in which projects are created

# Color for Output
green="\033[1;32m" # Green
red="\033[31m"     # Red
nc="\033[0m"       # No Color

[ "$(id -u)" -ne 0 ] && {
  echo -e "${red}Only root user may run the script!${nc}"
  exit 1
}

echo "$SUDO_USER"
echo -e "${green}----------------Choose a project name.----------------${nc}"
echo ""
read -r -p " Enter : " project_name
echo ""
echo -e "${green}---------------Enter the type of server.---------------${nc}"
echo ""
echo -e "${green}[cx11]${nc} --- ${green}[ 1/2gb 20GB    ]${nc} ~ ${red}[ €3.95 ]${nc}"
echo -e "${green}[cpx11]${nc} -- ${green}[ 2/2gb 40GB    ]${nc} ~ ${red}[ €4.62 ]${nc}"
echo -e "${green}[cx21]${nc} --- ${green}[ 2/4gb 40GB    ]${nc} ~ ${red}[ €5.82 ]${nc}"
echo -e "${green}[cpx21]${nc} -- ${green}[ 3/4gb 80GB    ]${nc} ~ ${red}[ €8.46 ]${nc}"
echo -e "${green}[cx31]${nc} --- ${green}[ 2/8gb 80GB    ]${nc} ~ ${red}[ €11.04 ]${nc}"
echo -e "${green}[cpx31]${nc} -- ${green}[ 4/8gb 160GB   ]${nc} ~ ${red}[ €15.72 ]${nc}"
echo -e "${green}[cx41]${nc} --- ${green}[ 4/16gb 160GB  ]${nc} ~ ${red}[ €20.28 ]${nc}"
echo -e "${green}[cpx41]${nc} -- ${green}[ 8/16gb 240GB  ]${nc} ~ ${red}[ €29.64 ]${nc}"
echo -e "${green}[cx51]${nc} --- ${green}[ 8/32gb 240GB  ]${nc} ~ ${red}[ €38.88 ]${nc}"
echo -e "${green}[cpx51]${nc} -- ${green}[ 16/32gb 360GB ]${nc} ~ ${red}[ €65.28 ]${nc}"
echo ""

pattern="^(cx|cpx)(11|21|31|41|51)$"

while true; do
  read -r -p " Enter : " type_value
  if [[ $type_value =~ $pattern ]]; then
    echo -e "${green}ok!${nc}"
    break
  else
    echo -e "${green}$type_value ${red}does not match the pattern${nc}"
  fi
done

echo -e "${green}-----How many servers ranges from 0 to 5-----${nc}"
echo ""
while true; do
  read -r -p " Enter : " count
  if [[ $count =~ ^[0-5]$ ]]; then
    echo -e "${green}ok!${nc}"
    break
  else
    echo -e "${red}ranges from 0 to 5 ${nc}"
  fi
done

echo -e "${green}You have selected ${red}${count}${green} servers like ${red}${type_value}${green} project name '${red}${project_name}${nc}' "

while true; do
    read -r -p "Continue to create ? (y/n) " answer
    case "$answer" in
    [Yy]*)
      :
      break
      ;;
    [Nn]*)
      exit 0
      break
      ;;
    *)
      echo -e "${red}Please answer y or n.${nc}"
      ;;
    esac
  done

mkdir -p "${projects_directory}/${project_name}"
cd "${projects_directory}/${project_name}"
cp "${path_terraform_vars}" .
cp "${path_ansible_vars}" .
sed -i 's/^server_count =.*/server_count = '"$count"'/' terraform.tfvars
sed -i 's/^host_group_name =.*/host_group_name = "'"$project_name"'"/' terraform.tfvars
sed -i 's/^type =.*/type = "'"$type_value"'"/' terraform.tfvars
git clone https://github.com/jonhespeto/ansible/
rsync -avq --exclude='hdcloud_terraform.sh' ansible/roles/instance/ .
rm -rf ansible/roles/
chown -R "$SUDO_USER":"$SUDO_USER" add_environments/ add_user/ docker_tls/ zabbix_agent/ zabbix_graphs/ ansible.cfg destroy.yml hetznercloud.tf hosts instancesterraform.yml variables.tf terraform.tfvars vars.yml
terraform init
terraform apply -auto-approve
