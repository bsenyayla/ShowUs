<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Administrations_SecurityRoles_RolePrivileges" Codebehind="RolePrivileges.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .sLabel
        {
            color: white;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ext:Hidden runat="server" ID="hdnRoleId">
    </ext:Hidden>
    <ext:Store ID="store2" runat="server" OnRefreshData="Store2OnRefreshData" RemoteSort="true"
        AutoLoad="false">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="EntityName">
                <Fields>
                    <ext:RecordField Name="EntityName" Type="String" />
                    <ext:RecordField Name="ShowMenuPrivilegeId" Type="String" />
                    <ext:RecordField Name="ReadPrivilegeId" Type="String" />
                    <ext:RecordField Name="WritePrivilegeId" Type="String" />
                    <ext:RecordField Name="AppendPrivilegeId" Type="String" />
                    <ext:RecordField Name="AppendToPrivilegeId" Type="String" />
                    <ext:RecordField Name="CreatePrivilegeId" Type="String" />
                    <ext:RecordField Name="DeletePrivilegeId" Type="String" />
                    <ext:RecordField Name="SharePrivilegeId" Type="String" />
                    <ext:RecordField Name="AssignPrivilegeId" Type="String" />
                    
                    <ext:RecordField Name="ShowMenuPrivilegeValue" Type="String" />
                    <ext:RecordField Name="ReadPrivilegeValue" Type="String" />
                    <ext:RecordField Name="WritePrivilegeValue" Type="String" />
                    <ext:RecordField Name="AppendPrivilegeValue" Type="String" />
                    <ext:RecordField Name="AppendToPrivilegeValue" Type="String" />
                    <ext:RecordField Name="CreatePrivilegeValue" Type="String" />
                    <ext:RecordField Name="DeletePrivilegeValue" Type="String" />
                    <ext:RecordField Name="SharePrivilegeValue" Type="String" />
                    <ext:RecordField Name="AssignPrivilegeValue" Type="String" />
                    
                    
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="EntityName" Direction="ASC" />
    </ext:Store>
    <ext:Panel runat="server" ID="Panel2" Frame="false" Border="false" LabelSeparator=""
        AutoScroll="true">
        <Body>
            <ext:FitLayout ID="FitLayout2" runat="server">
                <ext:GridPanel ID="rolelist" runat="server" AutoWidth="true" StripeRows="true" StoreID="store2"
                    ClicksToEdit="1" Height="520">
                    <ColumnModel ID="ColumnModel1" runat="server">
                        <Columns>
                            <ext:Column Header="ShowMenu" DataIndex="ShowMenuPrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Read" DataIndex="ReadPrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Write" DataIndex="WritePrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Append" DataIndex="AppendPrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="AppendTo" DataIndex="AppendToPrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Create" DataIndex="CreatePrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Delete" DataIndex="DeletePrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Share" DataIndex="SharePrivilegeId" Width="50" Hidden="true" />
                            <ext:Column Header="Assign" DataIndex="AssignPrivilegeId" Width="50" Hidden="true" />
                            
                            <ext:Column Header="Entity" DataIndex="EntityName" Width="200" />

                            <ext:Column Header="Menu" DataIndex="ShowMenuPrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            
                            <ext:Column Header="Read" DataIndex="ReadPrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="Write" DataIndex="WritePrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="Append" DataIndex="AppendPrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="AppendTo" DataIndex="AppendToPrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="Create" DataIndex="CreatePrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="Delete" DataIndex="DeletePrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="Share" DataIndex="SharePrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                            <ext:Column Header="Assign" DataIndex="AssignPrivilegeValue" Width="70"
                                Align="Center">
                                <Renderer Fn="ptype" />
                            </ext:Column>
                        </Columns>
                    </ColumnModel>
                    <LoadMask ShowMask="true" />
                    <Listeners>
                        <CellClick Fn="cellClick" />
                    </Listeners>
                </ext:GridPanel>
            </ext:FitLayout>
        </Body>
        <TopBar>
            <ext:Toolbar ID="Toolbar1" runat="server">
                <Items>
                    <ext:ToolbarButton runat="server" ID="Save" Icon="PageSave" Text="Değişiklikleri Kaydet">
                        <AjaxEvents>
                            <Click OnEvent="SubmitGrids">
                                <ExtraParams>
                                    <ext:Parameter Name="Values" Value="Ext.encode(#{rolelist}.getRowsValues(false))"
                                        Mode="Raw" />
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
        <BottomBar>
            <ext:Toolbar runat="server">
                <Items>
                    <ext:Image runat="server" ImageUrl="../../../../images/ico_18_role_x.gif">
                    </ext:Image>
                    <ext:Label runat="server" Text="None Selected" Cls="sLabel">
                    </ext:Label>
                    <ext:ToolbarSpacer Width="20" />
                    <ext:Image ID="Image1" runat="server" ImageUrl="../../../../images/ico_18_role_b.gif">
                    </ext:Image>
                    <ext:Label ID="Label1" runat="server" Text="User" Cls="sLabel">
                    </ext:Label>
                    <ext:ToolbarSpacer Width="20" />
                    <ext:Image ID="Image2" runat="server" ImageUrl="../../../../images/ico_18_role_l.gif">
                    </ext:Image>
                    <ext:Label ID="Label2" runat="server" Text="Bussiness Unit" Cls="sLabel">
                    </ext:Label>
                    <ext:ToolbarSpacer Width="20" />
                    <ext:Image ID="Image3" runat="server" ImageUrl="../../../../images/ico_18_role_d.gif">
                    </ext:Image>
                    <ext:Label ID="Label3" runat="server" Text="Parent:Child Bussiness Unit" Cls="sLabel">
                    </ext:Label>
                    <ext:ToolbarSpacer Width="20" />
                    <ext:Image ID="Image4" runat="server" ImageUrl="../../../../images/ico_18_role_g.gif">
                    </ext:Image>
                    <ext:Label ID="Label4" runat="server" Text="Organization" Cls="sLabel">
                    </ext:Label>
                </Items>
            </ext:Toolbar>
        </BottomBar>
    </ext:Panel>
    <script language="javascript" >
        var ptype = function (v, r, a, b, c, d) {
            
            if (c == 10 && v == "1") {
                return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_g.gif" />';
            }
            if (v == "0")
                return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_x.gif" />';
            if (v == "1")
                return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_b.gif" />';
            if (v == "2")
                return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_l.gif" />';
            if (v == "4")
                return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_d.gif" />';
            if (v == "8")
                return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_g.gif" />';
            return '<img id="img' + c + b + '" class="imgEdit"  style="cursor:pointer;" src="../../../../images/ico_18_role_x.gif" />';
        }
        var cellClick = function (grid, rowIndex, columnIndex, e) {
            //fds;
            var t = e.getTarget();
            var record = grid.getStore().getAt(rowIndex);  // Get the Record
            var columnId = grid.getColumnModel().getColumnId(columnIndex); // Get column id
            //fds;
            if (columnIndex == 9) {
                for (var i = 0; i < 9; i++) {
                    if (record.fields.items[10 + i].name == "ShowMenuPrivilegeValue") {
                        var v = record.data[record.fields.items[10 + i].name];
                        if (v == "")
                            v = "0";
                        if (v == "0") {
                            record.data[record.fields.items[10 + i].name] = "1";
                            document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_g.gif";
                        }
                        if (v == "1") {
                            record.data[record.fields.items[10 + i].name] = "0";
                            document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_x.gif";
                        }
                        continue;
                    }
                    var v = record.data[record.fields.items[10 + i].name];
                    if (v == "")
                        v = "0";
                    if (v == "0") {
                        record.data[record.fields.items[10 + i].name] = "1";
                        document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_b.gif";
                    }
                    if (v == "1") {
                        record.data[record.fields.items[10 + i].name] = "2";
                        document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_l.gif";
                    }
                    if (v == "2") {
                        record.data[record.fields.items[10 + i].name] = "4";
                        document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_d.gif";
                    }
                    if (v == "4") {
                        record.data[record.fields.items[10 + i].name] = "8";
                        document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_g.gif";
                    }
                    if (v == "8") {
                        record.data[record.fields.items[10 + i].name] = "0";
                        document.getElementById("img" + (i + (columnIndex + 1)).toString() + rowIndex).src = "../../../../images/ico_18_role_x.gif";
                    }
                }
            }
            if (t.className == 'imgEdit') {
                if (record.fields.items[columnIndex].name == "ShowMenuPrivilegeValue") {
                    var v = record.data[record.fields.items[columnIndex].name];
                    if (v == "")
                        v = "0";
                    if (v == "0") {
                        record.data[record.fields.items[columnIndex].name] = "1";
                        t.src= "../../../../images/ico_18_role_g.gif";
                    }
                    if (v == "1") {
                        record.data[record.fields.items[columnIndex].name] = "0";
                        t.src = "../../../../images/ico_18_role_x.gif";
                    }
                    return;
                }

                var v = record.data[record.fields.items[columnIndex].name];
                if (v == "")
                    v = "0";
                if (v == "0") {
                    record.data[record.fields.items[columnIndex].name] = "1";
                    t.src = "../../../../images/ico_18_role_b.gif";
                }
                if (v == "1") {
                    record.data[record.fields.items[columnIndex].name] = "2";
                    t.src = "../../../../images/ico_18_role_l.gif";
                }
                if (v == "2") {
                    record.data[record.fields.items[columnIndex].name] = "4";
                    t.src = "../../../../images/ico_18_role_d.gif";
                }
                if (v == "4") {
                    record.data[record.fields.items[columnIndex].name] = "8";
                    t.src = "../../../../images/ico_18_role_g.gif";
                }
                if (v == "8") {
                    record.data[record.fields.items[columnIndex].name] = "0";
                    t.src = "../../../../images/ico_18_role_x.gif";
                }
            }
        }
    </script>
    </form>
</body>
</html>
