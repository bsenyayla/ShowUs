<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_CalendarMath_Match" Codebehind="Match.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        #loading-mask
        {
            position: absolute;
            top: 0;
            left: 0;
            width: 99%;
            height: 99%;
            z-index: 70000;
            background: #5a6d81;
            border: 1px solid #99BBE8;
            font-family: tahoma,arial,verdana,sans-serif;
            font-size: 11px;
            font-weight: bold;
        }
        #loading
        {
            position: absolute;
            top: 40%;
            left: 45%;
            z-index: 70001;
        }
        #loading SPAN
        {
            color: white;
            font-family: Arial;
            font-size: small;
            background: url('<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/loading.gif') no-repeat left center;
            padding: 5px 30px;
            display: block;
        }
        .trgclear
        {
            margin: 1px -1px 0 !important;
        }
        .trgclear span
        {
            cursor: pointer;
            background: url("<%=GlobalConfig.Settings.ResourcePath%>/Themes/Slate/Images/clear-trigger.gif");
            background-repeat: no-repeat;
            background-color: transparent;
            background-position: 0px -1px;
            border: 0 none;
            height: 17px !important;
            margin: 0 !important;
            padding: 0 !important;
            top: 1px !important;
            width: 16px !important;
            z-index: 2;
            border: 0 solid #B5B8C8;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div runat="server" id="ScriptIframe">
    </div>
    <div id="loading-mask">
        <div id="loading">
            <span id="loading-message">Yükleniyor. Lütfen Bekleyiniz...</span>
        </div>
    </div>
    <ajx:RegisterResources runat="server" ID="RR"/>
    <div style="display: none">
        <ajx:Hidden runat="server" ID="hdnObjectId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnEntityName">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnEntityId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnRecid">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnRecidName">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnDefaultEditPageId">
        </ajx:Hidden>
        <ajx:Hidden runat="server" ID="hdnSavingMessage">
        </ajx:Hidden>
        <ajx:Hidden ID="UpdatedUrl" runat="server">
        </ajx:Hidden>
    </div>
    <ajx:KeyMap runat="server" ID="KeyMap1">
        <ajx:KeyBinding StopEvent="true">
            <Keys>
                <ajx:Key Code="ESC">
                    <Listeners>
                        <Event Handler="" />
                    </Listeners>
                </ajx:Key>
            </Keys>
        </ajx:KeyBinding>
    </ajx:KeyMap>
    <ajx:ToolBar runat="server" ID="EditToolbar">
        <Items>
            <ajx:ToolbarButton runat="server" ID="btnMlValues" Width="0" Text="OpenMultipleLanguage"
                Icon="FlagTr">
                <Listeners>
                    <Click Handler="OpenMultipleLanguage()" />
                </Listeners>
            </ajx:ToolbarButton>

            <ajx:ToolbarButton runat="server" ID="btnSave" Width="70" Text="Save" Icon="Disk">
                <AjaxEvents>
                    <Click OnEvent="BtnSaveClick">
                        <EventMask ShowMask="true" />
                        <ExtraParams>
                            <ajx:Parameter Name="Action" Value="1"></ajx:Parameter>
                        </ExtraParams>
                    </Click>
                </AjaxEvents>
            </ajx:ToolbarButton>
            <ajx:ToolbarButton runat="server" ID="btnSaveAndNew" Width="120" Text="Save And New"
                Icon="DiskMultiple">
                <AjaxEvents>
                    <Click OnEvent="BtnSaveClick">
                        <EventMask ShowMask="true" />
                        <ExtraParams>
                            <ajx:Parameter Name="Action" Value="2"></ajx:Parameter>
                        </ExtraParams>
                    </Click>
                </AjaxEvents>
            </ajx:ToolbarButton>
            <ajx:ToolbarButton runat="server" ID="btnSaveAndClose" Width="120" Text="Save And Close"
                Icon="DiskBlack">
                <AjaxEvents>
                    <Click OnEvent="BtnSaveClick">
                        <EventMask ShowMask="true" />
                        <ExtraParams>
                            <ajx:Parameter Name="Action" Value="3"></ajx:Parameter>
                        </ExtraParams>
                    </Click>
                </AjaxEvents>
            </ajx:ToolbarButton>
            <ajx:ToolbarButton runat="server" ID="btnDelete" Width="100" Text="Delete" Icon="Delete">
                <Listeners>
                    <Click Handler="BtnDelete_Click()" />
                </Listeners>
            </ajx:ToolbarButton>
            <ajx:Menu ID="ReportMenu" runat="server">
                <Items>
                </Items>
            </ajx:Menu>
            <ajx:Menu ID="ActionMenu" runat="server">
                <Items>
                </Items>
            </ajx:Menu>
            <ajx:ToolbarFill runat="server" ID="ToolbarFill1">
            </ajx:ToolbarFill>
            <ajx:ToolbarButton runat="server" ID="btnReport" minwidth="70" Icon="ArrowDown" Text="Report"
                MenuId="ReportMenu">
            </ajx:ToolbarButton>
            <ajx:ToolbarButton runat="server" ID="btnAction" minwidth="70" Icon="ArrowDown" Text="Action"
                MenuId="ActionMenu">
            </ajx:ToolbarButton>
            <ajx:ToolbarButton runat="server" Icon="ArrowRefresh" Width="100" ID="btnRefresh"
                Text="Refresh">
                <Listeners>
                    <Click Handler="location.reload(true);" />
                </Listeners>
            </ajx:ToolbarButton>
        </Items>
    </ajx:ToolBar>
    <div runat="server" id="pnlError">
        <div style="background: #FFFF99;">
            <ajx:Label runat="server" Text="" ID="lblError" Icon="Error" Width="200">
            </ajx:Label>
        </div>
    </div>
    <ajx:PanelX runat="server" ID="PnlMain" Frame="false" Border="false" AutoHeight="Full"
        AutoWidth="true">
        <Body>
            <ajx:ColumnLayout runat="server" ColumnLayoutLabelWidth="28" ID="Cl1" ColumnWidth="80%">
                <Rows>
                    <ajx:RowLayout runat="server" ID="RowLayout8">
                        <Body>
                            <ajx:TextField runat="server" AutoWidth="true" ID="CalendarMatchnameTxt" FieldLabel="LBLCALENDARMATCHNAME"
                                RequirementLevel="BusinessRequired">
                            </ajx:TextField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="Rl1">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLENTITY" ID="EntityComboField"
                                Mode="Local" RequirementLevel="BusinessRequired">
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    
                    <ajx:RowLayout runat="server" ID="Rl2">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLVIEW" ID="ViewComboField"
                                ValueField="ViewQueryId" DisplayField="Name" Mode="Remote" RequirementLevel="BusinessRequired">
                                <DataContainer>
                                    <DataSource OnEvent="ViewComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="ViewQueryId" Hidden="true" />
                                            <ajx:Column Name="Name" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>

                    <ajx:RowLayout runat="server" ID="RowLayout1">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLRESOURCE" ID="ResourceComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="ResourceComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="RowLayout2">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLSTARTDATE" ID="StartDateComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="StartDateComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="RowLayout3">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLENDDATE" ID="EndDateComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="EndDateComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="RowLayout4">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLALLDAY" ID="AllDayComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="AllDayComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="RowLayout5">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLHEADERTEXT" ID="HeaderTextComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="HeaderTextComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="RowLayout6">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLDETAILTEXT" ID="DetailTextComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="DetailTextComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                    <ajx:RowLayout runat="server" ID="RowLayout7">
                        <Body>
                            <ajx:ComboField runat="server" AutoWidth="true" FieldLabel="LBLCALENDERTYPE" ID="CalenderTypeComboField"
                                ValueField="AttributeId" DisplayField="Label" Mode="Remote">
                                <DataContainer>
                                    <DataSource OnEvent="CalenderTypeComboFieldLoad">
                                        <Columns>
                                            <ajx:Column Name="AttributeId" Hidden="true" />
                                            <ajx:Column Name="Label" />
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
        </Body>
    </ajx:PanelX>
    </form>
</body>
<script language="javascript" type="text/javascript">
    function OpenServerSideWindow(e, u, type) {
        var _a = eval(e);
        var _ret = eval(u).getValue();
        var _type = eval(type).getValue();
        if (_type == "0") {
            window.open(_ret);
        }
        else if (_type == "1") {

            window.top.newWindowRefleX(GetWebAppRoot + _ret
            , { maximized: false, width: 500, height: 300, resizable: false, modal: true, maximizable: false });
        }
        else if (_type == "2") {

            window.top.newWindowRefleX(GetWebAppRoot + _ret
            , { maximized: false, width: 800, height: 400, resizable: false, modal: true, maximizable: false });
        }
    }
    function BtnDelete_Click() {
        Myform = window;
        window.top.GlobalDelete(Myform, null, hdnObjectId.getValue())
    }    
</script>
</html>
