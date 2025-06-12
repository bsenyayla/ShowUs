<%@ WebHandler Language="C#" Class="PhoneCodeHandler" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using TuFactory.Domain;
using Coretech.Crm.Factory;

public class PhoneCodeHandler : IHttpHandler
{

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";



        switch (context.Request["method"])
        {
            case "list":
                context.Response.Write(GetMultiplePhoneCodeCountries());
                break;
            default:
                if (context.Request["phoneCode"] != null)
                {
                    context.Response.Write(GetCountryPhoneCode(context.Request["phoneCode"]));
                }
                else
                    context.Response.Write(string.Empty);
                break;
        }

    }

    public string GetCountryPhoneCode(string selectedCountry)
    {
        var multiplePhoneCodeCountries = JsonConvert.DeserializeObject<MultiplePhoneCodeCountry>(GetMultiplePhoneCodeCountries());

        return multiplePhoneCodeCountries.countries.Any(x => x.country.PadLeft(4,'0') == selectedCountry.PadLeft(4,'0')) ? string.Empty : selectedCountry;
    }

    //public void ValidatePhoneCode(HttpContext context)
    //{
    //    var selectedCountry = context.Request["selectedCode"];
    //    var countryCode = context.Request["phoneCode"];
    //    var gsmPrefix = context.Request["gsmPrefix"];
    //    var phoneNumber = string.Format("{0}{1}", countryCode.Replace("0", string.Empty), gsmPrefix.Replace("0", string.Empty));
    //    var multiplePhoneCodeCountries = GetMultiplePhoneCodeCountries();
    //    if (multiplePhoneCodeCountries.ContainsKey(selectedCountry))
    //    {
    //        if (selectedCountry == countryCode)
    //        {
    //            context.Response.Write(string.Empty);
    //        }
    //        else
    //        {
    //            if (!multiplePhoneCodeCountries[selectedCountry].Any(x => x == phoneNumber))
    //            {
    //                context.Response.Write("Kosovo country code should be one of these : 381, 377-44, 377-45, 386-49");
    //            }
    //        }
    //    }
    //    else
    //    {
    //        context.Response.Write(string.Empty);
    //    }
    //}


    private string GetMultiplePhoneCodeCountries()
    {
        string result = App.Params.GetConfigKeyValue("MULTIPLE_PHONE_CODE_COUNTRIES").Replace("\\","");
        if (string.IsNullOrEmpty(result))
        {
            result = "{ \"countries\": [{ \"country\" :\"381\", \"codes\":  [ {\"code\":\"37744\"}, {\"code\":\"37745\"}, {\"code\":\"38649\"} ]} ]}";
        }
        return result;
    }

    //private Dictionary<string, List<string>> GetMultiplePhoneCodeCountries()
    //{
    //    Dictionary<string, List<string>> multiplePhoneCodeCountries = new Dictionary<string, List<string>>();
    //    multiplePhoneCodeCountries.Add("381", new List<string>() { "37744", "37745", "38649" });

    //    return multiplePhoneCodeCountries;
    //}

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
