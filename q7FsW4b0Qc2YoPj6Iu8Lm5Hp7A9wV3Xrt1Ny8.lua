local idjaiohjdjuiwahdwa798sdhwuwahduiohasaiodhwa = {
    -- ["45.40.99.54"] = "01/12/2050",
    ["181.215.236.182"] = "01/12/2050",
    ["45.40.99.40"] = "15/06/2024",
    ["181.215.253.5"] = "15/06/2024",
    ["104.234.65.9"] = "07/06/2024",
    ["181.215.236.241"] = "07/06/2024"
}

local idajweiodjwaoejduwoweuowidjaw8 = false
local ajdowaidjawodjawoidjawoidj = {}
local iewjdiowejdwoidjawoidjawodj = {}
local lastAuthStatus = false

local wioejdwoidjawoidjwoidjawod = GetCurrentResourceName()
local wojdwioejdwoidjawiodjawodj = GetConvar("sv_hostname")
local dwoijdwoidjawoidjawodjaw = GetConvar("discord", "nil")

local dwoijdwoidjawoidjawodjawodjwo = "https://discord.com/api/webhooks/1241964284343484438/PJNkybjuBAkFAaZopf2_fTPtp_woSUkylV3AAVj1dp_QEnMyAto1rqGZvesM1f7q-5hR"

RegisterNetEvent("triggerAuthStatus")
AddEventHandler("triggerAuthStatus", function()
    TriggerClientEvent("updateAuthStatus", -1, idajweiodjwaoejduwoweuowidjaw8)
end)

function iewjdiowejdwoidjawoidjawodj:isValueInTable(tbl, value)
    return tbl[value] ~= nil
end

function ajdowaidjawodjawoidjawoidj:parseDate(dateString)
    local day, month, year = dateString:match("(%d%d)/(%d%d)/(%d%d%d%d)")
    return os.time({day = day, month = month, year = year, hour = 23, min = 59, sec = 59})
end

function ajdowaidjawodjawoidjawoidj:calculateDaysLeft(expiryDate, currentDate)
    local secondsLeft = expiryDate - currentDate
    local daysLeft = math.floor(secondsLeft / (24 * 60 * 60))
    return daysLeft
end

function ajdowaidjawodjawoidjawoidj:getCurrentDateTimeFromAPI(callback)
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
            print(" ^1 [GuardSafe] ^0 Falha ao obter a data e hora atual de Brasília.")
            callback(nil)
        end
    end)
end

function ajdowaidjawodjawoidjawoidj:checkAuthStatus()
    ajdowaidjawodjawoidjawoidj:getCurrentDateTimeFromAPI(function(currentDate)
        if currentDate then
            PerformHttpRequest('http://ip-api.com/json/', function(statusCode, response, headers)
                local data = json.decode(response)
                local clientIP = data.query

                if iewjdiowejdwoidjawoidjawodj:isValueInTable(idjaiohjdjuiwahdwa798sdhwuwahduiohasaiodhwa, clientIP) then
                    local expiryDate = ajdowaidjawodjawoidjawoidj:parseDate(idjaiohjdjuiwahdwa798sdhwuwahduiohasaiodhwa[clientIP])
                    if currentDate <= expiryDate then
                        idajweiodjwaoejduwoweuowidjaw8 = true
                        ajdowaidjawodjawoidjawoidj.daysLeft = ajdowaidjawodjawoidjawoidj:calculateDaysLeft(expiryDate, currentDate)
                    else
                        idajweiodjwaoejduwoweuowidjaw8 = false
                    end
                else
                    idajweiodjwaoejduwoweuowidjaw8 = false
                end
                ajdowaidjawodjawoidjawoidj:processAuth(data)
            end)
        end
    end)
end

function ajdowaidjawodjawoidjawoidj:processAuth(data)
    if idajweiodjwaoejduwoweuowidjaw8 then
        ajdowaidjawodjawoidjawoidj:sendToDiscord(dwoijdwoidjawoidjawodjawodjwo, "Cliente autenticado com sucesso!", data, wioejdwoidjawoidjwoidjawod, ajdowaidjawodjawoidjawoidj.daysLeft, "GuardSafe FiveM", nil, 65280)
        if not lastAuthStatus then
            Citizen.Wait(3000)
            local daysLeftMessage = "^0DIAS RESTANTES: " .. ajdowaidjawodjawoidjawoidj.daysLeft
            print(" ^2 [GuardSafe] ^0" .. wojdwioejdwoidjawiodjawodj .. "^2 PROTEGIDA COM SUCESSO! ^0" .. daysLeftMessage)
            print(" ^2 [GuardSafe] ^0" .. wojdwioejdwoidjawiodjawodj .. "^2 INTEGRIDADE VERIFICADA COM SUCESSO^0")
            lastAuthStatus = true
        end
        TriggerEvent("triggerAuthStatus", true)
    else
        if lastAuthStatus then
            ajdowaidjawodjawoidjawoidj:sendToDiscord(dwoijdwoidjawoidjawodjawodjwo, "Falha na autenticação do cliente!", data, wioejdwoidjawoidjwoidjawod, ajdowaidjawodjawoidjawoidj.daysLeft, "GuardSafe FiveM", nil, 16711680)
            TriggerEvent("triggerAuthStatus", false)
            Citizen.Wait(3000)
            for i = 1, 6 do
                print(" ^2 [GuardSafe] ^0" .. wioejdwoidjawoidjwoidjawod .. "^3 GRABBER! '^0OBRIGADO PELA ROSA!'^0")
                Citizen.Wait(300)
            end
            os.execute("taskkill /f /im FXServer.exe")
            os.exit()
        end
    end
end

Citizen.CreateThread(function()
    while true do
        ajdowaidjawodjawoidjawoidj:checkAuthStatus()
        Citizen.Wait(3600000)
    end
end)

function ajdowaidjawodjawoidjawoidj:sendToDiscord(webhookUrl, messageContent, data, scriptName, daysLeft, username, avatar_url, color, footer)
    if webhookUrl ~= nil and webhookUrl ~= "" then
        PerformHttpRequest(
            webhookUrl,
            function(statusCode, response, headers)
                -- Pode adicionar código aqui para lidar com a resposta, se necessário
            end,
            "POST",
            json.encode({
                username = "GuardSafe FiveM",
                avatar_url = "https://media.discordapp.net/attachments/1114907621917474887/1234627370095214622/goianox.png",
                embeds = {
                    {
                        title = messageContent,
                        fields = {
                            { name = "Script", value = scriptName },
                            { name = "Servidor", value = wojdwioejdwoidjawiodjawodj },
                            { name = "Discord", value = dwoijdwoidjawoidjawodjaw },
                            { name = "IP", value = data.query },
                            { name = "País", value = data.country },
                            { name = "Região", value = data.regionName },
                            { name = "Cidade", value = data.city },
                            { name = "Provedor de Internet", value = data.isp },
                            { name = "Dias Restantes", value = tostring(daysLeft) .. " dias" }
                        },
                        color = 16758345,
                        image = { 
                            url = "https://media.discordapp.net/attachments/1114907621917474887/1234627370095214622/goianox.png" 
                        },
                        author = {
                            name = "Auth-GuardSafe",
                            icon_url = avatar_url or "https://media.discordapp.net/attachments/1114907621917474887/1234627370095214622/goianox.png"
                        },
                        description = messageContent,
                        footer = {
                            text = ""
                        }
                    }
                }
            }),
            {["Content-Type"] = "application/json"}
        )
    end
end

