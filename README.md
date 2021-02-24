<h1 align="center">SMES</h1>

<p align="center">

<img src="https://img.shields.io/badge/made%20for-GTA%20SA--MP-blue" >

<img src="https://img.shields.io/badge/Server-SRP%20|%20ERP%20|%20ARP%20|%20DRP%20|%20TRP-red">

<img src="https://img.shields.io/github/languages/top/qrlk/weather-and-time">

<img src="https://img.shields.io/badge/dynamic/json?color=blueviolet&label=users%20%28active%29&query=result&url=http%3A%2F%2Fqrlk.me%2Fdev%2Fmoonloader%2Fusers_active.php%3Fscript%3Dsmes">

<img src="https://img.shields.io/badge/dynamic/json?color=blueviolet&label=users%20%28all%20time%29&query=result&url=http%3A%2F%2Fqrlk.me%2Fdev%2Fmoonloader%2Fusers_all.php%3Fscript%3Dsmes">

<img src="https://img.shields.io/date/1553634000?label=released" >

</p>

A **[moonloader](https://gtaforums.com/topic/890987-moonloader/)** script that adds a full-fledged SMS messenger to the **[gta samp](https://sa-mp.com/)**.  

**SMES** captures the messages of a simple in-game SMS chat system and shows them in a more pleasant way.

It requires **[CLEO 4+](http://cleo.li/?lang=ru)**, **[SAMPFUNCS 5+](https://blast.hk/threads/17/page-59#post-279414)**, **[MoonImgui](https://blast.hk/threads/19292/)**, **[Samp.Lua](https://blast.hk/threads/14624/)**.

---

**The following description is in Russian, because it is the main language of the user base**.

# Описание
**SMES** - это lua скрипт для MoonLoader, который добавляет в игру **полноценный SMS-мессенджер**, полезный для игроков RP серверов.  
Поддерживаемые проекты: **Samp-Rp**, **Evolve-Rp**, **Advance-Rp**, **Diamond-Rp**, **Trinity-Rp**, **Trinity-Rpg**. 
<p align="center">
  <img src="https://github.com/qrlk/smes/raw/master/screens/1.png" alt="Sublime's custom image"/>
</p>

# Функции
* Полноценный GUI мессенджер с диалогами, историей сообщений и многим другим.
* **СУБД**. Все ваши переписки могут храниться в отдельной базе данных, т.е. вы не потеряете свои диалоги после выхода из игры.
  * **Важно: все ваши смс хранятся в файле на вашем компьютере, а не у меня на сервере.**
* Возможность закрепить диалоги с друзьями: в списке они будут выше остальных.
* Возможность заблокировать собеседника: сообщения от него не будут вас тревожить.
* Хоткей открытия диалога с последней смс.
* Хоткей открытия мессенджера с фокусом на начало нового диалога.
* Автоматическое разрешение зависимостей (скрипт сам скачает все библиотеки, которые ему нужны).
* Непрочитанные диалоги меняют цвет, показывается количество непрочитанных сообщений.
* Кнопка создания нового диалога. Вписываешь в поле id, ник, если есть совпадение - выводится подсказка. Потом enter и всё - диалог создан.
* Фильтр по нику и онлайну.
* Автоопределитель номера по id/нику (DRP/TRP).
* Проверка на то, АФК ли собеседник (SRP).
* Возможность очистить диалог.
* Возможность удалить диалог.
* Возможность скрыть входящие смс в чате.
* Возможность изменить цвет входящих смс в чате.
* Возможность скрыть исходящие смс в чате.
* Возможность изменить цвет исходящих смс в чате.
* Возможность скрыть "Сообщение доставлено" в чате (SRP/ERP).
* Возможность изменить цвет "Сообщение доставлено" в чате (SRP/ERP).
* Звуковые уведомления о входящих и исходящих смс.
* Активация по хоткею и команде.
* Хоткей установки фокуса на ввод сообщения в активном диалоге.
* Настройка внешнего вида мессенджера.


Для запуска скрипта требуется: [SA-MP 0.3.7-R1](http://files.sa-mp.com/sa-mp-0.3.7-install.exe) и [MoonLoader 026+](http://blast.hk/moonloader/download.php).  
Зависимости: [CLEO 4+](http://cleo.li/?lang=ru), [SAMPFUNCS](https://blast.hk/threads/17/page-59#post-279414), [MoonImgui](https://blast.hk/threads/19292/), [Samp.Lua](https://blast.hk/threads/14624/).  
P.S. Скрипт может установить зависимости самостоятельно.  
Активация: /smes. 

# Скриншоты
<p align="center">
  <img src="https://github.com/qrlk/smes/raw/master/screens/2.png" alt="Sublime's custom image"/>
  <img src="https://github.com/qrlk/smes/raw/master/screens/3.png" alt="Sublime's custom image"/>
  <img src="https://github.com/qrlk/smes/raw/master/screens/4.png" alt="Sublime's custom image"/>
  <img src="https://github.com/qrlk/smes/raw/master/screens/5.png" alt="Sublime's custom image"/>
  <img src="https://github.com/qrlk/smes/raw/master/screens/6.png" alt="Sublime's custom image"/>
  <img src="https://github.com/qrlk/smes/raw/master/screens/7.png" alt="Sublime's custom image"/>
  <img src="https://github.com/qrlk/smes/raw/master/screens/8.png" alt="Sublime's custom image"/>
</p>

## Ссылки
* [Тема на blasthack](https://blast.hk/threads/32191/)
* [Авторский обзор](https://www.youtube.com/watch?v=JkdDO7obIJo)
