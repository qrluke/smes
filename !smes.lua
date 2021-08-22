require "lib.moonloader"
--meta
script_name("SMES")
script_author("qrlk")
script_version("22.08.2021")
script_dependencies('CLEO 4+', 'SAMPFUNCS', 'Dear Imgui', 'SAMP.Lua')
script_moonloader(026)
script_url("https://github.com/qrlk/smes")
script_changelog = [[  v22.08.2021
* UPD: Добавлено определена мода сервера по его названию.
* UPD: Система автообновления обновлена до последней версии.

  v11.05.2021
* UPD: Обновлены IP адреса серверов.

  v04.05.2021
* UPD: Обновлены IP адреса серверов.

  v23.02.2021
* UPD: Мелкое изменение системы автообновления и статистики.

  v2.16 [24.11.2020]
* UPD: Обновлены IP адреса серверов.

  v2.15 [01.06.2020]
* UPD: Обновлены IP адреса серверов.

  v2.1 [22.09.2019]
* FIX: Проверка афк адаптирована под обновление sleep (SRP).

  v2.0 [22.09.2019]
* INFO: Open Source.

	v1.27 [01.05.2019]
* FIX: Восстановление работоспособности
* UPD: Изменён формат отображения даты с европейского на СНГ.

	v1.26 [02.04.2019]
* FIX: Улучшен захват смсок на ERP.
* FIX: Фикс фикса краша при настройке звука через клавиатуру вне доступного диапазона.

	v1.25 [31.03.2019]
* UPD: Обновлен шаблон смски для ERP, гении зачем-то точку добавили в конце.

	v1.23 [30.03.2019]
* UPD: Переписана логика отрисовки диалогов, теперь количество сообщений активного диалога влияет на фпс в ~500 раз меньше.
* UPD: Оптимизирован модуль информации о собеседнике: скорость отрисовки кадра увеличена в три раза.
* UPD: Оптимизирован список диалогов для лучшей производительности.
* UPD: Теперь "Ваш_Ник достает мобильник скрывается если скрыты исходящие смс (ERP)".
* UPD: Теперь smes игнорирует смс от бота Малевича (ERP).
* UPD: Теперь smes сверяет номер собеседника. Если собеседник изменил номер, напишите ему одну смс вручную/пусть он вам напишет и номер обновится в БД (ARP/TRP/DRP).
* FIX: Фикс краша при настройке звука через клавиатуру вне доступного диапазона.

	v1.11 [28.03.2019]
* NEW: Добавлен хоткей фокуса на ввод: при нажатии устанавливается фокус на ввод сообщения в активном диалоге.
* NEW: Добавлена поддержка Trinity-RPG.
* UPD: Размеры селектора звуков увеличены.
* FIX: Исправлен баг хоткея быстрого ответа на смс (мессенджер не открывался если уже был выбран нужный диалог).
* FIX: Исправлен баг, когда хоткей создания диалога не работал как нужно.
* FIX: Уведомление о запуске скрипта больше не показывается на неподдерживаемых серверах (скрипт не запускался, но уведомление показывалось).
* FIX: Исправлен баг, когда курсор оставался после ввода кода активации PREMIUM.
* FIX: Исправлен баг, когда курсор оставался после перезапуска скрипта через менеджер лицензий.
* FIX: Исправлен баг, когда машина тормозила после фокуса на окно ввода текста.
* FIX: Исправлен редкий баг, когда управление персонажем блокировалось, если было закрыто окно мессенджера с активным окном созданием диалога.

	v1.0 [27.03.2019]
* Релиз.]]
--require
do
  -- This is your secret 67-bit key (any random bits are OK)
  local Key53 = 8186484168865098
  local Key14 = 4887

  local inv256

  function decode(str)
    local K, F = Key53, 16384 + Key14
    return (str:gsub('%x%x',
      function(c)
      local L = K % 274877906944 -- 2^38
      local H = (K - L) / 274877906944
      local M = H % 128
      c = tonumber(c, 16)
      local m = (c + (H - M) / 128) * (2 * M + 1) % 256
      K = L * F + H + c + m
      return string.char(m)
    end))
  end
end

do
  function r_smart_cleo_and_sampfuncs()
    if isSampfuncsLoaded() == false then
      while not isPlayerPlaying(PLAYER_HANDLE) do wait(100) end
      wait(1000)
      setPlayerControl(PLAYER_HANDLE, false)
      setGxtEntry('CMLUTTL', 'SMES')
      setGxtEntry('CMLUMSG', 'Skriptu nuzhen SAMPFUNCS.asi dlya raboty.~n~~w~Esli net CLEO, to tozhe budet ustanovlen.~n~~w~Hotite chtoby ya ego skachal?~n~~w~')
      setGxtEntry('CMLUYES', 'Da!')
      setGxtEntry('CMLUY', 'Ne, otkroy ssylku, ia sam!')
      setGxtEntry('CMLUNO', 'Net!')
      local menu = createMenu('CMLUTTL', 120, 110, 400, 1, true, true, 1)
      local dummy = 'DUMMY'
      setMenuColumn(menu, 0, 'CMLUMSG', dummy, dummy, dummy, dummy, 'CMLUYES', 'CMLUY', 'CMLUNO', dummy, dummy, dummy, dummy, dummy, dummy)
      setActiveMenuItem(menu, 4)
      while true do
        wait(0)
        if isButtonPressed(PLAYER_HANDLE, 15) or isButtonPressed(PLAYER_HANDLE, 16) then
          if getMenuItemSelected(menu) == 4 then
            pass = true
            if not isCleoLoaded() then
              pass = false
              downloadUrlToFile("https://github.com/qrlk/smes/raw/master/deps/cleo.asi", getGameDirectory().."\\cleo.asi",
                function(id, status, p1, p2)
                  if status == 5 then
                    printStringNow(string.format("CLEO.asi: %d KB / %d KB", p1 / 1000, p2 / 1000), 5000)
                  elseif status == 58 then
                    printStringNow("CLEO.asi installed.", 5000)
                    pass = true
                  end
                end
              )
            end
            while pass ~= true do wait(100) end
            downloadUrlToFile("https://github.com/qrlk/smes/raw/master/deps/SAMPFUNCS.asi", getGameDirectory().."\\SAMPFUNCS.asi",
              function(id, status, p1, p2)
                if status == 5 then
                  printStringNow(string.format("SAMPFUNCS.asi: %d KB / %d KB", p1 / 1000, p2 / 1000), 5000)
                elseif status == 58 then
                  printStringNow("Installed. You MUST RESTART the game!", 5000)
                  thisScript():unload()
                end
              end
            )
          end
          if getMenuItemSelected(menu) == 5 then
            local ffi = require 'ffi'
            ffi.cdef [[
							void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
							uint32_t __stdcall CoInitializeEx(void*, uint32_t);
						]]
            local shell32 = ffi.load 'Shell32'
            local ole32 = ffi.load 'Ole32'
            ole32.CoInitializeEx(nil, 2 + 4) -- COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
            deleteMenu(menu)
            print(shell32.ShellExecuteA(nil, 'open', 'https://blast.hk/threads/17/', nil, nil, 1))
            thisScript():unload()
          end
          break
        end
      end
      wait(0)
      deleteMenu(menu)
      setPlayerControl(PLAYER_HANDLE, true)
    end
  end

  function r_smart_lib_imgui()
    if not pcall(function() imgui = require 'imgui' end) then
      waiter = true
      local prefix = "[SMES]: "
      local color = 0xffa500
      sampAddChatMessage(prefix.."Модуль Dear ImGui загружен неудачно. Для работы скрипта этот модуль обязателен.", color)
      sampAddChatMessage(prefix.."Средство автоматического исправления ошибок может попробовать скачать модуль за вас.", color)
      sampAddChatMessage(prefix.."Нажмите F2, чтобы запустить средство автоматического исправления ошибок.", color)
      while not wasKeyPressed(113) do wait(10) end
      if wasKeyPressed(113) then
        sampAddChatMessage(prefix.."Запускаю средство автоматического исправления ошибок.", color)
        local imguifiles = {
          [getGameDirectory().."\\moonloader\\lib\\imgui.lua"] = "https://raw.githubusercontent.com/qrlk/smes/master/lib/imgui.lua",
          [getGameDirectory().."\\moonloader\\lib\\MoonImGui.dll"] = "https://github.com/qrlk/smes/raw/master/lib/MoonImGui.dll"
        }
        createDirectory(getGameDirectory().."\\moonloader\\lib\\")
        for k, v in pairs(imguifiles) do
          if doesFileExist(k) then
            sampAddChatMessage(prefix.."Файл "..k.." найден.", color)
            sampAddChatMessage(prefix.."Удаляю "..k.." и скачиваю последнюю доступную версию.", color)
            os.remove(k)
          else
            sampAddChatMessage(prefix.."Файл "..k.." не найден.", color)
          end
          sampAddChatMessage(prefix.."Ссылка: "..v..". Пробую скачать.", color)
          pass = false
          wait(1500)
          downloadUrlToFile(v, k,
            function(id, status, p1, p2)
              if status == 5 then
                sampAddChatMessage(string.format(prefix..k..' - Загружено %d KB из %d KB.', p1 / 1000, p2 / 1000), color)
              elseif status == 58 then
                sampAddChatMessage(prefix..k..' - Загрузка завершена.', color)
                pass = true
              end
            end
          )
          while pass == false do wait(1) end
        end
        sampAddChatMessage(prefix.."Кажется, все файлы загружены. Попробую запустить модуль Dear ImGui ещё раз.", color)
        local status, err = pcall(function() imgui = require 'imgui' end)
        if status then
          sampAddChatMessage(prefix.."Модуль Dear ImGui успешно загружен!", color)
          waiter = false
          waitforreload = true
        else
          sampAddChatMessage(prefix.."Модуль Dear ImGui загружен неудачно!", color)
          sampAddChatMessage(prefix.."Обратитесь в поддержку скрипта (vk.me/qrlk.mods), приложив файл moonloader.log", color)
          print(err)
          for k, v in pairs(imguifiles) do
            print(k.." - "..tostring(doesFileExist(k)).." from "..v)
          end
          thisScript():unload()
        end
      end
    end
    while waiter do wait(100) end
  end

  function r_smart_lib_samp_events()
    if not pcall(function() RPC = require 'lib.samp.events' end) then
      waiter = true
      local prefix = "[SMES]: "
      local color = 0xffa500
      sampAddChatMessage(prefix.."Модуль SAMP.Lua загружен неудачно. Для работы скрипта этот модуль обязателен.", color)
      sampAddChatMessage(prefix.."Средство автоматического исправления ошибок может попробовать скачать модуль за вас.", color)
      sampAddChatMessage(prefix.."Нажмите F2, чтобы запустить средство автоматического исправления ошибок.", color)
      while not wasKeyPressed(113) do wait(10) end
      if wasKeyPressed(113) then
        sampAddChatMessage(prefix.."Запускаю средство автоматического исправления ошибок.", color)
        local sampluafiles = {
          [getGameDirectory().."\\moonloader\\lib\\samp\\events.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\raknet.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/raknet.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\synchronization.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/synchronization.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\bitstream_io.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/bitstream_io.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\core.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/core.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\bitstream_io.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/bitstream_io.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\extra_types.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/extra_types.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\handlers.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/handlers.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\utils.lua"] = "https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/utils.lua",
        }
        createDirectory(getGameDirectory().."\\moonloader\\lib\\samp\\events")
        for k, v in pairs(sampluafiles) do
          if doesFileExist(k) then
            sampAddChatMessage(prefix.."Файл "..k.." найден.", color)
            sampAddChatMessage(prefix.."Удаляю "..k.." и скачиваю последнюю доступную версию.", color)
            os.remove(k)
          else
            sampAddChatMessage(prefix.."Файл "..k.." не найден.", color)
          end
          sampAddChatMessage(prefix.."Ссылка: "..v..". Пробую скачать.", color)
          pass = false
          wait(1500)
          downloadUrlToFile(v, k,
            function(id, status, p1, p2)
              if status == 5 then
                sampAddChatMessage(string.format(prefix..k..' - Загружено %d KB из %d KB.', p1 / 1000, p2 / 1000), color)
              elseif status == 58 then
                sampAddChatMessage(prefix..k..' - Загрузка завершена.', color)
                pass = true
              end
            end
          )
          while pass == false do wait(1) end
        end
        sampAddChatMessage(prefix.."Кажется, все файлы загружены. Попробую запустить модуль SAMP.Lua ещё раз.", color)
        local status1, err = pcall(function() RPC = require 'lib.samp.events' end)
        if status1 then
          sampAddChatMessage(prefix.."Модуль SAMP.Lua успешно загружен!", color)
          waiter = false
          waitforreload = true
        else
          sampAddChatMessage(prefix.."Модуль SAMP.Lua загружен неудачно!", color)
          sampAddChatMessage(prefix.."Обратитесь в поддержку скрипта (vk.me/qrlk.mods), приложив файл moonloader.log", color)
          print(err)
          for k, v in pairs(sampluafiles) do
            print(k.." - "..tostring(doesFileExist(k)).." from "..v)
          end
          thisScript():unload()
        end
      end
    end
    while waiter do wait(100) end
  end

  function r_smart_get_sounds()
    if not doesDirectoryExist(getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\") then
      createDirectory(getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\")
    end
    kols = 0
    if PREMIUM then
      currentaudiokolDD = tonumber(currentaudiokol)
    else
      currentaudiokolDD = 10
    end
    for i = 1, currentaudiokolDD do
      local file = getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\"..i..".mp3"
      if not doesFileExist(file) then
        kols = kols + 1
      end
    end
    if kols > 0 then
      local prefix = "[SMES]: "
      local color = 0xffa500
      sampAddChatMessage(prefix.."Для работы скрипта нужно докачать "..kols.." аудиофайлов.", color)
      sampAddChatMessage(prefix.."Нажмите F2, чтобы запустить скачивание аудиофайлов.", color)
      while not wasKeyPressed(113) do wait(10) end
      if wasKeyPressed(113) then
        for i = 1, currentaudiokolDD do
          local file = getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\"..i..".mp3"
          if not doesFileExist(file) then
            v = "https://github.com/qrlk/smes/raw/master/resource/smes/sounds/"..i..".mp3"
            k = file
            sampAddChatMessage(prefix..v.." -> "..k, color)
            pass = false
            wait(10)
            downloadUrlToFile(v, k,
              function(id, status, p1, p2)
                if status == 5 then
                  sampAddChatMessage(string.format(prefix..k..' - Загружено %d KB из %d KB.', p1 / 1000, p2 / 1000), color)
                elseif status == 58 then
                  sampAddChatMessage(prefix..k..' - Загрузка завершена.', color)
                  pass = true
                end
              end
            )
            while pass == false do wait(1) end
          end
        end
      end
    end
  end


  function r_lib_rkeys()

    --[[Register HotKey for MoonLoader
	   Author: DonHomka
	   Functions:
	      - bool result, int id = registerHotKey(table keys, bool pressed, function callback)
	      - bool result, int count = unRegisterHotKey(table keys)
	      - bool result, int id = isHotKeyDefined(table keys)
	      - bool result, int id = blockNextHotKey(table keys)
	      - bool result, int count = unBlockNextHotKey(table keys)
	      - bool result, int id = isBlockedHotKey(table keys)
	      - table keys = getCurrentHotKey()
	      - table keys = getAllHotKey()
	   HotKey data:
	      - table keys                  Return table keys for active hotkey
	      - bool pressed                True - wasKeyPressed() / False - isKeyDown()
	      - function callback           Call this function on active hotkey
	   E-mail: a.skinfy@gmail.com
	   VK: http://vk.com/DonHomka
	   TeleGramm: http://t.me/DonHomka
	   Discord: DonHomka#2534]]
    local vkeys = require 'vkeys'

    vkeys.key_names[vkeys.VK_LMENU] = "LAlt"
    vkeys.key_names[vkeys.VK_RMENU] = "RAlt"
    vkeys.key_names[vkeys.VK_LSHIFT] = "LShift"
    vkeys.key_names[vkeys.VK_RSHIFT] = "RShift"
    vkeys.key_names[vkeys.VK_LCONTROL] = "LCtrl"
    vkeys.key_names[vkeys.VK_RCONTROL] = "RCtrl"

    local tHotKey = {}
    local tKeyList = {}
    local tKeysCheck = {}
    local iCountCheck = 0
    local tBlockKeys = {[vkeys.VK_LMENU] = true, [vkeys.VK_RMENU] = true, [vkeys.VK_RSHIFT] = true, [vkeys.VK_LSHIFT] = true, [vkeys.VK_LCONTROL] = true, [vkeys.VK_RCONTROL] = true}
    local tModKeys = {[vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true}
    local tBlockNext = {}
    local module = {}
    module._VERSION = "1.0.7"
    module._MODKEYS = tModKeys
    module._LOCKKEYS = false

    local function getKeyNum(id)
      for k, v in pairs(tKeyList) do
        if v == id then
          return k
        end
      end
      return 0
    end

    function module.blockNextHotKey(keys)
      local bool = false
      if not module.isBlockedHotKey(keys) then
        tBlockNext[#tBlockNext + 1] = keys
        bool = true
      end
      return bool
    end

    function module.isHotKeyHotKey(keys, keys2)
      local bool
      for k, v in pairs(keys) do
        local lBool = true
        for i = 1, #keys2 do
          if v ~= keys2[i] then
            lBool = false
            break
          end
        end
        if lBool then
          bool = true
          break
        end
      end
      return bool
    end


    function module.isBlockedHotKey(keys)
      local bool, hkId = false, - 1
      for k, v in pairs(tBlockNext) do
        if module.isHotKeyHotKey(keys, v) then
          bool = true
          hkId = k
          break
        end
      end
      return bool, hkId
    end

    function module.unBlockNextHotKey(keys)
      local result = false
      local count = 0
      while module.isBlockedHotKey(keys) do
        local _, id = module.isBlockedHotKey(keys)
        tHotKey[id] = nil
        result = true
        count = count + 1
      end
      local id = 1
      for k, v in pairs(tBlockNext) do
        tBlockNext[id] = v
        id = id + 1
      end
      return result, count
    end

    function module.isKeyModified(id)
      return (tModKeys[id] or false) or (tBlockKeys[id] or false)
    end

    function module.isModifiedDown()
      local bool = false
      for k, v in pairs(tModKeys) do
        if isKeyDown(k) then
          bool = true
          break
        end
      end
      return bool
    end

    lua_thread.create(
      function ()
        while true do
          wait(0)
          local tDownKeys = module.getCurrentHotKey()
          for k, v in pairs(tHotKey) do
            if #v.keys > 0 then
              local bool = true
              for i = 1, #v.keys do
                if i ~= #v.keys and (getKeyNum(v.keys[i]) > getKeyNum(v.keys[i + 1]) or getKeyNum(v.keys[i]) == 0) then
                  bool = false
                  break
                elseif i == #v.keys and (v.pressed and not wasKeyPressed(v.keys[i]) or not v.pressed and not isKeyDown(v.keys[i])) or (#v.keys == 1 and module.isModifiedDown()) then
                  bool = false
                  break
                end
              end
              if bool and ((module.onHotKey and module.onHotKey(k, v.keys) ~= false) or module.onHotKey == nil) then
                local result, id = module.isBlockedHotKey(v.keys)
                if not result then
                  v.callback(k, v.keys)
                else
                  tBlockNext[id] = nil
                end
              end
            end
          end
        end
      end
    )

    function module.registerHotKey(keys, pressed, callback)
      tHotKey[#tHotKey + 1] = {keys = keys, pressed = pressed, callback = callback}
      return true, #tHotKey
    end

    function module.getAllHotKey()
      return tHotKey
    end

    function module.unRegisterHotKey(keys)
      local result = false
      local count = 0
      while module.isHotKeyDefined(keys) do
        local _, id = module.isHotKeyDefined(keys)
        tHotKey[id] = nil
        result = true
        count = count + 1
      end
      local id = 1
      local tNewHotKey = {}
      for k, v in pairs(tHotKey) do
        tNewHotKey[id] = v
        id = id + 1
      end
      tHotKey = tNewHotKey
      return result, count
    end

    function module.isHotKeyDefined(keys)
      local bool, hkId = false, - 1
      for k, v in pairs(tHotKey) do
        if module.isHotKeyHotKey(keys, v.keys) then
          bool = true
          hkId = k
          break
        end
      end
      return bool, hkId
    end

    function module.getKeysName(keys)
      local tKeysName = {}
      for k, v in ipairs(keys) do
        tKeysName[k] = vkeys.id_to_name(v)
      end
      return tKeysName
    end

    function module.getCurrentHotKey(type)
      local type = type or 0
      local tCurKeys = {}
      for k, v in pairs(vkeys) do
        if tBlockKeys[v] == nil then
          local num, down = getKeyNum(v), isKeyDown(v)
          if down and num == 0 then
            tKeyList[#tKeyList + 1] = v
          elseif num > 0 and not down then
            tKeyList[num] = nil
          end
        end
      end
      local i = 1
      for k, v in pairs(tKeyList) do
        tCurKeys[i] = type == 0 and v or vkeys.id_to_name(v)
        i = i + 1
      end
      return tCurKeys
    end

    return module
  end

  function r_lib_imcustom_hotkey()
    local vkeys = require 'vkeys'
    local rkeys = r_lib_rkeys()
    local wm = require 'lib.windows.message'

    local tBlockKeys = {[vkeys.VK_RETURN] = true, [vkeys.VK_T] = true, [vkeys.VK_F6] = true, [vkeys.VK_F8] = true}
    local tBlockChar = {[116] = true, [84] = true}
    local tBlockNextDown = {}
    local module = {}
    module._VERSION = "1.1.5"
    module._SETTINGS = {
      noKeysMessage = "No"
    }

    local tHotKeyData = {
      edit = nil,
      save = {}
    }
    local tKeys = {}

    function module.HotKey(name, keys, lastkeys, width)
      local width = width or 90
      local name = tostring(name)
      local lastkeys = lastkeys or {}
      local keys, bool = keys or {}, false
      lastkeys.v = keys.v

      local sKeys = table.concat(rkeys.getKeysName(keys.v), " + ")

      if #tHotKeyData.save > 0 and tostring(tHotKeyData.save[1]) == name then
        keys.v = tHotKeyData.save[2]
        sKeys = table.concat(rkeys.getKeysName(keys.v), " + ")
        tHotKeyData.save = {}
        bool = true
      elseif tHotKeyData.edit ~= nil and tostring(tHotKeyData.edit) == name then
        if #tKeys == 0 then
          sKeys = os.time() % 2 == 0 and module._SETTINGS.noKeysMessage or " "
        else
          sKeys = table.concat(rkeys.getKeysName(tKeys), " + ")
        end
      end

      imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
      imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
      imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
      if imgui.Button((tostring(sKeys):len() == 0 and module._SETTINGS.noKeysMessage or sKeys) .. name, imgui.ImVec2(width, 0)) then
        tHotKeyData.edit = name
      end
      imgui.PopStyleColor(3)
      return bool
    end

    function module.getCurrentEdit()
      return tHotKeyData.edit ~= nil
    end

    function module.getKeysList(bool)
      local bool = bool or false
      local tKeysList = {}
      if bool then
        for k, v in ipairs(tKeys) do
          tKeysList[k] = vkeys.id_to_name(v)
        end
      else
        tKeysList = tKeys
      end
      return tKeysList
    end

    function module.getKeyNumber(id)
      for k, v in ipairs(tKeys) do
        if v == id then
          return k
        end
      end
      return - 1
    end

    local function reloadKeysList()
      local tNewKeys = {}
      for k, v in pairs(tKeys) do
        tNewKeys[#tNewKeys + 1] = v
      end
      tKeys = tNewKeys
      return true
    end

    addEventHandler("onWindowMessage",
      function (msg, wparam, lparam)
        if tHotKeyData.edit ~= nil and msg == wm.WM_CHAR then
          if tBlockChar[wparam] then
            consumeWindowMessage(true, true)
          end
        end
        if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN then
          if tHotKeyData.edit ~= nil and wparam == vkeys.VK_ESCAPE then
            tKeys = {}
            tHotKeyData.edit = nil
            consumeWindowMessage(true, true)
          end
          if tHotKeyData.edit ~= nil and wparam == vkeys.VK_BACK then
            tHotKeyData.save = {tHotKeyData.edit, {}}
            tHotKeyData.edit = nil
            consumeWindowMessage(true, true)
          end
          local num = module.getKeyNumber(wparam)
          if num == -1 then
            tKeys[#tKeys + 1] = wparam
            if tHotKeyData.edit ~= nil then
              if not rkeys.isKeyModified(wparam) then
                tHotKeyData.save = {tHotKeyData.edit, tKeys}
                tHotKeyData.edit = nil
                tKeys = {}
                consumeWindowMessage(true, true)
              end
            end
          end
          reloadKeysList()
          if tHotKeyData.edit ~= nil then
            consumeWindowMessage(true, true)
          end
        elseif msg == wm.WM_KEYUP or msg == wm.WM_SYSKEYUP then
          local num = module.getKeyNumber(wparam)
          if num > - 1 then
            tKeys[num] = nil
          end
          reloadKeysList()
          if tHotKeyData.edit ~= nil then
            consumeWindowMessage(true, true)
          end
        end
      end
    )

    return module
  end

end
--------------------------------------VAR---------------------------------------
function var_require()
  r_smart_cleo_and_sampfuncs()
  while isSampfuncsLoaded() ~= true do wait(100) end
  while not isSampAvailable() do wait(10) end
  if getMoonloaderVersion() < 026 then
    local prefix = "[SMES]: "
    local color = 0xffa500
    sampAddChatMessage(prefix.."Ваша версия MoonLoader не поддерживается.", color)
    sampAddChatMessage("Пожалуйста, скачайте последнюю версию MoonLoader.", color)
    thisScript():unload()
  end

  currentprice = "0 RUB"
  currentbuylink = "http://qrlk.me"
  currentaudiokol = 100
  currentpromodis = "-%"
  update("http://qrlk.me/dev/moonloader/smes/stats.php", '['..string.upper(thisScript().name)..']: ', "http://qrlk.me/sampvk", "smeschangelog")
  openchangelog("smeschangelog", "http://qrlk.me/changelog/smes")
  while sampGetCurrentServerName() == "SA-MP" do wait(100) end

  if getmode(sampGetCurrentServerAddress()) == nil then
    print('сервер не поддерживается, завершаю работу')
    thisScript():unload()
  end
  r_smart_lib_imgui()
  ihk = r_lib_imcustom_hotkey()
  hk = r_lib_rkeys()
  while not sampIsLocalPlayerSpawned() do wait(1) end

  if getmode(sampGetCurrentServerAddress()) == nil then
    print('сервер не поддерживается, завершаю работу')
    thisScript():unload()
  end

  nokey()

  while PROVERKA ~= true do wait(100) end
  inicfg = require "inicfg"
  local _1, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  licensenick, licenseserver, licensemod = sampGetPlayerNickname(myid), sampGetCurrentServerAddress(), getmode(sampGetCurrentServerAddress())
  imgui_init()
  ihk._SETTINGS.noKeysMessage = ("-")
  encoding = require "encoding"
  encoding.default = 'CP1251'
  u8 = encoding.UTF8
  as_action = require('moonloader').audiostream_state
  key = require 'vkeys'
  apply_custom_style()
  var_cfg()
  var_imgui_ImBool()
  var_imgui_ImFloat4_ImColor()
  var_imgui_ImInt()
  var_imgui_ImBuffer()
  var_main()
  r_smart_get_sounds()
  r_smart_lib_samp_events()
  if mode == "samp-rp" then
    mode_samprp()
  end
  if mode == "evolve-rp" then
    mode_evolverp()
  end
  if mode == "advance-rp" then
    mode_advancerp()
  end
  if mode == "diamond-rp" then
    mode_diamondrp()
  end
  if mode == "trinity-rp" then
    mode_trinityrp()
  end
end

function nokey()
  PREMIUM = true
  mode = getmode(sampGetCurrentServerAddress())
  PROVERKA = true
end

function var_cfg()
  cfg = inicfg.load({
    options =
    {
      MouseDrawCursor = false,
      ReplaceSmsInColor = true,
      ReplaceSmsOutColor = false,
      ReplaceSmsReceivedColor = false,
      HideSmsIn = false,
      HideSmsOut = false,
      HideSmsReceived = true,
      SoundSmsIn = false,
      SoundSmsInNumber = 6,
      SoundSmsOut = true,
      SoundSmsOutNumber = 8,
      settingstab = 1,
    },
    hkMainMenu = {
      [1] = 90
    },
    hkm4 = {
      [1] = 55
    },
    hkm5 = {
      [1] = 56
    },
    hkm6 = {
      [1] = 13
    },
    colors =
    {
      SmsInColor = imgui.ImColor(0, 255, 166):GetU32(),
      SmsOutColor = imgui.ImColor(255, 255, 255):GetU32(),
      SmsReceivedColor = imgui.ImColor(255, 255, 255):GetU32(),
    },
    menuwindow =
    {
      Width = 800,
      Height = 400,
      PosX = 80,
      PosY = 310,
    },
    messanger =
    {
      hotkey4 = true,
      hotkey5 = true,
      hotkey6 = true,
      storesms = true,
      iSMSfilterBool = false,
      activesms = true,
      mode = 1,
      Height = 300,
      SmsInColor = imgui.ImColor(66.3, 150.45, 249.9, 102):GetU32(),
      SmsOutColor = imgui.ImColor(66.3, 150.45, 249.9, 102):GetU32(),
      SmsInTimeColor = imgui.ImColor(0, 0, 0):GetU32(),
      SmsOutTimeColor = imgui.ImColor(0, 0, 0):GetU32(),
      SmsInHeaderColor = imgui.ImColor(255, 255, 255):GetU32(),
      SmsOutHeaderColor = imgui.ImColor(255, 255, 255):GetU32(),
      SmsInTextColor = imgui.ImColor(255, 255, 255):GetU32(),
      SmsOutTextColor = imgui.ImColor(255, 255, 255):GetU32(),
      iChangeScrollSMS = true,
      iSetKeyboardSMS = true,
      iShowSHOWOFFLINESMS = true,
    },
  }, 'smes')
end

function var_imgui_ImBool()
  imgui.LockPlayer = false
  imgui.GetIO().MouseDrawCursor = cfg.options.MouseDrawCursor
  MouseDrawCursor = imgui.ImBool(cfg.options.MouseDrawCursor)
  read_only = imgui.ImBool(true)
  iReplaceSmsInColor = imgui.ImBool(cfg.options.ReplaceSmsInColor)
  iReplaceSmsOutColor = imgui.ImBool(cfg.options.ReplaceSmsOutColor)
  iReplaceSmsReceivedColor = imgui.ImBool(cfg.options.ReplaceSmsReceivedColor)
  iHideSmsIn = imgui.ImBool(cfg.options.HideSmsIn)
  iHideSmsOut = imgui.ImBool(cfg.options.HideSmsOut)
  iHideSmsReceived = imgui.ImBool(cfg.options.HideSmsReceived)
  imhk4 = imgui.ImBool(cfg.messanger.hotkey4)
  imhk5 = imgui.ImBool(cfg.messanger.hotkey5)
  imhk6 = imgui.ImBool(cfg.messanger.hotkey6)
  iChangeScrollSMS = imgui.ImBool(cfg.messanger.iChangeScrollSMS)
  iSetKeyboardSMS = imgui.ImBool(cfg.messanger.iSetKeyboardSMS)
  iShowSHOWOFFLINESMS = imgui.ImBool(cfg.messanger.iShowSHOWOFFLINESMS)
  iSoundSmsIn = imgui.ImBool(cfg.options.SoundSmsIn)
  iSoundSmsOut = imgui.ImBool(cfg.options.SoundSmsOut)
  iStoreSMS = imgui.ImBool(cfg.messanger.storesms)
  iSMSfilterBool = imgui.ImBool(cfg.messanger.iSMSfilterBool)
  main_window_state = imgui.ImBool(false)
end

function var_imgui_ImFloat4_ImColor()
  iSmsInTimeColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInTimeColor ):GetFloat4())
  iSmsInHeaderColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInHeaderColor):GetFloat4())
  iSmsInTextColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInTextColor):GetFloat4())

  iSmsOutTimeColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutTimeColor ):GetFloat4())
  iSmsOutTextColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutTextColor):GetFloat4())
  iSmsOutHeaderColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutHeaderColor):GetFloat4())

  iINcolor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInColor):GetFloat4())
  iOUTcolor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutColor):GetFloat4())

  SmsInColor = imgui.ImFloat4(imgui.ImColor(cfg.colors.SmsInColor):GetFloat4())
  SmsOutColor = imgui.ImFloat4(imgui.ImColor(cfg.colors.SmsOutColor):GetFloat4())
  SmsReceivedColor = imgui.ImFloat4(imgui.ImColor(cfg.colors.SmsReceivedColor):GetFloat4())
end

function var_imgui_ImInt()
  iSoundSmsInNumber = imgui.ImInt(cfg.options.SoundSmsInNumber)
  iSoundSmsOutNumber = imgui.ImInt(cfg.options.SoundSmsOutNumber)
  iMessangerHeight = imgui.ImInt(cfg.messanger.Height)
  iSettingsTab = imgui.ImInt(cfg.options.settingstab)
end

function var_imgui_ImBuffer()
  toActivate = imgui.ImBuffer(17)
  toAnswerSMS = imgui.ImBuffer(140)
  iSMSfilter = imgui.ImBuffer(64)
  iSMSAddDialog = imgui.ImBuffer(64)
  textSpur = imgui.ImBuffer(65536)
  changelog = imgui.ImBuffer(65536)
  changelog.v = u8:encode(script_changelog)
end

function var_main()
  hotkeys = {}
  hotk = {}
  hotke = {}
  smsafk = {}
  russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
  }
  file = getGameDirectory()..'\\moonloader\\resource\\smes\\suplog.csv'
  color = 0xffa500
  selected = 1
  selectedTAB = ""
  month_histogram = {}
  getfr = {}
  players = {}
  iYears = {}
  countall = 0
  ikkk = 0
  ScrollToDialogSMS = false
  LASTNICK_SMS = " "
  LASTID_SMS = -1
  ikkk = 0
  iooooo = 0
  kkk = -1
  kkkk = -1
  iaaaaa = 0
  iccccc = 0
  icccccb = 0
  iooooob = 0
  iaaaaab = 0
  DEBUG = false
  iAddSMS = false
  scroller = false
  kostilforscroll = false
  PLAYSMSIN = false
  PLAYSMSOUT = false
  SSDB_trigger = false
  SSDB1_trigger = false
  math.randomseed(os.time())
end
-------------------------------------MAIN---------------------------------------
function getonlinelist()
  while true do
    wait(500)
    onlineplayers = {}
    maxidnow = sampGetMaxPlayerId()

    for id = 0, maxidnow do
      if sampIsPlayerConnected(id) then
        onlineplayers[id] = sampGetPlayerNickname(id)
        maxid = id
      end
    end
    for k in pairs(sms) do
      if type(sms[k]) == "table" then
        for id in pairs(onlineplayers) do
          v = onlineplayers[id]
          if k == v and sms ~= nil and sms[k] ~= nil then
            sms[k]["id"] = id
            break
          end
          if id == maxid and sms ~= nil and sms[k] ~= nil then
            sms[k]["id"] = "-"
          end
        end
      end
    end
  end
end

function main()
  require_status = lua_thread.create(var_require)
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end
  while require_status:status() ~= "dead" do wait(10) end
  textSpur.v = u8:encode("-")
  if waitforreload then thisScript():reload() wait(1000) end
  while PROVERKA ~= true do wait(10) end
  if PROVERKA == true then
    main_init_sms()
    main_init_hotkeys()
    main_ImColorToHEX()
    main_copyright()
    sampRegisterChatCommand("smes",
      function()
        main_window_state.v = not main_window_state.v
      end
    )
    sampRegisterChatCommand("smesdebug",
      function()
        lua_thread.create(
          function()
            DEBUG = not DEBUG
            main_window_state.v = true
            selecteddialogSMS = "qrlk"
            math.randomseed(os.time())
            --[[for i = 1, 1000 do
              --RPC.onServerMessage(-1, " SMS: Тестовое сообщения для проблемы BBB. Отправитель: qrlk[16]")
							RPC.onServerMessage(-1, " SMS: Привет. Получатель: qrlk[16]")
              RPC.onServerMessage(-1, " SMS: Привет. Отправитель: qrlk[16]")
              RPC.onServerMessage(-1, " SMS: Я пажилая струя. Получатель: qrlk[16]")
              RPC.onServerMessage(-1, " SMS: Кто я пажилая струя?. Отправитель: qrlk[16]")
              RPC.onServerMessage(-1, " SMS: Да ты!. Получатель: qrlk[16]")
              RPC.onServerMessage(-1, " SMS: А, ну тогда давай!. Отправитель: qrlk[16]")
            end]]
            for i = 1, 50 do
              RPC.onServerMessage(-1, " SMS: Привет. Получатель: qrlk"..math.random(1, 3000).."[16]")
            end
          end
        )
      end
    )
    lua_thread.create(imgui_messanger_scrollkostil)
    lua_thread.create(render)
    lua_thread.create(
      function ()
        while true do
          wait(100)
          if kostilforscroll and sms ~= {} and selecteddialogSMS ~= nil and sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["mousewheel"] ~= nil then
            if sms[selecteddialogSMS]["maxpos"] < sms[selecteddialogSMS]["maxvisible"] then
              if sms[selecteddialogSMS]["mousewheel"] < 0 then
                sms[selecteddialogSMS]["maxpos"] = sms[selecteddialogSMS]["maxpos"] - sms[selecteddialogSMS]["mousewheel"]
              end
            else
              if sms[selecteddialogSMS]["mousewheel"] > 0 then
                sms[selecteddialogSMS]["maxpos"] = sms[selecteddialogSMS]["maxpos"] - sms[selecteddialogSMS]["mousewheel"]
              end
            end
            kostilforscroll = false
          end
        end
      end
    )
    lua_thread.create(getonlinelist)
    inicfg.save(cfg, "smes")
    while true do
      wait(0)
      if iAddSMS then main_window_state.v = true end
      asdsadasads, myidasdas = sampGetPlayerIdByCharHandle(PLAYER_PED)
      if PREMIUM and (licensenick ~= sampGetPlayerNickname(myidasdas) or sampGetCurrentServerAddress() ~= licenseserver) then
        thisScript():unload()
      end
      main_while_playsounds()
      imgui.Process = main_window_state.v
    end
  else
    sampAddChatMessage(12 > true)
  end
end

function main_init_sms()
  if not doesDirectoryExist(getGameDirectory().."\\moonloader\\config\\smsmessanger\\") then
    createDirectory(getGameDirectory().."\\moonloader\\config\\smsmessanger\\")
  end
  _213, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  smsfile = getGameDirectory()..'\\moonloader\\config\\smsmessanger\\'..sampGetCurrentServerAddress().."-"..sampGetPlayerNickname(myid)..'.sms'
  imgui_messanger_sms_loadDB()
  lua_thread.create(imgui_messanger_sms_kostilsaveDB)
end

function main_init_hotkeys()
  hotkeys["hkMainMenu"] = {}
  for i = 1, #cfg.hkMainMenu do
    table.insert(hotkeys["hkMainMenu"], cfg["hkMainMenu"][i])
  end
  hk.unRegisterHotKey(hotkeys["hkMainMenu"])
  hk.registerHotKey(hotkeys["hkMainMenu"], true,
    function()
      if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
        main_window_state.v = not main_window_state.v
      end
    end
  )

  if cfg.messanger.hotkey6 then
    hotkeys["hkm6"] = {}
    for i = 1, #cfg.hkm6 do
      table.insert(hotkeys["hkm6"], cfg["hkm6"][i])
    end
    hk.unRegisterHotKey(hotkeys["hkm6"])
    hk.registerHotKey(hotkeys["hkm6"], true,
      function()
        if not sampIsChatInputActive() and not isSampfuncsConsoleActive() then
          if main_window_state.v and not iAddSMS and cfg.messanger.mode == 2 and selecteddialogSMS ~= nil then
            KeyboardFocusReset = true
          end
        end
      end
    )
  end

  if PREMIUM and cfg.messanger.activesms and cfg.messanger.hotkey4 then
    hotkeys["hkm4"] = {}
    for i = 1, #cfg.hkm4 do
      table.insert(hotkeys["hkm4"], cfg["hkm4"][i])
    end
    hk.unRegisterHotKey(hotkeys["hkm4"])
    hk.registerHotKey(hotkeys["hkm4"], true,
      function()
        if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
          imgui_messanger_FO(4)
        end
      end
    )
  end
  if PREMIUM and cfg.messanger.activesms and cfg.messanger.hotkey5 then
    hotkeys["hkm5"] = {}
    for i = 1, #cfg.hkm5 do
      table.insert(hotkeys["hkm5"], cfg["hkm5"][i])
    end
    hk.unRegisterHotKey(hotkeys["hkm5"])
    hk.registerHotKey(hotkeys["hkm5"], true,
      function()
        if not sampIsChatInputActive() and not sampIsDialogActive() and not isSampfuncsConsoleActive() then
          imgui_messanger_FO(5)
        end
      end
    )
  end
end

function main_ImColorToHEX()
  local r, g, b, a = imgui.ImColor.FromFloat4(SmsInColor.v[1], SmsInColor.v[2], SmsInColor.v[3], SmsInColor.v[4]):GetRGBA()
  SmsInColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)

  local r, g, b, a = imgui.ImColor.FromFloat4(SmsOutColor.v[1], SmsOutColor.v[2], SmsOutColor.v[3], SmsOutColor.v[4]):GetRGBA()
  SmsOutColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)

  local r, g, b, a = imgui.ImColor.FromFloat4(SmsReceivedColor.v[1], SmsReceivedColor.v[2], SmsReceivedColor.v[3], SmsReceivedColor.v[4]):GetRGBA()
  SmsReceivedColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)

  inicfg.save(cfg, "smes")
end

function main_copyright()
  local prefix = "[SMES]: "
  if PREMIUM then sampAddChatMessage(prefix.."Все системы готовы. Версия скрипта: "..thisScript().version..". Активация: /smes. Приятной игры, "..licensenick..".", 0xffa500) end
end

function main_while_playsounds()
  if PLAYSMSIN then
    PLAYSMSIN = false
    if not PREMIUM and iSoundSmsInNumber.v > 10 then iSoundSmsInNumber.v = math.random(1, 10) end
    a4 = loadAudioStream(getGameDirectory()..[[\moonloader\resource\smes\sounds\]]..iSoundSmsInNumber.v..[[.mp3]])
    if getAudioStreamState(a4) ~= as_action.PLAY then
      setAudioStreamState(a4, as_action.PLAY)
    end
  end
  if PLAYSMSOUT then
    PLAYSMSOUT = false
    if not PREMIUM and iSoundSmsOutNumber.v > 10 then iSoundSmsOutNumber.v = math.random(1, 10) end
    a5 = loadAudioStream(getGameDirectory()..[[\moonloader\resource\smes\sounds\]]..iSoundSmsOutNumber.v..[[.mp3]])
    if getAudioStreamState(a5) ~= as_action.PLAY then
      setAudioStreamState(a5, as_action.PLAY)
    end
  end
end
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
function getmode(args)
  local servers = {
    ["95.181.158.74"] = "samp-rp",
    ["95.181.158.63"] = "samp-rp",
    ["95.181.158.69"] = "samp-rp",
    ["95.181.158.77"] = "samp-rp",
    ["185.169.134.67"] = "evolve-rp",
    ["185.169.134.68"] = "evolve-rp",
    ["185.169.134.91"] = "evolve-rp",
    ["54.37.142.72"] = "advance-rp",
    ["54.37.142.73"] = "advance-rp",
    ["54.37.142.74"] = "advance-rp",
    ["54.37.142.75"] = "advance-rp",
    ["51.83.207.240"] = "diamond-rp",
    ["51.75.33.152"] = "diamond-rp",
    ["51.83.207.241"] = "diamond-rp",
    ["51.75.33.153"] = "diamond-rp",
    ["51.83.207.242"] = "diamond-rp",
    ["51.83.207.243"] = "diamond-rp",
    ["51.75.33.154"] = "diamond-rp",
    ["185.169.134.83"] = "trinity-rp",
    ["185.169.134.84"] = "trinity-rp",
    ["185.169.134.85"] = "trinity-rp"
  }
  return servers[args] or getModeByServerName(sampGetCurrentServerName())
end

local serversNames = {
  ["Samp-Rp"] = "samp-rp",
  ["Evolve-Rp"] = "evolve-rp",
  ["Advance"] = "advance-rp",
  ["Diamond"] = "diamond-rp",
  ["Trinity"] = "trinity-rp"
}

function getModeByServerName(sname)
  for k, v in pairs(serversNames) do
    if string.find(sname, k, 1, true) then
      return v
    end
  end
end

function fixforcarstop()
  if isCharInAnyCar(playerPed) and getDriverOfCar(getCarCharIsUsing(playerPed)) == playerPed and getCarSpeed(getCarCharIsUsing(playerPed)) > 10 then
    --  printString("control not locked", 1000)
  else
    lockPlayerControl(true)
  end
end

function mode_samprp()
  function RPC.onPlaySound(sound)
    if sound == 1052 and iSoundSmsOut.v then
      return false
    end
  end

  function RPC.onServerMessage(color, text)
    if main_window_state.v and text:match(" "..tostring(selecteddialogSMS).." %[(%d+)%]") then
      if string.find(text, "AFK") then
        smsafk[selecteddialogSMS] = "AFK "..string.match(text, "AFK: (%d+)").." s"
      else
        if string.find(text, "SLEEP") then
          smsafk[selecteddialogSMS] = "SLEEP "..string.match(text, "SLEEP: (%d+)").." s"
        else
          smsafk[selecteddialogSMS] = "NOT AFK"
        end
      end
      return false
    end
    if text:find("SMS") then
      text = string.gsub(text, "{FFFF00}", "")
      text = string.gsub(text, "{FF8000}", "")
      local smsText, smsNick, smsId = string.match(text, "^ SMS%: (.*)%. Отправитель%: (.*)%[(%d+)%]")
      if smsText and smsNick and smsId then
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if sms[smsNick] and sms[smsNick].Chat then

        else
          sms[smsNick] = {}
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        if sms[smsNick]["Blocked"] ~= nil and sms[smsNick]["Blocked"] == 1 then return false end
        if iSoundSmsIn.v then PLAYSMSIN = true end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = smsNick, type = "FROM", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        SSDB_trigger = true
        if not iHideSmsIn.v then
          if iReplaceSmsInColor.v then
            sampAddChatMessage(text, SmsInColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
      local smsText, smsNick, smsId = string.match(text, "^ SMS%: (.*)%. Получатель%: (.*)%[(%d+)%]")
      if smsText and smsNick and smsId then
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if iSoundSmsOut.v then PLAYSMSOUT = true end
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sms[smsNick] and sms[smsNick].Chat then

        else
          sms[smsNick] = {}
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = sampGetPlayerNickname(myid), type = "TO", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        if sampIsPlayerConnected(smsId) then
          if sms ~= nil and sms[sampGetPlayerNickname(smsId)] ~= nil and sms[sampGetPlayerNickname(smsId)]["Checked"] ~= nil then
            sms[sampGetPlayerNickname(smsId)]["Checked"] = os.time()
          end
        end
        SSDB_trigger = true
        if not iHideSmsOut.v then
          if iReplaceSmsOutColor.v then
            sampAddChatMessage(text, SmsOutColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
    end
    if text == " Сообщение доставлено" then
      if iHideSmsReceived.v then return false end
      if not iHideSmsReceived.v then
        if iReplaceSmsReceivedColor.v then
          sampAddChatMessage(text, SmsReceivedColor_HEX)
          return false
        else
          --do nothing
        end
      else
        return false
      end
    end
  end
  function sendsms()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - 70)
    if imgui.InputText("##keyboardSMSKA", toAnswerSMS, imgui.InputTextFlags.EnterReturnsTrue) then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" then
        sampSendChat("/t " .. k .. " " .. u8:decode(toAnswerSMS.v))
        toAnswerSMS.v = ''
      end
      KeyboardFocusReset = true

    end
    if imgui.IsItemActive() then
      fixforcarstop()
    else
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if imgui.SameLine() or imgui.Button(u8"Отправить") then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" then
        sampSendChat("/t " .. k .. " " .. u8:decode(toAnswerSMS.v))
        toAnswerSMS.v = ''
      end
      KeyboardFocusReset = true
    end
  end
  function getafk(i)
    sampSendChat("/id "..i)
  end
  function getafkbutton()
    if smsafk[selecteddialogSMS] == nil then smsafk[selecteddialogSMS] = "CHECK AFK" end
    imgui.SameLine(imgui.GetContentRegionAvailWidth() - imgui.CalcTextSize(smsafk[selecteddialogSMS]).x)
    if smsafk[selecteddialogSMS]:find("s") then
      imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 0, 0, 113):GetVec4())
    end
    if smsafk[selecteddialogSMS]:find("NOT") then
      imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(0, 255, 0, 113):GetVec4())
    end
    if imgui.Button(smsafk[selecteddialogSMS]) then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then
          getafk(i)
          break
        end
      end
    end
    if smsafk[selecteddialogSMS]:find("s") or smsafk[selecteddialogSMS]:find("NOT") then
      imgui.PopStyleColor()
    end
  end
  function hidesmssent()
    if imgui.Checkbox("##HideSmsReceived", iHideSmsReceived) then
      cfg.options.HideSmsReceived = iHideSmsReceived.v
      inicfg.save(cfg, "smes")
    end
    imgui.SameLine()
    if iHideSmsReceived.v then
      imgui.Text(u8("Скрывать \"Сообщение доставлено\"?"))
    else
      imgui.TextDisabled(u8"Скрывать \"Сообщение доставлено\"?")
    end
  end
  function changesmssent()
    if not cfg.options.HideSmsReceived then
      if imgui.Checkbox("##iReplaceSmsReceivedColor", iReplaceSmsReceivedColor) then
        cfg.options.ReplaceSmsReceivedColor = iReplaceSmsReceivedColor.v
        inicfg.save(cfg, "smes")
      end
      imgui.SameLine()
      if iReplaceSmsReceivedColor.v then
        imgui.Text(u8("Цвет \"SMS доставлено\" изменяется на: "))
        imgui.SameLine(295)
        imgui.Text("")
        imgui.SameLine()
        if imgui.ColorEdit4("##SmsReceivedColor", SmsReceivedColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha + imgui.ColorEditFlags.NoOptions) then
          cfg.colors.SmsReceivedColor = imgui.ImColor.FromFloat4(SmsReceivedColor.v[1], SmsReceivedColor.v[2], SmsReceivedColor.v[3], SmsReceivedColor.v[4]):GetU32()
          local r, g, b, a = imgui.ImColor.FromFloat4(SmsReceivedColor.v[1], SmsReceivedColor.v[2], SmsReceivedColor.v[3], SmsReceivedColor.v[4]):GetRGBA()
          SmsReceivedColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)
          inicfg.save(cfg, "smes")
        end
      else
        imgui.TextDisabled(u8"Изменять \"Сообщение доставлено\" в чате?")
      end
    end
  end
  function newdialog()
    if imgui.InputText("##keyboardSMADD", iSMSAddDialog, imgui.InputTextFlags.EnterReturnsTrue) then
      createnewdialognick = iSMSAddDialog.v
      if iSMSAddDialog.v == "" then
        ikkk = 0
        iAddSMS = false
        if isPlayerControlLocked() then lockPlayerControl(false) end
      else
        iSMSAddDialog.v = ""
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and i == tonumber(createnewdialognick) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(createnewdialognick)) then
            if sms[sampGetPlayerNickname(i)] == nil then
              sms[sampGetPlayerNickname(i)] = {}
              sms[sampGetPlayerNickname(i)]["Chat"] = {}
              sms[sampGetPlayerNickname(i)]["Checked"] = 0
              sms[sampGetPlayerNickname(i)]["Pinned"] = 0
              ikkk = 0
              iAddSMS = false
              table.insert(sms[sampGetPlayerNickname(i)]["Chat"], {text = "Диалог создан", Nick = "мессенджер", type = "service", time = os.time()})
              selecteddialogSMS = sampGetPlayerNickname(i)
              SSDB_trigger = true
              ScrollToDialogSMS = true
              keyboard = true
              break
            else
              selecteddialogSMS = sampGetPlayerNickname(i)
              ikkk = 0
              iAddSMS = false
              ScrollToDialogSMS = true
              keyboard = true
              break
            end
          end
        end
      end
    end
    if imgui.IsKeyPressed(key.VK_ESCAPE) then
      iSMSAddDialog.v = ""
      ikkk = 0
      iAddSMS = false
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if KeyboardFocusResetForNewDialog then imgui.SetKeyboardFocusHere() fixforcarstop() KeyboardFocusResetForNewDialog = false end
    if iSMSAddDialog.v ~= "" then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and i == tonumber(iSMSAddDialog.v) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(iSMSAddDialog.v)) then
          imgui.SetTooltip(u8:encode(sampGetPlayerNickname(i).."["..i.."]"))
          break
        end
      end
    end
  end
  function smsheader()
    imgui.BeginChild("##header", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
    if sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["Chat"] ~= nil then
      if math.random(1, 9999) % 20 < 1 then
        for id = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == tostring(selecteddialogSMS) then
            shId = id
            break
          end
          if id == sampGetMaxPlayerId() + 1 then shId = "-" end
        end
      end
      if shId ~= nil and shId == "-" then
        imgui.Text(u8:encode("[Оффлайн] Ник: "..tostring(selecteddialogSMS)..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
      else
        imgui.Text(u8:encode("[Онлайн] Ник: "..tostring(selecteddialogSMS)..". ID: "..tostring(shId)..". LVL: "..tostring(sampGetPlayerScore(tonumber(shId)))..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
        getafkbutton()
      end
    end
    imgui.EndChild()
  end
end

function mode_evolverp()
  function RPC.onPlaySound(sound)
    if sound == 1052 and iSoundSmsOut.v then
      return false
    end
  end

  function RPC.onServerMessage(color, text)
    if text:find("SMS") and not string.find(text, "Малевич$") then
      text = string.gsub(text, "{FFFF00}", "")
      text = string.gsub(text, "{FF8000}", "")
      local smsText, smsNick, smsId = string.match(text, "^ SMS%: (.*)%.% Отправитель%: (.*)%[(%d+)%]")
      if not string.match(text, "^ SMS%: (.*)%.% Отправитель%: (.*)%[(%d+)%]") then
        smsText, smsNick, smsId = string.match(text, "^ SMS%: (.*)% Отправитель%: (.*)%[(%d+)%]")
      end
      if smsText and smsNick and smsId then
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if sms[smsNick] and sms[smsNick].Chat then

        else
          sms[smsNick] = {}
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        if sms[smsNick]["Blocked"] ~= nil and sms[smsNick]["Blocked"] == 1 then return false end
        if iSoundSmsIn.v then PLAYSMSIN = true end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = smsNick, type = "FROM", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        SSDB_trigger = true
        if not iHideSmsIn.v then
          if iReplaceSmsInColor.v then
            sampAddChatMessage(text, SmsInColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
      local smsText, smsNick, smsId = string.match(text, "^ SMS%: (.*)%.% Получатель%: (.*)%[(%d+)%]")
      if not string.match(text, "^ SMS%: (.*)%.% Получатель%: (.*)%[(%d+)%]") then
        smsText, smsNick, smsId = string.match(text, "^ SMS%: (.*)% Получатель%: (.*)%[(%d+)%]")
      end
      if smsText and smsNick and smsId then
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if iSoundSmsOut.v then PLAYSMSOUT = true end
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sms[smsNick] and sms[smsNick].Chat then

        else
          sms[smsNick] = {}
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = sampGetPlayerNickname(myid), type = "TO", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        if sampIsPlayerConnected(smsId) then
          if sms ~= nil and sms[sampGetPlayerNickname(smsId)] ~= nil and sms[sampGetPlayerNickname(smsId)]["Checked"] ~= nil then
            sms[sampGetPlayerNickname(smsId)]["Checked"] = os.time()
          end
        end
        SSDB_trigger = true
        if not iHideSmsOut.v then
          if iReplaceSmsOutColor.v then
            sampAddChatMessage(text, SmsOutColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
    end
    if text == " Сообщение доставлено" or text == "- Сообщение доставлено" then
      if iHideSmsReceived.v then return false end
      if not iHideSmsReceived.v then
        if iReplaceSmsReceivedColor.v then
          sampAddChatMessage(text, SmsReceivedColor_HEX)
          return false
        else
          --do nothing
        end
      else
        return false
      end
    end
    _213, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if iHideSmsOut.v and text == " "..sampGetPlayerNickname(myid).." достает мобильник" then return false end

  end

  function sendsms()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - 70)
    if imgui.InputText("##keyboardSMSKA", toAnswerSMS, imgui.InputTextFlags.EnterReturnsTrue) then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" then
        sampSendChat("/t " .. k .. " " .. u8:decode(toAnswerSMS.v))
        toAnswerSMS.v = ''
      end
      KeyboardFocusReset = true

    end
    if imgui.IsItemActive() then
      fixforcarstop()
    else
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if imgui.SameLine() or imgui.Button(u8"Отправить") then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" then
        sampSendChat("/t " .. k .. " " .. u8:decode(toAnswerSMS.v))
        toAnswerSMS.v = ''
      end
      KeyboardFocusReset = true
    end
  end
  function getafk(i) end
  function getafkbutton() end
  function hidesmssent()
    if imgui.Checkbox("##HideSmsReceived", iHideSmsReceived) then
      cfg.options.HideSmsReceived = iHideSmsReceived.v
      inicfg.save(cfg, "smes")
    end
    imgui.SameLine()
    if iHideSmsReceived.v then
      imgui.Text(u8("Скрывать \"Сообщение доставлено\"?"))
    else
      imgui.TextDisabled(u8"Скрывать \"Сообщение доставлено\"?")
    end
  end
  function changesmssent()
    if not cfg.options.HideSmsReceived then
      if imgui.Checkbox("##iReplaceSmsReceivedColor", iReplaceSmsReceivedColor) then
        cfg.options.ReplaceSmsReceivedColor = iReplaceSmsReceivedColor.v
        inicfg.save(cfg, "smes")
      end
      imgui.SameLine()
      if iReplaceSmsReceivedColor.v then
        imgui.Text(u8("Цвет \"SMS доставлено\" изменяется на: "))
        imgui.SameLine(295)
        imgui.Text("")
        imgui.SameLine()
        if imgui.ColorEdit4("##SmsReceivedColor", SmsReceivedColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha + imgui.ColorEditFlags.NoOptions) then
          cfg.colors.SmsReceivedColor = imgui.ImColor.FromFloat4(SmsReceivedColor.v[1], SmsReceivedColor.v[2], SmsReceivedColor.v[3], SmsReceivedColor.v[4]):GetU32()
          local r, g, b, a = imgui.ImColor.FromFloat4(SmsReceivedColor.v[1], SmsReceivedColor.v[2], SmsReceivedColor.v[3], SmsReceivedColor.v[4]):GetRGBA()
          SmsReceivedColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)
          inicfg.save(cfg, "smes")
        end
      else
        imgui.TextDisabled(u8"Изменять \"Сообщение доставлено\" в чате?")
      end
    end
  end
  function newdialog()
    if imgui.InputText("##keyboardSMADD", iSMSAddDialog, imgui.InputTextFlags.EnterReturnsTrue) then
      createnewdialognick = iSMSAddDialog.v
      if iSMSAddDialog.v == "" then
        ikkk = 0
        iAddSMS = false
        if isPlayerControlLocked() then lockPlayerControl(false) end
      else
        iSMSAddDialog.v = ""
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and i == tonumber(createnewdialognick) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(createnewdialognick)) then
            if sms[sampGetPlayerNickname(i)] == nil then
              sms[sampGetPlayerNickname(i)] = {}
              sms[sampGetPlayerNickname(i)]["Chat"] = {}
              sms[sampGetPlayerNickname(i)]["Checked"] = 0
              sms[sampGetPlayerNickname(i)]["Pinned"] = 0
              ikkk = 0
              iAddSMS = false
              table.insert(sms[sampGetPlayerNickname(i)]["Chat"], {text = "Диалог создан", Nick = "мессенджер", type = "service", time = os.time()})
              selecteddialogSMS = sampGetPlayerNickname(i)
              SSDB_trigger = true
              ScrollToDialogSMS = true
              keyboard = true
              break
            else
              selecteddialogSMS = sampGetPlayerNickname(i)
              ikkk = 0
              iAddSMS = false
              ScrollToDialogSMS = true
              keyboard = true
              break
            end
          end
        end
      end
    end
    if imgui.IsKeyPressed(key.VK_ESCAPE) then
      iSMSAddDialog.v = ""
      ikkk = 0
      iAddSMS = false
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if KeyboardFocusResetForNewDialog then imgui.SetKeyboardFocusHere() fixforcarstop() KeyboardFocusResetForNewDialog = false end
    if iSMSAddDialog.v ~= "" then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and i == tonumber(iSMSAddDialog.v) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(iSMSAddDialog.v)) then
          imgui.SetTooltip(u8:encode(sampGetPlayerNickname(i).."["..i.."]"))
          break
        end
      end
    end
  end
  function smsheader()
    imgui.BeginChild("##header", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
    if sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["Chat"] ~= nil then
      if math.random(1, 9999) % 20 < 1 then
        for id = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == tostring(selecteddialogSMS) then
            shId = id
            break
          end
          if id == sampGetMaxPlayerId() + 1 then shId = "-" end
        end
      end
      if shId ~= nil and shId == "-" then
        imgui.Text(u8:encode("[Оффлайн] Ник: "..tostring(selecteddialogSMS)..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
      else
        imgui.Text(u8:encode("[Онлайн] Ник: "..tostring(selecteddialogSMS)..". ID: "..tostring(shId)..". LVL: "..tostring(sampGetPlayerScore(tonumber(shId)))..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
        getafkbutton()
      end
    end
    imgui.EndChild()
  end
end

function mode_advancerp()
  function RPC.onServerMessage(color, text)
    if text:find("SMS") then
      text = string.gsub(text, "{FFFF00}", "")
      text = string.gsub(text, "{FF8000}", "")
      local smsText, smsNick, smsNumber = string.match(text, "SMS%: (.*)% %| Отправитель%: (.*) %[т.(%d+)%]")
      if smsText and smsNick and smsNumber then
        smsId = 1001
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == smsNick then
            smsId = i
            break
          end
        end
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if sms[smsNick] and sms[smsNick].Chat then
          if sms[smsNick]["Number"] ~= smsNumber then sms[smsNick]["Number"] = smsNumber end
        else
          sms[smsNick] = {}
          sms[smsNick]["Number"] = smsNumber
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        if sms[smsNick]["Blocked"] ~= nil and sms[smsNick]["Blocked"] == 1 then return false end
        if iSoundSmsIn.v then PLAYSMSIN = true end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = smsNick, type = "FROM", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        SSDB_trigger = true
        if not iHideSmsIn.v then
          if iReplaceSmsInColor.v then
            sampAddChatMessage(text, SmsInColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
      local smsText, smsNick, smsNumber = string.match(text, "SMS%: (.*)% %| Получатель%: (.*) %[т.(%d+)%]")
      if smsText and smsNick and smsNumber then
        smsId = 1001
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == smsNick then
            smsId = i
            break
          end
        end
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if iSoundSmsOut.v then PLAYSMSOUT = true end
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sms[smsNick] and sms[smsNick].Chat then
          if sms[smsNick]["Number"] ~= smsNumber then sms[smsNick]["Number"] = smsNumber end
        else
          sms[smsNick] = {}
          sms[smsNick]["Number"] = smsNumber
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = sampGetPlayerNickname(myid), type = "TO", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        if sampIsPlayerConnected(smsId) then
          if sms ~= nil and sms[sampGetPlayerNickname(smsId)] ~= nil and sms[sampGetPlayerNickname(smsId)]["Checked"] ~= nil then
            sms[sampGetPlayerNickname(smsId)]["Checked"] = os.time()
          end
        end
        SSDB_trigger = true
        if not iHideSmsOut.v then
          if iReplaceSmsOutColor.v then
            sampAddChatMessage(text, SmsOutColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
    end
  end
  function sendsms()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - 70)
    if imgui.InputText("##keyboardSMSKA", toAnswerSMS, imgui.InputTextFlags.EnterReturnsTrue) then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" and sms[selecteddialogSMS]["Number"] ~= nil then
        sampSendChat("/sms " .. sms[selecteddialogSMS]["Number"] .. " " .. u8:decode(toAnswerSMS.v))
        toAnswerSMS.v = ''
      end
      KeyboardFocusReset = true

    end
    if imgui.IsItemActive() then
      fixforcarstop()
    else
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if imgui.SameLine() or imgui.Button(u8"Отправить") then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" and sms[selecteddialogSMS]["Number"] ~= nil then
        sampSendChat("/sms " .. sms[selecteddialogSMS]["Number"] .. " " .. u8:decode(toAnswerSMS.v))
        toAnswerSMS.v = ''
      end
      KeyboardFocusReset = true
    end
  end
  function getafk(i) end
  function getafkbutton() end
  function hidesmssent() end
  function changesmssent() end
  function newdialog()
    if imgui.InputText("##keyboardSMADD", iSMSAddDialog, imgui.InputTextFlags.EnterReturnsTrue) then
      createnewdialognick = iSMSAddDialog.v
      if iSMSAddDialog.v == "" then
        ikkk = 0
        iAddSMS = false
        if isPlayerControlLocked() then lockPlayerControl(false) end
      else
        iSMSAddDialog.v = ""
        sampSendChat("/sms "..tonumber(createnewdialognick).." 1")
        if isPlayerControlLocked() then lockPlayerControl(false) end
        ikkk = 0
        iAddSMS = false
        lua_thread.create(
          function()
            wait(sampGetPlayerPing(myid) * 3)
            smsNick222 = nil
            local smsText222, smsNick222, smsNumbe2r = string.match(sampGetChatString(99), "SMS%: (.*)% %| Получатель%: (.*) %[т.(%d+)%]")
            if smsNick222 then
              if sms[smsNick222] == nil then
                sms[smsNick222] = {}
                sms[smsNick222]["Chat"] = {}
                sms[smsNick222]["Checked"] = 0
                sms[smsNick222]["Pinned"] = 0
                ikkk = 0
                iAddSMS = false
                table.insert(sms[smsNick222]["Chat"], {text = "Диалог создан", Nick = "мессенджер", type = "service", time = os.time()})
                selecteddialogSMS = smsNick222
                SSDB_trigger = true
                ScrollToDialogSMS = true
                keyboard = true
              else
                selecteddialogSMS = smsNick222
                ikkk = 0
                iAddSMS = false
                ScrollToDialogSMS = true
                keyboard = true
              end
            end
          end
        )
      end
    end
    if imgui.IsKeyPressed(key.VK_ESCAPE) then
      iSMSAddDialog.v = ""
      ikkk = 0
      iAddSMS = false
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if KeyboardFocusResetForNewDialog then imgui.SetKeyboardFocusHere() fixforcarstop() KeyboardFocusResetForNewDialog = false end
    if iSMSAddDialog.v ~= "" then
      imgui.SetTooltip(u8:encode("Введите номер и нажмите Enter"))
    end
  end

  function smsheader()
    imgui.BeginChild("##header", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
    if sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["Chat"] ~= nil then
      if math.random(1, 9999) % 30 < 1 then
        for id = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == tostring(selecteddialogSMS) then
            shId = id
            break
          end
          if id == sampGetMaxPlayerId() + 1 then shId = "-" end
        end
      end
      if shId ~= nil and shId == "-" then
        imgui.Text(u8:encode("[Оффлайн] Ник: "..tostring(selecteddialogSMS)..". Номер: "..sms[selecteddialogSMS]["Number"]..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
      else
        imgui.Text(u8:encode("[Онлайн] Ник: "..tostring(selecteddialogSMS)..". ID: "..tostring(shId)..". LVL: "..tostring(sampGetPlayerScore(tonumber(shId)))..". Номер: "..sms[selecteddialogSMS]["Number"]..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
        getafkbutton()
      end
    end
    imgui.EndChild()
  end
end

function mode_diamondrp()
  function RPC.onPlaySound(sound)
    if sound == 1054 and iSoundSmsOut.v then
      return false
    end
  end
  function RPC.onServerMessage(color, text)
    if selecteddialogSMS ~= nil and text:find("{33FF1F}Номер "..selecteddialogSMS..": {FF5500}") and getmenumber then
      if sms[selecteddialogSMS]["Number"] == "?" then
        sms[selecteddialogSMS]["Number"] = string.match(text, "%{33FF1F%}Номер "..selecteddialogSMS.."%: %{FF5500%}(.+)")
      end
      return false
    end
    if text:find("Абонент доступен для звонка") and getmenumber then
      if sms[selecteddialogSMS]["Number"] ~= "?" then
        getmenumber = false
        return false
      end
    end
    if text:find("SMS") then
      text = string.gsub(text, "{FF8000}", "")
      local smsText, smsNick, smsNumber = string.match(text, "{FF8C00}SMS%: {FFFF00}(.*)% {FF8C00}%| {FFFF00}Отправитель%: (.*) %(тел. (%d+)%)")
      if smsText and smsNick and smsNumber then
        smsId = 1001
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == smsNick then
            smsId = i
            break
          end
        end
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if sms[smsNick] and sms[smsNick].Chat then
          if sms[smsNick]["Number"] ~= smsNumber then sms[smsNick]["Number"] = smsNumber end
        else
          sms[smsNick] = {}
          sms[smsNick]["Number"] = smsNumber
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        if sms[smsNick]["Blocked"] ~= nil and sms[smsNick]["Blocked"] == 1 then return false end
        if iSoundSmsIn.v then PLAYSMSIN = true end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = smsNick, type = "FROM", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        SSDB_trigger = true
        if not iHideSmsIn.v then
          if iReplaceSmsInColor.v then
            text = string.gsub(text, "{FFFF00}", "")
            text = string.gsub(text, "{FF8C00}", "")

            sampAddChatMessage(text, SmsInColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
      local smsText, smsNick, smsNumber = string.match(text, "{FFA500}SMS%: {FFFF00}(.*)% {FFA500}%| {FFFF00}Получатель%: (.*) %(тел. (%d+)%)")
      if smsText and smsNick and smsNumber then
        smsId = 1001
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == smsNick then
            smsId = i
            break
          end
        end
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if iSoundSmsOut.v then PLAYSMSOUT = true end
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sms[smsNick] and sms[smsNick].Chat then
          if sms[smsNick]["Number"] ~= smsNumber then sms[smsNick]["Number"] = smsNumber end
        else
          sms[smsNick] = {}
          sms[smsNick]["Number"] = smsNumber
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = sampGetPlayerNickname(myid), type = "TO", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        if sampIsPlayerConnected(smsId) then
          if sms ~= nil and sms[sampGetPlayerNickname(smsId)] ~= nil and sms[sampGetPlayerNickname(smsId)]["Checked"] ~= nil then
            sms[sampGetPlayerNickname(smsId)]["Checked"] = os.time()
          end
        end
        SSDB_trigger = true
        if not iHideSmsOut.v then
          if iReplaceSmsOutColor.v then
            text = string.gsub(text, "{FFFF00}", "")
            text = string.gsub(text, "{FFA500}", "")

            sampAddChatMessage(text, SmsOutColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
    end
  end
  function sendsms()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - 70)
    if imgui.InputText("##keyboardSMSKA", toAnswerSMS, imgui.InputTextFlags.EnterReturnsTrue) then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" and sms[selecteddialogSMS]["Number"] ~= nil then
        lua_thread.create(hznomer)
      end
      KeyboardFocusReset = true

    end
    if imgui.IsItemActive() then
      fixforcarstop()
    else
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if imgui.SameLine() or imgui.Button(u8"Отправить") then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" and sms[selecteddialogSMS]["Number"] ~= nil then
        lua_thread.create(hznomer)
      end
      KeyboardFocusReset = true
    end
  end
  function hznomer()
    local newsms = u8:decode(toAnswerSMS.v)
    toAnswerSMS.v = ''
    if sms[selecteddialogSMS]["Number"] == "?" then
      getmenumber = true
      sampSendChat("/number "..selecteddialogSMS)
      wait(1200)
    end
    if sms[selecteddialogSMS]["Number"] ~= "?" then
      sampSendChat("/sms " .. sms[selecteddialogSMS]["Number"] .. " " .. newsms)
    end
  end
  function getafk(i) end
  function getafkbutton() end
  function hidesmssent() end
  function changesmssent() end
  function newdialog()
    if imgui.InputText("##keyboardSMADD", iSMSAddDialog, imgui.InputTextFlags.EnterReturnsTrue) then
      createnewdialognick = iSMSAddDialog.v
      if iSMSAddDialog.v == "" then
        ikkk = 0
        iAddSMS = false
        if isPlayerControlLocked() then lockPlayerControl(false) end
      else
        iSMSAddDialog.v = ""
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and i == tonumber(createnewdialognick) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(createnewdialognick)) then
            if sms[sampGetPlayerNickname(i)] == nil then
              sms[sampGetPlayerNickname(i)] = {}
              sms[sampGetPlayerNickname(i)]["Chat"] = {}
              sms[sampGetPlayerNickname(i)]["Checked"] = 0
              sms[sampGetPlayerNickname(i)]["Number"] = "?"
              sms[sampGetPlayerNickname(i)]["Pinned"] = 0
              ikkk = 0
              iAddSMS = false
              table.insert(sms[sampGetPlayerNickname(i)]["Chat"], {text = "Диалог создан", Nick = "мессенджер", type = "service", time = os.time()})
              selecteddialogSMS = sampGetPlayerNickname(i)
              SSDB_trigger = true
              ScrollToDialogSMS = true
              keyboard = true
              break
            else
              selecteddialogSMS = sampGetPlayerNickname(i)
              ikkk = 0
              iAddSMS = false
              ScrollToDialogSMS = true
              keyboard = true
              break
            end
          end
        end
      end
    end
    if imgui.IsKeyPressed(key.VK_ESCAPE) then
      iSMSAddDialog.v = ""
      ikkk = 0
      iAddSMS = false
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if KeyboardFocusResetForNewDialog then imgui.SetKeyboardFocusHere() fixforcarstop() KeyboardFocusResetForNewDialog = false end
    if iSMSAddDialog.v ~= "" then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and i == tonumber(iSMSAddDialog.v) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(iSMSAddDialog.v)) then
          imgui.SetTooltip(u8:encode(sampGetPlayerNickname(i).."["..i.."]"))
          break
        end
      end
    end
  end

  function smsheader()
    imgui.BeginChild("##header", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
    if sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["Chat"] ~= nil then
      if math.random(1, 9999) % 20 < 1 then
        for id = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == tostring(selecteddialogSMS) then
            shId = id
            break
          end
          if id == sampGetMaxPlayerId() + 1 then shId = "-" end
        end
      end
      if shId ~= nil and shId == "-" then
        imgui.Text(u8:encode("[Оффлайн] Ник: "..tostring(selecteddialogSMS)..". Номер: "..sms[selecteddialogSMS]["Number"]..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
      else
        imgui.Text(u8:encode("[Онлайн] Ник: "..tostring(selecteddialogSMS)..". ID: "..tostring(shId)..". LVL: "..tostring(sampGetPlayerScore(tonumber(shId)))..". Номер: "..sms[selecteddialogSMS]["Number"]..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
        getafkbutton()
      end
    end
    imgui.EndChild()
  end
end

function mode_trinityrp()
  function RPC.onPlaySound(sound)
    if sound == 1052 and iSoundSmsOut.v then
      return false
    end
  end
  function RPC.onServerMessage(color, text)
    if text:find("Телефонный справочник") and getmenumber then
      return false
    end
    if selecteddialogSMS ~= nil and text:find("{F5DEB3}Имя: {ffffff}"..selecteddialogSMS) and getmenumber then
      if sms[selecteddialogSMS]["Number"] == "?" then
        sms[selecteddialogSMS]["Number"] = string.match(text, "{F5DEB3}Имя: {ffffff}"..selecteddialogSMS.."{F5DEB3} Телефон: {ffffff}(.+){F5DEB3} Прожив")
      end
      getmenumber = false
      return false
    end
    if text:find("SMS") then
      local smsText, smsNick, smsNumber = string.match(text, "SMS%:{......}% (.+)% {......}От%: {......}(.+) {......}Тел%: {......}(.+)")
      if smsText and smsNick and smsNumber then
        smsId = 1001
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == smsNick then
            smsId = i
            break
          end
        end
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if sms[smsNick] and sms[smsNick].Chat then
          if sms[smsNick]["Number"] ~= smsNumber then sms[smsNick]["Number"] = smsNumber end
        else
          sms[smsNick] = {}
          sms[smsNick]["Number"] = smsNumber
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        if sms[smsNick]["Blocked"] ~= nil and sms[smsNick]["Blocked"] == 1 then return false end
        if iSoundSmsIn.v then PLAYSMSIN = true end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = smsNick, type = "FROM", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        SSDB_trigger = true
        if not iHideSmsIn.v then
          if iReplaceSmsInColor.v then
            text = string.gsub(text, "{FFFF00}", "")
            text = string.gsub(text, "{FFFFFF}", "")
            text = string.gsub(text, "{ffffff}", "")

            sampAddChatMessage(text, SmsInColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
      local smsText, smsNick, smsNumber = string.match(text, "SMS%:{......}% (.*)% {......}Для%: {......}(.+) {......}Тел%: {......}(.+)")
      if smsText and smsNick and smsNumber then
        smsId = 1001
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == smsNick then
            smsId = i
            break
          end
        end
        LASTID_SMS = smsId
        LASTNICK_SMS = smsNick
        if iSoundSmsOut.v then PLAYSMSOUT = true end
        local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if sms[smsNick] and sms[smsNick].Chat then
          if sms[smsNick]["Number"] ~= smsNumber then sms[smsNick]["Number"] = smsNumber end
        else
          sms[smsNick] = {}
          sms[smsNick]["Number"] = smsNumber
          sms[smsNick]["Chat"] = {}
          sms[smsNick]["Checked"] = 0
          sms[smsNick]["Pinned"] = 0
        end
        table.insert(sms[smsNick]["Chat"], {text = smsText, Nick = sampGetPlayerNickname(myid), type = "TO", time = os.time()})
        if selecteddialogSMS == smsNick then ScrollToDialogSMS = true end
        if sampIsPlayerConnected(smsId) then
          if sms ~= nil and sms[sampGetPlayerNickname(smsId)] ~= nil and sms[sampGetPlayerNickname(smsId)]["Checked"] ~= nil then
            sms[sampGetPlayerNickname(smsId)]["Checked"] = os.time()
          end
        end
        SSDB_trigger = true
        if not iHideSmsOut.v then
          if iReplaceSmsOutColor.v then
            text = string.gsub(text, "{FFFF00}", "")
            text = string.gsub(text, "{FFFFFF}", "")

            sampAddChatMessage(text, SmsOutColor_HEX)
            return false
          else
            --do nothing
          end
        else
          return false
        end
      end
    end
  end
  function sendsms()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - 70)
    if imgui.InputText("##keyboardSMSKA", toAnswerSMS, imgui.InputTextFlags.EnterReturnsTrue) then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" and sms[selecteddialogSMS]["Number"] ~= nil then
        lua_thread.create(hznomer)
      end
      KeyboardFocusReset = true

    end
    if imgui.IsItemActive() then
      fixforcarstop()
    else
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if imgui.SameLine() or imgui.Button(u8"Отправить") then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == selecteddialogSMS then k = i break end
        if i == sampGetMaxPlayerId() then k = "-" end
      end
      if k ~= "-" and sms[selecteddialogSMS]["Number"] ~= nil then
        lua_thread.create(hznomer)
      end
      KeyboardFocusReset = true
    end
  end
  function hznomer()
    local newsms = u8:decode(toAnswerSMS.v)
    toAnswerSMS.v = ''
    if sms[selecteddialogSMS]["Number"] == "?" then
      getmenumber = true
      sampSendChat("/number "..selecteddialogSMS)
      wait(1200)
    end
    if sms[selecteddialogSMS]["Number"] ~= "?" then
      sampSendChat("/sms " .. sms[selecteddialogSMS]["Number"] .. " " .. newsms)
    end
  end
  function getafk(i) end
  function getafkbutton() end
  function hidesmssent() end
  function changesmssent() end
  function newdialog()
    if imgui.InputText("##keyboardSMADD", iSMSAddDialog, imgui.InputTextFlags.EnterReturnsTrue) then
      createnewdialognick = iSMSAddDialog.v
      if iSMSAddDialog.v == "" then
        ikkk = 0
        iAddSMS = false
        if isPlayerControlLocked() then lockPlayerControl(false) end
      else
        iSMSAddDialog.v = ""
        for i = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(i) and i == tonumber(createnewdialognick) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(createnewdialognick)) then
            if sms[sampGetPlayerNickname(i)] == nil then
              sms[sampGetPlayerNickname(i)] = {}
              sms[sampGetPlayerNickname(i)]["Chat"] = {}
              sms[sampGetPlayerNickname(i)]["Checked"] = 0
              sms[sampGetPlayerNickname(i)]["Number"] = "?"
              sms[sampGetPlayerNickname(i)]["Pinned"] = 0
              ikkk = 0
              iAddSMS = false
              table.insert(sms[sampGetPlayerNickname(i)]["Chat"], {text = "Диалог создан", Nick = "мессенджер", type = "service", time = os.time()})
              selecteddialogSMS = sampGetPlayerNickname(i)
              SSDB_trigger = true
              ScrollToDialogSMS = true
              keyboard = true
              break
            else
              selecteddialogSMS = sampGetPlayerNickname(i)
              ikkk = 0
              iAddSMS = false
              ScrollToDialogSMS = true
              keyboard = true
              break
            end
          end
        end
      end
    end
    if imgui.IsKeyPressed(key.VK_ESCAPE) then
      iSMSAddDialog.v = ""
      ikkk = 0
      iAddSMS = false
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
    if KeyboardFocusResetForNewDialog then imgui.SetKeyboardFocusHere() fixforcarstop() KeyboardFocusResetForNewDialog = false end
    if iSMSAddDialog.v ~= "" then
      for i = 0, sampGetMaxPlayerId() do
        if sampIsPlayerConnected(i) and i == tonumber(iSMSAddDialog.v) or sampIsPlayerConnected(i) and string.find(string.rlower(sampGetPlayerNickname(i)), string.rlower(iSMSAddDialog.v)) then
          imgui.SetTooltip(u8:encode(sampGetPlayerNickname(i).."["..i.."]"))
          break
        end
      end
    end
  end

  function smsheader()
    imgui.BeginChild("##header", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
    if sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["Chat"] ~= nil then
      if math.random(1, 9999) % 20 < 1 then
        for id = 0, sampGetMaxPlayerId() + 1 do
          if sampIsPlayerConnected(id) and sampGetPlayerNickname(id) == tostring(selecteddialogSMS) then
            shId = id
            break
          end
          if id == sampGetMaxPlayerId() + 1 then shId = "-" end
        end
      end
      if shId ~= nil and shId == "-" then
        imgui.Text(u8:encode("[Оффлайн] Ник: "..tostring(selecteddialogSMS)..". Номер: "..sms[selecteddialogSMS]["Number"]..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
      else
        imgui.Text(u8:encode("[Онлайн] Ник: "..tostring(selecteddialogSMS)..". ID: "..tostring(shId)..". LVL: "..tostring(sampGetPlayerScore(tonumber(shId)))..". Номер: "..sms[selecteddialogSMS]["Number"]..". Всего сообщений: "..tostring(#sms[selecteddialogSMS]["Chat"]).."."))
        getafkbutton()
      end
    end
    imgui.EndChild()
  end
end
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA
----------------------------------WORKING MODE AREA

function imgui_init()
  function imgui.OnDrawFrame()
    iccccc = os.clock()

    if main_window_state.v then
      imgui.SetNextWindowPos(imgui.ImVec2(cfg.menuwindow.PosX, cfg.menuwindow.PosY), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowSize(imgui.ImVec2(cfg.menuwindow.Width, cfg.menuwindow.Height))
      if PREMIUM then
        beginflags = imgui.WindowFlags.NoCollapse
      else
        beginflags = imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar
      end
      if PREMIUM then
        imgui.Begin(u8:encode(thisScript().name.." Premium v"..thisScript().version), main_window_state, beginflags)
      else
        imgui.Begin(u8:encode(thisScript().name.." Lite v"..thisScript().version), main_window_state, beginflags)
      end
      imgui_saveposandsize()
      imgui_messanger()
      imgui.End()
    end
    icccccb = os.clock() - iccccc
  end
end

function imgui_menu()
  imgui.BeginMenuBar()
  if imgui.MenuItem(u8'Купить лицензию') then
    cfg.messanger.mode = 1
    selectedTAB = 8
    inicfg.save(cfg, "smes")
  end
  imgui.EndMenuBar()
end

function imgui_itspremiuim()
  cfg.messanger.mode = 1
  selectedTAB = 8
end

function imgui_saveposandsize()
  if cfg.menuwindow.Width ~= imgui.GetWindowWidth() or cfg.menuwindow.Height ~= imgui.GetWindowHeight() then
    cfg.menuwindow.Width = imgui.GetWindowWidth()
    cfg.menuwindow.Height = imgui.GetWindowHeight()
    inicfg.save(cfg, "smes")
  end
  if cfg.menuwindow.PosX ~= imgui.GetWindowPos().x or cfg.menuwindow.PosY ~= imgui.GetWindowPos().y then
    cfg.menuwindow.PosX = imgui.GetWindowPos().x
    cfg.menuwindow.PosY = imgui.GetWindowPos().y
    inicfg.save(cfg, "smes")
  end
end

function imgui_messanger_scrollkostil()
  while true do
    wait(0)
    if scroll then
      wait(100)
      scroll = false
    end
  end
end

function imgui_messanger_FO(mode)
  --mode = 4 => открыть смс на последней смс
  --mode = 5 => открыть смс на создании диалога
  if mode == 4 then
    if LASTNICK_SMS == " " then
      sampAddChatMessage("Ошибка: вам/вы ещё не писали смс.", color)
    else
      cfg.messanger.mode = 2
      if selecteddialogSMS ~= LASTNICK_SMS then
        --do nothing
        if not main_window_state.v then main_window_state.v = true end
      else
        main_window_state.v = not main_window_state.v
      end
      if cfg.messanger.activesms and cfg.messanger.hotkey4 then
        if sampIsPlayerConnected(LASTID_SMS) and sampGetPlayerNickname(LASTID_SMS) == LASTNICK_SMS then
          online = "Онлайн"
        else
          online = "Оффлайн"
        end
        selecteddialogSMS = LASTNICK_SMS
        smsafk[selecteddialogSMS] = "CHECK AFK"
        keyboard = true
        cfg.messanger.mode = 2
        ScrollToDialogSMS = true
        inicfg.save(cfg, "smes")
      end
    end
  end
  if mode == 5 then
    if cfg.messanger.mode == 1 then
      cfg.messanger.mode = 2
    end
    if not main_window_state.v then main_window_state.v = true end
    if cfg.messanger.activesms and cfg.messanger.hotkey5 then
      ikkk = -20
      iAddSMS = true
      KeyboardFocusResetForNewDialog = true
      cfg.messanger.mode = 2
      inicfg.save(cfg, "smes")
    end
  end
end

function imgui_messanger()
  if not PREMIUM then imgui_menu() end
  imgui_messanger_content()
end

function imgui_messanger_content()
  imgui.Columns(2, nil, false)
  imgui.SetColumnWidth(-1, 200)
  if cfg.messanger.mode == 1 then imgui_messanger_sup_settings() end
  if cfg.messanger.mode == 2 then imgui_messanger_sms_settings() end
  if cfg.messanger.mode == 1 then imgui_messanger_sup_player_list() end
  if cfg.messanger.mode == 2 then

    imgui_messanger_sms_player_list()

  end
  imgui_messanger_switchmode()
  imgui.NextColumn()
  if cfg.messanger.mode == 1 then imgui_messanger_sup_header() end

  if cfg.messanger.mode == 2 then imgui_messanger_sms_header() end
  if cfg.messanger.mode == 1 then imgui_messanger_sup_dialog() end
  if cfg.messanger.mode == 2 then
    iaaaaa = os.clock()
    imgui_messanger_sms_dialog()
    iaaaaab = os.clock() - iaaaaa
  end
  if cfg.messanger.mode == 1 then imgui_messanger_sup_keyboard() end
  if cfg.messanger.mode == 2 then imgui_messanger_sms_keyboard() end
  imgui.Columns(1)
end

function imgui_messanger_rightclick()
  if imgui.IsItemHovered(imgui.HoveredFlags.RootWindow) and imgui.IsMouseClicked(1) then
    cfg.only.messanger = true
    inicfg.save(cfg, "smes")
  end
end

function imgui_messanger_sup_settings()
  imgui.BeginChild("##settings", imgui.ImVec2(192, 35), true)

  imgui.EndChild()
end

function imgui_messanger_sms_settings()
  imgui.BeginChild("##settings", imgui.ImVec2(192, 35), true)
  imgui.SameLine(6)
  imgui.Text("")
  imgui.SameLine()
  imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.16, 0.29, 0.48, 0.54))
  if not iAddSMS then
    if imgui.Checkbox("##ShowSHO2WOFFLINE", iShowSHOWOFFLINESMS) then
      cfg.messanger.iShowSHOWOFFLINESMS = iShowSHOWOFFLINESMS.v
      inicfg.save(cfg, "smes")
    end
    if imgui.IsItemHovered() then
      imgui.SetTooltip(u8"Показывать оффлайн игроков?")
    end
    imgui.SameLine()
    if imgui.Checkbox("##SMSFILTER", iSMSfilterBool) then
      cfg.messanger.iSMSfilterBool = iSMSfilterBool.v
      inicfg.save(cfg, "smes")
    end
    if imgui.IsItemHovered() then
      imgui.SetTooltip(u8"Включить фильтр по нику?")
    end
    if iSMSfilterBool.v then
      imgui.SameLine()
      if imgui.InputText("##keyboardSMSFILTER", iSMSfilter) then
        cfg.messanger.smsfiltertext = iSMSfilter.v
        inicfg.save(cfg, "smes")
      end
    end
    if not iSMSfilterBool.v then
      imgui.SameLine()
      if imgui.Checkbox("##iSetKeyboardSMS", iSetKeyboardSMS) then
        cfg.messanger.iSetKeyboardSMS = iSetKeyboardSMS.v
        inicfg.save(cfg, "smes")
      end
      if imgui.IsItemHovered() then
        imgui.SetTooltip(u8"Курсор на ввод текста при выборе диалога?")
      end
      imgui.SameLine()
      if imgui.Checkbox("##iChangeScrollSMS", iChangeScrollSMS) then
        cfg.messanger.iChangeScrollSMS = iChangeScrollSMS.v
        inicfg.save(cfg, "smes")
      end
      if imgui.IsItemHovered() then
        imgui.SetTooltip(u8"Менять позицию скролла в списке диалогов при выборе диалога?")
      end
      imgui.SameLine()
      if imgui.Button(u8"Добавить", imgui.ImVec2(imgui.GetContentRegionAvailWidth() + 1, 20)) then
        ikkk = 0
        iAddSMS = true
        KeyboardFocusResetForNewDialog = true
      end
    end
  else
    newdialog()
    if iAddSMS and not imgui.IsItemActive() then
      ikkk = ikkk + 1
      if ikkk > 5 then
        ikkk = 0
        if isPlayerControlLocked() then lockPlayerControl(false) end
        ikkk = 0
        iAddSMS = false
      end
    end

    imgui.SameLine()
    if imgui.Button(u8"close", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 20)) then
      iSMSAddDialog.v = ""
      ikkk = 0
      iAddSMS = false
      if isPlayerControlLocked() then lockPlayerControl(false) end
    end
  end
  imgui.PopStyleColor()
  imgui.EndChild()
end

function imgui_messanger_sms_player_list()
  iooooo = os.clock()
  playerlistY = imgui.GetContentRegionAvail().y - 35
  imgui.BeginChild("список ников", imgui.ImVec2(192, playerlistY), true)
  if counter == nil then counter = 0 end
  if counter > 10 then
    counter = 0
    smsindex_PINNED = {}
    smsindex_PINNEDVIEWED = {}
    smsindex_NEW = {}
    smsindex_NEWVIEWED = {}

    for k in pairs(sms) do
      if cfg.messanger.iSMSfilterBool and cfg.messanger.smsfiltertext ~= nil then
        if cfg.messanger.smsfiltertext ~= "" then
          if string.find(string.rlower(k), string.rlower(cfg.messanger.smsfiltertext)) ~= nil then
            imgui_messanger_sms_player_list_filter(k)
          end
        else
          imgui_messanger_sms_player_list_filter(k)
        end
      else
        imgui_messanger_sms_player_list_filter(k)
      end
    end

    table.sort(smsindex_PINNED, function(a, b) return sms[a]["Chat"][#sms[a]["Chat"]]["time"] > sms[b]["Chat"][#sms[b]["Chat"]]["time"] end)
    table.sort(smsindex_PINNEDVIEWED, function(a, b) return sms[a]["Chat"][#sms[a]["Chat"]]["time"] > sms[b]["Chat"][#sms[b]["Chat"]]["time"] end)
    table.sort(smsindex_NEW, function(a, b) return sms[a]["Chat"][#sms[a]["Chat"]]["time"] > sms[b]["Chat"][#sms[b]["Chat"]]["time"] end)
    table.sort(smsindex_NEWVIEWED, function(a, b) return sms[a]["Chat"][#sms[a]["Chat"]]["time"] > sms[b]["Chat"][#sms[b]["Chat"]]["time"] end)
  else
    counter = counter + 1
  end
  if smsindex_PINNED ~= nil and smsindex_PINNEDVIEWED ~= nil and smsindex_NEW ~= nil and smsindex_NEWVIEWED ~= nil then
    imgui_messanger_sms_showdialogs(smsindex_PINNED, "Pinned")
    imgui_messanger_sms_showdialogs(smsindex_PINNEDVIEWED, "Pinned")
    imgui_messanger_sms_showdialogs(smsindex_NEW, "NotPinned")
    imgui_messanger_sms_showdialogs(smsindex_NEWVIEWED, "NotPinned")
  end
  iooooob = os.clock() - iooooo


  imgui.EndChild()

end

function imgui_messanger_sms_player_list_filter(k)
  if sms[k]["Pinned"] ~= nil and sms[k]["Chat"] ~= nil and sms[k]["Checked"] then
    if sms[k]["Pinned"] == 1 then
      kolvo = 0
      if #sms[k]["Chat"] ~= 0 then
        for i, z in pairs(sms[k]["Chat"]) do
          if z["type"] == "FROM" and z["time"] > sms[k]["Checked"] then
            kolvo = kolvo + 1
          end
        end
      end
      if kolvo > 0 then
        table.insert(smsindex_PINNED, k)
      else
        table.insert(smsindex_PINNEDVIEWED, k)
      end
    else
      kolvo = 0
      if #sms[k]["Chat"] ~= 0 then
        for i, z in pairs(sms[k]["Chat"]) do
          if z["type"] == "FROM" and z["time"] > sms[k]["Checked"] then
            kolvo = kolvo + 1
          end
        end
      end
      if kolvo > 0 then
        table.insert(smsindex_NEW, k)
      else
        table.insert(smsindex_NEWVIEWED, k)
      end
    end
  end
end

function imgui_messanger_sup_player_list()
  playerlistY = imgui.GetContentRegionAvail().y - 35
  imgui.BeginChild("список ников", imgui.ImVec2(192, playerlistY), true)
  imgui_messanger_sup_showdialogs(1, "Чат")
  imgui_messanger_sup_showdialogs(2, "Мессенджер")
  imgui_messanger_sup_showdialogs(3, "Звуки")
  imgui_messanger_sup_showdialogs(4, "Хоткеи")
  imgui_messanger_sup_showdialogs(5, "Разное")
  if not PREMIUM then imgui_messanger_sup_showdialogs(8, "Активировать код") else
    imgui_messanger_sup_showdialogs(9, "Чёрный список")
  end
  imgui_messanger_sup_showdialogs(6, "О скрипте")
  imgui.EndChild()
end

function imgui_messanger_sms_showdialogs(table, typ)
  for _, v in ipairs(table) do
    k = v
    if sms ~= nil and sms[k] ~= nil and ((sms[k]["id"] == "-" and iShowSHOWOFFLINESMS.v) or (sms[k]["id"] ~= "-")) then
      v = sms[v]
      if k ~= " " then
        if sms[k]["id"] == nil then
          pId = "-"
        else
          pId = sms[k]["id"]
        end
        kolvo = 0
        if #v["Chat"] ~= 0 then
          for i, z in pairs(v["Chat"]) do
            if z["type"] == "FROM" and z["time"] > v["Checked"] then
              kolvo = kolvo + 1
            end
          end
        end

        if typ == "Pinned" then
          imgui.PushID(1)
          imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(0, 0, 0, 113):GetVec4())
          if kolvo > 0 then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(0, 255, 0, 255):GetVec4())
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
          end
          if k == selecteddialogSMS then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(54, 12, 42, 113):GetVec4())
            sms[selecteddialogSMS]["Checked"] = os.time()

            --  elseif #iMessanger[k]["A"] == 0 then
          else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(255, 0, 0, 113):GetVec4())
          end
        end
        if k == selecteddialogSMS then
          sms[selecteddialogSMS]["Checked"] = os.time()
        end
        if typ == "NotPinned" then
          imgui.PushID(2)
          imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(0, 0, 0, 113):GetVec4())
          if kolvo > 0 then
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(0, 255, 0, 255):GetVec4())
          else
            imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
          end
          if k == selecteddialogSMS then
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(54, 12, 42, 113):GetVec4())
            sms[selecteddialogSMS]["Checked"] = os.time()
          else
            imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.40))
          end
        end

        if kolvo > 0 then
          if pId ~= nil and pId ~= "-" then
            if imgui.Button(u8(k .. "[" .. pId .. "] - "..kolvo), imgui.ImVec2(-0.0001, 30)) then
              selecteddialogSMS = k
              ScrollToDialogSMS = true
              online = "Онлайн"
              smsafk[selecteddialogSMS] = "CHECK AFK"
              scroll = true
              keyboard = true
              SSDB1_trigger = true
            end
          elseif iShowSHOWOFFLINESMS.v then
            if imgui.Button(u8(k .. "[-] - "..kolvo), imgui.ImVec2(-0.0001, 30)) then
              selecteddialogSMS = k
              ScrollToDialogSMS = true
              online = "Оффлайн"
              scroll = true
              keyboard = true
              SSDB1_trigger = true
            end
          end
        else
          if pId ~= nil and pId ~= "-" then
            if imgui.Button(u8(k .. "[" .. pId .. "]"), imgui.ImVec2(-0.0001, 30)) then
              selecteddialogSMS = k
              ScrollToDialogSMS = true
              smsafk[selecteddialogSMS] = "CHECK AFK"
              online = "Онлайн"
              scroll = true
              keyboard = true
              SSDB1_trigger = true
            end
          elseif iShowSHOWOFFLINESMS.v then
            if imgui.Button(u8(k .. "[-]"), imgui.ImVec2(-0.0001, 30)) then
              selecteddialogSMS = k
              ScrollToDialogSMS = true
              online = "Оффлайн"
              scroll = true
              keyboard = true
              SSDB1_trigger = true
            end
          end
        end
        if scroll and selecteddialogSMS == k and iChangeScrollSMS.v then
          imgui.SetScrollHere()
        end
        imgui.PopStyleColor()
        imgui_messanger_sms_player_list_contextmenu(k, typ)
        if typ == "Pinned" then
          imgui.PopStyleColor(2)
          imgui.PopID()
        end
        if typ == "NotPinned" then
          imgui.PopStyleColor(2)
          imgui.PopID()
        end
      end
    end
  end
end

function imgui_messanger_sms_player_list_contextmenu(k, typ)
  if imgui.BeginPopupContextItem("item context menu"..k) then
    if typ == "NotPinned" then
      if imgui.Selectable(u8"Закрепить") then
        if PREMIUM then
          sms[k]["Pinned"] = 1
          SSDB_trigger = true
          table.insert(sms[k]["Chat"], {text = "Собеседник закреплён", Nick = "мессенджер", type = "service", time = os.time()})
          ScrollToDialogSMS = true
        else
          imgui_itspremiuim()
        end
      end
    else
      if imgui.Selectable(u8"Открепить") then
        sms[k]["Pinned"] = 0
        SSDB_trigger = true
        table.insert(sms[k]["Chat"], {text = "Собеседник откреплён", Nick = "мессенджер", type = "service", time = os.time()})
        ScrollToDialogSMS = true
      end
    end
    if sms[k]["Blocked"] ~= nil then
      if imgui.Selectable(u8"Разблокировать") then
        sms[k]["Blocked"] = nil
        table.insert(sms[k]["Chat"], {text = "Собеседник разблокирован", Nick = "мессенджер", type = "service", time = os.time()})
        SSDB_trigger = true
        ScrollToDialogSMS = true
      end
    else
      if imgui.Selectable(u8"Заблокировать") then
        if PREMIUM then
          sms[k]["Blocked"] = 1
          table.insert(sms[k]["Chat"], {text = "Собеседник заблокирован", Nick = "мессенджер", type = "service", time = os.time()})
          SSDB_trigger = true
          ScrollToDialogSMS = true
        else
          imgui_itspremiuim()
        end
      end
    end
    if imgui.Selectable(u8"Очистить") then
      ispinned = 0
      if sms[k] and sms[k]["Pinned"] == 1 then
        ispinned = sms[k]["Pinned"]
      end
      sms[k] = {}
      sms[k]["Chat"] = {}
      sms[k]["Checked"] = 0
      sms[k]["Pinned"] = ispinned
      sms[k]["Chat"][1] = {text = "Диалог очищен", Nick = "мессенджер", type = "service", time = os.time()}
      selecteddialogSMS = k
      SSDB_trigger = true
      ScrollToDialogSMS = true
    end
    if imgui.Selectable(u8"Удалить") then
      sms[k] = nil
      SSDB_trigger = true
    end
    imgui.EndPopup()
  end
end

function imgui_messanger_sup_showdialogs(k, text)
  imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
  if k == selectedTAB then
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(54, 12, 42, 113):GetVec4())
  else
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.40))
  end
  if imgui.Button(u8(text), imgui.ImVec2(-0.0001, 30)) then
    selectedTAB = k
  end
  imgui.PopStyleColor(2)
end

function imgui_messanger_switchmode()
  imgui.BeginChild("Переключатель режимов", imgui.ImVec2(192, 35), true)
  kolvo1 = 0
  if cfg.messanger.mode == 1 then
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(0, 0, 0, 200):GetVec4())
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
  else
    if kolvo1 ~= nil and kolvo1 > 0 then
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(0, 255, 0, 255):GetVec4())
    else
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
    end
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.40))
  end
  if imgui.Button(u8("SETTINGS"), imgui.ImVec2(85, 20)) then
    cfg.messanger.mode = 1
    inicfg.save(cfg, "smes")
  end
  imgui.PopStyleColor(2)
  kolvo2 = 0
  for k in pairs(sms) do
    if #sms[k]["Chat"] ~= 0 then
      for i, z in pairs(sms[k]["Chat"]) do
        if z["type"] == "FROM" and z["time"] > sms[k]["Checked"] then
          kolvo2 = kolvo2 + 1
        end
      end
    end
  end
  if cfg.messanger.mode == 2 then
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(0, 0, 0, 200):GetVec4())
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
  else
    if kolvo2 ~= nil and kolvo2 > 0 then
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(0, 255, 0, 255):GetVec4())
    else
      imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(255, 255, 255, 255):GetVec4())
    end
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.26, 0.59, 0.98, 0.40))
  end
  imgui.SameLine()
  if imgui.Button(u8("SMS"), imgui.ImVec2(85, 20)) then
    cfg.messanger.mode = 2
    inicfg.save(cfg, "smes")
  end
  imgui.PopStyleColor(2)
  imgui.EndChild()
end

function imgui_messanger_sup_header()
  imgui.BeginChild("##header", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
  imgui.Text("")
  imgui.EndChild()
end

function imgui_messanger_sms_header()
  smsheader()
end

function imgui_messanger_sup_dialog()
  dialogY = imgui.GetContentRegionAvail().y - 35
  imgui.BeginChild("##middle", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), dialogY), true)
  if selectedTAB == 1 then imgui_settings_2_sms_hideandcol() end
  if selectedTAB == 2 then imgui_settings_6_sms_messanger() end
  if selectedTAB == 3 then imgui_settings_13_sms_sounds() end
  if selectedTAB == 4 then imgui_settings_14_hotkeys() end
  if selectedTAB == 5 then imgui_settings_15_extra() end
  if selectedTAB == 6 then imgui_info() end
  if selectedTAB == 9 then imgui_blacklist() end
  imgui.EndChild()
end

function render()
  resX, resY = getScreenResolution()
  font = renderCreateFont("Arial", 16, 5)
  local memory = require "memory"
  sf =
  [[Time to render:
Full frame: "%.3f"
Dialog list: "%.3f"
Dialog: "%.3f"]]
  while true do
    wait(0)
    while DEBUG do
      wait(0)
      renderFontDrawText(font, string.format(sf, icccccb, iooooob, iaaaaab), resX / 50, resY / 3.5, 0xFF00FF00)
    end
  end
end

function imgui_messanger_sms_dialog()
  dialogY = imgui.GetContentRegionAvail().y - 35

  imgui.BeginChild("##middle", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), dialogY), true)
  if selecteddialogSMS ~= nil and sms[selecteddialogSMS] ~= nil and sms[selecteddialogSMS]["Chat"] ~= nil then
    if sms[selecteddialogSMS]["maxpos"] == nil then sms[selecteddialogSMS]["maxpos"] = #sms[selecteddialogSMS]["Chat"] end
    if sms[selecteddialogSMS]["maxvisible"] == nil then sms[selecteddialogSMS]["maxvisible"] = -999 end
    kkkk = -1
    scroller = false
    for kkk, v in ipairs(sms[selecteddialogSMS]["Chat"]) do
      if kkk == sms[selecteddialogSMS]["maxpos"] - 10 and kkk ~= 1 then
        local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutColor):GetRGBA()
        imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImColor(r, g, b, a):GetVec4())
        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize("^")
        X = imgui.CalcTextSize("^").x + 15
        Y = imgui.CalcTextSize("^").y + 5
        imgui.NewLine()
        imgui.SameLine(width / 2 - calc.x / 2 - 15)
        imgui.BeginChild("##msgfe" .. kkk, imgui.ImVec2(X, Y), false, imgui.WindowFlags.AlwaysUseWindowPadding + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
        imgui.Text("^")
        if imgui.IsItemVisible() then
          scroller = true
        end
        imgui.EndChild()
        if imgui.IsItemClicked() then
          sms[selecteddialogSMS]["maxpos"] = 1
        end

        imgui.PopStyleColor()
      end
      if kkk >= sms[selecteddialogSMS]["maxpos"] - 10 and kkk <= sms[selecteddialogSMS]["maxpos"] + 10 then

        if DEBUG then msg = string.format("%s: %s", kkk, u8:encode(v.text)) else msg = string.format("%s", u8:encode(v.text)) end

        time = u8:encode(os.date("%d/%m/%y %X", v.time))
        if v.type == "FROM" then
          header = u8:encode("->SMS от "..v.Nick)
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsInColor):GetRGBA()
          imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImColor(r, g, b, a):GetVec4())
        end
        if v.type == "TO" then
          header = u8:encode("<-SMS от "..v.Nick)
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutColor):GetRGBA()
          imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImColor(r, g, b, a):GetVec4())
        end
        if v.type ~= "service" then
          Xmin = imgui.CalcTextSize(time).x + imgui.CalcTextSize(header).x
          Xmax = imgui.GetContentRegionAvailWidth() / 2 + imgui.GetContentRegionAvailWidth() / 4
          Xmes = imgui.CalcTextSize(msg).x

          if Xmin < Xmes then
            if Xmes < Xmax then
              X = Xmes + 15
              if (Xmin + 5) > X then anomaly = true else anomaly = false end
            else
              X = Xmax
              if (Xmin + 5) > X then anomaly = true else anomaly = false end
            end
          else
            if (Xmin + 5) < Xmax then
              X = Xmin + 15
              if (Xmin + 5) > X then anomaly = true else anomaly = false end
            else
              X = Xmax
              if (Xmin + 5) > X then anomaly = true else anomaly = false end
            end
          end
          Y = imgui.CalcTextSize(time).y + 7 + (imgui.CalcTextSize(time).y + 5) * math.ceil((imgui.CalcTextSize(msg).x) / (X - 14))
          if anomaly then Y = Y + imgui.CalcTextSize(time).y + 3 end
        else
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutColor):GetRGBA()
          imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImColor(r, g, b, a):GetVec4())
          X = imgui.CalcTextSize(msg).x + 9
          Y = imgui.CalcTextSize(msg).y + 5
        end
        if v.type == "TO" then
          imgui.NewLine()
          imgui.SameLine(imgui.GetContentRegionAvailWidth() - X + 20 - imgui.GetStyle().ScrollbarSize)
        end
        if v.type == "service" then
          imgui.NewLine()
          local width = imgui.GetWindowWidth()
          local calc = imgui.CalcTextSize(msg)
          imgui.SameLine(width / 2 - calc.x / 2 - 3)
        end
        imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 2.0))

        imgui.BeginChild("##msg" .. kkk, imgui.ImVec2(X, Y), false, imgui.WindowFlags.AlwaysUseWindowPadding + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
        if v.type == "FROM" then
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsInTextColor):GetRGBA()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(r, g, b, a):GetVec4())
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsInTimeColor):GetRGBA()
          imgui.TextColored(imgui.ImColor(r, g, b, a):GetVec4(), time)
          if not anomaly then imgui.SameLine() end
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsInHeaderColor):GetRGBA()
          imgui.TextColored(imgui.ImColor(r, g, b, a):GetVec4(), header)
        end
        if v.type == "TO" then
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutTextColor):GetRGBA()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(r, g, b, a):GetVec4())
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutTimeColor):GetRGBA()
          imgui.TextColored(imgui.ImColor(r, g, b, a):GetVec4(), time)
          if not anomaly then imgui.SameLine() end
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutHeaderColor):GetRGBA()
          imgui.TextColored(imgui.ImColor(r, g, b, a):GetVec4(), header)


        end
        if v.type == "service" then
          local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutTextColor):GetRGBA()
          imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(r, g, b, a):GetVec4())
        end
        imgui.TextWrapped(msg)
        if v.type == "service" and imgui.IsItemHovered() then
          imgui.SetTooltip(time)
        end

        imgui.PopStyleColor()
        imgui.EndChild()

        if imgui.IsItemVisible() and kkk > kkkk then kkkk = kkk end



        --sampAddChatMessage(imgui.GetScrollY(), color)
        imgui.PopStyleVar()
        imgui.PopStyleColor()
      end
      if kkk == sms[selecteddialogSMS]["maxpos"] + 10 and kkk ~= 1 then
        local r, g, b, a = imgui.ImColor(cfg.messanger.SmsOutColor):GetRGBA()
        imgui.PushStyleColor(imgui.Col.ChildWindowBg, imgui.ImColor(r, g, b, a):GetVec4())
        local width = imgui.GetWindowWidth()
        local calc = imgui.CalcTextSize(".")
        X = imgui.CalcTextSize(".").x + 15
        Y = imgui.CalcTextSize(".").y + 8
        imgui.NewLine()
        imgui.SameLine(width / 2 - calc.x / 2 - 15)
        imgui.BeginChild("##msgfhe" .. kkk, imgui.ImVec2(X, Y), false, imgui.WindowFlags.AlwaysUseWindowPadding + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoScrollWithMouse)
        imgui.Text(".")
        if imgui.IsItemVisible() then
          scroller = true
        end
        imgui.EndChild()
        if imgui.IsItemClicked() then
          sms[selecteddialogSMS]["maxpos"] = #sms[selecteddialogSMS]["Chat"]
        end

        imgui.PopStyleColor()
      end
    end
    sms[selecteddialogSMS]["maxvisible"] = kkkk
    if imgui.GetIO().MouseWheel ~= 0 and scroller then
      kostilforscroll = true
      sms[selecteddialogSMS]["mousewheel"] = imgui.GetIO().MouseWheel
    end
    if ScrollToDialogSMS then
      if scrolldone then
        imgui.SetScrollHere()
        ScrollToDialogSMS = false
        scrolldone = false
      else
        sms[selecteddialogSMS]["maxpos"] = #sms[selecteddialogSMS]["Chat"]
        scrolldone = true
      end
    end
  else
    if sms[selecteddialogSMS] == nil then
      local text = u8"Выберите диалог."
      local width = imgui.GetWindowWidth()
      local height = imgui.GetWindowHeight()
      local calc = imgui.CalcTextSize(text)
      imgui.SetCursorPos(imgui.ImVec2( width / 2 - calc.x / 2, height / 2 - calc.y / 2))
      imgui.Text(text)
    end
  end
  imgui.EndChild()
end

function imgui_messanger_sup_keyboard()
  imgui.BeginChild("##keyboard", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
  imgui.Text("")
  imgui.EndChild()
end

function imgui_messanger_sms_keyboard()
  imgui.BeginChild("##keyboardSMS", imgui.ImVec2(imgui.GetContentRegionAvailWidth(), 35), true)
  if sms[selecteddialogSMS] == nil then

  else
    if KeyboardFocusReset then
      imgui.SetKeyboardFocusHere()
      KeyboardFocusReset = false
    end
    if keyboard and iSetKeyboardSMS.v then
      imgui.SetKeyboardFocusHere()
      keyboard = false
    end
    sendsms()
  end
  imgui.EndChild()
end

function imgui_messanger_sms_loadDB()
  _213, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  smsfile = getGameDirectory()..'\\moonloader\\config\\smsmessanger\\'..sampGetCurrentServerAddress().."-"..sampGetPlayerNickname(myid)..'.sms'
  if PREMIUM and (cfg.messanger.storesms or ingamelaunch) then
    ingamelaunch = nil
    if doesFileExist(smsfile) then
      sms = table.load(smsfile)
    else
      if sms == nil then sms = {} end
      table.save(sms, smsfile)
      sms = table.load(smsfile)
    end
  else
    sms = {}
  end
end

function imgui_messanger_sms_saveDB()
  if PREMIUM and cfg.messanger.storesms then
    if type(sms) == "table" and doesFileExist(smsfile) then
      table.save(sms, smsfile)
    end
  end
end

function imgui_messanger_sms_kostilsaveDB()
  while true do
    wait(1500)
    if SSDB1_trigger or SSDB_trigger then
      imgui_messanger_sms_saveDB()
      SSDB1_trigger = false
      SSDB_trigger = false
      wait(1000)
    end
  end
end

function imgui_info()
  imgui_info_content()
end

function imgui_info_content()
  imgui.Text(thisScript().name.." v"..thisScript().version)
  imgui_info_open(currentbuylink)
  imgui.Text("<> by "..thisScript().authors[1])
  imgui_info_open("https://blast.hk/members/156833/")
  imgui.Text("")
  imgui.TextWrapped(u8"Группа ВКонтакте (все новости здесь): ".."http://vk.com/qrlk.mods")
  imgui_info_open("http://vk.com/qrlk.mods")
  imgui.TextWrapped(u8"Сообщение автору (все баги только сюда): ".."http://vk.me/qrlk.mods")
  imgui_info_open("http://vk.me/qrlk.mods")
  imgui.Text("")
  if imgui.TreeNode("Changelog") then
    imgui.InputTextMultiline("##changelog", changelog, imgui.ImVec2(-1, 200), imgui.InputTextFlags.ReadOnly)
    imgui.TreePop()
  end
  imgui.Text("")
  if PREMIUM then imgui.TextWrapped(u8:encode("Спасибо, что пользуетесь PREMIUM!")) imgui.TextWrapped(u8:encode("Лицензия принадлежит: "..licensenick..", сервер: "..licenseserver..", купленный мод: "..mode..".")) end
  imgui.TextWrapped(u8:encode("Текущая цена: "..currentprice..". Купить можно тут: "..currentbuylink))
  imgui_info_open(currentbuylink)
  imgui.Text("")
  imgui.Text(u8:encode("В скрипте задействованы следующие сампотехнологии:"))

  imgui.BeginChild("##credits", imgui.ImVec2(580, 158), true)
  imgui.Columns(4, nil, false)

  cp1 = 25
  cp2 = 125
  cp3 = 260
  cp4 = 160

  imgui.Text("1")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("Moonloader v0"..getMoonloaderVersion())
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://blast.hk/threads/13305/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("FYP, ")
  imgui_info_open("https://blast.hk/members/2/")
  imgui.SameLine()
  imgui.Text("hnnssy, ")
  imgui_info_open("https://blast.hk/members/66797/")
  imgui.SameLine()
  imgui.Text("EvgeN 1137.")
  imgui_info_open("https://blast.hk/members/1/")
  imgui.NextColumn()


  imgui.Text("2")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("SAMPFUNCS v5.3.3")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://blast.hk/threads/17/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("FYP")
  imgui_info_open("https://blast.hk/members/2/")
  imgui.NextColumn()

  imgui.Text("3")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("ImGui v1.52")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://github.com/ocornut/imgui/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("ocornut")
  imgui_info_open("https://github.com/ocornut/")
  imgui.NextColumn()

  imgui.Text("4")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("Moon ImGui v1.1.3")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://blast.hk/threads/19292/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("FYP")
  imgui_info_open("https://blast.hk/members/2/")
  imgui.NextColumn()

  imgui.Text("5")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("SAMP.Lua v2.0.5")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://github.com/THE-FYP/SAMP.Lua/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("FYP, ")
  imgui_info_open("https://blast.hk/members/2")
  imgui.SameLine()
  imgui.Text("MISTERGONWIK.")
  imgui_info_open("https://blast.hk/members/3")
  imgui.NextColumn()

  imgui.Text("6")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("lua-lockbox v0.1.0")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://github.com/somesocks/lua-lockbox/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("somesocks")
  imgui_info_open("https://github.com/somesocks/")
  imgui.NextColumn()

  imgui.Text("7")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("ImGui Custom v1.1.5")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://blast.hk/threads/22080/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("DonHomka")
  imgui_info_open("https://blast.hk/members/161656/")
  imgui.NextColumn()

  imgui.Text("8")
  imgui.SetColumnWidth(-1, cp1)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp2)
  imgui.Text("RKeys v1.0.7")
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp3)
  link = "https://blast.hk/threads/22145/"
  imgui.Text(link)
  imgui_info_open(link)
  imgui.NextColumn()
  imgui.SetColumnWidth(-1, cp4)
  imgui.Text("DonHomka")
  imgui_info_open("https://blast.hk/members/161656/")
  imgui.NextColumn()
  imgui.Columns(1)
  imgui.EndChild()
end

function imgui_info_open(link)
  if imgui.IsItemHovered() and imgui.IsMouseClicked(0) then
    local ffi = require 'ffi'
    ffi.cdef [[
			void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
			uint32_t __stdcall CoInitializeEx(void*, uint32_t);
		]]
    local shell32 = ffi.load 'Shell32'
    local ole32 = ffi.load 'Ole32'
    ole32.CoInitializeEx(nil, 2 + 4) -- COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE
    print(shell32.ShellExecuteA(nil, 'open', link, nil, nil, 1))
  end
end

function imgui_info_rightclick()
  if imgui.IsItemHovered(imgui.HoveredFlags.RootWindow) and imgui.IsMouseClicked(1) then
    cfg.only.info = true
  end
end


function imgui_blacklist()
  imgui.TextWrapped(u8"Здесь отображается ваш чёрный список.")
  imgui.TextWrapped(u8"Щёлкните правой кнопкой, чтобы удалить.")
  imgui.Text("")
  for k, v in pairs(sms) do
    if v["Blocked"] ~= nil and v["Blocked"] == 1 then imgui.Text(u8:encode(k)) end
    if imgui.IsItemHovered() and imgui.IsMouseClicked(1) then
      v["Blocked"] = nil
      table.insert(v["Chat"], {text = "Собеседник разблокирован", Nick = "мессенджер", type = "service", time = os.time()})
      SSDB_trigger = true
    end
  end
end


function imgui_settings_2_sms_hideandcol()
  if imgui.Checkbox("##HideSmsIn2", iHideSmsIn) then
    cfg.options.HideSmsIn = iHideSmsIn.v
    inicfg.save(cfg, "smes")
  end
  imgui.SameLine()
  if iHideSmsIn.v then
    imgui.Text(u8("Скрывать входящие сообщения?"))
  else
    imgui.TextDisabled(u8"Скрывать входящие сообщения?")
  end

  if imgui.Checkbox("##HideSmsOut", iHideSmsOut) then
    cfg.options.HideSmsOut = iHideSmsOut.v
    inicfg.save(cfg, "smes")
  end
  imgui.SameLine()
  if iHideSmsOut.v then
    imgui.Text(u8("Скрывать исходящие сообщения?"))
  else
    imgui.TextDisabled(u8"Скрывать исходящие сообщения?")
  end


  hidesmssent()

  if not cfg.options.HideSmsIn then
    if imgui.Checkbox("##iReplaceSmsInColor", iReplaceSmsInColor) then
      cfg.options.ReplaceSmsInColor = iReplaceSmsInColor.v
      inicfg.save(cfg, "smes")
    end
    imgui.SameLine()
    if iReplaceSmsInColor.v then
      imgui.Text(u8("Цвет входящих сообщений изменяется на: "))
      imgui.SameLine(295)
      imgui.Text("")
      imgui.SameLine()
      if imgui.ColorEdit4("##SmsInColor", SmsInColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha + imgui.ColorEditFlags.NoOptions) then
        cfg.colors.SmsInColor = imgui.ImColor.FromFloat4(SmsInColor.v[1], SmsInColor.v[2], SmsInColor.v[3], SmsInColor.v[4]):GetU32()
        local r, g, b, a = imgui.ImColor.FromFloat4(SmsInColor.v[1], SmsInColor.v[2], SmsInColor.v[3], SmsInColor.v[4]):GetRGBA()
        SmsInColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)
        inicfg.save(cfg, "smes")
      end
    else
      imgui.TextDisabled(u8"Изменять цвет входящих сообщений?")
    end
  end

  if not cfg.options.HideSmsOut then
    if imgui.Checkbox("##iReplaceSmsOutColor", iReplaceSmsOutColor) then
      cfg.options.ReplaceSmsOutColor = iReplaceSmsOutColor.v
      inicfg.save(cfg, "smes")
    end
    imgui.SameLine()
    if iReplaceSmsOutColor.v then
      imgui.Text(u8("Цвет исходящих сообщений изменяется на: "))
      imgui.SameLine(295)
      imgui.Text("")
      imgui.SameLine()
      if imgui.ColorEdit4("##SmsOutColor", SmsOutColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoAlpha + imgui.ColorEditFlags.NoOptions) then
        cfg.colors.SmsOutColor = imgui.ImColor.FromFloat4(SmsOutColor.v[1], SmsOutColor.v[2], SmsOutColor.v[3], SmsOutColor.v[4]):GetU32()
        local r, g, b, a = imgui.ImColor.FromFloat4(SmsOutColor.v[1], SmsOutColor.v[2], SmsOutColor.v[3], SmsOutColor.v[4]):GetRGBA()
        SmsOutColor_HEX = "0x"..string.sub(bit.tohex(join_argb(a, r, g, b)), 3, 8)
        inicfg.save(cfg, "smes")
      end
    else imgui.TextDisabled(u8"Изменять цвет исходящих сообщений в чате?")
    end
  end
  changesmssent()
end

function imgui_settings_6_sms_messanger()
  imgui.Text(u8("Цвета входящих смс в диалогах:"))
  imgui.SameLine(210)
  imgui.Text("")
  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет фона входящего смс", iINcolor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsInColor = imgui.ImColor.FromFloat4(iINcolor.v[1], iINcolor.v[2], iINcolor.v[3], iINcolor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end
  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет времени входящего смс", iSmsInTimeColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsInTimeColor = imgui.ImColor.FromFloat4(iSmsInTimeColor.v[1], iSmsInTimeColor.v[2], iSmsInTimeColor.v[3], iSmsInTimeColor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end

  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет заголовка входящего смс", iSmsInHeaderColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsInHeaderColor = imgui.ImColor.FromFloat4(iSmsInHeaderColor.v[1], iSmsInHeaderColor.v[2], iSmsInHeaderColor.v[3], iSmsInHeaderColor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end

  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет текста входящего смс", iSmsInTextColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsInTextColor = imgui.ImColor.FromFloat4(iSmsInTextColor.v[1], iSmsInTextColor.v[2], iSmsInTextColor.v[3], iSmsInTextColor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end

  if cfg.messanger.SmsInColor ~= imgui.ImColor(66.3, 150.45, 249.9, 102):GetU32() or cfg.messanger.SmsInTimeColor ~= imgui.ImColor(0, 0, 0):GetU32() or cfg.messanger.SmsInHeaderColor ~= imgui.ImColor(255, 255, 255):GetU32() or cfg.messanger.SmsInTextColor ~= imgui.ImColor(255, 255, 255):GetU32() then
    imgui.SameLine()
    if imgui.Button(u8"Сброс") then
      cfg.messanger.SmsInColor = imgui.ImColor(66.3, 150.45, 249.9, 102):GetU32()
      cfg.messanger.SmsInTimeColor = imgui.ImColor(0, 0, 0):GetU32()
      cfg.messanger.SmsInHeaderColor = imgui.ImColor(255, 255, 255):GetU32()
      cfg.messanger.SmsInTextColor = imgui.ImColor(255, 255, 255):GetU32()
      iINcolor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInColor):GetFloat4())
      iSmsInTimeColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInTimeColor ):GetFloat4())
      iSmsInHeaderColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInHeaderColor):GetFloat4())
      iSmsInTextColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsInTextColor):GetFloat4())
      inicfg.save(cfg, "smes")
    end
  end

  imgui.Text(u8("Цвета исходящих смс в диалогах:"))
  imgui.SameLine(210)
  imgui.Text("")
  imgui.SameLine()


  if imgui.ColorEdit4(u8"Цвет фона исходящих смс", iOUTcolor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsOutColor = imgui.ImColor.FromFloat4(iOUTcolor.v[1], iOUTcolor.v[2], iOUTcolor.v[3], iOUTcolor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end

  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет времени исходящего смс", iSmsOutTimeColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsOutTimeColor = imgui.ImColor.FromFloat4(iSmsOutTimeColor.v[1], iSmsOutTimeColor.v[2], iSmsOutTimeColor.v[3], iSmsOutTimeColor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end

  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет заголовка исходящего смс", iSmsOutHeaderColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsOutHeaderColor = imgui.ImColor.FromFloat4(iSmsOutHeaderColor.v[1], iSmsOutHeaderColor.v[2], iSmsOutHeaderColor.v[3], iSmsOutHeaderColor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end

  imgui.SameLine()
  if imgui.ColorEdit4(u8"Цвет текста исходящего смс", iSmsOutTextColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.NoOptions + imgui.ColorEditFlags.AlphaBar) then
    cfg.messanger.SmsOutTextColor = imgui.ImColor.FromFloat4(iSmsOutTextColor.v[1], iSmsOutTextColor.v[2], iSmsOutTextColor.v[3], iSmsOutTextColor.v[4]):GetU32()
    inicfg.save(cfg, "smes")
  end
  --
  if cfg.messanger.SmsOutColor ~= imgui.ImColor(66.3, 150.45, 249.9, 102):GetU32() or cfg.messanger.SmsOutTimeColor ~= imgui.ImColor(0, 0, 0):GetU32() or cfg.messanger.SmsOutHeaderColor ~= imgui.ImColor(255, 255, 255):GetU32() or cfg.messanger.SmsOutTextColor ~= imgui.ImColor(255, 255, 255):GetU32() then
    imgui.SameLine()
    if imgui.Button(u8"Сброс") then
      cfg.messanger.SmsOutColor = imgui.ImColor(66.3, 150.45, 249.9, 102):GetU32()
      cfg.messanger.SmsOutTimeColor = imgui.ImColor(0, 0, 0):GetU32()
      cfg.messanger.SmsOutHeaderColor = imgui.ImColor(255, 255, 255):GetU32()
      cfg.messanger.SmsOutTextColor = imgui.ImColor(255, 255, 255):GetU32()
      iOUTcolor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutColor):GetFloat4())
      iSmsOutTimeColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutTimeColor ):GetFloat4())
      iSmsOutHeaderColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutHeaderColor):GetFloat4())
      iSmsOutTextColor = imgui.ImFloat4(imgui.ImColor(cfg.messanger.SmsOutTextColor):GetFloat4())
      inicfg.save(cfg, "smes")
    end
  end
  if imgui.Checkbox("##включить сохранение бд смс", iStoreSMS) then
    if PREMIUM then
      if cfg.messanger.storesms == false then ingamelaunch = true imgui_messanger_sms_loadDB() end
      cfg.messanger.storesms = iStoreSMS.v
      inicfg.save(cfg, "smes")
    else
      imgui_itspremiuim()
    end
  end
  if not PREMIUM then iStoreSMS.v = false end
  if iStoreSMS.v then
    imgui.SameLine()
    kol = 0
    for k, v in pairs(sms) do
      kol = kol + 1
    end
    imgui.Text(u8:encode("СУБД активна. Количество диалогов: "..kol.."."))
    imgui.NewLine()
    imgui.SameLine(32)
    imgui.TextWrapped(u8:encode("Путь к БД: "..smsfile))
  else
    imgui.SameLine()
    imgui.TextDisabled(u8"Сохранять БД смс?")
    --imgui_messanger_sms_loadDB()
    if doesFileExist(smsfile) then
      imgui.SameLine()
      if imgui.Button(u8("Удалить БД")) then
        os.remove(smsfile)
        sms = {}
      end
    end
  end
end

function imgui_settings_13_sms_sounds()
  if not PREMIUM and iSoundSmsInNumber.v > 10 then iSoundSmsInNumber.v = math.random(1, 10) end
  if not PREMIUM and iSoundSmsOutNumber.v > 10 then iSoundSmsOutNumber.v = math.random(1, 10) end
  if imgui.Checkbox("##SoundSmsIn", iSoundSmsIn) then
    cfg.options.SoundSmsIn = iSoundSmsIn.v
    inicfg.save(cfg, "smes")
  end
  if iSoundSmsIn.v then
    imgui.SameLine()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - imgui.CalcTextSize(u8"Звук исходящего сообщения").x)
    imgui.SliderInt(u8"Звук входящего сообщения", iSoundSmsInNumber, 1, currentaudiokolDD)
    if iSoundSmsInNumber.v ~= cfg.options.SoundSmsInNumber and iSoundSmsInNumber.v <= currentaudiokolDD then
      PLAYSMSIN = true
      cfg.options.SoundSmsInNumber = iSoundSmsInNumber.v
      inicfg.save(cfg, "smes")
    end
  else
    imgui.SameLine()
    imgui.TextDisabled(u8"Включить уведомление о входящем сообщении?")
  end

  if imgui.Checkbox("##SoundSmsOut", iSoundSmsOut) then
    cfg.options.SoundSmsOut = iSoundSmsOut.v
    inicfg.save(cfg, "smes")
  end
  if iSoundSmsOut.v then
    imgui.SameLine()
    imgui.PushItemWidth(imgui.GetContentRegionAvailWidth() - imgui.CalcTextSize(u8"Звук исходящего сообщения").x)
    imgui.SliderInt(u8"Звук исходящего сообщения", iSoundSmsOutNumber, 1, currentaudiokolDD)
    if iSoundSmsOutNumber.v ~= cfg.options.SoundSmsOutNumber and iSoundSmsOutNumber.v <= currentaudiokolDD then
      PLAYSMSOUT = true
      cfg.options.SoundSmsOutNumber = iSoundSmsOutNumber.v
      inicfg.save(cfg, "smes")
    end
  else
    imgui.SameLine()
    imgui.TextDisabled(u8"Включить уведомление об исходящем сообщении?")
  end
end

function imgui_settings_14_hotkeys()
  hotk.v = {}
  hotke.v = hotkeys["hkMainMenu"]
  if ihk.HotKey("##hkMainMenu", hotke, hotk, 100) then
    if not hk.isHotKeyDefined(hotke.v) then
      if hk.isHotKeyDefined(hotk.v) then
        hk.unRegisterHotKey(hotk.v)
      end
    end
    cfg.hkMainMenu = {}
    for k, v in pairs(hotke.v) do
      table.insert(cfg.hkMainMenu, v)
    end
    if cfg.hkMainMenu == {} then cfg["hkMainMenu"][1] = 90 end
    inicfg.save(cfg, "smes")
    main_init_hotkeys()
  end
  imgui.SameLine()
  imgui.Text(u8"Горячая клавиша активации скрипта.")
  imgui.SameLine()
  imgui.TextDisabled("(?)")
  if imgui.IsItemHovered() then
    imgui.SetTooltip(u8"По нажатию хоткея открывается окно скрипта.")
  end

  if imgui.Checkbox("##imhk6", imhk6) then
    cfg.messanger.hotkey6 = imhk6.v
    inicfg.save(cfg, "smes")
    main_init_hotkeys()
  end
  imgui.SameLine()
  if imhk6.v then
    imgui.Text(u8("Хоткей фокуса на ввод в активном диалоге."))
  else
    imgui.TextDisabled(u8"Включить хоткей фокуса на ввод в активном диалоге?")
  end
  imgui.SameLine()
  imgui.TextDisabled("(?)")
  if imgui.IsItemHovered() then
    imgui.SetTooltip(u8"По нажатию хоткея устанавливается фокус на ввод сообщения в активном диалоге.")
  end

  if imhk6.v then
    hotk.v = {}
    hotke.v = hotkeys["hkm6"]
    if ihk.HotKey(u8"##hkm6", hotke, hotk, 100) then
      if not hk.isHotKeyDefined(hotke.v) then
        if hk.isHotKeyDefined(hotk.v) then
          hk.unRegisterHotKey(hotk.v)
        end
      end
      cfg.hkm6 = {}
      for k, v in pairs(hotke.v) do
        table.insert(cfg.hkm6, v)
      end
      if cfg.hkm6 == {} then cfg["hkm6"][6] = 13 end
      inicfg.save(cfg, "smes")
      main_init_hotkeys()
    end
    imgui.SameLine()
    imgui.Text(u8"Горячая клавиша фокуса на ввод в активном диалоге.")
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
      imgui.SetTooltip(u8"Если мессенджер и диалог открыт, фокус устанавливается на ввод сообщения.")
    end
  end


  if not PREMIUM then imhk4.v = false end
  if imgui.Checkbox("##imhk4", imhk4) then
    if PREMIUM then
      cfg.messanger.hotkey4 = imhk4.v
      main_init_hotkeys()
      inicfg.save(cfg, "smes")
    else
      imgui_itspremiuim()
    end
  end
  imgui.SameLine()
  if imhk4.v then
    imgui.Text(u8("Хоткей быстрого ответа через мессенджер sms включен."))
  else
    imgui.TextDisabled(u8"Включить хоткей быстрого ответа через мессенджер sms?")
  end
  imgui.SameLine()
  imgui.TextDisabled("(?)")
  if imgui.IsItemHovered() then
    if PREMIUM then
      imgui.SetTooltip(u8"По нажатию хоткея открывается/закрывается мессенджер sms с последним сообщением.\nЕсли он уже открыт, то фокус меняется на последнее сообщение.")
    else
      imgui.SetTooltip(u8"Только для PREMIUM-пользователей.\nПо нажатию хоткея открывается/закрывается мессенджер sms с последним сообщением.\nЕсли он уже открыт, то фокус меняется на последнее сообщение.")
    end
  end

  if imhk4.v and PREMIUM then
    hotk.v = {}
    hotke.v = hotkeys["hkm4"]
    if ihk.HotKey(u8"##hkm4", hotke, hotk, 100) then
      if not hk.isHotKeyDefined(hotke.v) then
        if hk.isHotKeyDefined(hotk.v) then
          hk.unRegisterHotKey(hotk.v)
        end
      end
      cfg.hkm4 = {}
      for k, v in pairs(hotke.v) do
        table.insert(cfg.hkm4, v)
      end
      if cfg.hkm4 == {} then cfg["hkm4"][4] = 54 end
      inicfg.save(cfg, "smes")
      main_init_hotkeys()
    end
    imgui.SameLine()
    imgui.Text(u8"Горячая клавиша быстрого ответа через мессенджер sms.")
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
      imgui.SetTooltip(u8"По нажатию хоткея открывается/закрывается мессенджер sms с последним сообщением.\nЕсли он уже открыт, то фокус меняется на последнее сообщение.")
    end
  end

  if imgui.Checkbox("##imhk5", imhk5) then
    if PREMIUM then
      cfg.messanger.hotkey5 = imhk5.v
      main_init_hotkeys()
      inicfg.save(cfg, "smes")
    else
      imgui_itspremiuim()
    end
  end
  if not PREMIUM then imhk5.v = false end
  imgui.SameLine()
  if imhk5.v then
    imgui.Text(u8("Хоткей создания диалога через sms мессенджер включен."))
  else
    imgui.TextDisabled(u8"Включить хоткей создания диалога через sms мессенджер?")
  end
  imgui.SameLine()
  imgui.TextDisabled("(?)")
  if imgui.IsItemHovered() then
    if PREMIUM then
      imgui.SetTooltip(u8"По нажатию хоткея открывается мессенджер смс с фокусом на ввод ника/id нового собеседника.")
    else
      imgui.SetTooltip(u8"Только для PREMIUM-пользователей.\nПо нажатию хоткея открывается мессенджер смс с фокусом на ввод ника/id нового собеседника.")
    end
  end


  if imhk5.v and PREMIUM then
    hotk.v = {}
    hotke.v = hotkeys["hkm5"]
    if ihk.HotKey(u8"##hkm5", hotke, hotk, 100) then
      if not hk.isHotKeyDefined(hotke.v) then
        if hk.isHotKeyDefined(hotk.v) then
          hk.unRegisterHotKey(hotk.v)
        end
      end
      cfg.hkm5 = {}
      for k, v in pairs(hotke.v) do
        table.insert(cfg.hkm5, v)
      end
      if cfg.hkm5 == {} then cfg["hkm5"][5] = 55 end
      inicfg.save(cfg, "smes")
      main_init_hotkeys()
    end
    imgui.SameLine()
    imgui.Text(u8"Горячая клавиша создания диалога через sms мессенджер.")
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
      imgui.SetTooltip(u8"По нажатию хоткея открывается мессенджер смс с фокусом на ввод ника/id нового собеседника.")
    end
  end
end

function imgui_settings_15_extra()
  if imgui.Checkbox(u8"Рендерить курсор силами gta?", MouseDrawCursor) then
    cfg.options.MouseDrawCursor = MouseDrawCursor.v
    imgui.GetIO().MouseDrawCursor = MouseDrawCursor.v
    inicfg.save(cfg, "smes")
  end
  imgui.SameLine()
  imgui.TextDisabled("(?)")
  if imgui.IsItemHovered() then
    imgui.SetTooltip(u8"Если включить, курсор будет отображаться на скринах.\nМинус: курсор будет немного лагать.")
  end
end

function apply_custom_style()
  imgui.SwitchContext()
  local style = imgui.GetStyle()
  local colors = style.Colors
  local clr = imgui.Col
  local ImVec4 = imgui.ImVec4
  style.WindowRounding = 2.0
  style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
  style.ChildWindowRounding = 2.0
  style.FrameRounding = 2.0
  style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
  style.ScrollbarSize = 13.0
  style.ScrollbarRounding = 0
  style.GrabMinSize = 8.0
  style.GrabRounding = 1.0
  colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
  colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
  colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94)
  colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 0.00)
  colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
  colors[clr.ComboBg] = colors[clr.PopupBg]
  colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
  colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
  colors[clr.FrameBg] = ImVec4(0.16, 0.29, 0.48, 0.54)
  colors[clr.FrameBgHovered] = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.FrameBgActive] = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.TitleBg] = ImVec4(0.04, 0.04, 0.04, 1.00)
  colors[clr.TitleBgActive] = ImVec4(0.16, 0.29, 0.48, 1.00)
  colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
  colors[clr.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00)
  colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
  colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
  colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
  colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00)
  colors[clr.CheckMark] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.SliderGrab] = ImVec4(0.24, 0.52, 0.88, 1.00)
  colors[clr.SliderGrabActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Button] = ImVec4(0.26, 0.59, 0.98, 0.40)
  colors[clr.ButtonHovered] = ImVec4(0, 0, 0, 1.00)
  colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
  colors[clr.Header] = ImVec4(0.26, 0.59, 0.98, 0.31)
  colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
  colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.Separator] = colors[clr.Border]
  colors[clr.SeparatorHovered] = ImVec4(0.26, 0.59, 0.98, 0.78)
  colors[clr.SeparatorActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
  colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
  colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
  colors[clr.ResizeGripActive] = ImVec4(0.26, 0.59, 0.98, 0.95)
  colors[clr.CloseButton] = ImVec4(0.41, 0.41, 0.41, 0.50)
  colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00)
  colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
  colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
  colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
  colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
  colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
  colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end
----------------------------------HELPERS---------------------------------------
do
  function join_argb(a, r, g, b)
    local argb = b -- b
    argb = bit.bor(argb, bit.lshift(g, 8)) -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
  end

  function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
      local ch = s:byte(i)
      if ch >= 192 and ch <= 223 then -- upper russian characters
        output = output .. russian_characters[ch + 32]
      elseif ch == 168 then -- Ё
        output = output .. russian_characters[184]
      else
        output = output .. string.char(ch)
      end
    end
    return output
  end

  function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
      local ch = s:byte(i)
      if ch >= 224 and ch <= 255 then -- lower russian characters
        output = output .. russian_characters[ch - 32]
      elseif ch == 184 then -- ё
        output = output .. russian_characters[168]
      else
        output = output .. string.char(ch)
      end
    end
    return output
  end


  local function exportstring( s )
    return string.format("%q", s)
  end

  --// The Save Function
  function table.save( tbl, filename )
    local charS, charE = "   ", "\n"
    local file, err = io.open( filename, "wb" )
    if err then return err end

    -- initiate variables for save procedure
    local tables, lookup = { tbl }, { [tbl] = 1 }
    file:write( "return {"..charE )

    for idx, t in ipairs( tables ) do
      file:write( "-- Table: {"..idx.."}"..charE )
      file:write( "{"..charE )
      local thandled = {}

      for i, v in ipairs( t ) do
        thandled[i] = true
        local stype = type( v )
        -- only handle value
        if stype == "table" then
          if not lookup[v] then
            table.insert( tables, v )
            lookup[v] = #tables
          end
          file:write( charS.."{"..lookup[v].."},"..charE )
        elseif stype == "string" then
          file:write( charS..exportstring( v )..","..charE )
        elseif stype == "number" then
          file:write( charS..tostring( v )..","..charE )
        end
      end

      for i, v in pairs( t ) do
        -- escape handled values
        if (not thandled[i]) then

          local str = ""
          local stype = type( i )
          -- handle index
          if stype == "table" then
            if not lookup[i] then
              table.insert( tables, i )
              lookup[i] = #tables
            end
            str = charS.."[{"..lookup[i].."}]="
          elseif stype == "string" then
            str = charS.."["..exportstring( i ).."]="
          elseif stype == "number" then
            str = charS.."["..tostring( i ).."]="
          end

          if str ~= "" then
            stype = type( v )
            -- handle value
            if stype == "table" then
              if not lookup[v] then
                table.insert( tables, v )
                lookup[v] = #tables
              end
              file:write( str.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
              file:write( str..exportstring( v )..","..charE )
            elseif stype == "number" then
              file:write( str..tostring( v )..","..charE )
            end
          end
        end
      end
      file:write( "},"..charE )
    end
    file:write( "}" )
    file:close()
  end

  --// The Load Function
  function table.load( sfile )
    local ftables, err = loadfile( sfile )
    if err then return _, err end
    local tables = ftables()
    for idx = 1, #tables do
      local tolinki = {}
      for i, v in pairs( tables[idx] ) do
        if type( v ) == "table" then
          tables[idx][i] = tables[v[1]]
        end
        if type( i ) == "table" and tables[i[1]] then
          table.insert( tolinki, { i, tables[i[1]] } )
        end
      end
      -- link indices
      for _, v in ipairs( tolinki ) do
        tables[idx][v[2]], tables[idx][v[1]] = tables[idx][v[1]], nil
      end
    end
    return tables[1]
  end
end
--------------------------------------------------------------------------------
------------------------------------UPDATE--------------------------------------
--------------------------------------------------------------------------------
function update(php, prefix, url, komanda)
  komandaA = komanda
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  local ffi = require 'ffi'
  ffi.cdef[[
	int __stdcall GetVolumeInformationA(
			const char* lpRootPathName,
			char* lpVolumeNameBuffer,
			uint32_t nVolumeNameSize,
			uint32_t* lpVolumeSerialNumber,
			uint32_t* lpMaximumComponentLength,
			uint32_t* lpFileSystemFlags,
			char* lpFileSystemNameBuffer,
			uint32_t nFileSystemNameSize
	);
	]]
  local serial = ffi.new("unsigned long[1]", 0)
  ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
  serial = serial[0]
  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local nickname = sampGetPlayerNickname(myid)
  if thisScript().name == "ADBLOCK" then
    if mode == nil then mode = "unsupported" end
    php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&m='..mode..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
  else
    php = php..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
  end
  downloadUrlToFile(php, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            if info.changelog ~= nil then
              changelogurl = info.changelog
            end
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix, komanda)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      if komandaA ~= nil then
                        sampAddChatMessage((prefix..'Обновление завершено! Подробнее об обновлении - /'..komandaA..'.'), color)
                      end
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end

function openchangelog(komanda, url)
  sampRegisterChatCommand(komanda,
    function()
      lua_thread.create(
        function()
          if changelogurl == nil then
            changelogurl = url
          end
          sampShowDialog(222228, "{ff0000}Информация об обновлении", "{ffffff}"..thisScript().name.." {ffe600}собирается открыть свой changelog для вас.\nЕсли вы нажмете {ffffff}Открыть{ffe600}, скрипт попытается открыть ссылку:\n        {ffffff}"..changelogurl.."\n{ffe600}Если ваша игра крашнется, вы можете открыть эту ссылку сами.", "Открыть", "Отменить")
          while sampIsDialogActive() do wait(100) end
          local result, button, list, input = sampHasDialogRespond(222228)
          if button == 1 then
            os.execute('explorer "'..changelogurl..'"')
          end
        end
      )
    end
  )
end
