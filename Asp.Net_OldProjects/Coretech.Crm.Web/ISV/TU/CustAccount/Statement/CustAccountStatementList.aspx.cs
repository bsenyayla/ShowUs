using System;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Object;
using Object = TuFactory.CustAccount.Object;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using TuFactory.CustAccount.Business.Service;
using System.IO;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Factory.Crm.ExcelImport;

public partial class CustAccount_Statement_CustAccountStatementList : BasePage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            mfStatementDate.FieldLabel = cmbStatementDateStart.FieldLabel;
            CreateViewGrid();
        }
    }

    protected void new_SenderId_OnChange(object sender, AjaxEventArgs e)
    {
        var senderId = ValidationHelper.GetGuid(new_SenderId.Value);
        if (senderId != Guid.Empty)
        {
            var df = new DynamicFactory(ERunInUser.SystemAdmin);
            var desender = df.RetrieveWithOutPlugin(TuEntityEnum.New_Sender.GetHashCode(), senderId, new[] { "new_CustAccountTypeId" });
            var CustAccountTypeId = desender.GetLookupValue("new_CustAccountTypeId");

            if (CustAccountTypeId != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.Value = CustAccountTypeId.ToString();
                new_CustAccountTypeId.SetValue(((Lookup)desender["new_CustAccountTypeId"]).Value.ToString(), ((Lookup)desender["new_CustAccountTypeId"]).name);
            }
        }
        else
        {
            new_CustAccountId.Clear();
        }
    }

    protected void new_CustAccountId_OnChange(object sender, AjaxEventArgs e)
    {
        var custAccountId = Guid.Empty;
        if (!string.IsNullOrEmpty(new_CustAccountId.Value))
        {
            custAccountId = ValidationHelper.GetGuid(new_CustAccountId.Value);
        }
        var df = new DynamicFactory(ERunInUser.CalingUser);
        var de = df.RetrieveWithOutPlugin(TuEntityEnum.New_CustAccounts.GetHashCode(), custAccountId, new[] { "new_CustAccountCurrencyId",
            "new_Balance", "new_SenderId", "new_CustAccountTypeId" });
        var currency = de.GetLookupValue("new_CustAccountCurrencyId");
        var balance = de.GetDecimalValue("new_Balance");
        if (currency != Guid.Empty)
        {
            var senderF = de.Properties["new_SenderId"] as Lookup;
            var custAccountTypeId = de.Properties["new_CustAccountTypeId"] as Lookup;
            if (senderF != null && senderF.Value != ValidationHelper.GetGuid(new_SenderId.Value))
            {
                new_SenderId.SetValue(senderF.Value.ToString(), senderF.name);
                new_SenderId.Value = senderF.Value.ToString();
                new_SenderId_OnChange(null, null);
            }
            if (custAccountTypeId != null && custAccountTypeId.Value != ValidationHelper.GetGuid(new_CustAccountTypeId.Value))
            {
                new_CustAccountTypeId.SetValue(custAccountTypeId.Value.ToString(), custAccountTypeId.name);
                new_CustAccountTypeId.Value = custAccountTypeId.Value.ToString();
            }
        }
    }
    private void CreateViewGrid()
    {
        GridPanelCreater gpc = new GridPanelCreater();
        gpc.CreateViewGrid("CustAccountStatementList", ExtractList, true);
        //ExtractList.ReConfigure();
    }

    protected void ExtractListOnDataList(object sender, AjaxEventArgs e)
    {
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CustAccountStatementList");
        List<CrmSqlParameter> spList = new List<CrmSqlParameter>();
        string strFilterSql = CustAccountStatementService.GetFiltersForStatementList(out spList, new_CustAccountTypeId, new_SenderId, new_CustAccountId, cmbStatementDateStart, cmbStatementDateEnd);
        Object.GridDataResponse gdr = CustAccountStatementService.GetList(ExtractList, viewqueryid, strFilterSql, spList);
        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(gdr.Data);
        }
        ExtractList.TotalCount = gdr.TotalRecordCount;
        ExtractList.DataSource = gdr.GridData;
        ExtractList.DataBind();
    }

    protected void FileDownloadEvent_Click(object sender, AjaxEventArgs e)
    {
        var rows = ((RowSelectionModel)ExtractList.SelectionModel[0]);
        if (rows != null && rows.SelectedRows != null && rows.SelectedRows.Length > 0)
        {
            foreach (var row in rows.SelectedRows)
            {
                try
                {
                    //var response = HttpContext.Current.Response;
                    //response.Buffer = true;
                    string filename = Path.GetFullPath(row.new_Path);
                    var fileInfo = new FileInfo(filename);
                    //Object.CustAccountStatementParameters parameter = new Object.CustAccountStatementParameters();
                    //string StatementPath;
                    //if(parameter.UseFileServer)
                    //{
                    //    StatementPath = new CustAccountStatementFileInformation().GetRemotePath();
                    //    var impersonator = new Impersonator();
                    //    impersonator.Impersonate(parameter.ImporterUser, parameter.ImporterDomain, parameter.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                    //}
                    //else
                    //{
                    //    StatementPath = new CustAccountStatementFileInformation().GetLocalPath();
                    //}
                    Response.Buffer = true;
                    Response.Clear();
                    if (filename.StartsWith("\\"))
                    {
                        Object.CustAccountStatementParameters parameter = new Object.CustAccountStatementParameters();
                        using (var impersonator = new Impersonator())
                        {
                            impersonator.Impersonate(ExcelImportFactory.ImporterUser, ExcelImportFactory.ImporterDomain, ExcelImportFactory.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);
                            if (!fileInfo.Exists)
                            {
                                throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", filename);
                            }
                            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                            //response.AddHeader("Content-Length", fileInfo.Length.ToString());
                            if (fileInfo.Name.EndsWith(".Pdf"))
                            {
                                Response.ContentType = "application/pdf";
                            }
                            Response.WriteFile(fileInfo.FullName);
                            Response.Flush();
                            Response.End();
                            Response.Close();
                        }
                    }
                    else
                    {
                        if (!fileInfo.Exists)
                        {
                            throw new FileNotFoundException("File to download was not found \n İndirmek İçin Dosya Bulunamadı.", filename);
                        }
                        Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileInfo.Name);
                        //response.AddHeader("Content-Length", fileInfo.Length.ToString());
                        if (fileInfo.Name.EndsWith(".Pdf"))
                        {
                            Response.ContentType = "application/pdf";
                        }
                        Response.WriteFile(fileInfo.FullName);
                        Response.Flush();
                        Response.End();
                        Response.Close();
                    }
                    //if (fileInfo.Name.EndsWith(".Pdf"))
                    //{
                    //    //fileInfo = new FileInfo(StatementPath + fileInfo.Name);
                    //}
                    
                }
                catch (Exception ex)
                {
                    LogUtil.WriteException(ex);
                }
            }
        }

    }
}