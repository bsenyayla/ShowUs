<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Root_Top" Codebehind="_Top.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
 

<body>

    <form id="form1" runat="server">
     <table id="barTopTable" cellspacing="0" cellpadding="0">
        <tbody>
            <tr>
                <td colspan="2">
                    <table   cellspacing="0" cellpadding="0">
                        <tbody>
                            <tr>
                                <td   id="tdLogoMastHeadBar">
                                    <span class="ms-crm-MastHead-SignIn-User" id="lblUserName">crm admin</span><br />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="2" noWrap="noWrap" >
                    <div id="CoretechDiv" > 
    
                        <ext:Button ID="Button1" runat="server" Text="Deneme">
                            <Menu>
                                <ext:Menu runat="server" id="New_menu" AllowOtherMenus="true" >
                                    <Items>
                                        <ext:MenuItem ID="MenuItem1" runat="server" Text="<b>Bold</b>">
                                        </ext:MenuItem>
                                        <ext:MenuItem ID="MenuItem2" runat="server" Text="<i>Italic</i>">
                                        </ext:MenuItem>
                                        <ext:MenuItem ID="MenuItem3" runat="server" Text="<u>Underline</u>">
                                        </ext:MenuItem>
                                        <ext:MenuItem ID="MenuItem4" runat="server" Text="<b>Bold</b>">
                                        </ext:MenuItem>
                                        <ext:MenuItem ID="MenuItem5" runat="server" Text="<i>Italic</i>">
                                        </ext:MenuItem>
                                        <ext:MenuItem ID="MenuItem6" runat="server" Text="<u>Underline</u>">
                                        </ext:MenuItem>
                                    </Items>
                                    <Listeners>
                                    <BeforeShow Fn="BeforeShow" />
                                    </Listeners>
                                </ext:Menu>
                            </Menu>
                        </ext:Button>
                    
       </div>
                </td>
            </tr>
            <tr>
                <td id="leftContextTD" width="190">
                    <table cellspacing="0" cellpadding="0">
                        <tbody>
                            <tr>
                                <td >
                                    <nobr id="tdLeftContextBar">Workplace</nobr>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
                <td>
                    <table cellspacing="0" cellpadding="0">
                        <tbody>
                            <tr>
                                <td class="ms-crm-ContextHeader-Title">
                                    <nobr id="tdStageContextBar">Activities</nobr>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
    </table> 
    </form>
</body>
</html>
<script>
//    function BeforeShow(el) {
//        alert(el.ul.dom.innerHTML)
//            var p=window.createPopup();
//            var pbody=p.document.body;
//            pbody.style = el.style;
//            pbody.innerHTML = el.ul.dom.innerHTML;
//            p.show(150,150,200,50,document.body);

//        return false;
//    }
</script>