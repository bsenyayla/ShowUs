CREATE OR REPLACE PACKAGE BODY DBS_DBA.internet_islem_pack IS
   -------------------------------------------------------------------------------------------------------------------------
   -------------------------------TTNET GELİŞTİRMELERİ PAKETLERİ-------------------------------------------------
   -------------------------------------------------------------------------------------------------------------------------

   PROCEDURE uyelik_iliskisi_olustur (in_account_number  IN     NUMBER,
                                      in_outlet_location IN     CHAR,
                                      in_iliskili_tt_id  IN     NUMBER,
                                      in_giren_kullanici        VARCHAR2,
                                      o_durum               OUT VARCHAR2
                                     ) IS
      v_hata_kodu NUMBER;
   BEGIN
      dbs_dba.kisi_iliski_pack.kisi_iliski_insert (in_kisi_bilgi_id          => NULL,
                                                   in_account_number         => in_account_number,
                                                   in_prospect_number        => NULL,
                                                   in_bb_user_id             => NULL,
                                                   in_dd_user_id             => NULL,
                                                   in_bp_user_id             => NULL,
                                                   in_da_user_id             => NULL,
                                                   in_iliski_kisi_bilgi_id   => NULL,
                                                   in_eslestirme_tipi_id     => 37,
                                                   in_iliski_account_number  => NULL,
                                                   in_iliski_prospect_number => NULL,
                                                   in_user                   => in_giren_kullanici,
                                                   in_aciklama               => 'TTNET üyelik eşleştirme',
                                                   out_durum                 => o_durum,
                                                   out_hata_kodu             => v_hata_kodu,
                                                   in_listeden_gizle         => 'H',
                                                   in_sysdate                => SYSDATE,
                                                   in_otomatik_giris         => 'H',
                                                   in_outlet_location        => in_outlet_location,
                                                   in_iliski_outlet_location => NULL,
                                                   in_millenicom_id          => NULL,
                                                   in_sol_id                 => NULL,
                                                   in_ttnet_id               => in_iliskili_tt_id,
                                                   in_co_status              => 'A',
                                                   in_co_kontrat_tarihi      => NULL
                                                  );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE ttnet_servis_islemleri (in_account_number IN NUMBER, in_outlet_location IN CHAR, in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_count                NUMBER;
      v_bundle_count         NUMBER := 0;
      v_internet_basvuru_id  NUMBER;
      indx                   NUMBER := 0;
      v_stb_tipi             CHAR (2);
      v_uye_tipi             CHAR (3);
      v_franchise_code       CHAR (3);
      v_uydu_tipi            NUMBER (1);
      v_hatali               BOOLEAN := FALSE;
      v_sonraki_statu        NUMBER;
      v_akis_tipi            NUMBER;
      v_guncel_statu         NUMBER;
      v_eklenecek_paket_adet NUMBER;
      v_uyelik_durum         NUMBER := 0; -- 1: Aktif , 2: SUS, 3:DON
      v_durum                VARCHAR2 (256);

      TYPE t_service IS RECORD
      (
         id                NUMBER,
         service_code      wiz_customer_hp_svc.service_code%TYPE,
         campaign_code     wiz_customer_hp_svc.campaign_code%TYPE,
         service_frequence wiz_customer_hp_svc.servis_frekansi%TYPE,
         closed_date       DATE
      );

      v_t_service            t_service;

      TYPE tb_service IS TABLE OF t_service;

      v_t_services           tb_service := tb_service ();
   BEGIN
      o_durum     := '0';

      BEGIN
         SELECT hp_cluster, customer_type, franchise_code
           INTO v_stb_tipi, v_uye_tipi, v_franchise_code
           FROM wiz_customer_hp_life
          WHERE account_number = in_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_durum := 'Account bilgisi hatalı.';
            RETURN;
      END;

      IF NOT (v_franchise_code = 'F01' AND v_uye_tipi = 'NOR') THEN
         o_durum := 'Sadece F01 ve NOR müşteriler için bu işlem yapılabilir...';
         RETURN;
      END IF;

      v_uydu_tipi := abone_sorgu_pack.uye_uydusu (in_account_number, in_outlet_location); -- 1 eutelsat 2 turksat 3 hata

      IF v_uydu_tipi != 1 THEN
         o_durum := 'Sadece eutelsat uydusu için bu işlem yapılabilmektedir..';
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM co_kullanici
       WHERE kod = in_kullanici;

      IF v_count = 0 THEN
         o_durum := 'Kullanıcı kodu hatalı.';
         RETURN;
      END IF;

      BEGIN
         SELECT DISTINCT bsv.application_id, CASE WHEN source = 'DBS' THEN 2 WHEN source = 'TTN' THEN 1 END AS akis_tipi
           INTO v_internet_basvuru_id, v_akis_tipi
           FROM dbs_dba.dt_internet_uye_basvuru bsv,
                dbs_dba.wf_tb_uye_statu st
          WHERE     bsv.account_number = in_account_number
                AND bsv.outlet_location = in_outlet_location
                AND st.account_number = in_account_number
                AND st.outlet_location = in_outlet_location
                AND st.durum = 'A';
      EXCEPTION
         WHEN OTHERS THEN
            o_durum := 'Üyenin aktif başvurusu bulunamadı..';
            RETURN;
      END;

      -- üyenin statüsüne bak. Eğer statü 5 harici ise hata var çık.
      dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (v_akis_tipi,
                                                       in_account_number,
                                                       in_outlet_location,
                                                       NULL,
                                                       v_guncel_statu,
                                                       o_durum,
                                                       v_internet_basvuru_id
                                                      );

      IF o_durum != '0' THEN
         o_durum := 'üyenin guncel statüsü bulunamadı. Hata : ' || o_durum;
         RETURN;
      END IF;

      IF v_guncel_statu != 5 THEN -- Servis ekleme işlemleri
         o_durum := ' Üyenin statüsü servis eklemek için uygun değildir.';
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_eklenecek_paket_adet
        FROM dbs_dba.dt_internet_uye_basvuru bsv,
             dbs_dba.dt_internet_uye_paket pkt
       WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id;

      IF v_eklenecek_paket_adet > 0 THEN
         IF v_eklenecek_paket_adet > 6 THEN
            o_durum := 'Hata : Servis ekleme adeti limiti aşıldı. IT ile iltişime geçiniz.';
            RETURN;
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.dt_internet_uye_basvuru bsv,
                dbs_dba.dt_internet_uye_paket pkt
          WHERE     bsv.application_id = pkt.application_id
                AND bsv.application_id = v_internet_basvuru_id
                AND package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))));

         IF v_count = 5 THEN -- 5 temel birden ekleniyordur. KMP yerine K02 ile ekle
            UPDATE dbs_dba.dt_internet_uye_paket
               SET campaign = 'K02'
             WHERE package_id IN (SELECT package_id
                                    FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                         dbs_dba.dt_internet_uye_paket pkt
                                   WHERE     bsv.application_id = pkt.application_id
                                         AND bsv.application_id = v_internet_basvuru_id
                                         AND package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))));
         END IF;

         -- Üyelik durumu kontrol ediliyor. Aktif, sus, don
         uye_kontrol_pack.uye_sus_mu (in_account_number, in_outlet_location, v_durum);

         IF v_durum != '0' THEN
            v_uyelik_durum := 2; -- Uye sus durumda
         ELSE
            uye_kontrol_pack.uye_donmus_mu (in_account_number, in_outlet_location, v_durum);

            IF v_durum != '0' THEN
               v_uyelik_durum := 3; -- Don durumunda
            ELSE
               v_uyelik_durum := 1; -- Üye aktif durumda
            END IF;
         END IF;

         -- Üyenin durumuna göre (aktif, sus, don ) iş emri var mı diye kontrol ediliyor
         BEGIN -- İş emirlerini var mı diye tek tek kontrol ediyor.
            IF v_uyelik_durum = 1 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_work_order wwo,
                      wiz_wo_line_items wwli
                WHERE     wwo.work_order_number = wwli.work_order_number
                      AND wwo.account_number = in_account_number
                      AND wwli.outlet_location = in_outlet_location
                      AND wwli.wo_status = 'O'
                      AND wwo.wo_status IN ('O', 'P');
            END IF;

            IF v_uyelik_durum = 2 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_kapama k,
                      ie_uyelik_kapama_servis s
                WHERE     k.durum = 'K'
                      AND k.account_number = in_account_number
                      AND k.outlet_location = in_outlet_location
                      AND k.id = s.uyelik_kapama_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 2;
            END IF;

            IF v_uyelik_durum = 3 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_dondurma d,
                      ie_uyelik_dondurma_servis s
                WHERE     d.durum = 'D'
                      AND d.account_number = in_account_number
                      AND d.outlet_location = in_outlet_location
                      AND d.id = s.uyelik_dondurma_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 2;
            END IF;
         END;

         -- Üye üzerinde işemirleri varsa, iş emrilerinin iptali ile ilgili işlemlerin yapılması.
         IF v_count > 0 THEN -- iş emirleri varsa iş emirleri iptal edilecek.
            IF v_uyelik_durum = 1 THEN
               FOR internet_paket_rec IN (SELECT pkt.package, pkt.campaign, frequency
                                            FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                                 dbs_dba.dt_internet_uye_paket pkt
                                           WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
                  FOR yasakli_servis_rec
                     IN (SELECT c.service_code
                           FROM pr_servis_takip a,
                                pr_servis_takip_detay b,
                                pr_yasak_zorunlu_servis_takip c
                          WHERE     a.kod = b.servis_takip_kodu
                                AND a.kod = c.servis_takip_kodu
                                AND a.service_code = internet_paket_rec.package
                                AND a.franchise_code = v_franchise_code
                                AND a.listeden_gizle = 'H'
                                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                AND b.customer_type = v_uye_tipi
                                AND c.yasakmi = 'E'
                         UNION
                         SELECT internet_paket_rec.package AS service_code FROM DUAL) LOOP
                     indx := 0;
                     v_t_services.delete;
                     v_t_services.EXTEND (33);

                     FOR isemri_rec
                        IN (SELECT   DISTINCT li.campaign_code, li.servis_frekansi, li.li_effective_date
                                FROM wiz_work_order wwo,
                                     wiz_wo_line_items li
                               WHERE     wwo.work_order_number = li.work_order_number
                                     AND wwo.account_number = in_account_number
                                     AND li.outlet_location = in_outlet_location
                                     AND li.service_code = yasakli_servis_rec.service_code
                                     AND li.wo_status = 'O'
                                     AND wwo.wo_status IN ('O', 'P')
                            ORDER BY li.li_effective_date) LOOP
                        indx                          := indx + 1;
                        v_t_service.service_code      := yasakli_servis_rec.service_code;
                        v_t_service.campaign_code     := isemri_rec.campaign_code;
                        v_t_service.service_frequence := isemri_rec.servis_frekansi;
                        v_t_service.closed_date       := isemri_rec.li_effective_date;
                        v_t_services (indx)           := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        from_excel_pack.uye_is_emri_iptal_extraparams (in_account_number       => in_account_number,
                                                                       in_outlet_location      => in_outlet_location,
                                                                       in_service_code_1       => v_t_services (1).service_code,
                                                                       in_campaign_code_1      => v_t_services (1).campaign_code,
                                                                       in_service_frequence_1  => v_t_services (1).service_frequence,
                                                                       in_closed_date_1        => v_t_services (1).closed_date,
                                                                       in_service_code_2       => v_t_services (2).service_code,
                                                                       in_campaign_code_2      => v_t_services (2).campaign_code,
                                                                       in_service_frequence_2  => v_t_services (2).service_frequence,
                                                                       in_closed_date_2        => v_t_services (2).closed_date,
                                                                       in_service_code_3       => v_t_services (3).service_code,
                                                                       in_campaign_code_3      => v_t_services (3).campaign_code,
                                                                       in_service_frequence_3  => v_t_services (3).service_frequence,
                                                                       in_closed_date_3        => v_t_services (3).closed_date,
                                                                       in_service_code_4       => v_t_services (4).service_code,
                                                                       in_campaign_code_4      => v_t_services (4).campaign_code,
                                                                       in_service_frequence_4  => v_t_services (4).service_frequence,
                                                                       in_closed_date_4        => v_t_services (4).closed_date,
                                                                       in_service_code_5       => v_t_services (5).service_code,
                                                                       in_campaign_code_5      => v_t_services (5).campaign_code,
                                                                       in_service_frequence_5  => v_t_services (5).service_frequence,
                                                                       in_closed_date_5        => v_t_services (5).closed_date,
                                                                       in_service_code_6       => v_t_services (6).service_code,
                                                                       in_campaign_code_6      => v_t_services (6).campaign_code,
                                                                       in_service_frequence_6  => v_t_services (6).service_frequence,
                                                                       in_closed_date_6        => v_t_services (6).closed_date,
                                                                       in_service_code_7       => v_t_services (7).service_code,
                                                                       in_campaign_code_7      => v_t_services (7).campaign_code,
                                                                       in_service_frequence_7  => v_t_services (7).service_frequence,
                                                                       in_closed_date_7        => v_t_services (7).closed_date,
                                                                       in_service_code_8       => v_t_services (8).service_code,
                                                                       in_campaign_code_8      => v_t_services (8).campaign_code,
                                                                       in_service_frequence_8  => v_t_services (8).service_frequence,
                                                                       in_closed_date_8        => v_t_services (8).closed_date,
                                                                       in_service_code_9       => v_t_services (9).service_code,
                                                                       in_campaign_code_9      => v_t_services (9).campaign_code,
                                                                       in_service_frequence_9  => v_t_services (9).service_frequence,
                                                                       in_closed_date_9        => v_t_services (9).closed_date,
                                                                       in_service_code_10      => v_t_services (10).service_code,
                                                                       in_campaign_code_10     => v_t_services (10).campaign_code,
                                                                       in_service_frequence_10 => v_t_services (10).service_frequence,
                                                                       in_closed_date_10       => v_t_services (10).closed_date,
                                                                       in_service_code_11      => v_t_services (11).service_code,
                                                                       in_campaign_code_11     => v_t_services (11).campaign_code,
                                                                       in_service_frequence_11 => v_t_services (11).service_frequence,
                                                                       in_closed_date_11       => v_t_services (11).closed_date,
                                                                       in_sebep_kodu           => 'TTN',
                                                                       in_kullanici            => 'SYSTEM',
                                                                       out_durum               => o_durum
                                                                      );

                        IF o_durum != '0' THEN
                           v_hatali := TRUE;
                        ELSE
                           v_hatali := FALSE;
                        END IF;
                     END IF;
                  END LOOP;

                  IF v_hatali THEN
                     indx := 0;
                     v_t_services.delete;
                     v_t_services.EXTEND (33);

                     FOR isemri_rec
                        IN (SELECT   DISTINCT li.campaign_code, li.servis_frekansi, li.li_effective_date, li.service_code
                                FROM wiz_work_order wwo,
                                     wiz_wo_line_items li
                               WHERE     wwo.work_order_number = li.work_order_number
                                     AND wwo.account_number = in_account_number
                                     AND li.outlet_location = in_outlet_location
                                     AND li.wo_status = 'O'
                                     AND wwo.wo_status IN ('O', 'P')
                            ORDER BY li.li_effective_date) LOOP
                        indx                          := indx + 1;
                        v_t_service.service_code      := isemri_rec.service_code;
                        v_t_service.campaign_code     := isemri_rec.campaign_code;
                        v_t_service.service_frequence := isemri_rec.servis_frekansi;
                        v_t_service.closed_date       := isemri_rec.li_effective_date;
                        v_t_services (indx)           := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        from_excel_pack.uye_is_emri_iptal_extraparams (in_account_number       => in_account_number,
                                                                       in_outlet_location      => in_outlet_location,
                                                                       in_service_code_1       => v_t_services (1).service_code,
                                                                       in_campaign_code_1      => v_t_services (1).campaign_code,
                                                                       in_service_frequence_1  => v_t_services (1).service_frequence,
                                                                       in_closed_date_1        => v_t_services (1).closed_date,
                                                                       in_service_code_2       => v_t_services (2).service_code,
                                                                       in_campaign_code_2      => v_t_services (2).campaign_code,
                                                                       in_service_frequence_2  => v_t_services (2).service_frequence,
                                                                       in_closed_date_2        => v_t_services (2).closed_date,
                                                                       in_service_code_3       => v_t_services (3).service_code,
                                                                       in_campaign_code_3      => v_t_services (3).campaign_code,
                                                                       in_service_frequence_3  => v_t_services (3).service_frequence,
                                                                       in_closed_date_3        => v_t_services (3).closed_date,
                                                                       in_service_code_4       => v_t_services (4).service_code,
                                                                       in_campaign_code_4      => v_t_services (4).campaign_code,
                                                                       in_service_frequence_4  => v_t_services (4).service_frequence,
                                                                       in_closed_date_4        => v_t_services (4).closed_date,
                                                                       in_service_code_5       => v_t_services (5).service_code,
                                                                       in_campaign_code_5      => v_t_services (5).campaign_code,
                                                                       in_service_frequence_5  => v_t_services (5).service_frequence,
                                                                       in_closed_date_5        => v_t_services (5).closed_date,
                                                                       in_service_code_6       => v_t_services (6).service_code,
                                                                       in_campaign_code_6      => v_t_services (6).campaign_code,
                                                                       in_service_frequence_6  => v_t_services (6).service_frequence,
                                                                       in_closed_date_6        => v_t_services (6).closed_date,
                                                                       in_service_code_7       => v_t_services (7).service_code,
                                                                       in_campaign_code_7      => v_t_services (7).campaign_code,
                                                                       in_service_frequence_7  => v_t_services (7).service_frequence,
                                                                       in_closed_date_7        => v_t_services (7).closed_date,
                                                                       in_service_code_8       => v_t_services (8).service_code,
                                                                       in_campaign_code_8      => v_t_services (8).campaign_code,
                                                                       in_service_frequence_8  => v_t_services (8).service_frequence,
                                                                       in_closed_date_8        => v_t_services (8).closed_date,
                                                                       in_service_code_9       => v_t_services (9).service_code,
                                                                       in_campaign_code_9      => v_t_services (9).campaign_code,
                                                                       in_service_frequence_9  => v_t_services (9).service_frequence,
                                                                       in_closed_date_9        => v_t_services (9).closed_date,
                                                                       in_service_code_10      => v_t_services (10).service_code,
                                                                       in_campaign_code_10     => v_t_services (10).campaign_code,
                                                                       in_service_frequence_10 => v_t_services (10).service_frequence,
                                                                       in_closed_date_10       => v_t_services (10).closed_date,
                                                                       in_service_code_11      => v_t_services (11).service_code,
                                                                       in_campaign_code_11     => v_t_services (11).campaign_code,
                                                                       in_service_frequence_11 => v_t_services (11).service_frequence,
                                                                       in_closed_date_11       => v_t_services (11).closed_date,
                                                                       in_sebep_kodu           => 'TTN',
                                                                       in_kullanici            => 'SYSTEM',
                                                                       out_durum               => o_durum
                                                                      );

                        IF o_durum != '0' THEN
                           o_durum := 'İş emri iptalinde hata alındı :  ' || o_durum;
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF; -- Aktif üye ise, iş emirleri tamamlandı. -- v_uyelik_durum = 1

            IF v_uyelik_durum = 2 THEN -- Üye SUS ise iş emri işlemleri yapılacak.
               FOR internet_paket_rec IN (SELECT pkt.package, pkt.campaign, frequency
                                            FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                                 dbs_dba.dt_internet_uye_paket pkt
                                           WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
                  FOR yasakli_servis_rec
                     IN (SELECT c.service_code
                           FROM pr_servis_takip a,
                                pr_servis_takip_detay b,
                                pr_yasak_zorunlu_servis_takip c
                          WHERE     a.kod = b.servis_takip_kodu
                                AND a.kod = c.servis_takip_kodu
                                AND a.service_code = internet_paket_rec.package
                                AND a.franchise_code = v_franchise_code
                                AND a.listeden_gizle = 'H'
                                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                AND b.customer_type = v_uye_tipi
                                AND c.yasakmi = 'E'
                         UNION
                         SELECT internet_paket_rec.package AS service_code FROM DUAL) LOOP
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_kapama k,
                                     ie_uyelik_kapama_servis s
                               WHERE     k.durum = 'K'
                                     AND k.account_number = in_account_number
                                     AND k.outlet_location = in_outlet_location
                                     AND s.service_code = yasakli_servis_rec.service_code
                                     AND k.id = s.uyelik_kapama_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                          := indx + 1;
                        v_t_services.EXTEND;
                        v_t_service.service_code      := yasakli_servis_rec.service_code;
                        v_t_service.id                := isemri_rec.iptal_id;
                        v_t_service.campaign_code     := isemri_rec.campaign_code;
                        v_t_service.service_frequence := isemri_rec.servis_frekansi;
                        v_t_service.closed_date       := isemri_rec.li_effective_date;
                        v_t_services (indx)           := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'KAPAMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Suspend işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'KAPAMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           v_hatali := TRUE;
                        ELSE
                           v_hatali := FALSE;
                        END IF;
                     END IF;
                  END LOOP;

                  IF v_hatali THEN
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code, s.servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_kapama k,
                                     ie_uyelik_kapama_servis s
                               WHERE     k.durum = 'K'
                                     AND k.account_number = in_account_number
                                     AND k.outlet_location = in_outlet_location
                                     AND k.id = s.uyelik_kapama_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                          := indx + 1;
                        v_t_service.service_code      := isemri_rec.service_code;
                        v_t_service.id                := isemri_rec.iptal_id;
                        v_t_service.campaign_code     := isemri_rec.campaign_code;
                        v_t_service.service_frequence := isemri_rec.servis_frekansi;
                        v_t_service.closed_date       := isemri_rec.li_effective_date;
                        v_t_services (indx)           := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'KAPAMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Suspend bütün işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'KAPAMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           o_durum := 'Suspend üye İş emri iptalinde hata alındı :  ' || o_durum;
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;

            IF v_uyelik_durum = 3 THEN
               FOR internet_paket_rec IN (SELECT pkt.package, pkt.campaign, frequency
                                            FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                                 dbs_dba.dt_internet_uye_paket pkt
                                           WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
                  FOR yasakli_servis_rec
                     IN (SELECT c.service_code
                           FROM pr_servis_takip a,
                                pr_servis_takip_detay b,
                                pr_yasak_zorunlu_servis_takip c
                          WHERE     a.kod = b.servis_takip_kodu
                                AND a.kod = c.servis_takip_kodu
                                AND a.service_code = internet_paket_rec.package
                                AND a.franchise_code = v_franchise_code
                                AND a.listeden_gizle = 'H'
                                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                AND b.customer_type = v_uye_tipi
                                AND c.yasakmi = 'E'
                         UNION
                         SELECT internet_paket_rec.package AS service_code FROM DUAL) LOOP
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_dondurma_id iptal_id, s.campaign_code, s.service_code, servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_dondurma d,
                                     ie_uyelik_dondurma_servis s
                               WHERE     d.durum = 'D'
                                     AND d.account_number = in_account_number
                                     AND d.outlet_location = in_outlet_location
                                     AND s.service_code = yasakli_servis_rec.service_code
                                     AND d.id = s.uyelik_dondurma_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                          := indx + 1;
                        v_t_services.EXTEND;
                        v_t_service.service_code      := yasakli_servis_rec.service_code;
                        v_t_service.id                := isemri_rec.iptal_id;
                        v_t_service.campaign_code     := isemri_rec.campaign_code;
                        v_t_service.service_frequence := isemri_rec.servis_frekansi;
                        v_t_service.closed_date       := isemri_rec.li_effective_date;
                        v_t_services (indx)           := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'DONDURMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Dondurma işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'DONDURMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           v_hatali := TRUE;
                        ELSE
                           v_hatali := FALSE;
                        END IF;
                     END IF;
                  END LOOP;

                  IF v_hatali THEN
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_dondurma_id iptal_id,
                                     s.campaign_code,
                                     s.service_code,
                                     s.servis_frekansi,
                                     s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_dondurma d,
                                     ie_uyelik_dondurma_servis s
                               WHERE     d.durum = 'D'
                                     AND d.account_number = in_account_number
                                     AND d.outlet_location = in_outlet_location
                                     AND d.id = s.uyelik_dondurma_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                          := indx + 1;
                        v_t_service.service_code      := isemri_rec.service_code;
                        v_t_service.id                := isemri_rec.iptal_id;
                        v_t_service.campaign_code     := isemri_rec.campaign_code;
                        v_t_service.service_frequence := isemri_rec.servis_frekansi;
                        v_t_service.closed_date       := isemri_rec.li_effective_date;
                        v_t_services (indx)           := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'DONDURMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Dondurma bütün işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'DONDURMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           o_durum := 'DON üye İş emri iptalinde hata alındı :  ' || o_durum;
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF; -- Aktif üye ise, iş emirleri tamamlandı. -- v_uyelik_durum = 2
         END IF;

         -- Seçilen servislerin üyenin üzerine eklenmesi.
         indx           := 0;
         v_t_services.delete;
         v_t_services.EXTEND (6);
         v_bundle_count := 0;

         FOR servis_rec
            IN (SELECT   package AS paket,
                         campaign AS kampanya,
                         frequency AS frekans,
                         CASE
                            WHEN pkt.package IN (SELECT service_code
                                                   FROM pr_servis_takip a,
                                                        pr_servis_takip_detay b
                                                  WHERE     a.kod = b.servis_takip_kodu
                                                        AND a.zorunlu = 'E'
                                                        AND a.franchise_code = v_franchise_code
                                                        AND a.listeden_gizle = 'H'
                                                        AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                                        AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                                        AND b.customer_type = v_uye_tipi) THEN
                               1
                            WHEN pkt.package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))) THEN
                               2
                            ELSE
                               3
                         END
                            sira
                    FROM dbs_dba.dt_internet_uye_basvuru bsv,
                         dbs_dba.dt_internet_uye_paket pkt
                   WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id
                ORDER BY sira) LOOP
            v_count := 0;

            -- Üye üzerinde ki de KMP Eklenen de kmp ise o zaman eklettirme
            --         IF servis_rec.kampanya = 'KMP'
            --         THEN
            --            SELECT COUNT (1)
            --              INTO v_count
            --              FROM wiz_Customer_hp_svc
            --             WHERE     account_number = in_account_number
            --                   AND outlet_location = in_outlet_location
            --                   AND service_code = servis_rec.paket
            --                   AND (promotion_code IS NULL OR promo_expire_date < SYSDATE);
            --         END IF;
            IF v_uyelik_durum = 1 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_svc svc
                WHERE     svc.account_number = in_account_number
                      AND svc.outlet_location = in_outlet_location
                      AND svc.service_code = servis_rec.paket
                      AND servis_rec.frekans = svc.servis_frekansi
                      AND (   (servis_rec.kampanya = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.kampanya = svc.campaign_code AND promo_expire_date > SYSDATE));

               IF v_count = 0 THEN
                  IF servis_rec.kampanya = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                          := indx + 1;
                     v_t_service.service_code      := servis_rec.paket;
                     v_t_service.campaign_code     := servis_rec.kampanya;
                     v_t_service.service_frequence := servis_rec.frekans;
                     v_t_services (indx)           := v_t_service;
                  END IF;
               END IF;
            END IF;

            -- Suspend ile ilgili paket ekleme
            IF v_uyelik_durum = 2 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_kapama k,
                      ie_uyelik_kapama_servis s
                WHERE     k.durum = 'K'
                      AND k.account_number = in_account_number
                      AND k.outlet_location = in_outlet_location
                      AND s.service_code = servis_rec.paket
                      AND s.servis_frekansi = servis_rec.frekans
                      AND (   (servis_rec.kampanya = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.kampanya = s.campaign_code AND promo_expire_date > SYSDATE))
                      AND k.id = s.uyelik_kapama_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 1;

               IF v_count = 0 THEN
                  IF servis_rec.kampanya = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                          := indx + 1;
                     v_t_service.service_code      := servis_rec.paket;
                     v_t_service.campaign_code     := servis_rec.kampanya;
                     v_t_service.service_frequence := servis_rec.frekans;
                     v_t_services (indx)           := v_t_service;
                  END IF;
               END IF;
            END IF;

            -- Donmuş bir üyelik ile ilgili paket ekleme
            IF v_uyelik_durum = 3 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_dondurma d,
                      ie_uyelik_dondurma_servis s
                WHERE     d.durum = 'D'
                      AND d.account_number = in_account_number
                      AND d.outlet_location = in_outlet_location
                      AND s.service_code = servis_rec.paket
                      AND s.servis_frekansi = servis_rec.frekans
                      AND (   (servis_rec.kampanya = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.kampanya = s.campaign_code AND promo_expire_date > SYSDATE))
                      AND d.id = s.uyelik_dondurma_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 1;

               IF v_count = 0 THEN
                  IF servis_rec.kampanya = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                          := indx + 1;
                     v_t_service.service_code      := servis_rec.paket;
                     v_t_service.campaign_code     := servis_rec.kampanya;
                     v_t_service.service_frequence := servis_rec.frekans;
                     v_t_services (indx)           := v_t_service;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF indx > 0 THEN
            from_excel_pack.uye_servis_ekle (in_account_number      => in_account_number,
                                             in_outlet_location     => in_outlet_location,
                                             in_service_code        => v_t_services (1).service_code,
                                             in_campaign_code       => v_t_services (1).campaign_code,
                                             in_service_frequence   => v_t_services (1).service_frequence,
                                             in_hemen_kapat         => 'E',
                                             in_li_effective_date   => SYSDATE,
                                             in_sebep_kodu          => 'TTN', --  Burada düzeltme yapılması gerekiyor. Bir tane sebep kodu eklenecek.
                                             in_bayiden_satis       => 'H',
                                             in_bayi_kodu           => NULL,
                                             in_ozel_fiyat          => NULL, -- v_ozel_fiyat,
                                             in_adet                => 1,
                                             in_bedelli             => 'E',
                                             in_sabit_promo_date    => NULL,
                                             in_kaynak              => 'DBS',
                                             in_kontrol_tipi        => 0,
                                             in_kullanici           => 'SYSTEM',
                                             out_durum              => o_durum,
                                             in_uyari_gec           => 'H',
                                             in_islem_tip           => 1,
                                             in_service_code_1      => v_t_services (2).service_code,
                                             in_campaign_code_1     => v_t_services (2).campaign_code,
                                             in_service_frequence_1 => v_t_services (2).service_frequence,
                                             in_service_code_2      => v_t_services (3).service_code,
                                             in_campaign_code_2     => v_t_services (3).campaign_code,
                                             in_service_frequence_2 => v_t_services (3).service_frequence,
                                             in_service_code_3      => v_t_services (4).service_code,
                                             in_campaign_code_3     => v_t_services (4).campaign_code,
                                             in_service_frequence_3 => v_t_services (4).service_frequence,
                                             in_service_code_4      => v_t_services (5).service_code,
                                             in_campaign_code_4     => v_t_services (5).campaign_code,
                                             in_service_frequence_4 => v_t_services (5).service_frequence,
                                             in_service_code_5      => v_t_services (6).service_code,
                                             in_campaign_code_5     => v_t_services (6).campaign_code,
                                             in_service_frequence_5 => v_t_services (6).service_frequence
                                            );

            IF o_durum != '0' THEN
               RETURN;
            END IF;
         END IF;
      END IF;

      uyelik_iliskisi_olustur (in_account_number, in_outlet_location, v_internet_basvuru_id, in_kullanici, o_durum);

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      wf_islem_pack.wf_sonraki_statuye_gec (v_akis_tipi,
                                            in_account_number,
                                            in_outlet_location,
                                            NULL,
                                            SYSDATE,
                                            5,
                                            'SYSTTN',
                                            v_sonraki_statu,
                                            o_durum,
                                            v_internet_basvuru_id
                                           );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE internet_servis_islemleri (in_account_number IN NUMBER, in_outlet_location IN CHAR, in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_count                NUMBER;
      v_bundle_count         NUMBER := 0;
      v_internet_basvuru_id  NUMBER;
      indx                   NUMBER := 0;
      v_stb_tipi             CHAR (2);
      v_uye_tipi             CHAR (3);
      v_franchise_code       CHAR (3);
      v_uydu_tipi            NUMBER (1);
      v_hatali               BOOLEAN := FALSE;
      v_sonraki_statu        NUMBER;
      v_akis_tipi            NUMBER;
      v_guncel_statu         NUMBER;
      v_eklenecek_paket_adet NUMBER;
      v_uyelik_durum         NUMBER := 0; -- 1: Aktif , 2: SUS, 3:DON
      v_durum                VARCHAR2 (256);

      TYPE t_service IS RECORD
      (
         id              NUMBER,
         service_code    wiz_customer_hp_svc.service_code%TYPE,
         campaign_code   wiz_customer_hp_svc.campaign_code%TYPE,
         servis_frekansi wiz_customer_hp_svc.servis_frekansi%TYPE,
         closed_date     DATE
      );

      v_t_service            t_service;

      TYPE tb_service IS TABLE OF t_service;

      v_t_services           tb_service := tb_service ();
   BEGIN
      o_durum := '0';

      BEGIN
         SELECT hp_cluster, customer_type, franchise_code
           INTO v_stb_tipi, v_uye_tipi, v_franchise_code
           FROM wiz_customer_hp_life
          WHERE account_number = in_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_durum := 'Account bilgisi hatalı.';
            RETURN;
      END;

      IF NOT (v_franchise_code = 'F01' AND v_uye_tipi = 'NOR') THEN
         o_durum := 'Sadece F01 ve NOR müşteriler için bu işlem yapılabilir...';
         RETURN;
      END IF;

      --      v_uydu_tipi := abone_sorgu_pack.uye_uydusu (in_account_number, in_outlet_location); -- 1 eutelsat 2 turksat 3 hata
      --
      --      IF v_uydu_tipi != 1 THEN
      --         o_durum := 'Sadece eutelsat uydusu için bu işlem yapılabilmektedir..';
      --         RETURN;
      --      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM co_kullanici
       WHERE kod = in_kullanici;

      IF v_count = 0 THEN
         o_durum := 'Kullanıcı kodu hatalı.';
         RETURN;
      END IF;

      BEGIN
         SELECT DISTINCT bsv.application_id, CASE WHEN provider = 2 THEN 3 WHEN source = 'DBS' THEN 2 WHEN source = 'TTN' THEN 1 END AS akis_tipi
           INTO v_internet_basvuru_id, v_akis_tipi
           FROM dbs_dba.dt_internet_uye_basvuru bsv,
                dbs_dba.wf_tb_uye_statu st
          WHERE     bsv.account_number = in_account_number
                AND bsv.outlet_location = in_outlet_location
                AND st.account_number = in_account_number
                AND st.outlet_location = in_outlet_location
                AND st.durum = 'A';
      EXCEPTION
         WHEN OTHERS THEN
            o_durum := 'Üyenin aktif başvurusu bulunamadı..';
            RETURN;
      END;

      -- üyenin statüsüne bak. Eğer statü 5 harici ise hata var çık.
      dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (v_akis_tipi,
                                                       in_account_number,
                                                       in_outlet_location,
                                                       NULL,
                                                       v_guncel_statu,
                                                       o_durum,
                                                       v_internet_basvuru_id
                                                      );

      IF o_durum != '0' THEN
         o_durum := 'üyenin guncel statüsü bulunamadı. Hata : ' || o_durum;
         RETURN;
      END IF;

      --      IF v_guncel_statu != 5 THEN -- Servis ekleme işlemleri
      --         o_durum := ' Üyenin statüsü servis eklemek için uygun değildir.';
      --         RETURN;
      --      END IF;

      SELECT COUNT (1)
        INTO v_eklenecek_paket_adet
        FROM dbs_dba.dt_internet_uye_basvuru bsv,
             dbs_dba.dt_internet_uye_paket pkt
       WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id;

      IF v_eklenecek_paket_adet > 0 THEN
         IF v_eklenecek_paket_adet > 6 THEN
            o_durum := 'Hata : Servis ekleme adeti limiti aşıldı. IT ile iltişime geçiniz.';
            RETURN;
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.dt_internet_uye_basvuru bsv,
                dbs_dba.dt_internet_uye_paket pkt
          WHERE     bsv.application_id = pkt.application_id
                AND bsv.application_id = v_internet_basvuru_id
                AND package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))));

         IF v_count = 5 THEN -- 5 temel birden ekleniyordur. KMP yerine K02 ile ekle
            UPDATE dbs_dba.dt_internet_uye_paket
               SET campaign = 'K02'
             WHERE package_id IN (SELECT package_id
                                    FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                         dbs_dba.dt_internet_uye_paket pkt
                                   WHERE     bsv.application_id = pkt.application_id
                                         AND bsv.application_id = v_internet_basvuru_id
                                         AND package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))));
         END IF;

         -- Üyelik durumu kontrol ediliyor. Aktif, sus, don
         uye_kontrol_pack.uye_sus_mu (in_account_number, in_outlet_location, v_durum);

         IF v_durum != '0' THEN
            v_uyelik_durum := 2; -- Uye sus durumda
         ELSE
            uye_kontrol_pack.uye_donmus_mu (in_account_number, in_outlet_location, v_durum);

            IF v_durum != '0' THEN
               v_uyelik_durum := 3; -- Don durumunda
            ELSE
               v_uyelik_durum := 1; -- Üye aktif durumda
            END IF;
         END IF;

         -- Üyenin durumuna göre (aktif, sus, don ) iş emri var mı diye kontrol ediliyor
         BEGIN -- İş emirlerini var mı diye tek tek kontrol ediyor.
            IF v_uyelik_durum = 1 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_work_order wwo,
                      wiz_wo_line_items wwli
                WHERE     wwo.work_order_number = wwli.work_order_number
                      AND wwo.account_number = in_account_number
                      AND wwli.outlet_location = in_outlet_location
                      AND wwli.wo_status = 'O'
                      AND wwo.wo_status IN ('O', 'P');
            END IF;

            IF v_uyelik_durum = 2 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_kapama k,
                      ie_uyelik_kapama_servis s
                WHERE     k.durum = 'K'
                      AND k.account_number = in_account_number
                      AND k.outlet_location = in_outlet_location
                      AND k.id = s.uyelik_kapama_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 2;
            END IF;

            IF v_uyelik_durum = 3 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_dondurma d,
                      ie_uyelik_dondurma_servis s
                WHERE     d.durum = 'D'
                      AND d.account_number = in_account_number
                      AND d.outlet_location = in_outlet_location
                      AND d.id = s.uyelik_dondurma_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 2;
            END IF;
         END;

         -- Üye üzerinde işemirleri varsa, iş emrilerinin iptali ile ilgili işlemlerin yapılması.
         IF v_count > 0 THEN -- iş emirleri varsa iş emirleri iptal edilecek.
            IF v_uyelik_durum = 1 THEN
               FOR internet_paket_rec IN (SELECT pkt.package, pkt.campaign, frequency
                                            FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                                 dbs_dba.dt_internet_uye_paket pkt
                                           WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
                  FOR yasakli_servis_rec
                     IN (SELECT c.service_code
                           FROM pr_servis_takip a,
                                pr_servis_takip_detay b,
                                pr_yasak_zorunlu_servis_takip c
                          WHERE     a.kod = b.servis_takip_kodu
                                AND a.kod = c.servis_takip_kodu
                                AND a.service_code = internet_paket_rec.package
                                AND a.franchise_code = v_franchise_code
                                AND a.listeden_gizle = 'H'
                                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                AND b.customer_type = v_uye_tipi
                                AND c.yasakmi = 'E'
                         UNION
                         SELECT internet_paket_rec.package AS service_code FROM DUAL) LOOP
                     indx := 0;
                     v_t_services.delete;
                     v_t_services.EXTEND (33);

                     FOR isemri_rec
                        IN (SELECT   DISTINCT li.campaign_code, li.servis_frekansi, li.li_effective_date
                                FROM wiz_work_order wwo,
                                     wiz_wo_line_items li
                               WHERE     wwo.work_order_number = li.work_order_number
                                     AND wwo.account_number = in_account_number
                                     AND li.outlet_location = in_outlet_location
                                     AND li.service_code = yasakli_servis_rec.service_code
                                     AND li.wo_status = 'O'
                                     AND wwo.wo_status IN ('O', 'P')
                            ORDER BY li.li_effective_date) LOOP
                        indx                        := indx + 1;
                        v_t_service.service_code    := yasakli_servis_rec.service_code;
                        v_t_service.campaign_code   := isemri_rec.campaign_code;
                        v_t_service.servis_frekansi := isemri_rec.servis_frekansi;
                        v_t_service.closed_date     := isemri_rec.li_effective_date;
                        v_t_services (indx)         := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        from_excel_pack.uye_is_emri_iptal_extraparams (in_account_number       => in_account_number,
                                                                       in_outlet_location      => in_outlet_location,
                                                                       in_service_code_1       => v_t_services (1).service_code,
                                                                       in_campaign_code_1      => v_t_services (1).campaign_code,
                                                                       in_service_frequence_1  => v_t_services (1).servis_frekansi,
                                                                       in_closed_date_1        => v_t_services (1).closed_date,
                                                                       in_service_code_2       => v_t_services (2).service_code,
                                                                       in_campaign_code_2      => v_t_services (2).campaign_code,
                                                                       in_service_frequence_2  => v_t_services (2).servis_frekansi,
                                                                       in_closed_date_2        => v_t_services (2).closed_date,
                                                                       in_service_code_3       => v_t_services (3).service_code,
                                                                       in_campaign_code_3      => v_t_services (3).campaign_code,
                                                                       in_service_frequence_3  => v_t_services (3).servis_frekansi,
                                                                       in_closed_date_3        => v_t_services (3).closed_date,
                                                                       in_service_code_4       => v_t_services (4).service_code,
                                                                       in_campaign_code_4      => v_t_services (4).campaign_code,
                                                                       in_service_frequence_4  => v_t_services (4).servis_frekansi,
                                                                       in_closed_date_4        => v_t_services (4).closed_date,
                                                                       in_service_code_5       => v_t_services (5).service_code,
                                                                       in_campaign_code_5      => v_t_services (5).campaign_code,
                                                                       in_service_frequence_5  => v_t_services (5).servis_frekansi,
                                                                       in_closed_date_5        => v_t_services (5).closed_date,
                                                                       in_service_code_6       => v_t_services (6).service_code,
                                                                       in_campaign_code_6      => v_t_services (6).campaign_code,
                                                                       in_service_frequence_6  => v_t_services (6).servis_frekansi,
                                                                       in_closed_date_6        => v_t_services (6).closed_date,
                                                                       in_service_code_7       => v_t_services (7).service_code,
                                                                       in_campaign_code_7      => v_t_services (7).campaign_code,
                                                                       in_service_frequence_7  => v_t_services (7).servis_frekansi,
                                                                       in_closed_date_7        => v_t_services (7).closed_date,
                                                                       in_service_code_8       => v_t_services (8).service_code,
                                                                       in_campaign_code_8      => v_t_services (8).campaign_code,
                                                                       in_service_frequence_8  => v_t_services (8).servis_frekansi,
                                                                       in_closed_date_8        => v_t_services (8).closed_date,
                                                                       in_service_code_9       => v_t_services (9).service_code,
                                                                       in_campaign_code_9      => v_t_services (9).campaign_code,
                                                                       in_service_frequence_9  => v_t_services (9).servis_frekansi,
                                                                       in_closed_date_9        => v_t_services (9).closed_date,
                                                                       in_service_code_10      => v_t_services (10).service_code,
                                                                       in_campaign_code_10     => v_t_services (10).campaign_code,
                                                                       in_service_frequence_10 => v_t_services (10).servis_frekansi,
                                                                       in_closed_date_10       => v_t_services (10).closed_date,
                                                                       in_service_code_11      => v_t_services (11).service_code,
                                                                       in_campaign_code_11     => v_t_services (11).campaign_code,
                                                                       in_service_frequence_11 => v_t_services (11).servis_frekansi,
                                                                       in_closed_date_11       => v_t_services (11).closed_date,
                                                                       in_sebep_kodu           => 'TTN',
                                                                       in_kullanici            => 'SYSTEM',
                                                                       out_durum               => o_durum
                                                                      );

                        IF o_durum != '0' THEN
                           v_hatali := TRUE;
                        ELSE
                           v_hatali := FALSE;
                        END IF;
                     END IF;
                  END LOOP;

                  IF v_hatali THEN
                     indx := 0;
                     v_t_services.delete;
                     v_t_services.EXTEND (33);

                     FOR isemri_rec
                        IN (SELECT   DISTINCT li.campaign_code, li.servis_frekansi, li.li_effective_date, li.service_code
                                FROM wiz_work_order wwo,
                                     wiz_wo_line_items li
                               WHERE     wwo.work_order_number = li.work_order_number
                                     AND wwo.account_number = in_account_number
                                     AND li.outlet_location = in_outlet_location
                                     AND li.wo_status = 'O'
                                     AND wwo.wo_status IN ('O', 'P')
                            ORDER BY li.li_effective_date) LOOP
                        indx                        := indx + 1;
                        v_t_service.service_code    := isemri_rec.service_code;
                        v_t_service.campaign_code   := isemri_rec.campaign_code;
                        v_t_service.servis_frekansi := isemri_rec.servis_frekansi;
                        v_t_service.closed_date     := isemri_rec.li_effective_date;
                        v_t_services (indx)         := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        from_excel_pack.uye_is_emri_iptal_extraparams (in_account_number       => in_account_number,
                                                                       in_outlet_location      => in_outlet_location,
                                                                       in_service_code_1       => v_t_services (1).service_code,
                                                                       in_campaign_code_1      => v_t_services (1).campaign_code,
                                                                       in_service_frequence_1  => v_t_services (1).servis_frekansi,
                                                                       in_closed_date_1        => v_t_services (1).closed_date,
                                                                       in_service_code_2       => v_t_services (2).service_code,
                                                                       in_campaign_code_2      => v_t_services (2).campaign_code,
                                                                       in_service_frequence_2  => v_t_services (2).servis_frekansi,
                                                                       in_closed_date_2        => v_t_services (2).closed_date,
                                                                       in_service_code_3       => v_t_services (3).service_code,
                                                                       in_campaign_code_3      => v_t_services (3).campaign_code,
                                                                       in_service_frequence_3  => v_t_services (3).servis_frekansi,
                                                                       in_closed_date_3        => v_t_services (3).closed_date,
                                                                       in_service_code_4       => v_t_services (4).service_code,
                                                                       in_campaign_code_4      => v_t_services (4).campaign_code,
                                                                       in_service_frequence_4  => v_t_services (4).servis_frekansi,
                                                                       in_closed_date_4        => v_t_services (4).closed_date,
                                                                       in_service_code_5       => v_t_services (5).service_code,
                                                                       in_campaign_code_5      => v_t_services (5).campaign_code,
                                                                       in_service_frequence_5  => v_t_services (5).servis_frekansi,
                                                                       in_closed_date_5        => v_t_services (5).closed_date,
                                                                       in_service_code_6       => v_t_services (6).service_code,
                                                                       in_campaign_code_6      => v_t_services (6).campaign_code,
                                                                       in_service_frequence_6  => v_t_services (6).servis_frekansi,
                                                                       in_closed_date_6        => v_t_services (6).closed_date,
                                                                       in_service_code_7       => v_t_services (7).service_code,
                                                                       in_campaign_code_7      => v_t_services (7).campaign_code,
                                                                       in_service_frequence_7  => v_t_services (7).servis_frekansi,
                                                                       in_closed_date_7        => v_t_services (7).closed_date,
                                                                       in_service_code_8       => v_t_services (8).service_code,
                                                                       in_campaign_code_8      => v_t_services (8).campaign_code,
                                                                       in_service_frequence_8  => v_t_services (8).servis_frekansi,
                                                                       in_closed_date_8        => v_t_services (8).closed_date,
                                                                       in_service_code_9       => v_t_services (9).service_code,
                                                                       in_campaign_code_9      => v_t_services (9).campaign_code,
                                                                       in_service_frequence_9  => v_t_services (9).servis_frekansi,
                                                                       in_closed_date_9        => v_t_services (9).closed_date,
                                                                       in_service_code_10      => v_t_services (10).service_code,
                                                                       in_campaign_code_10     => v_t_services (10).campaign_code,
                                                                       in_service_frequence_10 => v_t_services (10).servis_frekansi,
                                                                       in_closed_date_10       => v_t_services (10).closed_date,
                                                                       in_service_code_11      => v_t_services (11).service_code,
                                                                       in_campaign_code_11     => v_t_services (11).campaign_code,
                                                                       in_service_frequence_11 => v_t_services (11).servis_frekansi,
                                                                       in_closed_date_11       => v_t_services (11).closed_date,
                                                                       in_sebep_kodu           => 'TTN',
                                                                       in_kullanici            => 'SYSTEM',
                                                                       out_durum               => o_durum
                                                                      );

                        IF o_durum != '0' THEN
                           o_durum := 'İş emri iptalinde hata alındı :  ' || o_durum;
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF; -- Aktif üye ise, iş emirleri tamamlandı. -- v_uyelik_durum = 1

            IF v_uyelik_durum = 2 THEN -- Üye SUS ise iş emri işlemleri yapılacak.
               FOR internet_paket_rec IN (SELECT pkt.package, pkt.campaign, frequency
                                            FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                                 dbs_dba.dt_internet_uye_paket pkt
                                           WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
                  FOR yasakli_servis_rec
                     IN (SELECT c.service_code
                           FROM pr_servis_takip a,
                                pr_servis_takip_detay b,
                                pr_yasak_zorunlu_servis_takip c
                          WHERE     a.kod = b.servis_takip_kodu
                                AND a.kod = c.servis_takip_kodu
                                AND a.service_code = internet_paket_rec.package
                                AND a.franchise_code = v_franchise_code
                                AND a.listeden_gizle = 'H'
                                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                AND b.customer_type = v_uye_tipi
                                AND c.yasakmi = 'E'
                         UNION
                         SELECT internet_paket_rec.package AS service_code FROM DUAL) LOOP
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_kapama k,
                                     ie_uyelik_kapama_servis s
                               WHERE     k.durum = 'K'
                                     AND k.account_number = in_account_number
                                     AND k.outlet_location = in_outlet_location
                                     AND s.service_code = yasakli_servis_rec.service_code
                                     AND k.id = s.uyelik_kapama_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                        := indx + 1;
                        v_t_services.EXTEND;
                        v_t_service.service_code    := yasakli_servis_rec.service_code;
                        v_t_service.id              := isemri_rec.iptal_id;
                        v_t_service.campaign_code   := isemri_rec.campaign_code;
                        v_t_service.servis_frekansi := isemri_rec.servis_frekansi;
                        v_t_service.closed_date     := isemri_rec.li_effective_date;
                        v_t_services (indx)         := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'KAPAMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Suspend işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'KAPAMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           v_hatali := TRUE;
                        ELSE
                           v_hatali := FALSE;
                        END IF;
                     END IF;
                  END LOOP;

                  IF v_hatali THEN
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code, s.servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_kapama k,
                                     ie_uyelik_kapama_servis s
                               WHERE     k.durum = 'K'
                                     AND k.account_number = in_account_number
                                     AND k.outlet_location = in_outlet_location
                                     AND k.id = s.uyelik_kapama_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                        := indx + 1;
                        v_t_service.service_code    := isemri_rec.service_code;
                        v_t_service.id              := isemri_rec.iptal_id;
                        v_t_service.campaign_code   := isemri_rec.campaign_code;
                        v_t_service.servis_frekansi := isemri_rec.servis_frekansi;
                        v_t_service.closed_date     := isemri_rec.li_effective_date;
                        v_t_services (indx)         := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'KAPAMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Suspend bütün işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'KAPAMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           o_durum := 'Suspend üye İş emri iptalinde hata alındı :  ' || o_durum;
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;

            IF v_uyelik_durum = 3 THEN
               FOR internet_paket_rec IN (SELECT pkt.package, pkt.campaign, frequency
                                            FROM dbs_dba.dt_internet_uye_basvuru bsv,
                                                 dbs_dba.dt_internet_uye_paket pkt
                                           WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
                  FOR yasakli_servis_rec
                     IN (SELECT c.service_code
                           FROM pr_servis_takip a,
                                pr_servis_takip_detay b,
                                pr_yasak_zorunlu_servis_takip c
                          WHERE     a.kod = b.servis_takip_kodu
                                AND a.kod = c.servis_takip_kodu
                                AND a.service_code = internet_paket_rec.package
                                AND a.franchise_code = v_franchise_code
                                AND a.listeden_gizle = 'H'
                                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                AND b.customer_type = v_uye_tipi
                                AND c.yasakmi = 'E'
                         UNION
                         SELECT internet_paket_rec.package AS service_code FROM DUAL) LOOP
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_dondurma_id iptal_id, s.campaign_code, s.service_code servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_dondurma d,
                                     ie_uyelik_dondurma_servis s
                               WHERE     d.durum = 'D'
                                     AND d.account_number = in_account_number
                                     AND d.outlet_location = in_outlet_location
                                     AND s.service_code = yasakli_servis_rec.service_code
                                     AND d.id = s.uyelik_dondurma_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                        := indx + 1;
                        v_t_services.EXTEND;
                        v_t_service.service_code    := yasakli_servis_rec.service_code;
                        v_t_service.id              := isemri_rec.iptal_id;
                        v_t_service.campaign_code   := isemri_rec.campaign_code;
                        v_t_service.servis_frekansi := isemri_rec.servis_frekansi;
                        v_t_service.closed_date     := isemri_rec.li_effective_date;
                        v_t_services (indx)         := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'DONDURMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Dondurma işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'DONDURMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           v_hatali := TRUE;
                        ELSE
                           v_hatali := FALSE;
                        END IF;
                     END IF;
                  END LOOP;

                  IF v_hatali THEN
                     indx := 0;
                     v_t_services.delete;

                     FOR isemri_rec
                        IN (SELECT   s.uyelik_dondurma_id iptal_id,
                                     s.campaign_code,
                                     s.service_code,
                                     s.servis_frekansi,
                                     s.beklenen_kapanma_tarihi li_effective_date
                                FROM ie_uyelik_dondurma d,
                                     ie_uyelik_dondurma_servis s
                               WHERE     d.durum = 'D'
                                     AND d.account_number = in_account_number
                                     AND d.outlet_location = in_outlet_location
                                     AND d.id = s.uyelik_dondurma_id
                                     AND s.eklenecek_mi = 'E'
                                     AND s.durum = 2
                            ORDER BY beklenen_kapanma_tarihi DESC,
                                     s.id DESC) LOOP
                        indx                        := indx + 1;
                        v_t_service.service_code    := isemri_rec.service_code;
                        v_t_service.id              := isemri_rec.iptal_id;
                        v_t_service.campaign_code   := isemri_rec.campaign_code;
                        v_t_service.servis_frekansi := isemri_rec.servis_frekansi;
                        v_t_service.closed_date     := isemri_rec.li_effective_date;
                        v_t_services (indx)         := v_t_service;
                     END LOOP;

                     IF indx > 0 THEN
                        FOR v_index IN 1 .. v_t_services.COUNT LOOP
                           rama_servis.ozel_servis_islem (v_t_services (v_index).id, 'SYSTTN', 'TTN', 'DONDURMA', 'IPTAL', o_durum);

                           IF o_durum != '0' THEN
                              o_durum := 'Dondurma bütün işemri iptali hata : ' || o_durum;
                              RETURN;
                           END IF;
                        END LOOP;

                        rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'DONDURMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                        IF o_durum != '0' THEN
                           o_durum := 'DON üye İş emri iptalinde hata alındı :  ' || o_durum;
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF; -- Aktif üye ise, iş emirleri tamamlandı. -- v_uyelik_durum = 2
         END IF;

         -- Seçilen servislerin üyenin üzerine eklenmesi.
         indx           := 0;
         v_t_services.delete;
         v_t_services.EXTEND (6);
         v_bundle_count := 0;

         FOR servis_rec
            IN (SELECT   package AS paket,
                         campaign AS kampanya,
                         frequency AS frekans,
                         CASE
                            WHEN pkt.package IN (SELECT service_code
                                                   FROM pr_servis_takip a,
                                                        pr_servis_takip_detay b
                                                  WHERE     a.kod = b.servis_takip_kodu
                                                        AND a.zorunlu = 'E'
                                                        AND a.franchise_code = v_franchise_code
                                                        AND a.listeden_gizle = 'H'
                                                        AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                                        AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                                        AND b.customer_type = v_uye_tipi) THEN
                               1
                            WHEN pkt.package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))) THEN
                               2
                            ELSE
                               3
                         END
                            sira
                    FROM dbs_dba.dt_internet_uye_basvuru bsv,
                         dbs_dba.dt_internet_uye_paket pkt
                   WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id
                ORDER BY sira) LOOP
            v_count := 0;

            -- Üye üzerinde ki de KMP Eklenen de kmp ise o zaman eklettirme
            --         IF servis_rec.kampanya = 'KMP'
            --         THEN
            --            SELECT COUNT (1)
            --              INTO v_count
            --              FROM wiz_Customer_hp_svc
            --             WHERE     account_number = in_account_number
            --                   AND outlet_location = in_outlet_location
            --                   AND service_code = servis_rec.paket
            --                   AND (promotion_code IS NULL OR promo_expire_date < SYSDATE);
            --         END IF;
            IF v_uyelik_durum = 1 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_svc svc
                WHERE     svc.account_number = in_account_number
                      AND svc.outlet_location = in_outlet_location
                      AND svc.service_code = servis_rec.paket
                      AND servis_rec.frekans = svc.servis_frekansi
                      AND (   (servis_rec.kampanya = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.kampanya = svc.campaign_code AND promo_expire_date > SYSDATE));

               IF v_count = 0 THEN
                  IF servis_rec.kampanya = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                        := indx + 1;
                     v_t_service.service_code    := servis_rec.paket;
                     v_t_service.campaign_code   := servis_rec.kampanya;
                     v_t_service.servis_frekansi := servis_rec.frekans;
                     v_t_services (indx)         := v_t_service;
                  END IF;
               END IF;
            END IF;

            -- Suspend ile ilgili paket ekleme
            IF v_uyelik_durum = 2 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_kapama k,
                      ie_uyelik_kapama_servis s
                WHERE     k.durum = 'K'
                      AND k.account_number = in_account_number
                      AND k.outlet_location = in_outlet_location
                      AND s.service_code = servis_rec.paket
                      AND s.servis_frekansi = servis_rec.frekans
                      AND (   (servis_rec.kampanya = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.kampanya = s.campaign_code AND promo_expire_date > SYSDATE))
                      AND k.id = s.uyelik_kapama_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 1;

               IF v_count = 0 THEN
                  IF servis_rec.kampanya = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                        := indx + 1;
                     v_t_service.service_code    := servis_rec.paket;
                     v_t_service.campaign_code   := servis_rec.kampanya;
                     v_t_service.servis_frekansi := servis_rec.frekans;
                     v_t_services (indx)         := v_t_service;
                  END IF;
               END IF;
            END IF;

            -- Donmuş bir üyelik ile ilgili paket ekleme
            IF v_uyelik_durum = 3 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_dondurma d,
                      ie_uyelik_dondurma_servis s
                WHERE     d.durum = 'D'
                      AND d.account_number = in_account_number
                      AND d.outlet_location = in_outlet_location
                      AND s.service_code = servis_rec.paket
                      AND s.servis_frekansi = servis_rec.frekans
                      AND (   (servis_rec.kampanya = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.kampanya = s.campaign_code AND promo_expire_date > SYSDATE))
                      AND d.id = s.uyelik_dondurma_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 1;

               IF v_count = 0 THEN
                  IF servis_rec.kampanya = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                        := indx + 1;
                     v_t_service.service_code    := servis_rec.paket;
                     v_t_service.campaign_code   := servis_rec.kampanya;
                     v_t_service.servis_frekansi := servis_rec.frekans;
                     v_t_services (indx)         := v_t_service;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF indx > 0 THEN
            from_excel_pack.uye_servis_ekle (in_account_number      => in_account_number,
                                             in_outlet_location     => in_outlet_location,
                                             in_service_code        => v_t_services (1).service_code,
                                             in_campaign_code       => v_t_services (1).campaign_code,
                                             in_service_frequence   => v_t_services (1).servis_frekansi,
                                             in_hemen_kapat         => 'E',
                                             in_li_effective_date   => SYSDATE,
                                             in_sebep_kodu          => 'TTN', --  Burada düzeltme yapılması gerekiyor. Bir tane sebep kodu eklenecek.
                                             in_bayiden_satis       => 'H',
                                             in_bayi_kodu           => NULL,
                                             in_ozel_fiyat          => NULL, -- v_ozel_fiyat,
                                             in_adet                => 1,
                                             in_bedelli             => 'E',
                                             in_sabit_promo_date    => NULL,
                                             in_kaynak              => 'DBS',
                                             in_kontrol_tipi        => 0,
                                             in_kullanici           => 'SYSTEM',
                                             out_durum              => o_durum,
                                             in_uyari_gec           => 'H',
                                             in_islem_tip           => 1,
                                             in_service_code_1      => v_t_services (2).service_code,
                                             in_campaign_code_1     => v_t_services (2).campaign_code,
                                             in_service_frequence_1 => v_t_services (2).servis_frekansi,
                                             in_service_code_2      => v_t_services (3).service_code,
                                             in_campaign_code_2     => v_t_services (3).campaign_code,
                                             in_service_frequence_2 => v_t_services (3).servis_frekansi,
                                             in_service_code_3      => v_t_services (4).service_code,
                                             in_campaign_code_3     => v_t_services (4).campaign_code,
                                             in_service_frequence_3 => v_t_services (4).servis_frekansi,
                                             in_service_code_4      => v_t_services (5).service_code,
                                             in_campaign_code_4     => v_t_services (5).campaign_code,
                                             in_service_frequence_4 => v_t_services (5).servis_frekansi,
                                             in_service_code_5      => v_t_services (6).service_code,
                                             in_campaign_code_5     => v_t_services (6).campaign_code,
                                             in_service_frequence_5 => v_t_services (6).servis_frekansi
                                            );

            IF o_durum != '0' THEN
               RETURN;
            END IF;
         END IF;
      END IF;

      --      uyelik_iliskisi_olustur (in_account_number, in_outlet_location, v_internet_basvuru_id, in_kullanici, o_durum);
      --
      --      IF o_durum != '0' THEN
      --         RETURN;
      --      END IF;

      --wf_islem_pack.wf_sonraki_statuye_gec (v_akis_tipi, in_account_number, in_outlet_location, NULL, SYSDATE, 5, 'SYSTTN', v_sonraki_statu, o_durum);

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   /*
      1.    Digitürk TTNET `e Lead oluşturulur, Lead TTNET ` de başarısız kapatılır: ERR1154
      2.    Digitürk TTNET `e Lead oluşturulur, Lead siparişe çevirilir. Lead Teknik nedenlerden başarısız kapatılır : ERR1155
      3.    Digitürk TTNET `e Lead oluşturulur, Lead siparişe çevirilir. Lead başarılı kapatılır. : VLD1144
      4.    Digitürk DSL Kampanyalı Müşteri aboneliğini iptal eder. : ERR1156
      5.    Digitürk DSL Kampanyalı Müşteri TTNET `de başka DSL Kampanyasına geçer. : ERR1157
      */

   PROCEDURE ttnet_call_back (in_promo_code         IN     VARCHAR2,
                              in_result_code        IN     VARCHAR2,
                              in_result_description IN     VARCHAR2,
                              in_action_date        IN     DATE,
                              o_error_code             OUT VARCHAR2,
                              o_durum                  OUT VARCHAR2
                             ) IS
      v_account_number  NUMBER;
      v_outlet_location CHAR (3);
      v_application_id  NUMBER;
      v_basvuru_statu   NUMBER;
      v_guncel_statu    NUMBER;
      o_sonraki_statu   NUMBER;
      v_uye_statu_id    NUMBER;
   BEGIN
      o_durum := '0';

      BEGIN
         SELECT account_number, outlet_location, application_id, status
           INTO v_account_number, v_outlet_location, v_application_id, v_basvuru_statu
           FROM dbs_dba.dt_internet_uye_basvuru
          WHERE int_promo_code = in_promo_code;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_error_code := 'ERR1000';
            o_durum      := 'Gönderilen promo_code bilgisi hatalıdır. ';
            RETURN;
         WHEN TOO_MANY_ROWS THEN
            o_error_code := 'ERR9999';
            o_durum      := 'Hatalı promo_code bilgisi. Aynı promo_code birden fazla kullanılmış.';
            RETURN;
         WHEN OTHERS THEN
            o_error_code := 'ERR9999';
            o_durum      := 'Promo_code ile ilgili beklenmeyen bir hata meydana geldi.';
            RETURN;
      END;

      IF TRIM (v_account_number) IS NULL OR TRIM (v_outlet_location) IS NULL THEN
         o_error_code := 'ERR9999';
         o_durum      := 'Üye - Outlet bilgisinde hata bulundu. promo_code : ' || in_promo_code;
         RETURN;
      END IF;

      wf_islem_pack.wf_guncel_statusunu_getir (2, v_account_number, v_outlet_location, NULL, v_guncel_statu, o_durum, v_application_id);

      IF o_durum != '0' THEN
         o_error_code := 'ERR9999';
         o_durum      := 'Güncel statü bunurken hata meydana geldi. ' || o_durum;
         RETURN;
      END IF;

      --      IF v_guncel_statu != v_basvuru_statu THEN
      --         o_error_code := 'ERR9999';
      --         o_durum      := 'Üyenin statü akışında ki statüsü ile başvurda ki statüsü hatalı';
      --         RETURN;
      --      END IF;

      IF v_guncel_statu != 4 THEN
         o_error_code := 'ERR9999';
         o_durum      := 'Üyenin bulunduğu statü bilgisi hatalı. Sadece TT de beklemede olan kayıtlar için bu işlem yapılabilir.';
         RETURN;
      END IF;

      IF in_result_code = 'VLD1144' THEN
         wf_islem_pack.wf_sonraki_statuye_gec (2,
                                               v_account_number,
                                               v_outlet_location,
                                               NULL,
                                               SYSDATE,
                                               v_guncel_statu,
                                               'SYSTTN',
                                               o_sonraki_statu,
                                               o_durum,
                                               v_application_id
                                              );

         IF o_durum != '0' THEN
            o_error_code := 'ERR9999';
            o_durum      := 'Üye TT beklemede statüsünden, bir sonraki statüye geçirilemedi.' || o_durum;
            RETURN;
         END IF;

         SELECT s.id
           INTO v_uye_statu_id
           FROM dbs_dba.wf_tb_uye_statu s,
                dbs_dba.wf_pr_statu_tanim t
          WHERE     s.statu_tanim_tip = 2
                AND t.tip = 2
                AND t.durum = 'A'
                AND s.durum = 'A'
                AND s.statu = t.statu
                AND s.account_number = v_account_number
                AND s.outlet_location = v_outlet_location;

         UPDATE dbs_dba.wf_tb_uye_statu
            SET hata_code = in_result_code, hata_aciklama = in_result_description
          WHERE id = v_uye_statu_id;
      ELSE
         wf_islem_pack.wf_uye_statusunu_degistir (2, v_account_number, v_outlet_location, NULL, SYSDATE, 6, 'SYSTTN', o_durum, v_application_id);

         IF o_durum != '0' THEN
            o_error_code := 'ERR9999';
            o_durum      := 'Üye TT hata statüsüne geçirilemedi..' || o_durum;
            RETURN;
         END IF;

         SELECT s.id
           INTO v_uye_statu_id
           FROM dbs_dba.wf_tb_uye_statu s,
                dbs_dba.wf_pr_statu_tanim t
          WHERE     s.statu_tanim_tip = 2
                AND t.tip = 2
                AND t.durum = 'A'
                AND s.durum = 'A'
                AND s.statu = t.statu
                AND s.account_number = v_account_number
                AND s.outlet_location = v_outlet_location;

         UPDATE dbs_dba.wf_tb_uye_statu
            SET hata_code = in_result_code, hata_aciklama = in_result_description
          WHERE id = v_uye_statu_id;
      END IF;

      SELECT s.id
        INTO v_uye_statu_id
        FROM dbs_dba.wf_tb_uye_statu s,
             dbs_dba.wf_pr_statu_tanim t
       WHERE     s.statu_tanim_tip = 2
             AND t.tip = 2
             AND t.durum = 'A'
             AND s.durum = 'A'
             AND s.statu = t.statu
             AND s.account_number = v_account_number
             AND s.outlet_location = v_outlet_location;

      UPDATE dbs_dba.wf_tb_uye_statu
         SET hata_code = in_result_code, hata_aciklama = in_result_description
       WHERE id = v_uye_statu_id;
   END;

   -------------------------------------------------------------------------------------------------------------------------
   -------------------------------SOL GELİŞTİRMELERİ PAKETLERİ----------------------------------------------------
   -------------------------------------------------------------------------------------------------------------------------

   PROCEDURE sol_call_back (in_promo_code         IN     VARCHAR2,
                            in_result_code        IN     VARCHAR2,
                            in_result_description IN     VARCHAR2,
                            in_action_date        IN     DATE,
                            o_error_code             OUT VARCHAR2,
                            o_durum                  OUT VARCHAR2
                           ) IS
      v_account_number  NUMBER (10);
      v_outlet_location CHAR (3);
      v_guncel_statu    NUMBER;
      o_sonraki_statu   NUMBER;
      v_application_id  NUMBER;
      v_uye_statu_id    NUMBER;
   BEGIN
      o_error_code := 'C';
      o_durum      := '0';

      BEGIN
         SELECT account_number, outlet_location, application_id
           INTO v_account_number, v_outlet_location, v_application_id
           FROM dbs_dba.dt_internet_uye_basvuru
          WHERE int_promo_code = in_promo_code AND int_wf_tip = 3;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_error_code := 'E';
            o_durum      := 'Gönderilen promo_code bilgisi bulunamadı. ';
            RETURN;
         WHEN TOO_MANY_ROWS THEN
            o_error_code := 'E';
            o_durum      := 'Hatalı promo_code bilgisi. Aynı promo_code birden fazla kullanılmış.';
            RETURN;
         WHEN OTHERS THEN
            o_error_code := 'E';
            o_durum      := 'Promocode hatası. ' || SUBSTR (SQLERRM, 1, 225);
            RETURN;
      END;

      IF TRIM (v_account_number) IS NULL OR TRIM (v_outlet_location) IS NULL THEN
         o_error_code := 'E';
         o_durum      := 'Üye - Outlet bilgisinde hata bulundu. promo_code : ' || in_promo_code;
         RETURN;
      END IF;

      wf_islem_pack.wf_guncel_statusunu_getir (3, v_account_number, v_outlet_location, NULL, v_guncel_statu, o_durum, v_application_id);

      IF o_durum != '0' THEN
         o_error_code := 'E';
         o_durum      := 'Güncel statü bunurken hata meydana geldi. ' || o_durum;
         RETURN;
      END IF;

      IF v_guncel_statu = 3 THEN
         wf_islem_pack.wf_sonraki_statuye_gec (3,
                                               v_account_number,
                                               v_outlet_location,
                                               NULL,
                                               SYSDATE,
                                               v_guncel_statu,
                                               'SYSSOL',
                                               o_sonraki_statu,
                                               o_durum,
                                               v_application_id
                                              );

         IF o_durum != '0' THEN
            o_error_code := 'E';
            o_durum      := 'Sol başarılı kayıt için statü değiştirilemedi.' || o_durum;
            RETURN;
         END IF;
      END IF;

      IF in_result_code = 'VLD1144' THEN
         wf_islem_pack.wf_sonraki_statuye_gec (3,
                                               v_account_number,
                                               v_outlet_location,
                                               NULL,
                                               SYSDATE,
                                               v_guncel_statu,
                                               'SYSSOL',
                                               o_sonraki_statu,
                                               o_durum,
                                               v_application_id
                                              );

         IF o_durum != '0' THEN
            o_error_code := 'ERR9999';
            o_durum      := 'Sol başarılı kayıt için statü değiştirilemedi.' || o_durum;
            RETURN;
         END IF;
      ELSE
         wf_islem_pack.wf_uye_statusunu_degistir (3, v_account_number, v_outlet_location, NULL, SYSDATE, 12, 'SYSSOL', o_durum, v_application_id);

         IF o_durum != '0' THEN
            o_error_code := 'E';
            o_durum      := 'Üye SOL hata statüsüne geçirilemedi..' || o_durum;
            RETURN;
         END IF;
      END IF;

      SELECT s.id
        INTO v_uye_statu_id
        FROM dbs_dba.wf_tb_uye_statu s,
             dbs_dba.wf_pr_statu_tanim t
       WHERE     s.statu_tanim_tip = 3
             AND t.tip = 3
             AND t.durum = 'A'
             AND s.durum = 'A'
             AND s.statu = t.statu
             AND s.application_id = v_application_id
             AND s.account_number = v_account_number
             AND s.outlet_location = v_outlet_location;

      UPDATE dbs_dba.wf_tb_uye_statu
         SET hata_code = in_result_code, hata_aciklama = in_result_description
       WHERE id = v_uye_statu_id;
   END;

   PROCEDURE sol_uyelik_iliskisi_olustur (in_account_number  IN     NUMBER,
                                          in_outlet_location IN     CHAR,
                                          in_iliskili_sol_id IN     NUMBER,
                                          in_co_status       IN     VARCHAR2,
                                          in_giren_kullanici        VARCHAR2,
                                          o_durum               OUT VARCHAR2
                                         ) IS
      v_hata_kodu NUMBER;
   BEGIN
      dbs_dba.kisi_iliski_pack.kisi_iliski_insert (in_kisi_bilgi_id          => NULL,
                                                   in_account_number         => in_account_number,
                                                   in_prospect_number        => NULL,
                                                   in_bb_user_id             => NULL,
                                                   in_dd_user_id             => NULL,
                                                   in_bp_user_id             => NULL,
                                                   in_da_user_id             => NULL,
                                                   in_iliski_kisi_bilgi_id   => NULL,
                                                   in_eslestirme_tipi_id     => 36,
                                                   in_iliski_account_number  => NULL,
                                                   in_iliski_prospect_number => NULL,
                                                   in_user                   => in_giren_kullanici,
                                                   in_aciklama               => 'SOL üyelik eşleştirme',
                                                   out_durum                 => o_durum,
                                                   out_hata_kodu             => v_hata_kodu,
                                                   in_listeden_gizle         => 'H',
                                                   in_sysdate                => SYSDATE,
                                                   in_otomatik_giris         => 'H',
                                                   in_outlet_location        => in_outlet_location,
                                                   in_iliski_outlet_location => NULL,
                                                   in_millenicom_id          => NULL,
                                                   in_sol_id                 => in_iliskili_sol_id,
                                                   in_ttnet_id               => NULL,
                                                   in_co_status              => in_co_status, --in_co_status 'A',
                                                   in_co_kontrat_tarihi      => NULL
                                                  );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE uye_eksik_paketlerini_bul (in_account_number          IN     NUMBER,
                                        in_outlet_location         IN     CHAR,
                                        in_eksik_temel_adeti       IN     NUMBER,
                                        in_uyelik_durum            IN     CHAR,
                                        io_uye_eklenecek_servisler IN OUT dbs_dba.t_uye_servisleri,
                                        in_kullanici               IN     VARCHAR2,
                                        o_durum                       OUT VARCHAR2
                                       ) IS
      v_t_uye_servis          dbs_dba.t_uye_servis;

      --v_t_uye_uzerindeki_servisler dbs_dba.t_uye_servisleri := dbs_dba.t_uye_servisleri ();
      v_uyelik_durum          NUMBER;
      v_eksik_temel_adeti_tmp NUMBER;
   BEGIN
      o_durum                 := '0';
      v_t_uye_servis          := NEW dbs_dba.t_uye_servis ();

      v_eksik_temel_adeti_tmp := in_eksik_temel_adeti;

      IF in_uyelik_durum = 'A' THEN -- üye aktif ve üzerinde eğer paket vasa
         -- Üyeye paket eklemek gerekiyor ve üye üzerinde temel paket varsa eksik temel adetleri yapılmak isteniyor.
         FOR servis_rec
            IN (SELECT   svc.service_code,
                         svc.campaign_code,
                         svc.servis_frekansi,
                         CASE
                            WHEN svc.campaign_code IN ('KMP', 'K02') THEN 1
                            WHEN svc.promotion_code IS NULL OR svc.promo_expire_date <= SYSDATE THEN 1
                            ELSE 2
                         END
                            AS kampanya_sira,
                         CASE WHEN wo.service_code IS NULL THEN 1 ELSE 2 END AS is_emri_sira
                    FROM wiz_customer_hp_svc svc
                         LEFT JOIN
                         (SELECT DISTINCT li.service_code, li.campaign_code, li.servis_frekansi
                            FROM wiz_work_order wwo,
                                 wiz_wo_line_items li
                           WHERE     wwo.work_order_number = li.work_order_number
                                 AND wwo.account_number = in_account_number
                                 AND li.outlet_location = in_outlet_location
                                 AND li.wo_status = 'O'
                                 AND wwo.wo_status IN ('O', 'P')) wo
                            ON svc.service_code = wo.service_code AND svc.campaign_code = wo.campaign_code AND svc.servis_frekansi = wo.servis_frekansi
                   WHERE     svc.account_number = in_account_number
                         AND svc.outlet_location = in_outlet_location
                         AND svc.service_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))))
                         AND svc.service_code NOT IN (SELECT service_code FROM TABLE (io_uye_eklenecek_servisler))
                ORDER BY kampanya_sira,
                         is_emri_sira) LOOP
            IF v_eksik_temel_adeti_tmp > 0 THEN
               v_t_uye_servis.service_code                                   := servis_rec.service_code;
               v_t_uye_servis.campaign_code                                  := CASE WHEN servis_rec.campaign_code = 'K02' THEN 'K02' ELSE 'KMP' END;
               v_t_uye_servis.servis_frekansi                                := '1'; -- servis_rec.servis_frekansi;
               io_uye_eklenecek_servisler.EXTEND ();

               io_uye_eklenecek_servisler (io_uye_eklenecek_servisler.COUNT) := v_t_uye_servis;

               IF servis_rec.campaign_code = 'K02' THEN
                  v_eksik_temel_adeti_tmp := 0;
               END IF;

               v_eksik_temel_adeti_tmp                                       := v_eksik_temel_adeti_tmp - 1;
            END IF;
         END LOOP;
      END IF;

      IF in_uyelik_durum = 'S' THEN -- üye Suspend
         FOR servis_rec
            IN (SELECT   svc.service_code,
                         svc.campaign_code,
                         svc.servis_frekansi,
                         CASE
                            WHEN svc.campaign_code IN ('KMP', 'K02') THEN 1
                            WHEN svc.promotion_code IS NULL OR svc.promo_expire_date <= SYSDATE THEN 1
                            ELSE 2
                         END
                            AS kampanya_sira,
                         CASE WHEN wo.service_code IS NULL THEN 1 ELSE 2 END AS is_emri_sira
                    FROM (SELECT k.account_number,
                                 k.outlet_location,
                                 s.uyelik_kapama_id iptal_id,
                                 s.campaign_code,
                                 s.service_code,
                                 servis_frekansi,
                                 s.beklenen_kapanma_tarihi li_effective_date,
                                 s.promotion_code,
                                 s.promo_expire_date
                            FROM ie_uyelik_kapama k,
                                 ie_uyelik_kapama_servis s
                           WHERE     k.durum = 'K'
                                 AND k.account_number = in_account_number
                                 AND k.outlet_location = in_account_number
                                 AND s.service_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))))
                                 AND k.id = s.uyelik_kapama_id
                                 AND s.eklenecek_mi = 'E'
                                 AND s.durum = 1) svc
                         LEFT JOIN
                         (SELECT s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code, servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                            FROM ie_uyelik_kapama k,
                                 ie_uyelik_kapama_servis s
                           WHERE     k.durum = 'K'
                                 AND k.account_number = in_account_number
                                 AND k.outlet_location = in_account_number
                                 AND k.id = s.uyelik_kapama_id
                                 AND s.eklenecek_mi = 'E'
                                 AND s.durum = 2) wo
                            ON svc.service_code = wo.service_code AND svc.campaign_code = wo.campaign_code AND svc.servis_frekansi = wo.servis_frekansi
                   WHERE     svc.account_number = in_account_number
                         AND svc.outlet_location = in_account_number
                         AND svc.service_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))))
                         AND svc.service_code NOT IN (SELECT service_code FROM TABLE (io_uye_eklenecek_servisler))
                ORDER BY kampanya_sira,
                         is_emri_sira) LOOP
            IF v_eksik_temel_adeti_tmp > 0 THEN
               v_t_uye_servis.service_code                                   := servis_rec.service_code;
               v_t_uye_servis.campaign_code                                  := CASE WHEN servis_rec.campaign_code = 'K02' THEN 'K02' ELSE 'KMP' END;
               v_t_uye_servis.servis_frekansi                                := '1'; -- servis_rec.servis_frekansi;
               io_uye_eklenecek_servisler.EXTEND ();

               io_uye_eklenecek_servisler (io_uye_eklenecek_servisler.COUNT) := v_t_uye_servis;

               IF servis_rec.campaign_code = 'K02' THEN
                  v_eksik_temel_adeti_tmp := 0;
               END IF;

               v_eksik_temel_adeti_tmp                                       := v_eksik_temel_adeti_tmp - 1;
            END IF;
         END LOOP;
      END IF;

      IF in_uyelik_durum = 'D' THEN -- üye donmuş
         FOR servis_rec
            IN (SELECT   svc.service_code,
                         svc.campaign_code,
                         svc.servis_frekansi,
                         CASE
                            WHEN svc.campaign_code IN ('KMP', 'K02') THEN 1
                            WHEN svc.promotion_code IS NULL OR svc.promo_expire_date <= SYSDATE THEN 1
                            ELSE 2
                         END
                            AS kampanya_sira,
                         CASE WHEN wo.service_code IS NULL THEN 1 ELSE 2 END AS is_emri_sira
                    FROM (SELECT d.account_number,
                                 d.outlet_location,
                                 s.uyelik_dondurma_id iptal_id,
                                 s.campaign_code,
                                 s.service_code,
                                 servis_frekansi,
                                 s.beklenen_kapanma_tarihi li_effective_date,
                                 s.promotion_code,
                                 s.promo_expire_date
                            FROM ie_uyelik_dondurma d,
                                 ie_uyelik_dondurma_servis s
                           WHERE     d.durum = 'D'
                                 AND d.account_number = in_account_number
                                 AND d.outlet_location = in_account_number
                                 AND s.service_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))))
                                 AND d.id = s.uyelik_dondurma_id
                                 AND s.eklenecek_mi = 'E'
                                 AND s.durum = 1) svc
                         LEFT JOIN
                         (SELECT s.uyelik_dondurma_id iptal_id, s.campaign_code, s.service_code, servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                            FROM ie_uyelik_dondurma d,
                                 ie_uyelik_dondurma_servis s
                           WHERE     d.durum = 'D'
                                 AND d.account_number = in_account_number
                                 AND d.outlet_location = in_account_number
                                 AND d.id = s.uyelik_dondurma_id
                                 AND s.eklenecek_mi = 'E'
                                 AND s.durum = 2) wo
                            ON svc.service_code = wo.service_code AND svc.campaign_code = wo.campaign_code AND svc.servis_frekansi = wo.servis_frekansi
                   WHERE     svc.account_number = in_account_number
                         AND svc.outlet_location = in_account_number
                         AND svc.service_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))))
                         AND svc.service_code NOT IN (SELECT service_code FROM TABLE (io_uye_eklenecek_servisler))
                ORDER BY kampanya_sira,
                         is_emri_sira) LOOP
            IF v_eksik_temel_adeti_tmp > 0 THEN
               v_t_uye_servis.service_code                                   := servis_rec.service_code;
               v_t_uye_servis.campaign_code                                  := CASE WHEN servis_rec.campaign_code = 'K02' THEN 'K02' ELSE 'KMP' END;
               v_t_uye_servis.servis_frekansi                                := '1'; -- servis_rec.servis_frekansi;
               io_uye_eklenecek_servisler.EXTEND ();

               io_uye_eklenecek_servisler (io_uye_eklenecek_servisler.COUNT) := v_t_uye_servis;

               IF servis_rec.campaign_code = 'K02' THEN
                  v_eksik_temel_adeti_tmp := 0;
               END IF;

               v_eksik_temel_adeti_tmp                                       := v_eksik_temel_adeti_tmp - 1;
            END IF;
         END LOOP;
      END IF;

      IF v_eksik_temel_adeti_tmp > 0 THEN
         FOR servis_rec IN (SELECT   *
                                FROM (SELECT 'BLG' AS service_code, 1 AS siralama FROM DUAL
                                      UNION
                                      SELECT 'TSO' AS service_code, 2 AS siralama FROM DUAL
                                      UNION
                                      SELECT 'COC' AS service_code, 3 AS siralama FROM DUAL
                                      UNION
                                      SELECT 'YSM' AS service_code, 4 AS siralama FROM DUAL
                                      UNION
                                      SELECT 'HBR' AS service_code, 5 AS siralama FROM DUAL) pkt
                               WHERE pkt.service_code NOT IN (SELECT service_code FROM TABLE (io_uye_eklenecek_servisler))
                            ORDER BY pkt.siralama) LOOP
            IF v_eksik_temel_adeti_tmp > 0 THEN
               v_t_uye_servis.service_code                                   := servis_rec.service_code;
               v_t_uye_servis.campaign_code                                  := 'KMP';
               v_t_uye_servis.servis_frekansi                                := '1';
               io_uye_eklenecek_servisler.EXTEND ();

               io_uye_eklenecek_servisler (io_uye_eklenecek_servisler.COUNT) := v_t_uye_servis;
               v_eksik_temel_adeti_tmp                                       := v_eksik_temel_adeti_tmp - 1;
            END IF;
         END LOOP;
      END IF;
   END;

   PROCEDURE int_uye_servis_ekle (in_account_number         IN     NUMBER,
                                  in_outlet_location        IN     CHAR,
                                  in_uye_durum              IN     CHAR,
                                  in_servis_liste           IN OUT dbs_dba.t_uye_servisleri,
                                  in_kullanici              IN     VARCHAR2,
                                  o_durum                      OUT VARCHAR2,
                                  in_tum_isemirlerini_iptal IN     VARCHAR2
                                 ) IS
      indx               NUMBER;
      tmp_indx           NUMBER;
      v_t_uye_servis     dbs_dba.t_uye_servis;
      v_t_uye_servisleri dbs_dba.t_uye_servisleri := dbs_dba.t_uye_servisleri ();
      v_hatali           BOOLEAN;
      v_stb_tipi         CHAR (2);
      v_franchise_code   CHAR (3);
      v_uye_tipi         CHAR (3);
      v_servis_kontrol   CHAR (1) := 'E';
   BEGIN
      o_durum        := '0';
      v_t_uye_servis := NEW dbs_dba.t_uye_servis ();

      BEGIN
         SELECT lf.hp_cluster, lf.franchise_code, lf.customer_type
           INTO v_stb_tipi, v_franchise_code, v_uye_tipi
           FROM wiz_customer_hp_life lf
          WHERE lf.account_number = in_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_durum := 'Account bilgisi hatalı.';
            RETURN;
      END;

      IF NOT (v_franchise_code = 'F01' AND v_uye_tipi = 'NOR') THEN
         o_durum := 'Sadece F01 ve NOR müşteriler için bu işlem yapılabilir...';
         RETURN;
      END IF;

      IF in_uye_durum = 'A' THEN -- Akltif üye için iptal edilmesi gereken iş emirleri akışı.
         FOR paket_liste IN (SELECT   service_code, campaign_code, servis_frekansi
                                 FROM TABLE (in_servis_liste)
                             ORDER BY sira) LOOP
            FOR yasakli_servisli_isemri_rec
               IN (SELECT c.service_code
                     FROM pr_servis_takip a,
                          pr_servis_takip_detay b,
                          pr_yasak_zorunlu_servis_takip c
                    WHERE     a.kod = b.servis_takip_kodu
                          AND a.kod = c.servis_takip_kodu
                          AND a.service_code = paket_liste.service_code
                          AND a.franchise_code = v_franchise_code
                          AND a.listeden_gizle = 'H'
                          AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                          AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                          AND b.customer_type = v_uye_tipi
                          AND c.yasakmi = 'E'
                   UNION
                   SELECT paket_liste.service_code AS service_code FROM DUAL) LOOP
               indx     := 0;
               v_t_uye_servisleri.delete;
               v_t_uye_servisleri.EXTEND (33);

               FOR isemri_rec
                  IN (SELECT   DISTINCT li.service_code, li.campaign_code, li.servis_frekansi, li.li_effective_date
                          FROM wiz_work_order wwo,
                               wiz_wo_line_items li
                         WHERE     wwo.work_order_number = li.work_order_number
                               AND wwo.account_number = in_account_number
                               AND li.outlet_location = in_outlet_location
                               AND li.service_code = yasakli_servisli_isemri_rec.service_code
                               AND li.wo_status = 'O'
                               AND wwo.wo_status IN ('O', 'P')
                      ORDER BY li.li_effective_date) LOOP
                  indx                           := indx + 1;
                  v_t_uye_servis.service_code    := isemri_rec.service_code;
                  v_t_uye_servis.campaign_code   := isemri_rec.campaign_code;
                  v_t_uye_servis.servis_frekansi := isemri_rec.servis_frekansi;
                  v_t_uye_servis.closed_date     := isemri_rec.li_effective_date;
                  v_t_uye_servisleri (indx)      := v_t_uye_servis;
               END LOOP;

               tmp_indx := 0;

               IF indx > 0 THEN
                  WHILE tmp_indx < indx LOOP
                     IF tmp_indx + 11 < indx THEN
                        v_servis_kontrol := 'H';
                     ELSE
                        v_servis_kontrol := 'E';
                     END IF;

                     from_excel_pack.uye_is_emri_iptal_extraparams (in_account_number       => in_account_number,
                                                                    in_outlet_location      => in_outlet_location,
                                                                    in_service_code_1       => v_t_uye_servisleri (tmp_indx + 1).service_code,
                                                                    in_campaign_code_1      => v_t_uye_servisleri (tmp_indx + 1).campaign_code,
                                                                    in_service_frequence_1  => v_t_uye_servisleri (tmp_indx + 1).servis_frekansi,
                                                                    in_closed_date_1        => v_t_uye_servisleri (tmp_indx + 1).closed_date,
                                                                    in_service_code_2       => v_t_uye_servisleri (tmp_indx + 2).service_code,
                                                                    in_campaign_code_2      => v_t_uye_servisleri (tmp_indx + 2).campaign_code,
                                                                    in_service_frequence_2  => v_t_uye_servisleri (tmp_indx + 2).servis_frekansi,
                                                                    in_closed_date_2        => v_t_uye_servisleri (tmp_indx + 2).closed_date,
                                                                    in_service_code_3       => v_t_uye_servisleri (tmp_indx + 3).service_code,
                                                                    in_campaign_code_3      => v_t_uye_servisleri (tmp_indx + 3).campaign_code,
                                                                    in_service_frequence_3  => v_t_uye_servisleri (tmp_indx + 3).servis_frekansi,
                                                                    in_closed_date_3        => v_t_uye_servisleri (tmp_indx + 3).closed_date,
                                                                    in_service_code_4       => v_t_uye_servisleri (tmp_indx + 4).service_code,
                                                                    in_campaign_code_4      => v_t_uye_servisleri (tmp_indx + 4).campaign_code,
                                                                    in_service_frequence_4  => v_t_uye_servisleri (tmp_indx + 4).servis_frekansi,
                                                                    in_closed_date_4        => v_t_uye_servisleri (tmp_indx + 4).closed_date,
                                                                    in_service_code_5       => v_t_uye_servisleri (tmp_indx + 5).service_code,
                                                                    in_campaign_code_5      => v_t_uye_servisleri (tmp_indx + 5).campaign_code,
                                                                    in_service_frequence_5  => v_t_uye_servisleri (tmp_indx + 5).servis_frekansi,
                                                                    in_closed_date_5        => v_t_uye_servisleri (tmp_indx + 5).closed_date,
                                                                    in_service_code_6       => v_t_uye_servisleri (tmp_indx + 6).service_code,
                                                                    in_campaign_code_6      => v_t_uye_servisleri (tmp_indx + 6).campaign_code,
                                                                    in_service_frequence_6  => v_t_uye_servisleri (tmp_indx + 6).servis_frekansi,
                                                                    in_closed_date_6        => v_t_uye_servisleri (tmp_indx + 6).closed_date,
                                                                    in_service_code_7       => v_t_uye_servisleri (tmp_indx + 7).service_code,
                                                                    in_campaign_code_7      => v_t_uye_servisleri (tmp_indx + 7).campaign_code,
                                                                    in_service_frequence_7  => v_t_uye_servisleri (tmp_indx + 7).servis_frekansi,
                                                                    in_closed_date_7        => v_t_uye_servisleri (tmp_indx + 7).closed_date,
                                                                    in_service_code_8       => v_t_uye_servisleri (tmp_indx + 8).service_code,
                                                                    in_campaign_code_8      => v_t_uye_servisleri (tmp_indx + 8).campaign_code,
                                                                    in_service_frequence_8  => v_t_uye_servisleri (tmp_indx + 8).servis_frekansi,
                                                                    in_closed_date_8        => v_t_uye_servisleri (tmp_indx + 8).closed_date,
                                                                    in_service_code_9       => v_t_uye_servisleri (tmp_indx + 9).service_code,
                                                                    in_campaign_code_9      => v_t_uye_servisleri (tmp_indx + 9).campaign_code,
                                                                    in_service_frequence_9  => v_t_uye_servisleri (tmp_indx + 9).servis_frekansi,
                                                                    in_closed_date_9        => v_t_uye_servisleri (tmp_indx + 9).closed_date,
                                                                    in_service_code_10      => v_t_uye_servisleri (tmp_indx + 10).service_code,
                                                                    in_campaign_code_10     => v_t_uye_servisleri (tmp_indx + 10).campaign_code,
                                                                    in_service_frequence_10 => v_t_uye_servisleri (tmp_indx + 10).servis_frekansi,
                                                                    in_closed_date_10       => v_t_uye_servisleri (tmp_indx + 10).closed_date,
                                                                    in_service_code_11      => v_t_uye_servisleri (tmp_indx + 11).service_code,
                                                                    in_campaign_code_11     => v_t_uye_servisleri (tmp_indx + 11).campaign_code,
                                                                    in_service_frequence_11 => v_t_uye_servisleri (tmp_indx + 11).servis_frekansi,
                                                                    in_closed_date_11       => v_t_uye_servisleri (tmp_indx + 11).closed_date,
                                                                    in_sebep_kodu           => 'TTN',
                                                                    in_kullanici            => 'SYSTEM',
                                                                    out_durum               => o_durum,
                                                                    in_servis_kontrol       => v_servis_kontrol
                                                                   );

                     tmp_indx := tmp_indx + 11;

                     --IF v_servis_kontrol = 'E' THEN
                     IF o_durum != '0' THEN
                        v_hatali := TRUE;
                     ELSE
                        v_hatali := FALSE;
                     END IF;
                  --END IF;
                  END LOOP;
               END IF;
            END LOOP;
         END LOOP;

         IF v_hatali THEN
            IF in_tum_isemirlerini_iptal = 'E' THEN
               indx     := 0;
               v_t_uye_servisleri.delete;
               v_t_uye_servisleri.EXTEND (33);

               FOR isemri_rec
                  IN (SELECT   DISTINCT li.service_code, li.campaign_code, li.servis_frekansi, li.li_effective_date
                          FROM wiz_work_order wwo,
                               wiz_wo_line_items li
                         WHERE     wwo.work_order_number = li.work_order_number
                               AND wwo.account_number = in_account_number
                               AND li.outlet_location = in_outlet_location
                               AND li.wo_status = 'O'
                               AND wwo.wo_status IN ('O', 'P')
                      ORDER BY li.li_effective_date) LOOP
                  indx                           := indx + 1;
                  v_t_uye_servis.service_code    := isemri_rec.service_code;
                  v_t_uye_servis.campaign_code   := isemri_rec.campaign_code;
                  v_t_uye_servis.servis_frekansi := isemri_rec.servis_frekansi;
                  v_t_uye_servis.closed_date     := isemri_rec.li_effective_date;
                  v_t_uye_servisleri (indx)      := v_t_uye_servis;
               END LOOP;

               tmp_indx := 0;

               IF indx > 0 THEN
                  WHILE tmp_indx < indx LOOP
                     IF tmp_indx + 11 < indx THEN
                        v_servis_kontrol := 'H';
                     ELSE
                        v_servis_kontrol := 'E';
                     END IF;

                     from_excel_pack.uye_is_emri_iptal_extraparams (in_account_number       => in_account_number,
                                                                    in_outlet_location      => in_outlet_location,
                                                                    in_service_code_1       => v_t_uye_servisleri (tmp_indx + 1).service_code,
                                                                    in_campaign_code_1      => v_t_uye_servisleri (tmp_indx + 1).campaign_code,
                                                                    in_service_frequence_1  => v_t_uye_servisleri (tmp_indx + 1).servis_frekansi,
                                                                    in_closed_date_1        => v_t_uye_servisleri (tmp_indx + 1).closed_date,
                                                                    in_service_code_2       => v_t_uye_servisleri (tmp_indx + 2).service_code,
                                                                    in_campaign_code_2      => v_t_uye_servisleri (tmp_indx + 2).campaign_code,
                                                                    in_service_frequence_2  => v_t_uye_servisleri (tmp_indx + 2).servis_frekansi,
                                                                    in_closed_date_2        => v_t_uye_servisleri (tmp_indx + 2).closed_date,
                                                                    in_service_code_3       => v_t_uye_servisleri (tmp_indx + 3).service_code,
                                                                    in_campaign_code_3      => v_t_uye_servisleri (tmp_indx + 3).campaign_code,
                                                                    in_service_frequence_3  => v_t_uye_servisleri (tmp_indx + 3).servis_frekansi,
                                                                    in_closed_date_3        => v_t_uye_servisleri (tmp_indx + 3).closed_date,
                                                                    in_service_code_4       => v_t_uye_servisleri (tmp_indx + 4).service_code,
                                                                    in_campaign_code_4      => v_t_uye_servisleri (tmp_indx + 4).campaign_code,
                                                                    in_service_frequence_4  => v_t_uye_servisleri (tmp_indx + 4).servis_frekansi,
                                                                    in_closed_date_4        => v_t_uye_servisleri (tmp_indx + 4).closed_date,
                                                                    in_service_code_5       => v_t_uye_servisleri (tmp_indx + 5).service_code,
                                                                    in_campaign_code_5      => v_t_uye_servisleri (tmp_indx + 5).campaign_code,
                                                                    in_service_frequence_5  => v_t_uye_servisleri (tmp_indx + 5).servis_frekansi,
                                                                    in_closed_date_5        => v_t_uye_servisleri (tmp_indx + 5).closed_date,
                                                                    in_service_code_6       => v_t_uye_servisleri (tmp_indx + 6).service_code,
                                                                    in_campaign_code_6      => v_t_uye_servisleri (tmp_indx + 6).campaign_code,
                                                                    in_service_frequence_6  => v_t_uye_servisleri (tmp_indx + 6).servis_frekansi,
                                                                    in_closed_date_6        => v_t_uye_servisleri (tmp_indx + 6).closed_date,
                                                                    in_service_code_7       => v_t_uye_servisleri (tmp_indx + 7).service_code,
                                                                    in_campaign_code_7      => v_t_uye_servisleri (tmp_indx + 7).campaign_code,
                                                                    in_service_frequence_7  => v_t_uye_servisleri (tmp_indx + 7).servis_frekansi,
                                                                    in_closed_date_7        => v_t_uye_servisleri (tmp_indx + 7).closed_date,
                                                                    in_service_code_8       => v_t_uye_servisleri (tmp_indx + 8).service_code,
                                                                    in_campaign_code_8      => v_t_uye_servisleri (tmp_indx + 8).campaign_code,
                                                                    in_service_frequence_8  => v_t_uye_servisleri (tmp_indx + 8).servis_frekansi,
                                                                    in_closed_date_8        => v_t_uye_servisleri (tmp_indx + 8).closed_date,
                                                                    in_service_code_9       => v_t_uye_servisleri (tmp_indx + 9).service_code,
                                                                    in_campaign_code_9      => v_t_uye_servisleri (tmp_indx + 9).campaign_code,
                                                                    in_service_frequence_9  => v_t_uye_servisleri (tmp_indx + 9).servis_frekansi,
                                                                    in_closed_date_9        => v_t_uye_servisleri (tmp_indx + 9).closed_date,
                                                                    in_service_code_10      => v_t_uye_servisleri (tmp_indx + 10).service_code,
                                                                    in_campaign_code_10     => v_t_uye_servisleri (tmp_indx + 10).campaign_code,
                                                                    in_service_frequence_10 => v_t_uye_servisleri (tmp_indx + 10).servis_frekansi,
                                                                    in_closed_date_10       => v_t_uye_servisleri (tmp_indx + 10).closed_date,
                                                                    in_service_code_11      => v_t_uye_servisleri (tmp_indx + 11).service_code,
                                                                    in_campaign_code_11     => v_t_uye_servisleri (tmp_indx + 11).campaign_code,
                                                                    in_service_frequence_11 => v_t_uye_servisleri (tmp_indx + 11).servis_frekansi,
                                                                    in_closed_date_11       => v_t_uye_servisleri (tmp_indx + 11).closed_date,
                                                                    in_sebep_kodu           => 'TTN',
                                                                    in_kullanici            => 'SYSTEM',
                                                                    out_durum               => o_durum,
                                                                    in_servis_kontrol       => v_servis_kontrol
                                                                   );
                     tmp_indx := tmp_indx + 11;
                  END LOOP;

                  IF o_durum != '0' THEN
                     o_durum := 'İş emri iptalinde hata alındı :  ' || o_durum;
                     RETURN;
                  END IF;
               END IF;
            ELSE -- Tüm iş emirleri iptal edilmesi deniliyorsa
               IF o_durum != '0' THEN
                  o_durum := 'İş emri iptalinde hata alındı :  ' || o_durum;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF;

      IF in_uye_durum = 'S' THEN -- Suspend üye için iptal edilmesi gereken iş emirleri akışı.
         FOR paket_liste IN (SELECT   service_code, campaign_code, servis_frekansi
                                 FROM TABLE (in_servis_liste)
                             ORDER BY sira) LOOP
            FOR yasakli_servisli_isemri_rec
               IN (SELECT c.service_code
                     FROM pr_servis_takip a,
                          pr_servis_takip_detay b,
                          pr_yasak_zorunlu_servis_takip c
                    WHERE     a.kod = b.servis_takip_kodu
                          AND a.kod = c.servis_takip_kodu
                          AND a.service_code = paket_liste.service_code
                          AND a.franchise_code = v_franchise_code
                          AND a.listeden_gizle = 'H'
                          AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                          AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                          AND b.customer_type = v_uye_tipi
                          AND c.yasakmi = 'E'
                   UNION
                   SELECT paket_liste.service_code AS service_code FROM DUAL) LOOP
               indx := 0;
               v_t_uye_servisleri.delete;

               FOR isemri_rec
                  IN (SELECT   s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code, servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                          FROM ie_uyelik_kapama k,
                               ie_uyelik_kapama_servis s
                         WHERE     k.durum = 'K'
                               AND k.account_number = in_account_number
                               AND k.outlet_location = in_outlet_location
                               AND s.service_code = yasakli_servisli_isemri_rec.service_code
                               AND k.id = s.uyelik_kapama_id
                               AND s.eklenecek_mi = 'E'
                               AND s.durum = 2
                      ORDER BY beklenen_kapanma_tarihi DESC,
                               s.id DESC) LOOP
                  indx                           := indx + 1;
                  v_t_uye_servisleri.EXTEND;
                  v_t_uye_servis.id              := isemri_rec.iptal_id;
                  v_t_uye_servis.service_code    := isemri_rec.service_code;
                  v_t_uye_servis.campaign_code   := isemri_rec.campaign_code;
                  v_t_uye_servis.servis_frekansi := isemri_rec.servis_frekansi;
                  v_t_uye_servis.closed_date     := isemri_rec.li_effective_date;
                  v_t_uye_servisleri (indx)      := v_t_uye_servis;
               END LOOP;

               IF indx > 0 THEN
                  FOR v_index IN 1 .. v_t_uye_servisleri.COUNT LOOP
                     rama_servis.ozel_servis_islem (v_t_uye_servisleri (v_index).id, 'SYSTTN', 'TTN', 'KAPAMA', 'IPTAL', o_durum);

                     IF o_durum != '0' THEN
                        o_durum := 'Suspend işemri iptali hata : ' || o_durum;
                        RETURN;
                     END IF;
                  END LOOP;

                  rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'KAPAMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                  IF o_durum != '0' THEN
                     v_hatali := TRUE;
                  ELSE
                     v_hatali := FALSE;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;

         IF v_hatali THEN
            IF in_tum_isemirlerini_iptal = 'E' THEN
               indx := 0;
               v_t_uye_servisleri.delete;

               FOR isemri_rec
                  IN (SELECT   s.uyelik_kapama_id iptal_id, s.campaign_code, s.service_code, s.servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                          FROM ie_uyelik_kapama k,
                               ie_uyelik_kapama_servis s
                         WHERE     k.durum = 'K'
                               AND k.account_number = in_account_number
                               AND k.outlet_location = in_outlet_location
                               AND k.id = s.uyelik_kapama_id
                               AND s.eklenecek_mi = 'E'
                               AND s.durum = 2
                      ORDER BY beklenen_kapanma_tarihi DESC,
                               s.id DESC) LOOP
                  indx                           := indx + 1;

                  v_t_uye_servis.id              := isemri_rec.iptal_id;
                  v_t_uye_servis.service_code    := isemri_rec.service_code;
                  v_t_uye_servis.campaign_code   := isemri_rec.campaign_code;
                  v_t_uye_servis.servis_frekansi := isemri_rec.servis_frekansi;
                  v_t_uye_servis.closed_date     := isemri_rec.li_effective_date;
                  v_t_uye_servisleri (indx)      := v_t_uye_servis;
               END LOOP;

               IF indx > 0 THEN
                  FOR v_index IN 1 .. v_t_uye_servisleri.COUNT LOOP
                     rama_servis.ozel_servis_islem (v_t_uye_servisleri (v_index).id, 'SYSTTN', 'TTN', 'KAPAMA', 'IPTAL', o_durum);

                     IF o_durum != '0' THEN
                        o_durum := 'Suspend bütün işemri iptali hata : ' || o_durum;
                        RETURN;
                     END IF;
                  END LOOP;

                  rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'KAPAMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                  IF o_durum != '0' THEN
                     o_durum := 'Suspend üye İş emri iptalinde hata alındı :  ' || o_durum;
                     RETURN;
                  END IF;
               END IF;
            ELSE -- Tüm iş emri iptal edilmesin denildiyse veya hata alınmadıysa
               IF o_durum != '0' THEN
                  o_durum := 'Suspend üye İş emri iptalinde hata alındı :  ' || o_durum;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF;

      IF in_uye_durum = 'D' THEN -- Donmuş üye için iptal edilmesi gereken iş emirleri akışı.
         FOR paket_liste IN (SELECT   service_code, campaign_code, servis_frekansi
                                 FROM TABLE (in_servis_liste)
                             ORDER BY sira) LOOP
            FOR yasakli_servisli_isemri_rec
               IN (SELECT c.service_code
                     FROM pr_servis_takip a,
                          pr_servis_takip_detay b,
                          pr_yasak_zorunlu_servis_takip c
                    WHERE     a.kod = b.servis_takip_kodu
                          AND a.kod = c.servis_takip_kodu
                          AND a.service_code = paket_liste.service_code
                          AND a.franchise_code = v_franchise_code
                          AND a.listeden_gizle = 'H'
                          AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                          AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                          AND b.customer_type = v_uye_tipi
                          AND c.yasakmi = 'E'
                   UNION
                   SELECT paket_liste.service_code AS service_code FROM DUAL) LOOP
               indx := 0;
               v_t_uye_servisleri.delete;

               FOR isemri_rec
                  IN (SELECT   s.uyelik_dondurma_id iptal_id, s.campaign_code, s.service_code, servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                          FROM ie_uyelik_dondurma d,
                               ie_uyelik_dondurma_servis s
                         WHERE     d.durum = 'D'
                               AND d.account_number = in_account_number
                               AND d.outlet_location = in_outlet_location
                               AND s.service_code = yasakli_servisli_isemri_rec.service_code
                               AND d.id = s.uyelik_dondurma_id
                               AND s.eklenecek_mi = 'E'
                               AND s.durum = 2
                      ORDER BY beklenen_kapanma_tarihi DESC,
                               s.id DESC) LOOP
                  indx                           := indx + 1;
                  v_t_uye_servisleri.EXTEND;
                  v_t_uye_servis.id              := isemri_rec.iptal_id;
                  v_t_uye_servis.service_code    := isemri_rec.service_code;
                  v_t_uye_servis.campaign_code   := isemri_rec.campaign_code;
                  v_t_uye_servis.servis_frekansi := isemri_rec.servis_frekansi;
                  v_t_uye_servis.closed_date     := isemri_rec.li_effective_date;
                  v_t_uye_servisleri (indx)      := v_t_uye_servis;
               END LOOP;

               IF indx > 0 THEN
                  FOR v_index IN 1 .. v_t_uye_servisleri.COUNT LOOP
                     rama_servis.ozel_servis_islem (v_t_uye_servisleri (v_index).id, 'SYSTTN', 'TTN', 'DONDURMA', 'IPTAL', o_durum);

                     IF o_durum != '0' THEN
                        o_durum := 'Dondurma işemri iptali hata : ' || o_durum;
                        RETURN;
                     END IF;
                  END LOOP;

                  rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'DONDURMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                  IF o_durum != '0' THEN
                     v_hatali := TRUE;
                  ELSE
                     v_hatali := FALSE;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;

         IF v_hatali THEN
            IF in_tum_isemirlerini_iptal = 'E' THEN
               indx := 0;
               v_t_uye_servisleri.delete;

               FOR isemri_rec
                  IN (SELECT   s.uyelik_dondurma_id iptal_id, s.campaign_code, s.service_code, s.servis_frekansi, s.beklenen_kapanma_tarihi li_effective_date
                          FROM ie_uyelik_dondurma d,
                               ie_uyelik_dondurma_servis s
                         WHERE     d.durum = 'D'
                               AND d.account_number = in_account_number
                               AND d.outlet_location = in_outlet_location
                               AND d.id = s.uyelik_dondurma_id
                               AND s.eklenecek_mi = 'E'
                               AND s.durum = 2
                      ORDER BY beklenen_kapanma_tarihi DESC,
                               s.id DESC) LOOP
                  indx                           := indx + 1;
                  v_t_uye_servis.id              := isemri_rec.iptal_id;
                  v_t_uye_servis.service_code    := isemri_rec.service_code;
                  v_t_uye_servis.campaign_code   := isemri_rec.campaign_code;
                  v_t_uye_servis.servis_frekansi := isemri_rec.servis_frekansi;
                  v_t_uye_servis.closed_date     := isemri_rec.li_effective_date;
                  v_t_uye_servisleri (indx)      := v_t_uye_servis;
               END LOOP;

               IF indx > 0 THEN
                  FOR v_index IN 1 .. v_t_uye_servisleri.COUNT LOOP
                     rama_servis.ozel_servis_islem (v_t_uye_servisleri (v_index).id, 'SYSTTN', 'TTN', 'DONDURMA', 'IPTAL', o_durum);

                     IF o_durum != '0' THEN
                        o_durum := 'Dondurma bütün işemri iptali hata : ' || o_durum;
                        RETURN;
                     END IF;
                  END LOOP;

                  rama_servis.servis_islem_kontrol (in_account_number, in_outlet_location, 'IPTAL', 'DONDURMA_SERVIS', 'DBS', 'SYSTTN', o_durum, '0');

                  IF o_durum != '0' THEN
                     o_durum := 'DON üye İş emri iptalinde hata alındı :  ' || o_durum;
                     RETURN;
                  END IF;
               END IF;
            ELSE
               IF o_durum != '0' THEN
                  o_durum := 'DON üye İş emri iptalinde hata alındı :  ' || o_durum;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF;

      -- Paketlerin üye üzerine eklenmesi

      DECLARE
         v_bundle_count NUMBER;
         v_count        NUMBER;
         l_indx         NUMBER := 0;
      BEGIN
         indx           := 0;
         v_t_uye_servisleri.delete;
         v_t_uye_servisleri.EXTEND (18);
         v_bundle_count := 0; -- Bu daha önceden düzeltilmiş olarak gelmesi gerekiyor.

         FOR servis_rec
            IN (SELECT   svc.service_code,
                         svc.campaign_code,
                         svc.servis_frekansi,
                         CASE
                            WHEN svc.service_code IN (SELECT service_code
                                                        FROM pr_servis_takip a,
                                                             pr_servis_takip_detay b
                                                       WHERE     a.kod = b.servis_takip_kodu
                                                             AND a.zorunlu = 'E'
                                                             AND a.franchise_code = v_franchise_code
                                                             AND a.listeden_gizle = 'H'
                                                             AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                                                             AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                                                             AND b.customer_type = v_uye_tipi) THEN
                               1
                            WHEN svc.service_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))) THEN
                               2
                            ELSE
                               3
                         END
                            sira
                    FROM (SELECT service_code, servis_frekansi, campaign_code FROM TABLE (in_servis_liste)) svc
                ORDER BY sira) LOOP
            v_count := 0;

            IF in_uye_durum = 'A' THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_svc svc
                WHERE     svc.account_number = in_account_number
                      AND svc.outlet_location = in_outlet_location
                      AND svc.service_code = servis_rec.service_code
                      AND svc.servis_frekansi = servis_rec.servis_frekansi
                      AND (   (servis_rec.campaign_code = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.campaign_code = svc.campaign_code AND promo_expire_date > SYSDATE));

               IF v_count = 0 THEN -- E
                  IF servis_rec.campaign_code = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                     THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                           := indx + 1;
                     v_t_uye_servis.service_code    := servis_rec.service_code;
                     v_t_uye_servis.campaign_code   := servis_rec.campaign_code;
                     v_t_uye_servis.servis_frekansi := servis_rec.servis_frekansi;
                     v_t_uye_servisleri (indx)      := v_t_uye_servis;
                  END IF;
               END IF;
            END IF;

            -- Suspend ile ilgili paket ekleme
            IF in_uye_durum = 'S' THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_kapama k,
                      ie_uyelik_kapama_servis s
                WHERE     k.durum = 'K'
                      AND k.account_number = in_account_number
                      AND k.outlet_location = in_outlet_location
                      AND s.service_code = servis_rec.service_code
                      AND s.servis_frekansi = servis_rec.servis_frekansi
                      AND (   (servis_rec.campaign_code = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.campaign_code = s.campaign_code AND promo_expire_date > SYSDATE))
                      AND k.id = s.uyelik_kapama_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 1;

               IF v_count = 0 THEN
                  IF servis_rec.campaign_code = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                     THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                           := indx + 1;
                     v_t_uye_servis.service_code    := servis_rec.service_code;
                     v_t_uye_servis.campaign_code   := servis_rec.campaign_code;
                     v_t_uye_servis.servis_frekansi := servis_rec.servis_frekansi;
                     v_t_uye_servisleri (indx)      := v_t_uye_servis;
                  END IF;
               END IF;
            END IF;

            -- Donmuş bir üyelik ile ilgili paket ekleme
            IF in_uye_durum = 'D' THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_dondurma d,
                      ie_uyelik_dondurma_servis s
                WHERE     d.durum = 'D'
                      AND d.account_number = in_account_number
                      AND d.outlet_location = in_outlet_location
                      AND s.service_code = servis_rec.service_code
                      AND s.servis_frekansi = servis_rec.servis_frekansi
                      AND (   (servis_rec.campaign_code = 'KMP' AND (promotion_code IS NULL OR promo_expire_date <= SYSDATE))
                           OR (servis_rec.campaign_code = s.campaign_code AND promo_expire_date > SYSDATE))
                      AND d.id = s.uyelik_dondurma_id
                      AND s.eklenecek_mi = 'E'
                      AND s.durum = 1;

               IF v_count = 0 THEN
                  IF servis_rec.campaign_code = 'K02' -- Bundle K02 için 5 tane kayıt gelecek sadece 1 i için eklenecek.
                                                     THEN
                     v_bundle_count := v_bundle_count + 1;
                  END IF;

                  IF v_bundle_count <= 1 THEN
                     indx                           := indx + 1;
                     v_t_uye_servis.service_code    := servis_rec.service_code;
                     v_t_uye_servis.campaign_code   := servis_rec.campaign_code;
                     v_t_uye_servis.servis_frekansi := servis_rec.servis_frekansi;
                     v_t_uye_servisleri (indx)      := v_t_uye_servis;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         IF indx > 0 THEN
            l_indx := 1;

            WHILE (v_t_uye_servisleri (l_indx).service_code IS NOT NULL) LOOP
               from_excel_pack.uye_servis_ekle (in_account_number      => in_account_number,
                                                in_outlet_location     => in_outlet_location,
                                                in_service_code        => v_t_uye_servisleri (l_indx).service_code,
                                                in_campaign_code       => v_t_uye_servisleri (l_indx).campaign_code,
                                                in_service_frequence   => v_t_uye_servisleri (l_indx).servis_frekansi,
                                                in_hemen_kapat         => 'E',
                                                in_li_effective_date   => SYSDATE,
                                                in_sebep_kodu          => 'TTN', --  Burada düzeltme yapılması gerekiyor. Bir tane sebep kodu eklenecek.
                                                in_bayiden_satis       => 'H',
                                                in_bayi_kodu           => NULL,
                                                in_ozel_fiyat          => NULL, -- v_ozel_fiyat,
                                                in_adet                => 1,
                                                in_bedelli             => 'E',
                                                in_sabit_promo_date    => NULL,
                                                in_kaynak              => 'DBS',
                                                in_kontrol_tipi        => 0,
                                                in_kullanici           => 'SYSTEM',
                                                out_durum              => o_durum,
                                                in_uyari_gec           => 'H',
                                                in_islem_tip           => 1,
                                                in_service_code_1      => v_t_uye_servisleri (l_indx + 1).service_code,
                                                in_campaign_code_1     => v_t_uye_servisleri (l_indx + 1).campaign_code,
                                                in_service_frequence_1 => v_t_uye_servisleri (l_indx + 1).servis_frekansi,
                                                in_service_code_2      => v_t_uye_servisleri (l_indx + 2).service_code,
                                                in_campaign_code_2     => v_t_uye_servisleri (l_indx + 2).campaign_code,
                                                in_service_frequence_2 => v_t_uye_servisleri (l_indx + 2).servis_frekansi,
                                                in_service_code_3      => v_t_uye_servisleri (l_indx + 3).service_code,
                                                in_campaign_code_3     => v_t_uye_servisleri (l_indx + 3).campaign_code,
                                                in_service_frequence_3 => v_t_uye_servisleri (l_indx + 3).servis_frekansi,
                                                in_service_code_4      => v_t_uye_servisleri (l_indx + 4).service_code,
                                                in_campaign_code_4     => v_t_uye_servisleri (l_indx + 4).campaign_code,
                                                in_service_frequence_4 => v_t_uye_servisleri (l_indx + 4).servis_frekansi,
                                                in_service_code_5      => v_t_uye_servisleri (l_indx + 5).service_code,
                                                in_campaign_code_5     => v_t_uye_servisleri (l_indx + 5).campaign_code,
                                                in_service_frequence_5 => v_t_uye_servisleri (l_indx + 5).servis_frekansi
                                               );
               l_indx := l_indx + 6;

               IF o_durum != '0' THEN
                  RETURN;
               END IF;
            END LOOP;
         END IF;
      END;
   END;

   PROCEDURE int_yeni_uye_paket (in_account_number           IN     NUMBER,
                                 in_outlet_location          IN     CHAR,
                                 in_uyelik_durum             IN     CHAR,
                                 in_uydu_tipi                IN     NUMBER,
                                 o_t_uye_eklenecek_servisler IN OUT dbs_dba.t_uye_servisleri,
                                 in_kullanici                IN     VARCHAR2,
                                 o_durum                        OUT VARCHAR2
                                ) IS
      v_count               NUMBER;
      v_internet_basvuru_id NUMBER;
      v_akis_tipi           NUMBER;
      v_guncel_statu        NUMBER;
      v_sonraki_statu       NUMBER;
      indx                  NUMBER;
      v_t_service           dbs_dba.t_uye_servis;
      v_calisan             NUMBER (1) := 0;
      v_promo_code          dbs_dba.dt_internet_uye_basvuru.int_promo_code%TYPE;
      v_error_type          NUMBER;
      v_error_code          VARCHAR2 (10);
   BEGIN
      o_durum     := '0';
      v_t_service := NEW dbs_dba.t_uye_servis ();

      --  o_t_uye_eklenecek_servisler:= NEW dbs_dba.t_uye_servisleri ();

      BEGIN
         SELECT DISTINCT bsv.application_id, bsv.int_wf_tip AS akis_tipi, int_promo_code
           INTO v_internet_basvuru_id, v_akis_tipi, v_promo_code
           FROM dbs_dba.dt_internet_uye_basvuru bsv,
                dbs_dba.wf_tb_uye_statu st
          WHERE     bsv.application_id = st.application_id
                AND bsv.account_number = in_account_number
                AND bsv.outlet_location = in_outlet_location
                AND st.statu_tanim_tip = 3
                AND bsv.int_wf_tip = 3
                AND bsv.status != 8
                AND st.durum = 'A';
      EXCEPTION
         WHEN OTHERS THEN
            o_durum := 'Üyenin aktif başvurusu bulunamadı..';
            RETURN;
      END;

      -- üyenin statüsüne bak. Eğer statü 5 harici ise hata var çık.
      dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (v_akis_tipi,
                                                       in_account_number,
                                                       in_outlet_location,
                                                       NULL,
                                                       v_guncel_statu,
                                                       o_durum,
                                                       v_internet_basvuru_id
                                                      );

      IF o_durum != '0' THEN
         o_durum := 'üyenin guncel statüsü bulunamadı. Hata : ' || o_durum;
         RETURN;
      END IF;

      IF v_guncel_statu != 5 THEN -- Servis ekleme işlemleri
         o_durum := ' Üyenin statüsü servis eklemek için uygun değildir.';
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM (SELECT account_number
                FROM wiz_customer_hp_svc
               WHERE     account_number = in_account_number
                     AND outlet_location = in_outlet_location
                     AND service_code = 'BSL'
                     AND campaign_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('SOL_CALISAN_KAMPANYASI_KOD'))))
              UNION
              SELECT k.account_number
                FROM ie_uyelik_kapama k,
                     ie_uyelik_kapama_servis s
               WHERE     k.durum = 'K'
                     AND k.account_number = in_account_number
                     AND k.outlet_location = in_outlet_location
                     AND s.service_code = 'BSL'
                     AND s.campaign_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('SOL_CALISAN_KAMPANYASI_KOD'))))
                     AND k.id = s.uyelik_kapama_id
                     AND s.eklenecek_mi = 'E'
                     AND s.durum = 1
              UNION
              SELECT d.account_number
                FROM ie_uyelik_dondurma d,
                     ie_uyelik_dondurma_servis s
               WHERE     d.durum = 'D'
                     AND d.account_number = in_account_number
                     AND d.outlet_location = in_outlet_location
                     AND s.service_code = 'BSL'
                     AND s.campaign_code IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('SOL_CALISAN_KAMPANYASI_KOD'))))
                     AND d.id = s.uyelik_dondurma_id
                     AND s.eklenecek_mi = 'E'
                     AND s.durum = 1);

      IF v_count > 0 THEN
         v_calisan := 1;
      END IF;

      -- Ekrandan daha önceden seçilen paketleri default olarak listeye eklenecek diye listeye ekle.
      indx        := 0;

      IF v_calisan = 0 THEN
         FOR secilen_servis_rec
            IN (SELECT pkt.package AS service_code, pkt.campaign AS campaign_code, pkt.frequency AS servis_frekansi, pkt.effective_date AS li_effective_date
                  FROM dbs_dba.dt_internet_uye_basvuru bsv,
                       dbs_dba.dt_internet_uye_paket pkt
                 WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
            indx                               := indx + 1;
            v_t_service.service_code           := secilen_servis_rec.service_code;
            v_t_service.campaign_code          := secilen_servis_rec.campaign_code;
            v_t_service.servis_frekansi        := secilen_servis_rec.servis_frekansi;
            --v_t_service.closed_date       := secilen_servis_rec.li_effective_date;
            o_t_uye_eklenecek_servisler.EXTEND ();
            o_t_uye_eklenecek_servisler (indx) := v_t_service;
         END LOOP;

         DECLARE
            v_limitsiz                BOOLEAN := FALSE;
            v_zorunlu_temel_adeti     NUMBER := 0;
            v_eksik_temel_paket_adeti NUMBER := 0;
         BEGIN
            -- TO_DO :  v_limitsiz üyenin limitli mi limitzi mi oldugu bilgisinii bul.

            SELECT COUNT (1)
              INTO v_count
              FROM dbs_dba.wiz_customer_hp_svc_int a
             WHERE     a.account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND EXISTS
                          (SELECT *
                             FROM dbs_dba.wiz_product_codes_int b
                            WHERE download_kota = 'Limitsiz' AND baglanti_tipi IN ('ADSL', 'FIBER') AND a.service_code = b.dbs_urun_kodu);

            IF v_count > 0 THEN
               v_limitsiz := TRUE;
            END IF;

            IF in_uydu_tipi = 1 AND v_limitsiz = TRUE THEN
               -- TO_DO zorunlu temel adetleri yeni tabloya göre bulunacak.
               v_zorunlu_temel_adeti     := 2;
               v_eksik_temel_paket_adeti := v_zorunlu_temel_adeti;

               SELECT COUNT (1)
                 INTO v_count
                 FROM dbs_dba.dt_internet_uye_basvuru bsv,
                      dbs_dba.dt_internet_uye_paket pkt
                WHERE     bsv.application_id = pkt.application_id
                      AND bsv.application_id = v_internet_basvuru_id
                      AND package IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER'))));

               IF v_count >= v_zorunlu_temel_adeti THEN
                  v_eksik_temel_paket_adeti := 0;
               ELSE
                  v_eksik_temel_paket_adeti := v_zorunlu_temel_adeti - v_count;
               END IF;

               IF v_eksik_temel_paket_adeti > 0 THEN
                  -- Üyenin eksik temel paketlerini bulur.
                  uye_eksik_paketlerini_bul (in_account_number,
                                             in_outlet_location,
                                             v_eksik_temel_paket_adeti,
                                             in_uyelik_durum,
                                             o_t_uye_eklenecek_servisler,
                                             in_kullanici,
                                             o_durum
                                            );

                  IF o_durum != '0' THEN
                     o_durum := 'üye eksik temel paketleri bulunamadı. ' || o_durum;
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.mb_abone_ozellik oz
       WHERE oz.account_number = in_account_number AND oz.outlet_location = in_outlet_location AND oz.abone_ozellik_kodu = 424;

      IF v_count > 0 THEN
         abone_detay_pack.mb_abone_ozellik_delete (in_account_number, in_outlet_location, 424, in_kullanici, o_durum);

         IF o_durum != '0' THEN
            o_durum := 'Üye denemesi bedava özeliği silinmedi. Hata : ' || o_durum;
            RETURN;
         END IF;
      END IF;

      sol_uyelik_iliskisi_olustur (in_account_number, in_outlet_location, v_internet_basvuru_id, 'A', in_kullanici, o_durum);

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      wf_islem_pack.wf_sonraki_statuye_gec (v_akis_tipi,
                                            in_account_number,
                                            in_outlet_location,
                                            NULL,
                                            SYSDATE,
                                            5,
                                            'SYSTTN',
                                            v_sonraki_statu,
                                            o_durum,
                                            v_internet_basvuru_id
                                           );

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      dbs_dba.sf_pack.sf_sifre_kullanildi (v_promo_code,
                                           in_account_number,
                                           in_outlet_location,
                                           NULL,
                                           2,
                                           'C',
                                           in_kullanici,
                                           'DBS',
                                           v_error_type,
                                           v_error_code,
                                           o_durum
                                          );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   -- Üyenin şifresini closed stüsüne çeker
   /*DECLARE
      v_sifre_serino  VARCHAR2 (10);
      v_lg_sf_urun_id NUMBER;
   BEGIN
      SELECT sf.seri_no
        INTO v_sifre_serino
        FROM sf_urun sf,
             sf_urun_grup gr
       WHERE     sf.urun_grup_kod = gr.urun_grup_kod
             AND gr.urun_tipi = 7
             AND sf.urun_grup_kod = 1117
             AND sf.reserved_account_number = in_account_number
             AND sf.reserved_outlet_location = in_outlet_location
             AND sf.durum = 'R';

      UPDATE sf_urun
         SET durum = 'C', aciklama = 'Diginet bundle üyelik tamamlandı.', degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
       WHERE seri_no = v_sifre_serino;

      FOR rec IN (SELECT *
                    FROM sf_urun
                   WHERE seri_no = v_sifre_serino) LOOP
         SELECT lg_sf_urun_id_seq.NEXTVAL INTO v_lg_sf_urun_id FROM DUAL;

         INSERT
           INTO lg_sf_urun (id,
                            kisi,
                            islem,
                            islem_tarihi,
                            seri_no,
                            gizli_no,
                            durum,
                            detay_durum,
                            effective_date,
                            expire_date,
                            urun_grup_kod,
                            urun_tasarim_id,
                            account_number,
                            outlet_location,
                            reserved_account_number,
                            reserved_outlet_location,
                            reserved_prospect_number,
                            reserved_gizli_no,
                            depodan,
                            depoya,
                            kaynak,
                            aciklama
                           )
            VALUES (
                      v_lg_sf_urun_id,
                      in_kullanici,
                      'U',
                      SYSDATE,
                      v_sifre_serino,
                      rec.gizli_no,
                      rec.durum,
                      rec.detay_durum,
                      rec.effective_date,
                      rec.expire_date,
                      rec.urun_grup_kod,
                      rec.urun_tasarim_id,
                      rec.account_number,
                      rec.outlet_location,
                      rec.reserved_account_number,
                      rec.reserved_outlet_location,
                      rec.reserved_prospect_number,
                      rec.reserved_gizli_no,
                      rec.equip_location_code,
                      NULL,
                      rec.kaynak,
                      rec.aciklama);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         -- Eğer kayıt yoksa, zaten iptal e çekilecek seri no yoktur.
         NULL;
   END;*/
   END;

   PROCEDURE int_yeni_uye_simulasyon (in_account_number           IN     NUMBER,
                                      in_outlet_location          IN     CHAR,
                                      in_uyelik_durum             IN     CHAR,
                                      in_uydu_tipi                IN     NUMBER,
                                      o_t_uye_eklenecek_servisler IN OUT dbs_dba.t_uye_servisleri,
                                      in_kullanici                IN     VARCHAR2,
                                      o_durum                        OUT VARCHAR2
                                     ) IS
      v_count               NUMBER;
      v_internet_basvuru_id NUMBER;
      v_akis_tipi           NUMBER;
      v_guncel_statu        NUMBER;
      indx                  NUMBER;
      v_t_service           dbs_dba.t_uye_servis;
   BEGIN
      o_durum     := '0';
      v_t_service := NEW dbs_dba.t_uye_servis ();

      BEGIN
         SELECT DISTINCT bsv.application_id, bsv.int_wf_tip AS akis_tipi
           INTO v_internet_basvuru_id, v_akis_tipi
           FROM dbs_dba.dt_internet_uye_basvuru bsv,
                dbs_dba.wf_tb_uye_statu st
          WHERE     bsv.application_id = st.application_id
                AND bsv.account_number = in_account_number
                AND bsv.outlet_location = in_outlet_location
                AND st.statu_tanim_tip = 3
                AND bsv.int_wf_tip = 3
                AND bsv.status != 8
                AND st.durum = 'A';
      EXCEPTION
         WHEN OTHERS THEN
            o_durum := 'Üyenin aktif başvurusu bulunamadı..';
            RETURN;
      END;

      -- Simülasyon içn üyenin statüsü servis ekleme statüsünde bulumalıdır.
      dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (v_akis_tipi,
                                                       in_account_number,
                                                       in_outlet_location,
                                                       NULL,
                                                       v_guncel_statu,
                                                       o_durum,
                                                       v_internet_basvuru_id
                                                      );

      IF o_durum != '0' THEN
         o_durum := 'Üyenin guncel statüsü bulunamadı. Hata : ' || o_durum;
         RETURN;
      END IF;

      IF v_guncel_statu NOT IN (2, 3, 4, 5, 9, 10, 11) THEN -- Servis ekleme işlemleri
         o_durum := ' Üyenin statüsü servis simülasyonu için uygun değildir.';
         RETURN;
      END IF;

      indx        := 0;

      FOR secilen_servis_rec
         IN (SELECT pkt.package AS service_code, pkt.campaign AS campaign_code, pkt.frequency AS servis_frekansi, pkt.effective_date AS li_effective_date
               FROM dbs_dba.dt_internet_uye_basvuru bsv,
                    dbs_dba.dt_internet_uye_paket pkt
              WHERE bsv.application_id = pkt.application_id AND bsv.application_id = v_internet_basvuru_id) LOOP
         indx                               := indx + 1;
         o_t_uye_eklenecek_servisler.EXTEND ();
         v_t_service.service_code           := secilen_servis_rec.service_code;
         v_t_service.campaign_code          := secilen_servis_rec.campaign_code;
         v_t_service.servis_frekansi        := secilen_servis_rec.servis_frekansi;
         --v_t_service.closed_date       := secilen_servis_rec.li_effective_date;
         o_t_uye_eklenecek_servisler (indx) := v_t_service;
      END LOOP;
   END;

   PROCEDURE int_sol_üye_simulasyon (in_account_number IN NUMBER, in_outlet_location IN CHAR, in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_count NUMBER;
   BEGIN
      SAVEPOINT simulasyon_transaction;

      internet_islem_pack.int_paket_islemleri (in_account_number, in_outlet_location, in_kullanici, 2, o_durum, 'E');

      ROLLBACK TO simulasyon_transaction;
   END;

   PROCEDURE int_mevcut_uye_paket (in_account_number           IN     NUMBER,
                                   in_outlet_location          IN     CHAR,
                                   in_uyelik_durum             IN     CHAR,
                                   in_uydu_tipi                IN     NUMBER,
                                   o_t_uye_eklenecek_servisler IN OUT dbs_dba.t_uye_servisleri,
                                   in_kullanici                IN     VARCHAR2,
                                   o_durum                        OUT VARCHAR2
                                  ) IS
      v_count NUMBER;
   BEGIN
      o_durum := '0';

      -- o_t_uye_eklenecek_servisler := dbs_dba.t_uye_servisleri ();

      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.gl_kisi_bilgi_iliski ils,
             dbs_dba.gl_iliski_detay dt
       WHERE     ils.eslestirme_tipi_id = 36
             AND ils.account_number = in_account_number
             AND ils.outlet_location = in_outlet_location
             AND ils.iliski_id = dt.iliski_id
             AND dt.status = 'A';

      IF v_count = 0 THEN
         o_durum := 'Üyenin aktif bir turk - Süperonline bundle üyeliği bulunmamaktadır.';
         RETURN;
      END IF;

      DECLARE
         v_limitsiz                BOOLEAN := FALSE;
         v_zorunlu_temel_adeti     NUMBER := 0;
         v_eksik_temel_paket_adeti NUMBER := 0;
      BEGIN
         -- TO_DO :  v_limitsiz üyenin limitli mi limitzi mi oldugu bilgisinii bul.
         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.wiz_customer_hp_svc_int a
          WHERE     a.account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND EXISTS
                       (SELECT *
                          FROM dbs_dba.wiz_product_codes_int b
                         WHERE download_kota = 'Limitsiz' AND baglanti_tipi IN ('ADSL', 'FIBER') AND a.service_code = b.dbs_urun_kodu);

         IF v_count > 0 THEN
            v_limitsiz := TRUE;
         END IF;

         IF in_uydu_tipi = 1 AND v_limitsiz = TRUE THEN
            -- TO_DO zorunlu temel adetleri yeni tabloya göre bulunacak.
            v_zorunlu_temel_adeti     := 2;
            v_eksik_temel_paket_adeti := v_zorunlu_temel_adeti;

            IF v_eksik_temel_paket_adeti > 0 THEN
               -- Üyenin eksik temel paketlerini bulur.
               uye_eksik_paketlerini_bul (in_account_number,
                                          in_outlet_location,
                                          v_eksik_temel_paket_adeti,
                                          in_uyelik_durum,
                                          o_t_uye_eklenecek_servisler,
                                          in_kullanici,
                                          o_durum
                                         );

               IF o_durum != '0' THEN
                  o_durum := 'üye eksik temel paketleri bulunamadı. ' || o_durum;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END;
   END;

   PROCEDURE int_paket_islemleri (in_account_number         IN     NUMBER,
                                  in_outlet_location        IN     CHAR,
                                  in_kullanici              IN     VARCHAR2,
                                  in_islem_tipi             IN     NUMBER,
                                  o_durum                      OUT VARCHAR2,
                                  in_tum_isemirlerini_iptal IN     VARCHAR2 DEFAULT 'E'
                                 ) IS
      v_count                     NUMBER;
      v_uydu_tipi                 NUMBER;
      v_uyelik_durum              VARCHAR2 (1);
      v_t_uye_eklenecek_servisler dbs_dba.t_uye_servisleri;
   BEGIN
      o_durum                     := '0';
      v_t_uye_eklenecek_servisler := NEW dbs_dba.t_uye_servisleri ();

      v_uydu_tipi                 := abone_sorgu_pack.uye_uydusu (in_account_number, in_outlet_location); -- 1 eutelsat 2 turksat 3 hata

      IF v_uydu_tipi NOT IN (1, 2) THEN
         o_durum := 'Üye uydu bilgisi bulunamadı...';
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM co_kullanici
       WHERE kod = in_kullanici;

      IF v_count = 0 THEN
         o_durum := 'Kullanıcı kodu hatalı.';
         RETURN;
      END IF;

      -- Üyelik durumu kontrol ediliyor. Aktif, sus, don
      uye_kontrol_pack.uye_sus_mu (in_account_number, in_outlet_location, o_durum);

      IF o_durum != '0' THEN
         v_uyelik_durum := 'S'; -- Suspend Üye
      ELSE
         uye_kontrol_pack.uye_donmus_mu (in_account_number, in_outlet_location, o_durum);

         IF o_durum != '0' THEN
            v_uyelik_durum := 'D'; -- Dondurulmuş üye
         ELSE
            v_uyelik_durum := 'A'; -- Aktif üye
         END IF;
      END IF;

      CASE in_islem_tipi
         WHEN 1 THEN -- Yeni üyelik paket ekleme
            int_yeni_uye_paket (in_account_number, in_outlet_location, v_uyelik_durum, v_uydu_tipi, v_t_uye_eklenecek_servisler, in_kullanici, o_durum);
         WHEN 2 THEN -- üye paket simülasyon çalıştırma
            int_yeni_uye_simulasyon (in_account_number, in_outlet_location, v_uyelik_durum, v_uydu_tipi, v_t_uye_eklenecek_servisler, in_kullanici, o_durum);
         WHEN 3 THEN -- Bundle üyede paket değişikliği
            int_mevcut_uye_paket (in_account_number, in_outlet_location, v_uyelik_durum, v_uydu_tipi, v_t_uye_eklenecek_servisler, in_kullanici, o_durum);
         ELSE
            o_durum := 'Hatalı işlem tipi gönderildi.';
            RETURN;
      END CASE;

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      int_uye_servis_ekle (in_account_number,
                           in_outlet_location,
                           v_uyelik_durum,
                           v_t_uye_eklenecek_servisler,
                           in_kullanici,
                           o_durum,
                           in_tum_isemirlerini_iptal
                          );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE sol_ittp_eof_operations (in_account_number      IN     NUMBER,
                                      in_outlet_location     IN     CHAR,
                                      in_internet_basvuru_id IN     NUMBER,
                                      in_kullanici           IN     VARCHAR2,
                                      o_durum                   OUT VARCHAR2
                                     ) IS
      v_count         NUMBER;
      v_sonraki_statu NUMBER;
      v_error_type    NUMBER;
      v_error_code    VARCHAR2 (10);
      v_promo_code    VARCHAR2 (512);
   BEGIN
      SELECT bs.int_promo_code
        INTO v_promo_code
        FROM dbs_dba.dt_internet_uye_basvuru bs
       WHERE bs.application_id = in_internet_basvuru_id;

      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.mb_abone_ozellik oz
       WHERE oz.account_number = in_account_number AND oz.outlet_location = in_outlet_location AND oz.abone_ozellik_kodu = 424;

      IF v_count > 0 THEN
         abone_detay_pack.mb_abone_ozellik_delete (in_account_number, in_outlet_location, 424, in_kullanici, o_durum);

         IF o_durum != '0' THEN
            o_durum := 'Üye denemesi bedava özeliği silinmedi. Hata : ' || o_durum;
            RETURN;
         END IF;
      END IF;

      sol_uyelik_iliskisi_olustur (in_account_number, in_outlet_location, in_internet_basvuru_id, 'A', in_kullanici, o_durum);

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      wf_islem_pack.wf_sonraki_statuye_gec (3,
                                            in_account_number,
                                            in_outlet_location,
                                            NULL,
                                            SYSDATE,
                                            5,
                                            'SYSSOL',
                                            v_sonraki_statu,
                                            o_durum,
                                            in_internet_basvuru_id
                                           );

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      dbs_dba.sf_pack.sf_sifre_kullanildi (v_promo_code,
                                           in_account_number,
                                           in_outlet_location,
                                           NULL,
                                           2,
                                           'C',
                                           in_kullanici,
                                           'DBS',
                                           v_error_type,
                                           v_error_code,
                                           o_durum
                                          );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE sol_transaction_update (in_id IN NUMBER, in_status IN VARCHAR2, in_error_detail IN VARCHAR2, in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
   BEGIN
      o_durum := '0';

      UPDATE dt_sol_sales_info
         SET status = in_status, error_detail = in_error_detail, degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
       WHERE id = in_id;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_transaction_update :' || SQLERRM;
   END;

   PROCEDURE sol_find_set_promocode (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
   BEGIN
      o_durum := '0';

      FOR rec_sol_sales_info IN (SELECT sales.id, pro.promo_code, pro.id AS pro_id
                                   FROM dt_sol_sales_info sales,
                                        dt_sol_sales_promocode pro
                                  WHERE sales.contract_detail_main_code = pro.contract_detail_main_code AND pro.status = 'O') LOOP
         UPDATE dt_sol_sales_info
            SET promo_code = UPPER (rec_sol_sales_info.promo_code), degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
          WHERE id = rec_sol_sales_info.id;
      /*UPDATE dt_sol_sales_promocode
         SET status = 'C', degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
       WHERE id = rec_sol_sales_info.pro_id;*/
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.find_set_promocode :' || SQLERRM;
   END;

   PROCEDURE sol_stby_set_subscriber_info (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
   BEGIN
      o_durum := '0';

      FOR rec_sol_stby_info IN (SELECT stby.id, pro.promo_code, bas.application_id, bas.account_number, bas.outlet_location
                                  FROM dt_sol_activation_standby stby,
                                       dt_sol_sales_promocode pro,
                                       dt_internet_uye_basvuru bas
                                 WHERE stby.contract_detail_main_code = pro.contract_detail_main_code AND pro.promo_code = bas.int_promo_code) LOOP
         UPDATE dt_sol_activation_standby
            SET account_number       = rec_sol_stby_info.account_number,
                outlet_location      = rec_sol_stby_info.outlet_location,
                application_id       = rec_sol_stby_info.application_id,
                promo_code           = UPPER (rec_sol_stby_info.promo_code),
                degistirme_tarihi    = SYSDATE,
                degistiren_kullanici = in_kullanici
          WHERE id = rec_sol_stby_info.id;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_stby_set_subscriber_info :' || SQLERRM;
   END;

   PROCEDURE sol_susbcriber_info_update (in_application_id  IN     dt_internet_uye_basvuru.application_id%TYPE,
                                         in_account_number  IN     dt_internet_uye_basvuru.account_number%TYPE,
                                         in_outlet_location IN     dt_internet_uye_basvuru.outlet_location%TYPE,
                                         in_full_name       IN     dt_sol_sales_info.customer_name%TYPE,
                                         in_int_tckn        IN     dt_internet_uye_basvuru.int_tckn%TYPE,
                                         in_int_country     IN     dt_internet_uye_basvuru.int_country%TYPE,
                                         in_int_city        IN     dt_internet_uye_basvuru.int_city%TYPE,
                                         in_promo_code      IN     dt_internet_uye_basvuru.int_promo_code%TYPE,
                                         in_kullanici       IN     VARCHAR2,
                                         o_durum               OUT VARCHAR2
                                        ) IS
      v_tckn         dt_internet_uye_basvuru.int_tckn%TYPE;
      v_first_name   dt_internet_uye_basvuru.int_first_name%TYPE;
      v_last_name    dt_internet_uye_basvuru.int_last_name%TYPE;
      v_guncel_statu NUMBER;
      v_tckn_durum   NUMBER;
   BEGIN
      o_durum := '0';

      BEGIN
         SELECT det.tc_kimlik_no
           INTO v_tckn
           FROM dbs_dba.mb_abone_detay_bilgi det
          WHERE det.account_number = in_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_tckn := NULL;
      END;

      IF in_full_name IS NOT NULL THEN
         SELECT SUBSTR (TRIM (in_full_name), 1, INSTR (TRIM (in_full_name), ' ', -1, 1) - 1) INTO v_first_name FROM DUAL;

         SELECT SUBSTR (TRIM (in_full_name), INSTR (TRIM (in_full_name), ' ', -1, 1) + 1) INTO v_last_name FROM DUAL;
      END IF;

      UPDATE dt_internet_uye_basvuru
         SET int_first_name       = v_first_name,
             int_last_name        = v_last_name,
             int_tckn             = in_int_tckn,
             int_country          = in_int_country,
             int_city             = in_int_city,
             degistiren_kullanici = in_kullanici,
             degistirme_tarihi    = SYSDATE
       WHERE account_number = in_account_number AND int_promo_code = in_promo_code;

      IF v_tckn <> in_int_tckn THEN
         --Üye burada farkli bir statüye çekilecek
         wf_islem_pack.wf_guncel_statusunu_getir (3, --i_wf_tip              IN     NUMBER,
                                                    in_account_number, in_outlet_location, NULL, -- i_potansiyel_number   IN     NUMBER,
                                                                                                v_guncel_statu, o_durum, in_application_id);

         IF o_durum <> '0' THEN
            RETURN;
         END IF;

         IF v_guncel_statu NOT IN (3, 4, 9, 10, 11) THEN
            o_durum := 'Üyenin statüsü bu işlem için uygun değildir.';
            RETURN;
         END IF;

         IF v_guncel_statu NOT IN (10) THEN
            dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (3, -- i_wf_tip
                                                             in_account_number,
                                                             in_outlet_location,
                                                             NULL, -- i_potansiyel_number   IN     NUMBER,
                                                             SYSDATE, -- i_valid_after         IN     DATE,
                                                             10, --i_yeni_statu          IN     NUMBER,
                                                             in_kullanici,
                                                             o_durum,
                                                             in_application_id
                                                            );
         END IF;

         IF o_durum = '0' THEN
            SELECT tckn_durum
              INTO v_tckn_durum
              FROM dbs_dba.dt_internet_uye_basvuru
             WHERE application_id = in_application_id;

            IF NVL (v_tckn_durum, -1) <> 1 THEN
               o_durum := 'VLD9999';
            END IF;
         END IF;

         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_susbcriber_info_update' || SQLERRM;
   END;

   --MODEM ISLEMLERI
   PROCEDURE sol_modem_info_update (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_result_type    NUMBER;
      v_result_code    VARCHAR2 (10);
      v_result_message VARCHAR2 (1000);
      v_status         VARCHAR2 (32);
      v_error_detail   VARCHAR2 (512);
      o_guncel_statu   NUMBER;
   BEGIN
      o_durum := '0'; -- falamur 04012014

      FOR rec_sol_modem_info
         IN (SELECT DISTINCT
                    c.account_number,
                    c.application_id,
                    c.assigned_to,
                    c.bayi_kodu,
                    c.connection_type,
                    c.current_provider,
                    c.description,
                    c.int_birthdate,
                    c.int_city,
                    c.int_connection_date,
                    c.int_country,
                    c.int_county,
                    c.int_turk_account_void,
                    c.int_district,
                    c.int_first_name,
                    c.int_home_area_code,
                    c.int_home_country_code,
                    c.int_home_extension,
                    c.int_home_number,
                    c.int_last_name,
                    c.int_mobile_area_code,
                    c.int_mobile_country_code,
                    c.int_mobile_number,
                    c.int_modem_seri_no,
                    c.int_promo_code,
                    c.int_reason_code,
                    c.int_status,
                    c.int_status_date,
                    c.int_tckn,
                    c.int_wf_tip,
                    c.int_work_area_code,
                    c.int_work_country_code,
                    c.int_work_extension,
                    c.int_work_number,
                    c.modem_seri_no,
                    c.outlet_location,
                    c.prospect_number,
                    c.provider,
                    c.source,
                    c.status,
                    c.uydu_tipi,
                    b.associated_service_serial_no,
                    b.contract_code,
                    b.contract_detail_code,
                    b.contract_detail_main_code,
                    b.id AS modem_id,
                    c.tckn_durum,
                    c.taahhut_durum
               FROM dt_sol_sales_info a,
                    dbs_dba.dt_sol_active_modem_info b,
                    dt_internet_uye_basvuru c
              WHERE     a.contract_detail_main_code = b.contract_detail_main_code
                    AND a.promo_code = c.int_promo_code
                    AND a.report_type = 'AKTIF' --AND a.service_status = 'Aktif'
                    AND b.status = 'O' -- falamur
                                      ) LOOP
         dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (3,
                                                          rec_sol_modem_info.account_number,
                                                          rec_sol_modem_info.outlet_location,
                                                          NULL,
                                                          o_guncel_statu,
                                                          v_result_message,
                                                          rec_sol_modem_info.application_id
                                                         );

         IF v_result_message = '0' THEN
            internet_basvuru_pack.basvuru_insert_update (in_out_application_id      => rec_sol_modem_info.application_id,
                                                         in_account_number          => rec_sol_modem_info.account_number,
                                                         in_outlet_location         => rec_sol_modem_info.outlet_location,
                                                         in_prospect_number         => NULL,
                                                         in_uydu_tipi               => rec_sol_modem_info.uydu_tipi,
                                                         in_provider                => rec_sol_modem_info.provider, --superonline
                                                         in_status                  => o_guncel_statu,
                                                         in_connection_type         => rec_sol_modem_info.connection_type,
                                                         in_bayi_kodu               => rec_sol_modem_info.bayi_kodu,
                                                         in_assigned_to             => rec_sol_modem_info.assigned_to,
                                                         in_description             => rec_sol_modem_info.description,
                                                         in_modem_seri_no           => rec_sol_modem_info.modem_seri_no,
                                                         in_int_first_name          => rec_sol_modem_info.int_first_name,
                                                         in_int_last_name           => rec_sol_modem_info.int_last_name,
                                                         in_int_tckn                => rec_sol_modem_info.int_tckn,
                                                         in_int_birthdate           => rec_sol_modem_info.int_birthdate,
                                                         in_int_country             => rec_sol_modem_info.int_country,
                                                         in_int_city                => rec_sol_modem_info.int_city,
                                                         in_int_county              => rec_sol_modem_info.int_county,
                                                         in_int_district            => rec_sol_modem_info.int_district,
                                                         in_int_mobile_country_code => rec_sol_modem_info.int_mobile_country_code,
                                                         in_int_mobile_area_code    => rec_sol_modem_info.int_mobile_area_code,
                                                         in_int_mobile_number       => rec_sol_modem_info.int_mobile_number,
                                                         in_int_home_country_code   => rec_sol_modem_info.int_home_country_code,
                                                         in_int_home_area_code      => rec_sol_modem_info.int_home_area_code,
                                                         in_int_home_number         => rec_sol_modem_info.int_home_number,
                                                         in_int_home_extension      => rec_sol_modem_info.int_home_extension,
                                                         in_int_work_country_code   => rec_sol_modem_info.int_work_country_code,
                                                         in_int_work_area_code      => rec_sol_modem_info.int_work_area_code,
                                                         in_int_work_number         => rec_sol_modem_info.int_work_number,
                                                         in_int_work_extension      => rec_sol_modem_info.int_work_extension,
                                                         in_int_modem_seri_no       => rec_sol_modem_info.associated_service_serial_no, --sol den gelen modem seri no
                                                         in_out_int_promo_code      => rec_sol_modem_info.int_promo_code,
                                                         in_int_status              => rec_sol_modem_info.int_status,
                                                         in_int_status_date         => rec_sol_modem_info.int_status_date,
                                                         in_int_reason_code         => rec_sol_modem_info.int_reason_code,
                                                         in_kullanici               => in_kullanici,
                                                         in_source                  => 'SOL',
                                                         in_int_connection_date     => rec_sol_modem_info.int_connection_date,
                                                         in_int_wf_tip              => rec_sol_modem_info.int_wf_tip, --work flow tipi=1 -> TTN den gelen basvuru
                                                         in_current_provider        => rec_sol_modem_info.current_provider, --üyenin şuan kullandığı internet
                                                         in_turk_account_void   => rec_sol_modem_info.int_turk_account_void,
                                                         in_tckn_durum              => rec_sol_modem_info.tckn_durum,
                                                         in_taahhut_durum           => rec_sol_modem_info.taahhut_durum,
                                                         o_result_type              => v_result_type,
                                                         o_result_code              => v_result_code,
                                                         o_result_message           => v_result_message
                                                        );
         END IF;

         IF v_result_type = '0' THEN -- falamur 04012014
            v_status       := 'C';
            v_error_detail := 'SUCCESS';
         ELSE
            v_status       := 'E';
            v_error_detail := v_result_message;
            ROLLBACK; -- falamur 04012014
         END IF;

         -- Falamur ekleme
         UPDATE dbs_dba.dt_sol_active_modem_info
            SET status = v_status, error_detail = v_error_detail, degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
          WHERE id = rec_sol_modem_info.modem_id;

         COMMIT; -- falamur 04012014
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_modem_info_update' || SQLERRM;
   END;

   --Sol Paket Hareketlerini Yönetir
   PROCEDURE sol_package_trans_control (in_transaction_type  IN     VARCHAR2,
                                        in_product_name      IN     dbs_dba.dt_sol_sales_info.product_name%TYPE,
                                        in_application_id    IN     dbs_dba.dt_internet_uye_basvuru.application_id%TYPE,
                                        in_account_number    IN     dbs_dba.wiz_customer_hp_svc_int.account_number%TYPE,
                                        in_service_code      IN     dbs_dba.wiz_customer_hp_svc_int.service_code%TYPE,
                                        in_outlet_location   IN     dbs_dba.wiz_customer_hp_svc_int.outlet_location%TYPE,
                                        in_sales_code        IN     dbs_dba.wiz_customer_hp_svc_int.sales_code%TYPE,
                                        in_salesperson       IN     dbs_dba.wiz_customer_hp_svc_int.salesperson%TYPE,
                                        in_promo_expire_date IN     dbs_dba.wiz_customer_hp_svc_int.promo_expire_date%TYPE,
                                        in_add_closed_date   IN     dbs_dba.wiz_customer_hp_svc_int.add_closed_date%TYPE,
                                        in_servis_frekansi   IN     dbs_dba.wiz_customer_hp_svc_int.servis_frekansi%TYPE,
                                        in_servis_fiyati     IN     dbs_dba.wiz_customer_hp_svc_int.servis_fiyati%TYPE,
                                        in_provider          IN     dbs_dba.wiz_customer_hp_svc_int.provider%TYPE,
                                        in_promo_code        IN     dbs_dba.wiz_customer_hp_svc_int.promo_code%TYPE,
                                        in_drop_closed_date  IN     dbs_dba.wiz_customer_hp_svc_int_log.drop_closed_date%TYPE,
                                        in_out_hp_svc_int_id IN OUT dbs_dba.wiz_customer_hp_svc_int.id%TYPE,
                                        in_full_name         IN     dt_sol_sales_info.customer_name%TYPE,
                                        in_tckn              IN     dt_internet_uye_basvuru.int_tckn%TYPE,
                                        in_country           IN     dt_internet_uye_basvuru.int_country%TYPE DEFAULT 'TÜRKİYE',
                                        in_city              IN     dt_internet_uye_basvuru.int_city%TYPE,
                                        in_kullanici         IN     VARCHAR2,
                                        o_durum                 OUT VARCHAR2,
                                        o_status                OUT VARCHAR2
                                       ) IS
      v_hp_svc_int_id NUMBER := in_out_hp_svc_int_id;
      v_count         NUMBER;
      v_guncel_statu  NUMBER;
   BEGIN
      o_status := 'C';
      o_durum  := '0';

      BEGIN
         --Bu uyeye ait daha önce kayıt varmı kontrolü yapilir
         SELECT svc.id
           INTO v_hp_svc_int_id
           FROM wiz_customer_hp_svc_int svc
          WHERE svc.account_number = in_account_number AND svc.outlet_location = in_outlet_location AND svc.service_code = in_service_code;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            v_hp_svc_int_id := NULL;
      END;

      CASE in_transaction_type
         WHEN 'DROP' THEN
            IF v_hp_svc_int_id IS NOT NULL THEN
               dbs_dba.internet_basvuru_pack.del_wiz_customer_hp_svc_int (v_hp_svc_int_id, --in_hp_svc_int_id
                                                                          SYSDATE, --in_drop_date
                                                                          'DZM', --in_drop_code
                                                                          in_add_closed_date,
                                                                          in_drop_closed_date,
                                                                          in_kullanici, --in_kapatan_kullanici
                                                                          in_kullanici, --in_degistiren_kullanici
                                                                          SYSDATE, --in_degistirme_tarihi
                                                                          in_salesperson, --in_dusurme_talebi_alan_kull033
                                                                          in_kullanici, --in_dusuren_kullanici
                                                                          SYSDATE, --in_dusurme_tarihi
                                                                          o_durum
                                                                         );

               IF o_durum != '0' THEN
                  o_status := 'E';
                  RETURN;
               END IF;
            ELSE
               BEGIN
                  --Bu uyeye ait daha önce kayıt varmı kontrolü yapilir
                  SELECT COUNT (1)
                    INTO v_count
                    FROM wiz_customer_hp_svc_int_log svc
                   WHERE     svc.account_number = in_account_number
                         AND svc.outlet_location = in_outlet_location
                         AND svc.service_code = in_service_code
                         AND svc.drop_closed_date = in_drop_closed_date;

                  IF v_count > 0 THEN
                     o_status := 'I';
                     o_durum  := 'Ayni kayit daha önce isleme alinmis.';
                     RETURN;
                  ELSE
                     o_status := 'E';
                     o_durum  := 'Hata! Ekleme satırı bulunamayan kaydın iptali.';
                     RETURN;
                  --                     dbs_dba.internet_basvuru_pack.ins_upd_wiz_cus_hp_svc_int (in_account_number,
                  --                                                                               in_service_code,
                  --                                                                               in_outlet_location,
                  --                                                                               'DZM', --in_sales_code
                  --                                                                               in_salesperson,
                  --                                                                               in_promo_expire_date,
                  --                                                                               in_add_closed_date,
                  --                                                                               in_servis_frekansi,
                  --                                                                               in_servis_fiyati,
                  --                                                                               in_kullanici,
                  --                                                                               in_provider,
                  --                                                                               in_promo_code,
                  --                                                                               v_hp_svc_int_id, --in_out_hp_svc_int_id,
                  --                                                                               o_durum
                  --                                                                              );
                  --
                  --                     IF o_durum = '0' THEN
                  --                        dbs_dba.internet_basvuru_pack.del_wiz_customer_hp_svc_int (v_hp_svc_int_id, --in_hp_svc_int_id
                  --                                                                                   SYSDATE, --in_drop_date
                  --                                                                                   'DZM', --in_drop_code
                  --                                                                                   in_add_closed_date,
                  --                                                                                   in_drop_closed_date,
                  --                                                                                   in_kullanici, --in_kapatan_kullanici
                  --                                                                                   in_kullanici, --in_degistiren_kullanici
                  --                                                                                   SYSDATE, --in_degistirme_tarihi
                  --                                                                                   in_salesperson, --in_dusurme_talebi_alan_kull033
                  --                                                                                   in_kullanici, --in_dusuren_kullanici
                  --                                                                                   SYSDATE, --in_dusurme_tarihi
                  --                                                                                   o_durum
                  --                                                                                  );
                  --
                  --                        IF o_durum != '0' THEN
                  --                           o_status := 'E';
                  --                           RETURN;
                  --                        END IF;
                  --                     ELSE
                  --                        o_status := 'E';
                  --                        RETURN;
                  --                     END IF;
                  END IF;
               END;
            END IF;
         WHEN 'ADD' THEN
            IF v_hp_svc_int_id IS NOT NULL THEN --uye var ise
               o_status := 'I';
               o_durum  := 'Aynı kayıt daha önce işleme alınmış';
               RETURN;
            END IF;

            sol_susbcriber_info_update (in_application_id,
                                        in_account_number,
                                        in_outlet_location,
                                        in_full_name,
                                        in_tckn,
                                        in_country,
                                        in_city,
                                        in_promo_code,
                                        in_kullanici,
                                        o_durum
                                       );

            IF o_durum <> '0' THEN
               IF o_durum = 'VLD9999' THEN
                  o_status := 'W';
                  o_durum  := 'Superonline ve turk TCKN leri eslesmedi.';
               ELSE
                  o_status := 'E';
               END IF;

               RETURN;
            END IF;

            FOR rec_svc_int
               IN (SELECT svc.id, pro.baglanti_tipi
                     FROM wiz_customer_hp_svc_int svc,
                          wiz_product_codes_int pro
                    WHERE     svc.service_code = pro.dbs_urun_kodu
                          AND svc.account_number = in_account_number
                          AND svc.outlet_location = in_outlet_location
                          AND pro.baglanti_tipi = in_product_name) LOOP
               --Mevcuttaki urun tipi(ADSL,FIBER v.b.) varken yeni gelen ürün tipi ile aynı (ADSL,FIBER) ise eskisi dusurulur yenisi add edilir

               --DROP islemi yapiliyor
               dbs_dba.internet_basvuru_pack.del_wiz_customer_hp_svc_int (rec_svc_int.id, --in_hp_svc_int_id
                                                                          SYSDATE, --in_drop_date
                                                                          'DZM', --in_drop_code
                                                                          in_add_closed_date,
                                                                          in_drop_closed_date,
                                                                          in_kullanici, --in_kapatan_kullanici
                                                                          in_kullanici, --in_degistiren_kullanici
                                                                          SYSDATE, --in_degistirme_tarihi
                                                                          in_salesperson, --in_dusurme_talebi_alan_kull033
                                                                          in_kullanici, --in_dusuren_kullanici
                                                                          SYSDATE, --in_dusurme_tarihi
                                                                          o_durum
                                                                         );
            END LOOP;

            dbs_dba.internet_basvuru_pack.ins_upd_wiz_cus_hp_svc_int (in_account_number,
                                                                      in_service_code,
                                                                      in_outlet_location,
                                                                      'DZM', --in_sales_code
                                                                      in_salesperson,
                                                                      in_promo_expire_date,
                                                                      in_add_closed_date,
                                                                      in_servis_frekansi,
                                                                      in_servis_fiyati,
                                                                      in_kullanici,
                                                                      in_provider,
                                                                      in_promo_code,
                                                                      v_hp_svc_int_id, --in_out_hp_svc_int_id,
                                                                      o_durum
                                                                     );

            IF o_durum != '0' THEN
               o_status := 'E';
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM dbs_dba.wiz_customer_hp_svc_int a,
                   wiz_product_codes_int b
             WHERE     a.account_number = in_account_number
                   AND a.outlet_location = in_outlet_location
                   AND a.service_code = b.dbs_urun_kodu
                   AND b.baglanti_tipi IN ('ADSL', 'FIBER');

            IF v_count > 0 THEN
               dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (3, in_account_number, in_outlet_location, NULL, v_guncel_statu, o_durum, in_application_id);

               IF o_durum != '0' THEN
                  o_status := 'E';
                  RETURN;
               END IF;

               IF v_guncel_statu IN (3, 4, 9, 10, 11) THEN
                  dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (3, -- i_wf_tip
                                                                   in_account_number,
                                                                   in_outlet_location,
                                                                   NULL, -- i_potansiyel_number   IN     NUMBER,
                                                                   SYSDATE, -- i_valid_after         IN     DATE,
                                                                   5, --i_yeni_statu          IN     NUMBER,
                                                                   in_kullanici,
                                                                   o_durum,
                                                                   in_application_id
                                                                  );

                  IF o_durum <> '0' THEN
                     o_status := 'E';
                     o_durum  := 'Servis ekleme adımına geçilemedi : ' || o_durum;
                     RETURN;
                  END IF;
               --                  int_paket_islemleri (in_account_number, in_outlet_location, in_kullanici, 1, o_durum, 'E');
               --
               --                  IF o_durum != '0' THEN
               --                     o_status := 'P';
               --                     RETURN;
               --                  END IF;
               ELSE
                  o_status := 'E';
                  o_durum  := 'Uyenin statusu internet paket islemleri icin uygun degil.';
                  RETURN;
               END IF;
            END IF;
      END CASE;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_package_trans_control' || SQLERRM;
   END;

   --SATIS HAREKETLERI
/* Formatted on 08/01/2015 08:37:50 (QP5 v5.252.13127.32867) */
   PROCEDURE sol_sales_package_transaction (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_hp_svc_int_id    NUMBER;
      v_servis_fiyati    NUMBER;
      v_count            NUMBER;
      v_transaction_type VARCHAR2 (10) := NULL;
      v_status           dbs_dba.dt_sol_sales_info.status%TYPE;
      v_error_detail     dbs_dba.dt_sol_sales_info.error_detail%TYPE;
      v_guncel_statu     NUMBER;
      v_statu_id         NUMBER;
      v_new_status       VARCHAR2 (10);
   BEGIN
      FOR rec_sol_sales_info
         IN (SELECT   sal.*,
                      bas.application_id,
                      bas.account_number,
                      bas.outlet_location,
                      bas.bayi_kodu,
                      bas.connection_type,
                      bas.provider,
                      bas.uydu_tipi,
                      pro.baglanti_tipi,
                      pro.hiz,
                      pro.download_kota,
                      pro.upload_kota,
                      pro.dbs_urun_kodu,
                      pro.aciklama,
                      pro.yeni_uye_fiyat,
                      pro.mevcut_uye_fiyat,
                      pro.paket
                 FROM dbs_dba.dt_sol_sales_info sal,
                      dbs_dba.dt_internet_uye_basvuru bas,
                      dbs_dba.wiz_product_codes_int pro
                WHERE     sal.report_type = 'AKTIF'
                      AND sal.promo_code = bas.int_promo_code(+)
                      AND sal.product_name = pro.baglanti_tipi
                      AND NVL (sal.xsdl_type,'-1') = NVL(pro.xsdl_type,'-1')
                      AND bas.prospect_number IS NULL
                      AND (sal.adsl_fiber_bandwidth = pro.hiz OR sal.adsl_fiber_bandwidth IS NULL)
                      AND (sal.fuq_download = pro.adil_kullanim_kotasi OR sal.fuq_download IS NULL)
                      AND (sal.adsl_fiber_quota = pro.download_kota OR sal.adsl_fiber_quota IS NULL)
                      AND sal.status IN ('O', 'W', 'P')
                      AND NOT EXISTS
                                 (SELECT 1
                                    FROM dbs_dba.dt_sol_campaign_change cch
                                   WHERE     cch.contract_code = sal.contract_code
                                         AND cch.customer_no = sal.customer_no
                                         AND cch.tckn = sal.tckn
                                         AND cch.promo_code = sal.promo_code)
             ORDER BY sal.contract_detail_start_date,
                      sal.contract_detail_code ASC) LOOP
      BEGIN
         IF TRIM (LOWER (rec_sol_sales_info.service_status)) IN ('aktif', 'değiştirilmiş', 'deaktif', 'askıya alınmış') THEN
            IF (TRIM (rec_sol_sales_info.is_campaign_change) = 'Evet' OR TRIM (rec_sol_sales_info.is_speed_quota_change) = 'Evet') --   AND (rec_sol_sales_info.is_transport = 'Hayır' AND rec_sol_sales_info.is_takeover = 'Hayır')
                                                                                                                                  THEN
               v_servis_fiyati    := rec_sol_sales_info.mevcut_uye_fiyat;
               v_transaction_type := 'ADD';
            ELSIF     TRIM (rec_sol_sales_info.is_campaign_change) = 'Hayır'
                  AND TRIM (rec_sol_sales_info.is_speed_quota_change) = 'Hayır'
                  AND TRIM (rec_sol_sales_info.is_transport) = 'Hayır'
                  AND TRIM (rec_sol_sales_info.is_takeover) = 'Hayır' THEN
               v_transaction_type := 'ADD';
               v_servis_fiyati    := rec_sol_sales_info.yeni_uye_fiyat;
            END IF;
         --         ELSIF rec_sol_sales_info.service_status = 'Deaktif' THEN
         --            v_transaction_type := 'DROP';
         ELSE
            NULL;
         END IF;

         v_status       := 'C';
         v_error_detail := 'SUCCESS';

         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_life
          WHERE account_number = rec_sol_sales_info.account_number AND customer_status = 'IN';

         IF v_count > 0 THEN
            IF rec_sol_sales_info.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = rec_sol_sales_info.account_number
                      AND outlet_location = rec_sol_sales_info.outlet_location
                      AND application_id = rec_sol_sales_info.application_id;

               IF v_guncel_statu != 8 THEN
                  wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                           rec_sol_sales_info.account_number,
                                                           rec_sol_sales_info.outlet_location,
                                                           NULL,
                                                           SYSDATE,
                                                           8,
                                                           'SYSSOL',
                                                           o_durum,
                                                           rec_sol_sales_info.application_id
                                                          );
               END IF;

               IF o_durum != '0' THEN
                  v_status       := 'E';
                  v_error_detail := 'In üye için digitürk başvurusu iptal edilemedi.';
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'In üye için internet basvuru bilgisi bulunamadi.';
            END IF;
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.dt_internet_uye_basvuru
          WHERE int_promo_code = rec_sol_sales_info.promo_code;

         IF v_count = 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM dbs_dba.dt_internet_uye_basvuru_log
             WHERE int_promo_code = rec_sol_sales_info.promo_code;

            IF v_count > 0 THEN
               v_status       := 'E';
               v_error_detail := 'Aktif basvuruda promocode degisimi.';
            ELSE
               v_status       := 'E';
               v_error_detail := 'Promocode bilgisi bulunamadi.';
            END IF;
         END IF;

         IF v_status = 'C' THEN
            IF rec_sol_sales_info.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM dbs_dba.wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = rec_sol_sales_info.account_number
                      AND outlet_location = rec_sol_sales_info.outlet_location
                      AND application_id = rec_sol_sales_info.application_id;

               IF v_guncel_statu = 8 THEN
                  v_status       := 'I';
                  v_error_detail := 'turk başvuru iptal - Sol Aktiflendi.';

                  --Statu:13 cekilir
                  UPDATE wf_tb_uye_statu
                     SET statu = 13
                   WHERE id = v_statu_id;
               ELSE
                  SELECT COUNT (1)
                    INTO v_count
                    FROM dbs_dba.mb_outlet_takip mb
                   WHERE     mb.account_number = rec_sol_sales_info.account_number
                         AND mb.outlet_location = rec_sol_sales_info.outlet_location
                         AND mb.outlet_in_tarihi IS NULL;

                  IF v_count = 0 THEN
                     v_status       := 'I';
                     v_error_detail := 'turk üyeliği için başvurulan outlet aktif değildir..';
                  ELSE
                     sol_package_trans_control (v_transaction_type,
                                                rec_sol_sales_info.product_name,
                                                rec_sol_sales_info.application_id,
                                                rec_sol_sales_info.account_number,
                                                rec_sol_sales_info.dbs_urun_kodu,
                                                rec_sol_sales_info.outlet_location,
                                                rec_sol_sales_info.bayi_kodu,
                                                NULL, --rec_sol_sales_info.contract_detail_sales_person,
                                                rec_sol_sales_info.contract_commitment_end_date, --in_promo_expire_date
                                                rec_sol_sales_info.contract_detail_start_date, --in_add_closed_date
                                                1, --rec_sol_sales_info.contract_commitment_period, --in_servis_frekansi
                                                v_servis_fiyati, --in_servis_fiyati
                                                2, --rec_sol_sales_info.provider,
                                                rec_sol_sales_info.promo_code,
                                                rec_sol_sales_info.contract_detail_end_date, --in_drop_closed_date
                                                v_hp_svc_int_id,
                                                rec_sol_sales_info.customer_name, -- in_full_name
                                                rec_sol_sales_info.tckn, -- int_tckn
                                                'TÜRKİYE', --in_country
                                                rec_sol_sales_info.service_address_city_name, --int_city
                                                in_kullanici,
                                                o_durum,
                                                v_new_status
                                               );

                     IF o_durum != '0' THEN
                        v_status       := v_new_status;
                        v_error_detail := o_durum;
                     ELSE
                        v_status       := 'C';
                        v_error_detail := 'SUCCESS';
                     END IF;
                  END IF;
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'Aktif uye icin internet basvuru bilgisi bulunamadi.';
            END IF;
         END IF;

         IF v_status IN ('P', 'E', 'I') THEN -- Servis işlemlerinden hata alıyorsa  veya error oluşmuşsa, rollback et. diğer türlü commit atılacak.
            ROLLBACK;
         END IF;

         sol_transaction_update (rec_sol_sales_info.id, v_status, --error
                                                                 v_error_detail, in_kullanici, o_durum);

         IF v_status IN ('C', 'I') THEN
            UPDATE dt_sol_sales_info
               SET status = v_status, error_detail = v_error_detail, degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
             WHERE id IN (SELECT b.id
                            FROM dt_sol_sales_info b
                           WHERE     b.promo_code = rec_sol_sales_info.promo_code
                                 AND b.report_type = 'SATIS'
                                 AND b.status = 'O'
                                 AND b.contract_code = rec_sol_sales_info.contract_code
                                 AND b.contract_detail_code = rec_sol_sales_info.contract_detail_code
                                 AND rec_sol_sales_info.product_name = b.product_name
                                 AND NVL (b.adsl_fiber_bandwidth, '-1') = NVL (rec_sol_sales_info.adsl_fiber_bandwidth, '-1')
                                 AND NVL (b.fuq_download, '-1') = NVL (rec_sol_sales_info.fuq_download, '-1')
                                 AND NVL (b.adsl_fiber_quota, '-1') = NVL (rec_sol_sales_info.adsl_fiber_quota, '-1'));
         END IF;

         COMMIT;
         EXCEPTION WHEN OTHERS THEN
         ROLLBACK;
           CONTINUE;

           END;
      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_sales_package_transaction' || SQLERRM;
   END;
   --NAKIL ISLEMLERI
   PROCEDURE sol_transport_transaction (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
   BEGIN
      FOR rec_sol_transport_info IN (SELECT *
                                       FROM dt_sol_sales_info
                                      WHERE report_type = 'SATIS' AND is_transport = 'Evet') LOOP
         /*IF THEN
         END IF;*/
         NULL;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_transport_transaction' || SQLERRM;
   END;

   --DEVIR  ISLEMLERI

   PROCEDURE sol_takeover_transaction (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
   BEGIN
      FOR rec_sol_devir_info IN (SELECT *
                                   FROM dt_sol_sales_info
                                  WHERE report_type = 'SATIS' AND is_takeover = 'Evet') LOOP
         /*IF THEN
         END IF;*/
         NULL;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_takeover_transaction' || SQLERRM;
   END;

   PROCEDURE sol_batch_data_transaction IS
      in_kullanici VARCHAR2 (10) := 'SYSSOL';
      o_durum      VARCHAR2 (4000);
   BEGIN
      o_durum := 'SUCCESS';
      --sol_find_set_promocode (in_kullanici, o_durum);
      --DBMS_OUTPUT.put_line ('sol_find_set_promocode: ERROR =' || o_durum);

      --sol_modem_info_update (in_kullanici, o_durum);
      --DBMS_OUTPUT.put_line ('sol_modem_info_update: ERROR =' || o_durum);

      sol_sales_package_transaction (in_kullanici, o_durum);
      DBMS_OUTPUT.put_line ('sol_sales_package_transaction: ERROR =' || o_durum);

      sol_stby_set_subscriber_info (in_kullanici, o_durum);
      DBMS_OUTPUT.put_line ('sol_stby_set_subscriber_info: ERROR =' || o_durum);

      sol_statu_degistir (in_kullanici, o_durum);
      DBMS_OUTPUT.put_line ('sol_statu_degistir: ERROR =' || o_durum);

      sol_uyelik_iptal (in_kullanici, o_durum);
      DBMS_OUTPUT.put_line ('sol_uyelik_iptal: ERROR =' || o_durum);

      sol_campaign_change_activation (in_kullanici, o_durum);
      DBMS_OUTPUT.put_line ('sol_campaign_change_activation: ERROR =' || o_durum);

      sol_campaign_change_deactivate (in_kullanici, o_durum);
      DBMS_OUTPUT.put_line ('sol_campaign_change_deactivate: ERROR =' || o_durum);
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_batch_data_transaction' || SQLERRM;
         DBMS_OUTPUT.put_line ('sol_batch_data_transaction: ERROR =' || o_durum);
   END;

   PROCEDURE sol_uyelik_iptal (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      o_guncel_statu        NUMBER;
      v_iliski_id           NUMBER;
      v_statu               VARCHAR2 (10);
      o_error_code          VARCHAR2 (512);
      v_iptal_reason        VARCHAR2 (512);
      v_hp_svc_int_id       NUMBER;
      v_status              dbs_dba.dt_sol_sales_info.status%TYPE;
      v_error_detail        dbs_dba.dt_sol_sales_info.error_detail%TYPE;
      v_count               NUMBER;
      v_active_count        NUMBER;
      v_error_active_status BOOLEAN := FALSE;
      v_guncel_statu        NUMBER;
      v_statu_id            NUMBER;
      v_new_status          VARCHAR2 (10);
   BEGIN
      FOR iptal_rec
         IN (SELECT b.application_id basvuru_id,
                    a.id AS sales_info_id,
                    a.promo_code,
                    a.tckn,
                    a.customer_name,
                    a.service_address_city_name,
                    a.contract_commitment_end_date,
                    a.contract_detail_start_date,
                    a.contract_detail_end_date,
                    b.bayi_kodu,
                    b.application_id,
                    b.account_number,
                    b.outlet_location,
                    a.cancel_reason,
                    a.cancel_reason_detail,
                    a.product_name,
                    pro.dbs_urun_kodu,
                    pro.mevcut_uye_fiyat,
                    a.adsl_fiber_quota,
                    a.fuq_download,
                    a.adsl_fiber_bandwidth,
                    a.contract_detail_code,
                    a.contract_detail_main_code,
                    a.contract_code,
                    b.provider
               FROM dbs_dba.dt_sol_sales_info a,
                    dbs_dba.dt_internet_uye_basvuru b,
                    dbs_dba.wiz_product_codes_int pro
              WHERE     a.report_type = 'IPTAL'
                    --AND a.service_status = 'Deaktif'
                    AND a.status = 'O' -- IN ('O', 'W', 'S')
                    AND a.promo_code = b.int_promo_code(+)
                    AND a.product_name = pro.baglanti_tipi
                    AND NVL (a.xsdl_type,'-1') = NVL(pro.xsdl_type,'-1')
                    AND (a.adsl_fiber_bandwidth = pro.hiz OR a.adsl_fiber_bandwidth IS NULL)
                    AND (a.fuq_download = pro.adil_kullanim_kotasi OR a.fuq_download IS NULL)
                    AND (a.adsl_fiber_quota = pro.download_kota OR a.adsl_fiber_quota IS NULL)
                    AND NOT EXISTS
                               (SELECT 1
                                  FROM dbs_dba.dt_sol_campaign_change cch
                                 WHERE     cch.contract_code = a.contract_code
                                       AND cch.customer_no = a.customer_no
                                       AND cch.tckn = a.tckn
                                       AND cch.promo_code = a.promo_code
                                       AND EXISTS
                                              (SELECT *
                                                 FROM dbs_dba.dt_sol_sales_info sls
                                                WHERE     sls.report_type = 'AKTIF'
                                                      AND LOWER (sls.service_status) = 'deaktif'
                                                      AND sls.promo_code = a.promo_code
                                                      AND sls.customer_no = a.customer_no
                                                      AND sls.tckn = a.tckn
                                                      AND TRUNC (sls.contract_detail_end_date) = TRUNC (a.contract_detail_end_date)))) LOOP
         BEGIN
         -- Üyenin eğer güncel ilikisi varsa önce onu iptal et.
         o_durum        := '0';
         v_status       := 'C';
         v_error_detail := 'SUCCESS';

         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_life
          WHERE account_number = iptal_rec.account_number AND customer_status = 'IN';

         IF v_count > 0 THEN
            --Basvuru iptal e cekilince
            -- 1-)PromoCode iptal edilir. (Aktif: C->V) (Aktif Olmayan:R->V)
            -- 2-)svc_int deki internet ürünü silinir ve  svc_int_log a atilir
            -- 3-)kisi iliskide ki data iptal e cekilir (A->P)
            -- 4-)statu nun 8 e cekilmis olması gerekir
            IF iptal_rec.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = iptal_rec.account_number
                      AND outlet_location = iptal_rec.outlet_location
                      AND application_id = iptal_rec.application_id;

               IF v_guncel_statu != 8 THEN
                  wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                           iptal_rec.account_number,
                                                           iptal_rec.outlet_location,
                                                           NULL,
                                                           SYSDATE,
                                                           8,
                                                           'SYSSOL',
                                                           o_durum,
                                                           iptal_rec.application_id
                                                          );

                  IF o_durum = '0' THEN
                     sol_basvuru_iptal_islemleri (iptal_rec.application_id,
                                                  iptal_rec.contract_detail_start_date,
                                                  iptal_rec.contract_detail_end_date,
                                                  in_kullanici,
                                                  o_durum,
                                                  v_status
                                                 );

                     IF o_durum != '0' THEN
                        v_status       := 'E';
                        v_error_detail := o_durum;
                     --return edilebilir.
                     END IF;
                  END IF;
               END IF;

               IF o_durum != '0' THEN
                  v_status       := 'E';
                  v_error_detail := 'In üye için digitürk başvurusu iptal edilemedi.';
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'In üye için internet basvuru bilgisi bulunamadi.';
            END IF;
         --TODO:continue yapilabilir.
         END IF;

         IF v_status = 'C' THEN
            SELECT COUNT (1)
              INTO v_active_count
              FROM dbs_dba.dt_sol_sales_info a
             WHERE report_type = 'AKTIF' AND promo_code = iptal_rec.promo_code AND status = 'C';

            SELECT COUNT (1)
              INTO v_count
              FROM dbs_dba.dt_internet_uye_basvuru
             WHERE int_promo_code = iptal_rec.promo_code;

            IF v_count = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM dbs_dba.dt_internet_uye_basvuru_log
                WHERE int_promo_code = iptal_rec.promo_code;

               IF v_count > 0 THEN
                  IF v_active_count > 0 THEN
                     v_status              := 'E';
                     v_error_detail        := 'Aktif basvuruda promocode degisimi.';
                     v_error_active_status := TRUE;
                  ELSE
                     v_status       := 'I';
                     v_error_detail := 'Başvuru İptal Promocode değişti.';
                  END IF;
               ELSE
                  v_status       := 'E';
                  v_error_detail := 'Promocode bilgisi bulunamadi.';
               END IF;
            ELSE
               IF v_active_count = 0 THEN
                  SELECT statu, id
                    INTO v_guncel_statu, v_statu_id
                    FROM wf_tb_uye_statu
                   WHERE     durum IN ('A', 'V')
                         AND statu_tanim_tip = 3
                         AND account_number = iptal_rec.account_number
                         AND outlet_location = iptal_rec.outlet_location
                         AND application_id = iptal_rec.application_id;

                  IF v_guncel_statu != 8 THEN
                     wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                              iptal_rec.account_number,
                                                              iptal_rec.outlet_location,
                                                              NULL,
                                                              SYSDATE,
                                                              6,
                                                              'SYSSOL',
                                                              o_durum,
                                                              iptal_rec.application_id
                                                             );

                     IF o_durum != '0' THEN
                        v_status       := 'E';
                        v_error_detail := 'Sol iptale çekilemedi : .' || o_durum;
                     END IF;
                  END IF;
               END IF;
            END IF;

            IF iptal_rec.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = iptal_rec.account_number
                      AND outlet_location = iptal_rec.outlet_location
                      AND application_id = iptal_rec.application_id;

               IF v_guncel_statu = 8 THEN
                  v_status       := 'I';
                  v_error_detail := 'Digitürk başvurusu iptal durumda.';
               ELSE
                  IF v_active_count > 0 AND v_error_active_status = FALSE THEN
                     --bu üye satış aktif iptal kayitlarinda yer alıyor
                     IF iptal_rec.product_name IN ('ADSL', 'FIBER') THEN
                        BEGIN
                           v_iptal_reason := iptal_rec.cancel_reason || ' - ' || iptal_rec.cancel_reason_detail;

                           SELECT ils.iliski_id, status
                             INTO v_iliski_id, v_statu
                             FROM dbs_dba.gl_kisi_bilgi_iliski ils,
                                  dbs_dba.gl_iliski_detay dty
                            WHERE ils.sol_id = iptal_rec.basvuru_id AND ils.iliski_id = dty.iliski_id;

                           IF v_statu = 'A' THEN
                              sol_uyelik_iliskisi_olustur (iptal_rec.account_number,
                                                           iptal_rec.outlet_location,
                                                           iptal_rec.basvuru_id,
                                                           'P',
                                                           in_kullanici,
                                                           o_durum
                                                          );

                              IF o_durum != '0' THEN
                                 v_status       := 'E';
                                 v_error_detail := 'Sol internet ilişkisi iptal edilemedi. : ' || o_durum;
                              END IF;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_status = 'C' THEN
                           sol_call_back (iptal_rec.promo_code, 'ERR9999', v_iptal_reason, SYSDATE, o_error_code, o_durum);

                           IF o_durum != '0' THEN
                              v_status       := o_error_code;
                              v_error_detail := o_durum;
                           END IF;
                        END IF;
                     END IF;

                     IF o_durum = '0' AND v_status = 'C' THEN
                        sol_package_trans_control ('DROP',
                                                   iptal_rec.product_name,
                                                   iptal_rec.application_id,
                                                   iptal_rec.account_number,
                                                   iptal_rec.dbs_urun_kodu,
                                                   iptal_rec.outlet_location,
                                                   iptal_rec.bayi_kodu,
                                                   NULL, --rec_sol_sales_info.contract_detail_sales_person,
                                                   iptal_rec.contract_commitment_end_date, --in_promo_expire_date
                                                   iptal_rec.contract_detail_start_date, --in_add_closed_date
                                                   1, --rec_sol_sales_info.contract_commitment_period, --in_servis_frekansi
                                                   iptal_rec.mevcut_uye_fiyat, --in_servis_fiyati
                                                   iptal_rec.provider,
                                                   iptal_rec.promo_code,
                                                   iptal_rec.contract_detail_end_date, --in_drop_closed_date
                                                   v_hp_svc_int_id,
                                                   iptal_rec.customer_name, -- in_full_name
                                                   iptal_rec.tckn, -- int_tckn
                                                   'TÜRKİYE', --in_country
                                                   iptal_rec.service_address_city_name, --int_city
                                                   in_kullanici,
                                                   o_durum,
                                                   v_new_status
                                                  );

                        IF o_durum != '0' THEN
                           v_status       := v_new_status;
                           v_error_detail := o_durum;
                        ELSE
                           v_status       := 'C';
                           v_error_detail := 'SUCCESS';
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'İptal edilen kayit icin internet basvuru bilgisi bulunamadi.';
            END IF;
         END IF;

         IF v_status IN ('C', 'I') THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;

         UPDATE dbs_dba.dt_sol_sales_info
            SET status = v_status, error_detail = v_error_detail, degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
          WHERE id = iptal_rec.sales_info_id;

         IF v_status IN ('C', 'I') THEN
            UPDATE dt_sol_sales_info
               SET status = v_status, error_detail = v_error_detail, degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
             WHERE id IN (SELECT b.id
                            FROM dt_sol_sales_info b
                           WHERE     b.promo_code = iptal_rec.promo_code
                                 AND b.report_type = 'SATIS'
                                 AND b.status = 'O'
                                 AND b.contract_code = iptal_rec.contract_code
                                 AND b.contract_detail_code = iptal_rec.contract_detail_code
                                 AND iptal_rec.product_name = b.product_name
                                 AND NVL (b.adsl_fiber_bandwidth, '-1') = NVL (iptal_rec.adsl_fiber_bandwidth, '-1')
                                 AND NVL (b.fuq_download, '-1') = NVL (iptal_rec.fuq_download, '-1')
                                 AND NVL (b.adsl_fiber_quota, '-1') = NVL (iptal_rec.adsl_fiber_quota, '-1'));
         END IF;

         -- Aktif de çalışmayı bekleyen kayıtları varsa çalışmaması için I statüsüne çekiliyor.
         IF v_status IN ('C') THEN
            UPDATE dt_sol_sales_info
               SET status               = 'I',
                   error_detail         = 'Sol Başvurusu iptal olduğu için kayıt işleme alınmayacak. ',
                   degistiren_kullanici = in_kullanici,
                   degistirme_tarihi    = SYSDATE
             WHERE id IN (SELECT b.id
                            FROM dt_sol_sales_info b
                           WHERE     b.promo_code = iptal_rec.promo_code
                                 AND b.report_type = 'AKTIF'
                                 AND b.status IN ('O', 'W', 'P')
                                 AND b.contract_code = iptal_rec.contract_code
                                 AND b.contract_detail_code = iptal_rec.contract_detail_code
                                 AND iptal_rec.product_name = b.product_name
                                 AND NVL (b.adsl_fiber_bandwidth, '-1') = NVL (iptal_rec.adsl_fiber_bandwidth, '-1')
                                 AND NVL (b.fuq_download, '-1') = NVL (iptal_rec.fuq_download, '-1')
                                 AND NVL (b.adsl_fiber_quota, '-1') = NVL (iptal_rec.adsl_fiber_quota, '-1'));
         END IF;

         COMMIT;

          EXCEPTION WHEN OTHERS THEN
         ROLLBACK;
           CONTINUE;

           END;
      END LOOP;
       EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_package_trans_control' || SQLERRM;
   END;

   PROCEDURE sol_statu_degistir (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_count NUMBER;
   BEGIN
      FOR rec_sol_statu_info IN (SELECT bsv.application_id, bsv.account_number, bsv.outlet_location, bsv.int_promo_code, wf.statu AS guncel_statu
                                   FROM dbs_dba.wf_tb_uye_statu wf,
                                        dbs_dba.dt_internet_uye_basvuru bsv
                                  WHERE wf.application_id = bsv.application_id AND wf.statu IN (3, 4) AND wf.durum = 'A') LOOP
         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.dt_sol_sales_info
          WHERE report_type = 'SATIS' AND promo_code IS NOT NULL AND promo_code = rec_sol_statu_info.int_promo_code;

         IF v_count > 0 THEN
            wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                     rec_sol_statu_info.account_number,
                                                     rec_sol_statu_info.outlet_location,
                                                     NULL,
                                                     SYSDATE,
                                                     11,
                                                     'SYSSOL',
                                                     o_durum,
                                                     rec_sol_statu_info.application_id
                                                    );

            IF o_durum <> '0' THEN
               --DBMS_OUTPUT.put_line ('o_durum=' || o_durum);
               ROLLBACK;
            ELSE
               COMMIT;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_statu_degistir' || SQLERRM;
   END;

   PROCEDURE sol_basvuru_iptal_islemleri (in_application_id   IN     dbs_dba.dt_internet_uye_basvuru.application_id%TYPE,
                                          in_add_closed_date  IN     dbs_dba.wiz_customer_hp_svc_int.add_closed_date%TYPE,
                                          in_drop_closed_date IN     dbs_dba.wiz_customer_hp_svc_int_log.drop_closed_date%TYPE,
                                          in_kullanici        IN     VARCHAR2,
                                          o_durum                OUT VARCHAR2,
                                          o_status               OUT VARCHAR2
                                         ) IS
      v_count           NUMBER;
      v_promo_code      VARCHAR2 (32);
      v_sifre_gizli     VARCHAR2 (256);
      v_account_number  NUMBER;
      v_outlet_location VARCHAR2 (3);
      v_seri_no         VARCHAR2 (20);
      v_sifre_durum     VARCHAR2 (10);
      v_lg_sf_urun_id   NUMBER;
      v_hata_kodu       VARCHAR2 (32);
      v_new_status      NUMBER;
      v_status          dbs_dba.dt_sol_sales_info.status%TYPE;
      v_error_detail    dbs_dba.dt_sol_sales_info.error_detail%TYPE;
      v_hp_svc_int_id   NUMBER;
   BEGIN
      o_durum       := '0';

      BEGIN
         SELECT int_promo_code, account_number, outlet_location
           INTO v_promo_code, v_account_number, v_outlet_location
           FROM dbs_dba.dt_internet_uye_basvuru
          WHERE application_id = in_application_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_status := 'E';
            o_durum  := 'Application_id için başvuru kaydı bulunamadı.';
            RETURN;
      END;

      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.dt_internet_uye_basvuru
       WHERE int_promo_code = v_promo_code;

      IF v_count > 1 THEN
         o_status := 'E';
         o_durum  := 'Aynı promo_code birden fazla başvuruda kullanılmış.';
         RETURN;
      END IF;

      v_sifre_gizli := dbs_dba.digipaket_sifre.encrypt (v_promo_code);

      BEGIN
         SELECT seri_no, durum
           INTO v_seri_no, v_sifre_durum
           FROM sf_urun sf
          WHERE sf.reserved_account_number = v_account_number AND sf.reserved_outlet_location = v_outlet_location AND sf.reserved_gizli_no = v_sifre_gizli;
      EXCEPTION
         WHEN OTHERS THEN
            o_status := 'E';
            o_durum  := 'Şifre bulunamamıştır.';
            RETURN;
      END;

      IF v_sifre_durum = 'R' THEN
         UPDATE sf_urun
            SET durum = 'V', aciklama = 'Internet Başvurusu iptal edildi.', degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
          WHERE seri_no = v_seri_no;

         FOR rec IN (SELECT *
                       FROM sf_urun
                      WHERE seri_no = v_seri_no) LOOP
            SELECT dbs_dba.lg_sf_urun_id_seq.NEXTVAL INTO v_lg_sf_urun_id FROM DUAL;

            INSERT
              INTO lg_sf_urun (id,
                               kisi,
                               islem,
                               islem_tarihi,
                               seri_no,
                               gizli_no,
                               durum,
                               detay_durum,
                               effective_date,
                               expire_date,
                               urun_grup_kod,
                               urun_tasarim_id,
                               account_number,
                               outlet_location,
                               reserved_account_number,
                               reserved_outlet_location,
                               reserved_prospect_number,
                               reserved_gizli_no,
                               depodan,
                               depoya,
                               kaynak,
                               aciklama
                              )
               VALUES (
                         v_lg_sf_urun_id,
                         in_kullanici,
                         'U',
                         SYSDATE,
                         v_seri_no,
                         rec.gizli_no,
                         rec.durum,
                         rec.detay_durum,
                         rec.effective_date,
                         rec.expire_date,
                         rec.urun_grup_kod,
                         rec.urun_tasarim_id,
                         rec.account_number,
                         rec.outlet_location,
                         rec.reserved_account_number,
                         rec.reserved_outlet_location,
                         rec.reserved_prospect_number,
                         rec.reserved_gizli_no,
                         rec.equip_location_code,
                         NULL,
                         rec.kaynak,
                         rec.aciklama);
         END LOOP;
      END IF;

      DECLARE
         v_iliski_id NUMBER;
         v_statu     VARCHAR2 (10);
      BEGIN
         BEGIN
            SELECT ils.iliski_id, status
              INTO v_iliski_id, v_statu
              FROM dbs_dba.gl_kisi_bilgi_iliski ils,
                   dbs_dba.gl_iliski_detay dty
             WHERE ils.sol_id = in_application_id AND ils.iliski_id = dty.iliski_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_iliski_id := NULL;
         END;

         IF v_statu = 'A' THEN
            --sol_uyelik_iliskisi_olustur (v_account_number, v_outlet_location, in_application_id, 'P', in_kullanici, o_durum);

            dbs_dba.kisi_iliski_pack.kisi_iliski_insert (in_kisi_bilgi_id          => NULL,
                                                         in_account_number         => v_account_number,
                                                         in_prospect_number        => NULL,
                                                         in_bb_user_id             => NULL,
                                                         in_dd_user_id             => NULL,
                                                         in_bp_user_id             => NULL,
                                                         in_da_user_id             => NULL,
                                                         in_iliski_kisi_bilgi_id   => NULL,
                                                         in_eslestirme_tipi_id     => 36,
                                                         in_iliski_account_number  => NULL,
                                                         in_iliski_prospect_number => NULL,
                                                         in_user                   => in_kullanici,
                                                         in_aciklama               => 'SOL üyelik eşleştirme',
                                                         out_durum                 => o_durum,
                                                         out_hata_kodu             => v_hata_kodu,
                                                         in_listeden_gizle         => 'H',
                                                         in_sysdate                => SYSDATE,
                                                         in_otomatik_giris         => 'H',
                                                         in_outlet_location        => v_outlet_location,
                                                         in_iliski_outlet_location => NULL,
                                                         in_millenicom_id          => NULL,
                                                         in_sol_id                 => in_application_id,
                                                         in_ttnet_id               => NULL,
                                                         in_co_status              => 'P', --in_co_status 'A',
                                                         in_co_kontrat_tarihi      => NULL
                                                        );

            IF o_durum != '0' THEN
               RETURN;
            END IF;
         END IF;

         IF o_durum = '0' THEN
            BEGIN
               SELECT svc.id
                 INTO v_hp_svc_int_id
                 FROM wiz_customer_hp_svc_int svc
                WHERE svc.account_number = v_account_number AND svc.outlet_location = v_outlet_location AND svc.promo_code = v_promo_code;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_hp_svc_int_id := NULL;
               WHEN TOO_MANY_ROWS THEN
                  o_durum         := 'Aynı promo code için bir den fazla internet ürünü bulundu.';
                  v_hp_svc_int_id := NULL;
            END;

            IF v_hp_svc_int_id IS NOT NULL THEN
               dbs_dba.internet_basvuru_pack.del_wiz_customer_hp_svc_int (v_hp_svc_int_id, --in_hp_svc_int_id
                                                                          SYSDATE, --in_drop_date
                                                                          'DZM', --in_drop_code
                                                                          in_add_closed_date,
                                                                          in_drop_closed_date,
                                                                          in_kullanici, --in_kapatan_kullanici
                                                                          in_kullanici, --in_degistiren_kullanici
                                                                          SYSDATE, --in_degistirme_tarihi
                                                                          in_kullanici, --in_dusurme_talebi_alan_kull033
                                                                          in_kullanici, --in_dusuren_kullanici
                                                                          SYSDATE, --in_dusurme_tarihi
                                                                          o_durum
                                                                         );
            END IF;
         END IF;

         IF o_durum != '0' THEN
            o_status       := 'E';
            v_error_detail := o_durum;
         ELSE
            o_status       := 'C';
            v_error_detail := 'SUCCESS';
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            o_status := 'E';
            o_durum  := SUBSTR (SQLERRM, 1, 255);
      END;
   EXCEPTION
      WHEN OTHERS THEN
         o_status := 'E';
         o_durum  := SUBSTR (SQLERRM, 1, 255);
   END;

   PROCEDURE int_application_transfer (in_application_id      IN     NUMBER,
                                       in_promo_code          IN     VARCHAR2,
                                       in_new_account_number  IN     NUMBER,
                                       in_new_outlet_location IN     VARCHAR2,
                                       in_kullanici           IN     VARCHAR2,
                                       o_durum                   OUT VARCHAR2
                                      ) IS
      v_guncel_statu             NUMBER;
      v_lg_sf_urun_id            NUMBER;
      v_wf_tb_uye_statu_id       NUMBER;
      v_seri_no                  sf_urun.seri_no%TYPE;
      v_sifre_gizli              sf_urun.gizli_no%TYPE;
      rec_sf                     sf_urun%ROWTYPE;
      rec_bsv                    dbs_dba.dt_internet_uye_basvuru%ROWTYPE;
      rec_svc_int                dbs_dba.wiz_customer_hp_svc_int%ROWTYPE;
      rec_wftb                   dbs_dba.wf_tb_uye_statu%ROWTYPE;
      rec_iliski                 dbs_dba.gl_kisi_bilgi_iliski%ROWTYPE;
      v_account_number           sf_urun.account_number%TYPE;
      v_outlet_location          sf_urun.outlet_location%TYPE;
      v_reserved_account_number  sf_urun.reserved_account_number%TYPE;
      v_reserved_outlet_location sf_urun.reserved_outlet_location%TYPE;
      v_result_code              VARCHAR2 (10);
      --v_iliski_id                NUMBER;
      v_count                    NUMBER;
      v_new_account_app_id       dbs_dba.dt_internet_uye_basvuru.application_id%TYPE;
      v_error_code               NUMBER;
   BEGIN
      o_durum       := '0';
      v_result_code := 'VLD999';

      SELECT COUNT (1)
        INTO v_count
        FROM wiz_customer_hp_life
       WHERE account_number = in_new_account_number AND customer_status = 'AC';

      IF v_count < 1 THEN
         o_durum := 'Başvuru başka üyeliğe taşınamaz:Seçilen üyenin digitürk aboneliği aktif değildir.';
         RETURN;
      END IF;

      BEGIN
         SELECT *
           INTO rec_bsv
           FROM dbs_dba.dt_internet_uye_basvuru
          WHERE application_id = in_application_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_durum := 'Başvuru başka üyeliğe taşınamaz: Hata:' || SUBSTR (SQLERRM, 512);
            RETURN;
      END;

      IF rec_bsv.account_number = in_new_account_number THEN
         o_durum := 'Başvuru aynı üyeliğe taşınamaz';
         RETURN;
      END IF;

      --Seçilen Üyein outletinde iptal haricinden herhangi bir basvuru varmı
      BEGIN
         SELECT application_id
           INTO v_new_account_app_id
           FROM dbs_dba.dt_internet_uye_basvuru bsv
          WHERE bsv.account_number = in_new_account_number AND bsv.outlet_location = in_new_outlet_location AND bsv.status <> 8;

         dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (3,
                                                          in_new_account_number,
                                                          in_new_outlet_location,
                                                          NULL,
                                                          v_guncel_statu,
                                                          o_durum,
                                                          v_new_account_app_id
                                                         );

         IF o_durum != '0' THEN
            IF o_durum = 'Aktif bir akis bulunmamaktadir.' THEN
               NULL; --8:İptal statusu Durum:V
            ELSE
               o_durum := 'Başvuru başka üyeliğe taşınamaz:Üyenin guncel statüsü bulunamadı.Hata : ' || o_durum;
               RETURN;
            END IF;
         END IF;

         IF v_guncel_statu NOT IN (8, 13) THEN
            o_durum := 'Başvuru başka üyeliğe taşınamaz:Seçilen üyenin outletinde aktif bir başvurusu bulunmaktadır.';
            RETURN;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               NULL;
            END;
         WHEN TOO_MANY_ROWS THEN
            BEGIN
               o_durum := 'Başvuru başka üyeliğe taşınamaz:Seçilen üyenin outletinde aktif bir başvurusu bulunmaktadır.';
               RETURN;
            END;
      END;

      /******************************* sf_urun islemleri<begin> *********************************************************/
      v_sifre_gizli := dbs_dba.digipaket_sifre.encrypt (in_promo_code);

      BEGIN
         SELECT *
           INTO rec_sf
           FROM sf_urun
          WHERE urun_grup_kod = 1117 AND gizli_no = v_sifre_gizli OR reserved_gizli_no = v_sifre_gizli;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_durum := 'Başvuru başka üyeliğe taşınamaz: Hata:' || SUBSTR (SQLERRM, 512);
            RETURN;
      END;

      -- üyenin statüsüne bak
      dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (3, rec_bsv.account_number, rec_bsv.outlet_location, NULL, v_guncel_statu, o_durum, in_application_id);

      IF o_durum != '0' THEN
         o_durum := 'Başvuru başka üyeliğe taşınamaz:Üyenin guncel statüsü bulunamadı.Hata : ' || o_durum;
         RETURN;
      END IF;

      IF v_guncel_statu = 7 THEN --Aktif basvuru
         IF rec_sf.durum = 'C' THEN
            v_reserved_account_number  := NULL;
            v_reserved_outlet_location := NULL;
            v_account_number           := in_new_account_number;
            v_outlet_location          := in_new_outlet_location;
         ELSE
            o_durum := 'Başvuru başka üyeliğe taşınamaz:Üye aktif olduğu halde promo code kapalı statüsünde değil.';
            RETURN;
         END IF;
      ELSIF v_guncel_statu NOT IN (8) THEN
         IF rec_sf.durum = 'R' THEN
            v_reserved_account_number  := in_new_account_number;
            v_reserved_outlet_location := in_new_outlet_location;
            v_account_number           := NULL;
            v_outlet_location          := NULL;
         ELSIF rec_sf.durum = 'C' THEN
            v_reserved_account_number  := NULL;
            v_reserved_outlet_location := NULL;
            v_account_number           := in_new_account_number;
            v_outlet_location          := in_new_outlet_location;
         ELSE
            o_durum := 'Başvuru başka üyeliğe taşınamaz:Promo code iptal edilmiş.';
            RETURN;
         END IF;
      ELSE
         o_durum := 'Başvuru başka üyeliğe taşınamaz:Üye başvurusu iptal edilmiş.';
         RETURN;
      END IF;

      SELECT lg_sf_urun_id_seq.NEXTVAL INTO v_lg_sf_urun_id FROM DUAL;

      INSERT
        INTO lg_sf_urun (id,
                         kisi,
                         islem,
                         islem_tarihi,
                         seri_no,
                         gizli_no,
                         durum,
                         detay_durum,
                         effective_date,
                         expire_date,
                         urun_grup_kod,
                         urun_tasarim_id,
                         account_number,
                         outlet_location,
                         depoya,
                         depodan,
                         kaynak,
                         aciklama,
                         reserved_account_number,
                         reserved_outlet_location,
                         reserved_prospect_number,
                         reserved_gizli_no
                        )
         VALUES (
                   v_lg_sf_urun_id,
                   in_kullanici,
                   'U',
                   SYSDATE,
                   rec_sf.seri_no,
                   rec_sf.gizli_no,
                   rec_sf.durum,
                   rec_sf.detay_durum,
                   rec_sf.effective_date,
                   rec_sf.expire_date,
                   rec_sf.urun_grup_kod,
                   rec_sf.urun_tasarim_id,
                   rec_sf.account_number,
                   rec_sf.outlet_location,
                   NULL, --depoya
                   rec_sf.equip_location_code,
                   rec_sf.kaynak,
                   rec_sf.aciklama,
                   rec_sf.reserved_account_number,
                   rec_sf.reserved_outlet_location,
                   rec_sf.reserved_prospect_number,
                   rec_sf.reserved_gizli_no);

      UPDATE sf_urun
         SET reserved_account_number  = v_reserved_account_number,
             reserved_outlet_location = v_reserved_outlet_location,
             account_number           = v_account_number,
             outlet_location          = v_outlet_location,
             degistirme_tarihi        = SYSDATE,
             degistiren_kullanici     = in_kullanici
       WHERE seri_no = rec_sf.seri_no;

      /******************************* sf_urun islemleri<end> *********************************************************/

      /******************************* dt_internet_uye_basvuru islemleri<begin> *********************************************************/
      dbs_dba.internet_basvuru_pack.basvuru_log_insert (in_kisi                    => in_kullanici,
                                                        in_islem                   => 'U',
                                                        in_islem_tarihi            => SYSDATE,
                                                        in_application_id          => rec_bsv.application_id,
                                                        in_account_number          => rec_bsv.account_number,
                                                        in_outlet_location         => rec_bsv.outlet_location,
                                                        in_prospect_number         => rec_bsv.prospect_number,
                                                        in_uydu_tipi               => rec_bsv.uydu_tipi,
                                                        in_provider                => rec_bsv.provider,
                                                        in_status                  => rec_bsv.status,
                                                        in_connection_type         => rec_bsv.connection_type,
                                                        in_bayi_kodu               => rec_bsv.bayi_kodu,
                                                        in_assigned_to             => rec_bsv.assigned_to,
                                                        in_description             => rec_bsv.description,
                                                        in_modem_seri_no           => rec_bsv.modem_seri_no,
                                                        in_int_first_name          => rec_bsv.int_first_name,
                                                        in_int_last_name           => rec_bsv.int_last_name,
                                                        in_int_tckn                => rec_bsv.int_tckn,
                                                        in_int_birthdate           => rec_bsv.int_birthdate,
                                                        in_int_country             => rec_bsv.int_country,
                                                        in_int_city                => rec_bsv.int_city,
                                                        in_int_county              => rec_bsv.int_county,
                                                        in_int_district            => rec_bsv.int_district,
                                                        in_int_mobile_country_code => rec_bsv.int_mobile_country_code,
                                                        in_int_mobile_area_code    => rec_bsv.int_mobile_area_code,
                                                        in_int_mobile_number       => rec_bsv.int_mobile_number,
                                                        in_int_home_country_code   => rec_bsv.int_home_country_code,
                                                        in_int_home_area_code      => rec_bsv.int_home_area_code,
                                                        in_int_home_number         => rec_bsv.int_home_number,
                                                        in_int_home_extension      => rec_bsv.int_home_extension,
                                                        in_int_work_country_code   => rec_bsv.int_work_country_code,
                                                        in_int_work_area_code      => rec_bsv.int_work_area_code,
                                                        in_int_work_number         => rec_bsv.int_work_number,
                                                        in_int_work_extension      => rec_bsv.int_work_extension,
                                                        in_int_modem_seri_no       => rec_bsv.int_modem_seri_no,
                                                        in_int_promo_code          => rec_bsv.int_promo_code,
                                                        in_int_status              => rec_bsv.int_status,
                                                        in_int_status_date         => rec_bsv.int_status_date,
                                                        in_int_reason_code         => rec_bsv.int_reason_code,
                                                        in_result_code             => v_result_code,
                                                        in_result_message          => o_durum,
                                                        in_source                  => rec_bsv.source,
                                                        in_int_connection_date     => rec_bsv.int_connection_date,
                                                        in_int_wf_tip              => rec_bsv.int_wf_tip,
                                                        in_kullanici               => in_kullanici,
                                                        in_giris_tarihi            => SYSDATE,
                                                        in_tckn_durum              => rec_bsv.tckn_durum,
                                                        in_taahhut_durum           => rec_bsv.taahhut_durum
                                                       );

      UPDATE dbs_dba.dt_internet_uye_basvuru
         SET account_number = in_new_account_number, outlet_location = in_new_outlet_location, --int_first_name = in_new_first_name,int_last_name = in_new_last_name,int_tckn = in_new_tckn,
                                                                                              degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
       WHERE application_id = rec_bsv.application_id;

      /******************************* dt_internet_uye_basvuru islemleri<end> *********************************************************/

      /******************************* wf_tb_uye_statu ve wf_tb_uye_islem ile  ilgili islemler <begin> *******************************************/
      BEGIN
         --Eski üyeye ait bavusuru status bilgisi ceikiliyor
         SELECT *
           INTO rec_wftb
           FROM dbs_dba.wf_tb_uye_statu
          WHERE application_id = rec_bsv.application_id AND statu = v_guncel_statu AND durum IN ('A', 'V');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_durum := 'Başvuru başka üyeliğe taşınamaz: Hata:' || SUBSTR (SQLERRM, 512);
            RETURN;
      END;

      SELECT dbs_dba.seq_wf_tb_uye_statu_id.NEXTVAL INTO v_wf_tb_uye_statu_id FROM DUAL;

      INSERT
        INTO dbs_dba.wf_tb_uye_statu (id,
                                      wf_no,
                                      account_number,
                                      outlet_location,
                                      potansiyel_number,
                                      statu_tanim_tip,
                                      statu,
                                      durum,
                                      valid_after,
                                      giren_kullanici,
                                      giris_tarihi,
                                      degistiren_kullanici,
                                      degistirme_tarihi,
                                      application_id
                                     )
         VALUES (
                   v_wf_tb_uye_statu_id,
                   rec_wftb.wf_no,
                   in_new_account_number,
                   in_new_outlet_location,
                   NULL,
                   rec_wftb.statu_tanim_tip,
                   rec_wftb.statu,
                   'A',
                   rec_wftb.valid_after,
                   in_kullanici,
                   SYSDATE,
                   in_kullanici,
                   SYSDATE,
                   rec_wftb.application_id);

      UPDATE dbs_dba.wf_tb_uye_statu
         SET durum = 'K', degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
       WHERE id = rec_wftb.id;

      UPDATE dbs_dba.wf_tb_uye_islem
         SET account_number = in_new_account_number, outlet_location = in_new_outlet_location, degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
       WHERE pr_islem_id = 4 AND account_number = rec_wftb.account_number AND outlet_location = rec_wftb.outlet_location;

      /******************************* wf_tb_uye_statu ve wf_tb_uye_islem ile  ilgili islemler <end> *********************************************/

      /******************************* wiz_customer_hp_svc_int islemleri <begin> *********************************************************/
      BEGIN
         SELECT *
           INTO rec_svc_int
           FROM dbs_dba.wiz_customer_hp_svc_int
          WHERE promo_code = in_promo_code;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            rec_svc_int.id := NULL;
      END;

      IF rec_svc_int.id IS NOT NULL THEN
         dbs_dba.internet_basvuru_pack.ins_wiz_cus_hp_svc_int_log (rec_svc_int.outlet_location,
                                                                   rec_svc_int.account_number,
                                                                   rec_svc_int.service_code,
                                                                   rec_svc_int.sales_code,
                                                                   rec_svc_int.salesperson,
                                                                   SYSDATE, --in_drop_date
                                                                   'DZM', --in_drop_code
                                                                   rec_svc_int.add_closed_date, -- in_add_closed_date
                                                                   SYSDATE, -- in_drop_closed_date
                                                                   rec_svc_int.id,
                                                                   rec_svc_int.promo_expire_date,
                                                                   rec_svc_int.servis_frekansi,
                                                                   rec_svc_int.servis_fiyati,
                                                                   in_kullanici,
                                                                   SYSDATE,
                                                                   in_kullanici, --dusuren_kullanici
                                                                   SYSDATE,
                                                                   in_kullanici, --degistiren_kullanici
                                                                   rec_svc_int.provider,
                                                                   rec_svc_int.promo_code
                                                                  );

         UPDATE dbs_dba.wiz_customer_hp_svc_int
            SET account_number       = in_new_account_number,
                outlet_location      = in_new_outlet_location,
                degistirme_tarihi    = SYSDATE,
                degistiren_kullanici = in_kullanici
          WHERE id = rec_svc_int.id;
      END IF;

      /******************************* wiz_customer_hp_svc_int islemleri <end> *********************************************************/

      /******************************* gl_kisi_bilgi_iliski islemleri <begin> *********************************************************/
      BEGIN
         SELECT *
           INTO rec_iliski
           FROM dbs_dba.gl_kisi_bilgi_iliski
          WHERE listeden_gizle = 'H' AND sol_id = rec_bsv.application_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            rec_iliski.iliski_id := NULL;
      END;

      IF rec_iliski.iliski_id IS NOT NULL THEN
         UPDATE dbs_dba.gl_iliski_detay
            SET status = 'V', update_tarihi = SYSDATE, update_kullanici = in_kullanici
          WHERE iliski_id = rec_iliski.iliski_id;

         INSERT
           INTO lg_gl_kisi_bilgi_iliski (id,
                                         kisi,
                                         islem,
                                         islem_tarihi,
                                         kisi_bilgi_id,
                                         account_number,
                                         prospect_number,
                                         bb_user_id,
                                         eslestirme_tipi_id,
                                         iliski_kisi_bilgi_id,
                                         iliski_account_number,
                                         iliski_prospect_number,
                                         listeden_gizle,
                                         aciklama,
                                         dd_user_id,
                                         bp_user_id,
                                         da_user_id,
                                         millenicom_id,
                                         sol_id,
                                         ttnet_id,
                                         iliski_id,
                                         status
                                        )
            VALUES (
                      lg_gl_kisi_bilgi_iliski_id_seq.NEXTVAL,
                      in_kullanici,
                      'D',
                      SYSDATE,
                      rec_iliski.kisi_bilgi_id,
                      rec_iliski.account_number,
                      rec_iliski.prospect_number, --null
                      rec_iliski.bb_user_id, --null
                      rec_iliski.eslestirme_tipi_id, --36
                      rec_iliski.iliski_kisi_bilgi_id,
                      rec_iliski.iliski_account_number,
                      rec_iliski.iliski_prospect_number,
                      rec_iliski.listeden_gizle,
                      rec_iliski.aciklama,
                      rec_iliski.dd_user_id,
                      rec_iliski.bp_user_id,
                      rec_iliski.da_user_id,
                      rec_iliski.millenicom_id,
                      rec_iliski.sol_id,
                      rec_iliski.ttnet_id,
                      rec_iliski.iliski_id,
                      'V');

         --eski üye icin iliski_silinir
         DELETE FROM dbs_dba.gl_kisi_bilgi_iliski
               WHERE iliski_id = rec_iliski.iliski_id;

         --yeni uye icin iliski olusturulur
         sol_uyelik_iliskisi_olustur (in_account_number  => in_new_account_number,
                                      in_outlet_location => in_new_outlet_location,
                                      in_iliskili_sol_id => rec_bsv.application_id,
                                      in_co_status       => 'A',
                                      in_giren_kullanici => in_kullanici,
                                      o_durum            => o_durum
                                     );
      END IF;
   /******************************** gl_kisi_bilgi_iliski islemleri <end> *********************************************************/

   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.int_application_transfer' || SQLERRM;
   END;

   PROCEDURE getpromocodeinfo (in_promocode        IN     VARCHAR2,
                               o_firstname            OUT VARCHAR2,
                               o_lastname             OUT VARCHAR2,
                               o_registerid           OUT VARCHAR2,
                               o_offercode            OUT VARCHAR2,
                               o_offername            OUT VARCHAR2,
                               o_offerstatus          OUT VARCHAR2,
                               o_promocodestatus      OUT VARCHAR2,
                               o_islem_sonuc_tip      OUT NUMBER,
                               o_islem_sonuc_kod      OUT VARCHAR2,
                               o_islem_sonuc_mesaj    OUT VARCHAR2
                              ) IS
      l_http_request     UTL_HTTP.req;
      l_http_response    UTL_HTTP.resp;
      l_string_request   CLOB;
      l_clob_response    CLOB;
      --l_host_name      VARCHAR2(128) := 'dtl1ws02.turk.local';
      --l_port           VARCHAR2(128) := '8088';
      l_resp_xml         XMLTYPE;
      l_result_xml_node  VARCHAR2 (4000);
      l_namespace_soap   VARCHAR2 (1024) := 'xmlns="http://schemas.xmlsoap.org/soap/envelope/"';
      l_response_temp    VARCHAR2 (4000);
      v_module_name      VARCHAR2 (512) := 'DBS_DBA.Internet_Islem_Pack.GetPromoCodeInfo:';
      v_transfer_timeout PLS_INTEGER := TO_NUMBER (dbs_sabit ('ITTP_WEBSERVICE_REQUEST_TIMEOUT'));
      v_webservice_url   VARCHAR (1024);
      v_fault_code       VARCHAR2 (256);
      v_fault_string     VARCHAR2 (4000);
   BEGIN
      o_islem_sonuc_tip     := 0;

      IF ias_dba.ias_ortam_pack.get_environment_name IN ('DEV', 'TEST') THEN
         v_webservice_url := dbs_sabit ('SOL_PROMOCODE_TEST_WEBSERVICE_URL');
      ELSIF ias_dba.ias_ortam_pack.get_environment_name = 'LIVE' THEN
         v_webservice_url := dbs_sabit ('SOL_PROMOCODE_LIVE_WEBSERVICE_URL');
      END IF;

      --v_webservice_url      := 'http://212.252.205.228/webrequest/SuperonlineWs/SuperonlineService.asmx';

      IF in_promocode IS NULL THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR4000';
         o_islem_sonuc_mesaj := 'Promocode bilgisi dolu olmalidir.';
         RETURN;
      END IF;

      l_string_request      :=    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:iris="http://irisadmin.turk.net/">
      <soapenv:Header/>
       <soapenv:Body>
            <iris:GetPromoCodeInfo>'
                               || '<iris:promoCode>'
                               || in_promocode
                               || '</iris:promoCode>'
                               || '</iris:GetPromoCodeInfo>
       </soapenv:Body>
      </soapenv:Envelope>';

      UTL_HTTP.set_transfer_timeout (v_transfer_timeout);
      l_http_request        := UTL_HTTP.begin_request (url => LOWER (v_webservice_url), method => 'POST', http_version => 'HTTP/1.1');
      UTL_HTTP.set_header (l_http_request, 'User-Agent', 'Apache-HttpClient/4.1.1');
      --UTL_HTTP.set_header(l_http_request, 'Host', l_host_name || ':' || l_port);
      UTL_HTTP.set_header (l_http_request, 'Connection', 'close');
      UTL_HTTP.set_header (l_http_request, 'Content-Type', 'text/xml;charset=UTF-8');
      UTL_HTTP.set_header (l_http_request, 'SOAPAction', '"http://irisadmin.turk.net/GetPromoCodeInfo"');
      UTL_HTTP.set_header (l_http_request, 'Content-Length', LENGTH (l_string_request));

     --dbms_output.put_line('l_string_request='||l_string_request);

     <<request_loop>>
      UTL_HTTP.write_text (l_http_request, l_string_request);
      l_http_response       := UTL_HTTP.get_response (l_http_request);

      BEGIN
         UTL_HTTP.read_text (l_http_response, l_clob_response);
         UTL_HTTP.end_response (l_http_response);
      EXCEPTION
         WHEN UTL_HTTP.end_of_body THEN
            UTL_HTTP.end_response (l_http_response);
      END;

      IF (l_http_response.status_code = 200) THEN
         -- Create XML type from response text
         l_resp_xml        := xmltype.createxml (l_clob_response);

         --dbms_output.put_line('l_clob_response='||l_clob_response);

         -- Clean SOAP header
         SELECT EXTRACT (l_resp_xml, 'Envelope/Body/node()', l_namespace_soap) INTO l_resp_xml FROM DUAL;

         -- Extract XML for DropProductAndRelatedFutureOrders
         l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/ResultCode[1]';

         SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO l_response_temp FROM DUAL;

         --DBMS_OUTPUT.put_line('o_result> l_response_temp=' || l_response_temp);
         --DBMS_OUTPUT.put_line('o_result> l_result_xml_node=' || l_result_xml_node);

         IF LOWER (l_response_temp) = '0' THEN
            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/Name[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_firstname FROM DUAL;

            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/Surname[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_lastname FROM DUAL;

            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/RegisterID[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_registerid FROM DUAL;

            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/OfferCode[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_offercode FROM DUAL;

            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/OfferName[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_offername FROM DUAL;

            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/OfferStatus[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_offerstatus FROM DUAL;

            l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/PromoCodeStatus[1]';

            SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO o_promocodestatus FROM DUAL;

            o_offerstatus     := TRIM (LOWER (o_offerstatus));
            o_promocodestatus := TRIM (LOWER (o_promocodestatus));

            o_islem_sonuc_tip := 0;
            o_islem_sonuc_kod := 'VLD5000';
         ELSE
            o_islem_sonuc_tip := 1;
            o_islem_sonuc_kod := 'ERR5000';
         END IF;

         l_result_xml_node := 'GetPromoCodeInfoResponse/GetPromoCodeInfoResult/ResultMessage[1]';

         SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node, 'xmlns="http://irisadmin.turk.net/"') INTO l_response_temp FROM DUAL;
      --DBMS_OUTPUT.put_line('o_result> l_response_temp=' || l_response_temp);
      --DBMS_OUTPUT.put_line('o_result> l_result_xml_node=' || l_result_xml_node);
      ELSE
         --web servisden hata alindi.
         o_islem_sonuc_tip := 1;
         o_islem_sonuc_kod := 'ERR1141';
         l_resp_xml        := xmltype.createxml (l_clob_response);

         -- Clean SOAP header
         SELECT EXTRACT (l_resp_xml, 'Envelope/Body/Fault/node()', l_namespace_soap) INTO l_resp_xml FROM DUAL;

         -- Extract XML for GetPromocodeInfo
         --l_result_XML_node := 'detail/ExceptionDetail/';
         SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node || 'faultcode[1]') INTO v_fault_code FROM DUAL;

         SELECT EXTRACTVALUE (l_resp_xml, l_result_xml_node || 'faultstring[1]') INTO v_fault_string FROM DUAL;

         l_response_temp   := v_fault_code || ':' || v_fault_string;
      END IF;

      --DBMS_OUTPUT.put_line('o_result> l_clob_response=' || l_clob_response);
      --DBMS_OUTPUT.put_line('o_result> l_response_temp=' || l_response_temp);
      IF l_response_temp IS NOT NULL THEN
         l_response_temp := REPLACE (REPLACE (l_response_temp, CHR (10), ''), CHR (13), '');
      ELSE
         l_response_temp := 'Request for GetPromocodeInfo Response:Failed';
      END IF;

      o_islem_sonuc_mesaj   := TRIM (l_response_temp);

      IF l_http_request.private_hndl IS NOT NULL THEN
         UTL_HTTP.end_request (l_http_request);
      END IF;

      IF l_http_response.private_hndl IS NOT NULL THEN
         UTL_HTTP.end_response (l_http_response);
      END IF;
   EXCEPTION
      WHEN UTL_HTTP.request_failed THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.request_failed:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.bad_argument THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.bad_argument:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.bad_url THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.bad_url:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.protocol_error THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.protocol_error:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.unknown_scheme THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.unknown_scheme:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.header_not_found THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.header_not_found:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.end_of_body THEN
         UTL_HTTP.end_response (l_http_response);
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.end_of_body:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.illegal_call THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.illegal_call:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.http_client_error THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.http_client_error:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.http_server_error THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.http_server_error:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.too_many_requests THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.too_many_requests:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.partial_multibyte_char THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.partial_multibyte_char:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.transfer_timeout THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1142';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.transfer_timeout:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN UTL_HTTP.init_failed THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || 'UTL_HTTP.init_failed:' || UTL_HTTP.get_detailed_sqlerrm;
      WHEN OTHERS THEN
         o_islem_sonuc_tip   := 1;
         o_islem_sonuc_kod   := 'ERR1128';
         o_islem_sonuc_mesaj := v_module_name || SUBSTR (SQLERRM, 1, 1024);
   END;

   PROCEDURE ins_dt_sol_basvuru_hata (in_application_id        IN dbs_dba.dt_sol_basvuru_hata.application_id%TYPE,
                                      in_account_number        IN dbs_dba.dt_sol_basvuru_hata.account_number%TYPE,
                                      in_outlet_location       IN dbs_dba.dt_sol_basvuru_hata.outlet_location%TYPE,
                                      in_promo_code            IN dbs_dba.dt_sol_basvuru_hata.promo_code%TYPE,
                                      in_dt_name               IN dbs_dba.dt_sol_basvuru_hata.dt_name%TYPE,
                                      in_dt_tckn               IN dbs_dba.dt_sol_basvuru_hata.dt_tckn%TYPE,
                                      in_sol_name              IN dbs_dba.dt_sol_basvuru_hata.sol_name%TYPE,
                                      in_sol_tckn              IN dbs_dba.dt_sol_basvuru_hata.sol_tckn%TYPE,
                                      in_sol_offer_name        IN dbs_dba.dt_sol_basvuru_hata.sol_offer_name%TYPE,
                                      in_sol_offer_code        IN dbs_dba.dt_sol_basvuru_hata.sol_offer_code%TYPE,
                                      in_sol_offer_status      IN dbs_dba.dt_sol_basvuru_hata.sol_offer_status%TYPE,
                                      in_sol_promo_code_status IN dbs_dba.dt_sol_basvuru_hata.sol_promo_code_status%TYPE,
                                      in_hata                  IN dbs_dba.dt_sol_basvuru_hata.hata%TYPE,
                                      in_kullanici             IN dbs_dba.dt_sol_basvuru_hata.kullanici%TYPE
                                     ) IS
   BEGIN
      INSERT
        INTO dbs_dba.dt_sol_basvuru_hata (application_id,
                                          account_number,
                                          outlet_location,
                                          promo_code,
                                          dt_name,
                                          dt_tckn,
                                          sol_name,
                                          sol_tckn,
                                          sol_offer_name,
                                          sol_offer_code,
                                          sol_offer_status,
                                          sol_promo_code_status,
                                          hata,
                                          islem_tarihi,
                                          kullanici
                                         )
         VALUES (
                   in_application_id,
                   in_account_number,
                   in_outlet_location,
                   in_promo_code,
                   in_dt_name,
                   in_dt_tckn,
                   in_sol_name,
                   in_sol_tckn,
                   in_sol_offer_name,
                   in_sol_offer_code,
                   in_sol_offer_status,
                   in_sol_promo_code_status,
                   in_hata,
                   SYSDATE,
                   in_kullanici);
   END ins_dt_sol_basvuru_hata;

   /*[EBerker20131223]<END>*/

   FUNCTION get_application_current_status (in_wf_tip            IN NUMBER,
                                            in_account_number    IN NUMBER,
                                            in_outlet_location   IN VARCHAR2,
                                            in_potansiyel_number IN NUMBER,
                                            in_application_id    IN NUMBER
                                           )
      RETURN NUMBER IS
      v_guncel_statu NUMBER;
      o_durum        VARCHAR2 (512);
   BEGIN
      dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (in_wf_tip,
                                                       in_account_number,
                                                       in_outlet_location,
                                                       in_potansiyel_number,
                                                       v_guncel_statu,
                                                       o_durum,
                                                       in_application_id
                                                      );

      IF o_durum != '0' THEN
         --İptal durumu için kontrol
         BEGIN
            SELECT statu
              INTO v_guncel_statu
              FROM dbs_dba.wf_tb_uye_statu
             WHERE statu_tanim_tip = in_wf_tip AND durum = 'V' AND application_id = in_application_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_guncel_statu := NULL;
         END;
      END IF;

      IF v_guncel_statu IS NULL THEN
         o_durum        := 'üyenin guncel statüsü bulunamadı. Hata : ' || o_durum;
         v_guncel_statu := 0;
      END IF;

      RETURN v_guncel_statu; --0:Invalid Status
   END;

   PROCEDURE get_next_application (in_kullanici IN VARCHAR2, out_application_id OUT NUMBER, o_durum OUT VARCHAR2) IS
      v_application_id NUMBER (10);

      CURSOR cur_app  IS
         SELECT     bsv.*
               FROM dbs_dba.dt_internet_uye_basvuru bsv
              WHERE bsv.application_id = v_application_id
         FOR UPDATE NOWAIT;

      cur_rec          cur_app%ROWTYPE;
      v_counter        NUMBER := 0;
   BEGIN
      o_durum            := '0';
      out_application_id := 0;

      FOR rec
         IN (SELECT *
               FROM (SELECT   bsv.*
                         FROM dbs_dba.dt_internet_uye_basvuru bsv
                        WHERE     (bsv.application_process_status = 'OPEN' OR (bsv.application_process_status = 'DRAFT' AND bsv.assigned_to = in_kullanici))
                              AND ( (bsv.taahhut_durum = 1 AND bsv.int_connection_date <= TRUNC (SYSDATE)) OR bsv.taahhut_durum = 2)
                              AND get_application_current_status (3, bsv.account_number, bsv.outlet_location, bsv.prospect_number, bsv.application_id) = 4
                              AND bsv.sales_agent_workflow_type = 2
                     ORDER BY bsv.application_process_status,
                              bsv.application_id)
              WHERE ROWNUM <= 20) LOOP
         BEGIN
            v_application_id := rec.application_id;

            OPEN cur_app;

            FETCH cur_app INTO cur_rec;

            IF cur_app%FOUND THEN
               out_application_id := v_application_id;

               UPDATE dbs_dba.dt_internet_uye_basvuru
                  SET application_process_status = 'IN_PROGRESS', degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
                WHERE application_id = v_application_id;

               CLOSE cur_app;

               EXIT;
            ELSE
               IF cur_app%ISOPEN = TRUE THEN
                  CLOSE cur_app;
               END IF;

               v_counter := v_counter + 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_counter := v_counter + 1;

               IF cur_app%ISOPEN = TRUE THEN
                  CLOSE cur_app;
               END IF;

               IF v_counter > 20 THEN
                  o_durum := 'Açık başvuru bulunamadi. Lütfen daha sonra tekrar deneyiniz.';
                  RETURN;
               END IF;

               IF SQLERRM = 'ORA-00054: resource busy and acquire with NOWAIT specified' THEN
                  o_durum := 'Kayıt getirilemedi. Lütfen tekrar deneyiniz.';
               ELSE
                  o_durum := 'Hata:' || SQLERRM;
               END IF;
         END;
      END LOOP;
   END;

   PROCEDURE sol_campaign_change_activation (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_hp_svc_int_id            NUMBER;
      v_servis_fiyati            NUMBER;
      v_transaction_type         VARCHAR2 (10) := NULL;
      v_status                   dbs_dba.dt_sol_campaign_change.status%TYPE;
      v_error_detail             dbs_dba.dt_sol_campaign_change.error_detail%TYPE;
      v_statu_id                 NUMBER;
      v_new_status               VARCHAR2 (10);

      v_guncel_statu             NUMBER;
      v_lg_sf_urun_id            NUMBER;
      v_sifre_gizli              sf_urun.gizli_no%TYPE;
      rec_sf                     sf_urun%ROWTYPE;
      rec_bsv                    dbs_dba.dt_internet_uye_basvuru%ROWTYPE;
      rec_svc_int                dbs_dba.wiz_customer_hp_svc_int%ROWTYPE;
      rec_iliski                 dbs_dba.gl_kisi_bilgi_iliski%ROWTYPE;
      v_account_number           sf_urun.account_number%TYPE;
      v_outlet_location          sf_urun.outlet_location%TYPE;
      v_reserved_account_number  sf_urun.reserved_account_number%TYPE;
      v_reserved_outlet_location sf_urun.reserved_outlet_location%TYPE;
      v_count                    NUMBER := 0;
   BEGIN
      FOR rec_sol_campaign_info
         IN (SELECT *
               FROM (SELECT   cch.*,
                              bas.application_id,
                              bas.account_number,
                              bas.outlet_location,
                              bas.bayi_kodu,
                              bas.connection_type,
                              bas.provider,
                              bas.uydu_tipi,
                              bas.int_city,
                              pro.baglanti_tipi,
                              pro.hiz,
                              pro.download_kota,
                              pro.upload_kota,
                              pro.dbs_urun_kodu,
                              pro.aciklama,
                              pro.yeni_uye_fiyat,
                              pro.mevcut_uye_fiyat,
                              pro.paket,
                              ROW_NUMBER () OVER (PARTITION BY cch.promo_code ORDER BY pro.dbs_urun_kodu ASC) rn
                         FROM dbs_dba.dt_sol_campaign_change cch,
                              dbs_dba.dt_internet_uye_basvuru bas,
                              dbs_dba.wiz_product_codes_int pro
                        WHERE     cch.promo_code = bas.int_promo_code(+)
                              AND LOWER (cch.product_name) LIKE '%' || LOWER (pro.baglanti_tipi) || '%'
                              AND bas.prospect_number IS NULL
                              AND cch.status IN ('O', 'W', 'P')
                              AND LOWER (cch.service_status) IN ('aktif')
                              AND bas.application_id IS NOT NULL
                     ORDER BY cch.contract_detail_start_date,
                              cch.contract_detail_code ASC)
              WHERE rn = 1) LOOP
       BEGIN
         v_count            := v_count + 1;
         v_sifre_gizli      := dbs_dba.digipaket_sifre.encrypt (rec_sol_campaign_info.promo_code);

         DBMS_OUTPUT.put_line ('############################## ' || rec_sol_campaign_info.promo_code || '##############################');

         DBMS_OUTPUT.put_line ('v_sifre_gizli=' || v_sifre_gizli);

         BEGIN
            SELECT *
              INTO rec_sf
              FROM sf_urun
             WHERE urun_grup_kod = 1117 AND gizli_no = v_sifre_gizli OR reserved_gizli_no = v_sifre_gizli;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               o_durum := 'Başvuru başka üyeliğe taşınamaz: Hata:' || SUBSTR (SQLERRM, 512);
               DBMS_OUTPUT.put_line ('promo_code=' || rec_sol_campaign_info.promo_code || ':' || o_durum);
               CONTINUE;
         --RETURN;
         END;

         IF rec_sf.durum IN ('V', 'C') THEN
            v_reserved_account_number  := rec_sf.account_number;
            v_reserved_outlet_location := rec_sf.outlet_location;
            v_account_number           := NULL;
            v_outlet_location          := NULL;

            DBMS_OUTPUT.put_line ('v_reserved_account_number=' || v_reserved_account_number);
         END IF;

         SELECT dbs_dba.lg_sf_urun_id_seq.NEXTVAL INTO v_lg_sf_urun_id FROM DUAL;

         INSERT
           INTO dbs_dba.lg_sf_urun (id,
                                    kisi,
                                    islem,
                                    islem_tarihi,
                                    seri_no,
                                    gizli_no,
                                    durum,
                                    detay_durum,
                                    effective_date,
                                    expire_date,
                                    urun_grup_kod,
                                    urun_tasarim_id,
                                    account_number,
                                    outlet_location,
                                    depoya,
                                    depodan,
                                    kaynak,
                                    aciklama,
                                    reserved_account_number,
                                    reserved_outlet_location,
                                    reserved_prospect_number,
                                    reserved_gizli_no
                                   )
            VALUES (
                      v_lg_sf_urun_id,
                      in_kullanici,
                      'U',
                      SYSDATE,
                      rec_sf.seri_no,
                      rec_sf.gizli_no,
                      rec_sf.durum,
                      rec_sf.detay_durum,
                      rec_sf.effective_date,
                      rec_sf.expire_date,
                      rec_sf.urun_grup_kod,
                      rec_sf.urun_tasarim_id,
                      rec_sf.account_number,
                      rec_sf.outlet_location,
                      NULL, --depoya
                      rec_sf.equip_location_code,
                      rec_sf.kaynak,
                      rec_sf.aciklama,
                      rec_sf.reserved_account_number,
                      rec_sf.reserved_outlet_location,
                      rec_sf.reserved_prospect_number,
                      rec_sf.reserved_gizli_no);

         DBMS_OUTPUT.put_line ('v_lg_sf_urun_id=' || v_lg_sf_urun_id);

         UPDATE dbs_dba.sf_urun
            SET durum                    = 'R',
                reserved_account_number  = v_reserved_account_number,
                reserved_outlet_location = v_reserved_outlet_location,
                account_number           = v_account_number,
                outlet_location          = v_outlet_location,
                equip_location_code      = 'HBM',
                degistirme_tarihi        = SYSDATE,
                degistiren_kullanici     = in_kullanici
          WHERE seri_no = rec_sf.seri_no;

         DBMS_OUTPUT.put_line ('sf_urun=' || rec_sf.seri_no);

         UPDATE dbs_dba.dt_internet_uye_basvuru
            SET status = 3, degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
          WHERE application_id = rec_bsv.application_id;

         /*Statü güncellemeleri*/
         DELETE FROM dbs_dba.wf_tb_uye_statu
               WHERE statu_tanim_tip = 3 AND statu > 3 AND application_id = rec_sol_campaign_info.application_id;

         UPDATE dbs_dba.wf_tb_uye_statu
            SET durum = 'A', degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
          WHERE application_id = rec_sol_campaign_info.application_id AND statu = 3;

         DELETE FROM dbs_dba.wf_tb_uye_islem
               WHERE pr_islem_id = 4 AND account_number = rec_sol_campaign_info.account_number AND outlet_location = rec_sol_campaign_info.outlet_location;

         BEGIN
            SELECT *
              INTO rec_svc_int
              FROM dbs_dba.wiz_customer_hp_svc_int
             WHERE promo_code = rec_sol_campaign_info.promo_code;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               rec_svc_int.id := NULL;
         END;

         IF rec_svc_int.id IS NOT NULL THEN
            DBMS_OUTPUT.put_line ('rec_svc_int.id=' || rec_svc_int.id);

            dbs_dba.internet_basvuru_pack.ins_wiz_cus_hp_svc_int_log (rec_svc_int.outlet_location,
                                                                      rec_svc_int.account_number,
                                                                      rec_svc_int.service_code,
                                                                      rec_svc_int.sales_code,
                                                                      rec_svc_int.salesperson,
                                                                      SYSDATE, --in_drop_date
                                                                      'DZM', --in_drop_code
                                                                      rec_svc_int.add_closed_date, -- in_add_closed_date
                                                                      SYSDATE, -- in_drop_closed_date
                                                                      rec_svc_int.id,
                                                                      rec_svc_int.promo_expire_date,
                                                                      rec_svc_int.servis_frekansi,
                                                                      rec_svc_int.servis_fiyati,
                                                                      in_kullanici,
                                                                      SYSDATE,
                                                                      in_kullanici, --dusuren_kullanici
                                                                      SYSDATE,
                                                                      in_kullanici, --degistiren_kullanici
                                                                      rec_svc_int.provider,
                                                                      rec_svc_int.promo_code
                                                                     );

            DELETE FROM dbs_dba.wiz_customer_hp_svc_int
                  WHERE id = rec_svc_int.id;
         END IF;

         BEGIN
            SELECT *
              INTO rec_iliski
              FROM dbs_dba.gl_kisi_bilgi_iliski
             WHERE listeden_gizle = 'H' AND sol_id = rec_sol_campaign_info.application_id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               rec_iliski.iliski_id := NULL;
         END;

         IF rec_iliski.iliski_id IS NOT NULL THEN
            INSERT
              INTO dbs_dba.lg_gl_kisi_bilgi_iliski (id,
                                                    kisi,
                                                    islem,
                                                    islem_tarihi,
                                                    kisi_bilgi_id,
                                                    account_number,
                                                    prospect_number,
                                                    bb_user_id,
                                                    eslestirme_tipi_id,
                                                    iliski_kisi_bilgi_id,
                                                    iliski_account_number,
                                                    iliski_prospect_number,
                                                    listeden_gizle,
                                                    aciklama,
                                                    dd_user_id,
                                                    bp_user_id,
                                                    da_user_id,
                                                    millenicom_id,
                                                    sol_id,
                                                    ttnet_id,
                                                    iliski_id,
                                                    status
                                                   )
               VALUES (
                         dbs_dba.lg_gl_kisi_bilgi_iliski_id_seq.NEXTVAL,
                         in_kullanici,
                         'D',
                         SYSDATE,
                         rec_iliski.kisi_bilgi_id,
                         rec_iliski.account_number,
                         rec_iliski.prospect_number, --null
                         rec_iliski.bb_user_id, --null
                         rec_iliski.eslestirme_tipi_id, --36
                         rec_iliski.iliski_kisi_bilgi_id,
                         rec_iliski.iliski_account_number,
                         rec_iliski.iliski_prospect_number,
                         rec_iliski.listeden_gizle,
                         rec_iliski.aciklama,
                         rec_iliski.dd_user_id,
                         rec_iliski.bp_user_id,
                         rec_iliski.da_user_id,
                         rec_iliski.millenicom_id,
                         rec_iliski.sol_id,
                         rec_iliski.ttnet_id,
                         rec_iliski.iliski_id,
                         'V');

            DELETE FROM dbs_dba.gl_iliski_detay
                  WHERE iliski_id = rec_iliski.iliski_id;

            --eski üye icin iliski_silinir
            DELETE FROM dbs_dba.gl_kisi_bilgi_iliski
                  WHERE iliski_id = rec_iliski.iliski_id;
         END IF;

         UPDATE dbs_dba.dt_sol_campaign_change
            SET status = 'O', error_detail = 'SUCCESS', degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
          WHERE id = rec_sol_campaign_info.id;

         -- üyenin statüsüne bak
         dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (3,
                                                          rec_sol_campaign_info.account_number,
                                                          rec_sol_campaign_info.outlet_location,
                                                          NULL,
                                                          v_guncel_statu,
                                                          o_durum,
                                                          rec_sol_campaign_info.application_id
                                                         );

         IF o_durum != '0' THEN
            o_durum := 'Başvuru başka üyeliğe taşınamaz:Üyenin guncel statüsü bulunamadı.Hata : ' || o_durum;
            DBMS_OUTPUT.put_line ('promo_code=' || rec_sol_campaign_info.promo_code || ':' || o_durum);
            --ROLLBACK;
            CONTINUE;
         --RETURN;
         END IF;

         DBMS_OUTPUT.put_line ('v_guncel_statu=' || v_guncel_statu);

         DBMS_OUTPUT.put_line ('############################## KAYIT:' || v_count || '##############################');

         v_servis_fiyati    := rec_sol_campaign_info.mevcut_uye_fiyat;
         v_transaction_type := 'ADD';

         v_status           := 'C';
         v_error_detail     := 'SUCCESS';

         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_life
          WHERE account_number = rec_sol_campaign_info.account_number AND customer_status = 'IN';

         IF v_count > 0 THEN
            IF rec_sol_campaign_info.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM dbs_dba.wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = rec_sol_campaign_info.account_number
                      AND outlet_location = rec_sol_campaign_info.outlet_location
                      AND application_id = rec_sol_campaign_info.application_id;

               IF v_guncel_statu != 8 THEN
                  wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                           rec_sol_campaign_info.account_number,
                                                           rec_sol_campaign_info.outlet_location,
                                                           NULL,
                                                           SYSDATE,
                                                           8,
                                                           'SYSSOL',
                                                           o_durum,
                                                           rec_sol_campaign_info.application_id
                                                          );
               END IF;

               IF o_durum != '0' THEN
                  v_status       := 'E';
                  v_error_detail := 'In üye için digitürk başvurusu iptal edilemedi.';
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'In üye için internet basvuru bilgisi bulunamadi.';
            END IF;
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.dt_internet_uye_basvuru
          WHERE int_promo_code = rec_sol_campaign_info.promo_code;

         IF v_count = 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM dbs_dba.dt_internet_uye_basvuru_log
             WHERE int_promo_code = rec_sol_campaign_info.promo_code;

            IF v_count > 0 THEN
               v_status       := 'E';
               v_error_detail := 'Aktif basvuruda promocode degisimi.';
            ELSE
               v_status       := 'E';
               v_error_detail := 'Promocode bilgisi bulunamadi.';
            END IF;
         END IF;

         IF v_status = 'C' THEN
            IF rec_sol_campaign_info.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM dbs_dba.wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = rec_sol_campaign_info.account_number
                      AND outlet_location = rec_sol_campaign_info.outlet_location
                      AND application_id = rec_sol_campaign_info.application_id;

               IF v_guncel_statu = 8 THEN
                  v_status       := 'I';
                  v_error_detail := 'turk başvuru iptal - Sol Aktiflendi.';

                  --Statu:13 cekilir
                  UPDATE dbs_dba.wf_tb_uye_statu
                     SET statu = 13
                   WHERE id = v_statu_id;
               ELSE
                  SELECT COUNT (1)
                    INTO v_count
                    FROM dbs_dba.mb_outlet_takip mb
                   WHERE     mb.account_number = rec_sol_campaign_info.account_number
                         AND mb.outlet_location = rec_sol_campaign_info.outlet_location
                         AND mb.outlet_in_tarihi IS NULL;

                  IF v_count = 0 THEN
                     v_status       := 'I';
                     v_error_detail := 'turk üyeliği için başvurulan outlet aktif değildir..';
                  ELSE
                     sol_package_trans_control (v_transaction_type,
                                                rec_sol_campaign_info.product_name,
                                                rec_sol_campaign_info.application_id,
                                                rec_sol_campaign_info.account_number,
                                                rec_sol_campaign_info.dbs_urun_kodu,
                                                rec_sol_campaign_info.outlet_location,
                                                rec_sol_campaign_info.bayi_kodu,
                                                NULL, --rec_sol_campaign_info.contract_detail_sales_person,
                                                rec_svc_int.promo_expire_date, --rec_sol_campaign_info.contract_commitment_end_date, --in_promo_expire_date
                                                rec_sol_campaign_info.contract_detail_start_date, --in_add_closed_date
                                                1, --rec_sol_campaign_info.contract_commitment_period, --in_servis_frekansi
                                                v_servis_fiyati, --in_servis_fiyati
                                                2, --rec_sol_campaign_info.provider,
                                                rec_sol_campaign_info.promo_code,
                                                rec_sol_campaign_info.contract_detail_end_date, --in_drop_closed_date
                                                v_hp_svc_int_id,
                                                rec_sol_campaign_info.customer_name, -- in_full_name
                                                rec_sol_campaign_info.tckn, -- int_tckn
                                                'TÜRKİYE', --in_country
                                                rec_sol_campaign_info.int_city, --rec_sol_campaign_info.service_address_city_name, --int_city
                                                in_kullanici,
                                                o_durum,
                                                v_new_status
                                               );

                     IF o_durum != '0' THEN
                        v_status       := v_new_status;
                        v_error_detail := o_durum;
                     ELSE
                        v_status       := 'C';
                        v_error_detail := 'SUCCESS';
                     END IF;
                  END IF;
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'Aktif uye icin internet basvuru bilgisi bulunamadi.';
            END IF;
         END IF;

         IF v_status IN ('P', 'E', 'I') THEN -- Servis işlemlerinden hata alıyorsa  veya error oluşmuşsa, rollback et. diğer türlü commit atılacak.
            ROLLBACK;
         END IF;

         UPDATE dbs_dba.dt_sol_campaign_change
            SET status = v_status, error_detail = v_error_detail, degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
          WHERE id = rec_sol_campaign_info.id;

         COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         CONTINUE;
     END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_campaign_change_activation' || SQLERRM;
   END;


   PROCEDURE sol_campaign_change_deactivate (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      o_guncel_statu        NUMBER;
      v_iliski_id           NUMBER;
      v_statu               VARCHAR2 (10);
      o_error_code          VARCHAR2 (512);
      v_iptal_reason        VARCHAR2 (512);
      v_hp_svc_int_id       NUMBER;
      v_status              dbs_dba.dt_sol_sales_info.status%TYPE;
      v_error_detail        dbs_dba.dt_sol_sales_info.error_detail%TYPE;
      v_count               NUMBER;
      v_active_count        NUMBER;
      v_error_active_status BOOLEAN := FALSE;
      v_guncel_statu        NUMBER;
      v_statu_id            NUMBER;
      v_new_status          VARCHAR2 (10);
      iptal_rec             dbs_dba.dt_sol_sales_info%ROWTYPE;
   BEGIN
      FOR rec_sol_campaign_info
         IN (SELECT *
               FROM (SELECT   cch.*,
                              bas.application_id,
                              bas.account_number,
                              bas.outlet_location,
                              bas.bayi_kodu,
                              bas.connection_type,
                              bas.provider,
                              bas.uydu_tipi,
                              bas.int_city,
                              pro.baglanti_tipi,
                              pro.hiz,
                              pro.download_kota,
                              pro.upload_kota,
                              pro.dbs_urun_kodu,
                              pro.aciklama,
                              pro.yeni_uye_fiyat,
                              pro.mevcut_uye_fiyat,
                              pro.paket,
                              ROW_NUMBER () OVER (PARTITION BY cch.promo_code ORDER BY pro.dbs_urun_kodu ASC) rn
                         FROM dbs_dba.dt_sol_campaign_change cch,
                              dbs_dba.dt_internet_uye_basvuru bas,
                              dbs_dba.wiz_product_codes_int pro
                        WHERE     cch.promo_code = bas.int_promo_code(+)
                              AND LOWER (cch.product_name) LIKE '%' || LOWER (pro.baglanti_tipi) || '%'
                              AND bas.prospect_number IS NULL
                              AND cch.status IN ('O', 'W', 'P')
                              AND LOWER (cch.service_status) IN ('deaktif')
                              AND bas.application_id IS NOT NULL
                     ORDER BY cch.contract_detail_start_date,
                              cch.contract_detail_code ASC)
              WHERE rn = 1) LOOP
       BEGIN
         -- Üyenin eğer güncel ilikisi varsa önce onu iptal et.
         o_durum        := '0';
         v_status       := 'C';
         v_error_detail := 'SUCCESS';

         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_life
          WHERE account_number = rec_sol_campaign_info.account_number AND customer_status = 'IN';

         IF v_count > 0 THEN
            --Basvuru iptal e cekilince
            -- 1-)PromoCode iptal edilir. (Aktif: C->V) (Aktif Olmayan:R->V)
            -- 2-)svc_int deki internet ürünü silinir ve  svc_int_log a atilir
            -- 3-)kisi iliskide ki data iptal e cekilir (A->P)
            -- 4-)statu nun 8 e cekilmis olması gerekir
            IF rec_sol_campaign_info.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = rec_sol_campaign_info.account_number
                      AND outlet_location = rec_sol_campaign_info.outlet_location
                      AND application_id = rec_sol_campaign_info.application_id;

               IF v_guncel_statu != 8 THEN
                  wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                           rec_sol_campaign_info.account_number,
                                                           rec_sol_campaign_info.outlet_location,
                                                           NULL,
                                                           SYSDATE,
                                                           8,
                                                           'SYSSOL',
                                                           o_durum,
                                                           rec_sol_campaign_info.application_id
                                                          );

                  IF o_durum = '0' THEN
                     sol_basvuru_iptal_islemleri (rec_sol_campaign_info.application_id,
                                                  rec_sol_campaign_info.contract_detail_start_date,
                                                  rec_sol_campaign_info.contract_detail_end_date,
                                                  in_kullanici,
                                                  o_durum,
                                                  v_status
                                                 );

                     IF o_durum != '0' THEN
                        v_status       := 'E';
                        v_error_detail := o_durum;
                     --return edilebilir.
                     END IF;
                  END IF;
               END IF;

               IF o_durum != '0' THEN
                  v_status       := 'E';
                  v_error_detail := 'In üye için digitürk başvurusu iptal edilemedi.';
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'In üye için internet basvuru bilgisi bulunamadi.';
            END IF;
         --TODO:continue yapilabilir.
         END IF;

         IF v_status = 'C' THEN
            SELECT COUNT (1)
              INTO v_active_count
              FROM dbs_dba.dt_sol_sales_info a
             WHERE report_type = 'AKTIF' AND promo_code = rec_sol_campaign_info.promo_code AND status = 'C';

            SELECT COUNT (1)
              INTO v_count
              FROM dbs_dba.dt_internet_uye_basvuru
             WHERE int_promo_code = rec_sol_campaign_info.promo_code;

            IF v_count = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM dbs_dba.dt_internet_uye_basvuru_log
                WHERE int_promo_code = rec_sol_campaign_info.promo_code;

               IF v_count > 0 THEN
                  IF v_active_count > 0 THEN
                     v_status              := 'E';
                     v_error_detail        := 'Aktif basvuruda promocode degisimi.';
                     v_error_active_status := TRUE;
                  ELSE
                     v_status       := 'I';
                     v_error_detail := 'Başvuru İptal Promocode değişti.';
                  END IF;
               ELSE
                  v_status       := 'E';
                  v_error_detail := 'Promocode bilgisi bulunamadi.';
               END IF;
            ELSE
               IF v_active_count = 0 THEN
                  SELECT statu, id
                    INTO v_guncel_statu, v_statu_id
                    FROM wf_tb_uye_statu
                   WHERE     durum IN ('A', 'V')
                         AND statu_tanim_tip = 3
                         AND account_number = rec_sol_campaign_info.account_number
                         AND outlet_location = rec_sol_campaign_info.outlet_location
                         AND application_id = rec_sol_campaign_info.application_id;

                  IF v_guncel_statu != 8 THEN
                     wf_islem_pack.wf_uye_statusunu_degistir (3,
                                                              rec_sol_campaign_info.account_number,
                                                              rec_sol_campaign_info.outlet_location,
                                                              NULL,
                                                              SYSDATE,
                                                              6,
                                                              'SYSSOL',
                                                              o_durum,
                                                              rec_sol_campaign_info.application_id
                                                             );

                     IF o_durum != '0' THEN
                        v_status       := 'E';
                        v_error_detail := 'Sol iptale çekilemedi : .' || o_durum;
                     END IF;
                  END IF;
               END IF;
            END IF;

            IF rec_sol_campaign_info.application_id IS NOT NULL THEN
               SELECT statu, id
                 INTO v_guncel_statu, v_statu_id
                 FROM wf_tb_uye_statu
                WHERE     durum IN ('A', 'V')
                      AND statu_tanim_tip = 3
                      AND account_number = rec_sol_campaign_info.account_number
                      AND outlet_location = rec_sol_campaign_info.outlet_location
                      AND application_id = rec_sol_campaign_info.application_id;

               IF v_guncel_statu = 8 THEN
                  v_status       := 'I';
                  v_error_detail := 'Digitürk başvurusu iptal durumda.';
               ELSE
                  IF v_active_count > 0 AND v_error_active_status = FALSE THEN
                     BEGIN
                        SELECT *
                          INTO iptal_rec
                          FROM dbs_dba.dt_sol_sales_info a
                         WHERE report_type = 'IPTAL' AND promo_code = rec_sol_campaign_info.promo_code AND LOWER (service_status) = 'deaktif';
                     EXCEPTION
                        WHEN OTHERS THEN
                           CONTINUE;
                     END;

                     --bu üye satış aktif iptal kayitlarinda yer alıyor
                     IF LOWER (rec_sol_campaign_info.product_name) LIKE '%adsl%' OR LOWER (rec_sol_campaign_info.product_name) LIKE '%fiber%' THEN
                        BEGIN
                           v_iptal_reason := iptal_rec.cancel_reason || ' - ' || iptal_rec.cancel_reason_detail;

                           SELECT ils.iliski_id, status
                             INTO v_iliski_id, v_statu
                             FROM dbs_dba.gl_kisi_bilgi_iliski ils,
                                  dbs_dba.gl_iliski_detay dty
                            WHERE ils.sol_id = rec_sol_campaign_info.application_id AND ils.iliski_id = dty.iliski_id;

                           IF v_statu = 'A' THEN
                              sol_uyelik_iliskisi_olustur (rec_sol_campaign_info.account_number,
                                                           rec_sol_campaign_info.outlet_location,
                                                           rec_sol_campaign_info.application_id,
                                                           'P',
                                                           in_kullanici,
                                                           o_durum
                                                          );

                              IF o_durum != '0' THEN
                                 v_status       := 'E';
                                 v_error_detail := 'Sol internet ilişkisi iptal edilemedi. : ' || o_durum;
                              END IF;
                           END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                              NULL;
                        END;

                        IF v_status = 'C' THEN
                           sol_call_back (rec_sol_campaign_info.promo_code, 'ERR9999', v_iptal_reason, SYSDATE, o_error_code, o_durum);

                           IF o_durum != '0' THEN
                              v_status       := o_error_code;
                              v_error_detail := o_durum;
                           END IF;
                        END IF;
                     END IF;

                     IF o_durum = '0' AND v_status = 'C' THEN
                        sol_package_trans_control ('DROP',
                                                   rec_sol_campaign_info.product_name,
                                                   rec_sol_campaign_info.application_id,
                                                   rec_sol_campaign_info.account_number,
                                                   rec_sol_campaign_info.dbs_urun_kodu,
                                                   rec_sol_campaign_info.outlet_location,
                                                   rec_sol_campaign_info.bayi_kodu,
                                                   NULL, --rec_sol_sales_info.contract_detail_sales_person,
                                                   iptal_rec.contract_commitment_end_date, --in_promo_expire_date
                                                   rec_sol_campaign_info.contract_detail_start_date, --in_add_closed_date
                                                   1, --rec_sol_sales_info.contract_commitment_period, --in_servis_frekansi
                                                   rec_sol_campaign_info.mevcut_uye_fiyat, --in_servis_fiyati
                                                   rec_sol_campaign_info.provider,
                                                   rec_sol_campaign_info.promo_code,
                                                   rec_sol_campaign_info.contract_detail_end_date, --in_drop_closed_date
                                                   v_hp_svc_int_id,
                                                   rec_sol_campaign_info.customer_name, -- in_full_name
                                                   rec_sol_campaign_info.tckn, -- int_tckn
                                                   'TÜRKİYE', --in_country
                                                   rec_sol_campaign_info.int_city, --int_city
                                                   in_kullanici,
                                                   o_durum,
                                                   v_new_status
                                                  );

                        IF o_durum != '0' THEN
                           v_status       := v_new_status;
                           v_error_detail := o_durum;
                        ELSE
                           v_status       := 'C';
                           v_error_detail := 'SUCCESS';
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE
               v_status       := 'E';
               v_error_detail := 'İptal edilen kayit icin internet basvuru bilgisi bulunamadi.';
            END IF;
         END IF;

         IF v_status IN ('C', 'I') THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;

         UPDATE dbs_dba.dt_sol_campaign_change
            SET status = v_status, error_detail = v_error_detail, degistiren_kullanici = in_kullanici, degistirme_tarihi = SYSDATE
          WHERE id = rec_sol_campaign_info.id;

         COMMIT;
          EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         CONTINUE;
     END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.sol_campaign_change_deactivate' || SQLERRM;
   END;

   PROCEDURE trepas_uyelik_iliskisi_olustur (in_account_number     IN     NUMBER,
                                             in_outlet_location    IN     CHAR,
                                             in_iliskili_trepas_id IN     NUMBER,
                                             in_co_status          IN     VARCHAR2,
                                             in_giren_kullanici           VARCHAR2,
                                             o_durum                  OUT VARCHAR2
                                            ) IS
      v_hata_kodu NUMBER;
   BEGIN
      dbs_dba.kisi_iliski_pack.kisi_iliski_insert (in_kisi_bilgi_id          => NULL,
                                                   in_account_number         => in_account_number,
                                                   in_prospect_number        => NULL,
                                                   in_bb_user_id             => NULL,
                                                   in_dd_user_id             => NULL,
                                                   in_bp_user_id             => NULL,
                                                   in_da_user_id             => NULL,
                                                   in_iliski_kisi_bilgi_id   => NULL,
                                                   in_eslestirme_tipi_id     => 38,
                                                   in_iliski_account_number  => NULL,
                                                   in_iliski_prospect_number => NULL,
                                                   in_user                   => in_giren_kullanici,
                                                   in_aciklama               => 'Trepas üyelik eşleştirme',
                                                   out_durum                 => o_durum,
                                                   out_hata_kodu             => v_hata_kodu,
                                                   in_listeden_gizle         => 'H',
                                                   in_sysdate                => SYSDATE,
                                                   in_otomatik_giris         => 'H',
                                                   in_outlet_location        => in_outlet_location,
                                                   in_iliski_outlet_location => NULL,
                                                   in_millenicom_id          => NULL,
                                                   in_sol_id                 => NULL,
                                                   in_ttnet_id               => NULL,
                                                   in_trepas_id              => in_iliskili_trepas_id,
                                                   in_co_status              => in_co_status, --in_co_status 'A',
                                                   in_co_kontrat_tarihi      => NULL
                                                  );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE electricity_ittp_eof_operation (in_account_number  IN     NUMBER,
                                             in_outlet_location IN     CHAR,
                                             in_application_id  IN     NUMBER,
                                             in_is_new_comer    IN     INTEGER, --0:Legacy 1:NewComer
                                             in_kullanici       IN     VARCHAR2,
                                             o_durum               OUT VARCHAR2
                                            ) IS
      v_count         NUMBER;
      v_sonraki_statu NUMBER;
      v_error_type    NUMBER;
      v_error_code    VARCHAR2 (10);
      v_promo_code    VARCHAR2 (512);
   BEGIN
      SELECT bs.int_promo_code
        INTO v_promo_code
        FROM dbs_dba.dt_internet_uye_basvuru bs
       WHERE bs.application_id = in_application_id;

      trepas_uyelik_iliskisi_olustur (in_account_number, in_outlet_location, in_application_id, 'A', in_kullanici, o_durum);

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      IF in_is_new_comer = 0 THEN --Mevuct üye 5: Paket islemleri sürecine gecer
         wf_islem_pack.wf_sonraki_statuye_gec (4,
                                               in_account_number,
                                               in_outlet_location,
                                               NULL,
                                               SYSDATE,
                                               5,
                                               'SYSTRE',
                                               v_sonraki_statu,
                                               o_durum,
                                               in_application_id
                                              );
      ELSE --Yeni Üye akis tamamlandiya gecer.
         wf_islem_pack.wf_uye_statusunu_degistir (4, in_account_number, in_outlet_location, NULL, SYSDATE, 7, 'SYSTRE', o_durum, in_application_id);
      END IF;

      IF o_durum != '0' THEN
         RETURN;
      END IF;

      dbs_dba.sf_pack.sf_sifre_kullanildi (v_promo_code,
                                           in_account_number,
                                           in_outlet_location,
                                           NULL,
                                           2,
                                           'C',
                                           in_kullanici,
                                           'DBS',
                                           v_error_type,
                                           v_error_code,
                                           o_durum
                                          );

      IF o_durum != '0' THEN
         RETURN;
      END IF;
   END;

   PROCEDURE dt_sol_vendor_doc_info_ins_upd (in_application_id       IN     dbs_dba.dt_sol_vendor_documents_info.application_id%TYPE,
                                             in_account_number       IN     dbs_dba.dt_sol_vendor_documents_info.account_number%TYPE,
                                             in_outlet_location      IN     dbs_dba.dt_sol_vendor_documents_info.outlet_location%TYPE,
                                             in_promo_code           IN     dbs_dba.dt_sol_vendor_documents_info.promo_code%TYPE,
                                             in_bayi_kodu            IN     dbs_dba.dt_sol_vendor_documents_info.bayi_kodu%TYPE,
                                             in_reason_code          IN     dbs_dba.dt_sol_vendor_documents_info.reason_code%TYPE,
                                             in_description          IN     dbs_dba.dt_sol_vendor_documents_info.description%TYPE,
                                             in_hata                 IN     dbs_dba.dt_sol_vendor_documents_info.hata%TYPE,
                                             in_giren_kullanici      IN     dbs_dba.dt_sol_vendor_documents_info.giren_kullanici%TYPE,
                                             in_degistiren_kullanici IN     dbs_dba.dt_sol_vendor_documents_info.degistiren_kullanici%TYPE,
                                             in_reason_code_status   IN     dbs_dba.dt_sol_vendor_documents_info.reason_code_status%TYPE,
                                             o_durum                    OUT VARCHAR2
                                            ) IS
      v_count NUMBER;
   BEGIN
      o_durum := '0';

      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.dt_sol_vendor_documents_info i
       WHERE i.application_id = in_application_id AND i.reason_code = in_reason_code;

      IF v_count = 0 THEN
         INSERT
           INTO dbs_dba.dt_sol_vendor_documents_info (id,
                                                      application_id,
                                                      account_number,
                                                      outlet_location,
                                                      promo_code,
                                                      bayi_kodu,
                                                      reason_code,
                                                      description,
                                                      hata,
                                                      giris_tarihi,
                                                      giren_kullanici,
                                                      degistirme_tarihi,
                                                      degistiren_kullanici,
                                                      reason_code_status
                                                     )
            VALUES (
                      dbs_dba.dt_sol_vendor_documen_info_seq.NEXTVAL,
                      in_application_id,
                      in_account_number,
                      in_outlet_location,
                      in_promo_code,
                      in_bayi_kodu,
                      in_reason_code,
                      in_description,
                      in_hata,
                      SYSDATE,
                      in_giren_kullanici,
                      SYSDATE,
                      in_degistiren_kullanici,
                      in_reason_code_status);
      ELSE
         UPDATE dbs_dba.dt_sol_vendor_documents_info
            SET degistirme_tarihi = SYSDATE, degistiren_kullanici = in_degistiren_kullanici, reason_code_status = in_reason_code_status
          WHERE application_id = in_application_id AND reason_code = in_reason_code;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.dt_sol_vendor_documen_info_ins' || SQLERRM;

         INSERT
           INTO dbs_dba.dt_sol_vendor_documents_info (id,
                                                      application_id,
                                                      account_number,
                                                      outlet_location,
                                                      promo_code,
                                                      bayi_kodu,
                                                      reason_code,
                                                      description,
                                                      hata,
                                                      giris_tarihi,
                                                      giren_kullanici,
                                                      degistirme_tarihi,
                                                      degistiren_kullanici,
                                                      reason_code_status
                                                     )
            VALUES (
                      dbs_dba.dt_sol_vendor_documen_info_seq.NEXTVAL,
                      in_application_id,
                      in_account_number,
                      in_outlet_location,
                      in_promo_code,
                      in_bayi_kodu,
                      in_reason_code,
                      in_description,
                      o_durum,
                      SYSDATE,
                      in_giren_kullanici,
                      SYSDATE,
                      in_degistiren_kullanici,
                      in_reason_code_status);
   END;

   PROCEDURE ddm_app_process_status_change (in_application_id             IN     dbs_dba.dt_internet_uye_basvuru.application_id%TYPE,
                                            in_application_process_status IN     dbs_dba.dt_internet_uye_basvuru.application_process_status%TYPE,
                                            in_assigned_to                IN     dbs_dba.dt_internet_uye_basvuru.assigned_to%TYPE,
                                            in_degistiren_kullanici       IN     dbs_dba.dt_internet_uye_basvuru.degistiren_kullanici%TYPE,
                                            o_durum                          OUT VARCHAR2
                                           ) IS
   BEGIN
      o_durum := '0';

      UPDATE dbs_dba.dt_internet_uye_basvuru
         SET application_process_status = in_application_process_status,
             assigned_to                = in_assigned_to,
             degistiren_kullanici       = in_degistiren_kullanici,
             degistirme_tarihi          = SYSDATE
       WHERE application_id = in_application_id;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.dt_internet_uye_basvuru_draft' || SQLERRM;
   END;

   PROCEDURE trepas_activation_control (in_kullanici IN VARCHAR2, o_durum OUT VARCHAR2) IS
      v_sales_agent_code            dbs_dba.dt_internet_uye_basvuru.bayi_kodu%TYPE;
      v_arama_yonlendirme_detay_id  dbs_dba.bt_yts_arama_yonlendirme_detay.id%TYPE;
      v_stb_type                    dbs_dba.bt_yts_arama_yonlendirme.stb_tipi%TYPE := 'PH';
      v_dt_setup_memo_kodu          dbs_dba.co_memo_bilgi.memo_kodu%TYPE := TO_NUMBER (dbs_sabit ('ELEKTRIK_turk_KURULUM_MEMO_KODU'));
      v_dt_bayi_kodu_hata_memo_kodu dbs_dba.co_memo_bilgi.memo_kodu%TYPE := TO_NUMBER (dbs_sabit ('ELEKTRIK_KAMPANYASI_BAYI_KODU_HATASI_MEMO_KODU'));
      v_user_code                   VARCHAR2 (10) := in_kullanici; --'SYSTRE';
      o_result_type                 NUMBER;
      o_result_code                 VARCHAR2 (10);
      o_result_message              VARCHAR2 (1000) := '0';
      v_gsm_no                      VARCHAR2 (20);
      v_count                       NUMBER := 0;
      v_memo_id                     NUMBER;
      v_sms_text                    VARCHAR2 (155) := dbs_sabit ('ELEKTRIK_turk_BASVURU_OLUMSUZ_SMS');
      v_hatali_teklif_memo_kodu     dbs_dba.co_memo_bilgi.memo_kodu%TYPE := TO_NUMBER (dbs_sabit ('ELEKTRIK_TALEP_YENI_UYE_MEMO_KODU'));
      v_error_detail                VARCHAR2 (1000);
      v_current_segment_status      CHAR (1) := NULL;
      v_next_segment_status         CHAR (1) := NULL;
   BEGIN
      o_durum := '0';

      -- Trepas'dan OK geldi artık -->Segment bilgiside gelmişse Kurulum memosu acilip bayiye yönlendirme yapilmalidir.
      -- Prospect ise trepas'da beklemede ,Account ise üyelik statüsü baz alinacaktir.
      FOR rec
         IN (SELECT dt.*, sg.segment_name, sg.segment_info, sg.segment_description, sg.promo_code, sg.segment_status
               FROM dbs_dba.dt_internet_uye_basvuru dt,
                    dbs_dba.wf_tb_uye_statu wf,
                    dbs_dba.dt_provider_segment_info sg
              WHERE     dt.provider = 4
                    AND dt.application_id = wf.application_id
                    AND wf.durum = 'A'
                    AND ( (wf.account_number IS NOT NULL AND wf.statu = 3) OR (wf.potansiyel_number IS NOT NULL AND wf.statu = 2))
                    AND dt.int_promo_code = sg.promo_code
                    AND dt.application_id = sg.application_id
                    AND dt.provider = sg.provider
                    AND sg.segment_status IN ('O', 'W')) LOOP
         BEGIN
            v_current_segment_status := rec.segment_status;

            IF rec.provider_application_status IS NOT NULL THEN --TODO: Başvuru olumlu veya olumsuz farketmeksizin mi memo açılmalımıdır?
               IF rec.provider_application_status = 'OK' THEN
                  IF rec.account_number IS NOT NULL THEN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM dbs_dba.dt_internet_uye_paket pk
                      WHERE pk.provider = 4 AND pk.segment_name = rec.segment_name AND pk.segment_name = rec.segment_info AND pk.promo_code = rec.promo_code;

                     --Drafttaki teklif ile Trepas'dan gelen teklif esit ise statu 5 e cekilir
                     IF v_count > 0 THEN
                        dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (i_wf_tip            => 4,
                                                                         i_account_number    => rec.account_number,
                                                                         i_outlet_location   => rec.outlet_location,
                                                                         i_potansiyel_number => rec.prospect_number,
                                                                         i_valid_after       => SYSDATE,
                                                                         i_yeni_statu        => 5, --Elektrik üyelik islemleri
                                                                         i_giren_kullanici   => v_user_code,
                                                                         o_durum             => o_result_message,
                                                                         i_application_id    => rec.application_id
                                                                        );

                        IF o_result_message <> '0' THEN
                           o_result_type    := 1;
                           o_result_code    := 'ERR2154';
                           o_result_message := 'Elektrik İslemleri Statusune gecirilemedi!';
                        --DBMS_OUTPUT.put_line ('o_result_message : ' || o_result_message);
                        END IF;
                     ELSE
                        SELECT COUNT (1)
                          INTO v_count
                          FROM dbs_dba.dt_internet_uye_paket pk
                         WHERE pk.provider = 4 AND pk.promo_code = rec.promo_code;

                        IF v_count > 0 THEN
                           --ekrandan secili teklif trepasdan gelen teklifle uyusmadi teklifin duzeltilmesi lazim
                           --memo acilip teklif ve paket secme ekranına yönlendirme saglanmali
                           memo_pack.co_memo_bilgi_insert_out_id (v_memo_kodu               => v_hatali_teklif_memo_kodu, --ELEKTRIK KAMP. YARARLANMAK ISTIYORUM
                                                                  v_memo_aciklama           => 'TREPAS ELEKTRIK KURULUM MEMO ACIKLAMA',
                                                                  v_abone                   => rec.account_number,
                                                                  v_potansiyel              => rec.prospect_number,
                                                                  v_bayi_ts                 => NULL,
                                                                  v_durum_kodu              => dbs_sabit ('MEMO_MUSTERIYE_DON_DURUM'),
                                                                  v_onem_kodu               => 2, /*1-ÇOK ÖNEMLİ,2-ÖNEMLİ,3-ÖNEM DRC.DÜŞÜK,4-ÖNEMSİZ*/
                                                                  v_giren_kullanici         => 'SYSTRE', --tredas icin user
                                                                  v_acilis_tarihi           => SYSDATE,
                                                                  v_kapatan_kullanici       => NULL, --hemen kapat olursa kapatan kullanici belirtilmeli
                                                                  v_kapanis_tarihi          => NULL, --hemen kapat olursa kapanis tarihi belirtilmeli
                                                                  v_yonlendirilen_kullanici => rec.bayi_kodu,
                                                                  v_silinme_tarihi          => NULL,
                                                                  v_sonuc                   => o_result_type,
                                                                  v_memo_id                 => v_memo_id,
                                                                  v_yonlendirilen_kisi_tipi => 1, --1:Bayi ,2:Kisi
                                                                  v_kaynak                  => 67 --TREPAS ELEKTRIK KURULUM MEMO KAYNAK
                                                                 );

                           IF o_result_type <> 0 THEN
                              o_result_message := 'MEVCUT ÜYE ETIC-DİGİTURK ELEKTİRK KAMPNYASI TALEP MEMOSU ACİLAMADI :' || o_result_type;
                              o_result_type    := 1;
                              o_result_code    := 'ERR2155';
                           END IF;
                        ELSE
                           --DBMS_OUTPUT.put_line ('yeni üye=' || rec.account_number);
                           -- yeni üye basvuru statüsü 3-->5 e gecer
                           -- dt_internet_uye_paket herhangi bir paket secimine gerek yoktur
                           dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (4,
                                                                            rec.account_number,
                                                                            rec.outlet_location,
                                                                            NULL,
                                                                            SYSDATE,
                                                                            5,
                                                                            v_user_code,
                                                                            o_result_message,
                                                                            rec.application_id
                                                                           );

                           IF o_result_message != '0' THEN
                              o_result_type    := 1;
                              o_result_code    := 'ERR2156';
                              o_result_message := 'Yeni üye statüsü değiştirilemedi-' || o_result_message;
                              DBMS_OUTPUT.put_line ('yeni üye=' || o_result_message);
                           END IF;
                        --CONTINUE;
                        END IF;
                     END IF;
                  ELSIF rec.account_number IS NULL AND rec.prospect_number IS NOT NULL THEN
                     IF rec.bayi_kodu IS NOT NULL THEN
                        IF rec.is_setup_belong_to_me = 'E' THEN
                           --Bayi kodu var ama aktif olup olmadigina bakilmalidir
                           o_result_message   := '0';
                           v_sales_agent_code := rec.bayi_kodu;
                        ELSIF rec.is_setup_belong_to_me = 'H' THEN
                           IF rec.int_city IS NOT NULL AND rec.int_county IS NOT NULL AND rec.int_district IS NOT NULL THEN
                              dbs_dba.bayi_arama_yonlendirme_pack.yonlendirilecek_ts_bul (
                                 iprospect_number            => rec.prospect_number,
                                 iil                         => rec.int_city,
                                 iilce                       => rec.int_county,
                                 imahalle                    => rec.int_district,
                                 istb_tipi                   => v_stb_type,
                                 iis_tipi                    => 2,
                                 ikullanici                  => v_user_code,
                                 oyts                        => v_sales_agent_code,
                                 oarama_yonlendirme_detay_id => v_arama_yonlendirme_detay_id,
                                 odurum                      => o_result_message,
                                 iulke                       => NLS_UPPER (rec.int_country, 'nls_sort=xturkish'));

                              --Il,ilce,mahalle bilgisi dolu ise once kontrol edilir uygun yts varmi diye
                              --Sayet yts bulunamazsa ve bayi kodu gonderilmisse gonderilen bayi kodu ile devam edilecektir.
                              IF o_result_message <> '0' THEN
                                 o_result_message   := '0';
                                 v_sales_agent_code := rec.bayi_kodu;
                              END IF;
                           ELSE
                              o_result_message   := '0';
                              v_sales_agent_code := rec.bayi_kodu;
                           END IF;
                        END IF;
                     ELSE
                        IF rec.int_city IS NOT NULL AND rec.int_county IS NOT NULL AND rec.int_district IS NOT NULL THEN
                           dbs_dba.bayi_arama_yonlendirme_pack.yonlendirilecek_ts_bul (
                              iprospect_number            => rec.prospect_number,
                              iil                         => rec.int_city,
                              iilce                       => rec.int_county,
                              imahalle                    => rec.int_district,
                              istb_tipi                   => v_stb_type,
                              iis_tipi                    => 2,
                              ikullanici                  => v_user_code,
                              oyts                        => v_sales_agent_code,
                              oarama_yonlendirme_detay_id => v_arama_yonlendirme_detay_id,
                              odurum                      => o_result_message,
                              iulke                       => NLS_UPPER (rec.int_country, 'nls_sort=xturkish'));
                        ELSE
                           o_result_type    := 1;
                           o_result_code    := 'ERR2157';
                           o_result_message := 'Bölgeye bakan bayinin bulunması için il/ilçe/mahalle bilgisi gerekmektedir.';
                        END IF;
                     END IF;

                     IF o_result_message = '0' THEN
                        --o bölgeye bakan yts aktif bir yts olmalı
                        SELECT COUNT (*)
                          INTO v_count
                          FROM vv_bayi_teknik_servis
                         WHERE sales_agent_code = v_sales_agent_code;

                        IF v_count = 0 THEN
                           o_result_type    := 1;
                           o_result_code    := 'ERR2158';
                           o_result_message := 'Bu bölgeye bakan aktif bir YTS bulunamadi.';
                        --DBMS_OUTPUT.put_line ('o_result_message : Bu bölgeye bakan aktif bir YTS bulunamadi.');
                        END IF;

                        IF v_count > 0 THEN
                           --İlgili potansiyel icin bulunan bayi koduna Digitürk Kurulum mmemosu açılıyor...
                           -- v_yonlendirilen_kisi_tipi : 1=>Bayiye Yönlendirme v_yonlendirilen_kullanici Bayi olmalidir
                           -- v_yonlendirilen_kisi_tipi: 2 => DBS Kullanicisina Yönlendirme.  v_yonlendirilen_kullanici DBS Kullanicisi olmalidir
                           memo_pack.co_memo_bilgi_insert_out_id (v_memo_kodu               => v_dt_setup_memo_kodu, --turk KURULUM
                                                                  v_memo_aciklama           => 'TREPAS turk KURULUM MEMOSU',
                                                                  v_abone                   => rec.account_number,
                                                                  v_potansiyel              => rec.prospect_number,
                                                                  v_bayi_ts                 => v_sales_agent_code,
                                                                  v_durum_kodu              => dbs_sabit ('MEMO_MUSTERIYE_DON_DURUM'),
                                                                  v_onem_kodu               => 2, /*1-ÇOK ÖNEMLİ,2-ÖNEMLİ,3-ÖNEM DRC.DÜŞÜK,4-ÖNEMSİZ*/
                                                                  v_giren_kullanici         => 'SYSTRE', --tredas icin user
                                                                  v_acilis_tarihi           => SYSDATE,
                                                                  v_kapatan_kullanici       => NULL,
                                                                  v_kapanis_tarihi          => NULL,
                                                                  v_yonlendirilen_kullanici => v_sales_agent_code,
                                                                  v_silinme_tarihi          => NULL,
                                                                  v_sonuc                   => o_result_type,
                                                                  v_memo_id                 => v_memo_id,
                                                                  v_yonlendirilen_kisi_tipi => 1, --1:Bayi, 2:Kişi
                                                                  v_kaynak                  => 67 --TREPAS ELEKTRIK KURULUM MEMO KAYNAK
                                                                 );
                        END IF;

                        IF o_result_type <> 0 THEN
                           o_result_type    := 1;
                           o_result_code    := 'ERR2159';
                           o_result_message := 'Trepas-turk kampanyasi turk kurulum memosu olsturulamadi.';
                           --DBMS_OUTPUT.put_line ('o_result_message : ' || o_result_message);
                           --Bayi kodu hatasi veya bayiye acilan memolarda hata alininca acquisition ekibine yonlendirme memosu
                           -- ELEKTRIK_KAMPANYASI_BAYI_KODU_HATASI_MEMO_KODU
                           memo_pack.co_memo_bilgi_insert_out_id (v_memo_kodu               => v_dt_bayi_kodu_hata_memo_kodu, --turk KURULUM
                                                                  v_memo_aciklama           => 'ELEKTRIK_KAMPANYASI_BAYI_KODU_HATA_MEMOSU',
                                                                  v_abone                   => rec.account_number,
                                                                  v_potansiyel              => rec.prospect_number,
                                                                  v_bayi_ts                 => NULL,
                                                                  v_durum_kodu              => dbs_sabit ('MEMO_MUSTERIYE_DON_DURUM'),
                                                                  v_onem_kodu               => 2, /*1-ÇOK ÖNEMLİ,2-ÖNEMLİ,3-ÖNEM DRC.DÜŞÜK,4-ÖNEMSİZ*/
                                                                  v_giren_kullanici         => 'SYSTRE', --tredas icin user
                                                                  v_acilis_tarihi           => SYSDATE,
                                                                  v_kapatan_kullanici       => NULL,
                                                                  v_kapanis_tarihi          => NULL,
                                                                  v_yonlendirilen_kullanici => NULL, --acquisition
                                                                  v_silinme_tarihi          => NULL,
                                                                  v_sonuc                   => o_result_type,
                                                                  v_memo_id                 => v_memo_id,
                                                                  v_yonlendirilen_kisi_tipi => 2, --1:Bayi, 2:Kişi
                                                                  v_kaynak                  => 67 --TREPAS ELEKTRIK KURULUM MEMO KAYNAK
                                                                 );

                           IF o_result_type <> 0 THEN
                              o_result_type    := 1;
                              o_result_code    := 'ERR2160';
                              o_result_message := 'Trepas-turk kampanyasi hatali bayi kodu memosu olsturulamadi.';
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            ELSE --NOT OK
               --üyenin aranmasi için memo acilabilir veya basvuru esnasında belirtilen gsm_no icin başvuru olumsusz sms'i gönderilebilir.
               --gsm_no:90'li olmalidir.
               -- sms text: dbs_sabit e baglanabilir.
               v_current_segment_status := 'W';

               IF rec.int_mobile_country_code IS NOT NULL AND rec.int_mobile_area_code IS NOT NULL AND rec.int_mobile_number IS NOT NULL THEN
                  v_gsm_no := TRIM (rec.int_mobile_country_code) || TRIM (rec.int_mobile_area_code) || TRIM (rec.int_mobile_number);

                  dbs_dba.kontrat_pack.send_quick_sms (itelefon_no => v_gsm_no, itext => v_sms_text, odurum => o_result_message, ititle => 'turk');

                  IF o_result_message <> '0' THEN
                     o_result_type    := 1;
                     o_result_code    := 'ERR2161';
                     o_result_message := 'Trepas-turk kampanyasi turk kurulum memosu olsturulamadi.';
                  --DBMS_OUTPUT.put_line ('o_result_message : ' || o_result_message);
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               v_error_detail := SUBSTR (SQLERRM, 512);
         END;

         IF o_result_message = '0' THEN
            IF v_current_segment_status = 'O' THEN
               v_next_segment_status := 'W';
            ELSIF v_current_segment_status = 'W' THEN
               v_next_segment_status := 'C';
            END IF;

            UPDATE dbs_dba.dt_provider_segment_info
               SET segment_status = v_next_segment_status
             WHERE promo_code = rec.promo_code;

            COMMIT;
         ELSE
            ROLLBACK;
         END IF;

         dbs_dba.dt_sol_webservice_pack.dt_sol_ws_hata_log_save (in_module          => 'turkTredasServiceApproveBatch',
                                                                 in_error_type      => o_result_type,
                                                                 in_error_code      => o_result_code,
                                                                 in_error_message   => o_result_message,
                                                                 in_error_detail    => v_error_detail,
                                                                 in_promo_code      => rec.int_promo_code,
                                                                 in_giren_kullanici => v_user_code,
                                                                 in_account_number  => rec.account_number,
                                                                 in_outlet_location => rec.outlet_location,
                                                                 in_application_id  => rec.application_id,
                                                                 in_prospect_number => rec.prospect_number
                                                                );
         o_durum := o_result_message;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'dbs_dba.internet_islem_pack.trepas_activation_control' || SUBSTR (SQLERRM, 512);
   END;
   
/* Formatted on 04/02/2015 09:04:21 (QP5 v5.252.13127.32867) */
   PROCEDURE app_return_to_vendor_waiting (in_application_id  IN     NUMBER,
                                        in_account_number  IN     NUMBER,
                                        in_outlet_location IN     VARCHAR2,
                                        in_promo_code      IN     VARCHAR2,
                                        in_kullanici       IN     VARCHAR2,
                                        o_durum               OUT VARCHAR2
                                       ) IS
       v_lg_sf_urun_id NUMBER;
       v_sifre_gizli   sf_urun.gizli_no%TYPE;
       rec_sf          sf_urun%ROWTYPE;
       rec_bsv         dbs_dba.dt_internet_uye_basvuru%ROWTYPE;
       rec_svc_int     dbs_dba.wiz_customer_hp_svc_int%ROWTYPE;
       rec_iliski      dbs_dba.gl_kisi_bilgi_iliski%ROWTYPE;
       v_count         NUMBER := 0;
       v_guncel_statu  NUMBER;
       v_status_desc   VARCHAR2 (150);
    BEGIN
       o_durum := '0';
       v_count            := v_count + 1;
       v_sifre_gizli      := dbs_dba.digipaket_sifre.encrypt (in_promo_code);


       --DBMS_OUTPUT.put_line ('############################## ' || in_promo_code || '##############################');

       --DBMS_OUTPUT.put_line ('v_sifre_gizli=' || v_sifre_gizli);

       -- üyenin statüsüne bak
       dbs_dba.wf_islem_pack.wf_guncel_statusunu_getir (3, in_account_number, in_outlet_location, NULL, v_guncel_statu, o_durum, in_application_id);

       IF o_durum != '0' THEN
          o_durum := 'Başvuru başka üyeliğe taşınamaz:Üyenin guncel statüsü bulunamadı.Hata : ' || o_durum;
          --DBMS_OUTPUT.put_line ('promo_code=' || in_promo_code || ':' || o_durum);
          --ROLLBACK;
          --CONTINUE;
         RETURN;
       END IF;

       IF v_guncel_statu NOT IN (5, 7) THEN
          BEGIN
             SELECT aciklama
               INTO v_status_desc
               FROM dbs_dba.wf_pr_statu_tanim
              WHERE tip = 3 AND statu = v_guncel_statu;
          EXCEPTION
             WHEN OTHERS THEN
                v_status_desc := '[Undefined]';
          END;

          o_durum := v_status_desc || ' statüsünde ki başvuru için bu işlem yapilamaz.! ';
          RETURN;
       END IF;

       BEGIN
          SELECT *
            INTO rec_sf
            FROM sf_urun
           WHERE urun_grup_kod = 1117 AND gizli_no = v_sifre_gizli OR reserved_gizli_no = v_sifre_gizli;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             o_durum := 'Başvuru başka üyeliğe taşınamaz: Hata:' || SUBSTR (SQLERRM, 512);
             --DBMS_OUTPUT.put_line ('promo_code=' || in_promo_code || ':' || o_durum);
             --CONTINUE;
         RETURN;
       END;

       SELECT dbs_dba.lg_sf_urun_id_seq.NEXTVAL INTO v_lg_sf_urun_id FROM DUAL;

       INSERT
         INTO dbs_dba.lg_sf_urun (id,
                                  kisi,
                                  islem,
                                  islem_tarihi,
                                  seri_no,
                                  gizli_no,
                                  durum,
                                  detay_durum,
                                  effective_date,
                                  expire_date,
                                  urun_grup_kod,
                                  urun_tasarim_id,
                                  account_number,
                                  outlet_location,
                                  depoya,
                                  depodan,
                                  kaynak,
                                  aciklama,
                                  reserved_account_number,
                                  reserved_outlet_location,
                                  reserved_prospect_number,
                                  reserved_gizli_no
                                 )
          VALUES (
                    v_lg_sf_urun_id,
                    in_kullanici,
                    'U',
                    SYSDATE,
                    rec_sf.seri_no,
                    rec_sf.gizli_no,
                    rec_sf.durum,
                    rec_sf.detay_durum,
                    rec_sf.effective_date,
                    rec_sf.expire_date,
                    rec_sf.urun_grup_kod,
                    rec_sf.urun_tasarim_id,
                    rec_sf.account_number,
                    rec_sf.outlet_location,
                    NULL, --depoya
                    rec_sf.equip_location_code,
                    rec_sf.kaynak,
                    rec_sf.aciklama,
                    rec_sf.reserved_account_number,
                    rec_sf.reserved_outlet_location,
                    rec_sf.reserved_prospect_number,
                    rec_sf.reserved_gizli_no);

       DBMS_OUTPUT.put_line ('v_lg_sf_urun_id=' || v_lg_sf_urun_id);

       UPDATE dbs_dba.sf_urun
          SET durum = 'V', --reserved_account_number  = v_reserved_account_number,
                           --reserved_outlet_location = v_reserved_outlet_location,
                           --account_number           = v_account_number,
                           --outlet_location          = v_outlet_location,
                           -- equip_location_code      = 'HBM',
               degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
        WHERE seri_no = rec_sf.seri_no;

       DBMS_OUTPUT.put_line ('sf_urun=' || rec_sf.seri_no);

       UPDATE dbs_dba.dt_internet_uye_basvuru
          SET status = 3, degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
        WHERE application_id = rec_bsv.application_id;

       /*Statü güncellemeleri*/
       DELETE FROM dbs_dba.wf_tb_uye_statu
             WHERE statu_tanim_tip = 3 AND statu > 3 AND application_id = in_application_id;

       UPDATE dbs_dba.wf_tb_uye_statu
          SET durum = 'A', degistirme_tarihi = SYSDATE, degistiren_kullanici = in_kullanici
        WHERE application_id = in_application_id AND statu = 3;

       DELETE FROM dbs_dba.wf_tb_uye_islem
             WHERE pr_islem_id = 4 AND account_number = in_account_number AND outlet_location = in_outlet_location;

       BEGIN
          SELECT *
            INTO rec_svc_int
            FROM dbs_dba.wiz_customer_hp_svc_int
           WHERE promo_code = in_promo_code;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             rec_svc_int.id := NULL;
       END;

       IF rec_svc_int.id IS NOT NULL THEN
          DBMS_OUTPUT.put_line ('rec_svc_int.id=' || rec_svc_int.id);

          dbs_dba.internet_basvuru_pack.ins_wiz_cus_hp_svc_int_log (rec_svc_int.outlet_location,
                                                                    rec_svc_int.account_number,
                                                                    rec_svc_int.service_code,
                                                                    rec_svc_int.sales_code,
                                                                    rec_svc_int.salesperson,
                                                                    SYSDATE, --in_drop_date
                                                                    'DZM', --in_drop_code
                                                                    rec_svc_int.add_closed_date, -- in_add_closed_date
                                                                    SYSDATE, -- in_drop_closed_date
                                                                    rec_svc_int.id,
                                                                    rec_svc_int.promo_expire_date,
                                                                    rec_svc_int.servis_frekansi,
                                                                    rec_svc_int.servis_fiyati,
                                                                    in_kullanici,
                                                                    SYSDATE,
                                                                    in_kullanici, --dusuren_kullanici
                                                                    SYSDATE,
                                                                    in_kullanici, --degistiren_kullanici
                                                                    rec_svc_int.provider,
                                                                    rec_svc_int.promo_code
                                                                   );

          DELETE FROM dbs_dba.wiz_customer_hp_svc_int
                WHERE id = rec_svc_int.id;
       END IF;

       BEGIN
          SELECT *
            INTO rec_iliski
            FROM dbs_dba.gl_kisi_bilgi_iliski
           WHERE listeden_gizle = 'H' AND sol_id = in_application_id;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             rec_iliski.iliski_id := NULL;
       END;

       IF rec_iliski.iliski_id IS NOT NULL THEN
          INSERT
            INTO dbs_dba.lg_gl_kisi_bilgi_iliski (id,
                                                  kisi,
                                                  islem,
                                                  islem_tarihi,
                                                  kisi_bilgi_id,
                                                  account_number,
                                                  prospect_number,
                                                  bb_user_id,
                                                  eslestirme_tipi_id,
                                                  iliski_kisi_bilgi_id,
                                                  iliski_account_number,
                                                  iliski_prospect_number,
                                                  listeden_gizle,
                                                  aciklama,
                                                  dd_user_id,
                                                  bp_user_id,
                                                  da_user_id,
                                                  millenicom_id,
                                                  sol_id,
                                                  ttnet_id,
                                                  iliski_id,
                                                  status
                                                 )
             VALUES (
                       dbs_dba.lg_gl_kisi_bilgi_iliski_id_seq.NEXTVAL,
                       in_kullanici,
                       'D',
                       SYSDATE,
                       rec_iliski.kisi_bilgi_id,
                       rec_iliski.account_number,
                       rec_iliski.prospect_number, --null
                       rec_iliski.bb_user_id, --null
                       rec_iliski.eslestirme_tipi_id, --36
                       rec_iliski.iliski_kisi_bilgi_id,
                       rec_iliski.iliski_account_number,
                       rec_iliski.iliski_prospect_number,
                       rec_iliski.listeden_gizle,
                       rec_iliski.aciklama,
                       rec_iliski.dd_user_id,
                       rec_iliski.bp_user_id,
                       rec_iliski.da_user_id,
                       rec_iliski.millenicom_id,
                       rec_iliski.sol_id,
                       rec_iliski.ttnet_id,
                       rec_iliski.iliski_id,
                       'V');

          DELETE FROM dbs_dba.gl_iliski_detay
                WHERE iliski_id = rec_iliski.iliski_id;

          --eski üye icin iliski_silinir
          DELETE FROM dbs_dba.gl_kisi_bilgi_iliski
                WHERE iliski_id = rec_iliski.iliski_id;
       END IF;
    END;

END;
/
