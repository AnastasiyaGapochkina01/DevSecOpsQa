1) Содать namespace `homework-2`
2) Собрать docker image для приложения https://gist.github.com/AnastasiyaGapochkina01/aca9245918b4d8a706f731b1837e2178 и запушить его в dockerhub
3) В namespace `homework-2` создать deployment с именем `demo-app`, который запускает 3 реплики приложения из п2
4) Задать ограничения по ресурсам в deployment `demo-app`
5) Задать пробы в deployment `demo-app`
6) Добавить в namespace `homework-2` service с именем `demo-app-svc` типа nodeport
7) Добавить в кластер Metrics API
8) Создать HPA для deployment `demo-app`:
- Минимум реплик: 2.
- Максимум реплик: 7.
- Целевое использование CPU: 60%
Пример запуска генератора нагрузки для тестов
```bash
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://web-service; done"
```
