using Sniper.Api.Authorization;
using Sniper.Api.Base;
using Sniper.Api.Filters;
using Sniper.Core.Models.Common;
using Sniper.Core.SAPRest;
using Sniper.Core.SAPRest.Notes;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Description;
using System.Data;
using System.Linq.Expressions;
using System.Linq;
namespace Sniper.Api.Controllers
{
#if (!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/notes")]
    public class NotesController : ApiController
    {

        [Route("getall")]
        [HttpGet]
        public HttpResponseMessage GetNotes(string textProcedure = null)
        {
            try
            {
                NotesResult sapNoteResult;

                if (!string.IsNullOrEmpty(textProcedure))
                {
                    sapNoteResult = SAPRestService.GetNoteTypes(textProcedure);
                }
                else
                {
                    sapNoteResult = SAPRestService.GetNoteTypes();
                }

                var sniperNoteResult = sapNoteResult?.EXPORT?.ET_TD_ID
                                            .Select(x => new Core.Models.EntityModels.Notes.NoteValues { TdId = x.TDID, TdText = x.TDTEXT }).ToList();

                return Request.CreateResponse(HttpStatusCode.OK, sniperNoteResult);
            }
            catch (System.Exception ex)
            {
                return Request.CreateResponse(HttpStatusCode.InternalServerError, ex.Message);
            }
        }
    }
}
