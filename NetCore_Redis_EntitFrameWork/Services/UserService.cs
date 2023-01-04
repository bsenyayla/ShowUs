using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Settings;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using RestSharp;
using RestSharp.Authenticators;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Response;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace CRCAPI.Services
{
    [ScopedDependency(ServiceType = typeof(IUserService))]
    public class UserService : IUserService
    {
        private readonly AppSettings appSettings;
        private ApiUser user = new ApiUser();
        public List<ApiUser> users = new List<ApiUser>();

        // private readonly IRepository<User> userRepository;
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;

        private readonly ILogCoreMan logMan;
        private readonly IRedisCoreManager redisCoreManager;

        public UserService(IOptions<AppSettings> options, IUnitOfWork<CrcmsDbContext> unitOfWork, IRedisCoreManager redisCoreManager, ILogCoreMan logMan)// IRepository<User> userRepository)
        {
            this.appSettings = options.Value;
            user.Password = this.appSettings.ApiPassword;
            user.Username = this.appSettings.ApiUsername;
            users.Add(user);
            this.unitOfWork = unitOfWork;
            this.redisCoreManager = redisCoreManager;
            this.logMan = logMan;
        }

        /// <summary>
        /// Authenticates user to the api...
        /// </summary>
        /// <param name="username"></param>
        /// <param name="password"></param>
        /// <returns></returns>
        public async Task<ApiUser> Authenticate(string username, string password)
        {
            var user = await Task.Run(() => users.SingleOrDefault(x => x.Username == username && x.Password == password));

            // return null if user not found
            if (user == null)
                return null;

            // authentication successful so return user details without password
            user.Password = null;
            return user;
        }

        /// <summary>
        /// Gets user by technicianSapNumber...
        /// </summary>
        /// <param name="technicianSapNumber"></param>
        /// <returns></returns>
        public User GetUserByTechnicianSAPNumber(string technicianSapNumber)
        {
            var user = unitOfWork.GetRepository<User>().List(x => x.SAPNumber == technicianSapNumber).FirstOrDefault();

            if (user == null)
            {
                throw new BusinessException("User not found", StandartLibrary.Models.Enums.ErrorCode.UserNotFound);
            }
            return user;
        }

        /// <summary>
        /// checks if technician exists in db and if not creates a temporary technician...
        /// </summary>
        /// <param name="technician"></param>
        public void CheckAndCreateTemporaryTechnician(TechnicianViewModel technician)
        {
            var user = unitOfWork.GetRepository<User>().List(x => x.SAPNumber == technician.BpNo).FirstOrDefault();

            if (user == null)
            {
                string format = "dd-MM-yyyy";

                User newUser = new User
                {
                    Code = technician.Username,
                    EmployeeNumber = technician.BpNo,
                    EmployeeTypeId = 1,
                    JobTitle = "Technician",
                    SAPNumber = technician.BpNo,
                    ShowInWorkReport = 1,
                    Team = technician.TeamName,
                    TeamId = 0,
                    IsActive = true,
                    Name = technician.FullName,
                    NameEn = technician.FullName,
                    StartWorkDate = DateTime.ParseExact(technician.ActivationDate, format, CultureInfo.InvariantCulture),
                    GroupId = 0,
                    IsTemporary = true
                };
                unitOfWork.GetRepository<User>().Add(newUser);
                unitOfWork.SaveChanges();
            }
        }

        /// <summary>
        /// syncronize technicians from sap...
        /// </summary>
        public void SynchronizeTechnicians()
        {
            var format = "dd-MM-yyyy";
            var wekingIntegrationInfo = redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            var userList = unitOfWork.GetRepository<User>().List(x => !x.IsTemporary);
            var groups = unitOfWork.GetRepository<Group>().List();
            IRestClient restClient = GetWekingClient(wekingIntegrationInfo);

            var request = new RestRequest(wekingIntegrationInfo.TechniciansRoute + wekingIntegrationInfo.WeKingOrganizationId, Method.GET)
            {
                RequestFormat = DataFormat.Json
            };

            request.AddHeader("Language", "tr");

            var response = restClient.Get(request);
            if (response.StatusCode == System.Net.HttpStatusCode.OK)
            {
                var res = JsonConvert.DeserializeObject<RestApiResponse<List<TechnicianViewModel>>>(response.Content);
                var activeTecniciansFromSap = res.Data.Where(x => string.IsNullOrWhiteSpace(x.DeactivationDate));
                var deactiveTecniciansFromSap = res.Data.Where(x => !string.IsNullOrWhiteSpace(x.DeactivationDate));

                var arrr = activeTecniciansFromSap.Select(y => y.BpNo).ToList();
                arrr.AddRange(deactiveTecniciansFromSap.Select(y => y.BpNo).ToList());

                /// 3. party teknisyenler senkronizasyon esnasında silinmesinler....
                var thirdPartyTecnicianType = (int)StandartLibrary.Models.Enums.EmployeeTypeId.ThirdPartyTechnician;
                var notExistingUsers = userList.Where(x => !arrr.Contains(x.SAPNumber) && x.EmployeeTypeId != thirdPartyTecnicianType).ToList();

                if (res.ErrorCode == StandartLibrary.Models.Enums.ErrorCode.Success)
                {
                    foreach (var item in activeTecniciansFromSap)
                    {
                        var user = userList.Where(x => x.SAPNumber == item.BpNo).FirstOrDefault();

                        if (user != null)
                        {
                            var userGroup = groups.Where(x => x.Section == item.Section).FirstOrDefault();
                            var userToUpdate = unitOfWork.GetRepository<User>().List(x => x.UserId == user.UserId).First();
                            /// will be implemented soon...
                            if (!userToUpdate.IsActive)
                            {
                                userToUpdate.IsActive = true;
                            }
                            userToUpdate.Team = item.TeamName;
                            userToUpdate.Name = item.FullName;
                            userToUpdate.NameEn = item.FullName;
                            ///section bilgisi update de gelmiyorsa userın group bilgisi update edilmesin...
                            userToUpdate.GroupId = userGroup == null ? userToUpdate.GroupId : userGroup.GroupId;
                            userToUpdate.StartWorkDate = DateTime.ParseExact(item.ActivationDate, format, CultureInfo.InvariantCulture);
                            unitOfWork.GetRepository<User>().Update(userToUpdate);
                        }
                        else
                        {
                            var userGroup = groups.Where(x => x.Section == item.Section).FirstOrDefault();

                            User newUser = new User
                            {
                                Code = item.Username,
                                EmployeeNumber = item.BpNo,
                                EmployeeTypeId = 1,
                                JobTitle = "Technician",
                                SAPNumber = item.BpNo,
                                ShowInWorkReport = 1,
                                Team = item.TeamName,
                                TeamId = 0,
                                IsActive = true,
                                Name = item.FullName,
                                NameEn = item.FullName,
                                StartWorkDate = DateTime.ParseExact(item.ActivationDate, format, CultureInfo.InvariantCulture),
                                GroupId = userGroup == null ? 0 : userGroup.GroupId,
                                IsTemporary = false
                            };
                            unitOfWork.GetRepository<User>().Add(newUser);
                        }
                    }

                    foreach (var item in deactiveTecniciansFromSap)
                    {
                        var user = userList.Where(x => x.SAPNumber == item.BpNo).FirstOrDefault();

                        if (user != null)
                        {
                            user.IsActive = false;
                            unitOfWork.GetRepository<User>().Update(user);
                        }
                    }

                    foreach (var item in notExistingUsers)
                    {
                        var user = userList.Where(x => x.SAPNumber == item.SAPNumber).FirstOrDefault();

                        if (user != null)
                        {
                            user.IsActive = false;
                            unitOfWork.GetRepository<User>().Update(user);
                        }
                    }

                    unitOfWork.SaveChanges();
                }
            }
            else
            {
                logMan.Error($"SynchronizeTechnicians error. {JsonConvert.SerializeObject(response)}");
            }
        }

        /// <summary>
        /// Creates a rest Client...
        /// </summary>
        /// <returns></returns>
        public RestClient GetWekingClient(WekingIntegration wekingIntegrationInfo)
        {
            return new RestClient(wekingIntegrationInfo.WeKingUrl)
            {
                Authenticator = new HttpBasicAuthenticator(wekingIntegrationInfo.WekingIntegrationUser, wekingIntegrationInfo.WekingIntegrationPassword)
            };
        }

        /// <summary>
        /// gets the name of the user with sapnumber or code....
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public string GetUserFullName(string key)
        {
            var user = unitOfWork.GetRepository<User>().List(x => x.SAPNumber == key || x.Code == key).FirstOrDefault();
            if (user == null)
            {
                return string.Empty;
            }
            return user.Name;
        }
    }
}