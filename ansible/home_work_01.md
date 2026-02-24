1) Написать плейбук по установке docker
2) Написать плейбук, который выполняет следующие действия
- создает директорию `/opt/demo_app/config`
- копирует файл `app.conf` в `/opt/demo_app/config/app.conf` (содержимое файла `app.conf` придумать любое)
3) Написать плейбук, который
- создает пользователя `backuper`
- создает каталог `/opt/backups` с владельцем `backuper`
- скопирует скрипт `backup.sh` в `/opt/backups` так, чтобы `backuper` мог его запускать
4) Написать плейбук, который
- установит `rsync`
- создаст каталог `/etc/rsync.d` с правами `755`
- отрендерит шаблон `rsync.conf.j2` в `/etc/rsync.d/app.conf` с правами `0644`

`rsync.conf.j2`
```jinja2
pid file = /var/run/rsyncd.pid
port = 873
log file = /var/log/rsyncd.log
lock file = /var/run/rsyncd.lock
use chroot = true
reverse lookup = no

[app_backup]
path = {{ backup_path | default('/backup') }}
comment = Backup directory for demo application
read only = true
auth users = {{ rsync_user | default('backupuser') }}
secrets file = /etc/rsyncd.secrets
{% if log_level == 'debug' %}
log format = %t %a %m %f %i %o %l
{% endif %}
max connections = 10
```
