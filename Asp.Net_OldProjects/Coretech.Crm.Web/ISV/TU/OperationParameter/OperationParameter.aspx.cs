using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Data;

namespace Coretech.Crm.Web.ISV.TU.OperationParameter
{
    public partial class OperationParameter_OperationParameter : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void SaveOnEvent(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("ParameterId", DbType.Guid, ValidationHelper.GetGuid(hdnSelectedId.Value));
            sd.AddParameter("Data", DbType.String, txtParameterName.Value);
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

            try
            {
                sd.ExecuteNonQuerySp("spAddOperationParameter");
                QScript("alert('işlem başarıyla onaya gönderildi');FrmOperationParameter.hide();");
                gpOperationParameter.Reload();
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "OperationParameter_OperationParameter.SaveOnEvent");
                throw ex;
            }
        }

        protected void ConfirmOnEvent(object sender, AjaxEventArgs e)
        {
            if (hdnConfirmType.Value == "1")
            {
                QScript("alert('Dikkat! işlem statüsü onay için uygun değil');");
                return;
            }

            if (hdnCreatedBy.Value == App.Params.CurrentUser.SystemUserId.ToString())
            {
                QScript("alert('Dikkat! Bu parametreyi onaylama hakkınız bulunamamaktadır');");
                return;
            }

            var sd = new StaticData();
            sd.AddParameter("ParameterId", DbType.Guid, ValidationHelper.GetGuid(hdnSelectedId.Value));
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

            try
            {
                sd.ExecuteNonQuerySp("spConfirmOperationParameter");
                QScript("alert('işlem başarıyla Onaylandı');");
                gpOperationParameter.Reload();
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "OperationParameter_OperationParameter.RejectOnEvent");
                throw ex;
            }
        }

        protected void RejectOnEvent(object sender, AjaxEventArgs e)
        {
            if (hdnConfirmType.Value == "1")
            {
                QScript("alert('Dikkat! yalnızca onaydaki işlemler reddedilebilir');");
                return;
            }

            if (hdnCreatedBy.Value != App.Params.CurrentUser.SystemUserId.ToString())
            {
                QScript("alert('Dikkat! Bu parametreyi reddetme hakkınız bulunamamaktadır');");
                return;
            }

            var sd = new StaticData();
            sd.AddParameter("ParameterId", DbType.Guid, ValidationHelper.GetGuid(hdnSelectedId.Value));
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

            try
            {
                sd.ExecuteNonQuerySp("spRejectOperationParameter");
                QScript("alert('işlem başarıyla reddedildi');");
                gpOperationParameter.Reload();
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "OperationParameter_OperationParameter.RejectOnEvent");
                throw ex;
            }
        }



        protected void FindOnEvent(object sender, AjaxEventArgs e)
        {
            var sd = new StaticData();
            sd.AddParameter("ParameterName", DbType.String, txtSearch.Value);

            try
            {
                var dt = sd.ReturnDatasetSp("spGetOperationParameter").Tables[0];
                if (dt.Rows.Count > 0)
                {
                    gpOperationParameter.DataSource = dt;
                    gpOperationParameter.DataBind();
                }
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "OperationParameter_OperationParameter.FindOnEvent");
                throw ex;
            }
        }
    }
}