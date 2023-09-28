-- Tech Development
-- Join our discord for support: https://discord.gg/2mXXhQy

local ESX = exports.es_extended:getSharedObject()
local PlayerData = {}
local sendingImage = false
local sendingImageReportId = 0
local open = false

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(50)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('ricky-report:open')
AddEventHandler('ricky-report:open', function()
    OpenReport()
end)

RegisterCommand(Config.CommandName, function(source, args, rawCommand)
    OpenReport()
end)

SonoStaff = function()
    local staff1 = nil
    ESX.TriggerServerCallback('ricky-report:sonoStaff', function(staff) 
        staff1 = staff
    end)
    while staff1 == nil do
        Wait(0)
    end
    return staff1
end

postNUI = function(data)
    SendNUIMessage(data)
end

LoadData = function()
    ESX.TriggerServerCallback('ricky-report:getData', function(data)

        postNUI({
            type = "SET_LOCALES",
            locales = Config.Locales
        })

        postNUI({
            type = "SET_STAFF",
            staff = SonoStaff()
        })

        postNUI({
            type = 'LOAD_STAFF_LIST',
            staffList = data.staffList
        })


        if not SonoStaff() then 
            postNUI({
                type = 'LOAD_PLAYER_REPORT',
                reportPlayer = data.reportPlayer
            })

        else
            postNUI({
                type = 'SET_INFO_STAFF',
                identifier = PlayerData.identifier,
                name = GetPlayerName(PlayerId()), 
            })

            postNUI({
                type = 'LOAD_CLAIMED_REPORT',
                claimedReport = data.reportClaimed
            })

            postNUI({
                type = 'LOAD_ALL_REPORT',
                allReport = data.allReport
            })
        end
    end)
end

OpenReport = function()
    if not SonoStaff() then 
        postNUI({
            type = "SET_DEFAULT_SCHERMATA",
            schermata = 1
        })
    else
        postNUI({
            type = "SET_DEFAULT_SCHERMATA",
            schermata = 'all_report'
        })
    end
    LoadData()
    SetNuiFocus(true, true)
    postNUI({
        type = 'OPEN',
    })
    open = true
end

RegisterNetEvent('ricky-report:openReportUser')
AddEventHandler('ricky-report:openReportUser', function(idReport)
    SetNuiFocus(true, true)
    postNUI({
        type = 'OPEN_REPORT_USER',
        idReport = idReport
    })
end)

RegisterNetEvent('ricky-report:openReportStaff')
AddEventHandler('ricky-report:openReportStaff', function(idReport)
    SetNuiFocus(true, true)
    postNUI({
        type = 'OPEN_REPORT_STAFF',
        idReport = idReport
    })
end)

RegisterNUICallback('sendImage', function(data)
    SetNuiFocus(false, false)
    sendingImage = true
    sendingImageReportId = data.reportId
end)

RegisterNUICallback('createReport', function(data)
    local title = data.title
    local type = data.type
    TriggerServerEvent('ricky-report:createReport', title, type)
end)

RegisterNUICallback('action', function(data)
    local action = data.action
    local reportId = tonumber(data.reportId)
    TriggerServerEvent('ricky-report:action', action, reportId)
end)

RegisterNUICallback('sendMessage', function(data)
    TriggerServerEvent('ricky-report:sendMessage', data)
end)

RegisterNUICallback('close', function(data)
    SetNuiFocus(false, false)
    open = false
end)

RegisterNUICallback('claimReport', function(data)
    local reportId = tonumber(data.reportId)
    TriggerServerEvent('ricky-report:claimReport', reportId)
end)

RegisterNetEvent('ricky-report:updateReport')
AddEventHandler('ricky-report:updateReport', function()
    LoadData()
end)

RegisterNetEvent('ricky-report:scrollMessage')
AddEventHandler('ricky-report:scrollMessage', function(reportId)
  postNUI({
    type = "SCROLL_MESSAGE",
    reportId = reportId
  })
end)

Citizen.CreateThread(function()
  while true do

    if sendingImage then 
        Wait(0)
        if IsControlJustPressed(0, 38) then 
            ESX.TriggerServerCallback('ricky-report:getWebhook', function(link) 
                exports['screenshot-basic']:requestScreenshotUpload(link, 'files[]', function(data)
                    local resp = json.decode(data)
                    local url = resp.attachments[1].url
                    TriggerServerEvent('ricky-report:sendImage', sendingImageReportId, url)
                    sendingImage = false
                end)
            end)
        end
    else
        Wait(1000)
    end
   end
end)


RegisterNetEvent('ricky-report:notification')
AddEventHandler('ricky-report:notification', function(msg, type)
    if open then return end
    ESX.ShowNotification(msg, type)
end)


RegisterNUICallback('brutalAction', function(data, cb)
    local action = data.action
    local reportId = tonumber(data.reportId)
    local reason = data.reason
    TriggerServerEvent('ricky-report:brutalAction', action, reportId, reason)
end)