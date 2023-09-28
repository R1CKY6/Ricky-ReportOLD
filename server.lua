-- Tech Development
-- Join our discord for support: https://discord.gg/2mXXhQy

local ESX = exports.es_extended:getSharedObject()

RegisterServerEvent('ricky-report:createReport')
AddEventHandler('ricky-report:createReport', function(title, type)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  if not xPlayer then return end

  if type == 1 then 
    type = 'player'
  elseif type == 2 then
    type = 'bug'
  elseif type == 3 then
    type = 'other'
  end

  local info = {
    title = title,
    ownerName = GetPlayerName(xPlayer.source),
    type = type,
    openDate = os.date('%d/%m/%Y %H:%M'), 
    status = "pending"
  }

  MySQL.Sync.execute("INSERT INTO ricky_report (identifier, reportInfo) VALUES(@identifier, @reportInfo)", {
    ['@identifier'] = xPlayer.identifier,
    ['@reportInfo'] = json.encode(info)
  })


  local idReport = MySQL.Sync.fetchScalar("SELECT id FROM ricky_report WHERE identifier = @identifier AND reportInfo = @reportInfo", {
    ['@identifier'] = xPlayer.identifier,
    ['@reportInfo'] = json.encode(info)
  })



  TriggerClientEvent('ricky-report:updateReport', -1)
  sendNotificationToAllStaff(Config.Locales["new_report"], "success")
  Wait(500)
  TriggerClientEvent('ricky-report:openReportUser', xPlayer.source, idReport)
end)


getUserReport = function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then return end
  local reports = {}

  local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE identifier = @identifier", {
        ['@identifier'] = xPlayer.identifier,
  })
  for i=1, #result,1 do 
    local info = json.decode(result[i].reportInfo)
    table.insert(reports, {
      title = info.title,
      identifier = result[i].identifier,
      status = info.status,
      openDate = info.openDate,
      closeDate = info.closeDate or nil,
      type = info.type,
      id = result[i].id,
      ownerName = info.ownerName,
      msg = json.decode(result[i].message),
      staff = json.decode(result[i].staff),
    })
  end

  return reports
end

getAllReport = function()
  local reports = {}

  local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report", {})
  for i=1, #result,1 do 
    local info = json.decode(result[i].reportInfo)
    table.insert(reports, {
      title = info.title,
      identifier = result[i].identifier,
      status = info.status,
      openDate = info.openDate,
      closeDate = info.closeDate or nil,
      type = info.type,
      id = result[i].id,
      ownerName = info.ownerName,
      msg = json.decode(result[i].message),
      staff = json.decode(result[i].staff),
    })
  end

  return reports
end

getReportClaimed = function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then return end
  local reports = {}

  local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE staff LIKE @staff", {
        ['@staff'] = '%'..xPlayer.identifier..'%',
  })
  for i=1, #result,1 do 
    local info = json.decode(result[i].reportInfo)
    table.insert(reports, {
      title = info.title,
      identifier = result[i].identifier,
      status = info.status,
      openDate = info.openDate,
      closeDate = info.closeDate or nil,
      type = info.type,
      id = result[i].id,
      ownerName = info.ownerName,
      msg = json.decode(result[i].message),
      staff = json.decode(result[i].staff),
    })
  end

  return reports
end

getStaffList = function()
  local xPlayers = ESX.GetExtendedPlayers()
  local staff = {}
  for _, xPlayer in pairs(xPlayers) do
    for k,v in pairs(Config.AdminGroups) do 
      if sonoStaff(xPlayer.source) then 
        table.insert(staff, {
          name = GetPlayerName(xPlayer.source),
          status = "online"
        })
      end
    end
  end
  return staff
end

ESX.RegisterServerCallback('ricky-report:getData', function(source, cb)
  local data = {}

  data.reportPlayer = getUserReport(source)
  data.allReport = getAllReport()
  data.reportClaimed = getReportClaimed(source)
  data.staffList = getStaffList()
  cb(data)
end)

RegisterServerEvent('ricky-report:sendMessage')
AddEventHandler('ricky-report:sendMessage', function(data)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)


  local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE id = @id", {
        ['@id'] = data.reportId,
  })

  local message = json.decode(result[1].message)
  table.insert(message, {
    content = data.content,
    sender = data.sender,
    type = data.type,
    name = GetPlayerName(xPlayer.source),
    id = xPlayer.source
  })

  MySQL.Sync.execute("UPDATE ricky_report SET message = @message WHERE id = @id", {
    ['@message'] = json.encode(message),
    ['@id'] = data.reportId
  })
  TriggerClientEvent('ricky-report:updateReport', -1)
  Wait(300)
  TriggerClientEvent('ricky-report:scrollMessage', -1, data.reportId)
  
  if not sonoStaff(xPlayer.source) then 
    sendNotificationStaff(result[1].staff, Config.Locales["new_message"], "success")
  else
    sendNotification(result[1].identifier, Config.Locales["new_message"], "success")
  end
end)


sonoStaff = function(source)
  local xPlayer = ESX.GetPlayerFromId(source)
  if not xPlayer then return end

  for k,v in pairs(Config.AdminGroups) do 
    if xPlayer.getGroup() == v then 
      return true
    end
  end
  return false
end

ESX.RegisterServerCallback('ricky-report:sonoStaff', function(source, cb)
  cb(sonoStaff(source))
end)

RegisterServerEvent('ricky-report:claimReport')
AddEventHandler('ricky-report:claimReport', function(reportId)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE id = @id", {
        ['@id'] = reportId,
  })

  local staff = json.decode(result[1].staff)
  table.insert(staff, {
    name = GetPlayerName(xPlayer.source),
    identifier = xPlayer.identifier
  })

  MySQL.Sync.execute("UPDATE ricky_report SET staff = @staff WHERE id = @id", {
    ['@staff'] = json.encode(staff),
    ['@id'] = reportId
  })

  local reportInfo = json.decode(result[1].reportInfo)
  reportInfo.status = "open"
  MySQL.Sync.execute("UPDATE ricky_report SET reportInfo = @reportInfo WHERE id = @id", {
    ['@reportInfo'] = json.encode(reportInfo),
    ['@id'] = reportId
  })

  TriggerClientEvent('ricky-report:updateReport', -1)

  sendNotification(result[1].identifier, Config.Locales["your_report_claimed"], "success")
end)


RegisterServerEvent('ricky-report:action')
AddEventHandler('ricky-report:action', function(action, reportId)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  if action == 'closereport' then 
    local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE id = @id", {
        ['@id'] = reportId,
    })

    local reportInfo = json.decode(result[1].reportInfo)
    reportInfo.status = "closed"
    reportInfo.closeDate = os.date('%d/%m/%Y %H:%M')
    MySQL.Sync.execute("UPDATE ricky_report SET reportInfo = @reportInfo WHERE id = @id", {
      ['@reportInfo'] = json.encode(reportInfo),
      ['@id'] = reportId
    })
  end

  TriggerClientEvent('ricky-report:updateReport', -1)
end)


ESX.RegisterServerCallback('ricky-report:getWebhook', function(source, cb)
  cb(ConfigS.Webhook)
end)

RegisterServerEvent('ricky-report:sendImage')
AddEventHandler('ricky-report:sendImage', function(reportId, url)
  local src = source
  local sender = ""
  if sonoStaff(src) then 
    sender = "staff"
  else
    sender = "player"
  end

  local result =  MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE id = @id", {
        ['@id'] = reportId,
  })

  local message = json.decode(result[1].message)

  table.insert(message, {
    content = url,
    sender = sender,
    type = "image",
    name = GetPlayerName(src),
    id = src
  })


  MySQL.Sync.execute("UPDATE ricky_report SET message = @message WHERE id = @id", {
    ['@message'] = json.encode(message),
    ['@id'] = reportId
  })

  TriggerClientEvent('ricky-report:updateReport', -1)
  if not sonoStaff(src) then 
    sendNotificationStaff(json.decode(result[1].staff), Config.Locales["new_message"], "success")
    TriggerClientEvent('ricky-report:openReportUser', src, reportId)
  else
    sendNotification(result[1].identifier, Config.Locales["new_message"], "success")
    TriggerClientEvent('ricky-report:openReportStaff', src, reportId)
  end
end)

sendNotification = function(identifier, msg, type)
  local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
  if not xPlayer then return end
  TriggerClientEvent('ricky-report:notification', xPlayer.source, msg, type)
end

sendNotificationStaff = function(staff, msg, type)
  if staff == "[]" then 
    staff = {}
  end
  for k,v in pairs(staff) do 
    local xPlayer = ESX.GetPlayerFromIdentifier(v.identifier)
    if xPlayer then 
      TriggerClientEvent('ricky-report:notification', xPlayer.source, msg, type)
    end
  end
end

sendNotificationToAllStaff = function(msg, type)
  local xPlayers = ESX.GetExtendedPlayers()
  for _, xPlayer in pairs(xPlayers) do
    for k,v in pairs(Config.AdminGroups) do 
      if xPlayer.getGroup() == v then 
        TriggerClientEvent('ricky-report:notification', xPlayer.source, msg, type)
      end
    end
  end
end


RegisterServerEvent('ricky-report:brutalAction')
AddEventHandler('ricky-report:brutalAction', function(action, reportId, reason)
  local result = MySQL.Sync.fetchAll("SELECT * FROM ricky_report WHERE id = @id", {
        ['@id'] = reportId,
  })

  local staff = ESX.GetPlayerFromId(source)

  if action == 'kick' then 
    local xPlayer = ESX.GetPlayerFromIdentifier(result[1].identifier)
    if xPlayer then 
      DropPlayer(xPlayer.source, reason)
    else
      staff.showNotification(Config.Locales.player_off, "error")
    end
  elseif action == 'ban' then 
    Ban(result[1].identifier, reason)
  end
end)