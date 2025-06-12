<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Plugin_PluginDllEdit" Codebehind="PluginDllEdit.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div style="display:none">
        <ext:Hidden ID="hPluginDllId" runat="server">
        </ext:Hidden>
    </div>
    <div>
         <ext:FormPanel 
            
            ID="BasicForm" 
            runat="server"
            Width="500"
            Frame="true"
            Title="File Upload Form"
            AutoHeight="true"
            MonitorValid="true"
            BodyStyle="padding: 10px 10px 0 10px;">                
            <Defaults>
                <ext:Parameter Name="anchor" Value="95%" Mode="Value" />
                <ext:Parameter Name="allowBlank" Value="true" Mode="Raw" />
                <ext:Parameter Name="msgTarget" Value="side" Mode="Value" />
            </Defaults>
            <Body>
                <ext:FormLayout ID="FormLayout1" runat="server" LabelWidth="50">
                    <ext:Anchor>
                        <ext:TextField ID="TxtDllName" runat="server" FieldLabel="Name" AllowBlank="true" />
                    </ext:Anchor>
                    <ext:Anchor>
                        <ext:Checkbox ID="ChkDataBase" runat="server" Checked="true" FieldLabel="Database" />
                    </ext:Anchor>

                    <ext:Anchor>
                        <ext:FileUploadField 
                            ID="FileUploadField1" 
                            runat="server" 
                            EmptyText="Select a file"
                            FieldLabel="Dll"
                            ButtonText=""
                            Icon="NewRed"
                            AllowBlank="true"
                            >
                        </ext:FileUploadField>
                    </ext:Anchor>
                </ext:FormLayout>
            </Body>
            <Listeners>
                <ClientValidation Handler="#{SaveButton}.setDisabled(!valid);" />
            </Listeners>
            <Buttons>
                <ext:Button ID="SaveButton" runat="server" Text="Save">
                    <AjaxEvents>
                        <Click 
                            OnEvent="UploadClick"
                            Before="if(!#{BasicForm}.getForm().isValid()) { return false; } 
                            Ext.MessageBox.show({
			msg: 'Uploading File',
			progressText: 'Uploading...',
			width:300,
			wait:true,
			waitConfig: {interval:500}
		});
                                "
                            Success="Ext.MessageBox.hide();"   
                            Failure="Ext.Msg.show({ 
                                title   : 'Error', 
                                msg     : 'Error during uploading', 
                                minWidth: 200, 
                                modal   : true, 
                                icon    : Ext.Msg.ERROR, 
                                buttons : Ext.Msg.OK 
                            });">
                        </Click>
                    </AjaxEvents>
                </ext:Button>
                <ext:Button ID="Button1" runat="server" Text="Reset">
                    <Listeners>
                        <Click Handler="#{BasicForm}.getForm().reset();" />
                    </Listeners>
                </ext:Button>
            </Buttons>
        </ext:FormPanel>

    </div>
    </form>
</body>
</html>
