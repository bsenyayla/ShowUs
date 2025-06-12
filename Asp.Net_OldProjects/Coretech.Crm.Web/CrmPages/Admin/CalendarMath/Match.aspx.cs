using System;
using System.Collections.Generic;
using System.Linq;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.View;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Calendar;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public partial class CrmPages_Admin_CalendarMath_Match : BasePage
{

    private DynamicSecurity _dynamicSecurity;
    private int _objectId = 0;
    private Guid _recId = Guid.Empty;
    private DynamicEntity dynamicEntity = null;
    DynamicFactory dynamicFactory;
    private void TranslateMessages()
    {
        btnSave.AjaxEvents.Click.EventMask.Msg = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVING);
        btnSave.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        btnSaveAndNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_NEW);
        btnSaveAndClose.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE_AND_CLOSE);
        btnRefresh.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_EDITSCREEN_REFRESH);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        btnAction.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_ACTION);
        lblError.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_YOUCANNOTUPDATE);
        btnReport.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_REPORTMENU);
        btnMlValues.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_MULTIPELANGUAGE);

    }

    void FillSecurity()
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(ValidationHelper.GetInteger(hdnObjectId.Value, 0),
                                                          (string.IsNullOrEmpty(hdnRecid.Value)
                                                               ? (Guid?)null
                                                               : ValidationHelper.GetGuid(hdnRecid.Value)));


    }

    protected void Page_Load(object sender, EventArgs e)
    {
        hdnRecid.Value = QueryHelper.GetString("recid");
        hdnObjectId.Value = QueryHelper.GetString("objectid");
        dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);
        pnlError.Visible = false;
        dynamicEntity = new DynamicEntity(ValidationHelper.GetInteger(hdnObjectId.Value, 0));

        _objectId = ValidationHelper.GetInteger(hdnObjectId.Value, 0);
        _recId = ValidationHelper.GetGuid(hdnRecid.Value);
        if (!Page.IsPostBack && !RefleXFrameWork.RefleX.IsAjxPostback)
        {
            FillEntityData();

            Page.Title =
               App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].GetLabel(
                   App.Params.CurrentUser.LanguageId) + " " +
                   CrmLabel.TranslateMessage(LabelEnum.CRM_EDIT_PAGE) + " ";

            hdnEntityId.Value = App.Params.CurrentEntity[QueryHelper.GetInteger("objectid")].EntityId.ToString();
            SetClientScript();
            TranslateMessages();
            btnMlValues.Visible = false;
            if (_recId != Guid.Empty && _recId != GuidHelper.EmtyRecordId)
            {
                dynamicEntity = dynamicFactory.RetrieveWithOutPlugin(EntityEnum.Calendarmatch.GetHashCode(), _recId, DynamicFactory.RetrieveAllColumns);
                fillSavedData();
                if (dynamicEntity != null)
                {
                    Page.Title += " ... ";
                    hdnRecidName.Value =
                        dynamicEntity.GetStringValue(
                            EntityAttributeFactory.GetAttributeValString(
                                ValidationHelper.GetInteger(hdnObjectId.Value, 0)));
                    Page.Title += hdnRecidName.Value;
                    var statuscode = dynamicEntity.GetPicklistValue("statuscode");
                    if (statuscode == 2)
                    {
                        EditToolbar.SetVisible(false);
                        pnlError.Visible = true;
                    }
                }

                //ViewComboField.Disabled = true;
                //EntityComboField.Disabled = true;

            }
            else
            {
                AllDayComboField.Disabled = true;

                CalenderTypeComboField.Disabled = true;
                DetailTextComboField.Disabled = true;
                EndDateComboField.Disabled = true;
                HeaderTextComboField.Disabled = true;
                ResourceComboField.Disabled = true;
                StartDateComboField.Disabled = true;
            }

            QScript("try{parent.Tabpanel1.setTabTitle(window.name.substring(6,window.name.length), window.document.title);} catch(e){}");
            FillSecurity();
            if (EditToolbar.Visible)
            {
                if (hdnRecid.Value != "")
                {
                    if (!_dynamicSecurity.PrvWrite)
                    {
                        btnSave.SetDisabled(true);
                        btnSaveAndNew.SetDisabled(true);
                        btnSaveAndClose.SetDisabled(true);
                    }
                    else
                    {
                        if (App.Params.CurrentEntity[ValidationHelper.GetInteger(hdnObjectId.Value, 0)].IsMultipleLanguage)
                            btnMlValues.Visible = true;
                    }

                    if (!_dynamicSecurity.PrvDelete)
                    {
                        btnDelete.SetDisabled(true);
                    }
                }
                else
                {

                    if (!_dynamicSecurity.PrvCreate)
                    {
                        btnSave.SetDisabled(true);
                        btnSaveAndNew.SetDisabled(true);
                        btnSaveAndClose.SetDisabled(true);
                    }
                    btnDelete.SetDisabled(true);
                }
            }


        }





    }
    void SetClientScript()
    {
        var beforeScript = "return CrmValidateForm(msg,e);";
        btnSave.AjaxEvents.Click.Before = beforeScript;
        btnSave.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){window.location=UpdatedUrl.getValue();}";

        btnSaveAndNew.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndNew.AjaxEvents.Click.Success = "RefreshParetnGrid(false);if(UpdatedUrl.getValue()!=''){window.location=UpdatedUrl.getValue();}";

        btnSaveAndClose.AjaxEvents.Click.Before = beforeScript;
        btnSaveAndClose.AjaxEvents.Click.Success = "if(UpdatedUrl.getValue()!=''){RefreshParetnGrid(true);}";

    }
    protected void BtnSaveClick(object sender, AjaxEventArgs e)
    {
        FillSecurity();
        /*Ic Yetki Kontrolu*/
        if (hdnRecid.Value != "")
        {
            if (!_dynamicSecurity.PrvWrite)
            {
                return;
            }
        }
        else
        {
            if (!_dynamicSecurity.PrvCreate)
            {
                return;
            }

        }

        if (e.ExtraParams["Action"] != null)
        {
            var action = ValidationHelper.GetInteger(e.ExtraParams["Action"], 0);

            var cm = new CalendarMatch
            {
                AllDayId = ValidationHelper.GetGuid(AllDayComboField.Value),
                CalendarMatchname = ValidationHelper.GetString(CalendarMatchnameTxt.Value),
                CalenderTypeId = ValidationHelper.GetGuid(CalenderTypeComboField.Value),
                DetailTextId = ValidationHelper.GetGuid(DetailTextComboField.Value),
                EndDateId = ValidationHelper.GetGuid(EndDateComboField.Value),
                EntityId = ValidationHelper.GetGuid(EntityComboField.Value),
                HeaderTextId = ValidationHelper.GetGuid(HeaderTextComboField.Value),
                ResourceId = ValidationHelper.GetGuid(ResourceComboField.Value),
                StartDateId = ValidationHelper.GetGuid(StartDateComboField.Value),
                ViewQueryId = ValidationHelper.GetGuid(ViewComboField.Value)
            };
            cm.ObjectId = EntityFactory.GetEntityObjectId(cm.EntityId);

            var MatchXml = CalendarMatch.SerializeCalendarMatch(cm);
            dynamicEntity.AddStringProperty("MatchXml", MatchXml);
            dynamicEntity.AddLookupProperty("EntityId", "", cm.EntityId);
            dynamicEntity.AddStringProperty("calendarmatchname", cm.CalendarMatchname);



            try
            {
                if (hdnRecid.Value != string.Empty)
                {
                    dynamicEntity.AddKeyProperty("calendarmatchId", _recId);
                    dynamicFactory.Update(ValidationHelper.GetInteger(hdnObjectId.Value, 0), dynamicEntity);
                }
                else
                {
                    var gdNew = dynamicFactory.Create(ValidationHelper.GetInteger(hdnObjectId.Value, 0), dynamicEntity);
                    hdnRecid.Value = gdNew.ToString();
                }
            }
            catch (CrmException ex)
            {
                var msg = new MessageBox();
                if (ex.MessageType == CrmException.EMessageTpe.Error)
                    msg.MessageType = EMessageType.Error;
                msg.Modal = true;
                msg.Show(CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE), " ", ex.ErrorMessage);
                return;

            }


            var query = new Dictionary<string, string>();
            switch (action)
            {
                case 1:
                    query.Add("recid", hdnRecid.Value);
                    QScript("UpdatedUrl.setValue(\"" + QueryHelper.AddUpdateString(query) + "\");");
                    break;
                case 2:
                    query.Add("recid", "");
                    QScript("UpdatedUrl.setValue(\"" + QueryHelper.AddUpdateString(query) + "\");");
                    break;
                case 3:
                    query.Add("recid", "");
                    QScript("UpdatedUrl.setValue(\"" + QueryHelper.AddUpdateString(query) + "\");");
                    break;
            }

        }
    }
    private void fillSavedData()
    {

        if (dynamicEntity != null)
        {
            var matchXml = dynamicEntity.GetStringValue("MatchXml");
            var entityId = dynamicEntity.GetLookupValue("EntityId");
            var calendarMatchname = dynamicEntity.GetStringValue("calendarmatchname");
            CalendarMatchnameTxt.Value = calendarMatchname.ToString();


            var cm = new CalendarMatch();
            if (!string.IsNullOrEmpty(matchXml))
            {
                cm = CalendarMatch.XmlDeSerializeCalendarMatch(matchXml);

                if (cm.EntityId != Guid.Empty)
                {
                    EntityComboField.Value = cm.EntityId.ToString();
                }

                if (cm.ViewQueryId != Guid.Empty)
                {
                    ViewComboField.Value = cm.ViewQueryId.ToString();
                }

                if (cm.AllDayId != Guid.Empty)
                {
                    AllDayComboField.Value = cm.AllDayId.ToString();
                }

                if (cm.CalenderTypeId != Guid.Empty)
                {
                    CalenderTypeComboField.Value = cm.CalenderTypeId.ToString();
                }

                if (cm.DetailTextId != Guid.Empty)
                {
                    DetailTextComboField.Value = cm.DetailTextId.ToString();

                }

                if (cm.EndDateId != Guid.Empty)
                {
                    EndDateComboField.Value = cm.EndDateId.ToString();
                }


                if (cm.HeaderTextId != Guid.Empty)
                {
                    HeaderTextComboField.Value = cm.HeaderTextId.ToString();
                }

                if (cm.ResourceId != Guid.Empty)
                {
                    ResourceComboField.Value = cm.ResourceId.ToString();
                }

                if (cm.StartDateId != Guid.Empty)
                {
                    StartDateComboField.Value = cm.StartDateId.ToString();
                }

            }

        }

    }
    private List<object> _lookupList = new List<object>();
    private List<object> _dateList = new List<object>();
    private List<object> _textList = new List<object>();
    private List<object> _bitList = new List<object>();
    private List<object> _calTypeList = new List<object>();

    private void fillListData()
    {
        //var eaf = new EntityAttributeFactory();
        if (!string.IsNullOrEmpty(EntityComboField.Value) && ValidationHelper.GetGuid(EntityComboField.Value) != Guid.Empty)
        {
            
            foreach (var attribute in 
                (App.Params.CurrentEntityAttribute.Values.Where(a => a.EntityId == ValidationHelper.GetGuid(EntityComboField.Value)))
                )
            {
                var desc = string.Empty;
                var ea = App.Params.CurrentEntityAttribute[attribute.AttributeId];
                desc = ea.AttributeTypeIdname;
                switch (desc)
                {
                    case "datetime":
                    case "smalldatetime":
                        _dateList.Add(new { attribute.AttributeId, Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
                        break;
                    case "html":
                    case "ntext":
                    case "nvarchar":
                    case "text":
                    case "varchar":

                        _textList.Add(new { attribute.AttributeId, Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
                        break;
                    case "lookup":
                    case "owner":
                        if (ea.ReferencedObjectId == EntityEnum.CalendarType.GetHashCode())
                            _calTypeList.Add(new { attribute.AttributeId, Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
                        else
                        {
                            _lookupList.Add(
                                new
                                {
                                    attribute.AttributeId,
                                    Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)
                                });
                        }
                        break;
                    case "bit":
                        _bitList.Add(new { attribute.AttributeId, Label = ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId) });
                        break;
                }
            }
        }
    }


    private void FillEntityData()
    {
        var elist = App.Params.CurrentEntity;
        foreach (var entity in elist.Values)
        {
            EntityComboField.Items.Add(new ListItem(entity.EntityId.ToString(), entity.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)));
        }

        QScript("setTimeout(new Function(\"SetMaskScreen(false);\"),100);");
    }


    protected void ResourceComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        ResourceComboField.DataSource = _lookupList;
        ResourceComboField.DataBind();


    }
    protected void StartDateComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        StartDateComboField.DataSource = _dateList;
        StartDateComboField.DataBind();

    }
    protected void EndDateComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        EndDateComboField.DataSource = _dateList;
        EndDateComboField.DataBind();
    }
    protected void AllDayComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        AllDayComboField.DataSource = _bitList;
        AllDayComboField.DataBind();
    }
    protected void HeaderTextComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        HeaderTextComboField.DataSource = _textList;
        HeaderTextComboField.DataBind();

    }
    protected void DetailTextComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        DetailTextComboField.DataSource = _textList;
        DetailTextComboField.DataBind();

    }
    protected void CalenderTypeComboFieldLoad(object sender, AjaxEventArgs e)
    {
        fillListData();
        CalenderTypeComboField.DataSource = _calTypeList;
        CalenderTypeComboField.DataBind();
    }

    protected void ViewComboFieldLoad(object sender, AjaxEventArgs e)
    {
        ViewFactory vf = new ViewFactory();
        var entityId = EntityComboField.Value;
        if (EntityComboField.Value != null)
        {
            var objectId = EntityFactory.GetEntityObjectId(ValidationHelper.GetGuid(entityId));
            var viewList = vf.GetViewListByObjectId(objectId);
            var oList = new List<Object>();
            foreach (var view in viewList)
            {
                oList.Add(new { ViewQueryId = view.ViewQueryId, Name = view.Name });
            }

            ViewComboField.DataSource = oList;
            ViewComboField.DataBind();

        }

    }
}