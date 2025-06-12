using System;
using System.Data;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.AccountStatement;


public partial class BalanceStatements_Form : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
    }

    protected void CorporationLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"select Distinct new_CorporationIdName AS VALUE,
                                    acc.new_CorporationId AS ID,                                          
                                    crp.new_CorporationCode,
                                    crp.CorporationName
                            from vNew_AccStatement(NoLock) acc
                            inner join vNew_Corporation(NoLock) crp on acc.new_CorporationId = crp.New_CorporationId 
                            where acc.DeletionStateCode = 0
                            order by acc.new_CorporationIdName";

        StaticData sd = new StaticData();
        DataSet ds = sd.ReturnDataset(strSql);
        if (ds.Tables.Count > 0)
        {
            new_Corporation.TotalCount = ds.Tables[0].Rows.Count;
            new_Corporation.DataSource = ds.Tables[0];
            new_Corporation.DataBind();
        }
    }

    protected void AccStatementLoad(object sender, AjaxEventArgs e)
    {
        string strSql = @"spTUGetAccountStatementForComboFill";

        StaticData sd = new StaticData();
        sd.AddParameter("CorporationId", DbType.Guid, ValidationHelper.GetGuid(new_Corporation.Value));
        DataSet ds = sd.ReturnDatasetSp(strSql);
        if (ds.Tables.Count > 0)
        {
            new_AccStatementID.TotalCount = ds.Tables[0].Rows.Count;
            new_AccStatementID.DataSource = ds.Tables[0];
            new_AccStatementID.DataBind();
        }
    }


    protected void btnSaveOnEvent2(object sender, AjaxEventArgs e)
    {
        AccountStatementFactory asf = new AccountStatementFactory();
        //asf.StartMT940();

        Guid reportId = asf.GetReportNameByReportId("HesapEkstresiMT940");

        if (reportId == Guid.Empty)
        {
            QScript("alert('[HesapEkstresiMT940] adlı rapor yok ya da artık görüntülenemiyor.');");
        }
        else
        {
            if (string.IsNullOrEmpty(new_Corporation.Value) || string.IsNullOrEmpty(new_AccStatementID.Value)
                || new_StartDate.Value == null || new_EndDate.Value == null)
            {
                QScript("alert('Lütfen zorunlu alanları doldurarak ektre oluşturmayı deneyiniz.');");
            }
            else if (Math.Abs((new_StartDate.Value - new_EndDate.Value).Value.TotalDays) > 30)
            {
                QScript("alert('Başlangıç ve bitiş tarihi arasındaki fark en fazla 30 gün olabilir.');");
            }
            else
            {
                QScript(string.Format("hdnReportId.setValue('{0}');", reportId));
                QScript(string.Format("hdnRecid.setValue('{0}');", ValidationHelper.GetString("")));
                QScript("ShowAccountStatementReport(2);");
            }
        }

    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        AccountStatementFactory asf = new AccountStatementFactory();
        //asf.StartMT940();

        Guid reportId = asf.GetReportNameByReportId("HesapEkstresiMT940");

        if (reportId == Guid.Empty)
        {
            QScript("alert('[HesapEkstresiMT940] adlı rapor yok ya da artık görüntülenemiyor.');");
        }
        else
        {
            if (string.IsNullOrEmpty(new_Corporation.Value) || string.IsNullOrEmpty(new_AccStatementID.Value)
                || new_StartDate.Value == null || new_EndDate.Value == null)
            {
                QScript("alert('Lütfen zorunlu alanları doldurarak ektre oluşturmayı deneyiniz.');");
            }
            else if (Math.Abs((new_StartDate.Value - new_EndDate.Value).Value.TotalDays) > 30)
            {
                QScript("alert('Başlangıç ve bitiş tarihi arasındaki fark en fazla 30 gün olabilir.');");
            }
            else
            {
                QScript(string.Format("hdnReportId.setValue('{0}');", reportId));
                QScript(string.Format("hdnRecid.setValue('{0}');", ValidationHelper.GetString("")));
                QScript("ShowAccountStatementReport(1);");
            }
        }
    }
}