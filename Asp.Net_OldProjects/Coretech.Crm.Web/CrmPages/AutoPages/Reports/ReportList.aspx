<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_AutoPages_Reports_ReportList" Codebehind="ReportList.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR" />
    <rx:GridPanel ID="GridPanel1" Editable="false" runat="server"  
        Mode="Remote" AutoWidth="true" AutoHeight="Auto" AutoLoad="true" Width="800"
        AjaxPostable="true">
        <DataContainer>
            <DataSource OnEvent="Store1_Refresh">
                <Columns>
                    <rx:Column Name="ReportName">
                    </rx:Column>
                    <rx:Column Name="Description">
                    </rx:Column>
                    <rx:Column Name="ReportsId">
                    </rx:Column>
                    <rx:Column Name="Entity">
                    </rx:Column>
                    <rx:Column Name="EntityName">
                    </rx:Column>
                    <rx:Column Name="ReportType">
                    </rx:Column>
                    <rx:Column Name="ReportTypeName">
                    </rx:Column>
                </Columns>
            </DataSource>
            <Groups>
                <rx:Groups Name="ReportTypeName" StartCollapsed="false" HideGroupedColumn="false" GroupTextTpl="{ReportTypeName}" />
            </Groups>
        </DataContainer>
          
        <ColumnModel>
            <Columns>
                <rx:GridColumns Header="ReportName" DataIndex="ReportName" MenuDisabled="true" Width="300"
                    Hidden="false" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="Description" DataIndex="Description" MenuDisabled="true" Width="400"
                    Hidden="false" Sortable="false">
                </rx:GridColumns>
                <rx:GridColumns Header="EntityName" DataIndex="EntityName" MenuDisabled="true" Width="200"
                    Hidden="false" Sortable="false">
                </rx:GridColumns>
                
            </Columns>
        </ColumnModel>
        <SelectionModel>
            <rx:RowSelectionModel ID="RowSelectionModel1" runat="server">
                <Listeners>
                    <RowDblClick Handler="ShowWindow(this,1);" />
                </Listeners>
            </rx:RowSelectionModel>
        </SelectionModel>
        
        <LoadMask ShowMask="true" Msg="Loading Data..." />
    </rx:GridPanel>
    </form>
</body>
</html>
<script type="text/javascript" language="javascript">
    function ShowWindow(sender, arg) {
      
        var config = GetWebAppRoot + "/CrmPages/AutoPages/Reports/ReportViewer.aspx?gd=";
        var itemGuid = guid();
        config += itemGuid;
        if (arg == 0) {
            config = config + "&ReportsId=";
        }
        else {

            config = config + "&ReportsId=" + GridPanel1.selectedRecord.ReportsId;
        }
        
        window.top.newWindowRefleX(config, { title: 'Report Viewer :' + GridPanel1.selectedRecord.ReportName, width: 800, height: 600, resizable: true });
    }
</script>
