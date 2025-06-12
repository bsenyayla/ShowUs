<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_Customization_Entity_Property_Labels" Codebehind="Labels.aspx.cs" %>

<%@ Register Assembly="Coolite.Ext.Web" Namespace="Coolite.Ext.Web" TagPrefix="ext" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style>
        .x-icon-combo-icon
        {
            background-repeat: no-repeat;
            background-position: 0 50%;
            width: 18px;
            height: 14px;
        }
        .x-icon-combo-input
        {
            padding-left: 25px;
        }
        .x-form-field-wrap .x-icon-combo-icon
        {
            top: 3px;
            left: 5px;
        }
        .x-icon-combo-item
        {
            background-repeat: no-repeat !important;
            background-position: 3px 50% !important;
            padding-left: 24px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <ext:ScriptManager runat="server" ID="ScriptManager1" SourceFormatting="true">
    </ext:ScriptManager>
    <ext:Hidden runat="server" ID="objectid" />
    <ext:Store ID="store1" runat="server" OnRefreshData="Store1RefreshData" RemoteSort="true"
        AutoLoad="false">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="RegionName">
                <Fields>
                    <ext:RecordField Name="RegionName" Type="String" />
                    <ext:RecordField Name="LangId" Type="String" />
                    <ext:RecordField Name="iconCls" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <SortInfo Field="RegionName" Direction="ASC" />
    </ext:Store>
    <ext:Store ID="store2" runat="server" OnRefreshData="Store2RefreshData" RemoteSort="true"
        WarningOnDirty="false" AutoLoad="false">
        <Proxy>
            <ext:DataSourceProxy />
        </Proxy>
        <Reader>
            <ext:JsonReader ReaderID="LabelId">
                <Fields>
                    <ext:RecordField Name="ObjectName" Type="String" />
                    <ext:RecordField Name="ObjectId" Type="String" />
                    <ext:RecordField Name="LabelId" Type="String" />
                    <ext:RecordField Name="Value" Type="String" />
                    <ext:RecordField Name="LangId" Type="String" />
                    <ext:RecordField Name="Type" Type="String" />
                </Fields>
            </ext:JsonReader>
        </Reader>
        <BaseParams>
            <ext:Parameter Mode="Raw" Name="lng" Value="Language.getValue()" />
        </BaseParams>
    </ext:Store>
    <ext:Panel runat="server" ID="panel1" Frame="false" Border="false" BodyStyle="padding:10px">
        <Body>
            <ext:FormPanel runat="server" ID="formpanel1" Frame="false" Border="false" BodyStyle="padding:5px;"
                LabelSeparator="">
                <Body>
                    <ext:FormLayout ID="FormLayout2" runat="server" LabelSeparator="">
                        <ext:Anchor>
                            <ext:ComboBox runat="server" ID="Language" DisplayField="RegionName" ValueField="LangId"
                                FieldLabel="Language" StoreID="store1">
                                <Template>
                                <tpl for="."><div class="x-combo-list-item x-icon-combo-item {iconCls}">{RegionName}</div></tpl>
                                </Template>
                                <AjaxEvents>
                                    <Change OnEvent="LanguageOnEvent">
                                    </Change>
                                </AjaxEvents>
                            </ext:ComboBox>
                        </ext:Anchor>
                    </ext:FormLayout>
                </Body>
            </ext:FormPanel>
        </Body>
        <TopBar>
            <ext:Toolbar runat="server">
                <Items>
                    <ext:ToolbarButton runat="server" ID="Save" Icon="PageSave" Text="Label Kaydet">
                        <AjaxEvents>
                            <Click OnEvent="SaveOnEvent">
                                <ExtraParams>
                                    <ext:Parameter Name="Values" Value="Ext.encode(#{_grdsma}.getRowsValues(false))"
                                        Mode="Raw" />
                                    <ext:Parameter Mode="Raw" Name="lng" Value="Language.getValue()" />
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                    <ext:ToolbarButton runat="server" ID="BtnDelete" Icon="PageDelete" Text="Label Sil">
                        <AjaxEvents>
                            <Click OnEvent="DeleteOnEvent">
                                <ExtraParams>
                                    <ext:Parameter Name="Values" Value="Ext.encode(#{_grdsma}.getRowsValues())"
                                        Mode="Raw" />
                                    <ext:Parameter Mode="Raw" Name="lng" Value="Language.getValue()" />
                                </ExtraParams>
                            </Click>
                        </AjaxEvents>
                    </ext:ToolbarButton>
                    <ext:ToolbarButton runat="server" ID="BtnNew" Icon="PageAdd" Text="Label Ekle">
                        <Listeners>
                            <Click Handler="#{winLabelMessage}.show();" />
                        </Listeners>
                    </ext:ToolbarButton>
                </Items>
            </ext:Toolbar>
        </TopBar>
    </ext:Panel>
    <ext:Panel runat="server" ID="pnl2" Frame="false" Border="false" BodyStyle="padding:5px;"
        LabelSeparator="">
        <Body>
            <ext:GridPanel ID="_grdsma" runat="server" AutoWidth="true" StripeRows="true" StoreID="store2"
                ClicksToEdit="1" Height="470">
                <ColumnModel ID="_columnModel2" runat="server">
                    <Columns>
                        <ext:Column Header="LabelId" DataIndex="LabelId" Width="10" Hidden="true" />
                        <ext:Column Header="ObjectId" DataIndex="ObjectId" Width="200" Hidden="true" />
                        <ext:Column Header="ObjectName" DataIndex="ObjectName" Width="200" />
                        <ext:Column Header="Type" DataIndex="Type" Width="150" />
                        <ext:Column Header="Value" DataIndex="Value" Width="400">
                            <Editor>
                                <ext:TextField runat="server">
                                </ext:TextField>
                            </Editor>
                        </ext:Column>
                    </Columns>
                </ColumnModel>
                <LoadMask ShowMask="true" />
                <SelectionModel>
                    <ext:RowSelectionModel runat="server">
                    </ext:RowSelectionModel>
                </SelectionModel>
            </ext:GridPanel>
        </Body>
    </ext:Panel>
    <ext:Window runat="server" ID="winLabelMessage" Title="Insert Label Message" Width="300"
        BodyStyle="padding:10px" Frame="false" Border="false" Height="110" CenterOnLoad="true"
        ShowOnLoad="false">
        <Body>
            <table>
                <tr>
                    <td>
                        <ext:Label runat="server" Text="Label Message">
                        </ext:Label>
                    </td>
                    <td>
                        <ext:TextField runat="server" ID="LMessage" Width="180" MaskRe="/[A-Za-z0-9_]/">
                        </ext:TextField>
                    </td>
                </tr>
            </table>
        </Body>
        <Buttons>
            <ext:Button runat="server" Icon="PageSave" Text="Save">
                <AjaxEvents>
                    <Click OnEvent="LMessageSaveOnEvent" Success="#{winLabelMessage}.hide();">
                    </Click>
                </AjaxEvents>
            </ext:Button>
        </Buttons>
    </ext:Window>
    <script type='text/javascript' language='javascript'>
        Ext.override(Ext.form.ComboBox, {
            afterRender: function () {
                var wrap = this.el.up('div.x-form-field-wrap');
                this.wrap.applyStyles({ position: 'relative' });
                this.el.addClass('x-icon-combo-input');
                this.flag = Ext.DomHelper.append(wrap, {
                    tag: 'div', style: 'position:absolute'
                });
                Ext.form.ComboBox.superclass.afterRender.call(this);
            },
            setIconCls: function () {
                var rec = this.store.query(this.valueField, this.getValue()).itemAt(0);
                if (rec) {
                    this.flag.className = 'x-icon-combo-icon ' + rec.data.iconCls;
                }
            }
            , setValue: function (v) {
                var text = v;
                if (this.valueField) {
                    var r = this.findRecord(this.valueField, v);
                    if (r) {
                        text = r.data[this.displayField];
                        this.text = text;
                    } else {
                        if (v && this.mode == 'remote') {
                            this.lastQuery = '';
                            var p = this.getParams();
                            this.store.load({
                                scope: this,
                                params: p,
                                callback: function () {
                                    if (this.store.totalLength > 0) {
                                        this.setValue(v);
                                    }
                                    else
                                        if (this.valueNotFoundText !== undefined) {
                                            text = this.valueNotFoundText;
                                        }
                            }
                        });
                    }
                }
            }
            this.lastSelectionText = text;
            Ext.form.ComboBox.superclass.setValue.call(this, text);
            this.value = v;
            this.setIconCls();
        }
    });
    </script>
    </form>
</body>
</html>
