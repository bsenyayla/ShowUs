<%@ Page Language="C#" AutoEventWireup="true" Inherits="Calendar"
    ValidateRequest="false" Codebehind="Calendar.aspx.cs" %>

<%@ Register Assembly="RefleXFrameWork" Namespace="RefleXFrameWork"
    TagPrefix="rx" %>
<html>
<meta charset='utf-8' />
<head runat="server">
    <title></title>

    <style>
        body {
            margin: 40px 10px;
            padding: 0;
            font-family: "Lucida Grande",Helvetica,Arial,Verdana,sans-serif;
            font-size: 14px;
        }

        #calendar {
            max-width: 100px;
            margin: 0 auto;
        }
    </style>
    <script src="../../js/Global.js"></script>
    <link href="CalendarAsset/fullcalendar.css" rel="stylesheet" />
    <link href="CalendarAsset/fullcalendar.print.css" rel="stylesheet" media='print' />

</head>
<body>
    <form id="form1" runat="server">

        <rx:RegisterResources runat="server" ID="RR" />
        <rx:Hidden runat="server" ID="calMode" Value="Day" />
        <rx:Hidden runat="server" ID="objectId" />
        <rx:Hidden runat="server" ID="resId" />
        <rx:Hidden runat="server" ID="startId" />
        <rx:Hidden runat="server" ID="endId" />
        <rx:Hidden runat="server" ID="date1" />
        <rx:Hidden runat="server" ID="date2" />

        <rx:Hidden runat="server" ID="eventStartDate" />
        <rx:Hidden runat="server" ID="eventEndDate" />
        <rx:Hidden runat="server" ID="selectedEventId" />

        <div style="display: none">
            <rx:Button runat="server" ID="btnEvents">
                <AjaxEvents>
                    <Click Before="PrepareEvents();" OnEvent="CalenderEvent"></Click>
                </AjaxEvents>
            </rx:Button>
            <rx:Button runat="server" ID="btnSave">
                <AjaxEvents>
                    <Click Before="PrepareEvents();" OnEvent="BtnSaveOnClick"></Click>
                </AjaxEvents>
            </rx:Button>
        </div>
        <rx:PanelX runat="server" ID="pnlfunny" Height="50" AutoHeight="Normal">
            <Body>
                <rx:ToolBar runat="server" ID="toolCalendar">
                    <Items>
                        
                        <rx:ComboField runat="server" ID="CalenderList" Mode="Local" FieldLabel="LBL_CALENDAR" FieldLabelWidth="150">
                            <AjaxEvents>
                                <Change OnEvent="CalenderListOnChange"/>
                            </AjaxEvents>
                            
                        </rx:ComboField>
                        <rx:Label runat="server" id="lblSpace" value="" FieldLabelWidth="150"  />
                        <rx:ComboField runat="server" ID="CalenderResourses" Mode="Local" FieldLabel="LBL_RESOURCES" FieldLabelWidth="150">
                            <Listeners>
                                <Change Handler="btnEvents.click();"></Change>
                            </Listeners>
                        </rx:ComboField>
                    </Items>
                </rx:ToolBar>
            </Body>
        </rx:PanelX>
        <div class="calendar" style="width: 800px" id="calendar1"></div>

        <div id="CalendarAsset" runat="server" style="display: none">
            <script src="CalendarAsset/lib/moment.min.js"></script>
            <script src="CalendarAsset/lib/jquery-ui.custom.min.js"></script>
            <script src="CalendarAsset/fullcalendar.js"></script>
        </div>

    </form>
</body>
</html>

<script type="text/javascript">
    var ListData = [];
    $(document).ready(function () {
        function Create(id) {
            $(id).fullCalendar({
                customButtons: {
                    btnprev: {
                        text: 'prev',
                        click: function () {
                            $("#calendar1").fullCalendar('prev');
                            btnEvents.click();
                        }
                    },
                    btnnext: {
                        text: 'next',
                        click: function () {
                            $("#calendar1").fullCalendar('next');
                            btnEvents.click();
                        }
                    },
                    btntoday: {
                        text: 'today',
                        click: function () {
                            $("#calendar1").fullCalendar('today');
                            btnEvents.click();
                        }
                    },
                    btnmonth: {
                        text: CalendarMessage.CALENDAR_MONTH,
                        click: function () {
                            $("#calendar1").fullCalendar('changeView', "month");
                            btnEvents.click();
                        }
                    },
                    btnagendaWeek: {
                        text: CalendarMessage.CALENDAR_WEEK,
                        click: function () {
                            $("#calendar1").fullCalendar('changeView', "agendaWeek");
                            btnEvents.click();
                        }
                    },
                    btnagendaDay: {
                        text: CalendarMessage.CALENDAR_DAY,
                        click: function () {
                            $("#calendar1").fullCalendar('changeView', "agendaDay");
                            btnEvents.click();
                        }
                    },
                },
                header: {
                    left: 'btnprev btnnext btntoday',
                    center: 'title',
                    right: 'btnmonth,btnagendaWeek,btnagendaDay'
                },
                lang: CalendarMessage.CultureCode,
                defaultView: 'agendaDay',
                editable: true,
                selectable: true,
                displayEventEnd: true,
                displayEventTime: true,
                eventLimit: true, // allow "more" link when too many events
                events: [],
                eventClick: function (calEvent, jsEvent, view) {
                    //alert('Event: ' + calEvent.title);
                    //alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);
                    //alert('View: ' + view.name);

                    // change the border color just for fun
                    $(this).css('border-color', 'red');
                },
                eventDrop: function (event, delta, revertFunc) {
                    //alert(event.title + " was dropped on " + event.start.format());
                    if (!confirm("Değişiklikleri kaydetmek istediğinize emin misiniz?")) {
                        revertFunc();
                    } else {
                        SaveEventStatus(event.id, event.start, event.end);
                        return true;
                    }

                },
                eventResize: function (event, delta, revertFunc) {

                    //alert(event.title + " end is now " + event.end.format());

                    if (!confirm("Değişiklikleri kaydetmek istediğinize emin misiniz?")) {
                        revertFunc();
                    } else {
                        SaveEventStatus(event.id, event.start, event.end);
                        return true;
                    }

                },
                eventDestroy: function (event, delta) {

                },
                eventRender: function (event, element, view) {
                    $(element).attr("data-id", event.id);
                    element.bind('dblclick', function () {
                        //alert(' click!' + $(this).attr("data-id"));
                        ShowEditWindow('CrmCalendar', $(this).attr("data-id"), undefined, objectId.getValue(), undefined, false);
                    });
                },
                select: function (start, end, jsEvent, view, aaa) {
                    //start, end
                    //debugger;
                    if (view.type === "month") {
                        $("#calendar1").fullCalendar('changeView', "agendaDay");
                        $("#calendar1").fullCalendar('gotoDate', start);
                    } else if (view.type === "agendaDay") {


                        var startString = start.format("DD.MM.YYYY HH:SS");//time.startTime.toString(CrmCalendar.dateTimeFormat);
                        var endString = end.format("DD.MM.YYYY HH:SS");//time.endTime.toString(CrmCalendar.dateTimeFormat);
                        debugger;
                        ShowEditWindow('CrmCalendar', '', undefined, objectId.getValue(), CreateFXml(CalenderResourses.selectedRecord.Value, startString, endString), false);

                    }

                },

            });
        }
        Create("#calendar1");

        //$('#calendar1').fullCalendar('renderEvent', { id: 1, title: 'New event', start: new Date() }, true);
        //$('#calendar1').fullCalendar('removeEvents');
        //$('#calendar1').fullCalendar('renderEvent', { id: 1, title: 'New event', start: new Date() }, true);
        //var clientEvents = $('#calendar1').fullCalendar('clientEvents');

    });

    var CrmCalendar =
    {
        getData: function () {
            btnEvents.click();
        }
    }

    var PrepareEvents = function () {
        var view = $('#calendar1').fullCalendar('getView');
        date1.setValue(view.start.format());
        date2.setValue(view.end.format());
        return true;

    }
    function CreateFXml(recId, start, end) {
        var strQuery = "";
        strQuery += "<f objectid='" + objectId.getValue() + "'>";
        strQuery += "<w id='" + resId.getValue() + "' value='" + recId + "'/>";
        strQuery += "<w id='" + startId.getValue() + "' value='" + start + "'/>";
        strQuery += "<w id='" + endId.getValue() + "' value='" + end + "'/>";
        strQuery += "</f>";
        return strQuery;
    }

    function ItemClick(rec) {
        if (CalendarGrid.activeCol == 1)
            return;
        if (rec) {
            ShowEditWindow('CrmCalendar', rec.ID, undefined, objectId.getValue(), undefined, false);
        }
        else {
            col = CalendarGrid.activeCol - 2;
            var time = CrmCalendar.getSelectedColumnTimes(col);
            var start = time.startTime.toString(CrmCalendar.dateTimeFormat);
            var end = time.endTime.toString(CrmCalendar.dateTimeFormat);

            ShowEditWindow('CrmCalendar', '', undefined, objectId.getValue(), CreateFXml(CalendarGrid.selectedRecord.ID, start, end), false);
        }
    }
    var BindFullCalendarData = function (data) {
        $('#calendar1').fullCalendar('removeEvents');
        $.each(data, function (id, item) {
            debugger;
            //$('#calendar1').fullCalendar('renderEvent', item, true);

            $('#calendar1').fullCalendar('renderEvent', { id: item.id, title: item.title ,detail:item.detatil, start: item.start, end: item.end, backgroundColor: item.backgroundColor }, true);
        });
    }
    var SaveEventStatus = function (id, start, end) {
        selectedEventId.setValue(id);
        eventStartDate.setValue(start.format());

        if (jQuery.isEmptyObject(end)) {
            eventEndDate.setValue(start.format());
        }
        else {
            eventEndDate.setValue(end.format());
        }
        btnSave.click();
        return true;
    }
</script>
