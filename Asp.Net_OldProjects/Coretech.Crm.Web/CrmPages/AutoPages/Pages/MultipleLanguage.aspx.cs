using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.MultipleLanguage;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;

public partial class CrmPages_AutoPages_Pages_MultipleLanguage : BasePage
{
    private DynamicSecurity _dynamicSecurity;
    private EditMultipleLanguage _ep;
    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                          (string.IsNullOrEmpty(hdnRecid.Value)
                                                               ? (Guid?)null
                                                               : ValidationHelper.GetGuid(hdnRecid.Value)));


    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            hdnRecid.Value = QueryHelper.GetString("recid");
            hdnObjectId.Value = QueryHelper.GetString("objectid");
            FillSecurity();
            if (!App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].IsMultipleLanguage)
            {
                Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=It is Not Multiple Language");
            }
            if (!_dynamicSecurity.PrvRead)
            {

                Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=" +
                                  App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].UniqueName +
                                  " PrvRead ");
            }
            if (!_dynamicSecurity.PrvWrite)
            {
                btnSaveAndClose.SetDisabled(true);
            }
            TranslateMessages();
            _ep.DataBind();
        }
    }
    protected void BtnSaveClick(object sender, AjaxEventArgs e)
    {
        FillSecurity();
        if (hdnRecid.Value != "")
        {
            if (!_dynamicSecurity.PrvWrite)
            {
                return;
            }
            var list = _ep.GetDataForm();
            var mf= new MuLanguageFactory();
            mf.InsertRecordLanguage(ValidationHelper.GetGuid(hdnRecid.Value), ValidationHelper.GetInteger(hdnObjectId.Value,0), list);

            QScript("  top.R.WindowMng.getActiveWindow().hide();return;");
        }
    }
    private void TranslateMessages()
    {
          btnSaveAndClose.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_CLOSE);
    }
    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        _ep = new EditMultipleLanguage
        {
            
            ObjectId = ValidationHelper.GetInteger(QueryHelper.GetString("objectid"), 0),
            RecordId = ValidationHelper.GetGuid(QueryHelper.GetString("recid")),
        };
        hdnRecid.Value = QueryHelper.GetString("recid");
        hdnObjectId.Value = QueryHelper.GetString("objectid");
        PnlMain.BodyControls.Add(_ep);

        base.OnPreInit(e);
    }
}