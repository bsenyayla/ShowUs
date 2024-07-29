CREATE OR REPLACE PACKAGE BODY DBS_DBA.rama_servis
IS
   --------------------
   -- Talep edilen servis interaktif özellik tasiyorsa, kutu da bunu desteklemeli.
   --------------------
   -- Ekipman uyumu gerektiren farkli servisler gelebilir, (turk sadece interaktif servis degil)..
   -- bunlar için ekipman özellikleri tanimlandi.
   -- Ekipman uyumu gerektiren servisler için, hem ekipmana hem de servise bu özellik eklenir.


   FUNCTION get_resource_ownership_type (i_serial_number VARCHAR2)
      RETURN VARCHAR2
   IS
      v_account_number          NUMBER;
      v_outlet_location         CHAR (3);
      v_ekipman_tipi            NUMBER;
      v_converter_type          CHAR (2);
      v_hp_cluster              VARCHAR2 (10);
      v_count                   NUMBER;
      v_hospaket_bitis          DATE;
      v_ekipman_tip_matrix_id   eq_ekipman_tip_matrix.eq_ekipman_tip_matrix_id%TYPE;
      v_hos_paket_hd            NUMBER;
   BEGIN
      BEGIN
         SELECT account_number, outlet_location, ekipman_tipi
           INTO v_account_number, v_outlet_location, v_ekipman_tipi
           FROM eq_ekipman
          WHERE serial_number = i_serial_number;

         IF v_ekipman_tipi <> 248
         THEN
            RETURN NULL;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT account_number, outlet_location, converter_type
                 INTO v_account_number, v_outlet_location, v_converter_type
                 FROM wiz_equip
                WHERE serial_number = i_serial_number;

               IF v_converter_type = 'SC'
               THEN
                  RETURN 'KIRALIK';
               END IF;

               IF v_converter_type <> 'ST'
               THEN
                  RETURN NULL;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN NULL;
            END;
      END;

      IF v_converter_type = 'ST'
      THEN
         v_hospaket_bitis :=
            hos_paket_uyesi_mi (v_account_number, v_outlet_location, 'E');

         IF v_hospaket_bitis IS NOT NULL
         THEN
            SELECT COUNT (1)
              INTO v_hos_paket_hd
              FROM wiz_equip w, eq_ekipman_tip_matrix eq
             WHERE     TRIM (W.MANUFACTURER) = TRIM (EQ.MANUFACTURER)
                   AND TRIM (W.CONVERTER_TYPE) = TRIM (EQ.CONVERTER_TYPE)
                   AND TRIM (W.CONVERTER_MODEL) = TRIM (EQ.CONVERTER_MODEL)
                   AND W.SERIAL_NUMBER = i_serial_number
                   AND EXISTS
                          (SELECT *
                             FROM pr_urun_ozellik_tanim o
                            WHERE     O.OZELLIK_KODU = 33
                                  AND O.EKIPMAN_TIP_MATRIX_ID =
                                         EQ.EQ_EKIPMAN_TIP_MATRIX_ID)
                   AND NOT EXISTS
                              (SELECT *
                                 FROM pr_urun_ozellik_tanim o
                                WHERE     O.OZELLIK_KODU IN (103, 119)
                                      AND O.EKIPMAN_TIP_MATRIX_ID =
                                             EQ.EQ_EKIPMAN_TIP_MATRIX_ID);



            IF v_hos_paket_hd > 0
            THEN
               RETURN 'KIRALIK';
            END IF;
         END IF;
      END IF;

      BEGIN
         SELECT hp_cluster
           INTO v_hp_cluster
           FROM wiz_customer_hp_life
          WHERE account_number = v_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF v_hp_cluster IN ('LG', 'VS')
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM eq_ekipman_sahibi_kim kim
          WHERE     serial_number = i_serial_number
                AND kim.sahiplik_tipi = 1
                AND ekipman_sahibi_tipi = 1
                AND kayit_iptal = 'H';

         IF v_count > 0
         THEN
            RETURN 'KIRALIK';
         ELSE
            RETURN 'SATILIK';
         END IF;
      ELSE
         SELECT COUNT (1)
           INTO v_count
           FROM eq_ekipman_sahibi_kim kim
          WHERE     serial_number = i_serial_number
                AND kim.sahiplik_tipi = 0
                AND ekipman_sahibi_tipi = 1
                AND kayit_iptal = 'H';

         IF v_count > 0
         THEN
            RETURN 'SATILIK';
         ELSE
            RETURN 'KIRALIK';
         END IF;
      END IF;
   END get_resource_ownership_type;

   
   PROCEDURE servis_ekipman_uyum_ittp (in_account_number    IN     NUMBER,
                                       in_outlet_location   IN     VARCHAR2,
                                       in_servis_kodu       IN     VARCHAR2,
                                       in_cagrilan_yer      IN     VARCHAR2,
                                       o_sonuckod              OUT VARCHAR2,
                                       o_aciklama              OUT VARCHAR2,
                                       o_dusur                 OUT VARCHAR2)
   IS
      v_sql               VARCHAR2 (2000);
      v_ekipman_tipi      VARCHAR2 (10);
      v_irdeto_destekli   CHAR (1);

      v_sifreleme_tipi    VARCHAR2 (10);
      v_available         NUMBER;
      v_sahiplik          VARCHAR2 (10);
      v_offer_cd          VARCHAR2 (10);
      v_brand             wiz_customer_hp_life.hp_cluster%TYPE;
      v_franchise_code    wiz_customer_hp_life.franchise_code%TYPE;
      v_dusur             VARCHAR2 (20) := NULL;
      v_customer_type     wiz_customer_hp_life.customer_type%TYPE;
      v_count             NUMBER;
      v_client_info       VARCHAR2 (4000);
      v_offerid           NUMBER;
      v_count_ownership   NUMBER := 0;
      v_count_hd          NUMBER := 0;
   BEGIN
      o_dusur := 'H';
      o_sonuckod := '0';

      /*Tüm kontrollerde kullanılacak  müşteri bilgileri bulunuyor*/
      BEGIN
         SELECT hp_cluster, franchise_code, customer_type
           INTO v_brand, v_franchise_code, v_customer_type
           FROM wiz_customer_hp_life
          WHERE account_number = in_account_number;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            o_sonuckod := '-1';
            o_aciklama := 'Servis-Ekipman Uyumu : STB Bulunamadı';
            RETURN;
      END;

      /*ittp tarafında yapılacak tüm kontroller için acc-outlet altındaki tüm ekipmanlar alınıyor*/
      FOR rec
         IN (SELECT 'KUTU' AS tip,
                    serial_number,
                    eq_ekipman_tip_matrix_id,
                    irdeto_destekli
               FROM wiz_equip w
                    JOIN eq_ekipman_tip_matrix mx
                       ON (    TRIM (mx.manufacturer) = TRIM (w.manufacturer)
                           AND TRIM (mx.converter_type) =
                                  TRIM (w.converter_type)
                           AND TRIM (mx.converter_model) =
                                  TRIM (w.converter_model))
              WHERE     account_number = in_account_number
                    AND outlet_location = in_outlet_location
                    AND mx.converter_type = 'ST'
             UNION ALL
             SELECT 'KART' AS tip,
                    serial_number,
                    eq_ekipman_tip_matrix_id,
                    irdeto_destekli
               FROM wiz_equip w
                    JOIN eq_ekipman_tip_matrix mx
                       ON (    TRIM (mx.manufacturer) = TRIM (w.manufacturer)
                           AND TRIM (mx.converter_type) =
                                  TRIM (w.converter_type)
                           AND TRIM (mx.converter_model) =
                                  TRIM (w.converter_model))
              WHERE     account_number = in_account_number
                    AND outlet_location = in_outlet_location
                    AND mx.converter_type = 'SC'
             UNION ALL
             SELECT 'MODÜL' AS tip,
                    serial_number,
                    eq_ekipman_tip_matrix_id,
                    irdeto_destekli
               FROM eq_ekipman eq
                    JOIN eq_ekipman_tip_matrix mx
                       ON (    TO_CHAR (eq.ekipman_tipi) =
                                  TRIM (mx.converter_type)
                           AND NVL (TO_CHAR (eq.ekipman_modul_tipi), -1) =
                                  NVL (TRIM (mx.converter_model), -1))
              WHERE     account_number = in_account_number
                    AND outlet_location = in_outlet_location
                    AND eq.ekipman_tipi = '248')
      LOOP
         v_dusur := NULL;
         v_sahiplik := NULL;

         IF in_cagrilan_yer = 'EKIPMAN_EKLEME'
         THEN
            /* Control type 4 TIC ve YTI ler için ekipman kısıtlaması BAŞLANGIÇ*/
            /*İlk aşamada bu müşteri tipi için bir kısıt var mı ona bakıyoruz*/
            SELECT COUNT (1)
              INTO v_count
              FROM dt_product_api.vw_service_res_convenience
             WHERE     TYPE = 'RESOURCE_SPEC'
                   AND res_party_role_account_spec_cd = v_customer_type
                   AND resource_spec_type_cd = rec.tip
                   AND SYSDATE BETWEEN valid_from AND valid_thru;

            IF v_count > 1
            THEN
               /*Müşteri tipine göre kısıt bulundu, ekipmanla tekrar sorgulanıyor*/
               BEGIN
                  SELECT is_available
                    INTO v_available
                    FROM dt_product_api.vw_service_res_convenience
                   WHERE     TYPE = 'RESOURCE_SPEC'
                         AND res_party_role_account_spec_cd = v_customer_type
                         AND dbs_eq_ekipman_tip_matrix_id =
                                rec.eq_ekipman_tip_matrix_id
                         AND SYSDATE BETWEEN valid_from AND valid_thru;

                  IF v_available <> 1
                  THEN
                     o_sonuckod := '-1';
                     o_aciklama :=
                        v_customer_type || ' abone ile bu ekipman eklenemez';
                     RETURN;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     --bu kontrol tipi sadece available olanları tutar, bu yüzden no_data_found da hata vermeliyiz.
                     o_sonuckod := '-1';
                     o_aciklama :=
                        v_customer_type || ' abone ile bu ekipman eklenemez';
                     RETURN;
               END;
            END IF;
         END IF;

         IF in_cagrilan_yer = 'SERVIS_EKLEME'
         THEN
            /*önce ctpyoworks , sonra ownership sonra type 3*/
            /*offer_id yi buluyoruz*/
            BEGIN
               v_offer_cd := in_servis_kodu || '_SRV';
               v_sahiplik := get_resource_ownership_type (rec.serial_number);

               SELECT offer_id
                 INTO v_offerid
                 FROM dt_product_dba.offer
                WHERE offer_cd = v_offer_cd;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  o_sonuckod := '-1';
                  o_aciklama := 'ITTP Offerid bulunamadı ' || v_offer_cd;
            END;

            /*bulduğumuz offerid leri içeren tüm service_specler için kısıtlama var mı kontrol ediyoruz*/
            FOR offer_rec
               IN (SELECT ss.service_spec_id,
                          ss.service_spec_cd,
                          ss.service_spec_type_cd
                     FROM dt_product_dba.offer o,
                          dt_product_dba.product_spec_srv_spec_rel psr,
                          dt_product_dba.service_spec ss
                    WHERE     o.product_spec_id = psr.product_spec_id
                          AND psr.service_spec_id = ss.service_spec_id
                          AND psr.logical_delete_key IS NULL
                          AND SYSDATE BETWEEN psr.valid_from
                                          AND psr.valid_thru
                          AND o.offer_id = v_offerid
                   UNION
                   SELECT ss.service_spec_id,
                          ss.service_spec_cd,
                          ss.service_spec_type_cd
                     FROM dt_product_dba.offer o,
                          dt_product_dba.product_spec_srv_spec_rel psr,
                          dt_product_dba.service_spec_srel ssr,
                          dt_product_dba.service_spec ss
                    WHERE     o.product_spec_id = psr.product_spec_id
                          AND psr.service_spec_id = ssr.service_spec_from_id
                          AND psr.logical_delete_key IS NULL
                          AND SYSDATE BETWEEN psr.valid_from
                                          AND psr.valid_thru
                          AND ssr.logical_delete_key IS NULL
                          AND SYSDATE BETWEEN ssr.valid_from
                                          AND ssr.valid_thru
                          AND ssr.service_spec_to_id = ss.service_spec_id
                          AND o.offer_id = v_offerid)
            LOOP
               /*Control type 2 CW ekipmanla alınamaz kontrolü BAŞLANGIÇ*/
               BEGIN
                  SELECT is_available
                    INTO v_available
                    FROM dt_product_api.vw_service_res_convenience
                   WHERE     TYPE = '2'
                         AND service_spec_cd = offer_rec.service_spec_cd
                         AND char_type = rec.tip
                         AND res_char_spec_cd = 'SIFRELEME_METODU'
                         AND res_char_spec_value_cd =
                                CASE rec.irdeto_destekli
                                   WHEN 'E' THEN 'IRDETO'
                                   WHEN 'H' THEN 'CW'
                                END
                         AND SYSDATE BETWEEN valid_from AND valid_thru;

                  IF v_available <> 1
                  THEN
                     --control 2 den geçemedi
                     o_sonuckod := '-1';
                     o_aciklama :=
                        in_servis_kodu || ' bu ekipmanla alınamaz.';
                     RETURN;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT is_available
                          INTO v_available
                          FROM dt_product_api.vw_service_res_convenience
                         WHERE     TYPE = '2'
                               AND service_spec_cd =
                                      offer_rec.service_spec_cd
                               AND char_type = rec.tip
                               AND res_char_spec_cd = 'EKIPMAN_TIPI'
                               AND res_char_spec_value_cd =
                                      DECODE (rec.tip,
                                              'MODÜL', 'MODUL',
                                              rec.tip)
                               AND SYSDATE BETWEEN valid_from AND valid_thru;

                        IF v_available <> 1
                        THEN
                           --control 2 den geçemedi
                           o_sonuckod := '-1';
                           o_aciklama :=
                              in_servis_kodu || ' bu ekipmanla alınamaz.';
                           RETURN;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           NULL; /*bu kontrol tipi sınırlayıcıdır, is_available = 0 bulamadığımız sürece hata vermiyoruz.*/
                     END;
               END;
            END LOOP;

            /*Control type 2 CW ekipmanla alınamaz kontrolü BİTİŞ*/
            IF rec.tip = 'KUTU' OR rec.tip = 'MODÜL'
            THEN
               BEGIN
                  SELECT COUNT (1)
                    INTO v_count_ownership
                    FROM dt_product_api.vw_service_res_convenience a
                   WHERE     TYPE = 'OWNRSHIP_ELIGIBILITY'
                         AND SUBSTR (a.offer_cd, 1, 3) = in_servis_kodu
                         AND SYSDATE BETWEEN valid_from AND valid_thru;

                  IF v_count_ownership = 0
                  THEN
                     NULL;
                  ELSE
                     BEGIN
                        SELECT is_available
                          INTO v_available
                          FROM dt_product_api.vw_service_res_convenience
                         WHERE     TYPE = 'OWNRSHIP_ELIGIBILITY'
                               AND offer_cd = v_offer_cd
                               AND res_service_provider_cd = v_franchise_code
                               AND sahiplik_tipi = v_sahiplik
                               AND res_party_role_account_spec_cd =
                                      v_customer_type
                               AND ROWNUM = 1;

                        IF v_available <> 1
                        THEN
                           o_sonuckod := '-1';
                           o_aciklama :=
                                 'Müşteri tipi ya da franchise '
                              || in_servis_kodu
                              || ' servisini '
                              || v_sahiplik
                              || ' olarak almak için uygun değil.';
                           o_dusur := 'E';
                           RETURN;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           o_sonuckod := '-1';
                           o_aciklama :=
                                 'Müşteri tipi ya da franchise '
                              || in_servis_kodu
                              || ' servisini '
                              || v_sahiplik
                              || ' olarak almak için uygun değil.';
                           o_dusur := 'E';
                           RETURN;
                     END;
                  END IF;
               END;
            END IF;

            /*control type 3 HD Kutu kısıtı BAŞLANGIÇ */
            /*ilk önce servis üzerinde kısıt var mı bakıyoruz, service_type_action_cd yi de bir sonraki adımda kullanmak üzere alıyoruz*/
            BEGIN
               SELECT service_action_type_cd
                 INTO v_dusur
                 FROM dt_product_api.vw_service_res_convenience a
                WHERE     TYPE = '3'
                      AND a.offer_cd = v_offer_cd
                      AND TRIM (resource_spec_type_cd) = TRIM (rec.tip)
                      AND SYSDATE BETWEEN valid_from AND valid_thru
                      AND ROWNUM = 1; -- TODO: İlerde düşürme tipleri değişirse düzeltilmeli.
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;          /*bu offer için bir kısıt bulunamadı, devam*/
            END;

            IF v_dusur IS NOT NULL
            THEN
               BEGIN
                  IF v_sahiplik IS NULL
                  THEN
                     o_sonuckod := '-1';
                     o_aciklama := 'Ekipman sahiplik tipi bulunamadı';
                     RETURN;
                  END IF;

                  SELECT is_available
                    INTO v_available
                    FROM dt_product_api.vw_service_res_convenience
                   WHERE     TYPE = '3'
                         AND sahiplik_tipi = v_sahiplik
                         AND dbs_eq_ekipman_tip_matrix_id =
                                rec.eq_ekipman_tip_matrix_id
                         AND offer_cd = v_offer_cd
                         AND SYSDATE BETWEEN valid_from AND valid_thru;

                  IF v_available <> 1
                  THEN
                     o_sonuckod := '-1';
                     o_aciklama :=
                        in_servis_kodu || ' bu ekipman ile eklenemez';
                     RETURN;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     /*control type 3 sadece o servisi alabilecekleri tutar, bu sebeple no_data_found durumunda, bu ekipmana, bu servis için izin verilmemiş demektir.*/
                     IF v_dusur = 'YASAK_DUSUR'
                     THEN
                        o_dusur := 'E';
                     END IF;

                     o_sonuckod := '-1';
                     o_aciklama :=
                        in_servis_kodu || ' bu ekipman ile kullanılamaz.';
                     RETURN;
               END;
            END IF;
         END IF;
      END LOOP;
   END servis_ekipman_uyum_ittp;

   FUNCTION uye_kampanya_kontrolu (in_account_number      IN NUMBER,
                                   in_outlet_location     IN CHAR,
                                   in_servis_kodu         IN CHAR,
                                   in_kampanya_kodu       IN CHAR,
                                   in_li_effective_date   IN DATE)
      RETURN NUMBER
   IS
      v_count            NUMBER;
      v_franchise_code   CHAR (3);
      v_uye_tipi         CHAR (3);
      v_stb_tipi         CHAR (2);
      v_is_emri_var      NUMBER;
      v_return_value     NUMBER := 0;
      v_durum            VARCHAR2 (256);
      v_uyelik_durum     VARCHAR2 (16);
   BEGIN
      SELECT lf.franchise_code, lf.customer_type, lf.hp_cluster
        INTO v_franchise_code, v_uye_tipi, v_stb_tipi
        FROM wiz_customer_hp_life lf
       WHERE lf.account_number = in_account_number;

      -- Üyelik durumu kontrol ediliyor. Aktif, sus, don
      uye_kontrol_pack.uye_sus_mu (in_account_number,
                                   in_outlet_location,
                                   v_durum);

      IF v_durum != '0'
      THEN
         v_uyelik_durum := 'SUS';                           -- Uye sus durumda
      ELSE
         uye_kontrol_pack.uye_donmus_mu (in_account_number,
                                         in_outlet_location,
                                         v_durum);

         IF v_durum != '0'
         THEN
            v_uyelik_durum := 'DON';                          -- Don durumunda
         ELSE
            v_uyelik_durum := 'AKTIF';                    -- Üye aktif durumda
         END IF;
      END IF;

      v_is_emri_var := 0;
      v_return_value := 0;

      IF v_uyelik_durum = 'DON'
      THEN
         FOR dondurma_rec
            IN (  SELECT b.id, b.job_code
                    FROM ie_uyelik_dondurma a, ie_uyelik_dondurma_servis b
                   WHERE     a.account_number = in_account_number
                         AND a.outlet_location = in_outlet_location
                         AND a.id = b.uyelik_dondurma_id
                         AND b.campaign_code = in_kampanya_kodu
                         AND b.service_code IN (SELECT c.service_code
                                                  FROM pr_servis_takip a,
                                                       pr_servis_takip_detay b,
                                                       pr_yasak_zorunlu_servis_takip c
                                                 WHERE     a.kod =
                                                              b.servis_takip_kodu
                                                       AND a.kod =
                                                              c.servis_takip_kodu
                                                       AND a.service_code =
                                                              in_servis_kodu
                                                       AND a.franchise_code =
                                                              v_franchise_code
                                                       AND a.listeden_gizle =
                                                              'H'
                                                       AND (   a.bitis_tarihi
                                                                  IS NULL
                                                            OR a.bitis_tarihi >
                                                                  SYSDATE)
                                                       AND (   a.stb_tipi
                                                                  IS NULL
                                                            OR a.stb_tipi =
                                                                  v_stb_tipi)
                                                       AND b.customer_type =
                                                              v_uye_tipi
                                                       AND c.yasakmi = 'E')
                         AND TRIM (b.promotion_code) IS NOT NULL
                         AND a.durum = 'D'
                         AND b.add_closed_date <= in_li_effective_date
                         AND b.eklenecek_mi = 'E'
                         AND b.durum = 2
                ORDER BY b.add_closed_date DESC, b.id DESC)
         LOOP
            v_is_emri_var := 1;

            IF dondurma_rec.job_code = 'ADD'
            THEN
               v_return_value := 1;
            ELSE     -- is_emri var ama son satır add satırı degil yetki iste.
               v_return_value := 0;
            END IF;

            EXIT;                                -- ilk kayıttan sonra çıkacak
         END LOOP;

         IF v_is_emri_var = 0
         THEN               -- iş emri yoksa üyeye üzerinde ki servislere bak.
            SELECT COUNT (*)
              INTO v_return_value
              FROM ie_uyelik_dondurma a, ie_uyelik_dondurma_servis b
             WHERE     a.account_number = in_account_number
                   AND a.outlet_location = in_outlet_location
                   AND a.id = b.uyelik_dondurma_id
                   AND b.campaign_code = in_kampanya_kodu
                   AND b.service_code IN (SELECT c.service_code
                                            FROM pr_servis_takip a,
                                                 pr_servis_takip_detay b,
                                                 pr_yasak_zorunlu_servis_takip c
                                           WHERE     a.kod =
                                                        b.servis_takip_kodu
                                                 AND a.kod =
                                                        c.servis_takip_kodu
                                                 AND a.service_code =
                                                        in_servis_kodu
                                                 AND a.franchise_code =
                                                        v_franchise_code
                                                 AND a.listeden_gizle = 'H'
                                                 AND (   a.bitis_tarihi
                                                            IS NULL
                                                      OR a.bitis_tarihi >
                                                            SYSDATE)
                                                 AND (   a.stb_tipi IS NULL
                                                      OR a.stb_tipi =
                                                            v_stb_tipi)
                                                 AND b.customer_type =
                                                        v_uye_tipi
                                                 AND c.yasakmi = 'E')
                   AND TRIM (b.promotion_code) IS NOT NULL
                   AND a.durum = 'D'
                   AND b.promo_expire_date > a.dondurma_tarihi
                   AND b.eklenecek_mi = 'E'
                   AND b.durum = 1;
         END IF;
      ELSIF v_uyelik_durum = 'SUS'
      THEN
         FOR kapama_rec
            IN (  SELECT b.id, b.job_code
                    FROM ie_uyelik_kapama a, ie_uyelik_kapama_servis b
                   WHERE     a.account_number = in_account_number
                         AND a.outlet_location = in_outlet_location
                         AND a.id = b.uyelik_kapama_id
                         AND b.campaign_code = in_kampanya_kodu
                         AND b.service_code IN (SELECT c.service_code
                                                  FROM pr_servis_takip a,
                                                       pr_servis_takip_detay b,
                                                       pr_yasak_zorunlu_servis_takip c
                                                 WHERE     a.kod =
                                                              b.servis_takip_kodu
                                                       AND a.kod =
                                                              c.servis_takip_kodu
                                                       AND a.service_code =
                                                              in_servis_kodu
                                                       AND a.franchise_code =
                                                              v_franchise_code
                                                       AND a.listeden_gizle =
                                                              'H'
                                                       AND (   a.bitis_tarihi
                                                                  IS NULL
                                                            OR a.bitis_tarihi >
                                                                  SYSDATE)
                                                       AND (   a.stb_tipi
                                                                  IS NULL
                                                            OR a.stb_tipi =
                                                                  v_stb_tipi)
                                                       AND b.customer_type =
                                                              v_uye_tipi
                                                       AND c.yasakmi = 'E')
                         AND TRIM (b.promotion_code) IS NOT NULL
                         AND a.durum = 'K'
                         AND b.add_closed_date <= in_li_effective_date
                         AND b.eklenecek_mi = 'E'
                         AND b.durum = 2
                ORDER BY b.add_closed_date DESC, b.id DESC)
         LOOP
            v_is_emri_var := 1;

            IF kapama_rec.job_code = 'ADD'
            THEN
               v_return_value := 1;
            ELSE     -- is_emri var ama son satır add satırı degil yetki iste.
               v_return_value := 0;
            END IF;

            EXIT;                                -- ilk kayıttan sonra çıkacak
         END LOOP;

         IF v_is_emri_var = 0
         THEN               -- iş emri yoksa üyeye üzerinde ki servislere bak.
            SELECT COUNT (*)
              INTO v_return_value
              FROM ie_uyelik_kapama a, ie_uyelik_kapama_servis b
             WHERE     a.account_number = in_account_number
                   AND a.outlet_location = in_outlet_location
                   AND a.id = b.uyelik_kapama_id
                   AND b.campaign_code = in_kampanya_kodu
                   AND b.service_code IN (SELECT c.service_code
                                            FROM pr_servis_takip a,
                                                 pr_servis_takip_detay b,
                                                 pr_yasak_zorunlu_servis_takip c
                                           WHERE     a.kod =
                                                        b.servis_takip_kodu
                                                 AND a.kod =
                                                        c.servis_takip_kodu
                                                 AND a.service_code =
                                                        in_servis_kodu
                                                 AND a.franchise_code =
                                                        v_franchise_code
                                                 AND a.listeden_gizle = 'H'
                                                 AND (   a.bitis_tarihi
                                                            IS NULL
                                                      OR a.bitis_tarihi >
                                                            SYSDATE)
                                                 AND (   a.stb_tipi IS NULL
                                                      OR a.stb_tipi =
                                                            v_stb_tipi)
                                                 AND b.customer_type =
                                                        v_uye_tipi
                                                 AND c.yasakmi = 'E')
                   AND TRIM (b.promotion_code) IS NOT NULL
                   AND a.durum = 'K'
                   AND b.promo_expire_date > in_li_effective_date
                   AND b.eklenecek_mi = 'E'
                   AND b.durum = 1;
         END IF;
      ELSE
         FOR uye_servis_rec
            IN (  SELECT wol.id, wol.job_code
                    FROM wiz_wo_line_items wol, wiz_work_order wo
                   WHERE     wol.work_order_number = wo.work_order_number
                         AND wo.account_number = in_account_number
                         AND wol.outlet_location = in_outlet_location
                         AND wol.wo_status = 'O'
                         AND wo.wo_status IN ('O', 'P')
                         AND TRIM (wol.promotion_code) IS NOT NULL
                         AND li_effective_date <= in_li_effective_date
                         AND campaign_code = in_kampanya_kodu
                         AND wol.service_code IN (SELECT c.service_code
                                                    FROM pr_servis_takip a,
                                                         pr_servis_takip_detay b,
                                                         pr_yasak_zorunlu_servis_takip c
                                                   WHERE     a.kod =
                                                                b.servis_takip_kodu
                                                         AND a.kod =
                                                                c.servis_takip_kodu
                                                         AND a.service_code =
                                                                in_servis_kodu
                                                         AND a.franchise_code =
                                                                v_franchise_code
                                                         AND a.listeden_gizle =
                                                                'H'
                                                         AND (   a.bitis_tarihi
                                                                    IS NULL
                                                              OR a.bitis_tarihi >
                                                                    SYSDATE)
                                                         AND (   a.stb_tipi
                                                                    IS NULL
                                                              OR a.stb_tipi =
                                                                    v_stb_tipi)
                                                         AND b.customer_type =
                                                                v_uye_tipi
                                                         AND c.yasakmi = 'E')
                ORDER BY li_effective_date DESC, wol.id DESC)
         LOOP
            v_is_emri_var := 1;

            IF uye_servis_rec.job_code = 'ADD'
            THEN
               v_return_value := 1;
            ELSE     -- is_emri var ama son satır add satırı degil yetki iste.
               v_return_value := 0;
            END IF;

            EXIT;                                -- ilk kayıttan sonra çıkacak
         END LOOP;

         IF v_is_emri_var = 0
         THEN
            SELECT COUNT (*)
              INTO v_return_value
              FROM wiz_customer_hp_svc
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND campaign_code = in_kampanya_kodu
                   AND service_code IN (SELECT c.service_code
                                          FROM pr_servis_takip a,
                                               pr_servis_takip_detay b,
                                               pr_yasak_zorunlu_servis_takip c
                                         WHERE     a.kod =
                                                      b.servis_takip_kodu
                                               AND a.kod =
                                                      c.servis_takip_kodu
                                               AND a.service_code =
                                                      in_servis_kodu
                                               AND a.franchise_code =
                                                      v_franchise_code
                                               AND a.listeden_gizle = 'H'
                                               AND (   a.bitis_tarihi IS NULL
                                                    OR a.bitis_tarihi >
                                                          SYSDATE)
                                               AND (   a.stb_tipi IS NULL
                                                    OR a.stb_tipi =
                                                          v_stb_tipi)
                                               AND b.customer_type =
                                                      v_uye_tipi
                                               AND c.yasakmi = 'E')
                   AND TRIM (promotion_code) IS NOT NULL
                   AND promo_expire_date > in_li_effective_date;
         END IF;
      END IF;

      RETURN v_return_value;
   END uye_kampanya_kontrolu;

   /*bozturkmen servisekipmanuyumu çağıran tüm prosedürler dbms_application_info.set_client_info ile 'SERVIS_EKLEME' ya da 'EKIPMAN_EKLEME' şeklinde çağırmalıdır.*/
   PROCEDURE servisekipmanuyum (in_account_number    IN     NUMBER,
                                in_outlet_location   IN     VARCHAR2,
                                in_servis_kodu       IN     VARCHAR2,
                                in_kullanici         IN     VARCHAR2,
                                out_aciklama         IN OUT VARCHAR2,
                                out_durum               OUT VARCHAR2,
                                out_error_type          OUT NUMBER,
                                out_error_code          OUT VARCHAR2,
                                out_servis_dusur        OUT VARCHAR2,
                                in_cagrilan_yer      IN     VARCHAR2)
   IS
      vozellikliservis             NUMBER (1) := 0;
      vozellikliservisiceren       NUMBER (1) := 0;
      out_ekipman_ozellik_uyumlu   VARCHAR2 (1) := 'H';
      vcount                       NUMBER;
      vtempaciklama                VARCHAR2 (250);
      vkutuluuyelik                NUMBER (1);
      v_adet                       NUMBER;

      TYPE rpaketozellik IS RECORD
      (
         icerik_kodu    VARCHAR2 (5),
         ozellik_kodu   VARCHAR2 (5)
      );

      TYPE tpaketozellik IS TABLE OF rpaketozellik;

      vpaketozellik                tpaketozellik;
      v_ekipman_tip_matrix_id      NUMBER (10);

      -- bizim servisimiz ekipman uyumu gerektiren servislerden mi ?
      -- öyleyse hangi özellikleri içeriyor.
      CURSOR cservisekipmanuyumu
      IS
         SELECT a.icerik_kodu, b.ozellik_kodu
           FROM vv_servis_icerik a,
                (SELECT urun_kodu, ozellik_kodu -- ekipman uyumu gerektiren tüm servisler
                   FROM pr_urun_ozellik_tanim
                  WHERE     urun_tipi = '2'
                        AND ozellik_kodu IN (SELECT DISTINCT ozellik_kodu -- tüm ekipman özellikleri
                                               FROM pr_urun_ozellik_tanim
                                              WHERE urun_tipi = '6')) b
          WHERE     a.paket_kodu = in_servis_kodu
                AND (a.icerik_kodu = b.urun_kodu);
   BEGIN
      out_servis_dusur := 'H';

      OPEN cservisekipmanuyumu;

      FETCH cservisekipmanuyumu BULK COLLECT INTO vpaketozellik;

      CLOSE cservisekipmanuyumu;

      vcount := vpaketozellik.COUNT;

      IF vpaketozellik.COUNT = 0
      THEN
         vozellikliservis := 0;
         vozellikliservisiceren := 0;
      ELSE
         FOR i IN 1 .. vcount
         LOOP
            IF in_servis_kodu = vpaketozellik (i).icerik_kodu
            THEN
               vozellikliservis := 1;
            ELSE
               --HD2 sevisinin altinda sadece LHD sinyali var.MGG nin altinda OY1 var ama baska servisler de var. Bu ikisini ayirabilmek için asagidaki kod yazildi.
               --Ayrica baska bir sebep de mesela kutu hem push vod destekli hemde hd destekli ise bu servis eklenebilir olayini yapabilmek için
               SELECT COUNT (*)
                 INTO v_adet
                 FROM vv_servis_icerik a
                WHERE     a.paket_kodu = in_servis_kodu
                      AND a.icerik_kodu NOT IN (SELECT icerik_kodu
                                                  FROM vv_servis_icerik b,
                                                       (SELECT urun_kodu -- ekipman uyumu gerektiren tüm servisler
                                                          FROM pr_urun_ozellik_tanim
                                                         WHERE     urun_tipi =
                                                                      '2'
                                                               AND ozellik_kodu IN (SELECT DISTINCT
                                                                                           ozellik_kodu -- tüm ekipman özellikleri
                                                                                      FROM pr_urun_ozellik_tanim
                                                                                     WHERE urun_tipi =
                                                                                              '6'))
                                                       c
                                                 WHERE     b.paket_kodu =
                                                              in_servis_kodu
                                                       AND (b.icerik_kodu =
                                                               c.urun_kodu))
                      AND EXISTS
                             (SELECT *
                                FROM vv_servis_icerik b
                               WHERE     a.icerik_kodu = b.paket_kodu
                                     AND a.icerik_kodu = b.icerik_kodu);

               IF v_adet > 0
               THEN
                  vozellikliservisiceren := 1;
               ELSE
                  vozellikliservis := 1;
               END IF;
            END IF;

            --out_ekipman_ozellik_uyumlu :=
            ekipman_pack.ekipman_ozellik (NULL,
                                          in_account_number,
                                          in_outlet_location,
                                          vpaketozellik (i).ozellik_kodu,
                                          v_ekipman_tip_matrix_id,
                                          out_ekipman_ozellik_uyumlu);

            IF out_ekipman_ozellik_uyumlu = 'H'
            THEN
               IF     vozellikliservisiceren = 1
                  AND yetki_pack.yetkisi_varmi (
                         in_kullanici,
                         'ISLEM_INTERAKTIF_SERVIS_EKLE') <> 0
               THEN
                  vtempaciklama :=
                        'D I K K A T ! Üyenin kutusu bu özelligi desteklememektedir : '
                     || vpaketozellik (i).ozellik_kodu;

                  IF out_aciklama IS NULL
                  THEN
                     out_aciklama := vtempaciklama;
                  ELSE
                     out_aciklama := out_aciklama || '<E>' || vtempaciklama;
                  END IF;

                  out_durum := '0';
                  out_error_type := 0;
                  out_error_code := 'VLD113';
               ELSE
                  out_durum :=
                        'Üyenin kutusu bu özelligi desteklememektedir : '
                     || vpaketozellik (i).ozellik_kodu;
                  out_error_type := 1;
                  out_error_code := 'ERR778';
                  RETURN;
               END IF;
            END IF;
         END LOOP;
      END IF;

      /*bozturkmen - ittp tarafında servis ekipman uyum kontrolü sadece kutu ve modül için*/
      servis_ekipman_uyum_ittp (in_account_number,
                                in_outlet_location,
                                in_servis_kodu,
                                in_cagrilan_yer,
                                out_durum,
                                out_aciklama,
                                out_servis_dusur);

      IF out_durum <> '0'
      THEN
         IF yetki_pack.yetkisi_varmi (in_kullanici, 'KUTU_KISITINI_EZEBILIR') <>
               '0'
         THEN
            out_durum := '0';
            out_error_type := 0;
            out_error_code := 'VLD113';
         ELSE
            out_durum := out_durum || ' ' || out_aciklama;
            out_error_type := 1;
            out_error_code := 'ERR778';
            RETURN;
         END IF;
      END IF;

      -- Servis sadece TURKSAT destekli (14 nolu srvis özelligi olan ama 13 olmayan) ise ekipman da TURKSAT destekli(70) veya set_other_mode destekli(69) olmalidir.
      --
      SELECT SUM (ozellik_kodu)
        INTO vcount
        FROM pr_urun_ozellik_tanim
       WHERE     urun_tipi = '2'
             AND ozellik_kodu IN (13, 14)
             AND listeden_gizle = 'H'
             AND urun_kodu = in_servis_kodu;

      -- Modüllü veya kutusuz üyelere ACK gibi servisler eklemeyi kisitlamayalim.
      SELECT COUNT (1)
        INTO vkutuluuyelik
        FROM wiz_equip
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND converter_type = 'ST';

      IF vcount = 14 AND vkutuluuyelik = 1
      THEN
         ekipman_pack.ekipman_ozellik (NULL,
                                       in_account_number,
                                       in_outlet_location,
                                       70,
                                       v_ekipman_tip_matrix_id,
                                       out_ekipman_ozellik_uyumlu);

         IF out_ekipman_ozellik_uyumlu = 'H'
         THEN
            ekipman_pack.ekipman_ozellik (NULL,
                                          in_account_number,
                                          in_outlet_location,
                                          69,
                                          v_ekipman_tip_matrix_id,
                                          out_ekipman_ozellik_uyumlu);
         END IF;

         IF out_ekipman_ozellik_uyumlu = 'H'
         THEN
            IF yetki_pack.yetkisi_varmi (in_kullanici,
                                         'ISLEM_SERVIS_EKLE_TURKSAT_UYUMU') <>
                  0
            THEN
               vtempaciklama :=
                  'D I K K A T ! Üyenin kutusu TURKSAT yayini desteklememektedir';

               IF out_aciklama IS NULL
               THEN
                  out_aciklama := vtempaciklama;
               ELSE
                  out_aciklama := out_aciklama || '<E>' || vtempaciklama;
               END IF;

               out_durum := '0';
               out_error_type := 0;
               out_error_code := 'VLD113';
            ELSE
               out_durum :=
                  'Üyenin kutusu TURKSAT yayini özelligi desteklememektedir ';
               out_error_type := 1;
               out_error_code := 'ERR778';
               RETURN;
            END IF;
         END IF;
      END IF;
   END servisekipmanuyum;

   -------------------------
   PROCEDURE servis_operator_bul (
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_outlet              IN     NUMBER,
      in_servis_kodu         IN     icr_dp_servis_default.code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_billing_frequency   IN     icr_dp_servis_default.billing_frequency%TYPE,
      in_tarih               IN     icr_dp_servis_default.effective_date%TYPE,
      in_stb_tipi            IN     icr_dp_servis_default.stb_tipi%TYPE,
      v_durum                   OUT NUMBER)
   IS
      v_num_outlet    NUMBER;
      v_islem_tarih   icr_dp_servis_default.effective_date%TYPE;

      CURSOR sd_cur1
      IS                                           --SERVIS_DEFAULT_CUR    '='
           SELECT job,
                  s.sms_code,
                  s.promotion_code,
                  s.ek_servisler,
                  s.dusurulecek
             FROM icr_dp_servis_default s, icr_dp_servis_default_detay d
            WHERE     TO_NUMBER (s.outlet) = v_num_outlet
                  AND d.servis_default_kodu = s.kod
                  AND listeden_gizle = 'H'
                  AND operator = '='
                  AND s.franchise_code = in_franchise_code
                  AND (   s.billing_frequency = in_billing_frequency
                       OR s.billing_frequency IS NULL)
                  AND d.customer_type = in_uye_tipi
                  AND s.code = in_servis_kodu
                  AND s.campaign_code = in_kampanya_kodu
                  AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                  AND (   s.effective_date IS NULL
                       OR s.effective_date <= v_islem_tarih)
                  AND (s.expire_date IS NULL OR s.expire_date > SYSDATE)
         ORDER BY franchise_code, billing_frequency, expire_date DESC;

      CURSOR sd_cur2
      IS                                            --SERVIS_DEFAULT_CUR  '>='
           SELECT job,
                  s.sms_code,
                  s.promotion_code,
                  s.ek_servisler,
                  s.dusurulecek
             FROM icr_dp_servis_default s, icr_dp_servis_default_detay d
            WHERE     TO_NUMBER (s.outlet) <= v_num_outlet
                  AND d.servis_default_kodu = s.kod
                  AND listeden_gizle = 'H'
                  AND operator = '>='
                  AND s.franchise_code = in_franchise_code
                  AND (   s.billing_frequency = in_billing_frequency
                       OR s.billing_frequency IS NULL)
                  AND d.customer_type = in_uye_tipi
                  AND s.code = in_servis_kodu
                  AND s.campaign_code = in_kampanya_kodu
                  AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                  AND (   s.effective_date IS NULL
                       OR s.effective_date <= v_islem_tarih)
                  AND (s.expire_date IS NULL OR s.expire_date > SYSDATE)
         ORDER BY franchise_code,
                  billing_frequency,
                  TO_NUMBER (s.outlet) DESC,
                  expire_date DESC;

      CURSOR sd_cur3
      IS                                             --SERVIS_DEFAULT_CUR  '>'
           SELECT job,
                  s.sms_code,
                  s.promotion_code,
                  s.ek_servisler,
                  s.dusurulecek
             FROM icr_dp_servis_default s, icr_dp_servis_default_detay d
            WHERE     TO_NUMBER (s.outlet) < v_num_outlet
                  AND d.servis_default_kodu = s.kod
                  AND operator = '>'
                  AND listeden_gizle = 'H'
                  AND s.franchise_code = in_franchise_code
                  AND (   s.billing_frequency = in_billing_frequency
                       OR s.billing_frequency IS NULL)
                  AND d.customer_type = in_uye_tipi
                  AND s.code = in_servis_kodu
                  AND s.campaign_code = in_kampanya_kodu
                  AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                  AND (   s.effective_date IS NULL
                       OR s.effective_date <= v_islem_tarih)
                  AND (s.expire_date IS NULL OR s.expire_date > SYSDATE)
         ORDER BY franchise_code,
                  billing_frequency,
                  TO_NUMBER (s.outlet) DESC,
                  expire_date DESC;
   BEGIN
      v_islem_tarih := in_tarih;
      v_num_outlet := in_outlet;
      v_durum := 0;                                           -- Kayit bulundu

      FOR sd_rec IN sd_cur1
      LOOP
         RETURN;
      END LOOP;

      FOR sd_rec IN sd_cur2
      LOOP
         RETURN;
      END LOOP;

      FOR sd_rec IN sd_cur3
      LOOP
         RETURN;
      END LOOP;

      v_durum := 1;                                        -- Kayit bulunamadi
   END servis_operator_bul;

   PROCEDURE olan_servis_doldur (v_account_number   IN NUMBER,
                                 v_outlet           IN VARCHAR2)
   IS
      --Workorder number <> 0 ise kaydimiz wo içinde olan bir kayittir.
      --Workorder number = 0 ise svc den gelen bir kayit gibi islenmelidir.
      CURSOR serv_cur
      IS
         SELECT add_closed_date tarih,
                service_code,
                'ADD' job_code,
                campaign_code,
                0 work_order_number,
                servis_frekansi,
                promotion_code,
                id baglanti_id,
                promo_expire_date
           FROM wiz_customer_hp_svc hs
          WHERE     account_number = v_account_number
                AND outlet_location = v_outlet
         UNION
         SELECT DECODE (uds.durum,
                        '1', add_closed_date,
                        '2', beklenen_kapanma_tarihi)
                   tarih,
                service_code,
                DECODE (uds.durum, '1', 'ADD', job_code) job_code,
                campaign_code,
                DECODE (uds.durum,  '1', 0,  '2', 1) work_order_number,
                servis_frekansi,
                promotion_code,
                uds.id baglanti_id,
                promo_expire_date
           FROM ie_uyelik_dondurma_servis uds, ie_uyelik_dondurma ud
          WHERE     uds.uyelik_dondurma_id = ud.id
                AND ud.durum = 'D'
                AND uds.eklenecek_mi = 'E'
                AND ud.account_number = v_account_number
                AND ud.outlet_location = v_outlet
         UNION
         SELECT DECODE (uks.durum,
                        '1', add_closed_date,
                        '2', beklenen_kapanma_tarihi)
                   tarih,
                service_code,
                DECODE (uks.durum, '1', 'ADD', job_code) job_code,
                campaign_code,
                DECODE (uks.durum,  '1', 0,  '2', 1) work_order_number,
                servis_frekansi,
                promotion_code,
                uks.id baglanti_id,
                promo_expire_date
           FROM ie_uyelik_kapama_servis uks, ie_uyelik_kapama uk
          WHERE     uks.uyelik_kapama_id = uk.id
                AND uk.durum = 'K'
                AND uks.eklenecek_mi = 'E'
                AND uk.account_number = v_account_number
                AND uk.outlet_location = v_outlet
         UNION
         SELECT li_effective_date tarih,
                service_code,
                job_code,
                campaign_code,
                wol.work_order_number,
                servis_frekansi,
                promotion_code,
                id baglanti_id,
                promosyon_bitis_tarihi promo_expire_date
           FROM wiz_wo_line_items wol, wiz_work_order wo
          WHERE     wol.work_order_number = wo.work_order_number
                AND wo.account_number = v_account_number
                AND wol.outlet_location = v_outlet
                AND wol.wo_status = 'O'
                AND wo.wo_status IN ('O', 'P')
                AND job_code IN (SELECT deger
                                   FROM pa_sabitler
                                  WHERE adi IN ('SERVIS_EKLEME',
                                                'SERVIS_DUSURME'))
         ORDER BY 1 ASC;
   BEGIN
      DELETE FROM tm_servis
            WHERE     account_number = v_account_number
                  AND outlet_location = v_outlet;

      FOR serv_rec IN serv_cur
      LOOP
         INSERT INTO tm_servis (account_number,
                                outlet_location,
                                service_code,
                                islem,
                                tarih,
                                durum,
                                campaign_code,
                                work_order_number,
                                servis_frekansi,
                                promotion_code,
                                baglanti_id,
                                promosyon_bitis_tarihi)
              VALUES (v_account_number,
                      v_outlet,
                      serv_rec.service_code,
                      serv_rec.job_code,
                      serv_rec.tarih,
                      NULL,
                      serv_rec.campaign_code,
                      serv_rec.work_order_number,
                      serv_rec.servis_frekansi,
                      serv_rec.promotion_code,
                      serv_rec.baglanti_id,
                      serv_rec.promo_expire_date);
      END LOOP;
   END olan_servis_doldur;

   PROCEDURE gerek_servis_kontrol (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_add_servis          IN     tm_ek.service_code%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_li_effective_date   IN     DATE,
      durum                     OUT VARCHAR2)
   IS
      CURSOR grup_no_cur (
         p_durum    tm_ek.durum%TYPE)
      IS
         SELECT DISTINCT grup_no
           FROM tm_ek
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND ilgili_service = in_servis_kodu
                AND durum = p_durum;

      CURSOR tm_ek_cur (
         p_durum      tm_ek.durum%TYPE,
         p_grup_no    tm_ek.grup_no%TYPE)
      IS
           SELECT *
             FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND ilgili_service = in_servis_kodu
                  AND durum = p_durum
                  AND grup_no = p_grup_no
         ORDER BY and_or DESC;

      CURSOR servis_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND TRUNC (tarih) <= TRUNC (in_li_effective_date)
         ORDER BY tarih DESC;

      CURSOR servis_varmi_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND TRUNC (tarih) > TRUNC (in_li_effective_date)
                  AND work_order_number = 0
         ORDER BY tarih ASC;

      v_gerekli_servis_var    BOOLEAN;
      v_servisler_listesi     VARCHAR2 (500);
      v_servis_ekleme_kodu    tm_servis.islem%TYPE;
      v_servis_dusurme_kodu   tm_servis.islem%TYPE;
      v_ilk_servis_mi         BOOLEAN;
   BEGIN
      v_servis_ekleme_kodu := 'ADD';
      v_servis_dusurme_kodu := 'DSR';
      durum := '0';
      --GEREK SERVISI VARMI KONTROLÜ
      v_gerekli_servis_var := TRUE;

      FOR grup_no_rec IN grup_no_cur ('G')
      LOOP
         v_gerekli_servis_var := FALSE;

         FOR tm_ek_rec IN tm_ek_cur ('G', grup_no_rec.grup_no)
         LOOP
            v_gerekli_servis_var := FALSE;

            IF v_servisler_listesi IS NULL
            THEN
               v_servisler_listesi := tm_ek_rec.service_code;
            ELSE
               v_servisler_listesi :=
                     v_servisler_listesi
                  || ' '
                  || tm_ek_rec.and_or
                  || ' '
                  || tm_ek_rec.service_code;
            END IF;

            FOR gerek_servis_rec IN servis_cur (tm_ek_rec.service_code)
            LOOP
               IF gerek_servis_rec.islem = v_servis_ekleme_kodu
               THEN
                  v_gerekli_servis_var := TRUE;
               ELSE
                  v_gerekli_servis_var := FALSE;
               END IF;

               EXIT;                 --MAX TARIHE BAKIYOR SON KAYIT GEREKLI...
            END LOOP;

            IF NOT v_gerekli_servis_var
            THEN
               v_ilk_servis_mi := TRUE;

               FOR servis_varmi_rec
                  IN servis_varmi_cur (tm_ek_rec.service_code)
               LOOP
                  IF NOT v_ilk_servis_mi
                  THEN
                     v_gerekli_servis_var := FALSE;
                     EXIT;
                  END IF;

                  IF v_ilk_servis_mi
                  THEN
                     IF servis_varmi_rec.islem = v_servis_ekleme_kodu
                     THEN
                        IF in_add_servis = servis_varmi_rec.service_code
                        THEN
                           v_gerekli_servis_var := TRUE;
                        END IF;
                     ELSE
                        v_gerekli_servis_var := FALSE;
                        EXIT;
                     END IF;

                     v_ilk_servis_mi := FALSE;
                  END IF;
               END LOOP;
            END IF;

            IF tm_ek_rec.and_or = 'OR'
            THEN
               IF v_gerekli_servis_var
               THEN
                  EXIT;
               END IF;
            ELSE
               IF NOT v_gerekli_servis_var
               THEN
                  EXIT;
               END IF;
            END IF;
         END LOOP;

         IF v_gerekli_servis_var
         THEN
            EXIT;
         END IF;
      END LOOP;

      IF NOT v_gerekli_servis_var
      THEN
         durum :=
               in_servis_kodu
            || ' Servisi için gerekli servis(ler):'
            || v_servisler_listesi;
         RETURN;
      END IF;
   END gerek_servis_kontrol;

   PROCEDURE yasak_servis_kontrol (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_li_effective_date   IN     DATE,
      durum                     OUT VARCHAR2)
   IS
      CURSOR grup_no_cur (
         p_durum    tm_ek.durum%TYPE)
      IS
         SELECT DISTINCT grup_no
           FROM tm_ek
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND ilgili_service = in_servis_kodu
                AND durum = p_durum;

      CURSOR tm_ek_cur (
         p_durum      tm_ek.durum%TYPE,
         p_grup_no    tm_ek.grup_no%TYPE)
      IS
           SELECT *
             FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND ilgili_service = in_servis_kodu
                  AND durum = p_durum
                  AND grup_no = p_grup_no
         ORDER BY and_or DESC;

      CURSOR servis_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND TRUNC (tarih) <= TRUNC (in_li_effective_date)
         ORDER BY tarih DESC;

      v_servisler_listesi     VARCHAR2 (500);
      v_yasak_servis_var      BOOLEAN;
      v_servis_ekleme_kodu    tm_servis.islem%TYPE;
      v_servis_dusurme_kodu   tm_servis.islem%TYPE;
   BEGIN
      v_servis_ekleme_kodu := 'ADD';
      v_servis_dusurme_kodu := 'DSR';
      durum := '0';
      --YASAK SERVISI VARMI KONTROLÜ
      v_yasak_servis_var := FALSE;

      FOR grup_no_rec IN grup_no_cur ('Y')
      LOOP
         FOR tm_ek_rec IN tm_ek_cur ('Y', grup_no_rec.grup_no)
         LOOP
            v_yasak_servis_var := FALSE;

            FOR yasak_servis_rec IN servis_cur (tm_ek_rec.service_code)
            LOOP
               IF yasak_servis_rec.islem <> v_servis_dusurme_kodu
               THEN
                  v_yasak_servis_var := TRUE;
               ELSE
                  v_yasak_servis_var := FALSE;
               END IF;

               EXIT;                 --MAX TARIHE BAKIYOR SON KAYIT GEREKLI...
            END LOOP;

            IF v_yasak_servis_var
            THEN
               IF v_servisler_listesi IS NULL
               THEN
                  v_servisler_listesi := tm_ek_rec.service_code;
               ELSE
                  v_servisler_listesi :=
                        v_servisler_listesi
                     || ' '
                     || tm_ek_rec.and_or
                     || ' '
                     || tm_ek_rec.service_code;
               END IF;
            END IF;

            IF tm_ek_rec.and_or = 'OR'
            THEN
               IF v_yasak_servis_var
               THEN
                  EXIT;
               END IF;
            ELSE
               IF NOT v_yasak_servis_var
               THEN
                  EXIT;
               END IF;
            END IF;
         END LOOP;

         IF v_yasak_servis_var
         THEN
            EXIT;
         END IF;
      END LOOP;

      IF v_yasak_servis_var
      THEN
         durum :=
               in_servis_kodu
            || ' Servisi için yasak servis(ler) var:'
            || v_servisler_listesi;
         RETURN;
      END IF;
   END yasak_servis_kontrol;

   PROCEDURE yg_servis_bul (
      in_account_number   IN NUMBER,
      in_service_code     IN icr_dp_servis_default.code%TYPE,
      in_uye_tipi         IN icr_dp_servis_default_detay.customer_type%TYPE,
      in_outlet           IN VARCHAR2,
      in_franchise_code   IN icr_dp_servis_default.franchise_code%TYPE)
   IS
      --Gerek Yasak Servisleri TM_EK Tablosuna dolduruyor....
      v_stb_tipi       VARCHAR2 (10);
      v_servis_durum   tm_ek.durum%TYPE;

      CURSOR servisler_cur
      IS
         SELECT c.service_code,
                c.grup_no,
                c.and_or,
                c.yasakmi
           FROM pr_servis_takip a,
                pr_servis_takip_detay b,
                pr_yasak_zorunlu_servis_takip c
          WHERE     a.kod = b.servis_takip_kodu
                AND a.kod = c.servis_takip_kodu
                AND a.service_code = in_service_code
                AND a.franchise_code = in_franchise_code
                AND a.listeden_gizle = 'H'
                AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                AND b.customer_type = in_uye_tipi
                AND c.yasakmi IN ('E', 'H');

      servisler_rec    servisler_cur%ROWTYPE;
   BEGIN
      v_stb_tipi := vestel_pack.abone_stb_tipi_bul (in_account_number);

      FOR servisler_rec IN servisler_cur
      LOOP
         IF servisler_rec.yasakmi = 'E'
         THEN
            v_servis_durum := 'Y';
         ELSE
            v_servis_durum := 'G';
         END IF;


         INSERT INTO tm_ek (account_number,
                            outlet_location,
                            service_code,
                            promotion_code,
                            dusurulecek_mi,
                            promosyon_bitis_tarihi,
                            durum,
                            ilgili_service,
                            and_or,
                            grup_no)
              VALUES (in_account_number,
                      in_outlet,
                      servisler_rec.service_code,
                      '',
                      '',
                      '',
                      v_servis_durum,
                      in_service_code,
                      servisler_rec.and_or,
                      servisler_rec.grup_no);
      END LOOP;
   END yg_servis_bul;

   PROCEDURE jobprocess (
      in_account_number      IN NUMBER,
      in_uye_tipi            IN icr_dp_servis_default_detay.customer_type%TYPE,
      in_outlet              IN VARCHAR2,
      job                    IN icr_dp_servis_default.code%TYPE,
      in_kampanya_kodu       IN icr_dp_servis_default.campaign_code%TYPE,
      in_franchise_code      IN icr_dp_servis_default.franchise_code%TYPE,
      in_billing_frequency   IN icr_dp_servis_default.billing_frequency%TYPE)
   IS
      v_job              icr_dp_servis_default.code%TYPE;
      v_promotion_code   wiz_promo_descr.promotion_code%TYPE;
      v_sms_dmg          icr_dp_servis_default.code%TYPE;
      v_quantity         NUMBER;
      v_durum            VARCHAR2 (300);
      v_outlet           NUMBER;
      v_count            NUMBER;
      v_stb_tipi         CHAR (2);
   BEGIN
      v_stb_tipi := vestel_pack.abone_stb_tipi_bul (in_account_number);

      IF v_stb_tipi = '-1'
      THEN
         v_stb_tipi := NULL;
      END IF;

      v_outlet := TO_NUMBER (in_outlet);
      operator_bul_pack.operator_bul3 (in_uye_tipi,
                                       v_outlet,
                                       job,
                                       in_kampanya_kodu,
                                       in_franchise_code,
                                       in_billing_frequency,
                                       v_stb_tipi,
                                       v_job,
                                       v_promotion_code,
                                       v_sms_dmg,
                                       v_quantity,
                                       v_durum);

      INSERT INTO tm_ek (account_number,
                         outlet_location,
                         service_code,
                         promotion_code,
                         dusurulecek_mi,
                         durum)
           VALUES (in_account_number,
                   in_outlet,
                   v_job,
                   v_promotion_code,
                   'H',
                   'J');
   END jobprocess;

   PROCEDURE servis_process (
      in_account_number      IN NUMBER,
      in_uye_tipi            IN icr_dp_servis_default_detay.customer_type%TYPE,
      in_outlet              IN VARCHAR2,
      in_servis_kodu         IN icr_dp_servis_default.code%TYPE,
      in_kampanya_kodu       IN icr_dp_servis_default.campaign_code%TYPE,
      in_franchise_code      IN icr_dp_servis_default.franchise_code%TYPE,
      in_billing_frequency   IN icr_dp_servis_default.billing_frequency%TYPE,
      in_tarih               IN icr_dp_servis_default.effective_date%TYPE,
      in_kullanici           IN co_kullanici.kod%TYPE,
      in_ekleme_tipi         IN VARCHAR2 := 'A',
      in_kampanya_ok_mi      IN NUMBER := 0)
   IS
      /*
        TM_EK Tablosu doldurulyor,promosyon kodu ve ek servsiler bulunuyor...
        IN_KAMPANYA_OK_MI
                  1: Kampanya seçilebilir
                  0: Kampanya seçilemez
                  Servis Ekleme isleminde Kampanya Expire Etmis olsa bile
                  Yetkili kullanici seçebilir islem eger upgrade ise
      */
      v_sms_code                 icr_dp_servis_default.code%TYPE;
      v_promosyon_kodu           CHAR (3);
      v_job                      CHAR (3);
      v_servisler                VARCHAR2 (100);
      v_durum1                   NUMBER (3);
      v_dusurulecek              CHAR (1);
      v_servis                   VARCHAR2 (20);
      v_out_durum                VARCHAR2 (20);
      v_count                    NUMBER (3);
      v_promosyon_bitis_tarihi   DATE;
      v_yg_servisler             VARCHAR2 (550);
      v_yg_servis                VARCHAR2 (4);
      v_stb_tipi                 icr_dp_servis_default.stb_tipi%TYPE;
      v_icr_dp_code              NUMBER;
   BEGIN
      v_stb_tipi := vestel_pack.abone_stb_tipi_bul (in_account_number);
      operator_bul_pack.operator_bul_with_kod (in_uye_tipi,
                                               TO_NUMBER (in_outlet),
                                               in_servis_kodu,
                                               in_kampanya_kodu,
                                               in_franchise_code,
                                               in_billing_frequency,
                                               in_tarih,
                                               v_stb_tipi,
                                               v_sms_code,
                                               v_promosyon_kodu,
                                               v_job,
                                               v_servisler,
                                               v_durum1,
                                               v_dusurulecek,
                                               v_icr_dp_code,
                                               in_kullanici,
                                               in_kampanya_ok_mi);

      IF v_durum1 <> 0
      THEN
         v_out_durum := '100';
         RETURN;
      END IF;

      IF v_job <> '' OR v_job IS NOT NULL
      THEN
         jobprocess (in_account_number,
                     in_uye_tipi,
                     in_outlet,
                     v_job,
                     in_kampanya_kodu,
                     in_franchise_code,
                     in_billing_frequency);
      END IF;

      yg_servis_bul (in_account_number,
                     v_sms_code,
                     in_uye_tipi,
                     in_outlet,
                     in_franchise_code);

      INSERT INTO tm_ek (account_number,
                         outlet_location,
                         service_code,
                         promotion_code,
                         dusurulecek_mi,
                         durum)
           VALUES (in_account_number,
                   in_outlet,
                   v_sms_code,
                   v_promosyon_kodu,
                   v_dusurulecek,
                   in_ekleme_tipi);

      IF NOT v_servisler IS NULL
      THEN
         v_servisler := RTRIM (LTRIM (v_servisler));

         FOR i IN 1 .. LENGTH (v_servisler) + 1
         LOOP
            IF SUBSTR (v_servisler, i, 1) <> ',' OR LENGTH (v_servis) < 3
            THEN
               v_servis := v_servis || SUBSTR (v_servisler, i, 1);
            ELSE
               servis_process (in_account_number,
                               in_uye_tipi,
                               in_outlet,
                               v_servis,
                               in_kampanya_kodu,
                               in_franchise_code,
                               in_billing_frequency, -- '1',  // Yumurtlayan servis multi frekans
                               in_tarih,
                               in_kullanici,
                               'E');
               v_servis := '';
            END IF;
         END LOOP;
      END IF;
   END servis_process;

   FUNCTION kampanya_tanimli_mi (
      in_account_number      IN tm_ek.account_number%TYPE,
      in_outlet_location     IN tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN tm_ek.service_code%TYPE,
      in_kampanya_kodu       IN icr_dp_servis_default.campaign_code%TYPE,
      in_billing_frequency   IN icr_dp_servis_default.billing_frequency%TYPE,
      in_tarih               IN DATE,
      in_uye_tipi            IN icr_dp_servis_default_detay.customer_type%TYPE,
      in_franchise_code      IN icr_dp_servis_default.franchise_code%TYPE,
      in_kullanici           IN icr_dp_servis_default.degistiren_kullanici%TYPE)
      RETURN VARCHAR2
   IS
      -- '1' TANIMLI
      -- '0' TANIMSIZ
      -- HATA MESAJI
      v_count   NUMBER;
   BEGIN
      DELETE FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;

      servis_process (in_account_number,
                      in_uye_tipi,
                      in_outlet_location,
                      in_servis_kodu,
                      in_kampanya_kodu,
                      in_franchise_code,
                      in_billing_frequency,
                      in_tarih,
                      in_kullanici,
                      'A');

      SELECT COUNT (1)
        INTO v_count
        FROM tm_ek
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND service_code = in_servis_kodu
             AND durum = 'A';

      IF v_count > 0
      THEN
         RETURN '1';
      ELSE
         RETURN '0';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLERRM;
   END kampanya_tanimli_mi;

   PROCEDURE servis_eklenme_tarihi (
      in_account_number    IN     tm_servis.account_number%TYPE,
      in_outlet_location   IN     tm_servis.outlet_location%TYPE,
      in_service_code      IN     tm_servis.service_code%TYPE,
      in_servis_frekansi   IN     tm_servis.servis_frekansi%TYPE,
      in_tarih             IN     tm_servis.tarih%TYPE,
      out_eklenme_tarihi      OUT DATE,
      durum                   OUT VARCHAR2)
   IS
      v_add_tarihi    DATE;
      v_baglanti_id   NUMBER;
      v_svc_id        NUMBER;
      v_aciklama      VARCHAR2 (256);
   BEGIN
      durum := '0';
      v_add_tarihi := NULL;

      SELECT MAX (tarih)
        INTO v_add_tarihi
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND islem = 'ADD'
             AND service_code = in_service_code
             AND servis_frekansi = in_servis_frekansi
             AND tarih < in_tarih;

      SELECT baglanti_id
        INTO v_baglanti_id
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND islem = 'ADD'
             AND service_code = in_service_code
             AND servis_frekansi = in_servis_frekansi
             AND tarih = v_add_tarihi;

      IF v_baglanti_id IS NOT NULL AND v_baglanti_id > 0
      THEN
         uye_kontrol_pack.uye_sus_mu (in_account_number,
                                      in_outlet_location,
                                      v_aciklama);

         IF v_aciklama <> '0'
         THEN                                                       --kapanmis
            SELECT svc_id
              INTO v_svc_id
              FROM ie_uyelik_kapama_servis
             WHERE id = v_baglanti_id;
         ELSE
            uye_kontrol_pack.uye_donmus_mu (in_account_number,
                                            in_outlet_location,
                                            v_aciklama);

            IF v_aciklama <> '0'
            THEN                                                      --donmus
               SELECT svc_id
                 INTO v_svc_id
                 FROM ie_uyelik_dondurma_servis
                WHERE id = v_baglanti_id;
            ELSE
               v_svc_id := v_baglanti_id;
            END IF;
         END IF;

         SELECT MIN (tarih)
           INTO v_add_tarihi
           FROM (SELECT tarih
                   FROM tm_servis
                  WHERE     account_number = in_account_number
                        AND outlet_location = in_outlet_location
                        AND islem = 'ADD'
                        AND service_code = in_service_code
                        AND servis_frekansi = in_servis_frekansi
                        AND tarih = v_add_tarihi
                 UNION
                 SELECT add_closed_date AS tarih
                   FROM wiz_customer_hp_svc_history
                  WHERE     account_number = in_account_number
                        AND outlet_location = in_outlet_location
                        AND hp_svc_id = v_svc_id);
      END IF;

      out_eklenme_tarihi := v_add_tarihi;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Servis Eklenme Tarihi bulmada hata:' || SQLERRM;
   END servis_eklenme_tarihi;

   PROCEDURE servis_normal_dsr_tarihi (
      in_account_number    IN     tm_ek.account_number%TYPE,
      in_outlet_location   IN     tm_ek.outlet_location%TYPE,
      in_service_code      IN     tm_ek.service_code%TYPE,
      in_servis_frekansi   IN     tm_servis.servis_frekansi%TYPE,
      in_campaign_code     IN     tm_servis.campaign_code%TYPE,
      in_tarih             IN     DATE,
      out_ndsr_tarihi         OUT DATE,
      durum                   OUT VARCHAR2)
   IS
      v_add_tarihi   DATE;
      v_frekans      NUMBER;
   BEGIN
      durum := '0';
      v_add_tarihi := NULL;

      IF in_servis_frekansi <> '1'
      THEN
         servis_util_pack.servis_fiyat_bitis_tarihi (in_account_number,
                                                     in_outlet_location,
                                                     in_service_code,
                                                     in_servis_frekansi,
                                                     in_campaign_code,
                                                     in_tarih,
                                                     v_add_tarihi,
                                                     durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;

         IF v_add_tarihi IS NULL
         THEN              --Servis Düsürülecek tanimlanmissa bu kistasa girer
            servis_eklenme_tarihi (in_account_number,
                                   in_outlet_location,
                                   in_service_code,
                                   in_servis_frekansi,
                                   in_tarih,
                                   v_add_tarihi,
                                   durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;

            IF v_add_tarihi IS NULL
            THEN
               durum := 'Servis Normal Eklenme Tarihi bulmada hata';
               RETURN;
            END IF;

            SELECT billing_freq_number
              INTO v_frekans
              FROM wiz_billing_frequency_codes
             WHERE billing_frequency = in_servis_frekansi;

            --            IF in_servis_frekansi = 'A'
            --            THEN
            --               v_frekans := 12;
            --            ELSE
            --               v_frekans := in_servis_frekansi;
            --            END IF;

            v_add_tarihi := ADD_MONTHS (v_add_tarihi, v_frekans);
         ELSE
            --Servis düsürmede servis bitis tarihi geçmiste kalmis bir kayit var ve
            --baska bir paket ile downgrade yapilmaya çalisiliyor
            IF v_add_tarihi < SYSDATE
            THEN
               v_add_tarihi := SYSDATE;
            END IF;
         END IF;
      ELSE
         servis_eklenme_tarihi (in_account_number,
                                in_outlet_location,
                                in_service_code,
                                in_servis_frekansi,
                                in_tarih,
                                v_add_tarihi,
                                durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;

         IF v_add_tarihi IS NULL
         THEN
            durum := 'Servis Normal Eklenme Tarihi bulmada hata';
            RETURN;
         END IF;

         --Düsen Servisin eklenebilecegi tarih bulunuyor
         v_add_tarihi :=
            bilgi_pack.uye_billing_dx (in_account_number, v_add_tarihi);
         v_add_tarihi := ADD_MONTHS (TRUNC (v_add_tarihi), 1);
      END IF;

      out_ndsr_tarihi := v_add_tarihi;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Servis Normal Eklenme Tarihi bulmada hata:' || SQLERRM;
   END servis_normal_dsr_tarihi;

   PROCEDURE servis_erken_dsr_kontrol (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_service_code        IN     tm_ek.service_code%TYPE,
      in_servis_frekansi     IN     tm_servis.servis_frekansi%TYPE,
      in_campaign_code       IN     tm_servis.campaign_code%TYPE,
      in_li_effective_date   IN     DATE,                  --Servis DSR Tarihi
      in_dsr_li_effective    IN     DATE,
      --Servisin yeni DSR Tarihi (Servis_tarih_degistir proc. içerisinden çagriliyor)
      in_kullanici           IN     co_kullanici.kod%TYPE,
      in_kontrol_tipi        IN     NUMBER,
      durum                     OUT VARCHAR2)
   IS
      v_ndsr_tarihi   DATE;
      v_drop_tarihi   DATE;
      v_frekans       NUMBER;
   BEGIN
      durum := '0';
      v_drop_tarihi := in_dsr_li_effective;
      servis_eklenme_tarihi (in_account_number,
                             in_outlet_location,
                             in_service_code,
                             in_servis_frekansi,
                             in_li_effective_date,
                             v_ndsr_tarihi,
                             durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      v_ndsr_tarihi := ADD_MONTHS (v_ndsr_tarihi, 1);

      IF TRUNC (v_drop_tarihi) < TRUNC (v_ndsr_tarihi)
      THEN
         IF yetki_pack.yetkisi_varmi (in_kullanici,
                                      'ISLEM_SERVIS_ERKEN_DUSURME') = 0
         THEN
            durum :=
               'Bu servis degisikligi ISLEM_SERVIS_ERKEN_DUSURME yetkisi ile yapilabilir!';
            RETURN;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Servis Erken DSR Kontrol:' || SQLERRM;
   END servis_erken_dsr_kontrol;

   PROCEDURE islem_yetki_kontrol (
      in_account_number    IN     tm_ek.account_number%TYPE,
      in_outlet_location   IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu       IN     tm_ek.service_code%TYPE,
      in_islem_code        IN     tm_servis.islem%TYPE,
      in_kaynak            IN     VARCHAR2,
      in_kullanici         IN     co_kullanici.kod%TYPE,
      in_uye_tipi          IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_kontrol_tipi      IN     NUMBER,
      io_error_type        IN OUT NUMBER,
      io_error_code        IN OUT VARCHAR2,
      out_aciklama         IN OUT VARCHAR2,
      durum                   OUT VARCHAR2)
   IS
      --v_yetki_kategorisi              NUMBER;
      v_yetki_adi                     co_yetki_tanim.yetki_adi%TYPE;
      v_yetkili                       BOOLEAN;
      v_add_servis                    tm_servis.service_code%TYPE;
      v_add_servis_frekansi           tm_servis.servis_frekansi%TYPE;
      v_add_servis_frekansi_num       NUMBER (2);
      v_add_tarihi                    DATE;
      v_add_campaign_code             tm_servis.campaign_code%TYPE;
      v_add_promo_code                tm_servis.promotion_code%TYPE;
      v_add_ozel_fiyat                wiz_customer_hp_svc.non_standard_service_rate%TYPE;
      v_add_bill_freq_date            DATE;
      v_drop_campaign_code            tm_servis.campaign_code%TYPE;
      v_drop_promosyon_bitis_tarihi   tm_servis.promosyon_bitis_tarihi%TYPE;
      v_drop_tarihi                   DATE;
      v_drop_servis                   tm_servis.service_code%TYPE;
      v_drop_servis_frekansi          tm_servis.servis_frekansi%TYPE;
      v_drop_servis_frekansi_num      NUMBER (2);
      v_drop_promo_code               tm_servis.promotion_code%TYPE;
      v_count                         NUMBER;
      v_downgrade                     BOOLEAN;
      v_franchise_code                wiz_customer_hp_life.franchise_code%TYPE;
      v_customer_type                 wiz_customer_hp_life.customer_type%TYPE;
      v_mdu_subd_code                 wiz_customer_hp_life.mdu_subd_code%TYPE;
      v_current_amt_add_servis        wiz_rate_codes.current_amt%TYPE;
      v_current_amt_drop_servis       wiz_rate_codes.current_amt%TYPE;
      v_amt_add_servis                wiz_rate_codes.current_amt%TYPE;
      v_amt_drop_servis               wiz_rate_codes.current_amt%TYPE;
      v_frekans                       NUMBER (2);
      v_status                        VARCHAR2 (1000);
      v_rate_servis                   tm_servis.service_code%TYPE;
      v_yetki_kontrol                 BOOLEAN;
      v_servis_out                    tm_servis.service_code%TYPE;
      v_promo_out                     tm_servis.promotion_code%TYPE;
      v_drop_pesin                    BOOLEAN;
      v_add_pesin                     BOOLEAN;
      v_durum                         VARCHAR2 (4000);
      v_yillik_gecis_yetkisi          BOOLEAN;
      v_dwn_yetkisi_freq              BOOLEAN;
      v_last_order_date               DATE;
      v_taahutlu_mu                   BOOLEAN;
      v_taahut_ay                     NUMBER;
      v_count1                        NUMBER;
      v_stb_tipi                      VARCHAR2 (10);
      v_islem_kodu                    pr_urun_islem_yetki_tanim.islem_kodu%TYPE;
      v_kategori                      pr_urun_islem_yetki_tanim.yetki_kategorisi%TYPE;
      v_hatali_dwn                    BOOLEAN;
      v_kamp_kontrol_count            NUMBER := 0;

      CURSOR servis_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum IS NOT NULL
                AND durum <> 'J';

      CURSOR asil_servis_cur
      IS
           SELECT TRUNC (tarih),
                  SUM (DECODE (islem,  'ADD', 1,  'DSR', -1,  0)) islem_count
             FROM tm_servis c
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code IN (SELECT a.service_code
                                         FROM pr_servis_takip a,
                                              pr_servis_takip_detay b
                                        WHERE     a.kod = b.servis_takip_kodu
                                              AND a.zorunlu = 'E'
                                              AND a.franchise_code =
                                                     v_franchise_code
                                              AND a.listeden_gizle = 'H'
                                              AND (   a.bitis_tarihi IS NULL
                                                   OR a.bitis_tarihi > SYSDATE)
                                              AND (   a.stb_tipi IS NULL
                                                   OR a.stb_tipi = v_stb_tipi)
                                              AND b.customer_type = in_uye_tipi)
                  AND NOT EXISTS
                             (SELECT *
                                FROM icr_dp_servis_default a,
                                     icr_dp_servis_default_detay b
                               WHERE     c.islem = 'DSR'
                                     AND c.service_code = a.sms_code
                                     AND c.campaign_code = a.campaign_code
                                     AND c.servis_frekansi =
                                            a.billing_frequency
                                     AND a.franchise_code = v_franchise_code
                                     AND (   a.stb_tipi IS NULL
                                          OR a.stb_tipi = v_stb_tipi)
                                     AND a.kod = b.servis_default_kodu
                                     AND b.customer_type = in_uye_tipi
                                     AND a.dusurulecek = 'E')
         GROUP BY TRUNC (tarih);

      CURSOR asil_add_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND durum = 'A'
                  AND islem = 'ADD'
                  AND service_code IN (SELECT a.service_code
                                         FROM pr_servis_takip a,
                                              pr_servis_takip_detay b
                                        WHERE     a.kod = b.servis_takip_kodu
                                              AND a.zorunlu = 'E'
                                              AND a.franchise_code =
                                                     v_franchise_code
                                              AND a.listeden_gizle = 'H'
                                              AND (   a.bitis_tarihi IS NULL
                                                   OR a.bitis_tarihi > SYSDATE)
                                              AND (   a.stb_tipi IS NULL
                                                   OR a.stb_tipi = v_stb_tipi)
                                              AND b.customer_type = in_uye_tipi)
         ORDER BY tarih DESC;

      CURSOR asil_dsr_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND durum IS NOT NULL
                  AND durum NOT IN ('J', 'Z')
                  --Mustafa 15.07.2010 Z eklendi.Degilse düsen promosyondan dolayi olusan satirlari da down a dahil ediyordu
                  AND islem = 'DSR'
                  AND service_code IN (SELECT a.service_code
                                         FROM pr_servis_takip a,
                                              pr_servis_takip_detay b
                                        WHERE     a.kod = b.servis_takip_kodu
                                              AND a.zorunlu = 'E'
                                              AND a.franchise_code =
                                                     v_franchise_code
                                              AND a.listeden_gizle = 'H'
                                              AND (   a.bitis_tarihi IS NULL
                                                   OR a.bitis_tarihi > SYSDATE)
                                              AND (   a.stb_tipi IS NULL
                                                   OR a.stb_tipi = v_stb_tipi)
                                              AND b.customer_type = in_uye_tipi)
         ORDER BY tarih DESC;

      CURSOR dsr_servis_cur
      IS
         SELECT t.*
           FROM (SELECT DISTINCT p.service_code
                   FROM pr_servis_takip p, pr_servis_takip_detay d
                  WHERE     p.kod = d.servis_takip_kodu
                        AND p.zorunlu = 'H'
                        AND p.franchise_code = v_franchise_code
                        AND p.listeden_gizle = 'H'
                        AND (   p.bitis_tarihi IS NULL
                             OR p.bitis_tarihi > SYSDATE)
                        AND (p.stb_tipi IS NULL OR p.stb_tipi = v_stb_tipi)
                        AND d.customer_type = in_uye_tipi) p,
                tm_servis t
          WHERE     p.service_code = t.service_code
                AND t.account_number = in_account_number
                AND t.outlet_location = in_outlet_location
                AND t.durum IS NOT NULL
                AND t.durum <> 'J'
                AND t.islem = 'DSR';
   BEGIN
      durum := '0';
      v_stb_tipi := vestel_pack.abone_stb_tipi_bul (in_account_number);
      v_downgrade := FALSE;

      SELECT l.franchise_code, l.customer_type, l.mdu_subd_code
        INTO v_franchise_code, v_customer_type, v_mdu_subd_code
        FROM wiz_customer_hp_life l
       WHERE l.account_number = in_account_number;

      v_add_servis := NULL;

      FOR asil_add_rec IN asil_add_cur
      LOOP
         v_add_servis := asil_add_rec.service_code;
         v_add_tarihi := asil_add_rec.tarih;
         v_add_campaign_code := asil_add_rec.campaign_code;
         v_add_servis_frekansi := asil_add_rec.servis_frekansi;
         v_add_promo_code := asil_add_rec.promotion_code;
         v_add_ozel_fiyat := asil_add_rec.service_rate;
         v_durum :=
            servis_util_pack.taksit_mi (v_add_servis,
                                        v_add_servis_frekansi,
                                        v_add_campaign_code,
                                        v_add_promo_code,
                                        v_franchise_code,
                                        v_mdu_subd_code,
                                        v_add_tarihi,
                                        v_stb_tipi,
                                        -- Evren-ITTP
                                        v_customer_type);

         IF v_durum <> '0' AND v_durum <> '1'
         THEN
            durum := 'Eklenen servis taksit hata:' || v_durum;
            io_error_type := 1;
            io_error_code := 'ERR104';
            RETURN;
         END IF;

         v_add_pesin := v_durum = '0';
         EXIT;
      END LOOP;

      --12.06.2006 Mustafa - Bu satirlar gereksiz old. için kaldirildi !!!
      /*IF v_add_servis IS NULL
      THEN
         --DÜSEN SERVIS VAR MI
         SELECT COUNT (1)
           INTO v_count
           FROM TM_SERVIS
          WHERE account_number = in_account_number
            AND outlet_location = in_outlet_location
            AND durum IS NOT NULL
            AND durum <> 'J'
            AND islem = 'DSR';

         IF v_count > 0
         THEN
            v_downgrade := TRUE;
         END IF;
      ELSE*/
      IF v_add_servis IS NOT NULL
      THEN
         v_drop_servis := NULL;

         FOR asil_dsr_rec IN asil_dsr_cur
         LOOP
            v_drop_servis := asil_dsr_rec.service_code;
            v_drop_tarihi := asil_dsr_rec.tarih;
            v_drop_servis_frekansi := asil_dsr_rec.servis_frekansi;
            v_drop_campaign_code := asil_dsr_rec.campaign_code;
            v_drop_promo_code := asil_dsr_rec.promotion_code;
            v_durum :=
               servis_util_pack.taksit_mi (v_add_servis,
                                           v_add_servis_frekansi,
                                           v_add_campaign_code,
                                           v_add_promo_code,
                                           v_franchise_code,
                                           v_mdu_subd_code,
                                           v_add_tarihi,
                                           v_stb_tipi,
                                           -- Evren-ITTP
                                           v_customer_type);

            IF v_durum <> '0' AND v_durum <> '1'
            THEN
               durum := 'Düsen servis taksit hata:' || v_durum;
               io_error_type := 1;
               io_error_code := 'ERR104';
               RETURN;
            END IF;

            v_drop_pesin := v_durum = '0';

            BEGIN
               v_current_amt_drop_servis := 0;

               SELECT cur_cnvr (servis_dusurme_fiyati, currency, 2),
                      promo_expire_date
                 INTO v_current_amt_drop_servis,
                      v_drop_promosyon_bitis_tarihi
                 FROM wiz_customer_hp_svc
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND service_code = asil_dsr_rec.service_code
                      AND servis_frekansi = asil_dsr_rec.servis_frekansi
                      AND campaign_code = asil_dsr_rec.campaign_code;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_current_amt_drop_servis := 0;
               WHEN OTHERS
               THEN
                  durum := 'Servis düsürme fiyati bulmada hata:' || SQLERRM;
                  io_error_type := 1;
                  io_error_code := 'ERR97';
                  RETURN;
            END;

            EXIT;
         END LOOP;

         IF v_drop_servis IS NOT NULL
         THEN
            --DOWNGRADE MI kontrolü
            --fbt tasinmali ise down kontrolü için eklenen ve düsen paketin frekanslari aylik alinarak hesap yapiliyor.
            IF     v_add_campaign_code = v_drop_campaign_code
               AND servis_util_pack.urun_ozellik_var_mi (1,
                                                         v_add_campaign_code,
                                                         45) = 1
            THEN
               v_add_servis_frekansi := '1';
               v_drop_servis_frekansi := '1';
            END IF;

            v_rate_servis := v_add_servis;

            IF    v_add_ozel_fiyat IS NULL
               OR v_add_ozel_fiyat = (-999999999 / 100)
            THEN
               v_current_amt_add_servis := 0;
            ELSE
               v_current_amt_add_servis := v_add_ozel_fiyat;
            END IF;

            IF v_current_amt_add_servis = 0
            THEN
               work_order_pack.rate_found (v_franchise_code,
                                           v_mdu_subd_code,
                                           v_customer_type,
                                           v_add_servis_frekansi,
                                           v_rate_servis,
                                           v_add_tarihi,
                                           v_current_amt_add_servis,
                                           v_status,
                                           v_stb_tipi);

               IF v_status <> '0'
               THEN
                  durum :=
                        'Eklenen '
                     || v_add_servis
                     || ' servisi için fiyat bulunamadi!';
                  io_error_type := 1;
                  io_error_code := 'ERR104';
                  RETURN;
               END IF;

               /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
               IF     sabit.is_ittp_fiyat_ent_acik = 1
                  AND v_add_servis_frekansi <> '1'
               THEN
                  SELECT ROUND (
                            v_current_amt_add_servis / billing_freq_number,
                            2)
                    INTO v_current_amt_add_servis
                    FROM wiz_billing_frequency_codes
                   WHERE billing_frequency = v_add_servis_frekansi;
               --                  v_current_amt_add_servis :=
               --                     ROUND (  v_current_amt_add_servis
               --                            / (CASE
               --                                  WHEN v_add_servis_frekansi <> 'A'
               --                                     THEN v_add_servis_frekansi
               --                                  ELSE 12
               --                               END),
               --                            2
               --                           );
               END IF;
            /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
            END IF;

            IF    v_current_amt_drop_servis = 0
               OR v_current_amt_drop_servis IS NULL
            THEN                               --AND PESIN ISE EKLENEBILIR ???
               v_rate_servis := v_drop_servis;
               work_order_pack.rate_found (v_franchise_code,
                                           v_mdu_subd_code,
                                           v_customer_type,
                                           v_drop_servis_frekansi,
                                           v_rate_servis,
                                           v_drop_tarihi,
                                           v_current_amt_drop_servis,
                                           v_status,
                                           v_stb_tipi);

               IF v_status <> '0'
               THEN
                  durum :=
                        'Düsürülen '
                     || v_drop_servis
                     || ' servisi için fiyat bulunamadi!';
                  io_error_type := 1;
                  io_error_code := 'ERR104';
                  RETURN;
               END IF;

               /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
               IF     sabit.is_ittp_fiyat_ent_acik = 1
                  AND v_drop_servis_frekansi <> '1'
               THEN
                  SELECT ROUND (
                            v_current_amt_drop_servis / billing_freq_number,
                            2)
                    INTO v_current_amt_drop_servis
                    FROM wiz_billing_frequency_codes
                   WHERE billing_frequency = v_drop_servis_frekansi;
               --                  v_current_amt_drop_servis :=
               --                     ROUND (  v_current_amt_drop_servis
               --                            / (CASE
               --                                  WHEN v_drop_servis_frekansi <> 'A'
               --                                     THEN v_drop_servis_frekansi
               --                                  ELSE 12
               --                               END),
               --                            2
               --                           );
               END IF;
            /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
            END IF;

            --? yillik için çikan tutari * frekansi ile kontrol edilmeli sistemde aylik birim tutar olarak fiyatlar tutulmaktadr.

            SELECT billing_freq_number
              INTO v_frekans
              FROM wiz_billing_frequency_codes
             WHERE billing_frequency = v_drop_servis_frekansi;

            --            IF v_drop_servis_frekansi = 'A'
            --            THEN
            --               v_frekans := 12;
            --            ELSE
            --               v_frekans := TO_NUMBER (v_drop_servis_frekansi);
            --            END IF;

            --? DÜSÜRÜLECEK SERVIS FIYATININ ALINMASI
            IF v_drop_promosyon_bitis_tarihi > v_drop_tarihi
            THEN
               IF     servis_util_pack.urun_taahutlu_mu (
                         v_drop_campaign_code) = 1
                  AND servis_util_pack.urun_taahutlu_mu (v_add_campaign_code) =
                         0
               THEN
                  BEGIN
                     SELECT promotion_ending_length_months
                       INTO v_taahut_ay
                       FROM wiz_promo_descr
                      WHERE promotion_code = v_drop_promo_code;

                     IF NOT (v_taahut_ay = 0 OR v_taahut_ay IS NULL)
                     THEN
                        v_frekans := v_taahut_ay / v_frekans;
                     --3 AYLIK BORCLANDIRILIP TAAHHUT SÜRESI YILLIK OLABILIR.
                     --TAAHHUT FIYATI 3 AYLIK FIYAT ÜZERINDEN GIRDIGI IÇIN YILLIK SÜREYE GELMEK IÇIN KAT SAYI HESAPLANIYOR
                     END IF;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        NULL;
                  END;
               END IF;
            END IF;

            v_current_amt_drop_servis := v_current_amt_drop_servis * v_frekans;

            SELECT billing_freq_number
              INTO v_frekans
              FROM wiz_billing_frequency_codes
             WHERE billing_frequency = v_add_servis_frekansi;

            --            IF v_add_servis_frekansi = 'A'
            --            THEN
            --               v_frekans := 12;
            --            ELSE
            --               v_frekans := TO_NUMBER (v_add_servis_frekansi);
            --            END IF;

            v_current_amt_add_servis := v_current_amt_add_servis * v_frekans;

            IF NOT v_add_pesin
            THEN
               servis_util_pack.taksit_tutari (v_add_servis,
                                               v_add_servis_frekansi,
                                               v_add_campaign_code,
                                               v_add_promo_code,
                                               v_franchise_code,
                                               v_mdu_subd_code,
                                               v_add_tarihi,
                                               v_current_amt_add_servis,
                                               durum,
                                               v_stb_tipi,
                                               --Evren-ITTP
                                               v_customer_type);
            END IF;

            IF durum <> '0'
            THEN
               io_error_type := 1;
               io_error_code := 'ERR104';
               RETURN;
            END IF;

            IF NOT v_drop_pesin
            THEN
               servis_util_pack.taksit_tutari (v_drop_servis,
                                               v_drop_servis_frekansi,
                                               v_drop_campaign_code,
                                               v_drop_promo_code,
                                               v_franchise_code,
                                               v_mdu_subd_code,
                                               v_drop_tarihi,
                                               v_current_amt_drop_servis,
                                               durum,
                                               v_stb_tipi,
                                               --Evren-ITTP
                                               v_customer_type);
            END IF;

            IF durum <> '0'
            THEN
               io_error_type := 1;
               io_error_code := 'ERR104';
               RETURN;
            END IF;

            IF     v_current_amt_add_servis <= v_current_amt_drop_servis
               AND (   v_current_amt_add_servis <> 0
                    OR v_current_amt_drop_servis <> 0)
               AND in_servis_kodu <> 'BSL'
            THEN
               v_downgrade := TRUE;
            END IF;
         END IF;
      END IF;

      -- Bu bölüm asil servis olmayan ekleme düsürme isleminde kullaniliyor.
      -- ornek PLA 3 aylik var PLA 6 aylik ekleniyor
      IF v_drop_servis IS NULL AND v_add_servis IS NULL
      THEN
         v_downgrade := FALSE;
         v_current_amt_drop_servis := 0;
         v_current_amt_add_servis := 0;

         FOR ser_rec IN servis_cur
         LOOP
            --12.06.2006 Mustafa - Burada  IF ser_rec.durum<>'Z' THEN satiri eksik old. için eklendi!!!
            IF ser_rec.durum <> 'Z'
            THEN
               IF ser_rec.islem = 'DSR'
               THEN
                  BEGIN
                     v_amt_drop_servis := 0;

                     SELECT cur_cnvr (servis_dusurme_fiyati, currency, 2),
                            promo_expire_date
                       INTO v_amt_drop_servis, v_drop_promosyon_bitis_tarihi
                       FROM wiz_customer_hp_svc
                      WHERE     account_number = in_account_number
                            AND outlet_location = in_outlet_location
                            AND service_code = ser_rec.service_code
                            AND servis_frekansi = ser_rec.servis_frekansi
                            AND campaign_code = ser_rec.campaign_code;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_amt_drop_servis := 0;
                     WHEN OTHERS
                     THEN
                        durum :=
                           'Servis düsürme fiyati bulmada hata:' || SQLERRM;
                        io_error_type := 1;
                        io_error_code := 'ERR97';
                        RETURN;
                  END;

                  IF v_amt_drop_servis = 0 OR v_amt_drop_servis IS NULL
                  THEN
                     v_rate_servis := ser_rec.service_code;
                     work_order_pack.rate_found (v_franchise_code,
                                                 v_mdu_subd_code,
                                                 v_customer_type,
                                                 ser_rec.servis_frekansi,
                                                 v_rate_servis,
                                                 ser_rec.tarih,
                                                 v_amt_drop_servis,
                                                 v_status,
                                                 v_stb_tipi);

                     IF v_status <> '0'
                     THEN
                        durum :=
                              'Düsürülen '
                           || v_drop_servis
                           || ' servisi için fiyat bulunamadi!';
                        io_error_type := 1;
                        io_error_code := 'ERR104';
                        RETURN;
                     END IF;
                  END IF;

                  --? yillik için çikan tutari * frekansi ile kontrol edilmeli sistemde aylik birim tutar olarak fiyatlar tutulmaktadr.
                  SELECT billing_freq_number
                    INTO v_frekans
                    FROM wiz_billing_frequency_codes
                   WHERE billing_frequency = ser_rec.servis_frekansi;

                  --                  IF ser_rec.servis_frekansi = 'A'
                  --                  THEN
                  --                     v_frekans := 12;
                  --                  ELSE
                  --                     v_frekans := TO_NUMBER (ser_rec.servis_frekansi);
                  --                  END IF;

                  --? DÜSÜRÜLECEK SERVIS FIYATININ ALINMASI
                  /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
                  IF sabit.is_ittp_fiyat_ent_acik = 0
                  THEN
                     v_amt_drop_servis := v_amt_drop_servis * v_frekans;
                  ELSE
                     v_amt_drop_servis := v_amt_drop_servis;
                  END IF;

                  /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
                  v_current_amt_drop_servis :=
                     v_current_amt_drop_servis + v_amt_drop_servis;
               END IF;

               --DÜSEN FIYAT BULUNUYOR
               --------------------------------------------------------------------
               IF ser_rec.islem = 'ADD'
               THEN
                  v_rate_servis := ser_rec.service_code;

                  IF    ser_rec.service_rate IS NULL
                     OR ser_rec.service_rate = (-999999999 / 100)
                  THEN
                     v_amt_add_servis := 0;
                  ELSE
                     v_amt_add_servis := ser_rec.service_rate;
                  END IF;

                  IF v_amt_add_servis = 0
                  THEN
                     work_order_pack.rate_found (v_franchise_code,
                                                 v_mdu_subd_code,
                                                 v_customer_type,
                                                 ser_rec.servis_frekansi,
                                                 v_rate_servis,
                                                 ser_rec.tarih,
                                                 v_amt_add_servis,
                                                 v_status,
                                                 v_stb_tipi);

                     IF v_status <> '0'
                     THEN
                        durum :=
                              'Eklenen '
                           || v_add_servis
                           || ' servisi için fiyat bulunamadi!';
                        io_error_type := 1;
                        io_error_code := 'ERR104';
                        RETURN;
                     END IF;
                  END IF;

                  SELECT billing_freq_number
                    INTO v_frekans
                    FROM wiz_billing_frequency_codes
                   WHERE billing_frequency = ser_rec.servis_frekansi;

                  --                  IF ser_rec.servis_frekansi = 'A'
                  --                  THEN
                  --                     v_frekans := 12;
                  --                  ELSE
                  --                     v_frekans := TO_NUMBER (ser_rec.servis_frekansi);
                  --                  END IF;

                  --? DÜSÜRÜLECEK SERVIS FIYATININ ALINMASI
                  /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
                  IF sabit.is_ittp_fiyat_ent_acik = 0
                  THEN
                     v_amt_add_servis := v_amt_add_servis * v_frekans;
                  ELSE
                     v_amt_add_servis := v_amt_add_servis;
                  END IF;

                  /*--- Evren-ITTP Fiyat Entegrasyonu --- 20110825 ---*/
                  v_current_amt_add_servis :=
                     v_current_amt_add_servis + v_amt_add_servis;
               END IF;
            --12.06.2006 Mustafa --Sadece end if; satiri eklendi
            END IF;
         END LOOP;

         IF     v_current_amt_add_servis <= v_current_amt_drop_servis
            AND (   v_current_amt_add_servis <> 0
                 OR v_current_amt_drop_servis <> 0)
         THEN
            v_downgrade := TRUE;
         END IF;
      END IF;

      --Mustafa 31.05.2004 outlet kampanyasi kontrolünde birbirini kapsamayan paketler geçirilmiyor
      IF in_kontrol_tipi = 4
      THEN
         SELECT COUNT (*)
           INTO v_count1
           FROM (SELECT icerik_kodu
                   FROM vv_servis_icerik
                  WHERE paket_kodu = v_drop_servis
                 MINUS
                 SELECT icerik_kodu
                   FROM vv_servis_icerik
                  WHERE paket_kodu = v_add_servis);

         IF v_count1 > 0
         THEN
            durum :=
                  'Outlet kampanyasinda '
               || v_drop_servis
               || ' den '
               || v_add_servis
               || ' ya geçilmez!';
            io_error_type := 1;
            io_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      --ISLEM ZAMANINDA MI YAPILIYOR
      IF     v_add_servis IS NOT NULL
         AND v_drop_servis IS NOT NULL
         AND v_drop_servis_frekansi <> '1'
         AND in_kontrol_tipi <> 2
      THEN
         ---????
         servis_normal_dsr_tarihi (in_account_number,
                                   in_outlet_location,
                                   v_drop_servis,
                                   v_drop_servis_frekansi,
                                   v_drop_campaign_code,
                                   v_drop_tarihi,
                                   v_add_tarihi,
                                   durum);

         IF durum <> '0'
         THEN
            io_error_type := 1;
            io_error_code := 'ERR97';
            RETURN;
         END IF;

         SELECT billing_freq_number
           INTO v_frekans
           FROM wiz_billing_frequency_codes
          WHERE billing_frequency = v_drop_servis_frekansi;

         --         IF v_drop_servis_frekansi = 'A'
         --         THEN
         --            v_frekans := 12;
         --         ELSE
         --            v_frekans := TO_NUMBER (v_drop_servis_frekansi);
         --         END IF;

         IF MOD (MONTHS_BETWEEN (v_drop_tarihi, v_add_tarihi), v_frekans) <>
               0
         THEN
            v_yillik_gecis_yetkisi :=
               yetki_pack.yetkisi_varmi (in_kullanici,
                                         'ISLEM_SERVIS_YILLIK_PT_GECIS') <> 0;

            IF v_downgrade
            THEN
               IF NOT v_dwn_yetkisi_freq
               THEN
                  durum :=
                        'Bu islem için '
                     || v_drop_servis_frekansi
                     || ' frekansli servis düsürme yetkisi gerekmektedir!';
                  io_error_type := 1;
                  io_error_code := 'ERR97';
                  RETURN;
               END IF;
            END IF;

            SELECT billing_freq_number
              INTO v_add_servis_frekansi_num
              FROM wiz_billing_frequency_codes
             WHERE billing_frequency = v_add_servis_frekansi;

            --            IF v_add_servis_frekansi = 'A'
            --            THEN
            --               v_add_servis_frekansi_num := 12;
            --            ELSE
            --               v_add_servis_frekansi_num := TO_NUMBER (v_add_servis_frekansi);
            --            END IF;

            SELECT billing_freq_number
              INTO v_drop_servis_frekansi_num
              FROM wiz_billing_frequency_codes
             WHERE billing_frequency = v_drop_servis_frekansi;

            --            IF v_drop_servis_frekansi = 'A'
            --            THEN
            --               v_drop_servis_frekansi_num := 12;
            --            ELSE
            --               v_drop_servis_frekansi_num := TO_NUMBER (v_drop_servis_frekansi);
            --            END IF;

            IF v_drop_servis_frekansi <> '1'
            THEN
               IF v_add_servis_frekansi <> '1'
               THEN
                  IF v_drop_pesin AND NOT v_add_pesin
                  THEN
                     IF NOT v_downgrade
                     THEN
                        IF NOT v_yillik_gecis_yetkisi
                        THEN
                           durum :=
                                 v_drop_servis_frekansi_num
                              || ' aylik pesinden '
                              || v_add_servis_frekansi_num
                              || ' aylik taksitliye geçilemez!';
                           io_error_type := 1;
                           io_error_code := 'ERR106';
                           RETURN;
                        END IF;
                     ELSE
                        IF NOT v_dwn_yetkisi_freq
                        THEN
                           durum :=
                                 'Bu islem için '
                              || v_drop_servis_frekansi_num
                              || ' frekansli servis düsürme yetkisi gerekmektedir!';
                           io_error_type := 1;
                           io_error_code := 'ERR105';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;

                  IF NOT v_drop_pesin AND v_add_pesin
                  THEN
                     IF NOT v_downgrade
                     THEN
                        IF NOT v_yillik_gecis_yetkisi
                        THEN
                           durum :=
                                 v_drop_servis_frekansi_num
                              || ' aylik taksitliden '
                              || v_add_servis_frekansi_num
                              || ' aylik pesine geçilemez!';
                           io_error_type := 1;
                           io_error_code := 'ERR106';
                           RETURN;
                        END IF;
                     ELSE
                        IF NOT v_dwn_yetkisi_freq
                        THEN
                           durum :=
                                 'Bu islem için '
                              || v_drop_servis_frekansi_num
                              || ' frekansli servis düsürme yetkisi gerekmektedir!';
                           io_error_type := 1;
                           io_error_code := 'ERR105';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               IF v_add_servis_frekansi = '1'
               THEN
                  IF NOT v_drop_pesin
                  THEN
                     IF NOT v_downgrade
                     THEN
                        IF NOT v_yillik_gecis_yetkisi
                        THEN
                           durum :=
                                 v_drop_servis_frekansi_num
                              || ' aylik taksitliden ayliga geçilemez!';
                           io_error_type := 1;
                           io_error_code := 'ERR106';
                           RETURN;
                        END IF;
                     ELSE
                        IF NOT v_dwn_yetkisi_freq
                        THEN
                           durum :=
                                 'Bu islem için '
                              || v_drop_servis_frekansi
                              || ' frekansli servis düsürme yetkisi gerekmektedir!';
                           io_error_type := 1;
                           io_error_code := 'ERR105';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      --KAMPANYA PROMOSYON KONTROLU
      v_yetki_kontrol := FALSE;

      IF v_drop_promosyon_bitis_tarihi > v_drop_tarihi
      THEN
         IF     v_add_campaign_code <> v_drop_campaign_code
            AND v_add_servis IS NOT NULL
         THEN
            --DROP KAMPANYA ADD SERVIS IÇIN TANIMLI MI
            durum :=
               kampanya_tanimli_mi (in_account_number,
                                    in_outlet_location,
                                    v_add_servis,
                                    v_drop_campaign_code,
                                    v_add_servis_frekansi,
                                    v_add_tarihi,
                                    v_customer_type,
                                    v_franchise_code,
                                    in_kullanici);

            IF durum = '1'
            THEN                                            --KAMPANYA TANIMLI
               IF in_kaynak <> 'DBS' AND v_add_campaign_code = 'KMP'
               THEN
                  out_aciklama := '[KMP]' || v_drop_campaign_code;
                  --TV ÜYELIK KULLANIYOR [KMP]
                  durum := '0';
                  RETURN;
               END IF;

               IF v_drop_campaign_code = 'OT1'
               THEN
                  outlet_kmp_var_mi (in_outlet_location,
                                     in_account_number,
                                     v_add_servis,
                                     v_add_servis_frekansi,
                                     durum,
                                     v_servis_out,
                                     v_promo_out);

                  IF durum = '0' AND v_promo_out IS NOT NULL
                  THEN
                     v_yetki_kontrol := TRUE;
                  END IF;
               END IF;

               IF     (v_yetki_kontrol OR in_kaynak = 'DBS')
                  AND in_kontrol_tipi <> 2
               THEN                          --IN_KONTROL_TIPI = 2 PUAN ISLEMI
                  IF yetki_pack.yetkisi_varmi (
                        in_kullanici,
                        'ISLEM_SERVIS_KAMPANYA_FARKLI_GIRME') = 0
                  THEN
                     durum :=
                           'Bu servis '
                        || v_drop_campaign_code
                        || ' kampanyasi ile eklenmelidir!';
                     io_error_type := 1;
                     io_error_code := 'ERR107';
                     RETURN;
                  ELSE
                     durum :=
                           'D I K K A T ! Bu servis '
                        || v_drop_campaign_code
                        || ' kampanyasi ile eklenebilmektedir!';

                     IF out_aciklama IS NULL
                     THEN
                        out_aciklama := durum;
                     ELSE
                        out_aciklama := out_aciklama || '<E>' || durum;
                     --<E> Enter
                     END IF;

                     durum := '0';
                  END IF;
               END IF;
            ELSIF durum = '0'
            THEN                             --KAMPANYA TANIMLI DEGIL ...DEVAM
               NULL;
            ELSE
               durum := 'Kampanya tanimi bulmada hata:' || durum;
               io_error_type := 1;
               io_error_code := 'ERR97';
               RETURN;
            END IF;
         END IF;
      END IF;

      --Eklenen Asil Servis Bir tane olmalidir.
      v_yetkili :=
         yetki_pack.yetkisi_varmi (in_kullanici, 'ISLEM_ASIL_SERVIS') <> 0;

      -- müsteri tipine ait hiç tanim yok ise kontrol olmasin
      SELECT COUNT (*)
        INTO v_count
        FROM pr_servis_takip a, pr_servis_takip_detay b
       WHERE     a.kod = b.servis_takip_kodu
             AND a.zorunlu = 'E'
             AND a.franchise_code = v_franchise_code
             AND a.listeden_gizle = 'H'
             AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
             AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
             --12.06.2006 Mustafa - Asagidaki gibi bir kisitlama yapilmiyacak. Tablolar çoklanacak...
             --         AND (A.stb_tipi = v_stb_tipi OR (v_stb_tipi <> 'HK' AND A.stb_tipi IS NULL))
             AND b.customer_type = in_uye_tipi;

      IF    (NOT v_yetkili AND v_count <> 0)
         OR (in_kaynak <> 'DBS' AND v_count <> 0)
      THEN
         -- yetkisi olsa bile 555 den asil servissiz kalmamali
         v_count := 0;

         FOR asil_servis_rec IN asil_servis_cur
         LOOP
            v_count := v_count + asil_servis_rec.islem_count;

            -- hata : tarihi geri alabiliyor yoksa
            IF v_count <= 0
            THEN
               EXIT;
            END IF;
         END LOOP;

         IF v_count <= 0
         THEN
            -- EKLENEN SERVIS ASIL SERVIS MI
            IF in_islem_code = 'ADD'
            THEN
               SELECT COUNT (*)
                 INTO v_count
                 FROM pr_servis_takip a, pr_servis_takip_detay b
                WHERE     a.kod = b.servis_takip_kodu
                      AND a.service_code = in_servis_kodu
                      AND a.zorunlu = 'E'
                      AND a.franchise_code = v_franchise_code
                      AND a.listeden_gizle = 'H'
                      AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
                      AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                      AND b.customer_type = in_uye_tipi;
            END IF;

            IF v_count <= 0
            THEN
               durum := 'Üyede asil servis bulunmasi zorunludur.';
               io_error_type := 1;
               io_error_code := 'ERR97';
               RETURN;
            END IF;
         END IF;
      END IF;

      -- ? Eger eklenen servis asil ise isleme devam ettirmiyor ama ettirmeli
      -- Ör : + sta , - sta ayni gün içinde ise , + ext var ise ve sen sta , sin eklemeye
      -- çalismasinda izin vermeli
      FOR servis_rec IN servis_cur
      LOOP
         IF servis_rec.islem = 'ADD'
         THEN                                                  --SERVIS EKLEME
            v_islem_kodu := 1;
         ELSIF     servis_rec.islem = 'DSR'
               AND TRUNC (servis_rec.promosyon_bitis_tarihi) >
                      TRUNC (SYSDATE)
         THEN                                     --PROMOSYON BITMEDEN DÜSÜRME
            v_islem_kodu := 6;
         ELSIF servis_rec.islem = 'DSR'
         THEN                                                 --SERVIS DÜSÜRME
            v_islem_kodu := 2;
         END IF;

         servis_util_pack.get_urun_islem_yetki_tanim (
            in_account_number,
            in_uye_tipi,
            TO_NUMBER (in_outlet_location),
            servis_rec.service_code,
            servis_rec.campaign_code,
            v_franchise_code,
            servis_rec.servis_frekansi,
            servis_rec.tarih,
            38,                                               --in_islem_tipi,
            v_islem_kodu,
            in_kullanici,
            v_kategori,
            durum,
            3);

         IF durum <> '0'
         THEN
            io_error_type := 1;
            io_error_code := 'ERR97';
            RETURN;
         END IF;

         IF v_kategori IS NOT NULL
         THEN
            IF yetki_pack.yetkisi_varmi (
                  in_kullanici,
                  'ISLEM_URUN_YETKI_KATEGORI_' || v_kategori) = 0
            THEN
               v_kamp_kontrol_count :=
                  uye_kampanya_kontrolu (in_account_number,
                                         in_outlet_location,
                                         servis_rec.service_code,
                                         servis_rec.campaign_code,
                                         servis_rec.tarih);

               IF v_kamp_kontrol_count = 0
               THEN
                  io_error_type := 1;

                  IF v_islem_kodu = 1
                  THEN
                     durum := 'Bu servisi ekleme yetkiniz yok';
                     io_error_code := 'ERR436';
                  ELSIF v_islem_kodu = 2
                  THEN
                     durum := 'Bu servisi düsürme yetkiniz yok';
                     io_error_code := 'ERR435';
                  ELSIF v_islem_kodu = 6
                  THEN
                     durum :=
                        'Bu servis degisikligi promosyon bitmeden yapilamaz!';
                     io_error_code := 'ERR233';
                  END IF;

                  RETURN;
               END IF;
            END IF;
         END IF;

         v_yetki_adi := NULL;

         IF servis_rec.islem = 'ADD'
         THEN
            IF servis_rec.servis_frekansi <> '1'
            THEN
               v_yetki_adi := 'CEK_SERVIS_EKLE_' || servis_rec.servis_frekansi;
            END IF;

            BEGIN
               SELECT last_order_date
                 INTO v_last_order_date
                 FROM wiz_promo_descr
                WHERE     promotion_code = servis_rec.promotion_code
                      AND product_code = servis_rec.service_code;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_last_order_date := NULL;
            END;

            IF in_kontrol_tipi <> 2
            THEN
               IF TRUNC (v_last_order_date) <= TRUNC (servis_rec.tarih)
               THEN
                  durum :=
                        'Bu Promosyon için son islem tarihi :'
                     || TO_CHAR (v_last_order_date, 'DD.MM.YYYY')
                     || ' dir !'
                     || in_kontrol_tipi;
                  io_error_type := 1;
                  io_error_code := 'ERR102';
                  RETURN;
               END IF;
            END IF;
         ELSE                                            --ISLEM DSR TM_SERVIS
            v_drop_tarihi := servis_rec.tarih;
            -- ? servis bitis tarihi
            --( WIZ_WORK_ORDER içinde ise ekleme satiri bu henüz yok demektir.)
            -- ile li_effective date kontol edilmeli.
            servis_normal_dsr_tarihi (in_account_number,
                                      in_outlet_location,
                                      servis_rec.service_code,
                                      servis_rec.servis_frekansi,
                                      servis_rec.campaign_code,
                                      v_drop_tarihi,
                                      v_add_tarihi, ---> NORMAL DUSURME TARIHI
                                      durum);

            IF durum <> '0'
            THEN
               io_error_type := 1;
               io_error_code := 'ERR97';
               RETURN;
            END IF;

            --dusurme tarihi ok degilse
            SELECT billing_freq_number
              INTO v_frekans
              FROM wiz_billing_frequency_codes
             WHERE billing_frequency = servis_rec.servis_frekansi;

            --            IF servis_rec.servis_frekansi = 'A'
            --            THEN
            --               v_frekans := 12;
            --            ELSE
            --               v_frekans := TO_NUMBER (servis_rec.servis_frekansi);
            --            END IF;

            --? downgrade içinde yetki olmali.
            IF v_downgrade AND in_kontrol_tipi <> 2
            THEN                                                 --puan islemi
               servis_erken_dsr_kontrol (in_account_number,
                                         in_outlet_location,
                                         servis_rec.service_code,
                                         servis_rec.servis_frekansi,
                                         servis_rec.campaign_code,
                                         v_drop_tarihi,
                                         v_drop_tarihi,
                                         in_kullanici,
                                         in_kontrol_tipi,
                                         durum);

               IF durum <> '0'
               THEN
                  io_error_type := 1;
                  io_error_code := 'ERR97';
                  RETURN;
               END IF;
            END IF;

            --12.06.2006 Mustafa - HK yetkisizler için degistirilen satirlar !!!
            /*            IF    MOD (MONTHS_BETWEEN (v_drop_tarihi, v_add_tarihi), v_frekans) <> 0
            OR (    MOD (MONTHS_BETWEEN (v_drop_tarihi, v_add_tarihi), v_frekans) = 0
                AND TRUNC (v_drop_tarihi) = TRUNC (SYSDATE)
                AND Dbs_Sabit ('ILERI_BC_UYGULA') = 'EVET'
               )*/
            IF    (    v_stb_tipi <> 'HK'
                   AND (   MOD (MONTHS_BETWEEN (v_drop_tarihi, v_add_tarihi),
                                v_frekans) <> 0
                        OR (    MOD (
                                   MONTHS_BETWEEN (v_drop_tarihi,
                                                   v_add_tarihi),
                                   v_frekans) = 0
                            AND TRUNC (v_drop_tarihi) = TRUNC (SYSDATE)
                            AND dbs_sabit ('ILERI_BC_UYGULA') = 'EVET')))
               OR (    v_stb_tipi = 'HK'
                   AND MONTHS_BETWEEN (v_drop_tarihi, v_add_tarihi) < 1)
            THEN
               IF v_downgrade AND in_kontrol_tipi <> 2
               THEN
                  IF v_add_servis IS NULL
                  THEN
                     IF yetki_pack.yetkisi_varmi (
                           in_kullanici,
                              'ISLEM_SERVIS_DOWNGRADE_'
                           || servis_rec.servis_frekansi) = 0
                     THEN
                        durum :=
                              'Bu servis degisikligi DOWNGRADE_'
                           || servis_rec.servis_frekansi
                           || ' yetkisi ile yapilabilir!';
                        io_error_type := 1;
                        io_error_code := 'ERR105';
                        RETURN;
                     END IF;
                  ELSE
                     IF     yetki_pack.yetkisi_varmi (
                               in_kullanici,
                               'ISLEM_SERVIS_DOWNGRADE') = 0
                        AND v_stb_tipi <> 'TK'
                     THEN
                        durum :=
                           'Bu servis degisikligi DOWNGRADE yetkisi ile yapilabilir!';
                        io_error_type := 1;
                        io_error_code := 'ERR105';
                        RETURN;
                     END IF;
                  END IF;
               END IF;

               IF servis_rec.servis_frekansi <> '1'
               THEN
                  v_yetki_adi :=
                     'CEK_SERVIS_CIKAR_' || servis_rec.servis_frekansi;
               END IF;
            END IF;
         END IF;

         IF v_yetki_adi IS NOT NULL
         THEN
            v_yetkili :=
               yetki_pack.yetkisi_varmi (in_kullanici, v_yetki_adi) <> 0;

            IF NOT v_yetkili
            THEN
               IF servis_rec.islem = 'ADD'
               THEN
                  durum :=
                        servis_rec.servis_frekansi
                     || ' frekansli servis eklemeye yetkiniz yoktur.';
               ELSE
                  durum :=
                        servis_rec.servis_frekansi
                     || ' frekansli servis düsürmeye yetkiniz yoktur.';
               END IF;

               io_error_type := 1;
               io_error_code := 'ERR105';
               RETURN;
            END IF;
         END IF;
      END LOOP;

      --Mustafa 26.12.2006  Asagidaki böülümü 1470 nolu satirdan buraya aldim
      --Bu bölüm asil servis olmayan ekleme düsürme isleminde kullaniliyor.
      IF     LTRIM (in_kaynak) IS NOT NULL
         AND in_kaynak <> 'DBS'
         AND in_kontrol_tipi <> 2
      THEN
         --  Mustafa 01.02.2005 Asagidaki satirlar niye eklendigi anlasilamadigindan kaldirildi. Eski yapiya dönüldü.
         --  Bu yapida üyenin üzerinde SPO+EXO varsa MGG alamiyordu. Eski yapida alabiliyor.
         --        SELECT COUNT(1)
         --       INTO v_count1
         --       FROM PR_SERVIS_TAKIP P
         --          ,PR_SERVIS_TAKIP_DETAY D
         --       WHERE P.KOD = D.SERVIS_TAKIP_KODU
         --                AND P.LISTEDEN_GIZLE = 'H'
         --              AND (P.FRANCHISE_CODE = V_FRANCHISE_CODE OR P.FRANCHISE_CODE IS NULL)
         --              AND D.CUSTOMER_TYPE = IN_UYE_TIPI
         --              AND P.ZORUNLU = 'H'
         --              AND (P.BITIS_TARIHI > SYSDATE OR P.BITIS_TARIHI IS NULL)
         --              AND (P.STB_TIPI = v_stb_tipi OR P.STB_TIPI IS NULL)
         --              AND p.service_code = IN_SERVIS_KODU;
         --        IF v_count1= 0  THEN
         IF v_downgrade
         THEN
            --Düsen servis zamaninda mi düsüyor ??? ? ???
            v_hatali_dwn := TRUE;

            FOR dsr_rec IN dsr_servis_cur
            LOOP                                        --ör.Servisler PLA,PVB
               servis_normal_dsr_tarihi (dsr_rec.account_number,
                                         dsr_rec.outlet_location,
                                         dsr_rec.service_code,
                                         dsr_rec.servis_frekansi,
                                         dsr_rec.campaign_code,
                                         dsr_rec.tarih,
                                         v_add_tarihi,
                                         durum);

               IF durum <> '0'
               THEN
                  io_error_type := 1;
                  io_error_code := 'ERR97';
                  RETURN;
               END IF;

               SELECT billing_freq_number
                 INTO v_frekans
                 FROM wiz_billing_frequency_codes
                WHERE billing_frequency = dsr_rec.servis_frekansi;

               --               IF dsr_rec.servis_frekansi = 'A'
               --               THEN
               --                  v_frekans := 12;
               --               ELSE
               --                  v_frekans := TO_NUMBER (dsr_rec.servis_frekansi);
               --               END IF;

               IF MOD (MONTHS_BETWEEN (dsr_rec.tarih, v_add_tarihi),
                       v_frekans) = 0
               THEN
                  v_hatali_dwn := FALSE;
                  EXIT;
               --durum := 'Bu servis islemi bu kanaldan yapilamiyor.';
               --io_error_type := 1;
               --io_error_code := 'ERR105';
               --RETURN;
               END IF;
            END LOOP;

            IF v_hatali_dwn
            THEN
               durum := 'Bu servis islemi bu kanaldan yapilamiyor.';
               io_error_type := 1;
               io_error_code := 'ERR105';
               RETURN;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         io_error_type := 1;
         io_error_code := 'ERR97';
         durum := 'Yetki Kontrol:' || SQLERRM;
   END islem_yetki_kontrol;

   PROCEDURE servis_eklenebilir_mi (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_li_effective_date   IN     DATE,
      in_billing_frequency   IN     icr_dp_servis_default.billing_frequency%TYPE,
      io_error_type          IN OUT NUMBER,
      io_error_code          IN OUT VARCHAR2,
      durum                     OUT VARCHAR2)
   IS
      CURSOR servis_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND servis_frekansi = in_billing_frequency
                  AND tarih <= in_li_effective_date
         ORDER BY tarih DESC;

      CURSOR servis_varmi_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND tarih > in_li_effective_date
         ORDER BY tarih ASC;

      v_servis_ekleme_kodu    tm_servis.islem%TYPE;
      v_servis_dusurme_kodu   tm_servis.islem%TYPE;
      v_sc                    wiz_equip.serial_number%TYPE;
      v_kart_kill_tarihi      DATE;
      v_converter_model       wiz_equip.converter_model%TYPE;
      v_count                 NUMBER;
   BEGIN
      v_servis_ekleme_kodu := 'ADD';
      v_servis_dusurme_kodu := 'DSR';

      -- Üye üzerinde servis var mi ?
      SELECT COUNT (1)
        INTO v_count
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND durum IS NULL;

      IF v_count = 0
      THEN
         v_sc :=
            ekipman_durumu_pack.abone_outlete_gore_ekipman_no (
               in_account_number,
               in_outlet_location,
               'SC');

         IF v_sc IN ('-1', '-2')
         THEN
            durum := 'Üye kart numarasi bulmada hata!';
            io_error_type := 1;
            io_error_code := 'ERR65';
            RETURN;
         END IF;

         IF ekipman_durumu_pack.dummy_mi (v_sc) = 1
         THEN
            durum :=
               'Abonenin karti DUMMY! Bu Kart servis eklemede kullanilamaz!';
            io_error_type := 1;
            io_error_code := 'ERR100';
            RETURN;
         END IF;

         IF ekipman_durumu_pack.kill_mi (v_sc) = 1
         THEN
            durum :=
               'Abonenin karti KILL olmus! Bu Kart servis eklemede kullanilamaz!';
            io_error_type := 1;
            io_error_code := 'ERR100';
            RETURN;
         END IF;

         IF ekipman_durumu_pack.sinyal_gon_engellenmis_mi (v_sc) = 1
         THEN
            durum :=
               'Abonenin kartina sinyal gönderimi engellenmis! Bu Kart servis eklemede kullanilamaz!';
            io_error_type := 1;
            io_error_code := 'ERR100';
            RETURN;
         END IF;
      END IF;

      durum := '0';

      --Eklenme tarihinden önce servis var mi ?
      FOR servis_varmi_rec IN servis_cur (in_servis_kodu)
      LOOP
         IF servis_varmi_rec.islem = v_servis_ekleme_kodu
         THEN
            durum :=
                  'Servis '
               || TO_CHAR (servis_varmi_rec.tarih, 'DD.MM.YYYY HH24:MI:SS')
               || ' tarihinde zaten var!';
            io_error_type := 1;
            io_error_code := 'ERR108';
            RETURN;
         END IF;

         EXIT;
      END LOOP;

      --Eklenme tarihinden sonra servis var mi ?
      FOR servis_varmi_rec IN servis_varmi_cur (in_servis_kodu)
      LOOP
         IF servis_varmi_rec.islem = v_servis_ekleme_kodu
         THEN
            durum :=
                  'Servis '
               || TO_CHAR (servis_varmi_rec.tarih, 'DD.MM.YYYY HH24:MI:SS')
               || ' tarihinde zaten eklenecek!';
            io_error_type := 1;
            io_error_code := 'ERR108';
            RETURN;
         END IF;

         IF servis_varmi_rec.islem = v_servis_dusurme_kodu
         THEN
            durum :=
                  'Servis '
               || TO_CHAR (servis_varmi_rec.tarih, 'DD.MM.YYYY HH24:MI:SS')
               || ' tarihinde düsme satiri var!';
            io_error_type := 1;
            io_error_code := 'ERR108';
            RETURN;
         END IF;

         EXIT;
      END LOOP;
   END servis_eklenebilir_mi;

   PROCEDURE servis_doldur (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_outlet              IN     VARCHAR2,
      in_servis_kodu         IN     icr_dp_servis_default.code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_billing_frequency   IN     icr_dp_servis_default.billing_frequency%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_tarih               IN     icr_dp_servis_default.effective_date%TYPE,
      in_ekleme_tipi         IN     VARCHAR2,
      in_kullanici           IN     icr_dp_servis_default.degistiren_kullanici%TYPE,
      in_kampanya_ok_mi      IN     NUMBER,
      durum                     OUT VARCHAR2,
      in_kontrol_tipi        IN     NUMBER := 0)
   IS
      /*
       TM_SERVIS VE TM_EK TABLOLARI DOLDURULUYOR...

      TM SERVIS Durum
      A : Asil eklenecek servis
      E : Yumurtlamadan dolayi eklenecek servis
      D : Düsürülecek servis
      Z : Düsen Promosyon taniminda dolayi bitis tarihinde zorunlu düsme ( Advertise_code ='DSH')
      J : Ekleme job
      S : Sorma amaçli islemler ( yumurtlanan servis ,
        daha sonra islemlerde kendisini baslayan gerek yok ise,
        yasak var ise veya ayni servis var ise uyari vermektedir.)

      */
      v_kampanya_ok_mi   NUMBER;
      v_count            NUMBER;
   BEGIN
      durum := '0';

      DELETE FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet;

      DELETE FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet;

      olan_servis_doldur (in_account_number, in_outlet);
      v_kampanya_ok_mi := in_kampanya_ok_mi;

      IF in_kontrol_tipi <> 2
      THEN
         IF in_kampanya_ok_mi <> 0
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet
                   AND campaign_code = in_kampanya_kodu
                   AND promosyon_bitis_tarihi > in_tarih
                   AND durum IS NULL;

            IF v_count = 0
            THEN
               v_kampanya_ok_mi := 0;
            END IF;
         END IF;
      END IF;

      servis_process (in_account_number,
                      in_uye_tipi,
                      in_outlet,
                      in_servis_kodu,
                      in_kampanya_kodu,
                      in_franchise_code,
                      in_billing_frequency,
                      in_tarih,
                      in_kullanici,
                      in_ekleme_tipi,
                      v_kampanya_ok_mi);
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'SERVIS DOLDUR:' || SQLERRM;
   END servis_doldur;

   PROCEDURE servis_durum_kontrol (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     icr_dp_servis_default.code%TYPE,
      in_islem_code          IN     tm_servis.islem%TYPE,
      in_li_effective_date   IN     DATE,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_kaynak              IN     VARCHAR2,
      in_kullanici           IN     co_kullanici.kod%TYPE,
      in_kontrol_tipi        IN     NUMBER,
      io_error_type          IN OUT NUMBER,
      io_error_code          IN OUT VARCHAR2,
      out_aciklama           IN OUT VARCHAR2,
      durum                     OUT VARCHAR2)
   IS
      v_old_islem           tm_servis.islem%TYPE;
      v_old_servis          tm_servis.service_code%TYPE;
      v_old_kampanya        tm_servis.campaign_code%TYPE;
      v_old_frekans         tm_servis.servis_frekansi%TYPE;
      v_sonuc1              BOOLEAN;
      v_sonuc2              BOOLEAN;
      v_servis_var          BOOLEAN;
      v_in_servis_islem     tm_servis.islem%TYPE;
      v_count               NUMBER;
      v_li_effective_date   DATE;
      v_temp                VARCHAR2 (300);
      v_stb_tipi            wiz_customer_hp_life.hp_cluster%TYPE;
      v_tarih_tmp           DATE;

      CURSOR onceki_cur (
         p_service_code         tm_servis.service_code%TYPE,
         p_li_effective_date    tm_servis.tarih%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND islem IN ('ADD', 'DSR')
                  AND TRUNC (tarih) <= TRUNC (p_li_effective_date)
         ORDER BY tarih DESC;

      CURSOR servis_cur (
         p_li_effective_date    tm_servis.tarih%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND islem IN ('ADD', 'DSR')
                  AND TRUNC (tarih) <= TRUNC (p_li_effective_date)
                  AND (durum <> 'J' OR durum IS NULL)
         ORDER BY tarih DESC;

      CURSOR ek_servisler_cur
      IS
           SELECT DISTINCT TRUNC (tarih) tarih
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND islem IN ('ADD', 'DSR')
         ORDER BY tarih DESC;

      CURSOR in_servis_durum_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND islem IN ('ADD', 'DSR')
                AND service_code = in_servis_kodu
                AND tarih = in_li_effective_date
                AND (durum <> 'J' AND durum IS NOT NULL);

      CURSOR son_cur
      IS
           SELECT SUM (sayi),
                  account_number,
                  outlet_location,
                  service_code
             FROM (  SELECT account_number,
                            outlet_location,
                            service_code,
                            SUM (
                               DECODE (islem,
                                       dbs_sabit ('SERVIS_EKLEME'), 1,
                                       dbs_sabit ('SERVIS_DUSURME'), -1,
                                       0))
                               sayi
                       FROM tm_servis
                      WHERE     account_number = in_account_number
                            AND outlet_location = in_outlet_location
                            AND NVL (durum, '9') <> 'J'
                   GROUP BY account_number, outlet_location, service_code)
         GROUP BY account_number, outlet_location, service_code
           HAVING SUM (sayi) <> 1 AND SUM (sayi) <> 0;

      CURSOR ser_islem_cur
      IS
           SELECT islem,
                  service_code,
                  campaign_code,
                  servis_frekansi
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
         ORDER BY service_code, tarih;

      CURSOR ser_islem_cur2
      IS
           SELECT DECODE (p.zorunlu, 'E', 'XXX', p.service_code)
                     AS service_code,
                  p.service_code AS asil_service_code,
                  t.islem
             FROM (SELECT DISTINCT p.service_code, p.zorunlu
                     FROM pr_servis_takip p, pr_servis_takip_detay d
                    WHERE     p.kod = d.servis_takip_kodu
                          AND p.franchise_code = in_franchise_code
                          AND p.listeden_gizle = 'H'
                          AND (   p.bitis_tarihi IS NULL
                               OR p.bitis_tarihi > SYSDATE)
                          AND (p.stb_tipi IS NULL OR p.stb_tipi = v_stb_tipi)
                          AND d.customer_type = in_uye_tipi) p,
                  tm_servis t
            WHERE     p.service_code = t.service_code
                  AND t.account_number = in_account_number
                  AND t.outlet_location = in_outlet_location
                  AND NVL (t.durum, '9') <> 'J'
         ORDER BY service_code, tarih;

      CURSOR ser_sec_cur
      IS
         SELECT DISTINCT p.service_code
           FROM pr_servis_takip p, pr_servis_takip_detay d, tm_servis t
          WHERE     p.kod = d.servis_takip_kodu
                AND p.service_code = t.service_code
                AND p.zorunlu = 'H'
                AND p.franchise_code = in_franchise_code
                AND p.listeden_gizle = 'H'
                AND (p.bitis_tarihi IS NULL OR p.bitis_tarihi > SYSDATE)
                AND (p.stb_tipi IS NULL OR p.stb_tipi = v_stb_tipi)
                AND d.customer_type = in_uye_tipi
                AND t.account_number = in_account_number
                AND t.outlet_location = in_outlet_location
                AND NVL (t.durum, '9') <> 'J';

      CURSOR sec_tarih_cur (
         p_service_code    pr_servis_takip.service_code%TYPE)
      IS
           SELECT MAX (bas_tarih) AS bas_tarih, MAX (bit_tarih) AS bit_tarih
             FROM (SELECT ROWNUM + MOD (ROWNUM, 2) AS sira,
                          DECODE (sayi, 1, tarih, TO_DATE (NULL)) AS bas_tarih,
                          DECODE (sayi, 1, TO_DATE (NULL), tarih) AS bit_tarih
                     FROM (  SELECT DECODE (
                                       t.durum,
                                       NULL, DECODE (t.work_order_number,
                                                     0, TRUNC (SYSDATE) - 1,
                                                     TRUNC (t.tarih)),
                                       TRUNC (t.tarih))
                                       AS tarih,
                                    SUM (
                                       DECODE (t.islem,
                                               dbs_sabit ('SERVIS_EKLEME'), 1,
                                               -1))
                                       AS sayi
                               FROM (SELECT DISTINCT p.service_code
                                       FROM pr_servis_takip p,
                                            pr_servis_takip_detay d
                                      WHERE     p.kod = d.servis_takip_kodu
                                            AND p.service_code = p_service_code
                                            AND p.zorunlu = 'H'
                                            AND p.franchise_code =
                                                   in_franchise_code
                                            AND p.listeden_gizle = 'H'
                                            AND (   p.bitis_tarihi IS NULL
                                                 OR p.bitis_tarihi > SYSDATE)
                                            AND (   p.stb_tipi IS NULL
                                                 OR p.stb_tipi = v_stb_tipi)
                                            AND d.customer_type = in_uye_tipi) p,
                                    tm_servis t
                              WHERE     p.service_code = t.service_code
                                    AND t.account_number = in_account_number
                                    AND t.outlet_location = in_outlet_location
                                    AND NVL (t.durum, '9') <> 'J'
                           GROUP BY DECODE (
                                       t.durum,
                                       NULL, DECODE (t.work_order_number,
                                                     0, TRUNC (SYSDATE) - 1,
                                                     TRUNC (t.tarih)),
                                       TRUNC (t.tarih))
                             HAVING SUM (
                                       DECODE (t.islem,
                                               dbs_sabit ('SERVIS_EKLEME'), 1,
                                               -1)) <> 0) a) a
         GROUP BY sira;

      CURSOR zor_tarih_cur
      IS
           SELECT MAX (bas_tarih) AS bas_tarih, MAX (bit_tarih) AS bit_tarih
             FROM (SELECT ROWNUM + MOD (ROWNUM, 2) AS sira,
                          DECODE (sayi, 1, tarih, TO_DATE (NULL)) AS bas_tarih,
                          DECODE (sayi, 1, TO_DATE (NULL), tarih) AS bit_tarih
                     FROM (  SELECT DECODE (
                                       t.durum,
                                       NULL, DECODE (t.work_order_number,
                                                     0, TRUNC (SYSDATE) - 1,
                                                     TRUNC (t.tarih)),
                                       TRUNC (t.tarih))
                                       AS tarih,
                                    SUM (
                                       DECODE (t.islem,
                                               dbs_sabit ('SERVIS_EKLEME'), 1,
                                               -1))
                                       AS sayi
                               FROM (SELECT DISTINCT p.service_code
                                       FROM pr_servis_takip p,
                                            pr_servis_takip_detay d
                                      WHERE     p.kod = d.servis_takip_kodu
                                            AND p.zorunlu = 'E'
                                            AND p.franchise_code =
                                                   in_franchise_code
                                            AND p.listeden_gizle = 'H'
                                            AND (   p.bitis_tarihi IS NULL
                                                 OR p.bitis_tarihi > SYSDATE)
                                            AND (   p.stb_tipi IS NULL
                                                 OR p.stb_tipi = v_stb_tipi)
                                            AND d.customer_type = in_uye_tipi) p,
                                    tm_servis t
                              WHERE     p.service_code = t.service_code
                                    AND t.account_number = in_account_number
                                    AND t.outlet_location = in_outlet_location
                                    AND NVL (t.durum, '9') <> 'J'
                           GROUP BY DECODE (
                                       t.durum,
                                       NULL, DECODE (t.work_order_number,
                                                     0, TRUNC (SYSDATE) - 1,
                                                     TRUNC (t.tarih)),
                                       TRUNC (t.tarih))
                             HAVING SUM (
                                       DECODE (t.islem,
                                               dbs_sabit ('SERVIS_EKLEME'), 1,
                                               -1)) <> 0) a) a
         GROUP BY sira;

      CURSOR alakart_alamaz_kampanyalar_cur
      IS
           SELECT kmp.kampanya_kodu, service_code, kmp.tarih
             FROM (SELECT CASE
                             WHEN TRIM (promotion_code) IS NULL
                             THEN
                                TRIM (campaign_code)
                             WHEN    TRIM (promosyon_bitis_tarihi) IS NULL
                                  OR promosyon_bitis_tarihi > TRUNC (SYSDATE)
                             THEN
                                TRIM (campaign_code)
                             ELSE
                                'KMP'
                          END
                             AS kampanya_kodu,
                          service_code,
                          tarih
                     FROM tm_servis
                    WHERE     account_number = in_account_number
                          AND outlet_location = in_outlet_location
                          AND NVL (durum, '9') <> 'J'
                          AND islem = dbs_sabit ('SERVIS_EKLEME')) kmp,
                  pr_urun_ozellik_tanim t
            WHERE     t.urun_tipi = 1
                  AND t.ozellik_kodu = 85
                  AND t.listeden_gizle = 'H'
                  AND t.urun_kodu = kmp.kampanya_kodu
         ORDER BY kmp.tarih;
   BEGIN
      durum := '0';
      v_temp := ' ';
      v_stb_tipi := vestel_pack.abone_stb_tipi_bul (in_account_number);

      FOR ek_servisler_rec IN ek_servisler_cur
      LOOP
         FOR servis_rec IN servis_cur (ek_servisler_rec.tarih)
         LOOP
            IF ek_servisler_rec.tarih > in_li_effective_date
            THEN
               v_li_effective_date := ek_servisler_rec.tarih;
            ELSE
               v_li_effective_date := in_li_effective_date;
            END IF;

            FOR onceki_rec
               IN onceki_cur (servis_rec.service_code, v_li_effective_date)
            LOOP
               IF onceki_rec.islem = 'ADD'
               THEN
                  DELETE FROM tm_ek
                        WHERE     account_number = in_account_number
                              AND outlet_location = in_outlet_location;

                  yg_servis_bul (in_account_number,
                                 onceki_rec.service_code,
                                 in_uye_tipi,
                                 in_outlet_location,
                                 in_franchise_code);

                  -- eklenen servis için eger gerek servis abone üzerinde degil
                  -- ise gerek kontrolllerinde takilmamasi için gerek tanimi tablodan silinmektedir.
                  -- Ör : EXT servis için STA gerek ama önceden hatali eklnmis ve STA abone üzerinde degil.
                  -- STA eklenmeye çalisilirken izin vermesi için yapilan bir akis.
                  IF in_servis_kodu = onceki_rec.service_code
                  THEN
                     v_count := 1;                      --ILGILI SERVIS OLUYOR
                  ELSE
                     IF in_islem_code = 'IPT'
                     THEN
                        v_count := 1;
                     ELSE
                        SELECT COUNT (1)
                          INTO v_count
                          FROM tm_ek
                         WHERE     account_number = in_account_number
                               AND outlet_location = in_outlet_location
                               AND durum IN ('G', 'Y')
                               AND service_code IN (SELECT service_code
                                                      FROM tm_servis
                                                     WHERE     account_number =
                                                                  in_account_number
                                                           AND outlet_location =
                                                                  in_outlet_location
                                                           AND islem IN ('ADD',
                                                                         'DSR')
                                                           AND (   durum <>
                                                                      'J'
                                                                OR durum
                                                                      IS NOT NULL)
                                                    UNION
                                                    SELECT p.service_code
                                                      FROM pr_servis_takip p,
                                                           pr_servis_takip_detay d
                                                     WHERE     p.kod =
                                                                  d.servis_takip_kodu
                                                           AND p.service_code =
                                                                  in_servis_kodu
                                                           AND p.franchise_code =
                                                                  in_franchise_code
                                                           AND p.listeden_gizle =
                                                                  'H'
                                                           AND (   p.bitis_tarihi
                                                                      IS NULL
                                                                OR p.bitis_tarihi >
                                                                      SYSDATE)
                                                           AND (   p.stb_tipi
                                                                      IS NULL
                                                                OR p.stb_tipi =
                                                                      v_stb_tipi)
                                                           AND d.customer_type =
                                                                  in_uye_tipi
                                                           AND ROWNUM = 1);
                     --IN SERVISTEN DOLAYI ILGILI SERVIS ISLEMLERI
                     END IF;
                  END IF;

                  IF v_count > 0
                  THEN
                     IF NOT (    in_servis_kodu = onceki_rec.service_code
                             AND in_islem_code = 'DSR')
                     THEN
                        --islem düsürme ise ve düsen servis islemi ise gerek kontrolü yapma...
                        gerek_servis_kontrol (in_account_number,
                                              in_outlet_location,
                                              in_servis_kodu,
                                              onceki_rec.service_code,
                                              v_li_effective_date,
                                              durum);

                        IF durum <> '0'
                        THEN
                           io_error_type := 1;
                           io_error_code := 'ERR77';
                           RETURN;
                        END IF;
                     END IF;

                     IF NOT (in_islem_code = 'DSR')
                     THEN
                        --drg,pla,meg var drg düsürülemiyordu
                        --dsr isleminde yasak kontrolü gereksiz
                        yasak_servis_kontrol (in_account_number,
                                              in_outlet_location,
                                              onceki_rec.service_code,
                                              v_li_effective_date,
                                              durum);

                        IF durum <> '0'
                        THEN
                           io_error_type := 1;
                           io_error_code := 'ERR77';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               EXIT;
            END LOOP;
         END LOOP;
      END LOOP;

      FOR son_rec IN son_cur
      LOOP                                      -- BU CURSOR DA KAYIT OLMAMALI
         durum := son_rec.service_code || ' Servisi için kayit hatalidir.';
         io_error_type := 1;
         io_error_code := 'ERR77';
         RETURN;
      END LOOP;

      --Mustafa 15.06.2004 Asagidaki döngüde paketlerin +-+- seklinde eklenip eklenmedigi kontrol ediliyor.
      --Mustafa 18.04.2005 tarihinde degisiklik yapildi
      --Mustafa 04.08.2005 tarihinde 15.06.2004 tarihinde yapilan kontrol ile,18.04.2005 tarihinde yapilan degisikligin
      --ayri ayri gerekli old. farkina varildi. Su an her 2 durum için kontrol yapiliyor.
      v_old_islem := '0';

      FOR ser_islem_rec IN ser_islem_cur
      LOOP
         IF v_old_islem = '0' OR v_old_servis <> ser_islem_rec.service_code
         THEN
            v_old_islem := ser_islem_rec.islem;
            v_old_servis := ser_islem_rec.service_code;
            v_old_kampanya := ser_islem_rec.campaign_code;
            v_old_frekans := ser_islem_rec.servis_frekansi;

            IF v_old_islem <> dbs_sabit ('SERVIS_EKLEME')
            THEN
               durum :=
                     ser_islem_rec.service_code
                  || ' Servisi için kayit hatalidir_!';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         ELSIF ser_islem_rec.islem = dbs_sabit ('SERVIS_DUSURME')
         THEN
            IF     v_old_kampanya = ser_islem_rec.campaign_code
               AND v_old_frekans = ser_islem_rec.servis_frekansi
            THEN
               v_old_islem := ser_islem_rec.islem;
            ELSE
               durum :=
                     ser_islem_rec.service_code
                  || ' servisi için kayit hatalidir_!!';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         ELSIF ser_islem_rec.islem = dbs_sabit ('SERVIS_EKLEME')
         THEN
            IF v_old_islem = dbs_sabit ('SERVIS_DUSURME')
            THEN
               v_old_islem := ser_islem_rec.islem;
               v_old_kampanya := ser_islem_rec.campaign_code;
               v_old_frekans := ser_islem_rec.servis_frekansi;
            ELSE
               durum :=
                     ser_islem_rec.service_code
                  || ' servisi için kayit hatalidir_!!!';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         END IF;
      END LOOP;

      v_old_islem := '0';

      FOR ser_islem_rec IN ser_islem_cur2
      LOOP
         IF v_old_islem = '0' OR v_old_servis <> ser_islem_rec.service_code
         THEN
            v_old_servis := ser_islem_rec.service_code;
            v_old_islem := ser_islem_rec.islem;

            IF v_old_islem <> dbs_sabit ('SERVIS_EKLEME')
            THEN
               durum :=
                     ser_islem_rec.asil_service_code
                  || ' Servisi için kayit hatalidir_!!!!';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         ELSIF v_old_servis = ser_islem_rec.service_code
         THEN
            IF    (    v_old_islem = dbs_sabit ('SERVIS_EKLEME')
                   AND ser_islem_rec.islem = dbs_sabit ('SERVIS_DUSURME'))
               OR (    v_old_islem = dbs_sabit ('SERVIS_DUSURME')
                   AND ser_islem_rec.islem = dbs_sabit ('SERVIS_EKLEME'))
            THEN
               v_old_servis := ser_islem_rec.service_code;
               v_old_islem := ser_islem_rec.islem;
            ELSE
               durum :=
                     ser_islem_rec.asil_service_code
                  || ' servisi için kayit hatalidir_!!!!!';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         END IF;
      END LOOP;

      --Mustafa 16.06.2004 Asagidaki döngüde üyede seçmeli servisin oldugu tarihlerde gerek servisinin olup olmadigi kontrol ediliyor
      FOR ser_sec_rec IN ser_sec_cur
      LOOP
         FOR sec_tarih_rec IN sec_tarih_cur (ser_sec_rec.service_code)
         LOOP
            FOR zor_tarih_rec IN zor_tarih_cur
            LOOP
               v_sonuc1 := FALSE;
               v_sonuc2 := FALSE;

               IF zor_tarih_rec.bas_tarih IS NULL
               THEN
                  v_sonuc1 := TRUE;
               ELSIF sec_tarih_rec.bas_tarih IS NOT NULL
               THEN
                  IF sec_tarih_rec.bas_tarih >= zor_tarih_rec.bas_tarih
                  THEN
                     v_sonuc1 := TRUE;
                  END IF;
               END IF;

               IF zor_tarih_rec.bit_tarih IS NULL
               THEN
                  v_sonuc2 := TRUE;
               ELSIF sec_tarih_rec.bit_tarih IS NOT NULL
               THEN
                  IF sec_tarih_rec.bit_tarih <= zor_tarih_rec.bit_tarih
                  THEN
                     v_sonuc2 := TRUE;
                  END IF;
               END IF;

               IF v_sonuc1 AND v_sonuc2
               THEN
                  EXIT;
               END IF;
            END LOOP;

            IF NOT v_sonuc1 OR NOT v_sonuc2
            THEN
               durum :=
                     ser_sec_rec.service_code
                  || ' servisi tarih araliginin uyumsuzlugundan dolayi hatalidir !!!';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         END LOOP;
      END LOOP;

      /* Falamur üyeye alakartlar ve alakart alamaz kampanyalarin ayni anda eklenmesine engel oluyor. */
      IF (yetki_pack.yetkisi_varmi (
             in_kullanici,
             'ISLEM_ALAKART_SERVISI_ALAMAZ_KISTINI_GECEBILIR') = '0')
      THEN
         FOR kmp_rec IN alakart_alamaz_kampanyalar_cur
         LOOP
            -- 1 Burada bunun bu alakarta ait tarihden daha önceki küçük esitlerin toplamini aliyorum ve onlar arasinda eger 1 olan alakart var ise o
            -- o zaman hata veriyorum.
            SELECT COUNT (1)
              INTO v_count
              FROM (  SELECT SUM (sayi),
                             account_number,
                             outlet_location,
                             service_code
                        FROM (  SELECT account_number,
                                       outlet_location,
                                       service_code,
                                       SUM (
                                          DECODE (
                                             islem,
                                             dbs_sabit ('SERVIS_EKLEME'), 1,
                                             dbs_sabit ('SERVIS_DUSURME'), -1,
                                             0))
                                          sayi
                                  FROM tm_servis
                                 WHERE     account_number = in_account_number
                                       AND outlet_location = in_outlet_location
                                       AND NVL (durum, '9') <> 'J'
                                       AND tarih <= kmp_rec.tarih
                                       AND service_code IN (SELECT a.service_code
                                                              FROM pr_servis_takip a,
                                                                   pr_servis_takip_detay b,
                                                                   wiz_customer_hp_life l
                                                             WHERE     a.kod =
                                                                          b.servis_takip_kodu
                                                                   AND l.account_number =
                                                                          in_account_number
                                                                   AND a.zorunlu =
                                                                          'H'
                                                                   AND a.franchise_code =
                                                                          in_franchise_code
                                                                   AND a.listeden_gizle =
                                                                          'H'
                                                                   AND (   a.bitis_tarihi
                                                                              IS NULL
                                                                        OR a.bitis_tarihi >
                                                                              SYSDATE)
                                                                   AND (   a.stb_tipi
                                                                              IS NULL
                                                                        OR a.stb_tipi =
                                                                              l.hp_cluster)
                                                                   AND b.customer_type =
                                                                          l.customer_type)
                              GROUP BY account_number,
                                       outlet_location,
                                       service_code)
                    GROUP BY account_number, outlet_location, service_code
                      HAVING SUM (sayi) > 0);

            IF v_count > 0
            THEN
               durum :=
                  '"Alakart Servisi Alamaz" özelligine sahip kampanya ile alakart ayni anda eklenmis.';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;

            -- 2 Burada bu aldigim tarihden buyuk olan ve aldigim servisin bir düsürme kaydi var ise o tarihi al yok ise  Cok buyuk bir tarih al..
            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND NVL (durum, '9') <> 'J'
                   AND tarih > kmp_rec.tarih
                   AND service_code = kmp_rec.service_code
                   AND islem = 'DSR';

            IF v_count > 0
            THEN
               SELECT MIN (tarih)
                 INTO v_tarih_tmp
                 FROM tm_servis
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND NVL (durum, '9') <> 'J'
                      AND tarih > kmp_rec.tarih
                      AND service_code = kmp_rec.service_code
                      AND islem = 'DSR';
            ELSE
               v_tarih_tmp := ADD_MONTHS (SYSDATE, 120);
            END IF;

            -- 3 Burada 2. adimda buldugum elimde ki tarihden büyük aldigim tarihden küçük esit bir  alakart servisi var mis eger var ise o zaman hata ver.
            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND NVL (durum, '9') <> 'J'
                   AND tarih > kmp_rec.tarih
                   AND tarih <= v_tarih_tmp
                   AND service_code IN (SELECT a.service_code
                                          FROM pr_servis_takip a,
                                               pr_servis_takip_detay b,
                                               wiz_customer_hp_life l
                                         WHERE     a.kod =
                                                      b.servis_takip_kodu
                                               AND l.account_number =
                                                      in_account_number
                                               AND a.zorunlu = 'H'
                                               AND a.franchise_code =
                                                      in_franchise_code
                                               AND a.listeden_gizle = 'H'
                                               AND (   a.bitis_tarihi IS NULL
                                                    OR a.bitis_tarihi >
                                                          SYSDATE)
                                               AND (   a.stb_tipi IS NULL
                                                    OR a.stb_tipi =
                                                          l.hp_cluster)
                                               AND b.customer_type =
                                                      l.customer_type);

            IF v_count > 0
            THEN
               durum :=
                  '"Alakart Servisi Alamaz" özelligine sahip kampanya ile alakart ayni anda eklenmis.';
               io_error_type := 1;
               io_error_code := 'ERR77';
               RETURN;
            END IF;
         END LOOP;
      END IF;

      islem_yetki_kontrol (in_account_number,
                           in_outlet_location,
                           in_servis_kodu,
                           in_islem_code,
                           in_kaynak,
                           in_kullanici,
                           in_uye_tipi,
                           in_kontrol_tipi,
                           io_error_type,
                           io_error_code,
                           out_aciklama,
                           durum);
   END servis_durum_kontrol;

   PROCEDURE servis_dsr_ekle (in_account_number            IN     NUMBER,
                              in_outlet_location           IN     VARCHAR2,
                              in_service_code              IN     VARCHAR2,
                              in_campaign_code             IN     VARCHAR2,
                              in_servis_frekansi           IN     VARCHAR2,
                              in_islem                     IN     VARCHAR2,
                              in_tarih                     IN     DATE,
                              in_durum                     IN     VARCHAR2,
                              in_work_order_number         IN     NUMBER,
                              in_baglanti_id               IN     NUMBER,
                              in_promotion_code            IN     VARCHAR2,
                              in_promosyon_bitis_tarihi    IN     DATE,
                              in_li_effective_date         IN     DATE,
                              in_stb_tipi                  IN     VARCHAR2,
                              in_uye_tipi                  IN     VARCHAR2,
                              in_franchise_code            IN     VARCHAR2,
                              in_bundle_servisleri_cikar   IN     VARCHAR2,
                              out_durum                       OUT VARCHAR2)
   IS
      /* MURAT YILDIRIM - 27/03/2012 - TASK:16024
         Bundle servis çikartmlarda bundle içerisindeki tüm servislerin çikartilmasini saglayan kod eklendi.
         Buradaki islem parametre ile kontrol ediliyor.
      */

      v_max_add_tarih   DATE;
      v_count           NUMBER;
   BEGIN
      INSERT INTO tm_servis (account_number,
                             outlet_location,
                             service_code,
                             campaign_code,
                             servis_frekansi,
                             islem,
                             tarih,
                             durum,
                             work_order_number,
                             baglanti_id,
                             promotion_code,
                             promosyon_bitis_tarihi)
           VALUES (in_account_number,
                   in_outlet_location,
                   in_service_code,
                   in_campaign_code,
                   in_servis_frekansi,
                   in_islem,
                   in_tarih,
                   in_durum,
                   in_work_order_number,
                   in_baglanti_id,
                   in_promotion_code,
                   in_promosyon_bitis_tarihi);

      IF in_bundle_servisleri_cikar = 'E'
      THEN
         FOR bundle_rec
            IN (SELECT s.code AS service_code, s.promotion_code
                  FROM icr_dp_servis_default s,
                       icr_dp_servis_default_detay d,
                       pr_bundle_servis b,
                       pr_bundle_tanim t
                 WHERE     s.kod = d.servis_default_kodu
                       AND t.id = b.bundle_id
                       AND b.servis_default_kod = s.kod
                       AND s.listeden_gizle = 'H'
                       AND s.code <> in_service_code
                       AND s.franchise_code = in_franchise_code
                       AND (   s.billing_frequency = in_servis_frekansi
                            OR s.billing_frequency IS NULL)
                       AND d.customer_type = in_uye_tipi
                       AND s.campaign_code = in_campaign_code
                       AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi))
         LOOP
            SELECT MAX (tarih)
              INTO v_max_add_tarih
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND service_code = bundle_rec.service_code
                   AND servis_frekansi = in_servis_frekansi
                   AND campaign_code = in_campaign_code
                   AND islem = 'ADD';

            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND service_code = bundle_rec.service_code
                   AND islem = 'DSR'
                   AND tarih <= in_li_effective_date
                   AND tarih > v_max_add_tarih;

            IF v_count = 0
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM tm_servis
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND service_code = bundle_rec.service_code
                      AND servis_frekansi = in_servis_frekansi
                      AND campaign_code = in_campaign_code
                      AND islem = 'ADD'
                      AND tarih = v_max_add_tarih
                      AND (   promosyon_bitis_tarihi > in_li_effective_date
                           OR promosyon_bitis_tarihi IS NULL
                           OR TRUNC (promosyon_bitis_tarihi) = '01/01/0001');

               IF v_count > 0
               THEN
                  INSERT INTO tm_servis (account_number,
                                         outlet_location,
                                         service_code,
                                         islem,
                                         tarih,
                                         campaign_code,
                                         durum,
                                         servis_frekansi,
                                         promotion_code,
                                         promosyon_bitis_tarihi)
                          VALUES (
                                    in_account_number,
                                    in_outlet_location,
                                    bundle_rec.service_code,
                                    'DSR',
                                      in_li_effective_date
                                    - 10 * (1 / (24 * 60 * 60)),
                                    in_campaign_code,
                                    'D',
                                    in_servis_frekansi,
                                    bundle_rec.promotion_code,
                                    in_promosyon_bitis_tarihi);
               END IF;
            END IF;
         END LOOP;
      END IF;

      out_durum := '0';
   END;

   PROCEDURE yasak_servis_dusur (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_li_effective_date   IN     DATE,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_stb_tipi            IN     VARCHAR2,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      durum                     OUT VARCHAR2)
   IS
      CURSOR grup_no_cur (
         p_durum    tm_ek.durum%TYPE)
      IS
         SELECT DISTINCT grup_no
           FROM tm_ek
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND ilgili_service = in_servis_kodu
                AND durum = p_durum;

      CURSOR tm_ek_cur (
         p_durum      tm_ek.durum%TYPE,
         p_grup_no    tm_ek.grup_no%TYPE)
      IS
           SELECT *
             FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND ilgili_service = in_servis_kodu
                  AND durum = p_durum
                  AND grup_no = p_grup_no
         ORDER BY and_or DESC;

      CURSOR servis_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND TRUNC (tarih) <= TRUNC (in_li_effective_date)
         ORDER BY tarih DESC;

      CURSOR servis_varmi_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND TRUNC (tarih) > TRUNC (in_li_effective_date)
         ORDER BY tarih ASC;

      v_servisler_listesi     VARCHAR2 (500);
      v_yasak_servis_var      BOOLEAN;
      v_servis_ekleme_kodu    tm_servis.islem%TYPE;
      v_servis_dusurme_kodu   tm_servis.islem%TYPE;
      v_yasak_servis          VARCHAR2 (500);
      v_tmp_date              DATE;
   BEGIN
      v_servis_ekleme_kodu := 'ADD';
      v_servis_dusurme_kodu := 'DSR';
      durum := '0';
      --YASAK SERVISI VARMI KONTROLÜ---
      v_yasak_servis_var := FALSE;

      FOR grup_no_rec IN grup_no_cur ('Y')
      LOOP
         FOR tm_ek_rec IN tm_ek_cur ('Y', grup_no_rec.grup_no)
         LOOP
            v_yasak_servis := ' ';
            v_yasak_servis_var := FALSE;

            FOR yasak_servis_rec IN servis_cur (tm_ek_rec.service_code)
            LOOP
               IF yasak_servis_rec.islem <> v_servis_dusurme_kodu
               THEN
                  v_yasak_servis_var := TRUE;
               ELSE
                  v_yasak_servis_var := FALSE;
               END IF;

               EXIT;                 --MAX TARIHE BAKIYOR SON KAYIT GEREKLI...
            END LOOP;

            IF v_yasak_servis_var
            THEN
               IF v_servisler_listesi IS NULL
               THEN
                  v_servisler_listesi := tm_ek_rec.service_code;
               ELSE
                  v_servisler_listesi :=
                        v_servisler_listesi
                     || ' '
                     || tm_ek_rec.and_or
                     || ' '
                     || tm_ek_rec.service_code;
               END IF;

               v_yasak_servis :=
                     v_yasak_servis
                  || ' '
                  || tm_ek_rec.and_or
                  || ' '
                  || tm_ek_rec.service_code;
            END IF;

            IF tm_ek_rec.and_or = 'OR'
            THEN
               IF v_yasak_servis_var
               THEN
                  EXIT;
               END IF;
            ELSE
               IF NOT v_yasak_servis_var
               THEN
                  EXIT;
               END IF;
            END IF;
         END LOOP;

         IF v_yasak_servis_var
         THEN
            --YASAK SERVISLERI DÜSÜR
            FOR tm_ek_rec IN tm_ek_cur ('Y', grup_no_rec.grup_no)
            LOOP
               FOR yasak_servis_rec IN servis_cur (tm_ek_rec.service_code)
               LOOP
                  IF yasak_servis_rec.islem <> v_servis_dusurme_kodu
                  THEN
                     FOR sonraki_rec
                        IN servis_varmi_cur (tm_ek_rec.service_code)
                     LOOP
                        durum :=
                              tm_ek_rec.service_code
                           || ' yasak servisi düsürülemiyor, servsile ilgili '
                           || TO_CHAR (in_li_effective_date,
                                       'DD.MM.YYYY HH24:MI:SS')
                           || ' tarihinden sonraki islemler iptal edilmelidir.';
                        RETURN;
                     END LOOP;

                     IF    yasak_servis_rec.promosyon_bitis_tarihi =
                              TO_DATE ('0001.01.01', 'YYYY.MM.DD')
                        OR yasak_servis_rec.promosyon_bitis_tarihi IS NULL
                     THEN
                        v_tmp_date := NULL;
                     ELSE
                        v_tmp_date := yasak_servis_rec.promosyon_bitis_tarihi;
                     END IF;

                     servis_dsr_ekle (
                        in_account_number            => in_account_number,
                        in_outlet_location           => in_outlet_location,
                        in_service_code              => yasak_servis_rec.service_code,
                        in_campaign_code             => yasak_servis_rec.campaign_code,
                        in_servis_frekansi           => yasak_servis_rec.servis_frekansi,
                        in_islem                     => 'DSR',
                        in_tarih                     =>   in_li_effective_date
                                                        - (1 / (24 * 60 * 60)),
                        in_durum                     => 'D',
                        in_work_order_number         => NULL,
                        in_baglanti_id               => yasak_servis_rec.baglanti_id,
                        in_promotion_code            => yasak_servis_rec.promotion_code,
                        in_promosyon_bitis_tarihi    => v_tmp_date,
                        in_li_effective_date         => in_li_effective_date,
                        in_stb_tipi                  => in_stb_tipi,
                        in_uye_tipi                  => in_uye_tipi,
                        in_franchise_code            => in_franchise_code,
                        in_bundle_servisleri_cikar   => 'E',
                        out_durum                    => durum);
                  /*INSERT INTO tm_servis
                         (account_number, outlet_location, service_code, islem,
                          tarih, campaign_code, durum,
                          servis_frekansi, promotion_code,
                          baglanti_id, promosyon_bitis_tarihi
                         )
                  VALUES (in_account_number, in_outlet_location, yasak_servis_rec.service_code, 'DSR',
                          in_li_effective_date - (1 / (24 * 60 * 60)), yasak_servis_rec.campaign_code, 'D',
                          yasak_servis_rec.servis_frekansi, yasak_servis_rec.promotion_code,
                          yasak_servis_rec.baglanti_id, v_tmp_date
                         );*/
                  END IF;

                  EXIT;
               END LOOP;
            END LOOP;
         END IF;
      END LOOP;
   END yasak_servis_dusur;

   PROCEDURE sabit_promosyon_tarihi (
      in_account_number       IN     tm_servis.account_number%TYPE,
      in_outlet_location      IN     tm_servis.outlet_location%TYPE,
      in_franchise_code       IN     wiz_customer_hp_life.franchise_code%TYPE,
      in_stb_tipi             IN     wiz_customer_hp_life.hp_cluster%TYPE,
      in_uye_tipi             IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_kampanya_kodu        IN     icr_dp_servis_default.campaign_code%TYPE,
      in_li_effective_date    IN     DATE,
      out_promo_baglanti_id      OUT NUMBER,
      out_tablo                  OUT NUMBER,
      durum                      OUT VARCHAR2)
   IS
      CURSOR promo_tarihi_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND campaign_code = in_kampanya_kodu
                AND service_code IN (SELECT a.service_code
                                       FROM pr_servis_takip a,
                                            pr_servis_takip_detay b
                                      WHERE     a.kod = b.servis_takip_kodu
                                            AND a.zorunlu = 'E'
                                            AND a.franchise_code =
                                                   in_franchise_code
                                            AND a.listeden_gizle = 'H'
                                            AND (   a.bitis_tarihi IS NULL
                                                 OR a.bitis_tarihi > SYSDATE)
                                            AND (   a.stb_tipi IS NULL
                                                 OR a.stb_tipi = in_stb_tipi)
                                            AND b.customer_type = in_uye_tipi)
                AND islem = 'DSR'
                AND (durum <> 'J' AND durum IS NOT NULL);

      CURSOR promo_tarihi_cur2
      IS
         SELECT service_code, servis_frekansi
           FROM (SELECT x.service_code,
                        x.servis_frekansi,
                        COUNT (*) OVER () adet
                   FROM tm_servis x
                  WHERE     x.account_number = in_account_number
                        AND x.outlet_location = in_outlet_location
                        AND x.campaign_code = in_kampanya_kodu
                        AND service_code IN (SELECT a.service_code
                                               FROM pr_servis_takip a,
                                                    pr_servis_takip_detay b
                                              WHERE     a.kod =
                                                           b.servis_takip_kodu
                                                    AND a.zorunlu = 'H'
                                                    AND a.franchise_code =
                                                           in_franchise_code
                                                    AND a.listeden_gizle =
                                                           'H'
                                                    AND (   a.bitis_tarihi
                                                               IS NULL
                                                         OR a.bitis_tarihi >
                                                               SYSDATE)
                                                    AND (   a.stb_tipi
                                                               IS NULL
                                                         OR a.stb_tipi =
                                                               in_stb_tipi)
                                                    AND b.customer_type =
                                                           in_uye_tipi)
                        AND x.islem = 'DSR'
                        AND (x.durum <> 'J' AND x.durum IS NOT NULL))
          WHERE adet = 1;

      CURSOR baglanti_cur (
         p_service_code       tm_servis.service_code%TYPE,
         p_servis_frekansi    tm_servis.servis_frekansi%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND servis_frekansi = p_servis_frekansi
                  AND islem = 'ADD'
         ORDER BY tarih DESC;
   BEGIN
      out_promo_baglanti_id := NULL;
      durum := '0';

      FOR promo_rec IN promo_tarihi_cur
      LOOP
         FOR b_rec
            IN baglanti_cur (promo_rec.service_code,
                             promo_rec.servis_frekansi)
         LOOP
            out_promo_baglanti_id := b_rec.baglanti_id;

            IF b_rec.work_order_number > 0
            THEN
               out_tablo := 2;
            ELSE
               out_tablo := 1;
            END IF;

            EXIT;
         END LOOP;

         EXIT;
      END LOOP;

      /*--- Evren --- 20110203 --- begin ---*/
      -- düsen 1 adet servis için pbt nin tasinmasi saglandi.
      IF out_promo_baglanti_id IS NULL
      THEN
         FOR promo_rec2 IN promo_tarihi_cur2
         LOOP
            FOR b_rec2
               IN baglanti_cur (promo_rec2.service_code,
                                promo_rec2.servis_frekansi)
            LOOP
               out_promo_baglanti_id := b_rec2.baglanti_id;

               IF b_rec2.work_order_number > 0
               THEN
                  out_tablo := 2;
               ELSE
                  out_tablo := 1;
               END IF;

               EXIT;
            END LOOP;

            EXIT;
         END LOOP;
      END IF;
   /*--- Evren --- 20110203 --- end ---*/
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Sabit promosyon bulmada hata:' || SQLERRM;
   END sabit_promosyon_tarihi;

   PROCEDURE get_li_eff_date (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_billing_frequency   IN     icr_dp_servis_default.billing_frequency%TYPE,
      in_li_effective_date   IN     DATE,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_kullanici           IN     icr_dp_servis_default.degistiren_kullanici%TYPE,
      out_date                  OUT DATE,
      durum                     OUT VARCHAR2)
   IS
      CURSOR tm_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = in_servis_kodu
                  AND servis_frekansi = in_billing_frequency
         ORDER BY tarih DESC;

      v_frekans         NUMBER;
      v_tarih           DATE;
      v_promo_tarihi    DATE;
      v_campaign_code   tm_servis.campaign_code%TYPE;
      v_islem_kodu      pr_urun_islem_yetki_tanim.islem_kodu%TYPE;
      v_kategori        pr_urun_islem_yetki_tanim.yetki_kategorisi%TYPE;
      v_tmp_tarih       DATE;
   BEGIN
      durum := '0';
      v_tarih := NULL;

      olan_servis_doldur (in_account_number, in_outlet_location);

      -- son servis Eklenen servis ile Ayni ve islem Add ise ve workorder da degil ise
      FOR tm_rec IN tm_cur
      LOOP
         IF     tm_rec.islem = 'ADD'
            AND (   tm_rec.work_order_number = 0
                 OR tm_rec.work_order_number IS NULL)
         THEN
            v_tarih := tm_rec.tarih;
            v_promo_tarihi := tm_rec.promosyon_bitis_tarihi;
            v_campaign_code := tm_rec.campaign_code;
         END IF;

         EXIT;
      END LOOP;

      --ayni servis yok Gelen Tarih ile isleme devam
      IF v_tarih IS NULL
      THEN
         out_date := in_li_effective_date;
         RETURN;
      END IF;

      --ayni servis var Scheduling kontrol
      FOR v_islem_kodu IN 1 .. 2
      LOOP
         servis_util_pack.get_urun_islem_yetki_tanim (
            in_account_number,
            in_uye_tipi,
            TO_NUMBER (in_outlet_location),
            in_servis_kodu,
            in_kampanya_kodu,
            in_franchise_code,
            in_billing_frequency,
            in_li_effective_date,
            39,
            v_islem_kodu,
            in_kullanici,
            v_kategori,
            durum,
            3);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;

         IF v_kategori IS NOT NULL
         THEN
            IF v_islem_kodu = 1
            THEN                               --FARKLI TARIHTE ISLEM YAPMASIN
               IF yetki_pack.yetkisi_varmi (
                     in_kullanici,
                     'ISLEM_URUN_YETKI_KATEGORI_' || v_kategori) > 0
               THEN
                  out_date := in_li_effective_date;
                  RETURN;
               END IF;
            END IF;

            IF v_islem_kodu = 2
            THEN                                              --GEÇIS YAPMASIN
               IF yetki_pack.yetkisi_varmi (
                     in_kullanici,
                     'ISLEM_URUN_YETKI_KATEGORI_' || v_kategori) = 0
               THEN
                  durum := 'Bu ürün için geçis yapilamaz!';
                  RETURN;
               END IF;
            END IF;
         END IF;
      END LOOP;

      --Ayni servis var schedule et
      servis_normal_dsr_tarihi (in_account_number,
                                in_outlet_location,
                                in_servis_kodu,
                                in_billing_frequency,
                                v_campaign_code,
                                in_li_effective_date,
                                out_date,
                                durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      SELECT billing_freq_number
        INTO v_frekans
        FROM wiz_billing_frequency_codes
       WHERE billing_frequency = in_billing_frequency;

      --      IF in_billing_frequency = 'A'
      --      THEN
      --         v_frekans := 12;
      --      ELSE
      --         v_frekans := in_billing_frequency;
      --      END IF;

      --Asagida; sadece servisin fiyat bitis tarihine, ileri tarihli servis ekleme yapilabiliyor.
      --Ayrica kullanicinin geçmis tarihli servis ekleme yetkisi olsa bile sysdate den önceye servis ekleme yapilamiyor.
      IF SYSDATE > in_li_effective_date
      THEN
         v_tmp_tarih := SYSDATE;
      ELSE
         v_tmp_tarih := in_li_effective_date;
      END IF;

      IF v_frekans = '1'
      THEN
         IF servis_util_pack.urun_ozellik_var_mi (1, in_kampanya_kodu, 9) = 1
         THEN
            out_date := v_tmp_tarih;
         ELSE
            out_date :=
               bilgi_pack.uye_billing_dx (in_account_number, v_tmp_tarih);
         END IF;
      ELSIF     ADD_MONTHS (TRUNC (out_date), -v_frekans) >=
                   TRUNC (
                      ADD_MONTHS (
                         bilgi_pack.uye_next_billing_date (in_account_number),
                         -1))
            AND ADD_MONTHS (TRUNC (out_date), -v_frekans) <
                   TRUNC (
                      bilgi_pack.uye_next_billing_date (in_account_number))
      THEN
         IF TRUNC (v_tmp_tarih) > TRUNC (ADD_MONTHS (out_date, -v_frekans))
         THEN
            IF TRUNC (v_tmp_tarih) <=
                  TRUNC (
                     bilgi_pack.uye_next_billing_date (in_account_number))
            THEN
               out_date := v_tmp_tarih;
            END IF;
         ELSE
            out_date := ADD_MONTHS (out_date, -v_frekans) + (1 / 24) * 12;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'GET_LI_EFF_DATE:' || SQLERRM;
   END get_li_eff_date;

   PROCEDURE dergi_kontrol (
      in_account_number    IN     mb_abone_dergi.account_number%TYPE,
      in_outlet_location   IN     mb_abone_dergi.outlet_location%TYPE,
      in_islem             IN     VARCHAR2,
      in_islem_tarihi      IN     DATE,
      in_kullanici         IN     mb_abone_dergi.giren_kullanici%TYPE,
      durum                   OUT VARCHAR2,
      in_kontrol_tipi      IN     NUMBER := 0)
   IS
      /*
       servis ekleme, düsürme , iptal de çalisan kontrol
       IN_KONTROL_TIPI   = 3 => Bekleyen Dergi Islemi
      */
      /*
       IN_ISLEM 'ADD'
              'DSR'
              'IPT' JOB_CODE='DSR'
      */
      v_count                  NUMBER;
      v_baslangic_donemi       DATE;
      v_bitis_donemi           DATE;
      v_sd_cozulme_tarihi      DATE;
      v_kullanilabilir_donem   NUMBER;
      v_max_date               DATE;

      CURSOR m_cur
      IS
         SELECT *
           FROM mb_abone_dergi
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum = 1;                                          --AÇIK
   BEGIN
      durum := '0';

      IF in_kontrol_tipi <> 3
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM mb_abone_dergi
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum = 1;                                          --AÇIK

         IF v_count > 0
         THEN
            durum :=
                  'Üye ye disaridan DRG servisi gönderimi var! IN_KONTROL_TIPI :'
               || in_kontrol_tipi;

            IF in_islem = 'IPT'
            THEN
               durum := durum || ' Kayit iptal edilemez!';
            END IF;

            RETURN;
         END IF;
      ELSE                                            --BEKLEYEN SERVIS INSERT
         v_sd_cozulme_tarihi := NULL;

         SELECT MAX (beklenen_cozulme_tarihi)
           INTO v_sd_cozulme_tarihi
           FROM ie_uyelik_dondurma
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum = 'D';

         IF v_sd_cozulme_tarihi IS NULL
         THEN
            SELECT MAX (acilma_tarihi)
              INTO v_sd_cozulme_tarihi
              FROM ie_uyelik_kapama
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND durum = 'K';
         END IF;

         FOR m_rec IN m_cur
         LOOP
            IF m_rec.sabit_bitis_donemi IS NOT NULL
            THEN
               v_bitis_donemi := m_rec.sabit_bitis_donemi;
            END IF;

            IF m_rec.sabit_bitis_donemi IS NULL
            THEN
               IF m_rec.baslangic_donemi IS NOT NULL
               THEN
                  v_baslangic_donemi := m_rec.baslangic_donemi;
               END IF;

               IF m_rec.kullanilabilir_donem IS NOT NULL
               THEN
                  v_kullanilabilir_donem :=
                       NVL (m_rec.kullanilabilir_donem, 0)
                     - NVL (m_rec.kullanilan_donem, 0);
               END IF;
            END IF;
         END LOOP;

         IF v_sd_cozulme_tarihi > v_bitis_donemi
         THEN
            v_max_date := v_sd_cozulme_tarihi;
         ELSE
            v_max_date := v_bitis_donemi;
         END IF;

         IF v_baslangic_donemi > v_bitis_donemi
         THEN
            v_max_date := v_baslangic_donemi;
         END IF;

         IF v_max_date IS NULL
         THEN
            v_max_date := TRUNC (SYSDATE, 'MONTH');
            v_kullanilabilir_donem := v_kullanilabilir_donem + 1;
         END IF;

         IF v_kullanilabilir_donem IS NOT NULL
         THEN
            v_max_date := ADD_MONTHS (v_max_date, v_kullanilabilir_donem);
         END IF;

         --DURUM := 'Islem tarihi :'||TO_CHAR(IN_ISLEM_TARIHI,'DD.MM.YYYY HH24:MI:SS')||' max_date'||TO_CHAR(V_MAX_DATE,'DD.MM.YYYY HH24:MI:SS')||' V_KULLANILABILIR_DONEM: '||V_KULLANILABILIR_DONEM;
         --RETURN;
         IF TRUNC (in_islem_tarihi) < TRUNC (v_max_date)
         THEN
            durum :=
                  'Islem tarihi '
               || TO_CHAR (v_max_date, 'DD.MM.YYYY HH24:MI:SS')
               || ' tarihinden küçük olamaz!';
            RETURN;
         END IF;
      END IF;
   /*
   IF IN_ISLEM = 'ADD' THEN
        BEGIN
           SELECT BASLANGIC_DONEMI,SABIT_BITIS_DONEMI
        INTO V_BASLANGIC_DONEMI,V_BITIS_DONEMI
        FROM MB_ABONE_DERGI
        WHERE ACCOUNT_NUMBER = IN_ACCOUNT_NUMBER
        AND OUTLET_LOCATION = IN_OUTLET_LOCATION
        AND DURUM = 1; --AÇIK
        IF V_BITIS_DONEMI IS NULL THEN
          DURUM := 'Üye ye disaridan DRG servisi gönderimi var!';
          RETURN;
        ELSE
          IF TRUNC(IN_ISLEM_TARIHI) < ADD_MONTHS(TRUNC(V_BITIS_DONEMI),1) THEN
            DURUM := 'Üye ye disaridan DRG servisi gönderimi var!'||ADD_MONTHS(TRUNC(V_BITIS_DONEMI),1)||' tarihinden sonra ekleyebilirsiniz ';
            RETURN;
          END IF;
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
   END IF;

   IF IN_ISLEM = 'IPT' THEN
        BEGIN
           SELECT COUNT(1)
        INTO V_COUNT
        FROM MB_ABONE_DERGI
        WHERE ACCOUNT_NUMBER = IN_ACCOUNT_NUMBER
        AND OUTLET_LOCATION = IN_OUTLET_LOCATION
        AND DURUM = 1; --AÇIK
        IF V_COUNT > 0 THEN
          DURUM := 'Üye ye disaridan DRG servisi gönderimi var! Kayit iptal edilemez!';
          RETURN;
        END IF;
     EXCEPTION
        WHEN OTHERS THEN
           NULL;
     END;
   END IF;
   */
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'DERGI KONTROL:' || SQLERRM;
   END dergi_kontrol;

   FUNCTION bundle_servis_varmi (
      in_account_number      IN tm_ek.account_number%TYPE,
      in_outlet_location     IN tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN VARCHAR2,
      in_billing_frequency   IN icr_dp_servis_default.billing_frequency%TYPE,
      in_li_effective_date   IN DATE)
      RETURN NUMBER
   IS
      --return 1 var 0 yok
      v_count   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO v_count
        FROM tm_servis t1
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND service_code = in_servis_kodu
             AND servis_frekansi = in_billing_frequency
             AND TRUNC (tarih) <= TRUNC (in_li_effective_date)
             AND islem = 'ADD'
             AND NOT EXISTS
                        ( --bundle i ezer özelligine sahip servisleri dikkate alma
                         SELECT urun_kodu
                           FROM pr_urun_ozellik_tanim p
                          WHERE     p.urun_tipi = 1
                                AND p.ozellik_kodu = 21
                                AND p.listeden_gizle = 'H'
                                AND p.urun_kodu = t1.campaign_code)
             AND NOT EXISTS
                        (SELECT *
                           FROM tm_servis t2
                          WHERE     t2.account_number = in_account_number
                                AND t2.outlet_location = in_outlet_location
                                AND t2.service_code = in_servis_kodu
                                AND t2.servis_frekansi = in_billing_frequency
                                AND t2.tarih >= t1.tarih
                                AND islem = 'DSR');

      IF v_count > 0
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END bundle_servis_varmi;

   PROCEDURE bundle_kontrol (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_billing_frequency   IN     icr_dp_servis_default.billing_frequency%TYPE,
      in_li_effective_date   IN     DATE,
      in_ozel_fiyat          IN     NUMBER,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_stb_tipi            IN     VARCHAR2,
      in_kaynak              IN     VARCHAR2,
      in_kullanici           IN     co_kullanici.kod%TYPE,
      in_dsr_z_end_date      IN     DATE,
      in_dsr_z_d_mi          IN     VARCHAR2,
      out_error_type            OUT NUMBER,
      out_error_code            OUT VARCHAR2,
      out_aciklama              OUT VARCHAR2,
      durum                     OUT VARCHAR2)
   IS
      --servisle ilgili bundle kodlar bulunur
      v_bundle_kampanya     VARCHAR2 (3);
      v_yetkili             NUMBER (1);
      v_servis_dusur        CHAR (1) := 'H';

      CURSOR bundle_kod_cur
      IS
           SELECT DISTINCT t.kod, kapsam_adet, s.campaign_code
             FROM icr_dp_servis_default s,
                  icr_dp_servis_default_detay d,
                  pr_bundle_servis b,
                  pr_bundle_tanim t
            WHERE     s.kod = d.servis_default_kodu
                  AND t.id = b.bundle_id
                  AND TRUNC (t.baslangic_tarihi) <= TRUNC (SYSDATE)
                  AND (   TRUNC (t.bitis_tarihi) > TRUNC (SYSDATE)
                       OR t.bitis_tarihi IS NULL)
                  AND b.servis_default_kod = s.kod
                  AND s.code = in_servis_kodu
                  AND s.listeden_gizle = 'H'
                  AND s.franchise_code = in_franchise_code
                  AND (   s.billing_frequency = in_billing_frequency
                       OR s.billing_frequency IS NULL)
                  AND d.customer_type = in_uye_tipi
                  AND (   s.campaign_code = v_bundle_kampanya
                       OR v_bundle_kampanya IS NULL)
                  AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                  AND (   s.effective_date IS NULL
                       OR s.effective_date <= in_li_effective_date)
                  AND (   (s.expire_date IS NULL OR s.expire_date > SYSDATE)
                       OR v_yetkili <> 0)
         ORDER BY kapsam_adet DESC;

      --servisle ilgili bundle lar profile uyuyor mu
      CURSOR profil_cur (
         p_bundle_kod    NUMBER,
         p_kapsam        NUMBER,
         p_kampanya      VARCHAR2)
      IS
         SELECT s.*
           FROM icr_dp_servis_default s,
                icr_dp_servis_default_detay d,
                pr_bundle_servis b,
                pr_bundle_tanim t
          WHERE     s.kod = d.servis_default_kodu
                AND t.id = b.bundle_id
                AND t.kod = p_bundle_kod
                AND t.kapsam = p_kapsam
                AND TRUNC (t.baslangic_tarihi) <= TRUNC (SYSDATE)
                AND (   TRUNC (t.bitis_tarihi) > TRUNC (SYSDATE)
                     OR t.bitis_tarihi IS NULL)
                AND b.servis_default_kod = s.kod
                AND (   (s.code <> in_servis_kodu AND p_kapsam = 1)
                     OR p_kapsam = 2)
                AND s.listeden_gizle = 'H'
                AND s.franchise_code = in_franchise_code
                AND (   s.billing_frequency = in_billing_frequency
                     OR s.billing_frequency IS NULL)
                AND d.customer_type = in_uye_tipi
                AND s.campaign_code = p_kampanya
                AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                AND (   s.effective_date IS NULL
                     OR s.effective_date <= in_li_effective_date)
                AND (   (s.expire_date IS NULL OR s.expire_date > SYSDATE)
                     OR v_yetkili <> 0);

      CURSOR tm_cur (
         p_servis_kodu    VARCHAR2)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_servis_kodu
         ORDER BY tarih DESC;

      CURSOR tm_dsr_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = in_servis_kodu
                AND islem = 'DSR'
                AND campaign_code = in_kampanya_kodu;

      v_profil_mevcut       BOOLEAN;
      v_servis_frekansi     CHAR (1);
      v_profil_kampanya     CHAR (3);
      v_servis_any_count    NUMBER;
      v_count               NUMBER;
      v_count1              NUMBER;
      v_tmp_mevcut_servis   VARCHAR2 (300);
      v_tmp_servis          VARCHAR2 (100);
   BEGIN
      durum := '0';
      v_yetkili :=
         yetki_pack.yetkisi_varmi (in_kullanici,
                                   'SERVIS_EKLEME_BITMIS_KAMPANYA_ILE');

      SELECT COUNT (1)
        INTO v_count
        FROM icr_dp_servis_default s,
             icr_dp_servis_default_detay d,
             pr_bundle_servis b,
             pr_bundle_tanim t
       WHERE     s.kod = d.servis_default_kodu
             AND t.id = b.bundle_id
             AND TRUNC (t.baslangic_tarihi) <= TRUNC (SYSDATE)
             AND (   TRUNC (t.bitis_tarihi) > TRUNC (SYSDATE)
                  OR t.bitis_tarihi IS NULL)
             AND b.servis_default_kod = s.kod
             AND s.code = in_servis_kodu
             AND s.listeden_gizle = 'H'
             AND s.franchise_code = in_franchise_code
             AND (   s.billing_frequency = in_billing_frequency
                  OR s.billing_frequency IS NULL)
             AND d.customer_type = in_uye_tipi
             AND s.campaign_code = in_kampanya_kodu
             AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
             AND (   s.effective_date IS NULL
                  OR s.effective_date <= in_li_effective_date)
             AND (   (s.expire_date IS NULL OR s.expire_date > SYSDATE)
                  OR v_yetkili <> 0);

      --bundle servis degil
      --bundle profile ugun kayit var mi
      IF v_count = 0
      THEN
         --Gelen kampanyada bundle i ezer özelligi varsa geri kalan islemleri yapmasina gerek yok.
         SELECT COUNT (*)
           INTO v_count
           FROM pr_urun_ozellik_tanim
          WHERE     urun_tipi = 1
                AND ozellik_kodu = 21
                AND listeden_gizle = 'H'
                AND urun_kodu = in_kampanya_kodu;

         IF v_count > 0
         THEN
            RETURN;
         END IF;

         v_profil_kampanya := NULL;

         FOR bundle_kod_rec IN bundle_kod_cur
         LOOP
            v_profil_mevcut := TRUE;
            v_tmp_mevcut_servis := NULL;

            FOR profil_rec
               IN profil_cur (bundle_kod_rec.kod,
                              1,
                              bundle_kod_rec.campaign_code)
            LOOP                                          --kapsam exact match
               IF bundle_servis_varmi (in_account_number,
                                       in_outlet_location,
                                       profil_rec.code,
                                       profil_rec.billing_frequency,
                                       in_li_effective_date) = 0
               THEN
                  v_profil_mevcut := FALSE;
                  EXIT;
               END IF;

               SELECT descr
                 INTO v_tmp_servis
                 FROM wiz_product_codes
                WHERE product_code = profil_rec.code;

               IF v_tmp_mevcut_servis IS NULL
               THEN
                  v_tmp_mevcut_servis := v_tmp_servis;
               ELSE
                  v_tmp_mevcut_servis :=
                     v_tmp_mevcut_servis || ', ' || v_tmp_servis;
               END IF;

               v_profil_kampanya := profil_rec.campaign_code;
            END LOOP;

            IF v_profil_mevcut
            THEN
               v_servis_any_count := 0;

               FOR profil_rec
                  IN profil_cur (bundle_kod_rec.kod,
                                 2,
                                 bundle_kod_rec.campaign_code)
               LOOP                                               --kapsam any
                  IF bundle_servis_varmi (in_account_number,
                                          in_outlet_location,
                                          profil_rec.code,
                                          profil_rec.billing_frequency,
                                          in_li_effective_date) = 1
                  THEN
                     v_servis_any_count := v_servis_any_count + 1;

                     IF profil_rec.code <> in_servis_kodu
                     THEN
                        SELECT descr
                          INTO v_tmp_servis
                          FROM wiz_product_codes
                         WHERE product_code = profil_rec.code;

                        IF v_tmp_mevcut_servis IS NULL
                        THEN
                           v_tmp_mevcut_servis := v_tmp_servis;
                        ELSE
                           v_tmp_mevcut_servis :=
                              v_tmp_mevcut_servis || ', ' || v_tmp_servis;
                        END IF;
                     END IF;
                  END IF;

                  IF v_servis_any_count = bundle_kod_rec.kapsam_adet
                  THEN
                     v_profil_kampanya := profil_rec.campaign_code;
                     v_profil_mevcut := TRUE;
                  ELSE
                     v_profil_mevcut := FALSE;
                  END IF;

                  IF v_servis_any_count > bundle_kod_rec.kapsam_adet
                  THEN
                     durum :=
                           v_profil_kampanya
                        || ' kampanyasindan '
                        || bundle_kod_rec.kapsam_adet
                        || ' adetten fazla servis alinamaz!';
                     out_error_type := '1';
                     out_error_code := 'ERR77';
                     v_profil_mevcut := FALSE;
                     RETURN;
                  END IF;
               END LOOP;
            END IF;

            IF v_profil_mevcut AND v_profil_kampanya IS NOT NULL
            THEN
               SELECT descr
                 INTO v_tmp_servis
                 FROM wiz_product_codes
                WHERE product_code = in_servis_kodu;

               IF in_kaynak = 'DBS'
               THEN
                  v_tmp_mevcut_servis :=
                        'Mevcut '
                     || v_tmp_mevcut_servis
                     || ' üyeliginiz ile birlikte '
                     || v_tmp_servis
                     || ' servisini '
                     || v_profil_kampanya
                     || ' kampanyasi eklediginiz takdirde çok avantajli fiyatlardan yararlanabilirsiniz!';
               ELSE
                  v_tmp_mevcut_servis :=
                        '[BUNDLE]['
                     || v_profil_kampanya
                     || '] Mevcut '
                     || v_tmp_mevcut_servis
                     || ' üyeliginiz ile birlikte '
                     || v_tmp_servis
                     || ' servisine devam etmek istediginiz takdirde çok avantajli fiyatlardan yararlanabilirsiniz!';
               END IF;

               IF out_aciklama IS NULL
               THEN
                  out_aciklama := v_tmp_mevcut_servis;
               ELSE
                  out_aciklama := out_aciklama || '<E>' || v_tmp_mevcut_servis;
               --<E> Enter
               END IF;

               v_tmp_mevcut_servis := NULL;
               EXIT;
            END IF;
         END LOOP;
      ELSE                                                     --bundle servis
         v_profil_kampanya := NULL;
         v_bundle_kampanya := in_kampanya_kodu;

         FOR bundle_kod_rec IN bundle_kod_cur
         LOOP
            v_profil_mevcut := TRUE;

            FOR profil_rec
               IN profil_cur (bundle_kod_rec.kod, 1, v_bundle_kampanya)
            LOOP                                          --kapsam exact match
               v_profil_kampanya := profil_rec.campaign_code;

               FOR tm_rec IN tm_cur (profil_rec.code)
               LOOP
                  IF tm_rec.tarih > in_li_effective_date
                  THEN
                     durum :=
                           v_profil_kampanya
                        || ' Bundle kampanyasi için '
                        || tm_rec.service_code
                        || ' servisinin '
                        || TO_DATE (tm_rec.tarih, 'dd.mm.yyyy hh24:mi')
                        || ' tarihinden sonraki islemleri iptal edilmelidir!';
                     out_error_type := '1';
                     out_error_code := 'ERR77';
                     RETURN;
                  END IF;

                  IF tm_rec.islem = 'ADD'
                  THEN
                     servis_dsr_ekle (
                        in_account_number            => in_account_number,
                        in_outlet_location           => in_outlet_location,
                        in_service_code              => tm_rec.service_code,
                        in_campaign_code             => tm_rec.campaign_code,
                        in_servis_frekansi           => tm_rec.servis_frekansi,
                        in_islem                     => 'DSR',
                        in_tarih                     =>   in_li_effective_date
                                                        - 10 * (1 / (24 * 60 * 60)),
                        in_durum                     => 'D',
                        in_work_order_number         => NULL,
                        in_baglanti_id               => NULL,
                        in_promotion_code            => tm_rec.promotion_code,
                        in_promosyon_bitis_tarihi    => tm_rec.promosyon_bitis_tarihi,
                        in_li_effective_date         => in_li_effective_date,
                        in_stb_tipi                  => in_stb_tipi,
                        in_uye_tipi                  => in_uye_tipi,
                        in_franchise_code            => in_franchise_code,
                        in_bundle_servisleri_cikar   => 'E',
                        out_durum                    => durum);
                  /*INSERT INTO tm_servis
                         (account_number, outlet_location, service_code, islem,
                          tarih, campaign_code, durum,
                          promotion_code, servis_frekansi, promosyon_bitis_tarihi
                         )
                  VALUES (in_account_number, in_outlet_location, tm_rec.service_code, 'DSR',
                          in_li_effective_date - 10 * (1 / (24 * 60 * 60)), tm_rec.campaign_code, 'D',
                          tm_rec.promotion_code, tm_rec.servis_frekansi, tm_rec.promosyon_bitis_tarihi
                         );*/
                  END IF;

                  EXIT;
               END LOOP;

               --add bundle servis
               IF profil_rec.billing_frequency IS NULL
               THEN
                  v_servis_frekansi := in_billing_frequency;
               ELSE
                  v_servis_frekansi := profil_rec.billing_frequency;
               END IF;

               SELECT COUNT (*)
                 INTO v_count1
                 FROM vv_servis_icerik
                WHERE icerik_kodu = 'DRG' AND paket_kodu = profil_rec.code;

               IF v_count1 > 0
               THEN
                  dergi_kontrol (in_account_number,
                                 in_outlet_location,
                                 'ADD',
                                 in_li_effective_date,
                                 in_kullanici,
                                 durum);

                  IF durum <> '0'
                  THEN
                     out_error_type := '1';
                     out_error_code := 'ERR77';
                     RETURN;
                  END IF;
               END IF;

               INSERT INTO tm_servis (account_number,
                                      outlet_location,
                                      service_code,
                                      islem,
                                      tarih,
                                      campaign_code,
                                      durum,
                                      servis_frekansi,
                                      promotion_code)
                    VALUES (in_account_number,
                            in_outlet_location,
                            profil_rec.code,
                            'ADD',
                            in_li_effective_date,
                            profil_rec.campaign_code,
                            'E',
                            v_servis_frekansi,
                            profil_rec.promotion_code);

               --MURAT YILDIRIM 07/05/2012 TASK:15648
               --Bundle servisler eklenirken ekipman uygunlugu kontrolü eklendi
               servisekipmanuyum (in_account_number,
                                  in_outlet_location,
                                  profil_rec.code,
                                  in_kullanici,
                                  out_aciklama,
                                  durum,
                                  out_error_type,
                                  out_error_code,
                                  v_servis_dusur,
                                  'SERVIS_EKLEME' -- uyumsuz olduğu belirlenen servisin düşürülmesi için
                                                 );

               IF durum <> '0'
               THEN
                  RETURN;
               END IF;

               IF in_dsr_z_end_date IS NOT NULL
               THEN
                  INSERT INTO tm_servis (account_number,
                                         outlet_location,
                                         service_code,
                                         islem,
                                         tarih,
                                         campaign_code,
                                         durum,
                                         servis_frekansi,
                                         promotion_code,
                                         promosyon_bitis_tarihi)
                       VALUES (in_account_number,
                               in_outlet_location,
                               profil_rec.code,
                               'DSR',
                               in_dsr_z_end_date,
                               profil_rec.campaign_code,
                               in_dsr_z_d_mi,
                               v_servis_frekansi,
                               profil_rec.promotion_code,
                               in_dsr_z_end_date);
               END IF;
            --               FOR tm_rec IN tm_dsr_cur
            --               LOOP
            --                  INSERT INTO tm_servis
            --                              (account_number, outlet_location, service_code, islem, tarih,
            --                               campaign_code, durum, promotion_code, servis_frekansi,
            --                               promosyon_bitis_tarihi
            --                              )
            --                       VALUES (in_account_number, in_outlet_location, profil_rec.code, 'DSR', tm_rec.tarih,
            --                               profil_rec.campaign_code, 'D', profil_rec.promotion_code, v_servis_frekansi,
            --                               tm_rec.promosyon_bitis_tarihi
            --                              );
            --               END LOOP;
            END LOOP;

            IF v_profil_mevcut
            THEN
               v_servis_any_count := 0;

               FOR profil_rec
                  IN profil_cur (bundle_kod_rec.kod,
                                 2,
                                 bundle_kod_rec.campaign_code)
               LOOP                                               --kapsam any
                  IF bundle_servis_varmi (in_account_number,
                                          in_outlet_location,
                                          profil_rec.code,
                                          profil_rec.billing_frequency,
                                          in_li_effective_date) = 1
                  THEN
                     v_servis_any_count := v_servis_any_count + 1;
                  END IF;

                  IF v_servis_any_count = bundle_kod_rec.kapsam_adet
                  THEN
                     v_profil_kampanya := profil_rec.campaign_code;
                     v_profil_mevcut := TRUE;
                  ELSE
                     v_profil_mevcut := FALSE;
                  END IF;

                  IF v_servis_any_count > bundle_kod_rec.kapsam_adet
                  THEN
                     durum :=
                           v_profil_kampanya
                        || ' kampanyasindan '
                        || bundle_kod_rec.kapsam_adet
                        || ' adetten fazla servis alinamaz!';
                     out_error_type := '1';
                     out_error_code := 'ERR77';
                     v_profil_mevcut := FALSE;
                     RETURN;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Bundle Kontrol:' || SQLERRM;
   END bundle_kontrol;

   /* --- Evren --- 20100708 --- begin ---*/
   PROCEDURE temel_paket_kontrol (
      i_account_number       IN     tm_ek.account_number%TYPE,
      i_outlet_location      IN     tm_ek.outlet_location%TYPE,
      i_temel_paket_sayisi   IN     NUMBER,
      o_durum                   OUT VARCHAR2)
   IS
      temel_paket_var    NUMBER (1) := 0;
      v_franchise_code   wiz_customer_hp_life.franchise_code%TYPE;
      v_uye_tipi         wiz_customer_hp_life.customer_type%TYPE;
      v_stb_tipi         wiz_customer_hp_life.hp_cluster%TYPE;
      v_count            NUMBER;
   BEGIN
      o_durum := '0';

      FOR rec_
         IN (SELECT DISTINCT
                    (CASE
                        WHEN TRUNC (tarih) < TRUNC (SYSDATE)
                        THEN
                           TRUNC (SYSDATE)
                        ELSE
                           TRUNC (tarih)
                     END)
                       tarih
               FROM tm_servis
              WHERE     account_number = i_account_number
                    AND outlet_location = i_outlet_location
                    AND EXISTS
                           (SELECT 1
                              FROM TABLE (
                                      split_table_fnc (
                                         dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))
                             WHERE service_code = COLUMN_VALUE))
      LOOP
         SELECT franchise_code, customer_type, hp_cluster
           INTO v_franchise_code, v_uye_tipi, v_stb_tipi
           FROM wiz_customer_hp_life x
          WHERE x.account_number = i_account_number;

         SELECT   (SELECT COUNT (1)
                     FROM pr_servis_takip a,
                          pr_servis_takip_detay b,
                          tm_servis c
                    WHERE     c.account_number = i_account_number
                          AND c.outlet_location = i_outlet_location
                          AND a.service_code = c.service_code
                          AND a.service_code != 'BSL'
                          AND a.kod = b.servis_takip_kodu
                          AND a.zorunlu = 'E'
                          AND a.franchise_code = v_franchise_code
                          AND a.listeden_gizle = 'H'
                          AND (   a.bitis_tarihi IS NULL
                               OR a.bitis_tarihi > SYSDATE)
                          AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                          AND b.customer_type = v_uye_tipi
                          AND TRUNC (c.tarih) <= TRUNC (rec_.tarih)
                          AND islem = 'ADD')
                - (SELECT COUNT (1)
                     FROM pr_servis_takip a,
                          pr_servis_takip_detay b,
                          tm_servis c
                    WHERE     c.account_number = i_account_number
                          AND c.outlet_location = i_outlet_location
                          AND a.service_code = c.service_code
                          AND a.service_code != 'BSL'
                          AND a.kod = b.servis_takip_kodu
                          AND a.zorunlu = 'E'
                          AND a.franchise_code = v_franchise_code
                          AND a.listeden_gizle = 'H'
                          AND (   a.bitis_tarihi IS NULL
                               OR a.bitis_tarihi > SYSDATE)
                          AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
                          AND b.customer_type = v_uye_tipi
                          AND TRUNC (c.tarih) <= TRUNC (rec_.tarih)
                          AND islem = 'DSR')
           INTO v_count
           FROM DUAL;

         IF v_count = 0
         THEN                           -- o tarihte BSL haric Ana Paket yoksa
            SELECT   (SELECT COUNT (1)
                        FROM tm_servis,
                             TABLE (
                                split_table_fnc (
                                   dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))
                       WHERE     account_number = i_account_number
                             AND outlet_location = i_outlet_location
                             AND COLUMN_VALUE = service_code
                             AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                             AND islem = 'ADD')
                   - (SELECT COUNT (1)
                        FROM tm_servis,
                             TABLE (
                                split_table_fnc (
                                   dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))
                       WHERE     account_number = i_account_number
                             AND outlet_location = i_outlet_location
                             AND COLUMN_VALUE = service_code
                             AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                             AND islem = 'DSR')
              INTO v_count
              FROM DUAL;

            IF v_count < i_temel_paket_sayisi
            THEN
               IF v_count <> 0
               THEN
                  o_durum :=
                        rec_.tarih
                     || ' tarihinde '
                     || i_temel_paket_sayisi
                     || ' Adet Temel Paket bulunmalidir.';
                  RETURN;
               END IF;

               IF v_count = 0
               THEN
                  SELECT   (SELECT COUNT (1)
                              FROM tm_servis
                             WHERE     account_number = i_account_number
                                   AND outlet_location = i_outlet_location
                                   AND service_code = 'BSL'
                                   AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                                   AND islem = 'ADD')
                         - (SELECT COUNT (1)
                              FROM tm_servis
                             WHERE     account_number = i_account_number
                                   AND outlet_location = i_outlet_location
                                   AND service_code = 'BSL'
                                   AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                                   AND islem = 'DSR')
                    INTO v_count
                    FROM DUAL;

                  IF v_count <> 0
                  THEN
                     o_durum :=
                           rec_.tarih
                        || ' tarihinde '
                        || i_temel_paket_sayisi
                        || ' Adet Temel Paket bulunmalidir.';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;

         temel_paket_var := 1;
      END LOOP;

      IF temel_paket_var = 0
      THEN
         o_durum := 'Temel Paketiniz yok.';
         RETURN;
      END IF;

      FOR rec_
         IN (SELECT DISTINCT
                    (CASE
                        WHEN TRUNC (tarih) < TRUNC (SYSDATE)
                        THEN
                           TRUNC (SYSDATE)
                        ELSE
                           TRUNC (tarih)
                     END)
                       tarih
               FROM tm_servis
              WHERE     account_number = i_account_number
                    AND outlet_location = i_outlet_location
                    AND service_code = 'BSL')
      LOOP
         SELECT   (SELECT COUNT (1)
                     FROM tm_servis
                    WHERE     account_number = i_account_number
                          AND outlet_location = i_outlet_location
                          AND service_code = 'BSL'
                          AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                          AND islem = 'ADD')
                - (SELECT COUNT (1)
                     FROM tm_servis
                    WHERE     account_number = i_account_number
                          AND outlet_location = i_outlet_location
                          AND service_code = 'BSL'
                          AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                          AND islem = 'DSR')
           INTO v_count
           FROM DUAL;

         IF v_count > 0
         THEN
            SELECT   (SELECT COUNT (1)
                        FROM tm_servis,
                             TABLE (
                                split_table_fnc (
                                   dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))
                       WHERE     account_number = i_account_number
                             AND outlet_location = i_outlet_location
                             AND COLUMN_VALUE = service_code
                             AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                             AND islem = 'ADD')
                   - (SELECT COUNT (1)
                        FROM tm_servis,
                             TABLE (
                                split_table_fnc (
                                   dbs_dba.dbs_sabit ('TEMEL_PAKETLER')))
                       WHERE     account_number = i_account_number
                             AND outlet_location = i_outlet_location
                             AND COLUMN_VALUE = service_code
                             AND TRUNC (tarih) <= TRUNC (rec_.tarih)
                             AND islem = 'DSR')
              INTO v_count
              FROM DUAL;

            IF v_count < i_temel_paket_sayisi
            THEN
               o_durum :=
                     rec_.tarih
                  || ' tarihinde '
                  || i_temel_paket_sayisi
                  || ' Adet Temel Paket bulunmalidir.';
               RETURN;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         o_durum := 'Temel Paket Kontrol:' || SQLERRM;
   END temel_paket_kontrol;

   /* --- Evren --- 20100708 --- end ---*/
   PROCEDURE servis_islem_kontrol (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_islem_tipi   IN     VARCHAR2,
      in_islem_kaynak        IN     VARCHAR2,
      in_kaynak              IN     VARCHAR2,
      in_kullanici           IN     co_kullanici.kod%TYPE,
      durum                     OUT VARCHAR2,
      in_kontrol_tipi        IN     NUMBER := 0)
   IS
      /*
       servis_islem_kontrol
       Her servis isleminden sonra çagrilir
       DURUM = '0' ise
          iilem commit edilebilir
       else
          islem diger servis islemirleri ile devam eder.

      IN_KAYNAK         'DBS','555','IVR','WEB'....

      IN_KONTROL_TIPI     0 Genel
                     1 Zincir Magaza Satisi
                     2 PUAN ISLEMI
                     3 Bekleyen Servis DRG TALEBI
                     4 Outlet KMP
      in_servis_islem_tipi       'EKLEME' ,'DUSURME', 'IPTAL', 'TARIH_DEGISTIR',

      in_islem_kaynak          'NORMAL_SERVIS', 'DONDURMA_SERVIS', 'KAPAMA_SERVIS'
      */
      v_count               NUMBER;
      v_bundle_dsr_tarihi   DATE;
      v_bundle_add_tarihi   DATE;
      v_dsr_count           NUMBER;
      v_profil_mevcut       BOOLEAN;
      v_profil_kampanya     VARCHAR2 (3);
      v_tmp_profil_servis   VARCHAR2 (1000);
      v_servis_any_count    NUMBER;
      v_servis_bundle_kod   NUMBER;

      CURSOR bundle_cur
      IS
         SELECT DISTINCT campaign_code, servis_frekansi
           FROM tm_servis, pr_urun_ozellik_tanim
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND urun_tipi = 1
                AND ozellik_kodu = 3
                AND campaign_code = urun_kodu;

      CURSOR tm_cur (
         p_campaign_code      VARCHAR2,
         p_servis_frekansi    VARCHAR2)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND servis_frekansi = p_servis_frekansi
                  AND campaign_code = p_campaign_code
                  AND islem = 'ADD'
         ORDER BY tarih;

      CURSOR dsr_cur (
         p_campaign_code      VARCHAR2,
         p_servis_frekansi    VARCHAR2,
         p_tarih              DATE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND servis_frekansi = p_servis_frekansi
                  AND campaign_code = p_campaign_code
                  AND islem = 'DSR'
                  AND tarih > p_tarih
         ORDER BY tarih;

      CURSOR profil_cur (
         p_bundle_kod     NUMBER,
         p_kapsam         NUMBER,
         p_servis_kodu    VARCHAR2)
      IS
         SELECT s.*, kapsam_adet
           FROM icr_dp_servis_default s,
                pr_bundle_servis b,
                pr_bundle_tanim t
          WHERE     t.id = b.bundle_id
                AND t.kod = p_bundle_kod
                AND t.kapsam = p_kapsam
                AND TRUNC (t.baslangic_tarihi) <= TRUNC (v_bundle_add_tarihi)
                AND (   TRUNC (t.bitis_tarihi) > TRUNC (v_bundle_add_tarihi)
                     OR t.bitis_tarihi IS NULL)
                AND b.servis_default_kod = s.kod;

      v_tmp_any_servis      VARCHAR2 (1000);
      v_max_adet            NUMBER;
   BEGIN
      durum := '0';
      olan_servis_doldur (in_account_number, in_outlet_location);

      --Bundle servis varmi
      FOR bnd_rec IN bundle_cur
      LOOP
         FOR tm_rec
            IN tm_cur (bnd_rec.campaign_code, bnd_rec.servis_frekansi)
         LOOP
            BEGIN
               SELECT tarih
                 INTO v_bundle_dsr_tarihi
                 FROM tm_servis
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND service_code = tm_rec.service_code
                      AND servis_frekansi = bnd_rec.servis_frekansi
                      AND campaign_code = bnd_rec.campaign_code
                      AND islem = 'DSR'
                      AND tarih > tm_rec.tarih;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_bundle_dsr_tarihi := NULL;
            END;

            IF    v_bundle_dsr_tarihi IS NULL
               OR (    TRUNC (v_bundle_dsr_tarihi) > TRUNC (SYSDATE)
                   AND TRUNC (v_bundle_dsr_tarihi) > TRUNC (tm_rec.tarih))
            THEN
               --bundle servis izliyor
               --profilin tamami kontrol ediliyor
               IF tm_rec.tarih >= SYSDATE
               THEN
                  v_bundle_add_tarihi := TRUNC (tm_rec.tarih);
               ELSE
                  v_bundle_add_tarihi := TRUNC (SYSDATE);
               END IF;

               --v_bundle_add_tarihi nde profilin tamami mevcut olmali
               SELECT t.kod
                 INTO v_servis_bundle_kod
                 FROM icr_dp_servis_default s,
                      pr_bundle_servis b,
                      pr_bundle_tanim t
                WHERE     t.id = b.bundle_id
                      AND TRUNC (t.baslangic_tarihi) <=
                             TRUNC (v_bundle_add_tarihi)
                      AND (   TRUNC (t.bitis_tarihi) >
                                 TRUNC (v_bundle_add_tarihi)
                           OR t.bitis_tarihi IS NULL)
                      AND b.servis_default_kod = s.kod
                      AND s.code = tm_rec.service_code
                      AND s.listeden_gizle = 'H'
                      AND (   s.billing_frequency = tm_rec.servis_frekansi
                           OR s.billing_frequency IS NULL)
                      AND s.campaign_code = tm_rec.campaign_code
                      AND ROWNUM = 1;

               v_profil_mevcut := TRUE;

               FOR profil_rec
                  IN profil_cur (v_servis_bundle_kod, 1, tm_rec.service_code)
               LOOP                                       --kapsam exact match
                  SELECT COUNT (1)
                    INTO v_count
                    FROM tm_servis
                   WHERE     account_number = in_account_number
                         AND outlet_location = in_outlet_location
                         AND service_code = profil_rec.code
                         AND servis_frekansi = profil_rec.billing_frequency
                         AND campaign_code = profil_rec.campaign_code
                         AND islem = 'ADD'
                         AND TRUNC (tarih) <= TRUNC (v_bundle_add_tarihi);

                  v_profil_kampanya := profil_rec.campaign_code;

                  IF v_count = 0
                  THEN
                     v_profil_mevcut := FALSE;

                     IF v_tmp_profil_servis IS NULL
                     THEN
                        v_tmp_profil_servis :=
                           'Zorunlu servisler:' || profil_rec.code;
                     ELSE
                        v_tmp_profil_servis :=
                           v_tmp_profil_servis || ', ' || profil_rec.code;
                     END IF;
                  END IF;
               END LOOP;

               IF v_profil_mevcut
               THEN
                  v_servis_any_count := 0;

                  FOR profil_rec
                     IN profil_cur (v_servis_bundle_kod,
                                    2,
                                    tm_rec.service_code)
                  LOOP                                            --kapsam any
                     SELECT COUNT (1)
                       INTO v_count
                       FROM tm_servis
                      WHERE     account_number = in_account_number
                            AND outlet_location = in_outlet_location
                            AND service_code = profil_rec.code
                            AND servis_frekansi =
                                   profil_rec.billing_frequency
                            AND campaign_code = profil_rec.campaign_code
                            AND islem = 'ADD'
                            AND TRUNC (tarih) <= TRUNC (v_bundle_add_tarihi);

                     v_profil_kampanya := profil_rec.campaign_code;

                     IF v_count > 0
                     THEN
                        v_servis_any_count := v_servis_any_count + 1;
                     END IF;

                     v_max_adet := profil_rec.kapsam_adet;

                     IF v_tmp_any_servis IS NULL
                     THEN
                        v_tmp_any_servis := profil_rec.code;
                     ELSE
                        v_tmp_any_servis :=
                           v_tmp_any_servis || ', ' || profil_rec.code;
                     END IF;

                     IF v_servis_any_count >= profil_rec.kapsam_adet
                     THEN
                        v_profil_mevcut := TRUE;
                     ELSE
                        v_profil_mevcut := FALSE;
                     END IF;
                  END LOOP;
               END IF;

               IF NOT v_profil_mevcut
               THEN
                  IF v_tmp_any_servis IS NOT NULL
                  THEN
                     v_tmp_any_servis :=
                           'Seçmeli servisler:'
                        || v_tmp_any_servis
                        || ' (max '
                        || v_max_adet
                        || ' adet).';
                  END IF;

                  durum :=
                        ' Abone profili uygun degil! '
                     || v_profil_kampanya
                     || ' kampanyasi için '
                     || v_tmp_profil_servis
                     || ' '
                     || v_tmp_any_servis;
                  RETURN;
               END IF;

               ----
               IF v_bundle_dsr_tarihi IS NOT NULL
               THEN
                  --v_bundle_dsr_tarihi nde profilin tamami düsüyor olmali
                  SELECT COUNT (1)
                    INTO v_count
                    FROM tm_servis
                   WHERE     account_number = in_account_number
                         AND outlet_location = in_outlet_location
                         AND servis_frekansi = bnd_rec.servis_frekansi
                         AND campaign_code = bnd_rec.campaign_code
                         AND islem = 'ADD';

                  SELECT COUNT (1)
                    INTO v_dsr_count
                    FROM tm_servis
                   WHERE     account_number = in_account_number
                         AND outlet_location = in_outlet_location
                         AND servis_frekansi = bnd_rec.servis_frekansi
                         AND campaign_code = bnd_rec.campaign_code
                         AND TRUNC (tarih) = TRUNC (v_bundle_dsr_tarihi)
                         AND islem = 'DSR';

                  IF v_count > v_dsr_count
                  THEN
                     durum :=
                           bnd_rec.campaign_code
                        || ' Kampanyali tüm servisler '
                        || TO_CHAR (v_bundle_dsr_tarihi, 'dd.mm.yyyy')
                        || ' tarihinde düsürülmelidir!';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      /* --- Evren --- 20100708 --- begin ---*/
      DECLARE
         v_guncel_kampanya_kodu        VARCHAR2 (20);
         v_temel_paket_sayisi          NUMBER (1) := -1; --0 di -1 yaptim.0 desteklensin diye..
         v_account_number              NUMBER := in_account_number;
         v_outlet_location             VARCHAR2 (3) := in_outlet_location;
         v_bsl_tek_tanimlama_yetkisi   NUMBER (1);
         v_sol_internet_durum          NUMBER;
         v_limitsiz                    BOOLEAN := FALSE;
      BEGIN
         SELECT COUNT (1)
           INTO v_count
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = 'BSL';

         IF v_count > 0
         THEN
            -- Aktif sol internet bundle i var mı?
            SELECT COUNT (1)
              INTO v_sol_internet_durum
              FROM dbs_dba.gl_kisi_bilgi_iliski ils,
                   dbs_dba.gl_iliski_detay dt
             WHERE     ils.eslestirme_tipi_id = 36
                   AND ils.account_number = in_account_number
                   AND ils.outlet_location = in_outlet_location
                   AND ils.iliski_id = dt.iliski_id
                   AND dt.status = 'A';

            IF v_sol_internet_durum > 0
            THEN
               -- Burada üye üzerinde sol bundle kampanya bulunuyor demektir.
               -- Eğer üyede limitsiz internet paketi varsa üye ye her durumda ürüne atanmış temel paket adeti zorlanacak.
               -- Eğer limitli ürün varsa daha önceden temel paket adet zorunluluğu ne ise o işleyecek.

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_svc svc
                WHERE     svc.account_number = in_account_number
                      AND svc.outlet_location = in_outlet_location
                      AND svc.service_code = 'BSL'
                      AND svc.campaign_code IN (SELECT COLUMN_VALUE
                                                  FROM TABLE (
                                                          split_table_fnc (
                                                             dbs_dba.dbs_sabit (
                                                                'SOL_CALISAN_KAMPANYASI_KOD'))));

               IF v_count = 0
               THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM dbs_dba.wiz_customer_hp_svc_int a
                   WHERE     a.account_number = in_account_number
                         AND outlet_location = in_outlet_location
                         AND EXISTS
                                (SELECT *
                                   FROM dbs_dba.wiz_product_codes_int b
                                  WHERE     download_kota = 'Limitsiz'
                                        AND baglanti_tipi IN ('ADSL', 'FIBER')
                                        AND a.service_code = b.dbs_urun_kodu);

                  IF v_count > 0
                  THEN
                     v_limitsiz := TRUE;
                     v_temel_paket_sayisi := 2;
                  ELSE
                     v_limitsiz := FALSE; -- Sol geçişine kadar eski var olan akışları işlesin..
                     v_temel_paket_sayisi := -1;
                  END IF;
               ELSE
                  v_limitsiz := FALSE; -- DT çalışanlara temel paket zorlanmasın
                  v_temel_paket_sayisi := -1;
               END IF;
            END IF;

            IF v_limitsiz
            THEN
               IF v_temel_paket_sayisi > 0
               THEN
                  temel_paket_kontrol (in_account_number,
                                       in_outlet_location,
                                       v_temel_paket_sayisi,
                                       durum);

                  IF durum <> '0'
                  THEN
                     RETURN;
                  END IF;
               END IF;
            ELSE -- üzerinde internet paketi bulunmuyor veya limitli internet ürünü bulunuyor.
               SELECT COUNT (1)
                 INTO v_bsl_tek_tanimlama_yetkisi
                 FROM mb_abone_ozellik
                WHERE     account_number = in_account_number
                      AND abone_ozellik_kodu = 359
                      AND outlet_location = in_outlet_location;

               IF v_bsl_tek_tanimlama_yetkisi = 0
               THEN                                               -- BSL varsa
                  ------------------------------------------------------------------
                  WHILE     v_account_number IS NOT NULL
                        AND v_outlet_location IS NOT NULL
                  LOOP
                     BEGIN
                          SELECT y.campaign_code
                            INTO v_guncel_kampanya_kodu
                            FROM yk_dp_kontrat y, pr_urun_ozellik_tanim p
                           WHERE     y.uye_no = v_account_number
                                 AND y.devirli_outlet_location =
                                        v_outlet_location
                                 AND y.status IN ('30', '80')
                                 AND p.ozellik_kodu = 102 -- sürekli temel paket adedi özelligi
                                 AND p.urun_kodu = y.campaign_code
                                 AND p.urun_tipi = 1
                                 AND ROWNUM = 1
                        ORDER BY DECODE (y.status,
                                         '80', y.degistirme_tarihi,
                                         y.kayit_aktarilma_tarihi) DESC;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           BEGIN
                              SELECT y.kamp_kod
                                INTO v_guncel_kampanya_kodu
                                FROM dp_account_no y, pr_urun_ozellik_tanim p
                               WHERE     y.account_no = v_account_number
                                     AND y.outlet_location =
                                            v_outlet_location
                                     AND p.ozellik_kodu = 102
                                     AND p.urun_kodu = y.kamp_kod
                                     AND p.urun_tipi = 1;
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 v_guncel_kampanya_kodu := NULL;
                           END;
                     END;

                     IF v_guncel_kampanya_kodu IS NOT NULL
                     THEN
                        BEGIN
                           SELECT NVL (TRIM (parametre_degeri), 0)
                             INTO v_temel_paket_sayisi
                             FROM pr_urun_ozellik_params
                            WHERE     urun_kodu = v_guncel_kampanya_kodu
                                  AND parametre_kodu = 1
                                  AND ozellik_kodu = 102;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              v_temel_paket_sayisi := -1; --0 di -1 yaptim.0 desteklensin diye..
                        END;

                        IF v_temel_paket_sayisi > 0
                        THEN
                           temel_paket_kontrol (in_account_number,
                                                in_outlet_location,
                                                v_temel_paket_sayisi,
                                                durum);

                           IF durum <> '0'
                           THEN
                              RETURN;
                           ELSE
                              EXIT;
                           END IF;
                        END IF;
                     END IF;

                     BEGIN
                        SELECT ad.uye_no, ad.eski_outlet_location
                          INTO v_account_number, v_outlet_location
                          FROM ie_adres_degisikligi ad
                         WHERE     ad.durum = 'P'
                               AND ad.eski_stb_tipi IS NULL
                               AND ad.yeni_stb_tipi IS NULL
                               AND ad.yeni_uye_no = v_account_number
                               AND ad.yeni_outlet_location =
                                      v_outlet_location
                               AND (   ad.uye_no <> ad.yeni_uye_no
                                    OR ad.eski_outlet_location <>
                                          ad.yeni_outlet_location);
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           v_account_number := NULL;
                           v_outlet_location := NULL;
                     END;
                  END LOOP;

                  ------------------------------------------------------------------
                  IF v_temel_paket_sayisi = -1 --0 di -1 yaptim.0 desteklensin diye..
                  THEN
                     IF dbs_dba.hos_paket_uyesi_mi (in_account_number,
                                                    in_outlet_location,
                                                    'E')
                           IS NULL                       --hos paket degil ise
                     THEN
                        --v_temel_paket_sayisi := 2;
                        v_temel_paket_sayisi :=
                           TO_NUMBER (
                              dbs_sabit (
                                 'HOS_PAKET_OLMAYAN_TEMEL_PAKET_ADEDI'));

                        IF v_temel_paket_sayisi > 0
                        THEN
                           temel_paket_kontrol (in_account_number,
                                                in_outlet_location,
                                                v_temel_paket_sayisi,
                                                durum);

                           IF durum <> '0'
                           THEN
                              RETURN;
                           END IF;
                        END IF;
                     ELSE                                     -- Hos paket ise
                        BEGIN
                           SELECT guncel_kampanya_kodu
                             INTO v_guncel_kampanya_kodu
                             FROM fatura.mb_ekipman_taksit_charge
                            WHERE     account_number = in_account_number
                                  AND outlet_location =
                                         NVL (in_outlet_location,
                                              outlet_location)
                                  AND charge_finished IN ('Y', 'N')
                                  AND TRUNC (taahhut_bitis_tar) >
                                         TRUNC (SYSDATE);
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              v_guncel_kampanya_kodu := NULL;
                        END;

                        IF v_guncel_kampanya_kodu IS NOT NULL
                        THEN
                           SELECT COUNT (*)
                             INTO v_count
                             FROM pr_urun_ozellik_tanim
                            WHERE     urun_kodu = v_guncel_kampanya_kodu
                                  AND urun_tipi = 1
                                  AND ozellik_kodu = 100 -- hos paket temel paket ad. öz.
                                  AND listeden_gizle = 'H';

                           IF v_count > 0
                           THEN
                              BEGIN
                                 SELECT NVL (TRIM (parametre_degeri), 0)
                                   INTO v_temel_paket_sayisi
                                   FROM pr_urun_ozellik_params
                                  WHERE     urun_kodu =
                                               v_guncel_kampanya_kodu
                                        AND parametre_kodu = 1
                                        AND ozellik_kodu = 100;
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
                                    v_temel_paket_sayisi := -1; --0 di -1 yaptim.0 desteklensin diye..
                              END;

                              IF v_temel_paket_sayisi > 0
                              THEN
                                 temel_paket_kontrol (in_account_number,
                                                      in_outlet_location,
                                                      v_temel_paket_sayisi,
                                                      durum);

                                 IF durum <> '0'
                                 THEN
                                    RETURN;
                                 END IF;
                              END IF;
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END;

      /* --- Evren --- 20100708 --- end ---*/

      -- MURAT YILDIRIM - 082012 - 16632 - Start
      -- havadan aktivasyonlar eklenmis mi kontrolü yapiliyor
      IF durum = '0'
      THEN
         kampanyalar_pack.servis_havadan_kontrol (in_account_number,
                                                  in_outlet_location,
                                                  in_kullanici,
                                                  durum);
      END IF;

      -- MURAT YILDIRIM - 082012 - 16632 - End

      DELETE FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Servis Islem Kontrol Hatasi olustu!: ' || SQLERRM;
   END servis_islem_kontrol;

   PROCEDURE servis_islem_msg (
      in_account_number    IN     tm_ek.account_number%TYPE,
      in_outlet_location   IN     tm_ek.outlet_location%TYPE,
      in_islem             IN     VARCHAR2,
      in_kullanici         IN     VARCHAR2,
      out_error_type       IN OUT NUMBER,
      out_error_code       IN OUT VARCHAR2,
      out_msg                 OUT VARCHAR2,
      durum                   OUT VARCHAR2)
   IS
      --IN_ISLEM_TIPI       'EKLEME' ,'DUSURME', 'IPTAL', 'TARIH_DEGISTIR',
      v_add_servis            wiz_customer_hp_svc.service_code%TYPE;
      v_drop_servis           wiz_customer_hp_svc.service_code%TYPE;
      v_count                 NUMBER;
      v_get_oppv_mac_siniri   DATE;
   BEGIN
      durum := '0';
      out_msg := NULL;

      IF dbs_sabit ('OPPV_MAC_SATIS_SINIRLI_MI') = 'E'
      THEN
         v_get_oppv_mac_siniri := get_oppv_mac_siniri (SYSDATE, 2);

         --Eklenen servis içeriginde Lig servisi var
         --ve düsen servisin içeriginde yok ise veya düsen servis yok ise
         --Mustafa - Esen 31.05.2004
         SELECT COUNT (1)
           INTO v_count
           FROM tm_servis s, vv_servis_icerik i
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum IS NOT NULL
                AND islem = 'ADD'
                AND service_code = i.paket_kodu
                AND icerik_kodu = 'LIG'
                AND TRUNC (tarih) = TRUNC (SYSDATE);

         IF v_count > 0
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis s, vv_servis_icerik i
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND durum IS NOT NULL
                   AND islem = 'DSR'
                   AND service_code = i.paket_kodu
                   AND icerik_kodu = 'LIG'
                   AND TRUNC (tarih) = TRUNC (SYSDATE);

            IF v_count = 0
            THEN
               IF TRUNC (SYSDATE) <
                     TRUNC (
                          v_get_oppv_mac_siniri
                        + (  dbs_sabit ('OPPV_MAC_PAKET_AKTIFLEME_ZAMANI')
                           / (24 * 60)))
               THEN
                  v_get_oppv_mac_siniri := get_oppv_mac_siniri (SYSDATE, 1);
                  out_msg :=
                        v_get_oppv_mac_siniri
                     || ' tarihinden sonra alinan LIG servisi yayinlari ertesi gün açilir!';
                  out_error_type := 0;
                  out_error_code := 'VLD232';
               ELSE
                  out_msg :=
                          v_get_oppv_mac_siniri
                        + (  dbs_sabit ('OPPV_MAC_PAKET_AKTIFLEME_ZAMANI')
                           / (24 * 60))
                     || ' tarihinde LIG servisi yayinlari açilir!';
                  out_error_type := 0;
                  out_error_code := 'VLD231';
               END IF;
            END IF;
         END IF;
      END IF;

      IF out_msg IS NOT NULL
      THEN
         RETURN;
      END IF;

      IF dbs_sabit ('OUTLET_KAMPANYASI_UYGULANACAK_MI') = 'E'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM (SELECT add_closed_date tarih,
                        service_code,
                        'ADD' job_code,
                        campaign_code,
                        0 work_order_number,
                        servis_frekansi,
                        promotion_code,
                        id baglanti_id,
                        promo_expire_date
                   FROM wiz_customer_hp_svc hs
                  WHERE     account_number = in_account_number
                        AND campaign_code = 'OT1'
                 UNION
                 SELECT DECODE (uds.durum,
                                '1', add_closed_date,
                                '2', beklenen_kapanma_tarihi)
                           tarih,
                        service_code,
                        DECODE (uds.durum, '1', 'ADD', job_code) job_code,
                        campaign_code,
                        DECODE (uds.durum,  '1', 0,  '2', 1)
                           work_order_number,
                        servis_frekansi,
                        promotion_code,
                        uds.id baglanti_id,
                        promo_expire_date
                   FROM ie_uyelik_dondurma_servis uds, ie_uyelik_dondurma ud
                  WHERE     uds.uyelik_dondurma_id = ud.id
                        AND ud.durum = 'D'
                        AND uds.eklenecek_mi = 'E'
                        AND ud.account_number = in_account_number
                        AND campaign_code = 'OT1'
                 UNION
                 SELECT DECODE (uks.durum,
                                '1', add_closed_date,
                                '2', beklenen_kapanma_tarihi)
                           tarih,
                        service_code,
                        DECODE (uks.durum, '1', 'ADD', job_code) job_code,
                        campaign_code,
                        DECODE (uks.durum,  '1', 0,  '2', 1)
                           work_order_number,
                        servis_frekansi,
                        promotion_code,
                        uks.id baglanti_id,
                        promo_expire_date
                   FROM ie_uyelik_kapama_servis uks, ie_uyelik_kapama uk
                  WHERE     uks.uyelik_kapama_id = uk.id
                        AND uk.durum = 'K'
                        AND uks.eklenecek_mi = 'E'
                        AND uk.account_number = in_account_number
                        AND campaign_code = 'OT1'
                 UNION
                 SELECT li_effective_date tarih,
                        service_code,
                        job_code,
                        campaign_code,
                        wol.work_order_number,
                        servis_frekansi,
                        promotion_code,
                        id baglanti_id,
                        promosyon_bitis_tarihi promo_expire_date
                   FROM wiz_wo_line_items wol, wiz_work_order wo
                  WHERE     wol.work_order_number = wo.work_order_number
                        AND wo.account_number = in_account_number
                        AND campaign_code = 'OT1'
                        AND wol.wo_status = 'O'
                        AND wo.wo_status IN ('O', 'P')
                        AND job_code IN (SELECT deger
                                           FROM pa_sabitler
                                          WHERE adi IN ('SERVIS_EKLEME',
                                                        'SERVIS_DUSURME')));

         IF v_count > 0
         THEN
            out_msg :=
               'D I K K A T ! Üye outlet kampanyasindan faydalaniyor. Lütfen diger outletlerini kontrol ediniz!';
            RETURN;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Servis islemi mesaj bulunamadi!' || SQLERRM;
   END servis_islem_msg;

   PROCEDURE servis_sf_urun_bayi_kontrol (
      in_account_number      IN     NUMBER,
      in_outlet_location     IN     CHAR,
      in_servis_kodu         IN     CHAR,
      in_kampanya_kodu       IN     CHAR,
      in_servis_frekansi     IN     CHAR,
      in_li_effective_date   IN     DATE,
      in_sebep_kodu          IN     CHAR,
      in_bayi_kodu           IN     CHAR,
      in_bayiden_satis       IN     VARCHAR2,
      in_ozel_fiyat          IN     NUMBER,
      in_stb_tipi            IN     CHAR,
      in_uye_tipi            IN     CHAR,
      in_franchise_code      IN     CHAR,
      in_islem_kaynak        IN     VARCHAR2,
      in_kontrol_tipi        IN     NUMBER,
      in_kullanici           IN     VARCHAR2,
      out_durum                 OUT VARCHAR2)
   IS
      v_count                    NUMBER (5);
      v_main_service             wiz_campaign_codes.main_service%TYPE;
      v_campaign_sales_channel   NUMBER (5);
      v_sifreli_paket            VARCHAR2 (1);
      v_uye_tip_ticari_konut     VARCHAR2 (6);
      v_kategori_aciklama        VARCHAR2 (30);
      v_bayi_kota_id             NUMBER (10);
      v_il                       VARCHAR2 (3);
      v_ulke                     VARCHAR2 (3);
      v_add_tarihi               DATE;
      v_dsr_tarihi               DATE;
      v_frekans                  NUMBER (2);
      v_tmp_date                 DATE;

      CURSOR asil_dsr_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND durum = 'D'
                  AND islem = 'DSR'
                  AND service_code IN (SELECT service_code
                                         FROM pr_servis_takip a,
                                              pr_servis_takip_detay b
                                        WHERE     a.kod = b.servis_takip_kodu
                                              AND a.zorunlu = 'E'
                                              AND a.franchise_code =
                                                     in_franchise_code
                                              AND a.listeden_gizle = 'H'
                                              AND (   a.bitis_tarihi IS NULL
                                                   OR a.bitis_tarihi > SYSDATE)
                                              AND (   a.stb_tipi IS NULL
                                                   OR a.stb_tipi = in_stb_tipi)
                                              AND b.customer_type = in_uye_tipi)
         ORDER BY tarih DESC;
   BEGIN
      out_durum := '0';

      --Kampanya özelliklerini seç
      SELECT TRIM (main_service), TRIM (campaign_sales_channel)
        INTO v_main_service, v_campaign_sales_channel
        FROM wiz_campaign_codes
       WHERE campaign_code = in_kampanya_kodu;

      IF     v_main_service IS NULL
         AND v_campaign_sales_channel IN (2, 4)
         AND in_uye_tipi <> 'TIC'
      THEN
         v_main_service := in_servis_kodu;
      END IF;

      --sifreli paket mis
      SELECT COUNT (*)
        INTO v_count
        FROM pr_urun_ozellik_tanim a
       WHERE     a.urun_tipi = 1
             AND a.urun_kodu = in_kampanya_kodu
             AND a.ozellik_kodu = 22
             AND a.listeden_gizle = 'H';

      IF v_count > 0
      THEN
         v_sifreli_paket := 'E';
      ELSE
         v_sifreli_paket := 'H';
      END IF;

      --Matriks degil
      IF v_main_service IS NULL
      THEN
         IF v_sifreli_paket = 'E'
         THEN                                                  --sifreli paket
            IF in_kontrol_tipi <> 1
            THEN
               out_durum :=
                  'Bu kampanya sadece sifreli ürün satisi ile eklenebilmektedir';
               RETURN;
            END IF;
         ELSE                                                  --sifreli degil
            IF in_kontrol_tipi = 1
            THEN
               out_durum :=
                  'Bu kampanya ile sifreli ürün satisi yapilamamaktadir';
               RETURN;
            END IF;
         END IF;

         IF v_campaign_sales_channel IN (2, 4)
         THEN                                                  --Bayiden satis
            IF in_bayiden_satis <> 'E'
            THEN
               out_durum :=
                  'Bu kampanya için bayiden satis isaretli olmalidir.';
               RETURN;
            END IF;

            IF in_bayi_kodu IS NULL
            THEN
               out_durum := 'Bu kampanya için bayi kodu bos olamaz';
               RETURN;
            END IF;
         ELSE                                            --bayiden satis degil
            IF in_bayiden_satis = 'E'
            THEN
               out_durum :=
                  'Bu kampanya için bayiden satis isaretli olmamalidir.';
               RETURN;
            END IF;
         --            IF in_bayi_kodu IS NOT NULL
         --            THEN
         --               out_durum := 'Bu kampanya için bayi kodu bos olmali';
         --               RETURN;
         --            END IF;
         END IF;
      ELSE                                                           --matriks
         /*--- Evren --- 20100920 --- begin ---*/
         SELECT COUNT (*)                                       --column_value
           INTO v_count
           FROM TABLE (split_table_fnc (v_main_service))
          WHERE COLUMN_VALUE = in_servis_kodu;

         --IF v_main_service = in_servis_kodu THEN
         /*--- Evren --- 20100920 --- end ---*/
         IF v_count > 0
         THEN                          --Baslangiç paketi ile ekleme yapiliyor
            --Düsen servis var mi
            SELECT COUNT (*)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND campaign_code = in_kampanya_kodu
                   AND durum IN ('A',
                                 'E',
                                 'D',
                                 'B')
                   AND islem = 'DSR';

            IF v_count > 0
            THEN                                            --Düsen servis var
               IF in_kontrol_tipi = 1
               THEN
                  out_durum :=
                     'Matriks kampanyada upgrade/downgrade islemi sifreli ürün satisi ile yapilamamaktadir';
                  RETURN;
               END IF;

               IF in_bayiden_satis = 'E'
               THEN
                  out_durum :=
                     'Matriks kampanyada upgrade/downgrade islemi için bayiden satis isaretli olmamalidir.';
                  RETURN;
               END IF;
            --               IF in_bayi_kodu IS NOT NULL
            --               THEN
            --                  out_durum := 'Matriks kampanyada upgrade/downgrade islemi için bayi kodu bos olmali';
            --                  RETURN;
            --               END IF;
            ELSE                                            --Düsen servis yok
               IF v_sifreli_paket = 'E'
               THEN                                            --sifreli paket
                  IF in_kontrol_tipi <> 1
                  THEN
                     out_durum :=
                        'Bu kampanya sadece sifreli ürün satisi ile eklenebilmektedir';
                     RETURN;
                  END IF;
               ELSE                                            --sifreli degil
                  IF in_kontrol_tipi = 1
                  THEN
                     out_durum :=
                        'Bu kampanya ile sifreli ürün satisi yapilamamaktadir';
                     RETURN;
                  END IF;
               END IF;

               --Bayiden satis or bayiden kotali satis mis
               IF v_campaign_sales_channel IN (2, 4)
               THEN                                            --Bayiden satis
                  IF in_bayiden_satis <> 'E'
                  THEN
                     out_durum :=
                        'Bu kampanya için bayiden satis isaretli olmalidir.';
                     RETURN;
                  END IF;

                  IF in_bayi_kodu IS NULL
                  THEN
                     out_durum := 'Bu kampanya için bayi kodu bos olamaz';
                     RETURN;
                  END IF;
               ELSE                                      --bayiden satis degil
                  IF in_bayiden_satis = 'E'
                  THEN
                     out_durum :=
                        'Bu kampanya için bayiden satis isaretli olmamalidir.';
                     RETURN;
                  END IF;
               --                  IF in_bayi_kodu IS NOT NULL
               --                  THEN
               --                     out_durum := 'Bu kampanya için bayi kodu bos olmali';
               --                     RETURN;
               --                  END IF;
               END IF;
            END IF;
         ELSE                         --Baslangiç paketi ile ekleme yapilmiyor
            IF in_kontrol_tipi = 1
            THEN
               out_durum :=
                  'Matriks kampanyada upgrade/downgrade islemi sifreli ürün satisi ile yapilamamaktadir';
               RETURN;
            END IF;

            IF in_bayiden_satis = 'E'
            THEN
               out_durum :=
                  'Matriks kampanyada upgrade/downgrade islemi için bayiden satis isaretli olmamalidir.';
               RETURN;
            END IF;
         --            IF in_bayi_kodu IS NOT NULL
         --            THEN
         --               out_durum := 'Matriks kampanyada upgrade/downgrade islemi için bayi kodu bos olmali';
         --               RETURN;
         --            END IF;
         END IF;
      END IF;

      IF in_kontrol_tipi = 1
      THEN
         IF TRUNC (in_li_effective_date) <> TRUNC (SYSDATE)
         THEN
            IF yetki_pack.yetkisi_varmi (in_kullanici,
                                         'ISLEM_SF_URUN_SERVIS_ILERI_TARIH') =
                  0
            THEN
               out_durum :=
                  'sifreli ürün satisinda bugünden farkli bir tarih girmek için yetkiniz yok!';
               RETURN;
            END IF;
         END IF;

         /*
           sifreli ürün satisinda, eger mevcut üye üzerindeki paketler
           aylik disinda farkli bir frekansta ise
           ve servis bitis tarihi  takip eden billcycledan büyük ise
           o zaman eklenmesine izin vermek için yetki sahibi olsun.
           Ki bu yetki kimseye verilmeyecek gibi düsünülüyor.
         */
         FOR asil_dsr_rec IN asil_dsr_cur
         LOOP
            IF     asil_dsr_rec.servis_frekansi <> '1'
               AND yetki_pack.yetkisi_varmi (
                      in_kullanici,
                      'ISLEM_SF_URUN_SERVIS_MF_DOWNGRADE') = 0
            THEN
               v_add_tarihi := NULL;
               v_dsr_tarihi := TRUNC (asil_dsr_rec.tarih);
               servis_normal_dsr_tarihi (asil_dsr_rec.account_number,
                                         asil_dsr_rec.outlet_location,
                                         asil_dsr_rec.service_code,
                                         asil_dsr_rec.servis_frekansi,
                                         asil_dsr_rec.campaign_code,
                                         asil_dsr_rec.tarih,
                                         v_add_tarihi,
                                         out_durum);

               IF out_durum <> '0'
               THEN
                  RETURN;
               END IF;

               IF v_add_tarihi IS NOT NULL
               THEN                                --SERVIS FIYAT BITIS TARIHI
                  SELECT billing_freq_number
                    INTO v_frekans
                    FROM wiz_billing_frequency_codes
                   WHERE billing_frequency = asil_dsr_rec.servis_frekansi;

                  --                  IF asil_dsr_rec.servis_frekansi = 'A'
                  --                  THEN
                  --                     v_frekans := 12;
                  --                  ELSE
                  --                     v_frekans := TO_NUMBER (asil_dsr_rec.servis_frekansi);
                  --                  END IF;

                  IF MOD (MONTHS_BETWEEN (v_dsr_tarihi, v_add_tarihi),
                          v_frekans) <> 0
                  THEN
                     out_durum :=
                        'Bu sifreli ürün satisi için ISLEM_SF_URUN_SERVIS_MF_DOWNGRADE yetkisi gereklidir!';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      IF in_bayiden_satis = 'E'
      THEN
         IF v_campaign_sales_channel = 2
         THEN                                  --Kotali bayiden satis kontrolü
            SELECT COUNT (1)
              INTO v_count
              FROM icr_dp_servis_default a,
                   icr_dp_servis_default_detay b,
                   wiz_campaign_codes c
             WHERE     b.servis_default_kodu = a.kod
                   AND c.campaign_code = a.campaign_code
                   AND a.listeden_gizle = 'H'
                   AND (   a.effective_date IS NULL
                        OR a.effective_date <= SYSDATE)
                   AND c.campaign_sales_channel = 2
                   AND a.campaign_code = in_kampanya_kodu;

            IF v_count = 0
            THEN
               out_durum := 'Bu kampanyanin süresi dolMUS';
               RETURN;
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM bt_bayi_kota_hp_svc
             WHERE     campaign_code = in_kampanya_kodu
                   AND account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND listeden_gizle = 'H'
                   AND sales_agent_code <> in_bayi_kodu;

            IF v_count <> 0
            THEN
               out_durum := 'Üye baska bir bayinin kotasinda gözükmektedir';
               RETURN;
            END IF;

            IF    in_islem_kaynak = 'DONDURMA_SERVIS'
               OR in_islem_kaynak = 'KAPAMA_SERVIS'
            THEN
               out_durum :=
                  'Dondurma ve kapama islemlerinde kota kullanilamaz.';
               RETURN;
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM bt_bayi_kota_hp_svc
             WHERE     campaign_code = in_kampanya_kodu
                   AND account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND listeden_gizle = 'H';

            IF v_count = 0
            THEN
               BEGIN
                  SELECT aciklama
                    INTO v_uye_tip_ticari_konut
                    FROM vv_uye_tipi
                   WHERE customer_type = in_uye_tipi;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     out_durum := 'Abone tipi hatasi :' || SQLERRM;
                     RETURN;
               END;

               IF TRIM (v_uye_tip_ticari_konut) = 'TİCARİ'
               THEN
                  BEGIN
                     SELECT aciklama
                       INTO v_kategori_aciklama
                       FROM pr_abone_ozellik a, mb_abone_ozellik b
                      WHERE     a.kod = b.abone_ozellik_kodu
                            AND b.account_number = in_account_number
                            AND a.kod_grubu = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        out_durum :=
                           'Abone özellikte kategori bilgisi eksik! ';
                        RETURN;
                     WHEN OTHERS
                     THEN
                        out_durum := 'Abone özellik hatasi :' || SQLERRM;
                        RETURN;
                  END;
               ELSE
                  v_kategori_aciklama := NULL;
               END IF;

               bayi_detay_pack.tanimli_kota_var_mi (in_account_number,
                                                    in_kampanya_kodu,
                                                    in_servis_kodu,
                                                    v_kategori_aciklama,
                                                    in_servis_frekansi,
                                                    in_ozel_fiyat,
                                                    in_bayi_kodu,
                                                    in_bayiden_satis,
                                                    v_bayi_kota_id,
                                                    out_durum);

               IF out_durum <> '0'
               THEN
                  RETURN;
               END IF;

               IF TRIM (v_bayi_kota_id) IS NULL
               THEN
                  out_durum := 'Bayi kota id elde edilemedi.';
                  RETURN;
               END IF;
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM vv_kampanya_servis_kota x,
                   bt_bayi_kota_hp_svc y,
                   bt_bayi_kota z,
                   wiz_customer_hp_life wz
             WHERE     x.kod = y.campaign_code
                   AND wz.account_number = y.account_number
                   AND wz.customer_type = x.uye_tipi
                   AND x.kod <> in_kampanya_kodu
                   AND y.account_number = in_account_number
                   AND y.outlet_location = in_outlet_location
                   AND y.listeden_gizle = 'H'
                   AND y.service_code = in_servis_kodu
                   AND y.kota_kod_id = z.id
                   AND z.listeden_gizle = 'H'
                   AND z.baslama_tarihi <= SYSDATE
                   AND z.bitis_tarihi > SYSDATE;

            --Bu satir TKP servisi için eklendi
            IF v_count > 0
            THEN
               out_durum :=
                     'Bu abone daha önce baska bir kota kampanyasi ile aktiflenmistir.'
                  || CHR (13)
                  || CHR (10)
                  || 'Farkli bir kota kampanyasi ile tekrar aktifleme yapilamaz.';
               RETURN;
            END IF;
         ELSIF v_campaign_sales_channel = 4
         THEN                                         --Bayiden satis kontrolü
            SELECT a.id, NVL (b.kod, '-1')
              INTO v_ulke, v_il
              FROM (SELECT u.id, hp.city
                      FROM wiz_customer_hp_life hl,
                           wiz_hp_description hp,
                           co_ulke u
                     WHERE     hl.account_number = in_account_number
                           AND hl.service_address_id = hp.service_address_id
                           AND hp.ulke = u.ad) a,
                   co_il b
             WHERE a.id = b.ulke_id(+) AND a.city = b.ad(+);

            SELECT COUNT (*)
              INTO v_count
              FROM icr_dp_servis_default s,
                   icr_dp_servis_default_detay d,
                   wiz_campaign_codes c
             WHERE     s.kod = d.servis_default_kodu
                   AND s.campaign_code = c.campaign_code
                   AND s.listeden_gizle = 'H'
                   AND (   s.billing_frequency IS NULL
                        OR s.billing_frequency = in_servis_frekansi)
                   AND s.sms_code = in_servis_kodu
                   AND s.franchise_code = in_franchise_code
                   AND (   s.effective_date IS NULL
                        OR s.effective_date <= SYSDATE)
                   AND s.campaign_code = in_kampanya_kodu
                   AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                   AND d.customer_type = in_uye_tipi
                   AND c.campaign_sales_channel = 4
                   AND c.start_date <= SYSDATE;

            IF v_count = 0
            THEN
               out_durum := 'Bu kampanyanin servis frekansi hatali';
               RETURN;
            ELSE
               SELECT COUNT (*)
                 INTO v_count
                 FROM icr_dp_servis_default s,
                      icr_dp_servis_default_detay d,
                      (SELECT *
                         FROM icr_dp_servis_default_bayi_det
                        WHERE     (   baslangic_tarihi IS NULL
                                   OR baslangic_tarihi <= SYSDATE)
                              AND (   bitis_tarihi IS NULL
                                   OR bitis_tarihi > SYSDATE) --kurulus tipi - kapsama tipi
                                                             ) b,
                      wiz_campaign_codes c
                WHERE     s.kod = d.servis_default_kodu
                      AND s.kod = b.servis_default_kodu(+)
                      AND s.campaign_code = c.campaign_code
                      AND s.listeden_gizle = 'H'
                      AND (   s.billing_frequency IS NULL
                           OR s.billing_frequency = in_servis_frekansi)
                      AND s.sms_code = in_servis_kodu
                      AND s.franchise_code = in_franchise_code
                      AND (   s.effective_date IS NULL
                           OR s.effective_date <= SYSDATE)
                      AND s.campaign_code = in_kampanya_kodu
                      AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                      AND d.customer_type = in_uye_tipi
                      AND (b.bayi_kodu IS NULL OR b.bayi_kodu = in_bayi_kodu)
                      AND (b.ulke IS NULL OR b.ulke = v_ulke)
                      AND (b.il IS NULL OR b.il = v_il)
                      AND c.campaign_sales_channel = 4
                      AND c.start_date <= SYSDATE;

               IF v_count = 0
               THEN
                  v_count :=
                     uye_kampanya_kontrolu (in_account_number,
                                            in_outlet_location,
                                            in_servis_kodu,
                                            in_kampanya_kodu,
                                            in_li_effective_date);

                  IF v_count = 0
                  THEN
                     out_durum :=
                           'Bu kampanyada bayi kisiti bulunmaktadir.Bu kampanya '
                        || in_bayi_kodu
                        || ' bayi kodu için geçerli degildir.';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      IF     in_uye_tipi = 'TIC'
         AND in_servis_kodu = 'LG2'
         AND in_franchise_code = 'F01'
         AND yetki_pack.yetkisi_varmi (in_kullanici,
                                       'ISLEM_SERVIS_ODEMESIZ_TIC_LIG_EKLE') =
                0
         AND NVL (v_campaign_sales_channel, -1) <> 2
      THEN
         SELECT TO_DATE (
                   dbs_sabit ('TIC_LIG_ODEME_BASLANGIC_KONTROL_TARIHI'),
                   'dd.mm.yyyy')
           INTO v_tmp_date
           FROM DUAL;

         SELECT COUNT (1)
           INTO v_count
           FROM lig_2001_2002
          WHERE     payment_date > v_tmp_date
                AND abone_no = in_account_number
                AND payment_status = 2
                AND payment > 0;

         IF v_count = 0
         THEN
            out_durum :=
               'Lig servisinin eklenebilmesi için ödeme yapilmis olmalidir!';
            RETURN;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'servis_sf_urun_bayi_kontrol :' || SQLERRM;
   END servis_sf_urun_bayi_kontrol;

   PROCEDURE kontrat_kampanya_kontrol (
      in_account_number      IN     NUMBER,
      in_outlet_location     IN     CHAR,
      in_li_effective_date   IN     DATE,
      out_durum                 OUT VARCHAR2)
   IS
      v_kontrat_kampanya   CHAR (3);
      v_kayit_tarih        DATE;
      v_kampanya_sure      NUMBER (5);

      v_max_tarih          DATE;
      v_count              NUMBER;
      v_kampanya_kodu      CHAR (3);
      v_servis_frekansi    CHAR (1);
      v_islem              CHAR (3);
      v_sira               NUMBER (2);
   BEGIN
      out_durum := '0';

      BEGIN
         SELECT campaign_code, kayit_aktarilma_tarihi
           INTO v_kontrat_kampanya, v_kayit_tarih
           FROM yk_dp_kontrat
          WHERE     uye_no = in_account_number
                AND outlet_location = in_outlet_location
                AND status = 30;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN;
      END;

      /*kampanya süresi geçmis mi kontrolü*/
      BEGIN
         SELECT parametre_degeri
           INTO v_kampanya_sure
           FROM pr_urun_ozellik_params
          WHERE urun_kodu = v_kontrat_kampanya AND ozellik_kodu = 120;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_kampanya_sure := 1;
      END;

      IF TRUNC (in_li_effective_date) >
            TRUNC (v_kayit_tarih) + v_kampanya_sure
      THEN
         RETURN;
      END IF;

      /*kampanya için önceden ürün tanimlanmis mi kontrolü*/
      SELECT COUNT (*)
        INTO v_count
        FROM pr_aktivasyon_kmp_grup_kmp
       WHERE kampanya_kodu = v_kontrat_kampanya;

      IF v_count = 0
      THEN
         RETURN;
      END IF;

      FOR rec
         IN (SELECT DISTINCT service_code
               FROM tm_servis
              WHERE     account_number = in_account_number
                    AND outlet_location = in_outlet_location
                    AND TRUNC (tarih) <=
                           TRUNC (v_kayit_tarih) + v_kampanya_sure)
      LOOP
         SELECT MAX (tarih)
           INTO v_max_tarih
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND TRUNC (tarih) <= TRUNC (v_kayit_tarih) + v_kampanya_sure
                AND service_code = rec.service_code;

         SELECT campaign_code, servis_frekansi, islem
           INTO v_kampanya_kodu, v_servis_frekansi, v_islem
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = rec.service_code
                AND tarih = v_max_tarih;

         IF v_islem = 'ADD'
         THEN
            kampanya_hediye_pack.servis_exists_sira (v_kontrat_kampanya,
                                                     rec.service_code,
                                                     v_kampanya_kodu,
                                                     v_servis_frekansi,
                                                     v_sira,
                                                     out_durum);

            IF out_durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'kontrat_kampanya_kontrol :' || SQLERRM;
   END;

   PROCEDURE servis_ekle_calis (in_account_number      IN     NUMBER,
                                in_outlet_location     IN     CHAR,
                                in_servis_kodu         IN     CHAR,
                                in_kampanya_kodu       IN     CHAR,
                                in_servis_frekansi     IN     CHAR,
                                in_li_effective_date   IN     DATE,
                                in_sebep_kodu          IN     CHAR,
                                in_bayi_kodu           IN     CHAR,
                                in_bayiden_satis       IN     CHAR,
                                in_ozel_fiyat          IN     NUMBER,
                                in_stb_tipi            IN     CHAR,
                                in_uye_tipi            IN     CHAR,
                                in_franchise_code      IN     CHAR,
                                in_adet                IN     NUMBER,
                                in_bedelli             IN     CHAR,
                                in_sabit_promo_date    IN     DATE,
                                in_kaynak              IN     VARCHAR2,
                                in_islem_kaynak        IN     VARCHAR2,
                                in_kontrol_tipi        IN     NUMBER,
                                in_kullanici           IN     VARCHAR2,
                                in_is_bundle           IN     VARCHAR2,
                                out_dusurulecek_mi        OUT BOOLEAN,
                                out_error_type            OUT NUMBER,
                                out_error_code            OUT VARCHAR2,
                                out_aciklama              OUT VARCHAR2,
                                out_durum                 OUT VARCHAR2)
   IS
      /*
         Servis Eklemede gerekli kontroller burada yapiliyor
         out_durum ='0' => WO_YARAT ile servis eklenir (düsme satirlari varsa bunlar da düser...)
         OUT_ACIKLAMA ile kullaniciya mesaj gösterilir ve Devam edip etmeyecegi sorulur out_durum='0' olmalidir.
      */
      v_durum                     VARCHAR2 (4000);
      v_dsr_tarihi                DATE;
      v_promotion_end_date        DATE;
      v_servis_varmi              BOOLEAN;
      v_asil_serrvis_promo_code   tm_ek.promotion_code%TYPE;
      v_asil_servis_dusuyor_mu    BOOLEAN;
      v_ek_servis_durum_tipi      CHAR (1);
      v_billing_cycle             wiz_customer_hp_life.billing_cycle%TYPE;
      v_kampanya_ok_mi            NUMBER;
      v_kampanya_grup_kodu        wiz_campaign_codes.group_code%TYPE;
      v_tmp                       VARCHAR2 (100);
      v_count                     NUMBER;
      --v_dusen_servis_var          BOOLEAN;
      v_main_service              wiz_campaign_codes.main_service%TYPE;
      v_matrix_kont_gir           BOOLEAN;
      v_aciklama_puan             VARCHAR2 (512);
      v_dsr_z_end_date            DATE;
      v_dsr_z_d_mi                VARCHAR2 (1);

      CURSOR dsr_kontrol_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND islem IN ('ADD', 'DSR')
                  AND TRUNC (tarih) > TRUNC (in_li_effective_date)
         ORDER BY tarih ASC;

      CURSOR yum_servisler_cur
      IS
         SELECT *
           FROM tm_ek
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum = 'E';

      CURSOR servis_ekmi_cur
      IS
         SELECT *
           FROM tm_ek
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = in_servis_kodu
                AND durum = 'A';

      CURSOR job_servisler_cur
      IS
         SELECT *
           FROM tm_ek
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum = 'J';

      CURSOR servis_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND TRUNC (tarih) <= TRUNC (in_li_effective_date)
         ORDER BY tarih DESC;

      CURSOR asil_dsr_cur (
         p_zorunlu_servis   IN CHAR)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND durum = 'D'
                  AND islem = 'DSR'
                  AND service_code IN (SELECT service_code
                                         FROM pr_servis_takip a,
                                              pr_servis_takip_detay b
                                        WHERE     a.kod = b.servis_takip_kodu
                                              AND a.zorunlu = p_zorunlu_servis
                                              AND a.franchise_code =
                                                     in_franchise_code
                                              AND a.listeden_gizle = 'H'
                                              AND (   a.bitis_tarihi IS NULL
                                                   OR a.bitis_tarihi > SYSDATE)
                                              AND (   a.stb_tipi IS NULL
                                                   OR a.stb_tipi = in_stb_tipi)
                                              AND b.customer_type = in_uye_tipi)
         ORDER BY tarih DESC;

      CURSOR grup_dsr_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND durum IS NOT NULL
                AND islem = 'DSR';

      v_zorunlu_servis            CHAR (1);
      v_zorunlu_servis_varmi      BOOLEAN := FALSE;
   --      CURSOR svc_cur
   --      IS
   --         SELECT *
   --           FROM tm_servis
   --          WHERE account_number = in_account_number
   --            AND outlet_location = in_outlet_location
   --            AND service_code = in_servis_kodu
   --            AND campaign_code <> in_kampanya_kodu
   --            AND servis_frekansi = in_servis_frekansi
   --            AND durum IS NULL;
   BEGIN
      out_error_type := 0;
      out_error_code := 'VLD113';
      out_aciklama := '0';
      out_durum := '0';
      out_dusurulecek_mi := FALSE;

      IF in_servis_kodu = 'MOR'
      THEN
         IF dbs_sabit ('MOR_SATISI_SERBEST') <> 'EVET'
         THEN
            out_durum := 'MOR servisi turk satilmamaktadir!';
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      IF in_stb_tipi = 'TK'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM pr_servis_stok_tanim p, icr_dp_servis_default s
          WHERE     p.icr_dp_kod = s.kod
                AND p.stok_kodu IN (SELECT p.stok_kodu
                                      FROM pr_servis_stok_tanim p,
                                           icr_dp_servis_default s
                                     WHERE     p.icr_dp_kod = s.kod
                                           AND s.listeden_gizle = 'H'
                                           AND p.listeden_gizle = 'H'
                                           AND s.sms_code = in_servis_kodu
                                           AND s.campaign_code IN (SELECT kamp_kod
                                                                     FROM dp_account_no
                                                                    WHERE     account_no =
                                                                                 in_account_number
                                                                          AND outlet_location =
                                                                                 in_outlet_location)
                                           AND (   s.billing_frequency =
                                                      in_servis_frekansi
                                                OR s.billing_frequency
                                                      IS NULL)
                                           AND (   s.stb_tipi IS NULL
                                                OR s.stb_tipi = in_stb_tipi))
                AND s.listeden_gizle = 'H'
                AND p.listeden_gizle = 'H'
                AND s.sms_code = in_servis_kodu
                AND s.campaign_code = in_kampanya_kodu
                AND (   s.billing_frequency = in_servis_frekansi
                     OR s.billing_frequency IS NULL)
                AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                AND (s.effective_date IS NULL OR s.effective_date <= SYSDATE)
                AND (s.expire_date IS NULL OR s.expire_date > SYSDATE);

         IF v_count <> 1
         THEN
            out_durum :=
               'Seçtisiniz kampanya,frekans ve servis uyumlu degil!!';
            out_error_type := 1;
            out_error_code := 'ERR103';
            RETURN;
         END IF;
      END IF;

      IF in_uye_tipi = 'TIC' AND in_servis_kodu IN ('LG2', 'LG0')
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM pr_abone_ozellik a, mb_abone_ozellik b
          WHERE     a.kod = b.abone_ozellik_kodu
                AND b.account_number = in_account_number
                AND kod_grubu = 1;

         IF v_count <> 1
         THEN
            out_durum :=
                  'Abone özellik kategori taniminda hata var! :'
               || in_account_number;
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      SELECT billing_cycle
        INTO v_billing_cycle
        FROM wiz_customer_hp_life
       WHERE account_number = in_account_number;

      IF    in_kontrol_tipi = 2
         OR yetki_pack.yetkisi_varmi (in_kullanici,
                                      'SERVIS_EKLEME_BITMIS_KAMPANYA_ILE') <>
               0
      THEN
         v_kampanya_ok_mi := 1;
      ELSE
         v_kampanya_ok_mi := 0;
      END IF;

      servis_doldur (in_account_number,
                     in_uye_tipi,
                     in_outlet_location,
                     in_servis_kodu,
                     in_kampanya_kodu,
                     in_servis_frekansi,
                     in_franchise_code,
                     in_li_effective_date,
                     'A',                                     --IN_EKLEME_TIPI
                     in_kullanici,
                     v_kampanya_ok_mi,
                     out_durum,
                     in_kontrol_tipi);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      IF in_stb_tipi = 'TK'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = in_servis_kodu
                AND islem = 'ADD';

         IF v_count > 0
         THEN
            out_durum := 'Tek kart üyesinin bu servisi zaten üyede mevcut!';
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      --Ayni Servislerde Farkli kampanya ile eklemek için
      SELECT SUM (DECODE (islem,  'ADD', 1,  'DSR', -1,  0))
        INTO v_count
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND service_code = in_servis_kodu
             AND servis_frekansi = in_servis_frekansi
             AND tarih <= in_li_effective_date;

      IF v_count = 1
      THEN
         FOR svc_rec
            IN (  SELECT *
                    FROM tm_servis
                   WHERE     account_number = in_account_number
                         AND outlet_location = in_outlet_location
                         AND service_code = in_servis_kodu
                         AND servis_frekansi = in_servis_frekansi
                         AND tarih <= in_li_effective_date
                ORDER BY tarih DESC)
         LOOP
            IF    svc_rec.work_order_number = 0
               OR svc_rec.work_order_number IS NULL
            THEN
               IF     in_kaynak <> 'DBS'
                  AND TRUNC (svc_rec.promosyon_bitis_tarihi) >
                         TRUNC (in_li_effective_date)
                  AND yetki_pack.yetkisi_varmi (
                         in_kullanici,
                         'ISLEM_SERVIS_EKLE_AYNI_SERVIS') = 0
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR112';
                  out_durum := 'Ayni servisin kampanyasi devam ediyor!';
                  RETURN;
               END IF;

               IF     TRUNC (svc_rec.promosyon_bitis_tarihi) >
                         TRUNC (in_li_effective_date)
                  AND svc_rec.campaign_code = in_kampanya_kodu
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR112';
                  out_durum := 'Ayni servisin ayni kampanyasi devam ediyor!';
                  RETURN;
               END IF;

               IF     (   TRUNC (svc_rec.promosyon_bitis_tarihi) <=
                             TRUNC (in_li_effective_date)
                       OR TRIM (svc_rec.promotion_code) IS NULL)
                  AND in_kampanya_kodu = 'KMP'
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR112';
                  out_durum := 'Uye uzerinde zaten promosyonsuz servis var!';
                  RETURN;
               END IF;
            ELSE
               IF     in_kaynak <> 'DBS'
                  AND TRIM (svc_rec.promotion_code) IS NOT NULL
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR112';
                  out_durum := 'Ayni servisin kampanyasi devam ediyor!!';
                  RETURN;
               END IF;

               IF     in_kaynak = 'DBS'
                  AND TRIM (svc_rec.promotion_code) IS NOT NULL
                  AND svc_rec.campaign_code = in_kampanya_kodu
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR112';
                  out_durum := 'Ayni servisin ayni kampanyasi devam ediyor!!';
                  RETURN;
               END IF;

               IF     TRIM (svc_rec.promotion_code) IS NULL
                  AND in_kampanya_kodu = 'KMP'
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR112';
                  out_durum := 'Uye uzerinde zaten promosyonsuz servis var!!';
                  RETURN;
               END IF;
            END IF;

            servis_dsr_ekle (
               in_account_number            => in_account_number,
               in_outlet_location           => in_outlet_location,
               in_service_code              => in_servis_kodu,
               in_campaign_code             => svc_rec.campaign_code,
               in_servis_frekansi           => svc_rec.servis_frekansi,
               in_islem                     => 'DSR',
               in_tarih                     =>   in_li_effective_date
                                               - 10 * (1 / (24 * 60 * 60)),
               in_durum                     => 'D',
               in_work_order_number         => NULL,
               in_baglanti_id               => NULL,
               in_promotion_code            => svc_rec.promotion_code,
               in_promosyon_bitis_tarihi    => svc_rec.promosyon_bitis_tarihi,
               in_li_effective_date         => in_li_effective_date,
               in_stb_tipi                  => in_stb_tipi,
               in_uye_tipi                  => in_uye_tipi,
               in_franchise_code            => in_franchise_code,
               in_bundle_servisleri_cikar   => in_is_bundle,
               out_durum                    => out_durum);

            EXIT;
         END LOOP;
      END IF;

      servis_eklenebilir_mi (in_account_number,
                             in_outlet_location,
                             in_servis_kodu,
                             in_li_effective_date,
                             in_servis_frekansi,
                             out_error_type,
                             out_error_code,
                             out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      gerek_servis_kontrol (in_account_number,
                            in_outlet_location,
                            in_servis_kodu,
                            in_servis_kodu,
                            in_li_effective_date,
                            out_durum);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR77';
         out_durum := 'Gerekli servis bulunamadi. ' || out_durum;
         RETURN;
      END IF;

      --PROMOSYON UPDATE
      FOR servis_ekmi_rec IN servis_ekmi_cur
      LOOP
         v_asil_serrvis_promo_code := servis_ekmi_rec.promotion_code;
      END LOOP;

      FOR job_servis_rec IN job_servisler_cur
      LOOP
         INSERT INTO tm_servis (account_number,
                                outlet_location,
                                service_code,
                                islem,
                                tarih,
                                campaign_code,
                                durum,
                                servis_frekansi,
                                promotion_code)
              VALUES (in_account_number,
                      in_outlet_location,
                      job_servis_rec.service_code,
                      'ADD',
                      in_li_effective_date,
                      in_kampanya_kodu,
                      'J',
                      '1',
                      job_servis_rec.promotion_code);
      END LOOP;

      --TM_EK DE KAYIT YOKSA SERVIS KAMPANYA UYUMLU DEGILDIR...
      v_servis_varmi := FALSE;

      FOR servis_ekmi_rec IN servis_ekmi_cur
      LOOP
         --bu kodda mükerrlik olabilir.
         FOR servis_rec IN servis_cur (in_servis_kodu)
         LOOP
            IF servis_rec.islem = 'ADD'
            THEN
               -- ??? SERVIS EKLEME TARIHINDE SON ISLEM TARIHINE BAKIP LI_EFFECTIVE_DATE KONTROLÜ

               servis_dsr_ekle (
                  in_account_number            => in_account_number,
                  in_outlet_location           => in_outlet_location,
                  in_service_code              => in_servis_kodu,
                  in_campaign_code             => servis_rec.campaign_code,
                  in_servis_frekansi           => servis_rec.servis_frekansi,
                  in_islem                     => 'DSR',
                  in_tarih                     =>   in_li_effective_date
                                                  - 1 / (24 * 60 * 60),
                  in_durum                     => 'D',
                  in_work_order_number         => servis_rec.work_order_number,
                  in_baglanti_id               => servis_rec.baglanti_id,
                  in_promotion_code            => servis_rec.promotion_code,
                  in_promosyon_bitis_tarihi    => servis_rec.promosyon_bitis_tarihi,
                  in_li_effective_date         => in_li_effective_date,
                  in_stb_tipi                  => in_stb_tipi,
                  in_uye_tipi                  => in_uye_tipi,
                  in_franchise_code            => in_franchise_code,
                  in_bundle_servisleri_cikar   => in_is_bundle,
                  out_durum                    => out_durum);
            /*INSERT INTO tm_servis
                   (account_number, outlet_location, service_code, islem,
                    tarih, campaign_code, durum,
                    servis_frekansi, promotion_code, work_order_number,
                    baglanti_id, promosyon_bitis_tarihi
                   )
            VALUES (in_account_number, in_outlet_location, in_servis_kodu, 'DSR',
                    in_li_effective_date - 1 / (24 * 60 * 60), servis_rec.campaign_code, 'D',
                    servis_rec.servis_frekansi, servis_rec.promotion_code, servis_rec.work_order_number,
                    servis_rec.baglanti_id, servis_rec.promosyon_bitis_tarihi
                   );*/
            END IF;

            EXIT;
         END LOOP;

         INSERT INTO tm_servis (account_number,
                                outlet_location,
                                service_code,
                                islem,
                                tarih,
                                campaign_code,
                                durum,
                                servis_frekansi,
                                promotion_code,
                                service_rate)
              VALUES (in_account_number,
                      in_outlet_location,
                      in_servis_kodu,
                      'ADD',
                      in_li_effective_date,
                      in_kampanya_kodu,
                      'A',
                      in_servis_frekansi,
                      v_asil_serrvis_promo_code,
                      in_ozel_fiyat);

         v_servis_varmi := TRUE;

         IF in_sabit_promo_date IS NULL
         THEN
            IF TRIM (v_asil_serrvis_promo_code) IS NOT NULL
            THEN
               work_order_pack.promosyon_bitis_tarihi_bul (
                  v_billing_cycle,
                  in_servis_frekansi,
                  v_asil_serrvis_promo_code,
                  servis_ekmi_rec.service_code,
                  in_li_effective_date,
                  v_promotion_end_date,
                  out_durum,
                  in_kullanici);

               IF out_durum <> '0'
               THEN
                  out_error_type := 1;
                  out_error_code := 'ERR102';
                  out_durum :=
                     'Promosyon bitis tarihi  bulunamadi! ' || out_durum;
                  RETURN;
               END IF;

               /*---- 20100708  --- DBSDEN PRORATE HESABINDAKI HATAYI GIDERMEK IÇIN DEGISTIRILDI.  ----*/
               --IF v_kampanya_ok_mi = 1
               --THEN
               UPDATE tm_servis
                  SET promosyon_bitis_tarihi = v_promotion_end_date
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND service_code = in_servis_kodu
                      AND durum = 'A';
            --END IF;
            END IF;
         ELSE
            v_promotion_end_date := in_sabit_promo_date;
         END IF;

         v_dsr_z_end_date := NULL;

         IF servis_ekmi_rec.dusurulecek_mi = 'E'
         THEN
            out_dusurulecek_mi := TRUE;
            v_promotion_end_date :=
               TO_DATE (
                  TO_CHAR (v_promotion_end_date, 'DD.MM.YYYY') || ' 12:00:00',
                  'DD.MM.YYYY HH24:MI:SS');
            v_asil_servis_dusuyor_mu := TRUE;

            INSERT INTO tm_servis (account_number,
                                   outlet_location,
                                   service_code,
                                   islem,
                                   tarih,
                                   campaign_code,
                                   durum,
                                   servis_frekansi,
                                   promotion_code,
                                   promosyon_bitis_tarihi)
                 VALUES (in_account_number,
                         in_outlet_location,
                         in_servis_kodu,
                         'DSR',
                         v_promotion_end_date,
                         in_kampanya_kodu,
                         'Z',
                         in_servis_frekansi,
                         v_asil_serrvis_promo_code,
                         v_promotion_end_date);

            v_dsr_z_end_date := v_promotion_end_date;
            v_dsr_z_d_mi := 'Z';

            -- PROMOSYONDAN DOLAYI ZORUNLU DUSME SATIRI DSH ILE DUSECEK
            v_dsr_tarihi := v_promotion_end_date;
         END IF;

         EXIT;
      END LOOP;

      IF NOT v_servis_varmi
      THEN
         out_durum :=
               'Seçtisiniz kampanya,frekans ve servis uyumlu degil!'
            || ' ('
            || in_kampanya_kodu
            || ','
            || in_servis_frekansi
            || ','
            || in_servis_kodu
            || ')';
         out_error_type := 1;
         out_error_code := 'ERR103';
         RETURN;
      END IF;

      kontrat_kampanya_kontrol (in_account_number,
                                in_outlet_location,
                                in_li_effective_date,
                                out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      yasak_servis_dusur (in_account_number,
                          in_outlet_location,
                          in_servis_kodu,
                          in_kampanya_kodu,
                          in_li_effective_date,
                          in_uye_tipi,
                          in_stb_tipi,
                          in_franchise_code,
                          out_durum);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR77';
         RETURN;
      END IF;

      servis_sf_urun_bayi_kontrol (in_account_number,
                                   in_outlet_location,
                                   in_servis_kodu,
                                   in_kampanya_kodu,
                                   in_servis_frekansi,
                                   in_li_effective_date,
                                   in_sebep_kodu,
                                   in_bayi_kodu,
                                   in_bayiden_satis,
                                   in_ozel_fiyat,
                                   in_stb_tipi,
                                   in_uye_tipi,
                                   in_franchise_code,
                                   in_islem_kaynak,
                                   in_kontrol_tipi,
                                   in_kullanici,
                                   out_durum);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR77';
         RETURN;
      END IF;

      --Mustafa 19.12.2006 asagidaki kontrol yenisi ile degistirildi.
      --      v_dusen_servis_var := FALSE;
      --      FOR asil_dsr_rec IN asil_dsr_cur
      --      LOOP
      --         v_dusen_servis_var := TRUE;
      --         IF    asil_dsr_rec.promosyon_bitis_tarihi < SYSDATE
      --            OR asil_dsr_rec.promosyon_bitis_tarihi IS NULL
      --            OR asil_dsr_rec.promosyon_bitis_tarihi = TO_DATE ('0001.01.01', 'YYYY.MM.DD')
      --         THEN
      --            v_dusen_servis_var := FALSE;
      --         END IF;
      --      END LOOP;
      v_matrix_kont_gir := TRUE;

      FOR i IN 1 .. 2
      LOOP
         IF i = 1
         THEN
            v_zorunlu_servis := 'E';
         ELSE
            v_zorunlu_servis := 'H';
         END IF;

         FOR asil_dsr_rec IN asil_dsr_cur (v_zorunlu_servis)
         LOOP
            IF v_zorunlu_servis = 'E'
            THEN
               v_zorunlu_servis_varmi := TRUE;
            END IF;

            IF    asil_dsr_rec.promosyon_bitis_tarihi < SYSDATE
               OR asil_dsr_rec.promosyon_bitis_tarihi IS NULL
               OR asil_dsr_rec.promosyon_bitis_tarihi =
                     TO_DATE ('0001.01.01', 'YYYY.MM.DD')
            THEN
               IF asil_dsr_rec.campaign_code <> in_kampanya_kodu
               THEN
                  --v_matrix_kont_gir := TRUE;
                  NULL;
               ELSE
                  IF in_islem_kaynak = 'DONDURMA_SERVIS'
                  THEN
                     SELECT COUNT (*)
                       INTO v_count
                       FROM ie_uyelik_dondurma a, ie_uyelik_dondurma_servis b
                      WHERE     a.account_number = in_account_number
                            AND a.outlet_location = in_outlet_location
                            AND a.id = b.uyelik_dondurma_id
                            AND b.id = asil_dsr_rec.baglanti_id
                            AND b.eklenecek_mi = 'E'
                            AND b.durum = 1;

                     IF v_count > 0
                     THEN
                        --v_matrix_kont_gir := TRUE;
                        NULL;
                     ELSE
                        v_matrix_kont_gir := FALSE;
                     END IF;
                  ELSIF in_islem_kaynak = 'KAPAMA_SERVIS'
                  THEN
                     SELECT COUNT (*)
                       INTO v_count
                       FROM ie_uyelik_kapama a, ie_uyelik_kapama_servis b
                      WHERE     a.account_number = in_account_number
                            AND a.outlet_location = in_outlet_location
                            AND a.id = b.uyelik_kapama_id
                            AND b.id = asil_dsr_rec.baglanti_id
                            AND b.eklenecek_mi = 'E'
                            AND b.durum = 1;

                     IF v_count > 0
                     THEN
                        --v_matrix_kont_gir := TRUE;
                        NULL;
                     ELSE
                        v_matrix_kont_gir := FALSE;
                     END IF;
                  ELSE
                     SELECT COUNT (*)
                       INTO v_count
                       FROM wiz_customer_hp_svc
                      WHERE     account_number = in_account_number
                            AND outlet_location = in_outlet_location
                            AND id = asil_dsr_rec.baglanti_id;

                     IF v_count > 0
                     THEN
                        --v_matrix_kont_gir := TRUE;
                        NULL;
                     ELSE
                        v_matrix_kont_gir := FALSE;
                     END IF;
                  END IF;
               END IF;
            ELSE
               IF asil_dsr_rec.campaign_code <> in_kampanya_kodu
               THEN
                  --v_matrix_kont_gir := TRUE;
                  NULL;
               ELSE
                  v_matrix_kont_gir := FALSE;
               END IF;
            END IF;
         END LOOP;

         IF v_zorunlu_servis_varmi = TRUE
         THEN
            EXIT;
         END IF;
      END LOOP;

      --Matrix kampanya baslangiç servisi uygun MUS
      --IF NOT v_dusen_servis_var AND in_kontrol_tipi <> 2 THEN
      IF v_matrix_kont_gir AND in_kontrol_tipi <> 2
      THEN
         SELECT group_code, TRIM (main_service)
           INTO v_kampanya_grup_kodu, v_main_service
           FROM wiz_campaign_codes
          WHERE campaign_code = in_kampanya_kodu;

         IF v_kampanya_grup_kodu IS NOT NULL
         THEN
            v_tmp := NULL;

            BEGIN
               /*--- Evren --- 20100920 --- begin ---*/
               SELECT campaign_code
                 INTO v_tmp
                 FROM wiz_campaign_codes
                WHERE     group_code = v_kampanya_grup_kodu
                      AND EXISTS
                             (SELECT 1
                                FROM TABLE (
                                        split_table_fnc (TRIM (main_service)))
                               WHERE COLUMN_VALUE = in_servis_kodu);
            /*SELECT campaign_code
             INTO v_tmp
             FROM wiz_campaign_codes
            WHERE group_code = v_kampanya_grup_kodu
              AND TRIM (main_service) = in_servis_kodu;*/
            /*--- Evren --- 20100920 --- end ---*/
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_tmp := NULL;
            END;

            IF v_tmp IS NOT NULL
            THEN
               --Düsen servisin kampanyasi eklenen içinde geçerli mis
               SELECT COUNT (1)
                 INTO v_count
                 FROM icr_dp_servis_default s, icr_dp_servis_default_detay d
                WHERE     d.servis_default_kodu = s.kod
                      AND listeden_gizle = 'H'
                      AND s.franchise_code = in_franchise_code
                      AND (   s.billing_frequency = in_servis_frekansi
                           OR s.billing_frequency IS NULL)
                      AND d.customer_type = in_uye_tipi
                      AND s.code = in_servis_kodu
                      AND s.campaign_code = v_tmp
                      AND (s.stb_tipi IS NULL OR s.stb_tipi = in_stb_tipi)
                      AND (   s.effective_date IS NULL
                           OR s.effective_date <= in_li_effective_date)
                      AND (s.expire_date IS NULL OR s.expire_date > SYSDATE);

               IF v_count > 0
               THEN
                  IF v_tmp <> in_kampanya_kodu
                  THEN
                     IF yetki_pack.yetkisi_varmi (
                           in_kullanici,
                           'ISLEM_SERVIS_KAMPANYA_UPGRADE') = 0
                     THEN
                        out_durum :=
                              in_servis_kodu
                           || ' servisini '
                           || v_tmp
                           || ' kampanyasi ile eklemelisiniz!!';
                        out_error_type := 1;
                        out_error_code := 'ERR97';
                        RETURN;
                     END IF;
                  END IF;
               ELSE
                  /*--- Evren --- 20100920 --- begin ---*/
                  SELECT COUNT (*)                              --column_value
                    INTO v_count
                    FROM TABLE (split_table_fnc (v_main_service))
                   WHERE COLUMN_VALUE = in_servis_kodu;

                  -- IF v_main_service <> in_servis_kodu THEN
                  /*--- Evren --- 20100920 --- end ---*/
                  IF v_count = 0
                  THEN
                     IF yetki_pack.yetkisi_varmi (
                           in_kullanici,
                           'ISLEM_SERVIS_KAMPANYA_UPGRADE') = 0
                     THEN
                        out_durum :=
                              in_kampanya_kodu
                           || ' kampanyasi '
                           || v_main_service
                           || ' servisi ile ekleyebilirsiniz!!';
                        out_error_type := 1;
                        out_error_code := 'ERR97';
                        RETURN;
                     END IF;
                  END IF;
               END IF;
            ELSE
               IF yetki_pack.yetkisi_varmi (in_kullanici,
                                            'ISLEM_SERVIS_KAMPANYA_UPGRADE') =
                     0
               THEN
                  out_durum :=
                        in_servis_kodu
                     || ' servisini '
                     || in_kampanya_kodu
                     || ' kampanyasi ile upgrade isleminde kullanabilirsiniz!!';
                  out_error_type := 1;
                  out_error_code := 'ERR97';
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF;

      /***************<OGM DESC="ARTI PUAN KAMPANYASI AKISI">**********************/
      /***************<STEP NO=1 DESC="EGER EKLENEN kmp1 ARTI PUANLI ISE">*********/
      /********************<STEP NO=2 DESC="EGER nvl(DUSEN,'-') <> kmp1 ISE">******/
      /*************************<ACTION DESC="UYEDEN ARTI PUAN DUS"/>**************/
      /********************</STEP>*************************************************/
      /***************</STEP>******************************************************/
      DECLARE
         v_c                NUMBER (10);
         v_uye_puan_dusur   BOOLEAN;
         v_puan             NUMBER (15);
         v_hareket_id       NUMBER (10);
         v_billing_cycle    NUMBER (5);
         v_donem            ps_batch.donem%TYPE;
         v_from_date        ps_batch.donem_baslangic_tarihi%TYPE;
         v_to_date          ps_batch.donem_bitis_tarihi%TYPE;
         ----
         p_islem_tipi       ps_islem_tipi.islem_tipi%TYPE
                               := 'ARTI_PUAN_SERVIS_EKLEME';
         p_date             ps_islem_puan.effective_date%TYPE := SYSDATE;
         p_islem_tipi_id    ps_islem_tipi.id%TYPE;
         p_islem_puan_id    ps_islem_puan.id%TYPE;
         p_baslangic_adet   ps_islem_puan.baslangic_adet%TYPE;
         p_bitis_adet       ps_islem_puan.bitis_adet%TYPE;
         p_puan             ps_islem_puan.puan%TYPE;
         p_oran             ps_islem_puan.oran%TYPE;
         p_return_status    VARCHAR2 (500);
         p_sure             ps_islem_puan.bas_sure%TYPE := NULL;
      BEGIN
         v_uye_puan_dusur := FALSE;

         SELECT COUNT (*)
           INTO v_c
           FROM dbs_dba.pr_urun_ozellik_tanim
          WHERE     urun_kodu = in_kampanya_kodu
                AND ozellik_kodu = 71
                AND listeden_gizle = 'H';

         IF v_c > 0                                             --<STEP NO=1/>
         THEN
            v_uye_puan_dusur := TRUE;

            FOR rec_dsr_puan
               IN (SELECT service_code, campaign_code
                     FROM tm_servis
                    WHERE     account_number = in_account_number
                          AND outlet_location = in_outlet_location
                          AND campaign_code = in_kampanya_kodu
                          AND durum IN ('A',
                                        'E',
                                        'D',
                                        'B')
                          AND islem = 'DSR')
            LOOP
               --ayni +puanli kampanyada dolasmasina izin veriyoruz.
               v_uye_puan_dusur := FALSE;
            END LOOP;
         END IF;

         IF v_uye_puan_dusur
         THEN
            BEGIN
               SELECT puan
                 INTO v_puan
                 FROM dbs_dba.ps_uye_puan
                WHERE account_number = in_account_number;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_puan := 0;
            END;

            IF v_puan < 0
            THEN
               out_durum :=
                  'seçili +Puan kampanyasini ekleyebilmek için üyenin mevcut puani olmalidir.';
               out_error_type := 1;
               out_error_code := 'ERR960';
               RETURN;
            END IF;

            v_puan := NULL;

            BEGIN
               SELECT TO_NUMBER (dusulecek_arti_puan)
                 INTO v_puan
                 FROM vv_uye_arti_puan_bilgi_listesi
                WHERE     uye_no = in_account_number
                      AND kampanya = in_kampanya_kodu
                      AND servis_frekansi = in_servis_frekansi
                      AND paket = in_servis_kodu
                      AND kullanici = in_kullanici;
            EXCEPTION
               WHEN OTHERS
               THEN
                  out_durum := 'Dusulecek puan hesabinda hata..';
                  out_error_type := 1;
                  out_error_code := 'ERR962';
                  RETURN;
            END;

            IF v_puan IS NOT NULL
            THEN
               --yetkili ise puan dusulecek
               IF yetki_pack.yetkisi_varmi (
                     in_kullanici,
                     'ISLEM_PUAN_BORCLANARAK_SERVIS_ALMA') = 0
               THEN
                  out_durum := 'Arti puan servis ekleme yetkiniz yoktur.';
                  out_error_type := 1;
                  out_error_code := 'ERR966';
                  RETURN;
               END IF;

               ps_pack.ps_islem_puan_bul (p_islem_tipi,
                                          p_date,
                                          p_islem_tipi_id,
                                          p_islem_puan_id,
                                          p_baslangic_adet,
                                          p_bitis_adet,
                                          p_puan,
                                          p_oran,
                                          out_durum,
                                          p_sure);

               IF out_durum <> '0'
               THEN
                  out_durum := 'puan islem hata:' || out_durum;
                  out_error_type := 1;
                  out_error_code := 'ERR963';
                  RETURN;
               END IF;

               BEGIN
                  SELECT billing_cycle
                    INTO v_billing_cycle
                    FROM wiz_customer_hp_life
                   WHERE account_number = in_account_number;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     out_durum :=
                           'RAMA_HP_LIFE : Abone bulunamadi.'
                        || SUBSTR (SQLERRM, 1, 100);
                     out_error_type := 1;
                     out_error_code := 'ERR961';
                     RETURN;
               END;

               ps_pack.ps_donem (p_date,
                                 v_billing_cycle,
                                 v_donem,
                                 v_from_date,
                                 v_to_date,
                                 out_durum);

               IF out_durum <> '0'
               THEN
                  out_durum := 'RAMA_PS_DONEM:' || out_durum;
                  out_error_type := 1;
                  out_error_code := 'ERR961';
                  RETURN;
               END IF;

               ps_pack.ps_uye_hareket_insert (
                  in_account_number,
                  NULL,
                  p_islem_puan_id,
                  -1 * v_puan,
                  p_date,
                  v_donem,
                  p_islem_tipi_id,
                  in_kullanici,
                  SYSDATE,
                  v_hareket_id,
                  out_durum,
                     'Arti puan Servis ekleme ['
                  || in_servis_kodu
                  || '-'
                  || in_kampanya_kodu
                  || '-'
                  || in_servis_frekansi
                  || ']',
                  NULL,
                  'H');

               IF out_durum <> '0'
               THEN
                  out_durum := 'puan hareket hata:' || out_durum;
                  out_error_type := 1;
                  out_error_code := 'ERR963';
                  RETURN;
               END IF;

               v_aciklama_puan :=
                     'Bu islem sonucunda, üyeden '
                  || v_puan
                  || ' puan düsülecektir.';
            ELSE
               out_durum := 'Dusulecek puan hesabinda hata';
               out_error_type := 1;
               out_error_code := 'ERR962';
               RETURN;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            out_durum := 'Puan düsme isleminde hata:' || SQLERRM;
            out_error_type := 1;
            out_error_code := 'ERR964';
            RETURN;
      END;

      /*********************************</OGM>**************************************/
      --SERVIS DÜSECEK MI KONTROLÜ : Gerek servis(ler)i düsüyor MUS
      FOR dsr_kontrol_rec IN dsr_kontrol_cur
      LOOP
         IF dsr_kontrol_rec.islem = 'DSR'
         THEN
            -- YG_SERVISBUL CALISMALI
            DELETE FROM tm_ek
                  WHERE     account_number = in_account_number
                        AND outlet_location = in_outlet_location;

            yg_servis_bul (in_account_number,
                           in_servis_kodu,
                           in_uye_tipi,
                           in_outlet_location,
                           in_franchise_code);
            gerek_servis_kontrol (in_account_number,
                                  in_outlet_location,
                                  in_servis_kodu,
                                  in_servis_kodu,
                                  dsr_kontrol_rec.tarih,
                                  v_durum);

            IF v_durum <> '0'
            THEN
               IF v_asil_servis_dusuyor_mu
               THEN
                  IF dsr_kontrol_rec.tarih < v_promotion_end_date
                  THEN
                     UPDATE tm_servis
                        SET tarih = dsr_kontrol_rec.tarih
                      WHERE     account_number = in_account_number
                            AND outlet_location = in_outlet_location
                            AND service_code = in_servis_kodu
                            AND tarih = v_promotion_end_date
                            AND durum = 'Z';

                     v_dsr_tarihi := dsr_kontrol_rec.tarih;
                     v_dsr_z_end_date := dsr_kontrol_rec.tarih;
                     v_dsr_z_d_mi := 'Z';
                  END IF;
               ELSE
                  INSERT INTO tm_servis (account_number,
                                         outlet_location,
                                         service_code,
                                         islem,
                                         tarih,
                                         campaign_code,
                                         durum,
                                         servis_frekansi,
                                         promotion_code)
                       VALUES (in_account_number,
                               in_outlet_location,
                               in_servis_kodu,
                               'DSR',
                               dsr_kontrol_rec.tarih,
                               in_kampanya_kodu,
                               'D',
                               in_servis_frekansi,
                               v_asil_serrvis_promo_code);

                  v_dsr_tarihi := dsr_kontrol_rec.tarih;
                  v_dsr_z_end_date := dsr_kontrol_rec.tarih;
                  v_dsr_z_d_mi := 'D';
               END IF;

               EXIT;
            END IF;
         END IF;
      END LOOP;

      --YUMURTLANAN SERVISLER IÇIN ISLEMLER
      --TM_EK SILINDIGI IÇIN TEKRAR DOLDURULUYOR EK SERVISLER IÇIN
      DELETE FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;

      servis_process (in_account_number,
                      in_uye_tipi,
                      in_outlet_location,
                      in_servis_kodu,
                      in_kampanya_kodu,
                      in_franchise_code,
                      in_servis_frekansi,
                      in_li_effective_date,
                      in_kullanici,
                      'A');

      FOR yum_servisler_rec IN yum_servisler_cur
      LOOP
         FOR tm_servis_rec
            IN (  SELECT *
                    FROM tm_servis tm
                   WHERE     tm.account_number = in_account_number
                         AND tm.outlet_location = in_outlet_location
                         AND tm.tarih <= in_li_effective_date
                         AND (   tm.service_code =
                                    yum_servisler_rec.service_code
                              OR tm.service_code IN (SELECT c.service_code
                                                       FROM pr_servis_takip a,
                                                            pr_servis_takip_detay b,
                                                            pr_yasak_zorunlu_servis_takip c,
                                                            wiz_customer_hp_life l
                                                      WHERE     a.kod =
                                                                   b.servis_takip_kodu
                                                            AND a.kod =
                                                                   c.servis_takip_kodu
                                                            AND l.account_number =
                                                                   in_account_number
                                                            AND a.service_code =
                                                                   yum_servisler_rec.service_code
                                                            AND a.franchise_code =
                                                                   l.franchise_code --in_franchise_code
                                                            AND a.listeden_gizle =
                                                                   'H'
                                                            AND (   a.bitis_tarihi
                                                                       IS NULL
                                                                 OR a.bitis_tarihi >
                                                                       SYSDATE)
                                                            AND (   a.stb_tipi
                                                                       IS NULL
                                                                 OR a.stb_tipi =
                                                                       l.hp_cluster) --v_stb_tipi)
                                                            AND b.customer_type =
                                                                   l.customer_type --in_uye_tipi
                                                            AND c.yasakmi IN ('E')))
                ORDER BY tarih DESC)
         LOOP
            IF tm_servis_rec.islem = 'ADD'
            THEN
               servis_dsr_ekle (
                  in_account_number            => in_account_number,
                  in_outlet_location           => in_outlet_location,
                  in_service_code              => tm_servis_rec.service_code,
                  in_campaign_code             => tm_servis_rec.campaign_code,
                  in_servis_frekansi           => tm_servis_rec.servis_frekansi,
                  in_islem                     => 'DSR',
                  in_tarih                     =>   in_li_effective_date
                                                  - 10 * (1 / (24 * 60 * 60)),
                  in_durum                     => 'D',
                  in_work_order_number         => NULL,
                  in_baglanti_id               => NULL,
                  in_promotion_code            => tm_servis_rec.promotion_code,
                  in_promosyon_bitis_tarihi    => tm_servis_rec.promosyon_bitis_tarihi,
                  in_li_effective_date         => in_li_effective_date,
                  in_stb_tipi                  => in_stb_tipi,
                  in_uye_tipi                  => in_uye_tipi,
                  in_franchise_code            => in_franchise_code,
                  in_bundle_servisleri_cikar   => 'E',
                  out_durum                    => out_durum);
            END IF;

            EXIT;
         END LOOP;

         v_ek_servis_durum_tipi := 'E';
         servis_eklenebilir_mi (in_account_number,
                                in_outlet_location,
                                yum_servisler_rec.service_code,
                                in_li_effective_date,
                                in_servis_frekansi, -- '1',  // Yumurtlayan servis multi frekans
                                out_error_type,
                                out_error_code,
                                out_durum);

         IF out_durum <> '0'
         THEN
            RETURN;
         -- -- Burada uyarı verme amaçlıydı. Şimdi hata devam ettirmiyor. Durumu S ye çekiyor ve close wo S statüsünü kapatmıyor zaten.
         --            v_ek_servis_durum_tipi := 'S';
         --            IF out_aciklama IS NULL
         --            THEN
         --               out_aciklama := out_durum;
         --            ELSE
         --               out_aciklama := '<E>' || out_durum;
         --            END IF;
         --
         --            out_durum := '0';
         END IF;

         INSERT INTO tm_servis (account_number,
                                outlet_location,
                                service_code,
                                islem,
                                tarih,
                                campaign_code,
                                durum,
                                servis_frekansi,
                                promotion_code)
              VALUES (in_account_number,
                      in_outlet_location,
                      yum_servisler_rec.service_code,
                      'ADD',
                      in_li_effective_date,
                      -- in_li_effective_date - 10 * (1 / (24 * 60 * 60)),
                      in_kampanya_kodu,
                      v_ek_servis_durum_tipi,
                      in_servis_frekansi, --'1',   // Yumurtlayan servis multi frekans
                      yum_servisler_rec.promotion_code);

         IF v_ek_servis_durum_tipi = 'E'
         THEN
            IF TRIM (yum_servisler_rec.promotion_code) IS NOT NULL
            THEN
               work_order_pack.promosyon_bitis_tarihi_bul (
                  v_billing_cycle,
                  in_servis_frekansi, --'1',  // Yumurtlayan servis multi frekans
                  yum_servisler_rec.promotion_code,
                  yum_servisler_rec.service_code,
                  in_li_effective_date,
                  v_promotion_end_date,
                  out_durum,
                  in_kullanici);

               IF out_durum <> '0'
               THEN
                  out_durum :=
                     'Promosyon bitis tarihi  bulunamadi! ' || out_durum;
                  out_error_type := 1;
                  out_error_code := 'ERR102';
                  RETURN;
               END IF;

               IF     TRUNC (v_promotion_end_date) <= TRUNC (SYSDATE)
                  AND in_kontrol_tipi <> 2
               THEN
                  out_durum :=
                     'Bu promosyon bitmistir. Bu kampanya ile ekleyemezsiniz!';
                  out_error_type := 1;
                  out_error_code := 'ERR102';
                  RETURN;
               END IF;
            END IF;

            IF yum_servisler_rec.dusurulecek_mi = 'E'
            THEN
               v_promotion_end_date :=
                  TO_DATE (
                        TO_CHAR (v_promotion_end_date, 'DD.MM.YYYY')
                     || ' 12:00:00',
                     'DD.MM.YYYY HH24:MI:SS');

               IF v_dsr_tarihi IS NULL
               THEN
                  v_dsr_tarihi := v_promotion_end_date;
               ELSIF v_dsr_tarihi > v_promotion_end_date
               THEN
                  v_dsr_tarihi := v_promotion_end_date;
               END IF;

               INSERT INTO tm_servis (account_number,
                                      outlet_location,
                                      service_code,
                                      islem,
                                      tarih,
                                      campaign_code,
                                      durum,
                                      servis_frekansi,
                                      promotion_code,
                                      promosyon_bitis_tarihi)
                    VALUES (in_account_number,
                            in_outlet_location,
                            yum_servisler_rec.service_code,
                            'DSR',
                            v_dsr_tarihi,
                            in_kampanya_kodu,
                            'Z',
                            in_servis_frekansi, -- '1',  // Yumurtlayan servis multi frekans
                            yum_servisler_rec.promotion_code,
                            v_promotion_end_date);
            -- PROMOSYONDAN DOLAYI ZORUNLU DUSME SATIRI DSH ILE DUSECEK
            ELSE                  --YUM_SERVISLER_REC.DUSURULECEK_MI<>'E' THEN
               FOR dsr_kontrol_rec IN dsr_kontrol_cur
               LOOP
                  IF dsr_kontrol_rec.islem = 'DSR'
                  THEN
                     -- yg_SERVIS
                     DELETE FROM tm_ek
                           WHERE     account_number = in_account_number
                                 AND outlet_location = in_outlet_location;

                     yg_servis_bul (in_account_number,
                                    yum_servisler_rec.service_code, --in_servis_kodu,
                                    in_uye_tipi,
                                    in_outlet_location,
                                    in_franchise_code);
                     gerek_servis_kontrol (in_account_number,
                                           in_outlet_location,
                                           yum_servisler_rec.service_code, -- in_servis_kodu,
                                           yum_servisler_rec.service_code,
                                           dsr_kontrol_rec.tarih,
                                           v_durum);

                     IF v_durum <> '0'
                     THEN
                        INSERT INTO tm_servis (account_number,
                                               outlet_location,
                                               service_code,
                                               islem,
                                               tarih,
                                               campaign_code,
                                               durum,
                                               servis_frekansi)
                             VALUES (in_account_number,
                                     in_outlet_location,
                                     yum_servisler_rec.service_code,
                                     'DSR',
                                     dsr_kontrol_rec.tarih,
                                     in_kampanya_kodu,
                                     'D',
                                     in_servis_frekansi -- '1'   // Yumurtlayan servis multi frekans
                                                       );

                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         -- -- Servis_durum_kontrol kontrolü buradan kaldırıldı.
         --            servis_durum_kontrol (in_account_number,
         --                                  in_outlet_location,
         --                                  yum_servisler_rec.service_code,
         --                                  'ADD',
         --                                  in_li_effective_date,
         --                                  in_uye_tipi,
         --                                  in_franchise_code,
         --                                  in_kaynak,
         --                                  in_kullanici,
         --                                  in_kontrol_tipi,
         --                                  out_error_type,
         --                                  out_error_code,
         --                                  out_aciklama,
         --                                  out_durum);
         --
         --            IF out_durum <> '0'
         --            THEN
         --
         --                --out_durum := 'ut_durum;
         --                out_durum := '0';
         --                --RETURN;
         ----               v_ek_servis_durum_tipi := 'S';
         ----
         ----               UPDATE tm_servis
         ----                  SET durum = v_ek_servis_durum_tipi
         ----                WHERE     account_number = in_account_number
         ----                      AND outlet_location = in_outlet_location
         ----                      AND service_code = yum_servisler_rec.service_code
         ----                      AND tarih = in_li_effective_date
         ----                      AND durum = 'E';
         ----
         ----               DELETE FROM tm_servis
         ----                     WHERE     account_number = in_account_number
         ----                           AND outlet_location = in_outlet_location
         ----                           AND service_code = yum_servisler_rec.service_code
         ----                           AND tarih = v_dsr_tarihi
         ----                           AND durum IN ('D', 'Z');
         ----
         ----               IF out_aciklama IS NULL
         ----               THEN
         ----                  out_aciklama :=
         ----                     'D I K K A T ! Asagidaki ek servisler eklenmeyecektir : <E><E>'
         ----                     || out_durum;
         ----               ELSE
         ----                  out_aciklama := '<E>' || out_durum;              --<E> Enter
         ----               END IF;
         ----
         ----               out_durum := '0';
         --            END IF;
         END IF;
      END LOOP;

      -- Gruplu islemlerde ayni gün ekleme ve düsürmeye izin yok
      IF in_servis_frekansi <> '1'
      THEN
         FOR grup_dsr_rec IN grup_dsr_cur
         LOOP
            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND islem = 'ADD'
                   AND service_code = grup_dsr_rec.service_code
                   AND servis_frekansi = grup_dsr_rec.servis_frekansi
                   AND work_order_number <> 0
                   AND TRUNC (tarih) = TRUNC (grup_dsr_rec.tarih);

            IF v_count > 0
            THEN
               out_durum :=
                     'Bu islemden önce '
                  || grup_dsr_rec.service_code
                  || ' ekleme satirini iptal etmelisiniz!';
               out_error_type := 1;
               out_error_code := 'ERR97';
               RETURN;
            END IF;
         END LOOP;
      END IF;

      bundle_kontrol (in_account_number,
                      in_outlet_location,
                      in_servis_kodu,
                      in_kampanya_kodu,
                      in_servis_frekansi,
                      in_li_effective_date,
                      in_ozel_fiyat,
                      in_uye_tipi,
                      in_franchise_code,
                      in_stb_tipi,
                      in_kaynak,
                      in_kullanici,
                      v_dsr_z_end_date,
                      v_dsr_z_d_mi,
                      out_error_type,
                      out_error_code,
                      out_aciklama,
                      out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      servis_durum_kontrol (in_account_number,
                            in_outlet_location,
                            in_servis_kodu,
                            'ADD',
                            in_li_effective_date,
                            in_uye_tipi,
                            in_franchise_code,
                            in_kaynak,
                            in_kullanici,
                            in_kontrol_tipi,
                            out_error_type,
                            out_error_code,
                            out_aciklama,
                            out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM vv_servis_icerik
       WHERE icerik_kodu = 'DRG' AND paket_kodu = in_servis_kodu;

      IF v_count > 0
      THEN
         dergi_kontrol (in_account_number,
                        in_outlet_location,
                        'ADD',
                        in_li_effective_date,
                        in_kullanici,
                        out_durum,
                        in_kontrol_tipi);

         IF out_durum <> '0'
         THEN
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      IF in_kontrol_tipi = 4 AND in_kampanya_kodu = 'OT1'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = in_servis_kodu
                AND durum IS NOT NULL
                AND islem = 'DSR'
                AND campaign_code <> 'OT1'
                AND TRUNC (promosyon_bitis_tarihi) > TRUNC (SYSDATE);

         IF v_count > 0
         THEN
            out_durum :=
               'Outlet kampanyasi ile promosyonu olan servis otomatik düsürülemez!';
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      IF v_aciklama_puan IS NOT NULL
      THEN
         IF out_aciklama IS NULL
         THEN
            out_aciklama := v_aciklama_puan;
         ELSE
            out_aciklama := '<E>' || v_aciklama_puan;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'servis_ekle_calis :' || SQLERRM;
         out_error_type := 1;
         out_error_code := 'ERR97';
   END servis_ekle_calis;

   PROCEDURE servis_outlet_kmp (in_account_number        IN     NUMBER,
                                in_outlet_location       IN     CHAR,
                                in_servis_kodu           IN     CHAR,
                                in_kampanya_kodu         IN     CHAR,
                                in_kmp_outlet_location   IN     CHAR,
                                in_servis_frekansi       IN     CHAR,
                                in_li_effective_date     IN     DATE,
                                in_sebep_kodu            IN     CHAR,
                                in_bayi_kodu             IN     CHAR,
                                in_bayiden_satis         IN     CHAR,
                                in_ozel_fiyat            IN     NUMBER,
                                in_stb_tipi              IN     CHAR,
                                in_uye_tipi              IN     CHAR,
                                in_franchise_code        IN     CHAR,
                                in_adet                  IN     NUMBER,
                                in_bedelli               IN     CHAR,
                                in_sabit_promo_date      IN     DATE,
                                in_kaynak                IN     VARCHAR2,
                                in_islem_kaynak          IN     VARCHAR2,
                                in_kontrol_tipi          IN     NUMBER,
                                in_kullanici             IN     VARCHAR2,
                                out_error_type              OUT NUMBER,
                                out_error_code              OUT VARCHAR2,
                                out_aciklama                OUT VARCHAR2,
                                out_durum                   OUT VARCHAR2)
   IS
      CURSOR e_cur
      IS
         SELECT *
           FROM wiz_equip
          WHERE     account_number = in_account_number
                AND outlet_location NOT IN (in_kmp_outlet_location,
                                            in_outlet_location)
                AND converter_type = 'SC';

      CURSOR m_cur (
         p_outlet    VARCHAR2)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = p_outlet
                  AND campaign_code <> 'OT1'
                  AND service_code = in_servis_kodu
                  AND work_order_number = 0
         ORDER BY tarih DESC;

      v_durum                VARCHAR2 (1000);
      v_wo_number            wiz_work_order.work_order_number%TYPE;
      v_service_address_id   NUMBER;
      v_employee_code        VARCHAR2 (3);
      v_count                NUMBER;
      v_servis_kodu          CHAR (3);
      v_kmp_kodu             CHAR (3);
      v_frekans              CHAR (1);
      v_savepoint            VARCHAR2 (100);
      v_li_effective_date    DATE;
      v_dusecek_mi           BOOLEAN;
      v_uyari_mesaji         VARCHAR2 (512);
      v_taa_uyari            VARCHAR2 (512);
   BEGIN
      out_durum := '0';
      v_kmp_kodu := 'OT1';
      v_servis_kodu := in_servis_kodu;

      IF in_servis_kodu IN ('MEG', 'MGG')
      THEN
         v_servis_kodu := 'SUP';
      END IF;

      --Mustafa 18.11.2004 eskiden asagidaki parametre degeri 6 yerine 4 dü.
      IF servis_util_pack.urun_ozellik_var_mi (1, v_kmp_kodu, 6) > 0
      THEN
         --otomatik eklenmeyecek
         RETURN;
      END IF;

      IF servis_util_pack.urun_ozellik_var_mi (2, v_servis_kodu, 6) > 0
      THEN
         --otomatik eklenmeyecek
         RETURN;
      END IF;

      IF dbs_sabit ('OUTLET_KAMPANYASI_SABIT_FREKANS_MI') = 'E'
      THEN
         v_frekans := '1';
      ELSE
         v_frekans := in_servis_frekansi;
      END IF;

      SELECT service_address_id
        INTO v_service_address_id
        FROM wiz_customer_hp_life
       WHERE account_number = in_account_number;

      SELECT wiz_employee_code
        INTO v_employee_code
        FROM co_kullanici
       WHERE kod = in_kullanici;

      v_savepoint := NULL;

      FOR e_rec IN e_cur
      LOOP
         olan_servis_doldur (in_account_number, e_rec.outlet_location);

         FOR m_rec IN m_cur (e_rec.outlet_location)
         LOOP
            v_frekans := m_rec.servis_frekansi;
         END LOOP;

         v_count := 0;

         IF v_count = 0
         THEN
            v_li_effective_date := in_li_effective_date;

            IF     (   (    in_kaynak <> 'DBS'
                        AND dbs_sabit ('AYNI_PAKET_DBS_DISI_SCHEDULE_ET') =
                               'E')
                    OR (    in_kaynak = 'DBS'
                        AND dbs_sabit ('AYNI_PAKET_DBS_SCHEDULE_ET') = 'E'))
               AND yetki_pack.yetkisi_varmi (
                      in_kullanici,
                      'ISLEM_AYNI_PAKET_SCHEDULE_ETMEME_YETKI') = 0
            THEN
               get_li_eff_date (in_account_number,
                                e_rec.outlet_location,
                                v_servis_kodu,
                                v_kmp_kodu,
                                v_frekans,
                                in_li_effective_date,
                                in_uye_tipi,
                                in_franchise_code,
                                in_kullanici,
                                v_li_effective_date,
                                v_durum);

               --IF v_DURUM <> '0' THEN RETURN; END IF;
               IF v_li_effective_date IS NOT NULL
               THEN
                  IF v_li_effective_date <> in_li_effective_date
                  THEN
                     v_li_effective_date :=
                        TRUNC (v_li_effective_date) + (1 / 24) * 12;
                  END IF;
               END IF;
            END IF;

            IF v_li_effective_date IS NULL
            THEN
               v_li_effective_date := in_li_effective_date;
            END IF;

            v_savepoint := 'OUTLET_KMP' || e_rec.outlet_location;
            tran_pack.dbs_savepoint (v_savepoint);
            servis_ekle_calis (in_account_number,
                               e_rec.outlet_location,
                               v_servis_kodu,
                               v_kmp_kodu,
                               v_frekans,
                               v_li_effective_date,
                               in_sebep_kodu,
                               in_bayi_kodu,
                               in_bayiden_satis,
                               in_ozel_fiyat,
                               in_stb_tipi,
                               in_uye_tipi,
                               in_franchise_code,
                               in_adet,
                               in_bedelli,
                               in_sabit_promo_date,
                               in_kaynak,
                               in_islem_kaynak,
                               4,                            --in_kontrol_tipi
                               in_kullanici,
                               'H',
                               v_dusecek_mi,
                               out_error_type,
                               out_error_code,
                               out_aciklama,
                               v_durum);

            IF v_durum <> '0'
            THEN
               tran_pack.dbs_rollback (v_savepoint);
            ELSE
               wo_yarat (in_account_number,
                         e_rec.outlet_location,
                         NULL,
                         v_employee_code,
                         in_kullanici,
                         NULL,
                         'DZM',
                         1,
                         'OT1',
                         v_service_address_id,
                         1,
                         v_frekans,
                         NULL,
                         'E',
                         'EKLEME',
                         'NORMAL_SERVIS',
                         v_wo_number,
                         v_durum,
                         v_taa_uyari,
                         4);

               IF v_durum <> '0'
               THEN
                  tran_pack.dbs_rollback (v_savepoint);
               ELSE
                  work_order_pack.close_wo (v_wo_number,
                                            SYSDATE,
                                            e_rec.outlet_location,
                                            NULL,
                                            NULL,
                                            NULL,
                                            SYSDATE,
                                            in_kullanici,
                                            v_uyari_mesaji,
                                            v_durum);

                  IF v_durum <> '0'
                  THEN
                     tran_pack.dbs_rollback (v_savepoint);
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         BEGIN
            IF v_savepoint IS NOT NULL
            THEN
               tran_pack.dbs_rollback (v_savepoint);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
   END servis_outlet_kmp;

   FUNCTION kmp_outlet_mi (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_stb_tipi            IN     VARCHAR2,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_li_effective_date   IN     DATE,
      durum                     OUT VARCHAR2)
      RETURN VARCHAR2
   IS
      --  '000' Hayir
      --  else Outlet_numarasi
      CURSOR e_cur
      IS
         SELECT *
           FROM wiz_equip
          WHERE     account_number = in_account_number
                AND outlet_location <> in_outlet_location
                AND converter_type = 'SC';

      CURSOR m_cur (
         p_outlet    VARCHAR2)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = p_outlet
                  AND service_code = in_servis_kodu
                  AND campaign_code <> 'OT1'
                  AND tarih < in_li_effective_date
         ORDER BY tarih DESC;

      CURSOR o_cur (
         p_outlet    VARCHAR2)
      IS
           SELECT t.*
             FROM tm_servis t, pr_servis_takip p, pr_servis_takip_detay d
            WHERE     t.service_code = p.service_code
                  AND p.kod = d.servis_takip_kodu
                  AND t.account_number = in_account_number
                  AND t.outlet_location = p_outlet
                  AND t.campaign_code <> 'OT1'
                  AND t.tarih < in_li_effective_date
                  AND p.zorunlu = 'E'
                  AND p.franchise_code = in_franchise_code
                  AND p.listeden_gizle = 'H'
                  AND (p.bitis_tarihi IS NULL OR p.bitis_tarihi > SYSDATE)
                  AND (p.stb_tipi IS NULL OR p.stb_tipi = in_stb_tipi)
                  AND d.customer_type = in_uye_tipi
         ORDER BY t.tarih DESC;

      v_count                    NUMBER;
      v_in_servis_rate           NUMBER;
      v_outlet_servis_rate       NUMBER;
      v_outlet_zorunlu_servisi   CHAR (3);
   BEGIN
      durum := '0';

      SELECT COUNT (*)
        INTO v_count
        FROM pr_servis_takip a, pr_servis_takip_detay b
       WHERE     a.kod = b.servis_takip_kodu
             AND a.service_code = in_servis_kodu
             AND a.zorunlu = 'E'
             AND a.franchise_code = in_franchise_code
             AND a.listeden_gizle = 'H'
             AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
             AND (a.stb_tipi IS NULL OR a.stb_tipi = in_stb_tipi)
             AND b.customer_type = in_uye_tipi;

      IF v_count > 0
      THEN
         --Eklenen zorunlu servis ise fiyatini bul
         work_order_pack.rate_found (in_franchise_code,
                                     '   ',
                                     'NOR',
                                     '1',
                                     in_servis_kodu,
                                     in_li_effective_date,
                                     v_in_servis_rate,
                                     durum,
                                     in_stb_tipi);

         IF durum <> '0'
         THEN
            durum :=
                  'kmp_Outlet_mi :'
               || in_servis_kodu
               || ' servisi için fiyat bulunamadi!';
            RETURN NULL;
         END IF;
      END IF;

      FOR e_rec IN e_cur
      LOOP
         olan_servis_doldur (in_account_number, e_rec.outlet_location);

         IF v_in_servis_rate IS NULL
         THEN
            --Eklenen servis zorunlu degil ise
            --servis var ve sonrasinda islem yok ise
            SELECT COUNT (1)
              INTO v_count
              FROM tm_servis
             WHERE     account_number = in_account_number
                   AND outlet_location = e_rec.outlet_location
                   AND service_code = in_servis_kodu
                   AND tarih > in_li_effective_date;

            IF v_count = 0
            THEN
               FOR m_rec IN m_cur (e_rec.outlet_location)
               LOOP
                  IF m_rec.islem = 'ADD'
                  THEN
                     RETURN e_rec.outlet_location;
                  END IF;

                  EXIT;
               END LOOP;
            END IF;
         ELSE
            --Eklenen zorunlu servis ise
            --Servislerin normal fiyatlari karsilastiriliyor.
            v_outlet_zorunlu_servisi := NULL;

            FOR o_rec IN o_cur (e_rec.outlet_location)
            LOOP
               IF o_rec.islem = 'ADD'
               THEN
                  v_outlet_zorunlu_servisi := o_rec.service_code;
                  EXIT;
               END IF;
            END LOOP;

            IF v_outlet_zorunlu_servisi IS NOT NULL
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM tm_servis
                WHERE     account_number = in_account_number
                      AND outlet_location = e_rec.outlet_location
                      AND service_code = v_outlet_zorunlu_servisi
                      AND tarih > in_li_effective_date;

               IF v_count = 0
               THEN
                  work_order_pack.rate_found (in_franchise_code,
                                              '   ',
                                              'NOR',
                                              '1',
                                              v_outlet_zorunlu_servisi,
                                              in_li_effective_date,
                                              v_outlet_servis_rate,
                                              durum,
                                              in_stb_tipi);

                  IF durum <> '0'
                  THEN
                     durum :=
                           'kmp_Outlet_mi :'
                        || v_outlet_zorunlu_servisi
                        || ' servisi için fiyat bulunamadi!';
                     RETURN NULL;
                  END IF;

                  IF v_outlet_servis_rate >= v_in_servis_rate
                  THEN
                     RETURN e_rec.outlet_location;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      RETURN '000';
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'kmp_Outlet_mi :' || SQLERRM;
         RETURN NULL;
   END kmp_outlet_mi;

   PROCEDURE servis_ekle (in_account_number      IN     NUMBER,
                          in_outlet_location     IN     CHAR,
                          in_servis_kodu         IN     CHAR,
                          in_kampanya_kodu       IN     CHAR,
                          in_servis_frekansi     IN     CHAR,
                          in_li_effective_date   IN     DATE,
                          in_sebep_kodu          IN     CHAR,
                          in_bayi_kodu           IN     CHAR,
                          in_bayiden_satis       IN     CHAR,
                          in_ozel_fiyat          IN     NUMBER,
                          in_adet                IN     NUMBER,
                          in_bedelli             IN     CHAR,
                          in_sabit_promo_date    IN     DATE,
                          in_kaynak              IN     VARCHAR2,
                          in_islem_kaynak        IN     VARCHAR2,
                          in_kontrol_tipi        IN     NUMBER,
                          in_kullanici           IN     VARCHAR2,
                          out_error_type            OUT NUMBER,
                          out_error_code            OUT VARCHAR2,
                          out_aciklama              OUT VARCHAR2,
                          out_durum                 OUT VARCHAR2,
                          in_is_bundle           IN     VARCHAR2 DEFAULT 'H')
   IS
      /*
      in_bayiden_satis : Bayiden satis ise E degilse null
      in_bedelli  = Bedelli ise E veya null degilse H
      in_sabit_promo_date = Buraya null dan farkli bir deger verilirse eklenen servisin promosyonu o tarihte biter
      in_kaynak = 'DBS','555','IVR','WEB'....
      in_islem_kaynak = NORMAL_SERVIS, DONDURMA_SERVIS, KAPAMA_SERVIS
      in_kontrol_tipi = 0 Genel
                        1 sifreli Ürün Satis
                        2 +Puandan Ürün Talebi
                        3 Bekleyen Servis DRG Talebi
                        4 Outlet KMP
      TM SERVIS Durum
      A : Asil eklenecek servis
      B : Bayiden satistan dolayi düsen ve(ya) eklenen servis
      E : Yumurtlamadan dolayi eklenecek servis
      D : Düsürülecek servis
      Z : Düsen Promosyon taniminda dolayi bitis tarihinde zorunlu düsme ( Advertise_code ='DSH')
      J : Ekleme job
      S : Sorma amaçli islemler ( yumurtlanan servis ,
          daha sonra islemlerde kendisini baslayan gerek yok ise,
          yasak var ise veya ayni servis var ise uyari vermektedir.)
      Null : Uyenin üzerindeki mevcut Eski Servisler

      */
      v_stb_tipi                      VARCHAR2 (10);
      v_uye_tipi                      CHAR (3);
      v_franchise_code                CHAR (3);
      v_ulke                          VARCHAR2 (3);
      v_ulke_ad                       VARCHAR2 (50);
      v_il                            VARCHAR2 (3);
      v_il_ad                         VARCHAR2 (50);
      v_li_effective_date             DATE;
      v_temp_aciklama                 VARCHAR2 (300);
      v_error_type                    NUMBER;
      v_error_code                    VARCHAR2 (50);
      v_aciklama                      VARCHAR2 (1000);
      v_kampanya_kodu                 CHAR (3);
      v_kmp_outlet                    VARCHAR2 (3);
      v_count                         NUMBER;
      v_dusurulecek_servis            BOOLEAN;
      v_sc_ekipman_tip_matrix_id      NUMBER (10);           -- 20101019 Evren
      v_st_ekipman_tip_matrix_id      NUMBER (10);           -- 20101019 Evren
      v_md_ekipman_tip_matrix_id      NUMBER (10);           -- 20101019 Evren
      v_stb_seri_no                   yk_dp_kontrat.stb_seri_no%TYPE;
      -- 20101019 Evren
      v_sc_seri_no                    yk_dp_kontrat.sc_seri_no%TYPE;
      -- 20101019 Evren
      v_modul_seri_no                 yk_dp_kontrat.modul_seri_no%TYPE;
      v_sporlu_paket                  BOOLEAN := FALSE;
      v_serial_number                 wiz_equip.serial_number%TYPE;
      -- 20101019 Evren
      --20120611 Mesut
      v_abone_ozellik_aciklama        VARCHAR2 (1000);
      --20120611 Mesut
      v_kitle_sonuc                   VARCHAR2 (255);                --MKECECI
      v_servis_dusur                  CHAR (1) := 'H';

      --20130821 BSarcan
      p_gelecek_donem                 NUMBER;
      p_faturalanmis_borc             NUMBER;
      p_toplam_odenmis_miktar         NUMBER;
      p_alacak                        NUMBER;
      p_mahsup_edilecek               NUMBER;
      p_mahsup_edilen                 NUMBER;
      p_toplam_borc                   NUMBER;
      p_iade_edilmis_fatura_odemesi   NUMBER;
      p_iade_edilmis_avans_odemesi    NUMBER;
      p_bakiye                        NUMBER;
      p_vadesi_gecmis_borc            NUMBER;
      p_acik_fatura_sayisi            NUMBER := 0;
      v_eski_statu                    CHAR (1);
      v_kamp_kontrol_count            NUMBER := 0;

      /*DEBUG*/
      v_log_return_status             VARCHAR2 (2000);
   /*DEBUG*/

   BEGIN
      /*DEBUG */
      IF dbs_sabit ('KUTU_HD_DEBUG_ALL') = 1
      THEN
         abone_batch_pack.insert_log (
               'begin rama_servis.servis_ekle('
            || in_account_number
            || ','
            || in_outlet_location
            || ','
            || in_servis_kodu
            || ','
            || in_kampanya_kodu
            || ','
            || in_servis_frekansi
            || ','
            || in_li_effective_date
            || ','
            || in_sebep_kodu
            || ','
            || in_bayi_kodu
            || ','
            || in_bayiden_satis
            || ','
            || in_ozel_fiyat
            || ','
            || in_adet
            || ','
            || in_bedelli
            || ','
            || in_sabit_promo_date
            || ','
            || in_kaynak
            || ','
            || in_islem_kaynak
            || ','
            || in_kontrol_tipi
            || ','
            || in_kullanici
            || ','
            || out_error_type
            || ','
            || out_error_code
            || ','
            || out_aciklama
            || ','
            || out_durum
            || ','
            || in_is_bundle
            || '); end;');
      END IF;

      /*DEBUG */
      BEGIN
         SELECT a.hp_cluster,
                a.customer_type,
                a.franchise_code,
                a.id,
                a.ulke,
                NVL (b.kod, '-1'),
                a.city
           INTO v_stb_tipi,
                v_uye_tipi,
                v_franchise_code,
                v_ulke,
                v_ulke_ad,
                v_il,
                v_il_ad
           FROM (SELECT lf.hp_cluster,
                        lf.customer_type,
                        lf.franchise_code,
                        u.id,
                        ds.ulke,
                        ds.city
                   FROM wiz_customer_hp_life lf,
                        wiz_hp_description ds,
                        co_ulke u
                  WHERE     lf.account_number = in_account_number
                        AND lf.service_address_id = ds.service_address_id
                        AND ds.ulke = u.ad) a,
                co_il b
          WHERE a.id = b.ulke_id(+) AND a.city = b.ad(+);
      EXCEPTION
         WHEN OTHERS
         THEN
            out_durum := 'Abone bilgisi seçiminde hata';
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
      END;

      SELECT COUNT (*)
        INTO v_count
        FROM co_kullanici
       WHERE kod = in_kullanici;

      IF v_count = 0
      THEN
         out_durum := 'Kullanici bilgisi seçiminde hata';
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      fatura.currency_pack.currency_format_control (in_ozel_fiyat, out_durum);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      IF     in_islem_kaynak <> 'DONDURMA_SVCDEN_GERI_AL'
         AND in_islem_kaynak <> 'KAPAMA_SVCDEN_GERI_AL'
      THEN
         IF TRUNC (in_li_effective_date) + 1 <= TRUNC (SYSDATE)
         THEN
            IF yetki_pack.yetkisi_varmi (
                  in_kullanici,
                  'ISLEM_SERVIS_EKLE_DUSUR_GERI_TARIH') = 0
            THEN
               out_durum :=
                  'GERI TARIHLI ISLEM YAPMA YETKINIZ BULUNMAMAKTADIR';
               out_error_type := 1;
               out_error_code := 'ERR97';
               RETURN;
            END IF;
         END IF;
      END IF;

      -- sadece yeni kontrat için üyelik kapamasi olana servis eklenebilir
      IF     in_islem_kaynak <> 'KAPAMA_SERVIS'
         AND in_islem_kaynak <> 'KAPAMA_SVCDEN_GERI_AL'
         AND in_islem_kaynak <> 'KAPAMA_WODAN_GERI_AL'
         AND in_sebep_kodu <> dbs_sabit ('YENI_KONTRAT')
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM ie_uyelik_kapama
          WHERE account_number = in_account_number AND durum = 'K';

         IF v_count > 0
         THEN
            out_durum :=
               'Bu üye borcundan dolayi kapanmis durumdadir. Servis ekleyemezsiniz !!';
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;
      END IF;

      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'CEK_SERVIS_EKLE_' || in_servis_frekansi) =
            0
      THEN
         out_durum :=
               in_servis_frekansi
            || ' frekansi ile servis ekleme yetkiniz yok. ';
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      IF     NVL (in_bedelli, 'E') = 'H'
         AND yetki_pack.yetkisi_varmi (in_kullanici,
                                       'CEK_SERVIS_EKLE_BEDELSIZ') = 0
      THEN
         out_durum := 'BEDELSIZ SERVIS EKLEME YETKINIZ BULUNMAMAKTADIR';
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      uye_kontrol_pack.uye_icrada_mi (in_account_number, out_durum);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR89';
         RETURN;
      END IF;

      uye_kontrol_pack.uye_illegal_mi (in_account_number,
                                       in_outlet_location,
                                       in_kullanici,
                                       out_durum);

      IF out_durum <> '0'
      THEN
         out_error_type := 1;
         out_error_code := 'ERR90';
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM mb_abone_ozellik
       WHERE     account_number = in_account_number
             AND abone_ozellik_kodu = 155
             AND (   outlet_location = in_outlet_location
                  OR outlet_location IS NULL);

      IF v_count > 0
      THEN
         out_durum :=
               'Servis ekleyemezsiniz !!! '
            || dbs_sabit ('ADDRESSABLE_ISLEM_YAPAMAZ');
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM mb_abone_ozellik
       WHERE     account_number = in_account_number
             AND abone_ozellik_kodu = 182
             AND (   outlet_location = in_outlet_location
                  OR outlet_location IS NULL);

      IF v_count > 0
      THEN
         out_durum := 'Bu üyeye servis eklenemez.';
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      /*--- Evren --- 20110718 --- begin ---*/
      --IF v_uye_tipi = 'LOJ' AND yetki_pack.yetkisi_varmi (in_kullanici, 'ISLEM_SERVIS_CUST_TYPE_LOJ', 1) = 0
      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'ISLEM_SERVIS_CUST_TYPE_' || v_uye_tipi,
                                   1) = 0             --  MKECECI - 04.03.2013
      THEN
         out_durum :=
               v_uye_tipi
            || ' üye tipindeki üyelere servis ekleme/çikarma yetkiniz yoktur.';
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      /*--- Evren --- 20110718 --- end ---*/

      -- Outlette transfer var ise servisin yeni üyeye uyumlu mu kontrolu
      transfer_control.servis_add_kontrol (in_account_number,
                                           in_outlet_location,
                                           in_servis_kodu,
                                           in_servis_frekansi,
                                           in_kampanya_kodu,
                                           in_li_effective_date,
                                           out_durum);

      IF out_durum <> '0'
      THEN
         out_durum :=
               'Üyede outlet transferi oldugundan yeni üye için:'
            || out_durum;
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      /*[BSarcan201308021]<begin>
            Suspend Süreçlerinde
            A şıkkı
                Toplam Borc 100 tl ve üzeri olan
                2 veya daha Fazla açık faturası olan
                I,N,K ve w statüsündeki üyelere paket eklemeye izin vermemeli

            C şıkkı
                Sus to in olan üyelerin de yayınları 1 faturası olsa bile burada tutar limiti yok 10 tl olsa bile Aktiflenemeyecek

      */

      IF     yetki_pack.yetkisi_varmi (in_kullanici,
                                       'BORCLU_UYE_PAKET_EKLEME') = 0
         AND v_franchise_code = 'F01'
      THEN
         BEGIN
              SELECT COUNT (statu), eski_statu
                INTO v_count, v_eski_statu
                FROM mb_abone_statu
               WHERE     account_number = in_account_number
                     AND statu IN ('I',
                                   'N',
                                   'K',
                                   'W')
                     AND outlet_location = in_outlet_location
            GROUP BY statu, eski_statu;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_count := 0;
         END;

         IF v_count > 0
         THEN                                    -- statu in ('I','N','K','W')
            bilgi_pack.abone_cari_bilgileri (in_account_number,
                                             0, --yeni eklenen parametre,sadece kontrat girişinde 1 gönderilecek
                                             p_gelecek_donem,
                                             p_faturalanmis_borc,
                                             p_toplam_odenmis_miktar,
                                             p_alacak,
                                             p_mahsup_edilecek,
                                             p_mahsup_edilen,
                                             p_toplam_borc,
                                             p_iade_edilmis_fatura_odemesi,
                                             p_iade_edilmis_avans_odemesi,
                                             p_bakiye,
                                             p_vadesi_gecmis_borc);

            IF p_toplam_borc >= 100
            THEN
               --2 veya daha Fazla açık faturası olan

               SELECT COUNT (1)
                 INTO p_acik_fatura_sayisi
                 FROM dt_billing_dba.statement s,
                      dt_party_dba.party_role_account pra
                WHERE     s.bill_account_id = pra.party_role_account_id
                      AND pra.party_role_account_spec_cd =
                             'UYE_FATURA_HESABI'
                      AND s.main_statement_id IS NULL
                      AND s.payment_status_type_cd = 'ACIK'
                      AND s.statement_status_type_cd = 'GECERLI'
                      AND pra.dbs_account_number = in_account_number;

               IF p_acik_fatura_sayisi >= 2
               THEN
                  out_durum := 'Borçlu üyeye servis ekleyemezsiniz.';
                  out_error_type := 1;
                  out_error_code := 'ERR97';
                  RETURN;
               END IF;
            END IF;                                          -- A şıkkı bitti.

            IF v_eski_statu = 'S' AND p_toplam_borc > 0
            THEN                                                    -- c şıkkı
               out_durum := 'Suspend In olan uyeye servis ekleyemezsiniz.';
               out_error_type := 1;
               out_error_code := 'ERR97';
               RETURN;
            END IF;
         END IF;
      END IF;

      --[Bsarcan201308015]<end>
      /*--- Evren --- 20101019 --- begin ---*/
      --Turksat ve CW ise sporlu paket alamaz kontrolu
      SELECT COUNT (1)
        INTO v_count
        FROM dbs_addr_cas_services cc, dbs_addr_dbs_cas_services cdd
       WHERE     cc.code = cdd.cas_code
             AND cc.product_number IN (SELECT product_number
                                         FROM dbs_addr.dbs_addr_cas_services_group
                                        WHERE code IN (3, 4))
             AND NOT EXISTS
                        (SELECT 1
                           FROM TABLE (
                                   split_table_fnc (
                                      dbs_dba.dbs_sabit (
                                         TRIM (
                                            'SPORLU_PAKETTE_HARICI_SERVISLER'))))
                          WHERE COLUMN_VALUE = cdd.dbs_code)
             AND cdd.dbs_code = in_servis_kodu;

      IF v_count > 0 OR in_servis_kodu = 'SPM'
      THEN
         v_sporlu_paket := TRUE;
      END IF;

      v_sc_ekipman_tip_matrix_id := NULL;
      v_serial_number := NULL;

      BEGIN
         SELECT eq_ekipman_tip_matrix_id, serial_number
           INTO v_sc_ekipman_tip_matrix_id, v_serial_number
           FROM wiz_equip w, eq_ekipman_tip_matrix e
          WHERE     w.account_number = in_account_number
                AND w.outlet_location = in_outlet_location
                AND w.converter_type = 'SC'
                AND TRIM (e.manufacturer) = TRIM (w.manufacturer)
                AND TRIM (e.converter_model) = TRIM (w.converter_model)
                AND TRIM (e.converter_type) = TRIM (w.converter_type);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      IF    (    v_sporlu_paket
             AND abone_sorgu_pack.uye_uydusu (in_account_number,
                                              in_outlet_location) = 2
             AND NVL (
                    ekipman_pack.ekipman_irdeto_desteklimi (v_serial_number),
                    'H') <> 'E')
         OR (    v_sporlu_paket
             AND dbs_sabit ('CRYPTO_KARTLA_MAC_SEYREDILEMEZ') = 'E'
             AND NVL (
                    ekipman_pack.ekipman_irdeto_desteklimi (v_serial_number),
                    'H') <> 'E'
             AND yetki_pack.yetkisi_varmi (
                    in_kullanici,
                    'ISLEM_CRYPTO_KARTA_SPOR_EKLEYEBILME') = 0)
      THEN
         out_durum :=
            'EKLENILEN SPORLU PAKET BU KARTTA KULLANILAMAZ !!! KART IRDETO DESTEKLI OLMALIDIR ! ';
         out_error_type := 1;
         out_error_code := 'ERR97';
         RETURN;
      END IF;

      --      -- Sporlu pakette kullanilmayan ekipman ve abone kontrolu
      --      SELECT COUNT (1)
      --        INTO v_count
      --        FROM mb_abone_ozellik
      --       WHERE account_number = in_account_number
      --             AND (outlet_location = in_outlet_location
      --                  OR outlet_location IS NULL)
      --             AND abone_ozellik_kodu = 215;

      -- sporlu paket kullanamayan uye özellisi
      --IF v_count > 0 AND yetki_pack.yetkisi_varmi (in_kullanici, 'ISLEM_SERVIS_EKLE_SPORLU_PAKET') = 0 THEN                                 -- Aktivasyon mu normal mi kontrolu
      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'ISLEM_SERVIS_EKLE_SPORLU_PAKET') = 0
      THEN                                 -- Aktivasyon mu normal mi kontrolu
         SELECT COUNT (1)
           INTO v_count
           FROM TABLE (
                   split_table_fnc (
                      dbs_dba.dbs_sabit (
                         TRIM ('SPORLU_PAKETTE_EKIPMAN_KONTROLU'))))
          WHERE COLUMN_VALUE = v_franchise_code || ':' || v_uye_tipi;

         IF v_count > 0                      -- franchise ve uye tipi uyuyorsa
         THEN
            IF v_sporlu_paket                              -- Sporlu Paket ise
            THEN
               v_st_ekipman_tip_matrix_id := NULL;
               v_md_ekipman_tip_matrix_id := NULL;

               BEGIN
                  SELECT eq_ekipman_tip_matrix_id
                    INTO v_md_ekipman_tip_matrix_id
                    FROM eq_ekipman w, eq_ekipman_tip_matrix e
                   WHERE     w.account_number = in_account_number
                         AND w.outlet_location = in_outlet_location
                         AND e.converter_type = '248'
                         AND NVL (w.ekipman_modul_tipi, -1) =
                                NVL (e.converter_model, -1)
                         AND w.ekipman_tipi = e.converter_type;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
                        SELECT eq_ekipman_tip_matrix_id
                          INTO v_st_ekipman_tip_matrix_id
                          FROM wiz_equip w, eq_ekipman_tip_matrix e
                         WHERE     w.account_number = in_account_number
                               AND w.outlet_location = in_outlet_location
                               AND w.converter_type = 'ST'
                               AND TRIM (e.manufacturer) =
                                      TRIM (w.manufacturer)
                               AND TRIM (e.converter_model) =
                                      TRIM (w.converter_model)
                               AND TRIM (e.converter_type) =
                                      TRIM (w.converter_type);
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           NULL;
                     END;
               END;

               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE     ozellik_kodu = 98
                      AND ekipman_tip_matrix_id = v_st_ekipman_tip_matrix_id;

               IF v_count > 0
               THEN
                  out_durum :=
                     'EKLENILEN SPORLU PAKET BU KUTUDA KULLANILAMAZ. ';
                  out_error_type := 1;
                  out_error_code := 'ERR97';
                  RETURN;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE     ozellik_kodu = 98
                      AND ekipman_tip_matrix_id = v_md_ekipman_tip_matrix_id;

               IF v_count > 0
               THEN
                  out_durum :=
                     'EKLENILEN SPORLU PAKET BU MODULDE KULLANILAMAZ. ';
                  out_error_type := 1;
                  out_error_code := 'ERR97';
                  RETURN;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE     ozellik_kodu = 98
                      AND ekipman_tip_matrix_id = v_sc_ekipman_tip_matrix_id;

               IF v_count > 0
               THEN
                  out_durum :=
                     'EKLENILEN SPORLU PAKET BU KARTTA KULLANILAMAZ. ';
                  out_error_type := 1;
                  out_error_code := 'ERR97';
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF;

      --<MKECECI>CW kartların PPV içeren servisleri almaması sağlandı
      --      IF YETKI_PACK.YETKISI_VARMI (in_kullanici,'CW_KARTLA_PPV_EKLEME') = 0 THEN  --yetkisi yoksa
      --          IF NVL (ekipman_pack.ekipman_irdeto_desteklimi (v_serial_number), 'H') <> 'E' then   --CW destekli ise
      --                 --hülya abla ve evrim abladan gelen sorgu  buraya yazılıcakl.
      --                 --ppv içeren servis eklenmeye çalışılıyorsa eklenmesine izin verilmeyecek.
      --                 -- in_servis_kodu
      --
      --                  --out_durum := 'CW kart ile '|| in_servis_kodu ||' paketini ekleyemezsiniz';
      --                  --out_error_type := 1;
      --                  --out_error_code := 'ERR97';
      --                 NULL;
      --          END IF;
      --      END IF;
      --</end>

      /*--- Evren --- 20101019 --- end ---*/
      --------------------
      -- Evrim Mart 2007
      -- IBX0001231
      -- Ekipman satilik ise, kontrat asamasinda zaten satin alma islemi yapilmistir, ama DBS deki herhangi bir yarim  kalma sonucu
      -- ödeme ve sahiplik yapilmadiysa diye kontrol yapilir.
      -- Satilik olup da, ödemesi olmayan ekipmana, servis satilmaz
      DECLARE
         v_ozellik_satilik   VARCHAR2 (1);
         v_ekipman_sahibi    VARCHAR2 (20);
      BEGIN
         v_ozellik_satilik :=
            ekipman_pack.ekipman_satilikmi (NULL,           -- iserial_number,
                                            in_account_number,
                                            in_outlet_location,
                                            NULL);

         --v_old_lokasyon
         IF v_ozellik_satilik = 'E'
         THEN
            DECLARE
               l_ekipman_tip     NUMBER;
               l_serial_number   wiz_equip.serial_number%TYPE;
            BEGIN
               SELECT MIN (serial_number)
                 INTO l_serial_number
                 FROM eq_ekipman e
                WHERE     e.account_number = in_account_number
                      AND e.outlet_location = in_outlet_location
                      AND e.ekipman_tipi = 248;

               IF l_serial_number IS NULL
               THEN
                  SELECT MIN (serial_number)
                    INTO l_serial_number
                    FROM wiz_equip e
                   WHERE     e.account_number = in_account_number
                         AND e.outlet_location = in_outlet_location
                         AND e.converter_type = 'ST';

                  l_ekipman_tip := 247;
               ELSE
                  l_ekipman_tip := 248;
               END IF;

               IF ekipman_pack.ekipman_sahibi (in_account_number,
                                               in_outlet_location,
                                               l_ekipman_tip)
                     IS NULL
               THEN
                  out_durum :=
                     'Aboneye verilmis ekipman satiliktir, öncelikle ödemesinin yapilmasi gerekmektedir.';
                  out_error_type := 1;
                  out_error_code := 'ERR791';
                  RETURN;
               END IF;
            END;
         END IF;
      END;

      -- Talep edilen servis interaktif özellik tasiyorsa, kutu da bunu desteklemeli.
      --------------------
      -- Evrim Haziran 2007
      -- Ekipman uyumu gerektiren farkli servisler gelebilir, (turk sadece interaktif servis degil)..
      -- bunlar için ekipman özellikleri tanimlandi.
      -- Ekipman uyumu gerektiren servisler için, hem ekipmana hem de servise bu özellik eklenir.
      servisekipmanuyum (in_account_number,
                         in_outlet_location,
                         in_servis_kodu,
                         in_kullanici,
                         out_aciklama,
                         out_durum,
                         out_error_type,
                         out_error_code,
                         v_servis_dusur,
                         'SERVIS_EKLEME');

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      /*Mesut Keçecioglu - bayi gruplarinin kontrolü 24.05.2012*/
      SELECT COUNT (1)
        INTO v_count
        FROM bt_bayi_ozellik x, pr_abone_ozellik y
       WHERE     x.bayi_ozellik_kodu = y.kod -- Bayi üzerinde kod grubu 1 olan özellik var ise devam etmesini istiyoruz.
             AND x.sales_agent_code = in_bayi_kodu
             AND y.kod_grubu = 1;

      IF v_count > 0
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM mb_abone_ozellik x, pr_abone_ozellik y
          WHERE     x.abone_ozellik_kodu = y.kod
                AND y.kod_grubu = 1 -- üye üzerinde kod grubu 1 olan özellik var ise devam etmesini istiyoruz
                AND x.account_number = in_account_number;

         IF v_count > 0
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM bt_bayi_ozellik x, pr_abone_ozellik y
             WHERE     x.bayi_ozellik_kodu = y.kod
                   AND x.sales_agent_code = in_bayi_kodu
                   AND y.kod_grubu = 1
                   AND x.bayi_ozellik_kodu IN (SELECT abone_ozellik_kodu
                                                 FROM mb_abone_ozellik
                                                WHERE account_number =
                                                         in_account_number);

            IF v_count = 0
            THEN
               SELECT y.aciklama
                 INTO v_abone_ozellik_aciklama
                 FROM mb_abone_ozellik x, pr_abone_ozellik y
                WHERE     x.abone_ozellik_kodu = y.kod
                      AND y.kod_grubu = 1 --üyede olupta bayi üzerinde olmayan özelligi yakaliyoruz burada.
                      AND x.account_number = in_account_number
                      AND x.abone_ozellik_kodu NOT IN (SELECT x.bayi_ozellik_kodu
                                                         FROM bt_bayi_ozellik x,
                                                              pr_abone_ozellik y
                                                        WHERE     x.bayi_ozellik_kodu =
                                                                     y.kod
                                                              AND x.sales_agent_code =
                                                                     in_bayi_kodu
                                                              AND y.kod_grubu =
                                                                     1)
                      AND ROWNUM < 2;

               out_durum :=
                     v_abone_ozellik_aciklama
                  || ' grubundan islem yapma yetkiniz yoktur ';
               out_error_type := 1;
               out_error_code := 'ERR97';
               RETURN;
            END IF;
         END IF;
      END IF;

      /*Mesut Keçecioglu - bayi gruplarinin kontrolü*/
      -- kampanya kitle kontrolü
      -- EKayan Eylül 2007
      v_kitle_sonuc :=
         kitle_pack.kitleye_uygun_mu (NULL,           -- in_ust_kampanya_kodu,
                                      in_kampanya_kodu,
                                      in_servis_kodu,
                                      in_servis_frekansi,
                                      in_account_number,
                                      in_outlet_location,
                                      NULL,
                                      NULL,       -- in_ekipman_tip_matrix_id,
                                      NULL,                -- v_serial_number,
                                      v_uye_tipi,
                                      v_stb_tipi,
                                      v_franchise_code,
                                      SYSDATE,
                                      in_kullanici);

      IF v_kitle_sonuc <> '0'
      THEN
         v_kamp_kontrol_count :=
            uye_kampanya_kontrolu (in_account_number,
                                   in_outlet_location,
                                   in_servis_kodu,
                                   in_kampanya_kodu,
                                   in_li_effective_date);

         IF v_kamp_kontrol_count = 0
         THEN
            --Kitlenin neden uygun olmadığı açıklaması döndürülüyor.MKECECI
            --out_durum := 'Satis kampanyasi, bu abone için uygun degildir !';
            out_durum := v_kitle_sonuc;
            out_error_type := 1;
            out_error_code := 'ERR756';
            RETURN;
         END IF;
      END IF;

      -- kampnaya il kisiti kontrolü
      -- icr_dp_servis_default_bayi_det tablosunda kampanya il ve bayiye göre kisitlanmistir
      SELECT COUNT (*)
        INTO v_count
        FROM icr_dp_servis_default s, icr_dp_servis_default_detay d
       WHERE     s.kod = d.servis_default_kodu
             AND s.campaign_code = in_kampanya_kodu
             AND (   s.billing_frequency IS NULL
                  OR s.billing_frequency = in_servis_frekansi)
             AND s.sms_code = in_servis_kodu
             AND s.franchise_code = v_franchise_code
             AND (s.effective_date IS NULL OR s.effective_date <= SYSDATE)
             AND (s.stb_tipi IS NULL OR s.stb_tipi = v_stb_tipi)
             AND d.customer_type = v_uye_tipi;

      IF v_count > 0
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM icr_dp_servis_default s,
                icr_dp_servis_default_detay d,
                (SELECT *
                   FROM icr_dp_servis_default_bayi_det
                  WHERE     (   baslangic_tarihi IS NULL
                             OR baslangic_tarihi <= SYSDATE)
                        AND (bitis_tarihi IS NULL OR bitis_tarihi > SYSDATE))
                b
          WHERE     s.kod = d.servis_default_kodu
                AND s.kod = b.servis_default_kodu(+)
                AND s.campaign_code = in_kampanya_kodu
                AND (   s.billing_frequency IS NULL
                     OR s.billing_frequency = in_servis_frekansi)
                AND s.sms_code = in_servis_kodu
                AND s.franchise_code = v_franchise_code
                AND (s.effective_date IS NULL OR s.effective_date <= SYSDATE)
                AND (s.stb_tipi IS NULL OR s.stb_tipi = v_stb_tipi)
                AND d.customer_type = v_uye_tipi
                AND (b.ulke IS NULL OR b.ulke = v_ulke)
                AND (b.il IS NULL OR b.il = v_il);

         IF v_count = 0
         THEN
            v_count :=
               uye_kampanya_kontrolu (in_account_number,
                                      in_outlet_location,
                                      in_servis_kodu,
                                      in_kampanya_kodu,
                                      in_li_effective_date);

            IF v_count = 0
            THEN
               out_durum :=
                     'Bu kampanyada il kisiti bulunmaktadir.Bu kampanya '
                  || v_ulke_ad
                  || ' - '
                  || v_il_ad
                  || ' için geçerli degildir.';
               out_error_type := 1;
               out_error_code := 'ERR97';
               RETURN;
            END IF;
         END IF;
      END IF;

      v_kampanya_kodu := in_kampanya_kodu;
      v_kmp_outlet := NULL;
      v_dusurulecek_servis := FALSE;

      IF dbs_sabit ('OUTLET_KAMPANYASI_UYGULANACAK_MI') = 'E'
      THEN
         v_kmp_outlet := '000';
         v_kmp_outlet :=
            kmp_outlet_mi (in_account_number,
                           in_outlet_location,
                           v_franchise_code,
                           v_stb_tipi,
                           v_uye_tipi,
                           in_servis_kodu,
                           in_li_effective_date,
                           out_durum);

         IF out_durum <> '0'
         THEN
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;

         IF v_kmp_outlet = '000' AND in_kampanya_kodu = 'OT1'
         THEN
            out_durum :=
               'Outlet kampanyasi için gerekli kampanya üyede bulunmuyor!';
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;

         IF v_kmp_outlet <> '000'
         THEN
            IF v_kmp_outlet <> in_outlet_location
            THEN
               v_kampanya_kodu := 'OT1';
            END IF;
         ELSE
            v_kmp_outlet := in_outlet_location;
         END IF;
      END IF;

      IF NOT (in_kampanya_kodu = 'KMP' OR in_kampanya_kodu = 'OT1')
      THEN
         v_kmp_outlet := in_outlet_location;
         v_kampanya_kodu := in_kampanya_kodu;
      END IF;

      IF v_kampanya_kodu = 'OT1'
      THEN
         servis_operator_bul (v_uye_tipi,
                              in_outlet_location,
                              in_servis_kodu,
                              v_kampanya_kodu,
                              v_franchise_code,
                              in_servis_frekansi,
                              in_li_effective_date,
                              v_stb_tipi,
                              v_count);

         IF v_count > 0
         THEN
            --KAYIT BULUNAMADI ISE OT1 TANIMLI DEGIL OUTLET KAMPANYASI UYGULANMAYACAK
            v_kampanya_kodu := in_kampanya_kodu;
            v_kmp_outlet := NULL;
         END IF;
      END IF;

      v_li_effective_date := in_li_effective_date;

      IF     (   (    in_kaynak <> 'DBS'
                  AND dbs_sabit ('AYNI_PAKET_DBS_DISI_SCHEDULE_ET') = 'E')
              OR (    in_kaynak = 'DBS'
                  AND dbs_sabit ('AYNI_PAKET_DBS_SCHEDULE_ET') = 'E'))
         AND yetki_pack.yetkisi_varmi (
                in_kullanici,
                'ISLEM_AYNI_PAKET_SCHEDULE_ETMEME_YETKI') = 0
      THEN
         get_li_eff_date (in_account_number,
                          in_outlet_location,
                          in_servis_kodu,
                          v_kampanya_kodu,
                          in_servis_frekansi,
                          in_li_effective_date,
                          v_uye_tipi,
                          v_franchise_code,
                          in_kullanici,
                          v_li_effective_date,
                          out_durum);

         IF out_durum <> '0'
         THEN
            out_error_type := 1;
            out_error_code := 'ERR97';
            RETURN;
         END IF;

         IF v_li_effective_date IS NOT NULL
         THEN
            IF v_li_effective_date <> in_li_effective_date
            THEN
               v_li_effective_date :=
                  TRUNC (v_li_effective_date) + (1 / 24) * 12;
            END IF;
         END IF;
      END IF;

      IF v_li_effective_date IS NULL
      THEN
         v_li_effective_date := in_li_effective_date;
      END IF;

      servis_ekle_calis (in_account_number,
                         in_outlet_location,
                         in_servis_kodu,
                         v_kampanya_kodu,
                         in_servis_frekansi,
                         v_li_effective_date,
                         in_sebep_kodu,
                         in_bayi_kodu,
                         in_bayiden_satis,
                         in_ozel_fiyat,
                         v_stb_tipi,
                         v_uye_tipi,
                         v_franchise_code,
                         in_adet,
                         in_bedelli,
                         in_sabit_promo_date,
                         in_kaynak,
                         in_islem_kaynak,
                         in_kontrol_tipi,
                         in_kullanici,
                         in_is_bundle,
                         v_dusurulecek_servis,
                         out_error_type,
                         out_error_code,
                         out_aciklama,
                         out_durum);

      IF out_durum = '0'
      THEN
         out_error_type := 0;
         out_error_code := 'VLD113';

         IF TRUNC (in_li_effective_date) <> TRUNC (v_li_effective_date)
         THEN
            IF in_kaynak = 'DBS'
            THEN
               v_temp_aciklama :=
                  'D I K K A T ! Ekledisiniz servisin ekleme tarihi degistirilmistir. <E>';

               IF out_aciklama IS NULL
               THEN
                  out_aciklama := v_temp_aciklama;
               ELSE
                  out_aciklama := out_aciklama || '<E>' || v_temp_aciklama;
               END IF;
            END IF;

            out_error_type := 0;
            out_error_code := 'VLD230';
         END IF;

         servis_islem_msg (in_account_number,
                           in_outlet_location,
                           'ADD',
                           in_kullanici,
                           out_error_type,
                           out_error_code,
                           v_temp_aciklama,
                           out_durum);

         IF     out_durum = '0'
            AND dbs_sabit ('OUTLET_KAMPANYASI_UYGULANACAK_MI') = 'E'
            AND v_kmp_outlet IS NOT NULL
            AND NOT v_dusurulecek_servis
            AND in_kontrol_tipi <> 2
         THEN
            servis_outlet_kmp (in_account_number,
                               in_outlet_location,
                               in_servis_kodu,
                               in_kampanya_kodu,
                               v_kmp_outlet,
                               in_servis_frekansi,
                               v_li_effective_date,
                               in_sebep_kodu,
                               in_bayi_kodu,
                               in_bayiden_satis,
                               in_ozel_fiyat,
                               v_stb_tipi,
                               v_uye_tipi,
                               v_franchise_code,
                               in_adet,
                               in_bedelli,
                               in_sabit_promo_date,
                               in_kaynak,
                               in_islem_kaynak,
                               in_kontrol_tipi,
                               in_kullanici,
                               v_error_type,
                               v_error_code,
                               v_aciklama,
                               out_durum);
         END IF;

         RETURN;
      ELSE
         IF out_error_code = 'VLD113' OR TRIM (out_error_code) IS NULL
         THEN
            out_error_type := 1;
            out_error_code := 'ERR97';
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'servis_ekle :' || SQLERRM;
         out_error_type := 1;
         out_error_code := 'ERR97';
   END servis_ekle;

   PROCEDURE sf_urun_servis_kontrol (in_kampanya_kodu   IN     CHAR,
                                     in_kullanici       IN     VARCHAR2,
                                     out_durum             OUT VARCHAR2)
   IS
      v_count   NUMBER (5);
   BEGIN
      out_durum := '0';

      SELECT COUNT (*)
        INTO v_count
        FROM pr_urun_ozellik_tanim a
       WHERE     a.urun_tipi = 1
             AND a.urun_kodu = in_kampanya_kodu
             AND a.ozellik_kodu = 22
             AND a.listeden_gizle = 'H';

      -- sifreli ürün satisi degil
      IF v_count = 0
      THEN
         RETURN;
      END IF;

      -- sifreli ürün satisi o zaman yetkisi var mi?
      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'ISLEM_SF_URUN_SERVIS_DEGISTIR') = 0
      THEN
         out_durum :=
            'Bu servis islemini ISLEM_SF_URUN_SERVIS_DEGISTIR yetkisi ile yapabilirsiniz!';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'sf_urun_servis_kontrol :' || SQLERRM;
   END sf_urun_servis_kontrol;

   PROCEDURE servis_dusur (in_account_number      IN     NUMBER,
                           in_outlet_location     IN     CHAR,
                           in_servis_kodu         IN     CHAR,
                           in_kampanya_kodu       IN     CHAR,
                           in_servis_frekansi     IN     CHAR,
                           in_li_effective_date   IN     DATE,
                           in_sebep_kodu          IN     CHAR,
                           in_promotion_code      IN     CHAR,
                           in_bedelli             IN     CHAR,
                           in_kaynak              IN     VARCHAR2,
                           in_kontrol_tipi        IN     NUMBER,
                           in_kullanici           IN     VARCHAR2,
                           out_durum                 OUT VARCHAR2)
   IS
      CURSOR son_servis_cur (
         p_service_code    tm_servis.service_code%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND islem IN ('ADD', 'DSR')
         ORDER BY tarih DESC;

      CURSOR tm_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND islem = 'DSR';

      v_stb_tipi         VARCHAR2 (10);
      v_uye_tipi         CHAR (3);
      v_franchise_code   CHAR (3);
      v_count            NUMBER;
      v_error_type       NUMBER;
      v_error_code       VARCHAR2 (10);
      v_aciklama         VARCHAR2 (3000);
   BEGIN
      out_durum := '0';

      BEGIN
         SELECT hp_cluster, customer_type, franchise_code
           INTO v_stb_tipi, v_uye_tipi, v_franchise_code
           FROM wiz_customer_hp_life
          WHERE account_number = in_account_number;
      EXCEPTION
         WHEN OTHERS
         THEN
            out_durum := 'Abone bilgisi seçiminde hata';
            RETURN;
      END;

      SELECT COUNT (*)
        INTO v_count
        FROM co_kullanici
       WHERE kod = in_kullanici;

      IF v_count = 0
      THEN
         out_durum := 'Kullanici bilgisi seçiminde hata';
         RETURN;
      END IF;

      IF TRUNC (in_li_effective_date) + 1 <= TRUNC (SYSDATE)
      THEN
         IF yetki_pack.yetkisi_varmi (in_kullanici,
                                      'ISLEM_SERVIS_EKLE_DUSUR_GERI_TARIH') =
               0
         THEN
            out_durum := 'GERI TARIHLI ISLEM YAPMA YETKINIZ BULUNMAMAKTADIR';
            RETURN;
         END IF;
      END IF;

      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'CEK_SERVIS_CIKAR_' || in_servis_frekansi) =
            0
      THEN
         out_durum :=
               in_servis_frekansi
            || ' frekansli servisi çikarma yetkiniz yok. ';
         RETURN;
      END IF;

      IF     NVL (in_bedelli, 'E') = 'H'
         AND yetki_pack.yetkisi_varmi (in_kullanici,
                                       'CEK_SEVIS_CIKAR_BEDELSIZ') = 0
      THEN
         out_durum := 'BEDELSIZ SERVIS DÜSÜRME YETKINIZ BULUNMAMAKTADIR';
         RETURN;
      END IF;

      /*--- Evren --- 20110718 --- begin ---*/
      -- IF v_uye_tipi = 'LOJ' AND yetki_pack.yetkisi_varmi (in_kullanici, 'ISLEM_SERVIS_CUST_TYPE_LOJ', 1) = 0
      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'ISLEM_SERVIS_CUST_TYPE_' || v_uye_tipi,
                                   1) = 0                            --MKECECI
      THEN
         out_durum :=
               v_uye_tipi
            || ' üye tipindeki üyelere servis ekleme/çikarma yetkiniz yoktur.';
         RETURN;
      END IF;

      /*--- Evren --- 20110718 --- end ---*/
      servis_doldur (in_account_number,
                     v_uye_tipi,
                     in_outlet_location,
                     in_servis_kodu,
                     in_kampanya_kodu,
                     in_servis_frekansi,
                     v_franchise_code,
                     in_li_effective_date,
                     'A',                                     --IN_EKLEME_TIPI
                     in_kullanici,
                     0,                                     --V_KAMPANYA_OK_MI
                     out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      sf_urun_servis_kontrol (in_kampanya_kodu, in_kullanici, out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;

      FOR son_servis_rec IN son_servis_cur (in_servis_kodu)
      LOOP
         IF son_servis_rec.tarih >= in_li_effective_date
         THEN
            IF son_servis_rec.islem = 'ADD'
            THEN
               IF son_servis_rec.tarih >= in_li_effective_date
               THEN
                  out_durum :=
                        TO_CHAR (son_servis_rec.tarih,
                                 'DD.MM.YYYY HH24:MI:SS')
                     || ' Tarihinden önce bu servis düsürülemez!';
               ELSE
                  out_durum :=
                     'Bu servisi düsürmek için eklenmis son kayidi seçmelisiniz!';
               END IF;
            ELSE
               out_durum :=
                     TO_CHAR (son_servis_rec.tarih, 'DD.MM.YYYY HH24:MI:SS')
                  || ' Tarihinde bu servis zaten düsürülüyor!';
            END IF;

            RETURN;
         END IF;

         IF son_servis_rec.islem = 'DSR'
         THEN
            out_durum := 'Servis zaten düsecek!';
            RETURN;
         END IF;

         IF son_servis_rec.islem = 'ADD'
         THEN
            IF    in_kampanya_kodu <> son_servis_rec.campaign_code
               OR in_servis_frekansi <> son_servis_rec.servis_frekansi
            THEN
               out_durum := 'Düsecek servis ilgili son servis olmalidir.';
               RETURN;
            END IF;
         END IF;

         EXIT;
      END LOOP;

      IF in_kontrol_tipi = 2
      THEN
         IF servis_util_pack.bundle_kmp_mi (in_kampanya_kodu) > 0
         THEN
            out_durum :=
                  in_servis_kodu
               || ' Bundle kampanyali servis düsürülemiyor!';
            RETURN;
         END IF;
      END IF;

      --Önce Düsecek servis TM_SERVIS tablosuna insert edilir...
      INSERT INTO tm_servis (account_number,
                             outlet_location,
                             service_code,
                             islem,
                             tarih,
                             campaign_code,
                             durum,
                             servis_frekansi,
                             promotion_code)
           VALUES (in_account_number,
                   in_outlet_location,
                   in_servis_kodu,
                   'DSR',
                   in_li_effective_date,
                   in_kampanya_kodu,
                   'D',
                   in_servis_frekansi,
                   in_promotion_code);

      servis_durum_kontrol (in_account_number,
                            in_outlet_location,
                            in_servis_kodu,
                            'DSR',
                            in_li_effective_date,
                            v_uye_tipi,
                            v_franchise_code,
                            in_kaynak,
                            in_kullanici,
                            in_kontrol_tipi,
                            v_error_type,
                            v_error_code,
                            v_aciklama,
                            out_durum);

      IF out_durum <> '0'
      THEN
         RETURN;
      END IF;
   /*Yeni eklenecek bir kod...
    SELECT COUNT (*)
      INTO v_count
      FROM PR_SERVIS_TAKIP a,
           PR_SERVIS_TAKIP_DETAY b,
           PR_YASAK_ZORUNLU_SERVIS_TAKIP c,
           MB_ABONE_DERGI d
     WHERE a.kod = b.servis_takip_kodu
       AND a.kod = c.servis_takip_kodu
       AND a.service_code = 'DRG'
       AND a.franchise_code = in_franchise_code
       AND a.listeden_gizle = 'H'
       AND (a.bitis_tarihi IS NULL OR a.bitis_tarihi > SYSDATE)
       AND (a.stb_tipi IS NULL OR a.stb_tipi = v_stb_tipi)
       AND b.customer_type = in_uye_tipi
       AND c.yasakmi = 'H'
       AND c.service_code = in_servis_kodu
       AND d.account_number = in_account_number
       AND d.outlet_location = in_outlet_location
       AND d.durum = 1;

    IF v_count > 0
    THEN
       dergi_kontrol (in_account_number,
                                       in_outlet_location,
                                       'DSR',
                                       in_li_effective_date,
                                       in_kullanici,
                                       durum,
                                       3
                                      );

       IF durum <> '0'
       THEN
          RETURN;
       END IF;
    END IF;
   */
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'servis_dusur :' || SQLERRM;
   END servis_dusur;

   PROCEDURE servis_tarih_degistir (
      in_account_number      IN     tm_ek.account_number%TYPE,
      in_outlet_location     IN     tm_ek.outlet_location%TYPE,
      in_servis_kodu         IN     tm_ek.service_code%TYPE,
      in_job_code            IN     wiz_wo_line_items.job_code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_billing_frequency   IN     icr_dp_servis_default.billing_frequency%TYPE,
      in_li_effective_date   IN     DATE,
      in_new_li_effective    IN     DATE,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_kullanici           IN     co_kullanici.kod%TYPE,
      durum                     OUT VARCHAR2)
   IS
      v_onceki_tarih              DATE;
      v_sonraki_tarih             DATE;
      out_aciklama                VARCHAR2 (4000);      --BURADA KULLANILMIYOR
      v_drop_tarihi               DATE;
      v_add_tarihi                DATE;
      v_error_type                NUMBER;
      v_error_code                VARCHAR2 (50);
      v_count                     NUMBER;
      v_count1                    NUMBER;
      v_wo_id                     NUMBER;
      v_fiyat_bitis_tarihi        DATE;
      v_promosyon_bitis_tarihi    DATE;
      v_eski_fiyat_bitis_tarihi   DATE;
      v_promotion_code            CHAR (3);
   BEGIN
      IF in_job_code <> 'DSR'
      THEN
         IF yetki_pack.yetkisi_varmi (in_kullanici,
                                      'ISLEM_PUAN_SERVIS_TARIH_DEGISTIR') = 0
         THEN
            durum := 'Bu islem sadece düsürme satirina uygulanabilir.';
            RETURN;
         END IF;
      END IF;

      SELECT COUNT (*)
        INTO v_count1
        FROM vv_servis_icerik
       WHERE icerik_kodu = 'DRG' AND paket_kodu = in_servis_kodu;

      IF v_count1 > 0
      THEN
         dergi_kontrol (in_account_number,
                        in_outlet_location,
                        'DSR',
                        in_new_li_effective,
                        in_kullanici,
                        durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;
      END IF;

      servis_doldur (in_account_number,
                     in_uye_tipi,
                     in_outlet_location,
                     in_servis_kodu,
                     in_kampanya_kodu,
                     in_billing_frequency,
                     in_franchise_code,
                     in_li_effective_date,
                     'A',
                     in_kullanici,
                     0,
                     durum);

      SELECT MAX (tarih)
        INTO v_onceki_tarih
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND service_code = in_servis_kodu
             AND islem <> in_job_code
             AND tarih <= in_li_effective_date;

      IF v_onceki_tarih IS NOT NULL
      THEN
         IF in_new_li_effective <= v_onceki_tarih
         THEN
            durum :=
                  TO_CHAR (v_onceki_tarih, 'DD.MM.YYYY HH24:MI:SS')
               || ' tarihinden büyük olmalidir!';
            RETURN;
         END IF;
      END IF;

      SELECT MIN (tarih)
        INTO v_sonraki_tarih
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND service_code = in_servis_kodu
             AND islem <> in_job_code
             AND tarih >= in_li_effective_date;

      IF v_sonraki_tarih IS NOT NULL
      THEN
         IF in_new_li_effective > v_sonraki_tarih
         THEN
            durum :=
                  TO_CHAR (v_sonraki_tarih, 'DD.MM.YYYY HH24:MI:SS')
               || ' tarihinden büyük olamaz!';
            RETURN;
         END IF;
      END IF;

      SELECT baglanti_id
        INTO v_wo_id
        FROM tm_servis
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND tarih = in_li_effective_date
             AND service_code = in_servis_kodu
             AND islem = in_job_code;

      IF in_li_effective_date < in_new_li_effective
      THEN
         SELECT COUNT (*)
           INTO v_count1
           FROM mb_uye_kontor_cari_detay
          WHERE wo_line_id = v_wo_id;

         IF v_count1 = 0
         THEN
            durum := 'Tarihi geri alabilirsiniz!';
            RETURN;
         END IF;
      END IF;

      is_emri_iptal_edilebilir_mi (v_wo_id,
                                   in_kullanici,
                                   2,
                                   durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      --12.06.2006 Mustafa - HK yetkisizler için degistirilen satirlar !!!
      --      IF in_job_code = 'DSR'
      IF     in_job_code = 'DSR'
         AND vestel_pack.abone_stb_tipi_bul (in_account_number) <> 'HK'
      THEN
         servis_erken_dsr_kontrol (in_account_number,
                                   in_outlet_location,
                                   in_servis_kodu,
                                   in_billing_frequency,
                                   in_kampanya_kodu,
                                   in_li_effective_date,
                                   in_new_li_effective,
                                   in_kullanici,
                                   0,
                                   durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;
      END IF;

      sf_urun_servis_kontrol (in_kampanya_kodu, in_kullanici, durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      UPDATE tm_servis
         SET tarih = in_new_li_effective
       WHERE     account_number = in_account_number
             AND outlet_location = in_outlet_location
             AND tarih = in_li_effective_date
             AND service_code = in_servis_kodu
             AND islem = in_job_code;

      servis_durum_kontrol (in_account_number,
                            in_outlet_location,
                            in_servis_kodu,
                            in_job_code,
                            in_new_li_effective,
                            in_uye_tipi,
                            in_franchise_code,
                            NULL,
                            in_kullanici,
                            0,
                            v_error_type,
                            v_error_code,
                            out_aciklama,
                            durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      IF TRUNC (in_li_effective_date) <> TRUNC (in_new_li_effective)
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM wiz_wo_line_items
          WHERE     id =
                       (SELECT baglanti_id
                          FROM tm_servis
                         WHERE     account_number = in_account_number
                               AND outlet_location = in_outlet_location
                               AND tarih = in_new_li_effective
                               AND service_code = in_servis_kodu
                               AND islem = in_job_code)
                AND wo_grup_id IS NOT NULL;

         IF v_count > 0
         THEN
            durum := 'Grup islemlerinde tarih degistiremezsiniz';
            RETURN;
         END IF;
      END IF;

      UPDATE wiz_wo_line_items
         SET li_effective_date = in_new_li_effective,
             degistiren_kullanici = in_kullanici,
             degistirme_tarihi = SYSDATE
       WHERE id =
                (SELECT baglanti_id
                   FROM tm_servis
                  WHERE     account_number = in_account_number
                        AND outlet_location = in_outlet_location
                        AND tarih = in_new_li_effective
                        AND service_code = in_servis_kodu
                        AND islem = in_job_code);

      DELETE FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;

      DELETE FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;

      BEGIN
         SELECT fiyat_bitis_tarihi,
                promosyon_bitis_tarihi,
                eski_fiyat_bitis_tarihi,
                promotion_code
           INTO v_fiyat_bitis_tarihi,
                v_promosyon_bitis_tarihi,
                v_eski_fiyat_bitis_tarihi,
                v_promotion_code
           FROM wiz_wo_line_items a, ps_uye_talep_detay b
          WHERE a.id = b.wo_line_id AND a.id = v_wo_id AND a.job_code = 'ADD';

         v_count := in_new_li_effective - in_li_effective_date;

         IF v_fiyat_bitis_tarihi IS NOT NULL
         THEN
            v_fiyat_bitis_tarihi := v_fiyat_bitis_tarihi + v_count;
         END IF;

         IF v_promosyon_bitis_tarihi IS NOT NULL
         THEN
            v_promosyon_bitis_tarihi := v_promosyon_bitis_tarihi + v_count;
            fatura.servis_taksit_charge.taksit_update (
               in_account_number,
               in_outlet_location,
               in_servis_kodu,
               in_kampanya_kodu,
               v_promotion_code,
               v_promosyon_bitis_tarihi);
         END IF;

         IF v_eski_fiyat_bitis_tarihi IS NOT NULL
         THEN
            v_eski_fiyat_bitis_tarihi := v_eski_fiyat_bitis_tarihi + v_count;
         END IF;

         UPDATE wiz_wo_line_items
            SET fiyat_bitis_tarihi = v_fiyat_bitis_tarihi,
                promosyon_bitis_tarihi = v_promosyon_bitis_tarihi,
                eski_fiyat_bitis_tarihi = v_eski_fiyat_bitis_tarihi
          WHERE id = v_wo_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   ---????  lg islem takip e kayit
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'SERVIS TARIH DEGISTIR:' || SQLERRM;
   END servis_tarih_degistir;

   PROCEDURE is_emri_grup_iptal_kontrol (in_tablo       IN     VARCHAR2,
                                         in_kayit_id    IN     NUMBER,
                                         in_satir_id    IN     NUMBER,
                                         in_grup_id     IN     NUMBER,
                                         in_kullanici   IN     VARCHAR2,
                                         durum             OUT VARCHAR2)
   IS
      /*
        IN_TABLO => 'W' WIZ_WO_LINE_ITEMS
                    'D' DONDURMA
                    'K' KAPAMA

        IN_KAYIT_ID => WORK_ORDER_NUMBER
                   UYELIK_DONDURMA_ID
                   UYELIK_KAPAMA_ID
      */
      v_count     NUMBER;
      v_grup_id   NUMBER;
   BEGIN
      durum := '0';

      IF in_tablo = 'W'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM wiz_wo_line_items l1
          WHERE     work_order_number = in_kayit_id
                AND wo_status = 'O'
                AND wo_grup_id = in_grup_id
                AND id <> in_satir_id;
      ELSIF in_tablo = 'D'
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM ie_uyelik_dondurma_servis
          WHERE     uyelik_dondurma_id = in_kayit_id
                AND eklenecek_mi = 'E'
                AND durum = 2
                AND wo_grup_id = in_grup_id
                AND id <> in_satir_id;
      ELSE
         SELECT COUNT (1)
           INTO v_count
           FROM ie_uyelik_kapama_servis
          WHERE     uyelik_kapama_id = in_kayit_id
                AND eklenecek_mi = 'E'
                AND durum = 2
                AND wo_grup_id = in_grup_id
                AND id <> in_satir_id;
      END IF;

      IF v_count > 0
      THEN
         durum :=
            in_grup_id || ' grubundaki tüm is emirleri iptal edilmelidir!';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Grup No Kontrol:' || SQLERRM;
   END is_emri_grup_iptal_kontrol;

   PROCEDURE servis_isemri_iptal_kontrol (
      in_account_number       IN     tm_ek.account_number%TYPE,
      in_wo_numm              IN     wiz_wo_line_items.work_order_number%TYPE,
      in_outlet_location      IN     tm_ek.outlet_location%TYPE,
      in_service_code         IN     tm_ek.service_code%TYPE,
      in_billing_frequency    IN     wiz_wo_line_items.servis_frekansi%TYPE,
      in_job_code             IN     wiz_wo_line_items.job_code%TYPE,
      in_kullanici_kodu       IN     co_kullanici.wiz_employee_code%TYPE,
      in_sebep_kodu           IN     wiz_wo_line_items.problem_code%TYPE,
      in_islem_tarihi         IN     DATE,
      in_service_address_id   IN     wiz_work_order.service_address_id%TYPE,
      in_advertise_code       IN     wiz_wo_line_items.advertise_code%TYPE,
      in_campaign_code        IN     wiz_wo_line_items.campaign_code%TYPE,
      in_kullanici            IN     co_kullanici.kod%TYPE,
      out_hata_durumu            OUT VARCHAR2,
      durum                      OUT VARCHAR2,
      aciklama                   OUT VARCHAR2)
   IS
      /*
        OUT_HATA_DURUMU :
                    0 HATA YOK VEYA NORMAL HATA DIGER IPTALLER ILE DÜZELTILEBILIR
                    1 CIDDI HATA ISLEM IPTAL EDILMEZ
      */
      CURSOR dsh_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = in_service_code
                  AND tarih < in_islem_tarihi
         ORDER BY tarih DESC;

      CURSOR grup_cur
      IS
         SELECT wo_grup_id, id
           FROM wiz_wo_line_items
          WHERE     work_order_number = in_wo_numm
                AND wo_status = 'O'
                AND job_code = in_job_code
                AND service_code = in_service_code
                AND campaign_code = in_campaign_code
                AND outlet_location = in_outlet_location
                AND servis_frekansi = in_billing_frequency;

      v_customer_type    wiz_customer_hp_life.customer_type%TYPE;
      v_franchise_code   wiz_customer_hp_life.franchise_code%TYPE;
      v_stb_tipi         wiz_customer_hp_life.hp_cluster%TYPE;
      out_aciklama       VARCHAR2 (4000);               --BURADA KULLANILMIYOR
      v_error_type       NUMBER;
      v_error_code       VARCHAR2 (50);
      v_wo_grup_id       wiz_wo_line_items.wo_grup_id%TYPE;
      v_id               wiz_wo_line_items.id%TYPE;
      v_count            NUMBER;
   BEGIN
      out_hata_durumu := '0';

      SELECT customer_type, franchise_code, hp_cluster
        INTO v_customer_type, v_franchise_code, v_stb_tipi
        FROM wiz_customer_hp_life
       WHERE account_number = in_account_number;

      servis_doldur (in_account_number,
                     v_customer_type,
                     in_outlet_location,
                     in_service_code,
                     in_campaign_code,
                     in_billing_frequency,
                     v_franchise_code,
                     in_islem_tarihi,
                     'A',
                     in_kullanici,
                     0,
                     durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      IF dbs_sabit ('TRA_ADVERTISE_CODE') = in_advertise_code
      THEN
         FOR d_rec IN dsh_cur
         LOOP
            --Servisin ilgili ekleme satiri iptal edilmeden düsürme satiri iptal edilenmez!
            IF d_rec.islem = 'ADD'
            THEN
               out_hata_durumu := '1';
               durum :=
                  'Bu islemden önce ilgili ekleme satirini iptal etmelisiniz!';
               RETURN;
            END IF;

            EXIT;
         END LOOP;
      END IF;

      IF in_job_code = 'ADD'
      THEN
         sf_urun_servis_kontrol (in_campaign_code, in_kullanici, durum);

         IF durum <> '0'
         THEN
            out_hata_durumu := '1';
            RETURN;
         END IF;

         servis_ekle_tahsilat.kk_tahsilat_isemri_iptal_etmi (
            in_account_number,
            in_outlet_location,
            v_customer_type,
            v_franchise_code,
            v_stb_tipi,
            in_service_code,
            in_campaign_code,
            in_billing_frequency,
            in_islem_tarihi,
            in_kullanici,
            durum);

         IF durum <> '0'
         THEN
            out_hata_durumu := '1';
            RETURN;
         END IF;
      END IF;

      DELETE FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = in_service_code
                  AND tarih = in_islem_tarihi
                  AND islem = in_job_code;

      servis_durum_kontrol (in_account_number,
                            in_outlet_location,
                            in_service_code,
                            'IPT',
                            in_islem_tarihi,
                            v_customer_type,
                            v_franchise_code,
                            NULL,
                            in_kullanici,
                            0,
                            v_error_type,
                            v_error_code,
                            out_aciklama,
                            durum);

      IF durum <> '0'
      THEN
         durum := 'Bu satir iptal edilemez. ' || durum;
         RETURN;
      END IF;

      SELECT COUNT (*)
        INTO v_count
        FROM vv_servis_icerik
       WHERE icerik_kodu = 'DRG' AND paket_kodu = in_service_code;

      IF v_count > 0 AND in_job_code = 'DSR'
      THEN
         dergi_kontrol (in_account_number,
                        in_outlet_location,
                        'IPT',
                        in_islem_tarihi,
                        in_kullanici,
                        durum);

         IF durum <> '0'
         THEN
            out_hata_durumu := '1';
            RETURN;
         END IF;
      END IF;

      --Ayni gruptaki tüm is emirleri iptal edilmelidir.
      FOR grup_rec IN grup_cur
      LOOP
         is_emri_grup_iptal_kontrol ('W',
                                     in_wo_numm,
                                     grup_rec.id,
                                     grup_rec.wo_grup_id,
                                     in_kullanici,
                                     durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;
      END LOOP;

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      IF yetki_pack.yetkisi_varmi (in_kullanici,
                                   'ISLEM_SERVIS_KAMPANYA_UPGRADE') = 0
      THEN
         FOR srv_rec
            IN (SELECT DISTINCT
                       a.campaign_code, TRIM (b.main_service) AS main_service
                  FROM wiz_wo_line_items a, wiz_campaign_codes b
                 WHERE     a.work_order_number = in_wo_numm
                       AND a.outlet_location = in_outlet_location
                       AND a.job_code = 'ADD'
                       AND a.wo_status = 'O'
                       AND (   a.service_code <> in_service_code
                            OR a.servis_frekansi <> in_billing_frequency
                            OR a.li_effective_date <> in_islem_tarihi
                            OR a.campaign_code <> in_campaign_code)
                       AND a.campaign_code = b.campaign_code
                       AND TRIM (b.main_service) IS NOT NULL
                       AND TRIM (b.group_code) IS NOT NULL)
         LOOP
            SELECT COUNT (*)
              INTO v_count
              FROM wiz_customer_hp_svc
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND campaign_code = srv_rec.campaign_code;

            IF v_count = 0
            THEN
               /*--- Evren --- 20100920 --- begin ---*/
               SELECT COUNT (*)
                 INTO v_count
                 FROM wiz_wo_line_items a
                WHERE     a.work_order_number = in_wo_numm
                      AND a.outlet_location = in_outlet_location
                      AND a.job_code = 'ADD'
                      AND a.wo_status = 'O'
                      AND (   a.service_code <> in_service_code
                           OR a.servis_frekansi <> in_billing_frequency
                           OR a.li_effective_date <> in_islem_tarihi
                           OR a.campaign_code <> in_campaign_code)
                      AND a.campaign_code = srv_rec.campaign_code
                      AND EXISTS
                             (SELECT 1
                                FROM TABLE (
                                        split_table_fnc (
                                           srv_rec.main_service))
                               WHERE COLUMN_VALUE = a.service_code);

               /*SELECT COUNT (*)
                INTO v_count
                FROM wiz_wo_line_items a
               WHERE a.work_order_number = in_wo_numm
                 AND a.outlet_location = in_outlet_location
                 AND a.job_code = 'ADD'
                 AND a.wo_status = 'O'
                 AND (   a.service_code <> in_service_code
                      OR a.servis_frekansi <> in_billing_frequency
                      OR a.li_effective_date <> in_islem_tarihi
                      OR a.campaign_code <> in_campaign_code
                     )
                 AND a.service_code = srv_rec.main_service
                 AND a.campaign_code = srv_rec.campaign_code;*/
               /*--- Evren --- 20100920 --- end ---*/
               IF v_count = 0
               THEN
                  durum :=
                        srv_rec.campaign_code
                     || ' kampanyasinin baslangiç servisi '
                     || srv_rec.main_service
                     || ' bulunamiyor !!';
                  RETURN;
               END IF;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'Servis is Emri IPTAL :' || SQLERRM;
   END servis_isemri_iptal_kontrol;

   PROCEDURE servis_isemri_iptal (
      in_account_number       IN     tm_ek.account_number%TYPE,
      in_wo_numm              IN     wiz_wo_line_items.work_order_number%TYPE,
      in_outlet_location      IN     tm_ek.outlet_location%TYPE,
      in_service_code         IN     tm_ek.service_code%TYPE,
      in_billing_frequency    IN     wiz_wo_line_items.servis_frekansi%TYPE,
      in_job_code             IN     wiz_wo_line_items.job_code%TYPE,
      in_kullanici_kodu       IN     co_kullanici.wiz_employee_code%TYPE,
      in_sebep_kodu           IN     wiz_wo_line_items.problem_code%TYPE,
      in_islem_tarihi         IN     DATE,
      in_service_address_id   IN     wiz_work_order.service_address_id%TYPE,
      in_advertise_code       IN     wiz_wo_line_items.advertise_code%TYPE,
      in_campaign_code        IN     wiz_wo_line_items.campaign_code%TYPE,
      in_kullanici            IN     co_kullanici.kod%TYPE,
      durum                      OUT VARCHAR2,
      aciklama                   OUT VARCHAR2)
   IS
      v_islem_tarihi   DATE;
      v_co_kull_kod    co_kullanici.kod%TYPE;
      v_sc             wiz_equip.serial_number%TYPE;
      v_temp           VARCHAR2 (50);
      v_id             bt_bayi_kota_hp_svc.id%TYPE;
      v_status         wiz_wo_line_items.wo_status%TYPE;
   BEGIN
      durum := '0';

      IF TRUNC (in_islem_tarihi) = '01.01.1900'
      THEN
         v_islem_tarihi := '01.01.0001';
      ELSE
         v_islem_tarihi := in_islem_tarihi;
      END IF;

      work_order_pack.void_wo_line_items (in_wo_numm,
                                          in_job_code,
                                          in_service_code,
                                          in_outlet_location,
                                          in_campaign_code,
                                          in_kullanici_kodu,
                                          in_sebep_kodu,
                                          v_islem_tarihi,
                                          durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      /*--- Evren --- 20111126 -- begin ---*/
      --servise basli joblar da void a çekiliyor
      IF in_job_code = 'ADD'
      THEN
         FOR rec_
            IN (SELECT job_code
                  FROM wiz_wo_line_items
                 WHERE     work_order_number = in_wo_numm
                       AND wo_status = 'O'
                       AND TRIM (service_code) IS NULL
                       AND campaign_code = in_campaign_code
                       AND outlet_location = in_outlet_location
                       AND li_effective_date BETWEEN   v_islem_tarihi
                                                     - 5 / 86400
                                                 AND   v_islem_tarihi
                                                     + 5 / 86400
                       AND job_code IN (SELECT product_code
                                          FROM wiz_product_codes
                                         WHERE product_type = 3))
         LOOP
            work_order_pack.void_wo_line_items (in_wo_numm,
                                                rec_.job_code,
                                                NULL,
                                                in_outlet_location,
                                                in_campaign_code,
                                                in_kullanici_kodu,
                                                in_sebep_kodu,
                                                v_islem_tarihi,
                                                durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END LOOP;
      END IF;

      /*--- Evren --- 20111126 -- end ---*/
      SELECT kod
        INTO v_co_kull_kod
        FROM co_kullanici
       WHERE wiz_employee_code = in_kullanici_kodu;

      v_sc := uye_seri_no (in_account_number, in_outlet_location);

      IF in_job_code = 'ADD'
      THEN
         v_temp := 'EKLEME';
      ELSIF in_job_code = 'DSR'
      THEN
         v_temp := 'DÜSÜRME';
      ELSE
         v_temp := in_job_code;
      END IF;

      IF durum = '0' AND in_job_code = 'ADD'
      THEN
         BEGIN
            SELECT id, wo_status
              INTO v_id, v_status
              FROM (SELECT x.id, w.wo_status
                      FROM bt_bayi_kota_hp_svc x, wiz_wo_line_items w
                     WHERE     x.wo_line_id = w.id
                           AND x.work_order_number = in_wo_numm
                           AND x.account_number = in_account_number
                           AND x.outlet_location = in_outlet_location
                           AND x.service_code = in_service_code
                    UNION
                    SELECT x.id, ow.wo_status    --,x.kota_kod_id,x.wo_line_id
                      FROM bt_bayi_kota_hp_svc x, wiz_wo_line_history ow
                     WHERE     x.wo_line_id = ow.wo_line_id
                           AND x.work_order_number = in_wo_numm
                           AND x.account_number = in_account_number
                           AND x.outlet_location = in_outlet_location
                           AND x.service_code = in_service_code);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
            WHEN OTHERS
            THEN
               durum := 'BAYI KOTA SERVIS HATASI :' || SQLERRM;
               RETURN;
         END;

         IF TRIM (v_status) = 'V'
         THEN
            bayi_detay_pack.bt_bayi_kota_hp_svc_ins_upd (
               v_id,
               NULL,
               NULL,
               'E',
               v_co_kull_kod,
               'BKS',
               'Servis iptalinden dolayi kota iptal edildi.',
               v_id,
               durum);

            IF TRIM (durum) <> '0'
            THEN
               durum := 'BAYI KOTA SERVIS :' || durum;
               RETURN;
            END IF;
         END IF;
      END IF;

      log_pack.lg_abone_islem_takip_insert (
         in_account_number,
         in_service_code || ',' || v_temp || ',' || in_sebep_kodu,
         v_sc,
         '26',
         v_co_kull_kod,
         durum);

      DELETE FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;

      DELETE FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'SERVIS IS EMRI IPTAL:' || SQLERRM;
   END servis_isemri_iptal;

   PROCEDURE servis_degerleri (
      in_id                 IN     NUMBER,
      in_tablo              IN     NUMBER,
      out_adet                 OUT wiz_customer_hp_svc.quantity%TYPE,
      out_servis_frekansi      OUT wiz_customer_hp_svc.servis_frekansi%TYPE,
      out_ozel_fiyat           OUT wiz_customer_hp_svc.non_standard_service_rate%TYPE,
      out_bayiden_satis        OUT wiz_customer_hp_svc.bayiden_satis%TYPE)
   IS
      /*
        IN_TABLO
        1-WIZ_CUSTOMER_HP_SVC
        2-WIZ_WO_LINE_ITEMS
        3-UYELIK_DONDURMA_SERVIS
        4-UYELIK_KAPAMA_SERVIS
      */
      CURSOR svc_cur
      IS
         SELECT *
           FROM wiz_customer_hp_svc
          WHERE id = in_id;

      CURSOR wl_cur
      IS
         SELECT *
           FROM wiz_wo_line_items
          WHERE id = in_id;

      CURSOR don_cur
      IS
         SELECT *
           FROM ie_uyelik_dondurma_servis
          WHERE id = in_id;

      CURSOR kap_cur
      IS
         SELECT *
           FROM ie_uyelik_kapama_servis
          WHERE id = in_id;
   BEGIN
      IF in_tablo = 1
      THEN
         FOR kayit_rec IN svc_cur
         LOOP
            out_adet := kayit_rec.quantity;
            out_servis_frekansi := kayit_rec.servis_frekansi;
            out_ozel_fiyat :=
               cur_cnvr (kayit_rec.non_standard_service_rate,
                         kayit_rec.currency,
                         2);
            out_bayiden_satis := kayit_rec.bayiden_satis;
            RETURN;
         END LOOP;
      END IF;

      IF in_tablo = 2
      THEN
         FOR kayit_rec IN wl_cur
         LOOP
            out_adet := kayit_rec.quantity;
            out_servis_frekansi := kayit_rec.servis_frekansi;
            out_ozel_fiyat :=
               cur_cnvr (kayit_rec.non_standard_service_rate,
                         kayit_rec.currency,
                         2);
            out_bayiden_satis := kayit_rec.bayiden_satis;
            RETURN;
         END LOOP;
      END IF;

      IF in_tablo = 3
      THEN
         FOR kayit_rec IN don_cur
         LOOP
            out_adet := kayit_rec.quantity;
            out_servis_frekansi := kayit_rec.servis_frekansi;
            out_ozel_fiyat :=
               cur_cnvr (kayit_rec.non_standard_service_rate,
                         kayit_rec.currency,
                         2);
            out_bayiden_satis := kayit_rec.bayiden_satis;
            RETURN;
         END LOOP;
      END IF;

      IF in_tablo = 4
      THEN
         FOR kayit_rec IN kap_cur
         LOOP
            out_adet := kayit_rec.quantity;
            out_servis_frekansi := kayit_rec.servis_frekansi;
            out_ozel_fiyat :=
               cur_cnvr (kayit_rec.non_standard_service_rate,
                         kayit_rec.currency,
                         2);
            out_bayiden_satis := kayit_rec.bayiden_satis;
            RETURN;
         END LOOP;
      END IF;
   END servis_degerleri;

   PROCEDURE servis_promo_expire_date (
      in_id                         IN     NUMBER,
      in_tablo                      IN     NUMBER,
      out_promo_expire_date            OUT wiz_customer_hp_svc.promo_expire_date%TYPE,
      out_fiyat_bitis_tarihi           OUT wiz_customer_hp_svc.fiyat_bitis_tarihi%TYPE,
      out_eski_fiyat_bitis_tarihi      OUT wiz_customer_hp_svc.eski_fiyat_bitis_tarihi%TYPE)
   IS
      /*
        IN_TABLO
        1-WIZ_CUSTOMER_HP_SVC
        2-WIZ_WO_LINE_ITEMS
        3-UYELIK_DONDURMA_SERVIS
        4-UYELIK_KAPAMA_SERVIS
      */
      CURSOR svc_cur
      IS
         SELECT *
           FROM wiz_customer_hp_svc
          WHERE id = in_id;

      CURSOR wl_cur
      IS
         SELECT *
           FROM wiz_wo_line_items
          WHERE id = in_id;

      CURSOR don_cur
      IS
         SELECT *
           FROM ie_uyelik_dondurma_servis
          WHERE id = in_id;

      CURSOR kap_cur
      IS
         SELECT *
           FROM ie_uyelik_kapama_servis
          WHERE id = in_id;
   BEGIN
      IF in_tablo = 1
      THEN
         FOR kayit_rec IN svc_cur
         LOOP
            out_promo_expire_date := kayit_rec.promo_expire_date;
            out_fiyat_bitis_tarihi := kayit_rec.fiyat_bitis_tarihi;
            out_eski_fiyat_bitis_tarihi := kayit_rec.eski_fiyat_bitis_tarihi;
         END LOOP;
      END IF;

      IF in_tablo = 2
      THEN
         FOR kayit_rec IN wl_cur
         LOOP
            out_promo_expire_date := kayit_rec.promosyon_bitis_tarihi;
            out_fiyat_bitis_tarihi := kayit_rec.fiyat_bitis_tarihi;
            out_eski_fiyat_bitis_tarihi := kayit_rec.eski_fiyat_bitis_tarihi;
            RETURN;
         END LOOP;
      END IF;

      IF in_tablo = 3
      THEN
         FOR kayit_rec IN don_cur
         LOOP
            out_promo_expire_date := kayit_rec.promo_expire_date;
            out_fiyat_bitis_tarihi := kayit_rec.fiyat_bitis_tarihi;
            out_eski_fiyat_bitis_tarihi := kayit_rec.eski_fiyat_bitis_tarihi;
            RETURN;
         END LOOP;
      END IF;

      IF in_tablo = 4
      THEN
         FOR kayit_rec IN kap_cur
         LOOP
            out_promo_expire_date := kayit_rec.promo_expire_date;
            out_fiyat_bitis_tarihi := kayit_rec.fiyat_bitis_tarihi;
            out_eski_fiyat_bitis_tarihi := kayit_rec.eski_fiyat_bitis_tarihi;
            RETURN;
         END LOOP;
      END IF;
   END servis_promo_expire_date;

   PROCEDURE servis_kampanya_tanimli_mi (
      in_stb_tipi            IN     icr_dp_servis_default.stb_tipi%TYPE,
      in_uye_tipi            IN     icr_dp_servis_default_detay.customer_type%TYPE,
      in_franchise_code      IN     icr_dp_servis_default.franchise_code%TYPE,
      in_servis_kodu         IN     icr_dp_servis_default.code%TYPE,
      in_kampanya_kodu       IN     icr_dp_servis_default.campaign_code%TYPE,
      in_zorunlu_kampanya    IN     icr_dp_servis_default.campaign_code%TYPE,
      in_servis_frekansi     IN     icr_dp_servis_default.billing_frequency%TYPE,
      in_li_effective_date   IN     icr_dp_servis_default.effective_date%TYPE,
      in_kullanici           IN     icr_dp_servis_default.degistiren_kullanici%TYPE,
      durum                     OUT VARCHAR2)
   IS
      -- Durum '0' zorunlu servis tanimli yetkili ise onay gerekir degilse izin vermez
      -- Durum '1' zorunlu servis ihmal edilip istenilen kampanya ile eklenebilir
      -- Durum else hata mesaji verilip islem durur.
      v_count   NUMBER;
      v_sonuc   NUMBER;
   BEGIN
      SELECT COUNT (1)
        INTO v_count
        FROM DUAL
       WHERE dbs_sabit ('ZORUNLU_KAMPANYA_IHMAL') LIKE
                '%' || in_zorunlu_kampanya || '%';

      IF v_count > 0
      THEN
         durum := '1';
         RETURN;
      END IF;

      servis_operator_bul (in_uye_tipi,
                           '001',
                           in_servis_kodu,
                           in_zorunlu_kampanya,
                           in_franchise_code,
                           in_servis_frekansi,
                           in_li_effective_date,
                           in_stb_tipi,
                           v_sonuc);

      IF v_sonuc = 0
      THEN                                                 -- Kampanya tanimli
         durum := '0';
         RETURN;
      ELSIF v_sonuc = 1
      THEN                                                 --Kampanya tanimsiz
         durum := '1';
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'SERVIS KAMP TANIMLI MI:' || SQLERRM;
   END servis_kampanya_tanimli_mi;

   PROCEDURE wo_yarat (
      in_account_number       IN     tm_ek.account_number%TYPE,
      in_outlet_location      IN     tm_ek.outlet_location%TYPE,
      in_bayi_kodu            IN     wiz_work_order.sales_agent_code%TYPE,
      in_employee_code        IN     co_kullanici.wiz_employee_code%TYPE,
      in_kullanici_kodu       IN     co_kullanici.kod%TYPE,
      in_ozel_fiyat           IN     NUMBER,
      in_sebep_kodu           IN     wiz_wo_line_items.sales_code%TYPE,
      in_hemen_kapat          IN     NUMBER,
      in_kampanya_kodu        IN     icr_dp_servis_default.campaign_code%TYPE,
      in_service_address_id   IN     wiz_work_order.service_address_id%TYPE,
      in_adet                 IN     NUMBER,
      in_servis_frekansi      IN     wiz_wo_line_items.servis_frekansi%TYPE,
      in_bayiden_satis        IN     wiz_wo_line_items.bayiden_satis%TYPE,
      in_bedelli              IN     wiz_wo_line_items.bedelli%TYPE,
      in_servis_islem_tipi    IN     VARCHAR2,
      in_islem_kaynak         IN     VARCHAR2,
      wo_number                  OUT wiz_work_order.work_order_number%TYPE,
      durum                      OUT VARCHAR2,
      out_taa_uyari              OUT VARCHAR2,
      in_kontrol_tipi         IN     NUMBER := 0,
      in_taahhut_kontrollu    IN     VARCHAR2 := 'E')
   IS
      /*
      IN_KONTROL_TIPI 0 Genel
                      1 Zincir Magaza Satisi
                      2 PUAN ISLEMI
                      3 Bekleyen Servis DRG TALEBI

      in_servis_islem_tipi 'EKLEME' ,'DUSURME', 'IPTAL', 'TARIH_DEGISTIR'
      in_islem_kaynak      'NORMAL_SERVIS', 'DONDURMA_SERVIS', 'KAPAMA_SERVIS'

      TM SERVIS Durum
      A : Asil eklenecek servis
      B : Bayiden satistan dolayi düsen ve(ya) eklenen servis
      E : Yumurtlamadan dolayi eklenecek servis
      D : Düsürülecek servis
      Z : Düsen Promosyon taniminda dolayi bitis tarihinde zorunlu düsme ( Advertise_code ='DSH')
      J : Ekleme job
      S : Sorma amaçli islemler ( yumurtlanan servis ,
          daha sonra islemlerde kendisini baslayan gerek yok ise,
          yasak var ise veya ayni servis var ise uyari vermektedir.)
      Null : Uyenin üzerindeki mevcut Eski Servisler

      in_taahhut_kontrollu: Taahhut sorgulamasina girilip girilmeyecegini set eder. 'E' 'H'
      ornegin: ps_uye_talep_pack,outlet_transfer,batchler taahhut kontrolune girmez. yetki hatasi
      almadan devam etmeleri gerekir.
      */
      CURSOR servis_cur
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND durum IN ('A',
                                'E',
                                'D',
                                'Z',
                                'B')
         ORDER BY tarih;

      CURSOR baglanti_cur (
         p_service_code       tm_servis.service_code%TYPE,
         p_servis_frekansi    tm_servis.servis_frekansi%TYPE)
      IS
           SELECT *
             FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND service_code = p_service_code
                  AND servis_frekansi = p_servis_frekansi
                  AND islem = 'ADD'
         ORDER BY tarih DESC;

      CURSOR ek_servis_mi_cur (
         p_tarih           tm_servis.tarih%TYPE,
         p_service_code    tm_ek.service_code%TYPE)
      IS
         SELECT *
           FROM tm_servis
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND service_code = p_service_code
                AND tarih <= p_tarih
                AND durum = 'E';

      CURSOR job_cur
      IS
         SELECT *
           FROM tm_servis
          WHERE     durum = 'J'
                AND account_number = in_account_number
                AND outlet_location = in_outlet_location;

      v_baglanti_id                  tm_servis.baglanti_id%TYPE;
      v_promo_baglanti_id            tm_servis.baglanti_id%TYPE;
      v_ek_servis_dusuyor            BOOLEAN;
      v_sebep_kodu                   wiz_wo_line_items.sales_code%TYPE;
      v_is_emri_no                   wiz_work_order.work_order_number%TYPE;
      v_durum                        VARCHAR2 (300);
      v_advertise                    CHAR (3);
      v_asil_eklenecek_servis        tm_servis.service_code%TYPE;
      v_adet                         wiz_customer_hp_svc.quantity%TYPE;
      v_servis_frekansi              wiz_wo_line_items.servis_frekansi%TYPE;
      v_bayiden_satis                wiz_wo_line_items.bayiden_satis%TYPE;
      v_bayi_kodu                    wiz_work_order.sales_agent_code%TYPE;
      v_ozel_fiyat                   wiz_wo_line_items.non_standard_service_rate%TYPE;
      v_tablo                        NUMBER (1);
      v_ust_id                       ie_uyelik_dondurma.id%TYPE;
      v_sabit_kampanya               BOOLEAN;
      v_sabit_promo_end_date         DATE;
      v_promo_end_date               DATE;
      v_uye_tipi                     icr_dp_servis_default_detay.customer_type%TYPE;
      v_stb_tipi                     icr_dp_servis_default.stb_tipi%TYPE;
      v_count                        NUMBER;
      v_wo_line_id                   NUMBER (10);
      v_kota_svc_id                  NUMBER (10);
      v_bayi_kota_id                 bt_bayi_kota.id%TYPE;
      v_uye_tip_ticari_konut         VARCHAR2 (10);
      v_kategori_aciklama            pr_abone_ozellik.aciklama%TYPE;
      v_wo_grup_id                   wiz_wo_line_items.wo_grup_id%TYPE;
      v_dergi_id                     NUMBER;
      v_sozlesme_no                  VARCHAR2 (10);
      v_franchise_code               wiz_customer_hp_life.franchise_code%TYPE;
      v_fbt_tasinmali                BOOLEAN := FALSE;
      v_sabit_fiyat_bitis_tarihi     DATE;
      v_sabit_eski_fiyat_bitis_trh   DATE;
      v_wiz_wo_line_list             VARCHAR2 (3000);
      v_result_type                  NUMBER;
      v_result_code                  VARCHAR2 (20);
      v_result_message               VARCHAR2 (512);
   BEGIN
      durum := '0';

      IF    in_islem_kaynak IS NULL
         OR (    (in_islem_kaynak <> 'NORMAL_SERVIS')
             AND (in_islem_kaynak <> 'DONDURMA_SERVIS')
             AND (in_islem_kaynak <> 'KAPAMA_SERVIS'))
      THEN
         durum := 'ISLEMin kaynak bilgisi yok...';
         RETURN;
      END IF;

      v_bayi_kodu := in_bayi_kodu;
      v_bayiden_satis := in_bayiden_satis;
      v_advertise := NULL;

      SELECT customer_type, hp_cluster, franchise_code
        INTO v_uye_tipi, v_stb_tipi, v_franchise_code
        FROM wiz_customer_hp_life
       WHERE account_number = in_account_number;

      IF v_stb_tipi = 'TK' AND in_servis_islem_tipi = 'EKLEME'
      THEN
         BEGIN
            SELECT sozlesme_no
              INTO v_sozlesme_no
              FROM yk_dp_kontrat
             WHERE     uye_no = in_account_number
                   AND outlet_location = in_outlet_location
                   AND status = '30';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               durum := 'SOZLESME BULUNAMADI...';
               RETURN;
         END;

         SELECT COUNT (1)
           INTO v_count
           FROM lg_tk_sozlesme_aktivasyon
          WHERE sozlesme_no = v_sozlesme_no AND aktivasyon_tarihi IS NOT NULL;

         IF v_count > 0 AND in_sebep_kodu <> 'YKO'
         THEN
            durum :=
               'Bu üyenin sözlesmesi daha önce aktivasyonda kullanilmistir tekrar kullanilamaz!!';
            RETURN;
         END IF;

         IF v_count = 0
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM lg_tk_sozlesme_aktivasyon
             WHERE sozlesme_no = v_sozlesme_no;

            IF v_count = 0
            THEN
               INSERT INTO lg_tk_sozlesme_aktivasyon (sozlesme_no,
                                                      account_number,
                                                      outlet_location,
                                                      aktivasyon_tarihi,
                                                      giren_kullanici,
                                                      giris_tarihi,
                                                      degistiren_kullanici,
                                                      degistirme_tarihi)
                    VALUES (v_sozlesme_no,
                            in_account_number,
                            in_outlet_location,
                            SYSDATE,
                            in_kullanici_kodu,
                            SYSDATE,
                            in_kullanici_kodu,
                            SYSDATE);
            ELSE
               UPDATE lg_tk_sozlesme_aktivasyon
                  SET aktivasyon_tarihi = SYSDATE,
                      degistiren_kullanici = in_kullanici_kodu,
                      degistirme_tarihi = SYSDATE
                WHERE sozlesme_no = v_sozlesme_no;
            END IF;

            INSERT INTO lg_tk_sozlesme_aktivasyon_log (sozlesme_no,
                                                       account_number,
                                                       outlet_location,
                                                       aktivasyon_tarihi,
                                                       kullanici,
                                                       islem_tarihi)
                 VALUES (v_sozlesme_no,
                         in_account_number,
                         in_outlet_location,
                         SYSDATE,
                         in_kullanici_kodu,
                         SYSDATE);
         END IF;
      END IF;

      IF in_kontrol_tipi = 3
      THEN
         FOR servis_rec IN servis_cur
         LOOP
            SELECT MAX (id)
              INTO v_dergi_id
              FROM mb_abone_dergi
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND durum = 1;

            IF servis_rec.service_code = 'DRG' AND servis_rec.islem = 'ADD'
            THEN
               INSERT INTO ie_uye_bekleyen_servis (id,
                                                   dergi_id,
                                                   service_code,
                                                   job_code,
                                                   campaign_code,
                                                   promotion_code,
                                                   servis_frekansi,
                                                   beklenen_kapanma_tarihi,
                                                   durum,
                                                   non_standard_service_rate,
                                                   promosyon_dusurme_fiyati,
                                                   promo_expire_date,
                                                   quantity,
                                                   add_closed_date,
                                                   advertise_code,
                                                   bayiden_satis,
                                                   bedelli,
                                                   eklenecek_mi,
                                                   fiyat_bitis_tarihi,
                                                   servis_dusurme_fiyati,
                                                   servis_fiyati,
                                                   void_reason_code,
                                                   wo_grup_id,
                                                   zorunlu_servis_fiyati,
                                                   giren_kullanici,
                                                   giris_tarihi,
                                                   degistiren_kullanici,
                                                   degistirme_tarihi,
                                                   currency)
                    VALUES (ie_uye_bekleyen_servis_id_seq.NEXTVAL,
                            v_dergi_id,
                            servis_rec.service_code,
                            servis_rec.islem,
                            servis_rec.campaign_code,
                            servis_rec.promotion_code,
                            servis_rec.servis_frekansi,
                            servis_rec.tarih,
                            1,
                            -999999999 / 100,
                            NULL,
                            NULL,
                            1,
                            servis_rec.tarih,
                            'PAC',
                            'H',
                            'E',
                            'E',
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            in_kullanici_kodu,
                            SYSDATE,
                            in_kullanici_kodu,
                            SYSDATE,
                            cur_franchise (v_franchise_code));
            END IF;
         END LOOP;

         RETURN;
      END IF;

      IF in_islem_kaynak = 'NORMAL_SERVIS'
      THEN
         work_order_pack.work_order_insert (in_account_number,
                                            in_service_address_id,
                                            in_employee_code,
                                            v_bayi_kodu,
                                            4,
                                            v_is_emri_no,
                                            v_durum);

         IF v_durum <> '0'
         THEN
            durum := 'SERVIS WO_YARAT:' || v_durum;
            RETURN;
         END IF;
      END IF;

      /*      IF in_servis_islem_tipi = 'EKLEME' AND in_servis_frekansi <> '1'
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM tm_servis
                WHERE account_number = in_account_number
                  AND outlet_location = in_outlet_location
                  AND islem = 'DSR'
                  AND durum IS NOT NULL;

               IF v_count > 0
               THEN
                  --Mustafa 15.02.2005 Asagidaki select eklendi.
                  SELECT COUNT (1)
                    INTO v_count
                    FROM (SELECT DISTINCT TRUNC (tarih) AS tarih
                                     FROM tm_servis
                                    WHERE account_number = in_account_number
                                      AND outlet_location = in_outlet_location
                                      AND (   (servis_frekansi = in_servis_frekansi AND islem = 'ADD')
                                           OR (islem = 'DSR' AND durum IS NOT NULL)
                                          ));

                  IF v_count = 1
                  THEN
                     SELECT wiz_wo_line_wo_grup_id_seq.NEXTVAL
                       INTO v_wo_grup_id
                       FROM DUAL;
                  END IF;
               END IF;
            END IF;
      */
      IF in_servis_islem_tipi = 'EKLEME' AND in_servis_frekansi <> '1'
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM tm_servis a
          WHERE     account_number = in_account_number
                AND outlet_location = in_outlet_location
                AND islem = 'DSR'
                AND durum = 'D'
                AND EXISTS
                       (  SELECT b.account_number
                            FROM tm_servis b
                           WHERE     a.account_number = b.account_number
                                 AND a.outlet_location = b.outlet_location
                                 AND b.islem = 'ADD'
                                 AND b.durum IN ('A', 'E')
                        GROUP BY b.account_number
                          HAVING COUNT (*) = 1);

         IF v_count > 0
         THEN
            IF servis_util_pack.urun_ozellik_var_mi (1, in_kampanya_kodu, 45) =
                  1
            THEN
               SELECT COUNT (*)
                 INTO v_count
                 FROM (  SELECT DISTINCT
                                campaign_code,
                                servis_frekansi,
                                MAX (TRUNC (tarih)) AS tarih,
                                MAX (
                                   DECODE (
                                      promosyon_bitis_tarihi,
                                      TO_DATE ('01.01.0001', 'dd.mm.yyyy'), NULL,
                                      promosyon_bitis_tarihi))
                                   AS promosyon_bitis_tarihi
                           FROM tm_servis
                          WHERE     account_number = in_account_number
                                AND outlet_location = in_outlet_location
                                AND baglanti_id IS NOT NULL
                                AND service_code IN (SELECT a.service_code
                                                       FROM pr_servis_takip a,
                                                            pr_servis_takip_detay b
                                                      WHERE     a.kod =
                                                                   b.servis_takip_kodu
                                                            AND a.zorunlu = 'E'
                                                            AND a.franchise_code =
                                                                   v_franchise_code
                                                            AND a.listeden_gizle =
                                                                   'H'
                                                            AND (   a.bitis_tarihi
                                                                       IS NULL
                                                                 OR a.bitis_tarihi >
                                                                       SYSDATE)
                                                            AND (   a.stb_tipi
                                                                       IS NULL
                                                                 OR a.stb_tipi =
                                                                       v_stb_tipi)
                                                            AND b.customer_type =
                                                                   v_uye_tipi)
                       GROUP BY campaign_code, servis_frekansi) a
                WHERE     a.servis_frekansi = in_servis_frekansi
                      AND (   (    a.promosyon_bitis_tarihi > a.tarih
                               AND a.campaign_code = in_kampanya_kodu)
                           OR (    a.promosyon_bitis_tarihi <= a.tarih
                               AND 'KMP' = in_kampanya_kodu)
                           OR (    a.promosyon_bitis_tarihi IS NULL
                               AND a.campaign_code = in_kampanya_kodu));

               IF v_count = 0
               THEN
                  SELECT COUNT (*)
                    INTO v_count
                    FROM (  SELECT DISTINCT
                                   campaign_code,
                                   servis_frekansi,
                                   MAX (TRUNC (tarih)) AS tarih,
                                   MAX (
                                      DECODE (
                                         promosyon_bitis_tarihi,
                                         TO_DATE ('01.01.0001', 'dd.mm.yyyy'), NULL,
                                         promosyon_bitis_tarihi))
                                      AS promosyon_bitis_tarihi
                              FROM tm_servis
                             WHERE     account_number = in_account_number
                                   AND outlet_location = in_outlet_location
                                   AND baglanti_id IS NOT NULL
                                   AND service_code IN (SELECT a.service_code
                                                          FROM pr_servis_takip a,
                                                               pr_servis_takip_detay b
                                                         WHERE     a.kod =
                                                                      b.servis_takip_kodu
                                                               AND a.zorunlu =
                                                                      'E'
                                                               AND a.franchise_code =
                                                                      v_franchise_code
                                                               AND a.listeden_gizle =
                                                                      'H'
                                                               AND (   a.bitis_tarihi
                                                                          IS NULL
                                                                    OR a.bitis_tarihi >
                                                                          SYSDATE)
                                                               AND (   a.stb_tipi
                                                                          IS NULL
                                                                    OR a.stb_tipi =
                                                                          v_stb_tipi)
                                                               AND b.customer_type =
                                                                      v_uye_tipi)
                          GROUP BY campaign_code, servis_frekansi) a
                   WHERE     a.servis_frekansi <> in_servis_frekansi
                         AND (   (    a.promosyon_bitis_tarihi > a.tarih
                                  AND a.campaign_code = in_kampanya_kodu)
                              OR (    a.promosyon_bitis_tarihi <= a.tarih
                                  AND 'KMP' = in_kampanya_kodu)
                              OR (    a.promosyon_bitis_tarihi IS NULL
                                  AND a.campaign_code = in_kampanya_kodu));

                  IF v_count = 0
                  THEN
                     SELECT wiz_wo_line_wo_grup_id_seq.NEXTVAL
                       INTO v_wo_grup_id
                       FROM DUAL;
                  ELSE
                     durum :=
                        'Fiyat Bitis Tarihi Tasnnmali kampanyalarda ayni kampanya içerisinde aylik frekanslidan multi frekansli paketlere geçilemez!';
                     RETURN;
                  END IF;
               ELSE
                  v_fbt_tasinmali := TRUE;
               END IF;
            ELSE
               SELECT wiz_wo_line_wo_grup_id_seq.NEXTVAL
                 INTO v_wo_grup_id
                 FROM DUAL;
            END IF;
         END IF;
      END IF;

      FOR servis_rec IN servis_cur
      LOOP
         -- Kampanya sabit promosyon tanimli ise
         -- eklenen servisin promosyon bitis tarihini düsen servisten aliyor.
         -- sadece ayliklar için geçerli
         v_sabit_promo_end_date := NULL;
         v_sabit_fiyat_bitis_tarihi := NULL;
         v_sabit_eski_fiyat_bitis_trh := NULL;
         v_promo_end_date := NULL;
         v_promo_baglanti_id := NULL;

         --ADD IÇIN GEÇERLI, DSR IÇIN v_baglanti_id GEÇERLI
         IF     servis_rec.islem = 'ADD'
            AND servis_rec.durum = 'A'
            AND in_servis_islem_tipi = 'EKLEME'
         THEN
            v_asil_eklenecek_servis := servis_rec.service_code;
            v_durum :=
               servis_util_pack.sabit_kampanya_mi (in_kampanya_kodu,
                                                   servis_rec.tarih);
            v_sabit_kampanya := FALSE;

            IF v_durum = '1'
            THEN
               v_sabit_kampanya := TRUE;
            ELSIF v_durum = '0'
            THEN
               v_sabit_kampanya := FALSE;
            ELSE
               durum := v_durum;
               RETURN;                                         --HATA ALMisTIR
            END IF;

            IF v_sabit_kampanya
            THEN
               sabit_promosyon_tarihi (in_account_number,
                                       in_outlet_location,
                                       v_franchise_code,
                                       v_stb_tipi,
                                       v_uye_tipi,
                                       in_kampanya_kodu,
                                       servis_rec.tarih,
                                       v_promo_baglanti_id,
                                       v_tablo,
                                       durum);

               IF durum <> '0'
               THEN
                  RETURN;
               END IF;
            END IF;
         END IF;

         v_baglanti_id := NULL;
         --DSR IÇIN GEÇERLI, ADD IÇIN v_promo_baglanti_id GEÇERLI
         v_servis_frekansi := in_servis_frekansi;

         IF servis_rec.tarih IS NULL
         THEN
            durum := 'Servis islem tarihi bos olamaz!';
            RETURN;
         END IF;

         IF servis_rec.durum = 'Z'
         THEN
            v_advertise := dbs_sabit ('TRA_ADVERTISE_CODE');
         ELSE
            v_advertise := NULL;
         END IF;

         -- Eklenen servisin düsme kontrolü yapilmaktadir.
         v_ek_servis_dusuyor := FALSE;

         IF servis_rec.durum = 'D' OR servis_rec.durum = 'Z'
         THEN
            FOR ek_servis_mi_rec
               IN ek_servis_mi_cur (servis_rec.tarih,
                                    servis_rec.service_code)
            LOOP
               v_ek_servis_dusuyor := TRUE;
            END LOOP;
         END IF;

         IF servis_rec.durum = 'E' OR v_ek_servis_dusuyor
         THEN
            -- tüm eklenen veya D , Z ile düsüp öncesinde eklenen için
            v_adet := 1;
            v_servis_frekansi := servis_rec.servis_frekansi;
            v_ozel_fiyat := -999999999 / 100;
            v_bayiden_satis := NULL;
         ELSE
            -- A , D, Z için ama eklenenden dolayi olmayacak.
            v_adet := in_adet;
            v_servis_frekansi := in_servis_frekansi;
            v_ozel_fiyat := in_ozel_fiyat;
            v_bayiden_satis := in_bayiden_satis;
         END IF;                -- ADET NE OLURSA OLSUN YUMURTLAMA IÇIN ADET 1

         /* Mustafa 28.02.2006 da sabit tarihli kampanyalarda hatali çalistigi için kaldirildi
            bunun yerine sabit_promosyon_tarihi procuna tablo parametresi eklendi
                     IF in_islem_kaynak = 'NORMAL_SERVIS'
                     THEN
                        IF servis_rec.work_order_number > 0
                        THEN
                           v_tablo := 2;                                                             -- wo
                        ELSE
                           v_tablo := 1;                                                            -- svc
                        END IF;
         */
         IF in_islem_kaynak = 'DONDURMA_SERVIS'
         THEN
            v_tablo := 3;                                               -- don
         ELSIF in_islem_kaynak = 'KAPAMA_SERVIS'
         THEN
            v_tablo := 4;                                               -- sus
         END IF;

         /*
                  IF v_promo_baglanti_id IS NOT NULL
                  THEN
                     servis_promo_expire_date (v_promo_baglanti_id, v_tablo, v_sabit_promo_end_date);

                     -- Eger eklenen servisin promosyonu yok ise promosyon bitis tarihi olmamali
                     -- sadece ayliklar için geçerli
                     IF TRIM (servis_rec.promotion_code) IS NULL OR servis_rec.servis_frekansi <> '1'
                     THEN
                        v_sabit_promo_end_date := NULL;
                     --Mustafa 14.08.2006 Bu satirlar pbt geçmiste ve ayni kampanya ile tekrar ekleme yapmada pbt tekrar hesaplansin diye yazildi.
                     --Simdilik geçerli degil
                        --ELSIF TRUNC (v_sabit_promo_end_date) < TRUNC (SYSDATE)
                        --THEN
                        --   v_sabit_promo_end_date := NULL;
                     END IF;
                  END IF;
         */
         IF     v_promo_baglanti_id IS NOT NULL
            AND TRIM (servis_rec.promotion_code) IS NOT NULL
         THEN
            servis_promo_expire_date (v_promo_baglanti_id,
                                      v_tablo,
                                      v_sabit_promo_end_date,
                                      v_sabit_fiyat_bitis_tarihi,
                                      v_sabit_eski_fiyat_bitis_trh);

            IF     servis_rec.servis_frekansi <> '1'
               AND TRUNC (servis_rec.tarih) < v_sabit_promo_end_date
               AND v_sabit_fiyat_bitis_tarihi <= TRUNC (servis_rec.tarih)
            THEN
               SELECT ADD_MONTHS (v_sabit_fiyat_bitis_tarihi,
                                  billing_freq_number)
                 INTO v_sabit_fiyat_bitis_tarihi
                 FROM wiz_billing_frequency_codes
                WHERE billing_frequency = servis_rec.servis_frekansi;
            --               IF servis_rec.servis_frekansi = 'A'
            --               THEN
            --                  v_sabit_fiyat_bitis_tarihi := ADD_MONTHS (v_sabit_fiyat_bitis_tarihi, 12);
            --               ELSE
            --                  v_sabit_fiyat_bitis_tarihi := ADD_MONTHS (v_sabit_fiyat_bitis_tarihi, servis_rec.servis_frekansi);
            --               END IF;
            END IF;

            IF servis_rec.servis_frekansi = '1'
            THEN
               v_sabit_fiyat_bitis_tarihi := NULL;
               v_sabit_eski_fiyat_bitis_trh := NULL;
            ELSIF v_fbt_tasinmali = FALSE
            THEN
               v_sabit_promo_end_date := NULL;
               v_sabit_fiyat_bitis_tarihi := NULL;
               v_sabit_eski_fiyat_bitis_trh := NULL;
            END IF;
         END IF;

         IF servis_rec.durum = 'D' OR servis_rec.durum = 'Z'
         THEN
            -- düsen servislerin durumu için
            IF NOT v_ek_servis_dusuyor
            THEN
               -- eklenenin düsmesi degil
               -- düsen servisin ekleme satirinin woda mi svcdemi olduguna karar veriyor.
               FOR baglanti_rec
                  IN baglanti_cur (servis_rec.service_code,
                                   servis_rec.servis_frekansi)
               LOOP
                  IF in_islem_kaynak = 'NORMAL_SERVIS'
                  THEN
                     IF baglanti_rec.work_order_number > 0
                     THEN
                        v_tablo := 2;
                     ELSE
                        v_tablo := 1;
                     END IF;
                  END IF;                                     -- normal servis

                  v_baglanti_id := baglanti_rec.baglanti_id;
                  EXIT;
               END LOOP;

               IF v_baglanti_id IS NOT NULL AND v_baglanti_id > 0
               THEN
                  -- DÜSEN SERVISIN EKLEMESI ILE ILGILI OLAN KAYIT BULUNDU
                  servis_degerleri (v_baglanti_id,
                                    v_tablo,
                                    v_adet,
                                    v_servis_frekansi,
                                    v_ozel_fiyat,
                                    v_bayiden_satis);
                  v_bayiden_satis := in_bayiden_satis;
               ELSE
                  --EKLENIP DÜSEN SERVIS
                  v_adet := in_adet;
                  v_servis_frekansi := in_servis_frekansi;
                  v_ozel_fiyat := in_ozel_fiyat;
                  v_bayiden_satis := in_bayiden_satis;
               END IF;
            END IF;
         END IF;

         v_sebep_kodu := in_sebep_kodu;

         IF in_servis_islem_tipi = 'EKLEME'
         THEN
            IF servis_rec.durum = 'D'
            THEN
               v_sebep_kodu := 'GYS';
            ELSIF servis_rec.durum = 'Z'
            THEN
               v_sebep_kodu := 'PDS';
            END IF;
         END IF;

         --         IF v_bayiden_satis = 'H' OR v_bayiden_satis IS NULL
         --         THEN
         --            v_bayi_kodu := NULL;
         --         ELSE
         --            v_bayi_kodu := in_bayi_kodu;
         --         END IF;

         IF in_islem_kaynak = 'NORMAL_SERVIS'
         THEN
            IF v_sabit_promo_end_date IS NULL
            THEN
               v_sabit_promo_end_date := v_promo_end_date;
            END IF;

            work_order_pack.wo_line_insert_with_id (
               v_is_emri_no,
               servis_rec.service_code,
               servis_rec.islem,
               in_outlet_location,
               servis_rec.campaign_code,
               servis_rec.promotion_code,
               in_employee_code,
               v_ozel_fiyat,
               v_sebep_kodu,
               servis_rec.tarih,
               v_bayi_kodu,
               v_advertise,
               v_adet,
               v_servis_frekansi,
               v_bayiden_satis,
               in_bedelli,
               SYSDATE,
               NULL,
               NULL,
               v_sabit_fiyat_bitis_tarihi,
               v_sabit_promo_end_date,
               NULL,
               NULL,
               v_wo_grup_id,
               v_wo_line_id,
               durum,
               NULL,
               v_sabit_eski_fiyat_bitis_trh,
               cur_franchise (v_franchise_code));
            wo_number := v_is_emri_no;

            IF durum <> '0'
            THEN
               RETURN;
            END IF;

            --ogm : Taahhut uyari akislari
            IF in_taahhut_kontrollu = 'E'
            THEN
               IF TRIM (v_wiz_wo_line_list) IS NULL
               THEN
                  v_wiz_wo_line_list := v_wo_line_id;
               ELSE
                  v_wiz_wo_line_list :=
                     v_wiz_wo_line_list || ',' || v_wo_line_id;
               END IF;
            END IF;
         --/ogm
         /*Mustafa 17.10.2005 tm_servis_ek tablosu turk kullanilmiyacak.
                        IF servis_rec.islem = 'ADD' AND in_servis_islem_tipi = 'EKLEME' AND servis_rec.durum = 'A'
                        THEN
                           UPDATE TM_SERVIS_EK
                              SET wo_line_id = v_wo_line_id
                            WHERE account_number = in_account_number
                              AND outlet_location = in_outlet_location
                              AND service_code = servis_rec.service_code;
                        END IF;
         */
         END IF;

         IF     servis_rec.islem = 'ADD'
            AND in_kontrol_tipi <> 2
            AND v_bayiden_satis = 'E'
         THEN
            --Sadece kotali bayiden satisin update i burada yapiliyor.
            --Geri kalan kontrollerin hepsi servis_eklenin içerisinde
            SELECT COUNT (1)
              INTO v_count
              FROM wiz_campaign_codes
             WHERE     TRIM (campaign_sales_channel) = 2
                   AND campaign_code = in_kampanya_kodu;

            IF v_count > 0
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM bt_bayi_kota_hp_svc
                WHERE     campaign_code = in_kampanya_kodu
                      AND account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND listeden_gizle = 'H';

               IF v_count = 0
               THEN
                  SELECT aciklama
                    INTO v_uye_tip_ticari_konut
                    FROM vv_uye_tipi
                   WHERE customer_type = v_uye_tipi;

                  IF TRIM (v_uye_tip_ticari_konut) = 'TİCARİ'
                  THEN
                     SELECT aciklama
                       INTO v_kategori_aciklama
                       FROM pr_abone_ozellik a, mb_abone_ozellik b
                      WHERE     a.kod = b.abone_ozellik_kodu
                            AND b.account_number = in_account_number
                            AND a.kod_grubu = 1;
                  ELSE
                     v_kategori_aciklama := NULL;
                  END IF;

                  bayi_detay_pack.tanimli_kota_var_mi (
                     in_account_number,
                     in_kampanya_kodu,
                     servis_rec.service_code,
                     v_kategori_aciklama,
                     v_servis_frekansi,
                     v_ozel_fiyat,
                     v_bayi_kodu,
                     v_bayiden_satis,
                     v_bayi_kota_id,
                     durum);

                  IF durum <> '0'
                  THEN
                     RETURN;
                  END IF;

                  bayi_detay_pack.bt_bayi_kota_hp_svc_ins_upd (
                     NULL,
                     v_bayi_kota_id,
                     v_wo_line_id,
                     'H',
                     in_kullanici_kodu,
                     v_sebep_kodu,
                     'Servis ekleme islemi yapildi.',
                     v_kota_svc_id,
                     durum);

                  IF durum <> '0'
                  THEN
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;                                -- IF servis_rec.islem = 'ADD'

         IF in_islem_kaynak = 'DONDURMA_SERVIS'
         THEN
            SELECT id
              INTO v_ust_id
              FROM ie_uyelik_dondurma
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND durum = 'D';

            IF v_sabit_promo_end_date IS NULL
            THEN
               v_sabit_promo_end_date := v_promo_end_date;
            END IF;

            IF v_sabit_promo_end_date IS NULL
            THEN
               v_sabit_promo_end_date := TO_DATE ('01.01.0001', 'DD.MM.YYYY');
            END IF;

            close_batch_pack.ie_uyelik_don_servis_insert (
               v_ust_id,
               servis_rec.service_code,
               servis_rec.islem,
               v_adet,
               servis_rec.campaign_code,
               servis_rec.promotion_code,
               v_ozel_fiyat,
               v_sabit_promo_end_date,
               servis_rec.tarih,
               '2',
               'E',
               in_kullanici_kodu,
               SYSDATE,
               in_kullanici_kodu,
               SYSDATE,
               NULL,
               v_advertise,
               servis_rec.tarih,
               v_servis_frekansi,
               NULL,
               v_bayiden_satis,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               v_wo_grup_id,
               durum,
               NULL,
               NULL,
               NULL,
               NULL,
               cur_franchise (v_franchise_code),
               v_bayi_kodu);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;

         IF in_islem_kaynak = 'KAPAMA_SERVIS'
         THEN
            SELECT id
              INTO v_ust_id
              FROM ie_uyelik_kapama
             WHERE     account_number = in_account_number
                   AND outlet_location = in_outlet_location
                   AND durum = 'K';

            IF v_sabit_promo_end_date IS NULL
            THEN
               v_sabit_promo_end_date := v_promo_end_date;
            END IF;

            IF v_sabit_promo_end_date IS NULL
            THEN
               v_sabit_promo_end_date := TO_DATE ('01.01.0001', 'DD.MM.YYYY');
            END IF;

            uyelik_kapama_pack.ie_uyelik_kapama_servis_insert (
               v_ust_id,
               servis_rec.service_code,
               servis_rec.islem,
               v_adet,
               servis_rec.campaign_code,
               servis_rec.promotion_code,
               v_ozel_fiyat,
               v_sabit_promo_end_date,
               servis_rec.tarih,
               '2',
               'E',
               NULL,
               v_advertise,
               servis_rec.tarih,
               in_kullanici_kodu,
               SYSDATE,
               in_kullanici_kodu,
               SYSDATE,
               v_servis_frekansi,
               NULL,
               v_bayiden_satis,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               v_wo_grup_id,
               durum,
               NULL,
               NULL,
               NULL,
               NULL,
               cur_franchise (v_franchise_code),
               v_bayi_kodu);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;
      END LOOP;

      --ogm : Taahhut akislari
      IF in_taahhut_kontrollu = 'E'
      THEN
         IF TRIM (v_wiz_wo_line_list) IS NOT NULL
         THEN
            fatura.taa_taahhut_pack.abone_taahhut_kontrol (
               in_account_number,
               in_outlet_location,
               'PD',
               v_wiz_wo_line_list,
               in_kullanici_kodu,
               out_taa_uyari,
               durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;

            IF TRIM (out_taa_uyari) IS NOT NULL
            THEN
               IF yetki_pack.yetkisi_varmi (
                     in_kullanici_kodu,
                     'ISLEM_SERVIS_TAAHHUT_UYARI_GECME') = 0
               THEN
                  durum :=
                        'RAMA_SERVIS.WO_YARAT: Islem yetkiniz yok: '
                     || out_taa_uyari;
                  RETURN;
               END IF;
            END IF;
         END IF;
      END IF;

      --/ogm
      --JOBLARI EKLE
      FOR job_rec IN job_cur
      LOOP
         IF job_rec.service_code IS NOT NULL
         THEN
            IF in_islem_kaynak = 'NORMAL_SERVIS'
            THEN
               work_order_pack.wo_line_insert (
                  v_is_emri_no,
                  '   ',
                  job_rec.service_code,
                  in_outlet_location,
                  in_kampanya_kodu,
                  job_rec.promotion_code,
                  in_employee_code,
                  NULL,
                  in_sebep_kodu,
                  job_rec.tarih,
                  v_bayi_kodu,
                  NULL,
                  1,
                  '1',
                  NULL,
                  in_bedelli,
                  SYSDATE,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  durum,
                  NULL,
                  NULL,
                  cur_franchise (v_franchise_code));

               IF durum <> '0'
               THEN
                  RETURN;
               END IF;
            END IF;

            IF in_islem_kaynak = 'DONDURMA_SERVIS'
            THEN
               SELECT id
                 INTO v_ust_id
                 FROM ie_uyelik_dondurma
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND durum = 'D';

               close_batch_pack.ie_uyelik_don_servis_insert (
                  v_ust_id,
                  '   ',
                  job_rec.service_code,
                  v_adet,
                  job_rec.campaign_code,
                  job_rec.promotion_code,
                  v_ozel_fiyat,
                  TO_DATE ('01.01.0001', 'DD.MM.YYYY'),
                  job_rec.tarih,
                  '2',
                  'E',
                  in_kullanici_kodu,
                  SYSDATE,
                  in_kullanici_kodu,
                  SYSDATE,
                  NULL,
                  v_advertise,
                  job_rec.tarih,
                  v_servis_frekansi,
                  NULL,
                  v_bayiden_satis,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  durum,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  cur_franchise (v_franchise_code),
                  v_bayi_kodu);

               IF durum <> '0'
               THEN
                  RETURN;
               END IF;
            END IF;

            IF in_islem_kaynak = 'KAPAMA_SERVIS'
            THEN
               SELECT id
                 INTO v_ust_id
                 FROM ie_uyelik_kapama
                WHERE     account_number = in_account_number
                      AND outlet_location = in_outlet_location
                      AND durum = 'K';

               uyelik_kapama_pack.ie_uyelik_kapama_servis_insert (
                  v_ust_id,
                  '   ',
                  job_rec.service_code,
                  v_adet,
                  job_rec.campaign_code,
                  job_rec.promotion_code,
                  v_ozel_fiyat,
                  TO_DATE ('01.01.0001', 'DD.MM.YYYY'),
                  job_rec.tarih,
                  '2',
                  'E',
                  NULL,
                  v_advertise,
                  job_rec.tarih,
                  in_kullanici_kodu,
                  SYSDATE,
                  in_kullanici_kodu,
                  SYSDATE,
                  v_servis_frekansi,
                  NULL,
                  v_bayiden_satis,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  durum,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  cur_franchise (v_franchise_code),
                  v_bayi_kodu);

               IF durum <> '0'
               THEN
                  RETURN;
               END IF;
            END IF;
         END IF;
      END LOOP;

      IF in_hemen_kapat = 1
      THEN
         IF uye_kontrol_pack.outlet_aktif_mi (in_account_number,
                                              in_outlet_location) = 0
         THEN
            sms_yeni_kontrat_pack.mb_outlet_takip_insert (
               in_account_number,
               v_is_emri_no,
               in_outlet_location,
               dbs_sabit ('KONTRATSIZ_SERVIS_EKLEME'),
               in_kullanici_kodu,
               v_durum);

            IF v_durum <> '0'
            THEN
               durum :=
                     'PROC SMS_YENI_KONTRAT_PACK.MB_OUTLET_TAKIP_INSERT DURUM: '
                  || v_durum;
               RETURN;
            END IF;

            /* Begin ITTP Integration - MGOKSU*/
            billing_dbs_int.onl_customer_ittp_pkg.outlet_crt_sp (
               i_dbs_account_number    => in_account_number,
               i_dbs_outlet_location   => in_outlet_location,
               o_result_type           => v_result_type,
               o_result_code           => v_result_code,
               o_result_message        => v_result_message);

            IF v_result_type = 1
            THEN
               durum := v_result_message;
               RETURN;
            END IF;
         /* End ITTP Integration */
         END IF;
      END IF;

      DELETE FROM tm_ek
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;

      DELETE FROM tm_servis
            WHERE     account_number = in_account_number
                  AND outlet_location = in_outlet_location;
   /*Mustafa 17.10.2005 tm_servis_ek tablosu turk kullanilmiyacak.
         DELETE FROM TM_SERVIS_EK
               WHERE account_number = in_account_number AND outlet_location = in_outlet_location;
   */
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'WO_YARAT :' || SQLERRM;
   END wo_yarat;

   PROCEDURE ozel_servis_islem (
      in_id                 IN     NUMBER,
      in_kullanici          IN     co_kullanici.kod%TYPE,
      in_void_reason_code   IN     ie_uyelik_dondurma_servis.void_reason_code%TYPE,
      in_kaynak             IN     VARCHAR2,
      in_islem              IN     VARCHAR2,
      durum                    OUT VARCHAR2)
   IS
      -- IN_KAYNAK 'DONDURMA','KAPAMA'
      -- IN_ISLEM 'IPTAL','GERI_AL'
      CURSOR servis_cur
      IS
         SELECT 'DONDURMA' kaynak,
                id,
                job_code,
                service_code,
                beklenen_kapanma_tarihi,
                campaign_code,
                servis_frekansi,
                add_closed_date tarih,
                promotion_code,
                advertise_code,
                uyelik_dondurma_id ust_id,
                eklenecek_mi,
                add_closed_date,
                non_standard_service_rate,
                durum,
                wo_grup_id
           FROM ie_uyelik_dondurma_servis d
          WHERE id = in_id AND in_kaynak = 'DONDURMA'
         UNION
         SELECT 'KAPAMA' kaynak,
                id,
                job_code,
                service_code,
                beklenen_kapanma_tarihi,
                campaign_code,
                servis_frekansi,
                add_closed_date tarih,
                promotion_code,
                advertise_code,
                uyelik_kapama_id ust_id,
                eklenecek_mi,
                add_closed_date,
                non_standard_service_rate,
                durum,
                wo_grup_id
           FROM ie_uyelik_kapama_servis k
          WHERE id = in_id AND in_kaynak = 'KAPAMA';

      v_kayit_yok          BOOLEAN;
      v_account_number     wiz_customer_hp_life.account_number%TYPE;
      v_customer_type      wiz_customer_hp_life.customer_type%TYPE;
      v_franchise_code     wiz_customer_hp_life.franchise_code%TYPE;
      v_stb_tipi           wiz_customer_hp_life.hp_cluster%TYPE;
      v_outlet_location    ie_uyelik_kapama.outlet_location%TYPE;
      v_eklenecek_mi       ie_uyelik_kapama_servis.eklenecek_mi%TYPE;
      v_void_reason_code   ie_uyelik_dondurma_servis.void_reason_code%TYPE;
      out_aciklama         VARCHAR2 (4000);             --BURADA KULLANILMIYOR
      v_islem              CHAR (3);
      v_error_type         NUMBER;
      v_error_code         VARCHAR2 (50);
      v_satir_id           NUMBER;
      v_kayit_id           NUMBER;
      v_tablo              CHAR (1);
      v_grup_id            NUMBER;
      v_puan_kaydi         NUMBER;
      v_job_code           ie_uyelik_dondurma_servis.job_code%TYPE;
      v_campaign_code      ie_uyelik_dondurma_servis.campaign_code%TYPE;
   BEGIN
      durum := '0';
      v_kayit_yok := TRUE;

      FOR servis_rec IN servis_cur
      LOOP
         v_kayit_yok := FALSE;
         v_satir_id := servis_rec.id;
         v_kayit_id := servis_rec.ust_id;
         v_grup_id := servis_rec.wo_grup_id;
         v_job_code := servis_rec.job_code;
         v_campaign_code := servis_rec.campaign_code;

         IF servis_rec.eklenecek_mi <> 'E' AND in_islem = 'IPTAL'
         THEN
            durum := 'Kayit zaten eklenmiyecek';
            RETURN;
         END IF;

         IF servis_rec.eklenecek_mi <> 'H' AND in_islem = 'GERI_AL'
         THEN
            durum := 'Kayit zaten eklenecek';
            RETURN;
         END IF;

         IF in_islem = 'IPTAL'
         THEN
            IF servis_rec.advertise_code = dbs_sabit ('TRA_ADVERTISE_CODE')
            THEN
               durum := 'Bu satir IPTAL edilemez!';
               RETURN;
            END IF;
         END IF;

         IF in_kaynak = 'DONDURMA'
         THEN
            SELECT COUNT (*)
              INTO v_puan_kaydi
              FROM ie_uyelik_dondurma_servis d
             WHERE     EXISTS
                          (SELECT *
                             FROM ps_uye_talep_detay c
                            WHERE     EXISTS
                                         (SELECT *
                                            FROM ps_uye_talep_detay a
                                           WHERE     EXISTS
                                                        (SELECT *
                                                           FROM ie_uyelik_dondurma_servis b
                                                          WHERE     b.id =
                                                                       v_satir_id
                                                                AND a.wo_line_id =
                                                                       b.wo_line_id)
                                                 AND a.uye_talep_id =
                                                        c.uye_talep_id)
                                  AND c.wo_line_id = d.wo_line_id)
                   AND d.uyelik_dondurma_id = v_kayit_id;

            IF v_puan_kaydi > 1
            THEN
               durum :=
                     '+PUANDAN OLUSTURULMUS KAYITTA '
                  || in_islem
                  || ' ISLEMi YAPAMAZSINIZ !!!';
               RETURN;
            END IF;

            v_tablo := 'D';

            SELECT account_number, outlet_location
              INTO v_account_number, v_outlet_location
              FROM ie_uyelik_dondurma
             WHERE id = v_kayit_id;
         END IF;

         IF in_kaynak = 'KAPAMA'
         THEN
            SELECT COUNT (*)
              INTO v_puan_kaydi
              FROM ie_uyelik_kapama_servis d
             WHERE     EXISTS
                          (SELECT *
                             FROM ps_uye_talep_detay c
                            WHERE     EXISTS
                                         (SELECT *
                                            FROM ps_uye_talep_detay a
                                           WHERE     EXISTS
                                                        (SELECT *
                                                           FROM ie_uyelik_kapama_servis b
                                                          WHERE     b.id =
                                                                       v_satir_id
                                                                AND a.wo_line_id =
                                                                       b.wo_line_id)
                                                 AND a.uye_talep_id =
                                                        c.uye_talep_id)
                                  AND c.wo_line_id = d.wo_line_id)
                   AND d.uyelik_kapama_id = v_kayit_id;

            IF v_puan_kaydi > 1
            THEN
               durum :=
                     '+PUANDAN OLUSTURULMUS KAYITTA '
                  || in_islem
                  || ' ISLEMI YAPAMAZSINIZ !!!';
               RETURN;
            END IF;

            v_tablo := 'K';

            SELECT account_number, outlet_location
              INTO v_account_number, v_outlet_location
              FROM ie_uyelik_kapama
             WHERE id = v_kayit_id;
         END IF;

         --GRUP KODUNA GÖRE TOPLU IPTAL YADA GERI AL
         IF servis_rec.wo_grup_id IS NOT NULL AND servis_rec.wo_grup_id > 0
         THEN
            IF in_islem = 'IPTAL'
            THEN
               v_eklenecek_mi := 'H';
               v_void_reason_code := in_void_reason_code;
            ELSE
               v_eklenecek_mi := 'E';
               v_void_reason_code := NULL;
            END IF;

            IF in_kaynak = 'DONDURMA'
            THEN
               UPDATE ie_uyelik_dondurma_servis
                  SET eklenecek_mi = v_eklenecek_mi,
                      void_reason_code = v_void_reason_code,
                      degistiren_kullanici = in_kullanici,
                      degistirme_tarihi = SYSDATE
                WHERE     uyelik_dondurma_id = v_kayit_id
                      AND id <> v_satir_id
                      AND wo_grup_id = servis_rec.wo_grup_id;
            END IF;

            IF in_kaynak = 'KAPAMA'
            THEN
               UPDATE ie_uyelik_kapama_servis
                  SET eklenecek_mi = v_eklenecek_mi,
                      void_reason_code = v_void_reason_code,
                      degistiren_kullanici = in_kullanici,
                      degistirme_tarihi = SYSDATE
                WHERE     uyelik_kapama_id = v_kayit_id
                      AND id <> v_satir_id
                      AND wo_grup_id = servis_rec.wo_grup_id;
            END IF;
         END IF;

         SELECT customer_type, franchise_code, hp_cluster
           INTO v_customer_type, v_franchise_code, v_stb_tipi
           FROM wiz_customer_hp_life
          WHERE account_number = v_account_number;

         servis_doldur (v_account_number,
                        v_customer_type,
                        v_outlet_location,
                        servis_rec.service_code,
                        servis_rec.campaign_code,
                        servis_rec.servis_frekansi,
                        v_franchise_code,
                        servis_rec.tarih,
                        'A',
                        in_kullanici,
                        0,
                        durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;

         sf_urun_servis_kontrol (servis_rec.campaign_code,
                                 in_kullanici,
                                 durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;

         IF in_islem = 'IPTAL'
         THEN
            DELETE FROM tm_servis
                  WHERE baglanti_id = servis_rec.id;
         END IF;

         IF in_islem = 'GERI_AL'
         THEN
            INSERT INTO tm_servis (account_number,
                                   outlet_location,
                                   service_code,
                                   islem,
                                   tarih,
                                   campaign_code,
                                   durum,
                                   servis_frekansi,
                                   promotion_code)
                    VALUES (
                              v_account_number,
                              v_outlet_location,
                              servis_rec.service_code,
                              servis_rec.job_code,
                              DECODE (servis_rec.durum,
                                      1, SYSDATE - (1 / (24 * 30 * 60)),
                                      servis_rec.tarih),
                              servis_rec.campaign_code,
                              'A',
                              servis_rec.servis_frekansi,
                              servis_rec.promotion_code);
         END IF;

         v_islem := servis_rec.job_code;

         IF in_islem = 'IPTAL'
         THEN                                        --AND V_ISLEM= 'DSR' THEN
            IF servis_rec.durum = 1
            THEN                                              -- SERVIS SVC DE
               v_islem := 'DSR';
            ELSE
               v_islem := 'IPT';
            END IF;
         END IF;

         servis_durum_kontrol (v_account_number,
                               v_outlet_location,
                               servis_rec.service_code,
                               v_islem,
                               servis_rec.tarih,
                               v_customer_type,
                               v_franchise_code,
                               'DBS',
                               in_kullanici,
                               0,
                               v_error_type,
                               v_error_code,
                               out_aciklama,
                               durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;
      END LOOP;

      IF v_kayit_yok
      THEN
         durum := 'Kayit bulunamadi!';
         RETURN;
      END IF;

      IF in_islem = 'IPTAL'
      THEN
         v_eklenecek_mi := 'H';
         v_void_reason_code := in_void_reason_code;
         -- Ayni gruptaki tüm is emirleri iptal edilmelidir.
         is_emri_grup_iptal_kontrol (v_tablo,
                                     v_kayit_id,
                                     v_satir_id,
                                     v_grup_id,
                                     in_kullanici,
                                     durum);

         IF durum <> '0'
         THEN
            RETURN;
         END IF;
      ELSE
         v_eklenecek_mi := 'E';
         v_void_reason_code := NULL;
      END IF;

      IF in_kaynak = 'DONDURMA'
      THEN
         UPDATE ie_uyelik_dondurma_servis
            SET eklenecek_mi = v_eklenecek_mi,
                void_reason_code = v_void_reason_code,
                degistiren_kullanici = in_kullanici,
                degistirme_tarihi = SYSDATE
          WHERE id = in_id;

         /*--- Evren --- 20111126 -- begin ---*/
         --servise basli joblar da void a çekiliyor
         IF v_job_code = 'ADD'
         THEN
            FOR rec_ IN (SELECT id
                           FROM ie_uyelik_dondurma_servis
                          WHERE     uyelik_dondurma_id = v_kayit_id
                                AND TRIM (service_code) IS NULL
                                AND campaign_code = v_campaign_code
                                --AND li_effective_date BETWEEN v_islem_tarihi - 5/86400 AND v_islem_tarihi + 5/86400
                                AND job_code IN (SELECT product_code
                                                   FROM wiz_product_codes
                                                  WHERE product_type = 3))
            LOOP
               UPDATE ie_uyelik_dondurma_servis
                  SET eklenecek_mi = v_eklenecek_mi,
                      void_reason_code = v_void_reason_code,
                      degistiren_kullanici = in_kullanici,
                      degistirme_tarihi = SYSDATE
                WHERE id = rec_.id;
            END LOOP;
         END IF;
      /*--- Evren --- 20111126 -- end ---*/
      END IF;

      IF in_kaynak = 'KAPAMA'
      THEN
         UPDATE ie_uyelik_kapama_servis
            SET eklenecek_mi = v_eklenecek_mi,
                void_reason_code = v_void_reason_code,
                degistiren_kullanici = in_kullanici,
                degistirme_tarihi = SYSDATE
          WHERE id = in_id;

         /*--- Evren --- 20111126 -- begin ---*/
         --servise basli joblar da void a çekiliyor
         IF v_job_code = 'ADD'
         THEN
            FOR rec_ IN (SELECT id
                           FROM ie_uyelik_kapama_servis
                          WHERE     uyelik_kapama_id = v_kayit_id
                                AND TRIM (service_code) IS NULL
                                AND campaign_code = v_campaign_code
                                --AND li_effective_date BETWEEN v_islem_tarihi - 5/86400 AND v_islem_tarihi + 5/86400
                                AND job_code IN (SELECT product_code
                                                   FROM wiz_product_codes
                                                  WHERE product_type = 3))
            LOOP
               UPDATE ie_uyelik_kapama_servis
                  SET eklenecek_mi = v_eklenecek_mi,
                      void_reason_code = v_void_reason_code,
                      degistiren_kullanici = in_kullanici,
                      degistirme_tarihi = SYSDATE
                WHERE id = rec_.id;
            END LOOP;
         END IF;
      /*--- Evren --- 20111126 -- end ---*/
      END IF;

      DELETE FROM tm_ek
            WHERE     account_number = v_account_number
                  AND outlet_location = v_outlet_location;

      DELETE FROM tm_servis
            WHERE     account_number = v_account_number
                  AND outlet_location = v_outlet_location;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'OZEL_SERVIS_ISLEM:' || SQLERRM;
   END ozel_servis_islem;

   PROCEDURE outlet_kmp_var_mi (
      outlet               IN     VARCHAR2,
      account              IN     NUMBER,
      servis_in            IN     VARCHAR2,
      servis_frekansi_in   IN     wiz_customer_hp_svc.servis_frekansi%TYPE,
      durum                   OUT VARCHAR2,
      servis_out              OUT VARCHAR2,
      promo_out               OUT VARCHAR2)
   IS
      CURSOR cur_servis_sayi
      IS
           SELECT service_code, outlet_location
             FROM (SELECT service_code, 1 t, outlet_location
                     FROM wiz_customer_hp_svc
                    WHERE     account_number = account
                          AND outlet_location != outlet
                          AND service_code IN ('SIN',
                                               'SUP',
                                               'EXT',
                                               'MEG',
                                               'MGG')
                   UNION ALL
                   SELECT service_code,
                          DECODE (job_code, 'DSR', -1, 1) t,
                          outlet_location
                     FROM wiz_wo_line_items l, wiz_work_order w
                    WHERE     w.account_number = account
                          AND outlet_location != outlet
                          AND w.work_order_number = l.work_order_number
                          AND w.wo_status IN ('P', 'O')
                          AND l.wo_status = 'O'
                          AND l.job_code IN ('ADD', 'DSR')
                          AND service_code IN ('SIN',
                                               'SUP',
                                               'EXT',
                                               'MEG',
                                               'MGG'))
         GROUP BY service_code, outlet_location
           HAVING SUM (t) = 1;

      CURSOR cur_son_servis (
         p_srv    VARCHAR2,
         p_out    VARCHAR2)
      IS
           SELECT promotion_code,
                  promo_expire_date,
                  servis_frekansi,
                  v_type
             FROM (SELECT promotion_code,
                          NVL (promo_expire_date,
                               TO_DATE ('01.01.0001', 'DD.MM.YYYY'))
                             promo_expire_date,
                          servis_frekansi,
                          'SVC' v_type
                     FROM wiz_customer_hp_svc
                    WHERE     account_number = account
                          AND outlet_location = p_out
                          AND service_code = p_srv
                   UNION ALL
                   SELECT promotion_code,
                          NVL (li_effective_date,
                               TO_DATE ('01.01.0001', 'DD.MM.YYYY')),
                          servis_frekansi,
                          'WO' v_type
                     FROM wiz_wo_line_items l, wiz_work_order w
                    WHERE     w.account_number = account
                          AND w.work_order_number = l.work_order_number
                          AND w.wo_status IN ('P', 'O')
                          AND l.wo_status = 'O'
                          AND l.outlet_location = p_out
                          AND l.job_code = 'ADD'
                          AND l.service_code = p_srv)
         ORDER BY v_type DESC, promo_expire_date DESC;

      cnt_promo                 NUMBER := 0;
      cnt_promosuz              NUMBER := 0;
      v_date                    DATE;
      tmp_durum                 VARCHAR2 (1000);
      v_yillik_frekans_sayisi   NUMBER (5);
      v_billing_cycle           wiz_customer_hp_life.billing_cycle%TYPE;
   BEGIN
      durum := '1';                                    --OUTLET KAMPANYASI YOK
      RETURN;
      promo_out := NULL;
      servis_out := servis_in;
      v_yillik_frekans_sayisi := 0;

      SELECT billing_cycle
        INTO v_billing_cycle
        FROM wiz_customer_hp_life
       WHERE account_number = account;

      FOR r_sayi IN cur_servis_sayi
      LOOP
         -- Üzerinde olan servis için dönüyor Diger outlettekiler
         FOR r_son
            IN cur_son_servis (r_sayi.service_code, r_sayi.outlet_location)
         LOOP
            IF r_son.v_type = 'WO'
            THEN
               BEGIN
                  work_order_pack.promosyon_bitis_tarihi_bul (
                     v_billing_cycle,
                     r_son.servis_frekansi,
                     r_son.promotion_code,
                     r_sayi.service_code,
                     r_son.promo_expire_date,
                     v_date,
                     tmp_durum);

                  IF tmp_durum != '0'
                  THEN
                     r_son.promo_expire_date :=
                        TO_DATE ('01.01.0001', 'DD.MM.YYYY');
                  ELSE
                     r_son.promo_expire_date := v_date;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     r_son.promo_expire_date :=
                        TO_DATE ('01.01.0001', 'DD.MM.YYYY');
               END;
            END IF;

            IF TRUNC (r_son.promo_expire_date) <= TRUNC (SYSDATE)
            THEN
               cnt_promosuz := cnt_promosuz + 1;
            ELSIF    r_son.promotion_code IN ('2LT',
                                              '4LT',
                                              '2LA',
                                              '4LA',
                                              '6LT',
                                              '6LA',
                                              '379',
                                              '380')
                  OR r_son.promotion_code = 'OEX'
            THEN
               cnt_promo := cnt_promo + 1;
            END IF;

            IF r_son.servis_frekansi = 'A'
            THEN
               v_yillik_frekans_sayisi := v_yillik_frekans_sayisi + 1;
            END IF;

            EXIT;
         END LOOP;
      END LOOP;

      IF cnt_promosuz >= 1 AND cnt_promo < 2
      THEN
         durum := '0';

         IF servis_in = 'EXT' AND servis_frekansi_in <> 'A'
         THEN
            promo_out := 'OEX';
            servis_out := 'EXT';
         ELSE
            IF servis_in = 'SIN'
            THEN
               IF servis_frekansi_in = '1'
               THEN
                  promo_out := '2LT';
               ELSIF servis_frekansi_in = 'A' AND v_yillik_frekans_sayisi > 0
               THEN
                  promo_out := '2LA';
               END IF;
            ELSIF servis_in = 'SUP'
            THEN
               IF servis_frekansi_in = '1'
               THEN
                  promo_out := '4LT';
               ELSIF servis_frekansi_in = 'A' AND v_yillik_frekans_sayisi > 0
               THEN
                  promo_out := '4LA';
               END IF;
            ELSIF servis_in = 'MEG'
            THEN
               IF servis_frekansi_in = '1'
               THEN
                  promo_out := '6LT';
               ELSIF servis_frekansi_in = 'A' AND v_yillik_frekans_sayisi > 0
               THEN
                  promo_out := '6LA';
               END IF;
            ELSIF servis_in = 'MGG'
            THEN
               IF servis_frekansi_in = '1'
               THEN
                  promo_out := '379';
               ELSIF servis_frekansi_in = 'A' AND v_yillik_frekans_sayisi > 0
               THEN
                  promo_out := '380';
               END IF;
            END IF;
         END IF;
      END IF;
   END outlet_kmp_var_mi;
END;
/
