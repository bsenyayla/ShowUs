<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
    <link href="css/flip.css" rel="stylesheet" type="text/css" />
    <script src="Scripts/jquery-1.3.2.js" type="text/javascript"></script>
    <script src="Scripts/jqueryui.js" type="text/javascript"></script>
    <script src="Scripts/jquery.flip.min.js" type="text/javascript"></script>
    <link href="Yonetim/CSS/dd.css" rel="stylesheet" type="text/css" />
    <script src="Yonetim/Scripts/jquery.dd.js" type="text/javascript"></script>
    <script type="text/javascript">
//        $(document).ready(function() {
//            /* The following code is executed once the DOM is loaded */

//        $('.sponsorFlip').bind("click", function() {

//                // $(this) point to the clicked .sponsorFlip element (caching it in elem for speed):

//                var elem = $(this);

//                // data('flipped') is a flag we set when we flip the element:

//                if (elem.data('flipped')) {
//                    // If the element has already been flipped, use the revertFlip method
//                    // defined by the plug-in to revert to the default state automatically:

//                    elem.revertFlip();

//                    // Unsetting the flag:
//                    elem.data('flipped', false)
//                }
//                else {
//                    // Using the flip method defined by the plugin:

//                    elem.flip({
//                        direction: 'lr',
//                        speed: 350,
//                        onBefore: function() {
//                            // Insert the contents of the .sponsorData div (hidden from view with display:none)
//                            // into the clicked .sponsorFlip div before the flipping animation starts:

//                            elem.html(elem.siblings('.sponsorData').html());
//                        }
//                    });

//                    // Setting the flag:
//                    elem.data('flipped', true);
//                }
//            });

//        });
    </script>
</head>
<body>
    <form id="form1" runat="server"><script>
    $(document).ready(function(e) {
try {
$("body select").msDropDown();
} catch(e) {
alert(e.message);
}
});
</script>
    <div>

 
    
    <div id="main">
    <img src="images/logocrm.png" /><div><table>  <tr> <td>    <asp:DropDownList ID="webmenu" runat="server" Visible="false" 
            AutoPostBack="True" onselectedindexchanged="ddlproje_SelectedIndexChanged">
        </asp:DropDownList></td> <td> <img src="images/back1.png" title="Geri" onclick="javascript:history.go(-1);" style="cursor:hand;" /></td><td> <asp:Label ID="lblsonuc" Visible="False" 
            runat="server" Font-Bold="True" Font-Size="14px" ForeColor="#FF6666"></asp:Label></td>
            </tr></table>
</div>
	<div class="sponsorListHolder">
       <asp:DataList ID="DataList1"  runat="server" RepeatColumns="4" 
       RepeatDirection="Horizontal">
       <ItemTemplate>		
       <div class="sponsor" title="sayfaya gitmek için tıklayınız">
       <div class="sponsorFlip">
       <a href='<%#Eval("Link") %>'>
       <%#Eval("Aciklama") %><br />
	   <img src='<%#Eval("Resim") %>' border="0" alt='<%#Eval("SayfaAdi") %>' />
	   
	   </a>
	   <br />
	   </div>		
	   	</div>
		</ItemTemplate>

	 </asp:DataList>
</div></div>
    </form>
</body>
</html>
