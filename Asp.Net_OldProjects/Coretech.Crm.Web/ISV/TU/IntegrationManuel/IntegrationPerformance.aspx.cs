using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using Coretech.Crm.Provider;
using Coretech.Crm.PluginData;
using System.Data;

public partial class IntegrationManuel_IntegrationPerformance : Page
{
    private class GridViewExportUtil
    {

        public static void Export(string fileName, GridView gv)
        {
            HttpContext.Current.Response.Clear();
            HttpContext.Current.Response.AddHeader(
                "content-disposition", string.Format("attachment; filename={0}", fileName));
            HttpContext.Current.Response.ContentType = "application/ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                using (HtmlTextWriter htw = new HtmlTextWriter(sw))
                {
                    //  Create a form to contain the grid
                    Table table = new Table();

                    //  add the header row to the table
                    if (gv.HeaderRow != null)
                    {
                        GridViewExportUtil.PrepareControlForExport(gv.HeaderRow);
                        table.Rows.Add(gv.HeaderRow);
                    }

                    //  add each of the data rows to the table
                    foreach (GridViewRow row in gv.Rows)
                    {
                        GridViewExportUtil.PrepareControlForExport(row);
                        table.Rows.Add(row);
                    }

                    //  add the footer row to the table
                    if (gv.FooterRow != null)
                    {
                        GridViewExportUtil.PrepareControlForExport(gv.FooterRow);
                        table.Rows.Add(gv.FooterRow);
                    }

                    //  render the table into the htmlwriter
                    table.RenderControl(htw);

                    //  render the htmlwriter into the response
                    HttpContext.Current.Response.Write(sw.ToString());
                    HttpContext.Current.Response.End();
                }
            }
        }

        /// <summary>
        /// Replace any of the contained controls with literals
        /// </summary>
        /// <param name="control"></param>
        private static void PrepareControlForExport(Control control)
        {
            for (int i = 0; i < control.Controls.Count; i++)
            {
                Control current = control.Controls[i];
                if (current is LinkButton)
                {
                    control.Controls.Remove(current);
                    control.Controls.AddAt(i, new LiteralControl((current as LinkButton).Text));
                }
                else if (current is ImageButton)
                {
                    control.Controls.Remove(current);
                    control.Controls.AddAt(i, new LiteralControl((current as ImageButton).AlternateText));
                }
                else if (current is HyperLink)
                {
                    control.Controls.Remove(current);
                    control.Controls.AddAt(i, new LiteralControl((current as HyperLink).Text));
                }
                else if (current is DropDownList)
                {
                    control.Controls.Remove(current);
                    control.Controls.AddAt(i, new LiteralControl((current as DropDownList).SelectedItem.Text));
                }
                else if (current is CheckBox)
                {
                    control.Controls.Remove(current);
                    control.Controls.AddAt(i, new LiteralControl((current as CheckBox).Checked ? "True" : "False"));
                }

                if (current.HasControls())
                {
                    GridViewExportUtil.PrepareControlForExport(current);
                }
            }
        }
    }

    private bool CheckUserOnline()
    {
        var stringWriter = new StringWriter();
        using (var w = new HtmlTextWriter(stringWriter))
        {
            if (!CrmEngine.Params.CurrentUser.IsLoggedIn)
            {
                var strUrl = ResolveUrl("~/Login.aspx");
                var strGo = "top.window.location='{0}';";
                strGo = string.Format(strGo, strUrl);
                w.RenderBeginTag(HtmlTextWriterTag.Script);
                Response.Clear();
                w.Write(strGo);
                w.RenderEndTag();
                Response.Write(stringWriter.ToString());
                Response.Flush();
                Response.End();
                return false;
            }
            return true;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            CheckUserOnline();
            tDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
        }
    }

    protected void GetReport(object sender, EventArgs e)
    {
        StaticData sd = new StaticData();
        sd.AddParameter("Date", DbType.Date, tDate.Text);
        sd.AddParameter("MinTime", DbType.Int32, tTime.Text);
        DataSet ds = sd.ReturnDatasetSp("spGetIntegrationPerformance");
        gvReport.DataSource = ds;
        gvReport.DataBind();
    }

    protected void ExportToExcel(object sender, EventArgs e)
    {
        GridViewExportUtil.Export(DateTime.Now.ToString("yyyy-MM-dd-hh-mm-ss") + "_IntegrationPerformanceReport.xls", gvReport);
    }
}