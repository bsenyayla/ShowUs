using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Settings;
using Microsoft.Extensions.Options;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using Microsoft.AspNetCore.Http;
using UploadType = StandartLibrary.Models.Enums.UploadType;
using CRCAPI.Services.Models.CrcTransfer;

namespace CRCAPI.Services
{
    [TransientDependency(ServiceType = typeof(IAttachmentService))]
    public class AttachmentService : IAttachmentService
    {
        private readonly IDocumentService documentService;
        private readonly IDowloadLogService dowloadLogService;
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IAreaService areaService;
        private readonly IUserService userService;
        private readonly IRedisCoreManager redisCoreManager;
        private readonly AppSettings appSettings;

        public AttachmentService(IUnitOfWork<CrcmsDbContext> unitOfWork, IDocumentService documentService, IOptions<AppSettings> options, IDowloadLogService dowloadLogService, IAreaService areaService, IUserService userService, IRedisCoreManager redisCoreManager)
        {
            this.unitOfWork = unitOfWork;
            this.documentService = documentService;
            this.dowloadLogService = dowloadLogService;
            this.appSettings = options.Value;
            this.areaService = areaService;
            this.userService = userService;
            this.redisCoreManager = redisCoreManager;
        }

        public void SaveFile(List<IFormFile> files, int documentId, UploadType uploadType, string userId = "", string userName = "", int zoneId = 0)
        {
            foreach (var file in files)
            {
                if (file.Length > 0)
                {
                    var rootDirectory = appSettings.FileUploadRootFolder;
                    rootDirectory = rootDirectory + Constants.DocumentPath + documentId + "\\";
                    var filePath = rootDirectory + file.FileName;
                    var isExists = Directory.Exists(rootDirectory);
                    if (!isExists)
                        Directory.CreateDirectory(rootDirectory);

                    using Stream fileStream = new FileStream(filePath, FileMode.Create);
                    file.CopyTo(fileStream);

                    var upload = new Upload
                    {
                        DateUpload = DateTime.Now,
                        Name = file.FileName,
                        Path = filePath,
                        TypeId = (int)uploadType,
                        Deleted = false,
                        Extension = Path.GetExtension(file.FileName),
                        DocumentId = documentId,
                        SizeKB = file.Length,
                        UserId = userId,
                        UserName = userName,
                        ZoneId = zoneId
                    };

                    unitOfWork.GetRepository<Upload>().Add(upload);
                }
            }

            unitOfWork.SaveChanges();
        }

        public void SaveFile(List<CrcComponentsCreateOrEditModel> components, int documentId, UploadType uploadType, string userId = "", string userName = "")
        {
            foreach (var component in components)
            {
                foreach (var file in component.Attachments)
                {
                    if (file.Length > 0)
                    {
                        var rootDirectory = appSettings.FileUploadRootFolder;
                        rootDirectory = rootDirectory + Constants.DocumentPath + documentId + "\\";
                        var filePath = rootDirectory + file.FileName;
                        var isExists = Directory.Exists(rootDirectory);
                        if (!isExists)
                            Directory.CreateDirectory(rootDirectory);

                        using Stream fileStream = new FileStream(filePath, FileMode.Create);
                        file.CopyTo(fileStream);

                        var upload = new Upload
                        {
                            DateUpload = DateTime.Now,
                            Name = file.FileName,
                            Path = filePath,
                            TypeId = (int)uploadType,
                            Deleted = false,
                            Extension = Path.GetExtension(file.FileName),
                            DocumentId = documentId,
                            SizeKB = file.Length,
                            UserId = userId,
                            UserName = userName,
                            ZoneId = 0,
                            ReferenceId = component.ItemNumber
                        };

                        unitOfWork.GetRepository<Upload>().Add(upload);
                    }
                }
            }

            unitOfWork.SaveChanges();
        }

        /// <summary>
        /// add attachment to db and save to the Folder as is... foskan 17.10.2019
        /// </summary>
        /// <param name="request"></param>
        public AddAttachmentResponse AddAttachment(AddAttachmentRequest request)
        {
            /// wekingte arealar patladıgı için bu sekilde bir workaround düşünüldü ilerde kaldıralacak...
            var wekingIntegrationInfo = redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            int increaseNumber = wekingIntegrationInfo.AreaIncreaseNumber;

            var documentId = documentService.FindDocumentNumberWithWorkOrderNumber(request.OrderNumber);

            if (documentId != 0)
            {
                userService.CheckAndCreateTemporaryTechnician(request.Technician);
                int? areaId = Convert.ToInt32(request.AreaId) - increaseNumber;

                var path = string.Empty;
                try
                {
                    bool hasTestArea = unitOfWork.GetRepository<Area>().List(x => x.Segment == 18000 && !string.IsNullOrEmpty(x.IP)).Select(x => x.AreaId).Contains((areaId ?? -1));

                    if (hasTestArea)
                        request.Attachment.FileType = FileType.Test;

                    path = SaveFileToServer(request.Attachment.Base64EncodedContent, request.Attachment.Name, request.Attachment.FileType, request.AreaId, request.OrderNumber, documentId);
                }
                catch (Exception ex)
                {
                    throw new BusinessException("File not saved", ErrorCode.FileNotSaved);
                }

                var upload = new Upload
                {
                    DateUpload = DateTime.Now,
                    Name = request.Attachment.Name,
                    Path = path,
                    TypeId = (int)request.Attachment.FileType,
                    Deleted = false,
                    Extension = request.Attachment.Extension,
                    DocumentId = documentId,
                    SizeKB = Convert.ToDecimal(request.Attachment.Size),
                    UserId = request.TechnicianSapNumber,
                    UserName = "WeKing",
                    ZoneId = areaId
                };

                unitOfWork.GetRepository<Upload>().Add(upload);

                unitOfWork.SaveChanges();
                return new AddAttachmentResponse
                {
                    AttachmentId = upload.UploadId
                };
            }
            else
            {
                throw new BusinessException("Wrong work order number", ErrorCode.WrongWorkOrderNumber);
            }


        }

        /// <summary>
        /// save files to the server...
        /// </summary>
        /// <param name="file"></param>
        /// <param name="fileName"></param>
        /// <param name="fileType"></param>
        /// <param name="areaId"></param>
        /// <param name="orderNumber"></param>
        /// <param name="documentId"></param>
        /// <returns></returns>
        public string SaveFileToServer(string file, string fileName, FileType fileType, string areaId, string orderNumber, int documentId)
        {
            string rootDirectory = string.Empty;
            string path = string.Empty;

            if (fileType == FileType.Photo)
            {
                rootDirectory = appSettings.PhotoUploadRootFolder;
            }
            else
            {
                rootDirectory = appSettings.FileUploadRootFolder;
            }

            var thumbDirectory = rootDirectory + "\\" + areaId + Constants.ThumbnailPath + documentId.ToString() + "\\";
            rootDirectory = rootDirectory + "\\" + areaId + Constants.DocumentPath + documentId.ToString() + "\\";

            path = rootDirectory + fileName;
            var isExists = Directory.Exists(rootDirectory);
            if (!isExists)
                Directory.CreateDirectory(rootDirectory);
            File.WriteAllBytes(path, Convert.FromBase64String(file));


            if (fileType == FileType.Photo)
            {
                var thumbExists = Directory.Exists(thumbDirectory);
                if (!thumbExists)
                    Directory.CreateDirectory(thumbDirectory);

                var thumbPath = thumbDirectory + fileName;

                CreateThumbnail(path, thumbPath);

            }

            return path;
        }

        /// <summary>
        /// creates a thumbnail for the image given..
        /// </summary>
        /// <param name="sourcePath"></param>
        /// <param name="destinationPath"></param>
        /// <returns></returns>
        public string CreateThumbnail(string sourcePath, string destinationPath)
        {
            Image image = Image.FromFile(sourcePath);
            // Get thumbnail.
            Image thumbnail = image.GetThumbnailImage(120, 100, null, IntPtr.Zero);

            // Save thumbnail.
            thumbnail.Save(destinationPath);
            return string.Empty;
        }


        /// <summary>
        /// Lists all the attachments from db without base64string..
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public List<AttachmentResponse> GetAttachments(GetAttachmentListRequest request)
        {
            var areaList = areaService.GetAreaList();
            var documentId = documentService.FindDocumentNumberWithWorkOrderNumber(request.OrderNumber);
            if (documentId != 0)
            {
                var uploadList = unitOfWork.GetRepository<Upload>().List(x => x.DocumentId == documentId && !x.Deleted && !x.Name.Equals("NotApplicable")).Select(x => new AttachmentResponse
                {
                    DateUpload = x.DateUpload == null ? string.Empty : $"{x.DateUpload:yyyyMMddHHmmss}",
                    Extension = x.Extension,
                    FileType = (FileType)x.TypeId,
                    Id = x.UploadId.ToString(),
                    Name = x.Name,
                    Size = x.SizeKB.ToString(),
                    TechnicianSapNumber = x.UserId,
                    CreatedFullname = string.IsNullOrWhiteSpace(x.UserId) ? "" : userService.GetUserFullName(x.UserId),
                    AreaName = x.ZoneId == (int)ZoneType.Reception ? "Kabul" : (x.ZoneId == (int)ZoneType.Dispatch ? "Sevk" : (areaList.Where(y => y.AreaId == x.ZoneId.ToString()).FirstOrDefault() == null ? "" : areaList.Where(y => y.AreaId == x.ZoneId.ToString()).FirstOrDefault().AreaName))
                }).ToList();

                return uploadList;
            }
            return new List<AttachmentResponse>();
        }


        /// <summary>
        /// Lists all the attachments from db without base64string..
        /// only the thechnical report type=2  , Reception report type= 18 and  typeid = 23	  Dispatch Report	
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public List<AttachmentResponse> GetBoomAttachments(GetAttachmentListRequest request)
        {
            var areaList = areaService.GetAreaList();
            var documentId = documentService.FindDocumentNumberWithWorkOrderNumber(request.OrderNumber);
            if (documentId != 0)
            {
                var uploadList = unitOfWork.GetRepository<Upload>().List(x => x.DocumentId == documentId && !x.Deleted && !x.Name.Equals("NotApplicable") && (x.TypeId == 2 || x.TypeId == 5 || x.TypeId == 18 || x.TypeId == 23)).Select(x => new AttachmentResponse
                {
                    DateUpload = x.DateUpload == null ? string.Empty : $"{x.DateUpload:yyyyMMddHHmmss}",
                    Extension = x.Extension,
                    FileType = (FileType)x.TypeId,
                    Id = x.UploadId.ToString(),
                    Name = x.Name,
                    Size = x.SizeKB.ToString(),
                    TechnicianSapNumber = x.UserId,
                    MimeType = string.IsNullOrEmpty(x.Extension) ? "" : x.Extension.Trim('.').ToLower(),
                    UploadType = (UploadType)x.TypeId,
                    CreatedFullname = string.IsNullOrWhiteSpace(x.UserId) ? "" : userService.GetUserFullName(x.UserId),
                    AreaName = x.ZoneId == (int)ZoneType.Reception ? "Kabul" : (x.ZoneId == (int)ZoneType.Dispatch ? "Sevk" : (areaList.Where(y => y.AreaId == x.ZoneId.ToString()).FirstOrDefault() == null ? "" : areaList.Where(y => y.AreaId == x.ZoneId.ToString()).FirstOrDefault().AreaName))
                }).ToList();

                return uploadList;
            }
            return new List<AttachmentResponse>();
        }




        /// <summary>
        /// gets the details of a spesific attachment with base64string..
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public AttachmentResponse GetAttachment(GetAttachmentRequest request)
        {

            var areaList = areaService.GetAreaList();
            var attachment = unitOfWork.GetRepository<Upload>().List(x => x.UploadId.ToString() == request.AttachmentId && !x.Deleted && !x.Name.Equals("NotApplicable")).Select(x => new AttachmentResponse
            {
                DateUpload = x.DateUpload == null ? string.Empty : $"{x.DateUpload:yyyyMMddHHmmss}",
                Extension = x.Extension,
                FileType = (FileType)x.TypeId,
                Id = x.UploadId.ToString(),
                Name = x.Name,
                Size = x.SizeKB.ToString(),
                TechnicianSapNumber = x.UserId,
                CreatedFullname = string.IsNullOrWhiteSpace(x.UserId) ? "" : userService.GetUserFullName(x.UserId),
                Path = x.Path,
                Base64EncodedContent = ConvertToBase64String(x.Path),
                AreaName = x.ZoneId == (int)ZoneType.Reception ? "Kabul" : (x.ZoneId == (int)ZoneType.Dispatch ? "Sevk" : (areaList.Where(y => y.AreaId == x.ZoneId.ToString()).FirstOrDefault() == null ? "" : areaList.Where(y => y.AreaId == x.ZoneId.ToString()).FirstOrDefault().AreaName))
            }).FirstOrDefault();
           
            if (attachment == null)
            {
                return new AttachmentResponse();
            }


            bool converted = int.TryParse(attachment.Id, out var attachmentId);

            if (converted)
            {
                DowloadLogRequest downloadReq = new DowloadLogRequest
                {
                    AttachmentId = attachmentId,
                    AttachmentPath = attachment.Path,
                    Module = "CRCAPI",
                    TechnicianSapNumber = request.TechnicianSapNumber
                };

                dowloadLogService.Log(downloadReq);
            }

            return attachment;
        }

        public WorkOrderInfoAttachmentResponse GetAttachmentContent(int attachmentId)
        {
            var attachment = unitOfWork.GetRepository<Upload>().List(x => x.UploadId == attachmentId && !x.Deleted && !x.Name.Equals("NotApplicable")).Select(x => new WorkOrderInfoAttachmentResponse
            {
                FileName = x.Name,
                AttachmentId = attachmentId,
                Base64EncodedContent = ConvertToBase64String(x.Path)
            }).FirstOrDefault();

            if (attachment == null)
            {
                attachment = new WorkOrderInfoAttachmentResponse();
            }

            return attachment;
        }

        private string ConvertToBase64String(string path)
        {
            Byte[] bytes = File.ReadAllBytes(path);
            return Convert.ToBase64String(bytes);
        }
    }
}
