using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Reflection;
using System.Web.Services;
using TuFactory.Object;
using TuFactory.Utility;
using Coretech.Crm.Factory;
using System.IO;
using Coretech.Crm.Provider;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;

public partial class IntegrationManuel_CorpService : Page
{
    public class InputParameter
    {
        public string ParameterName { get; set; }
        public string ParameterDefaultValue { get; set; }
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
            if (CheckUserOnline())
            {
                SetMethods();
            }
        }
    }

    private void SetMethods()
    {
        Type serviceType = Type.GetType(ddlVersions.SelectedValue);

        List<string> list = new List<string>();
        MethodInfo[] methods = serviceType.GetMethods();
        for (int i = 0; i < methods.Length; i++)
        {
            object[] att = methods[i].GetCustomAttributes(typeof(WebMethodAttribute), false);
            if (att != null && att.Length > 0)
            {
                list.Add(methods[i].DeclaringType.FullName + "." + methods[i].Name);
            }
        }

        list.Sort();

        ddlMethods.DataSource = list;
        ddlMethods.DataBind();

        ddlMethods.Items.Insert(0, new ListItem("Seçiniz", ""));
    }

    protected void SetCurrentUser(object sender, EventArgs e)
    {
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        DynamicEntity de = df.RetrieveWithOutPlugin(1, App.Params.CurrentUser.SystemUserId, new string[] { "UserName" });
        tUserName.Text = de.GetStringValue("UserName");
    }

    protected void VersionChanged(object sender, EventArgs e)
    {
        tResult.Visible = false;
        tResult.Text = string.Empty;
        rpParams.DataSource = null;
        rpParams.DataBind();

        SetMethods();
    }

    protected void MethodChanged(object sender, EventArgs e)
    {
        tResult.Visible = false;
        tResult.Text = string.Empty;

        if (!string.IsNullOrEmpty(ddlMethods.SelectedValue))
        {
            Type serviceType = Type.GetType(ddlVersions.SelectedValue);

            MethodInfo mi = null;
            MethodInfo[] methods = serviceType.GetMethods();
            for (int i = 0; i < methods.Length; i++)
            {
                object[] att = methods[i].GetCustomAttributes(typeof(WebMethodAttribute), false);
                if (att != null && att.Length > 0)
                {
                    if (methods[i].DeclaringType.FullName + "." + methods[i].Name == ddlMethods.SelectedValue)
                    {
                        mi = methods[i];
                        break;
                    }
                }
            }

            ParameterInfo[] prms = mi.GetParameters();
            if (prms != null && prms.Length > 0)
            {
                List<InputParameter> inputParameters = new List<InputParameter>();
                if (typeof(WebServiceRequestBase).IsAssignableFrom(prms[0].ParameterType))
                {
                    PropertyInfo[] properties = prms[0].ParameterType.GetProperties();
                    if (properties != null && properties.Length > 0)
                    {
                        for(int i = 0; i < properties.Length; i++)
                        {
                            PropertyInfo pi = properties[i];
                            object[] att = pi.GetCustomAttributes(typeof(WebServiceTestInputValueAttribute), false);
                            if (att != null && att.Length > 0)
                            {
                                InputParameter ip = new InputParameter();
                                ip.ParameterName = pi.Name;
                                WebServiceTestInputValueAttribute testValAttr = att[0] as WebServiceTestInputValueAttribute;
                                ip.ParameterDefaultValue = testValAttr.Value;
                                inputParameters.Add(ip);
                            }
                        }

                        rpParams.DataSource = inputParameters;
                        rpParams.DataBind();
                    }
                }
                else
                {
                    InputParameter ip = new InputParameter();
                    ip.ParameterName = prms[0].Name;
                    ip.ParameterDefaultValue = string.Empty;
                    inputParameters.Add(ip);
                    rpParams.DataSource = inputParameters;
                    rpParams.DataBind();
                }
            }
            else
            {
                rpParams.DataSource = null;
                rpParams.DataBind();
            }

        }
    }

    protected void ParametersItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
        {
            InputParameter ip = e.Item.DataItem as InputParameter;
            Literal lParamName = e.Item.FindControl("lParamName") as Literal;
            TextBox tParamValue = e.Item.FindControl("tParamValue") as TextBox;
            lParamName.Text = ip.ParameterName;
            tParamValue.Text = ip.ParameterDefaultValue;
        }
    }

    protected void DoRequest(object sender, EventArgs e)
    {
        Type serviceType = Type.GetType(ddlVersions.SelectedValue);
        var service = Activator.CreateInstance(serviceType);
        serviceType.GetProperty("ByPassLogin", System.Reflection.BindingFlags.GetProperty | System.Reflection.BindingFlags.NonPublic | BindingFlags.Instance).SetValue(service, true, null);
        
        DynamicFactory df = new DynamicFactory(ERunInUser.CalingUser);
        DynamicEntity de = df.RetrieveWithOutPlugin(1, App.Params.CurrentUser.SystemUserId, new string[] { "UserName" });
        string tempUserName = de.GetStringValue("UserName");

        serviceType.GetProperty("UserInfo").SetValue(service, new Coretech.Crm.Provider.Security.WsSystemUserInfo() { Username = tUserName.Text }, null);

        MethodInfo mi = null;
        MethodInfo[] methods = serviceType.GetMethods();
        for (int i = 0; i < methods.Length; i++)
        {
            object[] att = methods[i].GetCustomAttributes(typeof(WebMethodAttribute), false);
            if (att != null && att.Length > 0)
            {
                if (methods[i].DeclaringType.FullName + "." + methods[i].Name == ddlMethods.SelectedValue)
                {
                    mi = methods[i];
                    break;
                }
            }
        }

        ParameterInfo[] prms = mi.GetParameters();
        if (prms != null && prms.Length > 0)
        {
            if (typeof(WebServiceRequestBase).IsAssignableFrom(prms[0].ParameterType))
            {
                object methodPrm = Activator.CreateInstance(prms[0].ParameterType);
                for (int i = 0; i < rpParams.Items.Count; i++)
                {
                    Literal lParamName = rpParams.Items[i].FindControl("lParamName") as Literal;
                    TextBox tParamValue = rpParams.Items[i].FindControl("tParamValue") as TextBox;
                    PropertyInfo pi = prms[0].ParameterType.GetProperty(lParamName.Text);

                    if (!string.IsNullOrEmpty(tParamValue.Text))
                    {
                        if (pi.PropertyType.IsGenericType && pi.PropertyType.GetGenericTypeDefinition() == typeof(Nullable<>))
                        {
                            pi.SetValue(methodPrm, Convert.ChangeType(tParamValue.Text, pi.PropertyType.GetGenericArguments()[0]), null);
                        }
                        else
                        {
                            pi.SetValue(methodPrm, Convert.ChangeType(tParamValue.Text, pi.PropertyType), null);
                        }
                    }
                }

                object[] methodPrms = new object[] { methodPrm };
                object result = mi.Invoke(service, methodPrms);
                tResult.Text = TuSerializer.Serialize(result);
                tResult.Visible = true;
            }
            else
            {
                List<string> methodPrmList = new List<string>();
                for (int i = 0; i < rpParams.Items.Count; i++)
                {
                    TextBox tParamValue = rpParams.Items[i].FindControl("tParamValue") as TextBox;
                    methodPrmList.Add(tParamValue.Text);
                }

                object[] methodPrms = methodPrmList.ToArray();
                object result = mi.Invoke(service, methodPrms);
                tResult.Text = TuSerializer.Serialize(result);
                tResult.Visible = true;
            }
        }
        else
        {
            object result = mi.Invoke(service, null);
            tResult.Text = TuSerializer.Serialize(result);
            tResult.Visible = true;
        }

        serviceType.GetProperty("UserInfo").SetValue(service, new Coretech.Crm.Provider.Security.WsSystemUserInfo() { Username = tempUserName }, null);
        serviceType.GetMethod("UserLoginWithoutPassword").Invoke(service, null);

        service = null;
    }
}