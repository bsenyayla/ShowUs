using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Plugin;
using Coretech.Crm.Objects.Crm.WorkFlow;

public partial class CrmPages_Admin_Schedule_SchedulePlugin : System.Web.UI.UserControl
{
    private Guid _recid;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            if (_recid != Guid.Empty)
            {
                SetPluginId();
            }
        }
    }

    private void SetPluginId()
    {
        if (_recid != Guid.Empty)
        {

            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            var de = df.Retrieve(EntityEnum.Schedule.GetHashCode(), _recid, new[] { "PluginId" });
            var val = de.GetUniqueIdentifierValue("PluginId");
            foreach (var value in App.Params.CurrentPluginMessages.Where(t => t.PluginMessageId == val))
            {
                var ID = value.PluginMessageId.ToString();
                var VALUE = value.EntityName + "|" + value.ClassName;
                PluginId.SetValue(ID, VALUE);
            }
        }
    }

    protected override void OnInit(EventArgs e)
    {
        _recid = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
        var p = Page as BasePage;
        if (p != null)
            p.beforeSaveHandler += p_BeforeSaveHandler;
    }
    private void p_BeforeSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool isUpdate)
    {

        de.AddUniqueidentifierProperty("PluginId", ValidationHelper.GetGuid(PluginId.Value));
    }
    protected void PluginListOnRefreshData(object sender, AjaxEventArgs e)
    {
        var l = new List<object>();
        foreach (var value in App.Params.CurrentPluginMessages.Where(t => t.MessageType == PluginMsgType.Schedule))
        {
            l.Add(
                new
                {
                    ID = value.PluginMessageId,
                    VALUE = value.EntityName + "|" + value.ClassName
                });
        }
        PluginId.DataSource = l;
        PluginId.DataBind();
    }
}