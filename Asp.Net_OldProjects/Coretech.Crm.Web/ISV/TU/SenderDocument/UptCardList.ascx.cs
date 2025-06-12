using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Db;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using TuFactory.SenderDocument;
using TuFactory.UptCard.Business;

public partial class SenderDocument_UptCardList : System.Web.UI.UserControl
{

    private const string GridName = "SenderCardDocuments";

    public bool CanShowList { get; set; }

    public Guid SenderId { get; set; }

    private List<string> _requiredDocument;
    public List<string> RequiredDocuments
    {
        get
        {
            if (_requiredDocument == null)
            {
                _requiredDocument = new List<string>();
            }
            return _requiredDocument;
        }
        set { _requiredDocument = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            Page.ClientScript.RegisterStartupScript(typeof(string), "SenderDocumentFormId", "var senderDocumentFormID = "
                + JsonConvert.SerializeObject(App.Params.GetConfigKeyValue("SENDER_DOCUMENT_FORM_ID")) + "; ", true);
            Page.ClientScript.RegisterStartupScript(typeof(string), "SenderID", "var senderID = "
                + JsonConvert.SerializeObject(SenderId) + "; ", true);

        }
    }

    public void CreateDocumentsIfNecessary()
    {
        if (RequiredDocuments.Count > 0)
        {
            SenderDocumentFactory docService = new SenderDocumentFactory();
            docService.InsertCardDocumentsIfNecessary(SenderId, RequiredDocuments);
            CreateViewGrid();
        }
    }

    public void CreateViewGrid()
    {
        var gpc = new GridPanelCreater();
        gpc.CreateViewGrid(GridName, gpUptCard, true);
    }
    protected void gpUptCardReload(object sender, AjaxEventArgs e)
    {
        var sort = gpUptCard.ClientSorts() ?? string.Empty;
        var spList = new List<CrmSqlParameter>();
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName(GridName);
        DataTable dtb;
        List<Dictionary<string, object>> t;

        new CardClientService().GetCardDocumentList(sort, out spList, SenderId, viewqueryid, gpUptCard.Start(), gpUptCard.Limit(), out dtb, out t);

        if (e.ExtraParams != null && e.ExtraParams["Excel"] != null &&
            ValidationHelper.GetInteger(e.ExtraParams["Excel"]) == 1)
        {
            var gpw = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid));
            gpw.Export(dtb);
        }
        gpUptCard.DataSource = t;
        gpUptCard.TotalCount = t.Count;
        gpUptCard.DataBind();
    }


}