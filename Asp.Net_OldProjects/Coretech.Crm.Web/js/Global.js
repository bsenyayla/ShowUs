var IsvWindowContainer = null;
var IsvObjectContainer = null;
var ddParentWindow = null;
var selectedCountryPhoneCode = null;
function GetMessages(code) {
    if (!R.isEmpty(window.top.Messages))
        if (!R.isEmpty(window.top.Messages[code])) {
            return window.top.Messages[code];
        }
    return code;
}

var FormLoadComplated = false;
var EmtyGuid = "00000000-0000-0000-0000-000000000000";
function CrmValidateForm(o, e) {
    var result = false;
    if (!e.returnValue)
        return result;

    var ReqObject = null;
    var MailObject = null;
    var CurrencyObject = null;
    if (FrameWorkType == "RefleX") {
        for (var i = 0; i < R.ComponentMng.length; i++) {
            var exType = "";
            var Obj = R.ComponentMng[i];
            exType = Obj.xType;

            if (
        (exType == "TextField") ||
        (exType == "NumericField") ||
        (exType == "DateField") ||
        (exType == "ComboField") ||
        (exType == "TextAreaField") ||
        (exType == "MultiSelectField") ||
        (exType == "FileUpload") ||
        (exType == "PhoneField") ||
        (exType == "CheckField")
        ) {

                var objs = Obj.src;

                if (Obj.visible && Obj.requirementLevel == 2 && GetParentNodeStyle(objs)) {

                    if (exType == "ComboField" && (R.isEmpty(Obj.getValue()))) {
                        ReqObject = Obj;
                        break;
                    }
                    else if ((exType == "TextAreaField" || exType == "TextField" || exType == "DateField" || exType == "NumericField" || exType == "MultiSelectField") && (R.isEmpty(Obj.getValue()))) {
                        ReqObject = Obj;
                        break;
                    } else if (exType == "CheckField" && R.isEmpty(Obj.getValue())) {
                        ReqObject = Obj;
                        break;
                    }
                    else if (exType == "PhoneField") {
                        if (Obj.id == "new_GSM" || Obj.id == "new_RecipientGSM" || "new_MobilePhone")
                        {
                            if (Obj.getValues().length < 5) {
                                ReqObject = Obj;
                                break;
                            }
                        }
                    }
                    else if (exType == "FileUpload" && (R.isEmpty(Obj.getValue()))) {
                        ReqObject = eval(Obj.id + "_Mf");
                        break;
                    }

                }

                if (exType == "NumericField" && Obj.visible && Obj.requirementLevel == 2 && GetParentNodeStyle(objs)) {
                    try {
                        if (!R.isEmpty(Obj.getValue())) {
                            var idname = Obj.id;
                            var c = eval(idname + "Currency");
                            if (R.isEmpty(c.getValue())) {
                                CurrencyObject = c;
                                break;
                            }
                        }
                        else {
                            var idname = Obj.id;
                            var c = eval(idname + "Currency");
                            if (!R.isEmpty(c.getValue())) {
                                c = eval(idname);
                                CurrencyObject = c;
                                break;
                            }
                        }

                    } catch (e) {

                    }
                }
                if (exType == "TextField" && !R.isEmpty(Obj.regex)) {
                    if (Obj.getValue() != "" && Obj.getValue() != null) {
                        if (!R.VTypes.email(Obj.getValue())) {
                            MailObject = Obj;
                            break;
                        }

                    }
                }
            }
        }
        if (ReqObject != null || MailObject != null || CurrencyObject != null) {
            if (MailObject != null) {
                alert(String.format(GetMessages("CRM_EMAIL_ADDRESS_NOT_CORRECT"), MailObject.getFieldLabel()));
                MailObject.focus();
                e.returnValue = false;

            }
            if (ReqObject != null) {
                alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), ReqObject.getFieldLabel()));
                ReqObject.focus();
                e.returnValue = false;

            }

            if (CurrencyObject != null) {
                alert(String.format(GetMessages("CRM_FIELD_CURRENCY_REQUIRED"), CurrencyObject.getFieldLabel()));
                CurrencyObject.focus();
                e.returnValue = false;

            }
        } else {
            e.returnValue = true;
            result = true;

        }



    }
    else {
        result = true;
    }
    // alert(result + "#" + e.returnValue + "#" + ReqObject)
    return result;
}
function GetParentNodeStyle(objs) {
    var myPanel = null;
    myPanel = R.ComponentMng.GetById(objs.id);
    if (myPanel != null && myPanel.xType != 'Panel')
        myPanel = null;
    if (myPanel != null && !myPanel.visible) {
        return false;
    }
    if (objs.parentNode && myPanel == null) {
        return GetParentNodeStyle(objs.parentNode);
    }
    return true;
}

function DownloadTemplate(Data, ObjectId, recId, AttributeId) {
    if (Data == "")
        return "";
    return String.format(
            "<a href=javascript:DownloadFile('{0}','{1}','{2}') ><img src='" + GetWebAppRoot + "/images/bullet_attach.png' width=12 height=12 />{3}</a>",
            ObjectId, recId, AttributeId, Data);
};
function LookUpTemplate(valGuid, ValName, ObjectId) {
    if (valGuid == "")
        return "";
    return String.format(
            "<a href=javascript:ShowEditWindow('','{0}','','{2}','') ><img src='" + GetWebAppRoot + "/images/bullet.png' width=12 height=12 /></a>{1}",
            valGuid, ValName, ObjectId);
};
function PhoneTemplate2(valNumber) {

    if (valNumber == "")
        return "";
    return String.format(
            "<a href=javascript:CallNumber2('{0}')><img src='" + GetWebAppRoot + "/images/phone.png' width=12 height=12 /></a><span>{1}<span>",
            valNumber.replace(/ /g, ''), valNumber);
}
function PhoneTemplate(valNumber) {

    if (valNumber == "")
        return "";
    return String.format(
            "<a href=javascript:CallNumber('{0}')><img src='" + GetWebAppRoot + "/images/phone.png' width=12 height=12 /></a><span>{1}<span>",
            valNumber.replace(/ /g, ''), valNumber);
}
function UrlTemplate(valUrl) {
    var prefix = "http://";
    if (valUrl.startsWith("http") || valUrl.startsWith("https"))
        prefix = "";
    if (valUrl.startsWith("~")) {
        prefix = "";
        valUrl = valUrl.replace("~", GetWebAppRoot);
    }
    if (valUrl == "")
        return "";
    return String.format(
            "<a href='{0}' target='_blank' ><img src='" + GetWebAppRoot + "/images/url.png' width=12 height=12 /></a>{1}",
             prefix + valUrl, valUrl);
}
function EmailTemplate(valEmail) {
    if (valEmail == "")
        return "";

    return String.format(
            "<a href='mailto:{0}'><img src='" + GetWebAppRoot + "/images/mail.png' width=12 height=12 />{0}</a>",
             valEmail);
}
function CurrencyTemplate(valNumber, valCurrencyCode) {
    if (valNumber == "" || valNumber == undefined)
        return "";
    return String.format(
            "{0} {1}",
             valNumber, valCurrencyCode);
}


function S4() {
    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
}
function guid() {
    return (S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4());
}
function ReadXml(text) {
    var xmlDoc
    if (window.DOMParser) {
        parser = new DOMParser();
        xmlDoc = parser.parseFromString(text, "text/xml");
    }
    else // Internet Explorer
    {
        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
        xmlDoc.async = "false";
        xmlDoc.loadXML(text);
    }
    return xmlDoc;
}
function getNodeValue(Xnode, AttributeName) {
    var ret = "";
    try {
        ret = Xnode.attributes.getNamedItem(AttributeName).nodeValue
    } catch (err) {

    }
    return ret;
}
function RefreshParetnGrid(IsCloseCurrentFrame) {

    if (FrameWorkType != "RefleX") {
        if (_framename == null || _framename == "")
            return;
        var frame = null;
        if (window.top.frames[_pframename] != null)
            frame = window.top.frames[_pframename].frames[_framename];
        else if (window.top.frames[_framename] != null)
            frame = window.top.frames[_framename];
        else if (window.parent.name == _framename)
            frame = window.parent;
        top.Ext.WindowMgr.getActive().body.unmask();
        if (!R.isEmpty(_gridpanelid)) {
            runScript(frame, "" + _gridpanelid + ".getData();");
        }
    }
    else {

        var win = window.top.R.WindowMng.getWindowById(_pawinid);
        if (win != null) {
            var tabpanel = win.getIFrame().window["Tabpanel1"];
            try {


                if (_tabframename == window.parent.frameElement.name) {/* Ilk Acılan Pencere IframeIcinde Değil*/
                    if (_gridpanelid != "") {
                        try {
                            var gframe = window.parent.frames[_rlistframename];
                            runScript(gframe, "" + _gridpanelid + ".getData();");
                            if (IsCloseCurrentFrame) {
                                R.clearDirty();
                                tabpanel.closeActiveTab();
                            }
                        } catch (e) {

                        }

                    }
                    return;
                }

                var frame = tabpanel.getTabIFrame(_tabframename);
                if (frame) { /*Bir ondeki tab kapanmis ise */
                    var gframe = frame.frames[_rlistframename];
                    if (_gridpanelid != "") {
                        runScript(gframe, "" + _gridpanelid + ".getData();");
                        if (IsCloseCurrentFrame) {
                            R.clearDirty();
                            tabpanel.closeActiveTab();
                        }
                    }
                }
            } catch (e) {//Gridlerde sorun varsa patlatmadan gec.
                if (IsCloseCurrentFrame) {
                    R.clearDirty();
                    tabpanel.closeActiveTab();
                }
            }
        } else {
            if (_gridpanelid != "") {
                var w = null;
                w = window.top.frames[_rlistframename];
                if (IsNull(window.top.frames[_rlistframename])) {
                    if (!IsNull(window.parent)) {
                        if (window.parent.name == _rlistframename)
                            w = window.parent;
                        else if (!IsNull(window.parent.parent)) {
                            if (window.parent.parent.name == _rlistframename)
                                w = window.parent.parent;
                        }
                    }
                }
                if (!IsNull(w)) {
                    if (!R.isEmpty(_gridpanelid)) {
                        runScript(w, "" + _gridpanelid + ".getData();");
                    }

                }
                else {
                    try {

                        w = window.top.frames["Frame_PnlCenter"].frames[_rlistframename];
                        if (!R.isEmpty(_gridpanelid)) {
                            runScript(w, "" + _gridpanelid + ".getData();");
                        }
                    } catch (e) {

                    }

                }
            }
            if (IsCloseCurrentFrame) {
                if (top.R.WindowMng.getActiveWindow() != 0) {
                    R.clearDirty();
                    top.R.WindowMng.getActiveWindow().hide();
                }
            }
        }
    }
}

function runScript(ev, code) {
    if (!R.isEmpty(ev)) {
        if (R.isIE)
            ev.execScript(code);
        else
            ev.eval(code);
    } else {
        try {
            eval(code);
        } catch (e) {

        }
    }
}

function ShowEditTabInfo(recid, DefaultEditPageId, ObjectId) {
    ShowEditTab(null, recid, DefaultEditPageId, ObjectId);
}

function ShowEditTab(gridpanelid, recid, DefaultEditPageId, ObjectId, FetchXML, Maximized) {
    if (FrameWorkType != "RefleX") {
        ShowEditWindow(gridpanelid, recid, DefaultEditPageId, ObjectId, FetchXML, Maximized);
        return;
    }
    //xxx
    var Qstring = "";
    Qstring = GetWebAppRoot + "/CrmPages/AutoPages/EditRefleX.aspx?defaulteditpageid=" + DefaultEditPageId
    + "&ObjectId=" + ObjectId
    + "&mode=2"
    + "&rlistframename=" + window.frameElement.name
    + "&gridpanelid=" + gridpanelid;
    if (window.parent != null)
        if (window.parent.frameElement) {
            Qstring += "&tabframename=" + window.parent.frameElement.name;
        }
        else {
            Qstring += "&tabframename=" + window.frameElement.name;
        }

    if (window.parent != null)
        Qstring += "&pawinid=" + window.top.R.WindowMng.getActiveWindow().id;
    if (recid != "")
        Qstring += "&recid=" + recid;
    if (FetchXML != null && FetchXML != "")
        Qstring += "&FetchXML=" + FetchXML;

    try {
        if (parent && parent.parent && parent.parent.Tabpanel1) {
            parent.parent.Tabpanel1.createTab(top.window.R.newId(), Qstring, "...", true, true);
        }
        else if (parent && parent.Tabpanel1) {
            parent.Tabpanel1.createTab(top.window.R.newId(), Qstring, "...", true, true);
        }
        else if (Tabpanel1) {
            Tabpanel1.createTab(top.window.R.newId(), Qstring, "...", true, true);
        }
    } catch (exc) {
        try {
            parent.Tabpanel1.createTab(top.window.R.newId(), Qstring, "...", true, true);
        } catch (e) {
            if (IsNull(parent.Tabpanel1)) {
                ShowEditWindow(gridpanelid, recid, DefaultEditPageId, ObjectId, FetchXML, Maximized);
            }
        }


    }

}

function TabCloseControl(el, id, chk) {
    if (R.isEmpty(chk))
        chk = false;

    var r = true;
    if (el.tabs.tabs.length == 1 && top.window.R.WindowMng.getActiveWindow() != 0) {
        top.window.R.WindowMng.getActiveWindow().hide();
    }
    else if (el.tabs.tabs.length == 1 && top.window.R.WindowMng.getActiveWindow() == 0) {
        for (i = 0; i < top.window.R.WindowMng.windows.length; i++) {
            if (!IsNull(top.window.R.WindowMng.windows[i]))
                top.window.R.WindowMng.windows[i].hide();
        }
    }
    else {
        if (frames["Frame_" + id])
            if (frames["Frame_" + id].R && frames["Frame_" + id].R.isDirty() && !chk)
                r = window.confirm(GetMessages("CRM_WINDOW_CLOSE"));
    }
    return r;
}
function GetPaWinId() {
    var Qstring = "";
    Qstring = window.top.R.WindowMng.getActiveWindow().id;
    return Qstring;
}
function GetFrameName() {
    var Qstring = "";
    Qstring = window.name;
    return Qstring
}
function GetPframeName() {
    var Qstring = "";
    if (window.parent != null)
        if (window.parent.frameElement) {
            Qstring += window.parent.frameElement.name;
        }
        else {
            Qstring += window.frameElement.name;
        }

    return Qstring
}
function ShowEditWindowFromLookup(cmb, DefaultEditPageId, ObjectId) {
    if (cmb.getValue() != null && cmb.getValue() != "")
        ShowEditWindow("", cmb.getValue(), DefaultEditPageId, ObjectId, "", false);
}

function ShowExcelImport(gridpanelid, ObjectId) {
    var itemGuid = guid();
    Qstring = GetWebAppRoot + "/CrmPages/Admin/ExcelImport/Import.aspx?"
    + "ObjectId=" + ObjectId
    + "&rlistframename=" + window.name
    + "&gridpanelid=" + gridpanelid
    + "&rnd=" + itemGuid;


    if (window.parent != null)
        Qstring += "&pframename=" + window.parent.name;

    var Width = 900;
    var Height = 350;

    window.top.newWindowRefleX(Qstring, { maximized: false, width: Width, height: Height, resizable: true, modal: true, maximizable: true });
}
function ShowEditWindow(gridpanelid, recid, DefaultEditPageId, ObjectId, FetchXML, Maximized) {
    var itemGuid = guid();
    var Qstring = "";
    if (FrameWorkType != "RefleX") {

        Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Edit.aspx?defaulteditpageid=" + DefaultEditPageId
    + "&ObjectId=" + ObjectId
    + "&framename=" + window.name
    + "&gridpanelid=" + gridpanelid;
    }
    else {
        Qstring = GetWebAppRoot + "/CrmPages/AutoPages/EditReflex.aspx?defaulteditpageid=" + DefaultEditPageId
    + "&ObjectId=" + ObjectId
    + "&mode=1"
    + "&rlistframename=" + window.name
    + "&gridpanelid=" + gridpanelid
    + "&rnd=" + itemGuid;
    }

    if (window.parent != null)
        Qstring += "&pframename=" + window.parent.name;


    if (recid != "")
        Qstring += "&recid=" + recid;
    if (FetchXML != null && FetchXML != "")
        Qstring += "&FetchXML=" + FetchXML;

    var Width = 900;
    var Height = 500;

    if (IsNull(Maximized)) {
        Maximized = true;
    }

    if (FrameWorkType != "RefleX") {
        window.top.newWindow(Qstring
    , { maximized: Maximized, width: Width, height: Height, resizable: true, modal: true, maximizable: true });
    }
    else {
        window.top.newWindowRefleX(Qstring, { maximized: Maximized, width: Width, height: Height, resizable: true, modal: true, maximizable: true });
    }
}

function WindowCloseControl(el, id) {
    var dirty = false;
    if (R.isEmpty(el.getIFrame()))
        return true;
    if (R.isEmpty(el.getIFrame().R))
        return true;
    if (!el.getIFrame().R.ComponentMng[0])
        return true;
    if (R.isEmpty(eval(el.getIFrame().R.ComponentMng[0]).tabs))
        return true;
    for (var i = 0; i < eval(el.getIFrame().R.ComponentMng[0]).tabs.tabs.length; i++) {
        var tab = eval(el.getIFrame().R.ComponentMng[0]).tabs.tabs[i];
        if (tab.mode != "Div") {
            if (!el.getTab("Frame_" + tab.id))
                return true;
            if (!el.getTab("Frame_" + tab.id).R)
                return true;

            if (el.getTab("Frame_" + tab.id).R.isDirty()) {
                dirty = true;
                break;
            }
        }
        else {
            if (el.getIFrame().R.isDirty()) {
                dirty = true;
                break;
            }
        }
    }

    var mytab = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"];
    var tCollection = mytab.tabs.tabs;
    var tabsret = true;
    for (var i = 0; i < tCollection.length; i++) {
        if (tCollection[i].listeners) {
            if (tCollection[i].listeners.tabClose) {
                if (tabsret)
                    tabsret = tCollection[i].listeners.tabClose(mytab, tCollection[i].id)
            }
        }
        //tabsret = mytab.closeTab(tCollection[i].id);
    }
    if (tabsret == false)
        return false;

    if (dirty)
        return window.confirm(GetMessages("CRM_WINDOW_CLOSE"));

    return true;
}

var newWindowRefleX = function (url, config) {
    var win = new R.Window(R.apply({
        isRender: false,
        resizeable: false,
        showOnLoad: true,
        windowMode: "Frame",
        centerOnLoad: true,
        closeAction: 'Destroy',
        url: url,
        listeners: {
            close: function (el, e) { return WindowCloseControl(el, e) }
        }
    }, config));
}

var newWindow = function (url, config) {
    try {
        new Ext.Window(Ext.apply({
            renderTo: Ext.getBody(),
            resizable: false,
            height: 500,
            width: 500,
            closeAction: 'close',
            frame: true,
            autoLoad: {
                maskMsg: "Creating...",
                showMask: true,
                mode: "iframe",
                url: url
            }
        }, config)).show();
    } catch (e) {
        newWindowRefleX(url, config)
        return;

    }


}

function ShowNtoNLookup(ObjectId, Lookup, viewqueryid, win, filterXml) {
    var w = window.top.newWindow(GetWebAppRoot + "/CrmPages/AutoPages/LookUp.aspx?FetchXML="
    + CreateNtoNLookupXml(ObjectId, Lookup, viewqueryid, win, filterXml),
    {
        title: 'Lookup', width: 400, height: 400, resizable: true,
        modal: true, plain: true
    }
    );
}
function ShowReport(reportid, recordid, extension, maximized) {
    var m = R.isEmpty(maximized) ? true : maximized;
    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + reportid
    + "&RecordId=" + recordid
    if (extension != null)
        Qstring += extension;
    if (FrameWorkType != "RefleX") {
        window.top.newWindow(Qstring
    , { maximized: m, width: 800, height: 600, resizable: true, modal: true, maximizable: true });
    }
    else {
        //window.top.newWindowRefleX(Qstring, { maximized: m, width: 800, height: 600, resizable: true, modal: true, maximizable: true });
        //window.open(Qstring);
        var w = 800, h = 600;
        var left = (screen.width / 2) - (w / 2);
        var top = (screen.height / 2) - (h / 2);
        window.open(Qstring, "Report", 'toolbar=yes, location=yes, directories=yes, status=yes, menubar=yes, scrollbars=yes, resizable=yes, copyhistory=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);
    }
}
function ShowReportWithParameters(reportid, recordid, Parameters, strValues) {
    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ShowReport.aspx?ReportId=" + reportid
    + "&RecordId=" + recordid
    + "&Parameters=" + Parameters
    for (var i = 0; i < strValues.length; i++) {
        Qstring += "&p" + i + "=" + strValues[i];
    }


    if (FrameWorkType != "RefleX") {
        window.top.newWindow(Qstring
    , { maximized: true, width: 800, height: 600, resizable: true, modal: true, maximizable: true });
    }
    else {
        window.top.newWindowRefleX(Qstring, { maximized: true, width: 800, height: 600, resizable: true, modal: true, maximizable: true });
    }
}

function CreateNtoNLookupXml(ObjectId, Lookup, viewqueryid, win, filter) {
    var strQuery = "";
    strQuery += "<f framename='" + win.name + "' lookup='" + Lookup + "' objectid='" + ObjectId + "' viewqueryid='" + viewqueryid + "' filtertext='' type='ntonlookup' >" /*Feach Begin Tag*/
    if (filter != null) {
        for (i = 0; i < filter.length; i++) {
            if (filter[i].AttributeValue) {
                strQuery += "<w id='" + filter[i].ToAttributeId + "' value='" + filter[i].AttributeValue + "'/>" /*Feach Begin Tag*/
            } else if (filter[i].AttributeIdName) {
                strQuery += "<w id='" + filter[i].ToAttributeId + "' value='" + eval(filter[i].AttributeIdName).getValue() + "'/>" /*Feach Begin Tag*/
            }
        }
    }
    strQuery += "</f>"
    return strQuery;
}
function ShowLookup(ObjectId, Lookup, viewqueryid, LookupText, win, filterXml) {

    var Qstring = GetWebAppRoot + "/CrmPages/AutoPages/LookUp.aspx?FetchXML=" + CreateLookupXml(ObjectId, Lookup, viewqueryid, LookupText, win, filterXml);
    if (FrameWorkType != "RefleX") {
        window.top.newWindow(Qstring, { title: 'Lookup', width: 400, height: 400, resizable: true, modal: true, plain: true });
    }
    else {
        Qstring += "&pawinid=" + window.top.R.WindowMng.getActiveWindow().id;
        window.top.newWindowRefleX(Qstring, { title: 'Lookup', width: 400, height: 400, resizable: true, modal: true, maximizable: false });
    }

}

function CreateLookupXml(ObjectId, Lookup, viewqueryid, LookupText, win, filter) {
    var filterText = LookupText.getValue();
    if (viewqueryid == "||") {
        ObjectId = GetLookUpObjectId();
    }
    var strQuery = "";
    strQuery += "<f framename='" + win.name + "' lookup='" + Lookup + "' objectid='" + ObjectId + "' viewqueryid='" + viewqueryid + "' filtertext='" + filterText + "' type='lookup' >" /*Feach Begin Tag*/
    if (filter != null) {
        for (i = 0; i < filter.length; i++) {
            if (!R.isEmpty(filter[i].AttributeValue)) {
                strQuery += "<w id='" + filter[i].ToAttributeId + "' value='" + filter[i].AttributeValue + "'/>" /*Feach Begin Tag*/
            } else if (filter[i].AttributeIdName) {
                var comp = R.isEmpty(filter[i].ComponentId) ? filter[i].AttributeIdName : filter[i].ComponentId;
                if (!R.isEmpty(comp)) {
                    if ((eval(comp).parentRequired == true || eval(comp).requirementLevel == 2) && R.isEmpty(eval(comp).getValue())) {
                        alert(String.format(GetMessages("CRM_FIELD_REQUIRED"), eval(comp).getFieldLabel()));
                        LookupText.cancel = true;
                        eval(comp).focus();
                        break;
                    }

                    strQuery += "<w id='" + filter[i].ToAttributeId + "' value='" + eval(comp).getValue(filter[i].AttributeIdName) + "'/>" /*Feach Begin Tag*/
                }
            }

        }
    }
    strQuery += "</f>";
    return strQuery;
}
function DownloadFile(ObjectId, RecId, AttributeId) {
    var s = String.format(GetWebAppRoot + "/CrmPages/AutoPages/DownloadFile.aspx?objectid={0}&recid={1}&attributeid={2}", ObjectId, RecId, AttributeId);
    window.location = s;
    //window.open(s, "Download" , "menubar = 1, resizable = 1, width = 350, height = 250");
}
function GetMapXMLValue(xmlvalue) {
    var XObject = ReadXml(xmlvalue);
    var strQuery = "";
    strQuery += "<f >";
    for (var i = 0; i < XObject.childNodes.length; i++) {
        for (j = 0; j < XObject.childNodes[i].childNodes.length; j++) {
            var Xnode = XObject.childNodes[i].childNodes[j];
            var fid = getNodeValue(Xnode, "id")
            var tid = getNodeValue(Xnode, "value")
            var mode = getNodeValue(Xnode, "mode");
            if (mode == "raw") {
                tid = eval(tid);
            }
            strQuery += "<w id='" + fid + "' value='" + tid + "'/>";
        }
    }
    strQuery += "</f>";
    return strQuery;
}



function IsNull(o) {
    return ("undefined" == typeof (o) || "unknown" == typeof (o) || null == o);
}
function sIsNull(o) {
    return ("undefined" == typeof (o) || "unknown" == typeof (o) || null == o) ? "" : o;
}

var sInvalidSchemaNameChars = "[^A-Za-z0-9_]";
function EscapeChr(s) {
    var regExp = new RegExp(sInvalidSchemaNameChars, "g");
    return s.replace(regExp, "").substr(0, 100);
}
String.prototype.ReplaceAll = function (stringToFind, stringToReplace) {
    var temp = this;
    var index = temp.indexOf(stringToFind);
    while (index != -1) {
        temp = temp.replace(stringToFind, stringToReplace);
        index = temp.indexOf(stringToFind);
    }
    return temp;
}
function SetMultiSelectValues(e) {
    if (e.getValues().length != "")
        eval("hdn_" + e.id.toString().substring(4, e.id.toString().length)).setValue(Ext.encode(e.getValues()));
}

function MultiSelectDelete_Selected(e) {
    var selectedValue = e.getValue();
    var splSelected = selectedValue.split(",");
    for (var i = 0; i < splSelected.length; i++) {
        for (j = 0; j < e.store.data.items.length; j++) {
            if (splSelected[i] == e.store.data.items[j].data.value) {
                e.store.remove(e.store.data.items[j]);
                continue;
            }
        }
    }
    SetMultiSelectValues(e);
}
function MultiSelectAdd_Selected(frame, e, id, text) {
    var itemGuid = guid();
    var MyRecordType = Ext.data.Record.create(["value", "text"]);
    myrec = new MyRecordType({ "value": '' + id + '', "text": '' + text + '' });
    myrec.id = itemGuid;
    e.view.store.insert(e.store.data.length, myrec);
    e.view.refresh();
    SetMultiSelectValues(e);
}



function SetMultiSelectValuesR(e) {
    if (e.getValue().length != "")
        eval("hdn_" + e.id.toString().substring(4, e.id.toString().length)).setValue(e.getValue());
}

function MultiSelectDelete_SelectedR(e) {
    e.deleteValue();
    SetMultiSelectValuesR(e);
}
function MultiSelectAdd_SelectedR(frame, e, id, text) {
    e.setValue(id, text);
    SetMultiSelectValuesR(e);
}

function CallNumber(phone) {
    try {
        while (phone.indexOf(" ") > -1) {
            phone = phone.replace(" ", "");
        }
        var c = 1;
        var phonex = "";
        while (c < 12) {
            if (phone[phone.length - c])
                phonex = phone[phone.length - c] + phonex;
            c++;
        }
        var MyPhone = new String();
        if (phonex[0] != "0")
            phonex = "0" + phonex;
        MyPhone = phonex;
        var objAgent = new ActiveXObject('CosmoAgent.clsCCAgent');
        objAgent.Connect();
        if (objAgent.CurrentState != '4') {
            if (objAgent.CurrentState == '1')
                objAgent.MakeAvailable();
            objAgent.MakeReleased();
            objAgent.DialOut(MyPhone);

            //            pause(1000);


            //            var CallID = objAgent.MyAgent.objCall.CallId.toString();
            //            var AgentID = objAgent.UserID.toString();


            //            var iframe;

            //            if (!document.getElementById("cosmocalllog")) {

            //                iframe = R._createIframe("cosmocalllog");

            //                iframe.src = GetWebAppRoot + "/CallCenter/CosmoCallLog.aspx?CallID=" + CallID + "&AgentID=" + AgentID + "&PhoneNumber=" + phonex;
            //                iframe.style.display = "none";
            //                document.body.appendChild(iframe);
            //            }

        }
        //        R.remove(iframe);
        objAgent = null;
    } catch (e) {

    }
}

function pause(iMilliseconds) {
    var sDialogScript = 'window.setTimeout( function () { window.close(); }, ' + iMilliseconds + ');';
    window.showModalDialog('javascript:document.writeln ("<script>' + sDialogScript + '<' + '/script>")');
}

function sleep(m) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > m)
            break;
    }

}

function CallNumber2(phone) {
    try {
        var MyPhone = new String();
        MyPhone = phone;
        var objAgent = new ActiveXObject('CosmoAgent.clsCCAgent');
        objAgent.Connect();
        if (objAgent.CurrentState != '4') {
            if (objAgent.CurrentState == '1')
                objAgent.MakeAvailable();
            objAgent.MakeReleased();

            objAgent.DialOut(MyPhone);

            //            pause(1000);


            //            var CallID = objAgent.MyAgent.objCall.CallId.toString();
            //            var AgentID = objAgent.UserID.toString();


            //            var iframe;

            //            if (!document.getElementById("cosmocalllog")) {

            //                iframe = R._createIframe("cosmocalllog");

            //                iframe.src = GetWebAppRoot + "/CallCenter/CosmoCallLog.aspx?CallID=" + CallID + "&AgentID=" + AgentID + "&PhoneNumber=" + phonex;
            //                iframe.style.display = "none";
            //                document.body.appendChild(iframe);
            //            }

        }
        //        R.remove(iframe);
        objAgent = null;
    } catch (e) {

    }
}

var xml_special_to_escaped_one_map = {
    '&': '&amp;',
    '"': '&quot;',
    '<': '&lt;',
    '>': '&gt;'
};

var escaped_one_to_xml_special_map = {
    '&amp;': '&',
    '&quot;': '"',
    '&lt;': '<',
    '&gt;': '>'
};

function encodeXml(string) {
    return string.replace(/([\&"<>])/g, function (str, item) {
        return xml_special_to_escaped_one_map[item];
    });
};

function decodeXml(string) {
    return string.replace(/(&quot;|&lt;|&gt;|&amp;)/g,
function (str, item) {
    return escaped_one_to_xml_special_map[item];
});
}

function SetMaskScreen(val) {

    var loadingMask = document.getElementById('loading-mask');
    var loading = document.getElementById('loading');
    loading.style.display = val ? 'block' : 'none';
    loadingMask.style.display = val ? 'block' : 'none';
}

function ExportExcel(type) {
    if (FrameWorkType != "RefleX") {
        var itemGuid = guid();
        var p = StoreViewer.lastOptions.params;
        p['FileName'] = itemGuid + '.xls';
        p['ExportType'] = type;

        StoreViewer.load({
            scope: this,
            params: p,
            callback: function () {
                window.open(GetWebAppRoot + "/CrmPages/Download.aspx?EFile=" + p['FileName'], '');
            }
        });
    }
    else {
        var myList = null;
        try {
            myList = CmbViewList;
        } catch (e) {
            myList = null;
        }

        if (myList == null || (myList != null && !R.isEmpty(myList.getValue()))) {
            var itemGuid = guid();
            var params = GridPanelViewer.getParameters(GridPanelViewer.dataContainer);
            params['FileName'] = itemGuid + '.xls';
            params['ExportType'] = type;
            var strLocation = GetWebAppRoot + "/Data/jsonCreater.ashx?x=1";
            R.forEach(params, function (key, value) {
                strLocation += "&" + key + "=" + value;
            });
            window.location = strLocation;
        }
        else {
            ShowMessage(ListEmptyMsg);
        }
    }
}

function SetGridElapsedTime(time) {
    ElapsedTime.setText(time);
}

function ShowMessage(message) {
    if (FrameWorkType != "RefleX") {
        window.top.Ext.Msg.show({
            title: R.ScriptErrorTitleText,
            msg: message,
            buttons: Ext.Msg.OK,
            icon: Ext.Msg.INFO,
            modal: true,
            closable: false
        });
    } else {
        window.top.R.MessageBox(R.ScriptErrorTitleText, "", message, true, R.MessageType.Warning, R.ButtonType.OK, function (btn) { }, false, 300, 150);
    }
}

function LogWindow() {
    var config = GetWebAppRoot + "/CrmPages/AutoPages/LogViewer.aspx?EntityId=" + hdnEntityId.getValue() + "&RecordId=" + hdnRecid.getValue();
    if (FrameWorkType != "RefleX") {
        window.top.newWindow(config, { title: 'LogViewer', width: 800, height: 500, resizable: false });
    }
    else {
        window.top.newWindowRefleX(config, { title: 'LogViewer', width: 800, height: 500, resizable: false });
    }
}

function LeftMenuSelect(el, index, node) {
    for (var i = 0; i < node.parentNode.childNodes.length - 1; i++) {
        if (i != index)
            node.parentNode.childNodes[i].className = "thumb-wrap";
        else
            node.parentNode.childNodes[i].className = "thumb-wrap x-view-selected";
    }

}

function ShowUserSecurityRole() {
    var config = GetWebAppRoot + "/CrmPages/Admin/Administrations/SecurityRoles/UserSecurityRoleRefleX.aspx?RecordId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'User Security Role', width: 800, height: 500, resizable: false });
}
/// <reference path="../CrmPages/AutoPages/Pages/AssignTo.aspx" />
function PassWordChance() {
    var config = GetWebAppRoot + "/CrmPages/Admin/Administrations/User/PassWord.aspx?SystemUserId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'User Passwod ', width: 400, height: 200, resizable: false });
}
function OpenMultipleLanguage() {
    var config = GetWebAppRoot + "/CrmPages/AutoPages/Pages/MultipleLanguage.aspx?ObjectId=" + hdnObjectId.getValue() + "&recid=" + hdnRecid.getValue()
    + "&framename=" + window.name
    window.top.newWindowRefleX(config, { title: 'MultipleLanguage', width: 800, height: 600, resizable: true, modal: true });
}
function ShowRolePrivileges() {
    var config = GetWebAppRoot + "/CrmPages/Admin/Administrations/SecurityRoles/RolePrivilegesReflex.aspx?RoleId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'RolePrivileges', width: 1000, height: 600, resizable: true });
}
function Assign(action) {
    var config = GetWebAppRoot + "/CrmPages/AutoPages/Pages/AssignTo.aspx?ObjectId=" + hdnObjectId.getValue() + "&RecordId=" + hdnRecid.getValue()
    + "&framename=" + window.name
    if (action != "1")
        config += "&gridpanelid=" + GridPanelViewer.id;
    if (window.parent != null)
        config += "&pframename=" + window.parent.name;
    window.top.newWindow(config, { title: 'AssignTo', width: 400, height: 200, resizable: false, modal: true });
}
function ShowWorkflow() {
    var config = GetWebAppRoot + "/CrmPages/Admin/WorkFlow/WorkFlowStepViewer.aspx?RecordId=" + hdnRecid.getValue();
    window.top.newWindow(config, { title: 'WorkFlowStepViewer', width: 800, height: 500, resizable: true, modal: true });
}
function Share() {

    var config = GetWebAppRoot + "/CrmPages/Admin/Share/Share.aspx?ObjectId=" + hdnObjectId.getValue() + "&RecordId=" + hdnRecid.getValue()
    + "&framename=" + window.name
    window.top.newWindow(config, { title: 'Share', width: 800, height: 300, resizable: false, modal: true });
}
function NewRecordCreate(ObjectId) {
    var config = GetWebAppRoot + "/CrmPages/AutoPages/Edit.aspx?objectid=" + ObjectId;
    window.top.newWindow(config, { title: 'New Record', width: 800, height: 500, resizable: false });
}

function ExportExcelStore() {
    var itemGuid = guid();
    var p = store1.lastOptions.params;
    p['FileName'] = itemGuid + '.xls';

    store1.load({
        scope: this,
        params: p,
        callback: function () {
            window.open(GetWebAppRoot + "/CrmPages/Download.aspx?EFile=" + p['FileName'], '');
        }
    });
}
function evalIframe(iframeid, command) {
    var iframe = null;
    for (i = 0; i < window.frames.length; i++) {
        if (window.frames[i].name == iframeid) {
            iframe = window.frames[i];
        }
    }
    if (iframe)
        return iframe.eval(command);
    else
        return null;
}

function CloseTab(ObjectId) {
    if (R.isEmpty(ObjectId)) {
        window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].closeTab(window.name.substring(6, window.name.length));
    }
    else {
        for (var i = 0; i < window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs.length; i++) {
            var tab = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[i];
            if (window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).hdnObjectId.getValue() == ObjectId) {
                window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].closeTab(tab.id);
            }
        }
    }
}
function CloseAllTabButThis() {
    var wn = window.name;
    for (var i = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs.length - 1; i >= 0; i--) {
        var tab = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[i];

        if ("Frame_" + tab.id != wn) {
            window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].closeTab(tab.id);
        }
    }
}
function RefreshParentTab() {
    window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame(window._tabframename).location = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame(window._tabframename).location;
}
function RefreshTab(ObjectId) {
    if (R.isEmpty(ObjectId)) {
        window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame(window.name).location = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame(window.name).location;
    }
    else {
        for (var i = 0; i < window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs.length; i++) {
            var tab = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[i];
            if (window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).hdnObjectId.getValue() == ObjectId) {
                window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).location = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).location;
            }
        }
    }
}
function SaveTab(ObjectId) {
    var e = e ? e : window.event;
    if (R.isEmpty(ObjectId)) {
        window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame(window.name).btnSave.click(e)
    }
    else {
        for (var i = 0; i < window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs.length; i++) {
            var tab = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[i];
            if (window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).hdnObjectId.getValue() == ObjectId) {
                window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).btnSave.click(e);
            }
        }
    }
}

function SaveAndCloseTab(ObjectId) {
    var e = e ? e : window.event;
    if (R.isEmpty(ObjectId))
        window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame(window.name).btnSaveAndClose.click(e);
    else {
        for (var i = 0; i < window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs.length; i++) {
            var tab = window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].tabs.tabs[i];
            if (window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).hdnObjectId.getValue() == ObjectId) {
                window.top.R.WindowMng.getActiveWindow().getIFrame().window["Tabpanel1"].getTabIFrame("Frame_" + tab.id).btnSaveAndClose.click(e);
            }
        }
    }
}
function ShowDebugger() {
    try {
        top.window["Debugger_RenderTime"].show();
    } catch (ev) { };
}
function PageRenderTime(time) {
    if (!top.window["Debugger_RenderTime"]) {
        var debug = new R.Debugger({ id: "RenderTime" });
    } else {
        top.window["Debugger_RenderTime"].show();
    }
    if (!IsNull(EditReflexName)) {
        top.window["Debugger_RenderTime"].addDebug("Client -- " + EditReflexName, time);
        top.window["Debugger_RenderTime"].addDebug("Server -- " + EditReflexName, EditReflexGenerateTime);
    }
}

function ShowSaveMessage() {
    R.clearDirty();
    ShowMessage(GetMessages("CRM_SAVE_COMPLATED"));
}
function GetMessage(x, y) {
    try {
        var m = eval("window.top.Messages." + x);
        if (IsNull(m))
            return y;

        return eval("window.top.Messages." + x);
    } catch (e) {
        return y;
    }
    return "";
}

function SpecialCloseRefreshParentGrid() {
    if (_gridpanelid != "") {
        var w = null;
        if (_tabframename != "" && _pawinid != "")
            w = window.top.frames[_pawinid].frames[_tabframename];
        if (w == null && _pawinid != "")
            w = window.top.frames[_pawinid];
        if (!IsNull(w)) {
            runScript(w, "" + _gridpanelid + ".getData();");
            runScript(w, "PagingToolBar1.reload();");
        }
    }
    if (top.R.WindowMng.getActiveWindow() != 0)
        top.R.WindowMng.getActiveWindow().hide();
}
function SpecialRefreshParentGrid() {
    if (_gridpanelid != "") {
        var w = null;
        if (_tabframename != "" && _pawinid != "")
            w = window.top.frames[_pawinid].frames[_tabframename];
        if (w == null && _pawinid != "")
            w = window.top.frames[_pawinid];
        if (!IsNull(w)) {
            runScript(w, "" + _gridpanelid + ".getData();");
            runScript(w, "PagingToolBar1.reload();");
        }
    }
}

function ShowPageInfo(x) {
    for (i = 0; i < _EntityHelp.length; i++) {
        if (_EntityHelp[i].UseScript) {
            eval(_EntityHelp[i].Command);
        } else {
            window.open(_EntityHelp[i].Command)
        }

    }
}
function GetTranslateMessage(messageName) {
    return AjaxMethods.GetTranslateMessage(messageName).value;
}

function stopRKey(evt) {

    var evt = (evt) ? evt : ((event) ? event : null);
    var node = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);

    if ((evt.keyCode == 13) && (node.type == "text")) { R.StopKeyEvent(evt); return false; }
    if (evt.keyCode == 8) {
        if (node.nodeName.toLowerCase() == "input" || node.nodeName.toLowerCase() == "textarea") {
            if (node.isDisabled || node.readOnly) {
                R.StopKeyEvent(evt); return false;
            }
        } else {
            R.StopKeyEvent(evt); return false;
        }
    }
    return true;
}
var XmlCreater = {
    str2xml: function (strXML) {
        if (window.ActiveXObject) {
            var doc = new ActiveXObject("Microsoft.XMLDOM");
            doc.async = "false";
            doc.loadXML(strXML);
        }
            // code for Mozilla, Firefox, Opera, etc. 
        else {
            var parser = new DOMParser();
            var doc = parser.parseFromString(strXML, "text/xml");
        } // documentElement always represents the root node 
        return doc;
    },
    xml2string: function (xmlDom) {
        var strs = null;
        var doc = xmlDom.documentElement;
        if (doc.xml == undefined) {
            strs = (new XMLSerializer()).serializeToString(xmlDom);
        } else strs = doc.xml;
        return strs;

    }
}






function RefreshParetnGridForCashTransaction(IsCloseCurrentFrame) {

    if (_gridpanelid != "") {
        var w = null;
        w = window.top.frames[_rlistframename];
        if (IsNull(window.top.frames[_rlistframename])) {
            if (!IsNull(window.parent)) {
                if (window.parent.name == _rlistframename) {
                    w = window.parent;

                }
                else if (!IsNull(window.parent.parent)) {
                    if (window.parent.parent.name == _rlistframename) {
                        w = window.parent.parent;
                    }
                }
            }
        }
        if (!IsNull(w)) {
            if (!R.isEmpty(_gridpanelid)) {
                runScript(w, "" + _gridpanelid + ".getData();");
            }
        }
    }
    if (IsCloseCurrentFrame) {
        if (top.R.WindowMng.getActiveWindow() != 0) {
            R.clearDirty();
            cashCurrentPage.hide();

        }
    }

}

var cashCurrentPage = null;

function LogCurrentPage() {
    cashCurrentPage = top.R.WindowMng.getActiveWindow();
}


function RefreshParetnGridForExternalAccount(IsCloseCurrentFrame) {
    if (IsCloseCurrentFrame) {
        if (top.R.WindowMng.getActiveWindow() != 0) {
            R.clearDirty();
            externalCurrentPage.hide();
            //top.hide();
        }
    }

}

var externalCurrentPage = null;
function SetCurrentPage() {
    externalCurrentPage = top.R.WindowMng.getActiveWindow();
}

if (!String.prototype.startsWith) {
    String.prototype.startsWith = function (searchString, position) {
        position = position || 0;
        return this.lastIndexOf(searchString, position) === position;
    };
}


function setCountryPhoneCode(phoneCode, sender) {

    var url = window.top.GetWebAppRoot;
    url += "/ISV/TU/Handlers/PhoneCodeHandler.ashx";

    var gsmDom = sender == 'recipientPayment' ? '_new_MobilePhone' : '_new_RecipientGSM';

    if (phoneCode) {
        selectedCountryPhoneCode = phoneCode;
    }

    $.ajax({
        url: url,
        type: 'POST',
        data: { 'method':'default','phoneCode': phoneCode },
        success: function (result) {
            if (sender == 'recipient' || sender == 'recipientPayment') {
                var recipientGsm = document.getElementById(gsmDom);
                //Alıcının ülke telefon kodu
                if (result == '' || !result) {
                    recipientGsm.disabled = false;
                    //recipientGsm.value = '';
                }
                else {
                    recipientGsm.disabled = true;
                    recipientGsm.value = result;
                }
            }

            if (sender == 'sender') {
                var senderGsm = document.getElementById("_new_GSM");

                if (!senderGsm) {
                    senderGsm = top.R.WindowMng.getActiveWindow().frame.contentWindow.document.getElementById('_new_GSM');
                }

                //Göndericinin ülke telefon kodu
                if (result == '' || !result) {
                    senderGsm.disabled = false;
                    //senderGsm.value = '';
                }
                else {
                    senderGsm.disabled = true;
                    senderGsm.value = result;
                }
                
            }
        },
        error: function () {
            
        }
    });
}
