<!-- #include virtual="/login/idbsecurity.inc" -->
<!-- #include virtual="/login/adovbs.inc" -->
<!-- #include virtual="/idb/no_cache.inc" -->
<% Call CheckPageRights(idbTemsilciGISKontrolDagitimDuzeltmeEkle) %>
<!-- #include virtual="/idb/idb/idbglobal.inc" -->
<!-- #include virtual="/idb/idbcombo.inc" -->
<!-- #include virtual="/idb/fake_sql.inc" -->
<!-- #include virtual="/idb/idb2000.inc" -->

<%
	sysNo = Request.QueryString("sysNo")
	islemTarihi = Request.QueryString("islemTarihi")

	If sysNo <> "" Then
		sysNo = ConvertNumeric(sysNo)
	Else
		sysNo = 0
	End If

	If islemTarihi = "" Then islemTarihi = ConvertDate(Date)
	
	If sysNo <> 0 Then
		islem = "U"
		
		Set Conn = Server.CreateObject("ADODB.Connection")
		Conn.Open Session("ConnString")
	
		Set Cmd = Server.CreateObject("ADODB.Command")
		Set Cmd.ActiveConnection = Conn
		Cmd.CommandText = "HISSE_DAGITIM_DUZELTME_IUDR"
		Cmd.CommandType = adCmdStoredProc
		Cmd.Parameters.Refresh
		
		Cmd.Parameters("@ISLEM_KODU").Value = "R"
		Cmd.Parameters("@SYS_NO").Value = sysNo

		Cmd.Execute
		
		islemTarihi = ConvertDate(Cmd.Parameters("@ISLEM_TARIHI").Value)
		seans = Cmd.Parameters("@SEANS").Value
		menkulNo = Cmd.Parameters("@MENKUL_NO").Value
		fiyat = Cmd.Parameters("@FIYAT").Value
		emir = Cmd.Parameters("@EMIR").Value
		eskmusteriNo = Cmd.Parameters("@ESKI_MUSTERI_NO").Value
		yenimusteriNo = Cmd.Parameters("@YENI_MUSTERI_NO").Value
		adet = Cmd.Parameters("@ADET").Value
		islemturu = Cmd.Parameters("@ISLEM_TURU").Value
		hatayapan = Cmd.Parameters("@HATA_YAPAN").Value
		onaylayan = Cmd.Parameters("@ONAYLAYAN").Value
		
		lngRetVal = Cmd.Parameters("@RETURN_VALUE").Value
		
		
		Set Cmd = Nothing
		Conn.Close
		Set Conn = Nothing

	Else
		islem = "I"
	End If
%>
<html>

<head>
<meta http-equiv="Content-Language" content="tr">
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Daðýtým Düzeltme Ýþlemi</title>
<link rel="STYLESHEET" type="text/css" href="/idb/idb/idbglobal.css">
<style>
	input {
		font-family: verdana;
		font-size: 8pt;
	}
	td {
		font-family: verdana;
		font-size: 8pt;
	}
	INPUT.date {behavior:url(/idbstyles/dateinput.htc);text-align:right;}
	INPUT.numeric {behavior:url(/idbstyles/currency.htc);text-align:right;}
	SELECT.incremental {behavior: url (/behavior/incsearch.htc);}
	select {
		font-family: verdana;
		font-size: 8pt;
	}
	
	.actButton {
		font-family: verdana;
		font-size: 8pt;
		width: 84px;
	}

</style>
<script defer language="JavaScript">

	function winLoad() {
		idbForm.seans.focus();
	}
	
	function winKeys() {
		if (event.keyCode == 27) {
			idbForm.eskmusteriNo.value = "";
			window.close();
		}
	}
	
	function checkForm() {
		if (idbForm.islemTarihi.value == "") { alert("Ýþlem tarihini boþ býrakamazsýnýz!"); idbForm.islemTarihi.focus(); idbForm.islemTarihi.select(); return false; }
		if (idbForm.eskmusteriNo.value == "") { alert("Eski Müþteri No'yu boþ býrakamazsýnýz!"); idbForm.eskmusteriNo.focus(); idbForm.eskmusteriNo.select(); return false; }
		if (idbForm.yenimusteriNo.value == "") { alert("Yeni Müþteri No'yu boþ býrakamazsýnýz!"); idbForm.yenimusteriNo.focus(); idbForm.yenimusteriNo.select(); return false; }
		if (idbForm.fiyat.value == "0") { alert("Fiyatý boþ býrakamazsýnýz!"); idbForm.fiyat.focus(); idbForm.fiyat.select(); return false; }
		if (idbForm.adet.value == "0") { alert("Adeti boþ býrakamazsýnýz!"); idbForm.adet.focus(); idbForm.fiyat.select(); return false; }
		idbForm.btnSubmit.disabled = true;
		return true;
	}
	
	function formKeys() {
		if ((event.keyCode == 13) && (event.ctrlKey) && (!idbForm.btnSubmit.disabled)) { event.returnValue = false; idbForm.btnSubmit.click(); return; }
		if (event.keyCode == 13) if (event.srcElement.type != "submit") event.keyCode = 9;
	}
	

	function idbLookupMusteri() {
		var sFeatures = "center: yes; scroll: no; status: no; help: no; dialogHeight: 240px; ";
		if (screen.availWidth > 720) sFeatures += "dialogWidth: 720px;"; else sFeatures += "dialogWidth: 600px;";
		idbLookupMusteriArguments.no = event.srcElement.value;
		window.showModalDialog("/idb/util/idbLookupMusteri.asp?musteriNo=" + event.srcElement.value, idbLookupMusteriArguments, sFeatures);
		event.srcElement.value = idbLookupMusteriArguments.no;
	}

	function idbLookupMusteri2() {
		var sFeatures = "center: yes; scroll: no; status: no; help: no; dialogHeight: 240px; ";
		if (screen.availWidth > 720) sFeatures += "dialogWidth: 720px;"; else sFeatures += "dialogWidth: 600px;";
		idbLookupMusteriArguments.no = event.srcElement.value;
		window.showModalDialog("/idb/util/idbLookupMusteri.asp?musteriNo=" + event.srcElement.value, idbLookupMusteriArguments, sFeatures);
		event.srcElement.value = idbLookupMusteriArguments.no;
	}

	function idbLookupMusteriArguments() {
		var no;
		var unvan;
	}
	
	function numericKeys() {
		switch (event.keyCode) {
			case   8: break; case  9: break; case 13: break; case 27: break;
			case  35: break; case 36: break; case 37: break; case 39: break; case 46: break;
			case  48: break; case 49: break; case 50: break; case 51: break; case 52: break;
			case  53: break; case 54: break; case 55: break; case 56: break; case 57: break;
			
			case  32:
				event.returnValue = false;
					switch (event.srcElement.id) {
						case "eskmusteriNo": idbLookupMusteri(); break;	
						case "yenimusteriNo": idbLookupMusteri2(); break;	
						default: break;
					}
				break;
			case  96: break; case  97: break; case  98: break; case  99: break; case 100: break;
			case 101: break; case 102: break; case 103: break; case 104: break; case 105: break;
			case 107: if(event.srcElement.value != '') event.srcElement.value = event.srcElement.value + "000"; event.returnValue = false; break;
			default: event.returnValue = false; break;
		}
	}
	
	function idbLookupMusteriGetName() {
		ifrMusteri.location = "gis_lookup_iki_musteri.asp?musteriNo=" + idbForm.eskmusteriNo.value+"&AdJs=musteriAdi1&NetJs=netBakiye1";
	}

	function idbLookupMusteriGetName2() {
		ifrMusteri.location = "gis_lookup_iki_musteri.asp?musteriNo=" + idbForm.yenimusteriNo.value+"&AdJs=musteriAdi2&NetJs=netBakiye2";
	}
	
</script>
</head>
<body onload="winLoad()" onkeydown="winKeys()">

<table border="0" width="100%" height="100%">
  <tr>
    <td width="100%" height="100%">
      <form id="idbForm" method="POST" action="dagitim_duzeltme_kaydi_save.asp" target="ifrSave" onkeydown="formKeys()" onsubmit="return checkForm()">
<table border="0" width="100%">
  <tr>
    <td nowrap>Ýþlem Tarihi</td>
    <td width="100%" nowrap><input type="text" id="islemTarihi" name="islemTarihi" size="12" maxlength="10" class="date" value="<%= islemTarihi%>"></td>
  </tr>
  <tr>
    <td nowrap>Seans</td>
    <td width="100%" nowrap><%= CreateComboStr("seans", "1;1.Seans;2;2.Seans", seans)%></td>
  </tr>
  <tr>
    <td nowrap>Emir</td>
    <td width="100%" nowrap><%= CreateComboStrEx("emir", "A;Alýþ;S;Satýþ", emir, "")%></td>
  </tr>
  <tr>
    <td nowrap>Menkul</td>
    <td width="100%" nowrap><%= CreateComboEx("HS_MENKUL_NO", "menkulNo", "", menkulNo, "class=incremental")%>&nbsp;<label id="menkulBakiye"></label></td>
  </tr>
  <tr>
    <td nowrap>Fiyat</td>
    <td width="100%" nowrap><input type="text" id="fiyat" name="fiyat" size="15" maxlength="15" class="numeric" value="<%= fiyat %>"></td>
  </tr>
  <tr>
    <td nowrap>Adet</td>
    <td width="100%" nowrap><input type="text" id="adet" name="adet" size="15" maxlength="15" class="numeric" value="<%= adet %>"></td>
  </tr>
  <tr>
    <td nowrap>Eski Müþteri No</td>
    <td width="100%" nowrap><input type="text" id="eskmusteriNo" class="numeric" name="eskmusteriNo" size="15" maxlength="15" style="text-align: right;" onkeydown="numericKeys()" onblur="idbLookupMusteriGetName()" value="<%= eskmusteriNo %>" title="Müþteri listesinden seçmek için boþluk (space) tuþuna basýnýz..."><b>&nbsp;<label id="musteriAdi1"></label>&nbsp;<label id="netBakiye1"></label></b></td>
  </tr>
  <tr>
    <td nowrap>Yeni Müþteri No</td>
    <td width="100%" nowrap><input type="text" id="yenimusteriNo" class="numeric" name="yenimusteriNo" size="15" maxlength="15" style="text-align: right;" onkeydown="numericKeys()" onblur="idbLookupMusteriGetName2()" value="<%= yenimusteriNo %>" title="Müþteri listesinden seçmek için boþluk (space) tuþuna basýnýz..."><b>&nbsp;<label id="musteriAdi2"></label>&nbsp;<label id="netBakiye2"></label></b></td>
  </tr>
  <tr>
    <td nowrap>Ýþlem Türü</td>
    <td width="100%" nowrap><%= CreateComboStrEx("islemturu", "N;Normal;K;Kredi;A;Açýða Satýþ;T;Teminat", islemturu, "")%></td>
  </tr>
  <tr>
    <td nowrap>Hata Yapan</td>
    <td><%= CreateComboEx("KULLANICI", "hatayapan", "", hatayapan, "class=incremental style='width:144px;'")%></td>
  </tr>
  <tr>
    <td nowrap>Onaylayan </td>
    <td><%= CreateComboEx("KULLANICI", "onaylayan", "", onaylayan, "class=incremental style='width:144px;'")%></td>
  </tr>
  <tr>
    <td nowrap></td>
    <td width="100%" nowrap><input type="submit" id="btnSubmit" name="btnSubmit" value="Kaydet"></td>
  </tr>
</table>
<input type="hidden" name="islemKodu" value="<%= islem %>">
<input type="hidden" name="sysNo" Value="<%= sysNo %>">
      </form>
    </td>
  </tr>
</table>
<% If sysNo <> 0 Then %>
<script defer language="JavaScript">
	idbLookupMusteriGetName();
</script>
<% End If %>
<iframe id="ifrSave" name="ifrSave" width="100%" height="100"></iframe>
<iframe id="ifrMusteri" name="ifrMusteri" width="0" height="0"></iframe>
</body>

</html>
