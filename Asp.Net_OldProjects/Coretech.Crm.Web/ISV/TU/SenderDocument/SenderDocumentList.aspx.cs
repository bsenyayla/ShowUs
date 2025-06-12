using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Object;

public partial class SenderDocument_SenderDocumentList : BasePage
{
    Guid SenderId = ValidationHelper.GetGuid(QueryHelper.GetString("SenderId"));
    Guid CustAccountTypeId = ValidationHelper.GetGuid(QueryHelper.GetString("CustAccountTypeId"));

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            CreateViewGrid();
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GetGridName(), gpSenderDocument, false);
    }

    protected void gpSenderDocumentReload(object sender, AjaxEventArgs e)
    {
        var sort = gpSenderDocument.ClientSorts() ?? string.Empty;
        string strSql = GetSenderDocumentSelectSql(CustAccountTypeId);
        var spList = GetSenderDocumentSelectParameters(SenderId, ref strSql);

        var gpc = new GridPanelCreater();

        int cnt;
        var start = gpSenderDocument.Start();
        var limit = gpSenderDocument.Limit();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GetGridName());
        DataTable dtb;
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb, false);
        gpSenderDocument.TotalCount = cnt;

        gpSenderDocument.DataSource = t;
        gpSenderDocument.DataBind();
    }

    private string GetGridName()
    {
        var custAccountTypeCode = GetCustAccountTypeCode(ValidationHelper.GetGuid(CustAccountTypeId));

        string path = string.Empty;

        if (custAccountTypeCode == "002")
        {
            return "CorporatedSenderDocumentView";
        }
        else
        {
            return "SenderDocumentView";
        }
    }

    protected void btnDownload_OnClick(object sender, EventArgs e)
    {

        Guid senderDocumentId = ValidationHelper.GetGuid(hdnSenderDocumentID.Value);

        pSenderDocument.LoadUrl(string.Format("/ISV/TU/SenderDocument/SenderDocumentForm.aspx?recid={0}", senderDocumentId));
        wSenderDocument.Show();
    }

    private string GetContentType(string FileExtension)
    {
        Dictionary<string, string> d = new Dictionary<string, string>();
        //Images'
        d.Add(".jpeg", "image/jpeg");
        d.Add(".jpg", "image/jpeg");
        d.Add(".png", "image/png");
        //Documents'
        d.Add(".doc", "application/msword");
        d.Add(".docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
        d.Add(".pdf", "application/pdf");

        return d[FileExtension];
    }

    private string GetSenderDocumentSelectSql(Guid CustAccountTypeId)
    {
        var custAccountTypeCode = GetCustAccountTypeCode(ValidationHelper.GetGuid(CustAccountTypeId));

        if (custAccountTypeCode == "002")
        {
            string strSql = @"SELECT Mt.New_CorporatedSenderDocumentsId AS ID ,Mt.new_Document AS VALUE ,Mt.*
                    FROM [dbo].[tvNew_CorporatedSenderDocuments](@SystemUserId) Mt ";
            strSql += " WHERE 1=1 ";
            return strSql;
        }
        else
        {
            string strSql = @"SELECT Mt.New_SenderDocumentId AS ID ,Mt.new_Document AS VALUE ,Mt.*
                    FROM [dbo].[tvNew_SenderDocument](@SystemUserId) Mt ";
            strSql += " WHERE 1=1 ";
            return strSql;
        }
    }

    private List<CrmSqlParameter> GetSenderDocumentSelectParameters(Guid SenderId, ref string filterSql)
    {
        var spList = new List<CrmSqlParameter>();

        if (!string.IsNullOrEmpty(SenderId.ToString()))
        {
            filterSql += " AND Mt.new_SenderID = @SenderId";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "SenderId",
                Value = SenderId
            });
        }

        return spList;
    }

    private string GetCustAccountTypeCode(Guid CustAccountTypeId)
    {
        string result = string.Empty;
        if (CustAccountTypeId == Guid.Empty)
            return result;

        DataTable dt = new DataTable();

        try
        {
            var sd = new StaticData();
            sd.AddParameter("CustAccountTypeId", DbType.Guid, CustAccountTypeId);
            dt = sd.ReturnDataset(@"Select new_EXTCODE From vNew_CustAccountType(NoLock)
                                            Where DeletionStateCode = 0 And New_CustAccountTypeId = @CustAccountTypeId
                                            ").Tables[0];
            result = ValidationHelper.GetString(dt.Rows[0]["new_EXTCODE"]);
        }
        catch (Exception ex)
        {
            throw ex;
        }

        return result;
    }
}
