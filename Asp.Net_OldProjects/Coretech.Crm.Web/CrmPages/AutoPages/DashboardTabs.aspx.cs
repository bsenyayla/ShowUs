using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using RefleXFrameWork;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;

public partial class CrmPages_AutoPages_DashboardTabs : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
        }
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
    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            if (!string.IsNullOrEmpty(App.Params.CurrentUser.DashboardXml))
            {
                var jsonReader = new JsonReader(App.Params.CurrentUser.DashboardXml);
                dynamic jsonObject = jsonReader.ReadValue();
                var datatbl = GetSecureData();
                var dic = new Dictionary<Guid, string>();
                foreach (DataRow row in datatbl.Rows)
                {
                    dic.Add(ValidationHelper.GetGuid(row["dashboardreportsId"]),"");
                    
                }
                foreach (var item in jsonObject)
                {
                    if (QueryHelper.GetString("TabId") == item.TabId)
                    {
                        var i = 0;
                        foreach (var rep in item.Reports)
                        {
                            try
                            {
                                if (!dic.ContainsKey(ValidationHelper.GetGuid(rep.DashboardreportsId)))
                                    continue;
                            
                            }
                            catch (Exception)
                            {

                                continue;
                            }
                            var url = "about:blank";
                            if (!String.IsNullOrEmpty(rep.ViewQueryId))
                            {
                                url = Page.ResolveUrl("~/CrmPages/AutoPages/DashboardList.aspx");
                                url += "?ViewQueryId=" + rep.ViewQueryId;
                            }
                            else if (!String.IsNullOrEmpty(rep.DynamicUrlId))
                            {
                                url = "DashboardDynamicUrl.aspx?DynamicUrlId=" + rep.DynamicUrlId;
                            }
                            else if (!String.IsNullOrEmpty(rep.Url))
                            {
                                url = rep.Url.Substring(0, 1) == "~" ? ResolveClientUrl(rep.Url) : rep.Url;
                            }
                            
                            var win = new Window
                            {
                                ID = "Window" + i,
                                Maximizable = rep.Maximizable,
                                Minimizable = rep.Minimizable,
                                Closable = rep.Closable,
                                Resizable = rep.Resizable,
                                CenterOnLoad = false,
                                Dragable = true,
                                MonitorResize = true,
                                Width = rep.Width <= 0 ? 300 : rep.Width,
                                Height = rep.Height <= 0 ? 200 : rep.Height,
                                X = rep.X,
                                Y = rep.Y,
                                Maximized = rep.Maximized,
                                Minimized = rep.Minimized,
                                Title = rep.ReportName,
                                Url = url,
                                WindowMode = Window.EWindowMode.Frame
                            };
                            form1.Controls.Add(win);
                            i++;
                        }
                    }
                }
            }
        }

        base.OnPreInit(e);
    }
}