<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_WebUserControl" Codebehind="WebUserControl.ascx.cs" %>
<%@ Register TagPrefix="rx" Namespace="RefleXFrameWork" Assembly="RefleXFrameWork" %>
<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>

                                <cc1:CrmComboComp runat="server" ID="new_Corporation" ObjectId="201500008" RequirementLevel="BusinessRequired" UniqueName="new_Corporation"
                                    Width="150" PageSize="500" FieldLabel="200" Mode="Remote">
                                    <DataContainer>
                                        <DataSource OnEvent="CorporationLoad">
                                        </DataSource>
                                    </DataContainer>
                                </cc1:CrmComboComp>
