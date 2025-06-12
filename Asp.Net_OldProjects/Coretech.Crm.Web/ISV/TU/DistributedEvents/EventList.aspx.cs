using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Utility;
using UPT.DistributedEvents.Business;
using UPT.DistributedEvents.Domain;

namespace Coretech.Crm.Web.ISV.TU.DistributedEvents
{
    public partial class EventList : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                dfStartDate.Value = DateTime.Today;
                dfEndDate.Value = DateTime.Today;

                IEnumerable<EventTypes> eventTypes = Enum.GetValues(typeof(EventTypes)).Cast<EventTypes>();
                for (int i = 0; i < eventTypes.Count(); i++)
                {
                    cfEventTypes.Items.Add(new RefleXFrameWork.ListItem(((int)eventTypes.ElementAt(i)).ToString(), EnumHelper.GetDescription(eventTypes.ElementAt(i))));
                }
            }
        }

        string ValidateDates(DateTime? startDate, DateTime? endDate, int dateRange)
        {
            if (startDate.HasValue && endDate.HasValue)
            {
                int days = endDate.Value.Subtract(startDate.Value).Days;
                if (days < 0)
                {
                    return "Bitiş tarihi, başlangıç tarihinden küçük olamaz.";
                }
                if (days > dateRange)
                {
                    return string.Format("{0} günden daha uzun aralık için gün sonu yapılamaz.", dateRange);
                }
            }
            else
            {
                return "Başlangıç tarihi ve bitiş tarihi bilgileri zorunludur.";
            }
            return string.Empty;
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 400;
            messageBox.Height = 200;
            messageBox.Show(messageText);
        }

        protected void Search(object sender, AjaxEventArgs e)
        {
            DateTime? startDate = dfStartDate.Value;
            DateTime? endDate = dfEndDate.Value;

            string validationMsg = ValidateDates(startDate, endDate, 15);
            if (string.IsNullOrEmpty(validationMsg))
            {
                gpEvents.DataSource = DistributedEventManager.GetEvents(startDate.Value, endDate.Value, (EventTypes?)null);
                gpEvents.DataBind();
            }
            else
            {
                ShowMessage(validationMsg);
            }
        }

        protected void ShowDetail(object sender, AjaxEventArgs e)
        {
            var rowSelectionModel = ((RowSelectionModel)gpEvents.SelectionModel[0]);
            if (rowSelectionModel != null && rowSelectionModel.SelectedRows != null)
            {
                Guid eventId = ValidationHelper.GetGuid(rowSelectionModel.SelectedRows[0].EventId);
                gpClients.DataSource = DistributedEventManager.GetEventProcessDetails(eventId);
                gpClients.DataBind();
                windowClients.Show();
            }
        }
    }
}