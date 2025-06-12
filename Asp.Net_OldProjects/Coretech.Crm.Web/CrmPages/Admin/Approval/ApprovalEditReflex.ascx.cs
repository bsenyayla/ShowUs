using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Approval;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using RefleXFrameWork;

public partial class CrmPages_Admin_Approval_ApprovalEditReflex : System.Web.UI.UserControl
{
    private Guid _recid;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            if (_recid != Guid.Empty)
            {
                var df = new DynamicFactory(ERunInUser.SystemAdmin);
                var de = df.Retrieve(EntityEnum.ApprovalMechanism.GetHashCode(), _recid, new[] {"KeyValuesXml"});
                var val = de.GetStringValue("KeyValuesXml");
                if (!string.IsNullOrEmpty(val))
                {
                    var list = KeyList.XmlDeSerializeList(val);
                    var l = new List<object>();
                    foreach (var gattr in list)
                    {
                        if (App.Params.CurrentEntityAttribute.ContainsKey(gattr))
                        {
                            l.Add(
                                new
                                {
                                    TargetAtrributeId = gattr.ToString(),
                                    TargetAtrributeIdName =
                                        App.Params.CurrentEntityAttribute[gattr].GetLabelWithUniqueName(
                                            App.Params.CurrentUser.LanguageId)
                                });


                        }


                    }
                    if (l.Count > 0)
                    {
                        AttributeList.DataSource = l;
                        AttributeList.DataBind();
                    }
                }

            }
        }

    }
    protected void EditTargetAtrributeIdOnRefreshData(object sender, AjaxEventArgs e)
    {
        var EntityId = (CrmComboComp)Page.FindControl("EntityId_Container");
        var l = new List<object>();
        foreach (var value in EntityAttributeFactory.GetAttributeEditableName(ValidationHelper.GetGuid(EntityId.Value)).OrderBy(ea => ea.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)))
        {
            l.Add(
                new
                {
                    EditTargetAtrributeId = value.AttributeId,
                    EditTargetAtrributeIdName = value.GetLabelWithUniqueName(App.Params.CurrentUser.LanguageId)
                });
        }
        EditTargetAtrributeId.DataSource = l;
        EditTargetAtrributeId.DataBind();
    }

    protected override void OnInit(EventArgs e)
    {
        _recid = ValidationHelper.GetGuid(QueryHelper.GetString("recid"));
        var btnSaveAsCopy = Page.FindControl("btnSaveAsCopy_Container") as ToolbarButton;
        if (btnSaveAsCopy != null)
            btnSaveAsCopy.SetVisible(false);
        var p = Page as BasePage;
        if (p != null)
            p.beforeSaveHandler += p_BeforeSaveHandler;
        base.OnInit(e);
    }

    void p_BeforeSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool isUpdate)
    {
        var gdl = AttributeList.AllRows;
        if (gdl != null)
        {
            var k = new KeyList();
            foreach (var item in gdl)
            {
                k.AttributeIdList.Add(ValidationHelper.GetGuid(item.TargetAtrributeId));
            }
            de.AddStringProperty("KeyValuesXml", KeyList.XmlSerializeList(k.AttributeIdList));
        }
        else
        {
            //MessageBox m = new MessageBox();
            //m.Height = 200;
            //m.Width = 300;
            //m.Show("Onay nesnesinin anahtar değeri boş bırakılamaz.");
            throw new Exception("Onay nesnesinin anahtar değeri boş bırakılamaz.");
        }
    }
}