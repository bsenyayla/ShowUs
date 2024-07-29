using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using Newtonsoft.Json;
using RazorEngine;
using RazorEngine.Templating;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels.MailQueue;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Text;

namespace CRCAPI.Services
{
    [ScopedDependency(ServiceType = typeof(IMailQueueService))]
    public class MailQueueService : IMailQueueService
    {
        private readonly ILogCoreMan logCoreMan;
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IAppSettingService appSettingService;
        private readonly IRedisCoreManager redisCoreManager;

        public MailQueueService(IUnitOfWork<CrcmsDbContext> unitOfWork, ILogCoreMan logCoreMan, IAppSettingService appSettingService, IRedisCoreManager redisCoreManager)
        {
            this.logCoreMan = logCoreMan;
            this.unitOfWork = unitOfWork;
            this.appSettingService = appSettingService;
            this.redisCoreManager = redisCoreManager;
        }

        private T GetModel<T>(string parameters)
        {
            T model = default(T);

            model = JsonConvert.DeserializeObject<T>(parameters);

            return model;
        }

        private MailQueueLog RenderMailQueue(string parameters, MailQueue mailQueue)
        {
            var appSetting = appSettingService.AppSetting();
            var model = GetModel<MailQueueParameterModel>(parameters);
            MailQueueType mailQueueType = (MailQueueType)Enum.Parse(typeof(MailQueueType), mailQueue.EmailTypeId.ToString());

            List<int> oldUploadIds = new List<int>();

            if (mailQueueType == MailQueueType.Reception && model.Reception != null && model.Reception.ReceptionItem != null)
            {
                foreach (var item in model.Reception.ReceptionItem)
                {
                    if (item.IsHaveRequestValues.ContainsKey(appSetting.JSContent.DefaultLanguage))
                    {
                        item.IsHaveRequestValue = item.IsHaveRequestValues[appSetting.JSContent.DefaultLanguage];
                    }
                    if (item.StandStatusIdValues.ContainsKey(appSetting.JSContent.DefaultLanguage))
                    {
                        item.StandStatusIdValue = item.StandStatusIdValues[appSetting.JSContent.DefaultLanguage];
                    }
                    if (item.IsErsValues.ContainsKey(appSetting.JSContent.DefaultLanguage))
                    {
                        item.IsErsValue = item.IsErsValues[appSetting.JSContent.DefaultLanguage];
                    }
                }
            }

            if (mailQueueType == MailQueueType.BaseOfQuotation && model.BaseOfQuotation != null)
            {
                if (model.BaseOfQuotation.DeliveryTerms.ContainsKey(appSetting.JSContent.DefaultLanguage))
                {
                    model.BaseOfQuotation.DeliveryTerm = model.BaseOfQuotation.DeliveryTerms[appSetting.JSContent.DefaultLanguage];
                }

                var oldMailQueueList = unitOfWork.GetRepository<MailQueue>()
                                                .List(x => x.EmailTypeId == mailQueue.EmailTypeId &&
                                                            x.Parameters.Contains("\"DocumentNumber\":\"" + model.BaseOfQuotation.DocumentNumber + "\"") &&
                                                            x.MailQueueId != mailQueue.MailQueueId &&
                                                            x.CreateDate < mailQueue.CreateDate)
                                                .OrderByDescending(x => x.CreateDate)
                                                .ToList();
                if (oldMailQueueList != null && oldMailQueueList.Any())
                {
                    //model.Subject = "{Quotation_Update_6910}";
                    foreach (var oldMailQueue in oldMailQueueList)
                    {
                        var oldModel = GetModel<MailQueueParameterModel>(oldMailQueue.Parameters);
                        if (oldModel != null && oldModel.UploadIds != null && oldModel.UploadIds.Any())
                        {
                            oldUploadIds.AddRange(oldModel.UploadIds);
                        }
                    }
                }
            }

            var mailQueueLogUploadIds = "";

            if (model.UploadIds != null && model.UploadIds.Any())
            {
                model.UploadList = new List<UploadItemModel>();

                var uploadList = unitOfWork
                                        .GetRepository<Upload>()
                                        .List()
                                        .Where(x => model.UploadIds.Contains(x.UploadId))
                                        .ToList();

                decimal sizeMBSum = uploadList.Sum(x => x.SizeKB) / 1024;
                bool isAttached = (appSetting.Smtp.SendAttachmentStatus &&
                                    sizeMBSum < appSetting.Smtp.AttachmentMaxFileSizeMbget)
                                    ? true
                                    : false;

                foreach (var item in uploadList)
                {
                    var oldUploadStatus = oldUploadIds.Contains(item.UploadId);

                    UploadItemModel uploadItem = new UploadItemModel
                    {
                        UploadId = item.UploadId,
                        Name = item.Name,
                        CreatedDate = item.DateUpload.Value.ToString("dd.MM.yyyy HH:mm"),
                        UserName = item.UserName,
                        SizeMB = (item.SizeKB / 1024).ToString("0.00"),
                        Url = $"{appSetting.ProjectUrl.WorkOrderHistoryPath}/Home/DownloadFile?uploadId={item.UploadId}",
                        IsAttached = isAttached
                            && !oldUploadStatus//Düzenle dedikten sonra gönderilen mailde bir önce gönderilen maildeki teklif eklenmemelidir. Güncel teklif bilgisi eklenmelidir. https://trello.com/c/PlYM3ENr/687-teklif-g%C3%BCncellendi-maili
                    };
                    model.UploadList.Add(uploadItem);
                }

                mailQueueLogUploadIds = string.Join(',', model.UploadList.Where(x => x.IsAttached).Select(s => s.UploadId));
                model.UploadWOHistoryUrl = $"{appSetting.ProjectUrl.WorkOrderHistoryPath}/Home/RebuildHistory?DocumentId={uploadList.FirstOrDefault().DocumentId}";
            }

            //subject
            var subject = model.Subject;

            //Email test flag
            if (!string.IsNullOrEmpty(appSetting?.Smtp?.Environment) && appSetting.Smtp.Environment.ToLower() != "prod")
            {
                subject = $"[{appSetting.Smtp.Environment.ToUpper()}] " + subject;
            }

            string templateRoot = System.IO.Directory.GetParent(System.IO.Directory.GetCurrentDirectory()) + "\\_cdoms_email_template\\";

            //layout
            string layoutFile = $"{templateRoot}_Layout.cshtml";
            if (!System.IO.File.Exists(layoutFile))
            {
                throw new BusinessException("Template Layout File Not Found", ErrorCode.TemplateFileNotFound);
            }
            string layout = System.IO.File.ReadAllText(layoutFile);

            //template
            string templateFile = $"{templateRoot}{mailQueueType.ToString()}.cshtml";
            if (!System.IO.File.Exists(templateFile))
            {
                throw new BusinessException("Template File Not Found", ErrorCode.TemplateFileNotFound);
            }
            string template = System.IO.File.ReadAllText(templateFile);

            template = layout.Replace("{BODY}", template);

            //html
            var html = "";
            if (Engine.Razor.IsTemplateCached(mailQueueType.ToString(), typeof(MailQueueParameterModel)))
            {
                html = Engine.Razor.Run(mailQueueType.ToString(), typeof(MailQueueParameterModel), model);
            }
            else
            {
                html = Engine.Razor.RunCompile(template, mailQueueType.ToString(), typeof(MailQueueParameterModel), model);
            }

            if (string.IsNullOrEmpty(html))
            {
                throw new Exception("html is empty");
            }

            var defaultLanguage = appSetting.JSContent.DefaultLanguage;
            var localizationItems = model.LocalizationItems
                                                                .Where(x => x.Language == defaultLanguage || string.IsNullOrEmpty(x.Language))
                                                                .ToList();
            foreach (var item in localizationItems)
            {
                string key = "{" + item.Key + "}";
                string value = item.Value;

                if (subject.Contains(key))
                {
                    subject = subject.Replace(key, value);
                }
                if (html.Contains(key))
                {
                    html = html.Replace(key, value);
                }
            }

            MailQueueLog mailQueueLog = new MailQueueLog
            {
                Subject = subject,
                Body = html,
                To = mailQueue.To,
                Cc = mailQueue.Cc,
                CreateDate = mailQueue.CreateDate,
                AttachmentCount = model.UploadIds != null ? model.UploadIds.Count() : 0,//TODO: MailQueue2.AttachmentCount
                UploadIds = mailQueueLogUploadIds,
                Smtp = "",
                SmtpPort = 0,
                From = "",
                Priority = 0,
                IsBodyHtml = true,
            };
            return mailQueueLog;
        }

        private string CleanBlackEmail(List<string> toList, List<string> whiteList)
        {
            var ciTr = new CultureInfo("tr");
            var ciEn = new CultureInfo("en");

            List<string> toWhite = toList
                                    .Where(x => whiteList.Contains(x.ToLower(ciTr)) || whiteList.Contains(x.ToLower(ciEn)))
                                    .Select(x => x.ToLower(ciEn))
                                    .ToList();

            return string.Join(",", toWhite);
        }

        private string EmailFixTurkishChar(string email)
        {
            var response = String.Join("", email.Normalize(NormalizationForm.FormD).Where(c => char.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark));

            return response;
        }

        private MailQueueLog SendSmtp(MailQueueLog mailQueueLog)
        {
            mailQueueLog.Error = "";
            var smtpConfig = appSettingService.AppSetting().Smtp;

            if (smtpConfig == null)
                return mailQueueLog;

            if (!smtpConfig.SendStatus)
                return mailQueueLog;

            if (smtpConfig.SendOnlyWhiteList)
            {
                var whiteList = smtpConfig.WhiteListList;

                if (!string.IsNullOrEmpty(mailQueueLog.To))
                    mailQueueLog.To = CleanBlackEmail(mailQueueLog.To.Split(',').ToList(), whiteList);

                if (!string.IsNullOrEmpty(mailQueueLog.Cc))
                    mailQueueLog.Cc = CleanBlackEmail(mailQueueLog.Cc.Split(',').ToList(), whiteList);

                if (!string.IsNullOrEmpty(mailQueueLog.Bcc))
                    mailQueueLog.Bcc = CleanBlackEmail(mailQueueLog.Bcc.Split(',').ToList(), whiteList);
            }

            var msg = new MailMessage { From = new MailAddress(smtpConfig.From) };

            if (!string.IsNullOrEmpty(mailQueueLog.To))
            {
                var toList = mailQueueLog.To.Split(",");
                foreach (var item in toList)
                {
                    msg.To.Add(item.Trim());
                }
            }
            if (!string.IsNullOrEmpty(mailQueueLog.Cc))
            {
                var ccList = mailQueueLog.Cc.Split(",");
                foreach (var item in ccList)
                {
                    msg.CC.Add(item.Trim());
                }
            }
            if (!string.IsNullOrEmpty(mailQueueLog.Bcc))
            {
                var bccList = mailQueueLog.Bcc.Split(",");
                foreach (var item in bccList)
                {
                    msg.Bcc.Add(item.Trim());
                }
            }

            msg.Subject = mailQueueLog.Subject;

            msg.Body = mailQueueLog.Body;
            msg.Priority = MailPriority.Normal;
            msg.IsBodyHtml = true;

            if (!string.IsNullOrEmpty(mailQueueLog.UploadIds))
            {
                List<int> uploadIds = mailQueueLog.UploadIds.Split(',').Select(x => int.Parse(x.Trim())).ToList();

                var uploadList = unitOfWork
                                        .GetRepository<Upload>()
                                        .List()
                                        .Where(x => uploadIds.Contains(x.UploadId))
                                        .ToList();

                foreach (var item in uploadList)
                {
                    if (System.IO.File.Exists(item.Path))
                    {
                        //msg.Attachments.Add(new Attachment(item.Path));
                        try
                        {
                            FileStream fileStream = new FileStream(item.Path, FileMode.Open, FileAccess.Read);
                            msg.Attachments.Add(new Attachment(fileStream, item.Name));
                        }
                        catch (Exception ex)
                        {
                            logCoreMan.Warn($"SendSmtp MailQueueId:{mailQueueLog.MailQueueId}, UploadId:{item.UploadId}, Exception:{ex.Message}", ex);
                        }
                    }
                }
            }

            var smtpClient = new SmtpClient(smtpConfig.Smtp, smtpConfig.SmtpPort) { EnableSsl = false };
            try
            {
                smtpClient.Send(msg);
                mailQueueLog.SendDate = DateTime.Now;
                //return mailQueueLog;
            }
            catch (Exception ex)
            {
                logCoreMan.Error($"SendSmtp MailQueueId:{mailQueueLog.MailQueueId}", ex);
                mailQueueLog.Error = ex.Message + ex.StackTrace;
            }
            return mailQueueLog;
        }

        public bool SendMail()
        {
            string redisValue = "";
            try
            {
                do
                {
                    redisValue = redisCoreManager.ListGetFromRight<string>(RedisConstants.MAILQUEUE);

                    if (string.IsNullOrEmpty(redisValue))
                        return true;

                    var mailQueueRedis = GetModel<MailQueue>(redisValue);

                    if (mailQueueRedis != null)
                    {
                        var mailQueue = unitOfWork.GetRepository<MailQueue>().GetById(mailQueueRedis.MailQueueId);

                        if (mailQueue == null || mailQueue.SendDate.HasValue || mailQueue.ErrorDate.HasValue || !string.IsNullOrEmpty(mailQueue.Error))
                            break;

                        var response = SendMailItem(mailQueue);
                    }
                } while (!string.IsNullOrEmpty(redisValue));
            }
            catch (Exception ex2)
            {
                logCoreMan.Error("MailQueueService SendMail Exception2", ex2);
                redisCoreManager.ListAddToLeft(RedisConstants.MAILQUEUE, redisValue);
            }

            return true;
        }

        public bool SendMailByMailQueueId(int mailQueueId)
        {
            var mailQueue = unitOfWork.GetRepository<MailQueue>().GetById(mailQueueId);

            if (mailQueue == null)
            {
                return false;
            }

            var response = SendMailItem(mailQueue);

            return response;
        }

        public string ViewMailByMailQueueId(int mailQueueId)
        {
            var mailQueue = unitOfWork.GetRepository<MailQueue>().GetById(mailQueueId);

            if (mailQueue == null)
            {
                return "";
            }
            var mailQueueLog = RenderMailQueue(mailQueue.Parameters, mailQueue);

            return mailQueueLog.Body;
        }

        private bool SendMailItem(MailQueue mailQueue)
        {
            try
            {
                MailQueueType emailType = (MailQueueType)Enum.Parse(typeof(MailQueueType), mailQueue.EmailTypeId.ToString());

                MailQueueLog mailQueueLog = null;
                mailQueue.Error = "";
                mailQueueLog = RenderMailQueue(mailQueue.Parameters, mailQueue);

                unitOfWork.GetRepository<MailQueueLog>().Add(mailQueueLog);

                //bcc=to+cc+bcc
                List<string> bccList = new List<string>();
                if (!string.IsNullOrEmpty(mailQueueLog.To))
                {
                    bccList.AddRange(mailQueueLog.To.Split(',').Select(x => EmailFixTurkishChar(x.Trim())).ToList());
                    mailQueueLog.To = "";
                }
                if (!string.IsNullOrEmpty(mailQueueLog.Cc))
                {
                    bccList.AddRange(mailQueueLog.Cc.Split(',').Select(x => EmailFixTurkishChar(x.Trim())).ToList());
                    mailQueueLog.Cc = "";
                }
                if (!string.IsNullOrEmpty(mailQueueLog.Bcc))
                {
                    bccList.AddRange(mailQueueLog.Bcc.Split(',').Select(x => EmailFixTurkishChar(x.Trim())).ToList());
                    mailQueueLog.Bcc = "";
                }

                bccList = bccList.Distinct().ToList();
                mailQueueLog.Bcc = string.Join(",", bccList);

                mailQueueLog = SendSmtp(mailQueueLog);

                if (!string.IsNullOrEmpty(mailQueueLog.Error))
                {
                    mailQueue.Error = mailQueueLog.Error;
                    mailQueue.ErrorDate = DateTime.Now;
                }
                else
                {
                    mailQueue.SendDate = DateTime.Now;
                }

                unitOfWork.SaveChanges();
            }
            catch (Exception ex)
            {
                logCoreMan.Error("MailQueueService SendMail Exception", ex);
                mailQueue.Error = ex.Message + ex.StackTrace;
                unitOfWork.SaveChanges();

                redisCoreManager.ListAddToLeft(RedisConstants.MAILQUEUE, mailQueue);

                return false;
            }
            return true;
        }
    }
}