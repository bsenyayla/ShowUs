using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Factory.Crm.Calendar;
using Coretech.Crm.Factory.Crm.Dynamic;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Labels;
using Coretech.Crm.Objects.Crm.View;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Objects.Crm.Calendar;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Web.UI.RefleX.View;

public partial class Calendar : /*System.Web.UI.Page*/ BasePage
{
    JavaScriptSerializer objSerialized = new JavaScriptSerializer();
    void TranslateMessage()
    {
        CalenderList.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CALENDAR);
        CalenderResourses.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_ENTITY_RESOURCE);
        var CalendarMessage = new
        {
            CALENDAR_DAY = CrmLabel.TranslateMessage(LabelEnum.CALENDAR_DAY),
            CALENDAR_WEEK = CrmLabel.TranslateMessage(LabelEnum.CALENDAR_WEEK),
            CALENDAR_MONTH = CrmLabel.TranslateMessage(LabelEnum.CALENDAR_MONTH),
            CultureCode = App.Params.CurrentUser.CultureCode
        };

        Page.ClientScript.RegisterClientScriptBlock(typeof(string), "CalendarMessage", "var CalendarMessage=" + objSerialized.Serialize(CalendarMessage) + ";", true);


        LiteralControl jsResource = new LiteralControl();
        jsResource.Text = "<script type=\"text/javascript\" src=\"" + string.Format("CalendarAsset/lang/{0}.js", App.Params.CurrentUser.CultureCode) + "\"></script>";
        CalendarAsset.Controls.Add(jsResource);

        //Page.ClientScript.RegisterClientScriptInclude("CalendarAssetlanguage", );


    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            FillCalendarList();
           
            FillCalenderResourses();
            TranslateMessage();
            QScript("setTimeout(new Function(\"btnEvents.click();\"),1000);");
        }
    }
    private void FillCalendarList()
    {
        var calendarFactory = new CalendarFactory();
        var list = calendarFactory.GetUserCalendarMatchList();
        if (list.Count > 0)
        {
            foreach (var calendarMatch in list)
            {
                CalenderList.AddItem(new ListItem(calendarMatch.CalendarMatchId.ToString(), calendarMatch.CalendarMatchname));
            }
            CalenderList.Value = list[0].CalendarMatchId.ToString();
            CalenderList.SetValue(list[0].CalendarMatchId.ToString());
        }
    }
    private void FillCalenderResourses()
    {
        var calendarFactory = new CalendarFactory();
        var cm = calendarFactory.GetUserCalendarMatchByMatchId(ValidationHelper.GetGuid(CalenderList.Value));
        var list = calendarFactory.GetAllResources(cm[0].ResourceId);
        //CalenderResourses.ClearItems();
        if (list.Count > 0)
        {
            foreach (var resource in list)
            {
                CalenderResourses.AddItem(new ListItem(resource.Key.ToString(), resource.Value));
            }
            CalenderResourses.Value = list.First().Key.ToString();
            CalenderResourses.SetValue(list.First().Key.ToString());
        }
        //CalenderResourses.DataBind();
    }

    protected void CalenderEvent(object sender, AjaxEventArgs e)
    {
        var tarih1 = ValidationHelper.GetDate(date1.Value);
        var tarih2 = ValidationHelper.GetDate(date2.Value);
        if (CalenderResourses.Value == string.Empty)
        {
            Alert("Hiçbir kayıt bulunamadı");
            return;
        }
        var datas = GetCalendarData(ValidationHelper.GetGuid(CalenderList.Value), tarih1, tarih2, CalenderResourses.Value);
        if (datas.Count > 0)
        {

            QScript(" BindFullCalendarData(" + objSerialized.Serialize(datas.First().GetFullCalendarData()) + ");");
        }
    }

    protected void CalenderListOnChange(object sender, AjaxEventArgs e)
    {
        FillCalenderResourses();
        CalenderEvent(sender,e);
    }
    public List<CalendarData> GetCalendarData(Guid calendarmatchId, DateTime date1, DateTime date2, string resourceId)
    {
        var ret = new List<CalendarData>();
        var calendarFactory = new CalendarFactory();
        var mylist = calendarFactory.GetUserCalendarMatchByMatchId(calendarmatchId);

        var myCalendar = new CalendarMatch();

        if (mylist.Count > 0)
        {
            myCalendar = mylist[0];
        }
        else
        {
            return new List<CalendarData>();
        }

        var ctType = calendarFactory.GetCalendarType();
        if (!App.Params.CurrentView.ContainsKey(myCalendar.ViewQueryId))
        {
            Alert("Hiçbir kayıt bulunamadı");
            return ret;
        }
        var gp = new GridPanelView(0, ValidationHelper.GetGuid(myCalendar.ViewQueryId), "");

        const string onOrAfter = "DEE5B907-10FE-4338-9240-441E4D20BEEB";
        const string onOrBefore = "B836B5EA-5866-49CC-B6AD-F11B58D41E30";
        const string eq = "85D01F29-40A6-4D62-9F8B-065A05C94B65";
        gp.View.FilterEntity.FilterAttributeList.Add(new FilterAttribute
        {
            attributeid = myCalendar.StartDateId,
            type = "0",
            clausevalue = date2.ToShortDateString(),
            conditiontype = ConditionType.Default,
            conditionvalue = ValidationHelper.GetGuid(onOrBefore),

        });
        gp.View.FilterEntity.FilterAttributeList.Add(new FilterAttribute
        {
            attributeid = myCalendar.EndDateId,
            type = "0",
            clausevalue = date1.ToShortDateString(),
            conditiontype = ConditionType.Default,
            conditionvalue = ValidationHelper.GetGuid(onOrAfter),

        });
        gp.View.FilterEntity.FilterAttributeList.Add(new FilterAttribute
        {
            attributeid = myCalendar.ResourceId,
            type = "0",
            clausevalue = resourceId,
            conditiontype = ConditionType.Default,
            conditionvalue = ValidationHelper.GetGuid(eq),

        });
        int totalCount;
        var dtb = new DataTable();
        var sorts = new List<Sorts>();
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

        for (int i = 0; i < sorts.Count; i++)
        {
            foreach (var v in gp.View.ColumnSet.Where(xx => xx.UniqueName == sorts[i].Field))
            {
                sorts[i].Field = GetSortField(v.AttributeId);
            }
        }
        gp.GetGridPanelViwerData("", 0, 1000, "", sorts, "", out totalCount, "", ref dtb, "", "", "", "");

        var dataList = new Dictionary<Guid, List<CalendarDataContent>>();
        var valueList = new Dictionary<Guid, string>();
        objectId.SetValue(myCalendar.ObjectId);
        resId.SetValue(myCalendar.ResourceId);
        startId.SetValue(myCalendar.StartDateId);
        endId.SetValue(myCalendar.EndDateId);
        if (dtb.Rows.Count > 0)
        {
            foreach (DataRow row in dtb.Rows)
            {
                var id =
                    ValidationHelper.GetGuid(row[App.Params.CurrentEntityAttribute[myCalendar.ResourceId].UniqueName]);
                if (!dataList.ContainsKey(id))
                {
                    dataList.Add(id, new List<CalendarDataContent>());
                    valueList.Add(id, ValidationHelper.GetString(row[App.Params.CurrentEntityAttribute[myCalendar.ResourceId].ReferencedLookupName]));
                }

                if (dataList.ContainsKey(id))
                {
                    var iteM = dataList[id];

                    var nitem = new CalendarDataContent();
                    if (myCalendar.AllDayId != Guid.Empty)
                        nitem.AllDay =
                            ValidationHelper.GetBoolean(
                                row[App.Params.CurrentEntityAttribute[myCalendar.AllDayId].UniqueName].ToString());

                    if (myCalendar.HeaderTextId != Guid.Empty)
                        nitem.Header = ValidationHelper.GetString(row[App.Params.CurrentEntityAttribute[myCalendar.HeaderTextId].UniqueName]);
                    if (myCalendar.DetailTextId != Guid.Empty)
                        nitem.Detail = ValidationHelper.GetString(row[App.Params.CurrentEntityAttribute[myCalendar.DetailTextId].UniqueName]);

                    if (myCalendar.StartDateId != Guid.Empty)
                        nitem.StartDate = ValidationHelper.GetDate(row[App.Params.CurrentEntityAttribute[myCalendar.StartDateId].UniqueName]);
                    if (myCalendar.EndDateId != Guid.Empty)
                        nitem.EndDate = ValidationHelper.GetDate(row[App.Params.CurrentEntityAttribute[myCalendar.EndDateId].UniqueName]);

                    if (myCalendar.CalenderTypeId != Guid.Empty)
                    {
                        var colorId =
                            ValidationHelper.GetGuid(
                                row[App.Params.CurrentEntityAttribute[myCalendar.CalenderTypeId].UniqueName]);

                        if (ctType.ContainsKey(colorId))
                            nitem.BackGroundColor = ctType[colorId].CalendarColor;
                    }
                    nitem.ID = row["ID"].ToString();
                    iteM.Add(nitem);

                }
            }

        }
        var allResources = calendarFactory.GetAllResources(myCalendar.ResourceId);

        foreach (var resource in allResources.Keys)
        {
            if (!valueList.ContainsKey(resource))
            {
                valueList.Add(resource, allResources[resource]);
            }
        }
        ret.AddRange(valueList.Select(myData => new CalendarData
        {
            ID = myData.Key.ToString(),
            VALUE = myData.Value,
            DATA = dataList.ContainsKey(myData.Key) ? dataList[myData.Key] : new List<CalendarDataContent>()
        }));

        return ret;
    }
    private static string GetSortField(Guid eaId)
    {
        var ea = App.Params.CurrentEntityAttribute[eaId];
        if (ea.AttributeTypeIdname == "datetime" || ea.AttributeTypeIdname == "smalldatetime")
        {
            return ea.UniqueName + "UtcTime";
        }
        return ea.UniqueName;
    }
    protected void BtnSaveOnClick(object sender, AjaxEventArgs e)
    {
        var calmatchid = ValidationHelper.GetGuid(CalenderList.Value);
        var startDate = ValidationHelper.GetDate(eventStartDate.Value);
        var endDate = ValidationHelper.GetDate(eventEndDate.Value);
        var eventRecid = ValidationHelper.GetGuid(selectedEventId.Value);

        var calendarFactory = new CalendarFactory();
        var myCalendar = calendarFactory.GetUserCalendarMatchByMatchId(calmatchid)[0];
        //myCalendar.EntityId
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        DynamicEntity de = new DynamicEntity(myCalendar.ObjectId);
        if (myCalendar.StartDateId != Guid.Empty)
            de.AddDateTimeProperty(App.Params.CurrentEntityAttribute[myCalendar.StartDateId].UniqueName, startDate);
        if (myCalendar.EndDateId != Guid.Empty)
            de.AddDateTimeProperty(App.Params.CurrentEntityAttribute[myCalendar.StartDateId].UniqueName, endDate);

        de.AddKeyProperty(EntityAttributeFactory.GetAttributePkString(de.ObjectId), eventRecid);

        df.Update(myCalendar.ObjectId, de);



    }
}