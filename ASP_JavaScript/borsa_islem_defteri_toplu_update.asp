<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(idbTemsilciGISIslemlerBorsaIslemDefteriAktar) %>
<!-- #include virtual="/idb/fake_sql.inc" -->
<!-- #include virtual="/idb/util/smart.inc" -->
<%
	On Error Resume Next
	If Request.ServerVariables("REQUEST_METHOD") = "POST" Then
		recordCount = Request.Form("recordCount")
		
		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Session("ConnString")
		
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_TOPLU_UPDATE"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh

		For i = 1 To recordCount
			If Request.Form("musteriNo" & i) <> "" Then
				Cmd.Parameters("@TARIH").Value = DateForSql2000(Request.Form("islemTarihi"))
				Cmd.Parameters("@SEANS").Value = Request.Form("seans")
				Cmd.Parameters("@BROKER").Value = Request.Form("broker" & i)
				Cmd.Parameters("@MUSTERI_KODU").Value = Request.Form("musteriKodu" & i)
				Cmd.Parameters("@MUSTERI_NO").Value = Request.Form("musteriNo" & i)
				'Response.Write "<p>" & DateForSql2000(Request.Form("islemTarihi")) & "; " & Request.Form("seans") & "; " & Request.Form("broker" & i) & "; " & Request.Form("musteriKodu" & i) & "; " & Request.Form("musteriNo" & i) & "</p>"
		
				Cmd.Execute
			End If
		Next
		
		Set Cmd = Nothing
		
		Conn.Close
		Set Conn = Nothing
	End If
%>
<html>

<head>
<meta http-equiv="Content-Language" content="tr">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Borsa Ýþlem Defteri Toplu Güncelleme</title>
<script defer language="JavaScript">

	function winLoad() {
		if (parent) {
			parent.idbForm2.btnSubmit.disabled = false;
		}
	}
</script>	
</head>

<body onload="winLoad()">
</body>
</html>
