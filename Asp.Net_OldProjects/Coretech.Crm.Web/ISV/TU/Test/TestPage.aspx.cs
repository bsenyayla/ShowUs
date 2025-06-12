using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm._3rdServiceAutomation.Automation;
using Coretech.Crm.Factory;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.AccountStatement.Repository;
using TuFactory.PostMessage;
using UPT.CacheManagement.Service.Services;


namespace Coretech.Crm.Web.ISV.TU.Test
{
    public partial class TestPage : BasePage
    {
        protected override void OnPreInit(EventArgs e)
        {
            //var options = new ParallelOptions()
            //{
            //    MaxDegreeOfParallelism = ValidationHelper.GetInteger(App.Params.GetConfigKeyValue("FTP_PARALLELFOR_THREAD_COUNT"), 10)
            //};

            //Parallel.For(1, 10000, options, (i, state) =>
            // {
            //using (SqlConnection connection = new SqlConnection("Data Source=tutestcls.aktifbank.com.tr;Initial Catalog=DIVACRM_TU_LISANS;User ID=tu_lisans;Password=tu_452lisans; Max Pool Size=1000; Connection Timeout=300"))
            //{
            //    connection.Open();

            //    SqlCommand command = connection.CreateCommand();
            //    SqlTransaction transaction;

            //    // Start a local transaction.
            //    transaction = connection.BeginTransaction();

            //    // Must assign both transaction object and connection
            //    // to Command object for a pending local transaction
            //    command.Connection = connection;
            //    command.Transaction = transaction;

            //    try
            //    {

            //        command.CommandText = "Exec spGetSequenceId 'TR'";
            //        command.ExecuteNonQuery();

            //        LogUtil.Write(i.ToString());

            //        // Attempt to commit the transaction.
            //        transaction.Commit();
            //        Console.WriteLine("Both records are written to database.");
            //    }
            //    catch (Exception ex)
            //    {
            //        Console.WriteLine("Commit Exception Type: {0}", ex.GetType());
            //        Console.WriteLine("  Message: {0}", ex.Message);

            //        // Attempt to roll back the transaction.
            //        try
            //        {
            //            transaction.Rollback();
            //        }
            //        catch (Exception ex2)
            //        {
            //            // This catch block will handle any errors that may have occurred
            //            // on the server that would cause the rollback to fail, such as
            //            // a closed connection.
            //            Console.WriteLine("Rollback Exception Type: {0}", ex2.GetType());
            //            Console.WriteLine("  Message: {0}", ex2.Message);
            //        }
            //    }
            //}



            //    var sd = new StaticData();
            //    var tr = sd.GetDbTransaction();

            //    try
            //    {
            //        sd.AddParameter("OBJECTNAME", System.Data.DbType.String, "TR");
            //        sd.ExecuteNonQuerySp("spGetSequenceId", tr);
            //        LogUtil.Write(i.ToString());
            //        StaticData.Commit(tr);
            //    }
            //    catch (Exception ex)
            //    {
            //        StaticData.Rollback(tr);
            //        LogUtil.WriteException(ex);
            //    }

            //});


            //AccountStatementRepository accrep = new AccountStatementRepository();
            //accrep.ManualySendAccountStatement(new Guid("00000000-AAAA-BBBB-CCCC-000000000001"));

            //AccountStatementAutomation acc = new AccountStatementAutomation();
            //acc.RunAccountStatementExcelDaily(new Guid("00000000-AAAA-BBBB-CCCC-000000000001"));

            PostMessageFactory pmf = new PostMessageFactory();
            pmf.Start();


            //var s = new TuFactory.TransactionManagers.Transfer.TransferManager();

            //TuFactory.Domain.Transfer transfer = s.GetTransfer(Guid.Parse("D659495C-DEA4-4E14-B150-9187E65B46F2"));
            ////            TuFactory.Domain.Transfer transfer = new TuFactory.Domain.Transfer();
            ////transfer.
            //new TransferPostMessageService().AddPostMessage(transfer);

        }
    }

}
