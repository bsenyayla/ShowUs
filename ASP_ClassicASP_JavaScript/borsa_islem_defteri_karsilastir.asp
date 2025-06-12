<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(idbTemsilciGISIslemlerBorsaGISKarsilastirma) %>
<!-- #include file="idb2000.inc" -->
<!-- #include file="no_cache.inc" -->
<%
	foMENKUL_KODU = 0
	foFIYAT = 1
	foIMKB_ALIS = 2
	foGIS_ALIS = 3
	foIMKB_SATIS = 4
	foGIS_SATIS = 5
	foBROKER = 6
	
	showrows = false

	if Request.ServerVariables("REQUEST_METHOD") = "POST" then
	
		ISLEM_TARIHI = Request.Form("ISLEM_TARIHI")
		SEANS = Request.Form("SEANS")
		BROKER_FILTRESI = Request.Form("BROKER_FILTRESI")
		MENKUL_NO = Request.Form("MENKUL_NO")
		
		Session("GLOBAL_TARIH") = ISLEM_TARIHI
	
		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Session("ConnString")
					
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_KARSILASTIR"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		
		Cmd.Parameters("@ISLEM_TARIHI").Value = DateForSql(ISLEM_TARIHI)
		Cmd.Parameters("@SEANS").Value = SEANS
		Cmd.Parameters("@BROKER_FILTRESI").Value = BROKER_FILTRESI
		Cmd.Parameters("@MENKUL_NO").Value = MENKUL_NO
%>		
<!-- #include file="printredir.inc" -->
<%
		Set Rs = Server.CreateObject("ADODB.Recordset")
		Set Rs = Cmd.Execute
					
		if not (Rs.Bof and Rs.Eof) then
			rows = Rs.GetRows
			showrows = true
		end if
		
		Rs.Close
		Set Rs = Nothing
		Set Cmd = Nothing
		Conn.Close
		Set Conn = Nothing
	end if
%>

<html>

<head>
<meta http-equiv="Content-Language" content="tr">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<META HTTP-EQUIV="Expires" CONTENT="0">
<title>Borsa Ýþlem Defteri Karþýlaþtýr</title>
<link rel="STYLESHEET" type="text/css" href="/idbstyles/idbform.css">
</head>

<body>
<%
	if Request.ServerVariables("REQUEST_METHOD") <> "POST" then
		SetGVFromParam()
		if Session("GLOBAL_ISLEM_TARIHI") <> "" then 
			ISLEM_TARIHI = Session("GLOBAL_ISLEM_TARIHI")
		else
			ISLEM_TARIHI = GetGlobalDegisken("TARIH")
		end if
%>
<form id="idbForm" class="check" method="POST" action="borsa_islem_defteri_karsilastir.asp">
  <div align="center">
    <center>
  <table id="idbFormTable" border="0">
    <caption><nobr>Borsa Ýþlem Defteri Karþýlaþtýr</nobr></caption>
    <tr>
      <td><label>Ýþlem Tarihi</label></td>
      <td><input class="date" required="true" maxlength=10 type="text" name="ISLEM_TARIHI" value="<%= ISLEM_TARIHI %>" size="12"></td>
    </tr>
    <tr>
      <td>Seans</td>
      <td><%= CreateRadioStr("SEANS", "0;Hepsi;1;1.Seans;2;2.Seans", "0")%></td>
    </tr>
    <tr>
      <td>Broker Filtresi</td>
      <td><%= ComboOlustur("BROKER", "BROKER_FILTRESI", "0;Broker'a göre gruplama;-1;Broker'a göre grupla")%></td>
	</tr>
    <tr>
      <td>Menkul</td>
      <td><%= CreateCombo("HS_MENKUL_NO", "MENKUL_NO", "0;Hepsi", "0")%></td>
    </tr>
<!-- #include file="printdest.inc" -->
    <tr>
      <td colspan="2" align="right">&nbsp;<input type="submit" value="Ýþlemi Gerçekleþtir" name="B1"></td>
    </tr>
  </table>
    </center>
  </div>
</form>
<%
	else 'post
%>
<%
		if showrows then
%>
<div align="center">
  <center>
  <table border="1" style="border-collapse: collapse; font-family: verdana; font-size: 10pt;" cellspacing="1" cellpadding="2">
    <tr style="background-color: activecaption; color: captiontext; font-size: 7pt; font-weight: bold; text-align: center;">
      <td colspan="7"><%= ISLEM_TARIHI%> TARÝHLÝ BORSA ÝÞLEM DEFTERÝ KARÞILAÞTIRMASI</td>
    </tr>
    <tr style="background-color: activecaption; color: captiontext; font-weight: bold; text-align: center;">
      <td>Menkul</td>
      <td>Fiyat</td>
      <td>ÝMKB Alýþ</td>
      <td>GÝÞ Alýþ</td>
      <td>ÝMKB Satýþ</td>
      <td>GÝÞ Satýþ</td>
      <td>Broker</td>
    </tr>
<%
		oncekiMenkul = rows(foMENKUL_KODU, 0)
		bgColor = "#ffffff"
		for i = 0 to UBound(rows, 2)
			If oncekiMenkul <> rows(foMENKUL_KODU, i) Then
				oncekiMenkul = rows(foMENKUL_KODU, i)
				If bgColor = "#ffffff" Then bgColor = "#eeeeee" Else bgColor = "#ffffff"
			End If
%>  
    <tr style="background-color=<%= bgColor%>;">
      <td><%= rows(foMENKUL_KODU, i)%></td>
      <td align="right"><%= FormatNumber(rows(foFIYAT, i), 0, True)%></td>
      <td align="right"><%= FormatNumber(rows(foIMKB_ALIS, i), 0, True)%></td>
      <td align="right"><%= FormatNumber(rows(foGIS_ALIS, i), 0, True)%></td>
      <td align="right"><%= FormatNumber(rows(foIMKB_SATIS, i), 0, True)%></td>
      <td align="right"><%= FormatNumber(rows(foGIS_SATIS, i), 0, True)%></td>
      <td><%= Trim(rows(foBROKER, i))%></td>
    </tr>
<%
		next
%>
  </table>
  </center>
</div>
<%
		else 'show_rows
%>
<p align="center"><font face="Verdana" size="1"><b>BORSA ÝÞLEM DEFTERÝ KARÞILAÞTIR<br>Raporlanacak kayýt bulunamadý!</b></font></p>
<%
		end if 'show_rows
%>
<%
	end if 'post
%>

</body>

</html>
