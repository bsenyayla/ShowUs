using System;
using System.Linq;
using Coolite.Ext.Web;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using System.Collections.Generic;
using Coretech.Crm.Objects.Crm.Survey;
using Coretech.Crm.Factory.Crm.Survey;

public partial class CrmPages_Admin_Customization_Survey_SurveyScript : AdminPage
{
    public CrmPages_Admin_Customization_Survey_SurveyScript()
    {
        base.ObjectId = EntityEnum.Survey.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvCreate && DynamicSecurity.PrvAppend ))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Survey  PrvAppend PrvCreate");
        }
        if (!Ext.IsAjaxRequest)
        {
            hdnSurveyId.Value = QueryHelper.GetString("SurveyId");
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var sr = new SurveyFactory();
        store1.DataSource = sr.GetQuestionScript(new Guid(hdnSurveyId.Value.ToString()));
        store1.DataBind();
    }

    protected void Store2OnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var sr = new SurveyFactory();
        store2.DataSource = sr.GetSurveyScript(new Guid(hdnSurveyId.Value.ToString()), new Guid(hdnanswerid.Value.ToString()));
        store2.DataBind();

        btnScriptSave.Disabled = e.TotalCount > 0;
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);

            hdnanswerid.Text = degerler[0]["SpqAnswerId"];
            GridPanel1.Reload();
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void ScriptSave(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);

            var s = new SurveyFactory();

            var ss = degerler.Select(t => new SurveyScript
                                              {
                                                  SurveyScriptId = new Guid(t["SurveyScriptId"]), 
                                                  SurveyId = new Guid(hdnSurveyId.Value.ToString()), 
                                                  SPartId = new Guid(t["SPartId"]), 
                                                  SpQuestionId = new Guid(t["SpQuestionId"]), 
                                                  SpqAnswerId = new Guid(hdnanswerid.Text), 
                                                  Show = ValidationHelper.GetBoolean(t["Show"]),
                                                  Hide = ValidationHelper.GetBoolean(t["Hide"])
                                              }).ToList();

            s.SaveSurveyScript(ss);
            GridPanel1.Reload();
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}