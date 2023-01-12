CREATE OR REPLACE PACKAGE BODY DBS_DBA.abone_batch_pack IS
   ----------------------------------------------------------------------------------------alpay
   -- Üzerinde servis tanimi olmayan bekleyen statudeki ilgili abonelerin outletleri
   -- toplu olarak iptal edecek.
   -- Her ayin 3'inde çalisarak, IE_UYELIK_IPTAL kayitlarini olusturacak.
   -- CLOSE_BATCH programi da bu kayitlar üzerinden iptal gerçeklestirecek.
   PROCEDURE uyelik_iptal IS
      CURSOR cbekleyenabone  IS
         SELECT a.account_number, b.outlet_location, a.service_address_id
           FROM wiz_customer_hp_life a,
                mb_abone_statu b
          WHERE     a.account_number = b.account_number
                AND a.customer_status = 'AC'
                AND b.statu = 'W'
                AND ADD_MONTHS (TRUNC (statu_tarihi), 3) < TRUNC (SYSDATE)
                AND (   (    a.franchise_code IN ('F02', 'F03', 'F04')
                         AND a.customer_type IN (SELECT customer_type -- Ticari
                                                   FROM wiz_customer_type_codes
                                                  WHERE TRIM (privileged_flag) = 'N' AND TRIM (abbrev) = '2'))
                     OR a.franchise_code NOT IN ('F01', 'F02', 'F03', 'F04'));

      eskipthisclient       EXCEPTION;
      enull                 EXCEPTION;
      vlogmessage           VARCHAR2 (100);
      vdurum                VARCHAR2 (100);
      vcount                NUMBER;
      vuyelikiptalid        ie_uyelik_iptal.id%TYPE;
      vgirenkullanici       co_kullanici.kod%TYPE;
      -- vserviceadressid    wiz_customer_hp_svc.service_address_id%TYPE;
      voutlog               VARCHAR2 (100);
      vsuccessrecordcount   NUMBER := 0;
      p_return_status       VARCHAR2 (1);
      v_taa_uyari           VARCHAR2 (512);

      v_ittp_order_int_open NUMBER;

      FUNCTION systemdate
         RETURN DATE IS
      BEGIN
         RETURN SYSDATE; -- RETURN  '01-JAN-2006';
      END;
   BEGIN
      --vgirenkullanici := NVL (pgirenkullanici, 'SYSTEM');
      vgirenkullanici       := 'SYSTEM';
      dt_profiler.start_profiler;

      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      FOR vbekleyenabone IN cbekleyenabone LOOP
         BEGIN
            abone_islem_pack.abone_islem (vbekleyenabone.account_number, p_return_status, vdurum);

            IF p_return_status != '0' THEN
               vlogmessage := vdurum;
               RAISE eskipthisclient;
            END IF;

            -- Üzerinde servis ve is emri olan aboneler iptal edilmez.
            -- Bsarcan 13.12.2013
            IF v_ittp_order_int_open = 0 THEN
               SELECT COUNT (1)
                 INTO vcount
                 FROM wiz_customer_hp_svc
                WHERE account_number = vbekleyenabone.account_number AND outlet_location = vbekleyenabone.outlet_location;
            ELSIF v_ittp_order_int_open = 1 THEN
               SELECT COUNT (1)
                 INTO vcount
                 FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                WHERE account_number = vbekleyenabone.account_number AND outlet_location = vbekleyenabone.outlet_location;
            END IF;

            IF vcount > 0 THEN
               vlogmessage := 'Bu outlet için servis tanimi mevcut, AccountNo = ' || vbekleyenabone.account_number;
               RAISE eskipthisclient;
            END IF;

            --            IF v_ittp_order_int_open = 0 THEN
            --               SELECT COUNT (1)
            --                 INTO vcount
            --                 FROM wiz_work_order o,
            --                      wiz_wo_line_items l
            --                WHERE     o.work_order_number = l.work_order_number
            --                      AND l.outlet_location = vbekleyenabone.outlet_location
            --                      AND account_number = vbekleyenabone.account_number
            --                      AND o.wo_status IN ('P', 'O')
            --                      AND l.wo_status = 'O';
            --ELSIF v_ittp_order_int_open = 1 THEN
            SELECT COUNT (1)
              INTO vcount
              FROM dt_dbs_int_dba.vv_ittp_customer_order wo
             WHERE     wo.dbs_outlet_location = vbekleyenabone.outlet_location
                   AND wo.dbs_account_number = vbekleyenabone.account_number
                   AND wo.work_order_statu = ('ACIK')
                   AND wo.work_line_statu = ('ACIK')
                   AND wo.havadan_flag = 0;

            --END IF;

            IF vcount > 0 THEN
               vlogmessage := 'Bu outlet için is emri tanimi mevcut: ' || vbekleyenabone.account_number || '-' || vbekleyenabone.outlet_location;
               RAISE eskipthisclient;
            END IF;

            SELECT COUNT (1)
              INTO vcount
              FROM ie_uyelik_iptal
             WHERE account_number = vbekleyenabone.account_number AND outlet_location = vbekleyenabone.outlet_location AND durum = 'O';

            IF vcount > 0 THEN
               vlogmessage := 'Bu outlet için üyelik iptali mevcut, AccountNo = ' || vbekleyenabone.account_number;
               RAISE enull;
            END IF;

            vuyelikiptalid      := 0;
            uyelik_iptali_pack.uyelik_iptal_insert_update (vuyelikiptalid,
                                                           vbekleyenabone.account_number,
                                                           vbekleyenabone.service_address_id,
                                                           vbekleyenabone.outlet_location,
                                                           'H', -- in_ekipman_sokulecek_mi,
                                                           NULL, -- in_ekipman_depo_lokasyon,
                                                           NULL, -- in_work_order_number,
                                                           NULL, -- in_atanan_ts,
                                                           systemdate,
                                                           -- in_ts_atanma_tarihi,
                                                           NULL, -- in_ts_form_no,
                                                           systemdate,
                                                           -- in_beklenen_kapanma_tarihi,
                                                           vgirenkullanici,
                                                           'O', -- durum
                                                           NULL, -- in_aciklama,
                                                           'TIP',
                                                           v_taa_uyari,
                                                           vdurum
                                                          );

            IF vdurum <> '0' THEN
               vlogmessage := vdurum;
               RAISE eskipthisclient;
            END IF;

            vsuccessrecordcount := vsuccessrecordcount + 1;
         EXCEPTION
            WHEN enull THEN
               NULL;
            WHEN eskipthisclient THEN
               log_pack.log_is_emri_hata (NULL, NULL, vuyelikiptalid, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                                      vgirenkullanici, systemdate, 'O', vlogmessage, voutlog);
            WHEN OTHERS THEN
               vlogmessage := SUBSTR (SQLERRM, 1, 100);
               log_pack.log_is_emri_hata (NULL, NULL, vuyelikiptalid, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                                      vgirenkullanici, systemdate, 'O', vlogmessage, voutlog);
         END;

         COMMIT;
      END LOOP;

      /* DEBUG AMAÇLI teste kaç kayit iptal edildigi görülür sonra kaldirilir
      log_pack.log_is_emri_hata (NULL,
                                 NULL,
                                 vuyelikiptalid,
                                 NULL,
                                 NULL,
                                 'J',    -- job ile uyelik iptali toplu islemi
                                 vgirenkullanici,
                                 systemdate,
                                 'O',
                                    vsuccessrecordcount
                                 || ' adet outlet iptal kaydi yaratildi',
                                 voutlog
                                );
      */
      dt_profiler.stop_profiler;
   EXCEPTION
      WHEN OTHERS THEN
         log_pack.log_is_emri_hata (NULL, NULL, vuyelikiptalid, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                                vgirenkullanici, systemdate, 'O', SUBSTR (SQLERRM, 1, 100), voutlog);
         COMMIT;
   END;

   PROCEDURE insert_log (description IN VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      out_durum VARCHAR2 (512);
   BEGIN
      log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                   'SYSTEM', SYSDATE, NULL, SUBSTR (description, 1, 200), out_durum);

      IF out_durum = '0' THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   PROCEDURE abone_dogum_gunu_kupon_mail_at (in_gonderi_sekil_id               NUMBER,
                                             in_account_number                 NUMBER,
                                             in_adsoyad                        VARCHAR2,
                                             in_email                          VARCHAR2,
                                             out_durum                     OUT VARCHAR2,
                                             in_abone_bedava_hediye_ata IN     BOOLEAN := FALSE,
                                             in_abone_hediye_tipi       IN     NUMBER := 1,
                                             in_franchise_code          IN     wiz_customer_hp_life.hp_cluster%TYPE,
                                             in_service_account_id      IN     NUMBER := 0
                                            ) IS
      v_gonderi_id          NUMBER (10);
      v_gonderi_confirm     VARCHAR2 (10);
      v_email_from          VARCHAR2 (100);
      v_mail_subject        VARCHAR2 (250);
      v_gonderi_tanim_id    NUMBER (10);
      v_gonderi_session_id  NUMBER (10);
      v_sure                NUMBER (5);
      v_ittp_order_int_open NUMBER;
      v_tmp_number          NUMBER;
      v_tmp_str             VARCHAR2 (300);

      PROCEDURE get_gonderi_info (i_gonderi_kod IN VARCHAR2, o_gonderi_tanim_id OUT NUMBER, o_gonderi_session_id OUT NUMBER) IS
      BEGIN
         SELECT gt.id AS gonderi_tanim_id, gs.gon_gonderi_session_id AS gonderi_session_id
           INTO o_gonderi_tanim_id, o_gonderi_session_id
           FROM dbs_dba.gon_gonderi_tanim gt LEFT JOIN dbs_dba.gon_gonderi_session gs ON gt.id = gs.gonderi_tanim_id
          WHERE gt.kod = i_gonderi_kod AND ROWNUM < 2;
      EXCEPTION
         WHEN OTHERS THEN
            o_gonderi_tanim_id   := 0;
            o_gonderi_session_id := 0;
      END;
   BEGIN
      out_durum             := '0';

      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      --test icin parametreler girilmistir.
      --kutlama mi yoksa bilgilendirme mi ona gore sablon at...
      IF TRIM (in_email) IS NULL THEN
         out_durum := 'Email Bos olamaz..' || 'acc:' || TO_CHAR (in_account_number) || 'in_service_account_id:' || TO_CHAR (in_service_account_id);
         RETURN;
      END IF;

      v_email_from          := dbs_dba.dbs_sabit ('INFO');
      v_mail_subject        := dbs_dba.dbs_sabit ('DOGUM_GUNU_HEDIYE_KUPON_EMAIL_BASLIGI');

      IF in_abone_bedava_hediye_ata THEN
         IF in_abone_hediye_tipi = 1 THEN --kupon
            v_gonderi_tanim_id   := 365;
            v_gonderi_session_id := 426;
         ELSIF in_abone_hediye_tipi = 2 THEN --havadan akt BSENYAYLA 2015.04.06
            /*
            DİZİ  PAKETİ    DIZ SIMPLE OFFER kay
            FİLM PAKETİ    FLM SIMPLE OFFER kay
            MEGASÜPER PAKET    MEG SIMPLE OFFER kaydi
            SPOR EXTRA PAKETİ    SPM SIMPLE OFFER kay
            TURKSAT SUPER PAKET    TSU SIMPLE OFFER kay

            1576 --> 1 SADECE FLM (EUTELSAT)*
            1577 --> 2 SADECE DIZ (EUTELSAT)*
            1578 --> 3 DIZ+FLM (EUTELSAT)*
            1579 --> 4 SUPER PAKET + SPOR EXTRA --> MEG(EUTELSAT) VEYA TSU(TURKSAT)*
            1580 --> 5 SUPER PAKET MEG+SPM(eutelsat) TSU+SPM(TURKSAT)*
            1581 --> 6 SADECE SPOR EXTRA  SPM(eutelsat+TURKSAT)
            */

            --BU SERVISE DOĞUM GUNU İÇİN BU GÜN BAŞKA MAİL ATILMIŞMI
            SELECT COUNT (*)
              INTO v_tmp_number
              FROM dtakaya.scheduled_bulk_process_log sl
             WHERE     sl.status = 'PASSIVE'
                   AND sl.customer_order_item_log_id IS NULL
                   AND sl.scheduled_business_service_id = 1
                   AND sl.scheduled_business_srv_item_id = 1
                   AND sl.service_account_id = in_service_account_id
                   AND TRUNC (sl.creation_date) = TRUNC (SYSDATE);

            --EĞER MAIL ATILMAMIŞ İSE
            IF v_tmp_number = 0 THEN
               -- KISIYE VERILMEK ISTENEN BUTUN PAKETLER
               SELECT LISTAGG (ofr.offer_cd, ',') WITHIN GROUP (ORDER BY ofr.offer_cd ASC) all_offer_cd
                 INTO v_tmp_str
                 FROM dt_product_dba.offer ofr
                WHERE     ofr.logical_delete_key IS NULL
                      AND ofr.offer_id IN (SELECT bp.offer_to_id --BP.SERVICE_ACCOUNT_ID,--BP.OFFER_FROM_ID,--BP.PRODUCT_SPEC_ID
                                             FROM dtakaya.scheduled_bulk_process bp
                                            WHERE     bp.scheduled_business_service_id = 1
                                                  AND bp.scheduled_business_srv_item_id = 1
                                                  AND bp.status IN ('ACTIVE', 'PROCESSING')
                                                  AND bp.system_event_cd = 'AKT_EKLE'
                                                  AND bp.logical_delete_key IS NULL
                                                  AND bp.service_account_id = in_service_account_id);

               /*UNION
               SELECT sl.offer_to_id
                 FROM dtakaya.scheduled_bulk_process_log sl
                WHERE     sl.status = 'PASSIVE'
                      AND sl.customer_order_item_log_id IS NULL
                      AND sl.service_account_id = in_service_account_id
                      AND sl.scheduled_business_service_id = 1
                      AND sl.scheduled_business_srv_item_id = 1
                      AND TRUNC (sl.creation_date) = TRUNC (SYSDATE))*/

               CASE v_tmp_str
                  WHEN 'FLM_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V1',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'DIZ_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V2',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'MEG_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V4',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'TSU_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V4',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'SPM_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V6',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'MEG_SRV,SPM_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V5',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'SPM_SRV,TSU_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V5',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'DIZ_SRV,FLM_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V3',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  WHEN 'MEG_SRV,TSU_SRV' THEN
                     get_gonderi_info (i_gonderi_kod        => 'YASGUNU_HAVADAN_V4',
                                       o_gonderi_tanim_id   => v_gonderi_tanim_id,
                                       o_gonderi_session_id => v_gonderi_session_id
                                      );
                  ELSE
                     IF in_franchise_code = 'F01' THEN
                        v_gonderi_tanim_id   := 574;
                        v_gonderi_session_id := 458;
                     ELSIF in_franchise_code = 'F02' THEN -- F02 lere mail gönderimi gerçeklestirilecek.
                        v_gonderi_tanim_id   := 800; --    Burasi prod a göze düzelt
                        v_gonderi_session_id := 825;
                     END IF;
               END CASE;
            END IF;
         END IF;
      ELSE
         IF in_franchise_code = 'F02' THEN -- F02 lere mail gönderimi gerçeklestirilecek.
            v_gonderi_tanim_id   := 799; --    Burasi prod a göze düzelt
            v_gonderi_session_id := 824;
         ELSE
            v_gonderi_tanim_id   := 364;
            v_gonderi_session_id := 424;
         END IF;
      END IF;

      gonderi_pack.gonderi_header_insert (v_gonderi_tanim_id,
                                          in_gonderi_sekil_id,
                                          in_account_number,
                                          NULL,
                                          NULL,
                                          'SYSTEM',
                                          v_gonderi_id,
                                          out_durum,
                                          v_gonderi_confirm,
                                          in_email,
                                          NVL (v_email_from, 'INFO@INFO.turk.COM.TR'),
                                          NVL (v_mail_subject, 'INFO'),
                                          v_gonderi_session_id,
                                          v_mail_durum => 2
                                         );

      IF out_durum = '0' THEN
         gonderi_pack.parameter_guncelle (v_gonderi_id, 'ADSOYAD', NVL (in_adsoyad, 'ÜYEMIZ'), 'SYSTEM', out_durum);
      END IF;

      IF out_durum = '0' AND in_abone_bedava_hediye_ata AND in_abone_hediye_tipi = 2 THEN
         IF v_ittp_order_int_open IN (0, 1) THEN
            BEGIN
               SELECT osrel.product_validity
                 INTO v_sure
                 FROM dt_product_dba.offer_srel osrel
                      INNER JOIN dtakaya.scheduled_bulk_process bp ON bp.offer_from_id = osrel.offer_from_id AND bp.offer_to_id = osrel.offer_to_id
                WHERE     bp.scheduled_business_service_id = 1
                      AND bp.scheduled_business_srv_item_id = 1
                      AND bp.status = 'ACTIVE'
                      AND bp.system_event_cd = 'AKT_EKLE'
                      AND bp.logical_delete_key IS NULL
                      AND bp.service_account_id = in_service_account_id
                      AND osrel.product_valid_compute_t_cd = 'KAYAN'
                      AND osrel.logical_delete_key IS NULL
                      AND ROWNUM < 2;
            EXCEPTION
               WHEN OTHERS THEN
                  v_sure := 0;
            END;
         END IF;

         IF NVL (v_sure, 0) > 0 THEN
            gonderi_pack.parameter_guncelle (v_gonderi_id, 'SURE', TO_CHAR (v_sure), 'SYSTEM', out_durum);
         ELSE
            out_durum := 'Email: Sure hesaplanamadi' || 'acc:' || TO_CHAR (in_account_number) || 'in_service_account_id:' || TO_CHAR (in_service_account_id);
         END IF;
      END IF;

      IF out_durum = '0' THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END abone_dogum_gunu_kupon_mail_at;

   PROCEDURE abone_dogum_gunu_kupon_sms_at (in_account_number                 NUMBER,
                                            in_ad                             VARCHAR2,
                                            in_soyad                          VARCHAR2,
                                            out_istek_grup_id          IN OUT NUMBER,
                                            in_uygulama_islem_id              NUMBER,
                                            in_kullanici_isim                 VARCHAR2,
                                            in_kullanici_sifre                VARCHAR2,
                                            out_durum                     OUT VARCHAR2,
                                            in_abone_bedava_hediye_ata IN     BOOLEAN := FALSE,
                                            in_abone_hediye_tipi       IN     NUMBER := 1
                                           ) IS
      out_istek_id           NUMBER (10);
      v_sonuc_tip            NUMBER (1);
      --v_sablon_kutlama       VARCHAR2 (255) := 'Dogumgününüz kutlu olsun! Hayatinizdan saglik, mutluluk ve eglence eksik olmasin. Mutlu yillar';
      v_sablon_kutlama       VARCHAR2 (255) := 'Dogum gününüz kutlu olsun! Hayatinizdan saglik, mutluluk ve eglence eksik olmasin! Nice Senelere'; --MKECECI yeni şablon
      --v_sablon_bilgilendirme VARCHAR2 (255) := 'Dogumgününüz kutlu olsun! <SURE> yildir üyemiz oldugunuz için <SURE> gün tüm kanallar bizden size hediye.';
      v_sablon_bilgilendirme VARCHAR2 (255)
                                := 'Dogum gününüz kutlu olsun. Keyifli bir dogum günü geçirmeniz için <SURE> gün boyunca tüm kanallarımız hediye.';
      v_sablon               VARCHAR2 (255);
      v_mesaj_max_uzunluk    NUMBER := 155;
      v_mesaj                VARCHAR2 (275);
      v_ulke_kodu            VARCHAR2 (100) := NULL;
      v_alan_kodu            VARCHAR2 (100) := NULL;
      v_telefon_no           VARCHAR2 (100) := NULL;
      v_sms_gonderim_tarihi  DATE; --VARCHAR2 (20);
      v_hour                 NUMBER (2);
      v_count                NUMBER (10);
      v_sure                 NUMBER (5);
      v_servis_id            NUMBER (2);
      v_operator_kod         VARCHAR2 (4);
      v_ittp_order_int_open  NUMBER;
   BEGIN
      out_durum             := '0';

      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      BEGIN
         SELECT ulke_kodu, alan_kodu, telefon_no
           INTO v_ulke_kodu, v_alan_kodu, v_telefon_no
           FROM (SELECT   *
                     FROM mb_abone_telefon tel,
                          mb_abone_telefon_register reg
                    WHERE     tel.id = reg.telefon_id(+)
                          AND telefon_tipi = 3
                          AND durum = 1
                          AND (reg.listeden_gizle = 'H' OR reg.account_number IS NULL)
                          AND tel.account_number = in_account_number
                 ORDER BY reg.account_number)
          WHERE ROWNUM = 1; --ulke kodu null yerli kayit var mi SOR
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN;
         WHEN OTHERS THEN
            out_durum := SUBSTR ('SMS: ' || SQLERRM, 1, 222) || 'acc:' || TO_CHAR (in_account_number);
            RETURN;
      END;

      --      SELECT COUNT (1)
      --        INTO v_count
      --        FROM sms_dba.sms_gonderim_istek
      --       WHERE uygulama_islem_id = in_uygulama_islem_id
      --         AND telefon_no = TRIM (v_alan_kodu) || TRIM (v_telefon_no);
      --      --bu telefona zaten gonderimi bekleyen bir kayit var.
      --      IF v_count > 0
      --      THEN
      --         RETURN;
      --      END IF;
      v_hour                := TO_NUMBER (TO_CHAR (SYSDATE, 'hh24'));

      IF v_hour < 10 THEN
         v_sms_gonderim_tarihi := TRUNC (SYSDATE) + 10 / 24;
      ELSE
         v_sms_gonderim_tarihi := TRUNC (SYSDATE) + 10 / 24 + 1;
      END IF;

      IF in_abone_bedava_hediye_ata THEN
         IF in_abone_hediye_tipi = 1 THEN
            v_sablon_bilgilendirme := 'Dogum gününüzü kutlar, salonlardan bedava film hediyesi kazandiginizi bildiririz. turk';
         ELSIF in_abone_hediye_tipi = 2 THEN
            IF v_ittp_order_int_open = 0 THEN
               BEGIN
                  SELECT sure
                    INTO v_sure
                    FROM pr_on_air_activation_kampanya
                   WHERE     kampanya_kodu IN (SELECT campaign_code
                                                 FROM dbs_addr.dbs_addr_on_air_activation
                                                WHERE account_number = in_account_number)
                         AND kampanya_tipi = 7
                         AND ROWNUM < 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     out_durum := 'SMS sure bulunamadi.' || 'acc:' || TO_CHAR (in_account_number);
                     RETURN;
               END;
            ELSIF v_ittp_order_int_open = 1 THEN
               BEGIN
                  SELECT sure
                    INTO v_sure
                    FROM pr_on_air_activation_kampanya
                   WHERE     kampanya_kodu IN (SELECT SUBSTR (campaign_code, 9, LENGTH (campaign_code)) -- ITTP DEN GELEN "HAVADAN_" PARCASI SILINDI - DTAKAYA 14.03.2014
                                                 FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan
                                                WHERE account_number = in_account_number)
                         AND kampanya_tipi = 7
                         AND ROWNUM < 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     out_durum := 'SMS sure bulunamadi.' || 'acc:' || TO_CHAR (in_account_number);
                     RETURN;
               END;
            END IF;

            v_sablon_bilgilendirme := REPLACE (v_sablon_bilgilendirme, '<SURE>', TO_CHAR (v_sure));
         END IF;
      END IF;

      IF TRIM (v_alan_kodu) IS NOT NULL AND TRIM (v_telefon_no) IS NOT NULL THEN
         --eger aboneye bedava kupon atilmis ise illegal gunde bile olsa SMS cikilabilir
         --eger kupon atanmamis ise illegal gunlerde SMS cikilmaz
         IF in_abone_bedava_hediye_ata THEN
            v_sablon := v_sablon_bilgilendirme;
         ELSE
            v_sablon := v_sablon_kutlama;
         END IF;

         v_mesaj := v_hitap || in_ad || ' ' || in_soyad || ', ' || v_sablon;

         IF LENGTH (v_mesaj) > v_mesaj_max_uzunluk THEN
            v_mesaj := v_hitap || in_soyad || ', ' || v_sablon;
         END IF;

         IF LENGTH (v_mesaj) > v_mesaj_max_uzunluk THEN
            v_mesaj := v_hitap || 'uyemiz' || ', ' || v_sablon;
         END IF;

         /*<begin>Almanya ya SMS için servis ve operator ayarlari yapildi.*/
         IF TRIM (v_ulke_kodu) = '49' THEN
            v_servis_id    := 7;
            v_operator_kod := 'TRL';
         ELSE
            v_servis_id    := NULL;
            v_operator_kod := NULL;
         END IF;

         /*</end>Almanya için SMS Mesut Keçecioglu 05.09.2012*/
         IF out_istek_grup_id IS NULL THEN
            --GRUP_YARAT,
            sms_dba.sms_gonderim_istek_pack.istek_grup_yarat (in_uygulama_islem_id, --uygulama_islem_id girmek gerekiyor SOR
                                                              in_kullanici_isim, --in_kullanici_isim,SOR
                                                              in_kullanici_sifre, --in_kullanici_sifre,SOR
                                                              v_operator_kod, --in_operator_kod,SOR
                                                              v_servis_id, --in_servis_id,SOR
                                                              'D.gunu kutlama/bilgilendirme',
                                                              v_sablon,
                                                              NULL,
                                                              NULL,
                                                              NULL, --gonderim tarihini set et.
                                                              out_istek_grup_id,
                                                              v_sonuc_tip,
                                                              out_durum
                                                             );
         END IF;

         IF NVL (v_sonuc_tip, 0) = 0 THEN
            sms_dba.sms_gonderim_istek_pack.istek_yarat (in_uygulama_islem_id,
                                                         out_istek_grup_id,
                                                         in_kullanici_isim,
                                                         in_kullanici_sifre,
                                                         v_operator_kod,
                                                         v_servis_id,
                                                         TRIM (v_alan_kodu) || TRIM (v_telefon_no),
                                                         v_mesaj,
                                                         v_sms_gonderim_tarihi,
                                                         --gonderim tarihine karar vermeli
                                                         out_istek_id,
                                                         v_sonuc_tip,
                                                         out_durum,
                                                         in_telefon_ulke_kod => v_ulke_kodu
                                                        );
         END IF;

         -- istek kaydina iliskin üyeyi girme
         IF v_sonuc_tip = 0 THEN
            sms_dba.sms_gonderim_istek_pack.detay_uye_yarat (out_istek_id, in_account_number, NULL, NULL, FALSE /*in_gonderdi*/
                                                                                                               , v_sonuc_tip, out_durum);
         END IF;

         IF v_sonuc_tip = 0 THEN
            COMMIT;
            out_durum := '0';
         ELSE
            ROLLBACK;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         out_durum := SUBSTR (SQLERRM, 1, 200) || 'acc:' || TO_CHAR (in_account_number);
   END abone_dogum_gunu_kupon_sms_at;

   PROCEDURE abone_dogum_gunu_kupon_ird_cik (in_account_number                 NUMBER,
                                             in_serial_number                  VARCHAR2,
                                             in_outlet_location                VARCHAR2,
                                             in_ad                             VARCHAR2,
                                             in_soyad                          VARCHAR2,
                                             out_durum                     OUT VARCHAR2,
                                             in_abone_bedava_hediye_ata IN     BOOLEAN := FALSE,
                                             in_abone_hediye_tipi       IN     NUMBER := 1
                                            ) IS
      c_mesaj_uzunluk CONSTANT NUMBER (3) := 105;
      p_errm                   VARCHAR2 (255);

      r                        NUMBER;
      v_dogum_gunu             VARCHAR2 (112) := 'Dogumgününüz kutlu olsun! Hayatinizdan saglik, mutluluk ve eglence eksik olmasin';
      v_sablon_kutlama         VARCHAR2 (112) := 'Dogumgününüz kutlu olsun! Hayatinizdan saglik, mutluluk ve eglence eksik olmasin';
      v_sablon_bilgilendirme   VARCHAR2 (112) := 'Dogumgününüz kutlu olsun! <SURE> yildir üyemiz oldugunuz için <SURE> gün tüm kanallar bizden hediye';
      v_dogum_gunu_id          NUMBER;
      v_fon_rengi              NUMBER (5);
      v_gonderim_tarihi        DATE;
      v_ind                    INTEGER := 0;
      v_karakter_rengi         NUMBER (5);
      v_mesaj                  VARCHAR2 (500);
      v_kacinci                VARCHAR2 (15);
      v_policy                 INTEGER;
      v_sonuc                  VARCHAR2 (255);
      v_tarih                  DATE := SYSDATE;
      v_yil                    INTEGER := 0;
      v_ird_gonderim_tarihi    DATE;
      v_hour                   NUMBER (3);
      v_account_number         NUMBER (10);
      v_outlet_location        VARCHAR2 (3);
      v_sure                   NUMBER (5);
      v_ittp_order_int_open    NUMBER;
   BEGIN
      out_durum             := '0';
      v_account_number      := in_account_number;
      v_outlet_location     := in_outlet_location;

      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      --      v_gonderim_tarihi := dbs_dba.dbs_sabit ('ABONE_DOGUM_GUNU_KUPON_IRD_GON_TARIHI');
      IF in_abone_bedava_hediye_ata THEN
         IF in_abone_hediye_tipi = 1 THEN
            v_sablon_bilgilendirme := 'Dogum gününüzü kutlar, salonlardan bedava film hediyesi kazandiginizi bildiririz. turk';
         ELSIF in_abone_hediye_tipi = 2 THEN
            IF v_ittp_order_int_open = 0 THEN
               BEGIN
                  SELECT sure
                    INTO v_sure
                    FROM pr_on_air_activation_kampanya
                   WHERE     kampanya_kodu IN (SELECT campaign_code
                                                 FROM dbs_addr.dbs_addr_on_air_activation
                                                WHERE account_number = in_account_number)
                         AND kampanya_tipi = 7
                         AND ROWNUM < 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     out_durum := 'IRD sure bulunamadi. ACC: ' || TO_CHAR (in_account_number);
                     RETURN;
               END;
            ELSIF v_ittp_order_int_open = 1 THEN
               BEGIN
                  SELECT sure
                    INTO v_sure
                    FROM pr_on_air_activation_kampanya
                   WHERE     kampanya_kodu IN (SELECT SUBSTR (campaign_code, 9, LENGTH (campaign_code)) -- ITTP DEN GELEN "HAVADAN_" PARCASI SILINDI - DTAKAYA 14.03.2014
                                                 FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan
                                                WHERE account_number = in_account_number)
                         AND kampanya_tipi = 7
                         AND ROWNUM < 2;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     out_durum := 'IRD sure bulunamadi. ACC: ' || TO_CHAR (in_account_number);
                     RETURN;
               END;
            END IF;

            v_sablon_bilgilendirme := REPLACE (v_sablon_bilgilendirme, '<SURE>', TO_CHAR (v_sure));
         END IF;
      END IF;

      v_policy              := 111; --SOR------***********************************
      v_hour                := TO_NUMBER (TO_CHAR (SYSDATE, 'hh24'));

      IF v_hour < 20 THEN
         v_ird_gonderim_tarihi := TRUNC (SYSDATE) + (20 / 24) + (10 / (24 * 60));
      -- saat 20:10 da çikacaktir.
      ELSE
         v_ird_gonderim_tarihi := TRUNC (SYSDATE) + (20 / 24) + 1 + (10 / (24 * 60));
      END IF;

      uye_kontrol_pack.uye_icrada_mi (v_account_number, out_durum);

      IF out_durum = '0' THEN
         uye_kontrol_pack.uye_suspend_mi (v_account_number, in_outlet_location, out_durum);

         IF out_durum <> '0' THEN
            out_durum := '0';
            RETURN;
         END IF;

         uye_kontrol_pack.uye_donmus_mu (v_account_number, in_outlet_location, out_durum);

         IF out_durum <> '0' THEN
            out_durum := '0';
            RETURN;
         ELSE
            BEGIN
               SELECT fon_rengi, karakter_rengi, id
                 INTO v_fon_rengi, v_karakter_rengi, v_dogum_gunu_id
                 FROM pr_ekran_mesaji_tanim
                WHERE id = dbs_sabit ('MESAJ_DOGUMGUNU');
            --dg kupon icin buraya kayit ekle
            EXCEPTION
               WHEN OTHERS THEN
                  v_fon_rengi      := 4;
                  v_karakter_rengi := 0;
            END;

            IF in_abone_bedava_hediye_ata THEN
               v_dogum_gunu := v_sablon_bilgilendirme;
            ELSE
               v_dogum_gunu := v_sablon_kutlama;
            END IF;

            v_mesaj := v_hitap || in_ad || ' ' || in_soyad || ', ' || v_dogum_gunu;

            IF LENGTH (v_mesaj) > c_mesaj_uzunluk THEN
               v_mesaj := v_hitap || in_soyad || ', ' || v_dogum_gunu;
            END IF;

            IF LENGTH (v_mesaj) > c_mesaj_uzunluk THEN
               v_mesaj := v_hitap || 'üyemiz, ' || v_dogum_gunu;
            END IF;

            IF LENGTH (v_mesaj) > c_mesaj_uzunluk THEN
               v_mesaj := v_dogum_gunu;
            END IF; --gene uzunsa diye bir kontrol yok SOR***************

            r       := dbs_addr_reqs_pack.display_message ('2',
                                                           in_serial_number,
                                                           v_mesaj,
                                                           v_ird_gonderim_tarihi,
                                                           'SYSTEM',
                                                           out_durum,
                                                           NULL,
                                                           --p_policy                 => v_policy,
                                                           p_background_colour => v_fon_rengi,
                                                           p_character_colour  => v_karakter_rengi
                                                          );

            INSERT INTO lg_abone_duzenli_mesaj_takip (id, account_number, serial_number, abone_mesaj_id, kisi, islem_tarihi, sonuc)
                 VALUES (lg_abone_duzenli_mesaj_id_seq.NEXTVAL, v_account_number, in_serial_number, v_dogum_gunu_id, 'SYSTEM', SYSDATE, out_durum);

            IF r = 1 THEN
               COMMIT;
               out_durum := '0';
            ELSE
               ROLLBACK;

               IF out_durum <> '0' THEN
                  out_durum := out_durum || ' Acc:' || in_account_number;
               END IF;
            END IF;
         END IF;
      ELSE
         out_durum := '0';
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END abone_dogum_gunu_kupon_ird_cik;

   PROCEDURE abone_havadan_aktivasyon_ekle (in_account_number IN NUMBER, in_abone_bedava_hediye_ata OUT BOOLEAN, out_durum OUT VARCHAR2) IS
      v_campaign_code           VARCHAR2 (100);
      v_service_code            VARCHAR2 (5) := 'MGG';
      v_illegal_dates           VARCHAR2 (500);
      v_sqlquery                VARCHAR2 (1000);
      v_count                   NUMBER (10);
      in_kullanici              VARCHAR2 (10) := 'SYSTEM';
      v_kupon_adeti             NUMBER (10) := 1;
      in_kupon_aciklama         VARCHAR2 (100);
      v_coupon_id               NUMBER (10);
      in_kupon_kaynak           VARCHAR2 (100) := 'DBS';
      v_kupon_gecerlilik_suresi VARCHAR2 (5);
      v_havadan_ekleme_tarihi   DATE;
      v_reason_code             VARCHAR2 (10);
      v_durum                   VARCHAR2 (255);
      o_return_status           NUMBER (5);
      o_return_code             VARCHAR2 (10);
      o_bitis_tarih             DATE;
      o_aciklama                VARCHAR2 (1000);
      o_id                      NUMBER (10);
      v_ittp_order_int_open     NUMBER;
   BEGIN
      v_ittp_order_int_open      := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');
      in_abone_bedava_hediye_ata := FALSE;
      out_durum                  := '0';
      --pa_sabitlerden exception gun konterolu yap.
      v_reason_code              := dbs_sabit ('DOGUM_GUNU_HAVADAN_AKTIVASYON_SEBEP_KODU');

      IF v_reason_code IS NULL THEN
         out_durum := 'Havadan aktivasyon sebep kodu sabitlerde bulunamamistir.';
         RETURN;
      END IF;

      v_illegal_dates            := dbs_sabit ('DOGUM_GUNU_BEDAVA_AKTIVASYON_ILLEGAL_GUNLER');

      IF INSTR (v_illegal_dates, TO_CHAR (v_havadan_ekleme_tarihi, 'DD.MM')) > 0 THEN
         RETURN;
      END IF;

      IF UPPER (dbs_sabit ('DOGUM_GUNU_HEDIYE_HAVADAN_EKLEME_TARIHI')) <> 'SYSDATE' THEN
         BEGIN
            v_havadan_ekleme_tarihi := TO_DATE (dbs_dba.dbs_sabit ('DOGUM_GUNU_HEDIYE_HAVADAN_EKLEME_TARIHI'), 'DD.MM.YYYY');
         EXCEPTION --1.nolu exception
            WHEN OTHERS THEN
               v_havadan_ekleme_tarihi := SYSDATE;
         END;
      ELSE
         v_havadan_ekleme_tarihi := SYSDATE;
      END IF;

      --bu havadan akt in yilda bir kere eklenmesi gerekir
      SELECT COUNT (1)
        INTO v_count
        FROM dbs_addr.dbs_addr_log_on_air_activation
       WHERE     account_number = in_account_number
             AND beklenen_acilma_tarihi > TRUNC (ADD_MONTHS (v_havadan_ekleme_tarihi, -12)) + 1
             AND campaign_code IN (SELECT kampanya_kodu
                                     FROM pr_on_air_activation_kampanya
                                    WHERE kampanya_tipi = '7')
             AND status = 'O';

      IF v_count > 0 THEN
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM mb_abone_ozellik
       WHERE account_number = in_account_number AND abone_ozellik_kodu = 38;

      -- bsarcan ebntegrasyon 16.12.2013
      IF v_count = 0 THEN
         IF v_ittp_order_int_open = 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM wiz_customer_hp_svc
             WHERE account_number = in_account_number AND (service_code IN ('SUP', 'MEG', 'MGG') OR service_code IN ('PLE', 'PLT', 'ALT'));
         ELSIF v_ittp_order_int_open = 1 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM dt_dbs_int_dba.vv_uye_ittp_servisler
             WHERE account_number = in_account_number AND (service_code IN ('SUP', 'MEG', 'MGG') OR service_code IN ('PLE', 'PLT', 'ALT'));
         END IF;

         IF v_count = 0 THEN
            IF v_ittp_order_int_open = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM (SELECT   COUNT (1)
                           FROM wiz_customer_hp_svc
                          WHERE account_number = in_account_number AND service_code IN ('BSL', 'YSM', 'COC', 'HBR', 'BLG', 'TSO', 'DIZ', 'FLM', 'SPR')
                       GROUP BY outlet_location
                         HAVING COUNT (1) = 9);
            ELSIF v_ittp_order_int_open = 1 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM (SELECT   COUNT (1)
                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                          WHERE account_number = in_account_number AND service_code IN ('BSL', 'YSM', 'COC', 'HBR', 'BLG', 'TSO', 'DIZ', 'FLM', 'SPR')
                       GROUP BY outlet_location
                         HAVING COUNT (1) = 9);
            END IF;
         END IF;

         --!Super, Mega Super, Mega Gold Paket üyesi olmayan AC, F01, F02, NOR, PH, iptal talebi vermemis olan üyeler!
         IF v_count = 0 THEN
            IF v_ittp_order_int_open = 0 THEN
               FOR rec_svc IN (SELECT DISTINCT outlet_location
                                 FROM wiz_customer_hp_svc svc
                                WHERE     account_number = in_account_number
                                      AND svc.outlet_location NOT IN (SELECT outlet_location
                                                                        FROM wiz_customer_hp_svc
                                                                       WHERE account_number = in_account_number AND service_code = 'CCK ')) LOOP
                  FOR kmp_rec IN (SELECT kampanya_kodu, service_code
                                    FROM (SELECT   *
                                              FROM pr_on_air_activation_kampanya
                                             WHERE     kampanya_tipi = 7
                                                   AND stb_tipi IN (SELECT hp_cluster
                                                                      FROM wiz_customer_hp_life
                                                                     WHERE account_number = in_account_number)
                                                   AND (sure <= TRUNC (uye_aktif_sure (in_account_number) / 12))
                                          ORDER BY sure DESC)
                                   WHERE ROWNUM < 3) LOOP
                     out_durum := '0';
                     dbs_dba.addressability_pack.dbs_activate_on_air (in_account_number,
                                                                      rec_svc.outlet_location,
                                                                      kmp_rec.kampanya_kodu,
                                                                      kmp_rec.service_code, --v_service_code,
                                                                      v_reason_code, --p_reason_code,
                                                                      v_havadan_ekleme_tarihi, --p_beklenen_acilma_tarihi,
                                                                      'SYSTEM', --p_kullanici,
                                                                      out_durum,
                                                                      o_return_status,
                                                                      o_return_code,
                                                                      o_bitis_tarih,
                                                                      o_aciklama,
                                                                      o_id,
                                                                      in_kupon_kaynak
                                                                     );

                     IF out_durum = '0' -- else log?
                                       THEN
                        COMMIT;
                        in_abone_bedava_hediye_ata := TRUE;
                     ELSE
                        ROLLBACK;
                        DBMS_OUTPUT.put_line ('hata meydana geldi : ' || out_durum);
                        out_durum := '0'; --hatayi sifirla kutlama mesaji cik
                     END IF;
                  END LOOP;
               END LOOP;
            ELSIF v_ittp_order_int_open = 1 THEN
               FOR rec_svc IN (SELECT DISTINCT outlet_location
                                 FROM dt_dbs_int_dba.vv_uye_ittp_servisler svc
                                WHERE     account_number = in_account_number
                                      AND svc.outlet_location NOT IN (SELECT outlet_location
                                                                        FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                                                                       WHERE account_number = in_account_number AND service_code = 'CCK ')) LOOP
                  FOR kmp_rec IN (SELECT kampanya_kodu, service_code
                                    FROM (SELECT   *
                                              FROM pr_on_air_activation_kampanya
                                             WHERE     kampanya_tipi = 7
                                                   AND stb_tipi IN (SELECT hp_cluster
                                                                      FROM wiz_customer_hp_life
                                                                     WHERE account_number = in_account_number)
                                                   AND (sure <= TRUNC (uye_aktif_sure (in_account_number) / 12))
                                          ORDER BY sure DESC)
                                   WHERE ROWNUM < 3) LOOP
                     out_durum := '0';
                     dbs_dba.addressability_pack.dbs_activate_on_air (in_account_number,
                                                                      rec_svc.outlet_location,
                                                                      kmp_rec.kampanya_kodu,
                                                                      kmp_rec.service_code, --v_service_code,
                                                                      v_reason_code, --p_reason_code,
                                                                      v_havadan_ekleme_tarihi, --p_beklenen_acilma_tarihi,
                                                                      'SYSTEM', --p_kullanici,
                                                                      out_durum,
                                                                      o_return_status,
                                                                      o_return_code,
                                                                      o_bitis_tarih,
                                                                      o_aciklama,
                                                                      o_id,
                                                                      in_kupon_kaynak
                                                                     );

                     IF out_durum = '0' -- else log?
                                       THEN
                        COMMIT;
                        in_abone_bedava_hediye_ata := TRUE;
                     ELSE
                        ROLLBACK;
                        DBMS_OUTPUT.put_line ('hata meydana geldi : ' || out_durum);
                        out_durum := '0'; --hatayi sifirla kutlama mesaji cik
                     END IF;
                  END LOOP;
               END LOOP;
            END IF;
         END IF;
      END IF;
   EXCEPTION --3 no lu exception
      WHEN OTHERS THEN
         ROLLBACK;
         out_durum := (SUBSTR (SQLERRM, 1, 200));
   END;

   PROCEDURE abone_dogum_gunu_kupon_ekle (in_account_number IN NUMBER, in_abone_bedava_hediye_ata OUT BOOLEAN, out_durum OUT VARCHAR2) IS
      --hangi gunler kupon eklenmemesi gerektigini pa_sabitlerden ceker.
      v_coupon_code             VARCHAR2 (100);
      v_illegal_dates           VARCHAR2 (500);
      v_sqlquery                VARCHAR2 (1000);
      v_count                   NUMBER (10);
      in_kullanici              VARCHAR2 (10) := 'SYSTEM';
      v_kupon_adeti             NUMBER (10) := 1;
      in_kupon_aciklama         VARCHAR2 (100);
      v_coupon_id               NUMBER (10);
      in_kupon_kaynak           VARCHAR2 (100) := 'DBS';
      v_kupon_gecerlilik_suresi VARCHAR2 (5);
      v_kupon_ekleme_tarihi     DATE;
      v_durum                   VARCHAR2 (255);
      v_ittp_order_int_open     NUMBER;

      CURSOR cur_eqp (v_abone NUMBER) IS
         SELECT serial_number, outlet_location
           FROM wiz_equip
          WHERE account_number = v_abone AND converter_type = 'SC';

      CURSOR cur_descrip (v_abone NUMBER) IS
         SELECT cd.first_name ad, cd.last_name soyad
           FROM wiz_customer_descrip cd
          WHERE account_number = v_abone;
   BEGIN
      in_abone_bedava_hediye_ata := FALSE;
      out_durum                  := '0';
      --pa_sabitlerden exception gun konterolu yap.
      v_illegal_dates            := dbs_sabit ('DOGUM_GUNU_HEDIYE_KUPON_ILLEGAL_GUNLER');

      v_ittp_order_int_open      := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      IF INSTR (v_illegal_dates, TO_CHAR (SYSDATE, 'DD.MM')) > 0 THEN
         out_durum := 'Program, sabitlerden cekilen illegal gunlerde calismaz.';
         RETURN;
      END IF;

      IF UPPER (dbs_sabit ('DOGUM_GUNU_HEDIYE_KUPON_EKLEME_TARIHI')) <> 'SYSDATE' THEN
         BEGIN
            v_kupon_ekleme_tarihi := TO_DATE (dbs_dba.dbs_sabit ('DOGUM_GUNU_HEDIYE_KUPON_EKLEME_TARIHI'), 'DD.MM.YYYY');
         EXCEPTION --1.nolu exception
            WHEN OTHERS THEN
               v_kupon_ekleme_tarihi := SYSDATE;
         END;
      ELSE
         v_kupon_ekleme_tarihi := SYSDATE;
      END IF;

      v_coupon_code              := dbs_dba.dbs_sabit ('DOGUM_GUNU_HEDIYE_KUPON_KODU');

      IF TRIM (v_coupon_code) IS NULL THEN
         out_durum := 'Aboneye atanacak kupon kodu, sabitlerde belirlenmemistir.';
         log_pack.log_is_emri_hata (in_account_number,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    'J', -- job ile uyelik iptali toplu islemi
                                    'SYSTEM',
                                    SYSDATE,
                                    NULL,
                                    'abone_dg_kupon_hata_kkodu: ' || SUBSTR (out_durum, 1, 200),
                                    v_durum
                                   );

         IF v_durum = '0' THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;

         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM wiz_customer_hp_life b
       WHERE b.account_number = in_account_number AND b.customer_status = 'AC' AND b.franchise_code = 'F01' AND b.customer_type = 'NOR' AND b.hp_cluster = 'PH';

      IF v_count = 0 THEN
         out_durum := 'Abonenin özellikleri hediye tanimina uygun degildir.';
         RETURN;
      END IF;

      --wiz cust hp svc de kaydi var mi?

      IF v_ittp_order_int_open = 0 THEN
         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_svc
          WHERE account_number = in_account_number;
      ELSIF v_ittp_order_int_open = 1 THEN
         SELECT COUNT (1)
           INTO v_count
           FROM dt_dbs_int_dba.vv_uye_ittp_servisler
          WHERE account_number = in_account_number;
      END IF;

      IF v_count < 1 THEN
         out_durum := 'uyenin hp_svc kaydi bulunmamaktadir.';
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM mb_abone_ozellik
       WHERE account_number = in_account_number AND abone_ozellik_kodu = 38;

      IF v_count > 0 THEN
         out_durum := 'Uyenin aboneligi borcundan ötürü kapatilmistir.';
         RETURN;
      END IF;

      IF out_durum = '0' THEN
         FOR rec_eq IN (SELECT   outlet_location
                            FROM wiz_equip
                           WHERE account_number = in_account_number AND converter_type = 'SC'
                        ORDER BY outlet_location DESC) LOOP
            uye_kontrol_pack.uye_iptal_talebi_var_mi (in_account_number, rec_eq.outlet_location, out_durum);

            IF out_durum = '0' THEN
               --DBMS_OUTPUT.put_line ('BULDUK GUZEL OUTLET, VER BU UYEYE');
               EXIT;
            END IF;
         END LOOP;
      END IF;

      IF out_durum = '0' THEN
         --bu kuponun yilda bir kere eklenmesi gerekir

         /*--- Evren-ITTP --- 20111104 ---*/
         IF sabit.is_ittp_indirim_ent_acik = 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM wiz_customer_coupon
             WHERE     account_number = in_account_number
                   AND effective_date > TRUNC (ADD_MONTHS (v_kupon_ekleme_tarihi, -12)) + 1
                   AND coupon_code = v_coupon_code
                   AND coupon_status <> 'V';
         ELSE
            SELECT COUNT (1)
              INTO v_count
              FROM billing_dbs_int.vw_kupon_ittp
             WHERE account_number = in_account_number AND effective_date > TRUNC (ADD_MONTHS (v_kupon_ekleme_tarihi, -12)) + 1 AND status <> 'Iptal';
         END IF;

         IF v_count > 0 THEN
            out_durum := 'Aboneye 1 yil içinde dogum günü kuponu atanmistir.';
            log_pack.log_is_emri_hata (in_account_number,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       'J', -- job ile uyelik iptali toplu islemi
                                       'SYSTEM',
                                       SYSDATE,
                                       NULL,
                                       'abone_dg_kupon_hata_1yil: ' || SUBSTR (out_durum, 1, 200),
                                       v_durum
                                      );

            IF v_durum = '0' THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;
         ELSE
            --ABONEYE KUPON EKLE ***********************************************************
            v_kupon_gecerlilik_suresi := dbs_dba.dbs_sabit ('DOGUM_GUNU_HEDIYE_KUPON_GECERLILIK_SURESI');

            IF is_numeric (v_kupon_gecerlilik_suresi) <> 1 OR TRIM (v_kupon_gecerlilik_suresi) IS NULL THEN
               v_kupon_gecerlilik_suresi := ADD_MONTHS (SYSDATE, 1) - SYSDATE;
            END IF;

            IF v_kupon_ekleme_tarihi > SYSDATE THEN
               v_kupon_gecerlilik_suresi := TRUNC (TO_CHAR (v_kupon_ekleme_tarihi - SYSDATE + TO_NUMBER (v_kupon_gecerlilik_suresi)));
            END IF;

            kupon_pack.coupon_insert (in_account_number,
                                      in_kullanici,
                                      v_coupon_code,
                                      v_kupon_adeti,
                                      in_kupon_aciklama,
                                      out_durum,
                                      v_coupon_id,
                                      in_kupon_kaynak,
                                      v_kupon_ekleme_tarihi,
                                      TO_DATE ('01.01.0001', 'DD.MM.YYYY'),
                                      TO_NUMBER (v_kupon_gecerlilik_suresi)
                                     );

            IF out_durum = '0' -- else log?
                              THEN
               COMMIT;
               in_abone_bedava_hediye_ata := TRUE;
            ELSE
               ROLLBACK;
               --log
               log_pack.log_is_emri_hata (in_account_number,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          'J', -- job ile uyelik iptali toplu islemi
                                          'SYSTEM',
                                          SYSDATE,
                                          NULL,
                                          'abone_dg_kupon_hata: ' || SUBSTR (out_durum, 1, 200),
                                          v_durum
                                         );

               IF v_durum = '0' THEN
                  COMMIT;
               ELSE
                  ROLLBACK;
               END IF;
            END IF;
         END IF;
      END IF;
   EXCEPTION --3 no lu exception
      WHEN OTHERS THEN
         ROLLBACK;
         out_durum := (SUBSTR (SQLERRM, 1, 200));
         log_pack.log_is_emri_hata (in_account_number,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    'J', -- job ile uyelik iptali toplu islemi
                                    'SYSTEM',
                                    SYSDATE,
                                    NULL,
                                    'abone_dogum_gunu_kupon_ekle_3: ' || SUBSTR (SQLERRM, 1, 200),
                                    v_durum
                                   );

         IF v_durum = '0' THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
   END;

   ----------------------------------------------------------------------------------------
   --Tum konut üyelerine dogum gunu mesaji atar
   --Eger abone uygun sartlari sagliyorsa ona bedava PPV kuponu tanimlanir. (su an icin F01, F02 AC, NOR, PH, iptal talebi olmayan, LUX/DELUX uyelere tanimlaniyor )
   PROCEDURE dogum_gunu (in_account_number IN NUMBER := NULL, in_process_date IN DATE := SYSDATE) IS
      v_grup_f01                sms_dba.sms_gonderim_istek.istek_grup_id%TYPE := NULL;
      v_grup_f04                sms_dba.sms_gonderim_istek.istek_grup_id%TYPE := NULL;
      v_ittp_order_int_open     NUMBER;

      CURSOR cur_eqp (v_abone NUMBER) IS
         (SELECT serial_number, outlet_location
            FROM wiz_equip e
           WHERE     e.account_number = v_abone
                 AND e.converter_type = 'SC'
                 AND EXISTS
                        (SELECT 1
                           FROM wiz_customer_hp_svc svc
                          WHERE svc.account_number = e.account_number AND svc.outlet_location = e.outlet_location)
                 AND NOT EXISTS
                        (SELECT 1
                           FROM wiz_customer_hp_svc svc2
                          WHERE svc2.account_number = e.account_number AND svc2.outlet_location = e.outlet_location AND svc2.service_code = 'CCK')
                 AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
         UNION
         (SELECT serial_number, outlet_location
            FROM wiz_equip e
           WHERE     e.account_number = v_abone
                 AND e.converter_type = 'SC'
                 AND EXISTS
                        (SELECT 1
                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler svc
                          WHERE svc.account_number = e.account_number AND svc.outlet_location = e.outlet_location)
                 AND NOT EXISTS
                        (SELECT 1
                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler svc2
                          WHERE svc2.account_number = e.account_number AND svc2.outlet_location = e.outlet_location AND svc2.service_code = 'CCK')
                 AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'));

      CURSOR cur_abone_detay  IS
         SELECT ad.account_number, hl.franchise_code
           FROM mb_abone_detay_bilgi ad,
                wiz_customer_hp_life hl,
                wiz_customer_type_codes tc
          WHERE     ad.account_number = hl.account_number
                AND hl.customer_type = tc.customer_type
                AND tc.privileged_flag = 'Y'
                AND hl.customer_status = 'AC'
                AND (   ad.account_number = in_account_number
                     OR (in_account_number IS NULL AND TO_CHAR (ad.dogum_tarihi, 'dd.mm') = TO_CHAR (in_process_date, 'dd.mm')))
                AND TO_CHAR (ad.dogum_tarihi, 'dd.mm') <> '01.01';

      CURSOR cur_descrip (v_abone NUMBER) IS
         SELECT cd.first_name ad, cd.last_name soyad
           FROM wiz_customer_descrip cd
          WHERE account_number = v_abone;

      v_abone_bedava_hediye_ata BOOLEAN := FALSE;
      v_illegal_kutlama_gunu_mu BOOLEAN := FALSE;
      v_kutlama_illegal_gunler  VARCHAR2 (100);
      v_gonderim_tarihi         DATE;
      out_durum                 VARCHAR2 (255);
      v_count                   NUMBER (10);
      v_email                   VARCHAR2 (100);
      v_istek_grup_id           NUMBER (10);
      v_uygulama_islem_id       NUMBER (10) := 75;
      v_hediye_tipi             NUMBER (2);
      for_continue_err          EXCEPTION;
      v_user_name               VARCHAR2 (20);
      v_password                VARCHAR2 (20);
   BEGIN
      v_kutlama_illegal_gunler := dbs_sabit ('ABONE_DOGUM_GUNU_KUTLAMA_ILLEGAL_GUNLER');

      IF INSTR (v_kutlama_illegal_gunler, TO_CHAR (SYSDATE, 'DD.MM')) > 0 THEN
         v_illegal_kutlama_gunu_mu := TRUE;
      END IF;

      v_hediye_tipi            := 2;

      --NVL (dbs_sabit ('ABONE_DOGUM_GUNU_HEDIYE_TIPI'), 2);

      --eger birsey set edilmemisse, task planindaki gibi hav. akt. set edilsin.
      FOR abone_detay_rec IN cur_abone_detay LOOP
         BEGIN
            v_abone_bedava_hediye_ata := FALSE;
            out_durum                 := '0';

            IF v_ittp_order_int_open = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_life b,
                      wiz_customer_hp_svc svc
                WHERE     b.account_number = svc.account_number
                      AND b.account_number = abone_detay_rec.account_number
                      AND b.customer_status = 'AC'
                      AND b.franchise_code IN ('F01', 'F02')
                      AND b.customer_type = 'NOR'
                      AND b.hp_cluster IN ('PH', 'ZS')
                      AND uye_aktif_sure (abone_detay_rec.account_number) > 12;
            ELSIF v_ittp_order_int_open = 1 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_life b,
                      dt_dbs_int_dba.vv_uye_ittp_servisler svc
                WHERE     b.account_number = svc.account_number
                      AND b.account_number = abone_detay_rec.account_number
                      AND b.customer_status = 'AC'
                      AND b.franchise_code IN ('F01', 'F02')
                      AND b.customer_type = 'NOR'
                      AND b.hp_cluster IN ('PH', 'ZS')
                      AND uye_aktif_sure (abone_detay_rec.account_number) > 12;
            END IF;

            --service i olan,12 aydan buyuk akt ph vs uyeler
            IF v_count > 0 THEN
               IF v_hediye_tipi = 1 --'KUPON'
                                   THEN
                  abone_dogum_gunu_kupon_ekle (abone_detay_rec.account_number, v_abone_bedava_hediye_ata, out_durum);

                  IF NOT v_abone_bedava_hediye_ata THEN
                     --kupon eklenemedi, dolayisiyla bilgilendirme vs de gitmemeli
                     RAISE for_continue_err;
                  END IF;
               ELSIF v_hediye_tipi = 2 --'HAVADAN_AKTIVASYON'
                                      THEN
                  abone_havadan_aktivasyon_ekle (abone_detay_rec.account_number, v_abone_bedava_hediye_ata, out_durum);

                  IF out_durum <> '0' --NOT v_abone_bedava_hediye_ata
                                     THEN
                     insert_log (out_durum);
                     out_durum := '0';
                     RAISE for_continue_err;
                  END IF;
               END IF;
            END IF;

            FOR descr_rec IN cur_descrip (abone_detay_rec.account_number) LOOP
               --eger kutlama acisindan istisna bir gun ise ve aboneye bedava kupon atanmamissa herhangi bir mesaj atma
               IF v_illegal_kutlama_gunu_mu AND NOT v_abone_bedava_hediye_ata THEN
                  EXIT;
               END IF;

               FOR equip_rec IN cur_eqp (abone_detay_rec.account_number) LOOP
                  abone_dogum_gunu_kupon_ird_cik (abone_detay_rec.account_number,
                                                  equip_rec.serial_number,
                                                  equip_rec.outlet_location,
                                                  TRIM (descr_rec.ad),
                                                  TRIM (descr_rec.soyad),
                                                  out_durum,
                                                  v_abone_bedava_hediye_ata,
                                                  v_hediye_tipi
                                                 );

                  IF out_durum <> '0' THEN
                     --insert_log (out_durum);
                     out_durum := '0';
                  END IF;
               END LOOP;

               IF abone_detay_rec.franchise_code = 'F04' THEN
                  v_email := NULL; --F04 üyeler MAIL istemiyor sadece SMS olucak...
               ELSE
                  v_email := iletisim_mail_pack.email_getir (abone_detay_rec.account_number);
               END IF;

               IF (TRIM (v_email) IS NOT NULL) THEN
                  abone_dogum_gunu_kupon_mail_at (2, --sekil_id
                                                  abone_detay_rec.account_number,
                                                  TRIM (descr_rec.ad) || ' ' || TRIM (descr_rec.soyad),
                                                  v_email,
                                                  out_durum,
                                                  v_abone_bedava_hediye_ata,
                                                  v_hediye_tipi,
                                                  abone_detay_rec.franchise_code
                                                 );

                  IF out_durum <> '0' THEN
                     insert_log (out_durum);
                     out_durum := '0';
                  END IF;
               ELSE
                  IF (v_abone_bedava_hediye_ata AND abone_detay_rec.franchise_code = 'F01') OR abone_detay_rec.franchise_code = 'F04' -- F02 lere sms gönderimi yapilmiyor.
                                                                                                                                     THEN
                     IF abone_detay_rec.franchise_code = 'F04' THEN
                        v_uygulama_islem_id := 81;
                        v_user_name         := 'routineMSGUsr';
                        v_password          := '0ly12Mp0s9';

                        IF v_grup_f04 IS NULL THEN
                           v_grup_f04      := -1;
                           v_istek_grup_id := NULL;
                        ELSE
                           v_istek_grup_id := v_grup_f04;
                        END IF;
                     ELSE
                        v_uygulama_islem_id := 75;
                        v_user_name         := 'reminder';
                        v_password          := 'dbs';

                        IF v_grup_f01 IS NULL THEN
                           v_grup_f01      := -1;
                           v_istek_grup_id := NULL;
                        ELSE
                           v_istek_grup_id := v_grup_f01;
                        END IF;
                     END IF;

                     abone_dogum_gunu_kupon_sms_at (abone_detay_rec.account_number,
                                                    TRIM (descr_rec.ad),
                                                    TRIM (descr_rec.soyad),
                                                    v_istek_grup_id,
                                                    v_uygulama_islem_id, --v_uygulama_islem_id := 91;
                                                    v_user_name, --'reminder',
                                                    v_password, --'dbs',
                                                    out_durum,
                                                    v_abone_bedava_hediye_ata,
                                                    v_hediye_tipi
                                                   );

                     IF v_grup_f04 = -1 THEN
                        v_grup_f04 := v_istek_grup_id;
                     END IF;

                     IF v_grup_f01 = -1 THEN
                        v_grup_f01 := v_istek_grup_id;
                     END IF;

                     IF out_durum <> '0' THEN
                        insert_log ('ABONE_BATCH_PACK.abone_dogum_gunu_kupon_sms_at ' || out_durum);
                        out_durum := '0';
                     END IF;
                  END IF;
               END IF;
            --Almanya için SMS gönderimi - 03.9.2012 - Mesut Keçecioglu
            END LOOP;
         EXCEPTION
            WHEN for_continue_err THEN
               COMMIT;
            WHEN OTHERS THEN
               ROLLBACK;
               insert_log (SQLERRM);
               out_durum := '0';
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   PROCEDURE uye_tc_kimlik_sorgula IS
      v_account_number        mb_abone_detay_bilgi.account_number%TYPE;
      v_anne_adi              mb_abone_detay_bilgi.anne_adi%TYPE;
      v_baba_adi              mb_abone_detay_bilgi.baba_adi%TYPE;
      v_dogum_tarihi          mb_abone_detay_bilgi.dogum_tarihi%TYPE;
      v_nufusa_kayitli_ili    mb_abone_detay_bilgi.nufusa_kayitli_ili%TYPE;
      v_nufusa_kayitli_ilcesi mb_abone_detay_bilgi.nufusa_kayitli_ilcesi%TYPE;
      v_cilt_no               mb_abone_detay_bilgi.cilt_no%TYPE;
      v_aile_sira_no          mb_abone_detay_bilgi.aile_sira_no%TYPE;
      v_sira_no               mb_abone_detay_bilgi.sira_no%TYPE;
      v_id                    lg_abone_detay_bilgi.id%TYPE;
      v_title                 wiz_customer_descrip.title%TYPE;
      v_ad                    wiz_customer_descrip.first_name%TYPE;
      v_soyad                 wiz_customer_descrip.last_name%TYPE;
      v_kilit                 VARCHAR2 (3000);
      tc_guncelle             NUMBER (10);
      durum                   VARCHAR2 (1000);
      v_durum                 VARCHAR2 (1000);
      v_tmp_durum             VARCHAR2 (1000);
      v_dummy_kisi_durum      VARCHAR2 (10);
      v_vatandaslikno         yk_dp_kontrat.tc_kimlik_no%TYPE;
      v_tc_kimlik_gecerli     mb_abone_detay_bilgi.tc_kimlik_no_gecerli%TYPE;
      v_tmp_vatandaslikno     yk_dp_kontrat.tc_kimlik_no%TYPE;
      for_continue_error      EXCEPTION;
      v_msg                   VARCHAR2 (3000);
      ivatnorequired          VARCHAR2 (1) := 'H';
      v_tckn_validation_type  NUMBER (2);
   BEGIN
      FOR rec IN (SELECT *
                    FROM sms_dba.sms_uye_tckimlik
                   WHERE durum = 'N') LOOP
         BEGIN
            v_account_number    := rec.account_number;

            /****************<EGER UYENIN TC KIMLIK DURUMU VALID ISE DOKUNMA>******************/
            SELECT COUNT (1)
              INTO tc_guncelle
              FROM mb_abone_detay_bilgi
             WHERE account_number = v_account_number AND tc_kimlik_no_gecerli = 'V';

            IF tc_guncelle > 0 THEN
               v_tc_kimlik_gecerli := 'P';

               UPDATE sms_dba.sms_uye_tckimlik
                  SET durum = v_tc_kimlik_gecerli, islem_tarihi = SYSDATE
                WHERE account_number = v_account_number;

               RAISE for_continue_error;
            END IF;

            /****************</EGER UYENIN TC KIMLIK DURUMU VALID ISE DOKUNMA>******************/
            abone_islem_pack.abone_islem (v_account_number, v_kilit, v_msg);

            IF v_kilit <> '0' THEN
               RAISE for_continue_error;
            END IF;

            /****************<UYE BILGILERINI CEK/>******************/
            BEGIN
               SELECT DISTINCT
                      mb_abone_detay_bilgi.anne_adi,
                      mb_abone_detay_bilgi.baba_adi,
                      mb_abone_detay_bilgi.dogum_tarihi,
                      mb_abone_detay_bilgi.nufusa_kayitli_ili,
                      mb_abone_detay_bilgi.nufusa_kayitli_ilcesi,
                      mb_abone_detay_bilgi.cilt_no,
                      mb_abone_detay_bilgi.aile_sira_no,
                      mb_abone_detay_bilgi.sira_no,
                      wiz_customer_descrip.title,
                      wiz_customer_descrip.first_name,
                      wiz_customer_descrip.last_name
                 INTO v_anne_adi,
                      v_baba_adi,
                      v_dogum_tarihi,
                      v_nufusa_kayitli_ili,
                      v_nufusa_kayitli_ilcesi,
                      v_cilt_no,
                      v_aile_sira_no,
                      v_sira_no,
                      v_title,
                      v_ad,
                      v_soyad
                 FROM mb_abone_detay_bilgi,
                      wiz_customer_descrip
                WHERE     mb_abone_detay_bilgi.account_number = wiz_customer_descrip.account_number
                      AND mb_abone_detay_bilgi.account_number = v_account_number
                      AND (tabiyet = 'TÜRKİYE' OR tabiyet IS NULL)
                      AND kisi_tipi = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  /****************<EGER TC KIMLIK ILE ALAKALI BIR KAYIT DEGILSE F03 TIC VS gelen tckimlikno yu mb'ye at ama gecerli NULL olsun, SMS E de gecerliye NULL AT/>******************/
                  v_tc_kimlik_gecerli := NULL;

                  UPDATE mb_abone_detay_bilgi
                     SET tc_kimlik_no_gecerli = v_tc_kimlik_gecerli,
                         tc_kimlik_no         = rec.tckimlik_no,
                         degistiren_kullanici = 'SYSTEM',
                         degistirme_tarihi    = SYSDATE
                   WHERE account_number = v_account_number;

                  abone_detay_pack.lg_abone_detay_bilgi_update (v_account_number, 'SYSTEM');

                  UPDATE sms_dba.sms_uye_tckimlik
                     SET durum = v_tc_kimlik_gecerli, islem_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  RAISE for_continue_error;
            END;

            /***********************************<TCKN SORGULAMA BLOGU>*****************************************/
            v_vatandaslikno     := rec.tckimlik_no;
            v_tmp_vatandaslikno := rec.tckimlik_no;
            v_tc_kimlik_gecerli := 'F';
            durum               := '0';

            IF NVL (dbs_sabit ('NEW_TCKN_WEB_SERVICE_IS_OPEN'), '0') = '0' THEN
               IF    v_vatandaslikno IS NULL
                  OR (NOT webrequest_pack.check_vatandaslikno (v_ad,
                                                               v_soyad,
                                                               TO_CHAR (v_dogum_tarihi, 'YYYY'),
                                                               v_vatandaslikno,
                                                               v_tmp_durum,
                                                               v_dummy_kisi_durum
                                                              )) THEN
                  webrequest_pack.get_vatandaslikno1 (v_no            => v_account_number,
                                                      annead          => v_anne_adi,
                                                      babaad          => v_baba_adi,
                                                      dogumtarihi     => v_dogum_tarihi,
                                                      kullanici       => 'SYSTEM',
                                                      vatandaslik_no  => v_vatandaslikno,
                                                      durum           => durum,
                                                      ivatno_required => ivatnorequired,
                                                      kisi_durum      => v_dummy_kisi_durum
                                                     );
               --               IF v_vatandaslikno IS NULL
               --               THEN
               --                  v_durum := '0';
               --                  webrequest_pack.get_vatandaslikno2 (v_account_number,
               --                                                      v_cilt_no,
               --                                                      v_aile_sira_no,
               --                                                      v_sira_no,
               --                                                      v_nufusa_kayitli_ili,
               --                                                      v_nufusa_kayitli_ilcesi,
               --                                                      'SYSTEM',
               --                                                      v_vatandaslikno,
               --                                                      v_durum,
               --                                                      ivatnorequired
               --                                                     );
               --
               --                  IF v_durum = '0'
               --                  THEN
               --                     durum := '0';
               --                  END IF;
               --               END IF;
               END IF;

               IF v_vatandaslikno IS NULL AND v_tmp_vatandaslikno IS NOT NULL THEN
                  /** Vatandaslik No bilgisi dogrulanamadi**/
                  UPDATE mb_abone_detay_bilgi
                     SET tc_kimlik_no_gecerli = 'F', /*v_status,*/
                                                    tc_kimlik_no = v_tmp_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  abone_detay_pack.lg_abone_detay_bilgi_update (v_account_number, 'SYSTEM');

                  UPDATE sms_dba.sms_uye_tckimlik
                     SET durum = 'F', islem_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  RAISE for_continue_error;
               ELSIF v_vatandaslikno <> v_tmp_vatandaslikno THEN
                  /** Vatandaslik No bilgisi dogrulanamadi**/
                  UPDATE mb_abone_detay_bilgi
                     SET tc_kimlik_no_gecerli = 'V', /*v_status,*/
                                                    tc_kimlik_no = v_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  abone_detay_pack.lg_abone_detay_bilgi_update (v_account_number, 'SYSTEM');

                  UPDATE sms_dba.sms_uye_tckimlik
                     SET durum = 'P', islem_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  RAISE for_continue_error;
               END IF;

               IF durum <> '0' THEN
                  /******buraya girmediginden emin ol******/
                  log_pack.log_is_emri_hata (v_account_number,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             'J', -- job ile uyelik iptali toplu islemi
                                             'SYSTEM',
                                             SYSDATE,
                                             NULL,
                                             'TCKN BATCH1: ' || SUBSTR (durum, 1, 200),
                                             durum
                                            );
                  RAISE for_continue_error;
               END IF;

               IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E' THEN
                  --IF v_vatandaslikno IS NOT NULL
                  --THEN
                  v_tc_kimlik_gecerli := 'E';
               --END IF;
               ELSE
                  IF v_vatandaslikno IS NOT NULL THEN
                     v_tc_kimlik_gecerli := 'V';
                  END IF;
               END IF;
            ELSE --yeni tckn servisi
               v_tckn_validation_type      := dbs_dba.webrequest_pack.check_vatandaslik_no_yeni (in_ad             => v_ad,
                                                                                                 in_soyad          => v_soyad,
                                                                                                 in_dogum_tarihi   => TO_CHAR (v_dogum_tarihi, 'DD/MM/YYYY'),
                                                                                                 in_vatandaslik_no => v_vatandaslikno,
                                                                                                 o_durum           => durum
                                                                                                );

               IF v_tckn_validation_type = 0 THEN --tckn doğrulanamadı ise
                  UPDATE mb_abone_detay_bilgi
                     SET tc_kimlik_no_gecerli = 'F', /*v_status,*/
                                                    tc_kimlik_no = v_tmp_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  abone_detay_pack.lg_abone_detay_bilgi_update (v_account_number, 'SYSTEM');

                  UPDATE sms_dba.sms_uye_tckimlik
                     SET durum = 'F', islem_tarihi = SYSDATE
                   WHERE account_number = v_account_number;

                  RAISE for_continue_error;
               ELSIF v_tckn_validation_type > 0 THEN --tckn doğrulandı ise
                  --sabit E ise tckn durumu V olarak setlenmemeli.E olarak setlenmeli.
                  IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E' THEN
                     v_tc_kimlik_gecerli := 'E';
                  ELSE
                     v_tc_kimlik_gecerli := 'V';
                  END IF;
               ELSIF v_tckn_validation_type = -1 THEN --sorgulama sırasında hata alırsa
                  --sorgulama sırasında hataalırsa loglanıyor
                  log_pack.log_is_emri_hata (v_account_number,
                                             NULL,
                                             NULL,
                                             NULL,
                                             NULL,
                                             'J', -- job ile uyelik iptali toplu islemi
                                             'SYSTEM',
                                             SYSDATE,
                                             NULL,
                                             'TCKN BATCH1: ' || SUBSTR (durum, 1, 200),
                                             durum
                                            );
                  RAISE for_continue_error;
               END IF;
            END IF; --MKECECI - yeni TCKN servisi

            /***********************************</TCKN SORGULAMA BLOGU>*****************************************/
            UPDATE mb_abone_detay_bilgi
               SET tc_kimlik_no_gecerli = v_tc_kimlik_gecerli, /*v_status,*/
                                                              tc_kimlik_no = v_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
             WHERE account_number = v_account_number;

            abone_detay_pack.lg_abone_detay_bilgi_update (v_account_number, 'SYSTEM');

            UPDATE sms_dba.sms_uye_tckimlik
               SET durum = v_tc_kimlik_gecerli, islem_tarihi = SYSDATE
             WHERE account_number = v_account_number;

            COMMIT;
         EXCEPTION
            WHEN for_continue_error THEN
               COMMIT;
               durum := '0';
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         log_pack.log_is_emri_hata (v_account_number, NULL, NULL, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                                  'SYSTEM', SYSDATE, NULL, 'TCKN BATCH2: ' || SUBSTR (durum, 1, 200), durum);
         COMMIT;
         NULL;
   END uye_tc_kimlik_sorgula;

   PROCEDURE tckn_check_service IS
      tckn_dbs_working   VARCHAR2 (1);
      out_durum          VARCHAR2 (512);
      v_vatandaslikno    NUMBER (11);
      v_dummy_kisi_durum VARCHAR2 (10);

      --dtvcaloglu - tc kimlik no kontrol - 06.12.2013
      tmp_mailfrom       VARCHAR2 (50);
      tmp_mailto         VARCHAR2 (5000);
      tmp_mailsubject    VARCHAR2 (75);
      tmp_mailmimetype   VARCHAR2 (50);
      tmp_mailcontent    VARCHAR2 (500);
      v_sonuc            NUMBER;
   BEGIN
      tckn_dbs_working     := NVL (dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET'), 'H');
      DBMS_OUTPUT.put_line ('DBS parametre = ' || tckn_dbs_working);

      --dtvcaloglu - tc kimlik no kontrol - 06.12.2013
      tmp_mailfrom         := 'irisadmin@turk.com.tr';
      tmp_mailto           := 'irisadmin@turk.com.tr;gokhan.ozturk@turk.com.tr;taner.ari@turk.com.tr;onur.cinemre@consultant.turk.com.tr;murat.gunermengi@turk.com.tr;okan.akinci@turk.com.tr;mustafa.temiz@turk.com.tr;mesut.kececioglu@turk.com.tr';
      tmp_mailsubject      := 'DBS Uygulamasında TC Kimlik Doğrulama Parametre Değişikliği';
      tmp_mailmimetype     := 'text/html; charset=UTF - 8';
      tmp_mailcontent      :=    '<html>
        <p>
            DBS Uygulamasında TC Kimlik Dogrulama parametresi <b>AÇILDI</b>
        </p>        
        <p>
            Parametre Degistirme Tarihi :  <b> '
                              || TO_CHAR (SYSDATE, 'DD.MM.YYYY HH24:MI:SS')
                              || '</b>
            <br>TC Kimlik No Dogrulama : <b>AÇIK</b>
        </p>      
      </html>';

      IF tckn_dbs_working <> 'E' THEN
         --once webrequesti account_number ki get vat no calissin
         UPDATE pa_sabitler
            SET deger = 'E'
          WHERE adi = 'TC_KIMLIK_NO_KONTROL_ET';

         IF NVL (dbs_sabit ('NEW_TCKN_WEB_SERVICE_IS_OPEN'), '0') = '0' THEN
            webrequest_pack.get_vatandaslikno1 (v_no            => 1403423,
                                                annead          => 'SEVİM',
                                                babaad          => 'AHMET İLHAN',
                                                dogumtarihi     => TO_DATE ('24.12.1981', 'dd.mm.yyyy'),
                                                kullanici       => 'SYSTEM',
                                                vatandaslik_no  => v_vatandaslikno,
                                                durum           => out_durum,
                                                ivatno_required => 'E',
                                                kisi_durum      => v_dummy_kisi_durum
                                               );

            IF v_vatandaslikno = 45550359208 THEN
               DBMS_OUTPUT.put_line ('TCKN TC working. DBS sabitin acilmasi gerekiyor.');
               tckn_dbs_working := 'E';

               --dtvcaloglu - tc kimlik no kontrol - 06.12.2013
               UTL_MAIL.send (tmp_mailfrom, tmp_mailto, NULL, NULL, tmp_mailsubject, tmp_mailcontent, tmp_mailmimetype, NULL);
            ELSE
               DBMS_OUTPUT.put_line ('TCKN TC NOT working. ');
               tckn_dbs_working := 'H';
            END IF;
         ELSE -- yeni tckn web servisi
            v_sonuc      := dbs_dba.webrequest_pack.check_vatandaslik_no_yeni (in_ad             => 'SÜLEYMAN MESUT',
                                                                               in_soyad          => 'KEÇECİOĞLU',
                                                                               in_dogum_tarihi   => '07.09.1989',
                                                                               in_vatandaslik_no => '26812254370',
                                                                               in_cuzdan_seri_no => NULL,
                                                                               in_cuzdan_no      => NULL,
                                                                               in_kimlik_seri_no => NULL,
                                                                               o_durum           => out_durum
                                                                              );

            IF v_sonuc > 0 THEN -- tckn doğrulandi ise
               DBMS_OUTPUT.put_line ('TCKN web service is working...(web_service_result' || out_durum || ') DBS sabitin acilmasi gerekiyor.');
               tckn_dbs_working := 'E';

               --dtvcaloglu - tc kimlik no kontrol - 06.12.2013
               UTL_MAIL.send (tmp_mailfrom, tmp_mailto, NULL, NULL, tmp_mailsubject, tmp_mailcontent, tmp_mailmimetype, NULL);
            ELSE
               DBMS_OUTPUT.put_line ('TCKN TC NOT working. ');
               tckn_dbs_working := 'H';
            END IF;
         END IF;

         UPDATE pa_sabitler
            SET deger = tckn_dbs_working
          WHERE adi = 'TC_KIMLIK_NO_KONTROL_ET';
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', 'SYSTEM', SYSDATE, NULL, SUBSTR ('tckn_check_service: ' || SQLERRM, 1, 256), out_durum);

         IF out_durum = '0' THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
   END;

   PROCEDURE tckn_exception_recovery (in_account_number IN NUMBER := NULL, in_kayit_tipi IN VARCHAR2 := NULL -- U Uye, P Potansiyel, null ise her ikisi içinde tüm kayitlara bakilacak.
                                                                                                            ) IS
      v_hour                  NUMBER (2);
      v_rownum                NUMBER (10) := 500;
      v_anne_adi              mb_abone_detay_bilgi.anne_adi%TYPE;
      v_baba_adi              mb_abone_detay_bilgi.baba_adi%TYPE;
      v_dogum_tarihi          mb_abone_detay_bilgi.dogum_tarihi%TYPE;
      v_nufusa_kayitli_ili    mb_abone_detay_bilgi.nufusa_kayitli_ili%TYPE;
      v_nufusa_kayitli_ilcesi mb_abone_detay_bilgi.nufusa_kayitli_ilcesi%TYPE;
      v_cilt_no               mb_abone_detay_bilgi.cilt_no%TYPE;
      v_aile_sira_no          mb_abone_detay_bilgi.aile_sira_no%TYPE;
      v_sira_no               mb_abone_detay_bilgi.sira_no%TYPE;
      v_id                    lg_abone_detay_bilgi.id%TYPE;
      v_title                 wiz_customer_descrip.title%TYPE;
      v_ad                    wiz_customer_descrip.first_name%TYPE;
      v_soyad                 wiz_customer_descrip.last_name%TYPE;
      v_kilit                 VARCHAR2 (3000);
      durum                   VARCHAR2 (1000);
      v_durum                 VARCHAR2 (1000);
      v_tmp_durum             VARCHAR2 (1000);

      v_vatandaslikno         yk_dp_kontrat.tc_kimlik_no%TYPE;
      v_tc_kimlik_gecerli     mb_abone_detay_bilgi.tc_kimlik_no_gecerli%TYPE;
      v_tmp_vatandaslikno     yk_dp_kontrat.tc_kimlik_no%TYPE;
      for_continue_error      EXCEPTION;
      v_msg                   VARCHAR2 (3000);
      ivatnorequired          VARCHAR2 (1) := 'H';
      v_dummy_kisi_durum      VARCHAR2 (10);
      v_tckn_validation_type  NUMBER;
      --uncomment edilecek //aybala 23032015
      --v_individual_id         NUMBER;
      v_citizen_number        NUMBER;
      v_qualification_status  VARCHAR2 (20);
   BEGIN
      tckn_check_service;
      v_hour := TO_NUMBER (TO_CHAR (SYSDATE, 'hh24'));

      IF v_hour > 7 THEN
         RETURN;
      END IF;

      BEGIN
         v_rownum := NVL (TO_NUMBER (dbs_sabit ('TC_KIMLIK_NO_EXCEPTION_RECOVERY_LIMIT')), 500);
      EXCEPTION
         WHEN OTHERS THEN
            v_rownum := 500;
      END;

      IF in_kayit_tipi = 'U' OR in_kayit_tipi IS NULL THEN
         FOR rec IN (SELECT *
                       FROM mb_abone_detay_bilgi
                      WHERE tc_kimlik_no_gecerli = 'E' AND ROWNUM < v_rownum AND (account_number = in_account_number OR in_account_number IS NULL)) LOOP
            BEGIN
               IF NVL (dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET'), 'H') = 'E' THEN
                  abone_islem_pack.abone_islem (rec.account_number, v_kilit, v_msg);

                  IF v_kilit <> '0' THEN
                     ROLLBACK;
                     RAISE for_continue_error;
                  END IF;

                  /****************<UYE BILGILERINI CEK/>******************/
                  BEGIN
                     SELECT DISTINCT
                            rec.anne_adi,
                            rec.baba_adi,
                            rec.dogum_tarihi,
                            rec.nufusa_kayitli_ili,
                            rec.nufusa_kayitli_ilcesi,
                            rec.cilt_no,
                            rec.aile_sira_no,
                            rec.sira_no,
                            wiz_customer_descrip.title,
                            wiz_customer_descrip.first_name,
                            wiz_customer_descrip.last_name,
                            rec.tc_kimlik_no
                       INTO v_anne_adi,
                            v_baba_adi,
                            v_dogum_tarihi,
                            v_nufusa_kayitli_ili,
                            v_nufusa_kayitli_ilcesi,
                            v_cilt_no,
                            v_aile_sira_no,
                            v_sira_no,
                            v_title,
                            v_ad,
                            v_soyad,
                            v_vatandaslikno
                       FROM mb_abone_detay_bilgi,
                            wiz_customer_descrip
                      WHERE     mb_abone_detay_bilgi.account_number = wiz_customer_descrip.account_number
                            AND mb_abone_detay_bilgi.account_number = rec.account_number
                            AND (tabiyet = 'TÜRKİYE' OR tabiyet IS NULL)
                            AND kisi_tipi = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        /****************<EGER TC KIMLIK ILE ALAKALI BIR KAYIT DEGILSE TIC VS mb'de tckimlikno varsa birak ve gecerliye DE NULL AT/>******************/
                        /*eger uye ornegin Alman,Kibrisli vs ise ve bize Vat No veriyorsa Tutariz. ama gecerliye NULL atariz.*/
                        v_tc_kimlik_gecerli := NULL;

                        UPDATE mb_abone_detay_bilgi
                           SET tc_kimlik_no_gecerli = v_tc_kimlik_gecerli, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                         WHERE account_number = rec.account_number;

                        abone_detay_pack.lg_abone_detay_bilgi_update (rec.account_number, 'SYSTEM');
                        RAISE for_continue_error;
                  END;

                  /***********************************<TCKN SORGULAMA BLOGU>*****************************************/
                  v_tmp_vatandaslikno := v_vatandaslikno;
                  v_tc_kimlik_gecerli := 'F';
                  durum               := '0';

                  IF NVL (dbs_sabit ('NEW_TCKN_WEB_SERVICE_IS_OPEN'), '0') = '0' THEN --MKECECI - 29.01.2015 yeni TCKN geliştirmeleri
                     IF    v_vatandaslikno IS NULL
                        OR (NOT webrequest_pack.check_vatandaslikno (v_ad,
                                                                     v_soyad,
                                                                     TO_CHAR (v_dogum_tarihi, 'YYYY'),
                                                                     v_vatandaslikno,
                                                                     v_tmp_durum,
                                                                     v_dummy_kisi_durum
                                                                    )) THEN
                        webrequest_pack.get_vatandaslikno1 (v_no            => rec.account_number,
                                                            annead          => v_anne_adi,
                                                            babaad          => v_baba_adi,
                                                            dogumtarihi     => v_dogum_tarihi,
                                                            kullanici       => 'SYSTEM',
                                                            vatandaslik_no  => v_vatandaslikno,
                                                            durum           => durum,
                                                            ivatno_required => ivatnorequired,
                                                            kisi_durum      => v_dummy_kisi_durum
                                                           );
                     --                     IF v_vatandaslikno IS NULL
                     --                     THEN
                     --                        v_durum := '0';
                     --                        webrequest_pack.get_vatandaslikno2 (rec.account_number,
                     --                                                            v_cilt_no,
                     --                                                            v_aile_sira_no,
                     --                                                            v_sira_no,
                     --                                                            v_nufusa_kayitli_ili,
                     --                                                            v_nufusa_kayitli_ilcesi,
                     --                                                            'SYSTEM',
                     --                                                            v_vatandaslikno,
                     --                                                            v_durum,
                     --                                                            ivatnorequired
                     --                                                           );
                     --
                     --                        IF v_durum = '0'
                     --                        THEN
                     --                           durum := '0';
                     --                        END IF;
                     --                     END IF;
                     END IF;

                     IF v_vatandaslikno IS NULL AND v_tmp_vatandaslikno IS NOT NULL THEN
                        /** Vatandaslik No bilgisi dogrulanamadi**/
                        UPDATE mb_abone_detay_bilgi
                           SET tc_kimlik_no_gecerli = 'F', /*v_status,*/
                                                          tc_kimlik_no = v_tmp_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                         WHERE account_number = rec.account_number;

                        abone_detay_pack.lg_abone_detay_bilgi_update (rec.account_number, 'SYSTEM');
                        RAISE for_continue_error;
                     ELSIF v_vatandaslikno <> v_tmp_vatandaslikno THEN
                        /** Vatandaslik No bilgisi dogrulanamadi**/
                        UPDATE mb_abone_detay_bilgi
                           SET tc_kimlik_no_gecerli = 'V', /*v_status,*/
                                                          tc_kimlik_no = v_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                         WHERE account_number = rec.account_number;

                        abone_detay_pack.lg_abone_detay_bilgi_update (rec.account_number, 'SYSTEM');
                        --valid tckn ittp ve party_role kontrolu icin eklendi aybalasert 13032015
                        --uncomment edilecek //aybala 23032015
                        --billing_dbs_int.account_ittp_pkg.tckn_validation_set_sp (i_dbs_account_number => rec.account_number, i_valid_tckn => v_vatandaslikno);

                        RAISE for_continue_error;
                     END IF;

                     IF durum <> '0' THEN
                        /******buraya girmediginden emin ol******/
                        log_pack.log_is_emri_hata (rec.account_number,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   'J', -- job ile uyelik iptali toplu islemi
                                                   'SYSTEM',
                                                   SYSDATE,
                                                   NULL,
                                                   'tckn_exception_recovery: ' || SUBSTR (durum, 1, 200),
                                                   durum
                                                  );
                        RAISE for_continue_error;
                     END IF;

                     IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E' THEN
                        --IF v_vatandaslikno IS NOT NULL
                        --THEN
                        v_tc_kimlik_gecerli := 'E';
                     --END IF;
                     ELSE
                        IF v_vatandaslikno IS NOT NULL THEN
                           v_tc_kimlik_gecerli := 'V';
                        END IF;
                     END IF;
                  ELSE --yeni tckn geliştirmeleri
                     v_tckn_validation_type      := dbs_dba.webrequest_pack.check_vatandaslik_no_yeni (
                                                       in_ad             => v_ad,
                                                       in_soyad          => v_soyad,
                                                       in_dogum_tarihi   => TO_CHAR (v_dogum_tarihi, 'DD/MM/YYYY'),
                                                       in_vatandaslik_no => v_vatandaslikno,
                                                       o_durum           => v_tmp_durum);

                     IF v_tckn_validation_type = 0 THEN --tckn doğrulanamadı ise
                        UPDATE mb_abone_detay_bilgi
                           SET tc_kimlik_no_gecerli = 'F', tc_kimlik_no = v_tmp_vatandaslikno, degistiren_kullanici = 'SYSTEM', degistirme_tarihi = SYSDATE
                         WHERE account_number = rec.account_number;

                        abone_detay_pack.lg_abone_detay_bilgi_update (rec.account_number, 'SYSTEM');

                        UPDATE sms_dba.sms_uye_tckimlik
                           SET durum = 'F', islem_tarihi = SYSDATE
                         WHERE account_number = rec.account_number;

                        RAISE for_continue_error;
                     ELSIF v_tckn_validation_type > 0 THEN --tckn doğrulandı ise
                        --sabit E ise tckn durumu V olarak setlenmemeli.E olarak setlenmeli.
                        IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E' THEN
                           v_tc_kimlik_gecerli := 'E';
                        ELSE
                           v_tc_kimlik_gecerli := 'V';
                        END IF;
                     ELSIF v_tckn_validation_type = -1 THEN --sorgulama sırasında hata alırsa
                        --sorgulama sırasında hataalırsa loglanıyor
                        log_pack.log_is_emri_hata (rec.account_number,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   'J', -- job ile uyelik iptali toplu islemi
                                                   'SYSTEM',
                                                   SYSDATE,
                                                   NULL,
                                                   'TCKN BATCH1: ' || SUBSTR (durum, 1, 200),
                                                   v_tmp_durum
                                                  );
                        RAISE for_continue_error;
                     END IF;
                  END IF;

                  /***********************************</TCKN SORGULAMA BLOGU>*****************************************/
                  UPDATE mb_abone_detay_bilgi
                     SET tc_kimlik_no_gecerli = v_tc_kimlik_gecerli,
                         /*v_status,*/
                         tc_kimlik_no         = v_vatandaslikno,
                         degistiren_kullanici = 'SYSTEM',
                         degistirme_tarihi    = SYSDATE
                   WHERE account_number = rec.account_number;

                  abone_detay_pack.lg_abone_detay_bilgi_update (rec.account_number, 'SYSTEM');
                  COMMIT;

                  --uncomment edilecek //aybala 23032015
--                  IF v_tc_kimlik_gecerli = 'V' THEN
--                     --valid tckn ittp ve party_role kontrolu icin eklendi aybalasert 13032015
--
--                     billing_dbs_int.account_ittp_pkg.tckn_validation_set_sp (i_dbs_account_number => rec.account_number, i_valid_tckn => v_vatandaslikno);
--                  END IF;
               ELSE
                  EXIT;
               END IF;
            EXCEPTION
               WHEN for_continue_error THEN
                  COMMIT;
                  durum := '0';
            END;
         END LOOP;
      END IF;

      IF in_kayit_tipi = 'P' OR in_kayit_tipi IS NULL THEN
         FOR rec IN (SELECT *
                       FROM wiz_prospect_descrip
                      WHERE tc_kimlik_no_gecerli = 'E' AND ROWNUM < v_rownum AND (prospect_number = in_account_number OR in_account_number IS NULL)) LOOP
            BEGIN
               IF NVL (dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET'), 'H') = 'E' THEN
                  IF NVL (dbs_sabit ('NEW_TCKN_WEB_SERVICE_IS_OPEN'), '0') = '0' THEN --yeni TCKN servisi
                     /*abone_islem_pack.abone_islem (rec.account_number, v_kilit, v_msg);

                     IF v_kilit <> '0'
                     THEN
                        ROLLBACK;
                        RAISE for_continue_error;
                     END IF;  */

                     /****************<POTANSIYEL BILGILERINI CEK/>******************/
                     BEGIN
                        SELECT DISTINCT
                               rec.nufus_ana_adi,
                               rec.nufus_baba_adi,
                               rec.nufus_dogum_tar,
                               rec.nufus_il,
                               rec.nufus_ilce,
                               rec.nufus_cilt_no,
                               rec.nufus_aile_sira,
                               rec.nufus_birey_sira,
                               title,
                               first_name,
                               last_name,
                               rec.tckn
                          INTO v_anne_adi,
                               v_baba_adi,
                               v_dogum_tarihi,
                               v_nufusa_kayitli_ili,
                               v_nufusa_kayitli_ilcesi,
                               v_cilt_no,
                               v_aile_sira_no,
                               v_sira_no,
                               v_title,
                               v_ad,
                               v_soyad,
                               v_vatandaslikno
                          FROM wiz_prospect_descrip
                         WHERE prospect_number = rec.prospect_number AND (nufus_tabiyet = 'TÜRKİYE' OR nufus_tabiyet IS NULL);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           /****************<EGER TC KIMLIK ILE ALAKALI BIR KAYIT DEGILSE TIC VS mb'de tckimlikno varsa birak ve gecerliye DE NULL AT/>******************/
                           /*eger uye ornegin Alman,Kibrisli vs ise ve bize Vat No veriyorsa Tutariz. ama gecerliye NULL atariz.*/
                           v_tc_kimlik_gecerli := NULL;

                           UPDATE wiz_prospect_descrip
                              SET tc_kimlik_no_gecerli = v_tc_kimlik_gecerli, updating_user = 15, date_updated = SYSDATE
                            WHERE prospect_number = rec.prospect_number;

                           RAISE for_continue_error;
                     END;

                     /***********************************<TCKN SORGULAMA BLOGU>*****************************************/
                     v_tmp_vatandaslikno := v_vatandaslikno;
                     v_tc_kimlik_gecerli := 'F';
                     durum               := '0';

                     IF    v_vatandaslikno IS NULL
                        OR (NOT webrequest_pack.check_vatandaslikno (v_ad,
                                                                     v_soyad,
                                                                     TO_CHAR (v_dogum_tarihi, 'YYYY'),
                                                                     v_vatandaslikno,
                                                                     v_tmp_durum,
                                                                     v_dummy_kisi_durum
                                                                    )) THEN
                        webrequest_pack.get_vatandaslikno1 (rec.prospect_number,
                                                            v_anne_adi,
                                                            v_baba_adi,
                                                            v_dogum_tarihi,
                                                            --v_nufusa_kayitli_ili,
                                                            --v_nufusa_kayitli_ilcesi,
                                                            'SYSTEM',
                                                            v_vatandaslikno,
                                                            durum,
                                                            ivatnorequired,
                                                            'P',
                                                            v_dummy_kisi_durum
                                                           );
                     --                     IF v_vatandaslikno IS NULL
                     --                     THEN
                     --                        v_durum := '0';
                     --                        webrequest_pack.get_vatandaslikno2 (rec.prospect_number,
                     --                                                            v_cilt_no,
                     --                                                            v_aile_sira_no,
                     --                                                            v_sira_no,
                     --                                                            v_nufusa_kayitli_ili,
                     --                                                            v_nufusa_kayitli_ilcesi,
                     --                                                            'SYSTEM',
                     --                                                            v_vatandaslikno,
                     --                                                            v_durum,
                     --                                                            ivatnorequired,
                     --                                                            'P'
                     --                                                           );
                     --
                     --                        IF v_durum = '0'
                     --                        THEN
                     --                           durum := '0';
                     --                        END IF;
                     --                     END IF;
                     END IF;

                     IF v_vatandaslikno IS NULL AND v_tmp_vatandaslikno IS NOT NULL THEN
                        /** Vatandaslik No bilgisi dogrulanamadi**/
                        UPDATE wiz_prospect_descrip
                           SET tc_kimlik_no_gecerli = 'F', /*v_status,*/
                                                          tckn = v_tmp_vatandaslikno, updating_user = 15, date_updated = SYSDATE
                         WHERE prospect_number = rec.prospect_number;

                        RAISE for_continue_error;
                     ELSIF v_vatandaslikno <> v_tmp_vatandaslikno THEN
                        /** Vatandaslik No bilgisi dogrulanamadi**/
                        UPDATE wiz_prospect_descrip
                           SET tc_kimlik_no_gecerli = 'V', /*v_status,*/
                                                          tckn = v_vatandaslikno, updating_user = 15, date_updated = SYSDATE
                         WHERE prospect_number = rec.prospect_number;

                        RAISE for_continue_error;
                     END IF;

                     IF durum <> '0' THEN
                        /******buraya girmediginden emin ol******/
                        log_pack.log_is_emri_hata (rec.prospect_number,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   'J', -- job ile uyelik iptali toplu islemi
                                                   'SYSTEM',
                                                   SYSDATE,
                                                   NULL,
                                                   'tckn_exception_recovery: ' || SUBSTR (durum, 1, 200),
                                                   durum
                                                  );
                        RAISE for_continue_error;
                     END IF;

                     IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E' THEN
                        --IF v_vatandaslikno IS NOT NULL
                        --THEN
                        v_tc_kimlik_gecerli := 'E';
                     --END IF;
                     ELSE
                        IF v_vatandaslikno IS NOT NULL THEN
                           v_tc_kimlik_gecerli := 'V';
                        END IF;
                     END IF;
                  ELSE --yeni tckn servisi
                     v_tckn_validation_type      := dbs_dba.webrequest_pack.check_vatandaslik_no_yeni (
                                                       in_ad             => v_ad,
                                                       in_soyad          => v_soyad,
                                                       in_dogum_tarihi   => TO_CHAR (v_dogum_tarihi, 'DD/MM/YYYY'),
                                                       in_vatandaslik_no => v_vatandaslikno,
                                                       o_durum           => v_tmp_durum);

                     IF v_tckn_validation_type = 0 THEN --tckn doğrulanamadı ise
                        UPDATE wiz_prospect_descrip
                           SET tc_kimlik_no_gecerli = 'F', tckn = v_tmp_vatandaslikno, updating_user = 15, date_updated = SYSDATE
                         WHERE prospect_number = rec.prospect_number;

                        RAISE for_continue_error;
                     ELSIF v_tckn_validation_type > 0 THEN --tckn doğrulandı ise
                        --sabit E ise tckn durumu V olarak setlenmemeli.E olarak setlenmeli.
                        IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E' THEN
                           v_tc_kimlik_gecerli := 'E';
                        ELSE
                           v_tc_kimlik_gecerli := 'V';
                        END IF;
                     ELSIF v_tckn_validation_type = -1 THEN --sorgulama sırasında hata alırsa
                        --sorgulama sırasında hataalırsa loglanıyor
                        log_pack.log_is_emri_hata (rec.prospect_number,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   'J', -- job ile uyelik iptali toplu islemi
                                                   'SYSTEM',
                                                   SYSDATE,
                                                   NULL,
                                                   'TCKN BATCH1: ' || SUBSTR (v_tmp_durum, 1, 200),
                                                   v_tmp_durum
                                                  );
                        RAISE for_continue_error;
                     END IF;
                  END IF; --MKECECI - yeni tckn servisi

                  /***********************************</TCKN SORGULAMA BLOGU>*****************************************/
                  UPDATE wiz_prospect_descrip
                     SET tc_kimlik_no_gecerli = v_tc_kimlik_gecerli, /*v_status,*/
                                                                    tckn = v_vatandaslikno, updating_user = 15, date_updated = SYSDATE
                   WHERE prospect_number = rec.prospect_number;

                  COMMIT;
               ELSE
                  EXIT;
               END IF;
            EXCEPTION
               WHEN for_continue_error THEN
                  COMMIT;
                  durum := '0';
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         log_pack.log_is_emri_hata (NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    'J',
                                    'SYSTEM',
                                    SYSDATE,
                                    NULL,
                                    SUBSTR ('tckn_exception_recovery2: ' || SQLERRM, 1, 256),
                                    durum
                                   );

         IF durum = '0' THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
   END;

   /* --- Evren --- 20100603 ---- */

   PROCEDURE create_daily_event_job IS
      event_start_time_ DATE;
      event_end_time_   DATE;

      CURSOR getevents  IS
         SELECT x.ppv_event_id event_id, y.event_start_time, y.event_end_time
           FROM mb_lig_fikstur_event x,
                vv_oppv_film_tanim y
          WHERE     x.ppv_event_id IS NOT NULL
                AND x.ppv_event_id = y.event_id
                AND TRUNC (y.event_start_time) = TRUNC (SYSDATE)
                AND SYSDATE > TRUNC (x.hafta_begin_date)
                AND SYSDATE < TRUNC (x.hafta_end_date) + 1;
   BEGIN
      --sys.dbms_scheduler.drop_job('EVENTS_DAILY_JOB');
      FOR rec_ IN getevents LOOP
         IF event_start_time_ IS NULL THEN
            event_start_time_ := rec_.event_start_time;
         END IF;

         IF event_end_time_ IS NULL THEN
            event_end_time_ := rec_.event_end_time;
         END IF;

         IF event_start_time_ > rec_.event_start_time THEN
            event_start_time_ := rec_.event_start_time;
         END IF;

         IF event_end_time_ < rec_.event_end_time THEN
            event_end_time_ := rec_.event_end_time;
         END IF;
      END LOOP;

      IF event_start_time_ IS NOT NULL THEN
         event_start_time_ := event_start_time_ - 5 / 24;
         sys.DBMS_SCHEDULER.create_job (job_name        => 'CREATE_PPV_EVENTS_JOB',
                                        job_type        => 'PLSQL_BLOCK',
                                        job_action      => 'BEGIN DBS_DBA.ABONE_BATCH_PACK.CREATE_PPV_EVENTS(); COMMIT; END;',
                                        start_date      => event_start_time_,
                                        repeat_interval => 'FREQ=MINUTELY;INTERVAL=5',
                                        end_date        => event_end_time_,
                                        job_class       => 'DEFAULT_JOB_CLASS',
                                        enabled         => TRUE,
                                        auto_drop       => TRUE
                                       );
      END IF;
   END;

   PROCEDURE create_ppv_events IS
      CURSOR getevents  IS
         SELECT DISTINCT dbs_kodu, event_id, event_start_time, event_end_time
           FROM (SELECT t.dbs_kodu, x.ppv_event_id event_id, y.event_start_time, y.event_end_time, t.kod
                   FROM mb_lig_fikstur_event x,
                        vv_oppv_film_tanim y,
                        mb_futbol_takimlari t
                  WHERE     x.evsahibi_takim_kodu = t.kod
                        AND x.ppv_event_id = y.event_id
                        AND x.ppv_event_id IS NOT NULL
                        AND t.dbs_kodu IS NOT NULL
                        AND SYSDATE > y.event_start_time - 5 / 24
                        AND SYSDATE < y.event_end_time
                 UNION ALL
                 SELECT t.dbs_kodu, x.ppv_event_id event_id, y.event_start_time, y.event_end_time, t.kod
                   FROM mb_lig_fikstur_event x,
                        vv_oppv_film_tanim y,
                        mb_futbol_takimlari t
                  WHERE     x.misafir_takim_kodu = t.kod
                        AND x.ppv_event_id = y.event_id
                        AND x.ppv_event_id IS NOT NULL
                        AND t.dbs_kodu IS NOT NULL
                        AND SYSDATE > y.event_start_time - 5 / 24
                        AND SYSDATE < y.event_end_time)
          WHERE NOT EXISTS
                   (SELECT 1
                      FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit (TRIM ('LIG_FIKSTUR_EVENT_HARICI_TAKIM_KODLARI'))))
                     WHERE COLUMN_VALUE = kod);

      CURSOR getmembers (
         dbs_kodu_ IN VARCHAR2,
         event_id_    NUMBER) IS
         SELECT c.account_number, c.outlet_location
           FROM ( (SELECT a.account_number, a.outlet_location
                     FROM wiz_customer_hp_svc a
                    WHERE a.service_code = dbs_kodu_ AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                   UNION
                   (SELECT a.account_number, a.outlet_location
                      FROM dt_dbs_int_dba.vv_uye_ittp_servisler a
                     WHERE a.service_code = dbs_kodu_ AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')))
                 UNION ALL
                 SELECT b.account_number, b.outlet_location
                   FROM dbs_addr_on_air_activation b
                  WHERE     b.gerceklesen_acilma_tarihi IS NOT NULL
                        AND b.service_code = dbs_kodu_
                        AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                 UNION ALL
                 SELECT hav.account_number, hav.outlet_location
                   FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan hav
                  WHERE     hav.service_code = dbs_kodu_
                        AND hav.giris_tarihi IS NOT NULL
                        AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')) c
          WHERE     NOT EXISTS
                       (SELECT 1
                          FROM dbs_addr_oppv_film_istek x
                         WHERE x.account_number = c.account_number AND x.outlet_location = c.outlet_location AND x.durum != 'V' AND x.event_id = event_id_)
                AND NOT EXISTS
                       (SELECT 1
                          FROM mb_abone_ozellik x
                         WHERE x.account_number = c.account_number AND x.outlet_location = c.outlet_location AND x.abone_ozellik_kodu = 38);

      v_serial_no  VARCHAR2 (200);
      o_istek_id   NUMBER;
      o_durum_kodu VARCHAR2 (200);
      o_durum      VARCHAR2 (200);
      hata_id      NUMBER;
   BEGIN
      FOR rec1_ IN getevents LOOP
         FOR rec_ IN (SELECT COLUMN_VALUE split_value
                        FROM TABLE (split_table_fnc (rec1_.dbs_kodu)) x
                       WHERE NOT EXISTS
                                (SELECT 1
                                   FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit (TRIM ('LIG_FIKSTUR_EVENT_HARICI_DBS_KODLARI')))) y
                                  WHERE y.COLUMN_VALUE = x.COLUMN_VALUE)) LOOP
            FOR rec2_ IN getmembers (rec_.split_value, rec1_.event_id) LOOP
               SELECT MAX (t.serial_number)
                 INTO v_serial_no
                 FROM wiz_equip t
                WHERE t.account_number = rec2_.account_number AND t.outlet_location = rec2_.outlet_location AND t.converter_type = 'SC';

               film_istek_pack.oppv_film_istek_insert ('',
                                                       '',
                                                       '',
                                                       rec2_.account_number,
                                                       rec2_.outlet_location,
                                                       v_serial_no,
                                                       rec1_.event_id,
                                                       rec1_.event_start_time,
                                                       (rec1_.event_start_time - 2 / 24),
                                                       'O',
                                                       'PPV',
                                                       'PPV',
                                                       '',
                                                       '',
                                                       '',
                                                       '',
                                                       'SYSTEM',
                                                       3,
                                                       '',
                                                       'DBS',
                                                       o_istek_id,
                                                       o_durum_kodu,
                                                       o_durum
                                                      );

               IF o_durum <> '0' THEN
                  ROLLBACK;
                  /*SELECT MAX(nvl(ID,0))+1
                    INTO hata_id
                    FROM LG_DBS_ISLEM_HATA;

                  INSERT INTO LG_DBS_ISLEM_HATA (ID,TARIH,KULLANICI,GIREN_MAKINE,KOMUT,PARAMETRELER,HATA_MESAJI)
                                         VALUES (hata_id,SYSDATE,'SYSTEM','SYSTEM','FILM_ISTEK_PACK.oppv_film_istek_insert',
                                                 'ACCOUNT_NUMBER : ' || rec2_.account_number || ' OUTLET : ' || rec2_.outlet_location || 'EVENT_ID : ' || rec1_.event_id,o_durum);*/
                  insert_log (
                        'ACCOUNT_NUMBER : '
                     || rec2_.account_number
                     || ' OUTLET : '
                     || rec2_.outlet_location
                     || ' EVENT_ID : '
                     || rec1_.event_id
                     || ' DURUM : '
                     || o_durum);
                  COMMIT;
               ELSE
                  COMMIT;
               END IF;
            END LOOP;
         END LOOP;
      END LOOP;
   END;

   /* 22062010 Falamur
          kampanyalar için aranarak ulasilamayan üyeler için IRD çikilmasini saglamak amaciyla hergün job tarafindan çalistirilacak ve ilgili üyelere IRD mesaji çikacatir.
          Bu IRD mesaji son 1 ay içinde sadece 1 defa çikilabilmektedir.
      */

   PROCEDURE ulasilamayan_uyelere_ird_cik IS
      v_sc_no               VARCHAR2 (20);
      v_msg_str             VARCHAR2 (512);
      v_arama_tipleri       VARCHAR2 (256);
      v_gonderim_tarihi     DATE;
      v_son_gonderim_tarihi DATE;
      v_count               NUMBER (10);
      o_durum               VARCHAR2 (512);
   BEGIN
      o_durum           := '0';
      v_msg_str         := TRIM (dbs_sabit ('IRD_ULASILAMADI_MESAJI'));
      v_arama_tipleri   := TRIM (dbs_sabit ('IRD_CIKILACAK_ARAMA_TIPLERI'));
      v_gonderim_tarihi := TO_DATE (TO_CHAR (SYSDATE, 'DDMMYYYY') || '200000', 'DDMMYYYYHH24MISS');

      FOR abone_rec
         IN (SELECT DISTINCT d.account_number
               FROM cti_dba.ct_uye_arama_detay d,
                    cti_dba.ct_arama_listesi l
              WHERE     l.id = d.arama_listesi_id
                    AND d.arama_tarihi > TRUNC (SYSDATE - 7)
                    AND l.arama_tipi_kodu IN (SELECT COLUMN_VALUE FROM TABLE (split_table_fnc (v_arama_tipleri)))
                    AND l.son_durum IN (4)
                    AND l.son_durum = d.durum) LOOP
         -- Count yerine max(islem_tarihi) almamin nedeni performans nedeni iledir. count la alirsam index kullanimi degisiyor ve sorgu cok uzun sürüyor.
         -- indexe hint vermek baska bir yöntem olarak yapilabilirdi ama tablo istatislikleri degisebilir diye müdahale etmek istemedim.
         SELECT NVL (MAX (islem_tarihi), SYSDATE - 365)
           INTO v_son_gonderim_tarihi
           FROM lg_abone_islem_takip lg
          WHERE lg.account_number = abone_rec.account_number AND lg.islem_takip_id = 29 AND lg.deger = v_msg_str;

         IF TRUNC (v_son_gonderim_tarihi) < ADD_MONTHS (TRUNC (SYSDATE), -1) THEN
            BEGIN
               SELECT serial_number
                 INTO v_sc_no
                 FROM (SELECT   serial_number
                           FROM wiz_equip eq
                          WHERE eq.account_number = abone_rec.account_number AND eq.converter_type = 'SC'
                       ORDER BY outlet_location)
                WHERE ROWNUM = 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_sc_no := '0';
            END;

            IF v_sc_no <> '0' THEN
               comm_dba.rutin_islem_pack.send_routine_ird (NULL, -- Sas_batch_id
                                                           abone_rec.account_number,
                                                           NULL, --outlet_location
                                                           v_sc_no,
                                                           v_gonderim_tarihi,
                                                           v_msg_str,
                                                           'SYSTEM',
                                                           NULL, -- p_background_color
                                                           NULL, -- p_foreground_color
                                                           o_durum
                                                          );
               COMMIT;
            END IF;
         END IF;
      END LOOP;
   END;

   PROCEDURE set_other_mode (paccbaslangic IN NUMBER DEFAULT 1000, paccbitis IN NUMBER DEFAULT 6000000, pbaslangictarihi IN DATE DEFAULT NULL) IS
      v_bas_turksat_acma_tarihi DATE;

      /*
          16 Nisandan sonra dagitilan 9002 kutular kontrat girisi sirasinda TURKSAT'a kapanmaktadir.
          Ancak, kutunun o anda sinyali alamamasi nedeniyle tekrar çikmak gerekmektedir.
          Sorgu, söyle kutulari ele alir :
          Üyede su anda 9002 varsa, bu kutunun veya denk modelinin üyeye verilis tarihi 16 Nisandan sonra ise,
          Üye, kutuya sahip degilse, uye numarasi degisecek sekilde herhangibir adres degisikligi yapmamissa
          Ayrica yetkili kullanicilarin bu sartlara ragmen hala TURKSAT'a açik tutmak istedikleri üyeler varsa bunlara da 166 özelligi eklenir.
      */
      v_sc_serial_number        VARCHAR2 (15);
      v_brand                   VARCHAR2 (3);
      v_count                   NUMBER (2);
      odurum                    VARCHAR2 (100);
      v_uye_uydusu              NUMBER (2);
      v_uye_stb_tipi            VARCHAR2 (2);
      v_sinyal_kapanacak        BOOLEAN;
      l_islem_ok                BOOLEAN;
      v_service_account         NUMBER;
      v_uye_durum               VARCHAR2 (1);
   BEGIN
      -- Eger maç var ise sinyal çikilmayacak. (5 Dakika ile 2 saat sonrasi arasinda maç var ise)
      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.mb_lig_fikstur_event f,
             prod_dba.wiz_ppv_events e
       WHERE     f.ppv_event_id = e.event_id
             AND SYSDATE BETWEEN f.hafta_begin_date AND f.hafta_end_date
             AND e.event_start_time BETWEEN SYSDATE + 5 / (24 * 60) AND SYSDATE + (2 / 24);

      IF v_count > 0 THEN
         RETURN;
      END IF;

      v_bas_turksat_acma_tarihi := TO_DATE (dbs_sabit ('TURKSAT_ACMA_TARIHI'), 'DD/MM/YYYY');

      FOR turksatkapali
         IN (SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number, eq.eq_ekipman_tip_matrix_id
               FROM wiz_equip wiz,
                    eq_ekipman_tip_matrix eq,
                    pr_urun_ozellik_tanim t,
                    wiz_customer_hp_life life
              WHERE     wiz.account_number <> 0
                    AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                    AND wiz.converter_type = 'ST'
                    AND wiz.manufacturer = eq.manufacturer
                    AND wiz.converter_model = eq.converter_model
                    AND wiz.converter_type = eq.converter_type
                    AND t.urun_tipi = 6
                    AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                    AND t.ozellik_kodu = 69
                    AND wiz.account_number = life.account_number
                    AND life.franchise_code IN ('F01', 'F02')
                    AND wiz.install_date > NVL (pbaslangictarihi, v_bas_turksat_acma_tarihi)
             UNION ALL
             SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number, eq.eq_ekipman_tip_matrix_id
               FROM wiz_equip wiz,
                    eq_ekipman_tip_matrix eq,
                    pr_urun_ozellik_tanim t,
                    wiz_customer_hp_life life,
                    dbs_dba.lg_abone_ozellik lg1
              WHERE     wiz.account_number <> 0
                    AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                    AND wiz.converter_type = 'ST'
                    AND wiz.manufacturer = eq.manufacturer
                    AND wiz.converter_model = eq.converter_model
                    AND wiz.converter_type = eq.converter_type
                    AND t.urun_tipi = 6
                    AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                    AND t.ozellik_kodu = 69
                    AND wiz.account_number = life.account_number
                    AND life.franchise_code IN ('F01', 'F02')
                    AND lg1.account_number = wiz.account_number
                    AND lg1.outlet_location = wiz.outlet_location
                    AND lg1.abone_ozellik_kodu = 166
                    AND lg1.islem = 'D'
                    AND lg1.islem_tarihi >= pbaslangictarihi) LOOP
         SELECT COUNT (1)
           INTO v_count
           FROM mb_abone_ozellik
          WHERE abone_ozellik_kodu = 166 AND account_number = turksatkapali.account_number AND outlet_location = turksatkapali.outlet_location;

         IF v_count = 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM eq_ekipman_sahibi_kim
             WHERE     account_number = turksatkapali.account_number
                   AND outlet_location = turksatkapali.outlet_location
                   AND sahiplik_tipi = 0
                   AND kayit_iptal = 'H';

            IF v_count = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_adres_degisikligi
                WHERE     durum = 'P'
                      AND uye_no <> yeni_uye_no
                      AND yeni_uye_no = turksatkapali.account_number
                      AND yeni_outlet_location = turksatkapali.outlet_location;

               IF v_count = 0 THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM (SELECT 1
                            FROM lg_ekipman lg
                           WHERE     lg.account_number = turksatkapali.account_number
                                 AND lg.outlet_location = turksatkapali.outlet_location
                                 AND lg.depodan IS NOT NULL
                                 AND lg.account_number IS NOT NULL
                                 AND EXISTS
                                        (SELECT *
                                           FROM wiz_equip w,
                                                eq_ekipman_tip_matrix e
                                          WHERE     lg.serial_number = w.serial_number
                                                AND w.converter_type = 'ST'
                                                AND w.manufacturer = e.manufacturer
                                                AND w.converter_model = e.converter_model
                                                AND w.converter_type = e.converter_type
                                                AND addressability_pack.ekipmanmodelkodu (e.eq_ekipman_tip_matrix_id) =
                                                       addressability_pack.ekipmanmodelkodu (turksatkapali.eq_ekipman_tip_matrix_id))
                          HAVING MIN (lg.islem_tarihi) < v_bas_turksat_acma_tarihi);

                  IF v_count = 0 THEN
                     odurum       := '0';
                     v_uye_uydusu := abone_sorgu_pack.uye_uydusu (turksatkapali.account_number, turksatkapali.outlet_location);

                     IF v_uye_uydusu = 1 THEN
                        BEGIN
                           SELECT serial_number
                             INTO v_sc_serial_number
                             FROM wiz_equip
                            WHERE account_number = turksatkapali.account_number AND outlet_location = turksatkapali.outlet_location AND converter_type = 'SC';

                           addressability_pack.setothermode (turksatkapali.account_number,
                                                             v_sc_serial_number,
                                                             turksatkapali.serial_number,
                                                             '0',
                                                             'SYSADDRLO',
                                                             odurum
                                                            );

                           IF odurum <> '0' THEN
                              NULL;
                              --insert_log ('SET_OTHER_MODE ÇIKILAMADI_1 :' || vturksatkapali.account_number || '-' || SUBSTR (odurum, 1, 100));
                              NULL;
                           END IF;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              NULL;
                           WHEN OTHERS THEN
                              insert_log (
                                    'SET_OTHER_MODE KAPAMA CIKILAMADI :'
                                 || turksatkapali.account_number
                                 || '-'
                                 || SUBSTR (odurum, 1, 100)
                                 || '-'
                                 || SUBSTR (SQLERRM, 1, 200));
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      COMMIT;

      FOR rturksatacma
         IN (SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number, eq.eq_ekipman_tip_matrix_id
               FROM wiz_equip wiz,
                    eq_ekipman_tip_matrix eq,
                    pr_urun_ozellik_tanim t,
                    wiz_customer_hp_life life
              WHERE     wiz.account_number <> 0
                    AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                    AND wiz.converter_type = 'ST'
                    AND wiz.manufacturer = eq.manufacturer
                    AND wiz.converter_model = eq.converter_model
                    AND wiz.converter_type = eq.converter_type
                    AND t.urun_tipi = 6
                    AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                    AND t.ozellik_kodu = 69
                    AND wiz.account_number = life.account_number
                    AND life.franchise_code IN ('F01', 'F02')
                    AND wiz.install_date > NVL (pbaslangictarihi, v_bas_turksat_acma_tarihi)
             UNION ALL
             SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number, eq.eq_ekipman_tip_matrix_id
               FROM wiz_equip wiz,
                    eq_ekipman_tip_matrix eq,
                    pr_urun_ozellik_tanim t,
                    wiz_customer_hp_life life,
                    dbs_dba.mb_abone_ozellik mb
              WHERE     wiz.account_number <> 0
                    AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                    AND wiz.converter_type = 'ST'
                    AND wiz.manufacturer = eq.manufacturer
                    AND wiz.converter_model = eq.converter_model
                    AND wiz.converter_type = eq.converter_type
                    AND t.urun_tipi = 6
                    AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                    AND t.ozellik_kodu = 69
                    AND wiz.account_number = life.account_number
                    AND life.franchise_code IN ('F01', 'F02')
                    AND mb.account_number = wiz.account_number
                    AND mb.outlet_location = wiz.outlet_location
                    AND mb.abone_ozellik_kodu = 166
                    AND mb.giris_tarihi >= pbaslangictarihi) LOOP
         v_service_account := billing_dbs_int.customer_ittp_pkg.get_service_account_id (rturksatacma.account_number, rturksatacma.outlet_location, NULL);

         SELECT COUNT (1)
           INTO v_count
           FROM dt_product_dba.product p
          WHERE     p.logical_delete_key IS NULL
                AND p.product_spec_id IS NOT NULL
                AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                AND p.service_account_id = v_service_account;

         IF v_count = 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM dt_bi_dba.business_inter don,
                   dt_bi_dba.business_inter_spec bis
             WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                   AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                   AND NOT EXISTS
                              (SELECT 1
                                 FROM dt_bi_dba.business_inter coz,
                                      dt_bi_dba.business_inter_spec biss
                                WHERE     coz.parent_id = don.business_inter_id
                                      AND biss.business_inter_spec_id = coz.business_inter_spec_id
                                      AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                      AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                      AND coz.logical_delete_key IS NULL
                                      AND biss.logical_delete_key IS NULL)
                   AND don.business_inter_status_t_cd = 'TAMAMLANDI'
                   AND don.service_account_id = v_service_account
                   AND don.logical_delete_key IS NULL
                   AND bis.logical_delete_key IS NULL;

            IF v_count = 0 THEN
               odurum       := '0';
               v_uye_uydusu := abone_sorgu_pack.uye_uydusu (rturksatacma.account_number, rturksatacma.outlet_location);

               SELECT COUNT (1)
                 INTO v_count
                 FROM dbs_dba.mb_abone_ozellik mb
                WHERE mb.account_number = rturksatacma.account_number AND mb.outlet_location = rturksatacma.outlet_location AND mb.abone_ozellik_kodu = 166;

               IF v_uye_uydusu = 2 OR v_count > 0 THEN
                  BEGIN
                     SELECT serial_number
                       INTO v_sc_serial_number
                       FROM wiz_equip
                      WHERE account_number = rturksatacma.account_number AND outlet_location = rturksatacma.outlet_location AND converter_type = 'SC';

                     addressability_pack.setothermode (rturksatacma.account_number, v_sc_serial_number, rturksatacma.serial_number, '1', 'SYSADDRLO', odurum);

                     IF odurum <> '0' THEN
                        --insert_log ('SET_OTHER_MODE ÇIKILAMADI_1 :' || vturksatacma.account_number || '-' || SUBSTR (odurum, 1, 100));
                        odurum := '0';
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                     WHEN OTHERS THEN
                        insert_log (
                              'SET_OTHER_MODE ACMA CIKILAMADI :'
                           || rturksatacma.account_number
                           || '-'
                           || SUBSTR (odurum, 1, 100)
                           || '-'
                           || SUBSTR (SQLERRM, 1, 200));
                  END;
               END IF;
            END IF;
         END IF;
      END LOOP;

      COMMIT;

      IF (paccbaslangic != paccbitis) THEN
         FOR rsusdonkapa
            IN (SELECT p.service_account_id, 'K' AS durum
                  FROM dt_product_dba.product p,
                       dt_bi_dba.business_inter_spec bis,
                       dt_bi_dba.business_inter bi
                 WHERE     p.logical_delete_key IS NULL
                       AND p.product_spec_id IS NOT NULL
                       AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                       AND p.service_account_id = bi.service_account_id
                       AND bi.business_inter_spec_id = bis.business_inter_spec_id
                       AND bi.business_inter_status_t_cd = 'TAMAMLANDI'
                       AND bis.business_inter_spec_cd = 'ASKI_DUSUR'
                       AND bi.interaction_complete_date >= pbaslangictarihi
                       AND bi.logical_delete_key IS NULL
                       AND bis.logical_delete_key IS NULL
                UNION
                SELECT DISTINCT don.service_account_id, 'D' AS durum
                  FROM dt_bi_dba.business_inter don,
                       dt_bi_dba.business_inter_spec bis
                 WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                       AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                       AND NOT EXISTS
                                  (SELECT *
                                     FROM dt_bi_dba.business_inter coz,
                                          dt_bi_dba.business_inter_spec biss
                                    WHERE     coz.parent_id = don.business_inter_id
                                          AND biss.business_inter_spec_id = coz.business_inter_spec_id
                                          AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                          AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                          AND coz.logical_delete_key IS NULL
                                          AND biss.logical_delete_key IS NULL)
                       AND don.business_inter_status_t_cd IN ('TAMAMLANDI')
                       AND don.logical_delete_key IS NULL
                       AND bis.logical_delete_key IS NULL
                       AND don.interaction_complete_date >= pbaslangictarihi) LOOP
            DECLARE
               l_account_number  NUMBER;
               l_outlet_location VARCHAR2 (512);
            BEGIN
               SELECT dbs_account_number, dbs_outlet_location
                 INTO l_account_number, l_outlet_location
                 FROM dt_party_dba.party_role_account
                WHERE party_role_account_id = rsusdonkapa.service_account_id;

               FOR equip
                  IN (SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
                        FROM wiz_equip wiz,
                             eq_ekipman_tip_matrix eq,
                             pr_urun_ozellik_tanim t,
                             wiz_customer_hp_life life
                       WHERE     wiz.account_number <> 0
                             AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                             AND wiz.converter_type = 'ST'
                             AND wiz.manufacturer = eq.manufacturer
                             AND wiz.converter_model = eq.converter_model
                             AND wiz.converter_type = eq.converter_type
                             AND life.account_number = wiz.account_number
                             AND wiz.account_number = l_account_number
                             AND wiz.outlet_location = l_outlet_location
                             AND t.urun_tipi = 6
                             AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                             AND t.ozellik_kodu = 69
                             AND life.franchise_code IN ('F01', 'F02')) LOOP
                  BEGIN
                     odurum             := '0';

                     SELECT serial_number
                       INTO v_sc_serial_number
                       FROM wiz_equip
                      WHERE account_number = equip.account_number AND outlet_location = equip.outlet_location AND converter_type = 'SC';

                     SELECT hp_cluster
                       INTO v_uye_stb_tipi
                       FROM wiz_customer_hp_life
                      WHERE account_number = equip.account_number;

                     v_sinyal_kapanacak := TRUE;

                     IF v_uye_stb_tipi IN ('LG', 'VS') AND rsusdonkapa.durum = 'D' THEN
                        v_sinyal_kapanacak := FALSE; -- Türksatçilar dondurulursa yayin kapatilmayacak.
                     ELSE
                        IF v_uye_stb_tipi IN ('LG', 'VS') AND rsusdonkapa.durum = 'K' THEN
                           SELECT COUNT (1)
                             INTO v_count
                             FROM eq_ekipman_sahibi_kim k,
                                  wiz_equip e
                            WHERE     e.account_number = equip.account_number
                                  AND e.outlet_location = equip.outlet_location
                                  AND e.converter_type = 'ST'
                                  AND e.serial_number = k.serial_number
                                  AND k.kayit_iptal = 'H'
                                  AND k.sahiplik_tipi = 0
                                  AND k.ekipman_sahibi_tipi = 1;

                           IF v_count > 0 THEN
                              v_sinyal_kapanacak := FALSE;
                           ELSE
                              SELECT COUNT (1)
                                INTO v_count
                                FROM eq_ekipman_sahibi_kim k,
                                     wiz_equip e
                               WHERE     e.account_number = equip.account_number
                                     AND e.outlet_location = equip.outlet_location
                                     AND e.converter_type = 'ST'
                                     AND e.serial_number = k.serial_number
                                     AND k.kayit_iptal = 'H';

                              IF v_count = 0 THEN
                                 v_sinyal_kapanacak := FALSE;
                              ELSE
                                 v_sinyal_kapanacak := TRUE;
                              END IF;
                           END IF;
                        END IF;

                        IF v_sinyal_kapanacak = TRUE THEN
                           IF ekipman_ozellik_pack.turksat_acik (equip.serial_number) = 'E' THEN
                              SELECT COUNT (1)
                                INTO v_count
                                FROM mb_abone_ozellik mb
                               WHERE mb.account_number = equip.account_number AND mb.outlet_location = equip.outlet_location AND mb.abone_ozellik_kodu = 206;

                              IF v_count = 0 THEN
                                 abone_detay_pack.mb_abone_ozellik_insert (equip.account_number, equip.outlet_location, 206, 'SYSTEM', odurum);

                                 IF odurum <> '0' THEN
                                    insert_log ('SET_OTHER_MODE HATA ABONE_OZELLIK_INSERT:' || '-' || SUBSTR (odurum, 1, 100));
                                 END IF;
                              END IF;
                           END IF;

                           addressability_pack.setothermode (equip.account_number, v_sc_serial_number, equip.serial_number, '0', 'SYSADDRLO', odurum);

                           IF odurum <> '0' THEN
                              odurum := '0';
                           END IF;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        insert_log ('SET_OTHER_MODE HATA SUS-DON KAPA:' || '-' || SUBSTR (odurum, 1, 100) || '-' || SUBSTR (SQLERRM, 1, 200));
                  END;
               END LOOP;
            END;
         END LOOP;
      ELSIF paccbaslangic = paccbitis THEN
         FOR rsusdonkapa
            IN (SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
                  FROM wiz_equip wiz,
                       eq_ekipman_tip_matrix eq,
                       pr_urun_ozellik_tanim t,
                       wiz_customer_hp_life life
                 WHERE     wiz.account_number <> 0
                       AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                       AND wiz.converter_type = 'ST'
                       AND wiz.manufacturer = eq.manufacturer
                       AND wiz.converter_model = eq.converter_model
                       AND wiz.converter_type = eq.converter_type
                       AND life.account_number = wiz.account_number
                       AND t.urun_tipi = 6
                       AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                       AND t.ozellik_kodu = 69
                       AND life.franchise_code IN ('F01', 'F02')) LOOP
            v_service_account := billing_dbs_int.customer_ittp_pkg.get_service_account_id (rsusdonkapa.account_number, rsusdonkapa.outlet_location, NULL);
            v_uye_durum       := '0';

            SELECT COUNT (1)
              INTO v_count
              FROM dt_product_dba.product p,
                   dt_bi_dba.business_inter_spec bis,
                   dt_bi_dba.business_inter bi
             WHERE     p.logical_delete_key IS NULL
                   AND p.product_spec_id IS NOT NULL
                   AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                   AND p.service_account_id = v_service_account
                   AND p.service_account_id = bi.service_account_id
                   AND bi.business_inter_spec_id = bis.business_inter_spec_id
                   AND bi.business_inter_status_t_cd = 'TAMAMLANDI'
                   AND bis.business_inter_spec_cd = 'ASKI_DUSUR'
                   AND bi.interaction_complete_date >= pbaslangictarihi
                   AND bi.logical_delete_key IS NULL
                   AND bis.logical_delete_key IS NULL;

            IF v_count > 0 THEN
               v_uye_durum := 'K';
            ELSE
               SELECT COUNT (1)
                 INTO v_count
                 FROM dt_bi_dba.business_inter don,
                      dt_bi_dba.business_inter_spec bis
                WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                      AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                      AND NOT EXISTS
                                 (SELECT *
                                    FROM dt_bi_dba.business_inter coz,
                                         dt_bi_dba.business_inter_spec biss
                                   WHERE     coz.parent_id = don.business_inter_id
                                         AND biss.business_inter_spec_id = coz.business_inter_spec_id
                                         AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                         AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                         AND coz.logical_delete_key IS NULL
                                         AND biss.logical_delete_key IS NULL)
                      AND don.business_inter_status_t_cd IN ('TAMAMLANDI')
                      AND don.service_account_id = v_service_account
                      AND don.logical_delete_key IS NULL
                      AND bis.logical_delete_key IS NULL
                      AND don.interaction_complete_date >= pbaslangictarihi;

               IF v_count > 0 THEN
                  v_uye_durum := 'D';
               ELSE
                  v_uye_durum := '0';
               END IF;
            END IF;

            IF v_uye_durum IN ('K', 'D') THEN
               BEGIN
                  odurum             := '0';

                  SELECT serial_number
                    INTO v_sc_serial_number
                    FROM wiz_equip
                   WHERE account_number = rsusdonkapa.account_number AND outlet_location = rsusdonkapa.outlet_location AND converter_type = 'SC';

                  SELECT hp_cluster
                    INTO v_uye_stb_tipi
                    FROM wiz_customer_hp_life
                   WHERE account_number = rsusdonkapa.account_number;

                  v_sinyal_kapanacak := TRUE;

                  IF v_uye_stb_tipi IN ('LG', 'VS') AND v_uye_durum = 'D' THEN
                     v_sinyal_kapanacak := FALSE; -- Türksatçilar dondurulursa yayin kapatilmayacak.
                  ELSE
                     IF v_uye_stb_tipi IN ('LG', 'VS') AND v_uye_durum = 'K' THEN
                        SELECT COUNT (1)
                          INTO v_count
                          FROM eq_ekipman_sahibi_kim k,
                               wiz_equip e
                         WHERE     e.account_number = rsusdonkapa.account_number
                               AND e.outlet_location = rsusdonkapa.outlet_location
                               AND e.converter_type = 'ST'
                               AND e.serial_number = k.serial_number
                               AND k.kayit_iptal = 'H'
                               AND k.sahiplik_tipi = 0
                               AND k.ekipman_sahibi_tipi = 1;

                        IF v_count > 0 THEN
                           v_sinyal_kapanacak := FALSE;
                        ELSE
                           SELECT COUNT (1)
                             INTO v_count
                             FROM eq_ekipman_sahibi_kim k,
                                  wiz_equip e
                            WHERE     e.account_number = rsusdonkapa.account_number
                                  AND e.outlet_location = rsusdonkapa.outlet_location
                                  AND e.converter_type = 'ST'
                                  AND e.serial_number = k.serial_number
                                  AND k.kayit_iptal = 'H';

                           IF v_count = 0 THEN
                              v_sinyal_kapanacak := FALSE;
                           ELSE
                              v_sinyal_kapanacak := TRUE;
                           END IF;
                        END IF;
                     END IF;

                     IF v_sinyal_kapanacak = TRUE THEN
                        IF ekipman_ozellik_pack.turksat_acik (rsusdonkapa.serial_number) = 'E' THEN
                           SELECT COUNT (1)
                             INTO v_count
                             FROM mb_abone_ozellik mb
                            WHERE     mb.account_number = rsusdonkapa.account_number
                                  AND mb.outlet_location = rsusdonkapa.outlet_location
                                  AND mb.abone_ozellik_kodu = 206;

                           IF v_count = 0 THEN
                              abone_detay_pack.mb_abone_ozellik_insert (rsusdonkapa.account_number, rsusdonkapa.outlet_location, 206, 'SYSTEM', odurum);

                              IF odurum <> '0' THEN
                                 insert_log ('SET_OTHER_MODE HATA ABONE_OZELLIK_INSERT:' || '-' || SUBSTR (odurum, 1, 100) || '-' || SUBSTR (SQLERRM, 1, 200));
                              END IF;
                           END IF;
                        END IF;

                        addressability_pack.setothermode (rsusdonkapa.account_number, v_sc_serial_number, rsusdonkapa.serial_number, '0', 'SYSADDRLO', odurum);

                        IF odurum <> '0' THEN
                           odurum := '0';
                        END IF;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     insert_log ('SET_OTHER_MODE HATA SUS-DON KAPA:' || '-' || SUBSTR (odurum, 1, 100) || '-' || SUBSTR (SQLERRM, 1, 200));
               END;
            END IF;
         END LOOP;
      END IF;

      COMMIT;

      IF (paccbaslangic != paccbitis) THEN
         FOR rsusdonac
            IN (SELECT don.service_account_id
                  INTO v_count
                  FROM dt_bi_dba.business_inter don,
                       dt_bi_dba.business_inter_spec bis,
                       dt_bi_dba.customer_order co
                 WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                       AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                       AND EXISTS
                              (SELECT *
                                 FROM dt_bi_dba.business_inter coz,
                                      dt_bi_dba.business_inter_spec biss
                                WHERE     coz.parent_id = don.business_inter_id
                                      AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                      AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                      AND coz.logical_delete_key IS NULL
                                      AND biss.logical_delete_key IS NULL)
                       AND don.business_inter_id = co.customer_order_id
                       AND don.business_inter_status_t_cd = 'TAMAMLANDI'
                       AND don.logical_delete_key IS NULL
                       AND bis.logical_delete_key IS NULL
                       AND co.resume_date >= pbaslangictarihi
                       AND NOT EXISTS -- uye don değilse
                                  (SELECT 1
                                     FROM dt_bi_dba.business_inter don_bi,
                                          dt_bi_dba.business_inter_spec don_spec
                                    WHERE     don_bi.business_inter_spec_id = don_spec.business_inter_spec_id
                                          AND don_spec.business_inter_spec_cd = 'PRODUCT_DON'
                                          AND NOT EXISTS
                                                     (SELECT 1
                                                        FROM dt_bi_dba.business_inter coz_bi,
                                                             dt_bi_dba.business_inter_spec coz_spec
                                                       WHERE     coz_bi.parent_id = don_bi.business_inter_id
                                                             AND coz_bi.business_inter_status_t_cd = 'TAMAMLANDI'
                                                             AND coz_bi.business_inter_spec_id = coz_spec.business_inter_spec_id
                                                             AND coz_spec.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                             AND coz_bi.logical_delete_key IS NULL
                                                             AND coz_spec.logical_delete_key IS NULL)
                                          AND don_bi.business_inter_status_t_cd IN ('TAMAMLANDI')
                                          AND don_bi.service_account_id = v_service_account
                                          AND don_bi.logical_delete_key IS NULL
                                          AND don_spec.logical_delete_key IS NULL)
                UNION
                SELECT DISTINCT bi.service_account_id
                  FROM dt_bi_dba.business_inter_spec bis,
                       dt_bi_dba.business_inter bi
                 WHERE     bi.business_inter_spec_id = bis.business_inter_spec_id
                       AND bi.business_inter_status_t_cd = 'TAMAMLANDI'
                       AND bis.business_inter_spec_cd = 'ASKI_DUSUR'
                       AND NOT EXISTS
                                  (SELECT 1
                                     FROM dt_product_dba.product p
                                    WHERE     p.logical_delete_key IS NULL
                                          AND p.product_spec_id IS NOT NULL
                                          AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                                          AND p.service_account_id = bi.service_account_id)
                       AND bi.interaction_complete_date >= pbaslangictarihi
                       AND bi.logical_delete_key IS NULL
                       AND bis.logical_delete_key IS NULL) LOOP
            DECLARE
               l_account_number  NUMBER;
               l_outlet_location VARCHAR2 (512);
            BEGIN
               SELECT dbs_account_number, dbs_outlet_location
                 INTO l_account_number, l_outlet_location
                 FROM dt_party_dba.party_role_account
                WHERE party_role_account_id = rsusdonac.service_account_id;

               FOR equip
                  IN (SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
                        FROM wiz_equip wiz,
                             eq_ekipman_tip_matrix eq,
                             pr_urun_ozellik_tanim t,
                             wiz_customer_hp_life life
                       WHERE     wiz.account_number <> 0
                             AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                             AND wiz.account_number = l_account_number
                             AND wiz.outlet_location = l_outlet_location
                             AND wiz.converter_type = 'ST'
                             AND wiz.manufacturer = eq.manufacturer
                             AND wiz.converter_model = eq.converter_model
                             AND wiz.converter_type = eq.converter_type
                             AND life.account_number = wiz.account_number
                             AND t.urun_tipi = 6
                             AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                             AND t.ozellik_kodu = 69
                             AND life.franchise_code IN ('F01', 'F02')) LOOP
                  BEGIN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM mb_abone_ozellik mb
                      WHERE mb.account_number = equip.account_number AND mb.outlet_location = equip.outlet_location AND mb.abone_ozellik_kodu = 206;

                     IF v_count = 1 OR ekipman_ozellik_pack.turksat_acik (equip.serial_number) = 'E' THEN
                        SELECT serial_number
                          INTO v_sc_serial_number
                          FROM wiz_equip
                         WHERE account_number = equip.account_number AND outlet_location = equip.outlet_location AND converter_type = 'SC';

                        IF v_count = 1 THEN
                           abone_detay_pack.mb_abone_ozellik_delete (equip.account_number, equip.outlet_location, 206, 'SYSTEM', odurum);
                        END IF;

                        addressability_pack.setothermode (equip.account_number, v_sc_serial_number, equip.serial_number, '1', 'SYSADDRLO', odurum);

                        IF odurum <> '0' THEN
                           odurum := '0';
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        insert_log ('SET_OTHER_MODE HATA SUS-DON AC :' || '-' || SUBSTR (odurum, 1, 100) || '-' || SUBSTR (SQLERRM, 1, 200));
                  END;
               END LOOP;
            END;
         END LOOP;
      ELSIF paccbaslangic = paccbitis THEN
         FOR rsusdonac
            IN (SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
                  FROM wiz_equip wiz,
                       eq_ekipman_tip_matrix eq,
                       pr_urun_ozellik_tanim t,
                       wiz_customer_hp_life life
                 WHERE     wiz.account_number <> 0
                       AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                       AND wiz.converter_type = 'ST'
                       AND wiz.manufacturer = eq.manufacturer
                       AND wiz.converter_model = eq.converter_model
                       AND wiz.converter_type = eq.converter_type
                       AND life.account_number = wiz.account_number
                       AND t.urun_tipi = 6
                       AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                       AND t.ozellik_kodu = 69
                       AND life.franchise_code IN ('F01', 'F02')) LOOP
            v_service_account := billing_dbs_int.customer_ittp_pkg.get_service_account_id (rsusdonac.account_number, rsusdonac.outlet_location, NULL);

            SELECT COUNT (1)
              INTO v_count
              FROM dt_bi_dba.business_inter don,
                   dt_bi_dba.business_inter_spec bis,
                   dt_bi_dba.customer_order co
             WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                   AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                   AND EXISTS
                          (SELECT *
                             FROM dt_bi_dba.business_inter coz,
                                  dt_bi_dba.business_inter_spec biss
                            WHERE     coz.parent_id = don.business_inter_id
                                  AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                  AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                  AND coz.logical_delete_key IS NULL
                                  AND biss.logical_delete_key IS NULL)
                   AND don.service_account_id = v_service_account
                   AND don.business_inter_id = co.customer_order_id
                   AND don.business_inter_status_t_cd = 'TAMAMLANDI'
                   AND don.logical_delete_key IS NULL
                   AND bis.logical_delete_key IS NULL
                   AND co.resume_date >= pbaslangictarihi
                   AND NOT EXISTS -- uye don değilse
                              (SELECT 1
                                 FROM dt_bi_dba.business_inter don_bi,
                                      dt_bi_dba.business_inter_spec don_spec
                                WHERE     don_bi.business_inter_spec_id = don_spec.business_inter_spec_id
                                      AND don_spec.business_inter_spec_cd = 'PRODUCT_DON'
                                      AND NOT EXISTS
                                                 (SELECT 1
                                                    FROM dt_bi_dba.business_inter coz_bi,
                                                         dt_bi_dba.business_inter_spec coz_spec
                                                   WHERE     coz_bi.parent_id = don_bi.business_inter_id
                                                         AND coz_bi.business_inter_status_t_cd = 'TAMAMLANDI'
                                                         AND coz_bi.business_inter_spec_id = coz_spec.business_inter_spec_id
                                                         AND coz_spec.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                         AND coz_bi.logical_delete_key IS NULL
                                                         AND coz_spec.logical_delete_key IS NULL)
                                      AND don_bi.business_inter_status_t_cd IN ('TAMAMLANDI')
                                      AND don_bi.service_account_id = v_service_account
                                      AND don_bi.logical_delete_key IS NULL
                                      AND don_spec.logical_delete_key IS NULL);

            IF v_count = 0 THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM dt_bi_dba.business_inter_spec bis,
                      dt_bi_dba.business_inter bi
                WHERE     bi.business_inter_spec_id = bis.business_inter_spec_id
                      AND bi.business_inter_status_t_cd = 'TAMAMLANDI'
                      AND bis.business_inter_spec_cd = 'ASKI_DUSUR'
                      AND bi.service_account_id = v_service_account
                      AND NOT EXISTS
                                 (SELECT 1
                                    FROM dt_product_dba.product p
                                   WHERE     p.logical_delete_key IS NULL
                                         AND p.product_spec_id IS NOT NULL
                                         AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                                         AND p.service_account_id = bi.service_account_id)
                      AND bi.interaction_complete_date >= pbaslangictarihi
                      AND bi.logical_delete_key IS NULL
                      AND bis.logical_delete_key IS NULL;
            END IF;

            IF v_count > 0 THEN
               BEGIN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM mb_abone_ozellik mb
                   WHERE mb.account_number = rsusdonac.account_number AND mb.outlet_location = rsusdonac.outlet_location AND mb.abone_ozellik_kodu = 206;

                  IF v_count = 1 OR ekipman_ozellik_pack.turksat_acik (rsusdonac.serial_number) = 'E' THEN
                     SELECT serial_number
                       INTO v_sc_serial_number
                       FROM wiz_equip
                      WHERE account_number = rsusdonac.account_number AND outlet_location = rsusdonac.outlet_location AND converter_type = 'SC';

                     IF v_count = 1 THEN
                        abone_detay_pack.mb_abone_ozellik_delete (rsusdonac.account_number, rsusdonac.outlet_location, 206, 'SYSTEM', odurum);
                     END IF;

                     addressability_pack.setothermode (rsusdonac.account_number, v_sc_serial_number, rsusdonac.serial_number, '1', 'SYSADDRLO', odurum);

                     IF odurum <> '0' THEN
                        odurum := '0';
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     insert_log ('SET_OTHER_MODE HATA SUS-DON AC :' || '-' || SUBSTR (odurum, 1, 100) || '-' || SUBSTR (SQLERRM, 1, 200));
               END;
            END IF;
         END LOOP;

         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         insert_log ('SET_OTHER_MODE HATA :' || '-' || SUBSTR (odurum, 1, 100) || '-' || SUBSTR (SQLERRM, 1, 200));
   END;

   PROCEDURE set_other_mode2 (paccbaslangic IN NUMBER DEFAULT 1000, paccbitis IN NUMBER DEFAULT 6000000, pbaslangictarihi IN DATE DEFAULT NULL) IS
      v_bas_turksat_acma_tarihi DATE;

      /*
          16 Nisandan sonra dagitilan 9002 kutular kontrat girisi sirasinda TURKSAT'a kapanmaktadir.
          Ancak, kutunun o anda sinyali alamamasi nedeniyle tekrar çikmak gerekmektedir.
          Sorgu, söyle kutulari ele alir :
          Üyede su anda 9002 varsa, bu kutunun veya denk modelinin üyeye verilis tarihi 16 Nisandan sonra ise,
          Üye, kutuya sahip degilse, uye numarasi degisecek sekilde herhangibir adres degisikligi yapmamissa
          Ayrica yetkili kullanicilarin bu sartlara ragmen hala TURKSAT'a açik tutmak istedikleri üyeler varsa bunlara da 166 özelligi eklenir.
      */
      CURSOR cturksatkapali  IS
         SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND wiz.account_number = life.account_number
                AND life.franchise_code IN ('F01', 'F02')
                --AND converter_model = 'DT-9002   '
                AND wiz.install_date > NVL (pbaslangictarihi, v_bas_turksat_acma_tarihi)
                AND NOT EXISTS
                       (SELECT account_number
                          FROM mb_abone_ozellik
                         WHERE abone_ozellik_kodu = 166 AND account_number = wiz.account_number AND outlet_location = wiz.outlet_location)
                AND NOT EXISTS
                       (SELECT *
                          FROM eq_ekipman_sahibi_kim
                         WHERE account_number = wiz.account_number AND outlet_location = wiz.outlet_location AND sahiplik_tipi = 0 AND kayit_iptal = 'H')
                AND NOT EXISTS
                       (SELECT *
                          FROM ie_adres_degisikligi
                         WHERE durum = 'P' AND uye_no <> yeni_uye_no AND yeni_uye_no = wiz.account_number AND yeni_outlet_location = wiz.outlet_location)
                AND NOT EXISTS
                           (SELECT 1
                              FROM lg_ekipman lg
                             WHERE     lg.account_number = wiz.account_number
                                   AND lg.outlet_location = wiz.outlet_location
                                   AND lg.depodan IS NOT NULL
                                   AND lg.account_number IS NOT NULL
                                   AND EXISTS
                                          (SELECT *
                                             FROM wiz_equip w,
                                                  eq_ekipman_tip_matrix e
                                            WHERE     lg.serial_number = w.serial_number
                                                  AND w.converter_type = 'ST'
                                                  AND w.manufacturer = e.manufacturer
                                                  AND w.converter_model = e.converter_model
                                                  AND w.converter_type = e.converter_type
                                                  AND addressability_pack.ekipmanmodelkodu (e.eq_ekipman_tip_matrix_id) =
                                                         addressability_pack.ekipmanmodelkodu (eq.eq_ekipman_tip_matrix_id))
                            HAVING MIN (lg.islem_tarihi) < v_bas_turksat_acma_tarihi)
         UNION
         SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND wiz.account_number = life.account_number
                AND life.franchise_code IN ('F01', 'F02')
                --AND converter_model = 'DT-9002   '
                AND EXISTS
                       (SELECT 1
                          FROM dbs_dba.lg_abone_ozellik lg1
                         WHERE     lg1.account_number = wiz.account_number
                               AND lg1.outlet_location = wiz.outlet_location
                               AND lg1.abone_ozellik_kodu = 166
                               AND lg1.islem = 'D'
                               AND lg1.islem_tarihi >= pbaslangictarihi)
                AND NOT EXISTS
                       (SELECT account_number
                          FROM mb_abone_ozellik
                         WHERE abone_ozellik_kodu = 166 AND account_number = wiz.account_number AND outlet_location = wiz.outlet_location)
                AND NOT EXISTS
                       (SELECT *
                          FROM eq_ekipman_sahibi_kim
                         WHERE account_number = wiz.account_number AND outlet_location = wiz.outlet_location AND sahiplik_tipi = 0 AND kayit_iptal = 'H')
                AND NOT EXISTS
                       (SELECT *
                          FROM ie_adres_degisikligi
                         WHERE durum = 'P' AND uye_no <> yeni_uye_no AND yeni_uye_no = wiz.account_number AND yeni_outlet_location = wiz.outlet_location)
                AND NOT EXISTS
                           (SELECT 1
                              FROM lg_ekipman lg
                             WHERE     lg.account_number = wiz.account_number
                                   AND lg.outlet_location = wiz.outlet_location
                                   AND lg.depodan IS NOT NULL
                                   AND lg.account_number IS NOT NULL
                                   AND EXISTS
                                          (SELECT *
                                             FROM wiz_equip w,
                                                  eq_ekipman_tip_matrix e
                                            WHERE     lg.serial_number = w.serial_number
                                                  AND w.converter_type = 'ST'
                                                  AND w.manufacturer = e.manufacturer
                                                  AND w.converter_model = e.converter_model
                                                  AND w.converter_type = e.converter_type
                                                  AND addressability_pack.ekipmanmodelkodu (e.eq_ekipman_tip_matrix_id) =
                                                         addressability_pack.ekipmanmodelkodu (eq.eq_ekipman_tip_matrix_id))
                            HAVING MIN (lg.islem_tarihi) < v_bas_turksat_acma_tarihi);

      CURSOR cturksatacma  IS
         SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND life.account_number = wiz.account_number
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND life.franchise_code IN ('F01', 'F02')
                AND (wiz.install_date > pbaslangictarihi)
                AND NOT EXISTS
                           -- Murat Aydin 1112013 ITTP ENTEGRASYON
                        (SELECT 1
                           FROM dt_product_dba.product p
                          WHERE     p.logical_delete_key IS NULL
                                AND p.product_spec_id IS NOT NULL
                                AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                                AND p.service_account_id =
                                       billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL))
                -- mtonkus : 23/01/14 ittp entegrasyonu
                AND NOT EXISTS
                           (SELECT 1
                              FROM dt_bi_dba.business_inter don,
                                   dt_bi_dba.business_inter_spec bis
                             WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                                   AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                                   AND NOT EXISTS
                                              (SELECT 1
                                                 FROM dt_bi_dba.business_inter coz,
                                                      dt_bi_dba.business_inter_spec biss
                                                WHERE     coz.parent_id = don.business_inter_id
                                                      AND biss.business_inter_spec_id = coz.business_inter_spec_id
                                                      AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                      AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                                      AND coz.logical_delete_key IS NULL
                                                      AND biss.logical_delete_key IS NULL)
                                   AND don.business_inter_status_t_cd IN ('TAMAMLANDI')
                                   AND don.service_account_id =
                                          billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL)
                                   AND don.logical_delete_key IS NULL
                                   AND bis.logical_delete_key IS NULL)
         UNION
         SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND life.account_number = wiz.account_number
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND life.franchise_code IN ('F01', 'F02')
                AND (EXISTS
                        (SELECT account_number, outlet_location
                           FROM dbs_dba.mb_abone_ozellik mb
                          WHERE     mb.account_number = wiz.account_number
                                AND mb.outlet_location = wiz.outlet_location
                                AND mb.abone_ozellik_kodu = 166
                                AND mb.giris_tarihi >= pbaslangictarihi))
                AND NOT EXISTS
                           -- Murat Aydin 1112013 ITTP ENTEGRASYON
                        (SELECT 1
                           FROM dt_product_dba.product p
                          WHERE     p.logical_delete_key IS NULL
                                AND p.product_spec_id IS NOT NULL
                                AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                                AND p.service_account_id =
                                       billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL))
                AND NOT EXISTS
                           -- mtonkus : ittp entegrasyonu
                        (SELECT 1
                           FROM dt_bi_dba.business_inter don,
                                dt_bi_dba.business_inter_spec bis
                          WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                                AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                                AND NOT EXISTS
                                           (SELECT 1
                                              FROM dt_bi_dba.business_inter coz,
                                                   dt_bi_dba.business_inter_spec biss
                                             WHERE     coz.parent_id = don.business_inter_id
                                                   AND biss.business_inter_spec_id = coz.business_inter_spec_id
                                                   AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                   AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                                   AND coz.logical_delete_key IS NULL
                                                   AND biss.logical_delete_key IS NULL)
                                AND don.business_inter_status_t_cd = 'TAMAMLANDI'
                                AND don.service_account_id =
                                       billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL)
                                AND don.logical_delete_key IS NULL
                                AND bis.logical_delete_key IS NULL);

      CURSOR cuyeliksusdonkapa  IS
         SELECT /*+ INDEX(WIZ EQUIP_ACCT_SORT) */
               wiz.account_number, wiz.outlet_location, wiz.serial_number, 'D' AS durum
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND life.account_number = wiz.account_number
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND life.franchise_code IN ('F01', 'F02')
                -- mtonkus : 10/12/13 ittp entegrasyonu
                AND EXISTS
                       (SELECT 1
                          FROM dt_bi_dba.business_inter don,
                               dt_bi_dba.business_inter_spec bis
                         WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                               AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                               AND NOT EXISTS
                                          (SELECT *
                                             FROM dt_bi_dba.business_inter coz,
                                                  dt_bi_dba.business_inter_spec biss
                                            WHERE     coz.parent_id = don.business_inter_id
                                                  AND biss.business_inter_spec_id = coz.business_inter_spec_id
                                                  AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                  AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                                  AND coz.logical_delete_key IS NULL
                                                  AND biss.logical_delete_key IS NULL)
                               AND don.business_inter_status_t_cd IN ('TAMAMLANDI')
                               AND don.service_account_id =
                                      billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL)
                               AND don.logical_delete_key IS NULL
                               AND bis.logical_delete_key IS NULL
                               AND don.interaction_complete_date >= pbaslangictarihi)
         UNION ALL
         SELECT /*+ INDEX(WIZ EQUIP_ACCT_SORT) */
               wiz.account_number, wiz.outlet_location, wiz.serial_number, 'K' AS durum
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND life.account_number = wiz.account_number
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND life.franchise_code IN ('F01', 'F02')
                AND EXISTS
                       -- Murat Aydin 1112013 ITTP ENTEGRASYON
                    (SELECT 1
                       FROM dt_product_dba.product p,
                            dt_bi_dba.business_inter_spec bis,
                            dt_bi_dba.business_inter bi
                      WHERE     p.logical_delete_key IS NULL
                            AND p.product_spec_id IS NOT NULL
                            AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                            AND p.service_account_id = billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL)
                            AND p.service_account_id = bi.service_account_id
                            AND bi.business_inter_spec_id = bis.business_inter_spec_id
                            AND bi.business_inter_status_t_cd = 'TAMAMLANDI'
                            AND bis.business_inter_spec_cd = 'ASKI_DUSUR'
                            AND bi.interaction_complete_date >= pbaslangictarihi
                            AND bi.logical_delete_key IS NULL
                            AND bis.logical_delete_key IS NULL);

      CURSOR cuyeliksusdonac  IS
         SELECT wiz.account_number, wiz.outlet_location, wiz.serial_number
           FROM wiz_equip wiz,
                eq_ekipman_tip_matrix eq,
                pr_urun_ozellik_tanim t,
                wiz_customer_hp_life life
          WHERE     wiz.account_number <> 0
                AND wiz.account_number BETWEEN paccbaslangic AND paccbitis
                AND wiz.converter_type = 'ST'
                AND wiz.manufacturer = eq.manufacturer
                AND wiz.converter_model = eq.converter_model
                AND wiz.converter_type = eq.converter_type
                AND life.account_number = wiz.account_number
                AND t.urun_tipi = 6
                AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                AND t.ozellik_kodu = 69
                AND life.franchise_code IN ('F01', 'F02')
                -- mtonkus : 23/01/14 ittp entegrasyonu
                AND (   EXISTS
                           (SELECT 1
                              FROM dt_bi_dba.business_inter don,
                                   dt_bi_dba.business_inter_spec bis,
                                   dt_bi_dba.customer_order co
                             WHERE     don.business_inter_spec_id = bis.business_inter_spec_id
                                   AND bis.business_inter_spec_cd = 'PRODUCT_DON'
                                   AND EXISTS
                                          (SELECT *
                                             FROM dt_bi_dba.business_inter coz,
                                                  dt_bi_dba.business_inter_spec biss
                                            WHERE     coz.parent_id = don.business_inter_id
                                                  AND coz.business_inter_status_t_cd = 'TAMAMLANDI'
                                                  AND biss.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                  AND coz.logical_delete_key IS NULL
                                                  AND biss.logical_delete_key IS NULL)
                                   AND don.service_account_id =
                                          billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL)
                                   AND don.business_inter_id = co.customer_order_id
                                   AND don.business_inter_status_t_cd = 'TAMAMLANDI'
                                   AND don.logical_delete_key IS NULL
                                   AND bis.logical_delete_key IS NULL
                                   AND co.resume_date >= pbaslangictarihi
                                   AND NOT EXISTS -- uye don değilse
                                              (SELECT 1
                                                 FROM dt_bi_dba.business_inter don_bi,
                                                      dt_bi_dba.business_inter_spec don_spec
                                                WHERE     don_bi.business_inter_spec_id = don_spec.business_inter_spec_id
                                                      AND don_spec.business_inter_spec_cd = 'PRODUCT_DON'
                                                      AND NOT EXISTS
                                                                 (SELECT 1
                                                                    FROM dt_bi_dba.business_inter coz_bi,
                                                                         dt_bi_dba.business_inter_spec coz_spec
                                                                   WHERE     coz_bi.parent_id = don_bi.business_inter_id
                                                                         AND coz_bi.business_inter_status_t_cd = 'TAMAMLANDI'
                                                                         AND coz_bi.business_inter_spec_id = coz_spec.business_inter_spec_id
                                                                         AND coz_spec.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                                                         AND coz_bi.logical_delete_key IS NULL
                                                                         AND coz_spec.logical_delete_key IS NULL)
                                                      AND don_bi.business_inter_status_t_cd IN ('TAMAMLANDI')
                                                      AND don_bi.service_account_id =
                                                             billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number,
                                                                                                                       wiz.outlet_location,
                                                                                                                       NULL
                                                                                                                      )
                                                      AND don_bi.logical_delete_key IS NULL
                                                      AND don_spec.logical_delete_key IS NULL))
                     OR EXISTS
                           -- Murat Aydin 1112013 ITTP ENTEGRASYON
                        (SELECT 1
                           FROM dt_bi_dba.business_inter_spec bis,
                                dt_bi_dba.business_inter bi
                          WHERE     bi.business_inter_spec_id = bis.business_inter_spec_id
                                AND bi.business_inter_status_t_cd = 'TAMAMLANDI'
                                AND bis.business_inter_spec_cd = 'ASKI_DUSUR'
                                AND bi.service_account_id =
                                       billing_dbs_int.customer_ittp_pkg.get_service_account_id (wiz.account_number, wiz.outlet_location, NULL)
                                AND NOT EXISTS
                                           (SELECT 1
                                              FROM dt_product_dba.product p
                                             WHERE     p.logical_delete_key IS NULL
                                                   AND p.product_spec_id IS NOT NULL
                                                   AND p.product_status_type_cd = 'ASKIYA_ALINMIS'
                                                   AND p.service_account_id = bi.service_account_id)
                                AND bi.interaction_complete_date >= pbaslangictarihi
                                AND bi.logical_delete_key IS NULL
                                AND bis.logical_delete_key IS NULL));

      v_sc_serial_number        VARCHAR2 (15);
      v_brand                   VARCHAR2 (3);
      v_count                   NUMBER (2);
      odurum                    VARCHAR2 (100);
      v_uye_uydusu              NUMBER (2);
      v_uye_stb_tipi            VARCHAR2 (2);
      v_sinyal_kapanacak        BOOLEAN;
   BEGIN
      -- Eger maç var ise sinyal çikilmayacak. (5 Dakika ile 2 saat sonrasi arasinda maç var ise)
      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.mb_lig_fikstur_event f,
             prod_dba.wiz_ppv_events e
       WHERE     f.ppv_event_id = e.event_id
             AND SYSDATE BETWEEN f.hafta_begin_date AND f.hafta_end_date
             AND e.event_start_time BETWEEN SYSDATE + 5 / (24 * 60) AND SYSDATE + (2 / 24);

      IF v_count > 0 THEN
         RETURN;
      END IF;

      v_bas_turksat_acma_tarihi := TO_DATE (dbs_sabit ('TURKSAT_ACMA_TARIHI'), 'DD/MM/YYYY');

      FOR vturksatkapali IN cturksatkapali LOOP
         odurum       := '0';
         v_uye_uydusu := abone_sorgu_pack.uye_uydusu (vturksatkapali.account_number, vturksatkapali.outlet_location);

         IF v_uye_uydusu = 1 THEN
            BEGIN
               SELECT serial_number
                 INTO v_sc_serial_number
                 FROM wiz_equip
                WHERE account_number = vturksatkapali.account_number AND outlet_location = vturksatkapali.outlet_location AND converter_type = 'SC';

               addressability_pack.setothermode (vturksatkapali.account_number, v_sc_serial_number, vturksatkapali.serial_number, '0', 'SYSADDRLO', odurum);

               IF odurum <> '0' THEN
                  NULL;
                  --insert_log ('SET_OTHER_MODE ÇIKILAMADI_1 :' || vturksatkapali.account_number || '-' || SUBSTR (odurum, 1, 100));
                  NULL;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  insert_log ('SET_OTHER_MODE KAPAMA CIKILAMADI :' || vturksatkapali.account_number || '-' || SUBSTR (odurum, 1, 100));
            END;
         END IF;
      END LOOP;

      COMMIT;

      FOR vturksatacma IN cturksatacma LOOP
         odurum       := '0';
         v_uye_uydusu := abone_sorgu_pack.uye_uydusu (vturksatacma.account_number, vturksatacma.outlet_location);

         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.mb_abone_ozellik mb
          WHERE mb.account_number = vturksatacma.account_number AND mb.outlet_location = vturksatacma.outlet_location AND mb.abone_ozellik_kodu = 166;

         IF v_uye_uydusu = 2 OR v_count > 0 THEN
            BEGIN
               SELECT serial_number
                 INTO v_sc_serial_number
                 FROM wiz_equip
                WHERE account_number = vturksatacma.account_number AND outlet_location = vturksatacma.outlet_location AND converter_type = 'SC';

               addressability_pack.setothermode (vturksatacma.account_number, v_sc_serial_number, vturksatacma.serial_number, '1', 'SYSADDRLO', odurum);

               IF odurum <> '0' THEN
                  --insert_log ('SET_OTHER_MODE ÇIKILAMADI_1 :' || vturksatacma.account_number || '-' || SUBSTR (odurum, 1, 100));
                  odurum := '0';
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  insert_log ('SET_OTHER_MODE ACMA CIKILAMADI :' || vturksatacma.account_number || '-' || SUBSTR (odurum, 1, 100));
            END;
         END IF;
      END LOOP;

      COMMIT;

      FOR vsusdonkapa IN cuyeliksusdonkapa LOOP
         BEGIN
            odurum             := '0';

            SELECT serial_number
              INTO v_sc_serial_number
              FROM wiz_equip
             WHERE account_number = vsusdonkapa.account_number AND outlet_location = vsusdonkapa.outlet_location AND converter_type = 'SC';

            SELECT hp_cluster
              INTO v_uye_stb_tipi
              FROM wiz_customer_hp_life
             WHERE account_number = vsusdonkapa.account_number;

            v_sinyal_kapanacak := TRUE;

            IF v_uye_stb_tipi IN ('LG', 'VS') AND vsusdonkapa.durum = 'D' THEN
               v_sinyal_kapanacak := FALSE; -- Türksatçilar dondurulursa yayin kapatilmayacak.
            ELSE
               IF v_uye_stb_tipi IN ('LG', 'VS') AND vsusdonkapa.durum = 'K' THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM eq_ekipman_sahibi_kim k,
                         wiz_equip e
                   WHERE     e.account_number = vsusdonkapa.account_number
                         AND e.outlet_location = vsusdonkapa.outlet_location
                         AND e.converter_type = 'ST'
                         AND e.serial_number = k.serial_number
                         AND k.kayit_iptal = 'H'
                         AND k.sahiplik_tipi = 0
                         AND k.ekipman_sahibi_tipi = 1;

                  IF v_count > 0 THEN
                     v_sinyal_kapanacak := FALSE;
                  ELSE
                     SELECT COUNT (1)
                       INTO v_count
                       FROM eq_ekipman_sahibi_kim k,
                            wiz_equip e
                      WHERE     e.account_number = vsusdonkapa.account_number
                            AND e.outlet_location = vsusdonkapa.outlet_location
                            AND e.converter_type = 'ST'
                            AND e.serial_number = k.serial_number
                            AND k.kayit_iptal = 'H';

                     IF v_count = 0 THEN
                        v_sinyal_kapanacak := FALSE;
                     ELSE
                        v_sinyal_kapanacak := TRUE;
                     END IF;
                  END IF;
               END IF;

               IF v_sinyal_kapanacak = TRUE THEN
                  IF ekipman_ozellik_pack.turksat_acik (vsusdonkapa.serial_number) = 'E' THEN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM mb_abone_ozellik mb
                      WHERE mb.account_number = vsusdonkapa.account_number AND mb.outlet_location = vsusdonkapa.outlet_location AND mb.abone_ozellik_kodu = 206;

                     IF v_count = 0 THEN
                        abone_detay_pack.mb_abone_ozellik_insert (vsusdonkapa.account_number, vsusdonkapa.outlet_location, 206, 'SYSTEM', odurum);

                        IF odurum <> '0' THEN
                           insert_log ('SET_OTHER_MODE HATA ABONE_OZELLIK_INSERT:' || '-' || SUBSTR (odurum, 1, 100));
                        END IF;
                     END IF;
                  END IF;

                  addressability_pack.setothermode (vsusdonkapa.account_number, v_sc_serial_number, vsusdonkapa.serial_number, '0', 'SYSADDRLO', odurum);

                  IF odurum <> '0' THEN
                     odurum := '0';
                  END IF;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               insert_log ('SET_OTHER_MODE HATA SUS-DON KAPA:' || '-' || SUBSTR (odurum, 1, 100));
         END;
      END LOOP;

      COMMIT;

      FOR vsusdonac IN cuyeliksusdonac LOOP
         BEGIN
            SELECT COUNT (1)
              INTO v_count
              FROM mb_abone_ozellik mb
             WHERE mb.account_number = vsusdonac.account_number AND mb.outlet_location = vsusdonac.outlet_location AND mb.abone_ozellik_kodu = 206;

            IF v_count = 1 OR ekipman_ozellik_pack.turksat_acik (vsusdonac.serial_number) = 'E' THEN
               SELECT serial_number
                 INTO v_sc_serial_number
                 FROM wiz_equip
                WHERE account_number = vsusdonac.account_number AND outlet_location = vsusdonac.outlet_location AND converter_type = 'SC';

               IF v_count = 1 THEN
                  abone_detay_pack.mb_abone_ozellik_delete (vsusdonac.account_number, vsusdonac.outlet_location, 206, 'SYSTEM', odurum);
               END IF;

               addressability_pack.setothermode (vsusdonac.account_number, v_sc_serial_number, vsusdonac.serial_number, '1', 'SYSADDRLO', odurum);

               IF odurum <> '0' THEN
                  odurum := '0';
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               insert_log ('SET_OTHER_MODE HATA SUS-DON AC :' || '-' || SUBSTR (odurum, 1, 100));
         END;
      END LOOP;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         insert_log ('SET_OTHER_MODE HATA :' || '-' || SUBSTR (odurum, 1, 100));
   END;

   PROCEDURE winback_aylik_calis (pislemtarihi IN DATE DEFAULT SYSDATE) IS
      v_count NUMBER;
   BEGIN
      /*[EBerker20130507]: K,W,D,A yeni gelmis direk in yapilacak üyeler */
      /*[EBerker20130507] <<Start>>*/
      FOR statu_rec2
         IN (SELECT a.account_number, a.outlet_location
               FROM dbs_dba.mb_abone_statu a
              WHERE     a.statu = 'K'
                    AND EXISTS
                           (SELECT account_number, outlet_location
                              FROM mb_outlet_takip b
                             WHERE b.outlet_in_tarihi IS NOT NULL AND a.account_number = b.account_number AND a.outlet_location = b.outlet_location)
                    AND EXISTS
                           (SELECT *
                              FROM wiz_customer_hp_life c
                             WHERE a.account_number = c.account_number AND c.franchise_code = 'F01' AND c.customer_type = 'NOR')
                    AND EXISTS
                           (SELECT *
                              FROM (SELECT   account_number, outlet_location, MIN (d.outlet_ac_tarihi) min_accdate
                                        FROM mb_outlet_takip d
                                    GROUP BY account_number,
                                             outlet_location) x
                             WHERE     a.account_number = x.account_number
                                   AND a.outlet_location = x.outlet_location
                                   AND TRUNC (min_accdate) >= TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (account_number, SYSDATE + 1), -1)))
                    AND NOT EXISTS
                               (SELECT *
                                  FROM ie_adres_degisikligi e
                                 WHERE     e.durum = 'P'
                                       AND e.yeni_uye_no <> e.uye_no
                                       AND a.account_number = e.yeni_uye_no
                                       AND a.outlet_location = e.yeni_outlet_location)) -- Abone_statu_islem durum gibi bir kolon eklenmeli.
                                                                                       LOOP
         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.mb_abone_statu_islem i
          WHERE i.account_number = statu_rec2.account_number AND i.outlet_location = statu_rec2.outlet_location AND i.islem_tarihi IS NULL;

         IF v_count > 0 THEN
            UPDATE dbs_dba.mb_abone_statu_islem
               SET beklenen_islem_tarihi = TRUNC (SYSDATE)
             WHERE account_number = statu_rec2.account_number AND outlet_location = statu_rec2.outlet_location AND islem_tarihi IS NULL;
         ELSE
            INSERT INTO dbs_dba.mb_abone_statu_islem (account_number, outlet_location, giren_kullanici, giris_tarihi, beklenen_islem_tarihi)
                 VALUES (statu_rec2.account_number, statu_rec2.outlet_location, 'CHURNMNG', SYSDATE, TRUNC (SYSDATE));
         END IF;
      END LOOP;

      /*[EBerker20130507] <<Finish>>*/
      FOR statu_rec IN (SELECT s.account_number, s.outlet_location
                          FROM dbs_dba.mb_abone_statu s
                         WHERE     s.statu = 'K'
                               AND TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (s.account_number, s.statu_tarihi), 2)) <= TRUNC (pislemtarihi)
                               AND NOT EXISTS
                                      (SELECT 1
                                         FROM dbs_dba.mb_abone_statu_islem i
                                        WHERE i.account_number = s.account_number AND i.outlet_location = s.outlet_location AND i.islem_tarihi IS NULL)) -- Abone_statu_islem durum gibi bir kolon eklenmeli.
                                                                                                                                                        LOOP
         INSERT INTO dbs_dba.mb_abone_statu_islem (account_number, outlet_location, giren_kullanici, giris_tarihi, beklenen_islem_tarihi)
              VALUES (statu_rec.account_number, statu_rec.outlet_location, 'SYSTEM', SYSDATE, TRUNC (SYSDATE));
      END LOOP;

      COMMIT;
   END;

   PROCEDURE winback_gunluk_islem_acc (paccount_number IN NUMBER, poutlet_location IN CHAR, pislemtarihi IN DATE, o_durum OUT VARCHAR2) IS
      v_count               NUMBER;
      v_count_ac_outlet     NUMBER;
      out_uyari_mesaji      VARCHAR2 (1000);
      -- durum                 VARCHAR2 (1000);
      v_service_adress_id   NUMBER (10);
      v_uyelik_iptal_id     NUMBER (10);
      out_work_order_number NUMBER (10);
      out_statu             NUMBER (10);
      --hata_exception        EXCEPTION;
      v_son_aktif_outlet    NUMBER (2);
      v_islem_tipi          NUMBER (2);
      v_iptal_sebep_kodu    CHAR (3);
      v_hos_paket_uyesi     DATE;
      v_hp_life_in_yap      NUMBER (1);
      v_cust_type_count     NUMBER;
      v_statu_count         NUMBER;
      v_islem_count         NUMBER;
      v_uye_statu           VARCHAR2 (10);
      v_ittp_order_int_open NUMBER;
   BEGIN
      o_durum               := '0';

      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      IF TRIM (paccount_number) IS NULL OR TRIM (poutlet_location) IS NULL THEN
         o_durum := 'Account ve outlet bilgisi boş gönderilemez.';
         RETURN;
      END IF;

      FOR islem_rec
         IN (SELECT *
               FROM dbs_dba.mb_abone_statu_islem st
              WHERE     st.islem_tarihi IS NULL
                    AND TRUNC (st.beklenen_islem_tarihi) <= TRUNC (pislemtarihi)
                    AND (st.account_number = paccount_number AND st.outlet_location = poutlet_location)) LOOP
         BEGIN
            o_durum := '0';

            SELECT statu
              INTO v_uye_statu
              FROM dbs_dba.mb_abone_statu
             WHERE account_number = islem_rec.account_number AND outlet_location = islem_rec.outlet_location;

            IF v_uye_statu NOT IN ('K', 'Q', 'I') --v_uye_statu != 'K'  bsarcan 11112014
                                                 THEN
               DELETE FROM dbs_dba.mb_abone_statu_islem st
                     WHERE     TRUNC (st.beklenen_islem_tarihi) <= TRUNC (pislemtarihi)
                           AND st.account_number = islem_rec.account_number
                           AND st.outlet_location = islem_rec.outlet_location
                           AND st.islem_tarihi IS NULL;

               -- Eğer üye K statüsü dışında ise o zaman bu üye için işlem yapma ve kay
               --o_durum := 'Sadece K statüsünde ki üyeler için bu işlem yapılabilir.';
               -- Bu işlemin normalde commit edilmesi gerekiyor.
               RETURN;
            END IF;

            SELECT COUNT (1)
              INTO v_count_ac_outlet
              FROM mb_outlet_takip
             WHERE account_number = islem_rec.account_number AND outlet_location = islem_rec.outlet_location AND outlet_in_tarihi IS NULL;

            IF v_count_ac_outlet > 0 THEN -- outlet AC
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_uyelik_iptal ie
                WHERE ie.account_number = islem_rec.account_number AND outlet_location = islem_rec.outlet_location AND durum = 'O';

               SELECT service_address_id
                 INTO v_service_adress_id
                 FROM wiz_customer_hp_life
                WHERE account_number = islem_rec.account_number;

               -- Eger iptal talebi yok ise iptal talebi aç
               IF v_count = 0 THEN
                  v_iptal_sebep_kodu := dbs_sabit ('UYE_KAZANIM_IPTAL_SEBEP_KODU');
                  uyelik_iptali_pack.uyelik_iptal_insert_update (0,
                                                                 islem_rec.account_number,
                                                                 v_service_adress_id,
                                                                 islem_rec.outlet_location,
                                                                 'H',
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 SYSDATE,
                                                                 NULL,
                                                                 SYSDATE,
                                                                 'SYSTEM',
                                                                 'O',
                                                                 NULL,
                                                                 v_iptal_sebep_kodu, --in_reason_code,
                                                                 out_uyari_mesaji,
                                                                 o_durum
                                                                );

                  IF o_durum <> '0' THEN
                     RETURN;
                  END IF;
               ELSIF v_count = 1 -- Iptal talebi var. Iptal tarih güncelleniyor.
                                THEN
                  UPDATE ie_uyelik_iptal ie
                     SET ie.beklenen_kapanma_tarihi = SYSDATE, ie.degistiren_kullanici = 'SYSTEM', ie.degistirme_tarihi = SYSDATE
                   WHERE ie.account_number = islem_rec.account_number AND ie.outlet_location = islem_rec.outlet_location AND ie.durum = 'O';
               END IF;

               SELECT id
                 INTO v_uyelik_iptal_id
                 FROM ie_uyelik_iptal
                WHERE account_number = islem_rec.account_number AND outlet_location = islem_rec.outlet_location AND durum = 'O';

               --close_disconnect
               close_batch_pack.close_disconnect (v_uyelik_iptal_id, 'SYSTEM', SYSDATE, o_durum);

               IF o_durum <> '0' THEN
                  --RAISE hata_exception;
                  RETURN;
               END IF;
            ELSE -- Outlet IN Durumdadir.
               uyelik_iptali_pack.son_aktif_outlet_mi (islem_rec.account_number, islem_rec.outlet_location, v_son_aktif_outlet);

               /** Falamur yeni eklemeeler bitis*/
               --Binnur

               --IF v_ittp_order_int_open = 0 THEN
               --                  SELECT COUNT (*)
               --                    INTO v_count
               --                    FROM wiz_work_order w,
               --                         (SELECT *
               --                            FROM wiz_wo_line_items
               --                           WHERE outlet_location <> islem_rec.outlet_location AND wo_status = 'O' AND job_code = 'ADD') l
               --                   WHERE w.work_order_number = l.work_order_number AND w.wo_status IN ('P', 'O') AND w.account_number = islem_rec.account_number;
               --               ELSIF v_ittp_order_int_open = 1 THEN
               SELECT COUNT (*)
                 INTO v_count
                 FROM dt_dbs_int_dba.vv_ittp_customer_order wo
                WHERE     wo.dbs_account_number = islem_rec.account_number
                      AND wo.dbs_outlet_location <> islem_rec.outlet_location
                      AND wo.work_order_statu = ('ACIK')
                      AND wo.work_line_statu = ('ACIK')
                      AND wo.job_code = 'ADD'
                      AND wo.havadan_flag = 0;

               --END IF;

               /** Falamur yeni eklemeeler bitis*/

               v_hos_paket_uyesi := hos_paket_uyesi_mi (islem_rec.account_number, islem_rec.outlet_location);

               SELECT COUNT (1)
                 INTO v_cust_type_count
                 FROM wiz_customer_hp_life
                WHERE account_number = islem_rec.account_number AND customer_type NOT IN ('NOR', 'NOK');

               SELECT COUNT (1)
                 INTO v_statu_count
                 FROM dbs_dba.mb_abone_statu
                WHERE account_number = islem_rec.account_number AND outlet_location = islem_rec.outlet_location AND statu IN ('P', 'I', 'N');

               SELECT COUNT (1)
                 INTO v_islem_count
                 FROM dbs_dba.mb_abone_statu_islem
                WHERE     account_number = islem_rec.account_number
                      AND outlet_location = islem_rec.outlet_location
                      AND islem_tarihi IS NULL
                      AND TRUNC (beklenen_islem_tarihi) <= TRUNC (SYSDATE);

               IF    v_iptal_sebep_kodu = 'BFI'
                  OR v_iptal_sebep_kodu = 'ILG'
                  OR (yetki_pack.yetkisi_varmi ('SYSTEM', 'HOS_PAKET_ERKEN_UYELIK_IPTALI') > 0 AND v_hos_paket_uyesi IS NOT NULL)
                  OR v_cust_type_count > 0
                  OR v_statu_count > 0
                  OR v_islem_count > 0 THEN
                  v_hp_life_in_yap := 1;
               ELSE
                  v_hp_life_in_yap := 0;
               END IF;

               /** Falamur yeni eklemeler Bitis*/
               IF v_son_aktif_outlet = 1 AND v_count = 0 AND v_hp_life_in_yap = 1 THEN
                  v_islem_tipi := 7;
               ELSE
                  v_islem_tipi := 6;
               END IF;

               work_order_pack.work_order_insert (islem_rec.account_number, v_service_adress_id, 'WIZ', NULL, v_islem_tipi, out_work_order_number, out_statu);
               work_order_pack.close_wo (out_work_order_number,
                                         SYSDATE,
                                         islem_rec.outlet_location,
                                         NULL,
                                         NULL,
                                         NULL,
                                         SYSDATE,
                                         'SYSTEM',
                                         out_uyari_mesaji,
                                         o_durum
                                        );

               IF o_durum <> '0' THEN
                  --RAISE hata_exception;
                  RETURN;
               END IF;
            END IF;

            IF o_durum = '0' THEN
               UPDATE mb_abone_statu_islem
                  SET islem_tarihi = SYSDATE
                WHERE account_number = islem_rec.account_number AND outlet_location = islem_rec.outlet_location AND islem_tarihi IS NULL;
            END IF;

            COMMIT;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               o_durum := 'Unhandled Exception ' || SUBSTR (SQLERRM, 1, 255);
         END;
      END LOOP;
   END;

   PROCEDURE winback_gunluk_islem (pislemtarihi IN DATE DEFAULT SYSDATE) IS
      o_durum VARCHAR2 (512);
   BEGIN
      FOR islem_rec IN (SELECT *
                          FROM dbs_dba.mb_abone_statu_islem
                         WHERE islem_tarihi IS NULL AND TRUNC (beklenen_islem_tarihi) <= TRUNC (pislemtarihi)) LOOP
         BEGIN
            o_durum := '0';
            winback_gunluk_islem_acc (islem_rec.account_number, islem_rec.outlet_location, pislemtarihi, o_durum);

            IF o_durum != '0' THEN
               ROLLBACK;
            ELSE
               COMMIT;
            END IF;
         END;
      END LOOP;
   END;

   PROCEDURE fta_60_sinyali (paccbaslangic     IN     NUMBER DEFAULT 1000,
                             paccbitis         IN     NUMBER DEFAULT 7000000,
                             pbaslangictarihi  IN     DATE DEFAULT SYSDATE - 1,
                             poutlet           IN     VARCHAR2 DEFAULT NULL,
                             o_durum              OUT VARCHAR2,
                             pmesaj               OUT VARCHAR2,
                             psc_serial_number IN     VARCHAR2 DEFAULT NULL
                            ) IS
      v_enable            BOOLEAN;
      v_count             NUMBER;
      v_sahiplik_count    NUMBER;
      v_sc_serial_number  wiz_equip.serial_number%TYPE;
      v_tra_id            NUMBER;
      v_result            NUMBER;
      v_dbs_ekran_sinyali BOOLEAN;
      v_ird_mesaj_str     VARCHAR2 (120);
      v_islem_tarihi      DATE;
      v_ird_snc           NUMBER;
      p_anahtar           NUMBER;
      v_addr_user         VARCHAR2 (10);
      v_sql_stmt          VARCHAR2 (10000);
      v_daylimit          VARCHAR2 (2) := '60';

      TYPE cur_type IS REF CURSOR;

      uye_cur             cur_type;
      v_bulk_mode         BOOLEAN DEFAULT TRUE; --paccbaslangic ve paccbitis verilmezse
      v_account_number    wiz_equip.account_number%TYPE;
      v_serial_number     wiz_equip.serial_number%TYPE;
      v_outlet            wiz_equip.outlet_location%TYPE;
   BEGIN
      /*tek bir account ile çagrildiginda eski sorguyu, account araligi için çagrildiginda yeni sorguyu kullanmak için*/
      IF paccbitis = paccbaslangic THEN
         v_bulk_mode := FALSE;
      ELSE
         v_bulk_mode := TRUE;
      END IF;

      IF NOT v_bulk_mode THEN
         /*mevcut viewi kullan*/
         v_sql_stmt := q'[SELECT k.account_number, k.outlet_location, k.serial_number
                     FROM eq_ekipman_sahibi_kim k
                    WHERE k.sahiplik_tipi = 0 AND k.ekipman_sahibi_tipi = 1
                          AND k.account_number = :paccbitis
                          AND EXISTS
                                 (SELECT 1
                                    FROM wiz_equip eq
                                   WHERE eq.serial_number = k.serial_number
                                         AND eq.account_number =
                                                k.account_number
                                         AND eq.outlet_location =
                                                k.outlet_location)
                   UNION -- ITTP entegrasyonu için yazildi. Kutu borcunu bitirmis üyeler listeye aliniyor.
                   SELECT account_number, outlet_location, serial_number
                     FROM dt_billing_dba.vw_resource_debit
                    WHERE account_number = :paccbitis
                          AND tutar <= 0
                   UNION
                   SELECT account_number, outlet_location, serial_number
                     FROM wiz_equip wiz
                    WHERE wiz.converter_type = 'ST'
                          AND wiz.account_number = :paccbitis]';
      ELSE
         /*yeni sqli kullan*/
         v_sql_stmt      := q'[SELECT k.account_number, k.outlet_location, k.serial_number
                     FROM eq_ekipman_sahibi_kim k
                    WHERE k.sahiplik_tipi = 0 AND k.ekipman_sahibi_tipi = 1
                          AND k.degistirme_tarihi >= TRUNC (:pbaslangictarihi)
                          AND k.account_number BETWEEN :paccbaslangic AND :paccbitis
                           AND EXISTS
                                 (SELECT 1
                                    FROM wiz_equip eq
                                   WHERE eq.serial_number = k.serial_number
                                         AND eq.account_number =
                                                k.account_number
                                         AND eq.outlet_location =
                                                k.outlet_location)
                          UNION (select account_number, outlet_location, serial_number from (WITH tablo
             AS (SELECT /*+ordered use_nl_with_index(abr nidx_applied_billing_rate_03) use_nl( p,servac,pr)  parallel(r,10) parallel(l,10)  */
                       r.serial_number,
                        abr.bill_item_id,
                        bilit.bill_id,
                        servac.dbs_account_number,
                        servac.dbs_outlet_location
                   FROM dt_product_dba.resources r,
                        dt_product_dba.product  p,
                        DT_PARTY_DBA.PARTY_ROLE_ACCOUNT servac,
                        dt_party_dba.party_role_account pr,
                        dt_collection_dba.payment_collection_trx_log l,
                        dt_product_dba.product_price pp,
                        dt_product_dba.applied_billing_rate abr,
                        dt_product_dba.applied_billing_rate_spec abrs,
                        dt_billing_dba.bill_item bilit
                  WHERE 
                  r.product_id=p.product_id
                  and p.service_account_id=servac.party_role_account_id
                  and servac.dbs_account_number=pr.dbs_account_number 
                  and pr.account_order_sequence is null
                  and l.payer_bill_account_id=pr.party_role_account_id
                  and l.paid_date >= :pbaslangictarihi /*Tarih Araligi*/
                 AND servac.dbs_account_number between :paccbaslangic and :paccbitis  /*Üye araligi Araligi*/
                  and abr.bill_item_id = bilit.bill_item_id
                        AND abr.abr_spec_cd = abrs.applied_billing_rate_spec_cd
                        AND abrs.applied_billrt_spc_grp_t_cd = 'EKIPMAN'
                        AND pp.product_price_id = abr.product_price_id
                        AND r.product_id = pp.product_id
                        AND ABR.LOGICAL_DELETE_KEY IS NULL
                        AND SERVAC.PARTY_ROLE_ACCOUNT_ID = abr.SERVICE_ACCOUNT_ID
                        AND abr.STATUS_TYPE_CD = 'GECERLI'  --and rownum<3
                                                          )
          SELECT SERIAL_NUMBER,
                 ACCOUNT_NUMBER,
                 OUTLET_LOCATION,
                 SUM (TUTAR) tutAR,
                 MAX (son_odeme_tarihi) son_odeme_tarihi
            FROM (SELECT  /*+parallel(t,10)*/ SERIAL_NUMBER,
                         t.DBS_ACCOUNT_NUMBER ACCOUNT_NUMBER,
                         t.DBS_OUTLET_LOCATION OUTLET_LOCATION,
                         (DECODE (PAYMENT_PLAN_COLPAY_ST_T_CD,
                                  'ACIK', ppcr.AMOUNT,
                                  0))
                            TUTAR,
                         (DECODE (PAYMENT_STATUS_TYPE_CD,
                                  'KAPALI', PAYMENT_DATE,
                                  NULL))
                            son_odeme_tarihi
                    FROM tablo t,
                         DT_COLLECTION_DBA.PAYMENT_PLAN payp,
                         DT_COLLECTION_DBA.PAYMENT_PLAN_COLLECTION_R ppcr,
                        DT_COLLECTION_DBA.PAYMENT_COLLECTION coll
                   WHERE
                   PAYP.PAYMENT_PLAN_TYPE_CD <> 'TAKSIT'    
                   AND  payp.bill_id = t.bill_id
                         AND payp.PAYMENT_PLAN_STATUS_TYPE_CD = 'GECERLI'
                         AND payp.LOGICAL_DELETE_KEY IS NULL
                         AND PPCR.PAYMENT_PLAN_ID = PAYP.PAYMENT_PLAN_ID
                         AND ppcr.PAYMENT_PLAN_COL_R_STAT_T_CD = 'GECERLI'
                         AND coll.PAYMENT_COLLECTION_ID(+) =
                                ppcr.PAYMENT_COLLECTION_ID
                         AND COLL.LOGICAL_DELETE_KEY IS NULL
                  UNION ALL
                  SELECT  /*+parallel(tt,10)*/ SERIAL_NUMBER,
                         tt.DBS_ACCOUNT_NUMBER ACCOUNT_NUMBER,
                         tt.DBS_OUTLET_LOCATION OUTLET_LOCATION,
                         (DECODE (PAYMENT_PLAN_COLPAY_ST_T_CD,
                                  'ACIK', ppcr.AMOUNT,
                                  0))
                            TUTAR,
                         (DECODE (PAYMENT_STATUS_TYPE_CD,
                                  'KAPALI', PAYMENT_DATE,
                                  NULL))
                            son_odeme_tarihi
                    FROM tablo tt,
                         DT_COLLECTION_DBA.PAYMENT_PLAN payp,
                         DT_COLLECTION_DBA.PAYMENT_PLAN_COLLECTION_R ppcr,
                         DT_COLLECTION_DBA.PAYMENT_COLLECTION coll
                   WHERE     PAYP.PAYMENT_PLAN_TYPE_CD = 'TAKSIT'
                         AND payp.BILL_ITEM_ID = tt.BILL_ITEM_ID
                         AND payp.PAYMENT_PLAN_STATUS_TYPE_CD = 'GECERLI'
                         AND payp.LOGICAL_DELETE_KEY IS NULL
                         AND PPCR.PAYMENT_PLAN_ID = PAYP.PAYMENT_PLAN_ID
                         AND ppcr.PAYMENT_PLAN_COL_R_STAT_T_CD = 'GECERLI'
                         AND coll.PAYMENT_COLLECTION_ID(+) =
                                ppcr.PAYMENT_COLLECTION_ID
                         AND COLL.LOGICAL_DELETE_KEY IS NULL)
        GROUP BY SERIAL_NUMBER, ACCOUNT_NUMBER, OUTLET_LOCATION HAVING SUM(TUTAR)<=0 ))
                   UNION
                   SELECT account_number, outlet_location, serial_number
                     FROM wiz_equip wiz
                    WHERE wiz.converter_type = 'ST'
                          AND wiz.account_number BETWEEN :paccbaslangic  AND :paccbitis AND install_date >= TRUNC (:pbaslangictarihi)]';
      END IF;

      --    dbms_output.put_line (v_sql_stmt);

      IF TRIM (poutlet) IS NOT NULL THEN
         o_durum             := '-1';
         pmesaj              := 'Kayit bulunamadi';
         v_addr_user         := 'SYSTEM';
         --            IF TRIM (psc_serial_number) IS NOT NULL
         --            THEN
         --                v_dbs_ekran_sinyali := FALSE;
         --            ELSE
         v_dbs_ekran_sinyali := TRUE;
      --            END IF;
      ELSE
         -- Burada batch ile fta sinyali çikilmaktadir.  Eger maç var ise o zaman bu batch çalismasin (5 Dakika ile 2 saat sonrasi arasinda maç var ise)
         o_durum             := '0';
         pmesaj              := '';
         v_addr_user         := 'SYSADDRLO';
         v_dbs_ekran_sinyali := FALSE;
      --MKECECI  - 13.08.2013
      --         SELECT COUNT (1)
      --           INTO v_count
      --           FROM dbs_dba.mb_lig_fikstur_event f, prod_dba.wiz_ppv_events e
      --          WHERE f.ppv_event_id = e.event_id
      --                AND SYSDATE BETWEEN f.hafta_begin_date AND f.hafta_end_date
      --                AND e.event_start_time BETWEEN SYSDATE + 5 / (24 * 60)
      --                                           AND SYSDATE + (2 / 24);
      --
      --         IF v_count > 0
      --         THEN
      --            RETURN;
      --         END IF;
      --</end>
      END IF;

      -- Gün limitinin güncel değerini almak için..
      v_daylimit := NVL (dbs_addr.getdinamikkeyvalue ('FTA_60_SINYALI_GUN_LIMITI'), '60'); -- varsa parametrik değeri kullan, yoksa default değeri

      -- ITTP Entegrasyon anahtar
      p_anahtar  := dbs_dba.sabit.is_ittp_finans_ent_acik;

      /*bozturkmen seçilen sql e göre parametreler degisecegi için cursor ve parametre seçimi yapiliyor.
        Parametreler belli oldugundan, Daha hizli calismasi icin dbms_sql yerine nds kullanildi*/
      IF NOT v_bulk_mode THEN
         OPEN uye_cur FOR v_sql_stmt USING paccbitis, paccbitis, paccbitis;
      ELSE
         OPEN uye_cur FOR v_sql_stmt
            USING pbaslangictarihi, paccbaslangic, paccbitis, pbaslangictarihi, paccbaslangic, paccbitis, paccbaslangic, paccbitis, pbaslangictarihi;
      END IF;

      LOOP
         FETCH uye_cur INTO v_account_number, v_outlet, v_serial_number;

         EXIT WHEN uye_cur%NOTFOUND;

         IF TRIM (poutlet) IS NULL OR poutlet = v_outlet THEN
            v_enable := TRUE;

            SELECT COUNT (1)
              INTO v_count
              FROM wiz_equip wiz,
                   eq_ekipman_tip_matrix eq,
                   pr_urun_ozellik_tanim t
             WHERE     wiz.serial_number = v_serial_number
                   AND wiz.account_number = v_account_number
                   AND wiz.outlet_location = v_outlet
                   AND wiz.converter_type = 'ST'
                   AND wiz.manufacturer = eq.manufacturer
                   AND wiz.converter_model = eq.converter_model
                   AND wiz.converter_type = eq.converter_type
                   AND t.urun_tipi = 6
                   AND eq.eq_ekipman_tip_matrix_id = t.ekipman_tip_matrix_id
                   AND t.ozellik_kodu = 89
                   AND t.listeden_gizle = 'H';

            IF v_count > 0 THEN -- Ekipman uyumludur.
               -- Afsin abiden alinan ekipman taksi devam edenlerin disinda ve ekipman sahipligi var ise
               SELECT COUNT (1)
                 INTO v_sahiplik_count
                 FROM eq_ekipman_sahibi_kim
                WHERE     sahiplik_tipi = 0
                      AND ekipman_sahibi_tipi = 1
                      AND kayit_iptal = 'H'
                      AND account_number = v_account_number
                      AND outlet_location = v_outlet
                      AND serial_number = v_serial_number;

               --01.11.2011 OZGUR ARSLAN
               -- poh_records ittp entg kodu eklendi
               IF v_sahiplik_count > 0 THEN -- gerçcek sahipligi var
                  IF p_anahtar <= 0 THEN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM fatura.mb_ekipman_tahsilat_taksit tt,
                            fatura.payment_plan pp,
                            wiz_customer_mailbox mb,
                            wiz_ar_trx trx
                      WHERE     tt.status IN ('O', 'C')
                            AND tt.process_status NOT IN (1, 3)
                            AND pp.ekp_tahs_taksit_id = tt.id
                            AND pp.account_number = trx.account_number
                            AND mb.account_number = trx.account_number
                            AND tt.account_number = v_account_number
                            AND tt.outlet_location = v_outlet
                            AND pp.trx_sequence_num = trx.trx_sequence_num
                            AND trx.posting_date BETWEEN mb.data_collection_from_date AND mb.data_collection_to_date
                            AND (   EXISTS
                                       (SELECT 1
                                          FROM fatura.payment_plan
                                         WHERE ekp_tahs_taksit_id = tt.id AND trx_sequence_num IS NULL)
                                 OR EXISTS
                                       (SELECT 1
                                          FROM poh_records
                                         WHERE ohxact IN (mb.statement_number, mb.dp_statement_number) AND poh_status = 1));
                  ELSE
                     -- Kutunun borcunun devam ettigi bilginin ITTP kontrolü
                     SELECT COUNT (1)
                       INTO v_count
                       FROM dt_billing_dba.vw_resource_debit_account --dt_billing_dba.vw_resource_debit
                      WHERE account_number = v_account_number AND outlet_location = v_outlet AND serial_number = v_serial_number AND tutar > 0;
                  END IF;

                  -- takstilerini ödememis üyeler disinda ise o zaman v_enable = FALSE olascak. afsin abiden sorguyu alacagiz.
                  IF v_count = 0 THEN
                     v_enable := FALSE;
                  END IF;
               ELSE
                  SELECT COUNT (1)
                    INTO v_count
                    FROM eq_ekipman_sahibi_kim kim
                   WHERE kim.account_number = v_account_number AND kim.outlet_location = v_outlet AND kim.serial_number = v_serial_number AND kayit_iptal = 'H';

                  IF v_count = 0 THEN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM wiz_customer_hp_life life
                      WHERE     life.account_number = v_account_number
                            AND life.hp_cluster IN ('LG', 'VS')
                            AND ekipman_taahhudu_var_mi (v_account_number, v_outlet, v_serial_number, 0, 0) <> 1;

                     IF v_count > 0 THEN
                        v_enable := FALSE;
                     END IF;
                  END IF;
               END IF;

               BEGIN
                  IF TRIM (psc_serial_number) IS NOT NULL THEN
                     v_sc_serial_number := psc_serial_number;

                     SELECT COUNT (1)
                       INTO v_count
                       FROM wiz_equip
                      WHERE serial_number = psc_serial_number AND converter_type = 'SC';

                     IF v_count = 0 THEN
                        o_durum := '-1';
                        pmesaj  := 'Hatali kart numarasi girildi..';
                        RETURN;
                     END IF;

                     SELECT COUNT (1)
                       INTO v_count
                       FROM wiz_equip
                      WHERE serial_number = psc_serial_number AND account_number = 0 OR (account_number = v_account_number AND outlet_location = v_outlet);

                     IF v_count = 0 THEN
                        o_durum := '-1';
                        pmesaj  := 'Kart depoda olmalidir..';
                        RETURN;
                     END IF;
                  ELSE
                     BEGIN
                        SELECT e.serial_number
                          INTO v_sc_serial_number
                          FROM wiz_equip e
                         WHERE e.account_number = v_account_number AND e.outlet_location = v_outlet AND e.converter_type = 'SC';
                     EXCEPTION
                        WHEN OTHERS THEN
                           o_durum := '-1';
                           pmesaj  := 'Üye üzerinde kart bulunmalidir.';
                           RETURN;
                     END;
                  END IF;

                  v_islem_tarihi := SYSDATE;

                  IF v_dbs_ekran_sinyali = TRUE THEN
                     IF v_enable = TRUE THEN
                        v_ird_mesaj_str := v_daylimit || ' gün izleme limiti devreye alinacaktir. Ikinci bir mesaja kadar kutuya müdahale etmeyin.';
                     ELSE
                        v_ird_mesaj_str := v_daylimit || ' gün izleme limiti devre disi birakilacaktir. Ikinci bir mesaja kadar kutuya müdahale etmeyin.';
                     END IF;

                     -- Burada IRD sinyali çikilacak.
                     v_ird_snc      := dbs_addr_reqs_pack.display_message ('2',
                                                                           v_sc_serial_number,
                                                                           v_ird_mesaj_str,
                                                                           v_islem_tarihi,
                                                                           v_addr_user,
                                                                           o_durum,
                                                                           NULL,
                                                                           --p_policy                      => v_policy,
                                                                           p_background_colour => NULL,
                                                                           p_character_colour  => NULL
                                                                          );

                     IF o_durum IS NULL THEN
                        o_durum := '0';
                     END IF;

                     IF o_durum <> '0' OR v_ird_snc <> 1 THEN
                        RETURN;
                     END IF;

                     v_islem_tarihi := v_islem_tarihi + 30 / (60 * 60 * 24);
                  -- 30 sn sonrasina set et.
                  END IF;

                  IF v_enable = FALSE THEN
                     --Disable sinyali çikilacak
                     v_result      := dbs_addr.dbs_addr_reqs_pisys_pack.set_freetoair_limit (56,
                                                                                             v_sc_serial_number,
                                                                                             0, -- 1 enable - 0 Disable
                                                                                             v_islem_tarihi,
                                                                                             v_addr_user,
                                                                                             v_tra_id,
                                                                                             o_durum
                                                                                            );
                  ELSE
                     --Enable sinyali çikilacak
                     v_result      := dbs_addr.dbs_addr_reqs_pisys_pack.set_freetoair_limit (56,
                                                                                             v_sc_serial_number,
                                                                                             1, -- 1 enable - 0 Disable
                                                                                             v_islem_tarihi,
                                                                                             v_addr_user,
                                                                                             v_tra_id,
                                                                                             o_durum
                                                                                            );
                  END IF;

                  v_islem_tarihi := v_islem_tarihi + 30 / (60 * 60 * 24);

                  IF v_dbs_ekran_sinyali = TRUE THEN
                     IF v_enable = TRUE THEN
                        v_ird_mesaj_str := v_daylimit || ' gün izleme limiti devreye alinmistir. Iyi Günler...';
                     ELSE
                        v_ird_mesaj_str := v_daylimit || ' gün izleme limiti devre disi birakilmistir. Iyi Günler...';
                     END IF;

                     -- Burada IRD sinyali çikilacak.
                     v_ird_snc      := dbs_addr_reqs_pack.display_message ('2',
                                                                           v_sc_serial_number,
                                                                           v_ird_mesaj_str,
                                                                           v_islem_tarihi,
                                                                           v_addr_user,
                                                                           o_durum,
                                                                           NULL,
                                                                           --p_policy                      => v_policy,
                                                                           p_background_colour => NULL,
                                                                           p_character_colour  => NULL
                                                                          );

                     IF o_durum IS NULL THEN
                        o_durum := '0';
                     END IF;

                     IF o_durum <> '0' OR v_ird_snc <> 1 THEN
                        RETURN;
                     END IF;

                     v_islem_tarihi := v_islem_tarihi + 30 / (60 * 60 * 24);
                  -- 30 sn sonrasina set et.
                  END IF;

                  IF TRIM (poutlet) IS NOT NULL THEN
                     IF TRIM (o_durum) IS NULL OR o_durum = '0' THEN
                        IF v_enable THEN
                           o_durum := '0';
                           pmesaj  := v_daylimit || ' Gün Sinyali açildi.';
                           RETURN;
                        ELSE
                           o_durum := '0';
                           pmesaj  := v_daylimit || ' Gün Sinyali Kapatildi.';
                           RETURN;
                        END IF;
                     ELSE
                        o_durum := '-1';
                        pmesaj  := 'Sinyal çikilamadi. Hata :' || o_durum;
                        RETURN;
                     END IF;
                  ELSE
                     COMMIT;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 2000));

                     IF TRIM (poutlet) IS NOT NULL THEN
                        o_durum := '-1';
                        pmesaj  := v_daylimit || ' gün sinyali gönderilemedi. ' || SUBSTR (SQLERRM, 1, 100);
                        RETURN;
                     END IF;
               END;
            ELSE
               IF TRIM (poutlet) IS NOT NULL AND poutlet = v_outlet THEN
                  o_durum := '-1';
                  pmesaj  := 'Kutu ' || v_daylimit || ' Gün sinyalini desteklememektedir.';
               --RETURN;  --MKECECI
               END IF;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.put_line (SUBSTR (SQLERRM, 1, 255));
   END;

   /*--- Evren --- 20101013 --- begin ---*/

   FUNCTION uye_outlet_suresi (in_account_number NUMBER, in_outlet_location VARCHAR2, in_hos_paket_kontrolu VARCHAR2 DEFAULT 'E')
      RETURN NUMBER IS
      TYPE statu_rec_type IS RECORD
      (
         bas_tarih DATE,
         bit_tarih DATE,
         silindi   CHAR (1)
      );

      TYPE statu_type IS TABLE OF statu_rec_type
         INDEX BY BINARY_INTEGER;

      statu_arr         statu_type;
      v_kisi_iliski     tabone_iliski;
      v_acc_list        VARCHAR2 (1024);
      v_sysdate         DATE := SYSDATE;
      v_arr_count       NUMBER := 0;
      v_sure_ay         NUMBER := 0;
      v_account_number  NUMBER;
      v_outlet_location VARCHAR2 (3);
      v_tarih           DATE;
      v_max_tarih       DATE;

      TYPE uye_outlet_rec_type IS RECORD
      (
         account_number  NUMBER,
         outlet_location VARCHAR2 (3)
      );

      TYPE uye_outlet_type IS TABLE OF uye_outlet_rec_type
         INDEX BY BINARY_INTEGER;

      uye_outlet_arr    uye_outlet_type;

      CURSOR statu_cur (
         p_account_number   NUMBER,
         p_outlet_location  VARCHAR2) IS
         SELECT   statu_bas_tarih, statu_bit_tarih
             FROM (SELECT statu_tarihi AS statu_bas_tarih, v_sysdate AS statu_bit_tarih
                     FROM mb_abone_statu
                    WHERE account_number = p_account_number AND outlet_location = p_outlet_location AND statu IN ('A', 'D', 'S', 'W', 'K') --I ve N yok
                   UNION
                   SELECT statu_baslangic_tarihi AS statu_bas_tarih, statu_bitis_tarihi AS statu_bit_tarih
                     FROM lg_abone_statu
                    WHERE     account_number = p_account_number
                          AND outlet_location = p_outlet_location
                          AND statu IN ('A', 'D', 'S', 'W', 'K') --I ve N yok
                          AND statu_bitis_tarihi IS NOT NULL)
         ORDER BY statu_bas_tarih,
                  statu_bit_tarih;
   BEGIN
      uye_outlet_arr (v_arr_count).account_number  := in_account_number;
      uye_outlet_arr (v_arr_count).outlet_location := in_outlet_location;
      v_account_number                             := in_account_number;
      v_outlet_location                            := in_outlet_location;
      v_arr_count                                  := 1;

      WHILE v_account_number IS NOT NULL AND v_outlet_location IS NOT NULL LOOP
         BEGIN
            SELECT ad.uye_no, ad.eski_outlet_location, uye_no, eski_outlet_location
              INTO v_account_number, v_outlet_location, uye_outlet_arr (v_arr_count).account_number, uye_outlet_arr (v_arr_count).outlet_location
              FROM ie_adres_degisikligi ad
             WHERE     ad.durum = 'P'
                   AND ad.eski_stb_tipi IS NULL
                   AND ad.yeni_stb_tipi IS NULL
                   AND ad.yeni_uye_no = v_account_number
                   AND ad.yeni_outlet_location = v_outlet_location
                   AND (ad.uye_no <> ad.yeni_uye_no OR ad.eski_outlet_location <> ad.yeni_outlet_location);

            v_arr_count := v_arr_count + 1;
         EXCEPTION
            WHEN OTHERS THEN
               v_account_number  := NULL;
               v_outlet_location := NULL;
         END;
      END LOOP;

      v_arr_count                                  := 0;

      /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
      IF in_hos_paket_kontrolu = 'E' THEN
         IF sabit.is_ittp_taahhut_ent_acik = 0 THEN
            SELECT NVL (TRUNC (MAX (taahhut_bas_tar)), TO_DATE ('01.01.1900', 'dd.mm.yyyy'))
              INTO v_max_tarih
              FROM fatura.mb_ekipman_taksit_charge
             WHERE account_number = in_account_number AND outlet_location = in_outlet_location AND charge_finished IN ('Y', 'N');
         ELSE
            SELECT NVL (TRUNC (MAX (ag.valid_from)), TO_DATE ('01.01.1900', 'dd.mm.yyyy'))
              INTO v_max_tarih
              FROM dt_bi_dba.business_inter bi,
                   dt_bi_dba.agreement ag
             WHERE     bi.business_inter_id = ag.agreement_id
                   AND bi.service_account_id = billing_dbs_int.customer_ittp_pkg.get_service_account_id (in_account_number, in_outlet_location)
                   AND bi.business_inter_spec_id IN (SELECT business_inter_spec_id
                                                       FROM dt_bi_dba.business_inter_spec taah
                                                      WHERE business_inter_spec_cd = 'HOS_PAKET_TAAHHUDU')
                   AND bi.business_inter_status_t_cd <> 'IPTAL';
         END IF;
      ELSE
         v_max_tarih := TO_DATE ('01.01.1900', 'dd.mm.yyyy');
      END IF;

      FOR i IN REVERSE 0 .. uye_outlet_arr.COUNT - 1 LOOP
         FOR statu_rec IN statu_cur (uye_outlet_arr (i).account_number, uye_outlet_arr (i).outlet_location) LOOP
            statu_arr (v_arr_count).bas_tarih := statu_rec.statu_bas_tarih;
            statu_arr (v_arr_count).bit_tarih := statu_rec.statu_bit_tarih;
            statu_arr (v_arr_count).silindi   := 'H';
            v_arr_count                       := v_arr_count + 1;
         END LOOP;

         SELECT NVL (MAX (statu_tarihi), TO_DATE ('01.01.1900', 'dd.mm.yyyy'))
           INTO v_tarih
           FROM (SELECT statu_tarihi
                   FROM mb_abone_statu
                  WHERE     account_number = uye_outlet_arr (i).account_number
                        AND outlet_location = uye_outlet_arr (i).outlet_location
                        AND statu = 'I'
                        AND eski_statu = 'K'
                 UNION
                 SELECT statu_baslangic_tarihi statu_tarihi
                   FROM lg_abone_statu
                  WHERE     account_number = uye_outlet_arr (i).account_number
                        AND outlet_location = uye_outlet_arr (i).outlet_location
                        AND statu = 'I'
                        AND eski_statu = 'K'
                        AND statu_bitis_tarihi IS NOT NULL
                 UNION
                 SELECT outlet_in_tarihi statu_tarihi
                   FROM mb_outlet_takip x
                  WHERE     account_number = uye_outlet_arr (i).account_number
                        AND outlet_location = uye_outlet_arr (i).outlet_location
                        AND outlet_in_tarihi IS NOT NULL
                        AND NOT EXISTS
                                   (SELECT 1
                                      FROM mb_abone_statu
                                     WHERE     account_number = uye_outlet_arr (i).account_number
                                           AND outlet_location = uye_outlet_arr (i).outlet_location
                                           AND statu IN ('K', 'T')
                                           AND x.outlet_in_tarihi >= statu_tarihi)
                        AND NOT EXISTS
                                   (SELECT 1
                                      FROM lg_abone_statu
                                     WHERE     account_number = uye_outlet_arr (i).account_number
                                           AND outlet_location = uye_outlet_arr (i).outlet_location
                                           AND statu IN ('K', 'T')
                                           AND statu_baslangic_tarihi <= x.outlet_in_tarihi
                                           AND statu_bitis_tarihi > x.outlet_in_tarihi));

         IF v_tarih > v_max_tarih THEN
            v_max_tarih := v_tarih;
         END IF;
      END LOOP;

      FOR i IN 0 .. v_arr_count - 1 LOOP
         FOR j IN i + 1 .. v_arr_count - 1 LOOP
            IF statu_arr (j).silindi = 'H' THEN
               IF statu_arr (i).bit_tarih >= statu_arr (j).bit_tarih THEN
                  statu_arr (j).silindi := 'E';
               ELSIF statu_arr (i).bit_tarih >= statu_arr (j).bas_tarih THEN
                  statu_arr (i).bit_tarih := statu_arr (j).bit_tarih;
                  statu_arr (j).silindi   := 'E';
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      FOR i IN 0 .. v_arr_count - 1 LOOP
         IF statu_arr (i).silindi = 'H' THEN
            IF statu_arr (i).bit_tarih > v_max_tarih AND statu_arr (i).bas_tarih > v_max_tarih THEN
               v_sure_ay := v_sure_ay + MONTHS_BETWEEN (statu_arr (i).bit_tarih, statu_arr (i).bas_tarih);
            ELSIF statu_arr (i).bit_tarih > v_max_tarih AND statu_arr (i).bas_tarih <= v_max_tarih THEN
               v_sure_ay := v_sure_ay + MONTHS_BETWEEN (statu_arr (i).bit_tarih, v_max_tarih);
            END IF;
         END IF;
      END LOOP;

      RETURN FLOOR (v_sure_ay);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END;

   PROCEDURE activate_on_air_for_churn (in_begin_date IN DATE DEFAULT TRUNC (SYSDATE - 1)) IS
      o_durum               VARCHAR2 (200);
      o_return_status       NUMBER;
      o_return_code         VARCHAR2 (200);
      o_bitis_tarih         VARCHAR2 (200);
      o_aciklama            VARCHAR2 (200);
      o_id                  NUMBER;
      --Mesut Keçecioglu 01.08.2012
      v_count               NUMBER;
      j                     NUMBER;
      v_outlet_suresi       NUMBER;
      v_outlet_ac_tarihi    DATE;
      v_next_billing_date   DATE;
      v_ittp_order_int_open NUMBER;

      TYPE servicelist IS VARRAY (5) OF VARCHAR2 (3);

      TYPE campaignlist IS VARRAY (5) OF VARCHAR2 (3);

      v_servisler           servicelist := servicelist ('BLG', 'TSO', 'COC', 'HBR', 'YSM');
      v_kampanyalar         campaignlist := campaignlist ('TM1', 'TM3', 'TM2', 'TM4', 'TM5');
   --Mesut Keçecioglu 01.08.2012
   BEGIN
      FOR rec_
         IN ( (SELECT DISTINCT hs.account_number, hs.outlet_location
                 FROM wiz_customer_hp_svc hs
                WHERE     hs.add_closed_date > in_begin_date
                      AND EXISTS
                             (SELECT 1
                                FROM wiz_customer_hp_life hl
                               WHERE     hl.account_number = hs.account_number
                                     AND hl.franchise_code IN ('F01', 'F02')
                                     AND hl.hp_cluster = 'PH'
                                     AND hl.customer_type = 'NOR')
                      AND NOT EXISTS
                             (SELECT 1
                                FROM dbs_addr_on_air_activation x
                               WHERE x.account_number = hs.account_number AND x.outlet_location = hs.outlet_location AND x.campaign_code = 'PC1')
                      AND NOT EXISTS
                             (SELECT 1
                                FROM mb_abone_ozellik mb
                               WHERE mb.account_number = hs.account_number AND mb.outlet_location = hs.outlet_location AND mb.abone_ozellik_kodu = 255)
                      AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
             UNION
             (SELECT DISTINCT hs.account_number, hs.outlet_location
                FROM dt_dbs_int_dba.vv_uye_ittp_servisler hs
               WHERE     hs.add_close_date > in_begin_date
                     AND EXISTS
                            (SELECT 1
                               FROM wiz_customer_hp_life hl
                              WHERE     hl.account_number = hs.account_number
                                    AND hl.franchise_code IN ('F01', 'F02')
                                    AND hl.hp_cluster = 'PH'
                                    AND hl.customer_type = 'NOR')
                     AND NOT EXISTS
                                (SELECT 1
                                   FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan hav
                                  WHERE     hav.account_number = hs.account_number
                                        AND hav.outlet_location = hs.outlet_location
                                        AND SUBSTR (hav.campaign_code, 7, 3) = 'PC1')
                     AND NOT EXISTS
                            (SELECT 1
                               FROM mb_abone_ozellik mb
                              WHERE mb.account_number = hs.account_number AND mb.outlet_location = hs.outlet_location AND mb.abone_ozellik_kodu = 255)
                     AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))) LOOP
         IF hos_paket_uyesi_mi (rec_.account_number, rec_.outlet_location, 'E') IS NOT NULL THEN
            IF uye_outlet_suresi (rec_.account_number, rec_.outlet_location) >= 12 THEN
               addressability_pack.dbs_activate_on_air (rec_.account_number,
                                                        rec_.outlet_location,
                                                        'PC1',
                                                        'GPM',
                                                        'CME',
                                                        SYSDATE,
                                                        'SYSTEM',
                                                        o_durum,
                                                        o_return_status,
                                                        o_return_code,
                                                        o_bitis_tarih,
                                                        o_aciklama,
                                                        o_id,
                                                        'DBS'
                                                       );

               IF o_durum = '0' THEN
                  COMMIT;
               ELSE
                  ROLLBACK;
               END IF;
            END IF;
         ELSE
            /***  MKECECI  - 25.12.2013  - <BEGIN>  ***/
            SELECT COUNT (1)
              INTO v_count
              FROM pr_urun_ozellik_tanim pr,
                   wiz_customer_hp_svc wz
             WHERE     pr.urun_tipi = 2 --servis
                   AND pr.ozellik_kodu = 95 --platin servis
                   AND pr.urun_kodu = wz.service_code
                   AND pr.listeden_gizle = 'H'
                   AND wz.account_number = rec_.account_number
                   AND wz.outlet_location = rec_.outlet_location;

            IF v_count = 0 THEN --üzerinde platin paket yoksa giricek
               SELECT TRUNC (MIN (outlet_ac_tarihi))
                 INTO v_outlet_ac_tarihi
                 FROM mb_outlet_takip
                WHERE account_number = rec_.account_number AND outlet_location = rec_.outlet_location;

               v_next_billing_date := bilgi_pack.uye_billing_dx (rec_.account_number, v_outlet_ac_tarihi);

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_svc_history wz,
                      pr_urun_ozellik_tanim pr
                WHERE     wz.account_number = rec_.account_number
                      AND wz.outlet_location = rec_.outlet_location
                      AND wz.add_closed_date < TRUNC (v_next_billing_date) + 1
                      AND wz.drop_date >= TRUNC (v_next_billing_date) + 1
                      AND wz.service_code = pr.urun_kodu
                      AND pr.urun_tipi = 2
                      AND pr.ozellik_kodu = 95;

               IF v_count = 0 THEN --geçmişinde platin servis yoksa
                  IF uye_outlet_suresi (rec_.account_number, rec_.outlet_location) >= 8 --üye 8.ayını doldurduysa
                                                                                       THEN
                     addressability_pack.dbs_activate_on_air (rec_.account_number,
                                                              rec_.outlet_location,
                                                              'PC1',
                                                              'GPM',
                                                              'CME',
                                                              SYSDATE,
                                                              'SYSTEM',
                                                              o_durum,
                                                              o_return_status,
                                                              o_return_code,
                                                              o_bitis_tarih,
                                                              o_aciklama,
                                                              o_id,
                                                              'DBS'
                                                             );

                     IF o_durum = '0' THEN
                        COMMIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      /*** </END - 25.12.2013> ***/

      END LOOP;

      /**** Mesut Keçecioglu 01.08.2012 - <BEGIN> ****/
      FOR rec_2
         IN (SELECT x.account_number, x.outlet_location
               FROM dbs_addr_on_air_activation x
              WHERE     x.gerceklesen_acilma_tarihi > (SYSDATE - 420) -- 12 ayin sonunda PC1 kmp ekleniyor.oyüzden PC1 kmp li üyelerden 14 aylik olanlari aldigimizda 26 aylik bir aralik elde ediyoruz.
                    AND x.campaign_code = 'PC1' --asagida da bize 18 ve 25 aylik olan üyeler lazim oldugu için bu aralik bize yetiyor
                    AND EXISTS
                           (SELECT 1
                              FROM wiz_customer_hp_svc hs
                             WHERE     hs.service_code = 'BSL'
                                   AND hs.account_number = x.account_number
                                   AND hs.outlet_location = x.outlet_location
                                   AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                            UNION
                            SELECT 1
                              FROM dt_dbs_int_dba.vv_uye_ittp_servisler hs
                             WHERE     hs.service_code = 'BSL'
                                   AND hs.account_number = x.account_number
                                   AND hs.outlet_location = x.outlet_location
                                   AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
                    AND NOT EXISTS
                               (SELECT 1
                                  FROM wiz_customer_hp_svc y
                                 WHERE     y.account_number = x.account_number
                                       AND y.outlet_location = x.outlet_location
                                       AND y.service_code IN (SELECT COLUMN_VALUE AS service_code
                                                                FROM TABLE (split_table_fnc (dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))
                                                              UNION ALL
                                                              SELECT pr.urun_kodu AS service_code
                                                                FROM pr_urun_ozellik_tanim pr
                                                               WHERE pr.urun_tipi = 2 AND pr.ozellik_kodu = 95 AND pr.listeden_gizle = 'H')
                                       AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                UNION
                                (SELECT 1
                                   FROM dt_dbs_int_dba.vv_uye_ittp_servisler y
                                  WHERE     y.account_number = x.account_number
                                        AND y.outlet_location = x.outlet_location
                                        AND y.service_code <> 'BSL'
                                        AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')))) /*   AND NOT EXISTS
                                                                                                                                              (SELECT 1
                                                                                                                                                 FROM wiz_customer_hp_svc y
                                                                                                                                                WHERE     y.account_number =
                                                                                                                                                             x.account_number
                                                                                                                                                      AND y.outlet_location =
                                                                                                                                                             x.outlet_location
                                                                                                                                                      AND y.service_code <> 'BSL')) */
                                                                                                                                -- Yukardaki sorgu ile değiştirildi
       LOOP
         IF hos_paket_uyesi_mi (rec_2.account_number, rec_2.outlet_location, 'E') IS NOT NULL THEN
            v_outlet_suresi := uye_outlet_suresi (rec_2.account_number, rec_2.outlet_location);

            IF v_outlet_suresi >= 18 AND v_outlet_suresi < 19 THEN
               --v_servisler(1) =  BLG    v_kampanyalar(1) = TM1
               --v_servilser(2) = TSO    v_kampanyalar(2) = TM3
               --v_servilser(3) = COC    v_kampanyalar(3) = TM2
               --v_servisler(4) = HBR    v_kampanyalar(4) = TM4
               --v_servisler(5) = YSM   v_kampanyalar(5) = TM5

               v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

               FOR i IN v_servisler.FIRST .. v_servisler.LAST LOOP
                  IF v_ittp_order_int_open = 0 THEN
                     SELECT COUNT (*)
                       INTO v_count
                       FROM dbs_addr_on_air_activation ac
                      WHERE ac.account_number = rec_2.account_number AND ac.outlet_location = rec_2.outlet_location AND ac.service_code = v_servisler (i);
                  ELSIF v_ittp_order_int_open = 1 THEN
                     SELECT COUNT (*)
                       INTO v_count
                       FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan ac
                      WHERE ac.account_number = rec_2.account_number AND ac.outlet_location = rec_2.outlet_location AND ac.service_code = v_servisler (i);
                  END IF;

                  IF v_count = 0 THEN
                     addressability_pack.dbs_activate_on_air (rec_2.account_number,
                                                              rec_2.outlet_location,
                                                              v_kampanyalar (i),
                                                              v_servisler (i),
                                                              'CME',
                                                              SYSDATE,
                                                              'SYSTEM',
                                                              o_durum,
                                                              o_return_status,
                                                              o_return_code,
                                                              o_bitis_tarih,
                                                              o_aciklama,
                                                              o_id,
                                                              'DBS'
                                                             );

                     IF o_durum = '0' THEN
                        COMMIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  END IF;
               END LOOP;
            ELSIF v_outlet_suresi >= 24 AND v_outlet_suresi < 25 THEN
               j := 1;

               LOOP
                  IF v_ittp_order_int_open = 0 THEN
                     SELECT COUNT (*)
                       INTO v_count
                       FROM dbs_addr_on_air_activation ac
                      WHERE ac.account_number = rec_2.account_number AND ac.outlet_location = rec_2.outlet_location AND ac.service_code = v_servisler (j);
                  ELSIF v_ittp_order_int_open = 1 THEN
                     SELECT COUNT (*)
                       INTO v_count
                       FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan ac
                      WHERE ac.account_number = rec_2.account_number AND ac.outlet_location = rec_2.outlet_location AND ac.service_code = v_servisler (j);
                  END IF;

                  IF v_count = 0 THEN
                     addressability_pack.dbs_activate_on_air (rec_2.account_number,
                                                              rec_2.outlet_location,
                                                              v_servisler (j),
                                                              v_kampanyalar (j),
                                                              'CME',
                                                              SYSDATE,
                                                              'SYSTEM',
                                                              o_durum,
                                                              o_return_status,
                                                              o_return_code,
                                                              o_bitis_tarih,
                                                              o_aciklama,
                                                              o_id,
                                                              'DBS'
                                                             );

                     IF o_durum = '0' THEN
                        COMMIT;
                     ELSE
                        ROLLBACK;
                     END IF;
                  END IF;

                  j := j + 1;
                  EXIT WHEN j > 2;
               END LOOP;
            END IF;
         END IF;
      END LOOP;
   /**** Mesut Keçecioglu </END>****/
   END;

   /*--- Evren --- 20101013 --- end ---*/
   /*--- Evren --- 20101109 --- begin ---*/

   PROCEDURE uye_digivipclup_islem IS
      odigivip_type      NUMBER;
      oozelmt            VARCHAR2 (100);
      odurum             VARCHAR2 (500);
      osegment_deger     VARCHAR2 (50);
      vdigivip_type      NUMBER;
      vozelmt            VARCHAR2 (100);
      vsegment_deger     VARCHAR2 (50);
      vsegment_deger_kod NUMBER;
      vcount             NUMBER;

      CURSOR get_accounts  IS
         SELECT   account_number
             FROM wiz_customer_hp_life
         ORDER BY account_number;

      CURSOR get_tck_accounts (p_account_number NUMBER) IS
         SELECT   account_number
             FROM (SELECT account_number
                     FROM mb_abone_detay_bilgi mb
                    WHERE     EXISTS
                                 (SELECT tc_kimlik_no, tc_kimlik_no_gecerli
                                    FROM mb_abone_detay_bilgi m
                                   WHERE account_number = p_account_number AND mb.tc_kimlik_no = m.tc_kimlik_no AND m.tc_kimlik_no_gecerli = 'V')
                          AND mb.tc_kimlik_no_gecerli = 'V'
                   UNION
                   SELECT p_account_number FROM DUAL) x
            WHERE    EXISTS
                        (SELECT 1
                           FROM mb_outlet_takip y
                          WHERE x.account_number = y.account_number AND y.outlet_in_tarihi IS NULL)
                  OR EXISTS
                        (SELECT 1
                           FROM mb_abone_statu y
                          WHERE x.account_number = y.account_number AND y.statu = 'K')
         ORDER BY account_number DESC;
   BEGIN
      FOR rec_ IN get_accounts LOOP
         odurum             := '0';
         vdigivip_type      := 0;
         vozelmt            := NULL;
         vsegment_deger_kod := NULL;

         FOR rec2_ IN get_tck_accounts (rec_.account_number) LOOP
            FOR rec3_ IN (SELECT   DECODE (segment_kod, 15, segment_deger_kod, NULL) AS segment_deger_kod
                              FROM vv_uye_segment
                             WHERE account_number = rec2_.account_number AND (segment_kod = 15 OR segment_deger_kod IN (113, 114))
                          ORDER BY segment_kod DESC,
                                   segment_deger_kod) LOOP
               IF vdigivip_type = 0 THEN
                  SELECT COUNT (1)
                    INTO vcount
                    FROM mb_abone_ozellik
                   WHERE account_number = rec2_.account_number AND abone_ozellik_kodu IN (221, 222);

                  -- diger TCK li acc lar için CIP varsa DVC dir CIP yoksa sadece o acc için platin warsa DVC tir
                  -- seklinde düzenlenecek ise asagidaki kod geçerli olacaktir.

                  --IF    (vdigivip_type = 0 AND rec3_.segment_deger_kod IS NOT NULL)
                  --   OR (    vdigivip_type = 0
                  --       AND rec3_.segment_deger_kod IS NULL
                  --       AND rec2_.account_number = rec_.account_number
                  --       AND vcount = 0
                  --      )THEN
                  IF rec3_.segment_deger_kod IS NOT NULL OR (rec3_.segment_deger_kod IS NULL AND vcount = 0) THEN
                     vdigivip_type := 1;
                  END IF;
               END IF;

               IF vsegment_deger_kod IS NULL AND rec3_.segment_deger_kod IS NOT NULL THEN
                  vsegment_deger_kod := rec3_.segment_deger_kod;
               END IF;

               IF vdigivip_type > 0 AND vsegment_deger_kod IS NOT NULL THEN
                  EXIT;
               END IF;
            END LOOP;

            IF vozelmt IS NULL THEN
               BEGIN
                  SELECT x.ozellik_degeri
                    INTO vozelmt
                    FROM mb_abone_ozellik x
                   WHERE x.account_number = rec2_.account_number AND x.abone_ozellik_kodu = 174;
               EXCEPTION
                  WHEN OTHERS THEN
                     vozelmt := NULL;
               END;
            END IF;

            IF vdigivip_type > 0 AND vsegment_deger_kod IS NOT NULL AND vozelmt IS NOT NULL THEN
               EXIT;
            END IF;
         END LOOP;

         SELECT COUNT (1)
           INTO vcount
           FROM mb_abone_ozellik x
          WHERE x.account_number = rec_.account_number AND x.abone_ozellik_kodu = 210;

         IF vcount > 0 AND vdigivip_type = 0 THEN
            abone_detay_pack.mb_abone_ozellik_delete (rec_.account_number, NULL, 210, 'SYSTEM', odurum);

            IF odurum <> '0' THEN
               ROLLBACK;
               insert_log ('abone_detay_pack.mb_abone_ozellik_delete - ' || rec_.account_number || ' - ' || '210');
            END IF;
         ELSIF vcount = 0 AND vdigivip_type > 0 THEN
            abone_detay_pack.mb_abone_ozellik_insert (rec_.account_number, NULL, 210, 'SYSTEM', odurum);

            IF odurum <> '0' THEN
               ROLLBACK;
               insert_log ('abone_detay_pack.mb_abone_ozellik_insert - ' || rec_.account_number || ' - ' || '210');
            END IF;
         END IF;

         vcount             := 0;

         FOR rec2_ IN (SELECT segment_deger_kod
                         FROM vv_uye_segment
                        WHERE account_number = rec_.account_number AND segment_kod = 15) LOOP
            IF vsegment_deger_kod IS NULL OR vsegment_deger_kod <> rec2_.segment_deger_kod THEN
               abone_detay_pack.mb_abone_ozellik_delete (rec_.account_number, NULL, rec2_.segment_deger_kod, 'SYSTEM', odurum);

               IF odurum <> '0' THEN
                  ROLLBACK;
                  insert_log ('abone_detay_pack.mb_abone_ozellik_delete - ' || rec_.account_number || ' - ' || rec2_.segment_deger_kod);
               END IF;
            ELSIF vsegment_deger_kod = rec2_.segment_deger_kod THEN
               vcount := 1;
            END IF;
         END LOOP;

         IF vcount = 0 AND vsegment_deger_kod IS NOT NULL THEN
            abone_detay_pack.mb_abone_ozellik_insert (rec_.account_number, NULL, vsegment_deger_kod, 'SYSTEM', odurum);

            IF odurum <> '0' THEN
               ROLLBACK;
               insert_log ('abone_detay_pack.mb_abone_ozellik_insert - ' || rec_.account_number || ' - ' || vsegment_deger_kod);
            END IF;
         END IF;

         BEGIN
            SELECT ozellik_degeri
              INTO oozelmt
              FROM mb_abone_ozellik
             WHERE abone_ozellik_kodu = 174 AND account_number = rec_.account_number;
         EXCEPTION
            WHEN OTHERS THEN
               oozelmt := NULL;
         END;

         IF NVL (oozelmt, '$$$') <> NVL (vozelmt, '$$$') THEN
            IF oozelmt IS NOT NULL THEN
               abone_detay_pack.mb_abone_ozellik_delete (rec_.account_number, NULL, 174, 'SYSTEM', odurum);

               IF odurum <> '0' THEN
                  ROLLBACK;
                  insert_log ('abone_detay_pack.mb_abone_ozellik_delete - ' || rec_.account_number || ' - ' || '174');
               END IF;
            END IF;

            IF vozelmt IS NOT NULL THEN
               abone_detay_pack.mb_abone_ozellik_insert (rec_.account_number, NULL, 174, 'SYSTEM', odurum, vozelmt);

               IF odurum <> '0' THEN
                  ROLLBACK;
                  insert_log ('abone_detay_pack.mb_abone_ozellik_insert - ' || rec_.account_number || ' - ' || '174');
               END IF;
            END IF;
         END IF;

         COMMIT;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         insert_log ('uye_digivipclup_islem : ' || SQLERRM);
   END uye_digivipclup_islem;

   /*--- Evren --- 20101109 --- end ---*/
   /*--- Evren --- 20101129 --- begin ---*/

   PROCEDURE toplu_abone_ozellik_islem (in_islem_id IN tm_dss_dbs_abone_ozellik.islem_id%TYPE, in_ozellik_kodu IN VARCHAR2) IS
      CURSOR get_accounts_delete  IS
         SELECT z.account_number, z.outlet_location, z.abone_ozellik_kodu ozellik_kodu
           FROM dbs_dba.mb_abone_ozellik z
          WHERE     z.abone_ozellik_kodu = in_ozellik_kodu
                AND NOT EXISTS
                           (SELECT 1
                              FROM dbs_dba.tm_dss_dbs_abone_ozellik x
                             WHERE     x.islem_id = in_islem_id
                                   AND x.account_number = z.account_number
                                   AND NVL (x.outlet_location, 'XXX') = NVL (z.outlet_location, 'XXX')
                                   AND x.ozellik_kodu = z.abone_ozellik_kodu
                                   AND NVL (x.ozellik_degeri, 'XXX') = NVL (z.ozellik_degeri, 'XXX'));

      --      CURSOR get_accounts_delete
      --      IS
      --         SELECT /*+ use_nl(t z)*/
      --               z.account_number,
      --                z.outlet_location,
      --                z.abone_ozellik_kodu ozellik_kodu
      --           FROM dbs_dba.mb_abone_ozellik z,
      --                TABLE (split_table_fnc (in_ozellik_kodu)) t
      --          WHERE     t.COLUMN_VALUE = z.abone_ozellik_kodu
      --                AND NOT EXISTS
      --                           (SELECT 1
      --                              FROM dbs_dba.tm_dss_dbs_abone_ozellik x
      --                             WHERE     x.islem_id = in_islem_id
      --                                   AND x.account_number = z.account_number
      --                                   AND NVL (x.outlet_location, 'XXX') =
      --                                          NVL (z.outlet_location, 'XXX')
      --                                   AND x.ozellik_kodu = z.abone_ozellik_kodu
      --                                   AND NVL (x.ozellik_degeri, 'XXX') =
      --                                          NVL (z.ozellik_degeri, 'XXX'));

      --      CURSOR get_accounts_insert
      --      IS
      --         SELECT x.account_number, x.OUTLET_LOCATION, x.ozellik_kodu, x.ozellik_degeri
      --           FROM dbs_dba.tm_dss_dbs_abone_ozellik x,
      --                TABLE (split_table_fnc (in_ozellik_kodu)) t,
      --                mb_abone_ozellik z
      --          WHERE x.islem_id = in_islem_id
      --            AND t.COLUMN_VALUE = x.ozellik_kodu
      --            AND x.account_number = z.account_number(+)
      --            AND x.ozellik_kodu = z.abone_ozellik_kodu(+)
      --            AND z.account_number IS NULL;
      --      CURSOR get_accounts_insert  IS
      --         SELECT x.account_number, x.outlet_location, x.ozellik_kodu, x.ozellik_degeri
      --           FROM dbs_dba.tm_dss_dbs_abone_ozellik x
      --          WHERE     x.islem_id = in_islem_id
      --                AND NOT EXISTS
      --                           (SELECT 1
      --                              FROM mb_abone_ozellik z,
      --                                   TABLE (split_table_fnc (in_ozellik_kodu)) t
      --                             WHERE     x.account_number = z.account_number
      --                                   AND NVL (x.outlet_location, 'XXX') = NVL (z.outlet_location, 'XXX')
      --                                   AND t.COLUMN_VALUE = z.abone_ozellik_kodu);

      CURSOR get_accounts_insert  IS
         SELECT x.account_number, x.outlet_location, x.ozellik_kodu, x.ozellik_degeri
           FROM dbs_dba.tm_dss_dbs_abone_ozellik x
          WHERE     x.islem_id = in_islem_id
                AND NOT EXISTS
                           (SELECT 1
                              FROM mb_abone_ozellik z
                             WHERE     x.account_number = z.account_number
                                   AND NVL (x.outlet_location, 'XXX') = NVL (z.outlet_location, 'XXX')
                                   AND z.abone_ozellik_kodu = in_ozellik_kodu);

      odurum VARCHAR2 (2000);
   BEGIN
      INSERT INTO tm_dss_dbs_abone_ozellik_lg (islem_id, ozellik_kodu, islem_tarihi)
           VALUES (in_islem_id, in_ozellik_kodu, SYSDATE);

      FOR rec_ IN get_accounts_delete LOOP
         abone_detay_pack.mb_abone_ozellik_delete (rec_.account_number, rec_.outlet_location, rec_.ozellik_kodu, 'SYSTEM', odurum);

         IF odurum <> '0' THEN
            ROLLBACK;
            insert_log ('abone_detay_pack.mb_abone_ozellik_delete - ' || rec_.account_number || ' - ' || rec_.ozellik_kodu || ' - ' || SUBSTR (odurum, 1, 100));
         ELSE
            COMMIT;
         END IF;
      END LOOP;

      FOR rec_ IN get_accounts_insert LOOP
         abone_detay_pack.mb_abone_ozellik_insert (rec_.account_number, rec_.outlet_location, rec_.ozellik_kodu, 'SYSTEM', odurum, rec_.ozellik_degeri);

         IF odurum <> '0' THEN
            ROLLBACK;
            insert_log ('abone_detay_pack.mb_abone_ozellik_insert - ' || rec_.account_number || ' - ' || rec_.ozellik_kodu || ' - ' || SUBSTR (odurum, 1, 100));
         ELSE
            COMMIT;
         END IF;
      END LOOP;
   END;

   /*--- Evren --- 20101129 --- end ---*/
   /*--- Evren --- 20110425 --- begin ---*/

   PROCEDURE brand_degisikligi_kapat IS
      v_ittp_order_int_open NUMBER;

      CURSOR get_data  IS
         SELECT DISTINCT uye_no, eski_service_address_id, yeni_stb_tipi
           FROM ie_adres_degisikligi
          WHERE     durum = 'O'
                AND giris_tarihi >
                       (CASE
                           WHEN TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -1)) + 4 > SYSDATE THEN TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -2)) + 4
                           ELSE TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -1)) + 4
                        END)
                AND NVL (eski_stb_tipi, 1) <> NVL (yeni_stb_tipi, 1);

      CURSOR get_servis_detay (
         p_account_no  wiz_customer_hp_life.account_number%TYPE) IS
         SELECT x.uye_no, x.eski_outlet_location, y.*
           FROM ie_adres_degisikligi x,
                ie_adres_degisikligi_detay y
          WHERE     x.id = y.adres_degisikligi_id
                AND x.uye_no = p_account_no
                AND y.detay_tipi = 4
                AND y.transfer_mi <> 'E'
                AND x.durum = 'O'
                AND x.giris_tarihi >
                       (CASE
                           WHEN TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -1)) + 4 > SYSDATE THEN TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -2)) + 4
                           ELSE TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -1)) + 4
                        END)
                AND NVL (x.eski_stb_tipi, 1) <> NVL (x.yeni_stb_tipi, 1);

      CURSOR get_ekipman_detay (
         p_account_no  wiz_customer_hp_life.account_number%TYPE) IS
         SELECT x.uye_no, x.eski_outlet_location, y.*
           FROM ie_adres_degisikligi x,
                ie_adres_degisikligi_detay y
          WHERE     x.id = y.adres_degisikligi_id
                AND x.uye_no = p_account_no
                AND y.detay_tipi <> 4
                AND x.durum = 'O'
                AND x.giris_tarihi >
                       (CASE
                           WHEN TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -1)) + 4 > SYSDATE THEN TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -2)) + 4
                           ELSE TRUNC (ADD_MONTHS (LAST_DAY (SYSDATE), -1)) + 4
                        END)
                AND NVL (x.eski_stb_tipi, 1) <> NVL (x.yeni_stb_tipi, 1)
                AND y.kampanya_kodu IS NOT NULL;

      o_id                  NUMBER;
      o_kod                 VARCHAR2 (2000);
      o_mesaj               VARCHAR2 (2000);
      v_count               NUMBER;
      out_tahsilat_durum    NUMBER;
      out_kayit_sayisi      NUMBER;
      out_tahsilat_id       NUMBER;
      out_icr_dp_code       NUMBER;
      out_tahsilat_info     VARCHAR2 (500);
      out_default_kk_no     VARCHAR2 (500);
      out_def_kk_expdate    DATE;
      out_default_isim      VARCHAR2 (500);
      out_warn_message      VARCHAR2 (500);
      out_kk_talimat        VARCHAR2 (500);
      out_cvv2              VARCHAR2 (500);
      o_durum               VARCHAR2 (2000);
      v_max_count           NUMBER;
      v_max_tmp             NUMBER;
   BEGIN
      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      FOR rec IN get_data LOOP
         o_durum            := '0';
         out_tahsilat_durum := 0;
         v_max_count        := 0;

         SELECT COUNT (1)
           INTO v_count
           FROM ie_adres_degisikligi
          WHERE uye_no = rec.uye_no AND durum = 'O' AND NVL (eski_stb_tipi, 1) <> NVL (yeni_stb_tipi, 1);

         FOR rec2 IN (SELECT   account_number, outlet_location
                          FROM (SELECT account_number, outlet_location FROM wiz_equip
                                UNION
                                SELECT account_number, outlet_location
                                  FROM wiz_customer_hp_svc
                                 WHERE 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                UNION
                                SELECT account_number, outlet_location
                                  FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                                 WHERE 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                UNION
                                SELECT account_no AS account_number, outlet_location FROM dp_account_no
                                UNION
                                SELECT account_number, outlet_location FROM mb_abone_statu
                                UNION
                                SELECT account_number, outlet_location FROM eq_ekipman) a
                         WHERE account_number = rec.uye_no
                      GROUP BY account_number,
                               outlet_location) LOOP
            SELECT COUNT (1)
              INTO v_max_tmp
              FROM mb_abone_statu
             WHERE account_number = rec2.account_number AND outlet_location = rec2.outlet_location AND statu = 'T';

            IF v_max_tmp = 0 THEN
               v_max_count := v_max_count + 1;
            END IF;
         END LOOP;

         IF v_count <> v_max_count THEN
            ROLLBACK;
            insert_log ('brand_degisikligi_kapat - ' || rec.uye_no || ' - Tüm Outletler Için Brand Degisiklik Kaydi Girilmelidir!...');
         ELSE
            UPDATE ie_adres_degisikligi
               SET durum = 'C', reason_code = 'TUT'
             WHERE uye_no = rec.uye_no AND durum = 'O' AND NVL (eski_stb_tipi, 1) <> NVL (yeni_stb_tipi, 1);

            outlet_transfer.close_stb_transfer (rec.uye_no, 'SYSTEM', 'CSR', o_durum);

            IF o_durum <> '0' THEN
               ROLLBACK;
               insert_log ('brand_degisikligi_kapat - outlet_transfer.close_stb_transfer - ' || rec.uye_no || ' - ' || SUBSTR (o_durum, 1, 100));
            ELSE
               FOR srv_rec IN get_servis_detay (rec.uye_no) LOOP
                  urun_ekle_tahsilat.kk_tahsilat_varmi (srv_rec.uye_no,
                                                        srv_rec.eski_outlet_location,
                                                        srv_rec.servis,
                                                        srv_rec.kampanya_kodu,
                                                        srv_rec.servis_frekansi,
                                                        SYSDATE,
                                                        'SYSTEM',
                                                        out_tahsilat_durum,
                                                        out_kayit_sayisi,
                                                        out_tahsilat_id,
                                                        out_icr_dp_code,
                                                        out_tahsilat_info,
                                                        out_default_kk_no,
                                                        out_def_kk_expdate,
                                                        out_default_isim,
                                                        out_warn_message,
                                                        out_kk_talimat,
                                                        o_durum
                                                       );

                  IF out_tahsilat_durum = 1 THEN
                     ROLLBACK;
                     insert_log ('brand_degisikligi_kapat - kk tahsilatli servis var - ' || srv_rec.uye_no || ' - ' || srv_rec.servis);
                     EXIT;
                  ELSIF o_durum <> '0' THEN
                     ROLLBACK;
                     insert_log (
                        'brand_degisikligi_kapat - kk tahsilat hata - ' || srv_rec.uye_no || ' - ' || srv_rec.servis || ' - ' || SUBSTR (o_durum, 1, 100));
                     EXIT;
                  END IF;
               END LOOP;

               IF out_tahsilat_durum <> 1 AND o_durum = '0' THEN
                  FOR ekp_rec IN get_ekipman_detay (rec.uye_no) LOOP
                     urun_ekle_tahsilat.ekipman_kk_tahsilat_varmi (ekp_rec.uye_no,
                                                                   ekp_rec.eski_outlet_location,
                                                                   ekp_rec.serial_number,
                                                                   SYSDATE,
                                                                   'SYSTEM',
                                                                   out_tahsilat_durum,
                                                                   out_kayit_sayisi,
                                                                   out_tahsilat_id,
                                                                   out_tahsilat_info,
                                                                   out_default_kk_no,
                                                                   out_def_kk_expdate,
                                                                   out_cvv2,
                                                                   out_default_isim,
                                                                   out_warn_message,
                                                                   out_kk_talimat,
                                                                   o_durum
                                                                  );

                     IF out_tahsilat_durum = 1 THEN
                        ROLLBACK;
                        insert_log ('brand_degisikligi_kapat - kk tahsilatli ekipman var - ' || ekp_rec.uye_no || ' - ' || ekp_rec.serial_number);
                        EXIT;
                     ELSIF o_durum <> '0' THEN
                        ROLLBACK;
                        insert_log (
                              'brand_degisikligi_kapat - kk tahsilat hata - '
                           || ekp_rec.uye_no
                           || ' - '
                           || ekp_rec.serial_number
                           || ' - '
                           || SUBSTR (o_durum, 1, 100));
                        EXIT;
                     END IF;
                  END LOOP;

                  IF out_tahsilat_durum <> 1 AND o_durum = '0' THEN
                     COMMIT;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
   END;

   /*--- Evren --- 20110425 --- end ---*/

   /*Yazan      :tunahan akbulut/mustafa temiz.
           Tarih      :18.07.2011
           Aciklama   :günlük olarak çalisir
           TFSWorkNo  :15663
           F01-F02 NOR AC TEK OUTLETE SAHIP, CEP TELEFON BILGISI OLDUGU HALDE ÜZERINDE REGISTER TEKEFON KAYDI BULUNMAYIP,  CEP TEL BILGISI BASKA BIR "AC" UYEDE OLMAYANLARA
           ILGILI CEP TELEFONU REGISTER EDILIYOR.*/

   PROCEDURE set_registerphone_daily IS
      v_out_sonuc_tip      NUMBER (10);
      v_out_sonuc_kod      VARCHAR2 (2000);
      v_out_sonuc_cevap    VARCHAR2 (2000);
      v_out_sonuc_aciklama VARCHAR2 (2000);
      v_count              NUMBER (10) := 1;

      CURSOR cur  IS
         SELECT a.account_number
           FROM wiz_customer_hp_life a
          WHERE     a.franchise_code IN ('F01', 'F02')
                AND a.customer_status = 'AC'
                AND a.customer_type = 'NOR'
                AND EXISTS
                       (SELECT   *
                            FROM mb_outlet_takip b
                           WHERE b.outlet_in_tarihi IS NULL AND a.account_number = b.account_number
                        GROUP BY b.account_number
                          HAVING COUNT (*) = 1)
                AND NOT EXISTS
                       (SELECT *
                          FROM mb_abone_telefon_register b
                         WHERE a.account_number = b.account_number AND b.listeden_gizle = 'H')
                AND EXISTS
                       (SELECT *
                          FROM mb_abone_telefon b
                         WHERE     a.account_number = b.account_number
                               AND b.telefon_tipi = 3
                               AND b.durum = 1
                               AND b.ulke_kodu = '90'
                               AND NOT EXISTS
                                          (SELECT *
                                             FROM mb_abone_telefon c,
                                                  wiz_customer_hp_life e
                                            WHERE     c.telefon_tipi = 3
                                                  AND c.durum = 1
                                                  AND c.account_number <> b.account_number
                                                  AND b.ulke_kodu = c.ulke_kodu
                                                  AND b.alan_kodu = c.alan_kodu
                                                  AND b.telefon_no = c.telefon_no
                                                  AND c.account_number = e.account_number
                                                  AND e.customer_status = 'AC'));
   BEGIN
      FOR rec IN cur LOOP
         FOR rec1
            IN (SELECT *
                  FROM mb_abone_telefon a
                 WHERE     account_number = rec.account_number
                       AND telefon_tipi = 3
                       AND durum = 1
                       AND ulke_kodu = '90'
                       AND NOT EXISTS
                                  (SELECT *
                                     FROM mb_abone_telefon b,
                                          wiz_customer_hp_life e
                                    WHERE     b.telefon_tipi = 3
                                          AND b.durum = 1
                                          AND b.account_number <> rec.account_number
                                          AND a.ulke_kodu = b.ulke_kodu
                                          AND a.alan_kodu = b.alan_kodu
                                          AND a.telefon_no = b.telefon_no
                                          AND b.account_number = e.account_number
                                          AND e.customer_status = 'AC')) LOOP
            abone_telefon_pack.abone_telefon_register_id (rec.account_number,
                                                          NULL,
                                                          rec1.id,
                                                          'SYSTEM',
                                                          v_out_sonuc_tip,
                                                          v_out_sonuc_kod,
                                                          v_out_sonuc_cevap,
                                                          v_out_sonuc_aciklama
                                                         );

            IF v_out_sonuc_tip = 0 THEN
               COMMIT;
               v_count := v_count + 1;
               EXIT;
            ELSE
               ROLLBACK;
            END IF;
         END LOOP;
      END LOOP;
   END;

   PROCEDURE kampanya_yenileme IS
      durum                 BOOLEAN;
      v_count               NUMBER;
      odurum                VARCHAR2 (2000);
      v_service_code_1      VARCHAR2 (3);
      v_campaign_code_1     VARCHAR2 (3);
      v_service_frequence_1 VARCHAR2 (1);
      v_service_code_2      VARCHAR2 (3);
      v_campaign_code_2     VARCHAR2 (3);
      v_service_frequence_2 VARCHAR2 (1);
      v_service_code_3      VARCHAR2 (3);
      v_campaign_code_3     VARCHAR2 (3);
      v_service_frequence_3 VARCHAR2 (1);
      v_service_code_4      VARCHAR2 (3);
      v_campaign_code_4     VARCHAR2 (3);
      v_service_frequence_4 VARCHAR2 (1);
      v_service_code_5      VARCHAR2 (3);
      v_campaign_code_5     VARCHAR2 (3);
      v_service_frequence_5 VARCHAR2 (1);
      v_service_code_6      VARCHAR2 (3);
      v_campaign_code_6     VARCHAR2 (3);
      v_service_frequence_6 VARCHAR2 (1);
      v_ittp_order_int_open NUMBER;
   BEGIN
      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      FOR rec
         IN (SELECT   *
                 FROM pr_kampanya_yenileme ky
                WHERE ky.listeden_gizle = 'H' AND ky.islem_tipi = 1 AND ky.baslangic_tarihi <= SYSDATE AND (ky.bitis_tarihi > SYSDATE OR ky.bitis_tarihi IS NULL)
             ORDER BY id) LOOP
         FOR rec2 IN (SELECT   *
                          FROM pr_kampanya_yenileme_detay kyd
                         WHERE kyd.tip = 1 AND kyd.kampanya_yenileme_id = rec.id
                      ORDER BY id) LOOP
            FOR rec3
               IN ( ( (SELECT account_number, outlet_location, service_code, campaign_code, servis_frekansi
                         FROM prod_dba.wiz_customer_hp_svc wz
                        WHERE     wz.non_standard_service_rate = -9999999.99
                              AND (wz.service_code = rec2.paket OR rec2.paket IS NULL)
                              AND (wz.servis_frekansi = rec2.frekans OR rec2.frekans IS NULL)
                              AND (   DECODE (
                                         TRIM (wz.promotion_code),
                                         NULL, wz.campaign_code,
                                         DECODE (SIGN (TRUNC (wz.promo_expire_date) - TRUNC (SYSDATE) - DECODE (rec2.kampanya, 'KMP', 1, 0)),
                                                 1, wz.campaign_code,
                                                 'KMP'
                                                )) = rec2.kampanya
                                   OR rec2.kampanya IS NULL)
                              AND (   (TRUNC (wz.promo_expire_date) = TRUNC (SYSDATE) + 1 AND wz.servis_frekansi = '1')
                                   OR (    TRUNC (wz.promo_expire_date) = TRUNC (SYSDATE) + 1
                                       AND wz.servis_frekansi <> '1'
                                       AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1)
                                   OR (TRIM (wz.promotion_code) IS NULL AND wz.servis_frekansi = '1' AND TO_NUMBER (TO_CHAR (TRUNC (SYSDATE) + 1, 'DD')) = 3)
                                   OR (TRIM (wz.promotion_code) IS NULL AND wz.servis_frekansi <> '1' AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1))
                              AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
                     UNION
                     (SELECT account_number, outlet_location, service_code, campaign_code, TO_CHAR (servis_frekansi)
                        FROM dt_dbs_int_dba.vv_uye_ittp_servisler wz
                       WHERE     wz.non_standard_service_rate = -9999999.99
                             AND (wz.service_code = rec2.paket OR rec2.paket IS NULL)
                             AND (wz.servis_frekansi = rec2.frekans OR rec2.frekans IS NULL)
                             AND (   DECODE (
                                        TRIM (wz.promotion_code),
                                        NULL, wz.campaign_code,
                                        DECODE (SIGN (TRUNC (wz.pdate) - TRUNC (SYSDATE) - DECODE (rec2.kampanya, 'KMP', 1, 0)), 1, wz.campaign_code, 'KMP')) =
                                        rec2.kampanya
                                  OR rec2.kampanya IS NULL)
                             AND (   (TRUNC (wz.pdate) = TRUNC (SYSDATE) + 1 AND wz.servis_frekansi = '1')
                                  OR (    TRUNC (wz.pdate) = TRUNC (SYSDATE) + 1
                                      AND wz.servis_frekansi <> '1'
                                      AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1)
                                  OR (TRIM (wz.promotion_code) IS NULL AND wz.servis_frekansi = '1' AND TO_NUMBER (TO_CHAR (TRUNC (SYSDATE) + 1, 'DD')) = 3)
                                  OR (TRIM (wz.promotion_code) IS NULL AND wz.servis_frekansi <> '1' AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1)) --AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                                                                                                                                              ))) LOOP
               --               IF v_ittp_order_int_open = 0 THEN
               --                  SELECT COUNT (*)
               --                    INTO v_count
               --                    FROM wiz_wo_line_items wol,
               --                         wiz_work_order wo
               --                   WHERE     wol.work_order_number = wo.work_order_number
               --                         AND wo.account_number = rec3.account_number
               --                         AND wol.outlet_location = rec3.outlet_location
               --                         AND wol.wo_status = 'O'
               --                         AND wo.wo_status IN ('O', 'P')
               --                         AND wol.service_code = rec3.service_code
               --                         AND wol.campaign_code = rec3.campaign_code
               --                         AND wol.servis_frekansi = rec3.servis_frekansi;
               --ELSIF v_ittp_order_int_open = 1 THEN
               SELECT COUNT (*)
                 INTO v_count
                 FROM dt_dbs_int_dba.vv_ittp_customer_order wo
                WHERE     wo.dbs_outlet_location = rec3.outlet_location
                      AND wo.dbs_account_number = rec3.account_number
                      AND wo.work_order_statu = ('ACIK')
                      AND wo.work_line_statu = ('ACIK')
                      AND wo.service_code = rec3.service_code
                      AND wo.campaign_code = rec3.campaign_code
                      AND wo.servis_frekansi = rec3.servis_frekansi
                      AND wo.havadan_flag = 0;

               --END IF;

               IF v_count = 0 THEN
                  SELECT COUNT (*)
                    INTO v_count
                    FROM mb_abone_statu mb
                   WHERE mb.account_number = rec3.account_number AND mb.outlet_location = rec3.outlet_location AND mb.statu = 'P';

                  IF v_count = 0 THEN
                     durum := TRUE;

                     FOR rec4 IN (SELECT   *
                                      FROM pr_kampanya_yenileme_detay kyd
                                     WHERE kyd.kampanya_yenileme_id = rec.id AND kyd.tip = 1 AND kyd.id <> rec2.id
                                  ORDER BY id) LOOP
                        IF v_ittp_order_int_open = 0 THEN
                           SELECT COUNT (*)
                             INTO v_count
                             FROM prod_dba.wiz_customer_hp_svc wz
                            WHERE     wz.non_standard_service_rate = -9999999.99
                                  AND (wz.service_code = rec4.paket OR rec4.paket IS NULL)
                                  AND (wz.servis_frekansi = rec4.frekans OR rec4.frekans IS NULL)
                                  AND wz.account_number = rec3.account_number
                                  AND wz.outlet_location = rec3.outlet_location
                                  AND (   DECODE (
                                             TRIM (wz.promotion_code),
                                             NULL, wz.campaign_code,
                                             DECODE (SIGN (TRUNC (wz.promo_expire_date) - TRUNC (SYSDATE) - DECODE (rec4.kampanya, 'KMP', 1, 0)),
                                                     1, wz.campaign_code,
                                                     'KMP'
                                                    )) = rec4.kampanya
                                       OR rec4.kampanya IS NULL)
                                  AND (   (TRUNC (wz.promo_expire_date) = TRUNC (SYSDATE) + 1 AND wz.servis_frekansi = '1')
                                       OR (    TRUNC (wz.promo_expire_date) = TRUNC (SYSDATE) + 1
                                           AND wz.servis_frekansi <> '1'
                                           AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1)
                                       OR (    TRIM (wz.promotion_code) IS NULL
                                           AND wz.servis_frekansi = '1'
                                           AND TO_NUMBER (TO_CHAR (TRUNC (SYSDATE) + 1, 'DD')) = 3)
                                       OR (    TRIM (wz.promotion_code) IS NULL
                                           AND wz.servis_frekansi <> '1'
                                           AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1))
                                  AND NOT EXISTS
                                             (SELECT *
                                                FROM wiz_wo_line_items wol,
                                                     wiz_work_order wo
                                               WHERE     wol.work_order_number = wo.work_order_number
                                                     AND wo.account_number = rec3.account_number
                                                     AND wol.outlet_location = rec3.outlet_location
                                                     AND wol.wo_status = 'O'
                                                     AND wo.wo_status IN ('O', 'P')
                                                     AND wol.service_code = wz.service_code
                                                     AND wol.campaign_code = wz.campaign_code
                                                     AND wol.servis_frekansi = wz.servis_frekansi);
                        ELSIF v_ittp_order_int_open = 1 THEN
                           SELECT COUNT (*)
                             INTO v_count
                             FROM dt_dbs_int_dba.vv_uye_ittp_servisler wz
                            WHERE     wz.non_standard_service_rate = -9999999.99
                                  AND (wz.service_code = rec4.paket OR rec4.paket IS NULL)
                                  AND (wz.servis_frekansi = rec4.frekans OR rec4.frekans IS NULL)
                                  AND wz.account_number = rec3.account_number
                                  AND wz.outlet_location = rec3.outlet_location
                                  AND (   DECODE (
                                             TRIM (wz.promotion_code),
                                             NULL, wz.campaign_code,
                                             DECODE (SIGN (TRUNC (wz.pdate) - TRUNC (SYSDATE) - DECODE (rec4.kampanya, 'KMP', 1, 0)),
                                                     1, wz.campaign_code,
                                                     'KMP'
                                                    )) = rec4.kampanya
                                       OR rec4.kampanya IS NULL)
                                  AND (   (TRUNC (wz.pdate) = TRUNC (SYSDATE) + 1 AND wz.servis_frekansi = '1')
                                       OR (    TRUNC (wz.pdate) = TRUNC (SYSDATE) + 1
                                           AND wz.servis_frekansi <> '1'
                                           AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1)
                                       OR (    TRIM (wz.promotion_code) IS NULL
                                           AND wz.servis_frekansi = '1'
                                           AND TO_NUMBER (TO_CHAR (TRUNC (SYSDATE) + 1, 'DD')) = 3)
                                       OR (    TRIM (wz.promotion_code) IS NULL
                                           AND wz.servis_frekansi <> '1'
                                           AND TRUNC (wz.fiyat_bitis_tarihi) = TRUNC (SYSDATE) + 1))
                                  AND NOT EXISTS
                                             (SELECT 1
                                                FROM dt_dbs_int_dba.vv_ittp_customer_order wo
                                               WHERE     wo.dbs_account_number = rec3.account_number
                                                     AND wo.dbs_outlet_location = rec3.outlet_location
                                                     AND wo.work_order_statu = ('ACIK')
                                                     AND wo.work_line_statu = ('ACIK')
                                                     AND wo.service_code = rec3.service_code
                                                     AND wo.campaign_code = rec3.campaign_code
                                                     AND wo.servis_frekansi = rec3.servis_frekansi
                                                     AND wo.havadan_flag = 0);
                        END IF;

                        IF v_count = 0 THEN
                           durum := FALSE;
                           EXIT;
                        END IF;
                     END LOOP;

                     IF durum THEN
                        FOR rec6 IN (SELECT *
                                       FROM pr_kampanya_yenileme_detay kyd
                                      WHERE kyd.tip = 3 AND kyd.kampanya_yenileme_id = rec.id) LOOP
                           IF v_ittp_order_int_open = 0 THEN
                              SELECT COUNT (*)
                                INTO v_count
                                FROM prod_dba.wiz_customer_hp_svc wz
                               WHERE     wz.non_standard_service_rate = -9999999.99
                                     AND (wz.service_code = rec6.paket OR rec6.paket IS NULL)
                                     AND (wz.servis_frekansi = rec6.frekans OR rec6.frekans IS NULL)
                                     AND wz.account_number = rec3.account_number
                                     AND wz.outlet_location = rec3.outlet_location
                                     AND (   DECODE (
                                                TRIM (wz.promotion_code),
                                                NULL, wz.campaign_code,
                                                DECODE (SIGN (TRUNC (wz.promo_expire_date) - TRUNC (SYSDATE) - DECODE (rec6.kampanya, 'KMP', 1, 0)),
                                                        1, wz.campaign_code,
                                                        'KMP'
                                                       )) = rec6.kampanya
                                          OR rec6.kampanya IS NULL);
                           ELSIF v_ittp_order_int_open = 1 THEN
                              SELECT COUNT (*)
                                INTO v_count
                                FROM dt_dbs_int_dba.vv_uye_ittp_servisler wz
                               WHERE     wz.non_standard_service_rate = -9999999.99
                                     AND (wz.service_code = rec6.paket OR rec6.paket IS NULL)
                                     AND (wz.servis_frekansi = rec6.frekans OR rec6.frekans IS NULL)
                                     AND wz.account_number = rec3.account_number
                                     AND wz.outlet_location = rec3.outlet_location
                                     AND (   DECODE (
                                                TRIM (wz.promotion_code),
                                                NULL, wz.campaign_code,
                                                DECODE (SIGN (TRUNC (wz.pdate) - TRUNC (SYSDATE) - DECODE (rec6.kampanya, 'KMP', 1, 0)),
                                                        1, wz.campaign_code,
                                                        'KMP'
                                                       )) = rec6.kampanya
                                          OR rec6.kampanya IS NULL);
                           END IF;

                           IF v_count > 0 THEN
                              durum := FALSE;
                              EXIT;
                           END IF;
                        END LOOP;
                     END IF;

                     IF durum THEN
                        v_count               := 1;
                        v_service_code_1      := NULL;
                        v_campaign_code_1     := NULL;
                        v_service_frequence_1 := NULL;
                        v_service_code_2      := NULL;
                        v_campaign_code_2     := NULL;
                        v_service_frequence_2 := NULL;
                        v_service_code_3      := NULL;
                        v_campaign_code_3     := NULL;
                        v_service_frequence_3 := NULL;
                        v_service_code_4      := NULL;
                        v_campaign_code_4     := NULL;
                        v_service_frequence_4 := NULL;
                        v_service_code_5      := NULL;
                        v_campaign_code_5     := NULL;
                        v_service_frequence_5 := NULL;
                        v_service_code_6      := NULL;
                        v_campaign_code_6     := NULL;
                        v_service_frequence_6 := NULL;

                        FOR rec5 IN (SELECT   *
                                         FROM pr_kampanya_yenileme_detay kyd
                                        WHERE kyd.tip = 2 AND kyd.kampanya_yenileme_id = rec.id
                                     ORDER BY id) LOOP
                           IF v_count = 1 THEN
                              v_service_code_1      := NVL (rec5.paket, rec3.service_code);
                              v_campaign_code_1     := NVL (rec5.kampanya, rec3.campaign_code);
                              v_service_frequence_1 := NVL (rec5.frekans, rec3.servis_frekansi);
                           ELSIF v_count = 2 THEN
                              v_service_code_2      := NVL (rec5.paket, rec3.service_code);
                              v_campaign_code_2     := NVL (rec5.kampanya, rec3.campaign_code);
                              v_service_frequence_2 := NVL (rec5.frekans, rec3.servis_frekansi);
                           ELSIF v_count = 3 THEN
                              v_service_code_3      := NVL (rec5.paket, rec3.service_code);
                              v_campaign_code_3     := NVL (rec5.kampanya, rec3.campaign_code);
                              v_service_frequence_3 := NVL (rec5.frekans, rec3.servis_frekansi);
                           ELSIF v_count = 4 THEN
                              v_service_code_4      := NVL (rec5.paket, rec3.service_code);
                              v_campaign_code_4     := NVL (rec5.kampanya, rec3.campaign_code);
                              v_service_frequence_4 := NVL (rec5.frekans, rec3.servis_frekansi);
                           ELSIF v_count = 5 THEN
                              v_service_code_5      := NVL (rec5.paket, rec3.service_code);
                              v_campaign_code_5     := NVL (rec5.kampanya, rec3.campaign_code);
                              v_service_frequence_5 := NVL (rec5.frekans, rec3.servis_frekansi);
                           ELSIF v_count = 6 THEN
                              v_service_code_6      := NVL (rec5.paket, rec3.service_code);
                              v_campaign_code_6     := NVL (rec5.kampanya, rec3.campaign_code);
                              v_service_frequence_6 := NVL (rec5.frekans, rec3.servis_frekansi);
                           ELSE
                              insert_log ('Kampanya_yenileme_batch: 6 dan fazla yeni eklenecek servis bulundu !!!');
                              durum := FALSE;
                           END IF;

                           v_count := v_count + 1;
                        END LOOP;

                        IF durum THEN
                           from_excel_pack.uye_servis_ekle (rec3.account_number,
                                                            rec3.outlet_location,
                                                            v_service_code_1,
                                                            v_campaign_code_1,
                                                            v_service_frequence_1,
                                                            'H',
                                                            SYSDATE + 1,
                                                            'CON',
                                                            'H',
                                                            NULL,
                                                            NULL,
                                                            1,
                                                            'E',
                                                            NULL,
                                                            'DBS',
                                                            0,
                                                            'SYSDZT',
                                                            odurum,
                                                            'E',
                                                            2,
                                                            v_service_code_2,
                                                            v_campaign_code_2,
                                                            v_service_frequence_2,
                                                            v_service_code_3,
                                                            v_campaign_code_3,
                                                            v_service_frequence_3,
                                                            v_service_code_4,
                                                            v_campaign_code_4,
                                                            v_service_frequence_4,
                                                            v_service_code_5,
                                                            v_campaign_code_5,
                                                            v_service_frequence_5,
                                                            v_service_code_6,
                                                            v_campaign_code_6,
                                                            v_service_frequence_6
                                                           );

                           IF odurum = '0' THEN
                              COMMIT;
                           ELSE
                              ROLLBACK;
                              insert_log (
                                 SUBSTR (
                                       'Kampanya_yenileme_batch:'
                                    || rec3.account_number
                                    || '-'
                                    || rec3.outlet_location
                                    || ':'
                                    || v_service_code_1
                                    || '-'
                                    || v_campaign_code_1
                                    || '-'
                                    || v_service_frequence_1
                                    || '-'
                                    || odurum,
                                    1,
                                    250));
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            EXIT;
         END LOOP;
      END LOOP;
   END;

   PROCEDURE iq_hediye_batch (in_from_date        DATE,
                              in_to_date          DATE,
                              in_sms_hour         NUMBER,
                              in_account_number   NUMBER DEFAULT NULL,
                              in_outlet_location  VARCHAR2 DEFAULT NULL
                             ) IS
      v_error_type             NUMBER;
      v_error_code             VARCHAR2 (100);
      v_message                VARCHAR2 (3200);
      v_error_desc             VARCHAR2 (3200);
      exp_generic              EXCEPTION;
      exp_hediye               EXCEPTION;
      v_out_log                VARCHAR2 (3200);
      v_register_telefon_count NUMBER;
      v_ulke_kodu              VARCHAR2 (100) := NULL;
      v_alan_kodu              VARCHAR2 (100) := NULL;
      v_telefon_no             VARCHAR2 (100) := NULL;
      v_sms_istek_grup_id      NUMBER;

      v_sms_uygulama_islem_id  NUMBER := 155;
      v_sms_kullanici_isim     VARCHAR2 (100) := 'routineMSGUsr';
      v_sms_kullanici_sifre    VARCHAR2 (100) := '0ly12Mp0s9';
      v_sms_istek_id           NUMBER;
      v_sms_gonderim_tarihi    DATE;
      v_count                  NUMBER;
   BEGIN
      IF in_from_date IS NULL THEN
         raise_application_error (-20001, 'in_from_date parametresi NULL olamaz. ');
      END IF;

      IF in_to_date IS NULL THEN
         raise_application_error (-20001, 'in_to_date parametresi NULL olamaz. ');
      END IF;

      IF in_from_date > in_to_date THEN
         raise_application_error (-20001, 'in_from_date, in_to_date den sonraki bir tarih olamaz. ');
      END IF;

      IF in_sms_hour IS NULL THEN
         raise_application_error (-20001, 'in_sms_hour NULL olamaz. ');
      END IF;

      IF in_sms_hour < 10 OR in_sms_hour > 19 THEN
         raise_application_error (-20001, 'in_sms_hour degeri 10 - 19 arasinda olmalidir. ');
      END IF;

      IF in_outlet_location IS NOT NULL AND in_account_number IS NULL THEN
         raise_application_error (-20001, 'in_account_number dolu in_outlet_location bos olamaz. ');
      END IF;

      FOR rec
         IN ( --Ilk baglanan outlet locationu buluyoruz.
             SELECT account_number, outlet_location
               FROM dbs_dba.lg_abone_ozellik i
              WHERE     i.abone_ozellik_kodu = 394
                    AND TO_DATE (i.ozellik_degeri, 'dd/mm/yyyy hh24:mi:ss') BETWEEN in_from_date AND in_to_date
                    AND i.account_number = NVL (in_account_number, i.account_number)
                    AND i.outlet_location = NVL (in_outlet_location, i.outlet_location)
                    AND EXISTS
                           (SELECT   l.account_number, l.outlet_location
                                FROM dbs_dba.lg_abone_ozellik l
                               WHERE     l.abone_ozellik_kodu = 394 --internet son baglanti
                                     AND l.islem = 'I'
                                     AND i.account_number = l.account_number
                                     AND i.outlet_location = l.outlet_location
                            GROUP BY l.account_number,
                                     l.outlet_location
                              HAVING MIN (l.id) = i.id)
                    AND EXISTS
                           (SELECT 1
                              FROM mb_abone_ozellik m
                             WHERE m.abone_ozellik_kodu = 256 -- iq segmentasyonuna girenler
                                                             AND m.outlet_location = i.outlet_location AND m.account_number = i.account_number)
                    AND NOT EXISTS
                           (SELECT 1
                              FROM mb_abone_ozellik m
                             WHERE m.abone_ozellik_kodu = 257 --iq segmentasyonundan hediye alanlar
                                                             AND m.outlet_location = i.outlet_location AND m.account_number = i.account_number)
                    AND EXISTS
                           (SELECT *
                              FROM wiz_customer_hp_life hp
                             WHERE     hp.account_number = i.account_number
                                   AND hp.franchise_code = 'F01'
                                   AND hp.customer_type = 'NOR'
                                   AND hp.customer_status = 'AC')) LOOP
         BEGIN
            SELECT COUNT (1)
              INTO v_count
              FROM wiz_equip eq
             WHERE     eq.account_number = rec.account_number
                   AND eq.outlet_location = rec.outlet_location
                   AND eq.converter_type = 'ST'
                   AND EXISTS
                          (SELECT *
                             FROM eq_ekipman_tip_matrix eqm
                            WHERE     eq.converter_type = eqm.converter_type
                                  AND eq.converter_model = eqm.converter_model
                                  AND eq.manufacturer = eqm.manufacturer
                                  AND EXISTS
                                         (SELECT *
                                            FROM pr_urun_ozellik_tanim oz
                                           WHERE oz.ekipman_tip_matrix_id = eqm.eq_ekipman_tip_matrix_id AND urun_tipi = 6 AND oz.ozellik_kodu = 119));

            IF v_count > 0 --IQ kutusu varsa hediye verilecek
                          THEN
               dbs_dba.kampanya_hediye_pack.uyeye_supriz_hediye_ver (in_account_number  => rec.account_number,
                                                                     in_outlet_location => rec.outlet_location,
                                                                     in_hediye_tipi     => 3,
                                                                     in_onay            => 'H',
                                                                     in_kaynak          => 'STB',
                                                                     in_kullanici       => 'SYSSTB',
                                                                     in_kaynak_memo_id  => 59,
                                                                     out_error_type     => v_error_type,
                                                                     out_error_code     => v_error_code,
                                                                     out_aciklama       => v_message
                                                                    );

               IF v_error_type = 1 THEN
                  v_error_desc := v_message;
                  RAISE exp_hediye;
               END IF;

               --MKECECI - IF kontrolü eklendi
               IF v_message IS NOT NULL THEN
                  BEGIN
                     SELECT ulke_kodu, alan_kodu, telefon_no
                       INTO v_ulke_kodu, v_alan_kodu, v_telefon_no
                       FROM (SELECT   *
                                 FROM mb_abone_telefon tel,
                                      mb_abone_telefon_register reg
                                WHERE     tel.id = reg.telefon_id(+)
                                      AND telefon_tipi = 3
                                      AND durum = 1
                                      AND (reg.listeden_gizle = 'H' OR reg.account_number IS NULL)
                                      AND tel.account_number = rec.account_number
                             ORDER BY reg.account_number)
                      WHERE ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_error_desc := 'Üyenin Telefon numarasi bulunamadi. ';
                        RAISE exp_generic;
                  END;

                  IF TRIM (v_alan_kodu) IS NULL OR TRIM (v_telefon_no) IS NULL THEN
                     v_error_desc := 'Üyenin Telefon numarasi bulunamadi. ';
                     RAISE exp_generic;
                  END IF;

                  IF v_sms_istek_grup_id IS NULL THEN
                     sms_dba.sms_gonderim_istek_pack.istek_grup_yarat (in_uygulama_islem_id => v_sms_uygulama_islem_id,
                                                                       in_kullanici_isim    => v_sms_kullanici_isim,
                                                                       in_kullanici_sifre   => v_sms_kullanici_sifre,
                                                                       in_operator_kod      => NULL,
                                                                       in_servis_id         => NULL,
                                                                       in_aciklama          => 'IQ - Hediyesi',
                                                                       in_sablon            => NULL,
                                                                       in_talep_id          => NULL,
                                                                       in_kampanya_kod      => NULL,
                                                                       in_gonderim_tarihi   => NULL,
                                                                       out_id               => v_sms_istek_grup_id,
                                                                       out_sonuc_tip        => v_error_type,
                                                                       out_hata_mesaj       => v_error_desc
                                                                      );

                     IF v_error_type <> 0 THEN
                        v_error_desc := 'SMS grup numarasi alinamadi. ' || v_error_desc;
                        RAISE exp_generic;
                     END IF;
                  END IF;

                  IF TO_NUMBER (TO_CHAR (SYSDATE, 'hh24')) < in_sms_hour THEN
                     v_sms_gonderim_tarihi := TRUNC (SYSDATE) + in_sms_hour / 24;
                  ELSE
                     v_sms_gonderim_tarihi := TRUNC (SYSDATE) + in_sms_hour / 24 + 1;
                  END IF;

                  sms_dba.sms_gonderim_istek_pack.istek_yarat (in_uygulama_islem_id => v_sms_uygulama_islem_id,
                                                               in_istek_grup_id     => v_sms_istek_grup_id,
                                                               in_kullanici_isim    => v_sms_kullanici_isim,
                                                               in_kullanici_sifre   => v_sms_kullanici_sifre,
                                                               in_telefon_no        => TRIM (v_alan_kodu) || TRIM (v_telefon_no),
                                                               in_mesaj_icerik      => v_message,
                                                               in_gonderim_tarihi   => v_sms_gonderim_tarihi,
                                                               out_id               => v_sms_istek_id,
                                                               out_sonuc_tip        => v_error_type,
                                                               out_hata_mesaj       => v_error_desc,
                                                               in_telefon_ulke_kod  => v_ulke_kodu
                                                              );

                  IF v_error_type <> 0 THEN
                     v_error_desc := 'SMS gönderilemedi. ' || v_error_desc;
                     RAISE exp_generic;
                  END IF;

                  -- istek kaydina iliskin üyeyi girme
                  IF v_error_type = 0 THEN
                     sms_dba.sms_gonderim_istek_pack.detay_uye_yarat (in_istek_id     => v_sms_istek_id,
                                                                      in_uye_no       => rec.account_number,
                                                                      in_uye_outlet   => rec.outlet_location,
                                                                      in_uye_ekipman  => NULL,
                                                                      in_gönderdi_mi => FALSE, /*in_gonderdi*/
                                                                      out_sonuc_tip   => v_error_type,
                                                                      out_hata_mesaj  => v_error_desc
                                                                     );
                  END IF;

                  IF v_error_type <> 0 THEN
                     v_error_desc := 'SMS gönderilemedi. Detay Üye kaydi olusturulamadi. ' || v_error_desc;
                     RAISE exp_generic;
                  END IF;
               END IF; --MKECECI - IF blogu eklendi

               COMMIT;
            END IF;
         EXCEPTION
            WHEN exp_generic THEN
               COMMIT; --hediye işlemini başarılı tamamlayıp sms gönderimi veya tel no bulmada hata alırsa buraya girer.
            WHEN exp_hediye THEN
               ROLLBACK; --hediye verme işleminde hata alırsa buraya girer.
            /* Mesut Keçecioglu 04.10.2012
                hata geldiginde log a atilmamasi istendi */

            --               log_pack.log_is_emri_hata (
            --                  NULL,
            --                  NULL,
            --                  NULL,
            --                  NULL,
            --                  NULL,
            --                  'J',
            --                  'SYSSTB',
            --                  SYSDATE,
            --                  'O',
            --                     'IQ_KULLANIM_HEDIYE - Acc_Num : '
            --                  || rec.account_number
            --                  || ', Outlet : '
            --                  || rec.outlet_location
            --                  || ', Hata : '
            --                  || v_error_desc,
            --                  v_out_log);
            --
            --               IF v_out_log <> '0'
            --               THEN
            --                  ROLLBACK;
            --                  RAISE_APPLICATION_ERROR (
            --                     -20001,
            --                     'log_pack.log_is_emri_hata prosesinde hata alindi. ');
            --               ELSE
            --                  COMMIT;
            --               END IF;

            /*</end> Mesut Keçecioglu */
            WHEN OTHERS THEN
               ROLLBACK;
               v_error_desc := SUBSTR (SQLERRM, 1, 250);
               log_pack.log_is_emri_hata (
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  'J',
                  'SYSSTB',
                  SYSDATE,
                  'O',
                  'IQ_KULLANIM_HEDIYE - Acc_Num : ' || rec.account_number || ', Hata : ' || ', Outlet : ' || rec.outlet_location || v_error_desc,
                  v_out_log);

               IF v_out_log <> '0' THEN
                  ROLLBACK;
                  raise_application_error (-20001, 'log_pack.log_is_emri_hata prosesinde hata alindi. Hata : ' || v_out_log);
               ELSE
                  COMMIT;
               END IF;
         END;
      END LOOP;
   END;

   PROCEDURE activate_on_air_for_k_status IS
      o_durum         VARCHAR2 (200);
      o_return_status NUMBER;
      o_return_code   VARCHAR2 (200);
      o_bitis_tarih   VARCHAR2 (200);
      o_aciklama      VARCHAR2 (200);
      o_id            NUMBER;

      CURSOR kayit_rec  IS
         SELECT /*+ INDEX_JOIN(MB) */
               mb.account_number, mb.outlet_location
           FROM mb_abone_statu mb,
                wiz_customer_hp_life wl
          WHERE     mb.account_number = wl.account_number
                AND wl.hp_cluster = 'PH'
                AND wl.franchise_code = 'F01'
                AND wl.customer_type = 'NOR'
                AND mb.statu = 'K'
                AND EXISTS
                       (SELECT 1
                          FROM wiz_equip we1
                         WHERE mb.account_number = we1.account_number AND mb.outlet_location = we1.outlet_location AND we1.converter_type = 'SC') --kart
                AND (   EXISTS
                           (SELECT 1
                              FROM wiz_equip we2
                             WHERE mb.account_number = we2.account_number AND mb.outlet_location = we2.outlet_location AND we2.converter_type = 'ST') --kutu
                     OR EXISTS
                           (SELECT 1
                              FROM eq_ekipman eq
                             WHERE mb.account_number = eq.account_number AND mb.outlet_location = eq.outlet_location AND eq.ekipman_tipi = 248)) --Modül sahipli?ini bsarcan
                AND NOT EXISTS
                           (SELECT 1
                              FROM dbs_addr_on_air_activation x
                             WHERE     x.account_number = mb.account_number
                                   AND x.outlet_location = mb.outlet_location
                                   AND x.campaign_code = 'CKB'
                                   AND x.service_code = 'BSL'
                                   AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                            UNION
                            SELECT 1
                              FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan x
                             WHERE     x.account_number = mb.account_number
                                   AND x.outlet_location = mb.outlet_location
                                   AND x.campaign_code = 'CKB'
                                   AND x.service_code = 'BSL'
                                   AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
                AND NOT EXISTS
                           (SELECT 1
                              FROM lg_abone_statu lg
                             WHERE     mb.account_number = lg.account_number
                                   AND mb.outlet_location = lg.outlet_location
                                   AND lg.statu = 'K'
                                   AND TRUNC (lg.statu_bitis_tarihi) > ADD_MONTHS (TRUNC (SYSDATE), -6))
                AND NOT EXISTS
                           (SELECT 1
                              FROM dbs_addr.dbs_addr_log_on_air_activation x
                             WHERE     x.account_number = mb.account_number
                                   AND x.outlet_location = mb.outlet_location
                                   AND x.campaign_code = 'CKB'
                                   AND x.service_code = 'BSL'
                                   AND TRUNC (x.gerceklesen_kapanma_tarihi) > --son 6 ay içinde önceden CKB ile BSL eklendiyse eklenmesin BSARCAN
                                                                             ADD_MONTHS (TRUNC (SYSDATE), -6));
   BEGIN
      FOR rec_ IN kayit_rec LOOP
         addressability_pack.dbs_activate_on_air (rec_.account_number,
                                                  rec_.outlet_location,
                                                  'CKB',
                                                  'BSL',
                                                  'RCN',
                                                  SYSDATE,
                                                  'SYSTEM',
                                                  o_durum,
                                                  o_return_status,
                                                  o_return_code,
                                                  o_bitis_tarih,
                                                  o_aciklama,
                                                  o_id,
                                                  'DBS'
                                                 );

         IF o_durum = '0' THEN
            COMMIT;
         ELSE
            ROLLBACK;
         END IF;
      END LOOP;
   END;

   PROCEDURE iptal_p_statu_accounts (in_bastarih IN DATE DEFAULT SYSDATE, in_bittarih IN DATE DEFAULT SYSDATE) IS
      v_durum               VARCHAR2 (512);
      voutlog               VARCHAR2 (100);
      v_count               NUMBER;
      v_ittp_order_int_open NUMBER;
   BEGIN
      v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      FOR rec
         IN ( --MKECECI - 04.12.2014
             --          ( (SELECT account_number, outlet_location
             --                 FROM mb_abone_statu s
             --                WHERE     statu = 'P'
             --                      AND (SELECT MIN (promo_expire_date)
             --                             FROM wiz_customer_hp_svc
             --                            WHERE account_number = s.account_number AND outlet_location = s.outlet_location) BETWEEN TRUNC (in_bastarih)
             --                                                                                                                 AND TRUNC (in_bittarih)
             --               UNION
             --               SELECT account_number, outlet_location
             --                 FROM mb_abone_statu s
             --                WHERE     statu = 'I'
             --                      AND eski_statu = 'P'
             --                      AND statu_tarihi BETWEEN TRUNC (in_bastarih) AND TRUNC (in_bittarih)
             --                      AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT'))
             --             UNION
             (SELECT account_number, outlet_location
                FROM mb_abone_statu s
               WHERE     statu = 'P'
                     AND   (SELECT MIN (pdate)
                              FROM dt_dbs_int_dba.vv_uye_ittp_servisler vv,
                                   dt_product_dba.product p
                             WHERE     account_number = s.account_number
                                   AND outlet_location = s.outlet_location
                                   AND vv.id = p.product_id
                                   AND EXISTS
                                          (SELECT 1
                                             FROM dt_product_dba.product_cat_offer_rel cat_rel,
                                                  dt_product_dba.product p2,
                                                  dt_product_dba.product_catalog pc
                                            WHERE     p2.product_id = p.parent_id
                                                  AND cat_rel.product_catalog_cd IN ('DENEMESI_BEDAVA_KAMPANYASI')
                                                  AND pc.product_catalog_type_cd = 'BUNDLE_OFFER_TYPE'
                                                  AND pc.product_catalog_cd = cat_rel.product_catalog_cd
                                                  AND p2.offer_id = cat_rel.offer_from_id
                                                  AND p2.logical_delete_key IS NULL
                                                  AND cat_rel.logical_delete_key IS NULL
                                                  AND SYSDATE BETWEEN cat_rel.valid_from AND cat_rel.valid_thru))
                         + 1 BETWEEN TRUNC (in_bastarih)
                                 AND TRUNC (in_bittarih)
              UNION
              SELECT account_number, outlet_location
                FROM mb_abone_statu s
               WHERE statu = 'I' AND eski_statu = 'P' AND TRUNC (statu_tarihi) BETWEEN TRUNC (in_bastarih) AND TRUNC (in_bittarih) --AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')  --MKECECI 04.12.2014
                                                                                                                                  )) LOOP
         --MKECECI entegrasyon kontrollerine artık gerek yok
         --         IF v_ittp_order_int_open = 0 THEN
         --            SELECT COUNT (1)
         --              INTO v_count
         --              FROM (SELECT account_number, outlet_location
         --                      FROM mb_abone_statu s
         --                     WHERE     statu = 'P'
         --                           AND (SELECT MIN (promo_expire_date)
         --                                  FROM wiz_customer_hp_svc
         --                                 WHERE account_number = s.account_number AND outlet_location = s.outlet_location) BETWEEN TRUNC (in_bastarih)
         --                                                                                                                      AND TRUNC (in_bittarih)
         --                           AND account_number = rec.account_number
         --                           AND outlet_location = rec.outlet_location
         --                    UNION
         --                    SELECT account_number, outlet_location
         --                      FROM mb_abone_statu s
         --                     WHERE     statu = 'I'
         --                           AND eski_statu = 'P'
         --                           AND statu_tarihi BETWEEN TRUNC (in_bastarih) AND TRUNC (in_bittarih)
         --                           AND account_number = rec.account_number
         --                           AND outlet_location = rec.outlet_location);
         --         ELSIF v_ittp_order_int_open = 1 THEN
         SELECT COUNT (1)
           INTO v_count
           FROM (SELECT account_number, outlet_location
                   FROM mb_abone_statu s
                  WHERE     statu = 'P'
                        AND   (SELECT MIN (pdate)
                                 FROM dt_dbs_int_dba.vv_uye_ittp_servisler vv,
                                      dt_product_dba.product p
                                WHERE     account_number = s.account_number
                                      AND outlet_location = s.outlet_location
                                      AND vv.id = p.product_id
                                      AND EXISTS
                                             (SELECT 1
                                                FROM dt_product_dba.product_cat_offer_rel cat_rel,
                                                     dt_product_dba.product p2,
                                                     dt_product_dba.product_catalog pc
                                               WHERE     p2.product_id = p.parent_id
                                                     AND cat_rel.product_catalog_cd IN ('DENEMESI_BEDAVA_KAMPANYASI')
                                                     AND pc.product_catalog_type_cd = 'BUNDLE_OFFER_TYPE'
                                                     AND pc.product_catalog_cd = cat_rel.product_catalog_cd
                                                     AND p2.offer_id = cat_rel.offer_from_id
                                                     AND p2.logical_delete_key IS NULL
                                                     AND cat_rel.logical_delete_key IS NULL
                                                     AND SYSDATE BETWEEN cat_rel.valid_from AND cat_rel.valid_thru))
                            + 1 BETWEEN TRUNC (in_bastarih)
                                    AND TRUNC (in_bittarih)
                        AND account_number = rec.account_number
                        AND outlet_location = rec.outlet_location
                 UNION
                 SELECT account_number, outlet_location
                   FROM mb_abone_statu s
                  WHERE     statu = 'I'
                        AND eski_statu = 'P'
                        AND TRUNC (statu_tarihi) BETWEEN TRUNC (in_bastarih) AND TRUNC (in_bittarih)
                        AND account_number = rec.account_number
                        AND outlet_location = rec.outlet_location);

         --         END IF;

         IF v_count > 0 THEN
            v_durum := '0';

            from_excel_pack.excel_uyelik_iptal (rec.account_number,
                                                rec.outlet_location,
                                                SYSDATE,
                                                'SYSTEM',
                                                in_excel_sebep_kodu     => 'TIP',
                                                in_ekran_sebep_kodu     => 'TIP',
                                                in_excel_sebep_alt_kodu => 'TIP',
                                                in_ekran_sebep_alt_kodu => 'TIP',
                                                in_excel_aciklama       => 'Potansiyel üye promosyon süresi doldugu için iptal',
                                                in_ekran_aciklama       => 'Potansiyel üye promosyon süresi doldugu için iptal',
                                                out_durum               => v_durum,
                                                in_basvuru_yontemi      => 1
                                               );

            IF v_durum <> '0' THEN
               ROLLBACK;
               log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                            'SYSTEM', SYSDATE, 'O', 'iptal_p_statu_accounts - hata :' || v_durum, voutlog);
            END IF;

            COMMIT;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   /*[EBerker20121226] Global Standby Sinyalinin Rating Özelligi Olan kutulara cikilmasini saglayan batch
          Sabit bir parametreye baglidir GLOBAL_STANDBY_FOR_RATING_BATCH_IS_ACTIVE:1 ise calisir.
          */

   PROCEDURE global_standby_for_rating IS
      v_rating_batch_is_active NUMBER := dbs_sabit ('GLOBAL_STANDBY_FOR_RATING_BATCH_IS_ACTIVE');
      p_irdeto_result          VARCHAR2 (1000);
      o_result                 VARCHAR2 (1000);
      voutlog                  VARCHAR2 (100);
   BEGIN
      IF (v_rating_batch_is_active = 1) THEN
         BEGIN
            /*
          p_day_after:null (day after degeri kadar sinyal cikis günü ötelenir)
              p_satellite:null
              o_result:
              p_standby_for_rating:1-->rating tms attribute var demektir.(default 0)
            */
            dbs_addr.global_stand_by_for_irdeto (NULL, NULL, p_irdeto_result, 1);

            IF (p_irdeto_result IS NULL) THEN
               o_result := 'Islem Basarili';
               COMMIT;
            ELSE
               o_result := 'Global Standby with Irdeto For Rating: ' || p_irdeto_result;
               ROLLBACK;
               log_pack.log_is_emri_hata (NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          'J', -- job ile rating için global standby sinyalinin cikilmasi
                                          'SYSTEM',
                                          SYSDATE,
                                          NULL,
                                          'GLOBAL STANDBY FOR RATING BATCH: ' || SUBSTR (o_result, 1, 200),
                                          voutlog
                                         );
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               o_result := SUBSTR (SQLERRM, 1, 255);
               log_pack.log_is_emri_hata (NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          'J', -- job ile rating için global standby sinyalinin cikilmasi
                                          'SYSTEM',
                                          SYSDATE,
                                          NULL,
                                          'GLOBAL STANDBY FOR RATING BATCH: ' || SUBSTR (o_result, 1, 200),
                                          voutlog
                                         );
         END;
      END IF;
   END;

   --  21.03.2013 Ozgur Arslan
   -- Her ayin 3 ünde calisir ve 325 memo kodu (Fatura istiyorum) olan uyeleri bularak abone ozellik 33 u ekler

   PROCEDURE memo_325_uye_fatura_gon_set IS
      v_date_to_date_ilk DATE;
      v_count            NUMBER;
      v_durum            VARCHAR2 (2000);

      CURSOR islem_listesi  IS
         SELECT *
           FROM co_memo_bilgi
          WHERE memo_kodu = 325 AND durum_kodu IN (1, 3) AND abone_kodu IS NOT NULL AND TRUNC (acilis_tarihi) >= v_date_to_date_ilk;
   BEGIN
      v_date_to_date_ilk := TRUNC (ADD_MONTHS (SYSDATE, -1));

      FOR cc IN islem_listesi LOOP
         BEGIN
            abone_detay_pack.mb_abone_ozellik_insert (cc.abone_kodu, NULL, 33, 'SYSTEM', v_durum, NULL);
         EXCEPTION
            WHEN OTHERS THEN
               -- hata alirsada devam etsin
               NULL;
         END;
      END LOOP;
   END;

   PROCEDURE mcr_kart_yetki IS
      --islem_yapilacak kartlar aliniyor
      CURSOR cur_kart  IS
         SELECT b.serial_number, a.account_number, a.outlet_location, c.aciklama
           FROM mb_abone_ozellik a,
                wiz_equip b,
                pr_abone_ozellik c
          WHERE     a.abone_ozellik_kodu IN (389, 390, 391, 416)
                AND b.converter_type = 'SC'
                AND b.account_number > 0
                AND a.account_number = b.account_number
                AND a.outlet_location = b.outlet_location
                AND a.abone_ozellik_kodu = c.kod;

      v_count             NUMBER (2);
      v_event_mesaj_tarih DATE;
      oistek_id           dbs_addr.dbs_addr_oppv_film_istek.id%TYPE;
      odurum_kodu         VARCHAR2 (400);
      odurum              VARCHAR (400);
   BEGIN
      FOR rec_1 IN cur_kart LOOP
         SELECT COUNT (1) --389,390,391 özelliklerinden sadece birine sahip olmasi isteniyor islem yapilacak
           INTO v_count
           FROM mb_abone_ozellik mb
          WHERE mb.account_number = rec_1.account_number AND mb.outlet_location = rec_1.outlet_location AND mb.abone_ozellik_kodu IN (389, 390, 391, 416);

         IF v_count = 1 THEN
            IF NVL (ekipman_pack.ekipman_irdeto_desteklimi (rec_1.serial_number), --Sadece IRDETO kartlarda islem yapilacak
                                                                                 'H') = 'E' THEN
               FOR rec_2
                  IN (SELECT * --kartin üzerindeki özellige göre yarinki ppvlerden FLM olanlar yakalaniyor
                        FROM vv_oppv_film_tanim ppv
                       WHERE     ppv.channel_code = rec_1.aciklama
                             AND NVL (ppv.ust_grup_kategori_kodu, ppv.kategori_kodu) = 'FLM'
                             AND TRUNC (ppv.event_start_time) = TRUNC (SYSDATE + 1)) LOOP
                  v_event_mesaj_tarih := rec_2.event_start_time - 2 / 24; --event_mesaj tarihi, event_start_time dan 2 saat öncesine set ediliyor.

                  film_istek_pack.oppv_film_istek_insert (NULL, --istek_id
                                                          NULL, --aktif_tra_id
                                                          NULL, -- cancel_tra_id
                                                          rec_1.account_number,
                                                          rec_1.outlet_location,
                                                          rec_1.serial_number,
                                                          rec_2.event_id,
                                                          rec_2.event_start_time,
                                                          v_event_mesaj_tarih, --event bildirim tarihi
                                                          'O', --durum
                                                          'PPV', --resaon_code --------     sorulacak???????
                                                          NULL, --update_reason_code
                                                          NULL, --faturalanacak
                                                          NULL, --isleme_girme_tarihi
                                                          NULL, --aciklama
                                                          rec_2.turkce_ad, --film_adi
                                                          'SYSTEM', --giren_kullanici
                                                          2, --abone_istek_kodu --  pr_oppv_deg_abone_istek_tanim.kod%TYPE --- sorulacak???
                                                          NULL, --charge_account_number --  sorulacak???
                                                          'DBS', --kaynak_kodu --- sorulacak?????
                                                          oistek_id, --out
                                                          odurum_kodu, --out
                                                          odurum
                                                         ); --out

                  IF odurum <> '0' THEN
                     insert_log (
                           'abone_batch_pack.ppv_batch - acc:'
                        || rec_1.account_number
                        || ' outlet:'
                        || rec_1.outlet_location
                        || ' event_id:'
                        || rec_2.event_id
                        || ' ppv eklenemedi '
                        || odurum);
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END LOOP;
   END;

   --   PROCEDURE f04_turkiye_paketleri_gca_set IS
   --      CURSOR cur_insert  IS
   --         --insert edilecek
   --         (SELECT mb.account_number, mb.outlet_location
   --            FROM wiz_customer_hp_life wz,
   --                 mb_outlet_takip mb
   --           WHERE     wz.franchise_code = 'F04'
   --                 AND wz.customer_type IN ('NOR', 'NOK')
   --                 AND wz.customer_status = 'AC'
   --                 AND mb.account_number = wz.account_number
   --                 AND mb.outlet_in_tarihi IS NULL
   --                 AND EXISTS
   --                        (SELECT *
   --                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler wiz
   --                          WHERE wiz.account_number = mb.account_number AND wiz.outlet_location = mb.outlet_location)
   --                 AND EXISTS
   --                        (SELECT *
   --                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler wiz
   --                          WHERE     wiz.account_number = mb.account_number
   --                                AND wiz.outlet_location = mb.outlet_location
   --                                AND EXISTS
   --                                       (SELECT 1
   --                                          FROM dt_product_dba.product_cat_offer_rel r
   --                                         WHERE r.product_catalog_cd = 'F04_TURKIYE_PAKETLERI' AND r.offer_from_id = wiz.simple_offer_id)) -- F04 Türkiye Paketleri Özelli?i
   --                 AND NOT EXISTS
   --                        (SELECT *
   --                           FROM mb_abone_ozellik oz
   --                          WHERE oz.account_number = mb.account_number AND oz.outlet_location = mb.outlet_location AND oz.abone_ozellik_kodu = 141));
   --
   --      --delete edilecek
   --      CURSOR cur_delete  IS
   --         (SELECT mb.account_number, mb.outlet_location
   --            FROM wiz_customer_hp_life wz,
   --                 mb_outlet_takip mb
   --           WHERE     wz.franchise_code = 'F04'
   --                 AND wz.customer_type IN ('NOR', 'NOK')
   --                 AND wz.customer_status = 'AC'
   --                 AND mb.account_number = wz.account_number
   --                 AND mb.outlet_in_tarihi IS NULL
   --                 AND EXISTS
   --                        (SELECT *
   --                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler wiz
   --                          WHERE wiz.account_number = mb.account_number AND wiz.outlet_location = mb.outlet_location)
   --                 AND NOT EXISTS
   --                        (SELECT *
   --                           FROM dt_dbs_int_dba.vv_uye_ittp_servisler wiz
   --                          WHERE     wiz.account_number = mb.account_number
   --                                AND wiz.outlet_location = mb.outlet_location
   --                                AND EXISTS
   --                                       (SELECT 1
   --                                          FROM dt_product_dba.product_cat_offer_rel r
   --                                         WHERE r.product_catalog_cd = 'F04_TURKIYE_PAKETLERI' AND r.offer_from_id = wiz.simple_offer_id)) --F04 Türkiye Paketleri Özelli?i
   --                 AND EXISTS
   --                        (SELECT *
   --                           FROM mb_abone_ozellik oz
   --                          WHERE oz.account_number = mb.account_number AND oz.outlet_location = mb.outlet_location AND oz.abone_ozellik_kodu = 141));
   --
   --      o_durum      VARCHAR2 (400);
   --      v_error_desc VARCHAR2 (400);
   --   BEGIN
   --      FOR rec IN cur_delete LOOP
   --         abone_detay_pack.mb_abone_ozellik_delete (rec.account_number, rec.outlet_location, 141, 'SYSTEM', o_durum);
   --
   --         IF o_durum <> '0' THEN
   --            log_pack.log_is_emri_hata (
   --               NULL,
   --               NULL,
   --               NULL,
   --               NULL,
   --               NULL,
   --               'J',
   --               'SYSTEM',
   --               SYSDATE,
   --               'O',
   --               'Türkiye GCA Özelliği Batch - Acc_Num : ' || rec.account_number || ', Hata : ' || ', Outlet : ' || rec.outlet_location,
   --               o_durum);
   --         END IF;
   --      END LOOP;
   --
   --      FOR rec_2 IN cur_insert LOOP
   --         abone_detay_pack.mb_abone_ozellik_insert (rec_2.account_number, rec_2.outlet_location, 141, 'SYSTEM', o_durum);
   --
   --         IF o_durum <> '0' THEN
   --            log_pack.log_is_emri_hata (
   --               NULL,
   --               NULL,
   --               NULL,
   --               NULL,
   --               NULL,
   --               'J',
   --               'SYSTEM',
   --               SYSDATE,
   --               'O',
   --               'Türkiye GCA Özelliği Batch - Acc_Num : ' || rec_2.account_number || ', Hata : ' || ', Outlet : ' || rec_2.outlet_location,
   --               o_durum);
   --         END IF;
   --      END LOOP;
   --   EXCEPTION
   --      WHEN OTHERS THEN
   --         v_error_desc := SUBSTR (SQLERRM, 1, 250);
   --         log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', 'SYSTEM', SYSDATE, 'O', v_error_desc, o_durum);
   --   END;

   PROCEDURE f04_turkiye_paketleri_gca_set IS
      o_durum             VARCHAR2 (400);
      v_error_desc        VARCHAR2 (400);
      v_count             NUMBER (1) := 0;
      vservice_account_id NUMBER;
   BEGIN
      FOR rec_2
         IN (SELECT mb.account_number, mb.outlet_location
               FROM wiz_customer_hp_life wz,
                    mb_outlet_takip mb
              WHERE     wz.franchise_code IN ('F04', 'F12') --MKECECI F12 eklenmesi istendi
                    AND wz.customer_type IN ('NOR', 'NOK', 'MST') -- MST eklenmesi istendi
                    AND wz.customer_status = 'AC'
                    AND mb.account_number = wz.account_number
                    AND mb.outlet_in_tarihi IS NULL) LOOP
         SELECT party_role_account_id
           INTO vservice_account_id
           FROM dt_party_dba.party_role_account
          WHERE dbs_account_number = rec_2.account_number AND dbs_outlet_location = rec_2.outlet_location;

         SELECT COUNT (1)
           INTO v_count
           FROM dt_product_dba.product p,
                dt_product_dba.product bp,
                dt_product_dba.product_spec ps
          WHERE     p.product_spec_id = ps.product_spec_id
                AND bp.product_id = p.parent_id
                AND ps.product_spec_type_cd = 'PAKET'
                AND p.service_account_id = vservice_account_id
                AND p.product_status_type_cd = 'AKTIF';

         --MKECECI - havadan paketlerine de bakması sağlandı-28.08.2014
         --                AND NOT EXISTS
         --                           (SELECT 1
         --                              FROM dt_product_dba.product_cat_offer_rel cat_rel,
         --                                   dt_product_dba.product_catalog cat
         --                             WHERE     bp.offer_id = cat_rel.offer_from_id
         --                                   AND cat.product_catalog_cd = cat_rel.product_catalog_cd
         --                                   AND cat_rel.product_catalog_cd = 'HAVADAN_AKTIVASYON'
         --                                   AND cat.product_catalog_type_cd = 'BUNDLE_OFFER_TYPE'
         --                                   AND cat_rel.logical_delete_key IS NULL
         --                                   AND SYSDATE BETWEEN NVL (cat_rel.valid_from, TO_DATE ('01.01.1900', 'DD.MM.YYYY'))
         --                                                   AND NVL (cat_rel.valid_thru, TO_DATE ('31.12.9000', 'DD.MM.YYYY')));

         IF v_count > 0 THEN
            SELECT COUNT (1)
              INTO v_count
              FROM dt_product_dba.product p,
                   dt_product_dba.product bp,
                   dt_product_dba.product_spec ps
             WHERE     p.product_spec_id = ps.product_spec_id
                   AND bp.product_id = p.parent_id
                   AND ps.product_spec_type_cd = 'PAKET'
                   AND p.service_account_id = vservice_account_id
                   AND p.product_status_type_cd = 'AKTIF'
                   --MKECECI - havadan paketlerine de bakması sağlandı-28.08.2014
                   --                   AND NOT EXISTS
                   --                              (SELECT 1
                   --                                 FROM dt_product_dba.product_cat_offer_rel cat_rel,
                   --                                      dt_product_dba.product_catalog cat
                   --                                WHERE     bp.offer_id = cat_rel.offer_from_id
                   --                                      AND cat.product_catalog_cd = cat_rel.product_catalog_cd
                   --                                      AND cat_rel.product_catalog_cd = 'HAVADAN_AKTIVASYON'
                   --                                      AND cat.product_catalog_type_cd = 'BUNDLE_OFFER_TYPE'
                   --                                      AND cat_rel.logical_delete_key IS NULL
                   --                                      AND SYSDATE BETWEEN NVL (cat_rel.valid_from, TO_DATE ('01.01.1900', 'DD.MM.YYYY'))
                   --                                                      AND NVL (cat_rel.valid_thru, TO_DATE ('31.12.9000', 'DD.MM.YYYY')))
                   AND EXISTS
                          (SELECT 1
                             FROM dt_product_dba.product_cat_offer_rel r
                            WHERE r.product_catalog_cd = 'F04_TURKIYE_PAKETLERI' AND r.offer_from_id = p.offer_id);

            IF v_count = 0 THEN --delete
               SELECT COUNT (1)
                 INTO v_count
                 FROM mb_abone_ozellik oz
                WHERE oz.account_number = rec_2.account_number AND oz.outlet_location = rec_2.outlet_location AND oz.abone_ozellik_kodu = 141;

               IF v_count > 0 THEN
                  abone_detay_pack.mb_abone_ozellik_delete (rec_2.account_number, rec_2.outlet_location, 141, 'SYSTEM', o_durum);

                  IF o_durum <> '0' THEN
                     log_pack.log_is_emri_hata (
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        'J',
                        'SYSTEM',
                        SYSDATE,
                        'O',
                        'Türkiye GCA Özelliği Batch - Acc_Num : ' || rec_2.account_number || ', Hata : ' || ', Outlet : ' || rec_2.outlet_location,
                        o_durum);
                  END IF;
               END IF;
            ELSE --insert
               SELECT COUNT (1)
                 INTO v_count
                 FROM mb_abone_ozellik oz
                WHERE oz.account_number = rec_2.account_number AND oz.outlet_location = rec_2.outlet_location AND oz.abone_ozellik_kodu = 141;

               IF v_count = 0 THEN
                  abone_detay_pack.mb_abone_ozellik_insert (rec_2.account_number, rec_2.outlet_location, 141, 'SYSTEM', o_durum);

                  IF o_durum <> '0' THEN
                     log_pack.log_is_emri_hata (
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        'J',
                        'SYSTEM',
                        SYSDATE,
                        'O',
                        'Türkiye GCA Özelliği Batch - Acc_Num : ' || rec_2.account_number || ', Hata : ' || ', Outlet : ' || rec_2.outlet_location,
                        o_durum);
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         v_error_desc := SUBSTR (SQLERRM, 1, 250);
         DBMS_OUTPUT.put_line (' v_error_desc : ' || v_error_desc);
         log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', 'SYSTEM', SYSDATE, 'O', v_error_desc, o_durum);
   END;

   PROCEDURE iq_internet_son_baglanti_set IS
      --      CURSOR cur_iq
      --      IS
      --           SELECT l.account_number,
      --                  l.outlet_location,
      --                  MAX (TO_CHAR (l.islem_tarihi, 'DD/MM/YYYY HH24:MI:SS'))
      --                     son_baglanti_zamani
      --             FROM ias_dba.ias_log_islem l
      --            WHERE     l.islem_kodu = 256
      --                  AND l.kaynak = 'STB'
      --                  AND l.islem_tarihi > SYSDATE - 1
      --                  AND l.mesaj_kodu LIKE 'VLD%'
      --                  AND l.account_number IS NOT NULL
      --         GROUP BY account_number, outlet_location;

      --MKECECI - logların artık replikeden okunması istendi yukardaki blok replikeye dblink ile bağlandı
      CURSOR cur_iq  IS
         SELECT   account_number, outlet_location, MAX (son_baglanti_zamani) son_baglanti_zamani
             FROM (SELECT   l.account_number, l.outlet_location, MAX (TO_CHAR (l.islem_tarihi, 'DD/MM/YYYY HH24:MI:SS')) AS son_baglanti_zamani
                       FROM ias_dba.ias_log_islem@dbs_replike l --replike den okunuyor
                      WHERE l.islem_kodu = 256 AND l.kaynak = 'STB' AND l.islem_tarihi > SYSDATE - 1 AND l.mesaj_kodu LIKE 'VLD%' AND l.account_number IS NOT NULL
                   GROUP BY account_number,
                            outlet_location
                   UNION ALL
                   SELECT   l.account_number, l.outlet_location, MAX (TO_CHAR (l.islem_tarihi, 'DD/MM/YYYY HH24:MI:SS')) AS son_baglanti_zamani
                       FROM ias_dba.ias_log_islem l --dbslive dan okunuyor
                      WHERE l.islem_kodu = 256 AND l.kaynak = 'STB' AND l.islem_tarihi > SYSDATE - 1 AND l.mesaj_kodu LIKE 'VLD%' AND l.account_number IS NOT NULL
                   GROUP BY account_number,
                            outlet_location)
         GROUP BY account_number,
                  outlet_location;

      --</end>

      o_durum      VARCHAR2 (400);
      v_error_desc VARCHAR2 (400);
   BEGIN
      FOR rec IN cur_iq LOOP
         abone_detay_pack.mb_abone_ozellik_insert (iaccount_number     => rec.account_number,
                                                   ioutlet_location    => rec.outlet_location,
                                                   iabone_ozellik_kodu => 394,
                                                   ikullanici          => 'SYSTEM',
                                                   durum               => o_durum,
                                                   iozellik_deger      => rec.son_baglanti_zamani
                                                  );

         IF o_durum <> '0' THEN
            log_pack.log_is_emri_hata (
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               'J',
               'SYSTEM',
               SYSDATE,
               'O',
                  'IQ_INTERNET_SON_BAGLANTI_SET - Acc_Num : '
               || rec.account_number
               || ', Hata : '
               || ', Outlet : '
               || rec.outlet_location
               || ' özellik insert yapilamadi ',
               o_durum);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         v_error_desc := 'IQ_INTERNET_SON_BAGLANTI_SET -  ' || SUBSTR (SQLERRM, 1, 250);
         log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', 'SYSTEM', SYSDATE, 'O', v_error_desc, o_durum);
   END;

   /*--- Evren Karada? --- */

   /*[EBerker20130507]: Son 1 ay icerisinde aktivasyonlari yapilmis,adres degisikligi yapilmamis K,W,D statuslerinde ki
         F01,NOR üyeler ile   yine son 1 ay icerinde aktivasyonu yapilip
         üzerinde üye iptal is emri acik olan ve beklenen kapanma tarihi son 2 dönemi kapsayan
         statusu A(aktif) olan F01,NOR üyeleri direkt IN yapar  */

   PROCEDURE iptal_k_w_d_a_status_accounts IS
      v_durum               VARCHAR2 (512);
      voutlog               VARCHAR2 (100);
      v_count               NUMBER;
      v_ittp_order_int_open NUMBER;
      v_sd_cozulme_tarihi   DATE;
      v_customer_order_id   NUMBER;
      v_service_account_id  NUMBER;
   BEGIN
      FOR rec
         IN (SELECT *
               FROM mb_abone_statu a
              WHERE     a.statu IN ('K', 'W', 'D')
                    AND EXISTS
                           (SELECT account_number, outlet_location
                              FROM mb_outlet_takip b
                             WHERE b.outlet_in_tarihi IS NULL AND a.account_number = b.account_number AND a.outlet_location = b.outlet_location)
                    AND EXISTS
                           (SELECT *
                              FROM wiz_customer_hp_life c
                             WHERE a.account_number = c.account_number AND c.franchise_code = 'F01' AND c.customer_type = 'NOR')
                    AND EXISTS
                           (SELECT *
                              FROM (SELECT   account_number, outlet_location, MIN (d.outlet_ac_tarihi) min_accdate
                                        FROM mb_outlet_takip d
                                    GROUP BY account_number,
                                             outlet_location) x
                             WHERE     a.account_number = x.account_number
                                   AND a.outlet_location = x.outlet_location
                                   AND TRUNC (min_accdate) >= TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (account_number, SYSDATE + 1), -1)))
                    AND NOT EXISTS
                               (SELECT *
                                  FROM ie_adres_degisikligi e
                                 WHERE     e.durum = 'P'
                                       AND e.yeni_uye_no <> e.uye_no
                                       AND a.account_number = e.yeni_uye_no
                                       AND a.outlet_location = e.yeni_outlet_location)
             UNION ALL
             SELECT *
               FROM mb_abone_statu a
              WHERE     a.statu = 'A'
                    AND EXISTS
                           (SELECT *
                              FROM wiz_customer_hp_life c
                             WHERE a.account_number = c.account_number AND c.franchise_code IN ('F01', 'F04') AND c.customer_type = 'NOR')
                    AND EXISTS
                           (SELECT *
                              FROM (SELECT   account_number, outlet_location, MIN (d.outlet_ac_tarihi) min_accdate
                                        FROM mb_outlet_takip d
                                    GROUP BY account_number,
                                             outlet_location) x
                             WHERE     a.account_number = x.account_number
                                   AND a.outlet_location = x.outlet_location
                                   AND TRUNC (min_accdate) >= TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (a.account_number, SYSDATE + 1), -1)))
                    AND EXISTS
                           (SELECT *
                              FROM ie_uyelik_iptal e
                             WHERE     e.account_number = a.account_number
                                   AND e.outlet_location = a.outlet_location
                                   AND e.durum = 'O'
                                   AND TRUNC (e.beklenen_kapanma_tarihi) <=
                                          TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (a.account_number, SYSDATE), 2)))
                    AND NOT EXISTS
                               (SELECT *
                                  FROM ie_adres_degisikligi e
                                 WHERE     e.durum = 'P'
                                       AND e.yeni_uye_no <> e.uye_no
                                       AND a.account_number = e.yeni_uye_no
                                       AND a.outlet_location = e.yeni_outlet_location)) LOOP
         --[EBerker20130426] - acik iptal is emri varmi
         --varsa 2 ay içerisinde açik is emri var mi kontrolu yapilir eger bu da varsa uyelik iptali yapilir
         --yoksa yani daha ilerde ise bu uye icin bir sey yapilmaz
         --uyenin statusu D ise ie_uyelik_dondurma ya bakilarak ilgili kayidin çözülme tarihi sysdate e çekilir.
         --bu durumun disinda kalanlara uyelik iptali yapilir
         IF rec.statu = 'D' THEN
            --uyelik dondurma
            -- mtonkus 23-01-14 ittp entg.
            v_ittp_order_int_open := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

            IF v_ittp_order_int_open = 0 THEN
               UPDATE ie_uyelik_dondurma
                  SET beklenen_cozulme_tarihi = TRUNC (SYSDATE)
                WHERE account_number = rec.account_number AND outlet_location = rec.outlet_location AND durum = 'D';
            ELSIF v_ittp_order_int_open = 1 THEN
               BEGIN
                  v_service_account_id := billing_dbs_int.customer_ittp_pkg.get_service_account_id (rec.account_number, rec.outlet_location, NULL);

                  v_customer_order_id  := NULL;

                  SELECT don_bi.business_inter_id
                    INTO v_customer_order_id
                    FROM dt_bi_dba.business_inter don_bi,
                         dt_bi_dba.business_inter_spec don_spec
                   WHERE     don_bi.business_inter_spec_id = don_spec.business_inter_spec_id
                         AND don_spec.business_inter_spec_cd = 'PRODUCT_DON'
                         AND don_spec.logical_delete_key IS NULL
                         AND don_bi.logical_delete_key IS NULL
                         AND don_bi.service_account_id = v_service_account_id
                         AND don_bi.business_inter_status_t_cd = 'TAMAMLANDI'
                         AND NOT EXISTS
                                    (SELECT 1
                                       FROM dt_bi_dba.business_inter coz_bi,
                                            dt_bi_dba.business_inter_spec coz_spec
                                      WHERE     coz_bi.parent_id = don_bi.business_inter_id
                                            AND coz_spec.business_inter_spec_id = coz_bi.business_inter_spec_id
                                            AND coz_spec.business_inter_spec_cd = 'PRODUCT_DONCOZ_EKLE'
                                            AND coz_bi.logical_delete_key IS NULL
                                            AND coz_spec.logical_delete_key IS NULL
                                            AND coz_bi.business_inter_status_t_cd = 'TAMAMLANDI');

                  v_sd_cozulme_tarihi  := SYSDATE;

                  IF v_customer_order_id IS NOT NULL THEN
                     dt_bi_dba.customer_order_cp.sv_customer_order (i_action_type        => 'UPDATE',
                                                                    io_customer_order_id => v_customer_order_id,
                                                                    i_resume_date        => v_sd_cozulme_tarihi
                                                                   );
                  END IF;
               END;
            END IF;
         END IF;

         /*SELECT COUNT(1)
           INTO v_count
           FROM (SELECT *
                   FROM IE_UYELIK_IPTAL E
                  WHERE E.ACCOUNT_NUMBER = REC.ACCOUNT_NUMBER
                    AND E.OUTLET_LOCATION = REC.OUTLET_LOCATION
                    AND E.DURUM = 'O'
                    AND TRUNC(E.BEKLENEN_KAPANMA_TARIHI) <=
                                        TRUNC(ADD_MONTHS(bilgi_pack.
                                                         uye_next_billing_date(A.account_number,
                                                                               SYSDATE),
                                                         2))));

         IF v_count > 0 THEN
           v_durum := '0';*/

         --hos paket üyelik iptali icin user:CHURNMNG kullanilacak
         from_excel_pack.excel_uyelik_iptal (rec.account_number,
                                             rec.outlet_location,
                                             SYSDATE,
                                             'CHURNMNG', --CHURNMNG
                                             in_excel_sebep_kodu     => 'TIP',
                                             in_ekran_sebep_kodu     => 'TIP',
                                             in_excel_sebep_alt_kodu => 'TIP',
                                             in_ekran_sebep_alt_kodu => 'TIP',
                                             in_excel_aciklama       => 'K,W,D statusu ayin 4 den sonra gelmis üyelerin iptali',
                                             in_ekran_aciklama       => 'K,W,D statusu ayin 4 den sonra gelmis üyelerin iptali',
                                             out_durum               => v_durum,
                                             in_basvuru_yontemi      => 1
                                            );

         IF v_durum <> '0' THEN
            ROLLBACK;
            log_pack.log_is_emri_hata (NULL, NULL, NULL, NULL, NULL, 'J', -- job ile uyelik iptali toplu islemi
                                                                         'CHURNMNG', SYSDATE, 'O', 'IPTAL_K_W_D_STATUS_ACCOUNTS - hata :' || v_durum, voutlog);
         END IF;

         COMMIT;
      /*END IF;*/

      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END iptal_k_w_d_a_status_accounts;

   --END;

   PROCEDURE inaktif_ts_memo_aktarim_batch -- Haftada bir gün gece 3-4 haric çal??acak
                                           --: inaktif bayilerin açik kalan memolarinin ilgili yts ye yonlendirilmesi için bir batch bsarcan 17/07/2013
    IS
      CURSOR abone_cur  IS
         SELECT ts.prospect_number, ts.tip, ts.yonlendirilen_ts
           FROM vv_memo_yonlendirilmis_ts ts,
                bt_bayi_teknik_servis bt
          WHERE     ts.yonlendirilen_ts = bt.sales_agent_code
                AND bt.franchise_code = 'F01'
                AND bt.durum_kodu IN (SELECT kod
                                        FROM bt_durum
                                       WHERE aktif_mi = 'H');

      --   AND  PROSPECT_NUMBER=991739;

                          /*    in ('972951',
'985632',
'965234',
'96544',
'852145');*/

      --  and  TS.YONLENDIRILEN_Ts='11347935' and PROSPECT_NUMBER ='136934' ;

      v_ulke                       wiz_hp_description.ulke%TYPE;
      v_il                         wiz_hp_description.city%TYPE;
      v_ilce                       wiz_hp_description.suppl_addr_line_1%TYPE;
      v_mahalle                    wiz_hp_description.suppl_addr_line_3%TYPE;
      v_stb_tipi                   wiz_customer_hp_life.hp_cluster%TYPE;
      v_is_tipi                    bt_yts_arama_yonlendirme.is_tipi%TYPE;
      v_arama_yonlendirme_detay_id bt_yts_arama_yonlendirme_detay.id%TYPE;
      v_arama_yonlendirme_id       bt_yts_arama_yonlendirme.id%TYPE;
      v_sales_agent_code           bt_uye_ts.sales_agent_code%TYPE;
      v_abone_kodu                 wiz_customer_hp_life.account_number%TYPE;
      v_durum                      VARCHAR2 (2000) := NULL;
      v_kullanici                  VARCHAR2 (50) := 'SYSTEM';
      v_hata_aciklama              VARCHAR2 (2000);
   BEGIN
      FOR abone_rec IN abone_cur LOOP
         v_abone_kodu    := abone_rec.prospect_number;

         v_hata_aciklama := NULL;
         v_durum         := '0';

         IF abone_rec.tip = 'ABONE' THEN
            BEGIN
               SELECT a.hp_cluster,
                      b.ulke,
                      b.city,
                      CASE WHEN LENGTH (b.suppl_addr_line_1) < 3 THEN NULL ELSE b.suppl_addr_line_1 END ilce,
                      CASE WHEN LENGTH (b.suppl_addr_line_3) < 3 THEN NULL ELSE b.suppl_addr_line_3 END mahalle
                 INTO v_stb_tipi, v_ulke, v_il, v_ilce, v_mahalle
                 FROM wiz_customer_hp_life a,
                      wiz_hp_description b
                WHERE a.account_number = v_abone_kodu --abone_rec.account_number
                                                     AND a.service_address_id = b.service_address_id AND a.franchise_code = 'F01';
            EXCEPTION
               WHEN OTHERS THEN
                  v_durum         := '-1';
                  v_hata_aciklama := 'wiz_customer_hp_life tablosunda abone yok';
            -- exit;
            END;
         ELSE --Potansiyel
            BEGIN
               SELECT 'PH',
                      w.ulke,
                      w.city,
                      CASE WHEN LENGTH (suppl_addr_line_1) < 3 THEN NULL ELSE suppl_addr_line_1 END ilce,
                      CASE WHEN LENGTH (suppl_addr_line_3) < 3 THEN NULL ELSE suppl_addr_line_3 END mahalle
                 INTO v_stb_tipi, v_ulke, v_il, v_ilce, v_mahalle
                 FROM wiz_prospect_descrip w
                WHERE w.prospect_number = v_abone_kodu AND ulke = 'TÜRKİYE';
            EXCEPTION
               WHEN OTHERS THEN
                  v_durum         := '-1';
                  v_hata_aciklama := 'WIZ_PROSPECT_DESCRIP  tablosunda abone yok';
            END;
         END IF;

         IF v_durum = '0' -- ?? tipini belirlemek için
                         THEN
            v_is_tipi := 1; --o bölgeye tanimli arama yönlendirme kaydi olmali
            bayi_arama_yonlendirme_pack.il_ilce_tanimlarini_bul (v_il, v_ilce, v_mahalle, v_stb_tipi, v_is_tipi, v_arama_yonlendirme_id, --out
                                                                                                                                        v_durum, --out
                                                                                                                                                v_ulke);

            --   dbms_output.put_line('v_is_tipi1-.'||v_is_tipi||'*'||v_stb_tipi||'*'||v_mahalle||'*'||v_ilce||v_arama_yonlendirme_id||v_durum);

            IF v_durum <> '0' THEN
               /*v_is_tipi := 1 ise servis
               v_is_tipi := 2 ise kurulum
                burdan sonraki blok servis atamasi olarak yts bulamazsa v_is_tipi = 2 yaparak servis atamasi için kurulum yapan bayiyi ariyor*/
               v_is_tipi := 2;
               bayi_arama_yonlendirme_pack.il_ilce_tanimlarini_bul (v_il, v_ilce, v_mahalle, v_stb_tipi, v_is_tipi, v_arama_yonlendirme_id, --out
                                                                                                                                           v_durum, --out
                                                                                                                                                   v_ulke);
            --            dbms_output.put_line('v_is_tipi2-.'||v_is_tipi||'*'||v_stb_tipi||'*'||v_mahalle||'*'||v_ilce||v_arama_yonlendirme_id||v_durum);

            END IF;

            IF v_arama_yonlendirme_id IS NULL THEN
               v_hata_aciklama := 'il-ilçe Tanimi Bulunamadı';
               v_durum         := '-1';
            END IF;
         END IF;

         --dbms_output.put_line(' v_hata_aciklama'|| v_hata_aciklama||'*'||v_arama_yonlendirme_id||'*'||v_durum);
         IF v_durum = '0' THEN
            bayi_arama_yonlendirme_pack.yonlendirilecek_ts_bul (NULL, --iprospect_number
                                                                v_il, --iil
                                                                v_ilce, --iilce
                                                                v_mahalle, --imahalle
                                                                v_stb_tipi, --istb_tipi
                                                                v_is_tipi, --iis_tipi
                                                                v_kullanici, --ikullanici
                                                                v_sales_agent_code, --oyts outhb
                                                                v_arama_yonlendirme_detay_id, --oarama_yonlendirme_detay_id out
                                                                v_durum, --odurum   out
                                                                v_ulke
                                                               ); --iulke

            -- dbms_output.put_line('yonts.'||v_durum||'-'||v_sales_agent_code);
            IF v_sales_agent_code IS NULL THEN
               v_hata_aciklama := 'Yönlendirilecek  Ts Bulunamadı';
               v_durum         := '-1';
            END IF;
         END IF;

         -- dbms_output.put_line('v_sales_agent_code'||v_sales_agent_code);

         IF v_durum = '0' AND v_sales_agent_code IS NOT NULL THEN
            IF abone_rec.tip = 'ABONE' THEN
               -- 333  adres degisikligi memolari için islem yapilmiyor.
               -- 333 için islem gerekirse MEMO_PACK.ABONE_MEMOLARI_TSYE_YONLENDIR 2 olarak bir daha çagrilacak
               -- 2 olarak çagrilirsa bt_uye_ts nasil update edilecek arastirilacak.

               --  dbms_output.put_line('a test.');

               memo_pack.abone_memolari_tsye_yonlendir (v_abone_kodu, -- v_account_number
                                                                     abone_rec.yonlendirilen_ts, --eski teknik servis
                                                                                                v_sales_agent_code, --yeni teknik servis
                                                                                                                   1, --v_yts_islem_tipi
                                                                                                                     v_kullanici, -- v_kullanici_kodu
                                                                                                                                 v_durum);
            ELSE --POTANSIYEL
               memo_pack.prspct_memolari_tsye_yonlendir (v_abone_kodu, abone_rec.yonlendirilen_ts, --eski teknik servis
                                                                                                  v_sales_agent_code, --yeni teknik servis
                                                                                                                     v_kullanici, v_durum);
            END IF;
         END IF;

         IF v_durum = '0' AND v_sales_agent_code IS NOT NULL THEN
            COMMIT;
         ELSE
            ROLLBACK;
         --insert_log ( 'I_TS_MEMO  Abone No : '||v_abone_kodu|| ' A/P: '|| abone_rec.Tip||' Eski Ts : '||abone_rec.YONLENDIRILEN_TS||'-'|| v_hata_aciklama);

         END IF;
      END LOOP;
   END;

   PROCEDURE memo_iptal_60_gun_batch --F01 uyeliklerde TS_YT kullanicisi haricinde 60 gundur açik kalan memolar iptale çekilecek. bsarcan 17/07/2013
                                    IS
      CURSOR memo_cur  IS
         SELECT id, abone_kodu, potansiyel_kodu
           FROM co_memo_bilgi a,
                (SELECT co_memo_durum.kod
                   FROM co_memo_durum
                  WHERE co_memo_durum.degistirme_yapilir = 'E') b
          WHERE     a.durum_kodu = b.kod
                AND a.memo_kodu NOT IN (333) -- adres degisikligi taleplerine dokunulmayacak
                AND a.acilis_tarihi < TO_DATE (SYSDATE, 'dd/mm/yyyy') - 60
                AND NOT EXISTS
                       (SELECT     kod
                              FROM co_kullanici
                             WHERE kod = a.giren_kullanici
                        START WITH ust_kod = 'TS_YT'
                        CONNECT BY PRIOR kod = ust_kod);

      --     and abone_kodu='1101862';

      v_sonuc VARCHAR2 (1000) := NULL;
      v_count NUMBER := 0;
   BEGIN
      FOR memo_rec IN memo_cur LOOP
         IF memo_rec.abone_kodu IS NOT NULL THEN
            SELECT COUNT (*)
              INTO v_count
              FROM wiz_customer_hp_life a
             WHERE a.account_number = memo_rec.abone_kodu AND a.franchise_code = 'F01';
         ELSE
            SELECT COUNT (*)
              INTO v_count
              FROM wiz_prospect_descrip w
             WHERE w.prospect_number = memo_rec.abone_kodu AND ulke = 'TÜRKİYE';
         END IF;

         IF v_count > 0 THEN
            dbs_dba.memo_pack.co_memo_durum_degistir (memo_rec.id, --v_memo_id
                                                                  2, --v_memo_durumu HATALI MEMO
                                                                    NULL, --v_randevu_durumu
                                                                         'SYSTEM', --v_kullanici
                                                                                  v_sonuc, --v_Sonuc
                                                                                          SYSDATE); --v_kapanis_tarihi

            IF v_sonuc = '0' THEN
               COMMIT;
            ELSE
               ROLLBACK;
            --insert_log ( 'MEMO_IPTAL_60_GUN_BATCH : '||v_sonuc);
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN;
   END;

   PROCEDURE vip_multiscreen_ligtv_kontrol IS
      v_mol_campaign_code     wiz_customer_hp_svc.campaign_code%TYPE;
      v_ekle_durum            VARCHAR2 (2000);
      v_dusur_durum           VARCHAR2 (2000);
      v_next_billing_date     DATE;
      v_outlet_found          mb_outlet_takip.outlet_location%TYPE;
      v_spor_found            VARCHAR2 (2000);
      v_effective_date        DATE;
      v_eklenecek_srv         VARCHAR2 (3);
      v_eklenecek_svc_kmp     VARCHAR2 (3);
      v_eklenecek_havadan_kmp VARCHAR2 (3);
      v_eklenecek_fre         VARCHAR2 (1);
      v_mol_servis_frek       VARCHAR2 (1);
      v_outletler             VARCHAR2 (4000);
      v_ekleme_turu           NUMBER := 1; /*1 svc , 2 havadan*/
      v_ittp_order_int_open   NUMBER;
   BEGIN
      v_eklenecek_srv         := 'MOL';
      v_eklenecek_svc_kmp     := 'MVV';
      v_eklenecek_fre         := '1';
      v_eklenecek_havadan_kmp := 'MO1';

      v_ittp_order_int_open   := billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT');

      /*Önce artık VIP olmayan abonelerden svclerdeki MOL paketlerini çıkartıyoruz*/
      FOR rec IN (SELECT svc.account_number, svc.outlet_location, svc.service_code, svc.campaign_code, svc.servis_frekansi
                    FROM wiz_customer_hp_svc svc,
                         wiz_customer_hp_life lf
                   WHERE     lf.account_number = svc.account_number
                         AND lf.customer_type IN ('NOR', 'TST')
                         AND lf.franchise_code IN ('F01', 'F02')
                         AND lf.hp_cluster IN ('PH', 'LG')
                         AND svc.service_code IN (SELECT paket_kodu
                                                    FROM vv_servis_icerik
                                                   WHERE icerik_kodu = v_eklenecek_srv)
                         AND svc.campaign_code = v_eklenecek_svc_kmp
                         AND svc.servis_frekansi = v_eklenecek_fre
                         AND NOT EXISTS
                                (SELECT *
                                   FROM mb_abone_ozellik mb
                                  WHERE abone_ozellik_kodu = 210 AND mb.account_number = svc.account_number)
                         AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                  UNION
                  SELECT svc.account_number, svc.outlet_location, svc.service_code, svc.campaign_code, svc.servis_frekansi
                    FROM dt_dbs_int_dba.vv_uye_ittp_servisler svc,
                         wiz_customer_hp_life lf
                   WHERE     lf.account_number = svc.account_number
                         AND lf.customer_type IN ('NOR', 'TST')
                         AND lf.franchise_code IN ('F01', 'F02')
                         AND lf.hp_cluster IN ('PH', 'LG')
                         AND svc.service_code IN (SELECT paket_kodu
                                                    FROM vv_servis_icerik
                                                   WHERE icerik_kodu = v_eklenecek_srv)
                         AND svc.campaign_code = v_eklenecek_svc_kmp
                         AND svc.servis_frekansi = v_eklenecek_fre
                         AND NOT EXISTS
                                (SELECT *
                                   FROM mb_abone_ozellik mb
                                  WHERE abone_ozellik_kodu = 210 AND mb.account_number = svc.account_number)
                         AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                  ORDER BY account_number) LOOP
         BEGIN
            v_dusur_durum    := NULL;
            v_effective_date := TO_DATE (TO_CHAR (bilgi_pack.uye_next_billing_date (rec.account_number), 'dd/mm/yyyy') || ' 23:55:00', 'dd/mm/yyyy hh24:mi:ss');
            from_excel_pack.uye_servis_dusur (in_account_number    => rec.account_number,
                                              in_outlet_location   => rec.outlet_location,
                                              in_service_code      => rec.service_code,
                                              in_campaign_code     => rec.campaign_code,
                                              in_service_frequence => rec.servis_frekansi,
                                              in_hemen_kapat       => 'H',
                                              in_li_effective_date => v_effective_date,
                                              in_sebep_kodu        => 'CON',
                                              in_bedelli           => 'E',
                                              in_kaynak            => 'DBS',
                                              in_kontrol_tipi      => 0,
                                              in_kullanici         => 'SYSTEM',
                                              out_durum            => v_dusur_durum,
                                              in_uyari_gec         => 'E',
                                              in_islem_tip         => 1,
                                              in_servis_kontrol    => 'E'
                                             );

            IF v_dusur_durum <> '0' THEN
               ROLLBACK;
               dbs_dba.abone_batch_pack.insert_log (
                     'NOT_VIP_MOL_DUSUR: '
                  || rec.account_number
                  || 'nolu abonenin '
                  || rec.outlet_location
                  || ' nolu outletinden '
                  || rec.service_code
                  || ' '
                  || rec.campaign_code
                  || ' düşürülürken hata : '
                  || v_dusur_durum);
            ELSE
               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               dbs_dba.abone_batch_pack.insert_log (
                     'NOT_VIP_MOL_DUSUR: '
                  || rec.account_number
                  || 'nolu abonenin '
                  || rec.outlet_location
                  || ' nolu outletinden '
                  || rec.service_code
                  || ' '
                  || rec.campaign_code
                  || ' düşürülürken hata : '
                  || DBMS_UTILITY.format_error_stack ());
         END;
      END LOOP;

      /*Artık VIP olmayan ancak üzerinde bizim kanpanya ile havadan bu paketler olanların paketlerini düşürüyoruz. */
      FOR rec IN (SELECT air.account_number, air.outlet_location, air.service_code, air.campaign_code
                    FROM dbs_addr_on_air_activation air,
                         wiz_customer_hp_life lf --on air
                   WHERE     air.account_number = lf.account_number
                         AND lf.customer_type IN ('NOR', 'TST')
                         AND lf.franchise_code IN ('F01', 'F02')
                         AND lf.hp_cluster IN ('PH', 'LG')
                         AND air.service_code IN (SELECT paket_kodu
                                                    FROM vv_servis_icerik
                                                   WHERE icerik_kodu = v_eklenecek_srv)
                         AND air.campaign_code = v_eklenecek_havadan_kmp
                         AND NOT EXISTS
                                (SELECT *
                                   FROM mb_abone_ozellik mb
                                  WHERE abone_ozellik_kodu = 210 AND mb.account_number = air.account_number)
                         AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                  UNION
                  SELECT air.account_number, air.outlet_location, air.service_code, air.campaign_code
                    FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan air,
                         wiz_customer_hp_life lf --on air
                   WHERE     air.account_number = lf.account_number
                         AND lf.customer_type IN ('NOR', 'TST')
                         AND lf.franchise_code IN ('F01', 'F02')
                         AND lf.hp_cluster IN ('PH', 'LG')
                         AND air.service_code IN (SELECT paket_kodu
                                                    FROM vv_servis_icerik
                                                   WHERE icerik_kodu = v_eklenecek_srv)
                         AND air.campaign_code = v_eklenecek_havadan_kmp
                         AND NOT EXISTS
                                (SELECT *
                                   FROM mb_abone_ozellik mb
                                  WHERE abone_ozellik_kodu = 210 AND mb.account_number = air.account_number)
                         AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                  ORDER BY account_number) LOOP
         BEGIN
            v_dusur_durum    := NULL;
            v_effective_date := TO_DATE (TO_CHAR (bilgi_pack.uye_next_billing_date (rec.account_number), 'dd/mm/yyyy') || ' 23:55:00', 'dd/mm/yyyy hh24:mi:ss');
            --on air dusur
            /* from_excel_pack.uye_servis_dusur (
                in_account_number      => rec.account_number,
                in_outlet_location     => rec.outlet_location,
                in_service_code        => rec.service_code,
                in_campaign_code       => rec.campaign_code,
                in_service_frequence   => 1,
                in_hemen_kapat         => 'H',
                in_li_effective_date   => v_effective_date,
                in_sebep_kodu          => 'CON',
                in_bedelli             => 'E',
                in_kaynak              => 'DBS',
                in_kontrol_tipi        => 0,
                in_kullanici           => 'SYSTEM',
                out_durum              => v_dusur_durum,
                in_uyari_gec           => 'E',
                in_islem_tip           => 1,
                in_servis_kontrol      => 'E');*/

            from_excel_pack.havadan_aktivasyon_srv_iptali (rec.account_number, rec.outlet_location, v_eklenecek_havadan_kmp, v_dusur_durum);

            IF v_dusur_durum <> '0' THEN
               ROLLBACK;
               dbs_dba.abone_batch_pack.insert_log (
                     'NOT_VIP_MOL_DUSUR: '
                  || rec.account_number
                  || 'nolu abonenin '
                  || rec.outlet_location
                  || ' nolu outletinden '
                  || rec.service_code
                  || ' '
                  || rec.campaign_code
                  || ' düşürülürken hata : '
                  || v_dusur_durum);
            ELSE
               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               dbs_dba.abone_batch_pack.insert_log (
                     'NOT_VIP_MOL_DUSUR: '
                  || rec.account_number
                  || 'nolu abonenin '
                  || rec.outlet_location
                  || ' nolu outletinden '
                  || rec.service_code
                  || ' '
                  || rec.campaign_code
                  || ' düşürülürken hata : '
                  || DBMS_UTILITY.format_error_stack ());
         END;
      END LOOP;

      FOR rec
         IN (SELECT *
               FROM (SELECT   mb.account_number --mb.account_number
                         FROM mb_abone_ozellik mb,
                              wiz_customer_hp_life lf
                        WHERE     mb.account_number = lf.account_number
                              AND lf.customer_type IN ('NOR', 'TST')
                              AND lf.franchise_code IN ('F01', 'F02')
                              AND lf.hp_cluster IN ('PH', 'LG')
                              AND mb.abone_ozellik_kodu = 210
                     ORDER BY mb.account_number)) LOOP
         v_outlet_found      := NULL;
         v_next_billing_date := NULL;
         v_outletler         := NULL;

         /*outleti in olmamış, kartı tanımlı, uye uydusu eutelsat ve kartı irdeto destekli outletler alınıyor*/
         FOR rec_outlet
            IN (SELECT   a.outlet_location, b.serial_number
                    FROM mb_outlet_takip a,
                         wiz_equip b
                   WHERE     a.account_number = rec.account_number
                         AND a.account_number = b.account_number
                         AND a.outlet_location = b.outlet_location
                         AND a.outlet_in_tarihi IS NULL
                         AND b.converter_type = 'SC'
                         AND abone_sorgu_pack.uye_uydusu (a.account_number, a.outlet_location) = 1
                         AND ekipman_pack.ekipman_irdeto_desteklimi (b.serial_number) = 'E'
                ORDER BY outlet_location) LOOP
            /*önce outletler toplanıyor*/
            IF v_outletler IS NULL THEN
               v_outletler := rec_outlet.outlet_location;
            ELSE
               v_outletler := v_outletler || ',' || rec_outlet.outlet_location;
            END IF;
         END LOOP;

         /*her bir outlet için 4 farklı kontrol sırayla yapılıyor.
         1. havadan hariç full sporu var mı
         2. havadan dahil fullsporu var mı
         3. havadan hariç fullspor harici spor var mı
         4.havadan dahil fullspor harici sor varmı*/
         FOR rec_outletler IN (SELECT COLUMN_VALUE AS outlet_location FROM TABLE (split_table_fnc (v_outletler))) LOOP
            IF /*Önce havadan hariç full spor var mı */
              abone_sorgu_pack.spor_servisi_varmi (in_account_number            => rec.account_number,
                                                   in_outlet_location           => rec_outletler.outlet_location,
                                                   wiz_customer_hp_svc_dahil_mi => 'E',
                                                   havadan_aktivasyon_dahil_mi  => 'H',
                                                   full_spor_dahil_mi           => 'E',
                                                   full_sporlar_harici_mi       => 'H',
                                                   spm_dahil_mi                 => 'H'
                                                  ) = 1 THEN
               v_outlet_found := rec_outletler.outlet_location;
               v_ekleme_turu  := 1;
               EXIT;
            END IF;
         END LOOP;

         IF v_outlet_found IS NULL THEN
            FOR rec_outletler IN (SELECT COLUMN_VALUE AS outlet_location FROM TABLE (split_table_fnc (v_outletler))) LOOP
               /*havadan dahil full spor*/
               v_spor_found      := abone_sorgu_pack.spor_servisi_varmi (in_account_number            => rec.account_number,
                                                                         in_outlet_location           => rec_outletler.outlet_location,
                                                                         wiz_customer_hp_svc_dahil_mi => 'E',
                                                                         havadan_aktivasyon_dahil_mi  => 'E',
                                                                         full_spor_dahil_mi           => 'E',
                                                                         full_sporlar_harici_mi       => 'H',
                                                                         spm_dahil_mi                 => 'H'
                                                                        );

               IF v_spor_found = '1' THEN
                  v_outlet_found := rec_outletler.outlet_location;
                  v_ekleme_turu  := 2;
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF v_outlet_found IS NULL THEN
            FOR rec_outletler IN (SELECT COLUMN_VALUE AS outlet_location FROM TABLE (split_table_fnc (v_outletler))) LOOP
               /*havadan hariç, full spor harici spor*/
               v_spor_found      := abone_sorgu_pack.spor_servisi_varmi (in_account_number            => rec.account_number,
                                                                         in_outlet_location           => rec_outletler.outlet_location,
                                                                         wiz_customer_hp_svc_dahil_mi => 'E',
                                                                         havadan_aktivasyon_dahil_mi  => 'H',
                                                                         full_spor_dahil_mi           => 'H',
                                                                         full_sporlar_harici_mi       => 'E',
                                                                         spm_dahil_mi                 => 'H'
                                                                        );

               IF v_spor_found = '1' THEN
                  v_outlet_found := rec_outletler.outlet_location;
                  v_ekleme_turu  := 1;
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF v_outlet_found IS NULL THEN
            FOR rec_outletler IN (SELECT COLUMN_VALUE AS outlet_location FROM TABLE (split_table_fnc (v_outletler))) LOOP
               /*havadan dahil, full spor harici sporlu mu*/
               v_spor_found      := abone_sorgu_pack.spor_servisi_varmi (in_account_number            => rec.account_number,
                                                                         in_outlet_location           => rec_outletler.outlet_location,
                                                                         wiz_customer_hp_svc_dahil_mi => 'E',
                                                                         havadan_aktivasyon_dahil_mi  => 'E',
                                                                         full_spor_dahil_mi           => 'H',
                                                                         full_sporlar_harici_mi       => 'E',
                                                                         spm_dahil_mi                 => 'H'
                                                                        );

               IF v_spor_found = '1' THEN
                  v_outlet_found := rec_outletler.outlet_location;
                  v_ekleme_turu  := 2;
                  EXIT;
               END IF;
            END LOOP;
         END IF;

         IF v_outlet_found IS NOT NULL THEN
            v_mol_campaign_code := NULL;
            v_mol_servis_frek   := NULL;

            /*molü kontrol et */
            IF v_ekleme_turu = 1 THEN
               IF v_ittp_order_int_open = 0 THEN
                  BEGIN
                     SELECT campaign_code, servis_frekansi
                       INTO v_mol_campaign_code, v_mol_servis_frek
                       FROM wiz_customer_hp_svc
                      WHERE     account_number = rec.account_number
                            AND outlet_location = v_outlet_found
                            AND service_code IN (SELECT paket_kodu
                                                   FROM vv_servis_icerik
                                                  WHERE icerik_kodu = v_eklenecek_srv);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;
               ELSIF v_ittp_order_int_open = 1 THEN
                  BEGIN
                     SELECT campaign_code, servis_frekansi
                       INTO v_mol_campaign_code, v_mol_servis_frek
                       FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                      WHERE     account_number = rec.account_number
                            AND outlet_location = v_outlet_found
                            AND service_code IN (SELECT paket_kodu
                                                   FROM vv_servis_icerik
                                                  WHERE icerik_kodu = v_eklenecek_srv);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;
               END IF;
            ELSE
               IF v_ittp_order_int_open = 0 THEN
                  BEGIN
                     SELECT campaign_code, '1'
                       INTO v_mol_campaign_code, v_mol_servis_frek
                       FROM dbs_addr_on_air_activation
                      WHERE     account_number = rec.account_number
                            AND outlet_location = v_outlet_found
                            AND service_code IN (SELECT paket_kodu
                                                   FROM vv_servis_icerik
                                                  WHERE icerik_kodu = v_eklenecek_srv);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;
               ELSIF v_ittp_order_int_open = 1 THEN
                  BEGIN
                     SELECT campaign_code, '1'
                       INTO v_mol_campaign_code, v_mol_servis_frek
                       FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan
                      WHERE     account_number = rec.account_number
                            AND outlet_location = v_outlet_found
                            AND service_code IN (SELECT paket_kodu
                                                   FROM vv_servis_icerik
                                                  WHERE icerik_kodu = v_eklenecek_srv);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL;
                  END;
               END IF;
            END IF;

            v_next_billing_date := bilgi_pack.uye_next_billing_date (rec.account_number);

            IF v_next_billing_date IS NULL THEN
               dbs_dba.abone_batch_pack.insert_log ('VIP_MOL_EKLE: ' || rec.account_number || 'nolu abonenin ' || ' next billing date i bulunamadı : ');
            ELSE
               v_effective_date := TO_DATE (TO_CHAR (v_next_billing_date, 'dd/mm/yyyy') || ' 23:55:00', 'dd/mm/yyyy hh24:mi:ss');
            END IF;

            IF v_effective_date IS NOT NULL THEN
               IF    (v_ekleme_turu = 1 AND v_mol_campaign_code IS NOT NULL AND v_mol_campaign_code <> v_eklenecek_svc_kmp)
                  OR (v_ekleme_turu = 2 AND v_mol_campaign_code IS NOT NULL AND v_mol_campaign_code <> v_eklenecek_havadan_kmp)
                  OR v_mol_campaign_code IS NULL
                  OR (    v_ekleme_turu = 1
                      AND v_mol_campaign_code IS NOT NULL
                      AND v_mol_campaign_code = v_eklenecek_svc_kmp
                      AND v_mol_servis_frek <> v_eklenecek_fre) THEN
                  IF v_ekleme_turu = 1 THEN
                     from_excel_pack.uye_servis_ekle (in_account_number    => rec.account_number,
                                                      in_outlet_location   => v_outlet_found,
                                                      in_service_code      => v_eklenecek_srv,
                                                      in_campaign_code     => v_eklenecek_svc_kmp,
                                                      in_service_frequence => v_eklenecek_fre,
                                                      in_hemen_kapat       => 'H',
                                                      in_li_effective_date => v_effective_date, --v_effective_date, --DEĞİŞECEK
                                                      in_sebep_kodu        => 'CON',
                                                      in_bayiden_satis     => 'H',
                                                      in_bayi_kodu         => NULL,
                                                      in_ozel_fiyat        => NULL,
                                                      in_adet              => 1,
                                                      in_bedelli           => 'E',
                                                      in_sabit_promo_date  => NULL,
                                                      in_kaynak            => 'DBS',
                                                      in_kontrol_tipi      => 0,
                                                      in_kullanici         => 'SYSTEM',
                                                      out_durum            => v_ekle_durum,
                                                      in_uyari_gec         => 'E',
                                                      in_islem_tip         => 1
                                                     );
                  ELSE
                     IF v_mol_campaign_code IS NOT NULL THEN
                        v_dusur_durum := NULL;
                        /*SVC ye eklerken aynı ürünü farklı kampanyayla eklerken  öncekini düşürür, ancak havadanda düşürmez, o yüzden biz manuel olarak düşürüyoruz*/
                        from_excel_pack.havadan_aktivasyon_srv_iptali (rec.account_number, v_outlet_found, v_mol_campaign_code, v_dusur_durum);

                        IF v_dusur_durum = '0' THEN
                           from_excel_pack.activateonair (rec.account_number,
                                                          v_outlet_found,
                                                          v_eklenecek_havadan_kmp,
                                                          'CON',
                                                          'SYSTEM',
                                                          SYSDATE,
                                                          v_ekle_durum,
                                                          'DBS'
                                                         );
                        ELSE
                           v_ekle_durum := '-1';
                        END IF;
                     END IF;
                  END IF;

                  IF v_ekle_durum = '0' THEN
                     v_dusur_durum := '0';

                     /*bir outlet ile işlem yapılınca diğer outletlerdeki tüm MOL, GOL, LMS ve LMY ler düşürülür*/
                     FOR rec_dusur IN (SELECT account_number, outlet_location, service_code, campaign_code, servis_frekansi
                                         FROM wiz_customer_hp_svc
                                        WHERE     account_number = rec.account_number
                                              AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '1', '000', v_outlet_found) = v_outlet_found)
                                              AND service_code IN (SELECT paket_kodu
                                                                     FROM vv_servis_icerik
                                                                    WHERE icerik_kodu = v_eklenecek_srv)
                                              AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                       UNION
                                       SELECT account_number, outlet_location, service_code, campaign_code, servis_frekansi
                                         FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                                        WHERE     account_number = rec.account_number
                                              AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '1', '000', v_outlet_found) = v_outlet_found)
                                              AND service_code IN (SELECT paket_kodu
                                                                     FROM vv_servis_icerik
                                                                    WHERE icerik_kodu = v_eklenecek_srv)
                                              AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')) LOOP
                        from_excel_pack.uye_servis_dusur (in_account_number    => rec.account_number,
                                                          in_outlet_location   => rec_dusur.outlet_location,
                                                          in_service_code      => rec_dusur.service_code,
                                                          in_campaign_code     => rec_dusur.campaign_code,
                                                          in_service_frequence => rec_dusur.servis_frekansi,
                                                          in_hemen_kapat       => 'H',
                                                          in_li_effective_date => v_effective_date,
                                                          in_sebep_kodu        => 'CON',
                                                          in_bedelli           => 'E',
                                                          in_kaynak            => 'DBS',
                                                          in_kontrol_tipi      => 0,
                                                          in_kullanici         => 'SYSTEM',
                                                          out_durum            => v_dusur_durum,
                                                          in_uyari_gec         => 'E',
                                                          in_islem_tip         => 1,
                                                          in_servis_kontrol    => 'E'
                                                         );

                        IF v_dusur_durum <> '0' THEN
                           ROLLBACK;
                           dbs_dba.abone_batch_pack.insert_log (
                                 'VIP_MOL_DUSUR: '
                              || rec.account_number
                              || 'nolu abonenin '
                              || rec_dusur.outlet_location
                              || ' nolu outletinden '
                              || rec_dusur.service_code
                              || ' '
                              || rec_dusur.campaign_code
                              || ' düşürülürken hata : '
                              || v_dusur_durum);
                           EXIT;
                        END IF;
                     END LOOP;

                     IF v_dusur_durum = '0' THEN
                        FOR rec_dusur IN (SELECT account_number, outlet_location, campaign_code, service_code
                                            FROM dbs_addr_on_air_activation
                                           WHERE     account_number = rec.account_number
                                                 AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '2', '000', v_outlet_found) = v_outlet_found)
                                                 AND service_code IN (SELECT paket_kodu
                                                                        FROM vv_servis_icerik
                                                                       WHERE icerik_kodu = v_eklenecek_srv)
                                                 AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                          UNION
                                          SELECT account_number, outlet_location, campaign_code, service_code
                                            FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan
                                           WHERE     account_number = rec.account_number
                                                 AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '2', '000', v_outlet_found) = v_outlet_found)
                                                 AND service_code IN (SELECT paket_kodu
                                                                        FROM vv_servis_icerik
                                                                       WHERE icerik_kodu = v_eklenecek_srv)
                                                 AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')) LOOP
                           from_excel_pack.havadan_aktivasyon_srv_iptali (in_account_number => rec_dusur.account_number,
                                                                          in_outlet         => rec_dusur.outlet_location,
                                                                          in_campaign_code  => rec_dusur.campaign_code,
                                                                          o_durum           => v_dusur_durum
                                                                         );

                           IF v_dusur_durum <> '0' THEN
                              ROLLBACK;
                              dbs_dba.abone_batch_pack.insert_log (
                                    'VIP_MOL_DUSUR: '
                                 || rec.account_number
                                 || 'nolu abonenin '
                                 || rec_dusur.outlet_location
                                 || ' nolu outletinden '
                                 || rec_dusur.service_code
                                 || ' '
                                 || rec_dusur.campaign_code
                                 || ' düşürülürken hata : '
                                 || v_dusur_durum);
                              EXIT;
                           END IF;
                        END LOOP;
                     END IF;

                     IF v_dusur_durum = '0' THEN
                        COMMIT;
                     END IF;
                  ELSE
                     ROLLBACK;
                     dbs_dba.abone_batch_pack.insert_log (
                           'VIP_MULTISCREEN: '
                        || rec.account_number
                        || ' nolu abonenin '
                        || v_outlet_found
                        || ' outletine '
                        || v_eklenecek_srv
                        || '- MGV'
                        || ' eklenirken hata : '
                        || v_ekle_durum);
                  END IF;
               ELSE
                  /*Adamın molü var ve bizim kampanyada, o yüzden diğer outletlerindeki paketleri düşürüyoruz*/
                  FOR rec_dusur IN (SELECT account_number, outlet_location, service_code, campaign_code, servis_frekansi
                                      FROM wiz_customer_hp_svc
                                     WHERE     account_number = rec.account_number
                                           AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '1', '000', v_outlet_found) = v_outlet_found)
                                           AND service_code IN (SELECT paket_kodu
                                                                  FROM vv_servis_icerik
                                                                 WHERE icerik_kodu = v_eklenecek_srv)
                                           AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                    UNION
                                    SELECT account_number, outlet_location, service_code, campaign_code, servis_frekansi
                                      FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                                     WHERE     account_number = rec.account_number
                                           AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '1', '000', v_outlet_found) = v_outlet_found)
                                           AND service_code IN (SELECT paket_kodu
                                                                  FROM vv_servis_icerik
                                                                 WHERE icerik_kodu = v_eklenecek_srv)
                                           AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')) LOOP
                     from_excel_pack.uye_servis_dusur (in_account_number    => rec.account_number,
                                                       in_outlet_location   => rec_dusur.outlet_location,
                                                       in_service_code      => rec_dusur.service_code,
                                                       in_campaign_code     => rec_dusur.campaign_code,
                                                       in_service_frequence => rec_dusur.servis_frekansi,
                                                       in_hemen_kapat       => 'H',
                                                       in_li_effective_date => v_effective_date,
                                                       in_sebep_kodu        => 'CON',
                                                       in_bedelli           => 'E',
                                                       in_kaynak            => 'DBS',
                                                       in_kontrol_tipi      => 0,
                                                       in_kullanici         => 'SYSTEM',
                                                       out_durum            => v_dusur_durum,
                                                       in_uyari_gec         => 'E',
                                                       in_islem_tip         => 1,
                                                       in_servis_kontrol    => 'E'
                                                      );

                     IF v_dusur_durum <> '0' THEN
                        ROLLBACK;
                        dbs_dba.abone_batch_pack.insert_log (
                              'VIP_MOL_DUSUR: '
                           || rec.account_number
                           || 'nolu abonenin '
                           || rec_dusur.outlet_location
                           || ' nolu outletinden '
                           || rec_dusur.service_code
                           || ' '
                           || rec_dusur.campaign_code
                           || ' düşürülürken hata : '
                           || v_dusur_durum);
                        EXIT;
                     END IF;
                  END LOOP;

                  IF v_dusur_durum = '0' THEN
                     FOR rec_dusur IN (SELECT account_number, outlet_location, campaign_code, service_code
                                         FROM dbs_addr_on_air_activation
                                        WHERE     account_number = rec.account_number
                                              AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '2', '000', v_outlet_found) = v_outlet_found)
                                              AND service_code IN (SELECT paket_kodu
                                                                     FROM vv_servis_icerik
                                                                    WHERE icerik_kodu = v_eklenecek_srv)
                                              AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                                       UNION
                                       SELECT account_number, outlet_location, campaign_code, service_code
                                         FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan
                                        WHERE     account_number = rec.account_number
                                              AND (outlet_location <> v_outlet_found OR DECODE (v_ekleme_turu, '2', '000', v_outlet_found) = v_outlet_found)
                                              AND service_code IN (SELECT paket_kodu
                                                                     FROM vv_servis_icerik
                                                                    WHERE icerik_kodu = v_eklenecek_srv)
                                              AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')) LOOP
                        from_excel_pack.havadan_aktivasyon_srv_iptali (in_account_number => rec_dusur.account_number,
                                                                       in_outlet         => rec_dusur.outlet_location,
                                                                       in_campaign_code  => rec_dusur.campaign_code,
                                                                       o_durum           => v_dusur_durum
                                                                      );

                        IF v_dusur_durum <> '0' THEN
                           ROLLBACK;
                           dbs_dba.abone_batch_pack.insert_log (
                                 'VIP_MOL_DUSUR: '
                              || rec.account_number
                              || 'nolu abonenin '
                              || rec_dusur.outlet_location
                              || ' nolu outletinden '
                              || rec_dusur.service_code
                              || ' '
                              || rec_dusur.campaign_code
                              || ' düşürülürken hata : '
                              || v_dusur_durum);
                           EXIT;
                        END IF;
                     END LOOP;

                     IF v_dusur_durum = '0' THEN
                        COMMIT;
                     END IF;
                  END IF;
               END IF;
            END IF;
         ELSE
            /* herhangi bir spor paketi bulunamadı, adamın havadan MOL ü  varsa düşürülecek, svcdeki sporlu paket iptal olunca otomatik düşer*/
            FOR rec_dusur IN (SELECT account_number, outlet_location, campaign_code, service_code
                                FROM dbs_addr_on_air_activation
                               WHERE     account_number = rec.account_number
                                     AND service_code IN (SELECT paket_kodu
                                                            FROM vv_servis_icerik
                                                           WHERE icerik_kodu = v_eklenecek_srv)
                                     AND 0 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')
                              UNION
                              SELECT account_number, outlet_location, campaign_code, service_code
                                FROM dt_dbs_int_dba.vv_uye_ittp_servisler_havadan
                               WHERE     account_number = rec.account_number
                                     AND service_code IN (SELECT paket_kodu
                                                            FROM vv_servis_icerik
                                                           WHERE icerik_kodu = v_eklenecek_srv)
                                     AND 1 = billing_dbs_int.exclude_control_pkg.is_integration_active ('ITTP_ORDER_INT')) LOOP
               from_excel_pack.havadan_aktivasyon_srv_iptali (in_account_number => rec_dusur.account_number,
                                                              in_outlet         => rec_dusur.outlet_location,
                                                              in_campaign_code  => rec_dusur.campaign_code,
                                                              o_durum           => v_dusur_durum
                                                             );

               IF v_dusur_durum <> '0' THEN
                  ROLLBACK;
                  dbs_dba.abone_batch_pack.insert_log (
                        'VIP_MOL_DUSUR: '
                     || rec.account_number
                     || 'nolu abonenin '
                     || rec_dusur.outlet_location
                     || ' nolu outletinden '
                     || rec_dusur.service_code
                     || ' '
                     || rec_dusur.campaign_code
                     || ' düşürülürken hata : '
                     || v_dusur_durum);
                  EXIT;
               END IF;
            END LOOP;

            IF v_dusur_durum = '0' THEN
               COMMIT;
            END IF;
         END IF;
      END LOOP;
   END vip_multiscreen_ligtv_kontrol;

   PROCEDURE p_promosyan_tarih_duzeltme IS --bsarcan 20092013
      v_promo_tarih       DATE;
      v_promo_expire_date DATE;
      v_mod               NUMBER;
      v_fark              NUMBER;
      v_servis_frekans    NUMBER;

      CURSOR bilgi  IS
         SELECT s.id, s.promo_expire_date, s.fiyat_bitis_tarihi, s.add_closed_date, s.servis_frekansi
           FROM wiz_customer_hp_svc s
          WHERE     MOD (MONTHS_BETWEEN (s.promo_expire_date, s.fiyat_bitis_tarihi), DECODE (s.servis_frekansi,  'A', 12,  'B', 24,  s.servis_frekansi)) <> 0
                AND s.servis_frekansi <> '1'
                AND TRIM (s.promotion_code) IS NOT NULL
                AND s.promo_expire_date > SYSDATE;
   BEGIN
      FOR c1 IN bilgi LOOP
         v_promo_tarih := TO_CHAR (c1.fiyat_bitis_tarihi, 'dd') || TO_CHAR (c1.promo_expire_date, 'mm.yyyy');

         IF c1.servis_frekansi = 'A' THEN
            v_servis_frekans := 12;
         ELSIF c1.servis_frekansi = 'B' THEN
            v_servis_frekans := 24;
         ELSE
            v_servis_frekans := c1.servis_frekansi;
         END IF;

         v_mod         := MOD (MONTHS_BETWEEN (v_promo_tarih, c1.fiyat_bitis_tarihi), v_servis_frekans);

         IF v_mod <> 0 THEN
            v_fark := v_servis_frekans - v_mod;

            IF v_fark <= (v_servis_frekans / 2) THEN
               v_promo_expire_date := ADD_MONTHS (v_promo_tarih, v_fark);
            ELSE
               v_promo_expire_date := ADD_MONTHS (v_promo_tarih, (v_fark - v_servis_frekans));
            END IF;
         ELSE
            v_promo_expire_date := v_promo_tarih;
         END IF;

         UPDATE wiz_customer_hp_svc
            SET promo_expire_date = v_promo_expire_date
          WHERE id = c1.id;
      --dbms_output.put_line (' fbt : ' || c1.fiyat_bitis_tarihi|| '   pbt: '||c1.promo_expire_date || ' spromosyon : '||v_promo_expire_date);

      END LOOP;
   END p_promosyan_tarih_duzeltme;

   PROCEDURE add_izo_product_for_churn IS
      v_offer_from_id       dt_product_dba.offer.offer_id%TYPE;
      v_offer_to_id         dt_product_dba.offer.offer_id%TYPE;
      v_service_account_id  dt_party_dba.party_role_account.party_role_account_id%TYPE;
      v_customer_order_data VARCHAR2 (4000);
      v_user_name           VARCHAR2 (20);
      v_password            VARCHAR2 (20);
      v_company_name        VARCHAR2 (20);
      v_application_name    VARCHAR2 (20);
      v_channel_name        VARCHAR2 (20);
      v_ittp_token          VARCHAR2 (2000);
      o_islem_sonuc_tip     NUMBER;
      o_islem_sonuc_kod     VARCHAR2 (1000);
      o_islem_sonuc_mesaj   VARCHAR2 (2000);
   BEGIN
      v_user_name           := dbs_sabit ('FRAMEWORK_DBS_USER');
      v_password            := dbs_sabit ('FRAMEWORK_DBS_PASS');
      v_company_name        := dbs_sabit ('FRAMEWORK_DBS_COMPANY_NAME');
      v_application_name    := dbs_sabit ('FRAMEWORK_DBS_APP_NAME');
      v_channel_name        := dbs_sabit ('FRAMEWORK_DBS_CHANNEL_NAME');
      v_offer_to_id         := 43276; --IZO_SRV offer_id
      v_offer_from_id       := 43277; --HAVADAN_IZO offer_id

      v_customer_order_data := NULL;
      v_customer_order_data := v_offer_from_id || ':' || v_offer_to_id || '::';
      v_ittp_token          := dbs_dba.ittp_webservice_pack.systemauthenticate_for_dbs (in_username        => v_user_name,
                                                                                        in_password        => v_password,
                                                                                        in_companyname     => v_company_name,
                                                                                        in_applicationname => v_application_name,
                                                                                        in_channelname     => v_channel_name
                                                                                       );

      IF v_ittp_token <> '-1' THEN
         FOR rec IN (SELECT mb.account_number, mb.outlet_location
                       FROM wiz_customer_hp_life wz,
                            mb_abone_statu mb,
                            wiz_equip eq
                      WHERE     mb.account_number = wz.account_number
                            AND wz.customer_type = 'NOR'
                            AND wz.franchise_code IN ('F01', 'F02')
                            AND mb.statu = 'K'
                            AND eq.account_number = mb.account_number
                            AND eq.outlet_location = mb.outlet_location
                            AND eq.converter_type = 'SC'
                            AND dbs_dba.ekipman_pack.ekipman_irdeto_desteklimi (eq.serial_number) = 'E'
                            AND mb.statu_tarihi > SYSDATE - 1
                            AND NOT EXISTS
                                   (SELECT 1
                                      FROM vv_uye_ittp_servisler vv
                                     WHERE vv.account_number = mb.account_number AND vv.outlet_location = mb.outlet_location AND vv.service_code = 'IZO')) LOOP
            SELECT pra.party_role_account_id
              INTO v_service_account_id
              FROM dt_party_dba.party_role_account pra
             WHERE pra.dbs_account_number = rec.account_number AND pra.dbs_outlet_location = rec.outlet_location;

            IF v_customer_order_data IS NOT NULL THEN
               --simülasyon
               dbs_dba.ittp_webservice_pack.addproductstodbsacc (in_serviceaccountid  => v_service_account_id,
                                                                 in_customerorderdata => v_customer_order_data,
                                                                 in_saveorders        => 0,
                                                                 in_token             => v_ittp_token,
                                                                 o_islem_sonuc_tip    => o_islem_sonuc_tip,
                                                                 o_islem_sonuc_kod    => o_islem_sonuc_kod,
                                                                 o_islem_sonuc_mesaj  => o_islem_sonuc_mesaj
                                                                );

               IF o_islem_sonuc_tip = 0 THEN
                  --commitli işlem
                  dbs_dba.ittp_webservice_pack.addproductstodbsacc (in_serviceaccountid  => v_service_account_id,
                                                                    in_customerorderdata => v_customer_order_data,
                                                                    in_saveorders        => 1,
                                                                    in_token             => v_ittp_token,
                                                                    o_islem_sonuc_tip    => o_islem_sonuc_tip,
                                                                    o_islem_sonuc_kod    => o_islem_sonuc_kod,
                                                                    o_islem_sonuc_mesaj  => o_islem_sonuc_mesaj
                                                                   );

                  IF o_islem_sonuc_tip <> 0 THEN
                     ROLLBACK;
                     insert_log (
                           'DBS_DBA.ABONE_BATCH_PACK.add_izo_product_for_churn -1 Account_number:'
                        || rec.account_number
                        || ' outlet_location:'
                        || rec.outlet_location
                        || ' Hata mesajı:'
                        || o_islem_sonuc_mesaj);
                  END IF;
               ELSE
                  ROLLBACK;
                  insert_log (
                        'DBS_DBA.ABONE_BATCH_PACK.add_izo_product_for_churn -2 Account_number:'
                     || rec.account_number
                     || ' outlet_location:'
                     || rec.outlet_location
                     || ' service_code:IZO'
                     || ' campaign_code:IZO'
                     || ' Hata mesajı:'
                     || o_islem_sonuc_mesaj);
               END IF;
            END IF;
         END LOOP;
      ELSE
         insert_log ('DBS_DBA.ABONE_BATCH_PACK.add_izo_product_for_churn - token alinamadi.Job calismadi!!');
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         insert_log ('DBS_DBA.ABONE_BATCH_PACK.add_izo_product_for_churn - Genel Hata - Job çalışamadı!!Hata mesajı:' || SQLERRM);
   END;

   PROCEDURE omega_batch IS --bsarcan
      v_statu         mb_abone_statu.statu%TYPE;
      v_eski_statu    mb_abone_statu.eski_statu%TYPE;
      v_detay_statu   mb_abone_statu.detay_statu%TYPE;
      p_return_status VARCHAR2 (20);
      voutlog         VARCHAR2 (500);
   BEGIN
      FOR r1
         IN (SELECT s.account_number, s.outlet_location
               FROM dbs_dba.mb_abone_statu s
              WHERE     s.statu = 'K'
                    AND (   TRUNC (SYSDATE) > TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (s.account_number, s.statu_tarihi), 2))
                         OR (    TRUNC (SYSDATE) = TRUNC (ADD_MONTHS (bilgi_pack.uye_next_billing_date (s.account_number, s.statu_tarihi), 2))
                             AND EXISTS
                                    (SELECT *
                                       FROM dbs_dba.mb_abone_statu_islem si
                                      WHERE     s.account_number = si.account_number
                                            AND s.outlet_location = si.outlet_location
                                            AND si.islem_tarihi IS NULL
                                            AND TRUNC (si.beklenen_islem_tarihi) > TRUNC (SYSDATE))))) LOOP
         dbs_dba.abone_outlet_statu_pack.outlet_statu_update (r1.account_number,
                                                              r1.outlet_location,
                                                              'SYSTEM',
                                                              SYSDATE,
                                                              v_statu,
                                                              v_eski_statu,
                                                              v_detay_statu,
                                                              p_return_status
                                                             );

         IF p_return_status <> '0' THEN
            log_pack.log_is_emri_hata (NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       'J', -- job ile uyelik iptali toplu islemi
                                       'SYSTEM',
                                       SYSDATE,
                                       'O',
                                       r1.account_number || ' - ' || r1.outlet_location || ' Q statu işleminde hata aldı ' || p_return_status,
                                       voutlog
                                      );
         END IF;

         COMMIT;
      END LOOP;
   END;

   PROCEDURE set_property_for_churn_process (i_process_date IN DATE) IS
      o_durum        VARCHAR2 (4000);
      v_process_date DATE;
   BEGIN
      v_process_date := NVL (i_process_date, SYSDATE);

      FOR rec
         IN (SELECT hp.franchise_code, hp.customer_type, hp.customer_status, ie.*
               FROM ie_uyelik_iptal ie,
                    wiz_customer_hp_life hp
              WHERE     ie.account_number = hp.account_number
                    AND hp.franchise_code = 'F01'
                    AND hp.customer_type = 'NOR'
                    AND ie.durum = 'O'
                    AND ie.giris_tarihi BETWEEN (TRUNC (v_process_date - 1, 'DD') + 19 / 24)
                                            AND (TRUNC (v_process_date, 'DD') + (19 / 24 - (1 / 1440) + (59 / 86400)))
                    AND ie.beklenen_kapanma_tarihi < bilgi_pack.uye_next_billing_date (ie.account_number, ie.giris_tarihi)
                    AND NOT EXISTS
                           (SELECT 1
                              FROM mb_abone_ozellik mb
                             WHERE mb.abone_ozellik_kodu = 239 AND mb.account_number = ie.account_number AND mb.outlet_location = ie.outlet_location)) LOOP
         BEGIN
            abone_detay_pack.mb_abone_ozellik_insert (iaccount_number     => rec.account_number,
                                                      ioutlet_location    => rec.outlet_location,
                                                      iabone_ozellik_kodu => 239,
                                                      ikullanici          => 'SYSTEM',
                                                      durum               => o_durum,
                                                      iozellik_deger      => NULL
                                                     );

            IF o_durum <> '0' THEN
               ROLLBACK;
               dbs_dba.log_pack.log_is_emri_hata (
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  'J',
                  'SYSTEM',
                  SYSDATE,
                  NULL,
                  SUBSTR ('Fesih K statü-AboneOzellikInsert-' || rec.account_number || '-' || rec.outlet_location || '-' || o_durum, 1, 499),
                  o_durum);
            ELSE
               COMMIT;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               ROLLBACK;
               dbs_dba.log_pack.log_is_emri_hata (
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  'J',
                  'SYSTEM',
                  SYSDATE,
                  NULL,
                  SUBSTR ('Fesih K statü-GenelHata-' || rec.account_number || '-' || rec.outlet_location || '-' || o_durum, 1, 499),
                  o_durum);
         END;
      END LOOP;

      /**************LOOP -2 *****************************/
      --239 özelliği olan ve bu özelliği TS girmemişse (F01-NOR)
      BEGIN
         FOR rec
            IN (SELECT hp.franchise_code, hp.customer_type, hp.customer_status, mb.*
                  FROM mb_abone_ozellik mb,
                       wiz_customer_hp_life hp
                 WHERE     mb.account_number = hp.account_number
                       AND hp.franchise_code = 'F01'
                       AND hp.customer_type = 'NOR'
                       AND mb.abone_ozellik_kodu = 239
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM dbs_dba.co_kullanici co
                                WHERE co.kod = mb.giren_kullanici AND co.ust_kod = 'TS_YT')
                       AND NOT EXISTS
                              (SELECT 1
                                 FROM dbs_dba.ie_uyelik_iptal
                                WHERE account_number = mb.account_number AND outlet_location = mb.outlet_location AND durum IN ('O'))
                       AND EXISTS
                              (SELECT 1
                                 FROM dbs_dba.mb_abone_statu ms
                                WHERE     ms.account_number = mb.account_number
                                      AND ms.outlet_location = mb.outlet_location
                                      AND ms.statu NOT IN ('A', 'D', 'S', 'P', 'U'))) LOOP
            BEGIN
               abone_detay_pack.mb_abone_ozellik_delete (iaccount_number     => rec.account_number,
                                                         ioutlet_location    => rec.outlet_location, -- NULL
                                                         iabone_ozellik_kodu => 239,
                                                         ikullanici          => 'SYSTEM',
                                                         durum               => o_durum
                                                        );

               IF o_durum <> '0' THEN
                  ROLLBACK;
                  dbs_dba.log_pack.log_is_emri_hata (
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     NULL,
                     'J',
                     'SYSTEM',
                     SYSDATE,
                     NULL,
                     SUBSTR ('Fesih K statü-AboneOzellikDelete-' || rec.account_number || '-' || rec.outlet_location || '-' || o_durum, 1, 499),
                     o_durum);
               ELSE
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  ROLLBACK;
                  dbs_dba.log_pack.log_is_emri_hata (NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     NULL,
                                                     'J',
                                                     'SYSTEM',
                                                     SYSDATE,
                                                     NULL,
                                                     SUBSTR ('Fesih K statü-' || rec.account_number || '-' || rec.outlet_location || '-' || o_durum, 1, 499),
                                                     o_durum
                                                    );
            END;
         END LOOP;
      END;
   END;

   PROCEDURE churn_k_process (i_process_date IN DATE DEFAULT NULL, i_account_number IN NUMBER DEFAULT NULL, i_outlet_location IN VARCHAR2 DEFAULT NULL) IS
      v_iptal_giris_tarihi         DATE;
      v_iptal_kapanis_tarihi       DATE;
      v_uyelik_iptal_row           dbs_dba.ie_uyelik_iptal%ROWTYPE;
      v_count                      NUMBER;
      v_islem_sonuc_tip            NUMBER;
      v_islem_sonuc_kod            VARCHAR2 (500);
      v_islem_sonuc_mesaj          CLOB;
      v_process_date               DATE;
      v_memo_kodu                  NUMBER;
      v_churn_process_started_date VARCHAR2 (30);
      v_adet                       NUMBER;
      is_exists_record             BOOLEAN;
      is_exists_error              BOOLEAN := FALSE;
      v_statu_tarihi               DATE := SYSDATE;
   BEGIN
      v_iptal_giris_tarihi         := NULL;
      v_iptal_kapanis_tarihi       := NULL;
      v_process_date               := NVL (i_process_date, SYSDATE);
      v_memo_kodu                  := TO_NUMBER (NVL (dbs_sabit ('CHURN_K_PROCESS_MEMO_KODU'), '38968'));
      v_churn_process_started_date := NVL (dbs_sabit ('CHURN_K_PROCESS_START_DATE'), '04/03/2015');
      v_adet                       := 0;

      --F01,NOR ve K statüsünde olan üyeleri alıyoruz
      FOR rec
         IN (SELECT mb.*
               FROM dbs_dba.mb_abone_statu mb,
                    wiz_customer_hp_life hp
              WHERE     mb.statu = 'K'
                    AND mb.account_number = hp.account_number
                    AND hp.franchise_code = 'F01'
                    AND hp.customer_type = 'NOR'
                    AND mb.account_number = NVL (i_account_number, mb.account_number)
                    AND mb.outlet_location = NVL (i_outlet_location, mb.outlet_location)
                    AND (TRUNC (mb.statu_tarihi) >= TO_DATE (v_churn_process_started_date, 'dd/mm/yyyy'))) LOOP
         BEGIN
            --o account ve outlet üzerindeki en son üyelik iptalini alıyoruz
            is_exists_record := TRUE;
            is_exists_error  := FALSE;

            BEGIN
               SELECT *
                 INTO v_uyelik_iptal_row
                 FROM (SELECT   *
                           FROM ie_uyelik_iptal
                          WHERE account_number = rec.account_number AND outlet_location = rec.outlet_location AND durum = 'C'
                       ORDER BY kapanis_tarihi DESC)
                WHERE ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  is_exists_record := FALSE;
            END;

            --K statüsüne geçtiği tarih ile üyelik iptalinin gerçekleştiği tarih aynı ise
            IF is_exists_record THEN
               IF TRUNC (v_uyelik_iptal_row.kapanis_tarihi) = TRUNC (rec.statu_tarihi) THEN
                  --üzerinde Kazanımda kalmak istiyor memosu yok ise
                  SELECT COUNT (1)
                    INTO v_count
                    FROM dbs_dba.co_memo_bilgi co
                   WHERE     co.abone_kodu = rec.account_number
                         AND co.memo_kodu = v_memo_kodu
                         AND co.durum_kodu <> 2
                         AND co.acilis_tarihi >= v_uyelik_iptal_row.kapanis_tarihi;

                  IF v_count = 0 THEN
                     --üyelik iptalini yapıldığı tarihten sonra 7 gün geçmiş ise
                     IF TRUNC (v_uyelik_iptal_row.giris_tarihi) + 7 <= TRUNC (v_process_date) THEN
                        --üye üzerindeki tüm havadanlar düşüyor

                        FOR rec_1
                           IN (SELECT o.offer_cd,
                                      o2.offer_cd parent_offer_cd,
                                      o2.offer_id parent_offer_id,
                                      p.offer_id,
                                      p.product_spec_id,
                                      p.product_id simple_product_id,
                                      p2.product_id AS parent_product_id,
                                      p.service_account_id
                                 FROM dt_product_dba.product p,
                                      dt_product_dba.product p2,
                                      dt_product_dba.offer o,
                                      dt_product_dba.offer o2,
                                      dt_party_dba.party_role_account pra
                                WHERE     p.offer_id = o.offer_id
                                      AND p.parent_id = p2.product_id
                                      AND p2.offer_id = o2.offer_id
                                      AND pra.party_role_account_id = p.service_account_id
                                      AND pra.dbs_account_number = rec.account_number
                                      AND pra.dbs_outlet_location = rec.outlet_location
                                      AND pra.logical_delete_key IS NULL
                                      AND p.logical_delete_key IS NULL
                                      AND p2.logical_delete_key IS NULL
                                      AND o.logical_delete_key IS NULL
                                      AND o2.logical_delete_key IS NULL
                                      AND p.product_status_type_cd <> 'INAKTIF'
                                      AND EXISTS
                                             (SELECT 1
                                                FROM dt_product_dba.product_cat_offer_rel cat_rel,
                                                     dt_product_dba.product_catalog cat
                                               WHERE     cat_rel.offer_from_id = o2.offer_id
                                                     AND cat.product_catalog_cd = cat_rel.product_catalog_cd
                                                     AND cat_rel.product_catalog_cd = 'HAVADAN_AKTIVASYON'
                                                     AND cat.product_catalog_type_cd = 'BUNDLE_OFFER_TYPE'
                                                     AND cat.logical_delete_key IS NULL
                                                     AND cat_rel.logical_delete_key IS NULL
                                                     AND SYSDATE BETWEEN NVL (cat_rel.valid_from, TO_DATE ('01.01.1900', 'DD.MM.YYYY'))
                                                                     AND NVL (cat_rel.valid_thru, TO_DATE ('31.12.9000', 'DD.MM.YYYY')))) LOOP
                           dbs_dba.ittp_webservice_pack.dropproductbyproductid (in_serviceaccountid => rec_1.service_account_id,
                                                                                in_productid        => rec_1.simple_product_id,
                                                                                in_dropdate         => SYSDATE,
                                                                                in_reasoncodecd     => 'DZM', --sebep kodu değiştirilecek
                                                                                o_islem_sonuc_tip   => v_islem_sonuc_tip,
                                                                                o_islem_sonuc_kod   => v_islem_sonuc_kod,
                                                                                o_islem_sonuc_mesaj => v_islem_sonuc_mesaj
                                                                               );

                           IF v_islem_sonuc_tip <> 0 THEN
                              is_exists_error := TRUE;
                              ROLLBACK;
                              dbs_dba.log_pack.log_is_emri_hata (
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 'J',
                                 'SYSTEM',
                                 SYSDATE,
                                 NULL,
                                 SUBSTR (
                                    'churn_k_process-dropProduct' || rec_1.service_account_id || '-' || rec_1.simple_product_id || '-' || v_islem_sonuc_mesaj,
                                    1,
                                    499),
                                 v_islem_sonuc_mesaj);
                              EXIT;
                           END IF;
                        END LOOP;

                        IF NOT is_exists_error THEN
                           --şuanki statü log a atılıyor
                           v_statu_tarihi := SYSDATE;

                           INSERT
                             INTO lg_abone_statu (id,
                                                  account_number,
                                                  outlet_location,
                                                  statu_baslangic_tarihi,
                                                  statu_bitis_tarihi,
                                                  statu,
                                                  eski_statu,
                                                  detay_statu,
                                                  giren_kullanici,
                                                  giris_tarihi,
                                                  degistiren_kullanici,
                                                  degistirme_tarihi
                                                 )
                              VALUES (
                                        dbs_dba.lg_abone_statu_id_seq.NEXTVAL,
                                        rec.account_number,
                                        rec.outlet_location,
                                        rec.statu_tarihi,
                                        v_statu_tarihi, --statu_bitis_tarihi
                                        rec.statu,
                                        rec.eski_statu,
                                        rec.detay_statu,
                                        rec.giren_kullanici,
                                        rec.giris_tarihi,
                                        'SYSTEM',
                                        v_statu_tarihi --degistirme_tarihi
                                                      );

                           --statu ! ye çekiliyor
                           UPDATE mb_abone_statu
                              SET statu                = 'Q',
                                  eski_statu           = rec.statu,
                                  detay_statu          = rec.detay_statu,
                                  statu_tarihi         = v_statu_tarihi,
                                  degistiren_kullanici = 'SYSTEM',
                                  degistirme_tarihi    = v_statu_tarihi
                            WHERE account_number = rec.account_number AND outlet_location = rec.outlet_location;

                           BEGIN
                              dt_complaint_api.churn_integration_pkg.process_bumerang_ticket (rec.account_number, rec.outlet_location, 'K', 'Q', 'SYSTEM');
                           EXCEPTION
                              WHEN OTHERS THEN
                                 dt_complaint_api.churn_integration_pkg.insert_case_log (
                                    NULL,
                                    NULL,
                                    NULL,
                                    1,
                                    'DBS_DBA.ABONE_BATCH_PACK.FESIH_K_STATU',
                                    SUBSTR (
                                          'I_DBS_ACCOUNT_NUMBER => '
                                       || rec.account_number
                                       || ','
                                       || CHR (10)
                                       || 'I_DBS_OUTLET_LOCATION => '''
                                       || rec.outlet_location
                                       || ''','
                                       --                  || CHR (10)
                                       --                  || 'I_IE_UYELIK_IPTAL_ID => NULL,'
                                       || CHR (10)
                                       || 'I_OLD_STATUS => '''
                                       || 'K'
                                       || ''','
                                       || CHR (10)
                                       || 'I_NEW_STATUS => '''
                                       || 'Q'
                                       || ''','
                                       || CHR (10)
                                       || 'IS_NEW_CHURN=>'
                                       || '1'
                                       || 'I_LOGIN_NAME => '''
                                       || 'SYSTEM'
                                       || ''','
                                       || CHR (10)
                                       || 'SQLERRM => '
                                       || SQLERRM,
                                       0,
                                       3999),
                                    NULL,
                                    NULL,
                                    -1);
                           END;

                           COMMIT;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END;
      END LOOP;
   END;

   PROCEDURE new_churn_process_on_air_batch (i_account_number IN NUMBER DEFAULT NULL, i_outlet_location IN VARCHAR2 DEFAULT NULL, o_durum OUT VARCHAR2) IS
      v_uye_uydusu          NUMBER;
      v_offer_from_id       dt_product_dba.offer.offer_id%TYPE;
      v_offer_to_id         dt_product_dba.offer.offer_id%TYPE;
      v_turksat_offer_id    dt_product_dba.offer.offer_id%TYPE;
      v_eutelsat_offer_id   dt_product_dba.offer.offer_id%TYPE;
      v_service_account_id  dt_party_dba.party_role_account.party_role_account_id%TYPE;
      v_user_name           VARCHAR2 (20);
      v_password            VARCHAR2 (20);
      v_company_name        VARCHAR2 (20);
      v_application_name    VARCHAR2 (20);
      v_channel_name        VARCHAR2 (20);
      v_customer_order_data VARCHAR2 (4000);
      v_ittp_token          VARCHAR2 (2000);
      o_islem_sonuc_tip     NUMBER;
      o_islem_sonuc_kod     VARCHAR2 (1000);
      o_islem_sonuc_mesaj   VARCHAR2 (2000);

      CURSOR cur_churn_acc (
         p_account_number   NUMBER,
         p_outlet_location  VARCHAR2) IS
         SELECT *
           FROM dbs_dba.mb_abone_statu mb
          WHERE     mb.statu = 'K'
                AND mb.account_number = NVL (p_account_number, mb.account_number)
                AND mb.outlet_location = NVL (p_outlet_location, mb.outlet_location)
                AND TRUNC (mb.statu_tarihi) >= TRUNC (SYSDATE - 1)
                AND EXISTS
                       (SELECT 1
                          FROM wiz_customer_hp_life hp
                         WHERE     hp.account_number = mb.account_number
                               AND hp.customer_type = 'NOR'
                               AND hp.franchise_code IN ('F01', 'F02')
                               AND hp.hp_cluster IN ('PH', 'LG'))
                AND EXISTS
                       (SELECT 1
                          FROM prod_dba.wiz_equip we1
                         WHERE mb.account_number = we1.account_number AND mb.outlet_location = we1.outlet_location AND we1.converter_type = 'SC')
                AND (   EXISTS
                           (SELECT 1
                              FROM prod_dba.wiz_equip we2
                             WHERE mb.account_number = we2.account_number AND mb.outlet_location = we2.outlet_location AND we2.converter_type = 'ST')
                     OR EXISTS
                           (SELECT 1
                              FROM dbs_dba.eq_ekipman eq
                             WHERE mb.account_number = eq.account_number AND mb.outlet_location = eq.outlet_location AND eq.ekipman_tipi = 248))
                AND NOT EXISTS
                           (SELECT 1
                              FROM dbs_dba.lg_abone_statu lg
                             WHERE     mb.account_number = lg.account_number
                                   AND mb.outlet_location = lg.outlet_location
                                   AND lg.statu = 'K'
                                   AND TRUNC (lg.statu_bitis_tarihi) > ADD_MONTHS (TRUNC (SYSDATE), -6));
   BEGIN
      o_durum             := '0';
      v_offer_from_id     := TO_NUMBER (NVL (dbs_sabit ('NEW_CHURN_PROCESS_OFFER_FROM_ID'), 66201)); --HAVADAN_KZB
      v_turksat_offer_id  := TO_NUMBER (NVL (dbs_sabit ('NEW_CHURN_PROCESS_OFFER_TO_ID_TURKSAT'), 50192)); --TGP_SRV
      v_eutelsat_offer_id := TO_NUMBER (NVL (dbs_sabit ('NEW_CHURN_PROCESS_OFFER_TO_ID_EUTELSAT'), 14801)); --BSL_SRV
      v_user_name         := dbs_sabit ('FRAMEWORK_DBS_USER');
      v_password          := dbs_sabit ('FRAMEWORK_DBS_PASS');
      v_company_name      := dbs_sabit ('FRAMEWORK_DBS_COMPANY_NAME');
      v_application_name  := dbs_sabit ('FRAMEWORK_DBS_APP_NAME');
      v_channel_name      := dbs_sabit ('FRAMEWORK_DBS_CHANNEL_NAME');

      v_ittp_token        := dbs_dba.ittp_webservice_pack.systemauthenticate_for_dbs (in_username        => v_user_name,
                                                                                      in_password        => v_password,
                                                                                      in_companyname     => v_company_name,
                                                                                      in_applicationname => v_application_name,
                                                                                      in_channelname     => v_channel_name
                                                                                     );

      IF v_ittp_token = '-1' THEN
         o_durum := 'ITTP token alinamadi!!-' || v_ittp_token;
         RETURN;
      END IF;

      IF TRIM (v_offer_from_id) IS NULL THEN
         o_durum := 'Kampanya bilgisi eksik!!';
         RETURN;
      END IF;

      FOR rec IN cur_churn_acc (i_account_number, i_outlet_location) LOOP
         o_durum               := '0';

         BEGIN
            SELECT pra.party_role_account_id
              INTO v_service_account_id
              FROM dt_party_dba.party_role_account pra
             WHERE pra.dbs_account_number = rec.account_number AND pra.dbs_outlet_location = rec.outlet_location AND pra.logical_delete_key IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               v_service_account_id := NULL;
         END;

         IF v_service_account_id IS NULL THEN
            ROLLBACK;
            o_durum := 'ServiceAccountId degeri bulunamadi-' || rec.account_number || '-' || rec.outlet_location;
            insert_log ('DBS_DBA.ABONE_BATCH_PACK.new_churn_process-0=' || rec.account_number || '-' || rec.outlet_location || '-' || SQLERRM);
            CONTINUE;
         END IF;

         v_uye_uydusu          := dbs_dba.abone_sorgu_pack.uye_uydusu (p_accountnumber => rec.account_number, p_outletlocation => rec.outlet_location);
         v_offer_to_id         := NULL;

         IF v_uye_uydusu = 1 THEN --eutelsat
            v_offer_to_id := v_eutelsat_offer_id;
         ELSIF v_uye_uydusu = 2 THEN --turksat
            v_offer_to_id := v_turksat_offer_id;
         ELSE
            o_durum := 'Uye uydu bilgisi bulunamadi';
            CONTINUE; --uye uydusu bulunamadı
         END IF;

         v_customer_order_data := NULL;
         v_customer_order_data := v_offer_from_id || ':' || v_offer_to_id || '::';

         IF v_customer_order_data IS NOT NULL THEN
            --simülasyon
            dbs_dba.ittp_webservice_pack.addproductstodbsacc (in_serviceaccountid  => v_service_account_id,
                                                              in_customerorderdata => v_customer_order_data,
                                                              in_saveorders        => 0, --simülasyon için 0 gönderildi
                                                              in_token             => v_ittp_token,
                                                              o_islem_sonuc_tip    => o_islem_sonuc_tip,
                                                              o_islem_sonuc_kod    => o_islem_sonuc_kod,
                                                              o_islem_sonuc_mesaj  => o_islem_sonuc_mesaj
                                                             );

            IF o_islem_sonuc_tip = 0 THEN --basarili ise
               dbs_dba.ittp_webservice_pack.addproductstodbsacc (in_serviceaccountid  => v_service_account_id,
                                                                 in_customerorderdata => v_customer_order_data,
                                                                 in_saveorders        => 1, --commitli islem
                                                                 in_token             => v_ittp_token,
                                                                 o_islem_sonuc_tip    => o_islem_sonuc_tip,
                                                                 o_islem_sonuc_kod    => o_islem_sonuc_kod,
                                                                 o_islem_sonuc_mesaj  => o_islem_sonuc_mesaj
                                                                );

               IF o_islem_sonuc_tip <> 0 THEN --hatali ise
                  o_durum := 'Servis eklenemedi-1' || v_service_account_id || '-' || v_offer_to_id || '-' || o_islem_sonuc_kod || '-' || o_islem_sonuc_mesaj;
                  ROLLBACK;
                  insert_log (
                        'DBS_DBA.ABONE_BATCH_PACK.new_churn_process-1='
                     || v_service_account_id
                     || '-'
                     || v_offer_to_id
                     || '-'
                     || o_islem_sonuc_kod
                     || '-'
                     || o_islem_sonuc_mesaj);
               END IF;
            ELSE
               o_durum := 'Servis eklenemedi-2' || v_service_account_id || '-' || v_offer_to_id || '-' || o_islem_sonuc_kod || '-' || o_islem_sonuc_mesaj;
               ROLLBACK;
               insert_log ('DBS_DBA.ABONE_BATCH_PACK.new_churn_process-2=' || v_service_account_id || '-' || o_islem_sonuc_kod || '-' || o_islem_sonuc_mesaj);
            END IF;

            COMMIT;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         o_durum := 'GenelHata=' || SQLERRM;
         insert_log ('DBS_DBA.ABONE_BATCH_PACK.new_churn_process-GenelHata=' || o_durum);
   END;
END;
/
