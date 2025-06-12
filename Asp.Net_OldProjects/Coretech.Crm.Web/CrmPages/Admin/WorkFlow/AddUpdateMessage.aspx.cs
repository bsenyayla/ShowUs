using System;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Web.UI.AutoGenerate;
using Coolite.Ext.Web;
using Coretech.Crm.Objects.Crm.Template;
public partial class CrmPages_Admin_WorkFlow_AddUpdateMessage : AdminPage
{
    public CrmPages_Admin_WorkFlow_AddUpdateMessage()
    {
        base.ObjectId = EntityEnum.Workflow.GetHashCode();
    }
    EditPageMode Mode;
    int ObjectId = int.MinValue;
    int Type = int.MinValue;
    int Action = int.MinValue;

    string _framename = "";
    string _objectid = "";
    string _action = "";
    string _type = "";
    string _pawinid = "";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Workflow PrvCreate,PrvDelete,PrvWrite");
        }
        ObjectId = QueryHelper.GetInteger("objectid");
        Type = QueryHelper.GetInteger("type");
        Action = QueryHelper.GetInteger("action");

        _framename = QueryHelper.GetString("framename");
        _pawinid = QueryHelper.GetString("pawinid");
        _objectid = QueryHelper.GetString("objectid");
        _action = QueryHelper.GetString("action");
        _type = QueryHelper.GetString("type");
        if (_action == "1")
            Mode = EditPageMode.New;
        else if (_action == "2")
            Mode = EditPageMode.EditUpdate;

        if (!Page.IsPostBack)
        {
            _WorkFlowId.Value = QueryHelper.GetString("WorkFlowId");
            xmlTemplateId.Value = QueryHelper.GetString("xmlTemplateId");

            ActiveScriptManager.RegisterClientScriptBlock("lframename", "var lframename='" + _framename + "';");
            ActiveScriptManager.RegisterClientScriptBlock("objectid", "var lobjectid='" + _objectid + "';");
            ActiveScriptManager.RegisterClientScriptBlock("action", "var laction='" + _action + "';");
            ActiveScriptManager.RegisterClientScriptBlock("type", "var type='" + _type + "';");
            ActiveScriptManager.RegisterClientScriptBlock("awinid", "var awinid='" + _pawinid + "';");

            if (string.IsNullOrEmpty(xmlTemplateId.Value.ToString()))
            {
                xmlTemplateId.Value = GuidHelper.New();
            }

            StoreLoad();
        }
        ActiveScriptManager.RegisterOnReadyScript("DisableDays();");
    }
    public void StoreLoad()
    {
        if (Mode == EditPageMode.EditUpdate && ValidationHelper.GetGuid(xmlTemplateId.Value) != Guid.Empty)
        {
            var Wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
            var aue = Wf.GetCallBackMessage(ValidationHelper.GetGuid(xmlTemplateId.Value));
            txtName.Value = aue.Name;
            MessageType.Value = ((int)aue.MessageType).ToString();
            WhereClauseDynamicEditor.Value = aue.HtmlValue;
        }

        
    }
    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var xmlValue = e.ExtraParams["XmlValue"];
        if (string.IsNullOrEmpty(xmlValue)) return;

        var xTemp = new xmlTemplate
                        {
                            ObjectId = ObjectId,
                            TemplateType = TemplateType.WorkflowMessage,
                            Xml = xmlValue,
                            xmlTemplateId = ValidationHelper.GetGuid(xmlTemplateId.Value),
                            GroupId = ValidationHelper.GetGuid(_WorkFlowId.Value)
                        };
        var wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
        var myMessage = new CallBackMessage();
        myMessage.CallBackMessageId = xTemp.xmlTemplateId;
        myMessage.Name = txtName.Text;
        myMessage.ObjectId = ObjectId;
        
        wf.CallBackMessageSave(xTemp,myMessage);
    }

}