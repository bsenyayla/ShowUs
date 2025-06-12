<%@ WebHandler Language="C#" Class="jsonCreater" %>

using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX.View;
using Newtonsoft.Json;
using CrmLabel = Coretech.Crm.Factory.Crm.CrmLabel;

public class jsonCreater : IHttpHandler, IReadOnlySessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html";

        var start = string.Empty;
        var limit = string.Empty;
        var sorts = new List<Sorts>();
        var dir = string.Empty;
        var query = string.Empty;
        var likes = string.Empty;
        var viewqueryid = string.Empty;
        var feachxml = string.Empty;
        var filename = string.Empty;
        var fieldssearch = string.Empty;
        var hierarchyparentid = string.Empty;
        var attributeid = string.Empty;
        var filterquery = string.Empty;
        var fromtype = string.Empty;
        if (!string.IsNullOrEmpty(context.Request["fromtype"]))
        {
            fromtype = context.Request["fromtype"];
        }

        if (!string.IsNullOrEmpty(context.Request["FileName"]))
        {
            filename = context.Request["FileName"];
        }

        if (!string.IsNullOrEmpty(context.Request["query"]))
        {
            query = context.Request["query"];
        }

        if (!string.IsNullOrEmpty(context.Request["start"]))
        {
            start = context.Request["start"];
        }

        if (!string.IsNullOrEmpty(context.Request["limit"]))
        {
            limit = context.Request["limit"];
        }

        if (!string.IsNullOrEmpty(context.Request["fieldssearch"]))
        {
            fieldssearch = context.Request["fieldssearch"];
        }

        if (!string.IsNullOrEmpty(context.Request["dir"]))
        {
            dir = context.Request["dir"];
        }

        if (!string.IsNullOrEmpty(context.Request["sort"]))
        {
            var sort = context.Request["sort"];
            sorts = JsonConvert.DeserializeObject<List<Sorts>>(sort);
        }

        if (!string.IsNullOrEmpty(context.Request["likes"]))
        {
            likes = context.Request["likes"];
        }

        if (!string.IsNullOrEmpty(context.Request["viewqueryid"]))
        {
            viewqueryid = context.Request["viewqueryid"];
        }
        if (!string.IsNullOrEmpty(context.Request["viewqueryname"]))
        {
            foreach (var item in
                App.Params.CurrentView.Values.Where(item => item.UniqueName == context.Request["viewqueryname"]))
            {
                viewqueryid = item.ViewQueryId.ToString();
            }
        }
        if (!string.IsNullOrEmpty(context.Request["feachxml"]))
        {
            feachxml = context.Request["feachxml"];
        }
        if (!string.IsNullOrEmpty(context.Request["attributeid"]))
        {
            attributeid = context.Request["attributeid"];
        }
        if (!string.IsNullOrEmpty(context.Request["wsresultid"]))
        {
        }

        if (!string.IsNullOrEmpty(context.Request["ExportType"]))
        {
            var exporttype = context.Request["ExportType"];
            if (exporttype == "1")
                limit = "0";
        }
        if (!string.IsNullOrEmpty(context.Request["hierarchyparentid"]))
        {
            hierarchyparentid = ValidationHelper.GetString(context.Request["hierarchyparentid"]);
            if (hierarchyparentid.Length < 20)
            {
                hierarchyparentid = "";
            }
        }
        if (!string.IsNullOrEmpty(context.Request["filterquery"]))
        {
            filterquery = context.Request["filterquery"];
        }
        int totalCount;

        if (!App.Params.CurrentUser.IsLoggedIn)
        {
            context.Response.Write("{script:true,Success:false,Message:'User not found. Please login first'}");
            return;
        }
        //Güvenlik kontrolü bu view i gorme hakkı yoksa getirme
        var vf = new ViewFactory();
        if (!vf.GetViewQueryPrivilege(ValidationHelper.GetGuid(viewqueryid)))
        {
            context.Response.Write("{script:true,Success:false,Message:" + JsonConvert.SerializeObject(CrmLabel.TranslateMessage(LabelEnum.CRM_VIEW_NOT_SELECTED)) + "}");
            return;
        }

        var starttime = DateTime.Now;
        var dtb = new DataTable();
        var gp = new GridPanelView(0, ValidationHelper.GetGuid(viewqueryid), filterquery);
        if (sorts.Count <= 0)
        {
            sorts.Clear();

            sorts.AddRange(
                from item in gp.View.ColumnSet.Where(item => item.OrderNumber != null).OrderBy(item => item.OrderNumber)
                let ea = App.Params.CurrentEntityAttribute[ValidationHelper.GetGuid(item.AttributeId)]
                select string.IsNullOrEmpty(ea.ReferencedLookupName)
                           ? new Sorts { Direction = item.Direction == "0" ? "ASC" : "DESC", Field = ea.UniqueName }
                           : new Sorts
                                 {
                                     Direction = item.Direction == "0" ? "ASC" : "DESC",
                                     Field = ea.ReferencedLookupName
                                 });

            if (sorts.Count <= 0)
            {
                var si = new Sorts { Direction = "ASC", Field = gp.GetStoreData()[0].Name };
                sorts.Add(si);
            }
        }

        var sumList = new ViewTotal();


        foreach (var t in sorts)
        {
            foreach (var v in gp.View.ColumnSet.Where(xx => xx.UniqueName == t.Field))
            {
                t.Field = GetSortField(v.AttributeId);
            }
        }

        try
        {
            gp.GetGridPanelViwerData(query, ValidationHelper.GetInteger(start, 0), ValidationHelper.GetInteger(limit, 0), dir, sorts, likes, out totalCount, ref sumList, feachxml, ref dtb, fieldssearch, hierarchyparentid, attributeid, fromtype);

        }
        catch (CrmException ex)
        {

            if (string.IsNullOrEmpty(ex.ErrorMessage) && ex.ErrorId > 0)
                context.Response.Write("{script:true,Success:false,Message:'" +
                                       string.Format(CrmLabel.TranslateMessage(LabelEnum.CRM_APPLICATION_ERROR),
                                                     ex.ErrorId) + "'}");
            return;

        }


        var serializer = new JavaScriptSerializer();
        List<string> passwordColumns;
        var rows = gp.GetDataList(dtb, out passwordColumns);
        if (!string.IsNullOrEmpty(filename))
        {
            gp.Export(filename, dtb, passwordColumns);

            return;
        }
        serializer.MaxJsonLength = int.MaxValue;
        var output = serializer.Serialize(rows);
        if (sumList.OutValues[0].Count == 0)
        {
            sumList.OutValues = null;
        }
        var totalOutput = serializer.Serialize(gp.GetDataListTotal(sumList));
        var endtime = DateTime.Now - starttime;
        context.Response.Write(String.Format("{{elapsedtime:\"{2}\", totalCount:{1},sumList:{3},Records : {0}}}", output, totalCount, endtime.Minutes + ":" + endtime.Seconds + ":" + endtime.Milliseconds, totalOutput));
    }




    private string GetSortField(Guid eaId)
    {
        var ea = App.Params.CurrentEntityAttribute[eaId];
        if (ea.AttributeTypeIdname == "datetime" || ea.AttributeTypeIdname == "smalldatetime")
        {
            return ea.UniqueName + "UtcTime";
        }
        return ea.UniqueName;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}