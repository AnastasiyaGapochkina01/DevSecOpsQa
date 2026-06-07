Запустить приложение https://github.com/AnastasiyaGapochkina01/cyberpunk-devops в k8s
1) Бэкенд запущен в количестве 3 реплик
2) Реализована liveness проба для бэкенда
3) База данных запущена через StatefulSet с PVC на 1Gi, режим доступа ReadWriteOnce
4) Доступы для подключения к БД берутся из Secret
