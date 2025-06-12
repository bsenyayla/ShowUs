using System;
using System.Collections.Generic;
using Coolite.Ext.Web;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm.Survey;
using Coretech.Crm.Objects.Crm.Survey;

public partial class CrmPages_Admin_Customization_Survey_Survey : AdminPage
{
    public CrmPages_Admin_Customization_Survey_Survey()
    {
        base.ObjectId = EntityEnum.Survey.GetHashCode();
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvRead))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Survey PrvRead");
        }
        if (!Ext.IsAjaxRequest)
        {
        }
    }

    protected void StoreOnRefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var sr = new SurveyFactory();
        store1.DataSource = sr.GetSurveyList();
        store1.DataBind();
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);
            hdnSurveyId.Text = degerler[0]["SurveyId"];
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void Publishing(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);


            var sl = new List<SurveyList>();
            for (int i = 0; i < degerler.Length; i++)
            {
                var item = new SurveyList();
                if (Convert.ToBoolean(degerler[i]["Publish"]))
                {
                    item.SurveyId = new Guid(degerler[i]["SurveyId"]);
                    sl.Add(item);
                }
            }

            var sf = new SurveyFactory();
            var publish = sf.PublishSurvey(sl);
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}