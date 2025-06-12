<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(708)%>
<!-- #include virtual="/idb/idb2000.inc" -->
<!-- #include virtual="/idb/fake_sql.inc" -->
<!-- #include virtual="/idb/no_cache.inc" -->
<!-- #include virtual="/idb/util/smart.inc" -->
<!-- #include virtual="/idb/flusher.inc"-->
<%
	If Request.ServerVariables("REQUEST_METHOD") = "POST" Then

		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Session("ConnString")
					
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_ACIGA_SATIS_ANALIZI"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		Cmd.Parameters("@TARIH").Value = ConvertDate(Request("islemTarihi"))
		Cmd.Parameters("@TO_TARIH").Value = ConvertDate(Request("islemTarihi"))
		Cmd.Parameters("@DETAY_DATA").Value = Request("DETAY_DATA")
		Cmd.Parameters("@SADECE_ACIKLARI_GOSTER").Value = 3
		Cmd.Execute
		Cmd.Parameters("@DETAY_DATA").Value = ""
		Cmd.Parameters("@SADECE_ACIKLARI_GOSTER").Value = 2
%>
<!-- #include virtual="/idb/printredir.inc" -->
<%
		Set Cmd = Nothing

		Conn.Close
		Set Conn = Nothing
		Response.Clear
		Response.Write "<script>window.close();</script>"
		Response.End
	Else
		DetayData = Replace(Request.Form("DETAY_DATA"),",","")
		islemTarihi = Request.Form("islemTarihi")
		if islemTarihi = "" Then islemTarihi = Date
	End If
%>
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 6.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Borsa Islem Defteri Açiga Satis</title>
<link rel="STYLESHEET" type="text/css" href="/idb/idb/idbglobal.css">
<style>
	select {
		font-family: verdana;
		font-size: 8pt;
	}
	button {
		font-family: verdana;
		font-size: 8pt;
	}
</style>
<%
	If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
<script>
	function winLoad() {
		window.moveTo(0, 0);
		window.resizeTo(screen.availWidth, screen.availHeight);
	}
</script>
</head>

<body onload="winLoad()">
<% 	If Session("CONTENT_DESTINATIONS") <> "" Then %>
<div align="center">
  <center>
<form id="printForm" method="POST" action="kredi_ozkaynak_tamamlama_formu.asp">
<input type="hidden" name="C" value="<%= MusteriNo%>">
<input type="hidden" name="islemTarihi" value="<%= islemTarihi%>">
<!-- #include virtual="/idb/printdest.inc" -->
<button onclick="printForm.submit();">Yazdir</button>
</form>
  </center>
</div>
<script defer language="JavaScript">
	printForm.CONTENT_DESTINATION.remove(0);
	printForm.CONTENT_DESTINATION.selectedIndex = 0;
</script>
<% End If %>
<%
	
	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Session("ConnString")
	
	Set Cmd = Server.CreateObject("ADODB.Command")
	Set Cmd.ActiveConnection = Conn
	Cmd.CommandText = "BORSA_ISLEM_DEFTERI_ACIGA_SATIS_ANALIZI"
	Cmd.CommandType = adCmdStoredProc
	Cmd.Parameters.Refresh

	Cmd.Parameters("@TARIH").Value = islemTarihi
	Cmd.Parameters("@DETAY_DATA").Value = DetayData
	Cmd.Parameters("@SADECE_ACIKLARI_GOSTER").Value = 2

	Set Rs = Server.CreateObject("ADODB.Recordset")
	Set Rs = Cmd.Execute
%>

<div align="center">
  <center>
  <table border="1" width="100%" bordercolor="#000000" cellspacing="0" cellpadding="2" style="TABLE-LAYOUT:fixed; border-collapse:collapse;">
    <tr>
      <td valign="middle" align="center" height="36"><font face="Times New Roman" size="3"><b>ÖZKAYNAK TAMAMLAMA ÇAGRI FORMU</b></font></td>
    </tr>
  </table>
  </div>
</center>
  <table border="1" width="100%" bordercolor="#000000" cellspacing="0" cellpadding="2" style="TABLE-LAYOUT:fixed; border-collapse:collapse;">
    <tr>
      <td valign="middle" align="center" height="36"><font face="Times New Roman" size="2">(KREDILI MENKUL KIYMET,AÇIGA SATIS,MENKUL KIYMETLERI ÖDÜNÇ ALMA VERME ISLEMLERI)</font></td>
    </tr>
  </table>
<%
	Do While CheckResponseFlush(Rs, 1000)
%>
  <table border="1" style="font-family: verdana; font-size: 8pt; border-collapse: collapse;" width="100%">
    <tr style="text-align: center; font-weight: bold;"></tr>
    
  <tr style="text-align: center; font-weight: bold;">
    <td width="55%" align="left"><b>MÜSTERI NO</b></td>
    <td width="30%" align="right" style="background-color: #ccffcc"><b><%= Rs("MUSTERI_NO")%></b></td>
    <td width="15%">&nbsp;</td> 
  </tr>
  <tr style="text-align: center; font-weight: bold;">
    <td width="55%" align="left"><b>HESAP SAHIBININ ADI SOYADI</b></td>
    <td width="30%" align="right" style="background-color: #ccffcc"><b><%= Rs("UNVANI")%></b></td>
    <td width="15%">&nbsp;</td> 
  </tr>
  <tr style="text-align: center; font-weight: bold;">
    <td width="55%" align="left"><b>MENKUL</b></td>
    <td width="30%" align="right" style="background-color: #ccffcc"><b><%= Rs("MENKUL_KODU")%></b></td>
    <td width="15%">&nbsp;</td> 
  </tr>
  <tr style="text-align: center; font-weight: bold;">
    <td width="55%" align="left"><b>MIN. STOK</b></td>
    <td width="30%" align="right" style="background-color: #ccffcc"><b><%= FormatNumber(Rs("MIN_STOK"), 0, True)%></b></td>
    <td width="15%">&nbsp;</td> 
  </tr>
<%
		Rs.MoveNext
	Loop

	Rs.Close
	Set Rs = Nothing
		
	Set Cmd = Nothing
		
	Conn.Close
	Set Conn = Nothing
	
	end if
%>
</table>
  </center>

</body>












































































