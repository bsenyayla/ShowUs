using System;
using Coretech.Crm.Factory.Crm.Dynamic;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using TuFactory.Object;
using TuFactory.Object.User;
using Coretech.Crm.Objects.Crm.WorkFlow;
using Coretech.Crm.Factory;
using TuFactory.TuUser;
using TuFactory.CashAccountTransactions;



public partial class AccountTransactions_CashAccountTransaction : BasePage
{
    #region Variables

    private TuUserApproval _userApproval = null;
    public Guid recId = Guid.Empty;

    #endregion

    protected override void OnPreInit(EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {

        }
        base.OnPreInit(e);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!RefleX.IsAjxPostback)
        {
            var ufFactory = new TuUserFactory();
            _userApproval = ufFactory.GetApproval(App.Params.CurrentUser.SystemUserId);
            new_CashAccountTransactionId.Value = QueryHelper.GetString("recid");

            LoadData();
        }

    }

    private void LoadData()
    {
        new_CashAccountTransactionId.Value = QueryHelper.GetString("recid");

        if (!string.IsNullOrEmpty(new_CashAccountTransactionId.Value))
        {
            DynamicFactory df;
            df = new DynamicFactory(ERunInUser.CalingUser) { ActivePage = Page };


            var cashAccountTransaction = df.Retrieve(TuEntityEnum.New_CashAccountTransaction.GetHashCode(),
                                              ValidationHelper.GetGuid(new_CashAccountTransactionId.Value),
                                              DynamicFactory.RetrieveAllColumns);


            new_TransactionType.FillDynamicEntityData(cashAccountTransaction);
            new_Amount.FillDynamicEntityData(cashAccountTransaction);
            new_ReferenceNumber.FillDynamicEntityData(cashAccountTransaction);

            //new_TransactionType.SetDisabled(true);
            //new_Amount.SetDisabled(true);
            //new_ReferenceNumber.SetDisabled(true);

            //new_TransactionType.SetReadOnly(true);
            

            //new_Amount.SetReadOnly(true);
           

            //new_ReferenceNumber.SetReadOnly(true);
            

            //btnSave.SetDisabled(true);



        }


    }

    protected void TransactionTypeChange(object sender, AjaxEventArgs e)
    {
        if (new_TransactionType.Value == CashAccountTransactionTypes.CashRequest.GetHashCode().ToString() || new_TransactionType.Value == CashAccountTransactionTypes.CashSubmit.GetHashCode().ToString())
        {
            new_ReferenceNumber.Clear();
            new_ReferenceNumber.SetReadOnly(true);
            new_ReferenceNumber.ReadOnly = true;
            new_Amount.SetVisible(true);
            new_Amount.Visible = true;
        }
        else if (new_TransactionType.Value == CashAccountTransactionTypes.CashReceive.GetHashCode().ToString())
        {
            new_ReferenceNumber.Clear();
            new_ReferenceNumber.SetReadOnly(false);
            new_ReferenceNumber.ReadOnly = false;
            new_Amount.SetVisible(false);
            new_Amount.Visible = false;
        }
    }

    //protected void btnSaveOnEvent(object sender, AjaxEventArgs e)
    //{
    //    if (new_TransactionType.IsEmpty)
    //    {
    //        var msg = new MessageBox { Width = 500 };
    //        msg.Show("İşlem Tipi Seçmelisiniz!");
    //        return;
    //    }
    //    if (new_TransactionType.Value == CashAccountTransactionTypes.CashReceive.GetHashCode().ToString())
    //    {
    //        if (new_ReferenceNumber.IsEmpty)
    //        {
    //            var msg = new MessageBox { Width = 500 };
    //            msg.Show("Referans numarası girmelisiniz!");
    //            return;
    //        }
    //    }


    //    if (new_TransactionType.Value == CashAccountTransactionTypes.CashRequest.GetHashCode().ToString() || new_TransactionType.Value == CashAccountTransactionTypes.CashSubmit.GetHashCode().ToString())
    //    {
    //        if (new_Amount.d1.IsEmpty)
    //        {
    //            var msg = new MessageBox { Width = 500 };
    //            msg.Show("Tutar girmelisiniz");
    //            return;
    //        }
    //        if (new_Amount.c1.IsEmpty)
    //        {
    //            var msg = new MessageBox { Width = 500 };
    //            msg.Show("Döviz seçmelisiniz");
    //            return;
    //        }
    //    }

    //    QScript("LogCurrentPage();");

    //    CashAccountTransaction cat = GetCashAccountTransaction();

    //    CashAccountTransactionManager manager = new CashAccountTransactionManager();

    //    manager.CompleteCashAccountTransaction2(cat);

    //    if (new_TransactionType.Value == CashAccountTransactionTypes.CashRequest.GetHashCode().ToString())
    //    {
    //        QScript("alert('Kasaya Para Talebi alındı.');");
    //    }
    //    else if (new_TransactionType.Value == CashAccountTransactionTypes.CashReceive.GetHashCode().ToString())
    //    {
    //        QScript("alert('Para Teslim Alındı.');");
    //    }
    //    else if (new_TransactionType.Value == CashAccountTransactionTypes.CashSubmit.GetHashCode().ToString())
    //    {
    //        QScript("alert('Para Teslim Edildi.');");
    //    }

    //    QScript("RefreshParetnGridForCashTransaction(true);");

    //}

    private CashAccountTransaction GetCashAccountTransaction()
    {
        CashAccountTransaction item = null;

        CashAccountTransactionTypes type = (CashAccountTransactionTypes)ValidationHelper.GetInteger(new_TransactionType.Value);
        CashAccountTransactionManager manager = new CashAccountTransactionManager();
        item = manager.CreateTransaction(type); ;


        item.Amount = ValidationHelper.GetDecimal(new_Amount.d1.Value, 0);
        item.AmountCurrencyId = ValidationHelper.GetGuid(new_Amount.c1.Value);

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
        else
        {
            item.Reference = new_ReferenceNumber.Value;
        }

        item.Description = string.Format(item.Description, item.Reference);



        return item;
    }


}

