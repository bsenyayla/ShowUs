using System;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Factory.Crm.Template;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coolite.Ext.Web;
using Coretech.Crm.Objects.Crm.Template;

public partial class CrmPages_Admin_WorkFlow_Condition : AdminPage
{
    public CrmPages_Admin_WorkFlow_Condition()
    {
        base.ObjectId = EntityEnum.Workflow.GetHashCode();
    }
    string  _framename="";
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
        _framename = QueryHelper.GetString("framename");
        _pawinid = QueryHelper.GetString("pawinid");
        _objectid = QueryHelper.GetString("objectid");
        _action = QueryHelper.GetString("action");
        _type= QueryHelper.GetString("type");

        if (!Page.IsPostBack) {


            ConditionName.Value = QueryHelper.GetString("Text");
            WorkFlowId.Value = QueryHelper.GetString("WorkFlowId");   
            ActiveScriptManager.RegisterClientScriptBlock("lframename", "var lframename='" + _framename + "';");
            ActiveScriptManager.RegisterClientScriptBlock("objectid", "var lobjectid='" + _objectid + "';");
            ActiveScriptManager.RegisterClientScriptBlock("action", "var laction='" + _action + "';");
            ActiveScriptManager.RegisterClientScriptBlock("type", "var type='" + _type + "';");
            ActiveScriptManager.RegisterClientScriptBlock("awinid", "var awinid='" + _pawinid + "';");

            xmlTemplateId.Value = QueryHelper.GetString("xmlTemplateId");
            if (string.IsNullOrEmpty(xmlTemplateId.Value.ToString()))
                xmlTemplateId.Value = Guid.NewGuid();


            ActiveScriptManager.RegisterOnReadyScript("wonload();"); 
            ParseXml();
        }
    }
    void ParseXml()
    {
        WorkFlowFactory Wf = new WorkFlowFactory(App.Params.CurrentUser.SystemUserId);
        FilterEntity f= Wf.GetFilterEntity(ValidationHelper.GetGuid(xmlTemplateId.Value));
        if (f.id!=Guid.Empty)
            CBuilder.ParseFilterEntity(f);
        
    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        //xmlTemplateId.Value 
        var XmlValue = e.ExtraParams["XmlValue"];
        if (!string.IsNullOrEmpty(XmlValue))
        {
            xmlTemplate xTemp = new xmlTemplate();
            xTemp.ObjectId = ValidationHelper.GetInteger(_objectid, 0);
            xTemp.TemplateType = TemplateType.WorkflowContition;
            xTemp.Xml = XmlValue;
            xTemp.xmlTemplateId = ValidationHelper.GetGuid(xmlTemplateId.Value);
            xTemp.GroupId=ValidationHelper.GetGuid(WorkFlowId.Value);
            TemplateFactory Tf = new TemplateFactory();
            Tf.AddUpdateXmlTemplate(xTemp);
        }

    }

    [AjaxMethod(ShowMask = true)]
    public string UpdateXmlTemplate(string gpXml)
    {
        return "";
    }
}