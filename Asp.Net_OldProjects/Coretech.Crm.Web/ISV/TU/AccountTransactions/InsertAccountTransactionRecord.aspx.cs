using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Factory.Exporter;
using Coretech.Crm.PluginData;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using TuFactory.CustomApproval;
using TuFactory.Object;
using UPTCache = UPT.Shared.CacheProvider.Service;
using UPTCacheObjects = UPT.Shared.CacheProvider.Model;

namespace Coretech.Crm.Web.ISV.TU.AccountTransactions
{
    /// <summary>
    /// Bu sayfaya hiç özenmedim. Çünkü arada sırada fiş kesmek için kullanılacak, çok az kullanılacak.
    /// </summary>
    public partial class InsertAccountTransactionRecord : CustomApprovalPage<FreePreAccountingApproval>
    {
        DataTable dtAccountTransactionRow
        {
            get
            {
                return Session["AccountTransactionRowList"] as DataTable;
            }
            set
            {
                Session["AccountTransactionRowList"] = value;
            }
        }

        protected List<AccountTransactionRow> AccountTransactionRowList
        {
            get
            {
                return Session["AccountTransactionRowList"] as List<AccountTransactionRow> ;
            }
            set
            {
                Session["AccountTransactionRowList"] = value;
            }
        }

        protected List<string> ValidDirections
        {
            get
            {
                List<string> validDirections = new List<string>();
                validDirections.Add("A");
                validDirections.Add("B");
                return validDirections;
            }
        }

        protected Dictionary<string, string> AccountTransactionTypes
        {
            get
            {
                Dictionary<string, string> ret = new Dictionary<string, string>();
                ret.Add("A", "HH31");
                ret.Add("B", "HH30");
                return ret;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!RefleX.IsAjxPostback)
            {
                var dynamicSecurity = DynamicFactory.GetSecurity(TuEntityEnum.New_UptReconcliationHeader.GetHashCode(), App.Params.CurrentUser.SystemUserId, null, null);
                if (!dynamicSecurity.PrvCreate)
                {
                    Response.Redirect("~/MessagePages/_PrivilegeError.aspx", false);
                }
                this.AccountTransactionRowList = new List<AccountTransactionRow>();
            }
        }

        protected void AddAccountTranRow(object sender, AjaxEventArgs e)
        {
            hdnRowId.Clear();
            windowRow.Show();
        }

        protected void DeleteAccountTranRow(object sender, AjaxEventArgs e)
        {
            var selectionModel = (RowSelectionModel)gridPanel.SelectionModel[0];
            if (selectionModel != null)
            {
                if (selectionModel.SelectedRows != null)
                {
                    Guid rowId = Guid.Parse(selectionModel.SelectedRows[0].RowId);
                    AccountTransactionRow row = this.AccountTransactionRowList.Find(r => r.RowId == rowId);
                    if (row != null)
                    {
                        this.AccountTransactionRowList.Remove(row);
                        BindGrid();
                    }
                }
            }
        }

        protected void ShowRowWindowForUpdate(object sender, AjaxEventArgs e)
        {
            var selectionModel = (RowSelectionModel)gridPanel.SelectionModel[0];
            if (selectionModel != null)
            {
                if (selectionModel.SelectedRows != null)
                {
                    Guid rowId = Guid.Parse(selectionModel.SelectedRows[0].RowId);
                    AccountTransactionRow row = this.AccountTransactionRowList.Find(r => r.RowId == rowId);
                    if (row != null)
                    {
                        SetRow(row);
                    }
                }
            }
        }

        protected void ShowRecordWindow(object sender, AjaxEventArgs e)
        {
            windowRecord.Show();
        }

        protected void SaveAccountTranRow(object sender, AjaxEventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(hdnRowId.Value))
                {
                    AddRow();
                }
                else
                {
                    UpdateRow();
                }
                BindGrid();
                CloseRowWindow();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        protected void SaveRecord(object sender, AjaxEventArgs e)
        {
            try
            {
                if (!string.IsNullOrEmpty(tDate.Value.Trim()))
                {
                    DateTime date = DateTime.Parse(tDate.Value.Trim());
                    string reference = GetReferenceNumber();
                    string transactionNumber = GetTransactionNumber();

                    //StaticData sd = new StaticData();
                    //DbTransaction tran = sd.GetDbTransaction();

                    Dictionary<string, decimal> directionTotals = new Dictionary<string, decimal>(); //Currency - total
                    Dictionary<string, decimal> logoDirectionTotals = new Dictionary<string, decimal>(); //Currency - total

                    try
                    {
                        for (int i = 0; i < this.AccountTransactionRowList.Count; i++)
                        {
                            this.AccountTransactionRowList[i].Reference = reference;
                            this.AccountTransactionRowList[i].TransactionNumber = transactionNumber;
                            this.AccountTransactionRowList[i].Date = date;
                            //InsertAccountTransaction(this.AccountTransactionRowList[i], tran);
                            if(!directionTotals.ContainsKey(this.AccountTransactionRowList[i].Currency))
                            {
                                directionTotals.Add(this.AccountTransactionRowList[i].Currency, 0);
                                logoDirectionTotals.Add(this.AccountTransactionRowList[i].Currency, 0);
                            }
                            directionTotals[this.AccountTransactionRowList[i].Currency] += this.AccountTransactionRowList[i].Direction == "A" ? this.AccountTransactionRowList[i].Amount : this.AccountTransactionRowList[i].Amount * -1;
                            logoDirectionTotals[this.AccountTransactionRowList[i].Currency] += this.AccountTransactionRowList[i].LogoDirection == "A" ? this.AccountTransactionRowList[i].Amount : this.AccountTransactionRowList[i].Amount * -1;
                        }

                        bool validateCurrencyTotals = true;
                        foreach(var key in directionTotals.Keys)
                        {
                            if(directionTotals[key] != 0 || logoDirectionTotals[key] != 0)
                            {
                                validateCurrencyTotals = false;
                                break;
                            }
                        }

                        if(!validateCurrencyTotals)
                        {
                            ShowMessage("Hesap hareketleri toplamında sorun bulunmaktadır, lütfen tutar ve yön değerlerini inceleyiniz.");
                            return;
                        }

                        //tran.Commit();
                        FreePreAccountingApproval approval = new FreePreAccountingApproval()
                        {
                            ApprovalKey = reference,
                            CreateUser = new TuFactory.Domain.SystemUser() { SystemUserId = App.Params.CurrentUser.SystemUserId },
                            AccountTransactions = this.AccountTransactionRowList,
                            ApprovalExplanation = this.tExplanation.Value
                        };

                        string saveRet = approval.Save();
                        if (string.IsNullOrEmpty(saveRet))
                        {
                            this.AccountTransactionRowList = new List<AccountTransactionRow>();
                            BindGrid();
                            ClearRowWindow();
                            //ShowMessage(string.Format("{0} referanslı fiş oluşturulmuştur.", reference));
                            ShowMessage("İşleminiz onaya gönderilmiştir.");
                            windowRecord.Hide();
                        }
                        else
                        {
                            ShowMessage(saveRet);
                        }                        
                    }
                    catch (Exception ex)
                    {
                        //tran.Rollback();
                        ShowMessage(ex.Message);
                    }
                }
                else
                {
                    ShowMessage("Tarih alanı zorunlu bir alandır.");
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }            
        }

        string GetReferenceNumber()
        {
            return SequenceCreater.NewId("DK");
        }

        string GetTransactionNumber()
        {
            StaticData sd = new StaticData();
            return sd.ExecuteScalar("SELECT NEXT VALUE FOR AccountTransactionSequence").ToString();
        }

        void BindGrid()
        {
     
            gridPanel.DataSource = this.AccountTransactionRowList;
            gridPanel.DataBind();
        }

     
        protected void ExportToExcel(object sender, AjaxEventArgs e)
        {
            var n = string.Format("Account_Transactions_{0:yyyy_MM_dd_hh_mm_ss}.xls", DateTime.Now);

            DataTable dt = new DataTable();

            dt = ToDataTable(AccountTransactionRowList);

            Export.ExportDownloadData(dt, n);
        }


        DataTable ToDataTable<T>(IList<T> data)
        {
            PropertyDescriptorCollection props =
                TypeDescriptor.GetProperties(typeof(T));
            DataTable table = new DataTable();
            for (int i = 0; i < props.Count; i++)
            {
                PropertyDescriptor prop = props[i];
                table.Columns.Add(prop.Name, prop.PropertyType);
            }
            object[] values = new object[props.Count];
            foreach (T item in data)
            {
                for (int i = 0; i < values.Length; i++)
                {
                    values[i] = props[i].GetValue(item);
                }
                table.Rows.Add(values);
            }
            return table;
        }

        AccountTransactionRow GetRow()
        {
            if
            (
                string.IsNullOrEmpty(tAccount.Value.Trim()) ||
                string.IsNullOrEmpty(tLogoAccount.Value.Trim()) ||
                string.IsNullOrEmpty(tAmount.Value.Trim()) ||
                string.IsNullOrEmpty(tCurrency.Value.Trim()) ||
                string.IsNullOrEmpty(tDirection.Value.Trim()) ||
                string.IsNullOrEmpty(tLogoDirection.Value.Trim()) ||
                string.IsNullOrEmpty(tRate.Value.Trim())
            )
            {
                throw new Exception("Tüm alanları doldurunuz.");
            }

            AccountTransactionRow row = new AccountTransactionRow();
            row.AccountNo = tAccount.Value.Trim();
            row.LogoAccountNo = tLogoAccount.Value.Trim();
            row.Amount = decimal.Parse(tAmount.Value.Trim());
            row.Currency = tCurrency.Value.Trim();
            row.Direction = tDirection.Value.Trim();
            row.LogoDirection = tLogoDirection.Value.Trim();
            row.Rate = decimal.Parse(tRate.Value.Trim());

            return row;
        }

        void AddRow()
        {
            AccountTransactionRow row = GetRow();
            row.RowId = Guid.NewGuid();

            ValidateAndSetExtraData(row);

            this.AccountTransactionRowList.Add(row);
        }

        void SetRow(AccountTransactionRow row)
        {
            hdnRowId.SetValue(row.RowId.ToString());
            tAccount.SetValue(row.AccountNo);
            tLogoAccount.SetValue(row.LogoAccountNo);
            tAmount.SetValue(row.Amount.ToString());
            tCurrency.SetValue(row.Currency);
            tDirection.SetValue(row.Direction);
            tLogoDirection.SetValue(row.LogoDirection);
            tRate.SetValue(row.Rate.ToString());
            windowRow.Show();
        }        

        void UpdateRow()
        {
            AccountTransactionRow tempRow = GetRow();
            tempRow.RowId = Guid.Parse(hdnRowId.Value);

            ValidateAndSetExtraData(tempRow);

            AccountTransactionRow row = this.AccountTransactionRowList.Find(r => r.RowId == tempRow.RowId);
            this.AccountTransactionRowList.Remove(row);
            this.AccountTransactionRowList.Add(tempRow);
        }

        void ValidateAndSetExtraData(AccountTransactionRow row)
        {
            if (!this.ValidDirections.Contains(row.Direction))
            {
                throw new Exception("Yön alanına uygun değer girilmemiştir.");
            }
            else
            {
                row.TypeCode = this.AccountTransactionTypes[row.Direction];
                UPTCacheObjects.AccountTransactionType type = UPTCache.AccountTransactionTypeService.List.Find(t => t.Code == row.TypeCode);
                row.TypeId = type.Id;
                row.TypeName = type.Name;
            }

            if (!this.ValidDirections.Contains(row.LogoDirection))
            {
                throw new Exception("Logo yön alanına uygun değer girilmemiştir.");
            }

            UPTCacheObjects.Currency currency = UPTCache.CurrencyService.GetCurrencyByCurrencyCode(row.Currency);
            if (currency == null)
            {
                throw new Exception("Döviz cinsi alanına uygun değer girilmemiştir.");
            }
            else
            {
                row.CurrencyId = currency.CurrencyId;
            }

            UPTCacheObjects.Account account = UPTCache.AccountService.GetAccountByAccountNo(row.AccountNo);
            if (account == null)
            {
                throw new Exception("Hesap alanına uygun değer girilmemiştir.");
            }
            else
            {
                row.AccountId = account.AccountId;
                row.AccountDesc = account.AccountDescription;
            }

            UPTCacheObjects.Account logoAccount = UPTCache.AccountService.GetAccountByAccountNo(row.LogoAccountNo);
            if (logoAccount == null)
            {
                throw new Exception("Logo hesap alanına uygun değer girilmemiştir.");
            }
            else
            {
                row.LogoAccountId = logoAccount.AccountId;
                row.LogoAccountDesc = logoAccount.AccountDescription;
            }

            if (account.CurrencyId != row.CurrencyId || logoAccount.CurrencyId != row.CurrencyId)
            {
                throw new Exception("Döviz cinsi, hesap bilgileri uyuşmamaktadır.");
            }
        }

        void CloseRowWindow()
        {
            ClearRowWindow();
            windowRow.Hide();
        }

        void ClearRowWindow()
        {
            tAccount.Clear();
            tLogoAccount.Clear();
            tAmount.Clear();
            tCurrency.Clear();
            tDirection.Clear();
            tLogoDirection.Clear();
            tRate.Clear();
        }

        void ShowMessage(string messageText)
        {
            MessageBox messageBox = new MessageBox();
            messageBox.Width = 360;
            messageBox.Height = 150;
            messageBox.Show(messageText);
        }

        protected override void SetApprovalData()
        {
            PanelX1.Visible = false;

            gridPanel.AddColumn(new GridColumns() { Header = "TARİH", ColumnId = "10", DataIndex = "DateStr", Width = 100});

            gridPanel.DataSource = this.Approval.AccountTransactions;
            gridPanel.DataBind();
        }

        protected override void AfterApprove()
        {
            this.AccountTransactionRowList = new List<AccountTransactionRow>();
            BindGrid();
            ClearRowWindow();
            windowRecord.Hide();
        }
    }
}