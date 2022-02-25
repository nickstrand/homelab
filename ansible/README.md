# Install Ansible
```sudo apt-get install ansible```

# Run Playbooks
```ansible-playbook -i hosts -K playbooks/powerlevel10K.yaml```
```ansible-playbook -i hosts -K playbooks/updates.yaml --skip-tags norestart```
