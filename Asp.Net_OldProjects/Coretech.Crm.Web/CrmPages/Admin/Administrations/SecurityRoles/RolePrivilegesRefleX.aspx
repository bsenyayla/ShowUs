<%@ Page Language="C#" AutoEventWireup="true"
    Inherits="CrmPages_Admin_Administrations_SecurityRoles_RolePrivilegesRefleX" Codebehind="RolePrivilegesRefleX.aspx.cs" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="CrmUI" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="ajx" %>
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
    <ajx:RegisterResources runat="server" ID="RR" />
    <ajx:Hidden runat="server" ID="hdnRoleId" />
    <ajx:GridPanel ID="rolelist" runat="server" AutoHeight="Auto" AutoWidth="true" PostAllData="true"
        Mode="Remote">
        <TopBar>
            <ajx:ToolBar ID="Toolbar1" runat="server">
                <Items>
                    <ajx:ToolbarButton runat="server" ID="Save" Icon="PageSave" Text="Değişiklikleri Kaydet">
                        <AjaxEvents>
                            <Click OnEvent="SubmitGrids">
                            </Click>
                        </AjaxEvents>
                    </ajx:ToolbarButton>
                    <ajx:ToolbarFill runat="server" ID="tbf1"/>
                    <ajx:ToolbarButton runat="server" ID="ImportFromRole" Icon="DatabaseAdd" Text="Yetkileri Başka rolden al">
                        <Listeners>
                            <Click Handler="WindowImport.show();" />
                        </Listeners>
                    </ajx:ToolbarButton>
                </Items>
            </ajx:ToolBar>
        </TopBar>
        <SelectionModel>
            <ajx:CellSelectionModel ID="CellSelectionModel1" runat="server">
                <Listeners>
                    <CellClick Handler="cellClick(el, record, row, col, e, dataIndex);" />
                </Listeners>
            </ajx:CellSelectionModel>
        </SelectionModel>
        <DataContainer>
            <DataSource OnEvent="Store2OnRefreshData">
                <Columns>
                    <ajx:Column Name="EntityName" />
                    <ajx:Column Name="ShowMenuPrivilegeId" />
                    <ajx:Column Name="ReadPrivilegeId" />
                    <ajx:Column Name="WritePrivilegeId" />
                    <ajx:Column Name="AppendPrivilegeId" />
                    <ajx:Column Name="AppendToPrivilegeId" />
                    <ajx:Column Name="CreatePrivilegeId" />
                    <ajx:Column Name="DeletePrivilegeId" />
                    <ajx:Column Name="SharePrivilegeId" />
                    <ajx:Column Name="AssignPrivilegeId" />
                    <ajx:Column Name="MultiLanguagePrivilegeId" />
                    <ajx:Column Name="ApprovalPrivilegeId"/>
                    <ajx:Column Name="SetActivePassivePrivilegeId"/>
                    <ajx:Column Name="ShowMenuPrivilegeValue" />
                    <ajx:Column Name="ReadPrivilegeValue" />
                    <ajx:Column Name="WritePrivilegeValue" />
                    <ajx:Column Name="AppendPrivilegeValue" />
                    <ajx:Column Name="AppendToPrivilegeValue" />
                    <ajx:Column Name="CreatePrivilegeValue" />
                    <ajx:Column Name="DeletePrivilegeValue" />
                    <ajx:Column Name="SharePrivilegeValue" />
                    <ajx:Column Name="AssignPrivilegeValue" />
                    <ajx:Column Name="MultiLanguagePrivilegeValue" />
                    <ajx:Column Name="ApprovalPrivilegeValue"/>
                    <ajx:Column Name="SetActivePassivePrivilegeValue"/>
                    <ajx:Column Name="IsMasterBusinessUnit" />
                    <ajx:Column Name="BusinessUnitId" />
                    <ajx:Column Name="BusinessUnitIdName" />
                </Columns>
            </DataSource>
        </DataContainer>
        <ColumnModel>
            <Columns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Entity" DataIndex="EntityName" Width="200" >
                    

                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Menu" DataIndex="ShowMenuPrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Read" DataIndex="ReadPrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Write" DataIndex="WritePrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Append" DataIndex="AppendPrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="AppendTo" DataIndex="AppendToPrivilegeValue" Width="60"
                    Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Create" DataIndex="CreatePrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Delete" DataIndex="DeletePrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Share" DataIndex="SharePrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Assign" DataIndex="AssignPrivilegeValue" Width="60" Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="MultiLanguage" DataIndex="MultiLanguagePrivilegeValue" Width="60"
                    Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Approval" DataIndex="ApprovalPrivilegeValue" Width="60"
                    Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="ActivePassive" DataIndex="SetActivePassivePrivilegeValue" Width="60"
                    Align="Center">
                    <Renderer Handler="return ptype(record, row, col, td, rowDiv, dataIndex);" />
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Master Bu" DataIndex="IsMasterBusinessUnit" Width="60" Align="Center"
                    ColumnType="Check">
                </ajx:GridColumns>
                <ajx:GridColumns  MenuDisabled="true" Sortable="false"  Header="Bu" DataIndex="BusinessUnitIdName" Width="100" Align="Center">
                    <Editor DisplayDataIndex="BusinessUnitIdName" ValueDataIndex="BusinessUnitId">
                        <Component>
                            <ajx:ComboField runat="server" ID="ComboFieldBu" AutoLoad="true" Mode="Remote" DisplayField="Name"
                                ValueField="BusinessUnitId">
                                <DataContainer>
                                    <DataSource OnEvent="ComboFieldBuOnRefreshData">
                                        <Columns>
                                            <ajx:Column Name="BusinessUnitId" Hidden="true">
                                            </ajx:Column>
                                            <ajx:Column Name="Name">
                                            </ajx:Column>
                                        </Columns>
                                    </DataSource>
                                </DataContainer>
                            </ajx:ComboField>
                        </Component>
                    </Editor>
                </ajx:GridColumns>
            </Columns>
        </ColumnModel>
        <LoadMask ShowMask="true" />
        <BottomBar>
            <ajx:ToolBar ID="Toolbar2" runat="server">
                <Items>
                    <ajx:Label ID="Label1" runat="server" Text="None Selected" CustomCss="sLabel" Width="120"
                        ImageUrl="../../../../images/ico_18_role_x.gif">
                    </ajx:Label>
                    <ajx:Label ID="Label2" runat="server" Text="User" CustomCss="sLabel" Width="80" ImageUrl="../../../../images/ico_18_role_b.gif">
                    </ajx:Label>
                    <ajx:Label ID="Label3" runat="server" Text="Bussiness Unit" CustomCss="sLabel" Width="120"
                        ImageUrl="../../../../images/ico_18_role_l.gif">
                    </ajx:Label>
                    <ajx:Label ID="Label4" runat="server" Text="Parent:Child Bussiness Unit" CustomCss="sLabel"
                        Width="180" ImageUrl="../../../../images/ico_18_role_d.gif">
                    </ajx:Label>
                    <ajx:Label ID="Label5" runat="server" Text="Organization" CustomCss="sLabel" Width="120"
                        ImageUrl="../../../../images/ico_18_role_g.gif">
                    </ajx:Label>
                </Items>
            </ajx:ToolBar>
        </BottomBar>
    </ajx:GridPanel>
    <ajx:Window runat="server" ID="WindowImport" Title="Import From Role" Height="200"
        Border="false" Resizable="false" CloseAction="Hide" Width="400" Modal="true"
        Icon="Plugin" ShowOnLoad="false" Maximizable="false">
        <Body>
            <ajx:ColumnLayout runat="server" ID="ColumnLayout14" ColumnWidth="100%" ColumnLayoutLabelWidth="50">
                <Rows>
                    <ajx:RowLayout ID="RowLayout16" runat="server">
                        <Body>
                            <CrmUI:CrmComboComp ID="RoleCrmLookupComp" ObjectId="35" UniqueName="RoleId" runat="server">
                            </CrmUI:CrmComboComp>
                        </Body>
                    </ajx:RowLayout>
                </Rows>
            </ajx:ColumnLayout>
        </Body>
        <Buttons>
            <ajx:Button ID="BtnWindowImport" runat="Server" Text="Rol Yetkilendirmelerini Kopyala"
                Icon="DatabaseAdd">
                <AjaxEvents>
                    <Click OnEvent="BtnWindowImportClickOnEvent" Before="return confirm('Bu Rolü Kopyalamak istediğinizden Emin mi siniz ? Üzerinde bulunduğunuz rolün tüm yetkileri silinip seçili rol üzerindeki yetkiler kopyalanacaktır.');">
                    </Click>
                </AjaxEvents>
            </ajx:Button>
        </Buttons>
    </ajx:Window>
    </form>
    <script language="javascript">
        var ptype = function (record, row, col, td, rowDiv, dataIndex) {
            var c = col;
            var v = record.data[dataIndex];
            var b = row + "_" + rolelist.id;
            if ((c == 1||c==11) && v == "1") {
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
        var cellClick = function (el, record, row, col, e, dataIndex) {
            var t = R.isEmpty(e.srcElement) ? e.target : e.srcElement;
            if (t.className != "imgEdit") {
                t = t.getElementsByTagName("img")[0];
            }
            if (col == 0) {
                for (var i = 0; i < 12; i++) {
                    dataIndex = rolelist.columnModel.Columns[i + 1].DataIndex;

                    if (dataIndex == "ShowMenuPrivilegeValue" ) {
                        var v = record[dataIndex];
                        if (R.isEmpty(v))
                            v = "0";
                        if (v == "0") {
                            record[dataIndex] = "1";
                            document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_g.gif";
                        }
                        if (v != "0") {
                            record[dataIndex] = "0";
                            document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_x.gif";
                        }
                        continue;
                    }
                    if (dataIndex == "ApprovalPrivilegeValue") {
                        var v = record[dataIndex];
                        if (R.isEmpty(v))
                            v = "0";
                        if (v == "0") {
                            record[dataIndex] = "8";
                            document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_g.gif";
                        }
                        if (v != "0") {
                            record[dataIndex] = "0";
                            document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_x.gif";
                        }
                        continue;
                    }
                    var v = record[dataIndex];
                    if (R.isEmpty(v))
                        v = "0";
                    if (v == "0") {
                        record[dataIndex] = "1";
                        document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_b.gif";
                    }
                    if (v == "1") {
                        record[dataIndex] = "2";
                        document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_l.gif";
                    }
                    if (v == "2") {
                        record[dataIndex] = "4";
                        document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_d.gif";
                    }
                    if (v == "4") {
                        record[dataIndex] = "8";
                        document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_g.gif";
                    }
                    if (v == "8") {
                        record[dataIndex] = "0";
                        document.getElementById("img" + (i + 1) + row + "_" + rolelist.id).src = "../../../../images/ico_18_role_x.gif";
                    }
                }
                return;
            }
            if (!t)
                return;

            if (t.className == 'imgEdit') {

                if (dataIndex == "ShowMenuPrivilegeValue" ) {
                    var v = record[dataIndex];
                    
                    if (R.isEmpty(v))
                        v = "0";
                    if (v >= "0") {
                        record[dataIndex] = "1";
                        t.src = "../../../../images/ico_18_role_g.gif";
                    }
                    if (v == "1") {
                        record[dataIndex] = "0";
                        t.src = "../../../../images/ico_18_role_x.gif";
                    }
                    return;
                }
                if (dataIndex == "ApprovalPrivilegeValue") {
                    var v = record[dataIndex];

                    if (R.isEmpty(v))
                        v = "0";
                    if (v >= "0") {
                        record[dataIndex] = "8";
                        t.src = "../../../../images/ico_18_role_g.gif";
                    }
                    if (v == "8") {
                        record[dataIndex] = "0";
                        t.src = "../../../../images/ico_18_role_x.gif";
                    }
                    return;
                }
                var v = record[dataIndex];
                if (R.isEmpty(v))
                    v = "0";
                if (v == "0") {
                    record[dataIndex] = "1";
                    t.src = "../../../../images/ico_18_role_b.gif";
                }
                if (v == "1") {
                    record[dataIndex] = "2";
                    t.src = "../../../../images/ico_18_role_l.gif";
                }
                if (v == "2") {
                    record[dataIndex] = "4";
                    t.src = "../../../../images/ico_18_role_d.gif";
                }
                if (v == "4") {
                    record[dataIndex] = "8";
                    t.src = "../../../../images/ico_18_role_g.gif";
                }
                if (v == "8") {
                    record[dataIndex] = "0";
                    t.src = "../../../../images/ico_18_role_x.gif";
                }
            }
        }
    </script>
</body>
</html>
