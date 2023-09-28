const app = new Vue({
    el: '#app',

    data: {
        nomeRisorsa : GetParentResourceName(),

        selectedOption : 1,

        selectedReportType: -1,

        staff : false,

        staffInfo : {},

        reportStaffs : [], 

        reportStaff : [],

        reportPlayer : [],

        reportSelected : {}, 

        currentImageView : "", 

        staffList : [],

        locales : {},

        showNotify : false,
        notifyText : "",

        viewReason : false,
        viewReasonTitle : "",
        viewReasonAction : ""
    },

    methods: {
        postNUI(type, data) {
            $.post(`https://${this.nomeRisorsa}/${type}`, JSON.stringify(data));
        },

        actionAfterConfirm() {
            var reason = $("#reason").val()
            if(reason == '') {
                this.shownotify(this.locales.reason_error)
                return
            }
            this.postNUI('brutalAction', {
                reportId : this.reportSelected.id,
                action : this.viewReasonAction,
                reason : reason
            })
            this.viewReason = false
            this.viewReasonTitle = ""
            this.viewReasonAction = ""
        },

        updateSelectedIndex(index) {
            this.selectedOption = index;
        },


        updateSelectedReportType(index) {
            this.selectedReportType = index;
        },

        createNewReport() {
            var title = $("#titleReport").val()
            var type = this.selectedReportType
            this.postNUI('createReport', {title, type})
        },

        viewReport(v) {
            this.reportSelected = v
            this.updateSelectedIndex('viewreportplayer')
            setTimeout(() => {
                var containerMsg = $("#containerMessaggi")
                containerMsg.scrollTop(containerMsg.prop("scrollHeight"));
            }, 500);
        },

        viewReportStaff(v) {
            this.reportSelected = v
            this.updateSelectedIndex('viewreportstaff')
            setTimeout(() => {
                var containerMsg = $("#containerMessaggi")
                containerMsg.scrollTop(containerMsg.prop("scrollHeight"));
            }, 500);
        },

        getStatusLabel(status) {
            if(status == 'pending') {
                return this.locales.pending
            } else if(status == 'closed') {
                return this.locales.closed
            } else if(status == 'open') {
                return this.locales.open
            }
        },

        getTypeLabel(type) {
            if(type == 'player') {
                return this.locales.player
            } else if(type == 'bug') {
                return this.locales.bug
            } else if(type == 'other') {
                return this.locales.other
            }
        },

        getStatusImage(status) {
            return {
                backgroundImage : `url('./img/status_${status}.png')`
            }
        },

        getStatusColor(status) {
            if(status == 'pending') {
                return {
                    border : "none",
                    backgroundColor : '#C29131',
                    // filter : "drop-shadow(0px 0px 40px rgba(194, 145, 49, 0.83))"
                }
            } else if(status == 'open') {
                return {
                    border : "none",
                    backgroundColor : '#31C240',
                    // filter : "drop-shadow(0px 0px 40px rgba(49, 194, 64, 0.83))"
                }
            } else if(status == 'closed') {
                return {
                    border : "none",
                    backgroundColor : '#DF1B1B',
                    // filter : "drop-shadow(0px 0px 40px rgba(223, 27, 27, 0.83))"
                }
            }
        },

        viewImage(url) {
            this.currentImageView = url
        },


        reportClaimed() {
            var report = []
            for(const[k,v] of Object.entries(this.reportStaff)) {
                for(const[a,b] of Object.entries(v.staff)) {
                    if(b.identifier == this.staffInfo.identifier) {
                        report.push(v)
                    }
                }
            }
            return report
        },

        action(action) {
            if(action == 'ban') {
                this.viewReason = true
                this.viewReasonTitle = this.locales.type_reason
                this.viewReasonAction = 'ban'
            } else if(action == 'kick') {
                this.viewReason = true
                this.viewReasonTitle = this.locales.type_reason
                this.viewReasonAction = 'kick'
            } else {
                this.postNUI('action', {
                    reportId : this.reportSelected.id,
                    action : action
                })
            }
        },

        sendMessage(staff) {
            var message = ''
            if(staff) {
                message = $("#messageStaff").val()
            } else {
                message = $("#messagePlayer").val()
            }
            if(message == '') {
                this.shownotify(this.locales.message_error)
                return
            }
            var sender = ""
            if(staff) {
                sender = "staff"
            } else {
                sender = "player"
            }
            this.postNUI('sendMessage', {
                type : 'message',
                content : message,
                sender : sender,
                reportId : this.reportSelected.id
            })
            
            if(staff) {
                $("#messageStaff").val('')
            } else {
                $("#messagePlayer").val('')
            }
        },

        claimedReport(reportId) {
            for(const[k,v] of Object.entries(this.reportStaffs)) {
                if(v.id == reportId) {
                    for(const[a,b] of Object.entries(v.staff)) {
                        if(b.identifier == this.staffInfo.identifier) {
                            return true
                        }
                    }
                }
            }
            return false
        },


        claimReport() {
            if(this.claimedReport(this.reportSelected.id)) {

                return
            }
            this.postNUI('claimReport', {
                reportId : this.reportSelected.id
            })
        },

        copyLicense() {
            var text = this.reportSelected.identifier
            var input = document.createElement('input');
            input.setAttribute('value', text);
            document.body.appendChild(input);
            input.select();
            document.execCommand('copy');
            document.body.removeChild(input);
            this.shownotify(this.locales.copied)
        },


        shownotify(text) {
            if(this.showNotify) return
            this.notifyText = text
            this.showNotify = true
            setTimeout(() => {
                this.showNotify = false
            }, 3000);
        },

        sendImage() {
            // $("#app").fadeOut(500)
            this.updateSelectedIndex('sendimage')
            this.postNUI('sendImage', {
                reportId : this.reportSelected.id
            })
        }
    }

});


document.onkeyup = function (data) {
    if (data.key == 'Escape' && app.currentImageView != '') {
        app.currentImageView = ''
    } else if(data.key == 'Escape' && app.viewReason) {
        app.viewReason = false
        app.viewReasonTitle = ""
        app.viewReasonAction = ""
    } else if(data.key == 'Escape' && app.selectedOption == 'viewreportplayer') {
        app.updateSelectedIndex(2)
        app.reportSelected = {}
    } else if(data.key == 'Escape' && app.selectedOption == 'viewreportstaff') {
        app.updateSelectedIndex('all_report')
        app.reportSelected = {}
    } else if(data.key == 'Enter' && app.selectedOption == 'viewreportplayer' && $("#messagePlayer").val() != '') {
        app.sendMessage(false)
    } else if(data.key == 'Enter' && app.selectedOption == 'viewreportstaff' && $("#messageStaff").val() != '') {
        app.sendMessage(true)
    } else if(data.key == 'Escape') {
        $("#app").fadeOut(500)
        app.postNUI('close')
    }
};


window.addEventListener('message', function(event) {
    var data = event.data;
    if (data.type === "OPEN") {
        $("#app").fadeIn(500)
    } else if(data.type  === "LOAD_PLAYER_REPORT") {
        if(app.reportSeleted != {}) {
            for(const[k,v] of Object.entries(data.reportPlayer)) {
                if(v.id == app.reportSelected.id) {
                    app.reportSelected = v
                }
            }
        }
        app.reportPlayer = data.reportPlayer
    } else if(data.type === "SET_STAFF") {
        app.staff = data.staff
    } else if(data.type === "LOAD_ALL_REPORT") {

        if(app.reportSeleted != {}) {
            for(const[k,v] of Object.entries(data.allReport)) {
                if(v.id == app.reportSelected.id) {
                    app.reportSelected = v
                }
            }
        }

        app.reportStaffs = data.allReport
    } else if(data.type === "SET_INFO_STAFF") {
        app.staffInfo.name = data.name
        app.staffInfo.identifier = data.identifier
    } else if(data.type === "LOAD_CLAIMED_REPORT") {
        app.reportStaff = data.claimedReport
    } else if(data.type === "SCROLL_MESSAGE") {
        var reportId = data.reportId
        
        if(app.reportSelected.id == reportId) {
            var containerMsg = $("#containerMessaggi")
            containerMsg.scrollTop(containerMsg.prop("scrollHeight"));  
        }
    } else if(data.type === "LOAD_STAFF_LIST") {
        app.staffList = data.staffList
    } else if(data.type === "OPEN_REPORT_USER") {

        $("#app").fadeIn(500)
        for(const[k,v] of Object.entries(app.reportPlayer)) {
            if(v.id == data.idReport) {
                app.viewReport(v)
            }
        }
    } else if(data.type === "OPEN_REPORT_STAFF") {
        $("#app").fadeIn(500)
        for(const[k,v] of Object.entries(app.reportStaff)) {
            if(v.id == data.idReport) {
                app.viewReportStaff(v)
            }
        }
    } else if(data.type === "SET_DEFAULT_SCHERMATA") {
        app.updateSelectedIndex(data.schermata)
    } else if(data.type === "SET_LOCALES") {
        app.locales = data.locales
    }
})