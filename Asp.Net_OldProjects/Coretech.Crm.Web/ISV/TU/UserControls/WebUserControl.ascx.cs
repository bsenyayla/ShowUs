using Coretech.Crm.PluginData;
using RefleXFrameWork;
using System;
using System.Data;

public partial class UserControls_WebUserControl : System.Web.UI.UserControl
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
}