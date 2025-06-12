<%@ Control Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Approval_ApprovalEditReflex" Codebehind="ApprovalEditReflex.ascx.cs" %>
<%@ Register TagPrefix="rx1" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>

<script type="text/javascript">
    function AttributeListInsert() {
        AttributeList.insertRow();
    }
    function AttributeListDelete() {
        if (!R.isEmpty(AttributeList.selectedRecord.length > 0)) {
            AttributeList.deleteRow();
        }
    }
</script>
<rx1:Menu ID="Menu1" runat="server">
    <Items>
        <rx1:MenuItem ID="MenuItem1" runat="server" Text="Ekle" Icon="Add">
            <Listeners>
                <Click Handler="AttributeListInsert();" />
            </Listeners>
        </rx1:MenuItem>
        <rx1:MenuItem ID="MenuItem2" runat="server" Text="Sil" Icon="Delete">
            <Listeners>
                <Click Handler="AttributeListDelete();" />
            </Listeners>
        </rx1:MenuItem>
    </Items>
</rx1:Menu>
<rx1:GridPanel ID="AttributeList" runat="server" Width="200" Height="200" Mode="Local"
    PostAllData="true" ContextMenuId="Menu1" Editable="true" DisableSelection="true"
    AutoLoad="true">

    <DataContainer>
        <DataSource>
            <Columns>

                <rx1:Column Name="TargetAtrributeId">
                </rx1:Column>
                <rx1:Column Name="TargetAtrributeIdName">
                </rx1:Column>

            </Columns>
        </DataSource>
    </DataContainer>
    <ColumnModel>
        <Columns>
            <rx1:GridColumns Header="Alan adı" DataIndex="TargetAtrributeIdName"
                MenuDisabled="true" Width="300" Hidden="false" Sortable="false">
                <Editor DisplayDataIndex="TargetAtrributeIdName" ValueDataIndex="TargetAtrributeId">
                    <Component>
                        <rx1:ComboField runat="server" ID="EditTargetAtrributeId" Width="150" Editable="false"
                            DisplayField="EditTargetAtrributeIdName" ValueField="EditTargetAtrributeId" AutoLoad="true"
                            Mode="Remote">
                            <DataContainer>
                                <DataSource OnEvent="EditTargetAtrributeIdOnRefreshData">
                                    <Columns>
                                        <rx1:Column Name="EditTargetAtrributeId" Hidden="true">
                                        </rx1:Column>
                                        <rx1:Column Name="EditTargetAtrributeIdName">
                                        </rx1:Column>
                                    </Columns>
                                </DataSource>
                            </DataContainer>
                        </rx1:ComboField>
                    </Component>
                </Editor>
            </rx1:GridColumns>
        </Columns>
    </ColumnModel>
    <SelectionModel>
        <rx1:RowSelectionModel ID="RowSelectionModel1" runat="server">
        </rx1:RowSelectionModel>
    </SelectionModel>
</rx1:GridPanel>
