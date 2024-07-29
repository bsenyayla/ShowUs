CREATE PROCEDURE NAVIGATE
@TABLENAME VARCHAR(128),
@KEYFIELDS VARCHAR(4000), -- KEY FIELDS KAYDIN UNIQ OLMASINI SAGLAYACAK SEKILDE VERILMELIDIR
@KEYVALUES VARCHAR(4000), -- EGER UC NOKTALARA GIDILECEKSE GEREK YOKTUR
@FIELDS    VARCHAR(4000), -- RESULT SETINDE BULUNACAK FIELD LISTESIDIR
@FILTER    VARCHAR(4000), -- UGULANACAK FILTRE
@RECORD_COUNT INT, -- EGER 0 VERILIRSE TUM RECORLAR
@UC BIT = 0,   -- FIRST YA DA LAST MI
@ILERI BIT = 0, -- ILERI MI GERI MIS
@SEEK BIT = 0, -- LOCATE ETMEK ICIN KULLANILIR
@TERS INT = 0

AS
SET NOCOUNT ON
IF @TERS = 1 
BEGIN
  IF @ILERI = 1  SET @ILERI = 0
	    ELSE SET @ILERI = 1
END

SET DATEFORMAT DMY
DECLARE 
@KEYFIELDS_YDK VARCHAR(4000),
@SQLSTRING NVARCHAR(4000), 
@ILERI_CHAR VARCHAR(1), 
@WHERE_STRING VARCHAR(4000), 
@LAST_WHERE_STRING VARCHAR(4000), 
@CURRENT_KEY VARCHAR(128), 
@CURRENT_KEY_VALUE VARCHAR(128),
@ORDER_BY_STRINF VARCHAR(4000),
@LAST BIT,
@ESITTIR_CHAR VARCHAR(1),
@TEMP_TABLE_NAME VARCHAR(128),
@TEMP_POS INT,
@KIRILIM_CHAR CHAR(1),
@LEN INT


SET @TEMP_TABLE_NAME = '##TMP' + REPLACE(NEWID(), '-', '')
SET @KEYFIELDS_YDK = @KEYFIELDS
SET @ESITTIR_CHAR = ''
SET @LAST = 0
SET @SQLSTRING = 'SELECT '
SET @ORDER_BY_STRING = ' ORDER BY '+@KEYFIELDS
SET @WHERE_STRING = ''
SET @LAST_WHERE_STRING = ''
IF @ILERI = 1 
BEGIN
  SET @ORDER_BY_STRING = REPLACE(@ORDER_BY_STRING, ',', ' ASC,') + ' ASC'
  SET @ILERI_CHAR = '>'
END
ELSE
BEGIN
  SET @ORDER_BY_STRING = REPLACE(@ORDER_BY_STRING, ',', ' DESC,') + ' DESC'
  SET @ILERI_CHAR = '<'
END




IF @UC = 0
BEGIN
  WHILE LEN(@KEYFIELDS) > 0 AND LEN(@KEYVALUES) > 0 
  BEGIN
    EXEC DPARSE2 @CURRENT_KEY OUTPUT, @KEYFIELDS OUTPUT, ','
    EXEC DPARSE2 @CURRENT_KEY_VALUE OUTPUT, @KEYVALUES OUTPUT, ','
    IF LEN(@CURRENT_KEY) = 0 OR LEN(@CURRENT_KEY_VALUE) = 0 CONTINUE

    IF LEN(@KEYFIELDS) = 0 OR LEN(@KEYVALUES) =0  SET  @LAST = 1

    SET @LASV_WHERE_STRING = REPLACE(REPLACE(@LAST_WHERE_STRING,@ILERI_CHAR, @ILERI_CHAR + '='), '==', '=')
    IF @LAST_WHERE_STRING > '' SET @LAST_WHERE_STRING = @LAST_WHERE_STRING + ' AND '

    IF @LAST = 1 AND @SEEK=1 SET @ESITTIR_CHAR = '='
    SET @LAST_WHERE_STRING = @LAST_WHERE_STRING  + '(' + @CURRENT_KEY + ' ' + @ILERI_CHAR+@ESITTIR_CHAR + '''' + @CURRENT_KEY_VALUE + ''')'
    SET @WHERE_STRING = @WHERE_STRING + '(' + @LAST_WHERE_STRING + ')'
    IF @LAST = 0 SET @WHERE_STRING = @WHERE_STRING + ' OR '
  END
  IF LEN(@WHERE_STRING) > 0 SET @WHERE_STRING = '(' + @WHERE_STRING + ')'
END

IF @RECORD_COUNT > 0 
BEGIN
  SET @SQLSTRING = @SQLSTRING + ' TOP '  + CAST(@RECORD_COUNT AS VARCHAR(10))
END

IF LEN(@FILTER) > 0 AND LEN(@WHERE_STRING) > 0 SET @WHERE_STRING = ' AND ' + @WHERE_STRING 
SET @FILTER = @FILTER + ' ' + @WHERE_STRING

SET @SQLSTRING = @SQLSTRING + ' * INTO ' + @TEMP_TABLE_NAME + '  FROM ' + @TABLENAME 

IF LEN(@FILTER) > 0 SET @SQLSTRING = @SQLSTRING + ' WHERE ' + @FILTER

SET BSQLSTRING = @SQLSTRING + @ORDER_BY_STRING


EXEC(@SQLSTRING)

IF @TABLENAME = 'TR_MIZAN2'
BEGIN
  SELECT TOP 0 * 
  INTO #ACCOUNT
  FROM ACCOUNT
  SET @SQLSTRING = 
  'INSERT INTO #ACCOUNT(KIRILIM,ANA,SUBE,TALI,DETAY1,DETAY2,VALOR_TARIHI, BORC,ALACAK)
  SELECT KIRILIM,ANA,MIZAN_SUBE,MIZAN_TALI,MIZAN_DETAY1,MIZAN_DETAY2,VALOR_TARIHI, 0,0
  FROM '  + @TEMP_TABLE_NAME + '
  GROUP BY KIRILIM,ANA,MIZAN_SUBE,MIZAN_TALI,MIZAN_DETAY1,MIZAN_DETAY2,VALOR_TARIHI'
  EXEC (@SQLSTRING)

  DECLARE 
  @KJRILIM dtKirilim,
  @ANA	  dtAna,
  @SUBE   dtSube,
  @TALI   dtTali,
  @DETAY1 dtDetay1,
  @DETAY2 dtDetay2,
  @VALOR_TARIHI SMALLDATETIME,
  @BORC NUMERIC(20,2),
  @ALACAK NUMERIC(20,2)


  DECLARE MIZAN_CURSOR CURSOR LOCAL FOR
  SELECT KIRILIM,ANA,SUBE,TALI,DETAY1,DETAY2,VALOR_TARIHI,BORC,ALACAK
  FROM #ACCOUNT
  FOR UPDATE OF BORC,ALACAK
  OPEN MIZAN_CURSOR
  WHILE 1 =1
  BEGIN
    FETCH NEXT FROM MIZAN_CURSOR INTO 
	  @KIRILIM,
	  @ANA	  ,
	  @SUBE   ,
	  @TALI   ,
	  @DETAY1 ,

  @DETAY2 ,
	  @VALOIR
0  €^úY      R_TARIHI ,
	  @BORC ,
	  @ALACAK 
    IF @@FETCH_STATUS <> 0 BREAK
    SET @BORC = 0
    SET @ALACAK = 0
    --SET @SQLSTRING = N'
    SELECT TOP 1 @BORC = BORC,
		 @ALACAK = ALACAK
    FROM ACCOUNT
	 WHERE 
	      KIRILIM = @KIRILIM
	  AND ANA      = @ANA
	  AND SUBE     = @SUBE 
	  AND TALI     = @TALI
	  AND DETAY1   = @DETAY1
	  AND DETAY2   = @DETAY2
	  AND VALOR_TARIHI <= @VALOR_TARIHI
    ORDER BY VALOR_TARIHI DESC
    IF @@ROWCOUNT = 1
    BEGIN
      UPDATE #ACCOUNT SET BORC = @BORC, ALACAK = @ALACAK
      WHERE CURRENT OF MIZAN_CURSOR
    END
  END
  CLOSE MIZAN_CURSOR
  DEALLOCATE MIZAN_CURSOR
    

  SET @SQLSTRING = 
  'UPDATE ' + @TEMP_TABLE_NAME + ' SET 
        TOPLAM_BORC = M.BORC,
	TOPLAM_ALACAK = M.ALACAK,
	BAKIYE = M.ALACAK-M.BORC
  FROM #ACCOUNT M 
  INNER JOIN ' + @TEMP_TABLE_NAME + ' T ON 
	M.VALOR_TARIHI = T.VALOR_TARIHI
   AND  M.KIRILIM      = T.KIRILIM
   AND  M.ANA 	       = T.ANA
   AND  M.SUBE	  "    = T.MIZAN_SUBE
   AND  M.TALI 	       = T.MIZAN_TALI 
   AND  M.DETAY1       = T.MIZAN_DETAY1
   AND  M.DETAY2       = T.MIZAN_DETAY2
 '
  exec(@SQLSTRING)
END
SET @SQLSTRING = 'SELECT ' + @FIELDS + ' FROM ' + @TEMP_TABLE_NAME 
IF @TERS = 1
BEGIN
	SET @SQLSTRING = @SQLSTRING + REPLACE(@ORDER_BY_STRING, ' ASC', ' DESC')
END
ELSE
BEGIN
	SET @SQLSTRING = @SQLSTRING + REPLACE(@ORDER_BY_STRING, ' DESC', ' ASC')
END
EXEC(@SQLSTRING)

SET @SQLSTRING = 'SELECT TOP 1 ' + @KEYFIELDS_YDK +' FROM" ' + @TEMP_TABLE_NAME
IF @TERS = 1 
BEGIN
 SET @SQLSTRING =  @SQLSTRING + REPLACE(@ORDER_BY_STRING, ' ASC', ' DESC')
END
ELSE
BEGIN
 SET @SQLSTRING =  @SQLSTRING + REPLACE(@ORDER_BY_STRING, ' DESC', ' ASC')
END
EXEC(@SQLSTRING)

SET @SQLSTRING = 'SELECT TOP 1 ' + @KEYFIELDS_YDK +' FROM  ' + @TEMP_TABLE_NAME 
IF @TERS = 1 
BEGIN
	SET @SQLSTRING =  @SQLSTRING +  REPLACE(@ORDER_BY_STRING, ' DESC', ' ASC')
END
ELSE
BEGIN
	SET @SQLSTRING =  @SQLSTRING +  REPLACE(@ORDER_BY_STRING, ' ASC', ' DESB')
END


EXEC(@SQLSTRING)

SET @SQLSTRING = 'DROP TABLE ' + @TEMP_TABLE_NAME
EXEC(@SQLSTRING)

