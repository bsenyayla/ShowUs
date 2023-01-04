using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels.Response;
using System.Threading.Tasks;

namespace CRCAPI.Services.Interfaces
{
    public interface IUserService
    {
        Task<ApiUser> Authenticate(string username, string password);

        User GetUserByTechnicianSAPNumber(string technicianSapNumber);

        void SynchronizeTechnicians();

        void CheckAndCreateTemporaryTechnician(TechnicianViewModel technician);

        string GetUserFullName(string key);
    }
}
