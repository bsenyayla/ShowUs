namespace CRCAPI.Services.Settings
{
    public class AppSettings
    {
        public string ApiUsername { get; set; }
        public string ApiPassword { get; set; }
        public string ServiceAssemblyName { get; set; }
        public string PhotoUploadRootFolder { get; set; }
        public string FileUploadRootFolder { get; set; }
        public string WekingUrl { get; set; }
        public string OrganizationId { get; set; }
        public string WekingIntegrationUser { get; set; }
        public string WekingIntegrationPassword { get; set; }
        public string CdomsLocationKey { get; set; }
        public string ConfigMode { get; set; }
    }
}
