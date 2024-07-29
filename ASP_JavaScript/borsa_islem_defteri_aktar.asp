<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(idbTemsilciGISIslemlerBorsaIslemDefteriAktar) %>
<!-- #include virtual="/idb/fake_sql.inc" -->
<!-- #include virtual="/idb/util/smart.inc" -->
<!-- #include virtual="/idb/idb/takvim.inc" -->
<html>

<head>
<meta http-equiv="Content-Language" content="tr">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<META HTTP-EQUIV="Expires" CONTENT="0">
<link rel="STYLESHEET" type="text/css" href="idbglobal.css">
<title>Borsa İşlem Defteri Aktar</title>
<style>
	input {
		font-family: verdana;
		font-size: 8pt;
	}
	select {
		font-family: verdana;
		font-size: 8pt;
	}
	button {
		font-family: verdana;
		font-size: 8pt;
	}
	td {
		font-family: verdana;
		font-size: 8pt;
	}
</style>
<% Server.ScriptTimeout = 600 %>
<script defer language="JavaScript">

	function winLoad() {
<% 	If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then %>
		idbForm.islemTarihi.focus();
<% End If %>
	}
	
	function winKeys() {
		if (event.keyCode == 27) {
			idbForm.musteriNo.value = "";
			window.close();
		}
		if (keyPressed) {
			labelWarning.innerText = "";
			keyPressed = false;
		}
	}
	function working() {
		if (labelProgress.innerText != "") labelProgress.innerText = ""; 	else labelProgress.innerText = "İşlem Gerçekleştiriliyor...";
	}
	
	function checkForm() {
		if (idbForm.islemTarihi.value == "") { alert("İşlem tarihini boş bırakamazsınız!"); idbForm.islemTarihi.focus(); idbForm.islemTarihi.select(); return false; }
		idbForm.btnSubmit.disabled = true;
		return true;
	}
	
	function checkForm1() {
		idbForm1.btnSubmit.disabled = true;
		return true;
	}
	function formKeys() {
		if ((event.keyCode == 13) && (event.ctrlKey) && (!idbForm.btnSubmit.disabled)) { event.returnValue = false; idbForm.btnSubmit.click(); return; }
		if (event.keyCode == 13) if (event.srcElement.type != "submit") event.keyCode = 9;
	}
	
	function validateForm() {
		if (idbForm.islemTarihi.value == "__/__/____") { alert("İşlem Tarihi Girmelisiniz!"); idbForm.islemTarihi.focus(); return false; }
		return true;
	}

	function idbLookupMusteriArguments() {
		var no;
		var unvan;
	}

	function idbLookupMusteri() {
		var sFeatures = "center: yes; scroll: no; status: no; help: no; dialogHeight: 240px; ";
		if (screen.availWidth > 720) sFeatures += "dialogWidth: 720px;"; else sFeatures += "dialogWidth: 600px;";
		idbLookupMusteriArguments.no = event.srcElement.value;
		window.showModalDialog("/idb/util/idbLookupMusteri.asp?musteriNo=" + event.srcElement.value, idbLookupMusteriArguments, sFeatures);
		event.srcElement.value = idbLookupMusteriArguments.no;
	}
	
	function processMusteriInputKeys() {
		switch (event.keyCode) {
			case   8: break; case  9: break; case 13: break; case 27: break;
			case  35: break; case 36: break; case 37: break; case 39: break; case 46: break;
			case  48: break; case 49: break; case 50: break; case 51: break; case 52: break;
			case  53: break; case 54: break; case 55: break; case 56: break; case 57: break;
			case  32: 	event.returnValue = false; idbLookupMusteri(); 	break;
			case  96: break; case  97: break; case  98: break; case  99: break; case 100: break;
			case 101: break; case 102: break; case 103: break; case 104: break; case 105: break;
			case 107: if(event.srcElement.value != '') event.srcElement.value = event.srcElement.value + "000"; event.returnValue = false; break;
			default: event.returnValue = false; break;
		}
	}
	
</script>
</head>

<body onload="winLoad()">
<%
	If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
<%
	islemTarihi = ConvertDate(Date)
	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Session("ConnString")
	Set Cmd = Server.CreateObject("ADODB.Command")
	Set Cmd.ActiveConnection = Conn
	Cmd.CommandText = "GIS_VALOR_KONTROL"
	Cmd.CommandType = adCmdStoredProc
	Cmd.Parameters.Refresh
	Cmd.Parameters("@ISLEM_TARIHI").Value = DateForSql2000(islemTarihi)
	Cmd.Parameters("@SEANS").Value = Request.Form("seans")
	Cmd.Execute
	ReturnValues = ConvertDate(Cmd.Parameters("@RETURN_VALUE").Value)
	Set Cmd = Nothing
	Conn.Close
	Set Conn = Nothing
%>

<form id="idbForm" method="POST" action="borsa_islem_defteri_aktar.asp" onkeydown="formKeys()" onsubmit="return checkForm()">
<div align="center">
  <center>
<table border="1" style="border-collapse: collapse;">
  <tr>
    <td class="header">Borsa İşlem Defteri Aktar</td>
  </tr>
  <tr>
    <td>
    
<div align="center">
  <center>
    
<table border="0">
  <tr>
    <td nowrap>İşlem Tarihi</td>
    <td nowrap><input type="text" class="date" id="islemTarihi" name="islemTarihi" size="12" maxlength="10" value="<%= ConvertDate(Date)%>">
   	 <input tabindex="-1" type=button value=" ? " class=takvimbtn onclick="islemTarihi.value=openPopUpTakvim(islemTarihi.value);" title="Takvim"></td>
  </tr>
<%
		sonAn = Time
		sureAsimi = False
		If sonAn > CDate("14:00") Then
			seans="2"
		Else 	
			seans="1"
		End If	
%>
  <tr>
    <td nowrap>Seans</td>
    <td nowrap><%= SmartComboStr("seans", "1;1.Seans;2;2.Seans", seans)%></td>
  </tr>
  <tr>
    <td nowrap>Aktarılacak Broker</td>
    <td nowrap><%= SmartCombo("BROKER", "BROKER", "0;Hepsi", "" )%></td>
  </tr>
  <tr>
    <td nowrap align="right"><input type="checkbox" checked id="ExapiAktarma" name="ExapiAktarma" value="1"></td>
    <td nowrap>Exapi Brokerını Aktarma</td>
  </tr>
  <tr>
    <td colspan="2" nowrap align="center">Broker-Müşteri Eşlemeleri</td>
  </tr>
  <tr>
    <td colspan="2" nowrap>

    <table border="0" style="font-family: verdana; font-size: 8pt;">
      <tr>
        <td class="header">Broker (Kod)</td>
        <td class="header"></td>
        <td class="header">Müşteri No</td>
      </tr>
<%
	Set Conn = Server.CreateObject("ADODB.Connection")
	Conn.Open Session("ConnString")
	
	Set Cmd = Server.CreateObject("ADODB.Command")
	Set Cmd.ActiveConnection = Conn
	Cmd.CommandText = "SpKodToAciklama"
	Cmd.CommandType = adCmdStoredProc
	Cmd.Parameters.Refresh
	
	Cmd.Parameters("@KullanimKodu").Value = 2
	Cmd.Parameters("@AlanAdi").Value = "BROKER"

	Set Rs = Cmd.Execute
	brokerSayisi = 0
	Do While Not Rs.Eof
		brokerSayisi = brokerSayisi + 1
%>
      <tr>
        <td><%= Rs(1).Value %> (<%= Rs(0).Value %>)</td>
        <td>=</td>
        <td><input type="text" id="musteriNox<%= brokerSayisi%>" name="musteriNox<%= brokerSayisi%>" size="15" maxlength="10" style="text-align: right;" onkeydown="processMusteriInputKeys()" value="" title="Müşteri listesinden seçmek için boşluk (space) tuşuna basınız...">
            <input type="hidden" id="brokerNox<%= brokerSayisi%>" name="brokerNox<%= brokerSayisi%>" value="<%= Rs(0).Value %>">
        </td>
      </tr>
<%
		Rs.MoveNext
	Loop
	
	Rs.Close
	Set Rs = Nothing
	
	Set Cmd = Nothing
	
	Conn.Close
	Set Conn = Nothing
%>
    </table>
    </td>
  </tr>
  <tr>
    <td nowrap align="right"><input type="checkbox" id="oncekilerisil" name="oncekilerisil" value="1"></td>
    <td nowrap>Önceki Kayıtları Sil</td>
  </tr>
  <tr>
    <td colspan="2" align="center"><input type="submit" id="btnSubmit" value="İşlemi Gerçekleştir"></td>
  </tr>
</table>
  </center>
</div>
    </td>
  </tr>
</table>
  </center>
</div>
<input type="hidden" name="gozardiEt" value="0">
<input type="hidden" name="musteriSayisi" value="0">
<input type="hidden" name="brokerSayisi" id="brokerSayisi" value="<%= brokerSayisi%>">
</form>

<%
	Else 'post
		musteriMusteri = Request.Form("musteriMusteri")
		oncekilerisil = Request.Form("oncekilerisil")		
		ExapiAktarma = Request.Form("ExapiAktarma")		
		broker = Request.Form("BROKER")		
		If Request.Form("brokerSayisi") <> "" Then
			brokerMusteri = ""
			For i = 1 to ConvertNumeric(Request.Form("brokerSayisi"))
				brokerMusteri = brokerMusteri & Request.Form("brokerNox" & i) & "=" & Replace(Request.Form("musteriNox" & i), ",", "") & ","
			Next
			If brokerMusteri <> "" Then brokerMusteri = Left(brokerMusteri, Len(brokerMusteri) - 1)
		Else
			brokerMusteri = Request.Form("brokerMusteri")
		End If
		
		For i = 1 To ConvertNumeric(Request.Form("musteriSayisi"))
			If Request.Form("MusteriNo" & i) <> "" Then
				musteriMusteri = musteriMusteri & "|" & Request.Form("broker" & i) & "," & Request.Form("musteriKodu" & i) & "," & ConvertNumeric(Request.Form("MusteriNo" & i))
			End If
		Next
		If Left(musteriMusteri, 1) = "|" Then musteriMusteri = Right(musteriMusteri, Len(musteriMusteri) - 1)
		
		If oncekilerisil Then oncekilerisil = 1 Else oncekilerisil = 0
		If ExapiAktarma Then ExapiAktarma = 1 Else ExapiAktarma = 0
		
		If ReturnValues = 1 Then 
				Response.Write "<script> alert(""İlgili Gün Valörlü !!.""); window.close();</script>"
				Response.end

		End If

	
		Set Conn = Server.CreateObject("ADODB.Connection")
		lngConnectionTimeout = Conn.ConnectionTimeout
		Conn.ConnectionTimeout = 600
		Conn.Open Session("ConnString")
		

		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		
		
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_ALMA_KONTROL"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		Cmd.Parameters("@TARIH").Value = DateForSql2000(Request.Form("islemTarihi"))
		Cmd.Parameters("@SEANS").Value = Request.Form("seans")
		Cmd.Execute
		if Cmd.Parameters("@ERROR").Value <> "" then
		%><script>alert("<%=Cmd.Parameters("@ERROR").Value%>")</script><%
		Response.end
		end if
		
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_AKTAR"
		Cmd.CommandType = adCmdStoredProc
		Cmd.CommandTimeout = 600
		Cmd.Parameters.Refresh
		
		Cmd.Parameters("@ISLEM_TARIHI").Value = DateForSql2000(Request.Form("islemTarihi"))
		Cmd.Parameters("@SEANS").Value = Request.Form("seans")
		Cmd.Parameters("@MUSTERI_KODU_BULUNMAYANLARI_GOZARDI_ET").Value = Request.Form("gozardiEt")
		Cmd.Parameters("@BROKER_MUSTERILERI").Value = brokerMusteri
		Cmd.Parameters("@ONCESIL").Value = ConvertNumeric(oncekilerisil)
		Cmd.Parameters("@MUSTERI_CONVERT").Value = Replace(musteriMusteri, "|", vbCrLf)
		Cmd.Parameters("@BROKER_FILTRESI").Value = broker
		Cmd.Parameters("@EXAPI_AKTARILMASIN").Value = ExapiAktarma

		Set Rs = Cmd.Execute
		lngRETVAL = 0
		if Rs.State = adStateClosed then
			lngRETVAL = CLng(Cmd.Parameters("@RETURN_VALUE").value	)
			if lngRETVAL <> 0 then
				Set Rs = Nothing
				Set Cmd = Nothing
				Conn.Close
				Set Conn = Nothing
				if lngRETVAL = 2 then
					Response.Write "<script> alert(""Seans Kilitli""); window.close();</script>"
					Response.end
				end if
				if lngRETVAL = 1 then
					Response.Write "<script> alert(""Bu Tarihe Valor Yapılmış !""); window.close();</script>"
					Response.end
				end if
				if lngRETVAL = 11 then
					Response.Write "<script> alert(""FON KAPANIŞLARI YAPMIŞ BU YÜZDEN Kayıtlar Eklenemez""); window.close();</script>"
					Response.end
				end if
				if lngRETVAL = 1000 then
                    ' portfoy işlemlerini aktarmayı unuttularsa diye
    				Response.Write "<script> alert(""Önce Portföy İşlemlerini Aktarmalısınız""); window.close();</script>"
					Response.end
				end if

			end if
		end if 

		
		If Not (Rs.Bof And Rs.Eof) Then
			'musteri numarasi yanlis olan kayitlar var
			'Response.Write "<p>" & brokerMusteri & "</p>"
%>
<p align="center"><b><font color="#ff0000">İşlem gerçekleştirilemedi!</font><br>Aşağıdaki müşteri kodları müşteri tablosu ile eşleştirilemedi!</b></p>

<form id="idbForm1" method="POST" action="borsa_islem_defteri_aktar.asp" onkeydown="formKeys()" onsubmit="return checkForm1()">
<div align="center">
  <center>
<table border="1" style="border-collapse: collapse; font-family: verdana; font-size: 8pt;">
  <tr style="text-align: center; font-weight: bold; background-color: #dddddd;">
    <td nowrap>Broker</td>
    <td nowrap>Müşteri Kodu</td>
    <td nowrap>Müşteri No</td>
    <td nowrap>Kayıt Sayısı</td>
<!--    <td nowrap>Açıklama</td>-->
  </tr>
<%
		Dim i
		i = 0
		Do While Not Rs.Eof
			i = i + 1
%>
  <tr>
    <td nowrap><%= Rs("BROKER")%></td>
    <td nowrap style="text-align: right;"><%= Rs("MUSTERI_NO")%>&nbsp;</td>
    <td nowrap style="text-align: right;"><input type="text" id="musteriNo<%= i%>" name="musteriNo<%= i%>" size="15" maxlength="10" style="text-align: right;" onkeydown="processMusteriInputKeys()" value="" title="Müşteri listesinden seçmek için boşluk (space) tuşuna basınız..."></td>
    <td nowrap style="text-align: right;"><%= Rs("SAYI")%>&nbsp;</td>
  </tr>

  <input type="hidden" name="broker<%= i%>" value="<%= Rs("BROKER")%>">
  <input type="hidden" name="musteriKodu<%= i%>" value="<%= Rs("MUSTERI_NO")%>">
<%
			Rs.MoveNext
		Loop
%>
  <tr>
    <td colspan="5" align="center"><input type="submit" id="btnSubmit" value="Borsa İşlem Defterini aktar" style="width: 320px"></td>
  </tr>
</table>

  </center>
</div>
<input type="hidden" name="BROKER" value="<%= broker%>">
<input type="hidden" name="oncekilerisil" value="<%= oncekilerisil%>">
<input type="hidden" name="ExapiAktarma" value="<%= ExapiAktarma%>">
<input type="hidden" name="musteriSayisi" value="<%= i%>">
<input type="hidden" name="islemTarihi" value="<%= Request.Form("islemTarihi")%>">
<input type="hidden" name="seans" value="<%= Request.Form("seans")%>">
<input type="hidden" name="brokerMusteri" value="<%= brokerMusteri%>">
<input type="hidden" name="musteriMusteri" value="<%= musteriMusteri%>">
<input type="hidden" name="gozardiEt" value="0">
</form>
<div><center><button id="btnDikkatsizAktar" style="width:520px; color: red;" onclick="idbForm1.gozardiEt.value = '1'; idbForm1.submit(); btnDikkatsizAktar.disabled = true; idbForm1.btnSubmit.disabled = true;"> Borsa İşlem Defterini müşteri numarası doğruluğunu dikkate almadan aktar!</button></center></div>

<script language="JavaScript">
	idbForm1.musteriNo1.focus();
</script>
<%
		Else
			'islem gerceklesitirildi.
%>
<p align="center">İşlem gerçekleştirilmiştir.</p>
<p align="center"><button onclick="window.close();">Pencereyi Kapat</button></p>
<%
		End If
		
		Rs.Close
		Set Rs = Nothing
		
		Set Cmd = Nothing

		Conn.Close
		Set Conn = Nothing
%>
<%
	End If
%>
<iframe id="ifrSave" name="ifrSave" width="0" height="0"></iframe>
</body>
</html>