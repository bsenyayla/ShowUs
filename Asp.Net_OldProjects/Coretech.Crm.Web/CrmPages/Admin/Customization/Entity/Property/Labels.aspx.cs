using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Labels;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Web.UI;
using Coolite.Ext.Web;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm;

public partial class CrmPages_Admin_Customization_Entity_Property_Labels : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_Labels()
    {
        ObjectId = EntityEnum.Language.GetHashCode();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Language PrvWrite");
        }
        
        if (!Ext.IsAjaxRequest && !IsPostBack)
        {
            if (!(DynamicSecurity.PrvDelete))
            {
                BtnDelete.Visible = false;
            }

            if (!(DynamicSecurity.PrvCreate))
            {
                BtnNew.Visible = false;
            }

            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId")))
            {
                objectid.Value = QueryHelper.GetString("ObjectId");

                var lf = new LangFactory();
                var ll = lf.GetLanguages(true);

                foreach (var t in ll)
                {
                    if (t.Flag != null) ScriptManager1.RegisterIcon(((Icon)t.Flag));
                }

                Language.Value = App.Params.CurrentUser.LanguageId;
                _grdsma.Reload();
            }
        }
    }

    protected void LMessageSaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var lf = new LabelsFactory();
            lf.SaveLabelMessage(ValidationHelper.GetInteger(objectid.Value, 0), ValidationHelper.GetString(LMessage.Value));
            _grdsma.Reload();
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void LanguageOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            _grdsma.Reload();
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void Store1RefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var lf = new LangFactory();
        var ll = lf.GetLanguages(true);

        var dt = new DataTable("Data");
        dt.Columns.Add("iconCls", typeof(string));
        dt.Columns.Add("RegionName", typeof(string));
        dt.Columns.Add("LangId", typeof(string));
        foreach (var t in ll)
        {
            var newRow = dt.NewRow();
            if (t.Flag != null)
            {
                var cls = ScriptManager1.GetIconClass(((Icon)t.Flag));
                newRow["iconCls"] = cls.IndexOf("{") > 0 ? cls.Substring(1, cls.IndexOf("{") - 1) : "";
            }
            newRow["RegionName"] = t.RegionName;
            newRow["LangId"] = t.LangId.ToString();
            dt.Rows.Add(newRow);
        }

        store1.DataSource = dt;
    }

    protected void Store2RefreshData(object sender, StoreRefreshDataEventArgs e)
    {
        var lf = new LabelsFactory();
        var ll = lf.GetLanguages(ValidationHelper.GetInteger(objectid.Value, 0), ValidationHelper.GetInteger(e.Parameters["lng"], 0));

        store2.DataSource = ll;
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);

            var data = new List<Labels>();

            for (int i = 0; i < degerler.Length; i++)
            {
                var item = new Labels
                {
                    Value = ValidationHelper.GetString(degerler[i]["Value"]),
                    LangId = ValidationHelper.GetInteger(e.ExtraParams["lng"]),
                    ObjectId = ValidationHelper.GetGuid(degerler[i]["ObjectId"]),
                    LabelId = ValidationHelper.GetGuid(degerler[i]["LabelId"]),
                    ObjId = QueryHelper.GetInteger("ObjectId")
                };
                data.Add(item);
            }

            var lf = new LabelsFactory();
            lf.DeleteLabels(data);
            _grdsma.Reload();
            MessageShow("Silme Tamamlandı.");
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }

    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var json = e.ExtraParams["Values"];
            var degerler = JSON.Deserialize<Dictionary<string, string>[]>(json);

            var data = new List<Labels>();

            for (int i = 0; i < degerler.Length; i++)
            {
                var item = new Labels
                               {
                                   Value = ValidationHelper.GetString(degerler[i]["Value"]),
                                   LangId = ValidationHelper.GetInteger(e.ExtraParams["lng"]),
                                   ObjectId = ValidationHelper.GetGuid(degerler[i]["ObjectId"]),
                                   LabelId = ValidationHelper.GetGuid(degerler[i]["LabelId"]),
                                   ObjId = QueryHelper.GetInteger("ObjectId")
                               };
                data.Add(item);
            }

            var lf = new LabelsFactory();
            lf.SaveLabels(data);
            _grdsma.Reload();
            MessageShow("Kaydetme Tamamlandı.");
        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}