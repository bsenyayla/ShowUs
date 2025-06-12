using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;

public partial class Sender_SenderMultipleSingularityResult : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            RR.RegisterIcon(Icon.Add);
            lblTwiceMessage.Text = "* "+ CrmLabel.TranslateMessage("CRM.NEW_SENDER_MULTIPLESINGULARITY_CLICK_TWICE");
            CreateViewGrid();
            QScript("gpMultipleSingularityHeader.reload();");
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid("SENDER_MULTIPLESINGULARITY_LIST", gpMultipleSingularityHeader, true);
    }

    protected void GpMultipleSingularityLoad(object sender, AjaxEventArgs e)
    {
        List<CrmSqlParameter> spList = new List<CrmSqlParameter>();
        StaticData sd = new StaticData();
        Guid viewqueryid = ViewFactory.GetViewIdbyUniqueName("SENDER_MULTIPLESINGULARITY_LIST");
        var sort = gpMultipleSingularityHeader.ClientSorts() ?? string.Empty;
        //GetFilters(out spList, ValidationHelper.GetGuid(Request.QueryString["NationalityID"]), ValidationHelper.GetString(Request.QueryString["IdentificationNumber"])
        //           , ValidationHelper.GetGuid(Request.QueryString["IdentificationCardTypeID"]), ValidationHelper.GetString(Request.QueryString["IdentityNo"]));
        sd.AddParameter("NationalityID", DbType.Guid, ValidationHelper.GetGuid(Request.QueryString["NationalityID"]));
        sd.AddParameter("IdentificationNumber", DbType.String, ValidationHelper.GetString(Request.QueryString["IdentificationNumber"]));
        sd.AddParameter("IdentificationCardTypeID", DbType.Guid, ValidationHelper.GetGuid(Request.QueryString["IdentificationCardTypeID"]));
        sd.AddParameter("IdentityNo", DbType.String, ValidationHelper.GetString(Request.QueryString["IdentityNo"]));
        sd.AddParameter("FullName", DbType.String, ValidationHelper.GetString(Request.QueryString["FullName"]));        

        var dtb = sd.ReturnDatasetSp("spSenderSingularityGetForeignSenderWithName").Tables[0];
        var gp = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
        List<string> passwordColumns;
        List<Dictionary<string, object>> t  = gp.GetDataList(dtb,out passwordColumns);
        gpMultipleSingularityHeader.TotalCount = dtb.Rows.Count;
        gpMultipleSingularityHeader.DataSource = t;
        gpMultipleSingularityHeader.DataBind();
    }

    private void GetFilters(out List<CrmSqlParameter> spList, Guid NationalityID, string IdentificationNumber, Guid IdentificationCardTypeID, string IdentityNo)
    {
        StaticData sd = new StaticData();
        string strSql = string.Empty;
        spList = new List<CrmSqlParameter>();

        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "NationalityID",
            Value = NationalityID
        });

        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.Guid,
            Paramname = "IdentificationCardTypeID",
            Value = IdentificationCardTypeID
        });

        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.String,
            Paramname = "IdentificationNumber",
            Value = IdentificationNumber
        });

        spList.Add(new CrmSqlParameter()
        {
            Dbtype = DbType.String,
            Paramname = "IdentityNo",
            Value = IdentityNo
        });
    }

}