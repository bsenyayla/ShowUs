CREATE OR REPLACE FORCE VIEW DBS_DBA.VV_SF_URUN_LISTESI
(SERI_NO, ID, URUN_GRUP_KOD, URUN_GRUP_ALT_KOD, URUN_MIN_ADET, 
 URUN_MAX_ADET, URUN_ACIKLAMA, FRANCHISE_CODE, STB_TIPI, EXPIRE_DATE, 
 CUSTOMER_TYPE, KAYNAK, URUN_TIPI, URUN_KODU, SERVIS_KAMPANYA_KODU, 
 SERVIS_FREKANSI, OFFER_PRICE_ID, OFFER_PRICE_NAME, UST_GRUP_KOD, UST_GRUP_ACIKLAMA)
AS 
SELECT a.seri_no,
          f.ID,
          f.urun_grup_kod,
          f.urun_grup_alt_kod,
          f.urun_min_adet,
          f.urun_max_adet,
          f.urun_aciklama,
          f.franchise_code,
          f.stb_tipi,
          f.expire_date,
          f.customer_type,
          DECODE (f.kaynak, 'CSR', 'DBS', f.kaynak) AS kaynak,
          f.urun_tipi,
          f.urun_kodu,
          f.servis_kampanya_kodu,
          f.servis_frekansi,
          NULL OFFER_PRICE_ID,
          NULL offer_price_name,
          f.UST_GRUP_KOD,
          f.UST_GRUP_ACIKLAMA
     FROM sf_urun a,
          (SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  c.franchise_code,
                  c.stb_tipi,
                  c.expire_date,
                  d.customer_type,
                  e.kaynak,
                  b.urun_tipi,
                  b.servis_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b,
                  icr_dp_servis_default c,
                  icr_dp_servis_default_detay d,
                  km_icr_servis_detay e
            WHERE     b.urun_tipi = 1
                  AND b.servis_kodu = c.sms_code
                  AND b.servis_frekansi = c.billing_frequency
                  AND b.servis_kampanya_kodu = c.campaign_code
                  AND c.effective_date <= SYSDATE
                  AND c.listeden_gizle = 'H'
                  AND c.kod = d.servis_default_kodu
                  AND c.kod = e.servis_default_kodu
                  AND e.baslangic_tarihi <= SYSDATE
                  AND e.bitis_tarihi > SYSDATE
           UNION ALL
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  c.franchise_code,
                  c.stb_tipi,
                  c.gecerlilik_bitis_tarihi AS expire_date,
                  d.customer_type,
                  e.kaynak,
                  b.urun_tipi,
                  b.ind_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b,
                  pr_indirim_tanim c,
                  pr_indirim_tanim_uye_tipi d,
                  pr_indirim_tanim_kaynak e
            WHERE     b.urun_tipi = 2
                  AND b.ind_kodu = c.indirim_kodu
                  AND c.gecerlilik_baslangic_tarihi <= SYSDATE
                  AND c.listeden_gizle = 'H'
                  AND c.indirim_kodu = d.indirim_kodu
                  AND c.indirim_kodu = e.indirim_kodu
                  AND sabit.is_ittp_indirim_ent_acik = 0
           /*--- Evren-ITTP Entegrasyonu --- 20111017 ---*/
           --           union all
           --           select b.ID,
           --                  b.urun_grup_kod,
           --                  b.urun_grup_alt_kod,
           --                  b.urun_min_adet,
           --                  b.urun_max_adet,
           --                  b.urun_aciklama,
           --                  i.SERVICE_PROVIDER_CD franchise_code,
           --                  i.stb_tipi,
           --                  i.valid_thru as expire_date,
           --                  i.PARTY_ROLE_ACCOUNT_SPEC_CD customer_type,
           --                  'DBS' kaynak,
           --                  b.urun_tipi,
           --                  b.ind_kodu as urun_kodu,
           --                  b.servis_kampanya_kodu,
           --                  b.servis_frekansi
           --             from sf_urun_grup b,
           --                  BILLING_DBS_INT.VW_INDIRIM_TANIM i,
           --                  BILLING_DBS_INT.VW_INDIRIM_ALT_PRICE_GROUP ap
           --            where     b.urun_tipi = 2
           --                  and b.ITTP_OFFER_PRICE_ID = ap.OFFER_PRICE_ID
           --                  and i.valid_from <= SYSDATE
           --                  and ap.offer_price_id = i.parent_id
           --                  and sabit.is_ittp_indirim_ent_acik = 1
           UNION ALL
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  --                  i.SERVICE_PROVIDER_CD franchise_code,
                  --                  i.stb_tipi,
                  --                  i.valid_thru as expire_date,
                  --                  i.PARTY_ROLE_ACCOUNT_SPEC_CD customer_type,
                  NULL franchise_code,
                  NULL stb_tipi,
                  ap.GECERLILIK_BITIS_TARIHI AS expire_date,
                  NULL customer_type,
                  'DBS' kaynak,
                  b.urun_tipi,
                  b.ind_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  AP.OFFER_PRICE_ID,
                  ap.NAME offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b, --                  BILLING_DBS_INT.VW_INDIRIM_TANIM i,
                  BILLING_DBS_INT.VW_INDIRIM_ALT_PRICE_GROUP ap
            WHERE     b.urun_tipi = 2
                  AND b.ITTP_OFFER_PRICE_ID = ap.OFFER_PRICE_ID
                  AND EXISTS
                         (SELECT 1
                            FROM BILLING_DBS_INT.VW_INDIRIM_TANIM i
                           WHERE     ap.offer_price_id = i.parent_id
                                 AND i.valid_from <= SYSDATE)
                  AND sabit.is_ittp_indirim_ent_acik = 1
           UNION ALL
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  c.franchise_code,
                  c.stb_tipi,
                  c.expire_date,
                  d.customer_type,
                  e.kaynak,
                  b.urun_tipi,
                  b.kupon_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b,
                  pr_kupon_tanim c,
                  pr_kupon_tanim_uye_tipi d,
                  pr_kupon_tanim_kaynak e
            WHERE     b.urun_tipi = 3
                  AND b.kupon_kodu = c.coupon_code
                  AND c.effective_date <= SYSDATE
                  AND c.coupon_code = d.coupon_code
                  AND c.coupon_code = e.coupon_code
           UNION ALL
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  c.franchise_code,
                  c.stb_tipi,
                  c.expire_date,
                  c.customer_type,
                  c.kaynak,
                  b.urun_tipi,
                  b.kontor_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b, hk_kontor_tanim c
            WHERE     b.urun_tipi = 4
                  AND b.kontor_kodu = c.kontor_kodu
                  AND c.effective_date <= SYSDATE
                  AND c.listeden_gizle = 'H'
           UNION ALL
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  'F03' AS franchise_code,
                  'BB' AS stb_tipi,
                  NULL AS expire_date,
                  'NOR' AS customer_type,
                  'BBA' AS kaynak,
                  b.urun_tipi,
                  b.bb_kupon_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b
            WHERE b.urun_tipi = 5
           UNION ALL
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  d.franchise_code,
                  c.stb_tipi,
                  c.kampanya_bitis_tarihi,
                  d.customer_type,
                  d.kaynak,
                  b.urun_tipi,
                  b.hav_akt_kampanya_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b,
                  pr_on_air_activation_kampanya c,
                  pr_on_air_activation_detay d
            WHERE     b.urun_tipi = 6
                  AND b.hav_akt_kampanya_kodu = c.kampanya_kodu
                  AND b.hav_akt_kampanya_kodu = d.kampanya_kodu
                  AND TRUNC (c.kampanya_baslangic_tarihi) <= TRUNC (SYSDATE)
                  AND (   TRUNC (c.kampanya_bitis_tarihi) >= TRUNC (SYSDATE)
                       OR c.kampanya_bitis_tarihi IS NULL)
                  AND (   TRUNC (c.listeden_gizle_tarihi) >= TRUNC (SYSDATE)
                       OR c.listeden_gizle_tarihi IS NULL)
                  AND c.kampanya_tipi = 2
                  UNION ALL 
           SELECT b.ID,
                  b.urun_grup_kod,
                  b.urun_grup_alt_kod,
                  b.urun_min_adet,
                  b.urun_max_adet,
                  b.urun_aciklama,
                  NULL AS franchise_code,
                  NULL AS stb_tipi,
                  NULL AS expire_date,
                  NULL AS customer_type,
                  NULL AS kaynak,
                  b.urun_tipi,
                  b.bb_kupon_kodu AS urun_kodu,
                  b.servis_kampanya_kodu,
                  b.servis_frekansi,
                  NULL OFFER_PRICE_ID,
                  NULL offer_price_name,
                  b.UST_GRUP_KOD,
                  b.UST_GRUP_ACIKLAMA
             FROM sf_urun_grup b
            WHERE b.urun_tipi = 7                  
                  ) f
    WHERE a.urun_grup_kod = f.urun_grup_kod
/
