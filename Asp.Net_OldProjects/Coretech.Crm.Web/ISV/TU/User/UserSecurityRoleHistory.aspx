<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserSecurityRoleHistory.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.User.UserSecurityRoleHistory" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function checkDelete() {
            var ret = confirm('Seçili döküman silinecek, Emin misiniz?');
            return ret;
        }

        function checkDeleteAll() {
            var ret = confirm('Tüm dökümanlar silinecek, Emin misiniz?');
            return ret;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnObjectId" runat="server"></rx:Hidden>
            <rx:GridPanel runat="server" ID="GridPanelConfirmHistory" AutoWidth="true" AutoHeight="Auto" AutoScroll="true"
                Height="500" AutoLoad="true" Width="1200" Mode="Remote" AjaxPostable="true">
                <DataContainer>
                    <DataSource OnEvent="UserSecurityRoleHistoryEvent">
                    </DataSource>
                    <Sorts>
                        <rx:DataSorts Name="CreatedOnUtcTime" Direction="Desc" />
                    </Sorts>
                </DataContainer>  
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="RoleLogHistoryId" Width="100" Header="ID" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="RoleLogHistoryId" />

                        <rx:GridColumns ColumnId="RoleId" Width="100" Header="RoleId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="RoleId" />
                        
                        <rx:GridColumns ColumnId="OldRoleId" Width="100" Header="OldRoleId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="OldRoleId" />

                        <rx:GridColumns ColumnId="CreatedOnUtcTime" Width="140" Header="İşlem Tarihi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CreatedOnUtcTime" />
                        
                        <rx:GridColumns ColumnId="CreateFullName" Width="140" Header="İşlem Yapan Kullanıcı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="CreateFullName" />

                        <rx:GridColumns ColumnId="ApprovedFullName" Width="140" Header="Onaylayan Kullanıcı" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="ApprovedFullName" />

                        <rx:GridColumns ColumnId="RoleTransaction" Width="150" Header="Işlem Tipi" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="RoleTransaction" />

                        <rx:GridColumns ColumnId="RoleName" Width="250" Header="Rol" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="RoleName" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:RowSelectionModel ID="gpSenderDocumentRowSelectionModel" runat="server" ShowNumber="true"
                        SingleSelect="true">
 
                    </rx:RowSelectionModel>
 
                </SelectionModel>
                <LoadMask ShowMask="true" />
            </rx:GridPanel>
        </div>
    </form>
</body>
</html>
