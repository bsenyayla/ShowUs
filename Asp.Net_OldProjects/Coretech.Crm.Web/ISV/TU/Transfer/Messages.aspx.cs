using System;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using TuFactory.Object;

public partial class Transfer_Messages : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            var objId = ValidationHelper.GetInteger(QueryHelper.GetString("ObjectId"), 0);
            var staticData = new StaticData();
            if (objId == TuEntityEnum.New_Transfer.GetHashCode())
                staticData.AddParameter("OperationType", DbType.Int32, 1);
            if (objId == TuEntityEnum.New_Payment.GetHashCode())
                staticData.AddParameter("OperationType", DbType.Int32, 2);

            staticData.AddParameter("systemuserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            var message =
                ValidationHelper.GetString(
                    staticData.ExecuteScalar("EXEC spGetCountryTransferMessages @OperationType,@systemuserId"));
            hdnMessage.Value = message;


            QScript("var ret = hdnMessage.getValue();window.parent.TuLabelMessage.setValue(ret);");
        }
        catch (Exception)
        {


        }

    }
}