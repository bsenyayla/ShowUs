namespace CRCAPI.Services.Interfaces
{
    public interface IDocumentService
    {
        int FindDocumentNumberWithWorkOrderNumber(string orderNumber);

        void UpdateDocuments();

        void UpdateDispatchedDocuments();

        int FindDocumentSegmentIdWithWorkOrderNumberSegmentCode(string orderNumber,int segmentCode);
    }
}
