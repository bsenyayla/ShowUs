using System;
using AjaxPro;
using Coretech.Crm.PluginData;
using System.Data;
using Coretech.Crm.Web.UI.RefleX;

public partial class SenderDocument_SenderDocument : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Utility.RegisterTypeForAjax(typeof(AjaxMethods));
        QScript("PageLoad();");
    }
    //protected override void OnInit(EventArgs e)
    //{
    //    var p = this.Page as BasePage;
    //    if (p != null)
    //    {
    //        p.AfterSaveHandler += p_AfterSaveHandler;
    //    }
    //}
    //private void p_AfterSaveHandler(Guid recId, DynamicFactory df, DynamicEntity de, bool IsUpdate)
    //{
    //    if(senderDocumentFile.HasFile)
    //    {
    //        if(!senderDocumentFile.FileName.EndsWith(".pdf"))
    //        {
    //            Alert("Lütfen pdf dosyası yükleyin.");
    //            return;
    //        }
    //        else
    //        {
    //            SenderDocumentService documentService = new SenderDocumentService();
    //            var fileName = documentService.GetSenderDocumentFileName(recId);
    //            SenderDocumentWriterFactory documentFactory = new SenderDocumentWriterFactory(SenderDocumentFileFormat.Extension.Pdf,fileName, recId);
    //            documentFactory.CreateDocument(senderDocumentFile.FileBytes);
    //        }
    //    }
    //}


    [AjaxNamespace("AjaxMethods")]
    public class AjaxMethods
    {
        [AjaxMethod()]
        public void UpdateDocumentReceivedFlg(Guid SenderDocumentID)
        {
            StaticData sd = new StaticData();
            sd.AddParameter("SenderDocumentID", DbType.Guid, SenderDocumentID);
            sd.ExecuteNonQuerySp("spTUSenderDocumentUpdateReceivedFlg");
        }
    }
}