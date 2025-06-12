<%@ Page Language="C#" AutoEventWireup="true" Inherits="CrmPages_Admin_CustomControl_CustomControlListReflex" Codebehind="CustomControlListReflex.aspx.cs" %>


<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork" TagPrefix="rx" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>

<body>
    <form id="form1" runat="server">
    <rx:RegisterResources runat="server" ID="RR"/>
    <rx:Hidden ID="hCustomControlDllId" runat="server">
    </rx:Hidden>
                <rx:GridPanel ID="_grdsma" runat="server" TrackMouseOver="false" AutoWidth="true"
        PostAllData="true" Mode="Remote" AutoHeight="Auto" AutoLoad="true" Width="600"
        AjaxPostable="true" Height="400">
                <DataContainer>
            <DataSource OnEvent="Store1_Refresh">
                <Columns>
                    <rx:Column Name="Name">
                    </rx:Column>
                    <rx:Column Name="ClassName">
                    </rx:Column>
                    <rx:Column Name="CustomControlId">
                    </rx:Column>
                </Columns>
            </DataSource>
        </DataContainer>
                    <ColumnModel>
                        <Columns>
                        
                            <rx:GridColumns Header="Name" DataIndex="Name" MenuDisabled="true" Width="200" Hidden="false"
                                Sortable="false">
                            </rx:GridColumns>
                            <rx:GridColumns Header="ClassName" DataIndex="ClassName" Width="400" MenuDisabled="true" Hidden="false"
                                Sortable="false">
                            </rx:GridColumns>
                            <rx:GridColumns Header="CustomControlId" DataIndex="CustomControlId" Width="100" Hidden="true" Sortable="false">
                            </rx:GridColumns>
                        </Columns>
                    </ColumnModel>
                    <SelectionModel>
                        <rx:RowSelectionModel ID="RowSelectionModel1" runat="server" />
                    </SelectionModel>
   
                    <LoadMask ShowMask="true" Msg="Loading Data..." />
                </rx:GridPanel>

    </form>
</body>
</html>

