using System;
using System.Collections.Generic;
using System.Data;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;
public partial class CustAccount_Sender_SenderFinde : System.Web.UI.UserControl
{

    public string SelectedFunction { get; set; }
    

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            CreateViewGrid();
            windowSenderSelectorBtnSelectSender.Listeners.Click.Handler = "UptSenderSelector.Select();" + SelectedFunction;
            new_SenderIdendificationNumber1Vkn.FieldLabel = CrmLabel.TranslateMessage("CRM.NEW_SENDER_VKN_LABEL");
        }
    }

    private const string GridName = "SENDERLIST_FOR_SELECTOR";
    protected override void OnInit(EventArgs e)
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGridModels(GridName, gpSenderSelector, true);
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GridName, gpSenderSelector, true);
    }

    protected void gpSenderSelectorReload(object sender, AjaxEventArgs e)
    {
        var sort = gpSenderSelector.ClientSorts() ?? string.Empty;


        var spList = new List<CrmSqlParameter>();

        string strSql = string.Empty;
        string strWhere = " Where 1=1 ";

        strSql = @" SELECT Mt.New_SenderId AS ID ,Mt.Sender AS VALUE ,Mt.*
                    FROM tvNew_Sender(@SystemUserId) Mt ";

        //UPT Card Girilirse birleştirmemiz gerekiyor. (kart sayısı birden fazla olabilir bu nedenle ilk aşamada concat edemiyoruz)
       if(!string.IsNullOrEmpty(Sendernew_CardNumber.Value))
        { 
            strSql += @" JOIN 
					(
						SELECT new_SenderID FROM tvNew_UptCard(@SystemUserId)
                        WHERE CardNumber = @CardNumber AND DeletionStateCode = 0 
					) UptCard ON UptCard.new_SenderID = Mt.New_SenderId ";
        }
        /*Sıralama islemleri icin.*/
        //sort = Request["sort"];
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GridName);
        strSql = strSql + strWhere;
       
        if (!string.IsNullOrEmpty(Sendernew_CustAccountTypeId.Value))
        {
            strSql += " AND Mt.new_CustAccountTypeId =@new_CustAccountTypeId ";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_CustAccountTypeId",
                Value = ValidationHelper.GetGuid(Sendernew_CustAccountTypeId.Value) 
            });
        }
        if (!string.IsNullOrEmpty(Sendernew_SenderNumber.Value))
        {
            strSql += " AND Mt.new_SenderNumber =@new_SenderNumber ";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderNumber",
                Value = Sendernew_SenderNumber.Value
            });
        }
        if (!string.IsNullOrEmpty(Sendernew_SenderIdendificationNumber1.Value))
        {
            strSql += " AND Mt.new_SenderIdendificationNumber1 =@new_SenderIdendificationNumber1 ";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderIdendificationNumber1",
                Value = Sendernew_SenderIdendificationNumber1.Value
            });
        }
        if (!string.IsNullOrEmpty(new_SenderIdendificationNumber1Vkn.Value))
        {
            strSql += " AND Mt.new_SenderIdendificationNumber1 =@new_SenderIdendificationNumber1Vkn ";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "new_SenderIdendificationNumber1Vkn",
                Value = new_SenderIdendificationNumber1Vkn.Value
            });
        }
        if (!string.IsNullOrEmpty(Sendernew_NationalityID.Value))
        {
            strSql += " AND Mt.new_NationalityID =@new_NationalityID ";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.Guid,
                Paramname = "new_NationalityID",
                Value = ValidationHelper.GetGuid(Sendernew_NationalityID.Value)
            });
        }
        if (!string.IsNullOrEmpty(SenderSender.Value))
        {
            strSql += " AND Mt.Sender like '%' +@Sender +'%' ";

            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "Sender",
                Value = SenderSender.Value
            });
        }
        //UPT Card Girerse
        if (!string.IsNullOrEmpty(Sendernew_CardNumber.Value))
        {
            spList.Add(new CrmSqlParameter()
            {
                Dbtype = DbType.String,
                Paramname = "CardNumber",
                Value = Sendernew_CardNumber.Value
            });
        }
        var gpc = new GridPanelCreater();

        int cnt;
        var start = gpSenderSelector.Start();
        var limit = gpSenderSelector.Limit();
        DataTable dtb;
        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt, out dtb, false);
        gpSenderSelector.TotalCount = cnt;

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dtb);
        }
        gpSenderSelector.DataSource = t;
        gpSenderSelector.DataBind();
    }


}