# Переходим в каталог sandbox и смотрим исходное содержимое
cd sandbox
ls -l
# Список всех выполняемых процессов записываем в Task_1
ps aux > Task_1
# Создаём каталог sandbox-2 и перемещаем туда Task_2 и Task_3
mkdir sandbox-2
mv Task_2 Task_3 sandbox-2
# Переписываем содержимое /bin/ls в Task_2
cat /bin/ls > sandbox-2/Task_2
# Переименовываем Task_2 в myls
mv sandbox-2/Task_2 sandbox-2/myls
# Права r-xr--r-- = 544
chmod 544 sandbox-2/myls
# Дописываем в Task_3 информацию о ядре системы
uname -a >> sandbox-2/Task_3
# Проверяем результат
ls -l
ls -l sandbox-2
head -5 Task_1
tail -2 sandbox-2/Task_3
