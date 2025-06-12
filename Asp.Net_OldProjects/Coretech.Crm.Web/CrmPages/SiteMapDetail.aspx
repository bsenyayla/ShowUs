<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_SiteMapDetail" CodeBehind="SiteMapDetail.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="ajx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <ajx:RegisterResources runat="server" ID="RR" />
        <ajx:ToolBar ID="ToolBar1" runat="server">
            <Items>
                <ajx:ToolbarButton ID="Reset" runat="server" Text="IIS Reset" Icon="ArrowRefresh">
                    <AjaxEvents>
                        <Click OnEvent="IISResetOnEvent" Before="return confirm('Dikkat! Sistem yeniden başlatılacak. Emin misiniz ?');" Success="alert('IIS Reset işlemi başarıyla tamamlandı.');"></Click>
                    </AjaxEvents>
                </ajx:ToolbarButton>
            </Items>
            
        </ajx:ToolBar>
        <ajx:DataView runat="server" ID="dataview1" ItemSelector="div.thumb-wrap" AutoLoad="true"
            MultiSelect="false" AutoWidth="true" AutoHeight="Auto" Mode="Local" OverClass="x-view-over">
            <LoadMask ShowMask="false" />
            <Listeners>
                <Click Handler="window.location=rec.Url;" />
            </Listeners>
        </ajx:DataView>
        
    </form>
</body>
</html>
