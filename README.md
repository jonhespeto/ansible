This script starts the process of creating a server on the Hetzner cloud using terraform , and then starts the ansible roles.
The roles include :
- creating a new user with ssh_key authorization , password and root login authorization disabled
- Install docker and protect daemon socket with tls certificates.
- Installation of the zabbix agent 6.4 , including auto connection to the server via tls PSK
-  creating a dashboard on the zabbix server with graphs by your project name
- adding to the Portainer server environment with the project name by TLS certs
- and also include rules in ufw , adding ip addresses to the white list for zabbix and zabbix agetn ports

You need to interactively specify the number , project name and type.

## Howto start (Ubuntu):
```
sudo curl -O "https://raw.githubusercontent.com/jonhespeto/ansible/master/roles/instance/hdcloud_terraform.sh" && sudo chmod +x hdcloud_terraform.sh && sudo bash hdcloud_terraform.sh
```
## Notes
### To work we will need files with variables for ansible and terraform , which will include tokens and more.
