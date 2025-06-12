using Coretech.Crm.PluginData;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class UpdateUserPasswords : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    { 
        //UpdateAllUserPasswords();
    }
    public static void ResetUserPassword(Guid sytemUserId, string passwordnew)
    {
        Coretech.Crm.Data.Crm.User.UserDb userDb = new Coretech.Crm.Data.Crm.User.UserDb();
        userDb.ResetUserPassword(sytemUserId, passwordnew);
    }

    public static DataTable GetAllUsers()
    {
        List<Guid> retval = new List<Guid>();
        StaticData sd = new StaticData();
        //string sql = @" select  SYSTEMUSERID, PasswordOriginal FROM SystemUserbase WHERE  SYSTEMUSERID not in('00000000-AAAA-BBBB-CCCC-000000000001','00000000-AAAA-BBBB-CCCC-000000000002','00000001-09A9-4610-83D5-58A8C7261081','00000001-EDA5-48D6-839C-65DC32D8B9A6','00000001-57CC-474A-AA24-890182A601D4')";
        string sql = @" select          SYSTEMUSERID, 
                                        PasswordOriginal 
                                FROM    SystemUserbase 
                                where   PassWord in ('KOYUNCUAS','12345678','123456','4228238','12345CEM','12345678','4228238','12345CEM')
                                        AND DeletionStateCode = 0";
        var data = sd.ReturnDataset(sql);
        return data.Tables[0];
    }

    public static void UpdateAllUserPasswords()
    {
        DataTable dt = GetAllUsers();
        foreach (DataRow dr in dt.Rows)
        {
            Guid userId = new Guid(dr["SYSTEMUSERID"].ToString());
            string password = dr["PasswordOriginal"].ToString();
            ResetUserPassword(userId, password);
        }
    }
}