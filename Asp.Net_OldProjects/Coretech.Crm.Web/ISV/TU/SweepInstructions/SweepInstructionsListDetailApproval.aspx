<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SweepInstructionsListDetailApproval.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.SweepInstructionsList.SweepInstructionsListDetailApproval" %>
<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <rx:RegisterResources runat="server" ID="RR" />
    <form id="form1" runat="server">
        <div>
            
            <rx:PanelX runat="server" ID="pnl1" AutoHeight="Normal" Height="430" AutoWidth="true" Collapsed="false" Collapsible="False"
            Border="true" Frame="true" Title="Süpürma Talimatı">
            <Body>
                <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="90%">
                    <Rows>
                        <rx:RowLayout ID="RowLayout13" runat="server">
                            <Body>
                                <rx:Label ID="lCancelTransaction" runat="server" Text="Süpürme Talimatı Silme İşlemi İptal Onayı." ForeColor="Red" Font-Bold="true" />
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout11" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_CorporationId" ObjectId="202000056" UniqueName="new_CorporationId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" RequirementLevel="BusinessRequired" AutoLoad="true" >
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout5" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_SenderAccountId" ObjectId="202000056" UniqueName="new_SenderAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="AccountWithBalanceLookupView" RequirementLevel="BusinessRequired" AutoLoad="false" >
                                 </cc1:CrmComboComp>
                            </Body>
                        </rx:RowLayout>
                        <rx:RowLayout ID="RowLayout22" runat="server">
                            <Body>
                                <cc1:CrmComboComp runat="server" ID="new_RecipientCorparationAccountId" ObjectId="202000056" UniqueName="new_RecipientCorparationAccountId" Hidden="false"
                                    Width="10" PageSize="50" FieldLabel="150" LookupViewUniqueName="AccountWithBalanceLookupView" RequirementLevel="BusinessRequired" AutoLoad="false" >
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
        </rx:PanelX>

            <rx:hidden ID="hdnRecId" runat="server"></rx:hidden>
    
           
        </div>
    </form>
</body>
</html>