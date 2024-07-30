using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using Newtonsoft.Json;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels.MailQueue;
using StandartLibrary.Models.Enums;

namespace CRCAPI.Services.Services
{
    [ScopedDependency(ServiceType = typeof(ISmtpService))]
    public class SmtpService : ISmtpService
    {
        private readonly IUnitOfWork<CrcmsDbContext> _unitOfWork;
        private readonly IAppSettingService _appSettingService;
        private readonly IRedisCoreManager _redisCoreManager;
        private readonly ILogCoreMan _logCoreMan;

        public SmtpService(IUnitOfWork<CrcmsDbContext> unitOfWork, IAppSettingService appSettingService, IRedisCoreManager redisCoreManager, ILogCoreMan logCoreMan)
        {
            _unitOfWork = unitOfWork;
            _appSettingService = appSettingService;
            _redisCoreManager = redisCoreManager;
            _logCoreMan = logCoreMan;
        }

        public bool SendMail(MailQueueParameterModel mailQueueParameterModel, List<string> toList, List<string> ccList)
        {
            try
            {
                if (toList != null && toList.Any() || ccList != null && ccList.Any())
                {
                    mailQueueParameterModel.MailQueueTypeId = (int)PrepareMailQueueType(mailQueueParameterModel);
                    mailQueueParameterModel.LocalizationItems = GetLocalizationItems(mailQueueParameterModel);

                    var mailQueueParameterModelValue = JsonConvert.SerializeObject(mailQueueParameterModel);
                    var mailQueue = new MailQueue
                    {
                        EmailTypeId = mailQueueParameterModel.MailQueueTypeId,
                        CreateDate = DateTime.Now,
                        SendDate = null,
                        To = toList != null ? string.Join(", ", toList) : "",
                        Cc = ccList != null ? string.Join(", ", ccList) : "",
                        Parameters = mailQueueParameterModelValue
                    };

                    _logCoreMan.Debug(JsonConvert.SerializeObject(mailQueue));

                    _unitOfWork.Context.MailQueue.Add(mailQueue);
                    _unitOfWork.SaveChanges();

                    /* add redis value */
                    var response = _redisCoreManager.ListAddToLeft(RedisConstants.MAILQUEUE, mailQueue);
                }
            }
            catch (Exception ex)
            {
                _logCoreMan.Error("AddMailQueue: ", ex);
            }

            return true;
        }

        private static MailQueueType PrepareMailQueueType(MailQueueParameterModel mailQueueParameterModel)
        {
            if (mailQueueParameterModel.BaseOfQuotation != null)
                return MailQueueType.BaseOfQuotation;
            if (mailQueueParameterModel.DefectList != null)
                return MailQueueType.DefectList;
            if (mailQueueParameterModel.DevTeam != null)
                return MailQueueType.DevTeam;
            if (mailQueueParameterModel.Dispatch != null)
                return MailQueueType.Dispatch;
            if (mailQueueParameterModel.PartsCollect != null)
                return MailQueueType.PartsCollect;
            if (mailQueueParameterModel.Reception != null)
                return MailQueueType.Reception;
            if (mailQueueParameterModel.SmcsCoordinator != null)
                return MailQueueType.SmcsCoordinator;
            if (mailQueueParameterModel.CrcRequest != null)
                return MailQueueType.CrcRequest;
            if (mailQueueParameterModel.CrcRequestAcceptance != null)
                return MailQueueType.CrcRequestAcceptance;
            if (mailQueueParameterModel.CrcTransferRequest != null)
                return MailQueueType.CrcTransferRequest;
            if (mailQueueParameterModel.SimpleText != null)
                return MailQueueType.SimpleText;

            throw new Exception("PrepareMailQueueType MailQueueType could not be found");
        }

        private List<LocalizationItemModel> GetLocalizationItems(MailQueueParameterModel mailQueueParameterModel)
        {
            var appSetting = _appSettingService.AppSetting();
            var response = new List<LocalizationItemModel>();
            var rootKey = "Root";

            response.Add(new LocalizationItemModel
            {
                Key = rootKey,
                Language = "",
                Value = appSetting?.Smtp?.HtmlImageRoot,
            });

            var template = GetTemplate((MailQueueType)Enum.ToObject(typeof(MailQueueType), mailQueueParameterModel.MailQueueTypeId));
            var bodyToFindLocalizedItems = mailQueueParameterModel.Subject + mailQueueParameterModel.Title + template;
            if (mailQueueParameterModel.CrcTransferRequest != null && mailQueueParameterModel.CrcTransferRequest.ChangedProps != null)
            {
                foreach (var item in mailQueueParameterModel.CrcTransferRequest.ChangedProps)
                {
                    bodyToFindLocalizedItems = item.Key + bodyToFindLocalizedItems;
                }
            }

            var match = Regex.Matches(bodyToFindLocalizedItems, @"\{@?\w+}")
                .OfType<Match>()
                .Select(m => m.Value.Replace("{", "").Replace("}", ""))
                .Distinct()
                .ToList();

            foreach (var key in match.Where(x => x != rootKey))
            {
                foreach (var lang in appSetting.Content.LanguageList)
                {
                    var value = GetResourceValue(lang, key);
                    response.Add(new LocalizationItemModel { Key = key, Language = lang, Value = value });
                }
            }

            return response;
        }

        private static string GetTemplate(MailQueueType mailQueueType)
        {
            try
            {
                var templateRoot = System.IO.Directory.GetParent(System.IO.Directory.GetParent(System.AppDomain.CurrentDomain.BaseDirectory).FullName) + "\\_cdoms_email_template\\";
                var templateLayoutFile = $"{templateRoot}_Layout.cshtml";

                if (!System.IO.File.Exists(templateLayoutFile))
                {
                    throw new BusinessException("Template File Not Found", ErrorCode.TemplateFileNotFound);
                }

                var templateLayout = System.IO.File.ReadAllText(templateLayoutFile);
                var templateFile = $"{templateRoot}{mailQueueType.ToString()}.cshtml";
                if (!System.IO.File.Exists(templateFile))
                {
                    throw new BusinessException("Template File Not Found", ErrorCode.TemplateFileNotFound);
                }

                var template = System.IO.File.ReadAllText(templateFile);
                var response = templateLayout.Replace("{BODY}", template);

                return response;
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        private static string GetResourceValue(string lang, string key)
        {
            try
            {
                var entry = StandartLibrary.Lang.Resources.ResourceManager.GetResourceSet(CultureInfo.GetCultureInfo(lang), true, true)?
                    .OfType<DictionaryEntry>()
                    .FirstOrDefault(e => e.Key.ToString().Equals(key, StringComparison.InvariantCultureIgnoreCase));

                return entry.Value.Value?.ToString();
            }
            catch (Exception)
            {
                return "{" + key + "}";
            }
        }
    }
}
