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
<title>Borsa Islem Defteri Açiga Satis Ekrani</title>
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
<form id="idbForm" method="POST" action="borsa_islem_defteri_aciga_satis.asp" onkeydown="processFormKey()" onsubmit="return validateForm()">
<div align="center">
<table border="1" style="border-collapse: collapse;">
  <tr>
    <td class="header" nowrap>Borsa Islem Defteri Açiga Satis Ekrani</td>
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
    <tr>
      <td>Açığa Satış Tuşlarını Göz Ardı Et</td>
      <td><input type="checkbox" name="ACIGA_SATIS_GOZARDI" value="1" checked>
    </tr>
<%= SubeSatiriYaz() %>
    <tr>
      <td>Menkul</td>
      <td><%= CreateCombo("MENKUL_NO", "MENKUL_NO", "0;Hepsi", MENKUL_NO)%></td>
    </tr>
    <tr>
      <td>Müsteri No</td>
      <td><input required="true" class="numeric" maxlength=10 type="text" name="MUSTERI_NO" size="12" value="<%= 0%>">
    </tr>
    <tr>
      <td>Temsilci</td>
      <td><%= CreateComboEx("TEMSILCI", "TEMSILCI", ";Hepsi", Session("USER_NAME"), "class='i100'")%></td>
    </tr>
    <tr>
      <td>Broker</td>
      <td><%= CreateCombo("BROKER", "broker", "0;Hepsi", "0")%></td>
    </tr>
    <tr>
      <td>Sadece Açiklari Göster</td>
      <td><input type="checkbox" name="SADECE_ACIKLARI_GOSTER" value="1" checked>
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
		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Session("ConnString")
	
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandTimeout = 600
		Server.ScriptTimeout = 600
		Cmd.CommandText = "BORSA_ISLEM_DEFTERI_ACIGA_SATIS_ANALIZI"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		islemTarihi = DateForSql2000(Request.Form("islemTarihi"))
		Cmd.Parameters("@TARIH").Value = islemTarihi
		Cmd.Parameters("@TO_TARIH").Value = DateForSql2000(Request.Form("totarih"))
		Cmd.Parameters("@ACIGA_SATIS_GOZARDI").Value = Request.Form("ACIGA_SATIS_GOZARDI")
		Cmd.Parameters("@SUBE_NO").Value = Request.Form("SUBE_NO")
		Cmd.Parameters("@MUSTERI_NO").Value = Request.Form("MUSTERI_NO")
		Cmd.Parameters("@TEMSILCI").Value = Request.Form("TEMSILCI")
		Cmd.Parameters("@BROKER").Value = Request.Form("broker")
		Cmd.Parameters("@PARAM_MENKUL_NO").Value = Request.Form("menkul_no")
		Cmd.Parameters("@SADECE_ACIKLARI_GOSTER").Value = "0" & Request.Form("SADECE_ACIKLARI_GOSTER")
		
%>		
<!-- #include file="printredir.inc" -->
<%
		Set Rs = Server.CreateObject("ADODB.Recordset")
		Set Rs = Cmd.Execute
if Rs.Bof and Rs.Eof then
%>
<div>
<center>Raporlanacak Veri Bulunamadi</center></div>
<%
else
%>
<form id="FrmIdb" width="100%"method="POST" action="borsa_islem_defteri_aciga_satis_tamam.asp">
<div>
<table border="1" width="100%" class="reportTable">
 <thead><tr><th colspan="14" >Borsa İşlem Defteri Açığa Satış Listesi</th></tr></thead>
 <tr>
    <td class="reportHeader" width="05%"><input type="checkbox" name="selectAll" id="selectAll" onclick="toggleSelected()">Müsteri</td>
    <td class="reportHeader" width="05%">Ünvani</td>
    <td class="reportHeader" width="03%">Menkul</td>
    <td class="reportHeader" width="03%">Söz.No</td>
    <td class="reportHeader" width="03%">Emir</td>
    <td class="reportHeader" width="10%" colspan = 2>Miktar</td>
    <td class="reportHeader" width="16%" colspan = 2>Fiyat</td>
    <td class="reportHeader" width="16%" colspan = 2>Tutar</td>
    <td class="reportHeader" width="02%">Açiga</td>
    <td class="reportHeader" width="07%">KarşıÜye</td>
    <td class="reportHeader" width="10%">Zaman</td>
    <td class="reportHeader" width="13%" colspan = 2>Stok</td>
    <td class="reportHeader" width="06%">Broker</td>
  </tr>
</table>
<a style="background:Aqua;font:bold;">
<li style="cursor: e-resize;" id="menu0" onclick="changeDisplay()">
	<input type="checkbox" id="cbx<%=Rs("MUSTERI_NO")%>" name="DETAY_DATA" value="<%= Rs("MUSTERI_NO") & "\" & Rs("MENKUL_NO") & "\" & Rs("MIN_STOK")& "\" & ConvertDate(Rs("ISLEM_TARIHI")) %>">&nbsp;
	<%= FormatNumber(Rs.Fields("MUSTERI_NO").Value,0,True) %> - <%= Rs.Fields("UNVANI").Value %> - <%= Rs.Fields("MENKUL_KODU").Value %> - <%= FormatNumber(Rs.Fields("MIN_STOK").Value,0,True) %>
</li>
</a>
  <ul style="display:'';">
  	<li>
	<table width="96%" class="reportTable">
	<%
		Prev_Musteri_No = Rs.Fields("MUSTERI_NO").Value
		Prev_Menkul_Kod = Rs.Fields("MENKUL_KODU").Value
		prev_tarih = Rs.Fields("ISLEM_TARIHI").Value
		lngBoxCounter = 0
		i = CLng(0)
    	toptutar = CDbl(0)
	Do While CheckResponseFlush(Rs, 1000)
			i = i + 1
			lngBoxCounter = lngBoxCounter + 1
            toptutar   = toptutar    + CDbl(Rs("TUTAR"))
            topmiktar  = topmiktar    + CDbl(Rs("MIKTAR"))
            topstok  = topstok    + CDbl(Rs("STOK"))
            topfiyat  = topfiyat    + CDbl(Rs("FIYAT"))
			if (Prev_Musteri_No <> Rs.Fields("MUSTERI_NO").Value) OR (Prev_Menkul_Kod <> Rs.Fields("MENKUL_KODU").Value) OR (prev_tarih <> Rs.Fields("ISLEM_TARIHI").Value) then
				Prev_Musteri_No = Rs.Fields("MUSTERI_NO").Value
				Prev_Menkul_Kod = Rs.Fields("MENKUL_KODU").Value 
				prev_tarih = Rs.Fields("ISLEM_TARIHI").Value
				%>

				</table>
				</li>
				</ul>
				<a style="background:Aqua;font:bold;">
				<li style="cursor: e-resize;" id="menu<%=i%>" onclick="changeDisplay()">
					<input type="checkbox" id="cbx<%=Rs("MUSTERI_NO")%>" name="DETAY_DATA" value="<%= Rs("MUSTERI_NO") & "\" & Rs("MENKUL_NO") & "\" & Rs("MIN_STOK")& "\" & ConvertDate(Rs("ISLEM_TARIHI")) %>">&nbsp;
					<%= FormatNumber(Rs.Fields("MUSTERI_NO").Value,0,True) %> - <%= Rs.Fields("UNVANI").Value %> - <%= Rs.Fields("MENKUL_KODU").Value %> - <%= FormatNumber(Rs.Fields("MIN_STOK").Value,0,True) %>
				</li>
				</a>
				<ul style="display:'';">
				<li>
				<table width="96%" class="reportTable">
			<%end if %>
  <tr>
    <td width="16%" colspan="3"><%=ConvertDate(Rs("ISLEM_TARIHI"))%></td>
    <td align="right" width="06%"><%= FormatNumber(Rs.Fields("SOZLESME_NO").Value, 0, True) %></td>
    <td align="center" width="06%"><%= Rs.Fields("EMIR").Value %></td>
    <td align="right" width="12%"><%= FormatNumber(Rs.Fields("MIKTAR").Value, 0, True) %></td>
    <td align="right" width="12%"><%= FormatNumber(Rs.Fields("FIYAT").Value, 0, True) %></td>
    <td align="right" width="12%"><%= FormatNumber(Rs.Fields("TUTAR").Value, 0, True) %></td>
    <td align="center" width="06%"><%= Rs.Fields("ACIGA").Value%></td>
    <td align="left" width="06%"><%= Rs.Fields("KARSI_UYE").Value %></td>
    <td align="right" width="07%"><%= Rs.Fields("ZAMAN").Value %></td>
    <td align="right" width="12%">
    	<%if CDbl(Rs.Fields("STOK").Value) < 0 then %>
    		<i><%= FormatNumber(Rs.Fields("STOK").Value, 0, True)%></i>
    	<%else%>
    		<%= FormatNumber(Rs.Fields("STOK").Value, 0, True) %>
    	<%end if%>
    </td>
    <td align="right" width="07%"><%= Rs.Fields("BROKER").Value %></td>
  </tr>
<%
		Rs.MoveNext 
		Loop
%>
  </table>
  </li>
  </ul>
<table width="100%" class="reportTable">
  <tr>
    <td align="left"  width="30%"><b>Toplam Müşteri : <%= i %></b></td>
    <td align="right" width="11%"><b><%= FormatNumber(topmiktar, 0, True)%></b></td>
    <td align="right" width="12%"><b><%= FormatNumber(topfiyat, 0, True)%></b></td>
    <td align="right" width="12%"><b><%= FormatNumber(toptutar, 0, True)%></b></td>
  	<td width="35%">&nbsp;</td>
  </tr>
</table>
</div>
<form>
<%		
		end if
		Rs.Close
		Set Rs = Nothing
		
		Set Cmd = Nothing
			
		Conn.Close
		Set Conn = Nothing
%>
<center>
<table border="0" width="50%" id="idbFormTable" bgcolor="#0099FF" style="font-family: verdana; font-size: 8pt; border-collapse: collapse;">
		<!-- #include virtual="/idb/printdest.inc" -->
	<tr>
		<input type=hidden value="<%=intCBoxCounter%>" Name="CboxCount" id="CboxCount">
		<input type=hidden value="<%=islemTarihi%>" Name="islemTarihi" id="islemTarihi">
        <td align="right" colspan="13">
            <p align="center">
			<%
				If Session("CONTENT_DESTINATIONS") <> "" Then
			%>	
					<input type="submit" class="button" accessKey="G" value="Formlari Yazdir" name="B1">
			<%	End If %>

            </p>
		</td>
	</tr>
</table>
</center>
</form>
<%
	End If 
%>
</body>

</html>