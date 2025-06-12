using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Reflection;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.View;
using RefleXFrameWork;
using TuFactory.Data;
using TuFactory.Integration3rd;
using TuFactory.Integrationd3rdLayer.Object;
using TuFactory.Object;
using TuFactory.Object.Integration3Rd;
using TuFactory.Object.User;
using TuFactory.Reconciliation;
using System.Linq;

namespace Operation.Detail
{
    public partial class Operation_Detail_EntegrationLog : BasePage
    {
        private TuUserApproval _userApproval = null;
        private Guid QueryId = Guid.Empty;
        protected override void OnPreInit(EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {

            }
            base.OnPreInit(e);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                CreateEntegrationlogViewGrid();


                var transferId = ValidationHelper.GetGuid(QueryHelper.GetString("TransferId"), Guid.Empty);

                var recId = ValidationHelper.GetGuid(QueryHelper.GetString("RecordId"), Guid.Empty);

                if (recId != Guid.Empty)
                {
                    hdnRecId.SetValue(recId);

                    GrdEntegrationlog.Reload();




                    //StaticData sd = new StaticData();
                    //sd.AddParameter("TransferId", System.Data.DbType.Guid, recId);

                    //DataSet ds = sd.ReturnDatasetSp("spGetTransactionHistoryAndLog");

                    //gvTransactionHistory.DataSource = ds.Tables[0];
                    //gvTransactionHistory.DataBind();

                    //gvEntegrationLog.DataSource = ds.Tables[1];
                    //gvEntegrationLog.DataBind();


                }

            }

        }


        public void CreateEntegrationlogViewGrid()
        {
            var gpc = new GridPanelCreater();
            gpc.CreateViewGrid("EntegrationLogDefaultView", GrdEntegrationlog);

            string strSelected = ViewFactory.GetViewIdbyUniqueName("EntegrationLogDefaultView").ToString();

            QueryId = ValidationHelper.GetGuid(strSelected);

            //hdnViewList.Value = strSelected;

            if (string.IsNullOrEmpty(strSelected))
                return;
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(strSelected));

            var getColumnList = new UserPoolMapDb().GetColumnList(Convert.ToInt32(8), QueryId, new UserPoolMapDb().GetAttributeListString(new UserPoolMapDb().getColumnSet(gpw.View.ColumnSetXml)));
            List<GridColumns> lstAddetColumn = GrdEntegrationlog.ColumnModel.Columns.ToList();
            GrdEntegrationlog.ClearColumns();

            foreach (GridColumns item in lstAddetColumn)
            {
                var count = (from c in getColumnList
                             where c.AttributeName == item.Header && c.Hide == true
                             select c).Count();
                if (count == 0)
                    GrdEntegrationlog.AddColumn(item);
            }
            GrdEntegrationlog.ReConfigure();

            var defaultEditPage = gpw.View.DefaultEditPage.ToString();
            //hdnViewDefaultEditPage2.Value = defaultEditPage;


        }

        protected void ToolbarButtonFindEntegrationlogClick(object sender, AjaxEventArgs e)
        {
            var recId = hdnRecId.Value;
            DataTable retDt = new DataTable();
            DataTable dt = new DataTable();
            if (!string.IsNullOrEmpty(recId))
            {


                string sql = @"SELECT new_TransferId,new_TransferIdName,
                                        New_EntegrationLogId,
                                        New_EntegrationLogId AS ID,
	                                    EntegrationLogNumber AS VALUE,
	                                    EntegrationLogNumber,
				                        CreatedOn,
                                        CreatedOn AS CreatedOnUtcTime,
									    ModifiedOn,
                                        ModifiedOn AS ModifiedOnUtcTime,
										CreatedBy,
										CreatedByName,
										ModifiedBy,
										ModifiedByName,
										new_PaymentId,
										new_PaymentIdName,
										new_Data,
										new_MethodName,
										new_DataOut,
										new_RequestDate,
										new_ResponseDate
	                                 FROM vNew_EntegrationLog(NOLOCK) dt		                     
	                                 WHERE new_TransferId = @TransferId AND DeletionStateCode =0 ";


                var sort = GrdEntegrationlog.ClientSorts();
                if (sort == null)
                { sort = string.Empty; }



                var viewqueryid = ViewFactory.GetViewIdbyUniqueName("EntegrationLogDefaultView");
                var spList = new List<CrmSqlParameter>();
                spList.Add(new CrmSqlParameter() { Dbtype = DbType.Guid, Paramname = "TransferId", Value = ValidationHelper.GetGuid(recId) });



                var gpc = new GridPanelCreater();
                var cnt = 0;
                var start = GrdEntegrationlog.Start();
                var limit = GrdEntegrationlog.Limit();
                var t = gpc.GetFilterData(sql, viewqueryid, sort, spList, start, limit, out cnt, out dt);
                GrdEntegrationlog.TotalCount = cnt;

                if (e.ExtraParams != null && e.ExtraParams["Excel"] != null && ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
                {
                    var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
                    gpw.Export(dt);
                }

                GrdEntegrationlog.DataSource = t;
                GrdEntegrationlog.DataBind();

            }




        }
    }
}