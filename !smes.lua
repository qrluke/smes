--meta
script_name("SMES")
script_author("qrlk")
script_version("1.24")
script_dependencies('CLEO 4+', 'SAMPFUNCS', 'Dear Imgui', 'SAMP.Lua')
script_moonloader(026)
script_changelog = [[	v1.24 [31.03.2019]
* UPD: Обновлен шаблон смски для EPR, гении зачем-то точку добавили в конце.

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
              downloadUrlToFile("http://qrlk.me/dev/moonloader/cleo.asi", getGameDirectory().."\\cleo.asi",
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
            downloadUrlToFile("http://qrlk.me/dev/moonloader/SAMPFUNCS.asi", getGameDirectory().."\\SAMPFUNCS.asi",
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
          [getGameDirectory().."\\moonloader\\lib\\imgui.lua"] = "http://qrlk.me/dev/moonloader/lib/imgui.lua",
          [getGameDirectory().."\\moonloader\\lib\\MoonImGui.dll"] = "http://qrlk.me/dev/moonloader/lib/MoonImGui.dll"
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
          [getGameDirectory().."\\moonloader\\lib\\samp\\events.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\raknet.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/raknet.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\synchronization.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/synchronization.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\bitstream_io.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events/bitstream_io.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\core.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events/core.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\bitstream_io.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events/bitstream_io.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\extra_types.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events/extra_types.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\handlers.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events/handlers.lua",
          [getGameDirectory().."\\moonloader\\lib\\samp\\events\\utils.lua"] = "http://qrlk.me/dev/moonloader/lib/SAMP.Lua-master/samp/events/utils.lua",
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
        createDirectory(getGameDirectory().."\\moonloader\\resource\\smes\\"..mode)
        for i = 1, currentaudiokolDD do
          local file = getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\"..i..".mp3"
          if not doesFileExist(file) then
            v = "http://qrlk.me/dev/moonloader/smes/resource/smes/sounds/"..i..".mp3"
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

  function r_lib_vkeys()
    -- This file is part of SA MoonLoader package.
    -- Licensed under the MIT License.
    -- Copyright (c) 2016, BlastHack Team <blast.hk>


    local k = { VK_LBUTTON = 0x01, VK_RBUTTON = 0x02, VK_CANCEL = 0x03, VK_MBUTTON = 0x04, VK_XBUTTON1 = 0x05, VK_XBUTTON2 = 0x06, VK_BACK = 0x08, VK_TAB = 0x09, VK_CLEAR = 0x0C, VK_RETURN = 0x0D, VK_SHIFT = 0x10, VK_CONTROL = 0x11, VK_MENU = 0x12, VK_PAUSE = 0x13, VK_CAPITAL = 0x14, VK_KANA = 0x15, VK_JUNJA = 0x17, VK_FINAL = 0x18, VK_KANJI = 0x19, VK_ESCAPE = 0x1B, VK_CONVERT = 0x1C, VK_NONCONVERT = 0x1D, VK_ACCEPT = 0x1E, VK_MODECHANGE = 0x1F, VK_SPACE = 0x20, VK_PRIOR = 0x21, VK_NEXT = 0x22, VK_END = 0x23, VK_HOME = 0x24, VK_LEFT = 0x25, VK_UP = 0x26, VK_RIGHT = 0x27, VK_DOWN = 0x28, VK_SELECT = 0x29, VK_PRINT = 0x2A, VK_EXECUTE = 0x2B, VK_SNAPSHOT = 0x2C, VK_INSERT = 0x2D, VK_DELETE = 0x2E, VK_HELP = 0x2F, VK_0 = 0x30, VK_1 = 0x31, VK_2 = 0x32, VK_3 = 0x33, VK_4 = 0x34, VK_5 = 0x35, VK_6 = 0x36, VK_7 = 0x37, VK_8 = 0x38, VK_9 = 0x39, VK_A = 0x41, VK_B = 0x42, VK_C = 0x43, VK_D = 0x44, VK_E = 0x45, VK_F = 0x46, VK_G = 0x47, VK_H = 0x48, VK_I = 0x49, VK_J = 0x4A, VK_K = 0x4B, VK_L = 0x4C, VK_M = 0x4D, VK_N = 0x4E, VK_O = 0x4F, VK_P = 0x50, VK_Q = 0x51, VK_R = 0x52, VK_S = 0x53, VK_T = 0x54, VK_U = 0x55, VK_V = 0x56, VK_W = 0x57, VK_X = 0x58, VK_Y = 0x59, VK_Z = 0x5A, VK_LWIN = 0x5B, VK_RWIN = 0x5C, VK_APPS = 0x5D, VK_SLEEP = 0x5F, VK_NUMPAD0 = 0x60, VK_NUMPAD1 = 0x61, VK_NUMPAD2 = 0x62, VK_NUMPAD3 = 0x63, VK_NUMPAD4 = 0x64, VK_NUMPAD5 = 0x65, VK_NUMPAD6 = 0x66, VK_NUMPAD7 = 0x67, VK_NUMPAD8 = 0x68, VK_NUMPAD9 = 0x69, VK_MULTIPLY = 0x6A, VK_ADD = 0x6B, VK_SEPARATOR = 0x6C, VK_SUBTRACT = 0x6D, VK_DECIMAL = 0x6E, VK_DIVIDE = 0x6F, VK_F1 = 0x70, VK_F2 = 0x71, VK_F3 = 0x72, VK_F4 = 0x73, VK_F5 = 0x74, VK_F6 = 0x75, VK_F7 = 0x76, VK_F8 = 0x77, VK_F9 = 0x78, VK_F10 = 0x79, VK_F11 = 0x7A, VK_F12 = 0x7B, VK_F13 = 0x7C, VK_F14 = 0x7D, VK_F15 = 0x7E, VK_F16 = 0x7F, VK_F17 = 0x80, VK_F18 = 0x81, VK_F19 = 0x82, VK_F20 = 0x83, VK_F21 = 0x84, VK_F22 = 0x85, VK_F23 = 0x86, VK_F24 = 0x87, VK_NUMLOCK = 0x90, VK_SCROLL = 0x91, VK_OEM_FJ_JISHO = 0x92, VK_OEM_FJ_MASSHOU = 0x93, VK_OEM_FJ_TOUROKU = 0x94, VK_OEM_FJ_LOYA = 0x95, VK_OEM_FJ_ROYA = 0x96, VK_LSHIFT = 0xA0, VK_RSHIFT = 0xA1, VK_LCONTROL = 0xA2, VK_RCONTROL = 0xA3, VK_LMENU = 0xA4, VK_RMENU = 0xA5, VK_BROWSER_BACK = 0xA6, VK_BROWSER_FORWARD = 0xA7, VK_BROWSER_REFRESH = 0xA8, VK_BROWSER_STOP = 0xA9, VK_BROWSER_SEARCH = 0xAA, VK_BROWSER_FAVORITES = 0xAB, VK_BROWSER_HOME = 0xAC, VK_VOLUME_MUTE = 0xAD, VK_VOLUME_DOWN = 0xAE, VK_VOLUME_UP = 0xAF, VK_MEDIA_NEXT_TRACK = 0xB0, VK_MEDIA_PREV_TRACK = 0xB1, VK_MEDIA_STOP = 0xB2, VK_MEDIA_PLAY_PAUSE = 0xB3, VK_LAUNCH_MAIL = 0xB4, VK_LAUNCH_MEDIA_SELECT = 0xB5, VK_LAUNCH_APP1 = 0xB6, VK_LAUNCH_APP2 = 0xB7, VK_OEM_1 = 0xBA, VK_OEM_PLUS = 0xBB, VK_OEM_COMMA = 0xBC, VK_OEM_MINUS = 0xBD, VK_OEM_PERIOD = 0xBE, VK_OEM_2 = 0xBF, VK_OEM_3 = 0xC0, VK_ABNT_C1 = 0xC1, VK_ABNT_C2 = 0xC2, VK_OEM_4 = 0xDB, VK_OEM_5 = 0xDC, VK_OEM_6 = 0xDD, VK_OEM_7 = 0xDE, VK_OEM_8 = 0xDF, VK_OEM_AX = 0xE1, VK_OEM_102 = 0xE2, VK_ICO_HELP = 0xE3, VK_PROCESSKEY = 0xE5, VK_ICO_CLEAR = 0xE6, VK_PACKET = 0xE7, VK_OEM_RESET = 0xE9, VK_OEM_JUMP = 0xEA, VK_OEM_PA1 = 0xEB, VK_OEM_PA2 = 0xEC, VK_OEM_PA3 = 0xED, VK_OEM_WSCTRL = 0xEE, VK_OEM_CUSEL = 0xEF, VK_OEM_ATTN = 0xF0, VK_OEM_FINISH = 0xF1, VK_OEM_COPY = 0xF2, VK_OEM_AUTO = 0xF3, VK_OEM_ENLW = 0xF4, VK_OEM_BACKTAB = 0xF5, VK_ATTN = 0xF6, VK_CRSEL = 0xF7, VK_EXSEL = 0xF8, VK_EREOF = 0xF9, VK_PLAY = 0xFA, VK_ZOOM = 0xFB, VK_PA1 = 0xFD, VK_OEM_CLEAR = 0xFE,
    }

    local names = {
      [k.VK_LBUTTON] = 'Left Button',
      [k.VK_RBUTTON] = 'Right Button',
      [k.VK_CANCEL] = 'Break',
      [k.VK_MBUTTON] = 'Middle Button',
      [k.VK_XBUTTON1] = 'X Button 1',
      [k.VK_XBUTTON2] = 'X Button 2',
      [k.VK_BACK] = 'Backspace',
      [k.VK_TAB] = 'Tab',
      [k.VK_CLEAR] = 'Clear',
      [k.VK_RETURN] = 'Enter',
      [k.VK_SHIFT] = 'Shift',
      [k.VK_CONTROL] = 'Ctrl',
      [k.VK_MENU] = 'Alt',
      [k.VK_PAUSE] = 'Pause',
      [k.VK_CAPITAL] = 'Caps Lock',
      [k.VK_KANA] = 'Kana',
      [k.VK_JUNJA] = 'Junja',
      [k.VK_FINAL] = 'Final',
      [k.VK_KANJI] = 'Kanji',
      [k.VK_ESCAPE] = 'Esc',
      [k.VK_CONVERT] = 'Convert',
      [k.VK_NONCONVERT] = 'Non Convert',
      [k.VK_ACCEPT] = 'Accept',
      [k.VK_MODECHANGE] = 'Mode Change',
      [k.VK_SPACE] = 'Space',
      [k.VK_PRIOR] = 'Page Up',
      [k.VK_NEXT] = 'Page Down',
      [k.VK_END] = 'End',
      [k.VK_HOME] = 'Home',
      [k.VK_LEFT] = 'Arrow Left',
      [k.VK_UP] = 'Arrow Up',
      [k.VK_RIGHT] = 'Arrow Right',
      [k.VK_DOWN] = 'Arrow Down',
      [k.VK_SELECT] = 'Select',
      [k.VK_PRINT] = 'Print',
      [k.VK_EXECUTE] = 'Execute',
      [k.VK_SNAPSHOT] = 'Print Screen',
      [k.VK_INSERT] = 'Insert',
      [k.VK_DELETE] = 'Delete',
      [k.VK_HELP] = 'Help',
      [k.VK_0] = '0',
      [k.VK_1] = '1',
      [k.VK_2] = '2',
      [k.VK_3] = '3',
      [k.VK_4] = '4',
      [k.VK_5] = '5',
      [k.VK_6] = '6',
      [k.VK_7] = '7',
      [k.VK_8] = '8',
      [k.VK_9] = '9',
      [k.VK_A] = 'A',
      [k.VK_B] = 'B',
      [k.VK_C] = 'C',
      [k.VK_D] = 'D',
      [k.VK_E] = 'E',
      [k.VK_F] = 'F',
      [k.VK_G] = 'G',
      [k.VK_H] = 'H',
      [k.VK_I] = 'I',
      [k.VK_J] = 'J',
      [k.VK_K] = 'K',
      [k.VK_L] = 'L',
      [k.VK_M] = 'M',
      [k.VK_N] = 'N',
      [k.VK_O] = 'O',
      [k.VK_P] = 'P',
      [k.VK_Q] = 'Q',
      [k.VK_R] = 'R',
      [k.VK_S] = 'S',
      [k.VK_T] = 'T',
      [k.VK_U] = 'U',
      [k.VK_V] = 'V',
      [k.VK_W] = 'W',
      [k.VK_X] = 'X',
      [k.VK_Y] = 'Y',
      [k.VK_Z] = 'Z',
      [k.VK_LWIN] = 'Left Win',
      [k.VK_RWIN] = 'Right Win',
      [k.VK_APPS] = 'Context Menu',
      [k.VK_SLEEP] = 'Sleep',
      [k.VK_NUMPAD0] = 'Numpad 0',
      [k.VK_NUMPAD1] = 'Numpad 1',
      [k.VK_NUMPAD2] = 'Numpad 2',
      [k.VK_NUMPAD3] = 'Numpad 3',
      [k.VK_NUMPAD4] = 'Numpad 4',
      [k.VK_NUMPAD5] = 'Numpad 5',
      [k.VK_NUMPAD6] = 'Numpad 6',
      [k.VK_NUMPAD7] = 'Numpad 7',
      [k.VK_NUMPAD8] = 'Numpad 8',
      [k.VK_NUMPAD9] = 'Numpad 9',
      [k.VK_MULTIPLY] = 'Numpad *',
      [k.VK_ADD] = 'Numpad +',
      [k.VK_SEPARATOR] = 'Separator',
      [k.VK_SUBTRACT] = 'Num -',
      [k.VK_DECIMAL] = 'Numpad .',
      [k.VK_DIVIDE] = 'Numpad /',
      [k.VK_F1] = 'F1',
      [k.VK_F2] = 'F2',
      [k.VK_F3] = 'F3',
      [k.VK_F4] = 'F4',
      [k.VK_F5] = 'F5',
      [k.VK_F6] = 'F6',
      [k.VK_F7] = 'F7',
      [k.VK_F8] = 'F8',
      [k.VK_F9] = 'F9',
      [k.VK_F10] = 'F10',
      [k.VK_F11] = 'F11',
      [k.VK_F12] = 'F12',
      [k.VK_F13] = 'F13',
      [k.VK_F14] = 'F14',
      [k.VK_F15] = 'F15',
      [k.VK_F16] = 'F16',
      [k.VK_F17] = 'F17',
      [k.VK_F18] = 'F18',
      [k.VK_F19] = 'F19',
      [k.VK_F20] = 'F20',
      [k.VK_F21] = 'F21',
      [k.VK_F22] = 'F22',
      [k.VK_F23] = 'F23',
      [k.VK_F24] = 'F24',
      [k.VK_NUMLOCK] = 'Num Lock',
      [k.VK_SCROLL] = 'Scrol Lock',
      [k.VK_OEM_FJ_JISHO] = 'Jisho',
      [k.VK_OEM_FJ_MASSHOU] = 'Mashu',
      [k.VK_OEM_FJ_TOUROKU] = 'Touroku',
      [k.VK_OEM_FJ_LOYA] = 'Loya',
      [k.VK_OEM_FJ_ROYA] = 'Roya',
      [k.VK_LSHIFT] = 'Left Shift',
      [k.VK_RSHIFT] = 'Right Shift',
      [k.VK_LCONTROL] = 'Left Ctrl',
      [k.VK_RCONTROL] = 'Right Ctrl',
      [k.VK_LMENU] = 'Left Alt',
      [k.VK_RMENU] = 'Right Alt',
      [k.VK_BROWSER_BACK] = 'Browser Back',
      [k.VK_BROWSER_FORWARD] = 'Browser Forward',
      [k.VK_BROWSER_REFRESH] = 'Browser Refresh',
      [k.VK_BROWSER_STOP] = 'Browser Stop',
      [k.VK_BROWSER_SEARCH] = 'Browser Search',
      [k.VK_BROWSER_FAVORITES] = 'Browser Favorites',
      [k.VK_BROWSER_HOME] = 'Browser Home',
      [k.VK_VOLUME_MUTE] = 'Volume Mute',
      [k.VK_VOLUME_DOWN] = 'Volume Down',
      [k.VK_VOLUME_UP] = 'Volume Up',
      [k.VK_MEDIA_NEXT_TRACK] = 'Next Track',
      [k.VK_MEDIA_PREV_TRACK] = 'Previous Track',
      [k.VK_MEDIA_STOP] = 'Stop',
      [k.VK_MEDIA_PLAY_PAUSE] = 'Play / Pause',
      [k.VK_LAUNCH_MAIL] = 'Mail',
      [k.VK_LAUNCH_MEDIA_SELECT] = 'Media',
      [k.VK_LAUNCH_APP1] = 'App1',
      [k.VK_LAUNCH_APP2] = 'App2',
      [k.VK_OEM_1] = {';', ':'},
      [k.VK_OEM_PLUS] = {'=', '+'},
      [k.VK_OEM_COMMA] = {',', '<'},
      [k.VK_OEM_MINUS] = {'-', '_'},
      [k.VK_OEM_PERIOD] = {'.', '>'},
      [k.VK_OEM_2] = {'/', '?'},
      [k.VK_OEM_3] = {'`', '~'},
      [k.VK_ABNT_C1] = 'Abnt C1',
      [k.VK_ABNT_C2] = 'Abnt C2',
      [k.VK_OEM_4] = {'[', '{'},
      [k.VK_OEM_5] = {'\'', '|'},
      [k.VK_OEM_6] = {']', '}'},
      [k.VK_OEM_7] = {'\'', '"'},
      [k.VK_OEM_8] = {'!', '§'},
      [k.VK_OEM_AX] = 'Ax',
      [k.VK_OEM_102] = '> <',
      [k.VK_ICO_HELP] = 'IcoHlp',
      [k.VK_PROCESSKEY] = 'Process',
      [k.VK_ICO_CLEAR] = 'IcoClr',
      [k.VK_PACKET] = 'Packet',
      [k.VK_OEM_RESET] = 'Reset',
      [k.VK_OEM_JUMP] = 'Jump',
      [k.VK_OEM_PA1] = 'OemPa1',
      [k.VK_OEM_PA2] = 'OemPa2',
      [k.VK_OEM_PA3] = 'OemPa3',
      [k.VK_OEM_WSCTRL] = 'WsCtrl',
      [k.VK_OEM_CUSEL] = 'Cu Sel',
      [k.VK_OEM_ATTN] = 'Oem Attn',
      [k.VK_OEM_FINISH] = 'Finish',
      [k.VK_OEM_COPY] = 'Copy',
      [k.VK_OEM_AUTO] = 'Auto',
      [k.VK_OEM_ENLW] = 'Enlw',
      [k.VK_OEM_BACKTAB] = 'Back Tab',
      [k.VK_ATTN] = 'Attn',
      [k.VK_CRSEL] = 'Cr Sel',
      [k.VK_EXSEL] = 'Ex Sel',
      [k.VK_EREOF] = 'Er Eof',
      [k.VK_PLAY] = 'Play',
      [k.VK_ZOOM] = 'Zoom',
      [k.VK_PA1] = 'Pa1',
      [k.VK_OEM_CLEAR] = 'OemClr'
    }

    k.key_names = names

    function k.id_to_name(vkey)
      local name = names[vkey]
      if type(name) == 'table' then
        return name[1]
      end
      return name
    end

    function k.name_to_id(keyname, case_sensitive)
      if not case_sensitive then
        keyname = string.upper(keyname)
      end
      for id, v in pairs(names) do
        if type(v) == 'table' then
          for _, v2 in pairs(v) do
            v2 = (case_sensitive) and v2 or string.upper(v2)
            if v2 == keyname then
              return id
            end
          end
        else
          local name = (case_sensitive) and v or string.upper(v)
          if name == keyname then
            return id
          end
        end
      end
    end

    return k
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
    local vkeys = r_lib_vkeys()

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

  function r_lib_window_message()
    -- This file is part of SA MoonLoader package.
    -- Licensed under the MIT License.
    -- Copyright (c) 2016, BlastHack Team <blast.hk>

    -- From https://wiki.winehq.org/List_Of_Windows_Messages
    local messages = { WM_CREATE = 0x0001, WM_DESTROY = 0x0002, WM_MOVE = 0x0003, WM_SIZE = 0x0005, WM_ACTIVATE = 0x0006, WM_SETFOCUS = 0x0007, WM_KILLFOCUS = 0x0008, WM_ENABLE = 0x000a, WM_SETREDRAW = 0x000b, WM_SETTEXT = 0x000c, WM_GETTEXT = 0x000d, WM_GETTEXTLENGTH = 0x000e, WM_PAINT = 0x000f, WM_CLOSE = 0x0010, WM_QUERYENDSESSION = 0x0011, WM_QUIT = 0x0012, WM_QUERYOPEN = 0x0013, WM_ERASEBKGND = 0x0014, WM_SYSCOLORCHANGE = 0x0015, WM_ENDSESSION = 0x0016, WM_SHOWWINDOW = 0x0018, WM_CTLCOLOR = 0x0019, WM_WININICHANGE = 0x001a, WM_DEVMODECHANGE = 0x001b, WM_ACTIVATEAPP = 0x001c, WM_FONTCHANGE = 0x001d, WM_TIMECHANGE = 0x001e, WM_CANCELMODE = 0x001f, WM_SETCURSOR = 0x0020, WM_MOUSEACTIVATE = 0x0021, WM_CHILDACTIVATE = 0x0022, WM_QUEUESYNC = 0x0023, WM_GETMINMAXINFO = 0x0024, WM_PAINTICON = 0x0026, WM_ICONERASEBKGND = 0x0027, WM_NEXTDLGCTL = 0x0028, WM_SPOOLERSTATUS = 0x002a, WM_DRAWITEM = 0x002b, WM_MEASUREITEM = 0x002c, WM_DELETEITEM = 0x002d, WM_VKEYTOITEM = 0x002e, WM_CHARTOITEM = 0x002f, WM_SETFONT = 0x0030, WM_GETFONT = 0x0031, WM_SETHOTKEY = 0x0032, WM_GETHOTKEY = 0x0033, WM_QUERYDRAGICON = 0x0037, WM_COMPAREITEM = 0x0039, WM_GETOBJECT = 0x003d, WM_COMPACTING = 0x0041, WM_COMMNOTIFY = 0x0044, WM_WINDOWPOSCHANGING = 0x0046, WM_WINDOWPOSCHANGED = 0x0047, WM_POWER = 0x0048, WM_COPYGLOBALDATA = 0x0049, WM_COPYDATA = 0x004a, WM_CANCELJOURNAL = 0x004b, WM_NOTIFY = 0x004e, WM_INPUTLANGCHANGEREQUEST = 0x0050, WM_INPUTLANGCHANGE = 0x0051, WM_TCARD = 0x0052, WM_HELP = 0x0053, WM_USERCHANGED = 0x0054, WM_NOTIFYFORMAT = 0x0055, WM_CONTEXTMENU = 0x007b, WM_STYLECHANGING = 0x007c, WM_STYLECHANGED = 0x007d, WM_DISPLAYCHANGE = 0x007e, WM_GETICON = 0x007f, WM_SETICON = 0x0080, WM_NCCREATE = 0x0081, WM_NCDESTROY = 0x0082, WM_NCCALCSIZE = 0x0083, WM_NCHITTEST = 0x0084, WM_NCPAINT = 0x0085, WM_NCACTIVATE = 0x0086, WM_GETDLGCODE = 0x0087, WM_SYNCPAINT = 0x0088, WM_NCMOUSEMOVE = 0x00a0, WM_NCLBUTTONDOWN = 0x00a1, WM_NCLBUTTONUP = 0x00a2, WM_NCLBUTTONDBLCLK = 0x00a3, WM_NCRBUTTONDOWN = 0x00a4, WM_NCRBUTTONUP = 0x00a5, WM_NCRBUTTONDBLCLK = 0x00a6, WM_NCMBUTTONDOWN = 0x00a7, WM_NCMBUTTONUP = 0x00a8, WM_NCMBUTTONDBLCLK = 0x00a9, WM_NCXBUTTONDOWN = 0x00ab, WM_NCXBUTTONUP = 0x00ac, WM_NCXBUTTONDBLCLK = 0x00ad, EM_GETSEL = 0x00b0, EM_SETSEL = 0x00b1, EM_GETRECT = 0x00b2, EM_SETRECT = 0x00b3, EM_SETRECTNP = 0x00b4, EM_SCROLL = 0x00b5, EM_LINESCROLL = 0x00b6, EM_SCROLLCARET = 0x00b7, EM_GETMODIFY = 0x00b8, EM_SETMODIFY = 0x00b9, EM_GETLINECOUNT = 0x00ba, EM_LINEINDEX = 0x00bb, EM_SETHANDLE = 0x00bc, EM_GETHANDLE = 0x00bd, EM_GETTHUMB = 0x00be, EM_LINELENGTH = 0x00c1, EM_REPLACESEL = 0x00c2, EM_SETFONT = 0x00c3, EM_GETLINE = 0x00c4, EM_LIMITTEXT = 0x00c5, EM_SETLIMITTEXT = 0x00c5, EM_CANUNDO = 0x00c6, EM_UNDO = 0x00c7, EM_FMTLINES = 0x00c8, EM_LINEFROMCHAR = 0x00c9, EM_SETWORDBREAK = 0x00ca, EM_SETTABSTOPS = 0x00cb, EM_SETPASSWORDCHAR = 0x00cc, EM_EMPTYUNDOBUFFER = 0x00cd, EM_GETFIRSTVISIBLELINE = 0x00ce, EM_SETREADONLY = 0x00cf, EM_SETWORDBREAKPROC = 0x00d0, EM_GETWORDBREAKPROC = 0x00d1, EM_GETPASSWORDCHAR = 0x00d2, EM_SETMARGINS = 0x00d3, EM_GETMARGINS = 0x00d4, EM_GETLIMITTEXT = 0x00d5, EM_POSFROMCHAR = 0x00d6, EM_CHARFROMPOS = 0x00d7, EM_SETIMESTATUS = 0x00d8, EM_GETIMESTATUS = 0x00d9, SBM_SETPOS = 0x00e0, SBM_GETPOS = 0x00e1, SBM_SETRANGE = 0x00e2, SBM_GETRANGE = 0x00e3, SBM_ENABLE_ARROWS = 0x00e4, SBM_SETRANGEREDRAW = 0x00e6, SBM_SETSCROLLINFO = 0x00e9, SBM_GETSCROLLINFO = 0x00ea, SBM_GETSCROLLBARINFO = 0x00eb, BM_GETCHECK = 0x00f0, BM_SETCHECK = 0x00f1, BM_GETSTATE = 0x00f2, BM_SETSTATE = 0x00f3, BM_SETSTYLE = 0x00f4, BM_CLICK = 0x00f5, BM_GETIMAGE = 0x00f6, BM_SETIMAGE = 0x00f7, BM_SETDONTCLICK = 0x00f8, WM_INPUT = 0x00ff, WM_KEYDOWN = 0x0100, WM_KEYFIRST = 0x0100, WM_KEYUP = 0x0101, WM_CHAR = 0x0102, WM_DEADCHAR = 0x0103, WM_SYSKEYDOWN = 0x0104, WM_SYSKEYUP = 0x0105, WM_SYSCHAR = 0x0106, WM_SYSDEADCHAR = 0x0107, WM_KEYLAST = 0x0108, WM_UNICHAR = 0x0109, WM_WNT_CONVERTREQUESTEX = 0x0109, WM_CONVERTREQUEST = 0x010a, WM_CONVERTRESULT = 0x010b, WM_INTERIM = 0x010c, WM_IME_STARTCOMPOSITION = 0x010d, WM_IME_ENDCOMPOSITION = 0x010e, WM_IME_COMPOSITION = 0x010f, WM_IME_KEYLAST = 0x010f, WM_INITDIALOG = 0x0110, WM_COMMAND = 0x0111, WM_SYSCOMMAND = 0x0112, WM_TIMER = 0x0113, WM_HSCROLL = 0x0114, WM_VSCROLL = 0x0115, WM_INITMENU = 0x0116, WM_INITMENUPOPUP = 0x0117, WM_SYSTIMER = 0x0118, WM_MENUSELECT = 0x011f, WM_MENUCHAR = 0x0120, WM_ENTERIDLE = 0x0121, WM_MENURBUTTONUP = 0x0122, WM_MENUDRAG = 0x0123, WM_MENUGETOBJECT = 0x0124, WM_UNINITMENUPOPUP = 0x0125, WM_MENUCOMMAND = 0x0126, WM_CHANGEUISTATE = 0x0127, WM_UPDATEUISTATE = 0x0128, WM_QUERYUISTATE = 0x0129, WM_CTLCOLORMSGBOX = 0x0132, WM_CTLCOLOREDIT = 0x0133, WM_CTLCOLORLISTBOX = 0x0134, WM_CTLCOLORBTN = 0x0135, WM_CTLCOLORDLG = 0x0136, WM_CTLCOLORSCROLLBAR = 0x0137, WM_CTLCOLORSTATIC = 0x0138, WM_MOUSEFIRST = 0x0200, WM_MOUSEMOVE = 0x0200, WM_LBUTTONDOWN = 0x0201, WM_LBUTTONUP = 0x0202, WM_LBUTTONDBLCLK = 0x0203, WM_RBUTTONDOWN = 0x0204, WM_RBUTTONUP = 0x0205, WM_RBUTTONDBLCLK = 0x0206, WM_MBUTTONDOWN = 0x0207, WM_MBUTTONUP = 0x0208, WM_MBUTTONDBLCLK = 0x0209, WM_MOUSELAST = 0x0209, WM_MOUSEWHEEL = 0x020a, WM_XBUTTONDOWN = 0x020b, WM_XBUTTONUP = 0x020c, WM_XBUTTONDBLCLK = 0x020d, WM_PARENTNOTIFY = 0x0210, WM_ENTERMENULOOP = 0x0211, WM_EXITMENULOOP = 0x0212, WM_NEXTMENU = 0x0213, WM_SIZING = 0x0214, WM_CAPTURECHANGED = 0x0215, WM_MOVING = 0x0216, WM_POWERBROADCAST = 0x0218, WM_DEVICECHANGE = 0x0219, WM_MDICREATE = 0x0220, WM_MDIDESTROY = 0x0221, WM_MDIACTIVATE = 0x0222, WM_MDIRESTORE = 0x0223, WM_MDINEXT = 0x0224, WM_MDIMAXIMIZE = 0x0225, WM_MDITILE = 0x0226, WM_MDICASCADE = 0x0227, WM_MDIICONARRANGE = 0x0228, WM_MDIGETACTIVE = 0x0229, WM_MDISETMENU = 0x0230, WM_ENTERSIZEMOVE = 0x0231, WM_EXITSIZEMOVE = 0x0232, WM_DROPFILES = 0x0233, WM_MDIREFRESHMENU = 0x0234, WM_IME_REPORT = 0x0280, WM_IME_SETCONTEXT = 0x0281, WM_IME_NOTIFY = 0x0282, WM_IME_CONTROL = 0x0283, WM_IME_COMPOSITIONFULL = 0x0284, WM_IME_SELECT = 0x0285, WM_IME_CHAR = 0x0286, WM_IME_REQUEST = 0x0288, WM_IMEKEYDOWN = 0x0290, WM_IME_KEYDOWN = 0x0290, WM_IMEKEYUP = 0x0291, WM_IME_KEYUP = 0x0291, WM_NCMOUSEHOVER = 0x02a0, WM_MOUSEHOVER = 0x02a1, WM_NCMOUSELEAVE = 0x02a2, WM_MOUSELEAVE = 0x02a3, WM_CUT = 0x0300, WM_COPY = 0x0301, WM_PASTE = 0x0302, WM_CLEAR = 0x0303, WM_UNDO = 0x0304, WM_RENDERFORMAT = 0x0305, WM_RENDERALLFORMATS = 0x0306, WM_DESTROYCLIPBOARD = 0x0307, WM_DRAWCLIPBOARD = 0x0308, WM_PAINTCLIPBOARD = 0x0309, WM_VSCROLLCLIPBOARD = 0x030a, WM_SIZECLIPBOARD = 0x030b, WM_ASKCBFORMATNAME = 0x030c, WM_CHANGECBCHAIN = 0x030d, WM_HSCROLLCLIPBOARD = 0x030e, WM_QUERYNEWPALETTE = 0x030f, WM_PALETTEISCHANGING = 0x0310, WM_PALETTECHANGED = 0x0311, WM_HOTKEY = 0x0312, WM_PRINT = 0x0317, WM_PRINTCLIENT = 0x0318, WM_APPCOMMAND = 0x0319, WM_HANDHELDFIRST = 0x0358, WM_HANDHELDLAST = 0x035f, WM_AFXFIRST = 0x0360, WM_AFXLAST = 0x037f, WM_PENWINFIRST = 0x0380, WM_RCRESULT = 0x0381, WM_HOOKRCRESULT = 0x0382, WM_GLOBALRCCHANGE = 0x0383, WM_PENMISCINFO = 0x0383, WM_SKB = 0x0384, WM_HEDITCTL = 0x0385, WM_PENCTL = 0x0385, WM_PENMISC = 0x0386, WM_CTLINIT = 0x0387, WM_PENEVENT = 0x0388, WM_PENWINLAST = 0x038f, DDM_SETFMT = 0x0400, DM_GETDEFID = 0x0400, NIN_SELECT = 0x0400, TBM_GETPOS = 0x0400, WM_PSD_PAGESETUPDLG = 0x0400, WM_USER = 0x0400, CBEM_INSERTITEMA = 0x0401, DDM_DRAW = 0x0401, DM_SETDEFID = 0x0401, HKM_SETHOTKEY = 0x0401, PBM_SETRANGE = 0x0401, RB_INSERTBANDA = 0x0401, SB_SETTEXTA = 0x0401, TB_ENABLEBUTTON = 0x0401, TBM_GETRANGEMIN = 0x0401, TTM_ACTIVATE = 0x0401, WM_CHOOSEFONT_GETLOGFONT = 0x0401, WM_PSD_FULLPAGERECT = 0x0401, CBEM_SETIMAGELIST = 0x0402, DDM_CLOSE = 0x0402, DM_REPOSITION = 0x0402, HKM_GETHOTKEY = 0x0402, PBM_SETPOS = 0x0402, RB_DELETEBAND = 0x0402, SB_GETTEXTA = 0x0402, TB_CHECKBUTTON = 0x0402, TBM_GETRANGEMAX = 0x0402, WM_PSD_MINMARGINRECT = 0x0402, CBEM_GETIMAGELIST = 0x0403, DDM_BEGIN = 0x0403, HKM_SETRULES = 0x0403, PBM_DELTAPOS = 0x0403, RB_GETBARINFO = 0x0403, SB_GETTEXTLENGTHA = 0x0403, TBM_GETTIC = 0x0403, TB_PRESSBUTTON = 0x0403, TTM_SETDELAYTIME = 0x0403, WM_PSD_MARGINRECT = 0x0403, CBEM_GETITEMA = 0x0404, DDM_END = 0x0404, PBM_SETSTEP = 0x0404, RB_SETBARINFO = 0x0404, SB_SETPARTS = 0x0404, TB_HIDEBUTTON = 0x0404, TBM_SETTIC = 0x0404, TTM_ADDTOOLA = 0x0404, WM_PSD_GREEKTEXTRECT = 0x0404, CBEM_SETITEMA = 0x0405, PBM_STEPIT = 0x0405, TB_INDETERMINATE = 0x0405, TBM_SETPOS = 0x0405, TTM_DELTOOLA = 0x0405, WM_PSD_ENVSTAMPRECT = 0x0405, CBEM_GETCOMBOCONTROL = 0x0406, PBM_SETRANGE32 = 0x0406, RB_SETBANDINFOA = 0x0406, SB_GETPARTS = 0x0406, TB_MARKBUTTON = 0x0406, TBM_SETRANGE = 0x0406, TTM_NEWTOOLRECTA = 0x0406, WM_PSD_YAFULLPAGERECT = 0x0406, CBEM_GETEDITCONTROL = 0x0407, PBM_GETRANGE = 0x0407, RB_SETPARENT = 0x0407, SB_GETBORDERS = 0x0407, TBM_SETRANGEMIN = 0x0407, TTM_RELAYEVENT = 0x0407, CBEM_SETEXSTYLE = 0x0408, PBM_GETPOS = 0x0408, RB_HITTEST = 0x0408, SB_SETMINHEIGHT = 0x0408, TBM_SETRANGEMAX = 0x0408, TTM_GETTOOLINFOA = 0x0408, CBEM_GETEXSTYLE = 0x0409, CBEM_GETEXTENDEDSTYLE = 0x0409, PBM_SETBARCOLOR = 0x0409, RB_GETRECT = 0x0409, SB_SIMPLE = 0x0409, TB_ISBUTTONENABLED = 0x0409, TBM_CLEARTICS = 0x0409, TTM_SETTOOLINFOA = 0x0409, CBEM_HASEDITCHANGED = 0x040a, RB_INSERTBANDW = 0x040a, SB_GETRECT = 0x040a, TB_ISBUTTONCHECKED = 0x040a, TBM_SETSEL = 0x040a, TTM_HITTESTA = 0x040a, WIZ_QUERYNUMPAGES = 0x040a, CBEM_INSERTITEMW = 0x040b, RB_SETBANDINFOW = 0x040b, SB_SETTEXTW = 0x040b, TB_ISBUTTONPRESSED = 0x040b, TBM_SETSELSTART = 0x040b, TTM_GETTEXTA = 0x040b, WIZ_NEXT = 0x040b, CBEM_SETITEMW = 0x040c, RB_GETBANDCOUNT = 0x040c, SB_GETTEXTLENGTHW = 0x040c, TB_ISBUTTONHIDDEN = 0x040c, TBM_SETSELEND = 0x040c, TTM_UPDATETIPTEXTA = 0x040c, WIZ_PREV = 0x040c, CBEM_GETITEMW = 0x040d, RB_GETROWCOUNT = 0x040d, SB_GETTEXTW = 0x040d, TB_ISBUTTONINDETERMINATE = 0x040d, TTM_GETTOOLCOUNT = 0x040d, CBEM_SETEXTENDEDSTYLE = 0x040e, RB_GETROWHEIGHT = 0x040e, SB_ISSIMPLE = 0x040e, TB_ISBUTTONHIGHLIGHTED = 0x040e, TBM_GETPTICS = 0x040e, TTM_ENUMTOOLSA = 0x040e, SB_SETICON = 0x040f, TBM_GETTICPOS = 0x040f, TTM_GETCURRENTTOOLA = 0x040f, RB_IDTOINDEX = 0x0410, SB_SETTIPTEXTA = 0x0410, TBM_GETNUMTICS = 0x0410, TTM_WINDOWFROMPOINT = 0x0410, RB_GETTOOLTIPS = 0x0411, SB_SETTIPTEXTW = 0x0411, TBM_GETSELSTART = 0x0411, TB_SETSTATE = 0x0411, TTM_TRACKACTIVATE = 0x0411, RB_SETTOOLTIPS = 0x0412, SB_GETTIPTEXTA = 0x0412, TB_GETSTATE = 0x0412, TBM_GETSELEND = 0x0412, TTM_TRACKPOSITION = 0x0412, RB_SETBKCOLOR = 0x0413, SB_GETTIPTEXTW = 0x0413, TB_ADDBITMAP = 0x0413, TBM_CLEARSEL = 0x0413, TTM_SETTIPBKCOLOR = 0x0413, RB_GETBKCOLOR = 0x0414, SB_GETICON = 0x0414, TB_ADDBUTTONSA = 0x0414, TBM_SETTICFREQ = 0x0414, TTM_SETTIPTEXTCOLOR = 0x0414, RB_SETTEXTCOLOR = 0x0415, TB_INSERTBUTTONA = 0x0415, TBM_SETPAGESIZE = 0x0415, TTM_GETDELAYTIME = 0x0415, RB_GETTEXTCOLOR = 0x0416, TB_DELETEBUTTON = 0x0416, TBM_GETPAGESIZE = 0x0416, TTM_GETTIPBKCOLOR = 0x0416, RB_SIZETORECT = 0x0417, TB_GETBUTTON = 0x0417, TBM_SETLINESIZE = 0x0417, TTM_GETTIPTEXTCOLOR = 0x0417, RB_BEGINDRAG = 0x0418, TB_BUTTONCOUNT = 0x0418, TBM_GETLINESIZE = 0x0418, TTM_SETMAXTIPWIDTH = 0x0418, RB_ENDDRAG = 0x0419, TB_COMMANDTOINDEX = 0x0419, TBM_GETTHUMBRECT = 0x0419, TTM_GETMAXTIPWIDTH = 0x0419, RB_DRAGMOVE = 0x041a, TBM_GETCHANNELRECT = 0x041a, TB_SAVERESTOREA = 0x041a, TTM_SETMARGIN = 0x041a, RB_GETBARHEIGHT = 0x041b, TB_CUSTOMIZE = 0x041b, TBM_SETTHUMBLENGTH = 0x041b, TTM_GETMARGIN = 0x041b, RB_GETBANDINFOW = 0x041c, TB_ADDSTRINGA = 0x041c, TBM_GETTHUMBLENGTH = 0x041c, TTM_POP = 0x041c, RB_GETBANDINFOA = 0x041d, TB_GETITEMRECT = 0x041d, TBM_SETTOOLTIPS = 0x041d, TTM_UPDATE = 0x041d, RB_MINIMIZEBAND = 0x041e, TB_BUTTONSTRUCTSIZE = 0x041e, TBM_GETTOOLTIPS = 0x041e, TTM_GETBUBBLESIZE = 0x041e, RB_MAXIMIZEBAND = 0x041f, TBM_SETTIPSIDE = 0x041f, TB_SETBUTTONSIZE = 0x041f, TTM_ADJUSTRECT = 0x041f, TBM_SETBUDDY = 0x0420, TB_SETBITMAPSIZE = 0x0420, TTM_SETTITLEA = 0x0420, MSG_FTS_JUMP_VA = 0x0421, TB_AUTOSIZE = 0x0421, TBM_GETBUDDY = 0x0421, TTM_SETTITLEW = 0x0421, RB_GETBANDBORDERS = 0x0422, MSG_FTS_JUMP_QWORD = 0x0423, RB_SHOWBAND = 0x0423, TB_GETTOOLTIPS = 0x0423, MSG_REINDEX_REQUEST = 0x0424, TB_SETTOOLTIPS = 0x0424, MSG_FTS_WHERE_IS_IT = 0x0425, RB_SETPALETTE = 0x0425, TB_SETPARENT = 0x0425, RB_GETPALETTE = 0x0426, RB_MOVEBAND = 0x0427, TB_SETROWS = 0x0427, TB_GETROWS = 0x0428, TB_GETBITMAPFLAGS = 0x0429, TB_SETCMDID = 0x042a, RB_PUSHCHEVRON = 0x042b, TB_CHANGEBITMAP = 0x042b, TB_GETBITMAP = 0x042c, MSG_GET_DEFFONT = 0x042d, TB_GETBUTTONTEXTA = 0x042d, TB_REPLACEBITMAP = 0x042e, TB_SETINDENT = 0x042f, TB_SETIMAGELIST = 0x0430, TB_GETIMAGELIST = 0x0431, TB_LOADIMAGES = 0x0432, EM_CANPASTE = 0x0432, TTM_ADDTOOLW = 0x0432, EM_DISPLAYBAND = 0x0433, TB_GETRECT = 0x0433, TTM_DELTOOLW = 0x0433, EM_EXGETSEL = 0x0434, TB_SETHOTIMAGELIST = 0x0434, TTM_NEWTOOLRECTW = 0x0434, EM_EXLIMITTEXT = 0x0435, TB_GETHOTIMAGELIST = 0x0435, TTM_GETTOOLINFOW = 0x0435, EM_EXLINEFROMCHAR = 0x0436, TB_SETDISABLEDIMAGELIST = 0x0436, TTM_SETTOOLINFOW = 0x0436, EM_EXSETSEL = 0x0437, TB_GETDISABLEDIMAGELIST = 0x0437, TTM_HITTESTW = 0x0437, EM_FINDTEXT = 0x0438, TB_SETSTYLE = 0x0438, TTM_GETTEXTW = 0x0438, EM_FORMATRANGE = 0x0439, TB_GETSTYLE = 0x0439, TTM_UPDATETIPTEXTW = 0x0439, EM_GETCHARFORMAT = 0x043a, TB_GETBUTTONSIZE = 0x043a, TTM_ENUMTOOLSW = 0x043a, EM_GETEVENTMASK = 0x043b, TB_SETBUTTONWIDTH = 0x043b, TTM_GETCURRENTTOOLW = 0x043b, EM_GETOLEINTERFACE = 0x043c, TB_SETMAXTEXTROWS = 0x043c, EM_GETPARAFORMAT = 0x043d, TB_GETTEXTROWS = 0x043d, EM_GETSELTEXT = 0x043e, TB_GETOBJECT = 0x043e, EM_HIDESELECTION = 0x043f, TB_GETBUTTONINFOW = 0x043f, EM_PASTESPECIAL = 0x0440, TB_SETBUTTONINFOW = 0x0440, EM_REQUESTRESIZE = 0x0441, TB_GETBUTTONINFOA = 0x0441, EM_SELECTIONTYPE = 0x0442, TB_SETBUTTONINFOA = 0x0442, EM_SETBKGNDCOLOR = 0x0443, TB_INSERTBUTTONW = 0x0443, EM_SETCHARFORMAT = 0x0444, TB_ADDBUTTONSW = 0x0444, EM_SETEVENTMASK = 0x0445, TB_HITTEST = 0x0445, EM_SETOLECALLBACK = 0x0446, TB_SETDRAWTEXTFLAGS = 0x0446, EM_SETPARAFORMAT = 0x0447, TB_GETHOTITEM = 0x0447, EM_SETTARGETDEVICE = 0x0448, TB_SETHOTITEM = 0x0448, EM_STREAMIN = 0x0449, TB_SETANCHORHIGHLIGHT = 0x0449, EM_STREAMOUT = 0x044a, TB_GETANCHORHIGHLIGHT = 0x044a, EM_GETTEXTRANGE = 0x044b, TB_GETBUTTONTEXTW = 0x044b, EM_FINDWORDBREAK = 0x044c, TB_SAVERESTOREW = 0x044c, EM_SETOPTIONS = 0x044d, TB_ADDSTRINGW = 0x044d, EM_GETOPTIONS = 0x044e, TB_MAPACCELERATORA = 0x044e, EM_FINDTEXTEX = 0x044f, TB_GETINSERTMARK = 0x044f, EM_GETWORDBREAKPROCEX = 0x0450, TB_SETINSERTMARK = 0x0450, EM_SETWORDBREAKPROCEX = 0x0451, TB_INSERTMARKHITTEST = 0x0451, EM_SETUNDOLIMIT = 0x0452, TB_MOVEBUTTON = 0x0452, TB_GETMAXSIZE = 0x0453, EM_REDO = 0x0454, TB_SETEXTENDEDSTYLE = 0x0454, EM_CANREDO = 0x0455, TB_GETEXTENDEDSTYLE = 0x0455, EM_GETUNDONAME = 0x0456, TB_GETPADDING = 0x0456, EM_GETREDONAME = 0x0457, TB_SETPADDING = 0x0457, EM_STOPGROUPTYPING = 0x0458, TB_SETINSERTMARKCOLOR = 0x0458, EM_SETTEXTMODE = 0x0459, TB_GETINSERTMARKCOLOR = 0x0459, EM_GETTEXTMODE = 0x045a, TB_MAPACCELERATORW = 0x045a, EM_AUTOURLDETECT = 0x045b, TB_GETSTRINGW = 0x045b, EM_GETAUTOURLDETECT = 0x045c, TB_GETSTRINGA = 0x045c, EM_SETPALETTE = 0x045d, EM_GETTEXTEX = 0x045e, EM_GETTEXTLENGTHEX = 0x045f, EM_SHOWSCROLLBAR = 0x0460, EM_SETTEXTEX = 0x0461, TAPI_REPLY = 0x0463, ACM_OPENA = 0x0464, BFFM_SETSTATUSTEXTA = 0x0464, CDM_FIRST = 0x0464, CDM_GETSPEC = 0x0464, EM_SETPUNCTUATION = 0x0464, IPM_CLEARADDRESS = 0x0464, WM_CAP_UNICODE_START = 0x0464, ACM_PLAY = 0x0465, BFFM_ENABLEOK = 0x0465, CDM_GETFILEPATH = 0x0465, EM_GETPUNCTUATION = 0x0465, IPM_SETADDRESS = 0x0465, PSM_SETCURSEL = 0x0465, UDM_SETRANGE = 0x0465, WM_CHOOSEFONT_SETLOGFONT = 0x0465, ACM_STOP = 0x0466, BFFM_SETSELECTIONA = 0x0466, CDM_GETFOLDERPATH = 0x0466, EM_SETWORDWRAPMODE = 0x0466, IPM_GETADDRESS = 0x0466, PSM_REMOVEPAGE = 0x0466, UDM_GETRANGE = 0x0466, WM_CAP_SET_CALLBACK_ERRORW = 0x0466, WM_CHOOSEFONT_SETFLAGS = 0x0466, ACM_OPENW = 0x0467, BFFM_SETSELECTIONW = 0x0467, CDM_GETFOLDERIDLIST = 0x0467, EM_GETWORDWRAPMODE = 0x0467, IPM_SETRANGE = 0x0467, PSM_ADDPAGE = 0x0467, UDM_SETPOS = 0x0467, WM_CAP_SET_CALLBACK_STATUSW = 0x0467, BFFM_SETSTATUSTEXTW = 0x0468, CDM_SETCONTROLTEXT = 0x0468, EM_SETIMECOLOR = 0x0468, IPM_SETFOCUS = 0x0468, PSM_CHANGED = 0x0468, UDM_GETPOS = 0x0468, CDM_HIDECONTROL = 0x0469, EM_GETIMECOLOR = 0x0469, IPM_ISBLANK = 0x0469, PSM_RESTARTWINDOWS = 0x0469, UDM_SETBUDDY = 0x0469, CDM_SETDEFEXT = 0x046a, EM_SETIMEOPTIONS = 0x046a, PSM_REBOOTSYSTEM = 0x046a, UDM_GETBUDDY = 0x046a, EM_GETIMEOPTIONS = 0x046b, PSM_CANCELTOCLOSE = 0x046b, UDM_SETACCEL = 0x046b, EM_CONVPOSITION = 0x046c, EM_CONVPOSITION = 0x046c, PSM_QUERYSIBLINGS = 0x046c, UDM_GETACCEL = 0x046c, MCIWNDM_GETZOOM = 0x046d, PSM_UNCHANGED = 0x046d, UDM_SETBASE = 0x046d, PSM_APPLY = 0x046e, UDM_GETBASE = 0x046e, PSM_SETTITLEA = 0x046f, UDM_SETRANGE32 = 0x046f, PSM_SETWIZBUTTONS = 0x0470, UDM_GETRANGE32 = 0x0470, WM_CAP_DRIVER_GET_NAMEW = 0x0470, PSM_PRESSBUTTON = 0x0471, UDM_SETPOS32 = 0x0471, WM_CAP_DRIVER_GET_VERSIONW = 0x0471, PSM_SETCURSELID = 0x0472, UDM_GETPOS32 = 0x0472, PSM_SETFINISHTEXTA = 0x0473, PSM_GETTABCONTROL = 0x0474, PSM_ISDIALOGMESSAGE = 0x0475, MCIWNDM_REALIZE = 0x0476, PSM_GETCURRENTPAGEHWND = 0x0476, MCIWNDM_SETTIMEFORMATA = 0x0477, PSM_INSERTPAGE = 0x0477, EM_SETLANGOPTIONS = 0x0478, MCIWNDM_GETTIMEFORMATA = 0x0478, PSM_SETTITLEW = 0x0478, WM_CAP_FILE_SET_CAPTURE_FILEW = 0x0478, EM_GETLANGOPTIONS = 0x0479, MCIWNDM_VALIDATEMEDIA = 0x0479, PSM_SETFINISHTEXTW = 0x0479, WM_CAP_FILE_GET_CAPTURE_FILEW = 0x0479, EM_GETIMECOMPMODE = 0x047a, EM_FINDTEXTW = 0x047b, MCIWNDM_PLAYTO = 0x047b, WM_CAP_FILE_SAVEASW = 0x047b, EM_FINDTEXTEXW = 0x047c, MCIWNDM_GETFILENAMEA = 0x047c, EM_RECONVERSION = 0x047d, MCIWNDM_GETDEVICEA = 0x047d, PSM_SETHEADERTITLEA = 0x047d, WM_CAP_FILE_SAVEDIBW = 0x047d, EM_SETIMEMODEBIAS = 0x047e, MCIWNDM_GETPALETTE = 0x047e, PSM_SETHEADERTITLEW = 0x047e, EM_GETIMEMODEBIAS = 0x047f, MCIWNDM_SETPALETTE = 0x047f, PSM_SETHEADERSUBTITLEA = 0x047f, MCIWNDM_GETERRORA = 0x0480, PSM_SETHEADERSUBTITLEW = 0x0480, PSM_HWNDTOINDEX = 0x0481, PSM_INDEXTOHWND = 0x0482, MCIWNDM_SETINACTIVETIMER = 0x0483, PSM_PAGETOINDEX = 0x0483, PSM_INDEXTOPAGE = 0x0484, DL_BEGINDRAG = 0x0485, MCIWNDM_GETINACTIVETIMER = 0x0485, PSM_IDTOINDEX = 0x0485, DL_DRAGGING = 0x0486, PSM_INDEXTOID = 0x0486, DL_DROPPED = 0x0487, PSM_GETRESULT = 0x0487, DL_CANCELDRAG = 0x0488, PSM_RECALCPAGESIZES = 0x0488, MCIWNDM_GET_SOURCE = 0x048c, MCIWNDM_PUT_SOURCE = 0x048d, MCIWNDM_GET_DEST = 0x048e, MCIWNDM_PUT_DEST = 0x048f, MCIWNDM_CAN_PLAY = 0x0490, MCIWNDM_CAN_WINDOW = 0x0491, MCIWNDM_CAN_RECORD = 0x0492, MCIWNDM_CAN_SAVE = 0x0493, MCIWNDM_CAN_EJECT = 0x0494, MCIWNDM_CAN_CONFIG = 0x0495, IE_GETINK = 0x0496, IE_MSGFIRST = 0x0496, MCIWNDM_PALETTEKICK = 0x0496, IE_SETINK = 0x0497, IE_GETPENTIP = 0x0498, IE_SETPENTIP = 0x0499, IE_GETERASERTIP = 0x049a, IE_SETERASERTIP = 0x049b, IE_GETBKGND = 0x049c, IE_SETBKGND = 0x049d, IE_GETGRIDORIGIN = 0x049e, IE_SETGRIDORIGIN = 0x049f, IE_GETGRIDPEN = 0x04a0, IE_SETGRIDPEN = 0x04a1, IE_GETGRIDSIZE = 0x04a2, IE_SETGRIDSIZE = 0x04a3, IE_GETMODE = 0x04a4, IE_SETMODE = 0x04a5, IE_GETINKRECT = 0x04a6, WM_CAP_SET_MCI_DEVICEW = 0x04a6, WM_CAP_GET_MCI_DEVICEW = 0x04a7, WM_CAP_PAL_OPENW = 0x04b4, WM_CAP_PAL_SAVEW = 0x04b5, IE_GETAPPDATA = 0x04b8, IE_SETAPPDATA = 0x04b9, IE_GETDRAWOPTS = 0x04ba, IE_SETDRAWOPTS = 0x04bb, IE_GETFORMAT = 0x04bc, IE_SETFORMAT = 0x04bd, IE_GETINKINPUT = 0x04be, IE_SETINKINPUT = 0x04bf, IE_GETNOTIFY = 0x04c0, IE_SETNOTIFY = 0x04c1, IE_GETRECOG = 0x04c2, IE_SETRECOG = 0x04c3, IE_GETSECURITY = 0x04c4, IE_SETSECURITY = 0x04c5, IE_GETSEL = 0x04c6, IE_SETSEL = 0x04c7, CDM_LAST = 0x04c8, EM_SETBIDIOPTIONS = 0x04c8, IE_DOCOMMAND = 0x04c8, MCIWNDM_NOTIFYMODE = 0x04c8, EM_GETBIDIOPTIONS = 0x04c9, IE_GETCOMMAND = 0x04c9, EM_SETTYPOGRAPHYOPTIONS = 0x04ca, IE_GETCOUNT = 0x04ca, EM_GETTYPOGRAPHYOPTIONS = 0x04cb, IE_GETGESTURE = 0x04cb, MCIWNDM_NOTIFYMEDIA = 0x04cb, EM_SETEDITSTYLE = 0x04cc, IE_GETMENU = 0x04cc, EM_GETEDITSTYLE = 0x04cd, IE_GETPAINTDC = 0x04cd, MCIWNDM_NOTIFYERROR = 0x04cd, IE_GETPDEVENT = 0x04ce, IE_GETSELCOUNT = 0x04cf, IE_GETSELITEMS = 0x04d0, IE_GETSTYLE = 0x04d1, MCIWNDM_SETTIMEFORMATW = 0x04db, EM_OUTLINE = 0x04dc, EM_OUTLINE = 0x04dc, MCIWNDM_GETTIMEFORMATW = 0x04dc, EM_GETSCROLLPOS = 0x04dd, EM_GETSCROLLPOS = 0x04dd, EM_SETSCROLLPOS = 0x04de, EM_SETSCROLLPOS = 0x04de, EM_SETFONTSIZE = 0x04df, EM_SETFONTSIZE = 0x04df, EM_GETZOOM = 0x04e0, MCIWNDM_GETFILENAMEW = 0x04e0, EM_SETZOOM = 0x04e1, MCIWNDM_GETDEVICEW = 0x04e1, EM_GETVIEWKIND = 0x04e2, EM_SETVIEWKIND = 0x04e3, EM_GETPAGE = 0x04e4, MCIWNDM_GETERRORW = 0x04e4, EM_SETPAGE = 0x04e5, EM_GETHYPHENATEINFO = 0x04e6, EM_SETHYPHENATEINFO = 0x04e7, EM_GETPAGEROTATE = 0x04eb, EM_SETPAGEROTATE = 0x04ec, EM_GETCTFMODEBIAS = 0x04ed, EM_SETCTFMODEBIAS = 0x04ee, EM_GETCTFOPENSTATUS = 0x04f0, EM_SETCTFOPENSTATUS = 0x04f1, EM_GETIMECOMPTEXT = 0x04f2, EM_ISIME = 0x04f3, EM_GETIMEPROPERTY = 0x04f4, EM_GETQUERYRTFOBJ = 0x050d, EM_SETQUERYRTFOBJ = 0x050e, FM_GETFOCUS = 0x0600, FM_GETDRIVEINFOA = 0x0601, FM_GETSELCOUNT = 0x0602, FM_GETSELCOUNTLFN = 0x0603, FM_GETFILESELA = 0x0604, FM_GETFILESELLFNA = 0x0605, FM_REFRESH_WINDOWS = 0x0606, FM_RELOAD_EXTENSIONS = 0x0607, FM_GETDRIVEINFOW = 0x0611, FM_GETFILESELW = 0x0614, FM_GETFILESELLFNW = 0x0615, WLX_WM_SAS = 0x0659, SM_GETSELCOUNT = 0x07e8, UM_GETSELCOUNT = 0x07e8, WM_CPL_LAUNCH = 0x07e8, SM_GETSERVERSELA = 0x07e9, UM_GETUSERSELA = 0x07e9, WM_CPL_LAUNCHED = 0x07e9, SM_GETSERVERSELW = 0x07ea, UM_GETUSERSELW = 0x07ea, SM_GETCURFOCUSA = 0x07eb, UM_GETGROUPSELA = 0x07eb, SM_GETCURFOCUSW = 0x07ec, UM_GETGROUPSELW = 0x07ec, SM_GETOPTIONS = 0x07ed, UM_GETCURFOCUSA = 0x07ed, UM_GETCURFOCUSW = 0x07ee, UM_GETOPTIONS = 0x07ef, UM_GETOPTIONS2 = 0x07f0, LVM_FIRST = 0x1000, LVM_GETBKCOLOR = 0x1000, LVM_SETBKCOLOR = 0x1001, LVM_GETIMAGELIST = 0x1002, LVM_SETIMAGELIST = 0x1003, LVM_GETITEMCOUNT = 0x1004, LVM_GETITEMA = 0x1005, LVM_SETITEMA = 0x1006, LVM_INSERTITEMA = 0x1007, LVM_DELETEITEM = 0x1008, LVM_DELETEALLITEMS = 0x1009, LVM_GETCALLBACKMASK = 0x100a, LVM_SETCALLBACKMASK = 0x100b, LVM_GETNEXTITEM = 0x100c, LVM_FINDITEMA = 0x100d, LVM_GETITEMRECT = 0x100e, LVM_SETITEMPOSITION = 0x100f, LVM_GETITEMPOSITION = 0x1010, LVM_GETSTRINGWIDTHA = 0x1011, LVM_HITTEST = 0x1012, LVM_ENSUREVISIBLE = 0x1013, LVM_SCROLL = 0x1014, LVM_REDRAWITEMS = 0x1015, LVM_ARRANGE = 0x1016, LVM_EDITLABELA = 0x1017, LVM_GETEDITCONTROL = 0x1018, LVM_GETCOLUMNA = 0x1019, LVM_SETCOLUMNA = 0x101a, LVM_INSERTCOLUMNA = 0x101b, LVM_DELETECOLUMN = 0x101c, LVM_GETCOLUMNWIDTH = 0x101d, LVM_SETCOLUMNWIDTH = 0x101e, LVM_GETHEADER = 0x101f, LVM_CREATEDRAGIMAGE = 0x1021, LVM_GETVIEWRECT = 0x1022, LVM_GETTEXTCOLOR = 0x1023, LVM_SETTEXTCOLOR = 0x1024, LVM_GETTEXTBKCOLOR = 0x1025, LVM_SETTEXTBKCOLOR = 0x1026, LVM_GETTOPINDEX = 0x1027, LVM_GETCOUNTPERPAGE = 0x1028, LVM_GETORIGIN = 0x1029, LVM_UPDATE = 0x102a, LVM_SETITEMSTATE = 0x102b, LVM_GETITEMSTATE = 0x102c, LVM_GETITEMTEXTA = 0x102d, LVM_SETITEMTEXTA = 0x102e, LVM_SETITEMCOUNT = 0x102f, LVM_SORTITEMS = 0x1030, LVM_SETITEMPOSITION32 = 0x1031, LVM_GETSELECTEDCOUNT = 0x1032, LVM_GETITEMSPACING = 0x1033, LVM_GETISEARCHSTRINGA = 0x1034, LVM_SETICONSPACING = 0x1035, LVM_SETEXTENDEDLISTVIEWSTYLE = 0x1036, LVM_GETEXTENDEDLISTVIEWSTYLE = 0x1037, LVM_GETSUBITEMRECT = 0x1038, LVM_SUBITEMHITTEST = 0x1039, LVM_SETCOLUMNORDERARRAY = 0x103a, LVM_GETCOLUMNORDERARRAY = 0x103b, LVM_SETHOTITEM = 0x103c, LVM_GETHOTITEM = 0x103d, LVM_SETHOTCURSOR = 0x103e, LVM_GETHOTCURSOR = 0x103f, LVM_APPROXIMATEVIEWRECT = 0x1040, LVM_SETWORKAREAS = 0x1041, LVM_GETSELECTIONMARK = 0x1042, LVM_SETSELECTIONMARK = 0x1043, LVM_SETBKIMAGEA = 0x1044, LVM_GETBKIMAGEA = 0x1045, LVM_GETWORKAREAS = 0x1046, LVM_SETHOVERTIME = 0x1047, LVM_GETHOVERTIME = 0x1048, LVM_GETNUMBEROFWORKAREAS = 0x1049, LVM_SETTOOLTIPS = 0x104a, LVM_GETITEMW = 0x104b, LVM_SETITEMW = 0x104c, LVM_INSERTITEMW = 0x104d, LVM_GETTOOLTIPS = 0x104e, LVM_FINDITEMW = 0x1053, LVM_GETSTRINGWIDTHW = 0x1057, LVM_GETCOLUMNW = 0x105f, LVM_SETCOLUMNW = 0x1060, LVM_INSERTCOLUMNW = 0x1061, LVM_GETITEMTEXTW = 0x1073, LVM_SETITEMTEXTW = 0x1074, LVM_GETISEARCHSTRINGW = 0x1075, LVM_EDITLABELW = 0x1076, LVM_GETBKIMAGEW = 0x108b, LVM_SETSELECTEDCOLUMN = 0x108c, LVM_SETTILEWIDTH = 0x108d, LVM_SETVIEW = 0x108e, LVM_GETVIEW = 0x108f, LVM_INSERTGROUP = 0x1091, LVM_SETGROUPINFO = 0x1093, LVM_GETGROUPINFO = 0x1095, LVM_REMOVEGROUP = 0x1096, LVM_MOVEGROUP = 0x1097, LVM_MOVEITEMTOGROUP = 0x109a, LVM_SETGROUPMETRICS = 0x109b, LVM_GETGROUPMETRICS = 0x109c, LVM_ENABLEGROUPVIEW = 0x109d, LVM_SORTGROUPS = 0x109e, LVM_INSERTGROUPSORTED = 0x109f, LVM_REMOVEALLGROUPS = 0x10a0, LVM_HASGROUP = 0x10a1, LVM_SETTILEVIEWINFO = 0x10a2, LVM_GETTILEVIEWINFO = 0x10a3, LVM_SETTILEINFO = 0x10a4, LVM_GETTILEINFO = 0x10a5, LVM_SETINSERTMARK = 0x10a6, LVM_GETINSERTMARK = 0x10a7, LVM_INSERTMARKHITTEST = 0x10a8, LVM_GETINSERTMARKRECT = 0x10a9, LVM_SETINSERTMARKCOLOR = 0x10aa, LVM_GETINSERTMARKCOLOR = 0x10ab, LVM_SETINFOTIP = 0x10ad, LVM_GETSELECTEDCOLUMN = 0x10ae, LVM_ISGROUPVIEWENABLED = 0x10af, LVM_GETOUTLINECOLOR = 0x10b0, LVM_SETOUTLINECOLOR = 0x10b1, LVM_CANCELEDITLABEL = 0x10b3, LVM_MAPINDEXTOID = 0x10b4, LVM_MAPIDTOINDEX = 0x10b5, LVM_ISITEMVISIBLE = 0x10b6, OCM__BASE = 0x2000, LVM_SETUNICODEFORMAT = 0x2005, LVM_GETUNICODEFORMAT = 0x2006, OCM_CTLCOLOR = 0x2019, OCM_DRAWITEM = 0x202b, OCM_MEASUREITEM = 0x202c, OCM_DELETEITEM = 0x202d, OCM_VKEYTOITEM = 0x202e, OCM_CHARTOITEM = 0x202f, OCM_COMPAREITEM = 0x2039, OCM_NOTIFY = 0x204e, OCM_COMMAND = 0x2111, OCM_HSCROLL = 0x2114, OCM_VSCROLL = 0x2115, OCM_CTLCOLORMSGBOX = 0x2132, OCM_CTLCOLOREDIT = 0x2133, OCM_CTLCOLORLISTBOX = 0x2134, OCM_CTLCOLORBTN = 0x2135, OCM_CTLCOLORDLG = 0x2136, OCM_CTLCOLORSCROLLBAR = 0x2137, OCM_CTLCOLORSTATIC = 0x2138, OCM_PARENTNOTIFY = 0x2210, WM_APP = 0x8000, WM_RASDIALEVENT = 0xcccd,
    }

    return messages
  end

  function r_lib_imcustom_hotkey()
    local vkeys = r_lib_vkeys()
    local rkeys = r_lib_rkeys()
    local wm = r_lib_window_message()

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

  function r_lib_encoding()
    local iconv = require 'iconv'

    local encoding = {
      default = 'ASCII'
    }

    local aliases = {
      UTF7 = 'UTF-7',
      UTF8 = 'UTF-8',
      UTF16 = 'UTF-16',
      UTF32 = 'UTF-32'
    }

    local function normalize_encoding_name(e)
      e = string.upper(string.gsub(e, '_', '-'))
      if aliases[e] then return aliases[e] end
      return e
    end

    local converter = {}
    function converter.new(enc)
      local private = {
        encoder = {},
        decoder = {},
      }

      local public = {
        encoding = enc
      }
      function public:encode(str, enc)
        if enc then enc = normalize_encoding_name(enc)
        else enc = encoding.default
        end
        local cd = private.encoder[enc]
        if not cd then
          cd = iconv.new(self.encoding .. '//IGNORE', enc)
          assert(cd)
          private.encoder[enc] = cd
        end
        local encoded = cd:iconv(str)
        return encoded
      end

      function public:decode(str, enc)
        if enc then enc = normalize_encoding_name(enc)
        else enc = encoding.default
        end
        local cd = private.decoder[enc]
        if not cd then
          cd = iconv.new(enc .. '//IGNORE', self.encoding)
          assert(cd)
          private.decoder[enc] = cd
        end
        local decoded = cd:iconv(str)
        return decoded
      end

      local mt = {}
      function mt:__call(str, enc)
        return self:encode(str, enc)
      end

      setmetatable(public, mt)
      return public
    end

    setmetatable(encoding, {
      __index =
      function(table, index)
        assert(type(index) == 'string')
        local enc = normalize_encoding_name(index)
        local already_loaded = rawget(table, enc)
        if already_loaded then
          table[index] = already_loaded
          return already_loaded
        else
          -- create new converter
          local conv = converter.new(enc)
          table[index] = conv
          table[enc] = conv
          return conv
        end
      end
    })

    return encoding
  end

  function r_lib_lockbox()
    local Lockbox = {};

    --[[
		package.path =  "./?.lua;"
						.. "./cipher/?.lua;"
						.. "./digest/?.lua;"
						.. "./kdf/?.lua;"
						.. "./mac/?.lua;"
						.. "./padding/?.lua;"
						.. "./test/?.lua;"
						.. "./util/?.lua;"
						.. package.path;
		]]--
    Lockbox.ALLOW_INSECURE = false;

    Lockbox.insecure = function()
      assert(Lockbox.ALLOW_INSECURE, "");
    end

    return Lockbox;
  end

  function r_lockbox_util_queue()
    local Queue = function()
      local queue = {};
      local tail = 0;
      local head = 0;

      local public = {};

      public.push = function(obj)
        queue[head] = obj;
        head = head + 1;
        return;
      end

      public.pop = function()
        if tail < head
        then
          local obj = queue[tail];
          queue[tail] = nil;
          tail = tail + 1;
          return obj;
        else
          return nil;
        end
      end

      public.size = function()
        return head - tail;
      end

      public.getHead = function()
        return head;
      end

      public.getTail = function()
        return tail;
      end

      public.reset = function()
        queue = {};
        head = 0;
        tail = 0;
      end

      return public;
    end

    return Queue;
  end

  function r_lockbox_util_stream()
    local Queue = r_lockbox_util_queue()

    local Stream = {};


    Stream.fromString = function(string)
      local i = 0;
      return function()
        i = i + 1;
        if(i <= string.len(string)) then
          return string.byte(string, i);
        else
          return nil;
        end
      end
    end


    Stream.toString = function(stream)
      local array = {};
      local i = 1;

      local byte = stream();
      while byte ~= nil do
        array[i] = string.char(byte);
        i = i + 1;
        byte = stream();
      end

      return table.concat(array, "");
    end


    Stream.fromArray = function(array)
      local queue = Queue();
      local i = 1;

      local byte = array[i];
      while byte ~= nil do
        queue.push(byte);
        i = i + 1;
        byte = array[i];
      end

      return queue.pop;
    end


    Stream.toArray = function(stream)
      local array = {};
      local i = 1;

      local byte = stream();
      while byte ~= nil do
        array[i] = byte;
        i = i + 1;
        byte = stream();
      end

      return array;
    end


    local fromHexTable = {};
    for i = 0, 255 do
      fromHexTable[string.format("%02X", i)] = i;
      fromHexTable[string.format("%02x", i)] = i;
    end

    Stream.fromHex = function(hex)
      local queue = Queue();

      for i = 1, string.len(hex) / 2 do
        local h = string.sub(hex, i * 2 - 1, i * 2);
        queue.push(fromHexTable[h]);
      end

      return queue.pop;
    end



    local toHexTable = {};
    for i = 0, 255 do
      toHexTable[i] = string.format("%02X", i);
    end

    Stream.toHex = function(stream)
      local hex = {};
      local i = 1;

      local byte = stream();
      while byte ~= nil do
        hex[i] = toHexTable[byte];
        i = i + 1;
        byte = stream();
      end

      return table.concat(hex, "");
    end

    return Stream;
  end

  function r_lib_lockbox_util_bit()
    local ok, e
    if not ok then
      ok, e = pcall(require, "bit") -- the LuaJIT one ?
    end
    if not ok then
      ok, e = pcall(require, "bit32") -- Lua 5.2
    end
    if not ok then
      ok, e = pcall(require, "bit.numberlua") -- for Lua 5.1, https://github.com/tst2005/lua-bit-numberlua/
    end
    if not ok then
      error("no bitwise support found", 2)
    end
    assert(type(e) == "table", "invalid bit module")

    -- Workaround to support Lua 5.2 bit32 API with the LuaJIT bit one
    if e.rol and not e.lrotate then
      e.lrotate = e.rol
    end
    if e.ror and not e.rrotate then
      e.rrotate = e.ror
    end

    return e
  end

  function r_lib_lockbox_util_array()
    local Bit = r_lib_lockbox_util_bit()
    local XOR = Bit.bxor;

    local Array = {};

    Array.size = function(array)
      return #array;
    end

    Array.fromString = function(string)
      local bytes = {};

      local i = 1;
      local byte = string.byte(string, i);
      while byte ~= nil do
        bytes[i] = byte;
        i = i + 1;
        byte = string.byte(string, i);
      end

      return bytes;

    end

    Array.toString = function(bytes)
      local chars = {};
      local i = 1;

      local byte = bytes[i];
      while byte ~= nil do
        chars[i] = string.char(byte);
        i = i + 1;
        byte = bytes[i];
      end

      return table.concat(chars, "");
    end

    Array.fromStream = function(stream)
      local array = {};
      local i = 1;

      local byte = stream();
      while byte ~= nil do
        array[i] = byte;
        i = i + 1;
        byte = stream();
      end

      return array;
    end

    Array.readFromQueue = function(queue, size)
      local array = {};

      for i = 1, size do
        array[i] = queue.pop();
      end

      return array;
    end

    Array.writeToQueue = function(queue, array)
      local size = Array.size(array);

      for i = 1, size do
        queue.push(array[i]);
      end
    end

    Array.toStream = function(array)
      local queue = Queue();
      local i = 1;

      local byte = array[i];
      while byte ~= nil do
        queue.push(byte);
        i = i + 1;
        byte = array[i];
      end

      return queue.pop;
    end


    local fromHexTable = {};
    for i = 0, 255 do
      fromHexTable[string.format("%02X", i)] = i;
      fromHexTable[string.format("%02x", i)] = i;
    end

    Array.fromHex = function(hex)
      local array = {};

      for i = 1, string.len(hex) / 2 do
        local h = string.sub(hex, i * 2 - 1, i * 2);
        array[i] = fromHexTable[h];
      end

      return array;
    end


    local toHexTable = {};
    for i = 0, 255 do
      toHexTable[i] = string.format("%02X", i);
    end

    Array.toHex = function(array)
      local hex = {};
      local i = 1;

      local byte = array[i];
      while byte ~= nil do
        hex[i] = toHexTable[byte];
        i = i + 1;
        byte = array[i];
      end

      return table.concat(hex, "");

    end

    Array.concat = function(a, b)
      local concat = {};
      local out = 1;

      local i = 1;
      local byte = a[i];
      while byte ~= nil do
        concat[out] = byte;
        i = i + 1;
        out = out + 1;
        byte = a[i];
      end

      local i = 1;
      local byte = b[i];
      while byte ~= nil do
        concat[out] = byte;
        i = i + 1;
        out = out + 1;
        byte = b[i];
      end

      return concat;
    end

    Array.truncate = function(a, newSize)
      local x = {};

      for i = 1, newSize do
        x[i] = a[i];
      end

      return x;
    end

    Array.XOR = function(a, b)
      local x = {};

      for k, v in pairs(a) do
        x[k] = XOR(v, b[k]);
      end

      return x;
    end

    Array.substitute = function(input, sbox)
      local out = {};

      for k, v in pairs(input) do
        out[k] = sbox[v];
      end

      return out;
    end

    Array.permute = function(input, pbox)
      local out = {};

      for k, v in pairs(pbox) do
        out[k] = input[v];
      end

      return out;
    end

    Array.copy = function(input)
      local out = {};

      for k, v in pairs(input) do
        out[k] = v;
      end
      return out;
    end

    Array.slice = function(input, start, stop)
      local out = {};

      for i = start, stop do
        out[i - start + 1] = input[i];
      end
      return out;
    end

    return Array;
  end

  function r_lib_lockbox_cipher_aes128()
    local Stream = r_lockbox_util_stream()
    local Array = r_lib_lockbox_util_array()
    local Bit = r_lib_lockbox_util_bit()
    local Math = require("math");


    local AND = Bit.band;
    local OR = Bit.bor;
    local NOT = Bit.bnot;
    local XOR = Bit.bxor;
    local LROT = Bit.lrotate;
    local RROT = Bit.rrotate;
    local LSHIFT = Bit.lshift;
    local RSHIFT = Bit.rshift;

    local SBOX = {
      [0] = 0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
      0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
      0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
      0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
      0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
      0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
      0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
      0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
      0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
      0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
      0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
      0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
      0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
      0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
      0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
    0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16};

    local ISBOX = {
      [0] = 0x52, 0x09, 0x6A, 0xD5, 0x30, 0x36, 0xA5, 0x38, 0xBF, 0x40, 0xA3, 0x9E, 0x81, 0xF3, 0xD7, 0xFB,
      0x7C, 0xE3, 0x39, 0x82, 0x9B, 0x2F, 0xFF, 0x87, 0x34, 0x8E, 0x43, 0x44, 0xC4, 0xDE, 0xE9, 0xCB,
      0x54, 0x7B, 0x94, 0x32, 0xA6, 0xC2, 0x23, 0x3D, 0xEE, 0x4C, 0x95, 0x0B, 0x42, 0xFA, 0xC3, 0x4E,
      0x08, 0x2E, 0xA1, 0x66, 0x28, 0xD9, 0x24, 0xB2, 0x76, 0x5B, 0xA2, 0x49, 0x6D, 0x8B, 0xD1, 0x25,
      0x72, 0xF8, 0xF6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xD4, 0xA4, 0x5C, 0xCC, 0x5D, 0x65, 0xB6, 0x92,
      0x6C, 0x70, 0x48, 0x50, 0xFD, 0xED, 0xB9, 0xDA, 0x5E, 0x15, 0x46, 0x57, 0xA7, 0x8D, 0x9D, 0x84,
      0x90, 0xD8, 0xAB, 0x00, 0x8C, 0xBC, 0xD3, 0x0A, 0xF7, 0xE4, 0x58, 0x05, 0xB8, 0xB3, 0x45, 0x06,
      0xD0, 0x2C, 0x1E, 0x8F, 0xCA, 0x3F, 0x0F, 0x02, 0xC1, 0xAF, 0xBD, 0x03, 0x01, 0x13, 0x8A, 0x6B,
      0x3A, 0x91, 0x11, 0x41, 0x4F, 0x67, 0xDC, 0xEA, 0x97, 0xF2, 0xCF, 0xCE, 0xF0, 0xB4, 0xE6, 0x73,
      0x96, 0xAC, 0x74, 0x22, 0xE7, 0xAD, 0x35, 0x85, 0xE2, 0xF9, 0x37, 0xE8, 0x1C, 0x75, 0xDF, 0x6E,
      0x47, 0xF1, 0x1A, 0x71, 0x1D, 0x29, 0xC5, 0x89, 0x6F, 0xB7, 0x62, 0x0E, 0xAA, 0x18, 0xBE, 0x1B,
      0xFC, 0x56, 0x3E, 0x4B, 0xC6, 0xD2, 0x79, 0x20, 0x9A, 0xDB, 0xC0, 0xFE, 0x78, 0xCD, 0x5A, 0xF4,
      0x1F, 0xDD, 0xA8, 0x33, 0x88, 0x07, 0xC7, 0x31, 0xB1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xEC, 0x5F,
      0x60, 0x51, 0x7F, 0xA9, 0x19, 0xB5, 0x4A, 0x0D, 0x2D, 0xE5, 0x7A, 0x9F, 0x93, 0xC9, 0x9C, 0xEF,
      0xA0, 0xE0, 0x3B, 0x4D, 0xAE, 0x2A, 0xF5, 0xB0, 0xC8, 0xEB, 0xBB, 0x3C, 0x83, 0x53, 0x99, 0x61,
    0x17, 0x2B, 0x04, 0x7E, 0xBA, 0x77, 0xD6, 0x26, 0xE1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0C, 0x7D};

    local ROW_SHIFT = { 1, 6, 11, 16, 5, 10, 15, 4, 9, 14, 3, 8, 13, 2, 7, 12, };
    local IROW_SHIFT = { 1, 14, 11, 8, 5, 2, 15, 12, 9, 6, 3, 16, 13, 10, 7, 4, };

    local ETABLE = {
      [0] = 0x01, 0x03, 0x05, 0x0F, 0x11, 0x33, 0x55, 0xFF, 0x1A, 0x2E, 0x72, 0x96, 0xA1, 0xF8, 0x13, 0x35,
      0x5F, 0xE1, 0x38, 0x48, 0xD8, 0x73, 0x95, 0xA4, 0xF7, 0x02, 0x06, 0x0A, 0x1E, 0x22, 0x66, 0xAA,
      0xE5, 0x34, 0x5C, 0xE4, 0x37, 0x59, 0xEB, 0x26, 0x6A, 0xBE, 0xD9, 0x70, 0x90, 0xAB, 0xE6, 0x31,
      0x53, 0xF5, 0x04, 0x0C, 0x14, 0x3C, 0x44, 0xCC, 0x4F, 0xD1, 0x68, 0xB8, 0xD3, 0x6E, 0xB2, 0xCD,
      0x4C, 0xD4, 0x67, 0xA9, 0xE0, 0x3B, 0x4D, 0xD7, 0x62, 0xA6, 0xF1, 0x08, 0x18, 0x28, 0x78, 0x88,
      0x83, 0x9E, 0xB9, 0xD0, 0x6B, 0xBD, 0xDC, 0x7F, 0x81, 0x98, 0xB3, 0xCE, 0x49, 0xDB, 0x76, 0x9A,
      0xB5, 0xC4, 0x57, 0xF9, 0x10, 0x30, 0x50, 0xF0, 0x0B, 0x1D, 0x27, 0x69, 0xBB, 0xD6, 0x61, 0xA3,
      0xFE, 0x19, 0x2B, 0x7D, 0x87, 0x92, 0xAD, 0xEC, 0x2F, 0x71, 0x93, 0xAE, 0xE9, 0x20, 0x60, 0xA0,
      0xFB, 0x16, 0x3A, 0x4E, 0xD2, 0x6D, 0xB7, 0xC2, 0x5D, 0xE7, 0x32, 0x56, 0xFA, 0x15, 0x3F, 0x41,
      0xC3, 0x5E, 0xE2, 0x3D, 0x47, 0xC9, 0x40, 0xC0, 0x5B, 0xED, 0x2C, 0x74, 0x9C, 0xBF, 0xDA, 0x75,
      0x9F, 0xBA, 0xD5, 0x64, 0xAC, 0xEF, 0x2A, 0x7E, 0x82, 0x9D, 0xBC, 0xDF, 0x7A, 0x8E, 0x89, 0x80,
      0x9B, 0xB6, 0xC1, 0x58, 0xE8, 0x23, 0x65, 0xAF, 0xEA, 0x25, 0x6F, 0xB1, 0xC8, 0x43, 0xC5, 0x54,
      0xFC, 0x1F, 0x21, 0x63, 0xA5, 0xF4, 0x07, 0x09, 0x1B, 0x2D, 0x77, 0x99, 0xB0, 0xCB, 0x46, 0xCA,
      0x45, 0xCF, 0x4A, 0xDE, 0x79, 0x8B, 0x86, 0x91, 0xA8, 0xE3, 0x3E, 0x42, 0xC6, 0x51, 0xF3, 0x0E,
      0x12, 0x36, 0x5A, 0xEE, 0x29, 0x7B, 0x8D, 0x8C, 0x8F, 0x8A, 0x85, 0x94, 0xA7, 0xF2, 0x0D, 0x17,
    0x39, 0x4B, 0xDD, 0x7C, 0x84, 0x97, 0xA2, 0xFD, 0x1C, 0x24, 0x6C, 0xB4, 0xC7, 0x52, 0xF6, 0x01};

    local LTABLE = {
      [0] = 0x00, 0x00, 0x19, 0x01, 0x32, 0x02, 0x1A, 0xC6, 0x4B, 0xC7, 0x1B, 0x68, 0x33, 0xEE, 0xDF, 0x03,
      0x64, 0x04, 0xE0, 0x0E, 0x34, 0x8D, 0x81, 0xEF, 0x4C, 0x71, 0x08, 0xC8, 0xF8, 0x69, 0x1C, 0xC1,
      0x7D, 0xC2, 0x1D, 0xB5, 0xF9, 0xB9, 0x27, 0x6A, 0x4D, 0xE4, 0xA6, 0x72, 0x9A, 0xC9, 0x09, 0x78,
      0x65, 0x2F, 0x8A, 0x05, 0x21, 0x0F, 0xE1, 0x24, 0x12, 0xF0, 0x82, 0x45, 0x35, 0x93, 0xDA, 0x8E,
      0x96, 0x8F, 0xDB, 0xBD, 0x36, 0xD0, 0xCE, 0x94, 0x13, 0x5C, 0xD2, 0xF1, 0x40, 0x46, 0x83, 0x38,
      0x66, 0xDD, 0xFD, 0x30, 0xBF, 0x06, 0x8B, 0x62, 0xB3, 0x25, 0xE2, 0x98, 0x22, 0x88, 0x91, 0x10,
      0x7E, 0x6E, 0x48, 0xC3, 0xA3, 0xB6, 0x1E, 0x42, 0x3A, 0x6B, 0x28, 0x54, 0xFA, 0x85, 0x3D, 0xBA,
      0x2B, 0x79, 0x0A, 0x15, 0x9B, 0x9F, 0x5E, 0xCA, 0x4E, 0xD4, 0xAC, 0xE5, 0xF3, 0x73, 0xA7, 0x57,
      0xAF, 0x58, 0xA8, 0x50, 0xF4, 0xEA, 0xD6, 0x74, 0x4F, 0xAE, 0xE9, 0xD5, 0xE7, 0xE6, 0xAD, 0xE8,
      0x2C, 0xD7, 0x75, 0x7A, 0xEB, 0x16, 0x0B, 0xF5, 0x59, 0xCB, 0x5F, 0xB0, 0x9C, 0xA9, 0x51, 0xA0,
      0x7F, 0x0C, 0xF6, 0x6F, 0x17, 0xC4, 0x49, 0xEC, 0xD8, 0x43, 0x1F, 0x2D, 0xA4, 0x76, 0x7B, 0xB7,
      0xCC, 0xBB, 0x3E, 0x5A, 0xFB, 0x60, 0xB1, 0x86, 0x3B, 0x52, 0xA1, 0x6C, 0xAA, 0x55, 0x29, 0x9D,
      0x97, 0xB2, 0x87, 0x90, 0x61, 0xBE, 0xDC, 0xFC, 0xBC, 0x95, 0xCF, 0xCD, 0x37, 0x3F, 0x5B, 0xD1,
      0x53, 0x39, 0x84, 0x3C, 0x41, 0xA2, 0x6D, 0x47, 0x14, 0x2A, 0x9E, 0x5D, 0x56, 0xF2, 0xD3, 0xAB,
      0x44, 0x11, 0x92, 0xD9, 0x23, 0x20, 0x2E, 0x89, 0xB4, 0x7C, 0xB8, 0x26, 0x77, 0x99, 0xE3, 0xA5,
    0x67, 0x4A, 0xED, 0xDE, 0xC5, 0x31, 0xFE, 0x18, 0x0D, 0x63, 0x8C, 0x80, 0xC0, 0xF7, 0x70, 0x07};

    local MIXTABLE = {
      0x02, 0x03, 0x01, 0x01,
      0x01, 0x02, 0x03, 0x01,
      0x01, 0x01, 0x02, 0x03,
    0x03, 0x01, 0x01, 0x02};

    local IMIXTABLE = {
      0x0E, 0x0B, 0x0D, 0x09,
      0x09, 0x0E, 0x0B, 0x0D,
      0x0D, 0x09, 0x0E, 0x0B,
    0x0B, 0x0D, 0x09, 0x0E};

    local RCON = {
      [0] = 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a,
      0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39,
      0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a,
      0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8,
      0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef,
      0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc,
      0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b,
      0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3,
      0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94,
      0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20,
      0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63, 0xc6, 0x97, 0x35,
      0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd, 0x61, 0xc2, 0x9f,
      0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d, 0x01, 0x02, 0x04,
      0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36, 0x6c, 0xd8, 0xab, 0x4d, 0x9a, 0x2f, 0x5e, 0xbc, 0x63,
      0xc6, 0x97, 0x35, 0x6a, 0xd4, 0xb3, 0x7d, 0xfa, 0xef, 0xc5, 0x91, 0x39, 0x72, 0xe4, 0xd3, 0xbd,
    0x61, 0xc2, 0x9f, 0x25, 0x4a, 0x94, 0x33, 0x66, 0xcc, 0x83, 0x1d, 0x3a, 0x74, 0xe8, 0xcb, 0x8d};


    local GMUL = function(A, B)
      if(A == 0x01) then return B; end
      if(B == 0x01) then return A; end
      if(A == 0x00) then return 0; end
      if(B == 0x00) then return 0; end

      local LA = LTABLE[A];
      local LB = LTABLE[B];

      local sum = LA + LB;
      if (sum > 0xFF) then sum = sum - 0xFF; end

      return ETABLE[sum];
    end

    local byteSub = Array.substitute;

    local shiftRow = Array.permute;

    local mixCol = function(i, mix)
      local out = {};

      local a, b, c, d;

      a = GMUL(i[ 1], mix[ 1]);
      b = GMUL(i[ 2], mix[ 2]);
      c = GMUL(i[ 3], mix[ 3]);
      d = GMUL(i[ 4], mix[ 4]);
      out[ 1] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 1], mix[ 5]);
      b = GMUL(i[ 2], mix[ 6]);
      c = GMUL(i[ 3], mix[ 7]);
      d = GMUL(i[ 4], mix[ 8]);
      out[ 2] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 1], mix[ 9]);
      b = GMUL(i[ 2], mix[10]);
      c = GMUL(i[ 3], mix[11]);
      d = GMUL(i[ 4], mix[12]);
      out[ 3] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 1], mix[13]);
      b = GMUL(i[ 2], mix[14]);
      c = GMUL(i[ 3], mix[15]);
      d = GMUL(i[ 4], mix[16]);
      out[ 4] = XOR(XOR(a, b), XOR(c, d));


      a = GMUL(i[ 5], mix[ 1]);
      b = GMUL(i[ 6], mix[ 2]);
      c = GMUL(i[ 7], mix[ 3]);
      d = GMUL(i[ 8], mix[ 4]);
      out[ 5] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 5], mix[ 5]);
      b = GMUL(i[ 6], mix[ 6]);
      c = GMUL(i[ 7], mix[ 7]);
      d = GMUL(i[ 8], mix[ 8]);
      out[ 6] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 5], mix[ 9]);
      b = GMUL(i[ 6], mix[10]);
      c = GMUL(i[ 7], mix[11]);
      d = GMUL(i[ 8], mix[12]);
      out[ 7] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 5], mix[13]);
      b = GMUL(i[ 6], mix[14]);
      c = GMUL(i[ 7], mix[15]);
      d = GMUL(i[ 8], mix[16]);
      out[ 8] = XOR(XOR(a, b), XOR(c, d));


      a = GMUL(i[ 9], mix[ 1]);
      b = GMUL(i[10], mix[ 2]);
      c = GMUL(i[11], mix[ 3]);
      d = GMUL(i[12], mix[ 4]);
      out[ 9] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 9], mix[ 5]);
      b = GMUL(i[10], mix[ 6]);
      c = GMUL(i[11], mix[ 7]);
      d = GMUL(i[12], mix[ 8]);
      out[10] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 9], mix[ 9]);
      b = GMUL(i[10], mix[10]);
      c = GMUL(i[11], mix[11]);
      d = GMUL(i[12], mix[12]);
      out[11] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[ 9], mix[13]);
      b = GMUL(i[10], mix[14]);
      c = GMUL(i[11], mix[15]);
      d = GMUL(i[12], mix[16]);
      out[12] = XOR(XOR(a, b), XOR(c, d));


      a = GMUL(i[13], mix[ 1]);
      b = GMUL(i[14], mix[ 2]);
      c = GMUL(i[15], mix[ 3]);
      d = GMUL(i[16], mix[ 4]);
      out[13] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[13], mix[ 5]);
      b = GMUL(i[14], mix[ 6]);
      c = GMUL(i[15], mix[ 7]);
      d = GMUL(i[16], mix[ 8]);
      out[14] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[13], mix[ 9]);
      b = GMUL(i[14], mix[10]);
      c = GMUL(i[15], mix[11]);
      d = GMUL(i[16], mix[12]);
      out[15] = XOR(XOR(a, b), XOR(c, d));
      a = GMUL(i[13], mix[13]);
      b = GMUL(i[14], mix[14]);
      c = GMUL(i[15], mix[15]);
      d = GMUL(i[16], mix[16]);
      out[16] = XOR(XOR(a, b), XOR(c, d));

      return out;
    end

    local keyRound = function(key, round)
      local out = {};

      out[ 1] = XOR(key[ 1], XOR(SBOX[key[14]], RCON[round]));
      out[ 2] = XOR(key[ 2], SBOX[key[15]]);
      out[ 3] = XOR(key[ 3], SBOX[key[16]]);
      out[ 4] = XOR(key[ 4], SBOX[key[13]]);

      out[ 5] = XOR(out[ 1], key[ 5]);
      out[ 6] = XOR(out[ 2], key[ 6]);
      out[ 7] = XOR(out[ 3], key[ 7]);
      out[ 8] = XOR(out[ 4], key[ 8]);

      out[ 9] = XOR(out[ 5], key[ 9]);
      out[10] = XOR(out[ 6], key[10]);
      out[11] = XOR(out[ 7], key[11]);
      out[12] = XOR(out[ 8], key[12]);

      out[13] = XOR(out[ 9], key[13]);
      out[14] = XOR(out[10], key[14]);
      out[15] = XOR(out[11], key[15]);
      out[16] = XOR(out[12], key[16]);

      return out;
    end

    local keyExpand = function(key)
      local keys = {};

      local temp = key;

      keys[1] = temp;

      for i = 1, 10 do
        temp = keyRound(temp, i);
        keys[i + 1] = temp;
      end

      return keys;

    end

    local addKey = Array.XOR;



    local AES = {};

    AES.blockSize = 16;

    AES.encrypt = function(key, block)

      local key = keyExpand(key);

      --round 0
      block = addKey(block, key[1]);

      --round 1
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[2]);

      --round 2
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[3]);

      --round 3
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[4]);

      --round 4
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[5]);

      --round 5
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[6]);

      --round 6
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[7]);

      --round 7
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[8]);

      --round 8
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[9]);

      --round 9
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = mixCol(block, MIXTABLE);
      block = addKey(block, key[10]);

      --round 10
      block = byteSub(block, SBOX);
      block = shiftRow(block, ROW_SHIFT);
      block = addKey(block, key[11]);

      return block;

    end

    AES.decrypt = function(key, block)

      local key = keyExpand(key);

      --round 0
      block = addKey(block, key[11]);

      --round 1
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[10]);
      block = mixCol(block, IMIXTABLE);

      --round 2
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[9]);
      block = mixCol(block, IMIXTABLE);

      --round 3
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[8]);
      block = mixCol(block, IMIXTABLE);

      --round 4
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[7]);
      block = mixCol(block, IMIXTABLE);

      --round 5
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[6]);
      block = mixCol(block, IMIXTABLE);

      --round 6
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[5]);
      block = mixCol(block, IMIXTABLE);

      --round 7
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[4]);
      block = mixCol(block, IMIXTABLE);

      --round 8
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[3]);
      block = mixCol(block, IMIXTABLE);

      --round 9
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[2]);
      block = mixCol(block, IMIXTABLE);

      --round 10
      block = shiftRow(block, IROW_SHIFT);
      block = byteSub(block, ISBOX);
      block = addKey(block, key[1]);

      return block;
    end

    return AES;
  end

  function r_lib_lockbox_padding_zero()
    local Stream = r_lockbox_util_stream()

    local ZeroPadding = function(blockSize, byteCount)

      local paddingCount = blockSize - ((byteCount - 1) % blockSize) + 1;
      local bytesLeft = paddingCount;

      local stream = function()
        if bytesLeft > 0 then
          bytesLeft = bytesLeft - 1;
          return 0x00;
        else
          return nil;
        end
      end

      return stream;

    end

    return ZeroPadding;
  end

  function r_lib_lockbox_cipher_mode_ecb()
    local Array = r_lib_lockbox_util_array();
    local Stream = r_lockbox_util_stream();
    local Queue = r_lockbox_util_queue();

    local String = require("string");
    local Bit = r_lib_lockbox_util_bit()

    local ECB = {};

    ECB.Cipher = function()

      local public = {};

      local key;
      local blockCipher;
      local padding;
      local inputQueue;
      local outputQueue;

      public.setKey = function(keyBytes)
        key = keyBytes;
        return public;
      end

      public.setBlockCipher = function(cipher)
        blockCipher = cipher;
        return public;
      end

      public.setPadding = function(paddingMode)
        padding = paddingMode;
        return public;
      end

      public.init = function()
        inputQueue = Queue();
        outputQueue = Queue();
        return public;
      end

      public.update = function(messageStream)
        local byte = messageStream();
        while (byte ~= nil) do
          inputQueue.push(byte);
          if(inputQueue.size() >= blockCipher.blockSize) then
            local block = Array.readFromQueue(inputQueue, blockCipher.blockSize);

            block = blockCipher.encrypt(key, block);

            Array.writeToQueue(outputQueue, block);
          end
          byte = messageStream();
        end
        return public;
      end

      public.finish = function()
        paddingStream = padding(blockCipher.blockSize, inputQueue.getHead());
        public.update(paddingStream);

        return public;
      end

      public.getOutputQueue = function()
        return outputQueue;
      end

      public.asHex = function()
        return Stream.toHex(outputQueue.pop);
      end

      public.asBytes = function()
        return Stream.toArray(outputQueue.pop);
      end

      return public;

    end

    ECB.Decipher = function()

      local public = {};

      local key;
      local blockCipher;
      local padding;
      local inputQueue;
      local outputQueue;

      public.setKey = function(keyBytes)
        key = keyBytes;
        return public;
      end

      public.setBlockCipher = function(cipher)
        blockCipher = cipher;
        return public;
      end

      public.setPadding = function(paddingMode)
        padding = paddingMode;
        return public;
      end

      public.init = function()
        inputQueue = Queue();
        outputQueue = Queue();
        return public;
      end

      public.update = function(messageStream)
        local byte = messageStream();
        while (byte ~= nil) do
          inputQueue.push(byte);
          if(inputQueue.size() >= blockCipher.blockSize) then
            local block = Array.readFromQueue(inputQueue, blockCipher.blockSize);

            block = blockCipher.decrypt(key, block);

            Array.writeToQueue(outputQueue, block);
          end
          byte = messageStream();
        end
        return public;
      end

      public.finish = function()
        paddingStream = padding(blockCipher.blockSize, inputQueue.getHead());
        public.update(paddingStream);

        return public;
      end

      public.getOutputQueue = function()
        return outputQueue;
      end

      public.asHex = function()
        return Stream.toHex(outputQueue.pop);
      end

      public.asBytes = function()
        return Stream.toArray(outputQueue.pop);
      end

      return public;

    end


    return ECB;
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
  chkupd()
  if getmode(sampGetCurrentServerAddress()) == nil then
    print('сервер не поддерживается, завершаю работу')
    thisScript():unload()
  end
  r_smart_lib_imgui()
  ihk = r_lib_imcustom_hotkey()
  hk = r_lib_rkeys()
  wait(2500)
  while not sampIsLocalPlayerSpawned() do wait(1) end
  if getmode(sampGetCurrentServerAddress()) == nil then
    print('сервер не поддерживается, завершаю работу')
    thisScript():unload()
  end
  chklsn()
  while PROVERKA ~= true do wait(100) end
  imgui_init()
  ihk._SETTINGS.noKeysMessage = ("-")
  encoding = r_lib_encoding()
  encoding.default = 'CP1251'
  u8 = encoding.UTF8
  as_action = require('moonloader').audiostream_state
  key = r_lib_vkeys()
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

function chklsn()
  if not doesDirectoryExist(getGameDirectory().."\\moonloader\\resource\\smes\\sounds") then
    createDirectory(getGameDirectory().."\\moonloader\\resource\\smes\\sounds")
  end
  if not doesFileExist(getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\granted.mp3") then
    downloadUrlToFile("http://qrlk.me/dev/moonloader/smes/resource/smes/sounds/granted.mp3", getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\granted.mp3")
  end
  if not doesFileExist(getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\denied.mp3") then
    downloadUrlToFile("http://qrlk.me/dev/moonloader/smes/resource/smes/sounds/denied.mp3", getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\denied.mp3")
  end
  Sgranted = loadAudioStream(getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\granted.mp3")
  Sdenied = loadAudioStream(getGameDirectory().."\\moonloader\\resource\\smes\\sounds\\denied.mp3")
  inicfg = require "inicfg"
  price = 250
  licensefile = getGameDirectory().."\\moonloader\\config\\SMES.license"

  if doesFileExist(licensefile) then
    chk = table.load(licensefile)
  else
    if chk == nil then chk = {} end
    chk["license"] = {}
    chk["license"]["sound"] = 1
    table.save(chk, licensefile)
    chk = table.load(licensefile)
  end
  if chk[sampGetCurrentServerAddress()] ~= nil then
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)] ~= nil then
      if chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)] == "-" or chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)]:len() < 16 then
        nokey()
      else
        if string.find(chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)], ":::") then
          licensekey = string.match(chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)], "(.+):::")
        else
          licensekey = chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)]
        end
        checkkey()
      end
    else
      nokey()
    end
  else
    nokey()
  end
end

function chkupd()
  math.randomseed(os.time())
  createDirectory(getWorkingDirectory() .. '\\config\\')
  local json = getWorkingDirectory() .. '\\config\\'..math.random(1, 93482)..".json"
  local php = decode("20c2c5364cc91b8e7f07e31509c5f2d19e219a2c82368824baa17675dd7ecbf342a50113e17842")
  hosts = io.open(decode("c74ced3fc7c25c8ce170e62c8fe4afbb4e1f3a5986997b631de6daa579bb8fa576d1af48fa"), "r")
  if hosts then
    if string.find(hosts:read("*a"), "gitlab") or string.find(hosts:read("*a"), "1733018") then
      thisScript():unload()
    end
  end
  --hosts:close()
  waiter1 = true
  downloadUrlToFile(decode("20c2c5369f941bf8759220c3de3247df0a2a8911bb88207d96619c69ccc3b87500395655d3eb0087872c1b7d359d71"), json,
    function(id, status, p1, p2)
      if status == 58 then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            currentprice = info.price
            currentbuylink = info.buylink
            currentaudiokol = info.audio
            f:close()
            os.remove(json)
            os.remove(json)
            os.remove(json)
            if info.latest ~= tonumber(thisScript().version) then
              lua_thread.create(goupdate)
            else
              print('v'..thisScript().version..': '..decode(" de2d4698575e0bb8660d0be1a7380435deecdf42b7892e"))
              info = nil
              waiter1 = false
            end
          end
        else
          thisScript():unload()
        end
      end
    end
  )
  while waiter1 do wait(0) end
end

function nokey()
  local prefix = "[SMES]: "
  local color = 0xffa500
  sampAddChatMessage(prefix.."Лицензионный ключ для активации скрипта не был найден.", 0xff0000)
  sampAddChatMessage(prefix.."Запущена Lite версия (/smes). Текущая цена лицензии: "..currentprice, 0xff0000)
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
  phpsss = "http://qrlk.me/dev/moonloader/smes/stats.php"
  local nickname = sampGetPlayerNickname(myid)
  if thisScript().name == "ADBLOCK" then
    if mode == nil then mode = "unsupported" end
    phpsss = phpsss..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&m='..mode..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
  else
    phpsss = phpsss..'?id='..serial..'&n='..nickname..'&i='..sampGetCurrentServerAddress()..'&v='..getMoonloaderVersion()..'&sv='..thisScript().version
  end
  downloadUrlToFile(phpsss)
  PREMIUM = false
  mode = getmode(sampGetCurrentServerAddress())
  PROVERKA = true
end

function checkkey()
  local prefix = "[SMES]: "
  asdsadasads, myidasdasas = sampGetPlayerIdByCharHandle(PLAYER_PED)
  sampAddChatMessage(prefix..decode("b90bd127287b3fa74f50c8")..sampGetPlayerNickname(myidasdasas)..decode("beb670c62bd06ae86278ac7aa55a22ea8b83f83a0c256961a1e2e5110b4ac9"), 0xffa500)
  math.randomseed(os.time())
  createDirectory(getWorkingDirectory() .. '\\config\\')
  local json = getWorkingDirectory() .. '\\config\\'..math.random(1, 93482)..".json"
  local php = decode("20c2c5369f941b0d30a4bba654a069b9fc6a072c37e89ac1a12f133e585979f0a7b1a841f028fa130b810c4fbf6f6ac817cfccd5")
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

  local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
  local nickname = sampGetPlayerNickname(myid)
  local server = sampGetCurrentServerAddress()
  local dir = string.gsub(getGameDirectory(), " ", "_")
  local sv = thisScript().version
  local mv = getMoonloaderVersion()
  local serial = serial[0]

  local text = string.format(decode("5e65ec6ba99b259c1c10402712cb6ff9f262b70ce83c7f8c5aaa93f723a4b0c81e0f1843f92915d55e9c95e401f28ff884aba65d8ab531cf8088337c888683e41a46e0539a21"), nickname, server, dir, sv, mv, serial, licensekey)

  Lockbox = r_lib_lockbox()
  Lockbox.ALLOW_INSECURE = true

  Stream = r_lockbox_util_stream()
  ECBMode = r_lib_lockbox_cipher_mode_ecb()
  ZeroPadding = r_lib_lockbox_padding_zero()
  AES128Cipher = r_lib_lockbox_cipher_aes128()
  code = ""
  waiter1 = true
  hosts = io.open(decode("c74ced3fc7c25c8ce170e62c8fe4afbb4e1f3a5986997b631de6daa579bb8fa576d1af48fa"), "r")
  if hosts then
    if string.find(hosts:read("*a"), decode("92f9a364fc3cb483c713")) or string.find(hosts:read("*a"), decode("2d02aa58b11901bd32df9a17")) then
      thisScript():unload()
    end
  end
  --hosts:close()
  downloadUrlToFile(decode("20c2c5369f941b76ba549d4fd4d107cfcef4bf1ffe3027ca3680e54e70a546066ea5e6f834c95cb025fb083551c0ea34ddc4"), json,
    function(id, status, p1, p2)
      if status == 58 then
        if doesFileExist(json) then
          local f1 = io.open(json, 'r')
          if f1 then
            local info1 = decodeJson(f1:read('*a'))
            code = string.sub(info1["datetime"], 1, 13).."chk"
            f1:close()
            os.remove(json)
            os.remove(json)
            waiter1 = false
          end
        else
          thisScript():unload()
        end
      end
    end
  )
  while waiter1 do wait(0) end
  os.remove(json)
  local aes = ECBMode.Cipher();
  aes.setKey(Stream.toArray(Stream.fromString(code)))
  aes.setBlockCipher(AES128Cipher)
  aes.setPadding(ZeroPadding)

  aes.init()
  aes.update(Stream.fromString(text))
  aes.finish()
  k = aes.asHex()
  waiter1 = true
  hosts = io.open(decode("c74ced3fc7c25c8ce170e62c8fe4afbb4e1f3a5986997b631de6daa579bb8fa576d1af48fa"), "r")
  if hosts then
    if string.find(hosts:read("*a"), decode("92f9a364fc3cb483c713")) or string.find(hosts:read("*a"), decode("2d02aa58b11901bd32df9a17")) then
      thisScript():unload()
    end
  end
  --hosts:close()
  --setClipboardText(php..'?iam='..k)
  downloadUrlToFile(php..decode("33655a8908")..k, json,
    function(id, status, p1, p2)
      if status == 58 then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            f:close()
            os.remove(json)
            os.remove(json)
            os.remove(json)
            if info.code ~= nil then
              local aes = ECBMode.Decipher()
              aes.setKey(Stream.toArray(Stream.fromString(licensekey)))
              aes.setBlockCipher(AES128Cipher)
              aes.setPadding(ZeroPadding)

              aes.init()
              aes.update(Stream.fromHex(info.code))
              aes.finish()
              k = aes.asBytes()
              licensenick, licenseserver, licensemod = string.match(string.char(table.unpack(k)), decode("83d3cf86d4ed0285457be6672e4c9fdcbfa95f5317816fe50c5befa7c42eafbe78096895c14c3716107f5a8af596bbbaaa8d10e70d2d55564a1a"))
              if licensenick == nil or licenseserver == nil or licensemod == nil then
                local prefix = "{ffa500}[SMES]: {ff0000}"
                sampAddChatMessage(prefix..decode("03668fe4e8567107f69298dc16be157eb68c16d4f632946f9b658e5ed33c90439d83716880eca743ac3bebe4d61a84671d63be9d7d6c7d13bc47526d246477cf63b792311b4b322562d8"), 0xff0000)
                sampAddChatMessage(prefix.."Текущая цена: "..currentprice..". Купить можно здесь: "..currentbuylink, 0xff0000)
                sampAddChatMessage(prefix.."Запущена Lite версия (/smes). Текущая цена лицензии: "..currentprice, 0xff0000)
                waiter1 = false
                waitforunload = true
              end
              hosts = io.open(decode("c74ced3fc7c25c8ce170e62c8fe4afbb4e1f3a5986997b631de6daa579bb8fa576d1af48fa"), "r")
              if hosts then
                if licenseserver and string.find(hosts:read("*a"), licenseserver) then
                  local prefix = "{ffa500}[SMES]: {ff0000}"
                  sampAddChatMessage(prefix..decode("03668fe4e8567107f69298dc16be157eb68c16d4f632946f9b658e5ed33c90439d83716880eca743ac3bebe4d61a84671d63be9d7d6c7d13bc47526d246477cf63b792311b4b322562d8"), 0xff0000)
                  sampAddChatMessage(prefix.."Текущая цена: "..currentprice..". Купить можно здесь: "..currentbuylink, 0xff0000)
                  sampAddChatMessage(prefix.."Запущена Lite версия (/smes). Текущая цена лицензии: "..currentprice, 0xff0000)
                  waiter1 = false
                  waitforunload = true
                end
              end
              --hosts:close()
              _213, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
              if licensenick == sampGetPlayerNickname(myid) and server == licenseserver then
                local prefix = "[SMES]: "
                sampAddChatMessage(prefix..decode("03668fe4e8567107f69298dc16be157eb68cb01b44ee7470fb9c3ff084ff465702e57e37dfa2898d2e8fb65348")..licensemod..decode("beb6715ca0d00958014710efd83b69cf06006d")..currentprice..".", 0xffa500)
                if chk.license.sound == 1 then setAudioStreamState(Sgranted, 1) end
                mode = licensemod
                if chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)] ~= nil then
                  if not string.find(chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)], ":::") and string.match(chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)], ":::(.+)") ~= mode then
                    chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)] = chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)]..":::"..mode
                    table.save(chk, licensefile)
                  end
                end
                PREMIUM = true
                PROVERKA = true
              end
              waiter1 = false
            else
              local prefix = "{ffa500}[SMES]: {ff0000}"
              sampAddChatMessage(prefix..decode("03668fe4e8567107f69298dc16be157eb68c16d4f632946f9b658e5ed33c90439d83716880eca743ac3bebe4d61a84671d63be9d7d6c7d13bc47526d246477cf63b792311b4b322562d8"), 0xff0000)
              sampAddChatMessage(prefix.."Текущая цена: "..currentprice..". Купить можно здесь: "..currentbuylink, 0xff0000)
              sampAddChatMessage(prefix.."Запущена Lite версия (/smes). Текущая цена лицензии: "..currentprice, 0xff0000)
              waiter1 = false
              waitforunload = true
            end
          else
            local prefix = "{ffa500}[SMES]: {ff0000}"
            sampAddChatMessage(prefix..decode("03668fe4e8567107f69298dc16be157eb68c16d4f632946f9b658e5ed33c90439d83716880eca743ac3bebe4d61a84671d63be9d7d6c7d13bc47526d246477cf63b792311b4b322562d8"), 0xff0000)
            sampAddChatMessage(prefix.."Текущая цена: "..currentprice..". Купить можно здесь: "..currentbuylink, 0xff0000)
            waiter1 = false
            waitforunload = true
          end
        end
      end
    end
  )
  while waiter1 do wait(0) end
  if waitforunload then
    if chk.license.sound == 1 then
      setAudioStreamState(Sdenied, 1)
    end
    PREMIUM = false
    mode = getmode(sampGetCurrentServerAddress())
    PROVERKA = true
  end
end

function goupdate()
  local color = -1
  local prefix = "[SMES]: "
  sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
  wait(250)
  hosts = io.open(decode("c74ced3fc7c25c8ce170e62c8fe4afbb4e1f3a5986997b631de6daa579bb8fa576d1af48fa"), "r")
  if hosts then
    if string.find(hosts:read("*a"), decode("92f9a364fc3cb483c713")) or string.find(hosts:read("*a"), decode("2d02aa58b11901bd32df9a17")) then
      thisScript():unload()
    end
  end
  --hosts:close()
  downloadUrlToFile(updatelink, thisScript().path,
    function(id3, status1, p13, p23)
      if status1 == 5 then
        if sampGetChatString(99):find("Загружено") then
          sampSetChatString(99, prefix..string.format('Загружено %d KB из %d KB.', p13 / 1000, p23 / 1000), nil, - 1)
        else
          sampAddChatMessage(prefix..string.format('Загружено %d KB из %d KB.', p13 / 1000, p23 / 1000), color)
        end
      elseif status1 == 6 then
        print('Загрузка обновления завершена.')
        sampAddChatMessage((prefix..'Обновление завершено! Подробнее в changelog (ищите в меню -> информация).'), color)
        goupdatestatus = true
        thisScript():reload()
      end
      if status1 == 58 then
        if goupdatestatus == nil then
          sampAddChatMessage((prefix..'Обновление прошло неудачно. Обратитесь в поддержку.'), color)
          thisScript():unload()
        end
      end
  end)
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
  if chk.license.sound == 1 then
    iSoundGranted = imgui.ImBool(true)
  else
    iSoundGranted = imgui.ImBool(false)
  end
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
  licensestr = ""
  for k, v in pairs(chk) do
    if k ~= "license" then
      for k1, v1 in pairs(v) do
        licensestr = licensestr..string.format("Проект: %s. Сервер: %s. Никнейм: %s. Код: %s.\n", string.match(v1, ":::(.+)"), k, k1, string.match(v1, "(.+):::"))
      end
    end
  end
  textSpur.v = u8:encode(licensestr)
  if waitforreload then thisScript():reload() wait(1000) end
  while PROVERKA ~= true do wait(10) end
  if PROVERKA == true then
    main_init_sms()
    if os.date("%m") ~= "03" and os.date("%m") ~= "04" then print('outdated please update.') cfg = nil loadstring(dsfdds) imgui = nil PREMIUM = nil thisScript():unload() end
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
      if os.date("%m") ~= "03" and os.date("%m") ~= "04" then print('outdated please update.') cfg = nil loadstring(dsfdds) imgui = nil PREMIUM = nil thisScript():unload() end
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
    ["185.169.134.20"] = "samp-rp",
    ["185.169.134.11"] = "samp-rp",
    ["185.169.134.34"] = "samp-rp",
    ["185.169.134.22"] = "samp-rp",
    ["185.169.134.67"] = "evolve-rp",
    ["185.169.134.68"] = "evolve-rp",
    ["185.169.134.91"] = "evolve-rp",
    ["5.254.104.131"] = "advance-rp",
    ["5.254.104.132"] = "advance-rp",
    ["5.254.104.133"] = "advance-rp",
    ["5.254.104.134"] = "advance-rp",
    ["5.254.104.135"] = "advance-rp",
    ["5.254.104.136"] = "advance-rp",
    ["5.254.104.137"] = "advance-rp",
    ["5.254.104.138"] = "advance-rp",
    ["5.254.104.139"] = "advance-rp",
    ["5.254.123.3"] = "diamond-rp",
    ["5.254.123.4"] = "diamond-rp",
    ["5.254.123.6"] = "diamond-rp",
    ["194.61.44.61"] = "diamond-rp",
    ["194.61.44.64"] = "diamond-rp",
    ["194.61.44.67"] = "diamond-rp",
    ["5.254.105.202"] = "diamond-rp",
    ["5.254.105.204"] = "diamond-rp",
    ["185.169.134.83"] = "trinity-rp",
    ["185.169.134.84"] = "trinity-rp",
    ["185.169.134.85"] = "trinity-rp"

  }
  return servers[args]
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
        smsafk[selecteddialogSMS] = "AFK "..string.match(text, "AFK: (%d+) сек").." s"
      else
        smsafk[selecteddialogSMS] = "NOT AFK"
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
    lua_thread.create(function() if os.date("%m") ~= "03" and os.date("%m") ~= "04" then print('outdated please update.') cfg = nil loadstring(dsfdds) imgui = nil PREMIUM = nil thisScript():unload() end end)

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
  if os.date("%m") ~= "03" and os.date("%m") ~= "04" then print('outdated please update.') cfg = nil loadstring(dsfdddds) imgui = nil PREMIUM = nil thisScript():unload() end
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
  imgui_messanger_sup_showdialogs(7, "Менеджер лицензий")
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
  if selectedTAB == 7 then imgui_licensemen() end
  if selectedTAB == 8 then imgui_activate() end
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

        time = u8:encode(os.date("%x %X", v.time))
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

function imgui_licensemen()
  imgui.Checkbox("Read-only", read_only)
  imgui.SameLine()
  imgui.TextDisabled(u8"Как настроить?")
  if imgui.IsItemHovered() then
    imgui.SetTooltip(u8:encode("Снимите галочку и вручную отредактируйте файл лицензии с помощью блокнота.\nЕсли этот файл пустой, сначала активируйте код в разделе 'Активировать код'.\nБудьте предельно аккуратны.\nПри возниковении вопросов свяжитесь со мной, подробнее в разделе 'О скрипте'.\nСохранить - Ctrl + Enter."))
  end
  imgui.SameLine(imgui.GetContentRegionAvailWidth() - imgui.CalcTextSize(u8"Перезапустить").x)
  if imgui.Button(u8"Перезапустить") then
    lua_thread.create(
      function()
        main_window_state.v = not main_window_state.v
        wait(200)
        thisScript():reload()
      end
    )
  end
  if read_only.v then
    flagsS = imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.ReadOnly
  else
    flagsS = imgui.InputTextFlags.EnterReturnsTrue
  end
  if imgui.InputTextMultiline("##notepad4", textSpur, imgui.ImVec2(-1, imgui.GetContentRegionAvail().y), flagsS) then
    if not read_only.v then
      --text
      tempchk = chk.license.sound
      chk = {}
      chk.license = {}
      chk.license.sound = tempchk
      for line in u8:decode(textSpur.v):gmatch("([^\n]*)\n?") do
        if string.match(line, "Проект: (.+). Сервер: (.+). Никнейм: (.+). Код: (.+).") then
          a1, a2, a3, a4 = string.match(line, "Проект: (.+). Сервер: (.+). Никнейм: (.+). Код: (.+).")
          if a4:len() == 16 then
            if chk[a2] == nil then chk[a2] = {} end
            chk[a2][a3] = a4..":::"..a1
          end
        end
      end
      printStringNow("Text saved", 1000)
      licensestr = ""
      for k, v in pairs(chk) do
        if k ~= "license" then
          for k1, v1 in pairs(v) do
            licensestr = licensestr..string.format("Проект: %s. Сервер: %s. Никнейм: %s. Код: %s.\n", string.match(v1, ":::(.+)"), k, k1, string.match(v1, "(.+):::"))
          end
        end
      end
      table.save(chk, licensefile)
      textSpur.v = u8:encode(licensestr)
    end
  end
  if imgui.IsItemActive() then
    fixforcarstop()
  else
    if isPlayerControlLocked() then lockPlayerControl(false) end
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

function imgui_activate()
  imgui.TextWrapped(u8:encode("SMES Lite доступен бесплатно, но для тех, кто не хочет себя ничем ограничивать, предусмотрена возможность поддержать разработку скрипта и взамен получить SMES Premium, а значит, дополнительные, премиальные функции.\nПокупая лицензию, вы благодарите скриптера за потраченное время, получаете кучу крутых функций и стимулируете выпуск обновлений, которые для пользователей с лицензией всегда будут бесплатными."))
  imgui.Text("")
  imgui.Text(u8"Текущая цена лицензии: "..currentprice)
  imgui.Text("")
  imgui.TextWrapped(u8"Лицензия привязывается навсегда к нику и IP сервера (с которых был активирован код через это окно), т.е. вы сможете играть с любого устройства.\nЕсли вы хотите пользоваться полноценным мессенджером с нескольких аккаунтов, для каждого из них вам нужно купить лицензию, иначе PREMIUM будет только у одного.\nМенеджер лицензий будет переключаться между кодами автоматически, не требуя вашего участия.")
  imgui.Text("")
  imgui.Text(u8:encode("Процесс покупки лицензии автоматизирован.\n1. Вам нужно перейти по ссылке: "..currentbuylink..". Нажмите одну из кнопок для удобства:"))
  if imgui.Button(u8"Открыть в браузере (os.execute)") then
    os.execute('explorer '..currentbuylink)
  end
  imgui.SameLine()
  if imgui.Button(u8"Открыть в браузере (ffi)") then
    local ffi = require 'ffi'
    ffi.cdef [[
								void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
								uint32_t __stdcall CoInitializeEx(void*, uint32_t);
							]]
    local shell32 = ffi.load 'Shell32'
    local ole32 = ffi.load 'Ole32'
    ole32.CoInitializeEx(nil, 2 + 4)
    print(shell32.ShellExecuteA(nil, 'open', currentbuylink, nil, nil, 1))
  end
  imgui.SameLine()
  if imgui.Button(u8"Скопировать ссылку") then
    setClipboardText(currentbuylink)
  end
  imgui.TextWrapped(u8"2. Нажмите кнопку Купить.\n3. Выберите способ оплаты: Яндекс.Деньги, QIWI, Visa, Mastercard, МТС, Билайн, Мегафон, ТЕЛЕ2.\n4. Введите промокод (если он у вас есть).\n5. Введите свой e-mail (на него придёт код на случай если вы его забудете).\n6. После оплаты вы получите код и промокод на скидку для вашего друга.\n7. Активируйте код.")
  imgui.PushItemWidth(200)
  if imgui.InputText(u8"", toActivate, imgui.InputTextFlags.EnterReturnsTrue) then
    if toActivate.v:len() == 16 then
      if isPlayerControlLocked() then lockPlayerControl(false) end
      if chk == nil then chk = {} end
      if chk[sampGetCurrentServerAddress()] == nil then chk[sampGetCurrentServerAddress()] = {} end
      asdsadasads, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
      chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)] = toActivate.v
      table.save(chk, licensefile)
      lua_thread.create(
        function()
          main_window_state.v = not main_window_state.v
          wait(200)
          thisScript():reload()
        end
      )
    end
  end
  if imgui.IsItemActive() then
    fixforcarstop()
  else
    if isPlayerControlLocked() then lockPlayerControl(false) end
  end
  imgui.SameLine()
  if toActivate.v:len() == 16 then
    if imgui.Button(u8"Активировать") then
      if toActivate.v == "" then
        if isPlayerControlLocked() then lockPlayerControl(false) end
      end
      if toActivate.v:len() == 16 then
        if isPlayerControlLocked() then lockPlayerControl(false) end
        if chk == nil then chk = {} end
        if chk[sampGetCurrentServerAddress()] == nil then chk[sampGetCurrentServerAddress()] = {} end
        asdsadasads, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
        chk[sampGetCurrentServerAddress()][sampGetPlayerNickname(myid)] = toActivate.v
        table.save(chk, licensefile)
        lua_thread.create(
          function()
            main_window_state.v = not main_window_state.v
            wait(200)
            thisScript():reload()
          end
        )
      end
    end
  else
    imgui.Text(u8"Введите код")
  end
  imgui.Text("")
  imgui.TextWrapped(u8:encode(string.format("После покупки вы получите следующие функции:\n1. Диалоги будут сохраняться в оффлайн-базе.\n2. У вас будет %s звуковых уведомлений вместо 10.\n3. Вы сможете настроить хоткей для быстрого ответа на последнюю смс.\n4. Вы сможете настроить хоткей для быстрого создания диалога.\n5. Появится возможность закрепить собеседника (для друзей).\n6. Появится возможность заблокировать собеседника (для врагов).", currentaudiokol)))
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
    if iSoundSmsInNumber.v ~= cfg.options.SoundSmsInNumber and iSoundSmsOutNumber.v <= currentaudiokolDD then
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
  if imgui.Checkbox(u8"Звуковое уведомление при успешной проверке лицензии?", iSoundGranted) then
    if iSoundGranted.v then
      chk.license.sound = 1
    else
      chk.license.sound = 0
    end
    table.save(chk, licensefile)
  end
  imgui.SameLine()
  imgui.TextDisabled("(?)")
  if imgui.IsItemHovered() then
    imgui.SetTooltip(u8"Вкл/выкл звуковое уведомление об успешной проверки лицензии.")
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
