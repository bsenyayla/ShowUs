using SharedCRCMS.Filter;
using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels.Counter;
using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_MAILING_CABINET_R)]
    public class PSSREditorController : BaseController
    {
        private CRCMSEntities db = new CRCMSEntities();

        [UserActivityFilter]
        public string AjaxAddCustomer(int customerId, string division)
        {
            db.Counter_PSSR_Customer.Add(new CounterPSSRCustomer() { CustomerId = customerId, Division = division });
            db.SaveChanges();
            return "ok";
        }

        public string AjaxAddEmail(int customerId, int type, string email)
        {
            if (!SmtpService.IsValidEmail(email))
            {
                return StandartLibrary.Lang.Resources.Email_address_is_wrong;
            }

            if (db.Counter_PSSR_Email.Any(x => x.Email == email))
            {
                return StandartLibrary.Lang.Resources.Mistake_Already_exists_6608;
            }

            db.Counter_PSSR_Email.Add(new CounterPssrEmail() { CustomerId = customerId, Type = type, Email = email });

            db.SaveChanges();
            return "ok";
        }

        [UserActivityFilter]
        public string AjaxEditCustomer(int id, string division)
        {
            var item = db.Counter_PSSR_Customer.Single(x => x.Id == id);
            item.Division = division;
            db.SaveChanges();
            return "ok";
        }

        public string AjaxEditEmail(int id, string email, int type)
        {
            if (!SmtpService.IsValidEmail(email))
            {
                return StandartLibrary.Lang.Resources.Email_address_is_wrong;
            }

            if (db.Counter_PSSR_Email.Any(x => x.Email == email && x.Id != id))
            {
                return StandartLibrary.Lang.Resources.Mistake_Already_exists_6608;
            }

            var item = db.Counter_PSSR_Email.Single(x => x.Id == id);
            item.Email = email;
            item.Type = type;
            db.SaveChanges();
            return "ok";
        }

        [UserActivityFilter]
        public string AjaxDeleteCustomer(int id)
        {
            var emailItems = db.Counter_PSSR_Email.Where(x => x.CustomerId == id);
            db.Counter_PSSR_Email.RemoveRange(emailItems);
            var item = db.Counter_PSSR_Customer.Single(x => x.Id == id);
            db.Counter_PSSR_Customer.Remove(item);
            db.SaveChanges();
            return "ok";
        }

        public string AjaxDeleteEmail(int id)
        {
            var item = db.Counter_PSSR_Email.Single(x => x.Id == id);
            db.Counter_PSSR_Email.Remove(item);
            db.SaveChanges();
            return "ok";
        }

        [ProvisionAccessAttribute(PermissionEnum.COUNTER_MAILING_CABINET_R, PermissionEnum.COUNTER_MAILING_CABINET_RW)]
        [UserActivityFilter]
        public ActionResult Index()
        {
            PssrEditorIndexModel model = new PssrEditorIndexModel
            {
                List = new List<PssrEditorIndexItemModel>()
            };

            var customerList = db.Customers.ToList();
            customerList.Insert(0, new Customer { CustomerId = 0, Name = "*" + StandartLibrary.Lang.Resources.All_5801, Code = "" });

            var pssrEmailList = db.Counter_PSSR_Email.ToList();

            var counterCustomerList = db.Counter_PSSR_Customer.ToList();
            counterCustomerList.Insert(0, new CounterPSSRCustomer { CustomerId = 0, Id = 0, Division = "" });

            foreach (var item in counterCustomerList)
            {
                var customer = customerList.FirstOrDefault(x => x.CustomerId == item.CustomerId);

                var emailList = pssrEmailList.Where(x => x.CustomerId == item.CustomerId).Select(x => x.Email);
                var emailsValue = string.Join(", ", emailList);

                var psstEditorIndexItem = new PssrEditorIndexItemModel
                {
                    Id = item.Id,
                    CustomerId = item.CustomerId,
                    CustomerName = customer?.Name,
                    Division = item.Division,
                    Emails = emailsValue,
                };
                model.List.Add(psstEditorIndexItem);
            }
            return View("PSSREditor", model);
        }

        public ActionResult Email(int customerId)
        {
            if (customerId == 0)
            {
                ViewBag.CustomerName = StandartLibrary.Lang.Resources.All_5801;
            }
            else
            {
                ViewBag.CustomerName = db.Customers.FirstOrDefault(x => x.CustomerId == customerId).Name;
            }
            ViewBag.CustomerId = customerId;
            var lst = db.Counter_PSSR_Email.Where(x => x.CustomerId == customerId);
            return View(lst);
        }

        public string Convert()
        {
            var customers = db.Customers.ToList();
            var convertList = db.Counter_CustomerPSSR.ToList();
            foreach (var convertItem in convertList)
            {
                var customer = customers.SingleOrDefault(x => x.Name.ToUpper().Trim() == convertItem.CustomerName.ToUpper().Trim());
                if (customer != null)
                {
                    var newCounterCustomer = new CounterPSSRCustomer() { CustomerId = customer.CustomerId, Division = convertItem.Division };
                    db.Counter_PSSR_Customer.Add(newCounterCustomer);
                    db.SaveChanges();
                    db.Counter_PSSR_Email.Add(new CounterPssrEmail()
                    {
                        CustomerId = newCounterCustomer.CustomerId,
                        Email = convertItem.PSSRs.Trim(),
                        Type = 1
                    });
                    if (convertItem.Copy != null)
                    {
                        var copy = convertItem.Copy.Trim();
                        var lines = copy.Split(new string[] { ";" }, StringSplitOptions.None);
                        foreach (var email in lines)
                        {
                            db.Counter_PSSR_Email.Add(new CounterPssrEmail()
                            {
                                CustomerId = newCounterCustomer.CustomerId,
                                Email = email.Trim(),
                                Type = 2
                            });
                        }
                    }
                    db.SaveChanges();
                }
                else
                {
                    var ddd = 1;
                    ddd++;
                }
            }
            return "ok";
        }
    }
}