Config = {}

Config.CommandName = 'report'

Config.AdminGroups = {
    'admin'
}

Config.Locales = {         
    ["create_new_report"] = "Create New Report",
    ['my_report'] = "My Report",
    ['my_report_sub'] = "View all the reports you have created",
    ['staff_list'] = "Staff List",
    ['fill_all'] = "Please fill in all required fields",
    ["player"] = "Player",
    ['bug'] = "Bug",
    ["other"] = "Other",
    ['type_title'] = "Type Title",
    ['create'] = "Create",
    ['no_closedate'] = "None",
    ['pending'] = "Pending",
    ['open'] = "Open",
    ['closed'] = "Closed",
    ['view_image'] = "View Image",
    ['title'] = "Title",
    ['status'] = "Status",
    ['open_date'] = "Open Date",
    ['close_date'] = "Close Date",
    ['type_message'] = "Type a message",
    ['admin_in_report'] = "Admin in Report",
    ['all_report'] = "All Report",
    ['report_claimed'] = "Report Claimed",
    ['ban'] = "Ban",
    ['kick'] = "Kick",
    ['close_report'] = "Close Report",
    ['claim_report'] = "Claim Report",
    ['player_name'] = "Player Name",
    ['copied'] = "Copied!",
    ['message_error'] = "Message er...",
    ['type'] = "Type",
    ['send_image'] = "[E] Send Image",
    ['new_message'] = "You have a new message in your report",
    ['your_report_claimed'] = "Your report has been claimed",
    ['confirm'] = "Confirm",
    ['type_reason'] = "Type a reason",
    ['player_off'] = "Player offline",
    ['new_report'] = "New Report!",
    ['reason_error'] = "Invalid reason!"
}


Ban = function(identifier, reason)
    print("Banned "..identifier.." for "..reason)
    -- Inserire il trigger
end