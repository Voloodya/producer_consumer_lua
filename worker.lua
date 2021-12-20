box.cfg{ listen = '127.0.0.1:3301' }
box.schema.user.grant('guest','super', nil, nil, {if_not_exists=true})

-- Create module fiber
fiber = require 'fiber'
-- Create канала. Переменная не local -> глобальная - доступна из консоли
chan = fiber.channel()

-- "..." - список аргументов
function put_msg(...)
    chan:put({...}) -- {...} - преобразование в таблицу
end

--
function get_msg(timeout)
    local msg = chan:get(timeout or 1)
    if not msg then error("No messages") end
    return msg
end

-- Создание нового fiber-а
fiber.create(function()
    fiber.name('worker')

    -- Получение сообщения из канала в бесконечном цикле
    while true do
        local msg = chan:get_msg(1)
        if msg then
            print("Got a message: ",msg)
        end
    end
end)

--Запуск консоли
require('console').start()
--Завершение процесса после закрытия консоли
os.exit()


--Запустить инстанс
--tarantool worker.lua
--Создать вторую консоль и поключиться к запущенному инстансу
--tarantoolctl connect 127.0.0.1:3301
--В консоли положить сообщение в канал
--chan:put("message")

