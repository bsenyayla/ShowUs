using Coretech.Crm.Provider.Security;
using Coretech.Crm.Web.UI.RefleX;
using System;
using System.Threading;
using TuFactory.Business.Transfer;
using TuFactory.TuBlacklist.Business;

public partial class UnitTest_ThreadTest : BasePage
{
    Guid[] recID = new Guid[]
    {
        new Guid("6C74AE86-39BB-E411-BE24-005056B200B3"),
        new Guid("A806B7BC-574F-4772-B4FE-6969845EC7CA"),
        new Guid("29A3D3AD-8402-428D-9CAE-1B48BD5DEA02"),
        new Guid("4D5242AE-8608-E611-A40A-005056B200B3"),
        new Guid("A9EF28D9-75BB-4E8A-B5F9-D50F2C8E58F9"),
        new Guid("D46AB40B-6F8C-E511-93B6-545216737709"),
        new Guid("F8626579-3984-4A35-B3E8-59158C65D95A"),
        new Guid("BF470D64-470C-41A5-A714-E7CE1D80BB1B"),
        new Guid("C68EE2E3-D7BC-E411-BE24-005056B200B3"),
        new Guid("FD038C3D-C517-4D70-BB72-9979FC9E3E3D"),
        new Guid("FEAB55F0-5288-E511-B688-005056B200B3"),
        new Guid("747381B9-88F5-4054-B5AB-BF497CCC5BE2"),
        new Guid("D5AE05B5-DBE1-E511-A40A-005056B200B3"),
        new Guid("E548FAAA-E739-E511-BBAF-005056B200B3"),
        new Guid("8D2E484C-D0A9-4E77-8836-893CDA093A62"),
        new Guid("212D1F6D-4EB6-46E5-B748-18B613CB47BA"),
        new Guid("F88F816F-11EC-47BD-A89D-9E9E83B41A11"),
        new Guid("0BFC8B28-1ADB-4306-8EB7-CD39BCF42E79"),
        new Guid("62D2DB7D-1741-E511-92CD-545216737709"),
        new Guid("B842C700-6750-4D63-A700-2CE72B91D68F"),
        new Guid("90A803E8-AF0B-E611-A0FA-54442FE8720D"),
        new Guid("934459D8-F8D2-400A-BB26-09DF181A5173"),
        new Guid("6909918E-C26D-E511-8067-005056B200B3"),
        new Guid("78807159-3BB1-E411-BE24-005056B200B3"),
        new Guid("BC84C5A7-DF27-4A17-A69B-19C1078BE76B"),
        new Guid("9D0FC7A2-C88B-4151-8707-7190D405F53F"),
        new Guid("9863A95B-0C7F-E511-B688-005056B200B3"),
        new Guid("DAD5F843-CD85-4B15-AE39-6D9780DE45B3"),
        new Guid("112F21BB-FC2F-422E-9734-A5798F7C8033"),
        new Guid("3D8FD3E0-629A-E511-B688-005056B200B3"),
        new Guid("3510BC4C-D93C-4529-B34C-62B1F664CECD"),
        new Guid("27FC1FCD-5F76-E511-B688-005056B200B3"),
        new Guid("79E40F87-DB86-E511-B688-005056B200B3"),
        new Guid("38633557-A1EB-4802-B39D-FEED5D5ED85D"),
        new Guid("DE86E93B-AAC1-E411-BE24-005056B200B3"),
        new Guid("BF1C1743-C94A-4F48-A84A-1CF3C57F679C"),
        new Guid("FD5F419C-5067-43B7-AF68-91DF55AB06E6"),
        new Guid("FAC0C716-38E3-4637-91F1-C91508622AE5"),
        new Guid("B4E9CF8B-692A-4C3D-8810-AE4C18026888"),
        new Guid("FBFF2836-E0A3-E511-B688-005056B200B3"),
        new Guid("CA047522-22D8-416A-B67F-203C3A6A4E0F"),
        new Guid("039A76AF-7958-E511-8067-005056B200B3"),
        new Guid("92E1A02F-9D7C-E511-B688-005056B200B3"),
        new Guid("0D5DB3B1-591E-4F47-910B-3EAA8C73677A"),
        new Guid("658F2823-B8BA-4503-B070-E61C9BFF1BD1"),
        new Guid("1D2AF16A-680D-41EE-A059-EBDFCB457471"),
        new Guid("CD6EAF0E-9EFA-4C54-91B3-F5D2CDF45D1B"),
        new Guid("4F6D48D1-78E4-4C5F-B943-6AFE40D655CB"),
        new Guid("5A910321-E653-4451-A787-318EFB4BEECC"),
        new Guid("3431DBEA-B0E2-E411-BE24-005056B200B3"),
        new Guid("71779944-A633-4EBD-8F0D-B3E7BC605FFE"),
        new Guid("DEBBF5EC-3352-E511-8067-005056B200B3"),
        new Guid("8113DCA4-8685-4FD4-8224-86F8B8F7F2D6"),
        new Guid("7029A285-4D3B-E511-BBAF-005056B200B3"),
        new Guid("BDEB8F74-73D3-4415-AD97-1F794AF080ED"),
        new Guid("5E99BF78-D0E1-434A-9D7D-E436356369DF"),
        new Guid("6E8F6DEF-02BC-E411-BE24-005056B200B3"),
        new Guid("D068C202-A504-4004-A073-12961FA7DF89"),
        new Guid("0BFC8B28-D629-4F58-BEA1-46BDE34531D7"),
        new Guid("075D58DD-AAEE-43F2-94D2-CABFE572D91A"),
        new Guid("0D549CF6-4698-474B-8707-55AD1069877E"),
        new Guid("02DF9110-FF82-E511-B688-005056B200B3"),
        new Guid("FD28FDAB-897B-43F0-873B-F007611687A6"),
        new Guid("A4B3E370-DA1F-4F5C-BC34-E90576152B7B"),
        new Guid("1F8956D2-9445-E511-BBAF-005056B200B3"),
        new Guid("FB167B9C-900F-444E-81D7-F736237BBDDC"),
        new Guid("868A4D5C-7CB0-E411-9446-54BAF6AB8D09"),
        new Guid("2449DA49-21BC-E411-BE24-005056B200B3"),
        new Guid("4617B350-BC49-4527-9106-1F438EA8954B"),
        new Guid("EEAEBBF3-F072-46AD-86DA-624AECF14EBD"),
        new Guid("A61F0DE2-2E25-44DC-986A-D20C02329A35"),
        new Guid("7A43617E-4613-476C-A94A-7BCD17238541"),
        new Guid("2B25178C-9873-46BB-9D84-B706592E5893"),
        new Guid("57683830-A411-4F88-B928-2C7AA5013DA0"),
        new Guid("7222EEF5-4922-E611-BF0D-005056B200B3"),
        new Guid("612C5D72-4CA3-4BB6-B272-1933C562A9B0"),
        new Guid("2B1C6302-2714-E511-B4D1-1458D0CB58F8"),
        new Guid("78A8F029-7AAE-4927-8792-9F84D19D4626"),
        new Guid("BE6E28B4-01E0-4BC1-BE5C-62557FE1E31F"),
        new Guid("28E50C76-E99F-4AC4-8AEF-6B70F9470792"),
        new Guid("D3415785-3533-4BB8-9C08-791BA890265B"),
        new Guid("0C51A5DB-17CB-492A-80FD-251F40C175AB"),
        new Guid("C1541D15-0E68-4790-9987-6BB310256B5F"),
        new Guid("DA5C70D1-EAC8-4AA9-9C78-0CB4757DE81A"),
        new Guid("2DD55508-7778-4ADB-8E05-5A2A11E7FECD"),
        new Guid("8B6890FD-CC47-E511-BBAF-005056B200B3"),
        new Guid("56C1F369-EDEF-424B-9A8E-5D4F7177B16E"),
        new Guid("F7AAEB4E-3BFF-4166-BC7A-3D90AAE50F56"),
        new Guid("5E4065B2-BAB2-E411-BE24-005056B200B3"),
        new Guid("4C512CC7-3CA4-41F1-ACA7-D1663649B644"),
        new Guid("8D82C7DA-6B38-4D41-BC5C-58255E27ADE6"),
        new Guid("75F0811C-8A04-4252-9911-219779E22491"),
        new Guid("96EC850C-3898-E511-B688-005056B200B3"),
        new Guid("0C0B0581-73EA-E411-BE24-005056B200B3"),
        new Guid("915D6C23-B88D-49BF-B831-9707DED58A8D"),
        new Guid("C1BA9912-2612-48EF-8D60-73E24C5C811F"),
        new Guid("21ADDB7D-4DD5-417B-8A02-EAD2B355AD67"),
        new Guid("2DD22AE0-03A5-4D95-A838-174C9AF0FEDA"),
        new Guid("D812801A-CAE4-462D-BD96-E593301D2532"),
        new Guid("72DDA1DA-A487-E511-B688-005056B200B3"),
        new Guid("27F738CF-4446-E511-BBAF-005056B200B3"),
        new Guid("553AB3F0-5E63-4DB0-BCAB-58F51452B715"),
        new Guid("68A5723F-9565-4734-BBA8-89F0D2CAC001"),
        new Guid("CB092AE7-7645-E511-BBAF-005056B200B3"),
        new Guid("F4F21E45-0597-4BD8-A243-643752FCEECB"),
        new Guid("CBD6CB00-9442-E511-BBAF-005056B200B3"),
        new Guid("3A9FF719-72F8-E411-BE24-005056B200B3")
    };

    protected override void InitializeCulture()
    {
        //var us = new UserSecurity();
        //us.WebServiceLogin(Guid.NewGuid().ToString(), "epos", "1");
        base.InitializeCulture();
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        //Random rnd = new Random();
        //Guid recId = new Guid("E1602A2B-3DEE-4C25-BA6A-FA49818D661A");
        ////recID[rnd.Next(105)];
        ////new Guid("6E8F6DEF-02BC-E411-BE24-005056B200B3");
        //try
        //{
        //    int worker;
        //    int MinWorkerThreads;
        //    int ioCompletion;
        //    int MinCompletionPortThreads;
        //    int workerThread;
        //    int completionThread;
        //    ThreadPool.GetMaxThreads(out worker, out ioCompletion);
        //    ThreadPool.GetMinThreads(out MinWorkerThreads, out MinCompletionPortThreads);
        //    ThreadPool.GetAvailableThreads(out workerThread, out completionThread);
        //    InfoLblMax.Text = "MaxWorker:" + worker + " MaxioCompletion: " + ioCompletion;
        //    InfoLblMin.Text = "MinWorker:" + MinWorkerThreads + " MinioCompletion: " + MinCompletionPortThreads;
        //    InfoLblThread.Text = "Worker:" + workerThread + " ioCompletion: " + completionThread;
        //    BlackListManager bManager = new BlackListManager();
        //    TransferService tService = new TransferService();
        //    var transfer = tService.Get(recId);
        //    transfer.SenderCorporationCountry = new TuFactory.Domain.Country();
        //    transfer.SenderCorporationCountry.CountryId = new Guid("0BFC8AF0-EDAC-482C-83C6-11D833A7A05B");
        //    bManager.GetTransferBlackListCheck(transfer);
        //}
        //catch
        //{
        //    throw;
        //}
    }
}



