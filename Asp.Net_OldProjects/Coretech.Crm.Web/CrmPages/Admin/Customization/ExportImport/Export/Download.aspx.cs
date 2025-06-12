using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Crm.Form;
using Coretech.Crm.Factory.Crm.Labels;
using Coretech.Crm.Factory.Crm.Reporting;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.ExportImport;
using Coretech.Crm.Objects.Crm.Reporting;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;

public partial class CrmPages_Admin_Customization_ExportImport_Export_Download : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {

    }
    protected override void OnPreInit(EventArgs e)
    {
        if (!Page.IsPostBack && !RefleX.IsAjxPostback)
        {
            var recid = QueryHelper.GetString("recid");
            if (!string.IsNullOrEmpty(recid))
            {
                var exportData = GetDatas(recid);
                var packageXml = exportData.GetStringValue("PackageXml");
                if (!string.IsNullOrEmpty(packageXml))
                {

                    var selectedSchema = ExportImportSchema.XmlDeSerializeExportImportSchema(packageXml);

                    var nExportImport = new ExportImport();
                    nExportImport.Name = selectedSchema.Name;
                    nExportImport.ExportDate = DateTime.UtcNow;

                    nExportImport.EntityList = new List<ExportEntity>();
                    nExportImport.PluginList = new List<ExportPlugin>();
                    nExportImport.SecurityRoleList = new List<ExportSecurityRole>();
                    nExportImport.ReportList = new List<ExportReport>();
                    var df = new DynamicFactory(ERunInUser.SystemAdmin);
                    var reportsFactory = new ReportsFactory();
                    foreach (var entitySchema in selectedSchema.EntityList)
                    {
                        var objectId = entitySchema.EEntity;
                        if (entitySchema.EEntity <= 0)
                            continue;

                        var eXentity = new ExportEntity();
                        eXentity.EEntity = App.Params.CurrentEntity[objectId];
                        eXentity.EeAttribute = new ExportEntityAttribute();
                        if (entitySchema.EaList)
                        {
                            var eif = new ExportImportFactory();
                            eXentity.EeAttribute.EaList = App.Params.CurrentEntityAttribute.Values.Where(ea => ea.ObjectId == objectId).ToList();
                            eXentity.EeAttribute.PicklistValueList = eif.GetPicklistValueList(objectId);

                        }
                        eXentity.EFormList = new List<DynamicEntity>();
                        foreach (var form in entitySchema.EFormList)
                        {
                            eXentity.EFormList.Add(FormFactory.ConvertFormToEntity(form));
                        }
                        eXentity.EViewList = new List<DynamicEntity>();
                        foreach (var view in entitySchema.EViewList)
                        {
                            eXentity.EViewList.Add(ViewFactory.ConvertViewToEntity(view));
                        }
                        eXentity.EWorkFlowList = new List<DynamicEntity>();
                        foreach (var wf in entitySchema.EWorkFlowList)
                        {
                            eXentity.EWorkFlowList.Add(WorkFlowFactory.ConvertWorkflowToEntity(wf));
                        }
                        eXentity.EDataList = new List<DynamicEntity>();
                        if (entitySchema.EData)
                        {
                            eXentity.EDataList = df.GetAllDataFromEntity(objectId, entitySchema.EDataList);
                        }
                        if (entitySchema.ELabelMessage)
                        {
                            var mylf = new LabelsFactory();
                            eXentity.ELabelMessage = mylf.GetLabelMessageDefinationbyObjectId(objectId);
                            var eif = new ExportImportFactory();
                            eXentity.EntityLabelList = eif.GetExportEntityLabels(objectId);
                        }
                        nExportImport.EntityList.Add(eXentity);
                    }

                    foreach (var pluginSchema in selectedSchema.PluginList)
                    {
                        var pdllId = pluginSchema.PDll;
                        var nplugin = new ExportPlugin
                                          {
                                              PDll = App.Params.CurrentPlugins[ValidationHelper.GetGuid(pdllId)],
                                              PluginMessageList = App.Params.CurrentPluginMessages.Where(
                                                  pm => pm.PluginDllId == ValidationHelper.GetGuid(pdllId)).ToList()
                                          };

                        nExportImport.PluginList.Add(nplugin);
                    }

                    foreach (var reportlist in selectedSchema.ReportList)
                    {
                        nExportImport.ReportList.Add(
                            new ExportReport()
                                {
                                    ActiveReport = reportsFactory.GetReport(reportlist.ReportsId),
                                    Report = reportsFactory.GetReportEntity(reportlist.ReportsId)
                                }
                            );
                    }
                    var securityFactory = new SecurityFactory();

                    foreach (var role in selectedSchema.SecurityRoleList)
                    {
                        nExportImport.SecurityRoleList.Add(
                            new ExportSecurityRole()
                            {
                                RolePrivilegeList = securityFactory.GetRolePrivileges(role),
                                SecurityRole = securityFactory.GetRoleEntity(role),
                            }
                            );
                    }


                    var xml = ExportImport.SerializeExportImport(nExportImport);
                    var ef = new ExportImportFactory();
                    ef.ToZip(xml, "Export" + DateTime.Now.ToString("dd_MM_yy") + ".zip");
                    
                }


            }
            Response.End();

        }
        base.OnPreInit(e);
    }
    private DynamicEntity GetDatas(string recid)
    {
        var myEntity = new DynamicEntity(EntityEnum.ExportPackage.GetHashCode());
        var df = new DynamicFactory(ERunInUser.CalingUser);
        myEntity = df.Retrieve(myEntity.ObjectId, ValidationHelper.GetGuid(recid), DynamicFactory.RetrieveAllColumns);
        return myEntity;
    }

}