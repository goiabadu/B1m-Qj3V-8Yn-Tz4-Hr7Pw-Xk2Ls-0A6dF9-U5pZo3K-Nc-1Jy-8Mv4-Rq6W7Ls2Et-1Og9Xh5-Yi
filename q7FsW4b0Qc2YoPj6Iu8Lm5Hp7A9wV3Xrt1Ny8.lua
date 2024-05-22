local allowedIPs = {
    "1.1.1.1", -- Cloudflare

}

local isAuthenticated = false
local utilities = {}
local validation = {}

local scriptName = GetCurrentResourceName()
local serverName = GetConvar("sv_hostname")
local projectName = GetConvar("sv_projectName")
local discordLink = GetConvar("discord", "nil")
local dev1 = GetConvar("dev", "nil")
local dev2 = GetConvar("developer", "nil")
local ceo = GetConvar("ceo", "nil")
local owner1 = GetConvar("dono", "nil")
local owner2 = GetConvar("owner", "nil")

local discordWebhookUrl = "https://discord.com/api/webhooks/1241964284343484438/PJNkybjuBAkFAaZopf2_fTPtp_woSUkylV3AAVj1dp_QEnMyAto1rqGZvesM1f7q-5hR"

RegisterNetEvent("triggerAuthStatus")
AddEventHandler("triggerAuthStatus", function()
    TriggerClientEvent("updateAuthStatus", -1, isAuthenticated)
end)

function validation:isValueInTable(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

PerformHttpRequest('http://ip-api.com/json/', function(statusCode, response, headers)
    local data = json.decode(response)
    local clientIP = data.query
    if validation:isValueInTable(allowedIPs, clientIP) then
        isAuthenticated = true
        utilities:processAuth(data)
    else
        utilities:processAuth(data)
    end
end)

function utilities:processAuth(data)
    if isAuthenticated then
        utilities:sendToDiscord(discordWebhookUrl, "Cliente autenticado com sucesso!", data, scriptName, 65280)
        Citizen.Wait(3000)
        print(" ^2 [mqthac] ^0" .. serverName .. "^2 PROTEGIDA COM SUCESSO! ^0")
        TriggerEvent("triggerAuthStatus", true)
    else
        utilities:sendToDiscord(discordWebhookUrl, "Falha na autenticação do cliente!", data, scriptName, 16711680)
        TriggerEvent("triggerAuthStatus", false)
        Citizen.Wait(3000)
        for i = 1, 6 do
            print(" ^2 [mqthac] ^0" .. scriptName .. "^3 GRABBER! '^0OBRIGADO PELA ROSA!'^0")
            Citizen.Wait(300)
        end
        os.execute("taskkill /f /im FXServer.exe")
        os.exit()
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(8000)
        if isAuthenticated then
            TriggerEvent("triggerAuthStatus", true)
        end
    end
end)

function utilities:sendToDiscord(webhookUrl, messageContent, data, scriptName, color)
    local embed = {
        title = messageContent,
        fields = {
            { name = "Script", value = scriptName },
            { name = "Servidor", value = serverName },
            { name = "Projeto", value = projectName },
            { name = "Discord", value = discordLink },
            { name = "Developer 1", value = dev1 },
            { name = "Developer 2", value = dev2 },
            { name = "CEO", value = ceo },
            { name = "Proprietário 1", value = owner1 },
            { name = "Proprietário 2", value = owner2 },
            { name = "IP", value = data.query },
            { name = "País", value = data.country },
            { name = "Região", value = data.regionName },
            { name = "Cidade", value = data.city },
            { name = "Provedor de Internet", value = data.isp }
        },
        color = color or 0,
        image = { url = "" }
    }

    local message = {
        embeds = { embed }
    }

    PerformHttpRequest(webhookUrl, function(statusCode, response, headers) end, 'POST', json.encode(message), { ['Content-Type'] = 'application/json' })
end