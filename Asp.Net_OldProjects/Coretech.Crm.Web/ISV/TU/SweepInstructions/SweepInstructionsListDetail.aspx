<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SweepInstructionsListDetail.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetail" ValidateRequest="false" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Import Namespace="Coretech.Crm.Utility.Util" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
        

        function ShowHistory() {

            //var config = "/CrmPages/AutoPages/LogViewer.aspx?EntityId=A25746C1-7200-4ED0-8E06-771FFBF2AA23&RecordId=" + hdnRecId.getValue();
            var config = "../ISV/TU/SweepInstructions/SweepInstructionsHistoryList.aspx?RecordId=" + hdnRecId.getValue();
            var title = "İşlem Logları";
            window.top.newWindow(config, { title: title, width: 800, height: 550, resizable: false });

        }
        
        function ShowLog() {
            //var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();

            /*
            if (hdnStatusId.getValue() < 2)
                return;
                */
            var config = "../ISV/TU/SweepInstructions/SweepInstructionsLogList.aspx?RecordId=" + hdnRecId.getValue();;
            var title = "Düzenleme Geçmişi";
            window.top.newWindow(config, { title: title, width: 800, height: 550, resizable: false });

        }

        function TransferTimeSelect()
        {
            var transferTime = IsSelectTransferTime.getValue();
            
            if (transferTime==1)
                document.getElementById('mfDays').style.visibility = "hidden";
            else
                document.getElementById('mfDays').style.visibility = "visible";
        }

        function SetValueHidden()
        {
            documentId.setValue(GridPanelConfirmHistory.selectedRecord.DocumentId);
            documentName.setValue(GridPanelConfirmHistory.selectedRecord.DocumentName);
            hdnUploaded.setValue(GridPanelConfirmHistory.selectedRecord.Uploaded);
        }

        function checkDelete() {
            var ret = confirm('Seçili kayıtlar silinecek, Emin misiniz?');
            return ret;
        }


        function ShowUploadDetail() {
            //var config = "../ISV/TU/Transfer/TransferDocument.aspx?ObjectId=" + operationTypeId.getValue() + "&RecordId=" + transferId.getValue();
            var defaulteditpageid = "";       
            
            if (hdnUploaded.getValue() == true)
                return;

            if (hdnRecId.getValue() == null || hdnRecId.getValue() == 'undefined' || hdnRecId.getValue() == '' || hdnRecId.getValue() == '<%=Guid.Empty%>')
                return;

            var config = "../ISV/TU/Corporated/CorporatedPreInfoNewRegistrationFileUpload.aspx?RecordId=" + hdnRecId.getValue() + "&MersisNo=" + new_CorparateCentralRegistryServiceNumber.getValue() + '&DocumentId=' + documentId.getValue() + '&DocumentName=' + documentName.getValue();
            var title = "Dosya Yükleme Ekranı";


            //var config = "/CrmPages/AutoPages/EditReflex.aspx?ObjectId=201900037&recId=" + hdnRecId.getValue() + "&defaulteditpageid=" + defaulteditpageid + "&SourceFormType=NormList";

            window.top.newWindow(config, { title: title, width: 400, height: 270, resizable: false });
        }

        function checkDelete() {
            var ret = confirm('Seçili kayıt silinecek, Emin misiniz?');
            return ret;
        }

        <%
        string islem = QueryHelper.GetString("islem");
        string mesaj="";
        if (islem == "islemTamam")
            mesaj = "Ofis kaydı güncellenmiştir.";
        if (islem == "islemOnay")
            mesaj = "İşlem onay beklemektedir.";
        if (islem == "islemTamamOnay")
            mesaj = "İşlem onaylanmıştır.";
        
        if (islem=="islemOnay")
        {
        %>
        function closeWindowAscx(mesaj) {
                if (mesaj!='')
                    alert(mesaj);
                window.top.R.WindowMng.getActiveWindow().hide();
        }
        closeWindowAscx('<%=mesaj%>');
        <%
        }
        %>

        //document.getElementsByClassName('x-grid3-hd-checker')[0].style.visibility = 'hidden';
        //document.getElementsByClassName('x-grid3-row-checker')[0].style.visibility = 'hidden';

    </script>

        <%
        string recId = QueryHelper.GetString("RecordId");
               
        if (!String.IsNullOrEmpty(recId))
        {
        %>
            <style type="text/css">
            .x-grid3-hd-checker ,.x-grid3-row-checker,.x-grid3-row-checker-on{
                display: none !important;
            }
        <%
        }
        %>
        
    </style>
</head>
<body>


            <rx:ToolBar runat="server" ID="ToolBar1">
            <Items>
                <rx:ToolbarFill runat="server" ID="ToolbarFill1">
                </rx:ToolbarFill>
                <rx:ToolbarButton runat="server" ID="BtnShowHistory" Text="Düzenleme Geçmişi" Icon="Hourglass"
                    Width="100">
                    <Listeners>
                        <Click Handler="ShowHistory();"></Click>
                    </Listeners>
                </rx:ToolbarButton>
            </Items>
        </rx:ToolBar>
    <form id="form1" runat="server">
        <rx:RegisterResources runat="server" ID="RR" />
        <div>
            <rx:Hidden ID="hdnTransactionTypeId" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnTransactionType" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatus" runat="server"></rx:Hidden>

        <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="430" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Süpürme Talimatı">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="90%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="202000056" UniqueName="new_CorporationId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="BusinessRequired" AutoLoad="true" >
                                    <Listeners>
                                        <Change Handler="new_SenderAccountId.clear(false,false);new_RecipientCorparationAccountId.clear(false,false);" />
                                    </Listeners>
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="202000056" UniqueName="new_SenderAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="AccountWithBalanceLookupView" RequirementLevel="BusinessRequired" AutoLoad="false" >
                                    <DataContainer>
                                        <DataSource OnEvent="newSenderUptAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                    <Listeners>
                                        <Change Handler="new_RecipientCorparationAccountId.clear(false,false);" />
                                    </Listeners>
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout22" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCorparationAccountId" ObjectId="202000056" UniqueName="new_RecipientCorparationAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="AccountWithBalanceLookupView" RequirementLevel="BusinessRequired" AutoLoad="false" >
                                    <DataContainer>
                                        <DataSource OnEvent="newRecipientCorpAccountLoad">
                                        </DataSource>
                                    </DataContainer>
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout6" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_SweepBalance" runat="server" ObjectId="202000056" UniqueName="new_SweepBalance"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                      <AjaxEvents>
                                           <Change OnEvent="SweepBalanceEvent">
                                           </Change>
                                      </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout12" runat="server">
                            <Body>
                                <cc1:CrmDecimalComp ID="new_SweepLevelAmount" runat="server" ObjectId="202000056" UniqueName="new_SweepLevelAmount"
                                    FieldLabelShow="True" Width="82" PageSize="50">
                                </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout21" runat="server">
                            <Body>
                                <cc1:CrmDecimalComp ID="new_SweepAmount" runat="server" ObjectId="202000056" UniqueName="new_SweepAmount"
                                    FieldLabelShow="True" Width="82" PageSize="50">
                                </cc1:CrmDecimalComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout7" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_SweepType" runat="server" ObjectId="202000056" UniqueName="new_SweepType"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                  <AjaxEvents>
                                            <Change OnEvent="SweepTypeEvent">
                                            </Change>
                                  </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout9" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_InstructionsDayType" runat="server" ObjectId="202000056" UniqueName="new_InstructionsDayType"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                  <AjaxEvents>
                                            <Change OnEvent="InstructionsDayTypeEvent">
                                            </Change>
                                  </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>


                        <%--<rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="MultiField1" FieldLabelShow="True">
                                <Items>
                                    <rx:Label runat="server" ID="Label2" Text=" Talimatın Günü:" Width="230" Disabled="True" />
                                   <rx:RadioGroup runat="server" ID="IsSelectTransferTime" FieldLabel="" EmptyText="Tümü" ToolTip="Çalışacak günleri seçin" FieldLabelWidth="200" Width="200">
                                        <Items>
                                            <rx:RadioColumn Text="Hepsi" Value="1" Checked="true" />
                                            <rx:RadioColumn Text="Seçili Güner" Value="0" />
                                        </Items>
                                         <AjaxEvents>
                                            <Click OnEvent="TransferTimeEvent">
                                            </Click>
                                        </AjaxEvents>
                                    </rx:RadioGroup>                                    
                                </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>--%>
                        <rx:RowLayout ID="RowLayout8" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="mfDays" FieldLabelShow="True">
                                <Items>
                                    <rx:Label runat="server" ID="Label3" Text=" Talimatın Günleri:" Width="230" Disabled="True"  />
                                        <rx:MultiField runat="server" ID="MultiField3" FieldLabelShow="True" Widt="100">
                                        <Items>
                                             <rx:CheckField runat="server" ID="chcPazartesi" FieldLabel="Pazartesi">
                                             </rx:CheckField>    
                                             <rx:CheckField runat="server" ID="chcSali" FieldLabel="Salı">
                                             </rx:CheckField>
                                             <rx:CheckField runat="server" ID="chcCarsamba" FieldLabel="Çarşamba">
                                             </rx:CheckField>   
                                             <rx:CheckField runat="server" ID="chcPersembe" FieldLabel="Perşembe">
                                             </rx:CheckField>   
                                             <rx:CheckField runat="server" ID="chcCuma" FieldLabel="Cuma">
                                             </rx:CheckField>    
                                             <rx:CheckField runat="server" ID="chcCumartesi" FieldLabel="Cumartesi">
                                             </rx:CheckField> 
                                             <rx:CheckField runat="server" ID="chcPazar" FieldLabel="Pazar">
                                             </rx:CheckField> 

                                         </Items> 
                                       </rx:MultiField>                                                                                                                                                                                                                                       
                                </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout1" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp ID="new_TransferTime" runat="server" ObjectId="202000056" UniqueName="new_TransferTime"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="true">
                                  <AjaxEvents>
                                       <Change OnEvent="TransferTimeEvent">
                                        </Change>
                                  </AjaxEvents>
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>

                        <rx:RowLayout ID="RowLayout3" runat="server">
                            <Body>
                                <rx:MultiField runat="server" ID="SweepTime" FieldLabelShow="True">
                                <Items>
                                    <rx:Label runat="server" ID="lcl" Text=" Süpürme zamanı:" Width="180" Disabled="True" />
                                    <cc1:CrmTextFieldComp  ID="new_SweepHour" runat="server" ObjectId="202000056" UniqueName="new_SweepHour"
                                        FieldLabelShow="false" Width="50" PageSize="50" >
                                    </cc1:CrmTextFieldComp>
                                    <rx:Label runat="server" ID="Label1" Text=" / " Width="10" Disabled="True" />
                                    <cc1:CrmTextFieldComp  ID="new_SweepMinute" runat="server" ObjectId="202000056" UniqueName="new_SweepMinute"
                                        FieldLabelShow="false" Width="50" PageSize="50">
                                    </cc1:CrmTextFieldComp>
                                    
                                </Items>
                                </rx:MultiField>
                            </Body>
                        </rx:RowLayout>


                        <rx:RowLayout ID="RowLayout10" runat="server">
                            <Body>
                                <cc1:CrmDateFieldComp ID="new_ScheduledTime" runat="server" ObjectId="202000056" UniqueName="new_ScheduledTime"
                                    FieldLabelShow="True" Width="82" PageSize="50">
                                </cc1:CrmDateFieldComp>
                            </Body>
                        </rx:RowLayout>

                         <rx:RowLayout ID="RowLayout2" runat="server">
                            <Body>
                                <cc1:CrmPicklistComp runat="server" ID="new_InstructionsStatus" ObjectId="202000056" UniqueName="new_InstructionsStatus"
                                            Width="10" PageSize="50" FieldLabel="150" ReadOnly="true">
                               </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>

                         <rx:RowLayout ID="RowLayout4" runat="server">
                            <Body>

                                <cc1:CrmPicklistComp ID="new_InstructionsConfirmStatus" runat="server" ObjectId="202000056" UniqueName="new_InstructionsConfirmStatus"
                                    FieldLabelShow="True" Width="82" PageSize="50" ReadOnly="false" Disabled="true">
                                </cc1:CrmPicklistComp>
                            </Body>
                        </rx:RowLayout>
                        
 

                    </Rows>
                </rx:ColumnLayout>
            </Body>
            <Buttons>
                  <rx:Button ID="BtnDelete" runat="server" Text="Sil" Icon="Delete" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="DeletionOnEvent"></Click>
                    </AjaxEvents>
                </rx:Button>
                 <rx:Button ID="BtnSave" runat="server" Text="Kaydet" Icon="BookEdit" Visible="true" AutoPostBack="true">
                    <AjaxEvents>
                        <Click OnEvent="SaveOnEvent"></Click>
                    </AjaxEvents>
                </rx:Button>
            </Buttons>
        </rx:PanelX>

            <rx:Hidden ID="hdnRecId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentId" runat="server"></rx:Hidden>
            <rx:Hidden ID="documentName" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnUploaded" runat="server"></rx:Hidden>
            <rx:Hidden ID="hdnStatusId" runat="server"></rx:Hidden>

         



        </div>
    </form>
</body>
</html>
 