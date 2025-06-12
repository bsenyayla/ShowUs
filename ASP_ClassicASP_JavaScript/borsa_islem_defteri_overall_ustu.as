<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(733)%>
<!-- #include virtual="/idb/idb2000.inc" -->
<!-- #include virtual="/idb/idbcombo.inc" -->
<!-- #include virtual="/idb/fake_sql.inc" -->
<!-- #include virtual="/idb/no_cache.inc" -->
<!-- #include virtual="/idb/idb/takvim.inc" -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 6.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Borsa İşlem Defteri Overall Üstü İşlem Hacmi Raporu</title>
<link rel="STYLESHEET" type="text/css" href="/idb/idb/idbglobal.css">
<style>
	SELECT.incremental {behavior: url (/behavior/incsearch.htc);}
	INPUT.numeric {behavior:url(/idbstyles/currency.htc);text-align:right;}
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
	.i100 {
		font-family: verdana;
		font-size: 8pt;
	}
</style>
<script defer language="JavaScript">
<!--
<% If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then %>
	function winLoad() {
		smartForm.tarih.focus();
	}
	
	function formKeys() {
		switch (event.keyCode) {
			case 13:
				if (event.ctrlKey) {
					smartForm.submitForm.click();
					event.returnValue = false;
				}
				else {
					if ((event.srcElement.tagName != "BUTTON") && (event.srcElement.type != "submit"))event.keyCode = 9;
				}
				break;
			case 27:
				window.close();
				break;
		}
	}
	
	function working() {
		if (labelProgress.innerText != "") labelProgress.innerText = ""; 	else labelProgress.innerText = "İşlem Gerçekleştiriliyor...";
	}

	function validateForm() {
		if (smartForm.tarih.value == "__/__/____") { 
			alert("Tarih Girmelisiniz!"); 
			smartForm.tarih.focus(); 
			return false; 
			}
		if (smartForm.tarih.value == "__/__/____") { 
			alert("Son Tarih Girmelisiniz!"); 
			smartForm.sontarih.focus(); 
			return false; 
			}
		smartForm.submitForm.disabled = true;
		window.setInterval("working()", 250);
		return true;
	}

<% Else %>
	function winLoad() {
		window.moveTo(0, 0);
		window.resizeTo(screen.availWidth, screen.availHeight);	}
<% End If %>
//-->
</script>
</head>
<body topmargin="1" leftmargin="1" onload="winLoad()">
<%
	if Request.ServerVariables("REQUEST_METHOD") <> "POST" then
 	   tarih = Request.QueryString("tarih")
 	   tarih = Request.QueryString("sontarih")
%>
<form id="smartForm" method="POST" action="borsa_islem_defteri_overall_ustu.asp" onkeydown="formKeys()" onsubmit="return validateForm()">
<div align="center">
  <center>
<table border="1" style="border-collapse: collapse;">
  <tr>
    <td class="header" nowrap>Borsa Islem Defteri Overall Üstü Raporu</td>
  </tr>
  <tr>
    <td colspan="2" nowrap>
      <table border="0" width="100%" style="font-family: verdana; font-size: 8pt;">
  <tr>
    <td nowrap>İlk Tarih</td>
    <td nowrap><input type="text" class="date" id="tarih" name="tarih" size="12" maxlength="10" value="<%= ConvertDate(Date)%>">
            	 <input tabindex="-1" type=button value=" ? " class=takvimbtn onclick="tarih.value=openPopUpTakvim(tarih.value);" title="Takvim"></td>
  </tr>
  <tr>
    <td nowrap>Son Tarih</td>
    <td nowrap><input type="text" class="date" id="sontarih" name="sontarih" size="12" maxlength="10" value="<%= ConvertDate(Date)%>">
            	 <input tabindex="-1" type=button value=" ? " class=takvimbtn onclick="sontarih.value=openPopUpTakvim(sontarih.value);" title="Takvim"></td>
  </tr>
<%= SubeSatiriYaz%>
    <tr>
      <td>Müsteri No</td>
      <td><input required="true" class="numeric" maxlength=10 type="text" name="MUSTERI_NO" size="12" value="<%= 0%>">
    </tr>
    <tr>
      <td>Temsilci</td>
      <td><%= CreateComboEx("TEMSILCI", "TEMSILCI", ";Hepsi", Session("USER_NAME"), "class='i100'")%></td>
    </tr>
  <tr>
      <td>Minimum Borç</td>
      <td><input type="text" id="limit" name="limit" size="15" maxlength="15" class="numeric" value=1></td>
  </tr>
    <tr>
      <td>Sadece Açiklari Göster</td>
      <td><input type="checkbox" name="SADECE_ACIKLARI_GOSTER" value="1" checked>
    </tr>
    <tr>
      <td>Açığa Satış Tuşlarını Göz Ardı Et</td>
      <td><input type="checkbox" name="ACIGA_SATIS_GOZARDI" value="1" checked>
    </tr>
<!-- #include file="printdest.inc" -->
  </table>
	  <tr>
   			 <td nowrap align="center"><input type="submit" id="submitForm" name="submitForm" value="Göster"></td>
	  </tr>
  </table>
  </center>
</div>
<div align="center"><b><label id="labelProgress" style="font-family: verdana; font-size: 8pt;"></label></b></div>
</form>
<%
	else 
		tarih = Request.Form("tarih")
		sontarih = Request.Form("sontarih")
		SUBE_NO = Request.Form("SUBE_NO")
		MUSTERI_NO = Request.Form("MUSTERI_NO")
		ACIGA_SATIS_GOZARDI = Request.Form("ACIGA_SATIS_GOZARDI")
		temsilci = Request.Form("TEMSILCI")
		limit = Request.Form("limit")
		SADECE_ACIKLARI_GOSTER = Request.Form("SADECE_ACIKLARI_GOSTER")
		
		Set Conn = Server.CreateObject("ADODB.Connection")
		lngConnectionTimeout = Conn.ConnectionTimeout
		Conn.ConnectionTimeout = 600
		Conn.Open Session("ConnString")
					
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_OVERALL_USTU"
		Cmd.CommandType = adCmdStoredProc
		Cmd.CommandTimeout = 600
		Cmd.Parameters.Refresh

		Cmd.Parameters("@TARIH").Value = DateForSql(tarih)
		Cmd.Parameters("@TO_TARIH").Value = DateForSql(sontarih)
		Cmd.Parameters("@SUBE_NO").Value = SUBE_NO
		Cmd.Parameters("@MUSTERI_NO").Value = Request.Form("MUSTERI_NO")
		Cmd.Parameters("@ACIGA_SATIS_GOZARDI").Value = "0" & Request.Form("ACIGA_SATIS_GOZARDI")
		Cmd.Parameters("@TEMSILCI").Value = Request.Form("TEMSILCI")
		Cmd.Parameters("@MIN_BORC").Value = ConvertNumeric(limit)
		Cmd.Parameters("@SADECE_ACIKLARI_GOSTER").Value = "0" & Request.Form("SADECE_ACIKLARI_GOSTER")
%>		
<!-- #include file="printredir.inc" -->
<%
		Set Rs = Server.CreateObject("ADODB.Recordset")
		Set Rs = Cmd.Execute
		
		if not (Rs.Bof and Rs.Eof) then
%>
<div align="center">
  <center>
  <table border="1" style="font-family: verdana; font-size: 8pt; border-collapse: collapse;" width="100%">
    <tr style="text-align: center; font-weight: bold;">
    <td colspan="19" align="center" nowrap><b><%= tarih %> - <%= sontarih %> Tarihleri arası Borsa İşlem Defteri Overall Üstü İşlem Hacmi Listesi - Alt Limit : <%= limit %></b></td>
  </tr>
    <tr style="text-align: center; font-weight: bold;">
    <td colspan="19" align="center" nowrap><b>(Bu Rapor Alındığı Tarihten bir gün önceki Overall'lara bakar.Bugün yatırılmış paralar rapor haricidir)</b></td>
  </tr>
  <tr style="text-align: center; font-weight: bold;">
    <td width="6%"><b>İşl.Tar.</b></td>
    <td width="5%"><b>Müşteri</b></td>
    <td width="15%"><b>Ünvanı</b></td>
    <td width="6%"><b>Menkul</b></td>
    <td width="6%"><b>Szl.No</b></td>
    <td width="4%"><b>Emr</b></td>
    <td width="6%"><b>Miktar</b></td>
    <td width="6%"><b>Fiyat</b></td>
    <td width="14%"><b>Tutar</b></td>
    <td width="2%"><b>Açığa</b></td>
    <td width="6%"><b>K.U</b></td>
    <td width="6%"><b>Zaman</b></td>
    <td width="6%"><b>TL</b></td>
    <td width="14%"><b>Overall</b></td>
    <td width="14%"><b>Aşım</b></td>
    <td width="14%"><b>Ek Limit</b></td>
    <td width="14%"><b>Broker</b></td>
    <td width="14%"><b>İ.No</b></td>
    <td width="8%"><b>Limit Sonrası</b></td>
  </tr>
<%
	i = CLng(0)
	Do While Not Rs.Eof
		i = i + 1
%>
  <tr style="background-color: #ccffcc">
    <td width="6%" align="left" nowrap><%= ConvertDate(Rs("ISLEM_TARIHI"))%></td>
    <td width="5%" align="right" nowrap> <%= FormatNumber(Rs("MUSTERI_NO"), 0, True)%></td>
    <td width="15%" align="left" nowrap><%= Trim(Rs("UNVANI"))%></td>
    <td width="6%" align="left" nowrap><%= Trim(Rs("MENKUL_KODU"))%></td>
    <td width="12%" align="right" nowrap> <%= FormatNumber(Rs("SOZLESME_NO"), 0, True)%></td>
    <td width="4%" align="center" nowrap><%= Trim(Rs("EMIR"))%></td>
    <td width="14%" align="right" nowrap> <%= FormatNumber(Rs("MIKTAR"), 0, True)%></td>
    <td width="14%" align="right" nowrap> <%= FormatNumber(Rs("FIYAT"), 0, True)%></td>
    <td width="14%" align="right" nowrap> <%= FormatNumber(Rs("TUTAR"), 0, True)%></td>
    <td width="8%" align="center" nowrap><%= Trim(Rs("ACIGA"))%></td>
    <td width="8%" align="left" nowrap><%= Trim(Rs("KARSI_UYE"))%></td>
    <td width="8%" align="left" nowrap><%= Trim(Rs("ZAMAN"))%></td>
    <td width="8%" align="right" nowrap> <%= FormatNumber(Rs("TL"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("OVERALL"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("ASIM"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("EKLIMIT"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("BROKER"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("INO"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("LIMITSONRASI"), 0, True)%></td>
  </tr>
<%
			Rs.MoveNext
			Loop
			if i > 1 then
%>
  <tr>
    <td colspan="3" align="right"><b>Toplam Kayıt  Sayısı : <%= i %></b></td>
  </tr>
<%
			end if
%>
</table>
  </center>
</div>
<%		
		else 
			response.write "<p align=""center""><b>Raporlanacak kayıt bulunamadı!</b></p>"
		end if
		Rs.Close
		Set Rs = Nothing
		
		Set Cmd = Nothing
			
		Conn.Close
		Conn.ConnectionTimeout = lngConnectionTimeout
		Set Conn = Nothing

	end if 'post
%>
</body>
</html>
