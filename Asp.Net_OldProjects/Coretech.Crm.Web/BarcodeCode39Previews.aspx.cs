using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BarcodeLib.Barcode;
using BarcodeLib.Barcode.WinForms;
using System.IO;
using System.Drawing;

namespace Coretech.Crm.Web
{
    public partial class BarcodeCode39Previews : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string keyValue = Request.QueryString["keyValue"];
            keyValue = "1111111111111";
            if (!String.IsNullOrEmpty(keyValue) )
            {
                BarcodeLib.Barcode.Linear code39 = new BarcodeLib.Barcode.Linear();
                code39.Type = BarcodeType.CODE39;
                code39.Data = keyValue;
                code39.ImageFormat = System.Drawing.Imaging.ImageFormat.Jpeg;
                code39.BarColor = Color.Black;
                code39.BarWidth = 2;
                code39.ShowText = false;
                

                //code39.drawBarcode("C:/code39-winforms.jpeg");
                byte[] barcodeInBytes = code39.drawBarcodeAsBytes();
                Response.BinaryWrite(barcodeInBytes);
                //pictureBox1.Image = byteArrayToImage(barcodeInBytes);
            }
        }


        /*
        public System.Drawing.Image byteArrayToImage(byte[] bytesArr)
        {
            using (MemoryStream memstr = new MemoryStream(bytesArr))
            {
                Image img = Image.FromStream(memstr);
                return img;
            }
        }
        */
    }
}