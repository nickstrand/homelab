# Install Ansible
```sudo apt-get install ansible```

# Run Playbooks
- `ansible-playbook -i hosts -K playbooks/powerlevel10K.yaml`
- `ansible-playbook -i hosts -K playbooks/updates.yaml --tags restart`
- `ansible-playbook -i hosts -K playbooks/newserver.yaml`

# AWX Playbook additions
To get the admin password
```kubectl get secret awx-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode```
See also: 
https://computingforgeeks.com/how-to-install-ansible-awx-on-ubuntu-linux/
