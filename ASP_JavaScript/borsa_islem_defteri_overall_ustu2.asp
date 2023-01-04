<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<% Call CheckPageRights(708)%>
<!-- #include virtual="/idb/idb2000.inc" -->
<!-- #include virtual="/idb/idbcombo.inc" -->
<!-- #include virtual="/idb/fake_sql.inc" -->
<!-- #include virtual="/idb/no_cache.inc" -->
<!-- #include virtual="/idb/idb/takvim.inc" -->
<!-- #include virtual="/idb/flusher.inc"-->

<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 6.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<link rel="STYLESHEET" type="text/css" href="/idb/idb/idbglobal.css">
<link rel="STYLESHEET" type="text/css" href="/idb/idb/idbreport.css">
<title>Borsa Islem Defteri Overall Üstü İşlem Hacmi</title>
<style>
	INPUT.numeric {behavior:url(/idbstyles/currency.htc);text-align:right;}
	input {
		font-family: verdana;
		font-size: 8pt;
	}
	select {
		font-family: verdana;
		font-size: 8pt;
	}
</style>
<SCRIPT LANGUAGE=javascript >
<!--
function changeDisplay(){
	if(!document.all) return;
	if (event.srcElement.id.substr(0, 4) == "menu") {
		var srcIndex = event.srcElement.sourceIndex;
		var nested = document.all[srcIndex + 2];
		if (nested.style.display == "none") {
			nested.style.display = ""; 
			//HV===
			var H = nested.offsetHeight;
			var S = document.body.scrollTop;
			var C = document.body.offsetHeight;
			var Y = event.clientY;
			
			if(Y+H > C) 
				document.body.scrollTop = S + (Y+H-C) + 10;
				
			//====HV
		}
		else {
			nested.style.display = "none";
		}
		event.returnValue = false;
		event.cancelBubble = true;
	}
}

function document_onkeydown() {
	if (event.keyCode == 27) window.close();
}

<%
	If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
function processFormKey() {
	if (event.srcElement.tagName != "BUTTON") {
		if (event.keyCode == 13) event.keyCode = 9;
	}
	if (event.keyCode == 13) if (event.srcElement.parentElement.btnSubmit) event.srcElement.parentElement.btnSubmit.click();
	if (event.keyCode == 113) if (event.srcElement.parentElement.btnSubmit) event.srcElement.parentElement.btnSubmit.click();
	if (event.keyCode == 27) window.close();
}

function processDateKey() {
	switch (event.keyCode) {
		case 8: break; case 9: break; case 13: break; case 27: break; case 48: break;  case 37: break; case 39: break;
		case 96: break; case 97: break; case 98: break; case 99: break; case 100: break; case 101: break; case 102: break; case 103: break;case 104: break; case 105: break;
		case 48: break; case 49: break; case 50: break; case 51: break;  case 52: break; case  53: break; case  54: break; case  55: break; case  56: break; case  57: break;
		case 111: break;
		case 106: event.srcElement.value = "<%= ConvertDate(Date) %>"; event.returnValue = false; break;
		default: event.returnValue = false; break;
	}
}

function window_onload() {
	idbForm.islemTarihi.focus();
}
<%
	Else
%>
function window_onload() {
}
function toggleSelected() 
	{
		bSelected = FrmIdb.selectAll.checked;
		frm = FrmIdb.elements;
		for (i=0; i<frm.length; i++) {
			if	(frm(i).id.substring(0,3)=="cbx") frm(i).checked = bSelected;
		}
	}	
<%
	End If
%>

	function validateForm() {
		if (idbForm.islemTarihi.value == "__/__/____") { alert("Islem Tarihi girmelisiniz!"); idbForm.islemTarihi.focus(); return false; }
		idbForm.submitForm.disabled = true;
		return true;
	}

//-->
</SCRIPT>
</head>

<body LANGUAGE=javascript onload="return window_onload()" topmargin="0" leftmargin="0">
<%
	If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
%>
<form id="idbForm" method="POST" action="borsa_islem_defteri_overall_ustu.asp" onkeydown="processFormKey()" onsubmit="return validateForm()">
<div align="center">
<table border="1" style="border-collapse: collapse;">
  <tr>
    <td class="header" nowrap>Borsa Islem Defteri Overall Üstü Raporu</td>
  </tr>
  <tr>
    <td colspan="2" nowrap>
      <table border="0" width="100%" style="font-family: verdana; font-size: 8pt;">
  <tr>
    <td nowrap>Tarih</td>
    <td nowrap><input type="text" class="date" id="islemTarihi" name="islemTarihi" size="12" maxlength="10" value="<%= ConvertDate(Date)%>">
            	 <input tabindex="-1" type=button value=" ? " class=takvimbtn onclick="islemTarihi.value=openPopUpTakvim(islemTarihi.value);" title="Takvim"></td>
  </tr>
  <tr>
    <td nowrap>Bitiş Tarihi</td>
    <td nowrap><input type="text" class="date" id="totarih" name="totarih" size="12" maxlength="10" value="<%= ConvertDate(Date)%>">
            	 <input tabindex="-1" type=button value=" ? " class=takvimbtn onclick="totarih.value=openPopUpTakvim(totarih.value);" title="Takvim"></td>
  </tr>
<%= SubeSatiriYaz() %>
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
      <td colspan="2" align="center"><button type="submit" id="submitForm" name="submitForm" class="actButton">Göster</button></td>
	  </tr>
  </table>
  </center>
</div>
</form>
<%
	Else

		islemTarihi = Request.Form("islemTarihi")		
		totarih = Request.Form("totarih")
		SUBE_NO = Request.Form("SUBE_NO")
		MUSTERI_NO = Request.Form("MUSTERI_NO")
		ACIGA_SATIS_GOZARDI = Request.Form("ACIGA_SATIS_GOZARDI")
		TEMSILCI = Request.Form("TEMSILCI")
		limit = Request.Form("limit")
		SADECE_ACIKLARI_GOSTER = Request.Form("SADECE_ACIKLARI_GOSTER")

		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Session("ConnString")
	
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandTimeout = 600
		Server.ScriptTimeout = 600
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_OVERALL_USTU"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		islemTarihi = DateForSql2000(Request.Form("islemTarihi"))
		Cmd.Parameters("@TARIH").Value = islemTarihi
		Cmd.Parameters("@TO_TARIH").Value = DateForSql2000(Request.Form("totarih"))
		Cmd.Parameters("@SUBE_NO").Value = Request.Form("SUBE_NO")
		Cmd.Parameters("@MUSTERI_NO").Value = Request.Form("MUSTERI_NO")
		Cmd.Parameters("@ACIGA_SATIS_GOZARDI").Value = Request.Form("ACIGA_SATIS_GOZARDI")
		Cmd.Parameters("@TEMSILCI").Value = Request.Form("TEMSILCI")
		Cmd.Parameters("@MIN_BORC").Value = ConvertNumeric(limit)
		Cmd.Parameters("@SADECE_ACIKLARI_GOSTER").Value = "0" & Request.Form("SADECE_ACIKLARI_GOSTER")
		
%>		
<!-- #include file="printredir.inc" -->
<%
		Set Rs = Server.CreateObject("ADODB.Recordset")
		Set Rs = Cmd.Execute
if Rs.Bof and Rs.Eof then
%>
<div align="center">
  <center>
  <table border="1" style="font-family: verdana; font-size: 8pt; border-collapse: collapse;" width="100%">
    <tr style="text-align: center; font-weight: bold;">
    <td colspan="10" align="center" nowrap><b><%= tarih %> TARİHLİ <% if kriter=1 Then %>BORÇ<% Else %>ALACAK<% End If%> LİSTE - Alt Limit : <%= limit %></b></td>
  </tr>
  <tr style="text-align: center; font-weight: bold;">
    <td width="6%"><b>İşl.Tar.</b></td>
    <td width="5%"><b>Müşteri</b></td>
    <td width="15%"><b>Ünvanı</b></td>
    <td width="6%"><b>Menkul</b></td>
    <td width="6%"><b>Szl.No</b></td>
    <td width="6%"><b>Emir</b></td>
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
	Do While CheckResponseFlush(Rs, 1000)
		i = i + 1
%>
  <tr style="background-color: <% If kriter = 1 Then %>#ffccff<% Else %>#ccffcc<% End If %>">
    <td width="6%" align="left" nowrap><%= ConvertDate(Rs("ISLEM_TARIHI"))%></td>
    <td width="5%" align="right" nowrap> <%= FormatNumber(Rs("MUSTERI_NO"), 0, True)%></td>
    <td width="15%" align="left" nowrap><%= Trim(Rs("UNVANI"))%></td>
    <td width="6%" align="left" nowrap><%= Trim(Rs("MENKUL_KODU"))%></td>
    <td width="12%" align="right" nowrap> <%= FormatNumber(Rs("SOZLESME_NO"), 0, True)%></td>
    <td width="8%" align="left" nowrap><%= Trim(Rs("EMIR"))%></td>
    <td width="14%" align="right" nowrap> <%= FormatNumber(Rs("MIKTAR"), 0, True)%></td>
    <td width="14%" align="right" nowrap> <%= FormatNumber(Rs("FIYAT"), 0, True)%></td>
    <td width="14%" align="right" nowrap> <%= FormatNumber(Rs("TUTAR"), 0, True)%></td>
    <td width="8%" align="left" nowrap><%= Trim(Rs("ACIGA"))%></td>
    <td width="8%" align="left" nowrap><%= Trim(Rs("KARSI_UYE"))%></td>
    <td width="8%" align="left" nowrap><%= Trim(Rs("ZAMAN"))%></td>
    <td width="8%" align="right" nowrap> <%= FormatNumber(Rs("TL"), 0, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("OVERALL"), 4, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("ASIM"), 4, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("EKLIMIT"), 4, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("BROKER"), 4, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("INO"), 4, True)%></td>
    <td width="4%" align="right" nowrap> <%= FormatNumber(Rs("LIMITSONRASI"), 4, True)%></td>
  </tr>
<%
			Rs.MoveNext
			Loop
			if i > 1 then
%>
  <tr>
    <td colspan="3" align="right"><b>Toplam Müşteri Sayısı : <%= i %></b></td>
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
