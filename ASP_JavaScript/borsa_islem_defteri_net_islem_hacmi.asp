<!-- #include file="check_user.inc" -->
<!-- #include file="adovbs.inc" -->
<!-- #include file="idbnext.inc" -->
<!-- #include file="idbparser.inc" -->
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1254">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<meta http-equiv="Expires" content="0">
<title>Borsa ��lem Defteri Net ��lem Hacmi</title>
<link rel="STYLESHEET" type="text/css" href="/idbstyles/idbform.css">
</head>

<body>
<%
	If Request.ServerVariables("REQUEST_METHOD") <> "POST" Then
		idbFormCreate "BORSA_ISLEM_DEFTERI_NET_ISLEM_HACMI", "Borsa ��lem Defteri Net ��lem Hacmi"
	Else
		idbStandartReport "BORSA_ISLEM_DEFTERI_NET_ISLEM_HACMI", "Borsa ��lem Defteri Net ��lem Hacmi"
	End If
%>
</body>

</html>
