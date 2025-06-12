<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Root_Left" Codebehind="_Left.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .menucaption
        {
            white-space: nowrap !important;
            word-wrap: normal !important;
            text-overflow: ellipsis !important;
            overflow: hidden !important;
            font-weight: normal;
            font-size: 11px;
            width: 90% !important;
        }
        .images-view .x-panel-body
        {
            background: white;
            font: 11px Arial, Helvetica, sans-serif;
        }
        .images-view .thumb
        {
            background: transparent;
            padding: 1px;
        }
        .images-view .thumb img
        {
            height: 10px;
            width: 48px;
        }
        .images-view .thumb-wrap
        {
            margin: 1px;
            margin-left: 10px;
            margin-right: 0;
            padding: 3px;
            text-align: left;
            width: 80% !important;
        }
        .images-view .thumb-wrap span
        {
            display: block;
            overflow: hidden;
            text-align: left;
        }
        
        .images-view .x-view-over
        {
            border: 1px solid #dddddd;
            background: #efefef url(../images/row-over.gif) repeat-x left top;
            padding: 2px;
            cursor: hand;
        }
        
        .images-view .x-view-selected
        {
            background: #eff5fb url(../images/selected.gif) no-repeat right bottom;
            border: 1px solid #99bbe8;
            padding: 2px;
        }
        .images-view .x-view-selected .thumb
        {
            background: transparent;
        }
    </style>
</head>
<ext:ViewPort ID="ViewPort1" runat="server" Cls="BODY">
    <Body>
        <ext:FitLayout ID="FitLayout1" runat="server">
            <Items>
                <ext:Panel ID="FitLayoutPanel" runat="server" AutoScroll="true">
                    <Body>
                    </Body>
                </ext:Panel>
            </Items>
        </ext:FitLayout>
    </Body>
</ext:ViewPort>
</html>
<script type="text/javascript" language="javascript">
    function Navigate(name, value) {
        if (value != "") {
            parent.PnlCenter.setTitle(name);
            parent.PnlCenter.load(value);
        }
        //parent.Panel2.

    }
   
</script>
