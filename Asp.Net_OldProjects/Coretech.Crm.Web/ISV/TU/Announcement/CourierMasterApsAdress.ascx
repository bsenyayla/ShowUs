<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="CourierMasterApsAdress.ascx.cs" 
    Inherits="CourierMasterApsAdress" %>


<%@ Import Namespace="Coretech.Crm.Factory" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>


<rx:PanelX runat="server" ID="Fieldset2" AutoHeight="Normal" Height="50" AutoWidth="true"
    Collapsible="false" Border="false" BorderStyle="None">
    <Body>    
        <rx:ColumnLayout runat="server" ID="ColoumnLayout1" ColumnWidth="100%">
            <Rows>
                <rx:RowLayout ID="RowLayout1" runat="server">
                    <Body>
                        <rx:TextField ID="txtApsAdres" runat="server" FieldLabel="Aps Adres" ReadOnly="true" >
                        </rx:TextField>
                    </Body>
                </rx:RowLayout>
            </Rows>
        </rx:ColumnLayout>
    </Body>
</rx:PanelX>