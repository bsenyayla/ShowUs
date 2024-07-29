<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(idbTemsilciGISIslemlerBorsaIslemDefteriAl) %>
<!-- #include file="idb2000.inc" -->
<!-- #include file="no_cache.inc" -->
<html>
<head>
<meta http-equiv="Content-Language" content="tr">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Borsa İşlem Defteri Al</title>
<link rel="STYLESHEET" type="text/css" href="/idbstyles/idbform.css">
<STYLE>
   .userData {behavior:url(#default#userdata);}
</STYLE>
</head>
<%

        Function CheckFileName(filename, TARIH, SEANS, prefix, uyari, fileSize)
                if filename <> "" then
			olmasiGereken = prefix & SEANS & "_" & Mid(TARIH, 4,2) & Mid(TARIH, 1,2) & "."  & Session("IMKB_UYE_KODU")
			if filename <> olmasiGereken then
				Response.Clear
				Response.Write "<script> alert("" "& uyari &" Dosya adı geçersiz. \n Olması gereken "& olmasiGereken &"""); </script>"
				Response.End
			end if
                        if fileSize <= 0 then
				Response.Clear
				Response.Write "<script> alert("" "& uyari &" Dosyası boş. ""); </script>"
				Response.End
                        end if
                end if
        end function

	If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

		Set objFerrush = Server.CreateObject("uplweb.WebUploader")
		objFerrush.Parse(Request)
		ulusalFileName = objFerrush.FileName("ULUSAL")
		BolgeselFileName = objFerrush.FileName("BOLGESEL")
		GozaltiFileName = objFerrush.FileName("GOZALTI")
                tumemirFileName = objFerrush.FileName("TUM_EMIR")
                pasifFileName   = objFerrush.FileName("PASIF")

		TARIH = objFerrush.AsString("TARIH")
		SEANS = objFerrush.AsString("SEANS")
		ULUSAL = objFerrush.AsString("ULUSAL")
		BOLGESEL = objFerrush.AsString("BOLGESEL")
		GOZALTI = objFerrush.AsString("GOZALTI")
                TUM_EMIR = objFerrush.AsString("TUM_EMIR")
                PASIF    = objFerrush.AsString("PASIF")
		objFerrush.FreeResources
		Set objFerrush = Nothing
                call CheckFileName(ulusalFileName, TARIH, SEANS, "CU", "Ulusal", Len(ULUSAL))
                call CheckFileName(BolgeselFileName, TARIH, SEANS, "CB", "Bölgesel", Len(BOLGESEL))
                call CheckFileName(GozaltiFileName, TARIH, SEANS, "CW", "Gözaltı", len(GOZALTI))
                call CheckFileName(tumemirFileName, TARIH, SEANS, "TU", "Tüm Emir", len(TUM_EMIR))
                call CheckFileName(pasifFileName, TARIH, SEANS, "AU", "Pasif", len(PASIF))

		Set Conn = Server.CreateObject("ADODB.Connection")
		lngConnectionTimeout = Conn.ConnectionTimeout

		Conn.ConnectionTimeout = 600
		Conn.Open Session("ConnString")

		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		

		Cmd.CommandTimeOut = 600
		
				

		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_ALMA_KONTROL"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		Cmd.Parameters("@TARIH").Value = DateForSql(TARIH)
		Cmd.Parameters("@SEANS").Value = SEANS
		Cmd.Execute
		if Cmd.Parameters("@ERROR").Value <> "" then
		%><script>alert("<%=Cmd.Parameters("@ERROR").Value%>")</script><%
		Response.end
		end if
		
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_AL"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		Cmd.Parameters("@TARIH").Value = DateForSql(TARIH)
		Cmd.Parameters("@SEANS").Value = SEANS
		Cmd.Parameters("@ULUSAL").Value = ULUSAL
		Cmd.Parameters("@BOLGESEL").Value = BOLGESEL
		Cmd.Parameters("@GOZALTI").Value = GOZALTI

		Cmd.Parameters("@TUM_EMIR").Value = TUM_EMIR
		Cmd.Parameters("@PASIF").Value = PASIF

		Set Rs = Server.CreateObject("ADODB.Recordset")
		intResponseEnd = 0
		Set Rs = Cmd.Execute
		If (Rs.Bof And Rs.Eof) Then
		   Response.Clear
			Response.Write "<script> alert(""Borsa İşlem Defteri alınmıştır.""); window.close(); </script>"
			intResponseEnd = 1
		else
%>
<body>
<div align="center">
  <center>
<table table style="border-collapse: collapse; font-family: verdana; font-size: 8pt;" border="1" bordercolor="#CCCCCC" cellspacing="0" cellpadding="2">
  <tr>
    <th width="100%" colspan="2" align="center">
      <p align="center"><font color="#FF0000">Açılmayan menkul kodları var, defter aktarılmamıştır</font></th>
  </tr>
  <tr>
    <th width="50%" align="center">
      <p align="center">IMKB Kodu</p>
    </th>
    <th width="50%" align="center">
      <p align="center">Grup Kodu</p>
    </th>
  </tr>

<%
				Do While Not Rs.Eof
%>			
  <tr>
    <td width="50%" align="center"><%= rs("IMKB_KODU")%></td>
    <td width="50%" align="center"><%= rs("GRUP_KODU")%></td>
  </tr>
<% 			
				Rs.MoveNext
				Loop
		End if
		Rs.Close
		set Rs = Nothing
		set cmd = Nothing
		conn.Close
		set conn = Nothing
		if intResponseEnd = 1 then Response.End
%>
</table>
  </center>
</div>
<%
 else
	TARIH = GetGlobalDegisken("TARIH")
%>
<body onload="windowLoad()">
<DIV CLASS=userData ID="oPersistDiv">
</DIV>

<script>
function sd(what)
{
	event.srcElement.select();
	var TARIH = idbForm.TARIH.value, SEANS =  idbForm.SEANS1.checked ? '1' : '2', DATA_DIRECTORY = idbForm.DATA_DIRECTORY.value;
	if (TARIH.length == 10)
	{
		if (DATA_DIRECTORY.length > 0 )
		{
			if (DATA_DIRECTORY.lastIndexOf('\\', DATA_DIRECTORY.length) != DATA_DIRECTORY.length-1) 
			{
			DATA_DIRECTORY = DATA_DIRECTORY + '\\'
			}
			a = new String(TARIH.substr(3,2));
			b = new String(TARIH.substr(0,2));
			DATA_DIRECTORY = DATA_DIRECTORY + what + SEANS + '_' + a + b + '.<%=Session("IMKB_UYE_KODU")%>';
			if (SEANS == '1' &&  what == 'CW') {DATA_DIRECTORY = "";}
			window.clipboardData.setData("Text", DATA_DIRECTORY);
		}
	}
	
}
function submitform()
{
	oPersistDiv.setAttribute("sPersistValue",idbForm.DATA_DIRECTORY.value);
	oPersistDiv.save("oXMLStore");
	return true;
}
function windowLoad()
{
	oPersistDiv.load("oXMLStore");
	idbForm.DATA_DIRECTORY.value=oPersistDiv.getAttribute("sPersistValue");
        if(idbForm.DATA_DIRECTORY.value=="null") idbForm.DATA_DIRECTORY.value = ""

}
</script>
<form id="idbForm" class="check" method="POST" action="borsa_islem_defteri_al.asp" enctype="multipart/form-data" onsubmit="submitform()">
  <center>
  <div align="center">
	<div style="color:black; background-color:#0099CC; border: 1px solid #FF0000; padding: 0">
	<p>
	<b>Data klasörünü bir defa girdikten sonra<br>
	dosya girişlerinin üzerinde yapıştır( paste [ CTRL+V ] ) yapabilirsiniz.
        <br>Data klasör adresi şu an kullandığınız bilgisayara kaydedilir.
        </b>
        </p>
	</div>
  <table id="idbFormTable" border="0">
    <caption><nobr>Borsa İşlem Defteri Al</nobr></caption>
    <tr>
      <td>Tarih</td>
      <td><input required="true" class="date" maxlength=10 type="text" id="TARIH" name="TARIH" size="12" value="<%= TARIH%>"></td>
    </tr>
    <tr>
      <td>Seans</td>
      <td><%= CreateRadioStr("SEANS", "1;1.Seans;2;2.Seans", "1")%></td>
    </tr>
    <tr>
	<td>Data Klasörü</td>
	<td><input id="DATA_DIRECTORY" name="DATA_DIRECTORY" type="directory"></td>
    </tr>
    <tr>
        <td colspan=2>
        <fieldset><legend>Gerçekleşen (Aktif) İşlemler</legend>
        <table>
        <tr>
          <td>Ulusal</td>
          <td><input type="file" name="ULUSAL" size="32" id="ULUSAL" onfocus="sd('CU')"></td>
        </tr>
        <tr>
          <td>Bölgesel</td>
          <td><input type="file" name="BOLGESEL" size="32" onfocus="sd('CB')"></td>
        </tr>
        <tr>
          <td>Gözaltı Aktif</td>
          <td><input type="file" id="GOZALTI" name="GOZALTI" size="32" onfocus="sd('CW')"></td>
        </tr>
        </table>
        </fieldset>
        </td>
    </tr>
    <tr>
        <td colspan=2>
        <fieldset><legend>Pasif & Ordino</legend>
        <table>
        <tr>
          <td>Tüm Emirler</td>
          <td><input type="file" name="TUM_EMIR" size="32" id="TUM_EMIR" onfocus="sd('TU')"></td>
        </tr>
        <tr>
          <td>Pasif</td>
          <td><input type="file" name="PASIF" size="32" onfocus="sd('AU')"></td>
        </tr>
        </table>
        </fieldset>
        </td>
    </tr>

    <tr>
      <td colspan="2" align="center">&nbsp;<input type="submit" value="Dosyaları Al" name="B1"></td>
    </tr>
  </table>
    </center>
  </div>
</form>
<% 
	end if
%>
</body>

</html>


