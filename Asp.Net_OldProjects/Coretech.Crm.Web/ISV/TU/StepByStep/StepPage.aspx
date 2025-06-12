<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StepPage.aspx.cs" Inherits="Coretech.Crm.Web.ISV.TU.StepByStep.StepPage" %>

<%@ Register Assembly="Coretech.Crm.Web.UI.RefleX" Namespace="Coretech.Crm.Web.UI.RefleX.AutoGenerate"
    TagPrefix="cc1" %>
<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <rx:RegisterResources runat="server" ID="RR" />
            <rx:Hidden runat="server" ID="hdnCurrentPageNumber" />
            <rx:Hidden runat="server" ID="hdnFinishPageNumber" />

            <rx:PanelX ID="wrapper" runat="server" Title="" >
                <Body>
                    <rx:PanelX ID="pnlStep1" runat="server" Title="{0} / {1} {2}" ToolTip="1">
                    </rx:PanelX>
                    <rx:PanelX ID="pnlStep2" runat="server" Title="{0} / {1} {2}" ToolTip="2">
                    </rx:PanelX>
                    <rx:PanelX ID="pnlStep3" runat="server" Title="{0} / {1} {2}" ToolTip="3">
                    </rx:PanelX>
                </Body>
            </rx:PanelX>

            <rx:ToolBar ID="toolBar" runat="server">
                <Items>
                    <rx:ToolbarSeparator ID="Sep" runat="server"></rx:ToolbarSeparator>
                    <rx:ToolbarFill ID="ToolbarFill1" runat="server">
                    </rx:ToolbarFill>
                    <rx:Button ID="Button1" runat="server" Text="Previus" Icon="PreviousGreen">

                        <AjaxEvents>
                            <Click OnEvent="Process"></Click>
                        </AjaxEvents>
                    </rx:Button>
                    <rx:Button ID="Button2" runat="server" Text="Next" Icon="NextGreen">
                        <AjaxEvents>
                            <Click OnEvent="Process"></Click>
                        </AjaxEvents>
                    </rx:Button>


                </Items>
            </rx:ToolBar>


        </div>
    </form>
</body>
</html>
