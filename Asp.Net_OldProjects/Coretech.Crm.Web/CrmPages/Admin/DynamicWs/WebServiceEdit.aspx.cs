using System;
using System.Collections.Generic;
using System.Web.UI;
using Coretech.Crm.Factory.Crm.DynamicWs;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.DynamicWs;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coolite.Ext.Web;

public partial class CrmPages_Admin_DynamicWs_WebServiceEdit : AdminPage
{
    public CrmPages_Admin_DynamicWs_WebServiceEdit()
    {
        base.ObjectId = EntityEnum.Entity.GetHashCode();
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!Page.IsPostBack)
        {
            WebServiceId.Text = QueryHelper.GetString("WebServiceId");

            if (string.IsNullOrEmpty(WebServiceId.Text))
            {
                WebServiceId.Text = GuidHelper.New().ToString();
            }
            else
            {
                FillPage();
            }

        }
    }

    internal void FillPage()
    {
        var wsId = ValidationHelper.GetGuid(WebServiceId.Text);
        var webServiceFactory = new WebServiceFactory();
        var ws = webServiceFactory.GetWebService(wsId);
        if (ws != null)
        {
            txtCerFile.Text = ws.CerFile;
            txtUrl.Text = ws.Url;
            txtUserName.Text = ws.Uname;
            txtPwd.Text = ws.Pwd;
            txtName.Text = ws.Name;
            Store1.DataSource = ws.WebServiceMethods;
            Store1.DataBind();
        }
    }

    protected void btnRefreshList_Click(object sender, AjaxEventArgs e)
    {
        var wc = WsdlCreate(true);
        Store1.DataSource = wc.WebServiceMethodList;
        Store1.DataBind();
        txtName.Text = wc.ServisName;

    }
    internal WsdlCreater WsdlCreate(bool generateInMemory)
    {
        var url = txtUrl.Text;
        var wsId = ValidationHelper.GetGuid(WebServiceId.Text);
        var wc = new WsdlCreater
                     {
                         Uname = txtUserName.Text,
                         Pwd = txtPwd.Text,
                         CerFile = txtCerFile.Text,
                         GenerateInMemory = generateInMemory,
                         WebServiceId = wsId
                     };
        wc.WsdlCreate(url);
        return wc;
    }

    protected void BtnSave_Click(object sender, AjaxEventArgs e)
    {
        var wc = WsdlCreate(false);
        var Values = e.ExtraParams["Values"];


        var degerler = JSON.Deserialize<Dictionary<string, string>[]>(Values);
        var myService = new WebService
                          {
                              Name = txtName.Text,
                              Url = txtUrl.Text,
                              WebServiceId = ValidationHelper.GetGuid(WebServiceId.Text),
                              Uname = txtUserName.Text,
                              Pwd = txtPwd.Text,
                              CerFile = txtCerFile.Text,
                          };
        var webServiceFactory = new WebServiceFactory();
        myService.BinaryDll = webServiceFactory.ConvertAssemblyToString(wc.GeneratedAssembly);
        myService.WebServiceMethods = new List<WebServiceMethod>();
        for (int i = 0; i < wc.WebServiceMethodList.Count; i++)
        {
            var method = wc.WebServiceMethodList[i];

            foreach (var t in degerler)
            {
                if (ValidationHelper.GetString(t["Name"]) == method.Name)
                {
                    method.MethodId = ValidationHelper.GetGuid(t["MethodId"]);
                    for (int j = 0; j < method.MethodParameterList.Count; j++)
                    {
                        method.MethodParameterList[j].MethodId = method.MethodId;
                    }
                    myService.WebServiceMethods.Add(method);
                }
            }
        }


        webServiceFactory.AddUpdateWebService(myService);

    }

}