using System;
using System.Collections.Generic;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Labels;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Provider;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm;
using RefleXFrameWork;

public partial class CrmPages_Admin_Customization_Entity_Property_LabelsReflex : Coretech.Crm.Web.UI.RefleX.AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_LabelsReflex()
    {
        ObjectId = EntityEnum.Language.GetHashCode();
    }
    void TranslateMessages()
    {

        Save.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        BtnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        BtnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        _grdsma.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_OBJECT_NAME);
        _grdsma.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_TYPE);
        _grdsma.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_VALUE);
        Label1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_LANGUAGE);
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Language PrvWrite");
        }

        if (!RefleX.IsAjxPostback)
        {
            if (!(DynamicSecurity.PrvDelete))
            {
                BtnDelete.Visible = false;
            }

            if (!(DynamicSecurity.PrvCreate))
            {
                BtnNew.Visible = false;
            }

            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId","")))
            {
                objectid.Value = QueryHelper.GetString("ObjectId","");

                var lf = new LangFactory();
                var ll = lf.GetLanguages(true);

                var text = "";
                foreach (var t in ll)
                {
                    if (App.Params.CurrentUser.LanguageId.ToString() == t.LangId.ToString())
                        text = t.RegionName;
                    Language.AddItem(new ListItem(t.LangId.ToString(), t.RegionName));
                }
                ScriptCreater.AddInstanceScript(string.Format("Language.setValue('{0}','{1}');", App.Params.CurrentUser.LanguageId, text));
                _grdsma.Reload();
            }
        }
    }

    protected void LMessageSaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (LMessage.Value.IndexOf(" ") == -1)
            {
                var lf = new LabelsFactory();
                lf.SaveLabelMessage(ValidationHelper.GetInteger(objectid.Value, 0),
                                    ValidationHelper.GetString(LMessage.Value));
                _grdsma.Reload();
            }
            else
            {
                var msg = new MessageBox();
                msg.Show("Not Space Enter!");
            }
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }
    protected void PublishAll_Click(object sender, AjaxEventArgs e)
    {
        CrmApplication.LoadApplicationData();
        new MessageBox("Publish Completed");
    }
    protected void LanguageOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            _grdsma.Reload();
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }


    protected void Store2RefreshData(object sender, AjaxEventArgs e)
    {
       
     //vf.GetFormListByObjectId(ValidationHelper.GetInteger(hdnObjectId.Value, 0));
        var lf = new LabelsFactory();
          _grdsma.DataSource = lf.GetLanguages(ValidationHelper.GetInteger(objectid.Value, 0), ValidationHelper.GetInteger(Language.Value, 1055));
        _grdsma.DataBind();
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
      //      var json = e.ExtraParams["Values"];
            var degerler = _grdsma.SelectionModel[0] as RowSelectionModel;
            var data = new List<Labels>();
            if (degerler != null)
            {
                foreach (var t in degerler.SelectedRows)
                {
                    data.Add(new Labels
                    {
                        ObjId = ValidationHelper.GetInteger(objectid.Value, 0),
                        ObjectId = ValidationHelper.GetGuid(t["ObjectId"]),
                        LabelId = ValidationHelper.GetGuid(t["LabelId"]),
                        Value = ValidationHelper.GetString(t["Value"]),
                        LangId = ValidationHelper.GetInteger(Language.Value, 1055),
                        PicklistValue = ValidationHelper.GetString(t["PicklistValue"]),
                    }
                        );
                }
            }
            var lf = new LabelsFactory();
            lf.DeleteLabels(data);
            _grdsma.Reload();
            var msg = new MessageBox();
            msg.Show("Kayıt Silindi");
        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }

    protected void SaveOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var degerler = _grdsma.AllRows;

            var data = new List<Labels>();

            if (degerler != null)
            {
                foreach (var t in degerler)
                {
                    data.Add(new Labels
                    {
                        ObjId = ValidationHelper.GetInteger(objectid.Value,0),
                        ObjectId = ValidationHelper.GetGuid(t["ObjectId"]),
                        LabelId = ValidationHelper.GetGuid(t["LabelId"]),
                        Value = ValidationHelper.GetString(t["Value"]),
                        LangId = ValidationHelper.GetInteger(Language.Value,1055) ,
                        PicklistValue = ValidationHelper.GetString(t["PicklistValue"])
                    }
                        );
                }

                var lf = new LabelsFactory();
                lf.SaveLabels(data);
                _grdsma.Reload();
                var msg = new MessageBox();
                msg.Show("Kayıt Kaydedildi");
            }

        }
        catch (Exception ex)
        {
            var msg = new MessageBox();
            msg.Show(ex.Message);
        }
    }
}