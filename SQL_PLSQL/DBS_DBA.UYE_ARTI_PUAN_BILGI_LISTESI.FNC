CREATE OR REPLACE FUNCTION DBS_DBA.uye_arti_puan_bilgi_listesi (
   in_account_number      IN   NUMBER,
   in_campaign_code       IN   VARCHAR2,
   in_service_code        IN   VARCHAR2,
   in_billing_frequency   IN   VARCHAR2
)
   RETURN VARCHAR2
IS
   v_franchise_code                 VARCHAR2 (3);
   v_mdu_subd_code                  VARCHAR2 (3);
   v_customer_type                  VARCHAR2 (3);
   v_hp_cluster                     VARCHAR (2);
   v_uyelik_suresi                  NUMBER (10);
-------------------------------------------------
   v_promotion_ending_date          DATE;
   v_promotion_ending_length        NUMBER (10);
   v_promotion_ending_length_mont   NUMBER (10);
   v_tekrarlanma_sayisi             NUMBER (3);
-------------------------------------------------
   v_kampanya_yururluk_suresi       NUMBER (10);
   v_paket                          VARCHAR2 (10);
   v_liste_fiyati                   NUMBER (13, 2);
   v_kampanya_fiyati                NUMBER (13, 2);
   v_aylik_indirim                  NUMBER (13, 2);
   v_yillik_indirim                 NUMBER (13, 2);
   v_dusulecek_arti_puan            NUMBER (10);
   v_mevcut_arti_puan               NUMBER (10);
   v_kazanilacak_arti_puan          NUMBER (10);
   v_bir_yil_sonraki_arti_puan      NUMBER (10);
-------------------------------------------------
   v_promotion_code                 VARCHAR2 (10);
   v_count                          NUMBER (10);
   v_status                         VARCHAR2 (255);
   ret_val                          VARCHAR2 (4000);
-------------------------------------------------
   v_islem_tipi                     VARCHAR2 (50)   := 'FATURA';
   v_start_date                     DATE            := SYSDATE;
   v_islem_tipi_id                  NUMBER (6);
   v_islem_puan_id                  NUMBER (6);
   v_baslangic_adet                 NUMBER (6);
   v_bitis_adet                     NUMBER (6);
   v_islem_puan                     NUMBER (15);
   v_islem_oran                     NUMBER (10, 6);
   v_islem_tipi_ex                  VARCHAR2 (50)   := 'FATURA_EXTRA';
   v_islem_tipi_id_ex               NUMBER (6);
   v_islem_puan_id_ex               NUMBER (6);
   v_islem_puan_ex                  NUMBER (15);
   v_islem_oran_ex                  NUMBER (10, 6);
BEGIN
   IF TRIM (in_account_number) IS NULL
   THEN
      RETURN NULL;
   ELSIF TRIM (in_campaign_code) IS NULL
   THEN
      RETURN NULL;
   ELSIF TRIM (in_service_code) IS NULL
   THEN
      RETURN NULL;
   ELSIF TRIM (in_billing_frequency) IS NULL
   THEN
      RETURN NULL;
   END IF;

   SELECT franchise_code, mdu_subd_code, customer_type, hp_cluster
     INTO v_franchise_code, v_mdu_subd_code, v_customer_type, v_hp_cluster
     FROM prod_dba.wiz_customer_hp_life
    WHERE account_number = in_account_number;

   --+ PUAN SADECE BELIRLI BRAND LER ICIN GECERLIDIR
   SELECT COUNT (1)
     INTO v_count
     FROM DUAL
    WHERE dbs_dba.dbs_sabit ('ARTI_PUAN_BRAND_LISTESI') LIKE
                                                    '%' || v_hp_cluster || '%';

   IF v_count = 0
   THEN
      RETURN NULL;
   END IF;

   /*----------PAKET HESAPLAMALARI----------*/
   v_paket := in_service_code;
   
   /*----------LISTE_FIYATI HESAPLAMALARI----------*/
   dbs_dba.work_order_pack.rate_found (v_franchise_code,
                                       v_mdu_subd_code,
                                       v_customer_type,
                                       in_billing_frequency,
                                       in_service_code,
                                       SYSDATE,
                                       v_liste_fiyati,
                                       v_status,
                                       v_hp_cluster,
                                       'H'
                                      );

   IF v_status <> '0'
   THEN
      RETURN NULL;
   END IF;

   /*----------KAMPANYA_FIYATI HESAPLAMALARI----------*/
   BEGIN
      SELECT DISTINCT (promotion_code)
                 INTO v_promotion_code
                 FROM dbs_dba.icr_dp_servis_default
                WHERE campaign_code = in_campaign_code
                  AND sms_code = in_service_code
                  AND billing_frequency = in_billing_frequency;
   EXCEPTION
      WHEN OTHERS
      THEN
         --PROMOSU OLMAYAN KAMPANYA ICIN DEGER DONMEMELI
         RETURN NULL;
   END;

   --PROMOSU OLMAYAN KAMPANYA ICIN DEGER DONMEMELI
   IF TRIM (v_promotion_code) IS NULL
   THEN
      RETURN NULL;
   END IF;

   dbs_dba.work_order_pack.rate_found (v_franchise_code,
                                       v_mdu_subd_code,
                                       v_customer_type,
                                       in_billing_frequency,
                                       v_promotion_code,
                                       SYSDATE,
                                       v_kampanya_fiyati,
                                       v_status,
                                       v_hp_cluster,
                                       'H'
                                      );

   IF v_status <> '0'
   THEN
      RETURN SQLERRM;
   END IF;

   --v_kampanya_yururluk_suresi HESAPLAMASI (KAZANILACAK PUAN HESABI ICIN)
   /*
    wiz_promo_descr deki promotion_ending_date e gore islem yapiliyor

    tarih       -0  -0  -0  --Sabit tarihli     847 03.12.2050
    null        -0  -12 -0  --Kayan 12 ay       844 kayan 3 ay
    01.01.9999  -0  -12 -0  --fatura tar. kayan 841 6 ay
    01.01.0001  - 1 -0  -4  --Multi frekans     840 multi 1

    icr_dp_servis_default dan v_frekans geliyor (in_billing_frequency)

    v_carpan 01.01.0001 ise 1
             null veya  01.01.9999 ise 12
             tarih-sysdate/12 küsürati at kalan deger

    AMAC:
    v_carpan*v_frekans (in_billing_frequency)
   */
   SELECT promotion_ending_date, promotion_ending_length,
          promotion_ending_length_months, tekrarlanma_sayisi
     INTO v_promotion_ending_date, v_promotion_ending_length,
          v_promotion_ending_length_mont, v_tekrarlanma_sayisi
     FROM prod_dba.wiz_promo_descr
    WHERE promotion_code = v_promotion_code;

   --KAYAN PROMOSYON ICIN
   IF TRIM (v_promotion_ending_date) IS NULL
   THEN
      SELECT billing_freq_number * v_promotion_ending_length_mont
         INTO v_kampanya_yururluk_suresi
        FROM wiz_billing_frequency_codes
      WHERE billing_frequency = in_billing_frequency;
      
--      v_kampanya_yururluk_suresi :=
--           TO_NUMBER (CASE in_billing_frequency
--                         WHEN 'A'
--                            THEN '12'
--                         ELSE in_billing_frequency
--                      END
--                     )
--         * v_promotion_ending_length_mont;
         
   --FATURA TARIHINDEN KAYAN PROMOSYON ICIN
   ELSIF TO_CHAR (TO_DATE (v_promotion_ending_date, 'DD.MM.YYYY'), 'YYYY') =
                                                                        '9999'
   THEN

      SELECT billing_freq_number * v_promotion_ending_length_mont
         INTO v_kampanya_yururluk_suresi
        FROM wiz_billing_frequency_codes
      WHERE billing_frequency = in_billing_frequency;
      
--      v_kampanya_yururluk_suresi :=
--           TO_NUMBER (CASE in_billing_frequency
--                         WHEN 'A'
--                            THEN '12'
--                         ELSE in_billing_frequency
--                      END
--                     )
--         * v_promotion_ending_length_mont;

   --MULTI FREKANS PROMOSYON ICIN
   ELSIF TO_CHAR (TO_DATE (v_promotion_ending_date, 'DD.MM.YYYY'), 'YYYY') =
                                                                        '0001'
   THEN

      SELECT billing_freq_number * v_promotion_ending_length
         INTO v_kampanya_yururluk_suresi
        FROM wiz_billing_frequency_codes
      WHERE billing_frequency = in_billing_frequency;
      
--      v_kampanya_yururluk_suresi :=
--           TO_NUMBER (CASE in_billing_frequency
--                         WHEN 'A'
--                            THEN '12'
--                         ELSE in_billing_frequency
--                      END
--                     )
--         * v_promotion_ending_length;
         
   --SABIT TARIHLI PROMOSYON ICIN
   ELSE

      SELECT billing_freq_number * TRUNC ((v_promotion_ending_date - TRUNC (SYSDATE)) / 12)
         INTO v_kampanya_yururluk_suresi
        FROM wiz_billing_frequency_codes
      WHERE billing_frequency = in_billing_frequency;
      
--      v_kampanya_yururluk_suresi :=
--           TO_NUMBER (CASE in_billing_frequency
--                         WHEN 'A'
--                            THEN '12'
--                         ELSE in_billing_frequency
--                      END
--                     )
--         * TRUNC ((v_promotion_ending_date - TRUNC (SYSDATE)) / 12);
         
   END IF;

   /*----------AYLIK_INDIRIM HESAPLAMALARI----------*/
   v_aylik_indirim := v_liste_fiyati - v_kampanya_fiyati;
   
   /*----------YILLIK_INDIRIM HESAPLAMALARI----------*/
   v_yillik_indirim := v_aylik_indirim * v_kampanya_yururluk_suresi;

   /*----------MEVCUT_ARTI_PUAN HESAPLAMALARI----------*/
   BEGIN
      SELECT NVL (puan, 0)
        INTO v_mevcut_arti_puan
        FROM dbs_dba.ps_uye_puan
       WHERE account_number = in_account_number;

      --UYENIN - PUANI VARSA DEGER DONMEMELI
      IF v_mevcut_arti_puan < 0
      THEN
         RETURN NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_mevcut_arti_puan := 0;
   END;

   /*----------KAZANILACAK_ARTI_PUAN HESAPLAMALARI----------*/
   --uyelik suresi hesaplanir
   v_uyelik_suresi := dbs_dba.uye_aktif_sure (in_account_number);
   
   --yillara gore puan carpanlari hesaplanir
   dbs_dba.ps_pack.ps_islem_puan_bul (v_islem_tipi,
                                      v_start_date,
                                      v_islem_tipi_id,
                                      v_islem_puan_id,
                                      v_baslangic_adet,
                                      v_bitis_adet,
                                      v_islem_puan,
                                      v_islem_oran,
                                      v_status
                                     );

   IF v_status <> '0'
   THEN
      RETURN NULL;
   END IF;

   dbs_dba.ps_pack.ps_islem_puan_bul (v_islem_tipi_ex,
                                      v_start_date,
                                      v_islem_tipi_id_ex,
                                      v_islem_puan_id_ex,
                                      v_baslangic_adet,
                                      v_bitis_adet,
                                      v_islem_puan_ex,
                                      v_islem_oran_ex,
                                      v_status,
                                      v_uyelik_suresi
                                     );

   IF v_status <> '0'
   THEN
      RETURN NULL;
   END IF;

   v_kazanilacak_arti_puan :=
        (v_kampanya_fiyati * (v_islem_oran + v_islem_oran_ex)
        )
      * v_kampanya_yururluk_suresi;
      
   --DUSULECEK_ARTI_PUAN HESAPLAMALARI
   v_dusulecek_arti_puan :=
             (v_mevcut_arti_puan + v_kazanilacak_arti_puan) / v_yillik_indirim;

   FOR rec IN
      (SELECT SUBSTR (TRIM (aciklama),
                      1,
                      INSTR (TRIM (aciklama), '-', 1) - 1
                     ) AS alt,
              SUBSTR (TRIM (aciklama),
                      INSTR (TRIM (aciklama), '-', 1) + 1,
                        INSTR (TRIM (aciklama), '-', 1, 2)
                      - INSTR (TRIM (aciklama), '-', 1, 1)
                      - 1
                     ) AS ust,
              SUBSTR (TRIM (aciklama),
                      INSTR (TRIM (aciklama), '-', 1, 2) + 1
                     ) AS carpan
         FROM dbs_dba.pr_genel_tip_detay
        WHERE islem_kodu = 172)              /*172:+ PUAN CARPAN KATSAYILARI*/
   LOOP
      IF v_dusulecek_arti_puan BETWEEN rec.alt AND rec.ust
      THEN
         v_dusulecek_arti_puan := v_yillik_indirim * rec.carpan;
      END IF;
   END LOOP;

   /*----------BIR_YIL_SONRAKI_ARTI_PUAN HESAPLAMALARI----------*/
   v_bir_yil_sonraki_arti_puan :=
        (v_mevcut_arti_puan + v_kazanilacak_arti_puan
        )
      - NVL (v_dusulecek_arti_puan, 0);

   /*----------DONUS DEGERININ FORMATLANMASI----------*/
   ret_val :=
         RPAD (NVL (v_paket, ' '), 5, ' ')
      || RPAD (NVL (TO_CHAR (v_liste_fiyati), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_kampanya_fiyati), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_aylik_indirim), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_yillik_indirim), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_dusulecek_arti_puan), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_mevcut_arti_puan), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_kazanilacak_arti_puan), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_bir_yil_sonraki_arti_puan), ' '), 20, ' ')
      || RPAD (NVL (TO_CHAR (v_kampanya_yururluk_suresi), ' '), 10, ' ');
   RETURN ret_val;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END uye_arti_puan_bilgi_listesi;
/
