<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OperationParameter.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.OperationParameter.OperationParameter_OperationParameter" %>

<%@ Import Namespace="Coretech.Crm.Factory" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        function imgRendererDetail(record, rowIndex, colIndex, store) {
            if (record == '0') {
                return "<img style='width:16px;height:16px;' src='../images/if_Remove_32542.png' />";
            }
            else {
                return "<img style='width:16px;height:16px;' src='../images/if_Add_32431.png' />";
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:Hidden ID="hdnSelectedId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnParameterName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnOldParameterName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnConfirmType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnCreatedBy" runat="server"></rx:Hidden>
            <rx:RegisterResources runat="server" ID="RR" />

            <rx:PanelX ID="pnl1" runat="server" Border="false" AutoHeight="Normal" Height="25" Padding="false" ContainerPadding="false">
                <Body>
                    <h3 style="color:orangered"></i><b>&nbsp;<b><strong style="color:black">Bilgilendirme :</strong> { 'E','1','Evet','true' }</b> gibi değeler <b>'var'</b> anlamına <b>{ 'H','0','Hayır','false' }</b> gibi değerler <b>'yok'<b/> anlamına gelmektedir.</b></h3>
                </Body>
            </rx:PanelX>

            <rx:ToolBar ID="toolBar1" runat="server">
                <Items>
                    <rx:Label ID="label1" runat="server" ImageUrl="../images/if_extension_79880.png" ImageHeight="36" ImageWidth="36" Width="40">
                    </rx:Label>
                    <rx:ToolbarSeparator ID="ToolbarSeparator2" runat="server">
                    </rx:ToolbarSeparator>

                    <rx:Label ID="lblSearch" Text="<b>Parametre Adı</b>" ForeColor="Black" runat="server"></rx:Label>
                    <rx:TextField ID="txtSearch" runat="server" Width="200" EmptyText="parametreyi giriniz">
                    </rx:TextField>

                    <rx:ToolbarSeparator ID="ToolbarSeparator1" runat="server">
                    </rx:ToolbarSeparator>

                    <rx:ToolbarButton ID="ToolbarButton4" runat="server" Icon="Find" Text="<b>Bul</b>">
                        <Listeners>
                            <Click Handler="gpOperationParameter.reload();" />
                        </Listeners>
                        <%--                        <AjaxEvents>
                            <Click OnEvent="FindOnEvent">
                            </Click>
                        </AjaxEvents>--%>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton ID="ToolbarButton1" runat="server" Icon="ApplicationEdit" Text="<b>Düzenle</b>">
                        <Listeners>
                            <Click Handler="
                                debugger;
                                if (gpOperationParameter.selectedRows == '')
                                { 
	                                alert('lütfen düzenlemek istediğiniz kaydı seçiniz');
                                } 
                                else 
                                { 
	                                if(hdnConfirmType.value == '0')
	                                {
		                                alert('Seçmiş olduğunuz işlem onaylanmayı bekliyor. Onay sonrası yeniden düzenleyebilirsiniz');
		                                return;
	                                }
	
	                                FrmOperationParameter.show(); 
	                                FrmOperationParameter.setTitle(hdnParameterName.value);
                                    txtOldParameterName.setValue(hdnOldParameterName.value);
                                    txtOldParameterName.value = hdnOldParameterName.value;
                                    
                                };
                                " />
                        </Listeners>
                    </rx:ToolbarButton>
                    
                    
                    <rx:ToolbarFill ID="ToolbarSeparator3" runat="server">
                    </rx:ToolbarFill>
                    <rx:ToolbarButton ID="btnConfirm" runat="server" Icon="Add" Text="<b>Onayla</b>">
                                                <AjaxEvents>
                            <Click OnEvent="ConfirmOnEvent">
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>
                    <rx:ToolbarButton ID="ToolbarButton2" runat="server" Icon="Delete" Text="<b>Reddet</b>">
                        <AjaxEvents>
                            <Click OnEvent="RejectOnEvent">
                            </Click>
                        </AjaxEvents>
                    </rx:ToolbarButton>

                </Items>
            </rx:ToolBar>

            <rx:GridPanel runat="server" ID="gpOperationParameter" AutoScroll="true"
                AutoWidth="true" AutoHeight="Normal" Collapsible="false" Mode="Remote" Height="800" AutoLoad="true">
                <DataContainer>
                    <DataSource OnEvent="FindOnEvent">
                    </DataSource>
                </DataContainer>
                <ColumnModel>
                    <Columns>
                        <rx:GridColumns ColumnId="ParameterId" Width="0" Header="ParameterId" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ParameterId" />
                        <rx:GridColumns ColumnId="DisplayName" Width="350" Header="<b>Parametre Adı</b>" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="DisplayName">
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="Value" Width="250" Header="<b>Mevcut Data</b>" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="Value" />
                        <rx:GridColumns ColumnId="TemporaryData" Width="500" Header="<b>Onay Bekleyen Data</b>" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TemporaryData" />
                        <rx:GridColumns ColumnId="TemporaryData" Width="20" Header="<b>Onay</b>" Align="Center" Sortable="false"
                            MenuDisabled="true" Hidden="false" DataIndex="TemporaryData">
                            <Renderer Handler="return imgRendererDetail(record.data.ConfirmType);" />
                        </rx:GridColumns>
                        <rx:GridColumns ColumnId="ConfirmType" Width="0" Header="<b>Onay Tipi</b>" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="ConfirmType" />
                        <rx:GridColumns ColumnId="CreatedBy" Width="0" Header="<b>Kayıt Sahibi</b>" Sortable="false"
                            MenuDisabled="true" Hidden="true" DataIndex="CreatedBy" />
                    </Columns>
                </ColumnModel>
                <SelectionModel>
                    <rx:CheckSelectionModel ID="gpOperationParameterSelectionModel1" runat="server" ShowNumber="true">
                        <Listeners>
                            <RowClick Handler="
                                hdnOldParameterName.clear();hdnOldParameterName.setValue(gpOperationParameter.selectedRecord.Value)
                                hdnCreatedBy.clear();hdnCreatedBy.setValue(gpOperationParameter.selectedRecord.CreatedBy)
                                hdnConfirmType.clear();hdnConfirmType.setValue(gpOperationParameter.selectedRecord.ConfirmType)
                                hdnParameterName.clear();hdnParameterName.setValue(gpOperationParameter.selectedRecord.DisplayName);
                                hdnSelectedId.clear();hdnSelectedId.setValue(gpOperationParameter.selectedRecord.ParameterId);"></RowClick>
                        </Listeners>
                        <%--                    <AjaxEvents>
                        <RowDblClick OnEvent="GetDataDetail">
                        </RowDblClick>
                    </AjaxEvents>--%>
                    </rx:CheckSelectionModel>
                </SelectionModel>

                <BottomBar>
                    <rx:PagingToolBar ID="pagingToolBar" runat="server" ControlId="gpOperationParameter">
                    </rx:PagingToolBar>
                </BottomBar>

            </rx:GridPanel>

            <rx:Window ID="FrmOperationParameter" runat="server" Width="500" Height="150" Modal="true"
                CenterOnLoad="true" WindowCenter="true" Closable="true" Maximizable="false" Resizable="false"
                CloseAction="Hide" ShowOnLoad="false" Border="false"
                Title="&nbsp;&nbsp;Operasyon Parametreler" ContainerPadding="false">
                <Body>
                    <rx:ToolBar ID="toolBar2" runat="server">
                        <Items>
                            <rx:ToolbarButton ID="ToolbarButton3" runat="server" Icon="ApplicationGo" Text="<b>Onaya Gönder</b>">
                                <AjaxEvents>
                                    <Click OnEvent="SaveOnEvent">
                                    </Click>
                                </AjaxEvents>
                            </rx:ToolbarButton>
                        </Items>
                    </rx:ToolBar>


                    <rx:ColumnLayout ID="cl1" runat="server" ColumnWidth="%100">
                        <Rows>
                            <rx:RowLayout ID="RowLayout2" runat="server">
                                <Body>
                                    <br />
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout3" runat="server">
                                <Body>
                                    <rx:TextField ID="txtOldParameterName" Disabled="true" FieldLabel="Mevcut Data" runat="server">
                                    </rx:TextField>
                                </Body>
                            </rx:RowLayout>
                            <rx:RowLayout ID="RowLayout1" runat="server">
                                <Body>
                                    <rx:TextField ID="txtParameterName" FieldLabel="Yeni Data" runat="server">
                                    </rx:TextField>
                                </Body>
                            </rx:RowLayout>

                        </Rows>
                    </rx:ColumnLayout>

                </Body>
            </rx:Window>

        </div>
    </form>
</body>
</html>
