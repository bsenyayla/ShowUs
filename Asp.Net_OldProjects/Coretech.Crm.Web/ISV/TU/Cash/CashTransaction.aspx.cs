using System;
using System.Data;
using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.Objects.Crm.Dynamic.Security;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using Coretech.Crm.Web.UI.RefleX.AutoGenerate;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Object.User;
using TuFactory.Cash;
using TuFactory.TuUser;
using System.Collections.Generic;
using Newtonsoft.Json;
using Coretech.Crm.Factory.Crm.View;
using Coretech.Crm.Web.UI.RefleX.View;
using Coretech.Crm.Objects.Db;
using TuFactory.CashAccountTransactions;
using System.Data.Common;
using TuFactory.CashTransactions;

public partial class Cash_CashTransaction : BasePage
{
    #region Variables

    private DynamicSecurity _dynamicSecurity;

    #endregion

    private TuUserFactory uf = new TuUserFactory();
    TuUserApproval _ua = new TuUserApproval();

    private void KupurPencereOlustur(DataTable dt)
    {
        Page.ClientScript.RegisterClientScriptBlock(GetType(), "Kupur", "var Kupur = [];", true);
        for (var i = 0; i < dt.Rows.Count; i++)
        {
            var w = new Window
            {
                Dragable = false,
                Maximizable = false,
                Closable = false,
                Resizable = false,
                Minimizable = false,
                CloseAction = Window.ECloseAction.Hide,
                Width = 290,
                Height = 400,
                ID = "Kupur_" + dt.Rows[i]["new_CurrencyIdName"],
                ShowOnLoad = false,
                BodyStyle = "padding:0px 20px 0px 20px",
                Modal = true
            };

            var cl = new ColumnLayout { ID = "CK_" + dt.Rows[i]["new_CurrencyIdName"] };

            var rl = new RowLayout { ID = "RK_" + dt.Rows[i]["new_CurrencyIdName"] };

            var currencyDt = GetCurrenyKupur(ValidationHelper.GetGuid(dt.Rows[i]["new_CurrencyId"].ToString()));

            Page.ClientScript.RegisterClientScriptBlock(GetType(), "Kupur" + dt.Rows[i]["new_CurrencyIdName"] + "_" + i, string.Format("Kupur[{1}] = {{Currency:'{0}',Detail:[]}};",
                dt.Rows[i]["new_CurrencyIdName"],
                i
                ), true);

            var kDetail = "";
            for (var x = 0; x < currencyDt.Rows.Count; x++)
            {
                var nf1 = new NumericField { ID = "nf_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"] + "_" + currencyDt.Rows[x]["new_KupurValue"], Width = 60, EmptyText = "0" };
                if (currencyDt.Rows[x]["new_IsEnterDecimal"].ToString() == "True")
                {
                    nf1.Mode = NumericField.EMode.Decimal;
                    nf1.DecimalPrecision = 2;
                    nf1.Value = 0;
                }

                kDetail += (string.Format("Kupur[{3}].Detail[{0}] = {{Carpan:{1},Adet:{2},KupurId:'{4}'}};", x, currencyDt.Rows[x]["new_KupurValue"], nf1.ID + ".getValue()", i, currencyDt.Rows[x]["New_CurrencyKupurId"]));
                nf1.Listeners.Blur.Handler = string.Format("{6}.setValue({1});{5}();var carp = parseFloat({1})*parseFloat({0}); {2}.setValue(carp);Topla(Kupur[{3}].Detail,{4});",
                   currencyDt.Rows[x]["new_KupurValue"],
                   nf1.ID + ".getValue()",
                   "nf2_" + x + "_" + dt.Rows[i]["new_CurrencyIdName"],
                   i,
                   "nf_Toplam_" + dt.Rows[i]["new_CurrencyIdName"],
                   "KupurDetail" + dt.Rows[i]["new_CurrencyIdName"],
                   nf1.ID
                   );

                var tf1 = currencyDt.Rows[x]["new_IsEnterDecimal"].ToString() == "True" ? new TextField { ID = "tf_" + x + "_" + currencyDt.Rows[x]["new_KupurValue"] + "_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"], Width = 50, ReadOnly = true, Disabled = true, EmptyText = currencyDt.Rows[x]["CurrencyKupurName"].ToString() } :
                    new TextField { ID = "tf_" + x + "_" + currencyDt.Rows[x]["new_KupurValue"] + "_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"], Width = 50, ReadOnly = true, Disabled = true, EmptyText = currencyDt.Rows[x]["new_KupurValue"].ToString() + " " + currencyDt.Rows[x]["new_KupurCurrencyIdName"] };

                tf1.Align = EAlign.Right;
                var nf2 = new NumericField
                {
                    ID = "nf2_" + x + "_" + dt.Rows[i]["new_CurrencyIdName"],
                    Width = 100,
                    Disabled = true,
                    Mode = NumericField.EMode.Decimal,
                    DecimalPrecision = 2,
                    Align = EAlign.Right,
                    Value = 0
                };
                var m = new MultiField
                {
                    ID = "MField_" + currencyDt.Rows[x]["new_KupurValue"]
                };

                m.Items.Add(nf1);
                m.Items.Add(tf1);
                m.Items.Add(nf2);

                rl.BodyContainer.Controls.Add(m);
                cl.Rows.Add(rl);
            }

            Page.ClientScript.RegisterClientScriptBlock(GetType(), "KupurDetail" + dt.Rows[i]["new_CurrencyIdName"], "function KupurDetail" + dt.Rows[i]["new_CurrencyIdName"] + "(){" + kDetail + "}", true);

            var mt = new MultiField
            {
                ID = "MField_Toplam"
            };

            var nfToplam = new NumericField
            {
                ID = "nf_Toplam_" + dt.Rows[i]["new_CurrencyIdName"],
                Width = 100,
                EmptyText = "0",
                Mode = NumericField.EMode.Decimal,
                DecimalPrecision = 2,
                Align = EAlign.Right,
                Disabled = true
            };

            var label = new Label { ID = "LblToplam", Width = 60, Text = "Toplam: " };

            var tfToplam = new TextField { ID = "nf2_Toplam", Width = 50, Disabled = true };

            mt.Items.Add(label);
            mt.Items.Add(tfToplam);
            mt.Items.Add(nfToplam);

            rl.BodyContainer.Controls.Add(mt);
            cl.Rows.Add(rl);

            w.BodyControls.Add(cl);

            var btn = new Button { ID = "btn_Ekle" + dt.Rows[i]["new_CurrencyIdName"], Text = "Ekle" };
            btn.Listeners.Click.Handler = string.Format("KupurEkle({0});", "Kupur_" + dt.Rows[i]["new_CurrencyIdName"]);
            w.Buttons.Add(btn);

            form1.Controls.Add(w);
        }
    }

    protected override void OnPreInit(EventArgs e)
    {
        New_CashTransactionHeaderId.Value = QueryHelper.GetString("recid");

        _ua = uf.GetApproval(App.Params.CurrentUser.SystemUserId);
        /*Döviz Türlerini Getirir*/
        DataTable dt;


        dt = !New_CashTransactionHeaderId.IsEmpty ? GetRecordCurrency() : GetCurreny();
        int cashTransctionType = 0;
        if (!New_CashTransactionHeaderId.IsEmpty)
        {
            cashTransctionType = new CashFactory().GetCashTransactionHeaderType(ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value));
        }

        /*Amount-Currency 'CrmMoneyComp' Objelerini Dinamik Olarak Yaratıyoruz..*/
        if (dt.Rows.Count > 0)
        {
            for (var i = 0; i < dt.Rows.Count; i++)
            {
                var rl = new RowLayout { ID = "RowLayout" + dt.Rows[i]["new_CurrencyIdName"] };
                var m = new CrmMoneyComp
                {
                    ID = "Currency_" + dt.Rows[i]["new_CurrencyIdName"],
                    UniqueName = "new_Amount",
                    ObjectId = "201300002",
                    c1 = { Value = dt.Rows[i]["new_CurrencyId"].ToString(), Disabled = true },
                };
                if (
                    (New_CashTransactionHeaderId.IsEmpty && cashTransctionType != CashTypeEnum.SecurverdidenTeslim.GetHashCode())
                   ||
                    (!New_CashTransactionHeaderId.IsEmpty && (cashTransctionType == CashTypeEnum.SecurverdidenTeslim.GetHashCode() || cashTransctionType == CashTypeEnum.OfistenOfise.GetHashCode()))
                   )
                {
                    var btn = new Button { ID = "btn_" + dt.Rows[i]["new_CurrencyIdName"], Text = "..." };
                    btn.Listeners.Click.Handler = string.Format("KupurAc('{0}',{1});", dt.Rows[i]["new_CurrencyIdName"], "Kupur_" + dt.Rows[i]["new_CurrencyIdName"]);
                    m.Items.Add(btn);
                }

                rl.BodyContainer.Controls.Add(m);
                ColumnLayout12.Rows.Add(rl);

            }

            KupurPencereOlustur(dt);

            if (!_ua.MainCashAdmin)
            {
                Fieldset2.Height = 20;
            }

            if (_ua.MainCashAdmin)
            {
                dt = GetCurreny();

                var rl2 = new RowLayout { ID = "RowLayout20" };
                var f = new Fieldset { ID = "Fieldset1", Title = "Ana Kasa Bakiye", Collapsible = false };
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var n = new CrmMoneyComp
                    {
                        ID = "Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "2",
                        UniqueName = "new_Balance",
                        ObjectId = "201300002",
                        c1 = { Value = dt.Rows[i]["new_CurrencyId"].ToString(), Disabled = true },
                        d1 = { CustomMinValue = int.MinValue, ReadOnly = true }
                    };
                    f.BodyContainer.Controls.Add(n);
                }
                rl2.BodyContainer.Controls.Add(f);
                ColumnLayout1.Rows.Add(rl2);

                var rl3 = new RowLayout { ID = "RowLayout30" };
                Fieldset f2;
                if (cashTransctionType == CashTypeEnum.OfistenOfise.GetHashCode())
                {
                    f2 = new Fieldset { ID = "Fieldset3", Title = "Anakasa Bakiye", Collapsible = false };
                }
                else
                {
                    f2 = new Fieldset { ID = "Fieldset3", Title = "Gişeci Bakiye", Collapsible = false };
                }

                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var n2 = new CrmMoneyComp
                    {
                        ID = "Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "3",
                        UniqueName = "new_Balance",
                        ObjectId = "201300002",
                        c1 = { Value = dt.Rows[i]["new_CurrencyId"].ToString(), Disabled = true },
                        d1 = { CustomMinValue = int.MinValue, ReadOnly = true }
                    };
                    f2.BodyContainer.Controls.Add(n2);
                }
                rl3.BodyContainer.Controls.Add(f2);
                ColumnLayout2.Rows.Add(rl3);
            }
        }
        else
        {
            Fieldset2.Height = 20;
        }

        base.OnPreInit(e);

    }

    private DataTable GetRecordCurrency()
    {
        var sd = new StaticData();
        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("New_CashTransactionHeaderId", DbType.Guid, ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value));
        sd.AddParameter("IsMain", DbType.Int32, _ua.MainCashAdmin ? 1 : 0);

        return sd.ReturnDataset(@"Select 
	h.new_ToCash,
    h.new_FromCash,
	h.HeaderRefno,
    case when h.new_Status = 2 then 1 else 0 end IsConfirm,
    c.new_AmountCurrency new_CurrencyId,
    c.new_AmountCurrencyName new_CurrencyIdName,
	c.*
	from tvNew_CashTransaction(@SystemUserId) c 
	inner join vNew_CashTransactionHeader h on c.new_CashTransactionHeaderId = h.new_CashTransactionHeaderId 
	inner join vNew_Cash s on c.new_CashNameID = s.New_CashId
	inner join vNew_Office o ON o.new_OfficeId=s.new_OfficeName
	inner join vSystemUser u ON u.new_OfficeID=o.new_OfficeId
	where 1=1
and c.new_CashTransactionHeaderId = @New_CashTransactionHeaderId 
and 1 = case 
			when @IsMain = 0 and s.new_SystemUserId = @SystemUserId then 1 
			when @IsMain = 1 and s.new_MainCash = 1 then 1 
			else 0
		end          
AND u.SystemUserId=@SystemUserId").Tables[0];

        //        return sd.ReturnDataset(@"
        //Select 
        //	h.new_ToCash,
        //    h.new_FromCash,
        //	h.HeaderRefno,
        //    case when h.new_Status = 2 then 1 else 0 end IsConfirm,
        //    c.new_AmountCurrency new_CurrencyId,
        //    c.new_AmountCurrencyName new_CurrencyIdName,
        //	c.*
        //	from tvNew_CashTransaction(@SystemUserId) c 
        //	inner join vNew_CashTransactionHeader h on c.new_CashTransactionHeaderId = h.new_CashTransactionHeaderId 
        //	inner join vNew_Cash s on c.new_CashNameID = s.New_CashId
        //	where 1=1
        //and c.new_CashTransactionHeaderId = @New_CashTransactionHeaderId 
        //and 1 = case 
        //			when @IsMain = 0 and s.new_SystemUserId = @SystemUserId then 1 
        //			when @IsMain = 1 and s.new_MainCash = 1 then 1 
        //			else 0
        //		end          
        //            ").Tables[0];
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        _dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_CashTransaction.GetHashCode(), null);
        if (!(_dynamicSecurity.PrvCreate || _dynamicSecurity.PrvRead || _dynamicSecurity.PrvWrite))
            Response.End();

        if (!RefleX.IsAjxPostback)
        {
            Translate();
            new_CashNameID.Disabled = true;
            hdnRecId.Value = New_CashTransactionHeaderId.Value;
            hdnReportId.Value = App.Params.GetConfigKeyValue("CASH_REPORTID");
            LoadData();

            if (New_CashTransactionHeaderId.IsEmpty)
            {
                if (_ua.MainCashAdmin)
                {
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "4"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "5"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "6"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "7"));
                    //new_TransactionType.Items.RemoveAt(3);
                    //new_TransactionType.Items.RemoveAt(3);
                    //new_TransactionType.Items.RemoveAt(3);
                    //new_TransactionType.Items.RemoveAt(3);
                }
                else
                {
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "1"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "2"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "3"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "5"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "6"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "7"));
                    new_TransactionType.Items.Remove(new_TransactionType.Items.Find(x => x.Value == "8"));
                    //new_TransactionType.Items.RemoveAt(0);
                    //new_TransactionType.Items.RemoveAt(0);
                    //new_TransactionType.Items.RemoveAt(0);
                    //new_TransactionType.Items.RemoveAt(1);
                    //new_TransactionType.Items.RemoveAt(1);
                    //new_TransactionType.Items.RemoveAt(1);
                }
            }
        }
    }

    protected void new_TransactionTypeChange(object sender, AjaxEventArgs e)
    {
        var mode = e.ExtraParams["Mode"];

        try
        {
            switch (((CashTypeEnum)(Convert.ToInt32(new_TransactionType.Value))))
            {
                case CashTypeEnum.SecurverdiyeTeslim:
                    {
                        new_CashNameID.SetFieldLabel("Devir Eden Kasa");
                        break;
                    }
                case CashTypeEnum.SecurverdidenTeslim:
                    {
                        new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                        break;
                    }
                case CashTypeEnum.GiseciyeTeslim:
                    {
                        new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                        break;
                    }
                case CashTypeEnum.GisecidenTeslim:
                    {
                        new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                        break;
                    }
                case CashTypeEnum.OfistenOfise:
                    {
                        new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                        break;
                    }
            }
            var cash = FindCash(true);
            if (new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
            {

                var dt = GetBalance(ValidationHelper.GetGuid(cash), ValidationHelper.GetGuid(new_CashNameID.Value));
                SetBalanceFields(dt);
                new_CashNameID.SetValue(cash);
                new_CashNameID.SetDisabled(true);
                ColumnLayout2.Hide();
            }

            if (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
            {
                var dt = GetBalance(ValidationHelper.GetGuid(cash), ValidationHelper.GetGuid(new_CashNameID.Value));
                SetBalanceFields(dt);
                if (mode == "1")
                    new_CashNameID.Clear();
                new_CashNameID.SetDisabled(false);
                new_CashNameID.RequirementLevel = RLevel.BusinessRequired;
                ColumnLayout2.Show();
            }

            if (new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString())
            {
                new_CashNameID.SetValue(cash);
                new_CashNameID.SetDisabled(true);
                ColumnLayout2.Show();
            }
            if (new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
            {
                var sd = new StaticData();

                var str =
                    string.Format(@"spGetCashAllKupur @UserId,@CashId");


                sd.AddParameter("UserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
                sd.AddParameter("CashId", DbType.Guid, ValidationHelper.GetGuid(cash));

                DataTable dtCashKupur = sd.ReturnDataset(str).Tables[0];

                Decimal kupurMaxValue = 0;

                DataTable dtCur;
                dtCur = !New_CashTransactionHeaderId.IsEmpty ? GetRecordCurrency() : GetCurreny();
                bool control = false;
                for (var i = 0; i < dtCur.Rows.Count; i++)
                {
                    var currencyDt = GetCurrenyKupur(ValidationHelper.GetGuid(dtCur.Rows[i]["new_CurrencyId"].ToString()));
                    for (var x = 0; x < currencyDt.Rows.Count; x++)
                    {

                        foreach (DataRow item in dtCashKupur.Rows)
                        {
                            if (item["CurrencyName"].ToString() == dtCur.Rows[i]["new_CurrencyIdName"].ToString())
                            {
                                if (Convert.ToDecimal(item["KupurValue"]) == Convert.ToDecimal(currencyDt.Rows[x]["new_KupurValue"]))
                                {
                                    kupurMaxValue = ValidationHelper.GetDecimal(item["Adet"], 999999);
                                    QScript(string.Format("{0}.maxValue = {1};", "nf_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"] + "_" + currencyDt.Rows[x]["new_KupurValue"], 0));
                                    QScript(string.Format("{0}.maxValue = {1};", "nf_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"] + "_" + currencyDt.Rows[x]["new_KupurValue"], kupurMaxValue.ToString().Replace(",", ".")));
                                    control = true;
                                }
                            }
                        }
                        if (!control)
                        {
                            QScript(string.Format("{0}.maxValue = {1};", "nf_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"] + "_" + currencyDt.Rows[x]["new_KupurValue"], 0));
                        }
                        control = false;
                    }

                }
            }
            else
            {
                DataTable dtCur;
                dtCur = !New_CashTransactionHeaderId.IsEmpty ? GetRecordCurrency() : GetCurreny();

                for (var i = 0; i < dtCur.Rows.Count; i++)
                {
                    var currencyDt = GetCurrenyKupur(ValidationHelper.GetGuid(dtCur.Rows[i]["new_CurrencyId"].ToString()));
                    for (var x = 0; x < currencyDt.Rows.Count; x++)
                    {
                        QScript(string.Format("{0}.maxValue = {1};", "nf_" + currencyDt.Rows[x]["new_KupurCurrencyIdName"] + "_" + currencyDt.Rows[x]["new_KupurValue"], 999999));
                    }
                }
            }


        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    private void LoadData()
    {
        if (!New_CashTransactionHeaderId.IsEmpty)
        {
            var dt = GetRecordCurrency();

            if (dt.Rows.Count > 0)
            {
                new_TransactionType.Disabled = true;
                new_CashNameID.Disabled = true;
                new_Description.Disabled = true;

                CashTransactionRefNo.Value = dt.Rows[0]["HeaderRefno"].ToString();
                new_TransactionType.Value = dt.Rows[0]["new_TransactionType"].ToString();
                new_CashNameID.Value = dt.Rows[0]["new_ToCash"].ToString();
                new_CashNameID.SetValue(dt.Rows[0]["new_ToCash"].ToString());
                new_Description.Value = dt.Rows[0]["new_Description"].ToString();

                switch (((CashTypeEnum)(Convert.ToInt32(new_TransactionType.Value))))
                {
                    case CashTypeEnum.SecurverdiyeTeslim:
                        {
                            new_CashNameID.SetFieldLabel("Devir Eden Kasa");
                            break;
                        }
                    case CashTypeEnum.SecurverdidenTeslim:
                        {
                            new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                            break;
                        }
                    case CashTypeEnum.GiseciyeTeslim:
                        {
                            new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                            break;
                        }
                    case CashTypeEnum.GisecidenTeslim:
                        {
                            new_CashNameID.SetFieldLabel("Devir Alan Kasa");
                            break;
                        }
                }

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    var cmc = (CrmDecimalComp)RR.FindControl("Currency_" + dt.Rows[i]["new_AmountCurrencyName"]);
                    cmc.SetValue(ValidationHelper.GetDecimal(dt.Rows[i]["new_Amount"], 0));
                    cmc.Disabled = true;
                }
                if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                    new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString()
                    )
                {
                    ColumnLayout2.Hide();
                }

                if (_ua.MainCashAdmin)
                {
                    var cash = FindCash(true);
                    var toCash = (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString()
                        || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString()
                        ) ?
                                            ValidationHelper.GetGuid(dt.Rows[0]["new_ToCash"].ToString()) :
                                            ValidationHelper.GetGuid(dt.Rows[0]["new_FromCash"].ToString());


                    var fromCash = ValidationHelper.GetGuid(dt.Rows[0]["new_FromCash"].ToString());

                    DataTable dt2;
                    if (new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                    {
                        dt2 = GetBalance(fromCash, toCash);
                    }
                    else
                    {
                        dt2 = GetBalance(ValidationHelper.GetGuid(cash), toCash);
                    }

                    SetBalanceFields(dt2);
                    btnSave.Hide();
                    if (ValidationHelper.GetInteger(dt.Rows[0]["new_Status"], 0) == 2 || ValidationHelper.GetInteger(dt.Rows[0]["new_Status"], 0) == 3)
                    {
                        btnRed.Hide();
                        btnConfirm.Hide();
                    }


                    if (!CheckCashConfirmUser(ValidationHelper.GetGuid(dt.Rows[0]["new_ToCash"].ToString()), App.Params.CurrentUser.SystemUserId))
                    {
                        btnRed.Hide();
                        btnConfirm.Hide();
                    }
                }
                else
                {
                    if (!ValidationHelper.GetBoolean(dt.Rows[0]["IsConfirm"]) && ValidationHelper.GetInteger(dt.Rows[0]["new_Status"], 0) == 2)
                    {
                        btnRed.Hide();
                        btnConfirm.Hide();
                    }
                    btnSave.Hide();
                }

                if (ValidationHelper.GetInteger(dt.Rows[0]["new_Status"], 0) == 2 && ValidationHelper.GetBoolean(dt.Rows[0]["IsConfirm"]))
                {
                    btnRed.Hide();
                    btnConfirm.Hide();
                    btnDekont.Show();
                }
                if (ValidationHelper.GetInteger(dt.Rows[0]["new_Status"], 0) == 3 && !ValidationHelper.GetBoolean(dt.Rows[0]["IsConfirm"]))
                {
                    btnRed.Hide();
                    btnConfirm.Hide();
                    btnDekont.Hide();
                }
            }
            else
            {
                btnRed.Hide();
                btnConfirm.Hide();
                btnDekont.Hide();
                btnSave.Hide();
            }
        }
        else
        {
            btnRed.Hide();
            btnConfirm.Hide();
        }
    }

    protected void Translate()
    {
        PanelX3.Title = Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_DEVIR_ISLEMLERI");
    }

    private string FindCash(bool isMainCash)
    {
        var sd = new StaticData();

        string str;
        if (isMainCash)
            str = string.Format(@"select distinct top 1 New_CashId from dbo.vNew_Cash C JOIN vSystemUser SU ON C.new_OfficeName = SU.new_OfficeID 
                            AND C.new_MainCash = 1 WHERE SU.SystemUserId = @SystemUserId and C.DeletionStateCode=0");
        else
            str = string.Format(@"select distinct top 1 New_CashId from dbo.vNew_Cash C JOIN vSystemUser SU ON C.new_OfficeName = SU.new_OfficeID 
                            AND C.new_MainCash = 0 WHERE C.new_SystemUserId = @SystemUserId and C.DeletionStateCode=0");


        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        return ValidationHelper.GetString(sd.ExecuteScalar(str));
    }

    private DataTable GetBalance(Guid fromCashId, Guid toCashId)
    {
        var sd = new StaticData();

        var str =
            string.Format(
                    @"
            Declare @officeID uniqueidentifier 
            SELECT @officeID = u.new_OfficeID FROM vSystemUser u
            INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
            LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID 
            Where SystemUserId = @SystemUserId

            select 
	            o.new_CurrencyIdName,
	            (
		            /*Select 
			            top 1
			            new_Balance
			            From vNew_CashTransaction 
			            where 1=1
		            and new_CashNameID = @FromCashId and new_BalanceCurrency = o.new_CurrencyId
		            and DeletionStateCode = 0 and new_Balance is not NULL
                    and new_Status = 2
		            order by CreatedOn desc*/
                    dbo.fnGetCashCurrencyBalance(@SystemUserId, @FromCashId, o.new_CurrencyId)
	            ) FromBalance,
	            (
		            /*Select 
			            top 1
			            new_Balance
			            From vNew_CashTransaction 
			            where 1=1
		            and new_CashNameID = @ToCashId and new_BalanceCurrency = o.new_CurrencyId
		            and DeletionStateCode = 0 and new_Balance is not NULL
                    and new_Status = 2
		            order by CreatedOn desc*/
                    dbo.fnGetCashCurrencyBalance(@SystemUserId, @ToCashId, o.new_CurrencyId)
	            ) ToBalance
	            from vNew_OfficeTransactionType o 
	            where 1=1 AND o.DeletionStateCode=0
	            and new_OfficeID = @officeID
	            and (
		            new_TransactionItemID in (select New_TransactionItemId from vNew_TransactionItem where new_ExtCode  IN ('001','002') AND DeletionStateCode=0) OR
		            new_TransactionTypeID in (select New_TransactionTypeId from vNew_TransactionType where new_ExtCode = '008' AND DeletionStateCode=0)
	            )
	            group by new_CurrencyId,new_CurrencyIdName 
        ");


        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("FromCashId", DbType.Guid, fromCashId);
        sd.AddParameter("ToCashId", DbType.Guid, toCashId);

        return sd.ReturnDataset(str).Tables[0];
    }

    private DataTable GetCurreny()
    {
        var sd = new StaticData();

        var str =
            string.Format(
                    @"Declare @officeID uniqueidentifier 
                    SELECT @officeID = u.new_OfficeID FROM vSystemUser u
                    INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
                    LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID Where SystemUserId = @SystemUserId

                    select new_CurrencyId,new_CurrencyIdName from vNew_OfficeTransactionType where 1=1 AND DeletionStateCode=0
                    and new_OfficeID = @officeID
                    and (
                    new_TransactionItemID in (select New_TransactionItemId from vNew_TransactionItem where new_ExtCode IN ('001','002')) OR
                    new_TransactionTypeID in (select New_TransactionTypeId from vNew_TransactionType where new_ExtCode = '008')
                        )
                    group by new_CurrencyId,new_CurrencyIdName");


        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);

        return sd.ReturnDataset(str).Tables[0];
    }

    private DataTable GetCurrenyKupur(Guid currencyId)
    {
        var sd = new StaticData();

        var str =
            string.Format(
                    @"select New_CurrencyKupurId,CurrencyKupurName,new_KupurValue,new_KupurCurrencyIdName,new_IsEnterDecimal 
from vNew_CurrencyKupur k where DeletionStateCode = 0 and new_KupurCurrencyId=@new_KupurCurrencyId order by new_KupurValue");


        sd.AddParameter("new_KupurCurrencyId", DbType.Guid, currencyId);

        return sd.ReturnDataset(str).Tables[0];
    }

    private void SetBalanceFields(DataTable dt)
    {
        if (dt.Rows.Count > 1)
        {
            for (var i = 0; i < dt.Rows.Count; i++)
            {
                var cmc = (CrmDecimalComp)RR.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "2");
                cmc.SetValue(ValidationHelper.GetDecimal(dt.Rows[i]["FromBalance"], 0));

                var cmc2 = (CrmDecimalComp)RR.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "3");
                cmc2.SetValue(ValidationHelper.GetDecimal(dt.Rows[i]["ToBalance"], 0));
            }
        }
    }

    private Guid GetCashUser(Guid cashId)
    {
        var sd = new StaticData();

        var str =
            string.Format(
                    @"            
            Declare @officeID uniqueidentifier 
            SELECT @officeID = u.new_OfficeID FROM vSystemUser u
            INNER JOIN vNew_Corporation c on u.new_CorporationID = c.New_CorporationId
            LEFT OUTER JOIN vnew_country co ON co.New_CountryId=c.new_CountryID 
            Where SystemUserId = @SystemUserId
			select top 1 new_SystemUserId from vNew_Cash where new_OfficeName = @officeID and DeletionStateCode = 0 and New_CashId = @CashID
");

        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("CashID", DbType.Guid, cashId);

        return ValidationHelper.GetGuid(sd.ExecuteScalar(str));
    }

    private bool CheckCashConfirmUser(Guid cashId, Guid SystemUserId)
    {
        var sd = new StaticData();

        sd.AddParameter("SystemUserId", DbType.Guid, SystemUserId);
        sd.AddParameter("CashId", DbType.Guid, cashId);

        return ValidationHelper.GetBoolean(sd.ExecuteScalarSp("spTuCheckCashConfirmUser"));
    }

    private Decimal GetCashCurrencyBalance(Guid toCashId, Guid currency, Guid recId)
    {
        var sd = new StaticData();

        var str =
            string.Format(
                    @"
            /*
            Select 
	            top 1
	            new_Balance
	            From vNew_CashTransaction (nolock)
	            where 1=1
            and new_CashNameID = @ToCashId
            and new_BalanceCurrency = @Currency
            and new_Status = 2
            and DeletionStateCode = 0 and new_Balance is not NULL
            and (@RecId != New_CashTransactionId)
            order by CreatedOn desc */

            select Result FROM
	        (
		        select
                    TOP 1
			        new_Balance AS Result,
			        case 
				        when cth.new_ConfirmDate IS NULL THEN ct.CreatedOn
				        else cth.new_ConfirmDate
			        end AS Date
			        from vNew_CashTransaction (nolock) ct
			        left outer join vNew_CashTransactionHeader (nolock) cth
			        on ct.new_CashTransactionHeaderId = cth.new_CashTransactionHeaderId
			        where 1=1 
		        and ct.DeletionStateCode = 0 
		        and ct.new_BalanceCurrency = @Currency
		        and ct.new_CashNameID = @ToCashId
                and ct.new_Status = 2
                and ct.new_Balance is not NULL
                and (@RecId != ct.New_CashTransactionId)
		        order by 2 desc
	        ) AS T
        ");

        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("Currency", DbType.Guid, currency);
        sd.AddParameter("ToCashId", DbType.Guid, toCashId);
        sd.AddParameter("RecId", DbType.Guid, recId);

        return ValidationHelper.GetDecimal(sd.ExecuteScalar(str), 0);
    }

    protected void btnRedOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            var sd = new StaticData();
            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sd.AddParameter("RecId", DbType.Guid, ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value));
            sd.ExecuteNonQuery(@"
    update vNew_CashTransaction set new_Status = 3 where new_CashTransactionHeaderId = @RecId
    update vNew_CashTransactionHeader set new_Status = 3, new_ConfirmDate = GETUTCDATE(),new_ConfirmUserId=@SystemUserId where New_CashTransactionHeaderId = @RecId              
            ");



            if (new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
            {
                DbTransaction tr = new StaticData().GetDbTransaction();
                try
                {
                    var dtr = GetRecordCurrency();
                    if (dtr.Rows.Count > 0)
                    {
                        Guid fromCash = ValidationHelper.GetGuid(dtr.Rows[0]["new_FromCash"].ToString());
                        Guid cashTransactionHeaderId = ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value);

                        CashTransactionManager cashManager = new CashTransactionManager();
                        List<CashTransactions> transactionList = cashManager.GetCashTransaction(cashTransactionHeaderId, fromCash, tr);

                        foreach (var item in transactionList)
                        {
                            cashManager.SaveAccountTransactions(item, true, CashAccountTransactionTypes.CashReceive, tr);
                        }
                    }
                    StaticData.Commit(tr);
                }
                catch (Exception ex)
                {
                    StaticData.Rollback(tr);
                    throw ex;
                }












            }



            var msg = new MessageBox { Width = 500 };
            msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_CANCEL_COMPLETE"));

            hdnRecId.SetIValue(New_CashTransactionHeaderId.Value);
            btnRed.Hide();
            btnConfirm.Hide();
        }
        catch (Exception ex)
        {
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    protected void btnConfirmOnEvent(object sender, AjaxEventArgs e)
    {
        var kupurler = e.ExtraParams["Kupurler"];
        var kupurList = JsonConvert.DeserializeObject<List<Kupurler>>(kupurler);


        var sd = new StaticData();
        DbTransaction tr = sd.GetDbTransaction();


        var df = new DynamicFactory(ERunInUser.CalingUser);
        df.GetBeginTrans(tr);

        try
        {
            var toCash = Guid.Empty;
            var dtr = GetRecordCurrency();
            if (dtr.Rows.Count > 0)
            {
                toCash = (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString()) ?
                                             ValidationHelper.GetGuid(dtr.Rows[0]["new_ToCash"].ToString()) :
                                             ValidationHelper.GetGuid(dtr.Rows[0]["new_FromCash"].ToString());
            }


            Guid fromCash = ValidationHelper.GetGuid(dtr.Rows[0]["new_FromCash"].ToString());

            var dt = GetCurreny();
            var maincash = FindCash(true);
            if (maincash == "")
            {
                var msgg = new MessageBox { Width = 500 };
                msgg.Show("Anakasa kullanıcısı değilsiniz, bu işleme yetkiniz yok.!");
                return;
            }

            if (dt.Rows.Count > 0)
            {
                string uyumsuzKupur = string.Empty;
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var cmc =
                        (CrmMoneyComp)
                        ColumnLayout12.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "field_Container");
                    if (cmc == null)
                        continue;

                    var c = cmc.d1.Value;
                    var d = cmc.c1.Value;

                    if (cmc.d1.IsEmpty)
                        continue;

                    var fc = new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString()
                                 ? ValidationHelper.GetGuid(toCash)
                                 : ValidationHelper.GetGuid(maincash);

                    if (new_TransactionType.Value != CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() && new_TransactionType.Value != CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                    {
                        if (EksiKontrol(fc, ValidationHelper.GetGuid(d), c))
                        {
                            throw new TuException(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_BALANCE_IS_NEGATIVE"), "0");
                        }
                    }


                    /*Aktifbanktan ofise gelen paralarda para geldiğinde yani onay aşamasında küpürler girilecek.*/
                    if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                    {
                        var kupur = new List<KupurDetail>();
                        foreach (var k in kupurList)
                        {
                            if (k.Currency == dt.Rows[i]["new_CurrencyIdName"].ToString())
                                kupur = k.Detail;
                        }

                        Guid cashTransactionId = new CashFactory().GetCashTransactionId(ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value), ValidationHelper.GetGuid(dt.Rows[i]["new_CurrencyId"]));

                        var deDetail = new DynamicEntity(TuEntityEnum.New_CashTransactionDetail.GetHashCode());
                        if (cashTransactionId != null && cashTransactionId != Guid.Empty)
                        {
                            decimal toplam = 0;
                            foreach (var item in kupur)
                            {
                                if (item.Adet == 0) continue;
                                var detailrecId = GuidHelper.Newfoid(TuEntityEnum.New_CashTransaction.GetHashCode());
                                deDetail.AddKeyProperty("New_CashTransactionDetailId", detailrecId);
                                deDetail.AddLookupProperty("new_CashTransactionId", "", ValidationHelper.GetGuid(cashTransactionId));
                                deDetail.AddDecimalProperty("new_Count", item.Adet);
                                deDetail.AddLookupProperty("new_CurrencyKupurId", "", ValidationHelper.GetGuid(item.KupurId));
                                df.Create("New_CashTransactionDetail", deDetail);
                                toplam += item.Adet * item.Carpan;
                            }
                            if (toplam != (decimal)c)
                            {
                                uyumsuzKupur += dt.Rows[i]["new_CurrencyIdName"].ToString() + ", ";
                            }
                        }

                        if (uyumsuzKupur != string.Empty)
                        {
                            throw new Exception(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_KUPUR_UYUMSUZ") + " (" + uyumsuzKupur.Substring(0, uyumsuzKupur.Length - 2) + ")");
                        }
                    }
                }
            }

            #region Kasa Hesabı işlemleri

            try
            {
                if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
                {
                    /*Aktifbanktan ofise para talebinde, Kasa hesabı işlemlerinde açılan Kasaya para talebi işlemlerinin sorunlu işlemlerden onaylanmasnı kontrol ediyoruz.*/

                    CashAccountTransactionManager manager = new CashAccountTransactionManager();

                    manager.CheckCashRequestIsConfirmed(ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value), tr);

                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        var cmc = (CrmMoneyComp)ColumnLayout12.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "field_Container");
                        if (cmc != null)
                        {
                            var amount = ValidationHelper.GetDecimal(cmc.d1.Value, 0);
                            var currency = cmc.c1.Value;

                            if (amount != 0)
                            {
                                CashAccountTransaction cat = GetCashAccountTransaction(amount, ValidationHelper.GetGuid(currency), ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value), true);
                                manager.CompleteCashAccountTransaction2(cat, tr);
                            }
                        }
                    }
                }
                else if (new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                {
                    Guid cashTransactionHeaderId = ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value);
                    Guid FromCashId = ValidationHelper.GetGuid(maincash);

                    CashTransactionManager cashManager = new CashTransactionManager();
                    List<CashTransactions> transactionList = cashManager.GetCashTransaction(cashTransactionHeaderId, toCash, tr);

                    foreach (var item in transactionList)
                    {
                        cashManager.SaveAccountTransactions(item, false, CashAccountTransactionTypes.CashSubmit, tr);
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            #endregion


            sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
            sd.AddParameter("RecId", DbType.Guid, ValidationHelper.GetGuid(New_CashTransactionHeaderId.Value));
            sd.ExecuteNonQuery(@"
	DECLARE CRS_BALANCE CURSOR
	READ_ONLY
	FOR SELECT new_CashNameID,new_Amount,new_AmountCurrency,New_CashTransactionId
					FROM vNew_CashTransactionHeader h
					inner join vNew_CashTransaction t on t.new_CashTransactionHeaderId = h.New_CashTransactionHeaderId
					where h.New_CashTransactionHeaderId = @RecId                          
	OPEN CRS_BALANCE
	DECLARE @new_CashNameID uniqueidentifier,@new_Amount money,@new_AmountCurrency uniqueidentifier,@Balance money,@New_CashTransactionId uniqueidentifier
	FETCH NEXT FROM CRS_BALANCE INTO @new_CashNameID,@new_Amount,@new_AmountCurrency,@New_CashTransactionId
	WHILE @@FETCH_STATUS = 0
	BEGIN          
        set @Balance = null
       
        update vNew_CashTransaction set ModifiedOn=GETUTCDATE() WHERE New_CashTransactionId = @New_CashTransactionId

        select @Balance = Result FROM
	    (
		    select
                TOP 1
			    new_Balance AS Result,
			    case 
				    when cth.new_ConfirmDate IS NULL THEN ct.CreatedOn
				    else cth.new_ConfirmDate
			    end AS Date
			    from vNew_CashTransaction ct
			    left outer join vNew_CashTransactionHeader cth
			    on ct.new_CashTransactionHeaderId = cth.new_CashTransactionHeaderId
			    where 1=1 
		    and ct.new_CashNameID = @new_CashNameID
            and ct.new_BalanceCurrency = @new_AmountCurrency
            and ct.new_Status = 2
            and ct.DeletionStateCode = 0 and ct.new_Balance is not NULL
            and ((@RecId != ct.New_CashTransactionHeaderId) or ct.New_CashTransactionHeaderId IS NULL)
		    order by 2 desc
	    ) AS T

		update vNew_CashTransaction 
			set 
			new_Balance = isnull(@Balance,0) + (case 
				when new_TransactionType IN (3,8) and new_Status = 1 then new_Amount
				when new_TransactionType IN (3,8) and new_Status = 2 then new_Amount*-1
				when new_TransactionType = 4 and new_Status = 2 then new_Amount*-1
				when new_TransactionType = 4 and new_Status = 1 then new_Amount
                when new_TransactionType = 1 and new_Status = 1 then new_Amount
                when new_TransactionType = 1 and new_Status = 2 then new_Amount*-1
					end)  
			,new_BalanceCurrency = @new_AmountCurrency where new_CashTransactionHeaderId = @RecId and New_CashTransactionId = @New_CashTransactionId

		FETCH NEXT FROM CRS_BALANCE INTO @new_CashNameID,@new_Amount,@new_AmountCurrency,@New_CashTransactionId
	END
	CLOSE CRS_BALANCE
	DEALLOCATE CRS_BALANCE

    update vNew_CashTransaction set new_Status = 2 where new_CashTransactionHeaderId = @RecId
    update vNew_CashTransactionHeader set new_Status = 2, new_ConfirmDate = GETUTCDATE(),new_ConfirmUserId=@SystemUserId where New_CashTransactionHeaderId = @RecId              


            ", tr);

            StaticData.Commit(tr);

            QScript("LogCurrentPage();");
            var msg = new MessageBox { Width = 500 };
            msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_APPROVED_COMPLETE"));

            hdnRecId.SetIValue(New_CashTransactionHeaderId.Value);
            btnDekont.Show();
            btnRed.Hide();
            btnConfirm.Hide();

            QScript("DekontBas();");
            QScript("RefreshParetnGridForCashTransaction(true);");
        }
        catch (TuException tt)
        {
            StaticData.Rollback(tr);
            e.Message = tt.ErrorMessage;
            e.Success = false;
        }
        catch (Exception ex)
        {
            StaticData.Rollback(tr);
            e.Message = ex.Message;
            e.Success = false;
        }
    }

    protected void new_CashNameIDonEvent(object sender, AjaxEventArgs e)
    {
        string strSql = @"select new_CashId ID,new_CashId,CashName VALUE,CashName,c.new_OfficeName,c.new_OfficeNameName from nltvNew_Cash(@systemuser) c where new_MainCash=@mainCash";
        const string sort = "";
        var viewqueryid = ViewFactory.GetViewIdbyUniqueName("CashLookup");
        var gpc = new GridPanelCreater();
        int cnt;
        var start = new_CashNameID.Start();
        var limit = new_CashNameID.Limit();
        var spList = new List<CrmSqlParameter>();
        var prm1 = new CrmSqlParameter
        {
            Dbtype = DbType.Guid,
            Paramname = "systemuser",
            Value = App.Params.CurrentUser.SystemUserId
        };
        spList.Add(prm1);

        if (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString())
        {
            var prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Boolean,
                Paramname = "mainCash",
                Value = 0

            };
            spList.Add(prm2);

        }
        else if (new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
        {
            strSql = @"select DISTINCT new_CashId ID,new_CashId,CashName VALUE,CashName ,c.new_OfficeName,c.new_OfficeNameName
from vNew_Cash(NOLOCK) c 
where new_MainCash=@mainCash AND c.DeletionStateCode=0 ";

            var prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Boolean,
                Paramname = "mainCash",
                Value = 1

            };
            spList.Add(prm2);
        }
        else
        {
            var prm2 = new CrmSqlParameter
            {
                Dbtype = DbType.Boolean,
                Paramname = "mainCash",
                Value = 1

            };
            spList.Add(prm2);
        }



        var t = gpc.GetFilterData(strSql, viewqueryid, sort, spList, start, limit, out cnt);
        new_CashNameID.TotalCount = cnt;
        new_CashNameID.DataSource = t;
        new_CashNameID.DataBind();
    }

    public class KupurDetail
    {
        public int Carpan { get; set; }
        public decimal Adet { get; set; }
        public Guid KupurId { get; set; }
    }
    public class Kupurler
    {
        public string Currency { get; set; }
        public List<KupurDetail> Detail = new List<KupurDetail>();
    }

    private bool EksiKontrol(Guid cashId, Guid currency, decimal? amount)
    {
        var sd = new StaticData();

        sd.AddParameter("SystemUserId", DbType.Guid, App.Params.CurrentUser.SystemUserId);
        sd.AddParameter("CashID", DbType.Guid, cashId);
        sd.AddParameter("Currency", DbType.Guid, currency);
        sd.AddParameter("Amount", DbType.Decimal, amount);
        return ValidationHelper.GetBoolean(sd.ExecuteScalarSp("spTUCashBalanceControl"));
    }

    protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    {
        var kupurler = e.ExtraParams["Kupurler"];
        var kupurList = JsonConvert.DeserializeObject<List<Kupurler>>(kupurler);

        if (new_CashNameID.IsEmpty && (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString()))
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("Kasa Seçmelisiniz!");
            return;
        }


        if (new_TransactionType.IsEmpty)
        {
            var msg = new MessageBox { Width = 500 };
            msg.Show("İşlem tipi seçmelisiniz!");
            return;
        }

        //if (!New_CashTransactionHeaderId.IsEmpty)
        //    return;

        var trans = (new StaticData()).GetDbTransaction();
        var df = new DynamicFactory(ERunInUser.CalingUser);

        df.GetBeginTrans(trans);

        try
        {
            var dt = GetCurreny();
            bool isNullControl = true;
            if (dt.Rows.Count > 0)
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var cmc =
                        (CrmMoneyComp)
                        ColumnLayout12.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "field_Container");

                    if (cmc.d1.Value != null)
                    {
                        isNullControl = false;
                    }
                }
            }
            if (isNullControl)
            {
                var msg = new MessageBox { Width = 500 };
                df.RollbackTrans();
                msg.Show("Devir için en az bir tutar girmelisiniz!");
                return;
            }

            var hRef = SequenceCreater.NewId("CT");
            CashTransactionRefNo.SetValue(hRef);
            var maincash = FindCash(true);
            if (maincash == "")
            {
                return;
            }
            var toCashUser = GetCashUser(ValidationHelper.GetGuid(new_CashNameID.Value));

            var de = new DynamicEntity(TuEntityEnum.New_CashTransaction.GetHashCode());

            #region Cash Transaction Header
            /*Header İçin Önce Bir HeaderId Kaydı Oluştururuz*/
            var deheader = new DynamicEntity(TuEntityEnum.New_CashTransactionHeader.GetHashCode());
            deheader.AddPicklistProperty("new_TransactionType", ValidationHelper.GetInteger(new_TransactionType.Value, 1));
            deheader.AddStringProperty("HeaderRefno", hRef);
            deheader.AddOwnerProperty("OwningUser", "OwningUser",
                                      new_CashNameID.IsEmpty
                                          ? App.Params.CurrentUser.SystemUserId
                                          : GetCashUser(ValidationHelper.GetGuid(new_CashNameID.Value)));

            /*Eğer Hareket Tipi Zırhlı Araçsa Onaylıdır*/
            //if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
            //    new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
            if (new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
            {
                deheader.AddPicklistProperty("new_Status", 2);
                deheader.AddLookupProperty("new_ConfirmUserId", "", App.Params.CurrentUser.SystemUserId);
                //deheader.AddDateTimeProperty("new_ConfirmDate", DateTime.UtcNow);

            }

            /*Eğer Hareket Tipi Zırhlı Araç Değilse Onaysızdır*/
            if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                deheader.AddPicklistProperty("new_Status", 1);

            /*FromCash ToCash Alanlarından Biri Duruma Göre Dolacak!!*/
            #region FromCash ToCash Yapısı

            Guid fromCash;
            if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
            {
                deheader.AddLookupProperty("new_ToCash", "", ValidationHelper.GetGuid(maincash));
            }
            if (new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
            {
                fromCash = ValidationHelper.GetGuid(maincash);
                deheader.AddLookupProperty("new_FromCash", "", fromCash);
            }
            if (new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString())
            {
                fromCash = ValidationHelper.GetGuid(FindCash(false));
                deheader.AddLookupProperty("new_FromCash", "", fromCash);
                deheader.AddLookupProperty("new_ToCash", "", ValidationHelper.GetGuid(new_CashNameID.Value));
            }
            if (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
            {
                fromCash = ValidationHelper.GetGuid(maincash);
                deheader.AddLookupProperty("new_FromCash", "", fromCash);
                deheader.AddLookupProperty("new_ToCash", "", ValidationHelper.GetGuid(new_CashNameID.Value));
            }
            #endregion

            var headerId = df.Create("New_CashTransactionHeader", deheader);

            var deHeaderForUpdate = new DynamicEntity(deheader.ObjectId);
            deHeaderForUpdate.AddKeyProperty("New_CashTransactionHeaderId", headerId);

            New_CashTransactionHeaderId.SetValue(headerId);

            #region ConfirmDate Update

            if (//new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                  new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
            {
                var sdHeaderUpdate = new StaticData();
                sdHeaderUpdate.AddParameter("RecId", DbType.Guid, ValidationHelper.GetGuid(headerId));
                sdHeaderUpdate.ExecuteNonQuery(@"update vNew_CashTransactionHeader set new_ConfirmDate = GETUTCDATE() where New_CashTransactionHeaderId = @RecId", trans);
            }
            #endregion

            #endregion


            string uyumsuzKupur = string.Empty;

            if (dt.Rows.Count > 0)
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    var cmc =
                        (CrmMoneyComp)
                        ColumnLayout12.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "field_Container");

                    var c = cmc.d1.Value;
                    var d = cmc.c1.Value;

                    if (cmc.d1.Value <= 0)
                    {
                        var msg = new MessageBox { Width = 500 };
                        df.RollbackTrans();
                        New_CashTransactionHeaderId.Value = null;
                        msg.Show("Tutar Sıfır ve Sıfırdan Küçük Olamaz!");
                        return;
                    }

                    if (cmc.d1.IsEmpty)
                        continue;

                    #region FromCash
                    var recId = GuidHelper.Newfoid(TuEntityEnum.New_CashTransaction.GetHashCode());
                    var fc = new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString()
                                 ? ValidationHelper.GetGuid(FindCash(false))
                                 : ValidationHelper.GetGuid(maincash);
                    var fromCashBalance = GetCashCurrencyBalance(fc, ValidationHelper.GetGuid(d), recId);

                    if (new_TransactionType.Value != CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
                    {
                        if (EksiKontrol(fc, ValidationHelper.GetGuid(d), c))
                        {
                            throw new TuException(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_BALANCE_IS_NEGATIVE"), "0");
                        }
                    }

                    var orjRecID = recId;
                    de.AddKeyProperty("New_CashTransactionId", recId);
                    de.AddLookupProperty("new_CashTransactionHeaderId", "", ValidationHelper.GetGuid(headerId));
                    de.AddLookupProperty("new_CashNameID", "", fc);
                    de.AddPicklistProperty("new_TransactionType", ValidationHelper.GetInteger(new_TransactionType.Value, 0));
                    de.AddOwnerProperty("OwningUser", "OwningUser", App.Params.CurrentUser.SystemUserId);
                    de.AddMoneyProperty("new_Amount", (decimal)c, new Lookup("new_AmountCurrency", ValidationHelper.GetGuid(d)));

                    //if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
                    //{
                    //    de.AddMoneyProperty("new_Balance", fromCashBalance + (decimal)c, new Lookup("new_BalanceCurrency", ValidationHelper.GetGuid(d)));
                    //}

                    if (new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
                    {
                        de.AddMoneyProperty("new_Balance", fromCashBalance - (decimal)c, new Lookup("new_BalanceCurrency", ValidationHelper.GetGuid(d)));
                    }

                    if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
                    {
                        de.AddPicklistProperty("new_Status", 1);
                    }
                    else
                    {
                        de.AddPicklistProperty("new_Status", 2);
                    }

                    de.AddStringProperty("new_Description", new_Description.Value);
                    df.Create("New_CashTransaction", de);

                    #region Girilen döviz tutarlarını header'a update eder

                    if (dt.Rows[i]["new_CurrencyIdName"].ToString() == "TL")
                    {
                        deHeaderForUpdate.AddDecimalProperty("new_TLAmount", (decimal)c);

                    }
                    else if (dt.Rows[i]["new_CurrencyIdName"].ToString() == "USD")
                    {
                        deHeaderForUpdate.AddDecimalProperty("new_UsdAmount", (decimal)c);

                    }
                    else if (dt.Rows[i]["new_CurrencyIdName"].ToString() == "EUR")
                    {
                        deHeaderForUpdate.AddDecimalProperty("new_EuroAmount", (decimal)c);

                    }
                    else if (dt.Rows[i]["new_CurrencyIdName"].ToString() == "GBP")
                    {
                        deHeaderForUpdate.AddDecimalProperty("new_GbpAmount", (decimal)c);

                    }

                    #endregion

                    #endregion

                    if (new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString() ||
                        new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() ||
                        new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                    {
                        #region ToCash
                        recId = GuidHelper.Newfoid(TuEntityEnum.New_CashTransaction.GetHashCode());
                        var toCashBalance = GetCashCurrencyBalance(ValidationHelper.GetGuid(new_CashNameID.Value), ValidationHelper.GetGuid(d), recId);

                        //if (new_TransactionType.Value != CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
                        //    if (EksiKontrol(ValidationHelper.GetGuid(new_CashNameID.Value), ValidationHelper.GetGuid(d), c))
                        //    {
                        //        throw new TuException(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_BALANCE_IS_NEGATIVE"), "0");
                        //    }

                        de.AddKeyProperty("New_CashTransactionId", recId);
                        de.AddLookupProperty("new_CashTransactionHeaderId", "", ValidationHelper.GetGuid(headerId));
                        de.AddLookupProperty("new_CashNameID", "", ValidationHelper.GetGuid(new_CashNameID.Value));
                        de.AddPicklistProperty("new_TransactionType", ValidationHelper.GetInteger(new_TransactionType.Value, 0));
                        de.AddOwnerProperty("OwningUser", "OwningUser",
                                            (new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString()
                                            || new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                                                ? toCashUser
                                                : App.Params.CurrentUser.SystemUserId);
                        de.AddMoneyProperty("new_Amount", (decimal)c, new Lookup("new_AmountCurrency", ValidationHelper.GetGuid(d)));
                        //de.AddMoneyProperty("new_Balance", toCashBalance + (decimal)c, new Lookup("new_BalanceCurrency", ValidationHelper.GetGuid(d)));
                        de.AddPicklistProperty("new_Status", 1);
                        de.AddStringProperty("new_Description", new_Description.Value);
                        df.Create("New_CashTransaction", de);
                        #endregion
                    }

                    if (new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString())
                    {
                        orjRecID = recId;
                    }


                    /*Aktifbanktan ofise gelen paralarda para geldiğinde yani onay aşamasında küpürler girilecek.*/
                    if (new_TransactionType.Value != CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
                    {
                        var kupur = new List<KupurDetail>();
                        foreach (var k in kupurList)
                        {
                            if (k.Currency == dt.Rows[i]["new_CurrencyIdName"].ToString())
                                kupur = k.Detail;
                        }

                        var deDetail = new DynamicEntity(TuEntityEnum.New_CashTransactionDetail.GetHashCode());

                        decimal toplam = 0;
                        foreach (var item in kupur)
                        {
                            if (item.Adet == 0) continue;
                            var detailrecId = GuidHelper.Newfoid(TuEntityEnum.New_CashTransaction.GetHashCode());
                            deDetail.AddKeyProperty("New_CashTransactionDetailId", detailrecId);
                            deDetail.AddLookupProperty("new_CashTransactionId", "", ValidationHelper.GetGuid(orjRecID));
                            deDetail.AddDecimalProperty("new_Count", item.Adet);
                            deDetail.AddLookupProperty("new_CurrencyKupurId", "", ValidationHelper.GetGuid(item.KupurId));
                            df.Create("New_CashTransactionDetail", deDetail);
                            toplam += item.Adet * item.Carpan;
                        }
                        if (toplam != (decimal)c)
                        {
                            uyumsuzKupur += dt.Rows[i]["new_CurrencyIdName"].ToString() + ", ";
                        }
                    }
                }

                df.Update("New_CashTransactionHeader", deHeaderForUpdate);


                if (uyumsuzKupur != string.Empty)
                {
                    throw new Exception(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_KUPUR_UYUMSUZ") + " (" + uyumsuzKupur.Substring(0, uyumsuzKupur.Length - 2) + ")");
                }
            }

            #region Kasa Hesabı işlemleri
            try
            {
                if (
                    new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                    new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString()
                    )
                {
                    for (var i = 0; i < dt.Rows.Count; i++)
                    {
                        var cmc =
                        (CrmMoneyComp)
                        ColumnLayout12.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "field_Container");

                        var amount = ValidationHelper.GetDecimal(cmc.d1.Value, 0);
                        var currency = cmc.c1.Value;

                        if (amount != 0)
                        {
                            CashAccountTransaction cat = GetCashAccountTransaction(amount, ValidationHelper.GetGuid(currency), ValidationHelper.GetGuid(headerId), false);
                            CashAccountTransactionManager manager = new CashAccountTransactionManager();
                            manager.CompleteCashAccountTransaction2(cat, trans);
                        }


                    }
                }
                else if (new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString())
                {
                    Guid cashTransactionHeaderId = ValidationHelper.GetGuid(headerId);
                    Guid FromCashId = ValidationHelper.GetGuid(maincash);

                    CashTransactionManager cashManager = new CashTransactionManager();
                    List<CashTransactions> transactionList = cashManager.GetCashTransaction(cashTransactionHeaderId, FromCashId, trans);

                    foreach (var item in transactionList)
                    {

                        cashManager.SaveAccountTransactions(item, false, CashAccountTransactionTypes.CashReceive, trans);

                    }
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }







            #endregion

            df.CommitTrans();

            #region Disable Controls


            new_TransactionType.SetDisabled(true);

            if (dt.Rows.Count > 0)
            {
                for (var i = 0; i < dt.Rows.Count; i++)
                {
                    string currencyControl = "Currency_" + dt.Rows[i]["new_CurrencyIdName"].ToString();
                    var cmc =
                        (CrmMoneyComp)
                        ColumnLayout12.FindControl("Currency_" + dt.Rows[i]["new_CurrencyIdName"] + "field_Container");
                    cmc.d1.SetDisabled(true);
                }
            }


            #endregion

            if (//new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString()
                )
            {
                hdnRecId.SetIValue(headerId);
                btnDekont.Show();

                QScript("LogCurrentPage();");
                QScript("DekontBas();");

            }
            btnSave.Hide();


            if (
                //new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString()
                )
            {
                var msg = new MessageBox { Width = 500 };
                msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_SAVE_COMPLETE"));
                QScript("RefreshParetnGridForCashTransaction(true);");



            }
            if (
                new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.GisecidenTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.GiseciyeTeslim.GetHashCode().ToString() ||
                new_TransactionType.Value == CashTypeEnum.OfistenOfise.GetHashCode().ToString()
                )
            {
                QScript("LogCurrentPage();");
                var msg = new MessageBox { Width = 500 };
                msg.Show(Coretech.Crm.Factory.Crm.CrmLabel.TranslateMessage("CRM.NEW_CASHTRANSACTIONHEADER_SEND_CONFIRM"));
                QScript("RefreshParetnGridForCashTransaction(true);");
            }



        }
        catch (TuException tt)
        {
            df.RollbackTrans();
            e.Message = tt.ErrorMessage;
            e.Success = false;
        }
        catch (Exception ex)
        {
            df.RollbackTrans();
            e.Message = ex.Message;
            e.Success = false;
        }
    }


    private CashAccountTransaction GetCashAccountTransaction(decimal amount, Guid currencyId, Guid cashTransactionHeaderId, bool isConfirm)
    {
        CashAccountTransaction item = null;
        CashAccountTransactionTypes type = CashAccountTransactionTypes.CashRequest;

        if (new_TransactionType.Value == CashTypeEnum.SecurverdidenTeslim.GetHashCode().ToString())
        {
            if (isConfirm)
            {
                type = CashAccountTransactionTypes.CashReceive;
            }
            else
            {
                type = CashAccountTransactionTypes.CashRequest;
            }

        }
        else if (new_TransactionType.Value == CashTypeEnum.SecurverdiyeTeslim.GetHashCode().ToString())
        {
            type = (CashAccountTransactionTypes)ValidationHelper.GetInteger(3);
        }

        CashAccountTransactionManager manager = new CashAccountTransactionManager();
        item = manager.CreateTransaction(type); ;

        item.CashTransactionHeaderId = cashTransactionHeaderId;
        item.Amount = amount;
        item.AmountCurrencyId = currencyId;

        switch (item.Type)
        {
            case CashAccountTransactionTypes.CashRequest:
            case CashAccountTransactionTypes.CashReceive:
                item.Description = "Kasa Hesabı Para Talebi {0}";
                break;
            case CashAccountTransactionTypes.CashSubmit:
                item.Description = "Kasa Hesabı Para Devri {0}";
                break;
        }

        if (item.Type != CashAccountTransactionTypes.CashReceive) //Para teslim alındı disindakiler - Para teslim alındığında zaten referans giriliyor.
        {
            item.Reference = manager.GetTransactionReference(item.OperationType);
        }


        item.Description = string.Format(item.Description, item.Reference);



        return item;
    }
}