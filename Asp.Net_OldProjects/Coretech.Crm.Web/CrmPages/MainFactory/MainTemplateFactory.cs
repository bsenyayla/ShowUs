using AjaxPro;
using Coretech.Crm.Factory.Site;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace Coretech.Crm.Web.CrmPages.MainFactory
{
    [AjaxNamespace("AjaxMethods")]
    public class MainTemplateFactory : Coretech.Crm.Web.UI.RefleX.BasePage
    {

        [AjaxMethods]
        public string GenerateMenuHtml(string a)
        {
            StringBuilder menuHtml = new StringBuilder();
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
                        for (int i = 0; i < menus.Count; i++)
                        {
                            // Alt menü bul
                            var subMenus = menus.Where(x => x.ParentSiteMapAreaId == menus[i].SiteMapAreaId).ToList();

                            if (subMenus != null && subMenus.Count > 0)
                            {
                                foreach (var subMenu in subMenus)
                                {
                                    if (subMenu.SiteMapAreaId != menus[i].SiteMapAreaId)
                                    {
                                        tempSubMenu.Append(string.Format(@"<li><a onclick=""{0}"">{1}</a></li>", "Navigate('" + menus[i].IsvLabel + "', '" + ResolveUrl(menus[i].IsvHref) + "');", subMenu.IsvLabel));
                                    }
                                }
                                tempMenu.Append(string.Format(@"<li><a href= ""{0}"">{1}</a><ul>{2}</ul></li>", "#", menus[i].IsvLabel, tempSubMenu.ToString()));
                                tempSubMenu.Clear();
                                continue;
                            }

                            tempMenu.Append(string.Format(@"<li><a onclick=""{0}"">{1}</a></li>", "Navigate('" + menus[i].IsvLabel + "', '" + ResolveUrl(menus[i].IsvHref) + "');", menus[i].IsvLabel));
                        }


                    }

                    menuHtml.Append(string.Format(@"<li><h3><a href=""#""><i class=""fa fa-lg fa-tasks""></i>" + module.Label + "</a></h3><ul>{0}</ul></li>", tempMenu.ToString()));
                    tempMenu.Clear();
                }
            }
            catch (Exception)
            {
                return "";
            }



            return menuHtml.ToString();
        }
    }
}