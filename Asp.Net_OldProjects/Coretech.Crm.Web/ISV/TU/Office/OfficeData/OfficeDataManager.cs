using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;

namespace Coretech.Crm.Web.ISV.TU.Office.OfficeData
{
    public class OfficeDataManager
    {
        public DataTable GetOfficeData(int ID, DateTime startDate, DateTime endDate)
        {
            DataTable dt = new DataTable();

            try
            {
                var sd = new StaticData();
                sd.AddParameter("ID", DbType.Int32, ID);
                if (startDate != DateTime.MinValue)
                {
                    sd.AddParameter("startDate", DbType.DateTime, startDate);
                }
                if (endDate != DateTime.MinValue)
                {
                    sd.AddParameter("endDate", DbType.DateTime, endDate);
                }
                dt = sd.ReturnDatasetSp("spGetOfficeData").Tables[0];
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Office.OfficeData.OfficeDataManager.GetOfficeData");
                throw ex;
            }

            return dt;
        }

        public int SaveOfficeData(string header, string fileName, string path, int interval, bool isInformationMail)
        {
            int result = 0;
            
            var sd = new StaticData();
            sd.AddParameter("HEADER", DbType.String, header);
            sd.AddParameter("FILENAME", DbType.String, fileName);
            sd.AddParameter("PATH", DbType.String, path);
            sd.AddParameter("CREATEDBY", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sd.AddParameter("CREATEDON", DbType.DateTime, DateTime.Now);
            sd.AddParameter("STATUS", DbType.String, 0); // Aktarım Bekliyor
            sd.AddParameter("INTERVAL", DbType.Int32, ValidationHelper.GetInteger(interval,0));
            sd.AddParameter("ISINFORMATIONMAIL", DbType.Boolean, isInformationMail);

            try
            {
                result = ValidationHelper.GetInteger(sd.ExecuteScalarSp("spSaveOfficeData"),0);
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Office.OfficeData.OfficeDataManager.SaveOfficeData");
                throw ex;
            }

            return result;
        }

        public DataTable GetOfficeDataDetail(int ID)
        {
            DataTable dt = new DataTable();

            try
            {
                var sd = new StaticData();
                sd.AddParameter("ID", DbType.Int32, ID);
                dt = sd.ReturnDatasetSp("spGetOfficeDataDetail").Tables[0];
            }
            catch (Exception ex)
            {
                LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.Office.OfficeData.OfficeDataManager.GetOfficeDataDetail");
                throw ex;
            }

            return dt;
        }

    }
}