using SharedCRCMS.Models;
using SharedCRCMS.Service;
using StandartLibrary.Models.Enums;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;

namespace Counter.Controllers
{
    [Authorize]
    [ProvisionAccessAttribute(PermissionEnum.COUNTER_CABINET_R, PermissionEnum.COUNTER_CABINET_RW)]
    public class UserInfoController : BaseController
    {
        // GET: UserInfo
        //public string GetSId()
        //{
        //    var userSid = SharedCRCMS.Service.Helper.GetADUserProfile(User.Identity.Name).Sid;
        //    return userSid;
        //}

        //public async Task UpdateSId()
        //{
        //    CRCMSEntities db = new CRCMSEntities();
        //    var sId = GetSId();
        //    var currentUser = db.LocalUser.FirstOrDefault(x => x.UserId == 1);
        //    if (currentUser != null)
        //    {
        //        currentUser.SID = sId;
        //        await db.SaveChangesAsync();
        //    }
        //}
    }
}