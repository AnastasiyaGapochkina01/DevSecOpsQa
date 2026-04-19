How to run these playbooks:

# Run Docker installation
ansible-playbook -i inventory install_docker.yml

# Run app config creation
ansible-playbook -i inventory create_app_config.yml

# Run backup user setup
ansible-playbook -i inventory create_backup_user.yml

# Run rsync setup (make sure rsync.conf.j2 is in templates/ directory)
ansible-playbook -i inventory setup_rsync.yml

# Or run all playbooks sequentially
for playbook in install_docker.yml create_app_config.yml create_backup_user.yml setup_rsync.yml; do
    ansible-playbook -i inventory $playbook
done







Directory structure needed:
ansible/
├── install_docker.yml
├── create_app_config.yml
├── create_backup_user.yml
├── setup_rsync.yml
├── templates/
│   └── rsync.conf.j2
└── inventory (your hosts file)



