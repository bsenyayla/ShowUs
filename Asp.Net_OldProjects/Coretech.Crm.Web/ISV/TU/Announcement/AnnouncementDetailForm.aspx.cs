using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using System;
using System.Data;
using System.Web.UI;

namespace Coretech.Crm.Web.ISV.TU.Announcement
{
    public partial class AnnouncementDetailForm : BasePage
    {
        private Guid announcementId = ValidationHelper.GetGuid(QueryHelper.GetString("recId"));

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetAnnouncementDetail();
            }

        }
        public void GetAnnouncementDetail()
        {
            var sd = new StaticData();
            sd.AddParameter("AnnouncementId", DbType.Guid, announcementId);
            DataTable dt = sd.ReturnDatasetSp(@"spTuGetAnnouncementDetail").Tables[0];

            string tablestring = "";
            tablestring = tablestring + @"<table id=""example"" class=""table table-striped"" cellspacing=""0"" width=""100%""><thead><tr><th></th></tr></thead><tbody>";

            if (dt.Rows.Count > 0)
            {

                foreach (DataRow dr in dt.Rows)
                {

                        tablestring = tablestring +
                           "<tr><td><b>" 
                           + dr[0].ToString() + "</b></hr></td></tr><tr><td>" 
                           + dr[1].ToString() + "</td></tr><tr><td><a download='"
                           + dr[4].ToString() + "' href='data:" 
                           + dr[3].ToString() + "; base64,"
                           + dr[2].ToString() + "'>"
                           + dr[4].ToString() + "</a></td></tr>";
                }
            }

            tablestring = tablestring + "</tbody></table>";
            Grid.InnerHtml = tablestring;
        }
    }
}