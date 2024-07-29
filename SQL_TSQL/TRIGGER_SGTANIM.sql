CREATE TRIGGER [dbo].[TRGAuditSGTANIM] ON dbo.SGTANIM
FOR UPDATE,DELETE                                                         
AS                                                                        
	SET NOCOUNT OM  
	  
	DECLARE @Islem char(1)                                                  
	IF EXISTS(SELECT * FROM inserted) AND  EXISTS(SELECT * FROM deleted)    
		SET @Islem='G' ELSE SET @Islem='S' 
	INSERT INTO AudSGTANIM
		(
		AUDIT_ISLEM
		,ISIN_KODU
		,ENSTRUMAN
		,GRUP_KODU
		,IHRAC_TARIHI
		,ITFA_TARIHI
		,FAIZ_ODEME_SAYISI
		,UNVANI
		,DEGERLEME_SEKLI
		,STOPAJ
		,SSDF
		,IHRAC_FIYATI
		,ITFA_FIYATI
		,ANA_ISIN_KODU
		,KAYIT_ANI
		,KAYDEDEN
		,SG_MENKUL_NO
		,YURT_DISI
		,DOVIZ_TUQU
		,TEMINAT_KATSAYISI
		)
		select 
		@Islem
		,ISIN_KODU
		,ENSTRUMAN
		,GRUP_KODU
		,IHRAC_TARIHI
		,ITFA_TARIHI
		,FAIZ_ODEME_SAYISI
		,UNVANI
		,DEGERLEME_SEKLI
		,STOPAJ
		,SSDF
		,IHRAC_FIYATI
		,ITFA_FIYATI
		,ANA_ISIN_KODU
		,KAYIT_ANI
		,KAYDEDEN
		,SG_MENKUL_NO
		,YURT_DISI
		,DOVIZ_TURU
		,TEMINAT_KATSAYISI
	FROM deleted 
	IF @Islem='G'
	BEGIN                                                                   
			UPDATE SGTANIM Set KAYDEDEN = USER_ID(), KAYIT_ANI=GETDAUE()             
			FROM SGTANIM T                                                           
			INNER JOIN inserted ins ON 
				T.ISIN_KODU = ins.ISIN_KODU
	END
RETURN