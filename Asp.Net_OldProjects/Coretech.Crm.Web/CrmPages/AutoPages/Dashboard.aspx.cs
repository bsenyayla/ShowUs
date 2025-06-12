using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dashboard;
using Coretech.Crm.Objects.Crm.Labels;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dashboard;
using Coretech.Crm.PluginData;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Utility.Util;
using Newtonsoft.Json;
using JsonReader = RefleXFrameWork.JsonReader;

public partial class CrmPages_AutoPages_Dashboard : BasePage
{
    void TranslateMessage()
    {
        DashTool.Items[0].Text = CrmLabel.TranslateMessage(LabelEnum.DASH_MENU_DASHBOARD);
        DashTool.Items[1].Text = CrmLabel.TranslateMessage(LabelEnum.DASH_MENU_VIEW);
        Setting.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_MENU_SETTINGS);
        UserSave.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_MENU_USERSAVE);
        UserSave.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessage(LabelEnum.DASH_USERSAVE_CLICK_EVENTMASK);
        MenuItem1.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_CASCADE);
        MenuItem2.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_TILE);
        Default.Title = CrmLabel.TranslateMessage(LabelEnum.DASH_DEFAULT_TAB);
        DashSettings.Title = CrmLabel.TranslateMessage(LabelEnum.DASH_WINDOW_TITLE);
        TabsList.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.DASH_TABLIST);
        TabName.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.DASH_TABNAME);
        //ReportList.Title = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_TITLE);
        pnlGrd.Title = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_TITLE);
        ReportList.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_COLUMN_REPORTNAME);
        //ReportList.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_COLUMN_CLOSABLE);
        //ReportList.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_COLUMN_RESIZABLE);
        //ReportList.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_COLUMN_MAXIMIZABLE);
        //ReportList.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_COLUMN_MINIMIZABLE);
        ReportList.LoadMask.Msg = CrmLabel.TranslateMessage(LabelEnum.DASH_GRID_LOADMASK);
        btnSave.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_SAVE);
        ToolbarButton4.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_DELETE);
        ToolbarButton3.Text = CrmLabel.TranslateMessage(LabelEnum.DASH_SAVEANDCLOSE);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            //TabsList.ClearItems();
            //TabsList.AddItem(new ListItem("NewGuid", CrmLabel.TranslateMessage(LabelEnum.EXPORT_TO_EXCEL)));
        }
    }

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            if (!string.IsNullOrEmpty(App.Params.CurrentUser.DashboardXml))
            {
                DashboardTabs.Tabs.Clear();
                 var jsonReader = new JsonReader(App.Params.CurrentUser.DashboardXml);
                dynamic jsonObject = jsonReader.ReadValue();

                foreach (var item in jsonObject)
                {
                    
                    
                    var tab = new Tab
                    {
                        Url = "DashboardTabs.aspx?TabId=" + item.TabId,
                        TabMode = ETabMode.Frame,
                        Closable = true,
                        Title = item.TabName,
                        ID = item.TabId
                    };

                    DashboardTabs.Tabs.Add(tab);
                    DashboardTabs.ActiveTab = 0;
                    TabsList.Items.Add(new ListItem(item.TabId, item.TabName));
                }
            }
        }

        base.OnPreInit(e);
        TranslateMessage();

    }

    DataTable GetSecureData()
    {
        const string strSql = @"
                    select 
                        dashboardreportsId,reportname,ViewQueryId,DynamicUrlId,Url,
                        cast(0 as bit) Closable,
                        cast(0 as bit) Resizable,
                        cast(0 as bit) Maximizable,
                        cast(0 as bit) Minimizable
                        from tvdashboardreports(@SystemUserId) order by  reportname
            ";
        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        var retDs = sd.ReturnDataset(strSql);
        return retDs.Tables[0];
    }
    protected void List(object sender, AjaxEventArgs e)
    {

        var dt = GetSecureData();

        var tabs = JsonConvert.DeserializeObject<List<Tabs>>(App.Params.CurrentUser.DashboardXml);
        if (tabs != null)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 0; j < tabs.Count; j++)
                {
                    if (tabs[j].TabName == TabName.Value)
                    {
                        foreach (Reports t in tabs[j].Reports)
                        {
                            if (ValidationHelper.GetGuid(dt.Rows[i]["dashboardreportsId"]) != ValidationHelper.GetGuid(t.DashboardreportsId)) continue;
                            //dt.Rows[i]["Closable"] = t.Closable;
                            //dt.Rows[i]["Resizable"] = t.Resizable;
                            //dt.Rows[i]["Maximizable"] = t.Maximizable;
                            //dt.Rows[i]["Minimizable"] = t.Minimizable;
                        }

                    }
                }
            }
        }
        ReportList.DataSource = dt;
        ReportList.DataBind();
        if (tabs != null)
        {
            ReportList.ClearSelection();
            foreach (var t in tabs.Where(t => t.TabName == TabName.Value))
            {
                foreach (var t1 in t.Reports)
                {
                    var i = 0;
                    foreach (var item in ReportList.AllRows)
                    {
                        if (item.reportname == t1.ReportName)
                        {
                            ReportList.SetSelectedRowsIndex(i);
                        }
                        i++;
                    }
                }
            }
        }
    }

    protected void SaveTab(object sender, AjaxEventArgs e)
    {
        var wins = e.ExtraParams["Windows"];
        if (!string.IsNullOrEmpty(wins))
        {
            var tabid = -1;
            var tabs = new List<Tabs>();
            if (!string.IsNullOrEmpty(App.Params.CurrentUser.DashboardXml))
            {
                tabs = JsonConvert.DeserializeObject<List<Tabs>>(App.Params.CurrentUser.DashboardXml);
                Tabs tab = null;

                var jsonReader = new JsonReader(wins);
                dynamic jsonObject = jsonReader.ReadValue();

                for (var i = 0; i < tabs.Count; i++)
                {
                    if (tabs[i].TabId.ToString() != jsonObject.TabId) continue;
                    tab = tabs[i];
                    tabid = i;
                }

                if (tab != null)
                {
                    foreach (var item in jsonObject.Tabs)
                    {
                        for (int i = 0; i < tab.Reports.Count; i++)
                        {
                            if (tab.Reports[i].ReportName == item.Title)
                            {
                                tab.Reports[i].Height = item.Height;
                                tab.Reports[i].Width = item.Width;
                                tab.Reports[i].Maximized = item.Maximized;
                                tab.Reports[i].Minimized = item.Minimized;
                                tab.Reports[i].X = item.X;
                                tab.Reports[i].Y = item.Y;

                            }
                        }

                    }

                    tabs[tabid] = tab;
                }

            }

            var json = JsonConvert.SerializeObject(tabs);
            App.Params.CurrentUser.DashboardXml = json;
            App.Params.CurrentUser = App.Params.CurrentUser;
            DashboardFactory.SaveDashboard();
        }
    }

    protected void Delete(object sender, AjaxEventArgs e)
    {
        var tabs = new List<Tabs>();
        if (!string.IsNullOrEmpty(App.Params.CurrentUser.DashboardXml))
        {
            tabs = JsonConvert.DeserializeObject<List<Tabs>>(App.Params.CurrentUser.DashboardXml);
        }
        for (var i = 0; i < tabs.Count; i++)
        {
            if (tabs[i].TabId.ToString() == TabsList.Value)
            {
                tabs.Remove(tabs[i]);
            }
        }

        var json = JsonConvert.SerializeObject(tabs);
        App.Params.CurrentUser.DashboardXml = json;
        App.Params.CurrentUser = App.Params.CurrentUser;
        DashboardFactory.SaveDashboard();
    }

    protected void Save(object sender, AjaxEventArgs e)
    {
        if (string.IsNullOrEmpty(TabName.Value))
        {
            var msg = new MessageBox { Dragable = true, Modal = true };
            msg.Show(CrmLabel.TranslateMessage(LabelEnum.DASH_PLEASE_SELECT_TAB));
            return;
        }
        var tabid = -1;
        var tabs = new List<Tabs>();
        if (!string.IsNullOrEmpty(App.Params.CurrentUser.DashboardXml))
        {
            tabs = JsonConvert.DeserializeObject<List<Tabs>>(App.Params.CurrentUser.DashboardXml);
        }
        Tabs tab = null;
        if (TabsList.Value == "NewGuid")
        {
            var id = Guid.NewGuid();
            tab = new Tabs
                      {
                          TabId =
                              TabsList.Value == "NewGuid" ? id : ValidationHelper.GetGuid(TabsList.Value),
                          TabName = TabName.Value
                      };

            TabsList.AddItem(new ListItem(id.ToString(), TabName.Value));
            TabsList.SetValue(id.ToString());
        }
        else
        {
            for (var i = 0; i < tabs.Count; i++)
            {
                if (tabs[i].TabId.ToString() == TabsList.Value)
                {
                    tab = tabs[i];
                    tab.TabName = TabName.Value;
                    tabid = i;
                }
            }
        }

        if (tab != null)
        {
            tab.Reports.Clear();
            var rs = ReportList.SelectionModel[0] as CheckSelectionModel;
            if (rs != null)
            {
                if (rs.SelectedRows != null)
                {
                    var x = 10;
                    var collactedReport = new Dictionary<string, string>();
                    foreach (var item in rs.SelectedRows)
                    {
                        x += 50;
                        if (collactedReport.ContainsKey(item.dashboardreportsId))
                            continue;
                        collactedReport.Add(item.dashboardreportsId, "");
                        var rep = new Reports
                                      {
                                          ViewQueryId = item.ViewQueryId,
                                          DynamicUrlId = item.DynamicUrlId,
                                          ReportName = item.reportname,
                                          Maximizable = true,
                                          Minimizable = true,
                                          Closable = true,
                                          Resizable = true,
                                          Url=item.Url,
                                          X = x,
                                          Y = x,
                                          DashboardreportsId = item.dashboardreportsId
                                      };
                        tab.Reports.Add(rep);
                    }
                }
            }
            if (tabid > -1)
                tabs[tabid] = tab;
            else
                tabs.Add(tab);
        }

        var json = JsonConvert.SerializeObject(tabs);
        App.Params.CurrentUser.DashboardXml = json;
        App.Params.CurrentUser = App.Params.CurrentUser;
        DashboardFactory.SaveDashboard();

    }
}