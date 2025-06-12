using System;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using TuFactory.Object;
using TuFactory.Reports;
using RefleXFrameWork;
using TuFactory.Confirm;

public partial class TransferResult : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            hdnRecId.Value = QueryHelper.GetString("recid");
            hdnReportId.Value = ValidationHelper.GetString(TuReports.GetReportId(TuReportTypeEnum.TalepFormu,
                                                             TuEntityEnum.New_Transfer,
                                                             ValidationHelper.GetGuid(hdnRecId.Value)));
        }
        catch (Exception)
        {


        }

    }
    protected void BtnInstructionOnEvent(object sender, AjaxEventArgs e)
    {

        var tdb = new ConfirmFactory();
        var trans = new StaticData().GetDbTransaction();
        /*Trunsaction icerisinde statü hataliya cevrilir ve kasaya kayit atilir.
         *Kasa Not kasa icerisinde  yalnızca ('TR000','TR004C','TR005C') statülerinde kasa hareketleri calismaktadir 'TR000E' hareketi bir sonraki 
         *TransferConfirm isleminde calismayacaktir.
         */
        try
        {
            tdb.UpdateConfirmStatusTo3rdTransactionErrorVait(ValidationHelper.GetGuid(hdnRecId.Value), trans);
            tdb.InsertCashTransaction(ValidationHelper.GetGuid(hdnRecId.Value), trans);
            StaticData.Commit(trans);
            QScript("ShowInstruction();window.parent.location=window.parent.location;");
            /*
             Ana Gönderim Kaydi Refreshlenerek bundan sonra Tekrar Dekont basilmasi engellenmeli.
             */
        }
        catch (TuException exct)
        {
            exct.Show();
            StaticData.Rollback(trans);
        }
        catch (Exception exc)
        {
            var ecxt = new TuException() { ErrorMessage = exc.Message };
            ecxt.Show();
            StaticData.Rollback(trans);
        }
        
    }
}