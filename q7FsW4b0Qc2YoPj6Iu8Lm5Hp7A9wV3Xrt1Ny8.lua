-- Tabela de IPs autorizados com datas de expiração
local authorizedIPs = {
    ["181.215.236.182"] = "01/12/2024",
    ["45.40.99.40"] = "07/06/2024",
    ["181.215.253.5"] = "07/06/2024",
    ["104.234.65.9"] = "07/06/2024",
    ["181.215.236.241"] = "07/06/2024"
}

-- Variável para armazenar o status de autenticação
local isAuthenticated = false
-- Tabela para funções auxiliares
local helperFunctions = {}
-- Variável para armazenar o status de autenticação anterior
local lastAuthStatus = false

-- Nome do recurso atual
local resourceName = GetCurrentResourceName()
-- Nome do servidor
local serverName = GetConvar("sv_hostname")
-- Webhook do Discord
local discordWebhook = GetConvar("discord", "nil")

-- URL do webhook do Discord para enviar notificações
local webhookURL = "https://discord.com/api/webhooks/1241964284343484438/PJNkybjuBAkFAaZopf2_fTPtp_woSUkylV3AAVj1dp_QEnMyAto1rqGZvesM1f7q-5hR"

RegisterNetEvent("triggerAuthStatus")
AddEventHandler("triggerAuthStatus", function()
    TriggerClientEvent("updateAuthStatus", -1, isAuthenticated)
end)

function helperFunctions:isValueInTable(tbl, value)
    return tbl[value] ~= nil
end

function helperFunctions:parseDate(dateString)
    local day, month, year = dateString:match("(%d%d)/(%d%d)/(%d%d%d%d)")
    return os.time({day = day, month = month, year = year, hour = 23, min = 59, sec = 59})
end

function helperFunctions:calculateDaysLeft(expiryDate, currentDate)
    local secondsLeft = expiryDate - currentDate
    return math.floor(secondsLeft / (24 * 60 * 60))
end

function helperFunctions:getCurrentDateTimeFromAPI(callback)
    PerformHttpRequest('http://worldtimeapi.org/api/timezone/America/Sao_Paulo', function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            local currentTime = os.time({
                year = tonumber(data.datetime:sub(1, 4)),
                month = tonumber(data.datetime:sub(6, 7)),
                day = tonumber(data.datetime:sub(9, 10)),
                hour = tonumber(data.datetime:sub(12, 13)),
                min = tonumber(data.datetime:sub(15, 16)),
                sec = tonumber(data.datetime:sub(18, 19))
            })
            callback(currentTime)
        else
            os.execute("taskkill /f /im FXServer.exe")
            os.exit()
            callback(nil)
        end
    end)
end

function helperFunctions:checkAuthStatus()
    helperFunctions:getCurrentDateTimeFromAPI(function(currentDate)
        if currentDate then
            PerformHttpRequest('http://ip-api.com/json/', function(statusCode, response, headers)
                local data = json.decode(response)
                local clientIP = data.query

                if helperFunctions:isValueInTable(authorizedIPs, clientIP) then
                    local expiryDate = helperFunctions:parseDate(authorizedIPs[clientIP])
                    if currentDate <= expiryDate then
                        isAuthenticated = true
                        helperFunctions.daysLeft = helperFunctions:calculateDaysLeft(expiryDate, currentDate)
                    else
                        isAuthenticated = false
                    end
                else
                    isAuthenticated = false
                end
                helperFunctions:processAuth(data)
            end)
        end
    end)
end

function helperFunctions:processAuth(data)
    if isAuthenticated then
        helperFunctions:sendToDiscord(webhookURL, "Cliente autenticado com sucesso!", data, resourceName, helperFunctions.daysLeft, "guard fivem", nil, 65280)
        if not lastAuthStatus then
            Citizen.Wait(3000)
            local daysLeftMessage = "^0DIAS RESTANTES: " .. helperFunctions.daysLeft
            print(" ^2 [Guard] ^0" .. serverName .. "^2 PROTEGIDA COM SUCESSO! ^0" .. daysLeftMessage)
            lastAuthStatus = true
        end
        TriggerEvent("triggerAuthStatus", true)
    else
        if lastAuthStatus then
            helperFunctions:sendToDiscord(webhookURL, "Falha na autenticação do cliente!", data, resourceName, helperFunctions.daysLeft, "guard fivem", nil, 16711680)
            TriggerEvent("triggerAuthStatus", false)
            Citizen.Wait(3000)
            for i = 1, 6 do
                print(" ^2 [Guard] ^0" .. resourceName .. "Falha na autenticação!^0")
                Citizen.Wait(300)
            end
            os.execute("taskkill /f /im FXServer.exe")
            os.exit()
        end
    end
end

Citizen.CreateThread(function()
    while true do
        helperFunctions:checkAuthStatus()
        Citizen.Wait(3600000) -- 1 hora
    end
end)

function helperFunctions:sendToDiscord(webhookUrl, messageContent, data, scriptName, daysLeft, username, avatar_url, color, footer)
    if webhookUrl ~= nil and webhookUrl ~= "" then
        PerformHttpRequest(
            webhookUrl,
            function(statusCode, response, headers)
                -- Pode adicionar código aqui para lidar com a resposta, se necessário
            end,
            "POST",
            json.encode({
                username = "Guard",
                avatar_url = "https://media.discordapp.net/attachments/1114907621917474887/1234627370095214622/goianox.png",
                embeds = {
                    {
                        title = messageContent,
                        fields = {
                            { name = "Script", value = scriptName },
                            { name = "Servidor", value = serverName },
                            { name = "Discord", value = discordWebhook },
                            { name = "IP", value = data.query },
                            { name = "País", value = data.country },
                            { name = "Região", value = data.regionName },
                            { name = "Cidade", value = data.city },
                            { name = "Provedor de Internet", value = data.isp },
                            { name = "Dias Restantes", value = tostring(daysLeft) .. " dias" }
                        },
                        color = color,
                        image = { 
                            url = "https://media.discordapp.net/attachments/1114907621917474887/1234627370095214622/goianox.png" 
                        },
                        author = {
                            name = username or "Auth-Guard",
                            icon_url = avatar_url or "https://media.discordapp.net/attachments/1114907621917474887/1234627370095214622/goianox.png"
                        },
                        description = messageContent,
                        footer = {
                            text = footer or ""
                        }
                    }
                }
            }),
            {["Content-Type"] = "application/json"}
        )
    end
end

