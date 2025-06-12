using Coretech.Crm.Objects.Crm.Form;
using Coretech.Crm.Utility.Util;
using RefleXFrameWork;
using System;

public partial class Sender_VendorSenderForm_MaskedDateControl_MaskedDate : System.Web.UI.UserControl
{
    [ClientConfig(ItemTyp.String)]
    public string TextValue
    {
        get
        {
            return ItemTextField.Value.ToString();
        }
        set
        {
            ItemTextField.Value = ValidationHelper.GetDate(value);
        }
    }
    [ClientConfig(ItemTyp.String)]
    public DateTime? RealValue
    {
        get
        {
            return ItemValueField.Value;
        }
        set
        {
            ItemValueField.Value = value;
        }
    }

    public string UniqueName
    {
        get
        {
            return ItemTextField.UniqueName;
        }
        set
        {
            ItemTextField.UniqueName = value;
        }
    }
    public string ObjectId
    {
        get
        {
            return ItemTextField.ObjectId;
        }
        set
        {
            ItemTextField.ObjectId = value;
        }
    }

    public string ID
    {
        set
        {
            ItemTextField.ID = value + "_" + ItemTextField.ID;
            ItemValueField.ID = value + "_" + ItemValueField.ID;
        }
    }

    public EParentType ParentType
    {
        set
        {
            ItemTextField.ParentType = value;
        }
        get
        {
            return ItemTextField.ParentType;
        }
    }

    public RLevel RequirementLevel { get { return ItemTextField.RequirementLevel; } set { ItemTextField.RequirementLevel = value; ItemValueField.RequirementLevel = value; } }
    public FormEntityAttribute FeAttribute { get; set; }
    protected void Page_Load(object sender, EventArgs e)
    {
    }
}