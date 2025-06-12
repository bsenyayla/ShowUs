CREATE OR REPLACE PACKAGE BODY IAS_DBA.ias_abone_sifre_pack
IS
   /****************************************************************************/
   FUNCTION abone_sifre_bul (
      in_account_number   IN mb_abone_sifre.account_number%TYPE,
      in_kaynak           IN mb_abone_sifre.kaynak%TYPE)
      RETURN mb_abone_sifre.sifre_1%TYPE
   IS
      /* Logging (-)*/
      /* Tanim : Önce MB_ABONE_SIFRE'den sifre kaydi bulunmaya çalisilir. Eger kaynak kodu
      esit olan kayit varsa sifre döndürülür. Kaynak kodu null olan varsa veya sifre
      kaydi yok ve serial numberin son 5 hanesi sifre olarak set edilecekse bu sifre
      için yeni kayit yaratilir. Sifre bulunamaz, ekipman numarasi da bulunamazsa
      sifre null döner.*/
      v_account_number   mb_abone_sifre.account_number%TYPE
                            := account_number_bul (in_account_number);

      CURSOR cur_sifre
      IS
           SELECT *
             FROM mb_abone_sifre
            WHERE     account_number = v_account_number
                  AND (kaynak = ias_sabit_pack.kaynak_sifre OR kaynak IS NULL)
         ORDER BY kaynak DESC;

      v_kullanici        VARCHAR2 (20);
      rec_sifre          cur_sifre%ROWTYPE;
      v_sifre            mb_abone_sifre.sifre_1%TYPE;
      v_sonuc            INTEGER;
   BEGIN
      v_kullanici := kaynak_kullanici_bul (in_kaynak);

      OPEN cur_sifre;

      FETCH cur_sifre INTO rec_sifre;

      IF cur_sifre%FOUND
      THEN
         v_sifre := rec_sifre.sifre_1;

         IF (rec_sifre.kaynak IS NULL)
         THEN
            /******* ESKİ ***************************
            INSERT INTO mb_abone_sifre (account_number,
                                        sifre_1,
                                        sifre_2,
                                        giren_kullanici,
                                        degistiren_kullanici,
                                        kaynak)
                 VALUES (v_account_number,
                         rec_sifre.sifre_1,
                         rec_sifre.sifre_2,
                         v_kullanici,
                         v_kullanici,
                         ias_sabit_pack.kaynak_sifre);
            ******* ESKİ ***************************/

            /******* YENİ ***************************/
            dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update (
               v_account_number   => v_account_number,
               v_sifre_1          => digipaket_sifre.decrypt (
                                       rec_sifre.sifre_1),
               v_sifre_2          => digipaket_sifre.decrypt (
                                       rec_sifre.sifre_2),
               v_deneme           => 0,
               v_kullanici        => v_kullanici,
               v_kaynak           => ias_sabit_pack.kaynak_sifre,
               v_sonuc            => v_sonuc);

            IF (v_sonuc = 0)
            THEN
               raise_application_error (
                  -20101,
                  'dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update -- EXCEPTION');
            END IF;
         /******* YENİ ***************************/

         END IF;
      -- Eger tabloda yok ise default sifre kullanilmaktadir.
      ELSE
         BEGIN
            /*SELECT SUBSTR (seri_no, LENGTH (seri_no) - 4, 5)
              INTO v_sifre
              -- son 5 hanesini almak için parametrik olsun diye
              FROM web_vv_uye_ekipman
             WHERE uye_no = v_account_number AND ROWNUM = 1
          ORDER BY outlet;*/

            v_sifre := ias_dba.generate_rnd_psw;

            /******* ESKİ ***************************
            v_sifre := digipaket_sifre.encrypt (v_sifre);

            INSERT INTO mb_abone_sifre (account_number,
                                        sifre_1,
                                        sifre_2,
                                        giren_kullanici,
                                        degistiren_kullanici,
                                        kaynak)
                 VALUES (v_account_number,
                         v_sifre,
                         v_sifre,
                         v_kullanici,
                         v_kullanici,
                         ias_sabit_pack.kaynak_sifre);
            ******* ESKİ ***************************/

            /******* YENİ ***************************/
            dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update (
               v_account_number   => v_account_number,
               v_sifre_1          => v_sifre,
               v_sifre_2          => v_sifre,
               v_deneme           => 0,
               v_kullanici        => v_kullanici,
               v_kaynak           => ias_sabit_pack.kaynak_sifre,
               v_sonuc            => v_sonuc);

            IF (v_sonuc = 0)
            THEN
               raise_application_error (
                  -20101,
                  'dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update -- EXCEPTION');
            END IF;
         /******* YENİ ***************************/

         -- serial number bulunamazsa sifre null döner
         EXCEPTION
            WHEN OTHERS
            THEN
               v_sifre := NULL;
         END;
      END IF;

      CLOSE cur_sifre;

      IF v_sifre IS NOT NULL
      THEN
         IF ias_ortam_pack.is_database_live
         THEN
            RETURN digipaket_sifre.decrypt (v_sifre);
         ELSE
            -- 07/10/2009; Emine; sifrenin gerçekten bulamadigi durumlari dev ve test ortaminda ayirdetmek için bu blok eklenmistir
            RETURN v_sifre;
         END IF;
      ELSE
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         RAISE;
   END;                                                     -- ABONE_SIFRE_BUL

   /****************************************************************************/
   FUNCTION abone_sifre_kilitli (
      in_account_number   IN mb_abone_sifre.account_number%TYPE)
      RETURN BOOLEAN
   IS
      /* Logging (-)*/
      /* Tanim : Gelen abone numarasi ve kaynagina iliskin sifre kaydi bulunur ve
      kilitli olup olmadigi kontrol edilir. Kayit bulunamazsa, false döner.*/
      kilitli_durum   CHAR (1) := 'H';
   BEGIN
      SELECT kilitli
        INTO kilitli_durum
        FROM mb_abone_sifre
       WHERE     account_number = in_account_number
             AND (kaynak = ias_sabit_pack.kaynak_sifre);

      -- sifre kilitliyse sifrenin geçerliligi kontrolü yapilmayacaktir...
      IF (kilitli_durum = 'E')
      THEN
         RETURN (TRUE);
      END IF;

      RETURN (FALSE);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN (FALSE);
   END;                                                 -- ABONE_SIFRE_KILITLI

   /****************************************************************************/
   PROCEDURE abone_sifre_hatali_giris (
      in_account_number   IN     mb_abone_sifre.account_number%TYPE,
      in_kaynak           IN     mb_abone_sifre.kaynak%TYPE,
      o_mesaj_tipi           OUT NUMBER,
      o_mesaj_kodu           OUT VARCHAR2)
   IS
      /* Logging (-)*/
      /* Result Codes:
      ERR8 : Sifre kilitli
      ERR10: Sifre girisi kilitlendi
      ERR979: Sifre hatali girildi ama kilitlenmedi */
      /* Tanim : Abonenin login sirasinda yanlis giris yaptigi zaman execute edilir.
      (sifre yanlis girilmisse, sifremi unuttum ekraninda yanlis giris yapilmissa)
      Bunun dogru sekilde execute edilebilmesi için belirtilen kaynak koduna iliskin
      sifre kaydinin bulunmasi gerekmektedir. Bu çagrilmadan önce ABONE_SIFRE_BUL'un
      çagrilmasi, bu sarti yerine getirir.
          Hatali giris yapilinca sifre kaydi güncellenir (HATALI_GIRIS_SAYISI,
      HATALI_GIRIS_TARIHI-ilk hata girisi ise). PA_SABITLER'de girilen parametreler
      (SIFRE_HATA_SAYISI, SIFRE_HATA_SURESI) yerine gelmisse ayni kayit üzerinde
      sifre kilitleme islemi gerçeklestirilir.*/
      CURSOR cur_sifre
      IS
         SELECT *
           FROM mb_abone_sifre
          WHERE     account_number = in_account_number
                AND (kaynak = ias_sabit_pack.kaynak_sifre)
         FOR UPDATE;

      rec_sifre     cur_sifre%ROWTYPE;
      hata_sayi     NUMBER;                           -- kilitleme parametresi
      hata_sure     NUMBER;                           -- kilitleme parametresi
      v_kullanici   VARCHAR2 (20);
   BEGIN
      OPEN cur_sifre;

      FETCH cur_sifre INTO rec_sifre;

      -- sifre zaten kilitliyse yapilacak bir is yok
      IF (rec_sifre.kilitli = 'E')
      THEN
         CLOSE cur_sifre;

         o_mesaj_tipi := 1;
         o_mesaj_kodu := 'ERR8';
         RETURN;
      END IF;

      v_kullanici := kaynak_kullanici_bul (in_kaynak);

      -- hata sayisi sifirsa hatali giris tarihi update edilir
      -- hatali giris sayisi her durumda bir arttirilir
      IF (NVL (rec_sifre.hatali_giris_sayisi, 0) = 0)
      THEN
         UPDATE mb_abone_sifre
            SET hatali_giris_sayisi = 1,
                hatali_giris_tarihi = SYSDATE,
                degistirme_tarihi = SYSDATE,
                degistiren_kullanici = v_kullanici
          WHERE CURRENT OF cur_sifre;
      ELSE
         UPDATE mb_abone_sifre
            SET hatali_giris_sayisi = hatali_giris_sayisi + 1,
                degistirme_tarihi = SYSDATE,
                degistiren_kullanici = v_kullanici
          WHERE CURRENT OF cur_sifre;
      END IF;

      -- sifre kilitleme parametreleri alinir
      hata_sayi := dbs_sabit ('SIFRE_HATA_SAYISI');
      hata_sure := dbs_sabit ('SIFRE_HATA_SURESI');

      -- sifre kosulu arastirilir
      IF (    rec_sifre.hatali_giris_sayisi >= hata_sayi
          AND (SYSDATE - rec_sifre.hatali_giris_tarihi) * 1440 >= hata_sure)
      THEN
         -- sifre kilitleniyorrrrrrrrr...
         UPDATE mb_abone_sifre
            SET kilitli = 'E',
                kilit_tarihi = SYSDATE,
                degistirme_tarihi = SYSDATE,
                degistiren_kullanici = v_kullanici
          WHERE CURRENT OF cur_sifre;

         CLOSE cur_sifre;

         o_mesaj_tipi := 1;
         o_mesaj_kodu := 'ERR10';
         RETURN;
      END IF;

      -- sifre kilitlenmemisse
      CLOSE cur_sifre;

      o_mesaj_tipi := 1;
      o_mesaj_kodu := 'ERR979';
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         RAISE;
   END;                                            -- ABONE_SIFRE_HATALI_GIRIS

   /***********************************************************************************/
   PROCEDURE abone_gizli_sifre_insert (
      in_kaynak                     IN mb_abone_sifre.kaynak%TYPE,
      in_account_number             IN mb_abone_sifre.account_number%TYPE,
      in_gizli_sifre                IN ias_gizli_abone_sifre.gizli_sifre%TYPE,
      in_email                      IN VARCHAR2,
      in_listeden_gizle             IN ias_gizli_abone_sifre.listeden_gizle%TYPE,
      in_listeden_gizlenme_tarihi   IN ias_gizli_abone_sifre.listeden_gizlenme_tarihi%TYPE)
   IS
      /* Logging (-)*/
      -- ABONE_GIZLI_SIFRE_YARAT tarafindan çagiriliyor, inner procedure
      /* Tanim: Gizli sifre kaydi insert ediliyor.*/
      v_kullanici    VARCHAR2 (20);
      v_islem_tipi   NUMBER (1);
      v_hata         VARCHAR2 (255);
   BEGIN
      v_kullanici := kaynak_kullanici_bul (in_kaynak);

      -- Bu kullanici için daha önce girilmis olan sifreleri disable etme
      UPDATE ias_gizli_abone_sifre
         SET listeden_gizle = 'E',
             degistirme_tarihi = SYSDATE,
             degistiren_kullanici = v_kullanici
       WHERE account_number = in_account_number AND listeden_gizle = 'H';

      INSERT INTO ias_gizli_abone_sifre (id,
                                         account_number,
                                         gizli_sifre,
                                         e_mail,
                                         giren_kullanici,
                                         degistiren_kullanici)
           VALUES (ias_gizli_abone_sifre_id_seq.NEXTVAL,
                   in_account_number,
                   in_email,
                   in_gizli_sifre,
                   v_kullanici,
                   v_kullanici);
   END;                                            -- ABONE_GIZLI_SIFRE_INSERT

   /****************************************************************************/
   /*
       FUNCTION RANDOM_SIFRE_URET (
           in_account_number IN MB_ABONE_SIFRE.account_number%type)
       return varchar2 is
       -- Logging (-)
       -- ABONE_SIFRESIZ_KONTROL tarafindan çagiriliyor, inner procedure
       -- Tanim : Abonenin sifresini unuttugu durumlarda, gizli sifre üreterek kaydini
       -- yaratir
              init_number               number(15);
           init_sayi                    varchar2(255);
           rndNumber1                NUMBER;
           rndNumber2                NUMBER;
           rndNumber3                NUMBER;
           rndNumber4                NUMBER;
           rndNumber5                NUMBER;
           kesim_karakteri1          number(10);
           kesim_karakteri2          number(10);
           v_gizli_sifre_seq          number(10);
           v_default_char             char(1);

           o_gizli_sifre              varchar2(255);
         BEGIN
           v_default_char := '_';

           select IAS_GIZLI_SIFRE_SEQ.nextval  into v_gizli_sifre_seq   from dual;

           SELECT TO_Char(SYSTIMESTAMP, 'hhmissff')    INTO   init_sayi    FROM   dual;
           init_number:= to_number (substr(rtrim(ltrim(init_sayi)),1,10));

           dbms_random.INITIALIZE (init_number);
           rndNumber1 := substr(dbms_random.RANDOM,1,10); -- ARTI ve EKSI number üretir

           SELECT TO_Char(SYSTIMESTAMP, 'hhmissff')    INTO   init_sayi    FROM   dual;
           init_number:= to_number (substr(rtrim(ltrim(init_sayi)),1,10));

           DBMS_RANDOM.SEED(in_account_number + init_number);
           rndNumber2 := substr(ABS(dbms_random.RANDOM),1,10); -- ARTI NUMBER ICIN

           DBMS_RANDOM.SEED(rndNumber1);
           rndNumber3 := substr(ABS(dbms_random.RANDOM),1,10); -- ARTI NUMBER ICIN

           DBMS_RANDOM.SEED(rndNumber2);
           rndNumber4 := substr(ABS(dbms_random.RANDOM),1,10); -- ARTI NUMBER ICIN

           SELECT TO_Char(SYSTIMESTAMP, 'hhmissff')    INTO   init_sayi    FROM   dual;
           init_number:= to_number (substr(rtrim(ltrim(init_sayi)),1,10));

           DBMS_RANDOM.SEED(in_account_number + init_number);
           rndNumber5 := substr(dbms_random.RANDOM,1,10); -- ARTI ve EKSI number üretir

           kesim_karakteri1 := mod(abs(dbms_random.RANDOM), length(rndNumber3));

           o_gizli_sifre:= rndNumber1||substr(v_gizli_sifre_seq,1,3)||substr(rndNumber3, 1, kesim_karakteri1);

           for i in 0 .. trunc(length( abs(rndNumber2))/3,0)-1 loop
                 o_gizli_sifre:= o_gizli_sifre||chr((mod(substr ( abs(rndNumber2) , i*2 ,2 ),94))+ 33 )||substr(v_gizli_sifre_seq,4,3);  -- 127 olmasinin sebebi browserda addres bölümde geçerli karakterleri ifade ediyor.
           end loop ;

           o_gizli_sifre:= o_gizli_sifre||substr(rndNumber3,kesim_karakteri1+1,length(rndNumber3)-kesim_karakteri1);

           kesim_karakteri2 := mod(abs(dbms_random.RANDOM), length(rndNumber5));

           o_gizli_sifre:= o_gizli_sifre||substr(rndNumber5, 1, kesim_karakteri2);

           for i in 0 .. trunc(length( abs(rndNumber4))/3,0)-1 loop
                 o_gizli_sifre:= o_gizli_sifre||chr(mod(substr ( abs(rndNumber4) , i*2 ,2 ),94)+33 ) ;  -- 127 olmasinin sebebi browserda addres bölümde geçerli karakterleri ifade ediyor.
           end loop ;

           o_gizli_sifre:= o_gizli_sifre||substr(rndNumber5,kesim_karakteri2+1,length(rndNumber5)-kesim_karakteri2)||substr(v_gizli_sifre_seq,7,3);

           -- gizli sifre kisitlari (;*<>|&%+#/\?'"!^~¨`´=@[](){})

           o_gizli_sifre := replace(o_gizli_sifre,'^',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'~',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'¨',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'`',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'´',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'"',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'&',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,' ',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,';',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'*',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'<',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'>',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'|',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'%',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'+',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'#',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'/',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'\',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'?',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'!',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'=',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'@',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'[',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,']',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'(',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,')',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'{',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,'}',v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,chr(39),v_default_char);
           o_gizli_sifre := replace(o_gizli_sifre,chr(96),v_default_char);

           dbms_random.TERMINATE;
           return o_gizli_sifre;
         END; --  ABONE_GIZLI_SIFRE_YARAT
   */
   /************************************************************************/
   PROCEDURE abone_sifre_kontrol (                           -- sifre kontrolü
      in_account_number     IN     mb_abone_sifre.account_number%TYPE,
      in_sifre              IN     mb_abone_sifre.sifre_1%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Logging (-)*/
      /* Result Codes:
      ERR8:   Sifre kaydi kilitli
      ERR10:  Girilen sifre yanlis ve sifre kilitlenmis
      ERR13:  Uygulamaya giris engelleniyor (vestel)
      ERR14:  Uygulamaya giris engelleniyor (bireysel ve ticari olmayanlar)
      ERR979:  Girilen sifre yanlis
      ERR17:  Ilk giris için outlet yok
      ERR217: Sifre girisi eksik (5 karakterden az giris)
      VLD210: Islemler valid sonuçlanmissa*/
      -- ABONE_SIFRE_KONTROL tarafindan çagiriliyor, inner procedure
      /* Tanim : Abone sifresinin geçerliligini kontrol eder. Sifre dogru mu, sifre
      kilitli mi. Sifre yanlis girilmisse hatali giris islemi baslatilir, sifre girisi
      dogruysa hatali sifre giris sayisi sifirlanir. */
      v_account_number      mb_abone_sifre.account_number%TYPE
                               := account_number_bul (in_account_number);
      v_kaynak              mb_abone_sifre.kaynak%TYPE
                               := upper_string (LTRIM (RTRIM (in_kaynak)));

      CURSOR cur_sifre
      IS
         SELECT *
           FROM mb_abone_sifre
          WHERE     account_number = v_account_number
                AND kaynak = ias_sabit_pack.kaynak_sifre;

      --FOR UPDATE NOWAIT;

      rec_sifre             cur_sifre%ROWTYPE;
      v_sifre               mb_abone_sifre.sifre_1%TYPE;
      v_stb_tipi            CHAR (2);
      v_musteri_tipi        CHAR (3);
      v_musteri_tipi_grup   NUMBER (1);
      v_kilitli_sifre       BOOLEAN;
      valid_login           BOOLEAN;
      v_islem_tipi          NUMBER (1);
   BEGIN
      v_stb_tipi := vestel_pack.abone_stb_tipi_bul (v_account_number);

      IF v_stb_tipi IS NULL OR v_stb_tipi = '-1'
      THEN
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR978';
         RETURN;
      END IF;

      BEGIN
         SELECT customer_type
           INTO v_musteri_tipi
           FROM wiz_customer_hp_life
          WHERE account_number = v_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR978';
            RETURN;
      END;

      -- sifre kilitliyse sifrenin geçerliligi kontrolü yapilmayacaktir...
      v_kilitli_sifre := abone_sifre_kilitli (v_account_number);

      IF (v_kilitli_sifre)
      THEN
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR8';
         RETURN;
      END IF;

      IF (LENGTH (in_sifre) < 5)
      THEN
         -- sifre olmasi gereken uzunluktan küçükse (11/12/2003, EmineB)
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR217';
         RETURN;
      END IF;                       -- hatali sifre kaydi muamelesi görmeyecek

      v_sifre := abone_sifre_bul (v_account_number, v_kaynak);

      IF (v_sifre IS NULL)
      THEN
         -- ilk giris için outlet kontrolü
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR17';
         RETURN;
      END IF;

      IF ias_ortam_pack.is_database_live
      THEN
         valid_login := (v_sifre = in_sifre);
      ELSE
         valid_login := TRUE;
      -- TEST ve DEV ortaminda sifre kontrolü yapilmiyor..
      END IF;

      -- valid sifre girilmisse; hatali giris sayisi sifirlanacak...
      IF (valid_login)
      THEN
         OPEN cur_sifre;

         FETCH cur_sifre INTO rec_sifre;

         UPDATE mb_abone_sifre
            SET hatali_giris_sayisi = 0,
                degistirme_tarihi = SYSDATE,
                degistiren_kullanici = kaynak_kullanici_bul (v_kaynak)
          WHERE account_number = v_account_number;

         --CURRENT OF cur_sifre;

         CLOSE cur_sifre;

         o_islem_sonuc_tip := 0;
         o_islem_sonuc_kod := 'VLD210';

         -- 22/09/2004 Emine; LG ve VS aboneleri de DIGIWEB kullanacaklardir, TK(tek kart) üyeleri kullanamayacak
         IF (v_stb_tipi NOT IN ('PH',
                                'LG',
                                'VS',
                                'ZS'))
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR13';
         ELSE
            /* 1: Bireysel , 2 : Ticari, 3: Otel, 4:? */
            v_musteri_tipi_grup := musteri_tip_grup_bul (v_musteri_tipi);

            IF (v_musteri_tipi_grup <> 1 AND v_musteri_tipi_grup <> 2)
            THEN
               o_islem_sonuc_tip := 1;
               o_islem_sonuc_kod := 'ERR14';
            END IF;
         END IF;

         IF     o_islem_sonuc_tip = 0
            AND NVL (rec_sifre.hatali_giris_sayisi, 0) <> 0
         THEN
            o_islem_sonuc_mesaj :=
                  'Sifreniz '
               || rec_sifre.hatali_giris_sayisi
               || ' kez hatali girilmistir!!!';
         END IF;
      -- invalid sifre girilmisse;
      ELSE
         abone_sifre_hatali_giris (v_account_number,
                                   v_kaynak,
                                   o_islem_sonuc_tip,
                                   o_islem_sonuc_kod);
      -- ERR8, ERR10, ERR979
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         RAISE;
   END;                                                 -- ABONE_SIFRE_KONTROL

   /****************************************************************************/
   PROCEDURE abone_sifre_kontrol (                  -- sisteme login (digiweb)
      in_account_number     IN OUT mb_abone_sifre.account_number%TYPE,
      in_phone_country      IN     mb_abone_telefon.ulke_kodu%TYPE,
      in_phone_area         IN     mb_abone_telefon.alan_kodu%TYPE,
      in_phone_number       IN     mb_abone_telefon.telefon_no%TYPE,
      in_sifre              IN     mb_abone_sifre.sifre_1%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      in_session_id         IN     NUMBER,
      o_islem_log_id           OUT NUMBER,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Process Code : 69 (sifre kontrolü, diginet-digiweb)
      Logging (valid, invalid)*/
      /* Result Codes:
      ERR8:  Sifre kaydi kilitli
      ERR10: Girilen sifre yanlis ve sifre kilitlenmis
      ERR13: Uygulamaya giris engelleniyor (vestel)
      ERR14: Uygulamaya giris engelleniyor (bireysel ve ticari olmayanlar)
      ERR978: kullanici invalid
      ERR979: Girilen sifre yanlis
      ERR217:Sifre girisi eksik (5 karakterden az giris)
      ERR18: SessionId null
      ERR19: Session kaydedilemedi
      ERR20: Login sirasinda islem logu atilamadi
      ERR21: Login sirasinda exception
      ERR17: Ilk giris için outlet yok
      ERR479:Geçersiz TelefonNumarasi / Abone*/
      -- bu prosedür hem bagimsiz olarak çagiriliyor, hem de sifreDegistir isleminden
      /* Tanim: Abonenin sifre kontrolünü yapar. Girilen sifre geçerliyse aktif session
      olarak bu giris set edilir. sifre case sensitive. (WEB ve NET kaynaklari için run edilir)*/
      v_account_number          mb_abone_sifre.account_number%TYPE
                                   := account_number_bul (in_account_number);
      v_kaynak                  mb_abone_sifre.kaynak%TYPE
                                   := upper_string (TRIM (in_kaynak));
      v_abone_session_kontrol   VARCHAR2 (1) := 'H';

      CURSOR cur_sifre
      IS
         SELECT *
           FROM mb_abone_sifre
          WHERE     account_number = v_account_number
                AND (kaynak = ias_sabit_pack.kaynak_sifre)
         FOR UPDATE;

      rec_sifre                 cur_sifre%ROWTYPE;
      v_islem_tipi              NUMBER (1);
      v_kullanici               VARCHAR2 (20);
      v_parametre               VARCHAR2 (1000);
      v_islem_kod               NUMBER (3) := 69;
      v_dm_uye                  NUMBER (10);
      v_dm_outlet               VARCHAR2 (3);
      v_dm_phone_country        mb_abone_telefon.ulke_kodu%TYPE
                                   := in_phone_country;
      v_dm_phone_area           mb_abone_telefon.alan_kodu%TYPE
                                   := in_phone_area;
      v_dm_phone_number         mb_abone_telefon.telefon_no%TYPE
                                   := in_phone_number;
      v_dm_phone_type           mb_abone_telefon.telefon_tipi%TYPE;
      v_dm_phone_id             mb_abone_telefon.id%TYPE;
      v_islem_sonuc_kod         VARCHAR2 (20);
   BEGIN
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_islem_kod,
                                  TO_CHAR (v_islem_kod),
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_no,
                                  v_account_number,
                                  FALSE);
      ias_islem_parametre_doldur (
         v_parametre,
         ias_sabit_pack.key_register_telno,
         in_phone_country || '-' || in_phone_area || '-' || in_phone_number,
         TRUE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_sifre,
                                  digipaket_sifre.encrypt (in_sifre),
                                  FALSE);
      tran_pack.dbs_savepoint ('ILK_DURUM');

      IF     v_account_number IS NULL
         AND v_dm_phone_country IS NOT NULL
         AND v_dm_phone_area IS NOT NULL
         AND v_dm_phone_number IS NOT NULL
      THEN
         ias_kayit_pack.abone_telefon_bul (v_dm_uye,
                                           v_dm_outlet,
                                           v_dm_phone_type,
                                           v_dm_phone_country,
                                           v_dm_phone_area,
                                           v_dm_phone_number,
                                           v_kaynak,
                                           in_session_id,
                                           v_islem_tipi,
                                           v_dm_phone_id);

         IF (   v_islem_tipi = 1
             OR (    v_account_number IS NOT NULL
                 AND v_dm_uye <> v_account_number))
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR479';
         ELSIF v_account_number IS NULL
         THEN
            v_account_number := v_dm_uye;
         END IF;
      END IF;

      in_account_number := v_account_number;

      IF o_islem_sonuc_tip = 0 OR o_islem_sonuc_tip IS NULL
      THEN
         IF (   in_session_id IS NULL
             OR (listede_var_mi (
                    ias_dba.get_param_value (
                       'IAS_SIFRE_KAYNAK_ALLOWENCE_LIST'),
                    ',',
                    in_kaynak)) = FALSE) -- bu kontrol islem_oncesi_kontrol içerisine alinsa daha okunakli olurmus; emine; 07/10/2009
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR18';
         ELSE
            BEGIN
               IF ( (listede_var_mi (
                        ias_dba.get_param_value (
                           'ACCOUNT_SESSION_KONTROL_KAYNAK_LIST'),
                        ',',
                        v_kaynak)) = FALSE)
               THEN
                  v_abone_session_kontrol := 'E';
               END IF;

               ias_islem_kontrol_pack.islem_oncesi_kontrol (
                  v_account_number,                      /*in_account_number*/
                  NULL                                      /*in_outlet_code*/
                      ,
                  NULL                                    /*in_serial_number*/
                      ,
                  v_kaynak                                       /*in_kaynak*/
                          ,
                  v_islem_kod                                  /*in_islem_id*/
                             ,
                  o_islem_sonuc_tip                          /*out_sonuc_tip*/
                                   ,
                  o_islem_sonuc_kod                          /*out_sonuc_kod*/
                                   ,
                  v_abone_session_kontrol,
                  in_session_id,
                  'H',
                  NULL);
            END;
         END IF;
      END IF;

      IF o_islem_sonuc_tip = 0
      THEN
         abone_sifre_kontrol (v_account_number,
                              in_sifre,
                              v_kaynak,
                              o_islem_sonuc_tip,
                              o_islem_sonuc_kod,
                              o_islem_sonuc_mesaj);

         IF (o_islem_sonuc_tip = 0)
         THEN
            /* ias_islem_kontrol_pack.islem_oncesi_kontrol(v_account_number \*in_account_number*\,
                                                         NULL \*in_outlet_code*\,
                                                         NULL \*in_serial_number*\,
                                                         v_kaynak \*in_kaynak*\,
                                                         v_islem_kod \*in_islem_id*\,
                                                         o_islem_sonuc_tip \*out_sonuc_tip*\,
                                                         v_islem_sonuc_kod \*out_sonuc_kod*\);*/

            --IF o_islem_sonuc_tip = 1 THEN
            --  o_islem_sonuc_kod := v_islem_sonuc_kod;
            --ELSE
            /**
            *  MULTISCREEN KAYNAKLARI ICIN SESSIN ACTIVATE ADIMI ATLATILMALI...
            *  AYNI KULLANICI AYNI ANDA AYNI KAYNAKLA BIRDEN FAZLA ISLEM YAPABILMESI ICIN
            *  IAS_PARAMS -> IAS_MULTISCREEN_KAYNAK_LIST
            *  19.02.2013 TOPLANTI KARARI, ERSEN
            **/
            IF ( (listede_var_mi (
                     ias_dba.get_param_value ('IAS_MULTISCREEN_KAYNAK_LIST'),
                     ',',
                     v_kaynak)) = FALSE)
            THEN
               ias_log_session_pack.session_activate (in_session_id,
                                                      v_kaynak,
                                                      v_account_number,
                                                      NULL,
                                                      NULL,
                                                      NULL);
            END IF;

            IF (o_islem_sonuc_tip = 1)
            THEN
               o_islem_sonuc_kod := 'ERR19';
            -- session loguna insert edilemedi
            ELSE
               -- kullanici basarili login olmus
               OPEN cur_sifre;

               FETCH cur_sifre INTO rec_sifre;

               v_kullanici := kaynak_kullanici_bul (v_kaynak);

               -- sifre degistirilmesi gerekmiyorsa giris sayisi arttirilir (web sinirlandirlmasi yapilmasi istenmedi, ESEN)
               IF (rec_sifre.sifre_degistir <> 'E')
               THEN
                  UPDATE mb_abone_sifre
                     SET giris_sayisi = NVL (giris_sayisi, 0) + 1,
                         sifre_giris_sayisi = NVL (sifre_giris_sayisi, 0) + 1,
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = v_kullanici
                   WHERE CURRENT OF cur_sifre;
               END IF;

               -- sifre degistirme sarti saglanilmis (digiweb, diginet)
               IF (NVL (rec_sifre.sifre_giris_sayisi, 0) + 1 >=
                      dbs_sabit ('SIFRE_DEGISTIR_SAYISI'))
               THEN
                  UPDATE mb_abone_sifre
                     SET sifre_degistir = 'E',
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = v_kullanici
                   WHERE CURRENT OF cur_sifre;
               END IF;

               CLOSE cur_sifre;
            END IF;
         --END IF;
         END IF;

         IF o_islem_sonuc_tip = 1
         THEN
            o_islem_sonuc_mesaj := NULL;
         END IF;
      END IF;

      -- logging result
      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     v_account_number,
                                     NULL,
                                     NULL,
                                     ias_sabit_pack.kaynak_sifre,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     NULL,
                                     'ABONE_SIFRE_KONTROL',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         -- islem logu atilamazsa islem geri alinir...
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR20';
         END IF;
      END IF;

      /* Bu dönüsler sifrenin kaç kez hatali girildigi haricinde döndürülmelidir, hatali oldugunda döndürülebilir,
      o da simdilik WEB uygulamasinda cacheden aliniyor - Bu cümle artik geçersiz :)) Emine*/
      IF o_islem_sonuc_tip = 1
      THEN
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR21';

         /* Bu dönüsler sifrenin kaç kez hatali girildigi haricinde döndürülmelidir, hatali oldugunda döndürülebilir,
         o da simdilik WEB uygulamasinda cacheden aliniyor */
         --o_islem_sonuc_mesaj := IAS_ISLEM_MESAJ_BUL(o_islem_sonuc_kod, in_kaynak, v_parametre, o_islem_sonuc_mesaj);
         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           v_account_number,
                                           NULL,
                                           NULL,
                                           ias_sabit_pack.kaynak_sifre,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_SIFRE_KONTROL',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;                                                 -- ABONE_SIFRE_KONTROL

   /************************************************************************/
   PROCEDURE abone_sifre_degistir (
      in_account_number     IN     mb_abone_sifre.account_number%TYPE,
      in_eski_sifre         IN     mb_abone_sifre.sifre_1%TYPE,
      in_yeni_sifre         IN     mb_abone_sifre.sifre_1%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      in_session_id         IN     NUMBER,
      o_islem_log_id           OUT NUMBER,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Process Code : 70
      Logging (valid, invalid)*/
      /* Result Codes:
      ERR8: Sifre kilitli
      ERR11: Session aktif session degil
      ERR10, ERR979 (Abone-sifre-kontrol'den dönüyor)
      ERR60: Sifre geçersiz (Mevcut sifre ile ayni deger, invalid deger)
      ERR61: Log atilamadi
      ERR62: Exception (MB_ABONE_SIFRE tablosuna insert veya baska birsey)
      VLD63: Islem ok*/
      /* Tanim: Aktif sessiondaki abonenin girdigi sifre geçerli ise sifre kaydi,
      yeni girilen sifreye update edilir. Buradaki yanlis girilen sifre de sifre
      kaydini kilitliyor. Mevcut sifre ile yeni girilen sifrenin farkli olmasi
      gerekmektedir*/
      v_account_number       mb_abone_sifre.account_number%TYPE
                                := account_number_bul (in_account_number);
      v_kaynak               mb_abone_sifre.kaynak%TYPE
                                := upper_string (LTRIM (RTRIM (in_kaynak)));

      CURSOR cur_sifre
      IS
         SELECT *
           FROM mb_abone_sifre
          WHERE     account_number = v_account_number
                AND kaynak = ias_sabit_pack.kaynak_sifre
         FOR UPDATE;

      rec_sifre              cur_sifre%ROWTYPE;
      v_kullanici            VARCHAR2 (20);
      v_sonuc                NUMBER (10);
      v_islem_tipi           NUMBER (1);
      v_hatali_giris_mesaj   VARCHAR2 (100);
      v_parametre            VARCHAR2 (1000);
      v_islem_kod            NUMBER (3) := 70;
      v_sifre                mb_abone_sifre.sifre_1%TYPE;
   BEGIN
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_islem_kod,
                                  TO_CHAR (v_islem_kod),
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_no,
                                  v_account_number,
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_sifre,
                                  digipaket_sifre.encrypt (in_eski_sifre),
                                  TRUE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_yenisifre,
                                  digipaket_sifre.encrypt (in_yeni_sifre),
                                  TRUE);
      -- sifre case sensitive olacak!!!
      tran_pack.dbs_savepoint ('ILK_DURUM');
      ias_islem_kontrol_pack.islem_oncesi_kontrol (v_account_number /*in_account_number*/
                                                                   ,
                                                   NULL     /*in_outlet_code*/
                                                       ,
                                                   NULL   /*in_serial_number*/
                                                       ,
                                                   v_kaynak      /*in_kaynak*/
                                                           ,
                                                   v_islem_kod /*in_islem_id*/
                                                              ,
                                                   o_islem_sonuc_tip /*out_sonuc_tip*/
                                                                    ,
                                                   o_islem_sonuc_kod /*out_sonuc_kod*/
                                                                    ,
                                                   'E'  /*in_session_kontrol*/
                                                      ,
                                                   in_session_id /*in_session_id*/
                                                                );

      IF o_islem_sonuc_tip = 0
      THEN
         IF (   in_eski_sifre = in_yeni_sifre
             OR NOT ias_kontrol_pack.is_sifre (in_yeni_sifre))
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR60';
         ELSE
            abone_sifre_kontrol (v_account_number,
                                 in_eski_sifre,
                                 v_kaynak,
                                 o_islem_sonuc_tip,
                                 o_islem_sonuc_kod,
                                 v_hatali_giris_mesaj);

            -- ERR8, ERR10, ERR13, ERR14, ERR979 error codelari dönüyor
            IF o_islem_sonuc_tip = 0
            THEN
               v_kullanici := kaynak_kullanici_bul (v_kaynak);

               OPEN cur_sifre;

               FETCH cur_sifre INTO rec_sifre;

               IF cur_sifre%NOTFOUND
               THEN
                  o_islem_sonuc_tip := 1;
                  o_islem_sonuc_kod := 'ERR62';
               ELSE
                  /******* ESKİ ***************************
                  v_sifre := digipaket_sifre.encrypt (in_yeni_sifre);

                  UPDATE mb_abone_sifre
                     SET sifre_1 = v_sifre,
                         sifre_2 = v_sifre,
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = v_kullanici
                   WHERE CURRENT OF cur_sifre;
                   ******* ESKİ ***************************/

                  /******* YENİ ***************************/

                  dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update (
                     v_account_number   => v_account_number,
                     v_sifre_1          => in_yeni_sifre,
                     v_sifre_2          => in_yeni_sifre,
                     v_deneme           => 0,
                     v_kullanici        => v_kullanici,
                     v_kaynak           => ias_sabit_pack.kaynak_sifre,
                     v_sonuc            => v_sonuc);

                  IF (v_sonuc = 0)
                  THEN
                     raise_application_error (
                        -20101,
                        'dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update -- EXCEPTION');
                  END IF;

                  /******* YENİ ***************************/

                  -- sifre degisikligi zorunluyken degistirilmisse
                  -- giris sayisi bir arttirilir (login esnasinda yapilmaz bu islem)
                  IF (rec_sifre.sifre_degistir = 'E')
                  THEN
                     UPDATE mb_abone_sifre
                        SET giris_sayisi = NVL (giris_sayisi, 0) + 1,
                            degistirme_tarihi = SYSDATE,
                            degistiren_kullanici = v_kullanici
                      WHERE CURRENT OF cur_sifre;
                  END IF;

                  -- Sifre degistiriminden sonra yeni sifreye iliskin degerler
                  UPDATE mb_abone_sifre
                     SET sifre_degistir = 'H',
                         sifre_giris_sayisi = 1,
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = v_kullanici
                   WHERE CURRENT OF cur_sifre;

                  o_islem_sonuc_tip := 0;
                  o_islem_sonuc_kod := 'VLD63';
               END IF;

               CLOSE cur_sifre;
            END IF;   -- abone sifre kontrolü (dönen hata kodu degistirilmedi)
         END IF;                                  -- girilen sifre geçerliligi
      END IF;                                               -- session validse

      -- logging result
      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     v_account_number,
                                     NULL,
                                     NULL,
                                     ias_sabit_pack.kaynak_sifre,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     NULL,
                                     'ABONE_SIFRE_DEGISTIR',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         -- islem logu atilamazsa islem geri alinir...
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR61';
         END IF;
      END IF;

      o_islem_sonuc_mesaj :=
         ias_islem_mesaj_bul (o_islem_sonuc_kod,
                              in_kaynak,
                              v_parametre,
                              o_islem_sonuc_mesaj);
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR62';
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);

         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           v_account_number,
                                           NULL,
                                           NULL,
                                           ias_sabit_pack.kaynak_sifre,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_SIFRE_DEGISTIR',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;                                                -- ABONE_SIFRE_DEGISTIR

   /************************************************************************/
   PROCEDURE abone_sifre_sifirla (
      in_account_number        IN     web_vv_uye_ekipman.uye_no%TYPE,
      in_outlet_code           IN     web_vv_uye_ekipman.outlet%TYPE,
      in_serial_number         IN     web_vv_uye_ekipman.seri_no%TYPE,
      in_kaynak                IN     mb_abone_sifre.kaynak%TYPE,
      o_sifre                     OUT mb_abone_sifre.sifre_1%TYPE,
      o_islem_sonuc_tip           OUT NUMBER,
      o_islem_sonuc_kod           OUT VARCHAR2,
      o_islem_sonuc_aciklama      OUT VARCHAR2)
   IS
      CURSOR cur_sifre
      IS
         SELECT *
           FROM mb_abone_sifre
          WHERE     account_number = in_account_number
                AND kaynak = ias_sabit_pack.kaynak_sifre
         FOR UPDATE;

      rec_sifre     cur_sifre%ROWTYPE;
      v_kullanici   VARCHAR2 (20);
      v_sonuc       NUMBER (10);
   BEGIN
      v_kullanici := kaynak_kullanici_bul (upper_string (TRIM (in_kaynak)));

      IF (NVL (ias_dba.get_param_value ('RANDOM_PSW_URETMEYI_KULLAN'), 'H') =
             'H')
      THEN
         -- TUNAHAN 22.11.2012
         BEGIN
              -- son 5 hanesini almak için parametrik olsun diye
              SELECT SUBSTR (seri_no, LENGTH (seri_no) - 4, 5)
                INTO o_sifre
                FROM web_vv_uye_ekipman
               WHERE uye_no = in_account_number AND ROWNUM = 1
            ORDER BY outlet;
         EXCEPTION
            WHEN OTHERS
            THEN
               o_islem_sonuc_tip := 1;
               o_islem_sonuc_kod := 'ERR1024';
               RETURN;
         END;
      ELSE
         o_sifre := ias_dba.generate_rnd_psw; -- 5 KAREKTERDEN OLUSAN NUMARALAR VE HARFLERDEN MUTEVLLI RANDOM BIR PASWORD URETILIR... tuna 22.11.2012
      END IF;

      /*******ESKİ*********************************
      o_sifre := digipaket_sifre.encrypt (o_sifre);
     *********ESKİ*******************************/

      OPEN cur_sifre;

      FETCH cur_sifre INTO rec_sifre;

      IF cur_sifre%NOTFOUND
      THEN
         /*******ESKİ*********************************
         INSERT INTO mb_abone_sifre (account_number,
                                     sifre_1,
                                     sifre_2,
                                     giren_kullanici,
                                     degistiren_kullanici,
                                     kaynak)
              VALUES (in_account_number,
                      o_sifre,
                      o_sifre,
                      v_kullanici,
                      v_kullanici,
                      ias_sabit_pack.kaynak_sifre);
         *********ESKİ*******************************/

         /*******YENİ*********************************/
         dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update (
            v_account_number   => in_account_number,
            v_sifre_1          => o_sifre,
            v_sifre_2          => o_sifre,
            v_deneme           => 0,
            v_kullanici        => v_kullanici,
            v_kaynak           => ias_sabit_pack.kaynak_sifre,
            v_sonuc            => v_sonuc);

         IF (v_sonuc = 0)
         THEN
            raise_application_error (
               -20101,
               'dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update -- EXCEPTION');
         END IF;
      /*********YENİ*******************************/

      ELSE
         IF rec_sifre.kilitli = 'E'
         THEN
            o_islem_sonuc_aciklama := 'KILIT KALDIRILDI';
         END IF;

         /*******ESKİ*********************************
         UPDATE mb_abone_sifre
            SET sifre_1 = o_sifre,
                sifre_2 = o_sifre,
                sifre_degistir = 'E',
                sifre_giris_sayisi = 0,
                kilitli = 'H',
                kilit_tarihi = NULL,
                hatali_giris_sayisi = 0,
                hatali_giris_tarihi = NULL,
                degistirme_tarihi = SYSDATE,
                degistiren_kullanici = v_kullanici
          WHERE CURRENT OF cur_sifre;
          *********ESKİ*******************************/

         /*******YENİ*********************************/

         dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update (
            v_account_number   => in_account_number,
            v_sifre_1          => o_sifre,
            v_sifre_2          => o_sifre,
            v_deneme           => 0,
            v_kullanici        => v_kullanici,
            v_kaynak           => ias_sabit_pack.kaynak_sifre,
            v_sonuc            => v_sonuc);

         IF (v_sonuc = 0)
         THEN
            raise_application_error (
               -20101,
               'dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update -- EXCEPTION');
         END IF;

         UPDATE mb_abone_sifre
            SET sifre_degistir = 'E',
                sifre_giris_sayisi = 0,
                kilitli = 'H',
                kilit_tarihi = NULL,
                hatali_giris_sayisi = 0,
                hatali_giris_tarihi = NULL
          WHERE CURRENT OF cur_sifre;
      /*********YENİ*******************************/

      END IF;

      CLOSE cur_sifre;

      o_islem_sonuc_tip := 0;
      o_islem_sonuc_kod := 'VLD59';
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR58';
   END;

   /************************************************************************/
   PROCEDURE abone_sifre_sifirla (
      in_account_number     IN     web_vv_uye_ekipman.uye_no%TYPE,
      in_outlet_code        IN     web_vv_uye_ekipman.outlet%TYPE,
      in_serial_number      IN     web_vv_uye_ekipman.seri_no%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      in_session_id         IN     NUMBER,
      o_islem_log_id           OUT NUMBER,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Process Code : 85
      Logging (valid, invalid)*/
      /* Result Codes:
      ERR57: Log atilamadi
      ERR58: Exception
      VLD59: Islem ok*/
      v_account_number   mb_abone_sifre.account_number%TYPE
                            := account_number_bul (in_account_number);
      v_kaynak           mb_abone_sifre.kaynak%TYPE
                            := upper_string (TRIM (in_kaynak));
      v_sifre            mb_abone_sifre.sifre_1%TYPE;
      v_islem_tipi       NUMBER (1);
      v_sonuc_aciklama   VARCHAR2 (100);
      v_parametre        VARCHAR2 (1000);
      v_islem_kod        NUMBER (3) := 85;
   BEGIN
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_islem_kod,
                                  TO_CHAR (v_islem_kod),
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_no,
                                  v_account_number,
                                  FALSE);
      tran_pack.dbs_savepoint ('ILK_DURUM');
      ias_islem_kontrol_pack.islem_oncesi_kontrol (v_account_number /*in_account_number*/
                                                                   ,
                                                   in_outlet_code /*in_outlet_code*/
                                                                 ,
                                                   in_serial_number /*in_serial_number*/
                                                                   ,
                                                   v_kaynak      /*in_kaynak*/
                                                           ,
                                                   v_islem_kod /*in_islem_id*/
                                                              ,
                                                   o_islem_sonuc_tip /*out_sonuc_tip*/
                                                                    ,
                                                   o_islem_sonuc_kod /*out_sonuc_kod*/
                                                                    );

      IF o_islem_sonuc_tip = 0
      THEN
         abone_sifre_sifirla (v_account_number,
                              in_outlet_code,
                              in_serial_number,
                              v_kaynak,
                              v_sifre,
                              o_islem_sonuc_tip,
                              o_islem_sonuc_kod,
                              v_sonuc_aciklama);
      END IF;

      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     v_account_number,
                                     in_outlet_code,
                                     in_serial_number,
                                     ias_sabit_pack.kaynak_sifre,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     v_sonuc_aciklama,
                                     'ABONE_SIFRE_SIFIRLA',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR57';
            o_islem_sonuc_mesaj := NULL;
         END IF;
      END IF;

      o_islem_sonuc_mesaj :=
         ias_islem_mesaj_bul (o_islem_sonuc_kod,
                              in_kaynak,
                              v_parametre,
                              o_islem_sonuc_mesaj);
   EXCEPTION
      WHEN OTHERS
      THEN
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR58';
         o_islem_sonuc_mesaj := NULL;
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);

         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           v_account_number,
                                           in_outlet_code,
                                           in_serial_number,
                                           ias_sabit_pack.kaynak_sifre,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_SIFRE_SIFIRLA',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;                                                 -- ABONE_SIFRE_SIFIRLA

   /************************************************************************/
   PROCEDURE abone_sifre_sifirla_sms (
      in_phone_country      IN     mb_abone_telefon.ulke_kodu%TYPE,
      in_phone_area         IN     mb_abone_telefon.alan_kodu%TYPE,
      in_phone_number       IN     mb_abone_telefon.telefon_no%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      in_session_id         IN     NUMBER,
      o_islem_log_id           OUT NUMBER,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Bu akis digiweb sifresine sahip olmak isteyen telefonu kayitli olan abonelere kolaylik saglamak için kurgulanmistir.
      Öncelikle tv guide için amaçlanmistir, ayni fonksiyonalitenin digiweb uygulamasi üzerine eklenmesi de planlanmaktadir.
      Kayitli olunan telefon numarasi sisteme girildiginde gerekli kontrolleri (register kontrol, günlük islem adedi kisiti)
      geçtikten sonra sifirlanan digiweb sifresi abonenin *giris yaptigi kayitli telefonuna gönderilmektedir. */
      v_account_number       mb_abone_sifre.account_number%TYPE;
      v_kaynak               mb_abone_sifre.kaynak%TYPE
                                := upper_string (TRIM (in_kaynak));
      v_sifre                mb_abone_sifre.sifre_1%TYPE;
      v_islem_tipi           NUMBER (1);
      v_sonuc_aciklama       VARCHAR2 (100);
      v_parametre            VARCHAR2 (4000);
      v_islem_kod            NUMBER (3) := 225;
      v_sms_id               NUMBER (10);
      v_sms_mesaj            VARCHAR2 (255);
      v_sms_sonuc_tip        NUMBER (1);
      v_sms_sonuc_mesaj      VARCHAR2 (255);
      v_gunluk_islem_adedi   NUMBER (3);
      v_session_kontrol      VARCHAR2 (1) := 'H';
   BEGIN
      ias_dba.ias_islem_parametre_doldur (
         v_parametre,
         ias_dba.ias_sabit_pack.key_islem_kod,
         TO_CHAR (v_islem_kod),
         FALSE);
      ias_islem_parametre_doldur (
         v_parametre,
         ias_sabit_pack.key_register_telno,
         in_phone_country || '-' || in_phone_area || '-' || in_phone_number,
         TRUE);
      tran_pack.dbs_savepoint ('ILK_DURUM');

      IF in_kaynak <> 'WEB'
      THEN -- OIM'den şifre sıfırlama tetiklendiğinde henüz account - session ilişkisi kurulmadığı için
         v_session_kontrol := 'E'; -- bu değerin 'H'de kalması gerekiyor. OIM akışlarında IP kontrolü olduğu için session
      END IF;                             -- doğruluk kontrolüne zorlamıyoruz.

      ias_dba.ias_islem_kontrol_pack.islem_oncesi_kontrol (NULL,
                                                           NULL /*in_outlet_code*/
                                                               ,
                                                           NULL /*in_serial_no*/
                                                               ,
                                                           v_kaynak /*in_kaynak*/
                                                                   ,
                                                           v_islem_kod /*in_islem_id*/
                                                                      ,
                                                           o_islem_sonuc_tip /*out_sonuc_tip*/
                                                                            ,
                                                           o_islem_sonuc_kod /*out_sonuc_kod*/
                                                                            ,
                                                           v_session_kontrol /*in_session_kontrol*/
                                                                            ,
                                                           in_session_id /*in_session_id*/
                                                                        );

      IF o_islem_sonuc_tip = 0
      THEN
         BEGIN
            SELECT r.account_number
              INTO v_account_number
              FROM vv_abone_telefon_register r, wiz_customer_hp_life l
             WHERE     r.ulke_kodu = in_phone_country
                   AND r.alan_kodu = in_phone_area
                   AND r.telefon_no = in_phone_number
                   AND r.listeden_gizle = 'H'
                   AND r.account_number = l.account_number
                   AND l.customer_status = 'AC';

            ias_dba.ias_islem_parametre_doldur (
               v_parametre,
               ias_dba.ias_sabit_pack.key_uye_no,
               v_account_number,
               FALSE);
         EXCEPTION
            WHEN OTHERS
            THEN
               o_islem_sonuc_tip := 1;
               o_islem_sonuc_kod := 'ERR974';          --Telefon kayıtlı değil
         END;
      END IF;

      IF o_islem_sonuc_tip = 0 AND v_account_number IS NOT NULL
      THEN
         ias_dba.ias_islem_kontrol_pack.islem_oncesi_kontrol (
            v_account_number,
            NULL                                            /*in_outlet_code*/
                ,
            NULL                                              /*in_serial_no*/
                ,
            v_kaynak                                             /*in_kaynak*/
                    ,
            v_islem_kod                                        /*in_islem_id*/
                       ,
            o_islem_sonuc_tip                                /*out_sonuc_tip*/
                             ,
            o_islem_sonuc_kod                                /*out_sonuc_kod*/
                             ,
            'H'                                         /*in_session_kontrol*/
               ,
            in_session_id                                    /*in_session_id*/
                         );

         IF o_islem_sonuc_tip = 0
         THEN
            -- ayni gun icinde o kanaldan maximum 3 defa deneyebilsin..
            SELECT COUNT (1)
              INTO v_gunluk_islem_adedi
              FROM ias_log_islem
             WHERE     account_number = v_account_number
                   AND islem_kodu = v_islem_kod
                   AND mesaj_tipi = 0
                   AND TRUNC (islem_tarihi) = TRUNC (SYSDATE);

            IF v_gunluk_islem_adedi >= 3
            THEN
               o_islem_sonuc_tip := 1;
               o_islem_sonuc_kod := 'ERR969';
            -- gunluk maximum islem adedi siniri asildi
            ELSE
               abone_sifre_sifirla (v_account_number,
                                    NULL,
                                    NULL,
                                    v_kaynak,
                                    v_sifre,
                                    o_islem_sonuc_tip,
                                    o_islem_sonuc_kod,
                                    v_sonuc_aciklama);
            END IF;

            IF o_islem_sonuc_tip = 0
            THEN
               v_sms_mesaj :=
                  ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                       v_kaynak,
                                       v_parametre,
                                       NULL);

               --Quick SMS yapısı türkçe karakter göndermiyor. make it english.Soner
               v_sms_mesaj := ias_string_funcs.english_string (v_sms_mesaj);

               /*ias_sms_pack.gonderim_istek_yarat(85,
                                                 'reminder',
                                                 'dbs',
                                                 in_phone_area ||
                                                 in_phone_number,
                                                 v_sms_mesaj,
                                                 SYSDATE,
                                                 v_sms_id,
                                                 v_sms_sonuc_tip,
                                                 v_sms_sonuc_mesaj,
                                                 v_account_number,
                                                 NULL,
                                                 NULL,
                                                 in_phone_country);*/

               --Digiturk'den SMS almayı engelleyen müşterilere ulaşabilmek için quick SMS yapısı kullanılmaya başlandı. 14/11/2013 - Soner
               kontrat_pack.send_quick_sms (in_phone_area || in_phone_number,
                                            v_sms_mesaj,
                                            v_sonuc_aciklama);

               IF v_sonuc_aciklama = 0
               THEN
                  o_islem_sonuc_kod := 'VLD976';
                  ias_islem_parametre_doldur (v_parametre,
                                              'BILGILENDIRME_SMS_ID',
                                              TO_CHAR (v_sms_id),
                                              TRUE);
               ELSE
                  o_islem_sonuc_tip := 1;
                  o_islem_sonuc_kod := 'ERR975';
               END IF;
            END IF;

            IF o_islem_sonuc_tip = 1
            THEN
               tran_pack.dbs_rollback ('ILK_DURUM');
            END IF;
         END IF;
      END IF;

      o_islem_sonuc_mesaj :=
         ias_islem_mesaj_bul (o_islem_sonuc_kod,
                              in_kaynak,
                              v_parametre,
                              o_islem_sonuc_mesaj);

      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     v_account_number,
                                     NULL,
                                     NULL,
                                     ias_sabit_pack.kaynak_sifre,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     o_islem_sonuc_mesaj,
                                     'ABONE_SIFRE_SIFIRLA_SMS',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR57';
            o_islem_sonuc_mesaj := NULL;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR58';
         o_islem_sonuc_mesaj := NULL;
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);

         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           v_account_number,
                                           NULL             /*in_outlet_code*/
                                               ,
                                           NULL               /*in_serial_no*/
                                               ,
                                           ias_sabit_pack.kaynak_sifre,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_SIFRE_SIFIRLA_SMS',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;                                             -- ABONE_SIFRE_SIFIRLA_SMS

   /***********************************************************************************/
   PROCEDURE abone_sifresiz_kontrol (
      in_account_number      IN OUT mb_abone_sifre.account_number%TYPE,
      in_phone_country       IN     mb_abone_telefon.ulke_kodu%TYPE,
      in_phone_area          IN     mb_abone_telefon.alan_kodu%TYPE,
      in_phone_number        IN     mb_abone_telefon.telefon_no%TYPE,
      in_ad                  IN     wiz_customer_descrip.first_name%TYPE,
      in_soyad               IN     wiz_customer_descrip.last_name%TYPE,
      in_anne_kizlik_soyad   IN     mb_abone_detay_bilgi.anne_kizlik_soyadi%TYPE,
      in_dogum_tarihi        IN     mb_abone_detay_bilgi.dogum_tarihi%TYPE,
      in_kaynak              IN     mb_abone_sifre.kaynak%TYPE,
      in_email               IN OUT VARCHAR2,
      in_session_id          IN     NUMBER,
      o_islem_log_id            OUT NUMBER,
      o_sifre                   OUT ias_gizli_abone_sifre.gizli_sifre%TYPE,
      o_islem_sonuc_tip         OUT NUMBER,
      o_islem_sonuc_kod         OUT VARCHAR2,
      o_islem_sonuc_mesaj       OUT VARCHAR2)
   IS
      /* Process Code : 71
      Logging (valid, invalid)*/
      /* Result Codes:
      ERR8:   Sifre kilitli
      ERR10:  Hatalardan dolayi sifre kilitlendi
      ERR13:  Uygulamaya giris engelleniyor (vestel)
      ERR14:  Uygulamaya giris engelleniyor (bireysel ve ticari olmayanlar)
      ERR980: kullanici invalid
      ERR981: Girilen bilgiler invalid
      VLD52:  Ok
      ERR53:  Log atilamadi
      ERR54:  Exception
      ERR343: SIFRE_UNUT:bireysel olmayan abonelerin islemi engelleniyor*/
      /* Tanim: Sifremi Unuttum isleminde kisisel bilgiler kontrol edilir. Girilen
      veriler dogruysa, gizli sifre olusturularak kaydi atilir. Java kodundan da
      mail gönderilir.*/
      v_account_number      mb_abone_sifre.account_number%TYPE
                               := account_number_bul (in_account_number);
      v_kaynak              mb_abone_sifre.kaynak%TYPE
                               := upper_string (TRIM (in_kaynak));
      v_stb_tipi            CHAR (2);
      v_musteri_tipi        CHAR (3);
      v_musteri_tipi_grup   NUMBER (1);
      v_kilitli_sifre       BOOLEAN;
      v_kayit_dogru         BOOLEAN := FALSE;
      v_sayi                NUMBER (5);
      v_islem_tipi          NUMBER (1);
      p_ad                  wiz_customer_descrip.first_name%TYPE;
      p_soyad               wiz_customer_descrip.last_name%TYPE;
      p_anne_kizlik_soyad   mb_abone_detay_bilgi.anne_kizlik_soyadi%TYPE;
      p_dogum_tarihi        mb_abone_detay_bilgi.dogum_tarihi%TYPE;
      v_ad                  wiz_customer_descrip.first_name%TYPE
                               := REPLACE (in_ad, '''', '');
      v_soyad               wiz_customer_descrip.last_name%TYPE
                               := REPLACE (in_soyad, '''', '');
      v_anne_kizlik_soyad   mb_abone_detay_bilgi.anne_kizlik_soyadi%TYPE
                               := REPLACE (in_anne_kizlik_soyad, '''', '');
      v_parametre           VARCHAR2 (1000);
      v_islem_kod           NUMBER (3) := 71;
      v_dm_uye              NUMBER (10);
      v_dm_outlet           VARCHAR2 (3);
      v_dm_phone_country    mb_abone_telefon.ulke_kodu%TYPE
                               := in_phone_country;
      v_dm_phone_area       mb_abone_telefon.alan_kodu%TYPE := in_phone_area;
      v_dm_phone_number     mb_abone_telefon.telefon_no%TYPE
                               := in_phone_number;
      v_dm_phone_type       mb_abone_telefon.telefon_tipi%TYPE;
      v_dm_phone_id         mb_abone_telefon.id%TYPE;
      v_sifre_exists        NUMBER (1);
      v_sifre_uret_count    NUMBER (1) := 0;
      v_islem_sonuc_kod     VARCHAR2 (20);
   BEGIN
      in_email := REPLACE (in_email, '''', '');
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_islem_kod,
                                  TO_CHAR (v_islem_kod),
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_no,
                                  v_account_number,
                                  FALSE);
      ias_islem_parametre_doldur (
         v_parametre,
         ias_sabit_pack.key_register_telno,
         in_phone_country || '-' || in_phone_area || '-' || in_phone_number,
         TRUE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_ad,
                                  v_ad,
                                  TRUE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_soyad,
                                  v_soyad,
                                  TRUE);
      /*
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_annesoyad,
                                  v_anne_kizlik_soyad,
                                  TRUE
                                 );
      */
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_email,
                                  in_email,
                                  TRUE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_dogumtarih,
                                  in_dogum_tarihi,
                                  TRUE);
      ias_islem_kontrol_pack.islem_oncesi_kontrol (NULL  /*in_account_number*/
                                                       ,
                                                   NULL     /*in_outlet_code*/
                                                       ,
                                                   NULL   /*in_serial_number*/
                                                       ,
                                                   v_kaynak      /*in_kaynak*/
                                                           ,
                                                   v_islem_kod /*in_islem_id*/
                                                              ,
                                                   o_islem_sonuc_tip /*out_sonuc_tip*/
                                                                    ,
                                                   o_islem_sonuc_kod /*out_sonuc_kod*/
                                                                    );

      IF     o_islem_sonuc_tip = 0
         AND v_dm_phone_country IS NOT NULL
         AND v_dm_phone_area IS NOT NULL
         AND v_dm_phone_number IS NOT NULL
      THEN
         ias_kayit_pack.abone_telefon_bul (v_dm_uye,
                                           v_dm_outlet,
                                           v_dm_phone_type,
                                           v_dm_phone_country,
                                           v_dm_phone_area,
                                           v_dm_phone_number,
                                           v_kaynak,
                                           in_session_id,
                                           v_islem_tipi,
                                           v_dm_phone_id);

         IF (   v_islem_tipi = 1
             OR (    v_account_number IS NOT NULL
                 AND v_dm_uye <> v_account_number))
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR977';
         ELSIF v_account_number IS NULL
         THEN
            v_account_number := v_dm_uye;
         END IF;
      END IF;

      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_no,
                                  v_account_number,
                                  FALSE);
      in_account_number := v_account_number;

      IF o_islem_sonuc_tip = 0
      THEN
         v_stb_tipi := vestel_pack.abone_stb_tipi_bul (in_account_number);

         IF v_stb_tipi IS NULL OR v_stb_tipi = '-1'
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR980';
         ELSE
            BEGIN
               SELECT customer_type
                 INTO v_musteri_tipi
                 FROM wiz_customer_hp_life
                WHERE account_number = v_account_number;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  o_islem_sonuc_tip := 1;
                  o_islem_sonuc_kod := 'ERR980';
            END;
         END IF;

         tran_pack.dbs_savepoint ('ILK_DURUM');

         IF o_islem_sonuc_tip = 0
         THEN
            v_ad := upper_string (LTRIM (RTRIM (v_ad)));
            v_soyad := upper_string (LTRIM (RTRIM (v_soyad)));
            v_anne_kizlik_soyad :=
               upper_string (LTRIM (RTRIM (v_anne_kizlik_soyad)));
            in_email := upper_email (LTRIM (RTRIM (in_email)));
            o_sifre := NULL;
            -- validation (account number, ad, soyad)
            v_sayi := 1;

            BEGIN
               SELECT LTRIM (RTRIM (first_name)), LTRIM (RTRIM (last_name))
                 INTO p_ad, p_soyad
                 FROM wiz_customer_descrip
                WHERE account_number = v_account_number;

               IF    (p_ad IS NULL AND p_soyad IS NULL)
                  OR (p_ad IS NULL AND p_soyad = v_soyad)
                  OR (p_soyad IS NULL AND p_ad = v_ad)
               THEN
                  v_sayi := 2;
               ELSIF (                                     /*p_ad = v_ad AND*/
                      p_soyad = v_soyad)
               THEN
                  v_sayi := 0;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_sayi := 3;                        -- error (üye kaydi yok)
            END;

            IF v_sayi = 0
            THEN
               BEGIN
                  v_sayi := 1;

                  SELECT dogum_tarihi
                    INTO p_dogum_tarihi
                    FROM mb_abone_detay_bilgi
                   WHERE account_number = v_account_number;

                  IF p_dogum_tarihi = in_dogum_tarihi
                  THEN
                     v_sayi := 0;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_sayi := 3;                     -- error (üye kaydi yok)
               END;

               /*-- validation (account number, anne kizlik soyadi, dogum tarihi)--*/
               v_sayi := 1;

               BEGIN
                  --SELECT LTRIM(RTRIM(ANNE_KIZLIK_SOYADI)),  dogum_tarihi INTO p_anne_kizlik_soyad, p_dogum_tarihi
                  SELECT    SUBSTR (LTRIM (RTRIM (anne_kizlik_soyadi)), 1, 1)
                         || SUBSTR (
                               LTRIM (RTRIM (anne_kizlik_soyadi)),
                               LENGTH (LTRIM (RTRIM (anne_kizlik_soyadi))),
                               1),
                         dogum_tarihi
                    INTO p_anne_kizlik_soyad, p_dogum_tarihi
                    FROM mb_abone_detay_bilgi
                   WHERE account_number = v_account_number;

                  IF    (    p_anne_kizlik_soyad IS NULL
                         AND p_dogum_tarihi IS NULL)
                     OR (    p_anne_kizlik_soyad IS NULL
                         AND p_dogum_tarihi = in_dogum_tarihi)
                     OR (    p_dogum_tarihi IS NULL
                         AND p_anne_kizlik_soyad = v_anne_kizlik_soyad)
                  THEN
                     v_sayi := 2;
                  ELSIF (    p_anne_kizlik_soyad = v_anne_kizlik_soyad
                         AND p_dogum_tarihi = in_dogum_tarihi)
                  THEN
                     v_sayi := 0;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_sayi := 3;                     -- error (üye kaydi yok)
               END;

               IF v_sayi = 0
               THEN
                  v_kayit_dogru := TRUE;
               END IF;
            END IF;

            IF v_kayit_dogru
            THEN
               IF (v_stb_tipi NOT IN ('PH',
                                      'LG',
                                      'VS',
                                      'ZS'))
               THEN
                  o_islem_sonuc_tip := 1;
                  o_islem_sonuc_kod := 'ERR13';
               ELSE
                  v_musteri_tipi_grup := musteri_tip_grup_bul (v_musteri_tipi);

                  /* 1: Bireysel , 2 : Ticari, 3: Otel, 4:? */
                  IF (v_musteri_tipi_grup <> 1 AND v_musteri_tipi_grup <> 2)
                  THEN
                     o_islem_sonuc_tip := 1;
                     o_islem_sonuc_kod := 'ERR14';
                  ELSIF (v_musteri_tipi_grup = 2)
                  THEN
                     o_islem_sonuc_tip := 1;
                     o_islem_sonuc_kod := 'ERR343';
                  ELSE
                     v_kilitli_sifre := abone_sifre_kilitli (v_account_number);

                     IF (v_kilitli_sifre)
                     THEN
                        o_islem_sonuc_tip := 1;
                        o_islem_sonuc_kod := 'ERR8';
                     END IF;
                  END IF;
               END IF;

               IF o_islem_sonuc_tip = 0
               THEN
                  ias_islem_kontrol_pack.islem_oncesi_kontrol (
                     v_account_number                    /*in_account_number*/
                                     ,
                     NULL                                   /*in_outlet_code*/
                         ,
                     NULL                                 /*in_serial_number*/
                         ,
                     v_kaynak                                    /*in_kaynak*/
                             ,
                     v_islem_kod                               /*in_islem_id*/
                                ,
                     o_islem_sonuc_tip                       /*out_sonuc_tip*/
                                      ,
                     v_islem_sonuc_kod                       /*out_sonuc_kod*/
                                      );

                  IF o_islem_sonuc_tip = 1
                  THEN
                     o_islem_sonuc_kod := v_islem_sonuc_kod;
                  ELSE
                     -- gizli sifrenin yaratilmasi
                     --o_sifre := substr(RANDOM_SIFRE_URET(v_Account_Number),1,50);
                     o_sifre := ias_random_pack.rand_string (50);

                     LOOP
                        SELECT COUNT (1)
                          INTO v_sifre_exists
                          FROM ias_gizli_abone_sifre
                         WHERE gizli_sifre = o_sifre;

                        v_sifre_uret_count := v_sifre_uret_count + 1;
                        EXIT WHEN    v_sifre_exists = 0
                                  OR v_sifre_uret_count = 3;
                     END LOOP;

                     abone_gizli_sifre_insert (v_kaynak,
                                               v_account_number,
                                               in_email,
                                               o_sifre,
                                               NULL,
                                               NULL);
                     o_islem_sonuc_tip := 0;
                     o_islem_sonuc_kod := 'VLD52';
                     ias_log_session_pack.session_update (in_session_id,
                                                          v_kaynak,
                                                          v_account_number,
                                                          NULL,
                                                          NULL,
                                                          NULL,
                                                          NULL);
                  END IF;
               END IF;
            ELSIF (v_sayi = 1)
            THEN
               -- giris invalidse hatali sifre girisi olarak sayilmasi gerekiyor
               BEGIN
                  abone_sifre_hatali_giris (v_account_number,
                                            v_kaynak,
                                            o_islem_sonuc_tip,
                                            o_islem_sonuc_kod);

                  -- ERR8, ERR10, ERR979
                  IF (o_islem_sonuc_kod = 'ERR979')
                  THEN
                     o_islem_sonuc_kod := 'ERR981';
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     o_islem_sonuc_tip := 1;
                     o_islem_sonuc_kod := 'ERR55';
               -- sifre kaydi olmadigi için hatali giris artisi saglanilamadi
               END;
            ELSIF (v_sayi = 2 OR v_sayi = 3)
            THEN
               -- giris invalidse ve içerideki datalar eksikse
               o_islem_sonuc_tip := 1;
               o_islem_sonuc_kod := 'ERR56';
            -- sifre kaydi olmadigi için hatali giris artisi saglanilamadi
            END IF;
         END IF;
      END IF;

      -- logging result
      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     v_account_number,
                                     NULL,
                                     NULL,
                                     ias_sabit_pack.kaynak_sifre,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     NULL,
                                     'ABONE_SIFRESIZ_KONTROL',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         -- islem logu atilamazsa islem geri alinir...
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR53';
         END IF;
      END IF;

      o_islem_sonuc_mesaj :=
         ias_islem_mesaj_bul (o_islem_sonuc_kod,
                              in_kaynak,
                              v_parametre,
                              o_islem_sonuc_mesaj);
   EXCEPTION
      WHEN OTHERS
      THEN
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR54';
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);

         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           v_account_number,
                                           NULL,
                                           NULL,
                                           ias_sabit_pack.kaynak_sifre,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_SIFRESIZ_KONTROL',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;                                              -- ABONE_SIFRESIZ_KONTROL

   /***********************************************************************************/
   PROCEDURE abone_gizli_sifre_bul (
      in_gizli_sifre        IN     ias_gizli_abone_sifre.gizli_sifre%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      in_session_id         IN     NUMBER,
      o_islem_log_id           OUT NUMBER,
      o_sifre                  OUT mb_abone_sifre.sifre_1%TYPE,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Process Code : 73
      Logging (valid, invalid)*/
      /* Result Codes:
      ERR8:   Sifre kilitli
      ERR196: Sifre bulunamadi
      ERR197: Log atilamadi
      ERR198: Exception
      VLD199: Ok*/
      /* Tanim: Aboneye iliskin yaratilan gizli sifreye iliskin sifre degeri return edilir.
      Kullaniciya gönderilen maildeki linke tiklayinca karsisinda görünecek.
      Ilk alinan sifre için hatali giris sayisinin sifirlanmasi gerekiyor */
      CURSOR cur_sifre
      IS
         SELECT *
           FROM ias_gizli_abone_sifre
          WHERE gizli_sifre = in_gizli_sifre
         FOR UPDATE;

      rec_sifre         cur_sifre%ROWTYPE;
      v_kaynak          mb_abone_sifre.kaynak%TYPE
                           := upper_string (LTRIM (RTRIM (in_kaynak)));
      v_kilitli_sifre   BOOLEAN;
      v_islem_tipi      NUMBER (1);
      v_hata            VARCHAR2 (255);
      v_kullanici       VARCHAR2 (20);
      v_parametre       VARCHAR2 (1000);
      v_islem_kod       NUMBER (3) := 73;
      v_sifre           mb_abone_sifre.sifre_1%TYPE;
      v_sonuc           NUMBER (10);
   BEGIN
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_islem_kod,
                                  TO_CHAR (v_islem_kod),
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_gizlisifre,
                                  in_gizli_sifre,
                                  TRUE);
      tran_pack.dbs_savepoint ('ILK_DURUM');
      ias_islem_kontrol_pack.islem_oncesi_kontrol (NULL  /*in_account_number*/
                                                       ,
                                                   NULL     /*in_outlet_code*/
                                                       ,
                                                   NULL   /*in_serial_number*/
                                                       ,
                                                   v_kaynak      /*in_kaynak*/
                                                           ,
                                                   v_islem_kod /*in_islem_id*/
                                                              ,
                                                   o_islem_sonuc_tip /*out_sonuc_tip*/
                                                                    ,
                                                   o_islem_sonuc_kod /*out_sonuc_kod*/
                                                                    );

      IF o_islem_sonuc_tip = 0
      THEN
         -- gizli sifreden üye bilgisinin bulunmasi
         OPEN cur_sifre;

         FETCH cur_sifre INTO rec_sifre;

         v_kilitli_sifre := abone_sifre_kilitli (rec_sifre.account_number);

         IF (v_kilitli_sifre)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR8';
         ELSE
            IF (cur_sifre%FOUND AND rec_sifre.listeden_gizle = 'H')
            THEN
               -- gizli sifre kaydinin yaratilmasi üzerinden bir gün geçmisse,
               -- gizli sifre kaydi disable olur...
               v_kullanici := kaynak_kullanici_bul (v_kaynak);

               IF (SYSDATE > rec_sifre.giris_tarihi + 1)
               THEN
                  UPDATE ias_gizli_abone_sifre
                     SET listeden_gizle = 'E',
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = v_kullanici
                   WHERE CURRENT OF cur_sifre;
               END IF;

               -- daha önce basarili bir girs yapilmamissa veya gizlenme zamani daha gelmemisse;
               IF (   rec_sifre.listeden_gizlenme_tarihi IS NULL
                   OR SYSDATE < rec_sifre.listeden_gizlenme_tarihi)
               THEN
                  -- üye numarasindan sifrenin bulunmasi
                  o_sifre :=
                     abone_sifre_bul (rec_sifre.account_number, v_kaynak);
               END IF;

               -- basarili girislerde;
               IF (o_sifre IS NOT NULL)
               THEN
                  -- sayili kismi biraz olsun atlatmak için aradan string select edilmistir.
                  --o_sifre := substr(RANDOM_SIFRE_URET(REC_SIFRE.ACCOUNT_NUMBER),14,6); --14,6 olayi:12/12/2003, Emine
                  o_sifre := ias_random_pack.rand_string (6);

                  /********ESKİ*******************************

                  v_sifre := digipaket_sifre.encrypt (o_sifre);

                  -- random sifre set etme islemi, hatali giris sayilari sifirlanmalidir.
                  UPDATE mb_abone_sifre
                     SET sifre_1 = v_sifre,
                         sifre_2 = v_sifre,
                         sifre_degistir = 'E',
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = v_kullanici
                   --,HATALI_GIRIS_SAYISI = 0
                   WHERE     account_number = rec_sifre.account_number
                         AND kaynak = ias_sabit_pack.kaynak_sifre;

                   *********ESKİ******************************/

                  /********YENİ*******************************/
                  dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update (
                     v_account_number   => rec_sifre.account_number,
                     v_sifre_1          => o_sifre,
                     v_sifre_2          => o_sifre,
                     v_deneme           => 0,
                     v_kullanici        => v_kullanici,
                     v_kaynak           => ias_sabit_pack.kaynak_sifre,
                     v_sonuc            => v_sonuc);

                  IF (v_sonuc = 0)
                  THEN
                     raise_application_error (
                        -20101,
                        'dbs_dba.abone_sifre_pack.mb_abone_sifre_insert_update -- EXCEPTION');
                  END IF;

                  UPDATE mb_abone_sifre
                     SET sifre_degistir = 'E'
                   WHERE     account_number = rec_sifre.account_number
                         AND kaynak = ias_sabit_pack.kaynak_sifre;

                  /********YENİ*******************************/

                  -- email bilgisinin güncellenmesi (Problem varsa da no problem)
                  ias_uyelik_pack.update_email_bilgi (
                     v_kaynak,
                     rec_sifre.account_number,
                     rec_sifre.e_mail,
                     o_islem_sonuc_tip,
                     o_islem_sonuc_kod);

                  -- ikinci girisse gizli sifre disable ediliyor
                  IF (rec_sifre.listeden_gizlenme_tarihi IS NOT NULL)
                  THEN
                     UPDATE ias_gizli_abone_sifre
                        SET listeden_gizle = 'E',
                            degistirme_tarihi = SYSDATE,
                            degistiren_kullanici = v_kullanici
                      WHERE CURRENT OF cur_sifre;
                  -- ilk girisse bir saat sonra gizlenecek sekilde set ediliyor
                  ELSE
                     UPDATE ias_gizli_abone_sifre
                        SET listeden_gizle = 'H',
                            listeden_gizlenme_tarihi = (SYSDATE + 1 / 24),
                            degistirme_tarihi = SYSDATE,
                            degistiren_kullanici = v_kullanici
                      WHERE CURRENT OF cur_sifre;
                  END IF;
               END IF;                                       -- basarili giris
            END IF;                                    -- gizlenmemis sifreyse

            IF o_sifre IS NULL
            THEN
               o_islem_sonuc_tip := 1;
               o_islem_sonuc_kod := 'ERR196';
            ELSE
               o_islem_sonuc_tip := 0;
               o_islem_sonuc_kod := 'VLD199';
               ias_islem_parametre_doldur (v_parametre,
                                           ias_sabit_pack.key_uye_no,
                                           rec_sifre.account_number,
                                           FALSE);
               ias_log_session_pack.session_update (in_session_id,
                                                    v_kaynak,
                                                    rec_sifre.account_number,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL);
            END IF;
         END IF;

         CLOSE cur_sifre;
      END IF;

      -- logging result
      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     rec_sifre.account_number,
                                     NULL,
                                     NULL,
                                     ias_sabit_pack.kaynak_sifre,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     NULL,
                                     'ABONE_GIZLI_SIFRE_BUL',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         -- islem logu atilamazsa islem geri alinir...
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR197';
         END IF;
      END IF;

      o_islem_sonuc_mesaj :=
         ias_islem_mesaj_bul (o_islem_sonuc_kod,
                              in_kaynak,
                              v_parametre,
                              o_islem_sonuc_mesaj);
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cur_sifre;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR198';
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);

         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           rec_sifre.account_number,
                                           NULL,
                                           NULL,
                                           ias_sabit_pack.kaynak_sifre,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_GIZLI_SIFRE_BUL',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;                                               -- ABONE_GIZLI_SIFRE_BUL

   /************************************************************************/
   PROCEDURE abone_uygulama_giris (
      in_account_number     IN     mb_abone_sifre.account_number%TYPE,
      in_kaynak             IN     mb_abone_sifre.kaynak%TYPE,
      in_net_session_id     IN     ias_log_session.session_id%TYPE,
      in_web_session_id     IN     ias_log_session.session_id%TYPE,
      in_session_id         IN     NUMBER,
      o_islem_log_id           OUT NUMBER,
      o_islem_sonuc_tip        OUT NUMBER,
      o_islem_sonuc_kod        OUT VARCHAR2,
      o_islem_sonuc_mesaj      OUT VARCHAR2)
   IS
      /* Process Code : 86
      Logging (valid, invalid)*/
      /* Result Codes:
      ERR8:  Sifre kilitli
      ERR11: Session aktif session degil
      ERR19: Session kaydedilemedi
      ERR238: Log atilamadi
      ERR239: Exception
      ERR246: sessiona giris engellenmis (time-out)
      VLD240: Islem ok*/
      /* Tanim: Abone digiturk tv sayfasina login olduktan sonra tekrar sifre girisi yapmadan
      DigiWeb uygulamasina login olabilmektedir. */
      v_account_number   mb_abone_sifre.account_number%TYPE
                            := account_number_bul (in_account_number);
      v_kaynak           mb_abone_sifre.kaynak%TYPE
                            := upper_string (LTRIM (RTRIM (in_kaynak)));
      v_giris_tarihi     DATE;
      v_islem_tipi       NUMBER (1);
      v_parametre        VARCHAR2 (1000);
      v_islem_kod        NUMBER (3) := 86;
   BEGIN
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_islem_kod,
                                  TO_CHAR (v_islem_kod),
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_uye_no,
                                  v_account_number,
                                  FALSE);
      ias_islem_parametre_doldur (v_parametre,
                                  ias_sabit_pack.key_digiturktv_session,
                                  in_net_session_id,
                                  TRUE);
      -- sifre case sensitive olacak!!!
      tran_pack.dbs_savepoint ('ILK_DURUM');
      ias_islem_kontrol_pack.islem_oncesi_kontrol (v_account_number /*in_account_number*/
                                                                   ,
                                                   NULL     /*in_outlet_code*/
                                                       ,
                                                   NULL   /*in_serial_number*/
                                                       ,
                                                   v_kaynak      /*in_kaynak*/
                                                           ,
                                                   v_islem_kod /*in_islem_id*/
                                                              ,
                                                   o_islem_sonuc_tip /*out_sonuc_tip*/
                                                                    ,
                                                   o_islem_sonuc_kod /*out_sonuc_kod*/
                                                                    ,
                                                   'E'  /*in_session_kontrol*/
                                                      ,
                                                   in_net_session_id /*in_session_id*/
                                                                    );

      IF o_islem_sonuc_tip = 0
      THEN
         SELECT islem_tarihi
           INTO v_giris_tarihi
           FROM ias_log_session
          WHERE account_number = v_account_number AND kaynak = v_kaynak;

         -- time-out kontrolü (digiturk.tv)
         IF SYSDATE - v_giris_tarihi < ias_sabit_pack.digiturktv_timeout_sure
         THEN
            ias_log_pack.log_session_insert (v_account_number,
                                             ias_sabit_pack.kaynak_sifre,
                                             in_web_session_id,
                                             FALSE,
                                             o_islem_sonuc_tip);

            IF (o_islem_sonuc_tip = 1)
            THEN
               o_islem_sonuc_kod := 'ERR19';
            -- session loguna insert edilemedi
            ELSE
               o_islem_sonuc_kod := 'VLD240';
               ias_log_session_pack.session_update (in_session_id,
                                                    v_kaynak,
                                                    v_account_number,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL);
            END IF;
         ELSE
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR246';
         END IF;
      END IF;                                               -- session validse

      -- logging result
      ias_log_pack.log_islem_insert (v_islem_kod,
                                     v_kaynak,
                                     v_account_number,
                                     NULL,
                                     NULL,
                                     NULL,
                                     o_islem_sonuc_tip,
                                     o_islem_sonuc_kod,
                                     NULL,
                                     'ABONE_UYGULAMA_GIRIS',
                                     v_parametre,
                                     in_session_id,
                                     v_islem_tipi,
                                     o_islem_log_id);

      IF (v_islem_tipi = 1)
      THEN
         -- islem logu atilamazsa islem geri alinir...
         tran_pack.dbs_rollback ('ILK_DURUM');

         IF (o_islem_sonuc_tip = 0)
         THEN
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR238';
         END IF;
      END IF;

      o_islem_sonuc_mesaj :=
         ias_islem_mesaj_bul (o_islem_sonuc_kod,
                              in_kaynak,
                              v_parametre,
                              o_islem_sonuc_mesaj);
   EXCEPTION
      WHEN OTHERS
      THEN
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR239';
         o_islem_sonuc_mesaj :=
            ias_islem_mesaj_bul (o_islem_sonuc_kod,
                                 in_kaynak,
                                 v_parametre,
                                 o_islem_sonuc_mesaj);

         BEGIN
            ias_log_pack.log_islem_insert (v_islem_kod,
                                           v_kaynak,
                                           v_account_number,
                                           NULL,
                                           NULL,
                                           NULL,
                                           o_islem_sonuc_tip,
                                           o_islem_sonuc_kod,
                                           SUBSTR (SQLERRM, 1, 255),
                                           'ABONE_UYGULAMA_GIRIS',
                                           v_parametre,
                                           in_session_id,
                                           v_islem_tipi,
                                           o_islem_log_id);
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END;
-- ABONE_UYGULAMA_GIRIS
/************************************************************************/
END;
/
