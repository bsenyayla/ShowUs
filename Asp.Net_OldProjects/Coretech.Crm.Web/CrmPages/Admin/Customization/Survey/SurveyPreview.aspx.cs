using System;
using Coolite.Ext.Web;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI;
using Coretech.Crm.Factory.Crm.Survey;
using System.Collections.Generic;
using Coretech.Crm.Objects.Crm.Survey;
using System.Web.UI.WebControls;
using Key = Coretech.Crm.Objects.Crm.Dynamic.DynamicObject.Key;
using Coretech.Crm.PluginData;
using System.Data;

public partial class CrmPages_Admin_Customization_Survey_SurveyPreview : AdminPage
{
    public CrmPages_Admin_Customization_Survey_SurveyPreview()
    {
        base.ObjectId = EntityEnum.Survey.GetHashCode();
    }
    
    public static List<Coretech.Crm.Objects.Crm.Survey.Survey> Publish;
    public void PublishDoldurma()
    {
        var sf = new SurveyFactory();

        var sl = new List<SurveyList>();
        var item = new SurveyList
        {
            SurveyId = new Guid(hdnSurveyId.Value.ToString())
        };
        sl.Add(item);
        Publish = sf.PublishSurvey(sl);
    }

    private void SurveyCreate()
    {
        if (Publish == null)
            return;

        for (var i = 0; i < Publish.Count; i++)
        {
            for (int j = 0; j < Publish[i].SurveyPartList.Count; j++)
            {
                var tpnl = new Table
                {
                    ID = "TR" +
                        GuidToInt(Publish[i].SurveyPartList[j].SurveyPartId)
                };
                if (!IsPostBack)
                    tpnl.Style.Add("display", j != 0 ? "none" : "block");
                var trpnl = new TableRow();
                var tdpnl = new TableCell();

                var pnl = new Coolite.Ext.Web.Panel
                {
                    BodyStyle = "padding:10px",
                    ID = "pnl" + GuidToInt(Publish[i].SurveyPartList[j].SurveyPartId),
                    Title = Publish[i].SurveyPartList[j].Description,
                    Collapsible = false,
                    Collapsed = false
                };

                for (var k = 0; k < Publish[i].SurveyPartList[j].SurveyPartQuestionList.Count; k++)
                {
                    var tb = new Table
                                    {
                                        ID = "TR" +
                                            GuidToInt(Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].SurveyPartQuestionId)
                                    };
                    if (!IsPostBack)
                        tb.Style.Add("display", k != 0 ? "none" : "block");
                    var tr = new TableRow();
                    var trq = new TableRow();
                    switch (Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].Type)
                    {
                        case QuestionType.Radio:
                            {
                                var td = new TableCell();
                                var question = new Coolite.Ext.Web.Label
                                {
                                    Text =
                                        Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].
                                        Description

                                };
                                question.Style.Add("color", "black");
                                question.Style.Add("font-family", "Tahoma");
                                question.Style.Add("font-weight", "bold");
                                question.Style.Add("font-size", "small");
                                var ekle = false;
                                var tdq = new TableCell();
                                td.Style.Add("width", "3000px");
                                //tdq.Style.Add("width", "350px");
                                var rdog = new RadioGroup
                                {
                                    ID = "G" +
                                         Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].
                                             SurveyPartQuestionId.ToString().Replace("-", "_"),
                                    AutoWidth = true,
                                    ColumnsNumber = 1

                                };

                                foreach (var t in
                                    Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].SurveyPartQuestionAnswerList)
                                {
                                    var rdo = new Radio
                                    {
                                        ID =
                                            "G" +
                                            t.
                                                SurveyPartQuestionAnswerId.ToString().Replace("-", "_"),
                                        BoxLabel =
                                            t.
                                            SurveyPartQuestionAnswerName,
                                        AutoWidth = true
                                    };
                                    rdo.Style.Add("color", "black");
                                    rdo.Style.Add("font-family", "Tahoma");
                                    rdo.Style.Add("font-weight", "bold");
                                    rdo.Style.Add("font-size", "small");


                                    var shows = "";
                                    var hides = "";
                                    for (var l = 0; l < Publish[i].SurveyScriptList.Count; l++)
                                    {
                                        if (Publish[i].SurveyScriptList[l].Level == 0)
                                        {
                                            if (Publish[i].SurveyScriptList[l].SpqAnswerId ==
                                                t.SurveyPartQuestionAnswerId)
                                            {
                                                if (Publish[i].SurveyScriptList[l].Show)
                                                {
                                                    shows += "document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SPartId) + "').style.display = 'block';";
                                                }
                                                if (Publish[i].SurveyScriptList[l].Hide)
                                                {
                                                    hides += "document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SPartId) + "').style.display = 'none';";
                                                }
                                            }
                                        }
                                        if (Publish[i].SurveyScriptList[l].Level == 1)
                                        {
                                            if (Publish[i].SurveyScriptList[l].SpqAnswerId ==
                                                t.SurveyPartQuestionAnswerId)
                                            {
                                                if (Publish[i].SurveyScriptList[l].Show)
                                                {
                                                    shows += "document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').style.display = 'block';";
                                                    shows += "for (var i = 0;i<document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').all.length;i++){if (document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').all[i].type == 'radio') {eval(document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').all[i].id).setValue(false);}}";
                                                }
                                                if (Publish[i].SurveyScriptList[l].Hide)
                                                {
                                                    hides += "document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').style.display = 'none';";
                                                    hides += "for (var i = 0;i<document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').all.length;i++){if (document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').all[i].type == 'radio') {eval(document.getElementById('TR" + GuidToInt(Publish[i].SurveyScriptList[l].SpQuestionId) + "').all[i].id).setValue(false);}}";
                                                }
                                            }
                                        }
                                    }


                                    rdo.Listeners.Focus.Handler = shows + hides;
                                    rdog.Items.Add(rdo);
                                    ekle = true;
                                }
                                if (ekle)
                                    tdq.Controls.Add(rdog);
                                td.Controls.Add(question);

                                tr.Controls.Add(td);

                                trq.Controls.Add(tdq);
                                break;
                            }
                        case QuestionType.TextBox:
                            {
                                var td = new TableCell();
                                var question = new Coolite.Ext.Web.Label
                                {
                                    Text =
                                        Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].
                                        Description
                                };
                                question.Style.Add("color", "black");
                                question.Style.Add("font-family", "Tahoma");
                                question.Style.Add("font-weight", "bold");
                                question.Style.Add("font-size", "small");

                                var tdq = new TableCell();
                                foreach (var t in
                                    Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].SurveyPartQuestionAnswerList)
                                {
                                    var rdo = new TextField
                                    {
                                        ID =
                                            "G" +
                                            Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].
                                              SurveyPartQuestionId.ToString().Replace("-", "_"),
                                        Width = 150
                                    };
                                    tdq.Controls.Add(rdo);
                                }

                                td.Controls.Add(question);

                                tr.Controls.Add(td);
                                trq.Controls.Add(tdq);
                                break;
                            }
                    }
                    tb.Controls.Add(tr);
                    tb.Controls.Add(trq);
                    pnl.BodyControls.Add(tb);
                }
                tdpnl.Controls.Add(pnl);
                trpnl.Controls.Add(tdpnl);
                tpnl.Controls.Add(trpnl);
                SurveyPanel.BodyControls.Add(tpnl);
            }
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvRead && DynamicSecurity.PrvAppend ))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Survey PrvAppend,PrvRead");
        }
        if (!Ext.IsAjaxRequest)
        {
            hdnSurveyId.Value = QueryHelper.GetString("SurveyId");
            hdnObjectid.Value = QueryHelper.GetString("ObjectId");
            hdnRecordid.Value = QueryHelper.GetString("RecordId");
            PublishDoldurma();
            SurveyCreate();
        }
    }

    private static string GuidToInt(Guid guid)
    {
        var sg = Convert.ToBase64String(guid.ToByteArray());
        return sg;
    }


    protected void ScriptSave(object sender, EventArgs e)
    {
        try
        {
            var create = false;
            if (string.IsNullOrEmpty(hdnSurveyRecordId.Value.ToString()))
            {
                hdnSurveyRecordId.Value = Guid.NewGuid().ToString();
                create = true;
            }
            var header = new DynamicEntity { Name = "surveyresultsheader",ObjectId=8 };
            header.Properties.Add(new LookupProperty { Name = "new_Survey", Value = new Lookup("survey", ValidationHelper.GetGuid(hdnSurveyId.Value.ToString())) });
            header.Properties.Add(new KeyProperty { Name = "surveyresultsheaderId", Value = new Key(new Guid(hdnSurveyRecordId.Value.ToString())) });

            
            var dynamicFactory = new DynamicFactory(ERunInUser.CalingUser);

            var gdret = new Guid(hdnSurveyRecordId.Value.ToString());
            if (create)
                gdret = dynamicFactory.Create("surveyresultsheader", header);
            else
            {
                var sd = new StaticData();
                sd.AddParameter("surveyresultsheaderId", DbType.Guid, gdret);
                sd.ExecuteScalar(@"exec SpSurveyDeleteResultDetail @surveyresultsheaderId");


            }
            #region List

            for (var i = 0; i < Publish.Count; i++)
            {
                for (var j = 0; j < Publish[i].SurveyPartList.Count; j++)
                {
                    for (var k = 0; k < Publish[i].SurveyPartList[j].SurveyPartQuestionList.Count; k++)
                    {
                        switch (Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].Type)
                        {
                            case QuestionType.Radio:
                                {
                                    var guid = Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].SurveyPartQuestionId;
                                    var cmp = ActiveScriptManager.FindControl("G" + guid.ToString().Replace("-", "_"));
                                    if (cmp != null)
                                    {
                                        if (((RadioGroup)cmp).CheckedItems.Count <= 0)
                                            continue;
                                        var value = ((RadioGroup)cmp).CheckedItems[0].ID;

                                        var detail = new DynamicEntity {Name = "surveyresultsdetail", ObjectId = 9};
                                        detail.Properties.Add(new LookupProperty
                                                                  {
                                                                      Name = "new_Answer",
                                                                      Value =
                                                                          new Lookup("surveypartquestionanswer",
                                                                                     ValidationHelper.GetGuid(
                                                                                         value.Substring(1, value.Length - 1).
                                                                                             Replace("_", "-")))
                                                                  });
                                        detail.Properties.Add(new LookupProperty
                                                                  {
                                                                      Name = "new_Header",
                                                                      Value =
                                                                          new Lookup("surveyresultsheader",
                                                                                     ValidationHelper.GetGuid(gdret))
                                                                  });
                                        detail.Properties.Add(new KeyProperty
                                                                  {
                                                                      Name = "surveyresultsdetailId",
                                                                      Value = new Key(Guid.NewGuid())
                                                                  });

                                        var dynamicFactoryd = new DynamicFactory(ERunInUser.CalingUser);

                                        var gdretd = dynamicFactoryd.Create("surveyresultsdetail", detail);
                                    }
                                    break;
                                }
                            case QuestionType.TextBox:
                                {
                                    var guid = Publish[i].SurveyPartList[j].SurveyPartQuestionList[k].SurveyPartQuestionId;
                                    var cmp = ActiveScriptManager.FindControl("G" + guid.ToString().Replace("-", "_"));
                                    if (cmp != null)
                                    {
                                        var value = ((TextField)cmp).Value.ToString();
                                        if (string.IsNullOrEmpty(value))
                                            continue;
                                        var detail = new DynamicEntity {Name = "surveyresultsdetail", ObjectId = 9};
                                        detail.Properties.Add(new LookupProperty
                                                                  {
                                                                      Name = "new_Header",
                                                                      Value =
                                                                          new Lookup("surveyresultsheader",
                                                                                     ValidationHelper.GetGuid(gdret))
                                                                  });
                                        detail.Properties.Add(new StringProperty { Name = "new_TextAnswer", Value = new CrmString(value) });
                                        detail.Properties.Add(new KeyProperty
                                                                  {
                                                                      Name = "surveyresultsdetailId",
                                                                      Value = new Key(Guid.NewGuid())
                                                                  });

                                        var dynamicFactoryd = new DynamicFactory(ERunInUser.CalingUser);

                                        var gdretd = dynamicFactoryd.Create("surveyresultsdetail", detail);
                                    }
                                    break;
                                }
                        }
                    }
                }
            }
            #endregion
            MessageShow("Anket Kaydedilmiştir.");

            if (ValidationHelper.GetInteger(hdnObjectid.Value, 0)>0)
            {
                header.Properties.Add(new DynamicLookupProperty("RecordId",
                                                                new DynamicLookup(
                                                                    ValidationHelper.GetInteger(hdnObjectid.Value, 0),
                                                                    "",
                                                                    ValidationHelper.GetGuid(hdnRecordid.Value))));
                dynamicFactory.Update("surveyresultsheader", header);
            }


        }
        catch (Exception ex)
        {
            ErrorMessageShow(ex);
        }
    }
}