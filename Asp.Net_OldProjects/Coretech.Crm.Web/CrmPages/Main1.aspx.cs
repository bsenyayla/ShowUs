using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using Coretech.Crm.Data.Users;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Calendar;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Pages;
using Coretech.Crm.Factory.Site;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Site;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Users;
using Coretech.Crm.Objects.Crm.WorkFlow;
using RefleXFrameWork;
using AjaxEventArgs = RefleXFrameWork.AjaxEventArgs;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
using EButtonType = RefleXFrameWork.EButtonType;
using EMessageType = RefleXFrameWork.EMessageType;
using EpMode = RefleXFrameWork.EpMode;
using Menu = RefleXFrameWork.Menu;
using MenuItem = RefleXFrameWork.MenuItem;
using MessageBox = RefleXFrameWork.MessageBox;
using Parameter = RefleXFrameWork.Parameter;
using ScriptCreater = RefleXFrameWork.ScriptCreater;
using UserSecurity = Coretech.Crm.Provider.Security.UserSecurity;
using System.Text;
using System.Linq;
using static Coretech.Crm.Factory.Crm.Dynamic.DynamicFactory;
using AjaxPro;
using System.Net;

public partial class CrmPages_Main1 : Coretech.Crm.Web.UI.RefleX.BasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            Utility.RegisterTypeForAjax(typeof(AjaxMet));
            SetTopTitle(App.Params.CurrentUser.BusinessUnitIdName + " / " + App.Params.CurrentUser.FullName);
            UserCmp.Value = App.Params.CurrentUser.SystemUserId.ToString();
            TranslateMessages();
            var uf = new UsersFactory();
            var cf = new CalendarFactory();
            var calret = cf.GetUserCalendarMatchList();
            if (calret.Count == 0)
                mnuHome.Items.Remove(mnuHome.Items[2]);


            var periodLogout = uf.IsPeriodLogout();
            if (periodLogout)
            {
                ScriptCreater.AddInstanceScript("document.location.href = '../Login.aspx?dologin=0';");
            }

            var periodAlert = uf.IsPeriodAlert();
            if (periodAlert > -9999)
            {
                var msg = new MessageBox
                {
                    Modal = true,
                    MessageType = EMessageType.Information,
                    Dragable = false,
                    ButtonType = EButtonType.Ok,
                    Width = 500
                };
                msg.Show(string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_PASSWORDPERIODALERT), periodAlert));
                ScriptCreater.AddInstanceScript("PnlCenter.load('Admin/Administrations/User/UserPassWord.aspx');");
                return;
            }

            var change = uf.IsFirstLogin();
            if (change)
            {
                ScriptCreater.AddInstanceScript("PnlCenter.load('Admin/Administrations/User/UserPassWord.aspx');");
            }
            else
            {
                if (!string.IsNullOrEmpty(PageFactory.GetAppHomePageUrl(Page)))
                {
                    //ScriptCreater.AddInstanceScript("PnlCenter.load('" + PageFactory.GetAppHomePageUrl(Page) + "');");
                    ScriptCreater.AddInstanceScript("PnlCenter.load('Admin/Administrations/User/Dashboard.aspx');");
                }

            }
        }
        FawIcon = App.Params.GetConfigKeyValue("FawIcon", ResolveUrl("~/images/favicon.ico"));
        var l = new HtmlLink();
        l.Attributes.Add("rel", "shortcut icon");
        l.Attributes.Add("type", "image/ico");
        l.Attributes.Add("href", FawIcon);
        Page.Controls.Add(l);
    }

    private int menuId = 0;
    public string FawIcon = string.Empty;
    private void SubMenu(Guid ParentSiteMapAreaId, List<SiteMapArea> m, Menu mnu)
    {
        for (int i = 0; i < m.Count; i++)
        {
            var me = m[i];
            if (me.ParentSiteMapAreaId == ParentSiteMapAreaId)
            {
                string strMessage1 = me.IsFavorite
                                         ? CrmLabel.TranslateMessage("CRM.ENTITY_MENU_REMOVE_FAVORITES")
                                         : CrmLabel.TranslateMessage("CRM.ENTITY_MENU_ADD_FAVORITES");
                var strbeforeScript = string.Format("return confirm({0});", SerializeString(strMessage1));
                var submenuitem = new MenuItem
                {
                    Text = me.IsvLabel,
                    ID = "MI_S_" + (menuId++),
                    Icon = me.IsFavorite ? Icon.StarBronze : Icon.StarGrey
                };
                submenuitem.AjaxEvents.IconClick.ExtraParams.Add(new Parameter("SiteMapAreaId",
                                                                               me.SiteMapAreaId.ToString(), EpMode.Value));
                submenuitem.AjaxEvents.IconClick.ExtraParams.Add(new Parameter("Action", me.IsFavorite ? "2" : "1",
                                                                               EpMode.Value));
                submenuitem.AjaxEvents.IconClick.Before = strbeforeScript;
                submenuitem.AjaxEvents.IconClick.Event += new AjaxComponentListener.AjaxEventHandler(MenuIconClick_Event);
                if (!string.IsNullOrEmpty(me.IsvHref))
                    submenuitem.Listeners.Click.Handler = "Navigate('" + me.IsvLabel + "','" + ResolveUrl(me.IsvHref) + "');";

                for (int j = 0; j < m.Count; j++)
                {
                    var siteMapArea = m[j];
                    if (siteMapArea.ParentSiteMapAreaId == me.SiteMapAreaId)
                    {
                        var submenu = new Menu
                        {
                            ID = ID = "MI_M_" + (menuId++)
                        };
                        SubMenu(me.SiteMapAreaId, m, submenu);
                        submenuitem.Menu.Add(submenu);
                    }
                }
                m[i].Added = true;
                mnu.Items.Add(submenuitem);
            }
        }
    }

    void MenuIconClick_Event(object sender, AjaxEventArgs e)
    {
        var id = e.ExtraParams["SiteMapAreaId"];
        var action = e.ExtraParams["Action"];
        if (ValidationHelper.GetInteger(action, 0) == 1)
        {
            (new ModulesFactory()).InsertSiteMapAreaFavorites(ValidationHelper.GetGuid(id));
        }
        else
        {
            (new ModulesFactory()).RemoveSiteMapAreaFavorites(ValidationHelper.GetGuid(id));
        }
        Response.Redirect("Main1.aspx");
        //((MenuItem)sender)
    }

    private void CreateModules()
    {
        var mlist = (new ModulesFactory()).GetUserModules(true);
        var favlist = (new ModulesFactory()).GetUserSiteMapAreaFavorites();

        for (int i = mlist.Count - 1; i >= 0; i--)
        {
            var m = mlist[i];
            var mnu = new Menu
            {
                ID = "MI_M_" + (menuId++)
            };
            for (int j = 0; j < m.SiteMapAreas.Count; j++)
            {
                foreach (var area in favlist)
                {
                    if (area.SiteMapAreaId == m.SiteMapAreas[j].SiteMapAreaId)
                        m.SiteMapAreas[j].IsFavorite = true;
                }
            }

            SubMenu(Guid.Empty, m.SiteMapAreas, mnu);
            var tb = new MenuBarItem
            {
                Text = m.Label,
                Menu = new ItemsCollection<MenuBase> { mnu }
            };

            MenuBar1.Items.Insert(0, tb);
        }
        SubMenu(Guid.Empty, favlist, mnuHome);
        foreach (var area in favlist)
        {
            if (!area.Added)
            {
                area.ParentSiteMapAreaId = Guid.Empty;
                SubMenu(Guid.Empty, new List<SiteMapArea>() { area }, mnuHome);
            }
        }


    }
    private void CreateChangeBuList()
    {
        var uf = new UsersFactory();
        var list = uf.GetAvailableUserBuList();
        if (list.Count == 0)
        {
            ChangeBu.Visible = false;
            return;
        }
        foreach (var me in list)
        {
            var submenuitem = new MenuItem
            {
                Text = me.Value,
                ID = "MI_S_" + me.Key.ToString().Replace("-", "_"),
            };
            submenuitem.AjaxEvents.Click.ExtraParams.Add(new Parameter("BuId", me.Key.ToString(), EpMode.Value));
            submenuitem.AjaxEvents.Click.Event += (Click_Event);
            ChangeBuMenu.Items.Add(submenuitem);
        }
    }

    void Click_Event(object sender, AjaxEventArgs e)
    {
        try
        {
            var buId = e.ExtraParams["BuId"];
            UsersFactory.ChengeActiveUserBusinessUnit(ValidationHelper.GetGuid(buId));
            var sessionId = App.Params.CurrentUser.SessionID;
            var user = UserDB.GetUser(App.Params.CurrentUser.SystemUserId);
            var us = new UserSecurity();
            us.SetDefaultUserCulture(user, sessionId);

            QScript("top.window.location = 'Main1.aspx';");
        }
        catch (Exception exc)
        {
            e.Success = false;
            e.Message = exc.Message;
        }

    }
    void TranslateMessages()
    {
        PnlCenter.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_PNLCENTER);
        MenuItem1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_LOGOUT);
        WindowDeleteList.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETELIST);
        BtnDeleteOk.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        WindowAssignList.Title = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGNLIST);
        BtnAssignOk.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN);
        UserCmp.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.SYSTEMUSER_USERNAME);
        home.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE);
        CrmCalendar.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_CALENDAR);
        pchange.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_USERPASSWORDCHANGE);
        ChangeBu.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_CHANGEBU);
    }
    protected override void OnPreInit(EventArgs e)
    {
        var systemUserSec = DynamicFactory.GetSecurity(EntityEnum.Systemuser.GetHashCode(), App.Params.CurrentUser.SystemUserId);
        if (!(systemUserSec.PrvAppend))
        {
            usermenu.Items.Remove(usermenu.Items[0]);
        }

        if (ValidationHelper.GetBoolean(Coretech.Crm.Factory.App.Params.GetConfigKeyValue("PASSWORD_WRONG_HISTORY", "false")))
        {
            UsersFactory ufac = new UsersFactory();
            string date = ufac.GetUserLastWrongLogin(App.Params.CurrentUser.SystemUserId);
            if (date != string.Empty)
            {
                MenuBar1.Items[1].Text = CrmLabel.TranslateMessage("SYSTEMUSER_LAST_WRONG_LOGIN_DATE") + date;
            }
            else
            {
                MenuBar1.Items[1].Text = string.Empty;
                MenuBar1.Items[1].Visible = false;
            }

        }
        else
        {
            MenuBar1.Items[1].Text = string.Empty;
            MenuBar1.Items[1].Visible = false;
        }




        MenuBar1.Items[2].Text = App.Params.CurrentUser.BusinessUnitIdName + " / " + App.Params.CurrentUser.FullName;
        //QScript("'$('#dvExample').text('"+ App.Params.CurrentUser.FullName + "')");
        MenuBar1.Items[3].Text = CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE);
        MenuBar1.Items[4].Text = CrmLabel.TranslateMessage(LabelEnum.CRM_LOGOUT);

        Page.ClientScript.RegisterStartupScript(typeof(string), "Messages", CrmLabel.GetTranslateLabelMessages(), true);
        var uf = new UsersFactory();

        var IsPeriodAlert = uf.IsPeriodAlert();
        var IsFirstLogin = uf.IsFirstLogin();
        if (IsPeriodAlert > -9999 & IsPeriodAlert <= 0)
            Response.Redirect("../Login.aspx?dologin=0");

        if (!(IsPeriodAlert > -9999) && !IsFirstLogin)
        {
            //CreateModules();
            CreateChangeBuList();
        }
        PnlCenter.AutoLoad.Url = PageFactory.GetAppHomePageUrl(Page);

        base.OnPreInit(e);
    }


    [AjaxMethods]
    public DynamicFactory.OperationReturnType GlobalDelete(string order, string recordId, string objectId)
    {
        var df = new DynamicFactory(ERunInUser.CalingUser);
        return df.GlobalDelete(order, recordId, objectId);
    }
    protected void StoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        /* BT, 2012.04.09 > EP projesi kapsamında login sürecinde yüklenen user listesi performans için kaldırıldı.
        var uf = new UsersFactory();
        UserCmp.DataSource = uf.GetUserList();
        UserCmp.DataBind();
        */
    }



    [AjaxMethods]
    public DynamicFactory.OperationReturnType GlobalAssign(string order, string recordId, string objectId, string assignTo)
    {
        var ret = new DynamicFactory.OperationReturnType { ErrorMessage = "", Order = order, Result = "1" };
        try
        {
            var dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(objectId, 0),
                                                     ValidationHelper.GetGuid(recordId));
            if (!dynamicSecurity.PrvAssign)
            {
                ret.Result = "0";
                ret.ErrorMessage = CrmLabel.TranslateMessage(LabelEnum.CRM_ASSIGN_NOT_PRV);
            }
            else
            {
                var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
                dynamicFactory.Assign(ValidationHelper.GetInteger(objectId, 0), ValidationHelper.GetGuid(recordId),
                                      ValidationHelper.GetGuid(assignTo));
                return ret;
            }
        }
        catch (Exception exception)
        {
            ret.Result = "0";
            ret.ErrorMessage = exception.Message;
        }
        return ret;
    }

    [AjaxNamespace("AjaxMethods")]
    public class AjaxMet : Coretech.Crm.Web.UI.RefleX.BasePage
    {
        public class Menu
        {
            public string MasterMenu { get; set; }
            public string ContentMenu { get; set; }
        }

        [AjaxMethod()]
        public Menu GenerateMenuHtml(string a)
        {
            System.Web.UI.Control control = new Control();
            StringBuilder menuHtml = new StringBuilder();
            StringBuilder menuContent = new StringBuilder();
            Menu m = new Menu();
            try
            {

                StringBuilder tempModule = new StringBuilder();
                StringBuilder tempMenu = new StringBuilder();
                StringBuilder tempSubMenu = new StringBuilder();
                var modules = (new ModulesFactory()).GetUserModules(true);

                foreach (var module in modules)
                {
                    var menus = (new ModulesFactory()).GetUserSiteMapArea(module.SiteMapId);

                    if (menus != null && menus.Count > 0)
                    {
                        for (int i = 0; i < menus.Count; i++

                            )
                        {
                            // Alt menü bul
                            var subMenus = menus.Where(x => x.ParentSiteMapAreaId == menus[i].SiteMapAreaId).ToList();

                            if (subMenus != null && subMenus.Count > 0)
                            {
                                foreach (var subMenu in subMenus)
                                {
                                    if (subMenu.SiteMapAreaId != menus[i].SiteMapAreaId)
                                    {
                                        tempSubMenu.Append(string.Format(@"<li style=""cursor:pointer;""><a onclick=""{0};"">{1}</a></li>", "Navigate('" + subMenu.IsvLabel + "', '" + control.ResolveUrl(subMenu.IsvHref) + "');", "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + subMenu.IsvLabel));
                                    }
                                }
                                tempMenu.Append(string.Format(@"<li style=""cursor:pointer;""><a href= ""{0}"">{1}</a><ul>{2}</ul></li>", "#", menus[i].IsvLabel, tempSubMenu.ToString()));
                                tempSubMenu.Clear();
                                continue;
                            }

                            tempMenu.Append(string.Format(@"<li style=""cursor:pointer;""><a onclick=""{0};"">{1}</a></li>", "Navigate('" + menus[i].IsvLabel + "', '" + control.ResolveUrl(menus[i].IsvHref) + "');", menus[i].IsvLabel));
                            menuContent.Append(string.Format(@"<li style=""cursor:pointer;""><a onclick=""{0};"">{1}</a></li>", "Navigate('" + menus[i].IsvLabel + "', '" + control.ResolveUrl(menus[i].IsvHref) + "');", menus[i].IsvLabel));
                        }


                    }
                    
                    if (module.IsActive)
                    {
                        menuHtml.Append(string.Format(@"<li class=""active"" style=""cursor:pointer;""><h3><a href=""#""><i class=""fa fa-lg fa-angle-double-right""></i>" + module.Label + "</a></h3><ul>{0}</ul></li>", tempMenu.ToString()));
                    }
                    else
                    {
                        menuHtml.Append(string.Format(@"<li style=""cursor:pointer;""><h3><a href=""#""><i class=""fa fa-lg fa-angle-double-right""></i>" + module.Label + "</a></h3><ul>{0}</ul></li>", tempMenu.ToString()));
                    }

                    tempMenu.Clear();
                }
            }
            catch (Exception)
            {
                return new Menu();
            }


            m.MasterMenu = menuHtml.ToString();
            m.ContentMenu = menuContent.ToString();
            return m;
        }

        [AjaxMethod()]
        public string GetHomePageParameters()
        {
            UsersFactory ufac = new UsersFactory();
            string date = ufac.GetUserLastWrongLogin(App.Params.CurrentUser.SystemUserId);
            string ipAdresi = string.Empty;
            try
            {
                string bilgisayarAdi = Dns.GetHostName();
                ipAdresi = Dns.GetHostByName(bilgisayarAdi).AddressList[0].ToString();
            }
            catch (Exception)
            {
            }



            return string.Format("{0};{1};{2};{3};{4};{5};{6};{7};{8};{9};{10}",
                App.Params.CurrentUser.BusinessUnitIdName,
                App.Params.CurrentUser.FullName,
                CrmLabel.TranslateMessage("SYSTEMUSER_LAST_WRONG_LOGIN_DATE") + date,
                CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE),
                CrmLabel.TranslateMessage(LabelEnum.CRM_HOMEPAGE),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_SEARCH"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_MENU"),
                CrmLabel.TranslateMessage("CRM.NEW_PROCESSMONITORING_MAIN_WELCOME"),
                CrmLabel.TranslateMessage(LabelEnum.CRM_LOGOUT),
                CrmLabel.TranslateMessage(LabelEnum.CRM_USERPASSWORDCHANGE),
                ipAdresi.Length > 2 ? "Sunucu: " + ipAdresi.Substring(ipAdresi.Length - 2, 2) : string.Empty
                );


        }

    }
}

