using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using TuFactory.EftRefundData;

public partial class Refund_NKolay_refundmonitor : BasePage
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void GridPanelEftMonitorOnEvent(object sender, AjaxEventArgs e)
    {
        EftRefundDataFactory eftRefundDataFactory = new EftRefundDataFactory();
        GridPanelEftMonitor.DataSource = eftRefundDataFactory.GetNKolayEftData(ValidationHelper.GetDate(StartDate.Value), ValidationHelper.GetDate(EndDate.Value), KrediBasvuruNo.Value);
        GridPanelEftMonitor.DataBind();
    }
}