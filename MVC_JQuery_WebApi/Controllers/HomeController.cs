using SharedCRCMS.Factory;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.Enums;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class HomeController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();
        //1-Новые наряды (ожидание обработки)
        //2-Наряды на разборке
        //3-Дефектовка
        //4-Подготовка отчета
        //5-Обработка заявок

        public ActionResult Index()
        {
            return View();
        }

        public string TestCrm()
        {
            var details = CrmFactory.Instance.BindWorkOrder("7500612");
            return string.Empty;
        }

        public JsonResult ResourceJson()
        {
            List<Tuple<string, string, string>> tuple = new List<Tuple<string, string, string>>();
            var expire = DateTime.Now.AddMinutes(10);
            tuple.Add(new Tuple<string, string, string>("expireValue", Request.Url.ToString(), expire.ToString("yyyyMMddHHmm")));

            string lang = System.Threading.Thread.CurrentThread.CurrentCulture.TwoLetterISOLanguageName;

            var resourceCrcms = Counter.Lang.Resources.ResourceManager.GetResourceSet(CultureInfo.GetCultureInfo(lang), false, true);
            if (resourceCrcms != null)
            {
                foreach (DictionaryEntry entry in resourceCrcms)
                {
                    //lang:en,tr,ru
                    string key = entry.Key.ToString();
                    string value = entry.Value.ToString();

                    tuple.Add(new Tuple<string, string, string>(lang, key, value));
                }
            }

            var resourceShared = StandartLibrary.Lang.Resources.ResourceManager.GetResourceSet(CultureInfo.GetCultureInfo(lang), false, true);
            if (resourceShared != null)
            {
                foreach (DictionaryEntry entry in resourceShared)
                {
                    //lang:en,tr,ru
                    string key = entry.Key.ToString();
                    string value = entry.Value.ToString();

                    var t = new Tuple<string, string, string>(lang, key, value);
                    if (!tuple.Contains(t))
                    {
                        tuple.Add(t);
                    }
                }
            }

            return Json(tuple, JsonRequestBehavior.AllowGet);
        }
    }
}