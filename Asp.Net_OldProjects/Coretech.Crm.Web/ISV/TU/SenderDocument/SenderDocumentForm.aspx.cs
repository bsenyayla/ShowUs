using Coretech.Crm.Factory;
using Coretech.Crm.Factory.Network;
using Coretech.Crm.PluginData;
using Coretech.Crm.Utility.Util;
using FileStorage.Factory;
using FileStorage.Interface;
using FileStorage.Manager;
using RefleXFrameWork;
using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Web;
using System.Web.UI;
using TuFactory.CustAccount.Business.Service;
using TuFactory.CustAccount.Object;
using TuFactory.Domain.Company;

namespace Coretech.Crm.Web.ISV.TU.SenderDocument
{
    public partial class SenderDocumentForm : Page
    {
        private string recid = string.Empty;

        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                string path = string.Empty;
                IFileService fmanager = null;
                IFileFactory fileFactory = new FileFactory();
                fmanager = fileFactory.Creator(App.Params.CurrentUser.CompanyId.ToString().ToLower());
                recid = QueryHelper.GetString("recid");

                SenderDocumentService documentService = new SenderDocumentService();

                path = documentService.GetCorporatedDocumentPath(ValidationHelper.GetGuid(recid));

                try
                {
                    Response.Buffer = true;
                    Response.Clear();
                    var isTurkey = App.Params.CurrentUser.CompanyId.ToString().ToLower() == Company.TurkeyCompanyId;

                    if (!isTurkey)
                    {
                        //fmanager = new AzureFileManager();

                        var fileName = "";
                        var ext = "";
                        var splitArr = path.Split('/');

                        if (splitArr != null && splitArr.Length > 0)
                        {
                            fileName = splitArr[splitArr.Length - 1];
                            var splitExt = fileName.Split('.');

                            if (splitExt != null && splitExt.Length > 0)
                            {
                                ext = "." + splitExt[1];
                                fileName = fileName.Replace(ext, "");
                            }
                        }

                        #region //SB Old Codes

                        //string localSavePath = Path.Combine(Server.MapPath("~"), "Download");
                        //localSavePath = Path.Combine(localSavePath, fileName);

                        //fmanager.DownloadFile(path, localSavePath, fileName);
                        //path = localSavePath;

                        #endregion

                        var byteArray = fmanager.GetFileStreamByteArray(path.Replace("/" + fileName + ext, ""), fileName, ext);

                        Response.Clear();
                        Response.Buffer = true;
                        Response.AddHeader("content-disposition", String.Format("attachment;filename={0}", fileName + ext));
                        Response.ContentType = GetContentType(ext.ToLower());
                        Response.BinaryWrite(byteArray);
                        Response.End();
                    }
                    else if (isTurkey && path.StartsWith("\\"))
                    {
                        using (var impersonator = new Impersonator())
                        {
                            SenderDocumentParameters parameters = new SenderDocumentParameters().GetParameter();
                            impersonator.Impersonate(parameters.ImporterUser, parameters.ImporterDomain, parameters.ImporterPwd, LogonType.LOGON32_LOGON_NEW_CREDENTIALS, LogonProvider.LOGON32_PROVIDER_DEFAULT);

                            var fileInfo = new FileInfo(path);

                            if (!fileInfo.Exists)
                            {
                                throw new FileNotFoundException("Dosya Bulunamadı.", path);
                            }

                            string mimeType = MimeMapping.GetMimeMapping(path);

                            if (mimeType.Contains("image"))
                            {

                                System.Drawing.Image img = System.Drawing.Image.FromFile(fileInfo.FullName);
                                System.Drawing.Image imgNew = resizeImage(img, new Size(800, 600));
                                byte[] b = ImageToByteArray(imgNew);

                                Response.Buffer = true;
                                Response.Clear();
                                Response.ContentType = mimeType;
                                Response.AddHeader("content-disposition", "filename=" + Guid.NewGuid() + fileInfo.Extension);
                                //Response.WriteFile(fileInfo.FullName);
                                Response.BinaryWrite(b);
                                Response.Flush();
                                Response.Close();

                            }
                            else
                            {
                                Response.Buffer = true;
                                Response.Clear();
                                Response.ContentType = mimeType;
                                Response.AddHeader("content-disposition", "filename=" + Guid.NewGuid() + fileInfo.Extension);
                                Response.WriteFile(fileInfo.FullName);
                                Response.Flush();
                                Response.Close();
                            }

                        }
                    }
                    else
                    {
                        var fileInfo = new FileInfo(path);

                        if (!fileInfo.Exists)
                        {
                            throw new FileNotFoundException("Dosya Bulunamadı.", path);
                        }

                        string mimeType = MimeMapping.GetMimeMapping(path);

                        Response.Buffer = true;
                        Response.Clear();
                        Response.ContentType = mimeType;
                        Response.AddHeader("content-disposition", "filename=" + Guid.NewGuid() + fileInfo.Extension);
                        Response.WriteFile(fileInfo.FullName);
                        Response.Flush();
                        Response.Close();

                    }
                }
                catch (Exception ex)
                {
                    LogUtil.WriteException(ex, "Coretech.Crm.Web.ISV.TU.SenderDocument.SenderDocumentForm");

                    var m = new MessageBox { Width = 400, Height = 150 };
                    m.Show("", "İşlem sırasında beklenmedik bir hata oluştu.");
                    return;
                }
            }
        }

        private string GetContentType(string FileExtension)
        {
            Dictionary<string, string> d = new Dictionary<string, string>();
            //Images'
            d.Add(".jpeg", "image/jpeg");
            d.Add(".jpg", "image/jpeg");
            d.Add(".png", "image/png");

            //Documents'
            d.Add(".doc", "application/msword");
            d.Add(".docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document");
            d.Add(".pdf", "application/pdf");

            d.Add(".eps", "application/postscript");
            d.Add(".gif", "image/gif");
            d.Add(".tif", "image/tiff");
            d.Add(".tiff", "image/tiff");
            d.Add(".bmp", "image/bmp");
            d.Add(".raw", "image/RAW");
            d.Add(".pict", "application/octet-stream");
            d.Add(".xps", "application/oxps");
            return d[FileExtension];
        }

        private static System.Drawing.Image resizeImage(System.Drawing.Image imgToResize, Size size)
        {

            //Get the image current width
            int sourceWidth = imgToResize.Width;
            //Get the image current height

            int sourceHeight = imgToResize.Height;



            float nPercent = 0;
            float nPercentW = 0;
            float nPercentH = 0;

            //Calulate  width with new desired size
            nPercentW = ((float)size.Width / (float)sourceWidth);

            //Calculate height with new desired size
            nPercentH = ((float)size.Height / (float)sourceHeight);



            if (nPercentH < nPercentW)
                nPercent = nPercentH;
            else
                nPercent = nPercentW;

            //New Width
            int destWidth = (int)(sourceWidth * nPercent);

            //New Height
            int destHeight = (int)(sourceHeight * nPercent);



            Bitmap b = new Bitmap(destWidth, destHeight);
            Graphics g = Graphics.FromImage((System.Drawing.Image)b);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;

            // Draw image with new width and height

            g.DrawImage(imgToResize, 0, 0, destWidth, destHeight);

            g.Dispose();

            return (System.Drawing.Image)b;

        }

        public byte[] ImageToByteArray(System.Drawing.Image imageIn)
        {
            using (var ms = new MemoryStream())
            {
                imageIn.Save(ms, ImageFormat.Png);
                return ms.ToArray();
            }
        }


    }
}