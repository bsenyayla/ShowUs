using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.ServiceProcess;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace Coretech.Crm.Web.CrmPages.Admin.Monitoring
{
    public partial class WindowsServices : AdminPage
    {
        class Service
        {
            public string ServiceName { get; set; }

            public string Status { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack && !RefleX.IsAjxPostback)
            {
                panelHeader.Title = string.Format("{0} - {1} Windows Services", Environment.MachineName, GetIPAddress());
                Refresh(null, null);
            }
        }

        void BindData()
        {
            List<string> uptServices = new List<string>()
            {
                "Coretech.Crm.3rdServiceAutomation",
                "Coretech.Crm.EmailSenderLive",
                "Coretech.Crm.FTPAutomation",
                "Coretech.Crm.PostSender",
                "UPT Scheduler Service",
               
            };

            ServiceController[] services = ServiceController.GetServices();

            List<Service> uptServiceList = new List<Service>();
            IEnumerable<ServiceController> tempServiceControllers = null;

            for (int i = 0; i < uptServices.Count; i++)
            {
                tempServiceControllers = services.Where(s => s.ServiceName == uptServices[i]);
                if (tempServiceControllers != null && tempServiceControllers.Count() == 1)
                {
                    uptServiceList.Add
                    (
                        new Service()
                        {
                            ServiceName = tempServiceControllers.ElementAt(0).ServiceName,
                            Status = tempServiceControllers.ElementAt(0).Status.ToString()
                        }
                    );
                }
            }

            gridPanel.DataSource = uptServiceList;
            gridPanel.DataBind();
        }

        protected void Refresh(object sender, AjaxEventArgs e)
        {
            BindData();
        }

        protected void ServiceStart(object sender, AjaxEventArgs e)
        {
            var degerler = ((RowSelectionModel)gridPanel.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {
                string servicename = string.Empty;
                foreach (var row in degerler.SelectedRows)
                {
                    servicename = row.ServiceName;
                }
                if (!string.IsNullOrEmpty(servicename))
                {
                    ServiceController service = new ServiceController(servicename);
                    if (service != null && service.Status == ServiceControllerStatus.Running)
                    {
                        MessageBox msg = new MessageBox();
                        msg.Show("Servis zaten çalışıyor");
                    }
                    else
                    {
                        service.Start();
                    }

                }
                else
                {
                    MessageBox msg = new MessageBox();
                    msg.Show("Bir servis seçmelisiniz");
                }

            }
        }

        protected void ServiceStop(object sender, AjaxEventArgs e)
        {
            var degerler = ((RowSelectionModel)gridPanel.SelectionModel[0]);
            if (degerler != null && degerler.SelectedRows != null)
            {
                string servicename = string.Empty;
                foreach (var row in degerler.SelectedRows)
                {
                    servicename = row.ServiceName;
                }
                if (!string.IsNullOrEmpty(servicename))
                {
                    ServiceController service = new ServiceController(servicename);
                    if (service != null && service.Status == ServiceControllerStatus.Stopped)
                    {
                        MessageBox msg = new MessageBox();
                        msg.Show("Servis zaten durmuş");
                    }
                    else
                    {
                        service.Stop();
                    }

                }
                else
                {
                    MessageBox msg = new MessageBox();
                    msg.Show("Bir servis seçmelisiniz");
                }

            }
        }





        string GetIPAddress()
        {
            IPHostEntry ipHostInfo = Dns.GetHostEntry(Dns.GetHostName()); // `Dns.Resolve()` method is deprecated.
            IPAddress ipAddress = ipHostInfo.AddressList[0];

            return ipAddress.ToString();
        }
    }
}