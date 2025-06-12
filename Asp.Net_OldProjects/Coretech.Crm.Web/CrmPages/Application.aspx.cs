using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Serialization;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.WorkFlow;
using Coretech.Crm.Objects.Crm;
using Coretech.Crm.Objects.Crm.Parameters;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Parameter = Coretech.Crm.Objects.Crm.Parameters.Parameter;

public partial class CrmPages_Application : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        var param = new Parameter() { NumericValue = 1, ParameterName = WorkFlowFactory.WORKFLOW_TRACE, Type = ParameterType.Numeric };
        if (App.Params.CurrentParameters.ContainsKey(WorkFlowFactory.WORKFLOW_TRACE))
        {
            App.Params.CurrentParameters[WorkFlowFactory.WORKFLOW_TRACE] = param;
        }
        else
        {
            App.Params.CurrentParameters.Add(WorkFlowFactory.WORKFLOW_TRACE, param);
        }

        var sb = new StringBuilder("");

        foreach (var value in App.Params.CurrentWorkFlow.Values)
        {
            sb.Append(XmlSerializeWf(value));
        }
        foreach (var value in App.Params.CurrentView.Values)
        {
            sb.Append(XmlSerializeView(value));
        }
        foreach (var value in App.Params.CurrentEntity.Values)
        {
            sb.Append(XmlSerializeEntity(value));
        }
        foreach (var value in App.Params.CurrentEntityAttribute.Values)
        {
            sb.Append(XmlSerializeEntityAttribute(value));
        }
        var map = Server.MapPath("..");

        var t = new FileInfo(map + "\\application.txt");

        var Tex = t.CreateText();
        Tex.Write(sb.ToString());
        Tex.Close();

    }
    public string XmlSerializeWf(WorkFlow workFlow)
    {
        var mySerializer = new XmlSerializer(typeof(WorkFlow));
        TextWriter tw = new StringWriter();
        mySerializer.Serialize(tw, workFlow);
        return tw.ToString();
    }
    public string XmlSerializeView(Coretech.Crm.Objects.Crm.View.View workFlow)
    {
        var mySerializer = new XmlSerializer(typeof(Coretech.Crm.Objects.Crm.View.View));
        TextWriter tw = new StringWriter();
        mySerializer.Serialize(tw, workFlow);
        return tw.ToString();
    }
    public string XmlSerializeEntity(Entity et)
    {
        var mySerializer = new XmlSerializer(typeof(Entity));
        TextWriter tw = new StringWriter();
        mySerializer.Serialize(tw, et);
        return tw.ToString();
    }
    public string XmlSerializeEntityAttribute(EntityAttribute ea)
    {
        var mySerializer = new XmlSerializer(typeof(EntityAttribute));
        TextWriter tw = new StringWriter();
        mySerializer.Serialize(tw, ea);
        return tw.ToString();
    }
}