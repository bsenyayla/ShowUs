using System;
using System.Collections.Generic;
using Coretech.Crm.Factory.Crm;
using Coretech.Crm.Objects.Crm.Dynamic.DynamicObject;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using Coretech.Crm.Web.UI.RefleX;
using RefleXFrameWork;
using Coretech.Crm.Objects.Crm.Attributes;
using Coretech.Crm.Objects.Crm.Labels;

public partial class CrmPages_Admin_Customization_Entity_Property_AttributeListReflex : AdminPage
{
    public CrmPages_Admin_Customization_Entity_Property_AttributeListReflex()
    {
        ObjectId = EntityEnum.Entity.GetHashCode();
    }

    void TranslateMessages()
    {
        btnNew.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        btnAdd.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_SAVE);
        btnDelete.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        DisplayName.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DISPLAY_NAME);
        Name.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_NAME);
        Level.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_LEVEL);
        txtDescription.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DESCRIPTION);
        Format.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_FORMAT);
        Type.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_TYPE);
        MaxLength.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_MAX_LENGTH);
        DefaultValue.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DEFAULT_VALUE);
        Format.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_FORMAT);
        Format.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_FORMAT);
        picklist.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_VALUE);
        picklist.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_LABEL);
        picklist.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_PICK_LIST_VALUES);
        Precision.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_PRECISION);
        MinValue.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_MINVALUE);
        MaxValue.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_MAXVALUE);
        AllowKeys.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_ALLOWKEYS);
        CaseMode.FieldLabel = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_CASEMODE);
        _grdsma.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_ATTRIBUTE_NAME);
        _grdsma.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_LABEL);
        _grdsma.ColumnModel.Columns[2].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_TYPE_ID_NAME);
        _grdsma.ColumnModel.Columns[3].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_MAX_LENGTH);
        _grdsma.ColumnModel.Columns[4].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_DEFAULT_VALUE);
        MenuItem1.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_NEW);
        MenuItem2.Text = CrmLabel.TranslateMessage(LabelEnum.CRM_DELETE);
        bitlist.ColumnModel.Columns[0].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_MESSAGES_VALUE);
        bitlist.ColumnModel.Columns[1].Header = CrmLabel.TranslateMessage(LabelEnum.CRM_CUST_ATTRIBUTE_LABEL);
    }

    protected override void OnPreInit(EventArgs e)
    {
        TranslateMessages();
        base.OnPreInit(e);
    }

    protected void SetTypeItems()
    {

        var atr = Enum.GetNames(typeof(Types));
        for (var i = 0; i < atr.Length; i++)
        {
            var li = new ListItem { Value = StringEnum.GetStringValue((Types)Enum.Parse(typeof(Types), i.ToString())), Text = atr[i] };
            Type.Items.Add(li);
        }
        Type.Value = StringEnum.GetStringValue(Types.Nvarchar);

        atr = Enum.GetNames(typeof(ECaseMode));
        for (var i = 0; i < atr.Length; i++)
        {
            var li = new ListItem { Value = i.ToString(), Text = atr[i] };
            CaseMode.Items.Add(li);
        }
        CaseMode.Value = ECaseMode.Normal.GetHashCode().ToString();

        FormatItems(Type.Value);
        TypeStatus(Type.Value, true);
    }

    protected void AllowKeysOnEvent(object sender, AjaxEventArgs e)
    {
        var sd = new StaticData();
        var dt =
            sd.ReturnDataset(
                "select CustomTextModeId,CustomTextModeName from vCustomTextMode where DeletionStateCode = 0").Tables[0];
        AllowKeys.TotalCount = dt.Rows.Count;
        AllowKeys.DataSource = dt;
        AllowKeys.DataBind();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!(DynamicSecurity.PrvWrite && DynamicSecurity.PrvCreate && DynamicSecurity.PrvDelete))
        {
            Response.Redirect("~/MessagePages/_PrivilegeError.aspx?error=Entity PrvCreate,PrvDelete,PrvWrite");
        }
        if (!RefleX.IsAjxPostback)
        {
            SetTypeItems();
            if (!string.IsNullOrEmpty(QueryHelper.GetString("ObjectId")))
            {
                var ef = new EntityFactory();
                var eo = ef.GetEntityFromObjectId(QueryHelper.GetInteger("ObjectId"));
                hdnentityid.Value = eo.EntityId.ToString();

                var eaf = new EntityAttributeFactory();
                eaf.GetEntityAttributesByObjectId(QueryHelper.GetInteger("ObjectId"));
            }
            QScript("btnNew.click();");
        }
    }

    private void TypeStatus(string type, bool isNew)
    {
        switch ((Types)StringEnum.Parse(typeof(Types), type))
        {
            case Types.Nvarchar:
                {
                    picklist.Hide();
                    bitlist.Hide();
                    DefaultValue.Hide();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Show();
                    MaxLength.Show();
                    Precision.Hide();
                    CaseMode.Show();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.Picklist:
                {
                    picklist.Show();
                    bitlist.Hide();
                    DefaultValue.Show();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Hide();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.Bit:
                {
                    picklist.Hide();
                    bitlist.Show();
                    DefaultValue.Show();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Hide();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.Integer:
                {
                    MinValue.SetValue(Int32.MinValue);
                    MaxValue.SetValue(Int32.MaxValue);

                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    MinValue.Show();
                    MaxValue.Show();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.Float:
                {
                    if (isNew)
                    {
                        Precision.SetValue(2);
                        MinValue.SetValue(0);
                        MaxValue.SetValue(10000000);
                        QScript(string.Format("MinValue.decimalPrecision = {0};", Convert.ToInt32(Precision.Value)));
                        QScript(string.Format("MaxValue.decimalPrecision = {0};", Convert.ToInt32(Precision.Value)));
                        IsLoggable.SetValue(false);
                    }
                    Format.Hide();
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    Precision.Show();
                    MinValue.Show();
                    MaxValue.Show();
                    MaxLength.Hide();
                    CaseMode.Hide();

                    break;
                }
            case Types.Decimal:
                {
                    if (isNew)
                    {
                        Precision.SetValue(2);
                        QScript(string.Format("MinValue.decimalPrecision = {0};", Convert.ToInt32(Precision.Value)));
                        QScript(string.Format("MaxValue.decimalPrecision = {0};", Convert.ToInt32(Precision.Value)));
                        MinValue.SetValue(0);
                        MaxValue.SetValue(10000000);
                        IsLoggable.SetValue(false);
                    }
                    Format.Hide();
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    Precision.Show();
                    MinValue.Show();
                    MaxValue.Show();
                    MaxLength.Hide();
                    CaseMode.Hide();

                    break;
                }
            case Types.Uom:
            case Types.Money:
                {
                    if (isNew)
                    {
                        Precision.SetValue(2);
                        MinValue.SetValue(0);
                        MaxValue.SetValue(10000000);
                        QScript(string.Format("MinValue.decimalPrecision = {0};", Convert.ToInt32(Precision.Value)));
                        QScript(string.Format("MaxValue.decimalPrecision = {0};", Convert.ToInt32(Precision.Value)));
                        IsLoggable.SetValue(false);
                    }
                    Format.Hide();
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    Precision.Show();
                    MinValue.Show();
                    MaxValue.Show();
                    MaxLength.Hide();
                    CaseMode.Hide();

                    break;
                }
            case Types.NText:
                {
                    if (isNew)
                    {
                        MaxLength.SetValue(2000);
                        IsLoggable.SetValue(false);
                    }
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Show();
                    //Format.Hide();
                    MaxLength.Show();
                    Precision.Hide();
                    CaseMode.Hide();

                    break;
                }
            case Types.DateTime:
                {
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Show();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Show();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.Html:
                {
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Hide();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.File:
                {
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Show();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }
            case Types.ghost:
            case Types.UniqueIdentifier:
                {
                    bitlist.Hide();
                    picklist.Hide();
                    DefaultValue.Hide();
                    MinValue.Hide();
                    MaxValue.Hide();
                    Format.Hide();
                    MaxLength.Hide();
                    Precision.Hide();
                    CaseMode.Hide();
                    if (isNew)
                    {
                        IsLoggable.SetValue(false);
                    }
                    break;
                }

        }
    }

    protected void StoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var eaf = new EntityAttributeFactory();
        var eo = eaf.GetEntityAttributesByObjectId(QueryHelper.GetInteger("ObjectId"));

        _grdsma.DataSource = eo;
        _grdsma.DataBind();
    }

    public class PickListItem
    {
        public string PickValue { get; set; }
        public string PickLabel { get; set; }
    }

    protected void PicklistDefault(object sender, AjaxEventArgs e)
    {
        DefaultValue.ClearItems();
        if (picklist.AllRows != null)
        {
            foreach (var t in picklist.AllRows)
            {
                DefaultValue.AddItem(new ListItem(t.PickValue.ToString(), t.PickLabel.ToString()));
            }
        }

    }

    protected void PicklistStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var degerler = ((RowSelectionModel)_grdsma.SelectionModel[0]);
        var tmpD = DefaultValue.Value;
        DefaultValue.ClearItems();
        var plf = new PicklistFactory();

        var pItems = new List<PickListItem>();

        picklist.DataSource = pItems;
        if (!string.IsNullOrEmpty(hdnattributeid.Value))
        {
            var lst = plf.GetPicklistValueList(new Guid(hdnattributeid.Value));

            foreach (var t in lst)
            {
                var i = new PickListItem { PickLabel = t.Label, PickValue = t.Value.ToString() };
                pItems.Add(i);
                DefaultValue.AddItem(new ListItem(t.Value.ToString(), t.Label));
            }
            picklist.DataSource = pItems;
        }

        if (degerler.SelectedRows != null)
            DefaultValue.SetValue(degerler.SelectedRows["DefaultValue"]);
        else
        {
            DefaultValue.SetValue(tmpD);
        }

        picklist.DataBind();
    }

    protected void RowSelectOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {

            var degerler = ((RowSelectionModel)_grdsma.SelectionModel[0]);
            DisplayName.SetIValue(degerler.SelectedRows["Label"]);
            Name.SetIValue(degerler.SelectedRows["Name"]);
            Level.SetIValue(degerler.SelectedRows["RequirementLevel"]);
            txtDescription.SetIValue(degerler.SelectedRows["Description"]);
            hdnattributeid.SetIValue(degerler.SelectedRows["AttributeId"]);
            var tval = degerler.SelectedRows["AttributeTypeId"] == "00000000-0000-0000-0000-000000000016"
                           ? StringEnum.GetStringValue(Types.DateTime)
                           : degerler.SelectedRows["AttributeTypeId"];
            Type.SetIValue(tval);
            MaxLength.SetIValue(ValidationHelper.GetDecimal(degerler.SelectedRows["MaxLength"], 0));
            Precision.SetIValue(ValidationHelper.GetDecimal(degerler.SelectedRows["Precision"], 0));
            MinValue.SetIValue(ValidationHelper.GetDecimal(degerler.SelectedRows["MinValue"], 0));
            MaxValue.SetIValue(ValidationHelper.GetDecimal(degerler.SelectedRows["MaxValue"], 0));
            IsLoggable.SetIValue(ValidationHelper.GetBoolean(degerler.SelectedRows["IsLoggable"]));
            CaseMode.SetIValue(degerler.SelectedRows["CaseModeValue"]);
            AllowKeys.SetIValue(degerler.SelectedRows["AllowKeys"]);
            if (degerler.SelectedRows["CaseModeValue"].ToString() == ECaseMode.AllowKeys.GetHashCode().ToString())
                AllowKeys.Show();
            else
                AllowKeys.Hide();
            Name.SetReadOnly(true);
            DisplayName.SetReadOnly(true);
            Type.SetReadOnly(true);
            TypeStatus(tval, false);
            FormatItems(tval);
            if (degerler.SelectedRows["DefaultValue"] != null)
                DefaultValue.SetIValue(degerler.SelectedRows["DefaultValue"]);
            if (degerler.SelectedRows["FormatType"] != null)
                Format.SetValue(degerler.SelectedRows["FormatType"]);


        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }

    public class BitListItem
    {
        public string BitValue { get; set; }
        public string BitLabel { get; set; }
    }

    protected void BitStoreOnRefreshData(object sender, AjaxEventArgs e)
    {
        var degerler = ((RowSelectionModel)_grdsma.SelectionModel[0]);
        var tmpD = DefaultValue.Value;
        DefaultValue.ClearItems();
        var pItems = new List<BitListItem>
                         {
                             new BitListItem {BitLabel = "No", BitValue = "0"},
                             new BitListItem {BitLabel = "Yes", BitValue = "1"}
                         };
        var plf = new PicklistFactory();
        bitlist.DataSource = pItems;

        if (!string.IsNullOrEmpty(hdnattributeid.Value))
        {
            pItems.Clear();
            var lst = plf.GetPicklistValueList(new Guid(hdnattributeid.Value));

            foreach (var t in lst)
            {
                var i = new BitListItem { BitLabel = t.Label, BitValue = t.Value.ToString() };
                pItems.Add(i);
                DefaultValue.AddItem(new ListItem(t.Value.ToString(), t.Label));
            }
            bitlist.DataSource = pItems;
        }
        else
        {
            DefaultValue.AddItem(new ListItem("0", "No"));
            DefaultValue.AddItem(new ListItem("1", "Yes"));
        }

        if (degerler.SelectedRows != null)
            DefaultValue.SetValue(degerler.SelectedRows["DefaultValue"]);
        else
        {
            DefaultValue.SetValue(tmpD);
        }

        bitlist.DataBind();
    }

    private void FormatItems(string type)
    {
        DefaultValue.ClearItems();
        switch ((Types)StringEnum.Parse(typeof(Types), type))
        {
            case Types.Nvarchar:
                {
                    Format.ClearItems();
                    Format.AddItem(new ListItem("1", "Text"));
                    Format.AddItem(new ListItem("2", "E-Mail"));
                    Format.AddItem(new ListItem("3", "Text Area"));
                    Format.AddItem(new ListItem("4", "URL"));
                    Format.AddItem(new ListItem("7", "Tele Phone"));
                    Format.AddItem(new ListItem("10", "Password"));
                    QScript("Format.setValue(1);");
                    break;
                }
            case Types.Picklist:
                {
                    picklist.Reload();
                    break;
                }
            case Types.Bit:
                {
                    bitlist.Reload();
                    break;
                }
            case Types.Integer:
                {
                    break;
                }
            case Types.Float:
                {
                    break;
                }
            case Types.Decimal:
                {
                    break;
                }
            case Types.Uom:
            case Types.Money:
                {
                    break;
                }
            case Types.NText:
                {
                    break;
                }
            case Types.DateTime:
                {
                    Format.ClearItems();
                    Format.AddItem(new ListItem("5", "Date Only"));
                    Format.AddItem(new ListItem("6", "Date and Time"));
                    Format.AddItem(new ListItem("11", "None Utc Date"));

                    QScript("Format.setValue(5);");

                    DefaultValue.AddItem(new ListItem("0", "Boş"));
                    DefaultValue.AddItem(new ListItem("1", "Bugün"));
                    QScript("DefaultValue.setValue(0);");
                    break;
                }
            case Types.Html:
                {
                    break;
                }
            case Types.File:
                {
                    Format.ClearItems();
                    Format.AddItem(new ListItem("12", "Db"));
                    Format.AddItem(new ListItem("13", "Disk"));
                    QScript("Format.setValue(12);");

                    break;
                }
        }

    }

    protected void TypeOnChangeEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(hdnattributeid.Value))
            {
                FormatItems(Type.Value);
                TypeStatus(Type.Value, true);
            }
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }

    protected void NewOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            bitlist.Reload();
            picklist.Reload();
            DefaultValue.ClearItems();
            hdnattributeid.Clear();
            Name.Clear();
            DisplayName.Clear();
            Level.SetValue("0");
            Format.SetValue("1");
            Type.SetValue(StringEnum.GetStringValue(Types.Nvarchar));
            MaxLength.SetValue(100);
            Name.SetReadOnly(false);
            Type.SetReadOnly(false);
            FormatItems(StringEnum.GetStringValue(Types.Nvarchar));
            TypeStatus(StringEnum.GetStringValue(Types.Nvarchar), true);
            CaseMode.SetValue("0");
            AllowKeys.Clear();
            DisplayName.SetReadOnly(false);
            txtDescription.Clear();
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }

    protected void AddOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            switch ((Types)StringEnum.Parse(typeof(Types), Type.Value))
            {
                case Types.Nvarchar:
                    {
                        var typ = new Nvarchar
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Name = Name.Value,
                            Format = (EFormat)Enum.Parse(typeof(EFormat), Format.Value),
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            MaxLength = ValidationHelper.GetDouble(MaxLength.Value, 0),
                            CaseMode = (ECaseMode)Enum.Parse(typeof(ECaseMode), CaseMode.Value),
                            Description = txtDescription.Value,
                            AllowKeys = ValidationHelper.GetGuid(AllowKeys.Value),
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetNVarchar(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Picklist:
                    {
                        var pv = new List<Pickvalues>();
                        foreach (var t in picklist.AllRows)
                        {
                            var i = new Pickvalues { Value = ValidationHelper.GetString(t.PickValue), Text = ValidationHelper.GetString(t.PickLabel) };
                            pv.Add(i);
                        }

                        var typ = new Coretech.Crm.Objects.Crm.Attributes.Picklist
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Name = Name.Value,
                            Items = pv,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            DefaultValue = DefaultValue.Value,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetPiclist(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Bit:
                    {
                        var pv = new List<Bitvalues>();
                        foreach (var t in bitlist.AllRows)
                        {
                            var i = new Bitvalues { Value = t.BitValue, Text = t.BitLabel };
                            pv.Add(i);
                        }

                        var typ = new Bit
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            DefaultValue = DefaultValue.Value,
                            Name = Name.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Items = pv,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetBit(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Integer:
                    {
                        var typ = new Integer
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            MinValue = ValidationHelper.GetInteger(MinValue.Value, 0),
                            MaxValue = ValidationHelper.GetInteger(MaxValue.Value, 0),
                            Name = Name.Value,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetInteger(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Float:
                    {
                        var typ = new Float
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            MinValue = ValidationHelper.GetDouble(MinValue.Value, 0),
                            MaxValue = ValidationHelper.GetDouble(MaxValue.Value, 0),
                            Name = Name.Value,
                            Precision = ValidationHelper.GetDouble(Precision.Value, 0),
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetFloat(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Decimal:
                    {
                        var typ = new Coretech.Crm.Objects.Crm.Attributes.Decimal
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            MinValue = ValidationHelper.GetDouble(MinValue.Value, 0),
                            MaxValue = ValidationHelper.GetDouble(MaxValue.Value, 0),
                            Name = Name.Value,
                            Precision = ValidationHelper.GetDouble(Precision.Value, 0),
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetDecimal(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Uom:
                    {
                        var typ = new Uom
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            MinValue = ValidationHelper.GetDouble(MinValue.Value, 0),
                            MaxValue = ValidationHelper.GetDouble(MaxValue.Value, 0),
                            Name = Name.Value,
                            Precision = ValidationHelper.GetDouble(Precision.Value, 0),
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetUom(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Money:
                    {
                        var typ = new Money
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            MinValue = ValidationHelper.GetDouble(MinValue.Value, 0),
                            MaxValue = ValidationHelper.GetDouble(MaxValue.Value, 0),
                            Name = Name.Value,
                            Precision = ValidationHelper.GetDouble(Precision.Value, 0),
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetMoney(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.NText:
                    {
                        var typ = new Ntext
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Name = Name.Value,
                            MaxLength = ValidationHelper.GetDouble(MaxLength.Value, 0),
                            Description = txtDescription.Value,
                            Format = (EFormat)Enum.Parse(typeof(EFormat), Format.Value),
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetNtext(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.DateTime:
                    {
                        var typ = new Datetime
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            DefaultValue = DefaultValue.Value,
                            Format = (EFormatD)Enum.Parse(typeof(EFormatD), Format.Value),
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Name = Name.Value,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetDatetime(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.Html:
                    {
                        var typ = new Html
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Name = Name.Value,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetHtml(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.File:
                    {
                        var typ = new File
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Name = Name.Value,
                            Description = txtDescription.Value,
                            Format = (EFormatF)Enum.Parse(typeof(EFormatF), Format.Value),
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.SetFile(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.UniqueIdentifier:
                    {
                        var typ = new UniqueIdentifier
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Name = Name.Value,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.setUniqueIdentifier(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
                case Types.ghost:
                    {
                        var typ = new ghost
                        {
                            AttributeId = ValidationHelper.GetGuid(hdnattributeid.Value),
                            ObjectId = QueryHelper.GetInteger("ObjectId"),
                            EntityId = hdnentityid.Value,
                            Type = Type.Value,
                            DisplayName = DisplayName.Value,
                            Level = (ELevel)Enum.Parse(typeof(ELevel), Level.Value),
                            Name = Name.Value,
                            Description = txtDescription.Value,
                            IsLoggable = ValidationHelper.GetBoolean(IsLoggable.Value)
                        };
                        var atr = new AttributeAdd();
                        var atrid = atr.setGhost(typ);
                        hdnattributeid.Value = atrid.ToString();
                        break;
                    }
            }
            _grdsma.Reload();
            bitlist.Reload();
            picklist.Reload();
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }

    protected void DeleteOnEvent(object sender, AjaxEventArgs e)
    {
        try
        {
            if (!string.IsNullOrEmpty(hdnattributeid.Value))
            {
                var atr = new AttributeAdd();
                atr.DeleteAttribute(new Guid(hdnattributeid.Value), new Guid(hdnentityid.Value));
                NewOnEvent(sender, e);
                _grdsma.Reload();
            }
        }
        catch (Exception ex)
        {
            e.Success = false;
            e.Message = ex.Message;
        }
    }
}