CREATE OR REPLACE PACKAGE BODY DBS_ADDR.dbs_addr_reqs_pisys_pack
AS
   /**************************************************************************************************************************************/
   FUNCTION get_paket_tms_value (
      p_serial_number           IN     wiz_equip.serial_number%TYPE,
      p_paket_tms_attribute     IN     VARCHAR2,
      p_derbisiz_filter_dusur      OUT BOOLEAN,
      p_derbisiz_filter_ekle       OUT BOOLEAN)
      RETURN NUMBER
   IS
      result                 NUMBER;
      v_dinamik_key          VARCHAR2 (100);
      v_derbili_paket_cnt    NUMBER (2) := 0;
      v_derbisiz_paket_cnt   NUMBER (2) := 0;
      b_derbili_paket_var    BOOLEAN := FALSE;
      b_derbisiz_paket_var   BOOLEAN := FALSE;
      v_sporlu_paket_cnt     NUMBER (2) := 0;

      CURSOR sporlu_urun_cur
      IS
           SELECT urun_kodu, COUNT (1) adet
             FROM (SELECT svc.service_code urun_kodu
                     FROM wiz_customer_hp_svc svc,
                          wiz_equip e,
                          (SELECT DISTINCT dcs.dbs_code
                             FROM dbs_addr_cas_services cs,
                                  dbs_addr_dbs_cas_services dcs
                            WHERE     cs.code = dcs.cas_code
                                  AND dcs.dbs_code NOT IN (SELECT COLUMN_VALUE
                                                             FROM TABLE (
                                                                     dbs_dba.split_table_fnc (
                                                                        dbs_dba.dbs_sabit (
                                                                           TRIM (
                                                                              'SPORLU_PAKETTE_HARICI_SERVISLER')))))
                                  AND cs.product_number IN (SELECT product_number
                                                              FROM dbs_addr.dbs_addr_cas_services_group
                                                             WHERE code IN (3,
                                                                            4)))
                          su
                    WHERE     svc.account_number = e.account_number
                          AND svc.outlet_location = e.outlet_location
                          AND e.converter_type = 'SC'
                          AND svc.service_code = su.dbs_code
                          AND e.serial_number = p_serial_number
                   UNION
                   SELECT oa.service_code urun_kodu
                     FROM dbs_addr_on_air_activation oa,
                          wiz_equip e,
                          (SELECT DISTINCT dcs.dbs_code
                             FROM dbs_addr_cas_services cs,
                                  dbs_addr_dbs_cas_services dcs
                            WHERE     cs.code = dcs.cas_code
                                  AND dcs.dbs_code NOT IN (SELECT COLUMN_VALUE
                                                             FROM TABLE (
                                                                     dbs_dba.split_table_fnc (
                                                                        dbs_dba.dbs_sabit (
                                                                           TRIM (
                                                                              'SPORLU_PAKETTE_HARICI_SERVISLER')))))
                                  AND cs.product_number IN (SELECT product_number
                                                              FROM dbs_addr.dbs_addr_cas_services_group
                                                             WHERE code IN (3,
                                                                            4)))
                          su
                    WHERE     oa.account_number = e.account_number
                          AND oa.outlet_location = e.outlet_location
                          AND oa.beklenen_acilma_tarihi IS NOT NULL
                          AND e.converter_type = 'SC'
                          AND oa.service_code = su.dbs_code
                          AND e.serial_number = p_serial_number
                          AND (    oa.gerceklesen_acilma_tarihi IS NOT NULL
                               AND oa.beklenen_kapanma_tarihi > SYSDATE)
                   UNION
                   SELECT oa.service_code urun_kodu
                     FROM dbs_addr_on_air_activation oa,
                          wiz_equip e,
                          (SELECT DISTINCT dcs.dbs_code
                             FROM dbs_addr_cas_services cs,
                                  dbs_addr_dbs_cas_services dcs
                            WHERE     cs.code = dcs.cas_code
                                  AND dcs.dbs_code NOT IN (SELECT COLUMN_VALUE
                                                             FROM TABLE (
                                                                     dbs_dba.split_table_fnc (
                                                                        dbs_dba.dbs_sabit (
                                                                           TRIM (
                                                                              'SPORLU_PAKETTE_HARICI_SERVISLER')))))
                                  AND cs.product_number IN (SELECT product_number
                                                              FROM dbs_addr.dbs_addr_cas_services_group
                                                             WHERE code IN (3,
                                                                            4)))
                          su
                    WHERE     oa.serial_number = e.serial_number
                          AND NVL (oa.account_number, 0) = 0
                          AND oa.outlet_location IS NULL
                          AND e.converter_type = 'SC'
                          AND oa.service_code = su.dbs_code
                          AND e.serial_number = p_serial_number
                          AND (    oa.gerceklesen_acilma_tarihi IS NOT NULL
                               AND oa.beklenen_kapanma_tarihi > SYSDATE))
         GROUP BY urun_kodu;
   BEGIN
      IF p_paket_tms_attribute = 'SPOR'
      THEN
         p_derbisiz_filter_dusur := FALSE;
         p_derbisiz_filter_ekle := FALSE;

         FOR rec IN sporlu_urun_cur
         LOOP
            --DERBILI FULL LIG TV YI ICEREN URUN KODLARI
            IF rec.adet > 0
            THEN
               BEGIN
                  SELECT COUNT (1)
                    INTO v_derbili_paket_cnt
                    FROM dbs_addr.dbs_addr_dbs_cas_services dcs,
                         dbs_addr.dbs_addr_cas_services cs
                   WHERE     cs.code = dcs.cas_code
                         AND cs.product_number IN (SELECT COLUMN_VALUE
                                                     FROM TABLE (
                                                             dbs_dba.split_table_fnc (
                                                                getdinamikkeyvalue (
                                                                   TRIM (
                                                                      'TMS_DERBILI_LIGTV_PRODUCT_LIST')))))
                         AND dcs.dbs_code NOT IN (SELECT COLUMN_VALUE
                                                    FROM TABLE (
                                                            dbs_dba.split_table_fnc (
                                                               getdinamikkeyvalue (
                                                                  TRIM (
                                                                     'TMS_DERBISIZ_LIGTV_SERVIS_LIST')))))
                         AND dcs.dbs_code = rec.urun_kodu;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               IF v_derbili_paket_cnt > 0
               THEN
                  b_derbili_paket_var := TRUE;
               END IF;

               BEGIN
                  IF (INSTR (
                         dbs_addr.getdinamikkeyvalue (
                            'TMS_DERBISIZ_LIGTV_SERVIS_LIST'),
                         rec.urun_kodu)) > 0
                  THEN
                     v_derbisiz_paket_cnt := v_derbisiz_paket_cnt + 1;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               IF v_derbisiz_paket_cnt > 0
               THEN
                  b_derbisiz_paket_var := TRUE;
               END IF;

               v_sporlu_paket_cnt := v_sporlu_paket_cnt + rec.adet; --sporlu paket sayısı
            END IF;
         END LOOP;

         IF b_derbili_paket_var AND b_derbisiz_paket_var
         THEN
            p_derbisiz_filter_dusur := TRUE;
         END IF;

         IF b_derbili_paket_var = FALSE AND b_derbisiz_paket_var = TRUE
         THEN
            p_derbisiz_filter_ekle := TRUE;
         END IF;

         result := v_sporlu_paket_cnt;
      ELSE
         --DIZILI/SINEMALI//EROTIK PAKETLERE SAHIPMI... DIYE BAKILABILIR
         v_dinamik_key := p_paket_tms_attribute || '_PRODUCT_LIST';

         SELECT SUM (adet) uye_sinemadizili_urun_adet
           INTO result
           FROM (SELECT NVL (COUNT (1), 0) adet
                   FROM wiz_customer_hp_svc svc,
                        wiz_equip e,
                        (SELECT DISTINCT dcs.dbs_code
                           FROM dbs_addr_cas_services cs,
                                dbs_addr_dbs_cas_services dcs
                          WHERE     cs.code = dcs.cas_code
                                AND cs.product_number IN (SELECT COLUMN_VALUE
                                                            FROM TABLE (
                                                                    dbs_dba.split_table_fnc (
                                                                       getdinamikkeyvalue (
                                                                          v_dinamik_key)))))
                        su
                  WHERE     svc.account_number = e.account_number
                        AND svc.outlet_location = e.outlet_location
                        AND e.converter_type = 'SC'
                        AND svc.service_code = su.dbs_code
                        AND e.serial_number = p_serial_number
                 UNION
                 SELECT NVL (COUNT (1), 0) adet
                   FROM dbs_addr_on_air_activation oa,
                        wiz_equip e,
                        (SELECT DISTINCT dcs.dbs_code
                           FROM dbs_addr_cas_services cs,
                                dbs_addr_dbs_cas_services dcs
                          WHERE     cs.code = dcs.cas_code
                                AND cs.product_number IN (SELECT COLUMN_VALUE
                                                            FROM TABLE (
                                                                    dbs_dba.split_table_fnc (
                                                                       getdinamikkeyvalue (
                                                                          v_dinamik_key)))))
                        su
                  WHERE     oa.account_number = e.account_number
                        AND oa.outlet_location = e.outlet_location
                        AND oa.beklenen_acilma_tarihi IS NOT NULL
                        AND e.converter_type = 'SC'
                        AND oa.service_code = su.dbs_code
                        AND e.serial_number = p_serial_number
                 UNION
                 SELECT NVL (COUNT (1), 0) adet
                   FROM dbs_addr_on_air_activation oa,
                        wiz_equip e,
                        (SELECT DISTINCT dcs.dbs_code
                           FROM dbs_addr_cas_services cs,
                                dbs_addr_dbs_cas_services dcs
                          WHERE     cs.code = dcs.cas_code
                                AND cs.product_number IN (SELECT COLUMN_VALUE
                                                            FROM TABLE (
                                                                    dbs_dba.split_table_fnc (
                                                                       getdinamikkeyvalue (
                                                                          v_dinamik_key)))))
                        su
                  WHERE     oa.serial_number = e.serial_number
                        AND NVL (oa.account_number, 0) = 0
                        AND oa.outlet_location IS NULL
                        AND e.converter_type = 'SC'
                        AND oa.service_code = su.dbs_code
                        AND e.serial_number = p_serial_number);
      END IF;

      IF result > 0
      THEN
         RETURN (1);                          --BELIRTILEN TURDEN PAKETE SAHIP
      ELSE
         RETURN (0);                   --BELIRTILEN TURDEN PAKETE SAHIP DEGIL;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         result := 0;
         RETURN (result);
   END get_paket_tms_value;

   /*********************************************************************************************************************************************/

   /********************************************************************************************************************/
   FUNCTION checkifexistsinhist (p_tra_id IN NUMBER, p_req_id IN NUMBER)
      RETURN NUMBER
   AS
      v_exists   NUMBER (1) := -1;
   BEGIN
      SELECT 1
        INTO v_exists
        FROM dbs_addr_pisys_reqs_hist
       WHERE tra_id = p_tra_id AND req_id = p_req_id;

      RETURN v_exists;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_exists := 0;
         RETURN v_exists;
      WHEN OTHERS
      THEN
         v_exists := 0;
         RETURN v_exists;
   END;

   /********************************************************************************************************************/
   PROCEDURE move_to_hist (p_tra_id          IN     NUMBER,
                           p_req_id          IN     NUMBER,
                           p_response_code   IN     NUMBER,
                           p_response_msg    IN     VARCHAR2,
                           p_err_str         IN     VARCHAR2,
                           p_status          IN     VARCHAR2,
                           p_session_id      IN     VARCHAR2,
                           p_sonuc              OUT NUMBER,
                           p_error              OUT VARCHAR2)
   AS
      v_exists         NUMBER (1);
      v_date_handled   DATE;
      v_response_msg   VARCHAR2 (255);
      v_err_str        VARCHAR2 (255);
   BEGIN
      p_sonuc := 1;
      p_error := NULL;
      v_exists := checkifexistsinhist (p_tra_id, p_req_id);

      IF p_response_msg IS NOT NULL
      THEN
         IF LENGTH (TRIM (p_response_msg)) > 255
         THEN
            v_response_msg := SUBSTR (TRIM (p_response_msg), 255);
         ELSE
            v_response_msg := TRIM (p_response_msg);
         END IF;
      END IF;

      IF p_err_str IS NOT NULL
      THEN
         IF LENGTH (TRIM (p_err_str)) > 255
         THEN
            v_err_str := SUBSTR (TRIM (p_err_str), 255);
         ELSE
            v_err_str := TRIM (p_err_str);
         END IF;
      END IF;

      IF v_exists <> 1
      THEN
         BEGIN
            INSERT INTO dbs_addr_pisys_reqs_hist (tra_id,
                                                  req_id,
                                                  serial_number,
                                                  account_number,
                                                  req_group_type,
                                                  req_type,
                                                  response_code,
                                                  response_msg,
                                                  system_error_msg,
                                                  status,
                                                  valid_after,
                                                  valid_before,
                                                  req_user,
                                                  req_date,
                                                  try_count,
                                                  first_handled_date,
                                                  last_handled_date,
                                                  req_param,
                                                  daemon_session_id,
                                                  req_dbs_type,
                                                  is_ird)
               SELECT tra_id,
                      req_id,
                      serial_number,
                      account_number,
                      req_group_type,
                      req_type,
                      p_response_code,
                      v_response_msg,
                      v_err_str,
                      p_status,
                      valid_after,
                      valid_before,
                      req_user,
                      req_date,
                      1,
                      SYSDATE,
                      SYSDATE,
                      req_param,
                      p_session_id,
                      req_dbs_type,
                      is_ird
                 FROM dbs_addr_pisys_reqs
                WHERE tra_id = p_tra_id AND req_id = p_req_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               UPDATE dbs_addr_pisys_reqs_hist
                  SET response_code = p_response_code,
                      response_msg = v_response_msg,
                      system_error_msg = v_err_str,
                      status = p_status,
                      try_count = try_count + 1,
                      last_handled_date = SYSDATE,
                      daemon_session_id = p_session_id
                WHERE tra_id = p_tra_id AND req_id = p_req_id;
         END;
      ELSE
         UPDATE dbs_addr_pisys_reqs_hist
            SET response_code = p_response_code,
                response_msg = v_response_msg,
                system_error_msg = v_err_str,
                status = p_status,
                try_count = try_count + 1,
                last_handled_date = SYSDATE,
                daemon_session_id = p_session_id
          WHERE tra_id = p_tra_id AND req_id = p_req_id;
      END IF;

      DELETE FROM dbs_addr_pisys_reqs
            WHERE tra_id = p_tra_id AND req_id = p_req_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_sonuc := 0;
         p_error := 'PROC-ERROR:' || SQLERRM;
   END;

   /********************************************************************************************************************/
   PROCEDURE move_to_hist (p_tra_id          IN NUMBER,
                           p_req_id          IN NUMBER,
                           p_response_code   IN NUMBER,
                           p_response_msg    IN VARCHAR2,
                           p_err_str         IN VARCHAR2,
                           p_status          IN VARCHAR2,
                           p_session_id      IN VARCHAR2,
                           p_send_date       IN DATE,
                           p_resp_date       IN DATE,
                           p_duration        IN NUMBER,
                           p_is_last_try     IN VARCHAR2)
   AS
      v_exists         NUMBER (1);
      v_date_handled   DATE;
      v_response_msg   VARCHAR2 (255);
      v_err_str        VARCHAR2 (255);
   BEGIN
      v_exists := checkifexistsinhist (p_tra_id, p_req_id);

      IF p_response_msg IS NOT NULL
      THEN
         IF LENGTH (TRIM (p_response_msg)) > 255
         THEN
            v_response_msg := SUBSTR (TRIM (p_response_msg), 255);
         ELSE
            v_response_msg := TRIM (p_response_msg);
         END IF;
      END IF;

      IF p_err_str IS NOT NULL
      THEN
         IF LENGTH (TRIM (p_err_str)) > 255
         THEN
            v_err_str := SUBSTR (TRIM (p_err_str), 255);
         ELSE
            v_err_str := TRIM (p_err_str);
         END IF;
      END IF;

      IF v_exists <> 1
      THEN
         BEGIN
            INSERT INTO dbs_addr_pisys_reqs_hist (tra_id,
                                                  req_id,
                                                  serial_number,
                                                  account_number,
                                                  req_group_type,
                                                  req_type,
                                                  response_code,
                                                  response_msg,
                                                  system_error_msg,
                                                  status,
                                                  valid_after,
                                                  valid_before,
                                                  req_user,
                                                  req_date,
                                                  try_count,
                                                  first_handled_date,
                                                  last_handled_date,
                                                  req_param,
                                                  daemon_session_id,
                                                  req_dbs_type,
                                                  is_ird,
                                                  read_date,
                                                  send_date,
                                                  resp_date,
                                                  duration)
               SELECT tra_id,
                      req_id,
                      serial_number,
                      account_number,
                      req_group_type,
                      req_type,
                      p_response_code,
                      v_response_msg,
                      v_err_str,
                      p_status,
                      valid_after,
                      valid_before,
                      req_user,
                      req_date,
                      1,
                      SYSDATE,
                      SYSDATE,
                      req_param,
                      p_session_id,
                      req_dbs_type,
                      is_ird,
                      read_date,
                      p_send_date,
                      p_resp_date,
                      p_duration
                 FROM dbs_addr_pisys_reqs
                WHERE tra_id = p_tra_id AND req_id = p_req_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               UPDATE dbs_addr_pisys_reqs_hist
                  SET response_code = p_response_code,
                      response_msg = v_response_msg,
                      system_error_msg = v_err_str,
                      status = p_status,
                      try_count = try_count + 1,
                      last_handled_date = SYSDATE,
                      daemon_session_id = p_session_id,
                      send_date = p_send_date,
                      resp_date = p_resp_date,
                      duration = p_duration
                WHERE tra_id = p_tra_id AND req_id = p_req_id;
         END;
      ELSE
         UPDATE dbs_addr_pisys_reqs_hist
            SET response_code = p_response_code,
                response_msg = v_response_msg,
                system_error_msg = v_err_str,
                status = p_status,
                try_count = try_count + 1,
                last_handled_date = SYSDATE,
                daemon_session_id = p_session_id,
                send_date = p_send_date,
                resp_date = p_resp_date,
                duration = p_duration
          WHERE tra_id = p_tra_id AND req_id = p_req_id;
      END IF;

      IF p_is_last_try = 'E'
      THEN
         DELETE FROM dbs_addr_pisys_reqs
               WHERE tra_id = p_tra_id AND req_id = p_req_id;
      END IF;
   END;

   /********************************************************************************************************************/

   FUNCTION get_req_type_group (p_req_type IN NUMBER)
      RETURN NUMBER
   AS
      v_req_type_group   NUMBER;
   BEGIN
      SELECT t.message_group
        INTO v_req_type_group
        FROM dbs_addr_pisys_msg_groups g, dbs_addr_pisys_msg_types t
       WHERE     t.message_type_code = p_req_type
             AND g.group_code = t.message_group;

      RETURN v_req_type_group;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION get_rating_date_time (p_rating_date_time   OUT VARCHAR2,
                                  p_errm               OUT VARCHAR2)
      RETURN NUMBER
   AS
      v_seq_id   NUMBER (5);
      vpvr       VARCHAR2 (1);
   BEGIN
      SELECT seq_dm_report_date_time_lookup.NEXTVAL INTO v_seq_id FROM DUAL;

      -- dbms_output.put_line('v_seq_id = ' || to_char(v_seq_id) );

      SELECT report_date_time
        INTO p_rating_date_time
        FROM dbs_addr_dmdt_lookup
       WHERE cycled_seq_id = v_seq_id;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION pair_chipset (p_req_dbs_type    IN     VARCHAR2,
                          p_serial_number   IN     VARCHAR2,
                          p_chipset         IN     VARCHAR2,
                          p_valid_after     IN     DATE,
                          p_req_user        IN     VARCHAR2,
                          p_tra_id             OUT NUMBER,
                          p_errm               OUT VARCHAR2)
      RETURN NUMBER
   AS
      /* ÖNEMLI :*/
      -- Teorik olarak her çip sinirsiz sayida Smart Card ile PAIR edilebilir.
      -- Her Smart Card ise sinirli sayida çip ile PAIR edilebilir. Bu sinir 1-3 arasinda degisebilir ve PISys'den ayarlanir.
      /*          */
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_pair_chipset; --16;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_chipset           VARCHAR2 (20);
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   --exc_id                 NUMBER;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_chipset) != 8
      THEN
         p_errm := 'Chipset hatali!';
         RAISE input_exception;
      ELSE
         v_chipset := TRIM (dbms_numsystem_package.hex2dec (p_chipset));
      END IF;

      SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;

      v_req_param := v_chipset;

      log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                v_account_number, --p_account_number       number,
                                NULL,         --p_prospect_number      number,
                                NULL,         --p_service_address_id   number,
                                NULL,       --p_equip_location_code  varchar2,
                                p_req_user, --p_kisi                  varchar2,
                                v_req_date,  --p_islem_tarihi            date,
                                p_req_dbs_type, --p_islem_tipi           number,
                                NULL,         --p_ppv_kredi_limiti     number,
                                NULL,         --p_msg_account_number   number,
                                NULL,       --p_msg_serial_number    varchar2,
                                NULL,       --p_mesaj_metni          varchar2,
                                NULL, --p_channel_map_1          lg_mesaj_takip.channel_map_1%type,
                                NULL, --p_channel_map_2          lg_mesaj_takip.channel_map_2%type,
                                NULL, --p_channel_map_3          lg_mesaj_takip.channel_map_3%type,
                                NULL, --p_channel_map_4          lg_mesaj_takip.channel_map_4%type,
                                NULL,                                    --gca
                                p_tra_id, --out                     lg_mesaj_takip.id%type,
                                v_durum);

      IF v_durum <> '0'
      THEN
         p_errm := v_durum;
         RAISE log_exception;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (p_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         /*
         BEGIN
              SELECT PISYS_INPUT_EXCEPTION_LOG_SEQ.NEXTVAL INTO exc_id FROM dual;
              INSERT INTO PISYS_INPUT_EXCEPTION_LOG ( ID,
                                                           REQ_DBS_TYPE,
                                                      REQ_GROUP_TYPE,
                                                      REQ_TYPE,
                                                      ACCOUNT_NUMBER,
                                                      SERIAL_NUMBER,
                                                         ERROR) VALUES
                                                    ( exc_id,
                                                         p_req_dbs_type,
                                                      v_req_group_type,
                                                      v_req_type,
                                                      v_account_number,
                                                      p_serial_number,
                                                      p_errm );
              INSERT INTO EXC_PAIR_CHIPSET (ID, CHIPSET) VALUES (exc_id, p_chipset);
         EXCEPTION WHEN OTHERS THEN
              p_errm     := SQLERRM;
         END;*/
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION unpair_chipset (p_req_dbs_type    IN     VARCHAR2,
                            p_serial_number   IN     VARCHAR2,
                            p_chipset         IN     VARCHAR2,
                            p_valid_after     IN     DATE,
                            p_req_user        IN     VARCHAR2,
                            p_tra_id             OUT NUMBER,
                            p_errm               OUT VARCHAR2)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_unpair_chipset; --25;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_chipset           VARCHAR2 (20);
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   --exc_id                 NUMBER;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_chipset) != 8
      THEN
         p_errm := 'Chipset No hatali!';
         RAISE input_exception;
      ELSE
         v_chipset := TRIM (dbms_numsystem_package.hex2dec (p_chipset));
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;

      v_req_param := v_chipset;
      log_pack.log_mesaj_takip (p_serial_number, --p_serial_number           varchar2,
                                v_account_number, --p_account_number          number,
                                NULL,        --p_prospect_number       number,
                                NULL,        --p_service_address_id    number,
                                NULL,      --p_equip_location_code   varchar2,
                                p_req_user, --p_kisi                    varchar2,
                                v_req_date,    --p_islem_tarihi          date,
                                p_req_dbs_type, --p_islem_tipi            number,
                                NULL,        --p_ppv_kredi_limiti      number,
                                NULL,        --p_msg_account_number    number,
                                NULL,      --p_msg_serial_number     varchar2,
                                NULL,    --p_mesaj_metni             varchar2,
                                NULL, --p_channel_map_1         lg_mesaj_takip.channel_map_1%type,
                                NULL, --p_channel_map_2         lg_mesaj_takip.channel_map_2%type,
                                NULL, --p_channel_map_3         lg_mesaj_takip.channel_map_3%type,
                                NULL, --p_channel_map_4         lg_mesaj_takip.channel_map_4%type,
                                NULL,                                    --gca
                                p_tra_id, --                        out   lg_mesaj_takip.id%type,
                                v_durum);

      IF v_durum <> '0'
      THEN
         p_errm := v_durum;
         RAISE log_exception;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (p_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN

         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION set_debit_limit (
      p_req_dbs_type           IN     VARCHAR2,
      p_serial_number          IN     VARCHAR2,
      p_prev_credits           IN     VARCHAR2,
      p_curr_credits           IN     VARCHAR2,
      p_valid_after            IN     DATE,
      p_req_user               IN     VARCHAR2,
      p_tra_id                 IN OUT NUMBER,
      p_errm                      OUT VARCHAR2,
      p_logla                  IN     CHAR DEFAULT 'E',
      p_req_id                 IN     NUMBER DEFAULT NULL,
      p_chk_acc_out_f_signal   IN     CHAR DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_set_debit_limit; --23;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000) := NULL;
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      v_prev_credits      NUMBER;
      v_curr_credits      NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF     (p_chk_acc_out_f_signal IS NULL OR p_chk_acc_out_f_signal = 'E')
         AND TO_NUMBER (p_curr_credits) <> 0
      THEN
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);
      ELSE
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   FALSE,
                                   FALSE);
      END IF;

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL 
		 INTO v_req_id 
		 FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_prev_credits := TO_NUMBER (p_prev_credits) / 500;

      IF (TO_NUMBER (p_curr_credits) = 99999999)
      THEN
         v_curr_credits := 99999;                        --means do not change
      ELSE
         v_curr_credits := TO_NUMBER (p_curr_credits) / 500;
      END IF;

      IF v_curr_credits IS NULL
      THEN
         v_curr_credits := 0;
      END IF;

      v_req_param := TO_CHAR (v_curr_credits);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   p_curr_credits, --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,     --p_mesaj_metni         varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                   lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      IF v_prev_credits != v_curr_credits AND v_curr_credits != 99999
      THEN
         INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                          req_id,
                                          serial_number,
                                          account_number,
                                          req_dbs_type,
                                          req_group_type,
                                          req_type,
                                          req_user,
                                          req_date,
                                          valid_after,
                                          req_param)
              VALUES (v_tra_id,
                      v_req_id,
                      p_serial_number,
                      v_account_number,
                      p_req_dbs_type,
                      v_req_group_type,
                      v_req_type,
                      p_req_user,
                      v_req_date,
                      p_valid_after,
                      v_req_param);
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION create_tms_attributes (
      p_req_dbs_type         IN     VARCHAR2,
      p_serial_number        IN     VARCHAR2,
      p_tms_attribute_list   IN     VARCHAR2,
      p_valid_after          IN     DATE,
      p_req_user             IN     VARCHAR2,
      p_tra_id               IN OUT NUMBER,
      p_errm                    OUT VARCHAR2,
      p_logla                IN     CHAR DEFAULT 'E')
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_create_tms_attributes;      --31;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_tra_id            NUMBER;
      v_durum             VARCHAR2 (400);
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;

      v_req_param := p_tms_attribute_list;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number           varchar2,
                                   v_account_number, --p_account_number             number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,   --p_service_address_id      number,
                                   NULL, --p_equip_location_code     varchar2,
                                   p_req_user, --p_kisi                    varchar2,
                                   v_req_date, --p_islem_tarihi               date,
                                   p_req_dbs_type, --p_islem_tipi                 number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,   --p_msg_account_number      number,
                                   NULL, --p_msg_serial_number       varchar2,
                                   NULL, --p_mesaj_metni             varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                        lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION create_sector (p_req_dbs_type    IN     VARCHAR2,
                           p_serial_number   IN     VARCHAR2,
                           p_nationality     IN     VARCHAR2,
                           p_region          IN     VARCHAR2,
                           p_product_list    IN     VARCHAR2,
                           p_valid_after     IN     DATE,
                           p_req_user        IN     VARCHAR2,
                           p_tra_id          IN OUT NUMBER,
                           p_errm               OUT VARCHAR2,
                           p_logla           IN     CHAR DEFAULT 'E')
      RETURN NUMBER
   AS
      /* karttaki yetkileri silmeden yeni product bilgilerini gonderir */
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_create_sector; --71;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_tra_id            NUMBER;
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_nationality IS NULL OR LENGTH (p_nationality) > 3
      THEN
         p_errm := 'Nationality hatali!';
         RAISE input_exception;
      END IF;

      IF p_region IS NULL OR LENGTH (p_region) > 2
      THEN
         p_errm := 'Region hatali!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;

      v_req_param := p_nationality || '|' || p_region || '|' || p_product_list;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                    varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                      lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION overwrite_sector (p_req_dbs_type    IN     VARCHAR2,
                              p_serial_number   IN     VARCHAR2,
                              p_nationality     IN     VARCHAR2,
                              p_region          IN     VARCHAR2,
                              p_product_list    IN     VARCHAR2,
                              p_valid_after     IN     DATE,
                              p_req_user        IN     VARCHAR2,
                              p_tra_id          IN OUT NUMBER,
                              p_errm               OUT VARCHAR2,
                              p_logla           IN     CHAR DEFAULT 'E')
      RETURN NUMBER
   AS
      /* ÖNEMLI :*/
      -- Product bilgisi belirtmeden gönderildiginde karttaki OPPV de dahil tüm yetkileri siler.
      -- Overwrite Sector mesajiyla karttaki Pairing bilgisi silinmez
      /*          */
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_overwrite_sector; --73;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_tra_id            NUMBER;
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_nationality IS NULL OR LENGTH (p_nationality) > 3
      THEN
         p_errm := 'Nationality hatali!';
         RAISE input_exception;
      END IF;

      IF p_region IS NULL OR LENGTH (p_region) > 2
      THEN
         p_errm := 'Region hatali!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;

      v_req_param := p_nationality || '|' || p_region || '|' || p_product_list;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                    varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                      lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION delete_all_entitlements (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_delete_all_entitlements;    --60;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := NULL;

      IF v_account_number IS NULL
      THEN
         v_account_number := 0;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number          number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1         lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2         lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3         lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4         lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION delete_entitlements (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_product_list    IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL,
      p_is_voucher      IN     CHAR DEFAULT 'H')
      RETURN NUMBER
   AS
      /* ÖNEMLI :*/
      -- Karttan sadece belirtilen product i siler, digerlerini ezmez.
      /*          */
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF p_is_voucher = 'E'
      THEN
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_delete_voucher_entitlement; --107;
      ELSE
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_delete_entitlements; --62;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_product_list;

      IF v_account_number IS NULL
      THEN
         v_account_number := 0;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number         number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,   --p_msg_account_number      number,
                                   NULL, --p_msg_serial_number       varchar2,
                                   NULL, --p_mesaj_metni             varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION create_entitlements (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_product_list    IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      /* ÖNEMLI :*/
      -- Kartta bulunan yetkileri ezmez.
      /*          */
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_create_entitlements; --59;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_product_list IS NULL
      THEN
         p_errm := 'Product Listesi Bos Olamaz!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_product_list;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION swap_secure_clients (
      p_req_dbs_type        IN     VARCHAR2,
      p_serial_number       IN     VARCHAR2,
      p_new_serial_number   IN     VARCHAR2,
      p_valid_after         IN     DATE,
      p_req_user            IN     VARCHAR2,
      p_tra_id              IN OUT NUMBER,
      p_errm                   OUT VARCHAR2,
      p_logla               IN     CHAR DEFAULT 'E',
      p_req_id              IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_swap_secure_clients; --94
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_new_serial_number) != 11
      THEN
         p_errm := 'Swap edilecek Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_new_serial_number;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE input_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION overwrite_entitlements (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_product_list    IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_overwrite_entitlements;      --63
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      /* Product Listesi Bos Gönderilirse Tüm Productlari siler*/
      /*
      IF p_product_list IS NULL THEN
         p_errm     := 'Product Listesi Bos Olamaz!';
         -- IF the command IS sent without specifying ANY products, ALL CURRENT ones
         -- will NOT be available AND the secure client will NOT have ANY active products
         -- (ALL services will be scrambled, IF UNDER conditional ACCESS).
         RAISE INPUT_EXCEPTION;
      END IF;
      */
      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_product_list;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,        --p_prospect_number    number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                   varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,  --p_mesaj_metni            varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                      lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   PROCEDURE calc_add_cancel_products (
      p_prev_channel_map_1     IN     NUMBER,
      p_prev_channel_map_2     IN     NUMBER,
      p_prev_channel_map_3     IN     NUMBER,
      p_prev_channel_map_4     IN     NUMBER,
      p_curr_channel_map_1     IN     NUMBER,
      p_curr_channel_map_2     IN     NUMBER,
      p_curr_channel_map_3     IN     NUMBER,
      p_curr_channel_map_4     IN     NUMBER,
      o_add_product_codes         OUT VARCHAR2,
      o_cancel_product_codes      OUT VARCHAR2,
      p_errm                      OUT VARCHAR2)
   AS
      TYPE dbs_svc_type IS RECORD
      (
         service_id        VARCHAR2 (4),
         tier              NUMBER (5),
         t_ch_map_id       NUMBER (10) DEFAULT 0,
         t_ch_map_bit      NUMBER (10) DEFAULT 0,
         t_first_pointer   NUMBER (5) DEFAULT -1,
         t_last_pointer    NUMBER (5) DEFAULT -1
      );

      TYPE dbs_arr_type IS TABLE OF dbs_svc_type
         INDEX BY BINARY_INTEGER;

      dbs_arr                  dbs_arr_type;

      TYPE cas_svc_type IS RECORD
      (
         service_id       VARCHAR2 (4),
         product_number   NUMBER (8)
      );

      TYPE cas_arr_type IS TABLE OF cas_svc_type
         INDEX BY BINARY_INTEGER;

      cas_arr                  cas_arr_type;

      TYPE dbs_cas_svc_type IS RECORD
      (
         dbs_code        VARCHAR2 (3),
         cas_code        VARCHAR2 (4),
         t_cas_pointer   NUMBER (5) DEFAULT 0
      );

      TYPE dbs_cas_arr_type IS TABLE OF dbs_cas_svc_type
         INDEX BY BINARY_INTEGER;

      dbs_cas_arr              dbs_cas_arr_type;

      TYPE cas_svc_arr_type IS TABLE OF dbs_addr_cas_services%ROWTYPE
         INDEX BY BINARY_INTEGER;

      cas_svc_arr_data         cas_svc_arr_type;

      TYPE dbs_svc_arr_type IS TABLE OF dbs_addr_dbs_services%ROWTYPE
         INDEX BY BINARY_INTEGER;

      dbs_svc_arr_data         dbs_svc_arr_type;

      TYPE dbs_cas_svc_arr_type IS TABLE OF dbs_addr_dbs_cas_services%ROWTYPE
         INDEX BY BINARY_INTEGER;

      dbs_cas_svc_arr_data     dbs_cas_svc_arr_type;

      TYPE prev_entitlements_arr_type IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      prev_entitlements_arr    prev_entitlements_arr_type;

      TYPE curr_entitlements_arr_type IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      curr_entitlements_arr    curr_entitlements_arr_type;

      TYPE prev_ch_map_arr_type IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      prev_ch_map_arr          prev_ch_map_arr_type;

      TYPE curr_ch_map_arr_type IS TABLE OF NUMBER
         INDEX BY BINARY_INTEGER;

      curr_ch_map_arr          curr_ch_map_arr_type;
      v_channel_map_id         NUMBER;
      v_channel_map_bit        NUMBER;
      v_service_id             VARCHAR2 (4);
      v_count_dbs              NUMBER;
      v_count_cas              NUMBER;
      v_count_dbs_cas          NUMBER;
      v_kont                   NUMBER;
      v_add_product_codes      NUMBER (8);
      v_cancel_product_codes   NUMBER (8);
      v_index                  NUMBER;
      v_bit_prev               NUMBER;
      v_bit_curr               NUMBER;
      v_prev                   NUMBER;
      v_curr                   NUMBER;
      v_ind                    NUMBER;
      v_temp_n                 NUMBER;

      v_temp_s                 VARCHAR2 (100);
      v_temp_s1                VARCHAR2 (100);
   BEGIN
      o_add_product_codes := '';
      o_cancel_product_codes := '';
      prev_ch_map_arr (0) := p_prev_channel_map_1;
      prev_ch_map_arr (1) := p_prev_channel_map_2;
      prev_ch_map_arr (2) := p_prev_channel_map_3;
      prev_ch_map_arr (3) := p_prev_channel_map_4;
      curr_ch_map_arr (0) := p_curr_channel_map_1;
      curr_ch_map_arr (1) := p_curr_channel_map_2;
      curr_ch_map_arr (2) := p_curr_channel_map_3;
      curr_ch_map_arr (3) := p_curr_channel_map_4;

      SELECT COUNT (1) INTO v_count_cas FROM dbs_addr_cas_services;

      SELECT COUNT (1) INTO v_count_dbs FROM dbs_addr_dbs_services;

      SELECT COUNT (1) INTO v_count_dbs_cas FROM dbs_addr_dbs_cas_services;

      --SELECT * BULK COLLECT INTO CAS_SVC_ARR_DATA FROM DBS_ADDR_CAS_SERVICES;
      --SELECT * BULK COLLECT INTO DBS_SVC_ARR_DATA FROM DBS_ADDR_DBS_SERVICES;
      --SELECT * BULK COLLECT INTO DBS_CAS_SVC_ARR_DATA FROM DBS_ADDR_DBS_CAS_SERVICES;

      --BEGIN - construct static arrays
      v_index := 0;

      FOR rec IN (SELECT * FROM dbs_addr_cas_services)
      LOOP
         cas_svc_arr_data (v_index).code := rec.code;
         cas_svc_arr_data (v_index).product_number := rec.product_number;
         v_index := v_index + 1;
      END LOOP;

      v_index := 0;

      FOR rec IN (SELECT * FROM dbs_addr_dbs_services)
      LOOP
         dbs_svc_arr_data (v_index).code := rec.code;
         dbs_svc_arr_data (v_index).tier := rec.tier;
         v_index := v_index + 1;
      END LOOP;

      v_index := 0;

      FOR rec IN (  SELECT *
                      FROM dbs_addr_dbs_cas_services
                  ORDER BY dbs_code)
      LOOP
         dbs_cas_svc_arr_data (v_index).dbs_code := rec.dbs_code;
         dbs_cas_svc_arr_data (v_index).cas_code := rec.cas_code;
         v_index := v_index + 1;
      END LOOP;

      v_index := 0;

      --END - construct static arrays

      --BEGIN - construct dynamic arrays
      FOR v_index IN 0 .. v_count_dbs - 1                                 --59
      LOOP
         dbs_arr (v_index).service_id := dbs_svc_arr_data (v_index).code;
         dbs_arr (v_index).tier := dbs_svc_arr_data (v_index).tier;
         dbs_arr (v_index).t_ch_map_id :=
            TRUNC ( ( (dbs_svc_arr_data (v_index).tier - 1) / 32), 0);
         dbs_arr (v_index).t_ch_map_bit :=
            (dbs_svc_arr_data (v_index).tier - 1) MOD 32;
         dbs_arr (v_index).t_first_pointer := -1;
         dbs_arr (v_index).t_last_pointer := -1;
      END LOOP;

      FOR v_index IN 0 .. v_count_cas - 1                                 --37
      LOOP
         cas_arr (v_index).service_id := cas_svc_arr_data (v_index).code;
         cas_arr (v_index).product_number :=
            cas_svc_arr_data (v_index).product_number;
      END LOOP;

      FOR v_index IN 0 .. v_count_dbs_cas - 1                            --165
      LOOP
         dbs_cas_arr (v_index).dbs_code :=
            dbs_cas_svc_arr_data (v_index).dbs_code;
         dbs_cas_arr (v_index).cas_code :=
            dbs_cas_svc_arr_data (v_index).cas_code;
         dbs_cas_arr (v_index).t_cas_pointer := 0;
      END LOOP;

      --END - construct dynamic arrays

      --BEGIN - init services
      FOR i IN 0 .. v_count_dbs - 1
      LOOP
         FOR j IN 0 .. v_count_dbs_cas - 1
         LOOP
            IF dbs_arr (i).service_id = dbs_cas_arr (j).dbs_code
            THEN
               IF (   j < dbs_arr (i).t_first_pointer
                   OR dbs_arr (i).t_first_pointer = -1)
               THEN
                  dbs_arr (i).t_first_pointer := j;
               END IF;

               IF (   j > dbs_arr (i).t_last_pointer
                   OR dbs_arr (i).t_last_pointer = -1)
               THEN
                  dbs_arr (i).t_last_pointer := j;
               END IF;
            END IF;
         END LOOP;
      END LOOP;

      FOR i IN 0 .. v_count_cas - 1
      LOOP
         --v_temp_s  := CAS_ARR(i).SERVICE_ID;
         FOR j IN 0 .. v_count_dbs_cas - 1
         LOOP
            --v_temp_s1 := DBS_CAS_ARR(j).CAS_CODE;
            IF cas_arr (i).service_id = dbs_cas_arr (j).cas_code
            THEN
               dbs_cas_arr (j).t_cas_pointer := i;
            END IF;
         END LOOP;
      END LOOP;

      /*see the results*/
      /*
      FOR j IN DBS_ARR.FIRST..DBS_ARR.LAST
         LOOP
            DBMS_OUTPUT.PUT_LINE('DBS_ARR(j).SERVICE_ID:'||DBS_ARR(j).SERVICE_ID);
            DBMS_OUTPUT.PUT_LINE('DBS_ARR(j).TIER:'||DBS_ARR(j).TIER);
            DBMS_OUTPUT.PUT_LINE('DBS_ARR(j).t_ch_map_id:'||DBS_ARR(j).t_ch_map_id);
            DBMS_OUTPUT.PUT_LINE('DBS_ARR(j).t_ch_map_bit:'||DBS_ARR(j).t_ch_map_bit);
            DBMS_OUTPUT.PUT_LINE('DBS_ARR(j).t_first_pointer:'||DBS_ARR(j).t_first_pointer);
            DBMS_OUTPUT.PUT_LINE('DBS_ARR(j).t_last_pointer:'||DBS_ARR(j).t_last_pointer);
         END LOOP;
        */
      /*
      FOR j IN DBS_CAS_ARR.FIRST..DBS_CAS_ARR.LAST
          LOOP
            DBMS_OUTPUT.PUT_LINE('DBS_CAS_ARR(j).DBS_CODE:'||DBS_CAS_ARR(j).DBS_CODE);
            DBMS_OUTPUT.PUT_LINE('DBS_CAS_ARR(j).CAS_CODE:'||DBS_CAS_ARR(j).CAS_CODE);
            DBMS_OUTPUT.PUT_LINE('DBS_CAS_ARR(j).t_cas_pointer:'||DBS_CAS_ARR(j).t_cas_pointer);
         END LOOP;
        */
      --END - init services
      FOR i IN 0 .. v_count_cas - 1
      LOOP
         prev_entitlements_arr (i) := 0;
         curr_entitlements_arr (i) := 0;
      END LOOP;

      FOR i IN 0 .. v_count_dbs - 1
      LOOP
         v_service_id := dbs_arr (i).service_id;
         v_channel_map_id := dbs_arr (i).t_ch_map_id;
         v_channel_map_bit := dbs_arr (i).t_ch_map_bit;

         SELECT BITAND (POWER (2, v_channel_map_bit),
                        prev_ch_map_arr (v_channel_map_id))
           INTO v_bit_prev
           FROM DUAL;

         SELECT BITAND (POWER (2, v_channel_map_bit),
                        curr_ch_map_arr (v_channel_map_id))
           INTO v_bit_curr
           FROM DUAL;

         IF v_bit_prev = POWER (2, v_channel_map_bit)
         THEN
            v_kont := dbs_arr (i).t_first_pointer;

            LOOP
               v_ind := dbs_cas_arr (v_kont).t_cas_pointer;
               prev_entitlements_arr (dbs_cas_arr (v_kont).t_cas_pointer) := 1;
               v_kont := v_kont + 1;
               --DBMS_OUTPUT.PUT_LINE('prev -'||v_kont||'-:'||PREV_ENTITLEMENTS_ARR(DBS_CAS_ARR(v_kont).t_cas_pointer));
               EXIT WHEN v_kont > dbs_arr (i).t_last_pointer;
            END LOOP;
         END IF;

         IF v_bit_curr = POWER (2, v_channel_map_bit)
         THEN
            v_kont := dbs_arr (i).t_first_pointer;

            LOOP
               v_ind := dbs_cas_arr (v_kont).t_cas_pointer;
               curr_entitlements_arr (dbs_cas_arr (v_kont).t_cas_pointer) := 1;
               --DBMS_OUTPUT.PUT_LINE('curr -'||v_kont||'-:'||CURR_ENTITLEMENTS_ARR(DBS_CAS_ARR(v_kont).t_cas_pointer));
               v_kont := v_kont + 1;
               EXIT WHEN v_kont > dbs_arr (i).t_last_pointer;
            END LOOP;
         END IF;
      END LOOP;

      /*see the results*/
      /*
      FOR i IN PREV_ENTITLEMENTS_ARR.FIRST..PREV_ENTITLEMENTS_ARR.LAST
        LOOP
           DBMS_OUTPUT.PUT_LINE('prev -'||i||'-:'||PREV_ENTITLEMENTS_ARR(i));
        END LOOP;
      FOR i IN CURR_ENTITLEMENTS_ARR.FIRST..CURR_ENTITLEMENTS_ARR.LAST
        LOOP
           DBMS_OUTPUT.PUT_LINE('curr -'||i||'-:'||CURR_ENTITLEMENTS_ARR(i));
        END LOOP;
     */
      FOR i IN 0 .. v_count_cas - 1
      LOOP
         --v_prev := TO_NUMBER(PREV_ENTITLEMENTS_ARR(i));
         --v_curr   := TO_NUMBER(CURR_ENTITLEMENTS_ARR(i));
         IF prev_entitlements_arr (i) <> curr_entitlements_arr (i)
         THEN
            IF curr_entitlements_arr (i) = 0
            THEN
               v_cancel_product_codes := cas_arr (i).product_number;

               /*
               IF v_cancel_product_codes = '666' THEN
                  v_cancel_product_codes := 'PVR0';
               END IF;*/
               IF v_cancel_product_codes <> 1303
               THEN
                  IF LENGTH (o_cancel_product_codes) > 0
                  THEN
                     o_cancel_product_codes :=
                           o_cancel_product_codes
                        || ','
                        || v_cancel_product_codes;
                  ELSE
                     o_cancel_product_codes := v_cancel_product_codes;
                  END IF;
               END IF;
            ELSE
               v_add_product_codes := cas_arr (i).product_number;

               /*
               IF v_add_product_codes = '666' THEN
                  v_add_product_codes := 'PVR0';
               END IF;
               */
               IF v_add_product_codes <> 1303
               THEN
                  IF LENGTH (o_add_product_codes) > 0
                  THEN
                     o_add_product_codes :=
                        o_add_product_codes || ',' || v_add_product_codes;
                  ELSE
                     o_add_product_codes := v_add_product_codes;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;

      /*
      IF LENGTH(o_add_product_codes) > 0 AND SUBSTR(o_add_product_codes, LENGTH(o_add_product_codes)) <> ',' THEN
         o_add_product_codes := SUBSTR(0, LENGTH(o_add_product_codes)-1);
      END IF;*/
      parse_and_find_products (o_add_product_codes,
                               o_add_product_codes,
                               p_errm);
      parse_and_find_products (o_cancel_product_codes,
                               o_cancel_product_codes,
                               p_errm);
      o_add_product_codes := TO_CHAR (o_add_product_codes);
      o_cancel_product_codes := TO_CHAR (o_cancel_product_codes);
   --DBMS_OUTPUT.PUT_LINE('o_add_product_codes:'||o_add_product_codes);
   --DBMS_OUTPUT.PUT_LINE('o_cancel_product_codes:'||o_cancel_product_codes);
   EXCEPTION
      WHEN OTHERS
      THEN                    --dbms_output.put_line(SUBSTR(SQLERRM, 1, 255));
         p_errm := SUBSTR (SQLERRM, 1, 255);
   END;

   /********************************************************************************************************************/
   PROCEDURE parse_and_find_products (p_in_string    IN     VARCHAR2,
                                      p_out_string      OUT VARCHAR2,
                                      p_errm            OUT VARCHAR2)
   AS
      v_tokenized_str               VARCHAR2 (1000) := NULL;
      v_str_to_be_tokenized         VARCHAR2 (1000) := NULL;
      v_out_string                  VARCHAR2 (1000) := NULL;
      v_product_tag                 VARCHAR2 (64) := NULL;
      product_not_found_exception   EXCEPTION;
   BEGIN
      IF p_in_string IS NOT NULL
      THEN
         IF SUBSTR (p_in_string, LENGTH (p_in_string)) <> ','
         THEN
            v_str_to_be_tokenized := p_in_string || ',';
         ELSE
            v_str_to_be_tokenized := p_in_string;
         END IF;

         LOOP
            IF (v_str_to_be_tokenized IS NOT NULL)
            THEN
               v_tokenized_str :=
                  dbs_dba.split (v_str_to_be_tokenized, 1, ',');
               v_product_tag := NULL;

               -- FIND THE CORRESPONDING PRODUCT TAG FROM TABLE
               BEGIN
                  SELECT code
                    INTO v_product_tag
                    FROM dbs_addr_cas_services
                   WHERE product_number = v_tokenized_str;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_product_tag := NULL;
               END;

               IF v_product_tag IS NULL
               THEN
                  RAISE product_not_found_exception;
               ELSE
                  /*
                  IF  v_tokenized_str = '666' THEN
                     v_tokenized_str := 'PVR0';
                  END IF;*/
                  IF LENGTH (v_out_string) > 0
                  THEN
                     v_out_string := v_out_string || ',' || v_tokenized_str;
                  ELSE
                     v_out_string := v_tokenized_str;
                  END IF;
               END IF;
            ELSE
               EXIT;
            END IF;

            IF (v_tokenized_str IS NOT NULL)
            THEN
               v_str_to_be_tokenized :=
                  SUBSTR (v_str_to_be_tokenized,
                          INSTR (v_str_to_be_tokenized, ',') + 1);
            END IF;
         END LOOP;
      END IF;

      IF v_out_string IS NOT NULL
      THEN
         p_out_string := v_out_string;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN                    --dbms_output.put_line(SUBSTR(SQLERRM, 1, 255));
         p_errm := SUBSTR (SQLERRM, 1, 255);
   END;

   /********************************************************************************************************************/
   PROCEDURE check_if_tms_attr_exists (
      p_serial_number      IN     VARCHAR2,
      p_req_user           IN     VARCHAR2,
      p_tms_attr_key       IN     VARCHAR2,
      p_tms_attr_val       IN     VARCHAR2,
      p_tms_attr_val_old      OUT VARCHAR2,
      p_errm                  OUT VARCHAR2,
      p_out_tms            IN OUT VARCHAR2,
      p_tms_attr_ciksin    IN     VARCHAR2 DEFAULT 'E')
   AS
      v_tms_attr_id        NUMBER;
      v_tms_attr           VARCHAR2 (10);
      p_exists_but_null    NUMBER;
      exc_check_tms_attr   EXCEPTION;
   BEGIN
      p_errm := '0';

      BEGIN
         SELECT tms_attr_id
           INTO v_tms_attr_id
           FROM dbs_addr_equip
          WHERE serial_number = p_serial_number;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         SELECT NVL (tms_value, 0)
           INTO p_tms_attr_val_old
           FROM dbs_addr_tms
          WHERE id = v_tms_attr_id AND tms_key = p_tms_attr_key;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            p_tms_attr_val_old := NULL;
      END;

      IF v_tms_attr_id IS NULL
      THEN
         SELECT dbs_addr_pisys_tms_id_seq.NEXTVAL
           INTO v_tms_attr_id
           FROM DUAL;

         INSERT INTO dbs_addr_equip (serial_number,
                                     gca,
                                     call_back_date_time,
                                     giren_kullanici,
                                     giris_tarihi,
                                     degistiren_kullanici,
                                     degistirme_tarihi,
                                     tms_attr_id)
              VALUES (p_serial_number,
                      NULL                                           /*p_gca*/
                          ,
                      NULL,
                      p_req_user,
                      SYSDATE,
                      p_req_user,
                      SYSDATE,
                      v_tms_attr_id);
      ELSE
         UPDATE dbs_addr_equip
            SET                                 --tms_attr_id = v_tms_attr_id,
               degistiren_kullanici = p_req_user,
                degistirme_tarihi = SYSDATE
          WHERE serial_number = p_serial_number;
      END IF;

      IF p_tms_attr_val_old IS NULL
      THEN
         INSERT INTO dbs_addr_tms (id, tms_key, tms_value)
              VALUES (v_tms_attr_id, p_tms_attr_key, p_tms_attr_val);
      ELSIF p_tms_attr_val_old <> NVL (p_tms_attr_val, 0)
      THEN
         UPDATE dbs_addr_tms
            SET tms_value = p_tms_attr_val
          WHERE id = v_tms_attr_id AND tms_key = p_tms_attr_key;
      END IF;

      IF     (   p_tms_attr_val_old IS NULL
              OR p_tms_attr_val_old <> NVL (p_tms_attr_val, 0))
         AND p_tms_attr_ciksin = 'E'
      THEN
         IF LENGTH (p_out_tms) > 0
         THEN
            p_out_tms :=
               p_out_tms || ',' || p_tms_attr_key || ' ' || p_tms_attr_val;
         ELSE
            p_out_tms := p_tms_attr_key || ' ' || p_tms_attr_val;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errm := 'procedure check_if_tms_attr_exists:' || SQLERRM;
         RAISE exc_check_tms_attr;
   END;

   /********************************************************************************************************************/
   PROCEDURE find_set_tms (p_serial_number   IN     VARCHAR2,
                           p_req_user        IN     VARCHAR2,
                           p_out_tms            OUT VARCHAR2,
                           p_errm               OUT VARCHAR2,
                           p_tms_sablon      IN     VARCHAR2 := NULL,
                           p_force_send      IN     CHAR DEFAULT 'H')
   AS
      v_serial_number                wiz_equip.serial_number%TYPE
                                        := TRIM (p_serial_number);
      v_account_number               wiz_equip.account_number%TYPE;
      v_service_address_id           wiz_equip.service_address_id%TYPE;
      v_outlet_location              wiz_equip.outlet_location%TYPE;
      v_bolge                        co_ulke.gca_descr%TYPE;
      v_ulke                         wiz_hp_description.ulke%TYPE;
      v_il                           wiz_hp_description.city%TYPE;
      v_ilce                         wiz_hp_description.suppl_addr_line_1%TYPE;
      v_franchise_code               wiz_customer_hp_life.franchise_code%TYPE;
      v_brand                        wiz_customer_hp_life.hp_cluster%TYPE;
      v_stb_type                     VARCHAR2 (25) := NULL;
      v_manufacturer                 wiz_equip.manufacturer%TYPE;
      v_converter_model              wiz_equip.converter_model%TYPE;
      v_customer_type                wiz_customer_hp_life.customer_type%TYPE;
      v_ekran_mesaji_izleme          VARCHAR2 (5);
      v_birthdate                    VARCHAR2 (10);
      v_btv                          VARCHAR2 (10);
      v_service_1                    VARCHAR2 (10);
      v_satellite_service            VARCHAR2 (10);
      v_bouqet_type                  VARCHAR2 (30);

      v_tms_bolge                    VARCHAR2 (10);
      v_tms_bolge_old                VARCHAR2 (10);
      v_tms_ulke                     VARCHAR2 (10);
      v_tms_ulke_old                 VARCHAR2 (10);
      v_tms_il                       VARCHAR2 (10);
      v_tms_il_old                   VARCHAR2 (10);
      v_tms_franchise_code           VARCHAR2 (10);
      v_tms_franchise_code_old       VARCHAR2 (10);
      v_tms_customer_type            VARCHAR2 (10);
      v_tms_customer_type_old        VARCHAR2 (10);
      v_tms_display_msg              VARCHAR2 (10);
      v_tms_display_msg_old          VARCHAR2 (10);
      v_tms_stb_type                 VARCHAR2 (10);
      v_tms_stb_type_old             VARCHAR2 (10);
      v_tms_brand                    VARCHAR2 (10);
      v_tms_brand_old                VARCHAR2 (10);
      v_tms_birthday                 VARCHAR2 (10);
      v_tms_birthday_old             VARCHAR2 (10);
      v_tms_btv                      VARCHAR2 (10);
      v_tms_btv_old                  VARCHAR2 (10);
      v_tms_service_1                VARCHAR2 (10);
      v_tms_service_1_old            VARCHAR2 (10);
      v_tms_satellite_type           VARCHAR2 (10);
      v_tms_satellite_type_old       VARCHAR2 (10);
      v_tms_rating                   VARCHAR2 (10); /*[EBerker20121226] - Rating Tms Attribute*/
      v_tms_rating_old               VARCHAR2 (10); /*[EBerker20121226] - Rating Tms Attribute*/
      v_tra_id                       NUMBER;
      v_req_date                     DATE := SYSDATE;
      v_req_dbs_type                 NUMBER (2) := 11;
      v_durum                        VARCHAR2 (400);
      v_ret                          NUMBER;
      v_product_number               VARCHAR2 (6);
      v_add_product_list             VARCHAR2 (500) := NULL;
      v_cancel_product_list          VARCHAR2 (500) := NULL;
      v_bouqet_tms_attribute         VARCHAR2 (50) := 'BOUQUET=0'; --DEFAULT BOUQUET_ID:128 DIR
      v_abone_ozellik_23             NUMBER;
      v_tms_bouqet_type              NUMBER;
      v_tms_bouqet_type_old          NUMBER;
      v_bouqet_id                    NUMBER := 0;
      v_reset_channel_order          BOOLEAN := FALSE;

      v_ekipman_ozellik              VARCHAR2 (10);
      v_ekipman_tip_matrix_id        NUMBER (10);
      v_kutu_cocuk_bouqet_destekli   BOOLEAN := FALSE;
      v_kutu_hd_bouqet_destekli      BOOLEAN := FALSE;
      v_bouqet_default_kisit         BOOLEAN := FALSE;
      v_uye_uydu_tipi                NUMBER (2) := 0;
      v_cnt                          NUMBER (5) := 0;

      v_tms_spor                     NUMBER (1) := 0;
      v_tms_spor_old                 NUMBER (1) := 0;
      v_tms_sinema                   NUMBER (1) := 0;
      v_tms_sinema_old               NUMBER (1) := 0;
      v_tms_erotik                   NUMBER (1) := 0;
      v_tms_erotik_old               NUMBER (1) := 0;
      v_tms_derbi_filter             NUMBER (1) := 0;
      v_tms_derbi_filter_old         NUMBER (1) := 0;

      v_derbisiz_filter_dusur        BOOLEAN := FALSE;
      v_derbisiz_filter_ekle         BOOLEAN := FALSE;
      v_dumy_boolean                 BOOLEAN := FALSE;
      v_trace_order_cnt              NUMBER (5) := 1;
      v_filter_sinyal_ciksin         BOOLEAN := FALSE; --BU SINYAL TMSKEY-VALU SETI CIKMASIN AMA BUNA BAGLI BIR FILTER PRODUCT SINYALI VARSA O CIKSIN ICIN EKLENMIS DEGISKEN.. BU DURUMDA TRU OLMALI.

      v_kart_abonede                 BOOLEAN := TRUE;
      /*[EBerker20121226] Abone de Rating Özelligi Varmi*/
      v_abone_ozellik_rating         NUMBER := 0;
      v_count                        NUMBER;
      v_tms_ticari_logo              VARCHAR2 (10) := 0; /*[EBerker20130531] - Ticari Logo Tms Attribute*/
      v_tms_ticari_logo_old          VARCHAR2 (10) := 0; /*[EBerker20130531] - Ticari Logo Tms Attribute*/
      v_tms_fingerprint              NUMBER := 0; /*bozturkmen -  fingerprint istemiyor*/
      v_tms_fingerprint_old          NUMBER; /*bozturkmen -  fingerprint istemiyor*/
      v_abone_ozellik_fingerprint    NUMBER := 0; /*bozturkmen - abone fingerprint istemiyor mu*/
      v_st_ekipman_no                wiz_equip.serial_number%TYPE; /*[EBerker20140326] - TURKSAT HD Bouquet*/

      v_tms_info_message             NUMBER := 0;                   -- bsarcan
      v_tms_info_message_old         NUMBER := 0;                   -- bsarcan
   BEGIN
      p_errm := '0';

      /*Tuna:Kill olan Ekipmanlar için find_Set_tms çalışmasın. Irdeto kutularda zaten kill ise sinyal gönderilmesin isteniyor.:Gokhan Korkut*/
      IF dbs_dba.ekipman_durumu_pack.kill_mi (v_serial_number) = 1
      THEN
         p_errm := 'find_tms: ekipman kill durumunda!';
         RETURN;
      END IF;

      BEGIN
         SELECT account_number, service_address_id, outlet_location
           INTO v_account_number, v_service_address_id, v_outlet_location
           FROM wiz_equip
          WHERE wiz_equip.serial_number = v_serial_number;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_errm := 'find_tms: ekipman bilgisi bulunamadi!';
            RETURN;
      END;

      /*bozturkmen -  abone fingerprint istemiyor özelliği
                      0: istiyor
                      1: istemiyor  */

      BEGIN
         SELECT COUNT (1)
           INTO v_count
           FROM mb_abone_ozellik
          WHERE     account_number = v_account_number
                AND (   (outlet_location = v_outlet_location)
                     OR (outlet_location IS NULL))
                AND abone_ozellik_kodu =
                       (SELECT kod
                          FROM pr_abone_ozellik
                         WHERE aciklama = 'FINGERPRINT ISTEMIYOR');

         IF v_count > 0
         THEN
            v_tms_fingerprint := 1;
         ELSE
            v_tms_fingerprint := 0;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_tms_fingerprint := 0;
            v_durum := 'Fingerprint istiyormu:' || SQLERRM;
      END;



      /*bsarcan -  ekran mesaj
                      0: gösterilmeyecek
                      1: gösterilecek  */


      SELECT COUNT (1)
        INTO v_count
        FROM mb_abone_ozellik
       WHERE     account_number = v_account_number
             AND (   (outlet_location = v_outlet_location)
                  OR (outlet_location IS NULL))
             AND abone_ozellik_kodu =
                    (SELECT kod
                       FROM pr_abone_ozellik
                      WHERE aciklama = 'SOZLESME YENILEME OPR');       /*439*/

      IF v_count > 0
      THEN
         v_tms_info_message := 1;
      ELSE
         v_tms_info_message_old := 0;
      END IF;



      /*[EBerker20121226] - Abone Rating Özellik Kontrol
             1: RATING ÖZELLİĞİ VAR
             2: RATING ÖZELLİĞİ YOK
             3: HATA OLDU
      */
      BEGIN
         SELECT COUNT (1)
           INTO v_count
           FROM mb_abone_ozellik
          WHERE     account_number = v_account_number
                AND (   (outlet_location = v_outlet_location)
                     OR (outlet_location IS NULL))
                AND abone_ozellik_kodu =
                       (SELECT kod
                          FROM pr_abone_ozellik
                         WHERE aciklama = dbs_sabit ('ABONE_RATING_ACIKLAMA'));

         IF v_count > 0
         THEN
            v_abone_ozellik_rating := 1;
         ELSE
            v_abone_ozellik_rating := 2;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_abone_ozellik_rating := 3;
            v_durum := 'Rating varmı:' || SQLERRM;
      END;

      IF v_account_number IS NOT NULL AND v_account_number > 0
      THEN
         SELECT franchise_code,
                service_address_id,
                hp_cluster,
                customer_type
           INTO v_franchise_code,
                v_service_address_id,
                v_brand,
                v_customer_type
           FROM wiz_customer_hp_life
          WHERE account_number = v_account_number;

         /*bozturkmen -  F04 TICler için TRT blackout yapılması için F04 üyeler, F03 franchiseına kaydırıldı ve tmslerine bu şekilde set edilmesi sağlandı.*/
         IF TRIM (v_franchise_code) = 'F04' AND v_customer_type = 'TIC'
         THEN
            v_franchise_code := 'F03';
         END IF;

         SELECT ulke, city, suppl_addr_line_1
           INTO v_ulke, v_il, v_ilce
           FROM wiz_hp_description
          WHERE service_address_id = v_service_address_id;

         SELECT ulke.gca_descr
           INTO v_bolge
           FROM co_ulke ulke
          WHERE ulke.ad = v_ulke;

         SELECT DECODE (COUNT (1), '1', 'HAYIR', 'EVET')
           INTO v_ekran_mesaji_izleme
           FROM mb_abone_ozellik
          WHERE account_number = v_account_number AND abone_ozellik_kodu = 3; --Asagidakiozellik kodu yerine 3 olarak bakilmasi isteniyor. Mustafa Temiz, degistiren Tunahan

         /*( SELECT kod
          FROM   pr_abone_ozellik
          WHERE  aciklama = 'EKRAN MESAJI IZLEMEME' );*/

         -- Abone ozellik kodu 23 olanlara GCA-TURKIYE gibi davranilacak..
         SELECT COUNT (1)
           INTO v_abone_ozellik_23
           FROM mb_abone_ozellik
          WHERE     account_number = v_account_number
                AND outlet_location = v_outlet_location
                AND abone_ozellik_kodu =
                       (SELECT kod
                          FROM pr_abone_ozellik
                         WHERE aciklama = 'GCA BOLGE TURKIYE');

         IF v_abone_ozellik_23 = 1
         THEN
            /*[EBerker03012012] ulkesi ve ili ne ise o gelecektir.*/
            v_bolge := dbs_addr_sabit_pack.turkiye_yurtdisi;
         END IF;

         /*[EBerker20140326] - TURKSAT HD Bouquet icin st ekipman no(kutu veya modul) bilgisi gerekti*/
         BEGIN
            SELECT e.eq_ekipman_tip_matrix_id, w.serial_number --digikutu serial number
              INTO v_stb_type, v_st_ekipman_no
              FROM wiz_equip w, eq_ekipman_tip_matrix e
             WHERE     account_number = v_account_number
                   AND outlet_location = v_outlet_location
                   AND w.converter_type = 'ST'
                   AND w.converter_model <> 'DUMMY'
                   AND TRIM (w.manufacturer) = TRIM (e.manufacturer)
                   AND TRIM (w.converter_model) = TRIM (e.converter_model);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  SELECT e.eq_ekipman_tip_matrix_id, ek.serial_number --moudule serial number
                    INTO v_stb_type, v_st_ekipman_no
                    FROM eq_ekipman ek, eq_ekipman_tip_matrix e
                   WHERE     account_number = v_account_number
                         AND outlet_location = v_outlet_location
                         AND ek.ekipman_tipi = 248
                         AND NVL (TRIM (ek.ekipman_modul_tipi), '-1') =
                                NVL (TRIM (e.converter_model), '-1');
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_stb_type := 0;
               END;
         END;

         BEGIN
            SELECT MIN (TO_CHAR (dogum_tarihi, 'DD.MM.YYYY'))
              INTO v_birthdate
              FROM mb_abone_detay_bilgi
             WHERE account_number = v_account_number;

            IF TO_DATE (v_birthdate, 'DD.MM.YYYY') BETWEEN TO_DATE (
                                                              '01.01.1900',
                                                              'DD.MM.YYYY')
                                                       AND SYSDATE
            THEN
               NULL;             --NOT BETWEEN ÇALISMADIGI IÇIN BÖYLE YAPILDI.
            ELSE
               v_tms_birthday := NULL;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_tms_birthday := NULL;
            WHEN OTHERS
            THEN
               v_tms_birthday := NULL;
         END;

         v_btv := kontrol_pack.btv_gca_bul (p_req_user, p_serial_number);

         tms_attributes ('BOLGEKODU', v_bolge, v_tms_bolge);
         tms_attributes ('COUNTRY', v_ulke, v_tms_ulke);
         tms_attributes ('CITYCODE', v_il, v_tms_il);
         tms_attributes ('FRANCHISE', v_franchise_code, v_tms_franchise_code);
         tms_attributes ('CUSTTYPE', v_customer_type, v_tms_customer_type);
         tms_attributes ('BRAND', v_brand, v_tms_brand);
         tms_attributes ('DISPLAYMSG',
                         v_ekran_mesaji_izleme,
                         v_tms_display_msg);
         tms_attributes ('STBMODEL', v_stb_type, v_tms_stb_type);
         tms_attributes ('BIRTH_DATE', v_birthdate, v_tms_birthday);
         tms_attributes ('BTVCOMPANY', v_btv, v_tms_btv);

         --  tms_attributes ( 'SERVICE_1',  v_service_1,           v_tms_service_1 );    -- service yapısı standarda uydurulursa, böyle olmalı.
         --  tms_attributes ( 'SATELLITE',  v_satellite_service,   v_tms_satellite_type );--TUNA GEREK KALMADI
         --  tms_attributes ( 'SATELLITE',  v_satellite_service,   v_tms_satellite_type );--TUNA GEREK KALMADI

         IF v_tms_il = '34'
         THEN
            v_tms_il :=
               TO_NUMBER (get_il_bolge (LPAD (v_tms_il, 3, '0'), v_ilce));
         END IF;

         v_service_1 :=
            dbs_addr_reqs_pack.find_product_type (v_account_number,
                                                  v_outlet_location,
                                                  v_serial_number,
                                                  v_brand,
                                                  v_customer_type);

         /*  0: PAKET        1:ZAP PAKET         2:ÇOCUK PAKETİ
             3:ZEUS PAKETİ           4:BCH SERVİSİ       5:BCS SERVİSİ
             6:BHS SERVİSİ           7:CHS SERVİSİ*/

         --     tms tablosuna gitmeden yapildi.
         v_tms_service_1 := v_service_1;

         /*[EBerker20121226] rating ozelligi varsa tms attribute 1 e set edilir.*/
         IF v_abone_ozellik_rating = 1
         THEN
            v_tms_rating := 1;
         ELSE
            v_tms_rating := 0; /* 2: RATING ÖZELLİĞİ YOK ,3: HATA OLDU bu her iki durumda tms attribute durumu belli degil o yüzden 0 a set edilir->Ref:Mustafa Temiz */
         END IF;

         -- [EBerker20130531] ticari logo tms attr value aliniyor
         BEGIN
            SELECT pr.kod_alt_grubu
              INTO v_tms_ticari_logo
              FROM mb_abone_ozellik mb, pr_abone_ozellik pr
             WHERE     account_number = v_account_number
                   AND (   (outlet_location = v_outlet_location)
                        OR (outlet_location IS NULL))
                   AND abone_ozellik_kodu = pr.kod
                   AND pr.kod_grubu = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_tms_ticari_logo := 0;
            WHEN OTHERS
            THEN
               v_tms_ticari_logo := 0;
         END;
      ELSE
         --  Abone üzerinden düsürülmüs kartlarin TMS'lerinin hepsi default value'lara geri dönsün
         --  Bu arada karttaki filter product'lar da silinsin.
         --  Evirm Kayan, Ocak 2008
         v_kart_abonede := FALSE;
         v_tms_bolge := 0;
         v_tms_ulke := 0;
         v_tms_il := 0;
         v_tms_franchise_code := 0;
         v_tms_customer_type := 0;
         v_tms_brand := 0;
         v_tms_display_msg := 0;
         v_tms_stb_type := 0;
         v_tms_birthday := 0;
         v_tms_btv := 0;
         v_tms_service_1 := 0;
         v_tms_satellite_type := 1;
         v_tms_bouqet_type := -1;
         v_tms_spor := 0;
         v_tms_sinema := 0;
         v_tms_erotik := 0;
         v_tms_derbi_filter := 0;
         v_tms_rating := 0; /*[EBerker20121226] rating tms attribute default degere set edilir.*/
         v_tms_ticari_logo := 0; /*[EBerker20130531] ticari tms attribute default degere 0'a set edilir.*/
         v_tms_fingerprint := 0;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BOLGEKODU',
                                v_tms_bolge,
                                v_tms_bolge_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_bolge_old, 0) <> NVL (v_tms_bolge, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'BOLGEKODU';

         IF NVL (v_tms_bolge_old, 0) > 0
         THEN
            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (
                          dbs_addr.dbms_numsystem_package.dec2hex (
                             v_tms_bolge_old)));
            ELSE
               v_cancel_product_list :=
                     v_cancel_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (
                             dbs_addr.dbms_numsystem_package.dec2hex (
                                v_tms_bolge_old)));
            END IF;
         END IF;

         IF NVL (v_tms_bolge, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (
                          dbs_addr.dbms_numsystem_package.dec2hex (
                             v_tms_bolge)));
            ELSE
               v_add_product_list :=
                     v_add_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (
                             dbs_addr.dbms_numsystem_package.dec2hex (
                                v_tms_bolge)));
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'CITYCODE',
                                v_tms_il,
                                v_tms_il_old,
                                p_errm,
                                p_out_tms);
      -- 27/01/2010; Emine; İl bilgisine göre çıkan filter productların çıkması engellendi (Gökhan'ın talebi)
      /*IF nvl(v_tms_il_old,0) <> nvl(v_tms_il,0) THEN
          SELECT PRODUCT_NUMBER INTO v_product_number FROM DBS_ADDR_CAS_FILTER_PRODUCTS WHERE CODE = 'CITYCODE';
          IF nvl(v_tms_il_old,0) > 0 THEN
              IF v_cancel_product_list IS NULL THEN
                  v_cancel_product_list := DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_il_old));
              ELSE
                  v_cancel_product_list := v_cancel_product_list||','|| DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_il_old));
              END IF;
          END IF;
          IF nvl(v_tms_il,0) > 0 THEN
              IF v_add_product_list IS NULL THEN
                  v_add_product_list := DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_il));
              ELSE
                  v_add_product_list := v_add_product_list||','|| DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_il));
              END IF;
          END IF;
      END IF;*/

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'COUNTRY',
                                v_tms_ulke,
                                v_tms_ulke_old,
                                p_errm,
                                p_out_tms);

      --Tuna:İNGİLTERE deki ekipmanlara BBC Prime (Entertainment) ve BBC World?ün Uk?de dağıtma hakkımız olmadığı için 31A0 productının eklenmesi gerekti
      IF NVL (v_tms_ulke_old, 0) <> NVL (v_tms_ulke, 0)
      THEN
         IF NVL (v_tms_ulke_old, 0) IN (7) OR v_tms_ulke IN (7)
         THEN
            SELECT product_number
              INTO v_product_number
              FROM dbs_addr_cas_filter_products
             WHERE code = 'COUNTRY'; --CNTYAYIN: ULKE BAZINDA KANAL KISITI KOYMAK ICIN KULLANILIYOR.

            --7:INGILTERE icin filter product
            IF v_tms_ulke_old = 7
            THEN
               IF v_cancel_product_list IS NULL
               THEN
                  v_cancel_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_ulke_old));
               ELSE
                  v_cancel_product_list :=
                        v_cancel_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_ulke_old));
               END IF;
            ELSIF v_tms_ulke = 7
            THEN                        --ULKE:ingiltere olarak set ediliyorsa
               IF v_add_product_list IS NULL
               THEN
                  v_add_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                        TO_NUMBER (v_product_number) + TO_NUMBER (v_tms_ulke));
               ELSE
                  v_add_product_list :=
                        v_add_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_ulke));
               END IF;
            END IF;
         --7:INGILTERE icin filter product
         --ulke bazında eklenencek yeni filterproductlar olması durumunda aşağıdya eklenmelıdır.
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'FRANCHISE',
                                v_tms_franchise_code,
                                v_tms_franchise_code_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_franchise_code_old, 0) <> NVL (v_tms_franchise_code, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'FRANCHISE';

         IF NVL (v_tms_franchise_code_old, 0) > 0
         THEN
            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_franchise_code_old));
            ELSE
               v_cancel_product_list :=
                     v_cancel_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_franchise_code_old));
            END IF;
         END IF;

         IF NVL (v_tms_franchise_code, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_franchise_code));
            ELSE
               v_add_product_list :=
                     v_add_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_franchise_code));
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'CUSTTYPE',
                                v_tms_customer_type,
                                v_tms_customer_type_old,
                                p_errm,
                                p_out_tms);

      --tuna 1:TICARI YADA OTEL:BLK ISE FILTER PRODUCT ÇIKILIYOR...
      IF v_tms_customer_type IN (1, 3) OR v_tms_customer_type_old IN (1, 3)
      THEN
         IF NVL (v_tms_customer_type_old, 0) <> NVL (v_tms_customer_type, 0)
         THEN
            SELECT product_number
              INTO v_product_number
              FROM dbs_addr_cas_filter_products
             WHERE code = 'CUSTTYPE';

            IF NVL (v_tms_customer_type_old, 0) IN (1, 3)
            THEN
               CASE v_tms_customer_type_old
                  WHEN 1
                  THEN
                     v_tms_customer_type_old := 0;   --TICARI ISE 3031+0->3031
                  WHEN 3
                  THEN
                     v_tms_customer_type_old := 1;   --OTEL ISE   3031+1->3032
                  ELSE
                     NULL;                                           --DEFAULT
               END CASE;

               IF v_cancel_product_list IS NULL
               THEN
                  v_cancel_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_customer_type_old));
               ELSE
                  v_cancel_product_list :=
                        v_cancel_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_customer_type_old));
               END IF;
            END IF;

            IF NVL (v_tms_customer_type, 0) IN (1, 3)
            THEN
               CASE v_tms_customer_type
                  WHEN 1
                  THEN
                     v_tms_customer_type := 0;       --TICARI ISE 3031+0->3031
                  WHEN 3
                  THEN
                     v_tms_customer_type := 1;       --OTEL ISE   3031+1->3032
                  ELSE
                     NULL;                                           --DEFAULT
               END CASE;

               IF v_add_product_list IS NULL
               THEN
                  v_add_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_customer_type));
               ELSE
                  v_add_product_list :=
                        v_add_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_customer_type));
               END IF;
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BRAND',
                                v_tms_brand,
                                v_tms_brand_old,
                                p_errm,
                                p_out_tms);
      /*02/02/2010 TUNA: Mantis ve Kino nedeni ile Artık ZS->ZEUS brendi için daha önce çıkılan 304F+4=3053 filter prdouctına gerek kalmadı.
      IF v_tms_brand = 4 THEN --ZS ISE
          IF nvl(v_tms_brand_old,0) <> nvl(v_tms_brand,0) THEN
              SELECT PRODUCT_NUMBER INTO v_product_number FROM DBS_ADDR_CAS_FILTER_PRODUCTS WHERE CODE = 'BRAND';
              IF nvl(v_tms_brand_old,0) > 0 THEN
                  IF v_cancel_product_list IS NULL THEN
                      v_cancel_product_list := DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_brand_old));
                  ELSE
                      v_cancel_product_list := v_cancel_product_list||','|| DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_brand_old));
                  END IF;
              END IF;
              IF nvl(v_tms_brand,0) > 0 THEN
                  IF v_add_product_list IS NULL THEN
                      v_add_product_list := DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_brand));
                  ELSE
                      v_add_product_list := v_add_product_list||','|| DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_brand));
                  END IF;
              END IF;
          END IF;
      END IF;
      */

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'DISPLAYMSG',
                                v_tms_display_msg,
                                v_tms_display_msg_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'STBMODEL',
                                v_tms_stb_type,
                                v_tms_stb_type_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BIRTH_DATE',
                                v_tms_birthday,
                                v_tms_birthday_old,
                                p_errm,
                                p_out_tms);

      /*[EBerker20121226] rating tms attribute kontrolu yapiliyor*/
      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'DM_SCORE1',
                                v_tms_rating,
                                v_tms_rating_old,
                                p_errm,
                                p_out_tms);
      /*[EBerker20130531] ticari logo tms attribute kontrolu yapiliyor*/
      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'TICARI',
                                v_tms_ticari_logo,
                                v_tms_ticari_logo_old,
                                p_errm,
                                p_out_tms);

      /*bozturkmen fingerprint attribute kontrolü*/
      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'FPRINT',
                                v_tms_fingerprint,
                                v_tms_fingerprint_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BTVCOMPANY',
                                v_tms_btv,
                                v_tms_btv_old,
                                p_errm,
                                p_out_tms);



      /*bsarcan sözleşme ekranı 30122014 */
      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'INFOMSG',
                                v_tms_info_message,
                                v_tms_info_message_old,
                                p_errm,
                                p_out_tms);


      IF NVL (v_tms_btv_old, 0) <> NVL (v_tms_btv, 0)
      THEN
         IF NVL (v_tms_btv_old, 0) > 0
         THEN
            --Emine; 13/05/2009; filter product degerler sequential gitmedigi icin asagidaki satirlar commentlendi
            --SELECT PRODUCT_NUMBER INTO v_product_number FROM DBS_ADDR_CAS_FILTER_PRODUCTS WHERE CODE = 'BTVCOMPANY';
            SELECT gca
              INTO v_product_number
              FROM gca_pool
             WHERE gca_pool_id = v_tms_btv_old;

            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list := v_product_number;
            --v_cancel_product_list := DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_btv_old));
            ELSE
               v_cancel_product_list :=
                  v_cancel_product_list || ',' || v_product_number;
            --v_cancel_product_list := v_cancel_product_list||','|| DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_btv_old));
            END IF;
         END IF;

         IF NVL (v_tms_btv, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list := v_btv;
            ELSE
               v_add_product_list := v_add_product_list || ',' || v_btv;
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'SERVICE_01',
                                v_tms_service_1,
                                v_tms_service_1_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_service_1_old, 0) <> NVL (v_tms_service_1, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'SERVICE_01';

         IF NVL (v_tms_service_1_old, 0) > 0
         THEN
            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_service_1_old));
            ELSE
               v_cancel_product_list :=
                     v_cancel_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_service_1_old));
            END IF;
         END IF;

         IF NVL (v_tms_service_1, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_service_1));
            ELSE
               v_add_product_list :=
                     v_add_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_service_1));
            END IF;
         END IF;
      END IF;

      /*1:EutelSat 2:Turksat 3:Ortak, -1:Hatali durum*/
      IF v_kart_abonede
      THEN
         v_tms_satellite_type :=
            abone_sorgu_pack.uye_uydusu (v_account_number, v_outlet_location);
      END IF;

      v_uye_uydu_tipi := TO_NUMBER (v_tms_satellite_type); --UYE BOUQET TIPINDE KULLANILMAK UZERE UYDU TIPI YEDEKLENDI.

      --uYDUSU Hatalı dönenler,EUTALSAT OLARAK KABUL EDILIR. tuna
      IF v_tms_satellite_type < 0
      THEN
         v_tms_satellite_type := 1;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'SATELLITE',
                                v_tms_satellite_type,
                                v_tms_satellite_type_old,
                                p_errm,
                                p_out_tms);

      --TUNA:MUSTERI TIPININ TICARI:1 / OTEL-BLK:3 olması durumunda uydu filter productlarını çıkmıyoruz. Gokhan Korkut. Spormax ile ilgili değişiklikler.
      IF NVL (v_tms_customer_type, 0) NOT IN (1, 3)
      THEN
         IF NVL (v_tms_satellite_type_old, 0) <>
               NVL (v_tms_satellite_type, 0)
         THEN
            SELECT product_number
              INTO v_product_number
              FROM dbs_addr_cas_filter_products
             WHERE code = 'SATELLITE';

            IF NVL (v_tms_satellite_type_old, 0) IN (1, 2, 3)
            THEN
               CASE v_tms_satellite_type_old
                  WHEN 1
                  THEN
                     v_tms_satellite_type_old := 0; --EUTALSAT          : 3030
                  WHEN 2
                  THEN
                     v_tms_satellite_type_old := 3; --TURKSAT           : 3033
                  WHEN 3
                  THEN
                     v_tms_satellite_type_old := 4; --EUTELSAT+TURKSAT  : 3034
                  ELSE
                     v_tms_satellite_type_old := 0; --DEFAULT EUTALSAT FILTER PRODUCTI
               END CASE;

               IF v_cancel_product_list IS NULL
               THEN
                  v_cancel_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_satellite_type_old));
               ELSE
                  v_cancel_product_list :=
                        v_cancel_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_satellite_type_old));
               END IF;
            END IF;

            IF NVL (v_tms_satellite_type, 0) IN (1, 2, 3)
            THEN
               CASE v_tms_satellite_type
                  WHEN 1
                  THEN
                     v_tms_satellite_type := 0;      --EUTALSAT          :3030
                  WHEN 2
                  THEN
                     v_tms_satellite_type := 3;      --TUKSAT            :3033
                  WHEN 3
                  THEN
                     v_tms_satellite_type := 4;      --EUTELSAT+TURKSAT  :3034
                  ELSE
                     v_tms_satellite_type := 0; --DEFAULT EUTALSAT FILTER PRODUCTI
               END CASE;

               IF v_add_product_list IS NULL
               THEN
                  v_add_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_satellite_type));
               ELSE
                  v_add_product_list :=
                        v_add_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_satellite_type));
               END IF;
            END IF;
         END IF;
      END IF;

      --TUNAHAN 12.11.2011 BOUQET BASLA------------------------------------------------------------------------------------------------------
      BEGIN --KANAL SIRALAMA DEGISIKLIK MODU ACIKSA BU KONTROLE GEREK KALMADI..
         --KANAL BOUQET TIPI TESPIT EDILIYOR EGER KANAL BUKET TIPI DEGISIRSE RESET CHANNEL ORDER SINYALI CIKILIYOR
         --EGER UYEDE COCUK PAKETI VAR ISE ve KUTU COCUK BUKETINI DESTEKLIYORSA BOUQET TYPE:=1  ; COCUK_BOUQET_ID:4347
         --EĞER UYE HD SERVISI(LHD:3000) ICEREN BIR PAKETE SAHIPSA VE KUTU HD BUKETINI DESTEKLIYORSA BOUQET TYPE:=2  ; COCUK_BOUQET_ID:4347
         --DEFAULT BOUQET TYPE:=0 ; DEFAULT_BOUQET_ID:128

         --TUNAHAN:ZATEN YUKARDA MALIYETINE GIRIP TESPIT ETTIGIMIZ OZELLIKLERI KULLANARAK GENEL BOUQET KISITI ELDE EDEREK DIGER KISIT TESPIT MALIYETLERINE GIRMEYE GEREK VARMI ICIN AYRI TUTULdu.
         v_bouqet_default_kisit :=
            (    (v_tms_franchise_code IN (1, 2))             --F01,F02-ISE VE
             AND (INSTR (
                     dbs_addr.getdinamikkeyvalue (
                        'TMS_BOUQET_CUST_TYPE_LIST'),
                     v_customer_type) > 0)                    --NOR,TST-ISE VE
             AND v_uye_uydu_tipi IN (1, 2) --[EBerker20131030]- TURKSAT HD BUKE kontrolu eklendi
                                          --.Dolayısıyla EUTALSAT ve TURKSAT OLANLAR
            );

         --VE
         --IF v_bouqet_default_kisit THEN
         SELECT COUNT (1)
           INTO v_cnt
           FROM dbs_dba.mb_abone_ozellik
          WHERE     abone_ozellik_kodu = 241 -- 241 : KANAL SIRALAMASI DEGISMEZ...
                AND account_number = v_account_number
                AND (   outlet_location IS NULL
                     OR outlet_location = v_outlet_location);

         IF v_cnt > 0
         THEN
            v_bouqet_default_kisit := FALSE;
         ELSIF v_uye_uydu_tipi = 2
         THEN
            v_bouqet_default_kisit := TRUE;
         END IF;

         --END IF;

         IF v_kart_abonede
         THEN
            /*[EBerker20131030]- TURKSAT HD BOUQUET kontrolu eklendi.*/
            -- UYDU TIPI= 1:EUTELSAT  2:TURKSAT  3:EUTELSAT + TURKSAT
            IF v_uye_uydu_tipi = 2
            THEN
               v_tms_bouqet_type := 0;       --TURKSAT DEFAULT BOUQUET TYPE: 0

               IF v_bouqet_default_kisit
               THEN
                  dbs_dba.ekipman_pack.ekipman_ozellik (
                     NULL,
                     v_account_number,
                     v_outlet_location,
                     115                         /*HD BOUQUET DESTEKLER KUTU*/
                        ,
                     v_ekipman_tip_matrix_id,
                     v_ekipman_ozellik);
                  v_kutu_hd_bouqet_destekli :=
                     (    v_ekipman_ozellik IS NOT NULL
                      AND v_ekipman_ozellik = 'E'
                      AND dbs_dba.abone_sorgu_pack.hd_servisi_varmi (
                             v_account_number,
                             v_outlet_location) > 0);

                  IF v_kutu_hd_bouqet_destekli
                  THEN
                     v_tms_bouqet_type := 3;     --TURKSAT HD BOUQUET TYPE : 3
                  END IF;
               END IF;
            /*IF p_errm <> '0' THEN
               RETURN;
            END IF;*/
            ELSE
               v_tms_bouqet_type := 0;      --EUTELSAT DEFAULT BOUQUET TYPE: 0

               IF v_bouqet_default_kisit
               THEN
                  --F01-NOR-TST-EUTALSAT OLANLARIN BOUQETI DEAFULT BOUQETTEN FARKLI MI KONTROL EDILIYOR...
                  --FARKLI ISE YA COCUK BOUQESIDIR YADA HD BOUQESI.
                  v_kutu_cocuk_bouqet_destekli := FALSE;
                  v_kutu_hd_bouqet_destekli := FALSE;

                  dbs_dba.ekipman_pack.ekipman_ozellik (
                     NULL,
                     v_account_number,
                     v_outlet_location,
                     116                      /*ÇOCUK BOUQUET DESTEKLER KUTU*/
                        ,
                     v_ekipman_tip_matrix_id,
                     v_ekipman_ozellik);
                  v_kutu_cocuk_bouqet_destekli :=
                     (    v_ekipman_ozellik IS NOT NULL
                      AND v_ekipman_ozellik = 'E'
                      AND v_tms_service_1 = 2);

                  IF v_kutu_cocuk_bouqet_destekli
                  THEN
                     v_tms_bouqet_type := 1;           --COCUK BOUQUET TYPE :1
                  ELSE -- COCUK BOUQUET DESTEKLI ISE HD BOUQUET DESTEKLIMI DIYE BAKILMAZ CUNKU BOUQUET ONCELIGI COCUKTA...
                     dbs_dba.ekipman_pack.ekipman_ozellik (
                        NULL,
                        v_account_number,
                        v_outlet_location,
                        115                      /*HD BOUQUET DESTEKLER KUTU*/
                           ,
                        v_ekipman_tip_matrix_id,
                        v_ekipman_ozellik);
                     v_kutu_hd_bouqet_destekli :=
                        (    v_ekipman_ozellik IS NOT NULL
                         AND v_ekipman_ozellik = 'E'
                         AND dbs_dba.abone_sorgu_pack.hd_servisi_varmi (
                                v_account_number,
                                v_outlet_location) > 0);

                     IF v_kutu_hd_bouqet_destekli
                     THEN
                        v_tms_bouqet_type := 2;          --HD BOUQUET TYPE : 2
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         check_if_tms_attr_exists (p_serial_number,
                                   p_req_user,
                                   'BOUQUET',
                                   v_tms_bouqet_type,
                                   v_tms_bouqet_type_old,
                                   p_errm,
                                   p_out_tms);

         v_reset_channel_order := FALSE;            --BOUQUET SINYALI CIKMASIN

         IF NVL (v_tms_bouqet_type_old, 0) <> NVL (v_tms_bouqet_type, 0)
         THEN                 --SIMIDIKI BOUQUET DURUMU ONCEKINDEN FARKLI ISE.
            IF    NVL (dbs_dba.dbs_sabit ('COCUK_BUKE_SINYAL_AKTIF'), 'H') =
                     'E'
               OR NVL (dbs_dba.dbs_sabit ('HD_BUKE_SINYAL_AKTIF'), 'H') = 'E'
               OR NVL (dbs_dba.dbs_sabit ('TURKSAT_HD_BUKE_SINYAL_AKTIF'),
                       'H') = 'E'
            THEN
               v_reset_channel_order := TRUE;        -- BOUQUET SINYALI CIKSIN
            END IF;

            --SET BOUQET ID SIGNAL PARAMETERS
            IF v_reset_channel_order
            THEN
               CASE NVL (v_tms_bouqet_type, 0)
                  WHEN 1
                  THEN
                     v_bouqet_tms_attribute := 'BOUQUET=1';
                     v_bouqet_id :=
                        TO_NUMBER (getdinamikkeyvalue ('BOUQET_COCUK')); -- COCUK_BOUQET_ID:4347

                     IF NVL (dbs_dba.dbs_sabit ('COCUK_BUKE_SINYAL_AKTIF'),
                             'H') = 'H'
                     THEN
                        v_reset_channel_order := FALSE; --COCUK ICIN YENI BOUQET SINYALI CIKMA
                     END IF;
                  WHEN 2
                  THEN
                     v_bouqet_tms_attribute := 'BOUQUET=2';
                     v_bouqet_id :=
                        TO_NUMBER (getdinamikkeyvalue ('BOUQET_HD')); -- HD_BOUQET_ID:4348

                     IF NVL (dbs_dba.dbs_sabit ('HD_BUKE_SINYAL_AKTIF'), 'H') =
                           'H'
                     THEN
                        v_reset_channel_order := FALSE; --HD ICIN YENI BOUQET SINYALI CIKMA
                     END IF;
                  /*[EBerker20131030]-Turksat HD Buke*/
                  WHEN 3
                  THEN
                     v_bouqet_tms_attribute := 'BOUQUET=3';
                     v_bouqet_id :=
                        TO_NUMBER (getdinamikkeyvalue ('TURKSAT_BOUQET_HD')); -- TURKSAT_HD_BOUQET_ID:151

                     IF NVL (
                           dbs_dba.dbs_sabit ('TURKSAT_HD_BUKE_SINYAL_AKTIF'),
                           'H') = 'H'
                     THEN
                        v_reset_channel_order := FALSE; --TURKSAT HD ICIN YENI BOUQET SINYALI CIKMA
                     END IF;
                  WHEN 0
                  THEN
                     --TURKSAT DEFAULT BUKE ID :132
                     --EUTELSAT DEFAULT BUKE ID:128
                     v_bouqet_tms_attribute := 'BOUQUET=0';

                     IF v_uye_uydu_tipi = 2
                     THEN
                        v_bouqet_id :=
                           TO_NUMBER (
                              getdinamikkeyvalue ('TURKSAT_BOUQET_DEFAULT'));
                     ELSE
                        v_bouqet_id :=
                           TO_NUMBER (getdinamikkeyvalue ('BOUQET_DEFAULT'));
                     END IF;
               END CASE;
            END IF;
         END IF;
      END; --TUNAHAN 12.11.2011 BOUQET BITIR-----------------------------------------------------------------------------------------------------

      BEGIN --TUNA:01.06.2012PAKET TMS DEGERLERININ BELIRLENMESI, BU TIP TMSLER GLOBA MESAJLAR ICIN KULLANILIR VE FILTER PRODUCT SINYALI CIKMAZLAR
         dbs_addr.trace_addr (v_serial_number,
                              'TMS_DERBIBO_BASLA',
                              v_trace_order_cnt);                      --TRACE

         IF v_kart_abonede
         THEN
            v_tms_spor :=
               get_paket_tms_value (p_serial_number,
                                    'SPOR',
                                    v_derbisiz_filter_dusur,
                                    v_derbisiz_filter_ekle); --Spor paketi(Ligtv) 1:var, 0:yok
         ELSE
            v_tms_spor := 0;
            v_derbisiz_filter_dusur := TRUE;
            v_derbisiz_filter_ekle := FALSE;
         END IF;

         check_if_tms_attr_exists (p_serial_number,
                                   p_req_user,
                                   'SPOR',
                                   v_tms_spor,
                                   v_tms_spor_old,
                                   p_errm,
                                   p_out_tms);

         /*TRACE*/
         IF v_derbisiz_filter_dusur
         THEN
            dbs_addr.trace_addr (v_serial_number,
                                 'v_derbisiz_filter_dusur:TRUE',
                                 v_trace_order_cnt);
         ELSE
            dbs_addr.trace_addr (v_serial_number,
                                 'v_derbisiz_filter_dusur:FALSE',
                                 v_trace_order_cnt);
         END IF;

         IF v_derbisiz_filter_ekle
         THEN
            dbs_addr.trace_addr (v_serial_number,
                                 'v_derbisiz_filter_ekle:TRUE',
                                 v_trace_order_cnt);
         ELSE
            dbs_addr.trace_addr (v_serial_number,
                                 'v_derbisiz_filter_ekle:FALSE',
                                 v_trace_order_cnt);
         END IF;

         /*TRACE*/

         IF (NVL (dbs_addr.getdinamikkeyvalue ('TMS_DERBI_FILTER_AKTIF'),
                  'H') = 'E')
         THEN
            --5301 YETKISININ DERBISIZ PAKETLERE EKLENMESI VE CIKARILMASI...TUNA 29.02.2011
            IF v_derbisiz_filter_dusur
            THEN
               v_tms_derbi_filter := 0;                      --YOK/DUSURULMELI
            ELSIF v_derbisiz_filter_ekle
            THEN
               v_tms_derbi_filter := 1;                     --OLMALI/EKLENMELI
            END IF;

            dbs_addr.trace_addr (v_serial_number,
                                 'v_tms_derbi_filter:' || v_tms_derbi_filter,
                                 v_trace_order_cnt);                   --TRACE

            check_if_tms_attr_exists (p_serial_number,
                                      p_req_user,
                                      'DERBIBO', --DERBI BLACK OUT PRODUCTI VAR/YOK ICIN
                                      v_tms_derbi_filter,
                                      v_tms_derbi_filter_old,
                                      p_errm,
                                      p_out_tms,
                                      'H');

            dbs_addr.trace_addr (
               v_serial_number,
               'v_tms_derbi_filter:' || TO_CHAR (v_tms_derbi_filter),
               v_trace_order_cnt);                                     --TRACE
            dbs_addr.trace_addr (
               v_serial_number,
                  'v_tms_derbi_filter_old:'
               || TO_CHAR (NVL (v_tms_derbi_filter_old, -1)),
               v_trace_order_cnt);                                     --TRACE

            IF v_tms_derbi_filter <> NVL (v_tms_derbi_filter_old, -1)
            THEN
               IF    v_derbisiz_filter_dusur
                  OR (    v_tms_derbi_filter = 0
                      AND NVL (v_tms_derbi_filter_old, -1) = 1)
               THEN
                  dbs_addr.trace_addr (v_serial_number,
                                       '5301_DUSUR_OK',
                                       v_trace_order_cnt);             --TRACE

                  IF v_cancel_product_list IS NULL
                  THEN
                     v_cancel_product_list :=
                        dbs_addr.getdinamikkeyvalue ('TMS_DERBI_FILTER_PRD'); --DUSURLECEKLER ICINE DERBISIZ LIG TV BLOCKOUT PRODUCTINIDA EKLE.
                  ELSE
                     v_cancel_product_list :=
                           v_cancel_product_list
                        || ','
                        || dbs_addr.getdinamikkeyvalue (
                              'TMS_DERBI_FILTER_PRD'); --DUSURLECEKLER ICINE DERBISIZ LIG TV BLOCKOUT PRODUCTINIDA EKLE.
                  END IF;

                  v_filter_sinyal_ciksin := TRUE;
               ELSIF    v_derbisiz_filter_ekle
                     OR (    v_tms_derbi_filter = 1
                         AND NVL (v_tms_derbi_filter_old, -1) = 1)
               THEN
                  dbs_addr.trace_addr (v_serial_number,
                                       '5301_EKLE_OK',
                                       v_trace_order_cnt);             --TRACE

                  IF v_add_product_list IS NULL
                  THEN
                     v_add_product_list :=
                        dbs_addr.getdinamikkeyvalue ('TMS_DERBI_FILTER_PRD'); --EKELENECEKLER ICINE DERBISIZ LIG TV BLOCKOUT PRODUCTINIDA EKLE.
                  ELSE
                     v_add_product_list :=
                           v_add_product_list
                        || ','
                        || dbs_addr.getdinamikkeyvalue (
                              'TMS_DERBI_FILTER_PRD'); --EKELENECEKLER ICINE DERBISIZ LIG TV BLOCKOUT PRODUCTINIDA EKLE.
                  END IF;

                  v_filter_sinyal_ciksin := TRUE;
               END IF;
            END IF;
         --5301 YETKISININ DERBISIZ PAKETLERE EKLENMESI VE CIKARILMASI...TUNA 29.02.2011
         END IF;

         dbs_addr.trace_addr (
            v_serial_number,
            'v_add_product_list:' || NVL (v_add_product_list, ''),
            v_trace_order_cnt);                                        --TRACE
         dbs_addr.trace_addr (
            v_serial_number,
            'v_cancel_product_list:' || NVL (v_cancel_product_list, ''),
            v_trace_order_cnt);                                        --TRACE
         dbs_addr.trace_addr (v_serial_number,
                              'TMS_DERBIBO_BITIR',
                              v_trace_order_cnt);                      --TRACE

         IF     NVL (dbs_dba.dbs_sabit ('SINEMA_TMS_AKTIF'), 'H') = 'E'
            AND v_kart_abonede
         THEN
            v_tms_sinema :=
               get_paket_tms_value (p_serial_number,
                                    'SINEMA',
                                    v_dumy_boolean,
                                    v_dumy_boolean); --Sinema+Dizi paketi ueyede 1:var, 0:yok
         END IF;

         check_if_tms_attr_exists (p_serial_number,
                                   p_req_user,
                                   'SINEMA',
                                   v_tms_sinema,
                                   v_tms_sinema_old,
                                   p_errm,
                                   p_out_tms);

         IF     NVL (dbs_dba.dbs_sabit ('EROTIK_TMS_ AKTIF'), 'H') = 'E'
            AND v_kart_abonede
         THEN
            v_tms_erotik :=
               get_paket_tms_value (p_serial_number,
                                    'EROTIK',
                                    v_dumy_boolean,
                                    v_dumy_boolean); --Erotik paketlerden en az biri ueyede 1:var, 0:yok
         END IF;

         check_if_tms_attr_exists (p_serial_number,
                                   p_req_user,
                                   'EROTIK',
                                   v_tms_erotik,
                                   v_tms_erotik_old,
                                   p_errm,
                                   p_out_tms);
      END;              --TUNA:PAKET TMS DEGERLERININ BELIRLENMESI--06.01.2012

      IF p_out_tms IS NOT NULL OR v_filter_sinyal_ciksin
      THEN
         log_pack.log_mesaj_takip (p_serial_number,
                                   v_account_number, --p_account_number           number,
                                   NULL,  --p_prospect_number          number,
                                   v_service_address_id, --p_service_address_id       number,
                                   NULL, --p_equip_location_code      varchar2,
                                   p_req_user, --p_kisi                     varchar2,
                                   v_req_date, --p_islem_tarihi             date,
                                   v_req_dbs_type, --p_islem_tipi               number,
                                   NULL,  --p_ppv_kredi_limiti         number,
                                   NULL,  --p_msg_account_number       number,
                                   NULL, --p_msg_serial_number        varchar2,
                                   NULL, --p_mesaj_metni              varchar2,
                                   NULL, --p_channel_map_1            lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2            lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3            lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4            lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                        lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RETURN;
         END IF;

         --TUNA 12.10.2011: BASLA:BOQUET SINYALLERI CIKILIYOR EKIPMANIN KANAL SIRASINI DEGISTIRIR.-----------------
         IF v_reset_channel_order
         THEN
            IF v_uye_uydu_tipi = 2
            THEN
               /*[EBerker20140326] - TURKSAT HD Bouquet*/
               --TURKSAT:SD veya HD kurulum için Bouquet sinyali öncesi set other mode cikiliyor
               --Buradan alınan hata akısı kesmeyecektir.
               addressability_pack.setothermode (v_account_number,
                                                 v_serial_number,
                                                 v_st_ekipman_no,
                                                 '1',
                                                 'SYSADDRLO',
                                                 p_errm);
            END IF;

            v_ret := 0;
            v_ret :=
               reset_bouquet_channel_order (23,
                                            p_serial_number,
                                            v_bouqet_id,
                                            v_bouqet_tms_attribute,
                                            v_req_date,
                                            p_req_user,
                                            v_tra_id,
                                            p_errm);

            IF v_ret <> 1
            THEN
               p_errm :=
                     'procedure find_tms: reset_bouquet_channel_order :'
                  || p_errm;
            ELSE
               p_errm := '0';
            END IF;
         END IF;

         --BITIR:BASLA:BOQUET SINYALLERI CIKILIYOR-------------------------------------

         IF p_out_tms IS NOT NULL
         THEN
            v_ret := 0;
            v_ret :=
               create_tms_attributes (v_req_dbs_type,
                                      p_serial_number,
                                      p_out_tms,
                                      v_req_date,
                                      p_req_user,
                                      v_tra_id,
                                      p_errm,
                                      'H');
         END IF;

         IF v_ret <> 1
         THEN
            p_errm := 'procedure find_tms: create_tms_attributes :' || p_errm;
         ELSE
            p_errm := '0';
         END IF;

         IF v_cancel_product_list IS NOT NULL
         THEN
            dbs_addr.trace_addr (
               v_serial_number,
               'DE_v_cancel_product_list:' || NVL (v_cancel_product_list, ''),
               v_trace_order_cnt);                                     --TRACE
            v_ret := 0;
            v_ret :=
               delete_entitlements (v_req_dbs_type,
                                    v_serial_number,
                                    v_cancel_product_list,
                                    SYSDATE,
                                    p_req_user,
                                    v_tra_id,
                                    p_errm,
                                    'H');

            IF v_ret <> 1
            THEN
               p_errm := 'procedure find_tms_delete_product:' || p_errm;
            ELSE
               p_errm := '0';
            END IF;
         END IF;

         IF v_add_product_list IS NOT NULL
         THEN
            dbs_addr.trace_addr (
               v_serial_number,
               'AE_v_add_product_list:' || NVL (v_add_product_list, ''),
               v_trace_order_cnt);                                     --TRACE
            v_ret := 0;
            v_ret :=
               create_entitlements (v_req_dbs_type,
                                    v_serial_number,
                                    v_add_product_list,
                                    SYSDATE,
                                    p_req_user,
                                    v_tra_id,
                                    p_errm,
                                    'H');

            IF v_ret <> 1
            THEN
               p_errm := 'procedure find_tms_add_product:' || p_errm;
            ELSE
               p_errm := '0';
            END IF;
         END IF;
      END IF;

      dbs_addr.trace_addr (v_serial_number,
                           'p_errm' || SUBSTR (p_errm, 1, 255),
                           v_trace_order_cnt);                         --TRACE
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errm :=
            'procedure find_tms:p_out_tms:' || p_out_tms || ':' || SQLERRM;
         dbs_addr.trace_addr (v_serial_number,
                              'Exp_p_errm' || SUBSTR (p_errm, 1, 255),
                              v_trace_order_cnt);                      --TRACE
   END;

   /********************************************************************************************************************/
   FUNCTION set_schedule_ippv_report (
      p_req_dbs_type                IN     VARCHAR2,
      p_serial_number               IN     VARCHAR2,
      p_status                      IN     VARCHAR2,
      p_prev_callback_dateandtime   IN     VARCHAR2,
      p_curr_callback_dateandtime   IN     VARCHAR2,
      p_valid_after                 IN     DATE,
      p_req_user                    IN     VARCHAR2,
      p_tra_id                      IN OUT NUMBER,
      p_errm                           OUT VARCHAR2,
      p_logla                       IN     CHAR DEFAULT 'E',
      p_req_id                      IN     NUMBER DEFAULT NULL,
      p_chk_acc_out_f_signal        IN     CHAR DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                    DATE := SYSDATE;
      v_req_type                    NUMBER (3)
                                       := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type              NUMBER (2);
      v_account_number              wiz_equip.account_number%TYPE;
      v_outlet_location             wiz_equip.outlet_location%TYPE;
      v_param                       VARCHAR2 (1000);
      v_req_param                   VARCHAR2 (1000);
      v_req_id                      NUMBER (10);
      v_durum                       VARCHAR2 (400);
      v_tra_id                      NUMBER;
      v_year                        CHAR (7);
      v_month                       CHAR (4);
      v_day                         CHAR (5);
      v_hour                        CHAR (2);
      v_minute                      CHAR (2);
      v_prev_callback_dateandtime   VARCHAR2 (16);
      v_curr_callback_dateandtime   VARCHAR2 (16);
      v_status                      VARCHAR2 (2);
      v_msg_length                  VARCHAR2 (4);
      v_all_msg_length              VARCHAR2 (4);
      v_destination                 VARCHAR2 (4) := '0001';
      v_tag                         VARCHAR2 (2) := '06';
      v_ekipman_tip_matrix_id       NUMBER (10);
      v_ekipman_ozellik             VARCHAR2 (3);
      input_exception               EXCEPTION;
      log_exception                 EXCEPTION;

      v_modem_destekli              BOOLEAN := FALSE;
      v_ethernet_destekli           BOOLEAN := FALSE;
   BEGIN
      IF p_chk_acc_out_f_signal IS NULL OR p_chk_acc_out_f_signal = 'E'
      THEN
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);
      ELSE
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   FALSE,
                                   FALSE);
      END IF;

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
         -- 08/08/2011; Taner; sadece (modem veya ethernet) destekli kutulara IPPV yetkilerinin cikmasi isteniyor

         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       66                            /*modem*/
                                         ,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_modem_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       101                        /*ethernet*/
                                          ,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_ethernet_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         IF v_modem_destekli = FALSE AND v_ethernet_destekli = FALSE
         THEN
            RETURN 1;              -- ne MODEM ne de ETHERNET destekli degil..
         END IF;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      --STATUS '00000001' means enable scheduling
      --STATUS '00000000' means disable scheduling
      IF p_status <> '1' AND p_status <> '0'
      THEN
         p_errm := 'Status hatali!';
         RAISE input_exception;
      ELSE
         v_status := LPAD (p_status, 2, 0);
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      --p_status      : When this 8-bit field is set to 0x01 scheduling is enabled. Otherwise it is disabled and the following fields are ignored
      --p_report_date : This 16-bit field specifies the scheduled callback date information which is defined according to the Cryptoworks date format[1].
      --p_report_time : The RANGE IS 0000 - 2359, 9999 disables scheduled reporting FOR IPPV callback
      IF p_prev_callback_dateandtime = '99.99.99'
      THEN
         v_prev_callback_dateandtime :=
            '9999.99.' || p_prev_callback_dateandtime;
      ELSE
         v_prev_callback_dateandtime :=
            '2111.00.' || p_prev_callback_dateandtime;
      END IF;

      IF p_curr_callback_dateandtime = '99.99.99'
      THEN
         v_curr_callback_dateandtime :=
            '9999.99.' || p_curr_callback_dateandtime;
      ELSE
         v_curr_callback_dateandtime :=
            '2111.00.' || p_curr_callback_dateandtime;
      END IF;

      /*
      dbms_output.put_line(SUBSTR ( 'YEAR :'||v_curr_callback_dateandtime,  0, 4 ));
      dbms_output.put_line(SUBSTR ( 'HOUR :'||v_curr_callback_dateandtime, 12, 2 ));
      dbms_output.put_line(SUBSTR ( 'MINU :'||v_curr_callback_dateandtime, 15, 2 ));
      dbms_output.put_line(SUBSTR ( 'DAY  :'||v_curr_callback_dateandtime,  9, 2 ));
      */

      IF v_prev_callback_dateandtime <> v_curr_callback_dateandtime
      THEN
         v_year :=
            TO_CHAR (
               dbms_numsystem_package.dec2bin (
                    TO_NUMBER (SUBSTR (v_curr_callback_dateandtime, 0, 4))
                  - 1990));
         v_hour := SUBSTR (v_curr_callback_dateandtime, 12, 2);
         v_minute := SUBSTR (v_curr_callback_dateandtime, 15, 2);

         IF LENGTH (v_hour) = 1
         THEN
            v_hour := '0' || v_hour;
         END IF;

         IF LENGTH (v_minute) = 1
         THEN
            v_minute := '0' || v_minute;
         END IF;

         /*
         IF LENGTH ( TO_CHAR ( Dbms_Numsystem_Package.hex2dec ( v_hour ))) = 1 THEN
            v_hour    := '0' || TO_CHAR ( Dbms_Numsystem_Package.hex2dec ( v_hour ));
         ELSE
            v_hour    := TO_CHAR ( Dbms_Numsystem_Package.hex2dec ( v_hour ));
         END IF;

         IF LENGTH ( TO_CHAR ( Dbms_Numsystem_Package.hex2dec ( v_minute ))) = 1 THEN
            v_minute  := '0' || TO_CHAR ( Dbms_Numsystem_Package.hex2dec ( v_minute ));
         ELSE
            v_minute  := TO_CHAR ( Dbms_Numsystem_Package.hex2dec ( v_minute ));
         END IF;
         */
         v_day :=
            LPAD (
               TO_CHAR (
                  dbms_numsystem_package.dec2bin (
                     SUBSTR (v_curr_callback_dateandtime, 9, 2))),
               5,
               0);

         IF SUBSTR (v_curr_callback_dateandtime, 0, 4) = '2111'
         THEN                                           --PERIODIC EVERY MONTH
            v_month := '0000';
         ELSE                                   --NONPERIODIC MONTH IS DEFINED
            v_month :=
               TO_CHAR (
                  dbms_numsystem_package.dec2bin (
                     SUBSTR (v_curr_callback_dateandtime, 6, 2)));
         END IF;

         v_param := v_year || v_month || v_day;

         --dbms_output.put_line('v_param_bin        :'||v_param);
         v_param := dbms_numsystem_package.bin2dec (v_param);
         --dbms_output.put_line('v_param_dec        :'||v_param);
         v_param := dbms_numsystem_package.dec2hex (v_param);
         --dbms_output.put_line('v_param_hex        :'||v_param);
         v_param := v_param || v_hour || v_minute;
         --dbms_output.put_line('v_param             :'||v_param);
         v_param := v_status || v_param;
         --dbms_output.put_line('v_param:'||v_param);
         --dbms_output.put_line('v_param length:'||LENGTH(v_param));

         --v_length     := LENGTH(v_param)/2;
         --v_msg_length := LENGTH(v_param) + 2;
         --v_msg_length := Dbms_Numsystem_Package.dec2hex(v_msg_length);
         --dbms_output.put_line('v_length     :'||v_length);
         --dbms_output.put_line('v_msg_length :'||v_msg_length);
         v_msg_length := LPAD (LENGTH (v_param) / 2, 4, 0);
         v_all_msg_length :=
            LPAD (
               dbms_numsystem_package.dec2hex (
                    LENGTH (
                          '3C00'
                       || v_destination
                       || v_tag
                       || v_msg_length
                       || v_param)
                  / 2),
               4,
               0);

         v_req_param :=
               '010003090001'
            || v_all_msg_length
            || '3C00'
            || v_destination
            || v_tag
            || v_msg_length
            || v_param;
      --dbms_output.put_line('v_req_param :'||v_req_param);
      /*Sample Data : v_req_param :010003090001|000C|3C00|0001|06|0005|01F2032203 */

      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,     --p_mesaj_metni         varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                   lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      IF     v_prev_callback_dateandtime <> v_curr_callback_dateandtime
         AND v_curr_callback_dateandtime <> '9999.99.99.99.99'
      THEN
         INSERT INTO dbs_addr_pisys_reqs                             /*_TEMP*/
                                         (tra_id,
                                          req_id,
                                          serial_number,
                                          account_number,
                                          req_dbs_type,
                                          req_group_type,
                                          req_type,
                                          req_user,
                                          req_date,
                                          valid_after,
                                          req_param,
                                          is_ird)
              VALUES (v_tra_id,
                      v_req_id,
                      p_serial_number,
                      v_account_number,
                      p_req_dbs_type,
                      v_req_group_type,
                      v_req_type,
                      p_req_user,
                      v_req_date,
                      p_valid_after,
                      v_req_param,
                      'Y');
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION recover_sector_date_code (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_year            IN     NUMBER,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id             OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_recover_sector_date_code;   --77;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_year;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                    varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION overwrite_parental_pin_code (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_overwrite_parental_p_code;  --15;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := NULL;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number           varchar2,
                                   v_account_number, --p_account_number         number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,   --p_service_address_id      number,
                                   NULL, --p_equip_location_code     varchar2,
                                   p_req_user, --p_kisi                    varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,   --p_msg_account_number      number,
                                   NULL, --p_msg_serial_number       varchar2,
                                   NULL, --p_mesaj_metni             varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   p_tra_id, --out                          lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION configure_call_back (
      p_req_dbs_type             IN     VARCHAR2,
      p_serial_number            IN     VARCHAR2,
      p_call_back_phone_number   IN     VARCHAR2,
      p_caller_id                IN     NUMBER,
      p_valid_after              IN     DATE,
      p_req_user                 IN     VARCHAR2,
      p_tra_id                   IN OUT NUMBER,
      p_errm                        OUT VARCHAR2,
      p_logla                    IN     CHAR DEFAULT 'E',
      p_req_id                   IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                 DATE := SYSDATE;
      v_req_type                 NUMBER (3)
                                    := dbs_addr_pisys_msg_type_defs.m_t_configure_callback; --99;
      v_req_group_type           NUMBER (2);
      v_account_number           wiz_equip.account_number%TYPE;
      v_outlet_location          wiz_equip.outlet_location%TYPE;
      v_req_param                VARCHAR2 (1000);
      v_req_id                   NUMBER (10);
      v_durum                    VARCHAR2 (400);
      v_tra_id                   NUMBER;
      v_ekipman_tip_matrix_id    NUMBER (10);
      v_ekipman_ozellik          VARCHAR2 (3);
      input_exception            EXCEPTION;
      log_exception              EXCEPTION;
      v_call_back_phone_number   VARCHAR2 (8);
      v_caller_id                NUMBER;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
         -- 28/01/2009; emine; sadece modem destekli kutulara ippv yetkilerinin cikmasi isteniyor
         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       66,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);

         IF v_ekipman_ozellik IS NULL OR v_ekipman_ozellik <> 'E'
         THEN
            RETURN 1;
         END IF;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      /* 24/12/2008; Emine
      Asagidaki block commentlendi, telefon numarasinin alan kodsuz ve ascii olarak gönderilmesi saglandi (Gökhan Korkut)*/
      /*IF p_call_back_phone_number IS NULL THEN
          v_call_back_phone_number :=  Dbms_Numsystem_Package.dec2hex(TO_NUMBER('0212'||'3260880'));
      ELSE
          v_call_back_phone_number := Dbms_Numsystem_Package.dec2hex(TO_NUMBER('0212'||p_call_back_phone_number));
      END IF;*/

      IF p_call_back_phone_number IS NOT NULL
      THEN
         v_call_back_phone_number := p_call_back_phone_number;
      ELSE
         BEGIN
            SELECT phone_number
              INTO v_call_back_phone_number
              FROM dbs_addr_params;                                  --3260880
         EXCEPTION
            WHEN OTHERS
            THEN
               v_call_back_phone_number := NULL;
         END;
      END IF;

      IF p_caller_id IS NULL
      THEN
         v_caller_id := 1;
      ELSE
         v_caller_id := p_caller_id;
      END IF;

      v_req_param := v_call_back_phone_number || '|' || v_caller_id;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number            varchar2,
                                   v_account_number, --p_account_number           number,
                                   NULL,  --p_prospect_number          number,
                                   NULL,  --p_service_address_id       number,
                                   NULL, --p_equip_location_code      varchar2,
                                   p_req_user, --p_kisi                     varchar2,
                                   v_req_date, --p_islem_tarihi             date,
                                   p_req_dbs_type, --p_islem_tipi               number,
                                   NULL,  --p_ppv_kredi_limiti         number,
                                   NULL,  --p_msg_account_number       number,
                                   NULL, --p_msg_serial_number        varchar2,
                                   NULL, --p_mesaj_metni              varchar2,
                                   NULL, --p_channel_map_1            lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2            lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3            lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4            lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   p_tra_id, --out                          lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION overwrite_nationality (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_nationality     IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_overwrite_nationality;      --86;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_nationality) > 3
      THEN
         p_errm := 'Nationality hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_nationality;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION overwrite_sector_region (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_region_tag      IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_overwrite_sector_region;    --74;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_region_tag) > 2
      THEN
         p_errm := 'Region hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_region_tag;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION clear_3pa_data (p_req_dbs_type       IN     VARCHAR2,
                            p_serial_number      IN     VARCHAR2,
                            p_clear_flash_data   IN     VARCHAR2,
                            p_clear_eprom_data   IN     VARCHAR2,
                            p_valid_after        IN     DATE,
                            p_req_user           IN     VARCHAR2,
                            p_tra_id             IN OUT NUMBER,
                            p_errm                  OUT VARCHAR2,
                            p_logla              IN     CHAR DEFAULT 'E',
                            p_req_id             IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date           DATE := SYSDATE;
      v_req_type           NUMBER (3)
                              := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type     NUMBER (2);
      v_account_number     wiz_equip.account_number%TYPE;
      v_outlet_location    wiz_equip.outlet_location%TYPE;
      v_req_param          VARCHAR2 (1000);
      v_param              VARCHAR2 (1000);
      v_req_id             NUMBER (10);
      v_durum              VARCHAR2 (400);
      v_tra_id             NUMBER;
      v_clear_flash_data   VARCHAR2 (2);
      v_clear_eprom_data   VARCHAR2 (2);
      v_msg_length         VARCHAR2 (4);
      v_all_msg_length     VARCHAR2 (4);
      v_destination        VARCHAR2 (4) := '0002';
      v_tag                VARCHAR2 (2) := '08';
      input_exception      EXCEPTION;
      log_exception        EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF    p_clear_flash_data IS NULL
         OR LENGTH (p_clear_flash_data) != 1
         OR (p_clear_flash_data <> '0' AND p_clear_flash_data <> '1')
      THEN
         p_errm := 'p_clear_flash_data alani "0" veya "1" olabilir!';
         RAISE input_exception;
      END IF;

      IF    p_clear_eprom_data IS NULL
         OR LENGTH (p_clear_eprom_data) != 1
         OR (p_clear_eprom_data <> '0' AND p_clear_eprom_data <> '1')
      THEN
         p_errm := 'p_clear_eprom_data alani "0" veya "1" olabilir!';
         RAISE input_exception;
      END IF;

      --p_clear_flash_data = '00000001' means 3PA area of Flash should be erased.
      --p_clear_flash_data = '00000000' means 3PA area of Flash should NOT be erased.
      --p_clear_eprom_data = '00000001' means The 3PA area of EEPROM should be erased.
      --p_clear_eprom_data = '00000000' means The 3PA area of EEPROM should NOT be erased.
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_clear_flash_data := RAWTOHEX (p_clear_flash_data);
      v_clear_eprom_data := RAWTOHEX (p_clear_eprom_data);

      v_param :=
            LPAD (v_clear_flash_data, 2, '0')
         || LPAD (v_clear_eprom_data, 2, '0');

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);
      /*SAMPLE DATA : 010003090001|0009|3C00|0002|08|0002|0001 */

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION mail_tms_message_global (
      p_req_dbs_type     IN     VARCHAR2,
      p_tms_expression   IN     VARCHAR2,
      p_tms_duration     IN     NUMBER,
      p_tms_flashing     IN     NUMBER,
      p_tms_banner       IN     NUMBER,
      p_tms_coverage     IN     NUMBER,
      p_tms_text         IN     VARCHAR2,
      p_valid_after      IN     DATE,
      p_req_user         IN     VARCHAR2,
      p_tra_id           IN OUT NUMBER,
      p_errm                OUT VARCHAR2,
      p_logla            IN     CHAR DEFAULT 'E',
      p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_mail_tms_message_global;    --36;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      v_tms_coverage      NUMBER;
      v_tms_flashing      NUMBER;
      v_tms_banner        NUMBER;
      v_tms_duration      NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_tms_coverage > 100 OR p_tms_coverage < 0
      THEN
         p_errm := 'p_tms_coverage 0 - 100 arasinda olmalidir!';
         RAISE input_exception;
      ELSIF p_tms_coverage < 20 OR p_tms_coverage IS NULL
      THEN
         v_tms_coverage := 20;
      ELSE
         v_tms_coverage := p_tms_coverage;
      END IF;

      IF LENGTH (p_tms_text) > 255
      THEN
         p_errm := 'p_tms_text max 255 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_tms_expression) > 700
      THEN
         p_errm := 'p_tms_expression max 700 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF p_tms_flashing IS NULL
      THEN
         v_tms_flashing := 1;
      ELSE
         v_tms_flashing := p_tms_flashing;
      END IF;

      IF p_tms_banner IS NULL
      THEN
         v_tms_banner := 1;
      ELSE
         v_tms_banner := p_tms_banner;
      END IF;

      IF v_tms_duration IS NULL
      THEN
         v_tms_duration := 0;
      ELSE
         v_tms_duration := p_tms_duration;
      END IF;

      --p_tms_flashing := 0 means flashing
      --p_tms_flashing := 1 means normal text
      --p_tms_banner   := 0 means display text as banner
      --p_tms_banner   := 1 means display text as normal
      v_req_param :=
            p_tms_expression
         || '|'
         || v_tms_duration
         || '|'
         || v_tms_flashing
         || '|'
         || v_tms_banner
         || '|'
         || v_tms_coverage
         || '|'
         || p_tms_text;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip ('99999999999', --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   p_tms_text, --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   '99999999999',
                   0,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION send_tms_message_global (
      p_req_dbs_type     IN     VARCHAR2,
      p_tms_expression   IN     VARCHAR2,
      p_tms_duration     IN     NUMBER,
      p_tms_flashing     IN     NUMBER,
      p_tms_banner       IN     NUMBER,
      p_tms_coverage     IN     NUMBER,
      p_tms_text         IN     VARCHAR2,
      p_valid_after      IN     DATE,
      p_req_user         IN     VARCHAR2,
      p_tra_id           IN OUT NUMBER,
      p_errm                OUT VARCHAR2,
      p_logla            IN     CHAR DEFAULT 'E',
      p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_send_tms_message_global;    --98;
      v_req_group_type          NUMBER (2);
      v_req_param               VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;
      v_tms_coverage            NUMBER;
      v_tms_flashing            NUMBER;
      v_tms_banner              NUMBER;
      v_tms_duration            NUMBER;

      v_gonderim_oneri_tarihi   DATE;
      v_valid_after             DATE := p_valid_after;
      v_allowed_valid_after     DATE := p_valid_after; --aynı zamanli global sinyallerin çıkılmasi PVR kutularda sürekli restart sorununa yol açtığından bu değişkene ihtiyaç duyuldu tuna 10.04.2012
      v_trying_cnt              NUMBER
         := TO_NUMBER (
               NVL (
                  dbs_addr.getdinamikkeyvalue (
                     'TRYING_COUNT_FOR_GLB_SENDTMSMSG'),
                  '1'));

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
      global_risk_exception     EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_tms_coverage IS NULL OR p_tms_coverage < 20
      THEN
         v_tms_coverage := 20;
      ELSIF p_tms_coverage > 100 OR p_tms_coverage < 0
      THEN
         p_errm := 'p_tms_coverage 0 - 100 arasinda olmalidir!';
         RAISE input_exception;
      ELSE
         v_tms_coverage := p_tms_coverage;
      END IF;

      IF LENGTH (p_tms_text) > 255
      THEN
         p_errm := 'p_tms_text max 255 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_tms_expression) > 700
      THEN
         p_errm := 'p_tms_expression max 700 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF p_tms_flashing IS NOT NULL AND p_tms_flashing NOT IN (0, 1)
      THEN
         p_errm := 'p_tms_flashing parametresi ( 0 veya 1 ) olabilir !';
         RAISE input_exception;
      ELSE
         IF p_tms_flashing IS NULL OR p_tms_flashing = 0
         THEN
            v_tms_flashing := 1;                       -- normal (no_flashing)
         ELSIF p_tms_flashing = 1
         THEN
            v_tms_flashing := 0;                                   -- flashing
         END IF;
      END IF;

      IF p_tms_banner IS NOT NULL AND p_tms_banner NOT IN (0, 1)
      THEN
         p_errm := 'p_tms_banner parametresi ( 0 veya 1 ) olabilir !';
         RAISE input_exception;
      ELSE
         IF p_tms_banner IS NULL
         THEN
            v_tms_banner := 1;                                       -- normal
         ELSE
            v_tms_banner := p_tms_banner;
         END IF;
      END IF;

      IF p_tms_duration IS NULL
      THEN
         v_tms_duration := 0;
      ELSE
         v_tms_duration := p_tms_duration;
      END IF;

      --p_tms_flashing := 0 means flashing
      --p_tms_flashing := 1 means normal text
      --p_tms_banner   := 0 means display text as banner
      --p_tms_banner   := 1 means display text as normal
      v_req_param :=
            p_tms_expression
         || '|'
         || v_tms_duration
         || '|'
         || v_tms_flashing
         || '|'
         || v_tms_banner
         || '|'
         || v_tms_coverage
         || '|'
         || p_tms_text;

      /*BEGIN GLOBAL SINYAL VALID_AFTER KONTROLU
      GLOBAL SINYAL GONDERIMLERINDE SORUN TESKIL EDEN SINYALLER ICIN, SINYAL GONDERIM ZAMANI(VALID_AFTER) AYNI ZAMANLI OLMAMALI.. tunahan 10.04.2012 */
      IF v_req_type =
            dbs_addr_pisys_msg_type_defs.m_t_send_tms_message_global
      THEN
         p_errm :=
            dbs_dba.global_sinyal_kontrol (
               v_valid_after,
               dbs_addr_pisys_msg_type_defs.m_t_send_tms_message_global,
               v_trying_cnt,
               v_allowed_valid_after --önerilen global sinyal valid after ı...
                                    );

         IF p_errm <> '0'
         THEN
            RAISE global_risk_exception;
         ELSE
            p_errm := NULL;

            IF v_allowed_valid_after IS NOT NULL
            THEN
               v_valid_after := v_allowed_valid_after;
            END IF;
         END IF;
      END IF;

      /*END GLOBAL SINYAL VALID_AFTER KONTROLU*/

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip ('99999999999', --p_serial_number        varchar2,
                                   NULL,      --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   p_valid_after, --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   p_tms_text, --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id,    --out  lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   '99999999999',
                   0,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   v_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception OR global_risk_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION send_mail (p_req_dbs_type     IN     VARCHAR2,
                       p_serial_number    IN     VARCHAR2,
                       p_message          IN     VARCHAR2,
                       p_text_mode        IN     VARCHAR2,
                       p_valid_after      IN     DATE,
                       p_req_user         IN     VARCHAR2,
                       p_tra_id           IN OUT NUMBER,
                       p_errm                OUT VARCHAR2,
                       p_logla            IN     CHAR DEFAULT 'E',
                       p_req_id           IN     NUMBER DEFAULT NULL,
                       p_tms_attributes   IN     VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_send_mail;       --19;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_send_mail_global; --20;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF LENGTH (p_message) > 253
      THEN
         p_errm := 'p_message max 253 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF     p_text_mode <> 'Ansi'
         AND p_text_mode <> 'Raw'
         AND p_text_mode <> 'Unicode'
      THEN
         p_errm :=
            'p_text_mode Ansi, Raw, Unicode degerlerinden birini alabilir';
         RAISE input_exception;
      END IF;

      v_req_param := p_message || '|' || p_text_mode;

      IF     p_serial_number = '99999999999'
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_req_param := v_req_param || p_tms_attributes;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   p_message, --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION colour_display (p_req_dbs_type     IN     VARCHAR2,
                            p_serial_number    IN     VARCHAR2,
                            p_tms_attributes   IN     VARCHAR2,
                            p_row              IN     NUMBER,
                            p_col              IN     NUMBER,
                            p_flashing         IN     NUMBER,
                            p_back_type        IN     VARCHAR2,
                            p_back_colour      IN     VARCHAR2,
                            p_text_colour      IN     VARCHAR2,
                            p_duration         IN     NUMBER,
                            p_text             IN     VARCHAR2,
                            p_valid_after      IN     DATE,
                            p_req_user         IN     VARCHAR2,
                            p_tra_id           IN OUT NUMBER,
                            p_errm                OUT VARCHAR2,
                            p_logla            IN     CHAR DEFAULT 'E',
                            p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_param             VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_row               VARCHAR2 (4);
      v_col               VARCHAR2 (4);
      v_flashing          VARCHAR2 (2);
      v_back_type         VARCHAR2 (2);
      v_back_colour       VARCHAR2 (2);
      v_text_colour       VARCHAR2 (2);
      v_duration          VARCHAR2 (2);
      v_text_len          VARCHAR2 (2);
      v_length_of_text    NUMBER;
      v_text              VARCHAR2 (32767);

      v_msg_length        VARCHAR2 (4);
      v_all_msg_length    VARCHAR2 (4);
      v_destination       VARCHAR2 (4) := '0002';
      v_tag               VARCHAR2 (2) := '09';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_row IS NULL OR p_row = 0
      THEN
         v_row := '0000';
      ELSE
         v_row := LPAD (dbms_numsystem_package.dec2hex (p_row), 4, '0');
      END IF;

      IF p_col IS NULL OR p_col = 0
      THEN
         v_col := '0000';
      ELSE
         v_col := LPAD (dbms_numsystem_package.dec2hex (p_col), 4, '0');
      END IF;

      IF p_flashing IS NULL OR p_flashing = 0
      THEN
         v_flashing := '00';
      ELSE
         v_flashing :=
            LPAD (dbms_numsystem_package.dec2hex (p_flashing), 2, '0');
      END IF;

      /*p_back_type : 0x00 - 0x08*/
      IF p_back_type IS NULL OR LENGTH (p_back_type) = 0 OR p_back_type = '0'
      THEN
         v_back_type := '00';
      ELSE
         v_back_type :=
            LPAD (dbms_numsystem_package.dec2hex (p_back_type), 2, '0');
      END IF;

      /*p_back_colour : 0x00 - 0x07*/
      IF    p_back_colour IS NULL
         OR LENGTH (p_back_colour) = 0
         OR p_back_colour = '0'
      THEN
         v_back_colour := '00';
      ELSE
         v_back_colour :=
            LPAD (dbms_numsystem_package.dec2hex (p_back_colour), 2, '0');
      END IF;

      /*p_text_colour : 0x00 - 0x07*/
      IF    p_text_colour IS NULL
         OR LENGTH (p_text_colour) = 0
         OR p_text_colour = '0'
      THEN
         v_text_colour := '00';
      ELSE
         v_text_colour :=
            LPAD (dbms_numsystem_package.dec2hex (p_text_colour), 2, '0');
      END IF;

      /*p_back_colour : e.g. 10 means 10 seconds*/
      IF p_duration IS NULL OR p_duration = 0
      THEN
         v_duration := '00';
      ELSE
         v_duration :=
            LPAD (dbms_numsystem_package.dec2hex (p_duration), 2, '0');
      END IF;

      /* Gökhan 8'in katları yapma olayının gereksiz olduğunu söyediği için aşağıdaki satır commentlendi.
      Zaten bu şekilde kalsaydı 8'in katı uzunluklar için yanlış çalışıyordu, müdahale edilmesi gerekiyordu.
      Emine; 25/12/2009 */
      --SELECT RAWTOHEX(RPAD(p_text, LENGTH(p_text) + 8-MOD(LENGTH(p_text), 8), ' ')) INTO v_text FROM dual;
      SELECT RAWTOHEX (p_text) INTO v_text FROM DUAL;

      v_length_of_text := LENGTH (v_text) / 2;
      v_text_len :=
         LPAD (dbms_numsystem_package.dec2hex (v_length_of_text), 2, '0');
      v_param :=
            v_row
         || v_col
         || v_flashing
         || v_back_type
         || v_back_colour
         || v_text_colour
         || v_duration
         || v_text_len
         || v_text;
      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_param := v_param || '|' || p_tms_attributes;
      END IF;

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                   varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   p_text, --p_mesaj_metni             varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                      lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION display_card_number (
      p_req_dbs_type     IN     VARCHAR2,
      p_x_pos            IN     NUMBER,
      p_y_pos            IN     NUMBER,
      p_duration         IN     NUMBER,
      p_valid_after      IN     DATE,
      p_req_user         IN     VARCHAR2,
      p_tra_id           IN OUT NUMBER,
      p_errm                OUT VARCHAR2,
      p_serial_number    IN     VARCHAR2,
      p_tms_attributes   IN     VARCHAR2 DEFAULT NULL,
      p_logla            IN     CHAR DEFAULT 'E',
      p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_param             VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      v_x_pos             VARCHAR2 (4);
      v_y_pos             VARCHAR2 (4);
      v_duration          VARCHAR2 (2);
      v_msg_length        VARCHAR2 (4);
      v_all_msg_length    VARCHAR2 (4);
      v_destination       VARCHAR2 (4) := '0002';
      v_tag               VARCHAR2 (2) := '03';
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF p_serial_number = '99999999999'
      THEN
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
      ELSE
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_x_pos := LPAD (dbms_numsystem_package.dec2hex (p_x_pos), 4, '0');
      v_y_pos := LPAD (dbms_numsystem_package.dec2hex (p_y_pos), 4, '0');
      v_duration := LPAD (dbms_numsystem_package.dec2hex (p_duration), 2, '0');

      v_param := v_x_pos || v_y_pos || v_duration;
      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
      THEN
         v_req_param :=
               '010003090001'
            || v_all_msg_length
            || '3C00'
            || v_destination
            || v_tag
            || v_msg_length
            || v_param
            || '|'
            || p_tms_attributes;
      ELSE
         v_req_param :=
               '010003090001'
            || v_all_msg_length
            || '3C00'
            || v_destination
            || v_tag
            || v_msg_length
            || v_param;
      END IF;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   0,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION send_message (p_req_dbs_type     IN     VARCHAR2,
                          p_serial_number    IN     VARCHAR2,
                          p_message          IN     VARCHAR2,
                          p_text_mode        IN     VARCHAR2,
                          p_valid_after      IN     DATE,
                          p_req_user         IN     VARCHAR2,
                          p_tra_id           IN OUT NUMBER,
                          p_errm                OUT VARCHAR2,
                          p_logla            IN     CHAR DEFAULT 'E',
                          p_req_id           IN     NUMBER DEFAULT NULL,
                          p_tms_attributes   IN     VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_send_message; --21;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_send_message;    --21;
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_send_message_global; --22;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF    p_message IS NULL
         OR LENGTH (TRIM (p_message)) <= 0
         OR LENGTH (p_message) > 253
      THEN
         p_errm := 'p_message min 1 karakter, max 253 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF     p_text_mode <> 'ANSI'
         AND p_text_mode <> 'Raw'
         AND p_text_mode <> 'Unicode'
      THEN
         p_errm :=
            'p_text_mode  (''ANSI'', ''Raw'', ''Unicode'')  degerlerinden birini alabilir';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := p_message || '|' || p_text_mode;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   p_valid_after, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   p_message, --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION set_ippv_callback_information (
      p_req_dbs_type           IN     VARCHAR2,
      p_serial_number          IN     VARCHAR2,
      p_phone_no               IN     VARCHAR2,
      p_ip_address             IN     VARCHAR2,
      p_port                   IN     VARCHAR2,
      p_valid_after            IN     DATE,
      p_req_user               IN     VARCHAR2,
      p_tra_id                 IN OUT NUMBER,
      p_errm                      OUT VARCHAR2,
      p_logla                  IN     CHAR DEFAULT 'E',
      p_req_id                 IN     NUMBER DEFAULT NULL,
      p_chk_acc_out_f_signal   IN     CHAR DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3)
                                   := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_param                   VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;
      v_phone_no                VARCHAR2 (16);
      v_phone_no_ascii          VARCHAR2 (32);
      v_ip_address              VARCHAR2 (8);
      v_port                    VARCHAR2 (4);
      v_msg_length              VARCHAR2 (4);
      v_all_msg_length          VARCHAR2 (4);
      v_destination             VARCHAR2 (4) := '0001';
      v_tag                     VARCHAR2 (2) := '04';
      v_len                     NUMBER;
      v_ekipman_tip_matrix_id   NUMBER (10);
      v_ekipman_ozellik         VARCHAR2 (3);
      input_exception           EXCEPTION;
      log_exception             EXCEPTION;

      v_modem_destekli          BOOLEAN := FALSE;
      v_ethernet_destekli       BOOLEAN := FALSE;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_chk_acc_out_f_signal IS NULL OR p_chk_acc_out_f_signal = 'E'
      THEN
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);
      ELSE
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   FALSE,
                                   FALSE);
      END IF;

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
         -- 28/01/2009; emine; modem destekli kutulara ippv yetkileri cikabilir.. Tabi IP adresi farkli olarak..
         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       66,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_modem_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');
         -- 08/07/2011; taner; ethernet destekli kutulara ippv yetkileri cikabilir.. Tabi IP adresi farkli olarak..
         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       101,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_ethernet_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         IF v_modem_destekli = FALSE AND v_ethernet_destekli = FALSE
         THEN
            RETURN 1;              -- ne MODEM ne de ETHERNET destekli degil..
         END IF;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      /* 24/12/2008; Emine
      Asagidaki block commentlendi, telefon numarasinin alan kodsuz ve ascii olarak gönderilmesi saglandi (Gökhan Korkut)*/
      /*IF p_phone_no IS NULL THEN
          SELECT phone_number INTO v_phone_no FROM DBS_ADDR_PARAMS;--3260880
         v_phone_no := Dbms_Numsystem_Package.dec2hex(TO_NUMBER('0212'||v_phone_no));
      ELSE
          v_phone_no := p_phone_no;
      END IF;*/

      IF p_phone_no IS NOT NULL
      THEN
         v_phone_no := p_phone_no;
      ELSE
         BEGIN
            SELECT phone_number INTO v_phone_no FROM dbs_addr_params; --3260880
         EXCEPTION
            WHEN OTHERS
            THEN
               v_phone_no := NULL;
         END;
      END IF;

      IF v_phone_no IS NOT NULL
      THEN
         v_len := LENGTH (v_phone_no);

         FOR c IN 1 .. v_len
         LOOP
            v_phone_no_ascii :=
                  v_phone_no_ascii
               || NVL (
                     dbs_addr.dbms_numsystem_package.dec2hex (
                        ASCII (SUBSTR (v_phone_no, c, 1))),
                     0);
         END LOOP;
      END IF;

      IF p_ip_address IS NULL
      THEN                           /*128.128.32.01 / 128.128.32.02 -serkan*/
         IF v_ethernet_destekli
         THEN
            -- TANER : ethernet destekli olanlarin IP adresleri farkli.. Eger ikisi de destekli ise onceligi ethernet'e verdim..
            v_ip_address :=
                  LPAD (dbms_numsystem_package.dec2hex (212), 2, 0)
               || LPAD (dbms_numsystem_package.dec2hex (252), 2, 0)
               || LPAD (dbms_numsystem_package.dec2hex (205), 2, 0)
               || LPAD (dbms_numsystem_package.dec2hex (236), 2, 0);
         ELSIF v_modem_destekli
         THEN
            -- 24/12/2008; Emine; LPAD kismi eklendi
            v_ip_address :=
                  LPAD (dbms_numsystem_package.dec2hex (192), 2, 0)
               || LPAD (dbms_numsystem_package.dec2hex (168), 2, 0)
               || LPAD (dbms_numsystem_package.dec2hex (40), 2, 0)
               || LPAD (dbms_numsystem_package.dec2hex (10), 2, 0);
         END IF;
      ELSE
         v_ip_address := p_ip_address;
      END IF;

      IF p_port IS NULL
      THEN
         v_port := dbms_numsystem_package.dec2hex (20013);     -- 1E6A Erdem ?
      ELSE
         v_port := p_port;
      END IF;

      v_param :=
            RPAD (v_phone_no_ascii, 32, '0')
         || LPAD (v_ip_address, 8, '0')
         || LPAD (v_port, 4, '0');

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);
      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION forced_standby (p_req_dbs_type     IN     VARCHAR2,
                            p_serial_number    IN     VARCHAR2,
                            p_tms_attributes   IN     VARCHAR2,
                            p_valid_after      IN     DATE,
                            p_req_user         IN     VARCHAR2,
                            p_tra_id           IN OUT NUMBER,
                            p_errm                OUT VARCHAR2,
                            p_logla            IN     CHAR DEFAULT 'E',
                            p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3);
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;

      v_destination             VARCHAR2 (4) := '0002';
      v_tag                     VARCHAR2 (2) := '02';

      v_gonderim_oneri_tarihi   DATE;
      v_valid_after             DATE := p_valid_after;
      v_allowed_valid_after     DATE := p_valid_after; --aynı zamanli global sinyallerin çıkılmasi PVR kutularda sürekli restart sorununa yol açtığından bu değişkene ihtiyaç duyuldu tuna 10.04.2012
      v_trying_cnt              NUMBER
         := TO_NUMBER (
               NVL (
                  dbs_addr.getdinamikkeyvalue (
                     'TRYING_COUNT_FOR_GLB_STANDBY'),
                  '10'));

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
      global_risk_exception     EXCEPTION;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param :=
         '01000309000100073C00' || v_destination || v_tag || '0000';

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_req_param := v_req_param || '|' || p_tms_attributes;
      END IF;

      /*BEGIN GLOBAL SINYAL VALID_AFTER KONTROLU
      GLOBAL SINYAL GONDERIMLERINDE SORUN TESKIL EDEN SINYALLER ICIN, SINYAL GONDERIM ZAMANI(VALID_AFTER) AYNI ZAMANLI OLMAMALI.. tunahan 10.04.2012 */
      IF v_req_type =
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
      THEN
         p_errm :=
            dbs_dba.global_sinyal_kontrol (
               v_valid_after,
               dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global,
               v_trying_cnt,
               v_allowed_valid_after --önerilen global sinyal valid after ı...
                                    );

         IF p_errm <> '0'
         THEN
            RAISE global_risk_exception;
         ELSE
            p_errm := NULL;

            IF v_allowed_valid_after IS NOT NULL
            THEN
               v_valid_after := v_allowed_valid_after;
            END IF;
         END IF;
      END IF;

      /*END GLOBAL SINYAL VALID_AFTER KONTROLU*/

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   v_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception OR global_risk_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION delete_secure_client (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_delete_secure_client;       --84;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := NULL;

      IF v_account_number IS NULL
      THEN
         v_account_number := 0;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number          number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1         lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2         lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3         lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4         lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      UPDATE dbs_addr_tms
         SET tms_value = 0
       WHERE id IN (SELECT tms_attr_id
                      FROM dbs_addr_equip
                     WHERE serial_number = p_serial_number);

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION reactivate_secure_client (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_reactivate_secure_client;   --89;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param := NULL;

      IF v_account_number IS NULL
      THEN
         v_account_number := 0;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number          number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1         lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2         lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3         lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4         lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      /*Tunahan Akbulut: 26.07.2010 Pazartesi gunu eklendi
        Özgül Özelinin talebi doğrultusunda eklendi. Konuyla ilgil EVRIM KAYAN ve MUSTAFA TEMIZE sorulabilir.
        Talep: 41 DELETE SECURE CLIENT sınyalı ıcınde bulunan UPDATE TMS ATTRIBUTE ıle ılgılı scrıptın, 42 REACTIVATE SECURE CLIENT sınyalı ıcıne de ekleyebılır mısın?*/
      UPDATE dbs_addr_tms
         SET tms_value = 0
       WHERE id IN (SELECT tms_attr_id
                      FROM dbs_addr_equip
                     WHERE serial_number = p_serial_number);

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   --PROCEDURE find_tms (
   --        p_serial_number    IN        VARCHAR2,
   --        p_out_tms          OUT       VARCHAR2,
   --        p_errm             OUT       VARCHAR2
   --    ) AS
   --    v_tms_id     NUMBER;
   --    v_out_tms     VARCHAR2(1000);
   --    v_serial_number          wiz_equip.serial_number%TYPE := TRIM ( p_serial_number );
   --    v_account_number         wiz_equip.account_number%TYPE;
   --    v_service_address_id     wiz_equip.service_address_id%TYPE;
   --    v_outlet_location        wiz_equip.outlet_location%TYPE;

   --    BEGIN
   --        v_tms_id     := NULL;
   --        v_out_tms      := NULL;
   --        p_errm         := '0';
   --        BEGIN
   --            SELECT account_number, service_address_id, outlet_location
   --            INTO   v_account_number, v_service_address_id, v_outlet_location
   --            FROM   wiz_equip
   --            WHERE  wiz_equip.serial_number = v_serial_number;

   --          EXCEPTION WHEN OTHERS THEN
   --            p_errm := 'find_tms: ekipman bilgisi bulunamadi!';
   --            RETURN;
   --        END;

   --        BEGIN
   --            SELECT TMS_ATTR_ID INTO v_tms_id FROM DBS_ADDR_EQUIP WHERE  serial_number = p_serial_number;
   --            IF v_tms_id IS NULL THEN
   --                 p_out_tms := NULL;
   --            ELSE
   --                FOR rec IN ( SELECT * FROM DBS_ADDR_TMS WHERE ID = v_tms_id )
   --                LOOP
   --                    IF LENGTH ( v_out_tms ) > 0
   --                    THEN
   --                        v_out_tms    := v_out_tms || ',' || rec.TMS_KEY || ' ' || rec.TMS_VALUE;
   --                    ELSE
   --                        v_out_tms   := rec.TMS_KEY || ' ' || rec.TMS_VALUE;
   --                    END IF;
   --                END LOOP;
   --            END IF;
   --            p_out_tms := trim(v_out_tms);
   --          EXCEPTION WHEN OTHERS THEN
   --            p_errm := 'find_tms: ekipman bilgisi bulunamadi!';
   --            RETURN;
   --        END;

   --    EXCEPTION WHEN OTHERS THEN
   --        p_errm     := SQLERRM;
   --        RETURN;
   --END;
   /********************************************************************************************************************/
   FUNCTION force_ippv_callback (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3)
                                   := dbs_addr_pisys_msg_type_defs.m_t_force_ippv_callback; --14;
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;
      v_ekipman_tip_matrix_id   NUMBER (10);
      v_ekipman_ozellik         VARCHAR2 (3);
      input_exception           EXCEPTION;
      log_exception             EXCEPTION;

      v_modem_destekli          BOOLEAN := FALSE;
      v_ethernet_destekli       BOOLEAN := FALSE;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
         -- 08/08/2011; Taner; sadece (modem veya ethernet) destekli kutulara IPPV yetkilerinin cikmasi isteniyor

         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       66                            /*modem*/
                                         ,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_modem_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       101                        /*ethernet*/
                                          ,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_ethernet_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         IF v_modem_destekli = FALSE AND v_ethernet_destekli = FALSE
         THEN
            RETURN 1;              -- ne MODEM ne de ETHERNET destekli degil..
         END IF;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION virtual_bill (p_req_dbs_type    IN     VARCHAR2,
                          p_serial_number   IN     VARCHAR2,
                          p_data            IN     VARCHAR2,
                          p_valid_after     IN     DATE,
                          p_req_user        IN     VARCHAR2,
                          p_tra_id          IN OUT NUMBER,
                          p_errm               OUT VARCHAR2,
                          p_logla           IN     CHAR DEFAULT 'E',
                          p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_param             VARCHAR2 (1000);
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      v_msg_length        VARCHAR2 (4);
      v_all_msg_length    VARCHAR2 (4);
      v_destination       VARCHAR2 (4) := '0001';
      v_tag               VARCHAR2 (2) := '01';
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_serial_number <> '99999999999'
      THEN
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_account_number := 0;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_param := p_data;

      --v_msg_length      := LPAD(Dbms_Numsystem_Package.dec2hex(LENGTH(v_param) / 2), 4, 0);
      v_msg_length := LPAD (LENGTH (v_param) / 2, 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE input_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION update_hard_disk (p_req_dbs_type    IN     VARCHAR2,
                              p_serial_number   IN     VARCHAR2,
                              p_valid_after     IN     DATE,
                              p_req_user        IN     VARCHAR2,
                              p_tra_id          IN OUT NUMBER,
                              p_errm               OUT VARCHAR2,
                              p_logla           IN     CHAR DEFAULT 'E',
                              p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_destination       VARCHAR2 (4) := '0002';
      v_tag               VARCHAR2 (2) := '0C';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param :=
         '01000309000100073C00' || v_destination || v_tag || '0000';

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,     --p_mesaj_metni         varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                   lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION format_hard_disk (p_req_dbs_type    IN     VARCHAR2,
                              p_serial_number   IN     VARCHAR2,
                              p_valid_after     IN     DATE,
                              p_req_user        IN     VARCHAR2,
                              p_tra_id          IN OUT NUMBER,
                              p_errm               OUT VARCHAR2,
                              p_logla           IN     CHAR DEFAULT 'E',
                              p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_destination       VARCHAR2 (4) := '0002';
      v_tag               VARCHAR2 (2) := '0D';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param :=
         '01000309000100073C00' || v_destination || v_tag || '0000';

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,     --p_mesaj_metni         varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                   lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION remote_recording (
      p_req_dbs_type      IN     VARCHAR2,
      p_serial_number     IN     VARCHAR2,
      p_service_id        IN     NUMBER,
      p_ts_id             IN     NUMBER,
      p_network_id        IN     NUMBER,
      p_start_date_time   IN     DATE,
      p_service_name      IN     VARCHAR2,
      p_duration          IN     NUMBER,
      p_valid_after       IN     DATE,
      p_req_user          IN     VARCHAR2,
      p_tra_id            IN OUT NUMBER,
      p_errm                 OUT VARCHAR2,
      p_logla             IN     CHAR DEFAULT 'E',
      p_req_id            IN     NUMBER DEFAULT NULL,
      p_event_id          IN     NUMBER DEFAULT 0,
      p_event_name        IN     VARCHAR2 DEFAULT NULL,
      p_time_before       IN     NUMBER DEFAULT 0,
      p_time_after        IN     NUMBER DEFAULT 0)
      RETURN NUMBER
   AS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3);
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_param                   VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;

      v_start_date_time         VARCHAR2 (8);
      v_date_time_diff          NUMBER;
      v_event_name              VARCHAR2 (120);
      /*[EBerker20120103]-Eda Takbak Şahin e soruldu LISYS sistemindeki ETI alanina yazilan
      program adi alani 30 karakter ile sinirlandirildigi icin event_name max 30 karakter olabilir. */
      v_event_name_for_eti      VARCHAR2 (30);
      v_service_name            VARCHAR2 (60);
      v_duration                NUMBER := 1;
      v_time_diff               VARCHAR2 (10);
      v_start_date_time_w_gmt   DATE;
      v_time_before             NUMBER (8);
      v_time_after              NUMBER (8);

      v_msg_length              VARCHAR2 (4);
      v_all_msg_length          VARCHAR2 (4);
      v_destination             VARCHAR2 (4) := '0002';
      v_tag                     VARCHAR2 (2) := '06';

      v_len                     NUMBER;
      --MKECECI
      v_seriesflag              NUMBER := 0; -- 0=No Series Recording, 1=Series Recording
      v_frequency               NUMBER := 0; --0=don`t care,1=once,2=daily,3=weekly,4=weekends,5=weekdays
      v_expiration              VARCHAR2 (100) := '0';           --expire_date
      v_cancelflag              NUMBER := 0;        --0=record,1=cancel record
      --</end - MKECECI>
      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
   BEGIN
      p_errm := '0';
      v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RETURN 0;
      ELSE
         p_errm := '0';
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_start_date_time IS NULL
      THEN
         p_errm := 'Event başlangıç saati boş olamaz!';
         RETURN 0;
      ELSIF NVL (p_duration, 0) <= 0
      THEN
         p_errm := 'Kayıt süresi geçersiz!';
         RETURN 0;
      ELSIF p_start_date_time + (p_duration / (24 * 60)) <= SYSDATE
      THEN
         p_errm := 'Bitmiş eventlere "remote recording" yapılamaz!';
         RETURN 0;
      END IF;

      IF p_service_id IS NULL
      THEN
         p_errm := 'Service_id değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_ts_id IS NULL
      THEN
         p_errm := 'Ts_id değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_network_id IS NULL
      THEN
         p_errm := 'Network_id değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_service_name IS NULL
      THEN
         p_errm := 'Service_name değeri boş olamaz!';
         RETURN 0;
      END IF;

      v_service_name :=
         SUBSTR (
            dbs_addr.dbms_numsystem_package.hex2asciihex (p_service_name),
            1,
            60);

      /*[EBerker20120103]-event name LISYS eti sinirlandirmasi max 30 karakter*/
      v_event_name_for_eti := SUBSTR (p_event_name, 1, 30);
      v_event_name :=
         SUBSTR (
            dbs_addr.dbms_numsystem_package.hex2asciihex (
               v_event_name_for_eti),
            1,
            120);

      IF p_time_before IS NULL
      THEN
         v_time_before := '00000000';
      ELSE
         v_time_before := p_time_before;
      END IF;

      IF p_time_after IS NULL
      THEN
         v_time_after := '00000000';
      ELSE
         v_time_after := p_time_after;
      END IF;

      v_time_diff :=
         dbs_addr_ppv_events_pack.get_time_difference (p_start_date_time);

      SELECT p_start_date_time - (v_time_diff / 24)
        INTO v_start_date_time_w_gmt
        FROM DUAL;

      SELECT ROUND (
                  (  v_start_date_time_w_gmt
                   - (TO_DATE ('01.01.1970 00:00:00',
                               'DD.MM.YYYY HH24:MI:SS')))
                * 3600
                * 24)
        INTO v_date_time_diff
        FROM DUAL;

      v_start_date_time :=
         dbs_addr.dbms_numsystem_package.dec2hex (v_date_time_diff);

      v_param :=
            LPAD (dbs_addr.dbms_numsystem_package.dec2hex (p_network_id),
                  4,
                  '0')
         || LPAD (NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_ts_id), 0),
                  4,
                  '0')
         || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (p_service_id),
                  4,
                  '0')
         || v_start_date_time
         || LPAD (
               NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_event_id), 0),
               4,
               '0')
         || LPAD (
               NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_duration), 0),
               4,
               '0')
         || LPAD (
               NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_time_before),
                    0),
               8,
               '0')
         || LPAD (
               NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_time_after),
                    0),
               8,
               '0')
         || RPAD (v_service_name, 60, '0')
         || RPAD (NVL (v_event_name, 0), 120, '0')
         || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (v_seriesflag),
                  2,
                  '0') -- 0=No Series Recording, 1=Series Recording         --MKECECI
         || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (v_frequency),
                  4,
                  '0') --0=don`t care,1=once,2=daily,3=weekly,4=weekends,5=weekdays    --MKECECI
         || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (v_expiration),
                  8,
                  '0')                              --expire_date    --MKECECI
         || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (v_expiration),
                  2,
                  '0');                --0=record,1=cancel record    --MKECECI

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      --dbms_output.put_line('v_msg_length :'||v_msg_length);
      --dbms_output.put_line('v_all_msg_length :'||v_all_msg_length);
      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION change_secure_client_type (
      p_req_dbs_type         IN     VARCHAR2,
      p_serial_number        IN     VARCHAR2,
      p_valid_after          IN     DATE,
      p_req_user             IN     VARCHAR2,
      p_tra_id               IN OUT NUMBER,
      p_errm                    OUT VARCHAR2,
      p_secure_client_type   IN     VARCHAR2 DEFAULT 'DEFAULT',
      p_logla                IN     CHAR DEFAULT 'E',
      p_req_id               IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date             DATE := SYSDATE;
      v_req_type             NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_change_secure_client_type;   --81
      v_req_group_type       NUMBER (2);
      v_account_number       wiz_equip.account_number%TYPE;
      v_outlet_location      wiz_equip.outlet_location%TYPE;
      v_req_param            VARCHAR2 (1000);
      v_req_id               NUMBER (10);
      v_durum                VARCHAR2 (400);
      v_tra_id               NUMBER;
      input_exception        EXCEPTION;
      log_exception          EXCEPTION;
      v_secure_client_type   VARCHAR2 (20);
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_secure_client_type IS NULL
      THEN
         v_secure_client_type := 'DEFAULT';
      ELSE
         v_secure_client_type := p_secure_client_type;
      END IF;

      v_req_param := v_secure_client_type;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   v_secure_client_type, --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE input_exception;
         END IF;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION set_other_mode (
      p_req_dbs_type        IN     VARCHAR2,
      p_serial_number       IN     VARCHAR2,
      p_enable_other_mode   IN     VARCHAR2,
      p_valid_after         IN     DATE,
      p_req_user            IN     VARCHAR2,
      p_tra_id              IN OUT NUMBER,
      p_errm                   OUT VARCHAR2,
      p_chipset             IN     VARCHAR2 DEFAULT 'FFFFFFFF',
      p_logla               IN     CHAR DEFAULT 'E',
      p_req_id              IN     NUMBER DEFAULT NULL,
      p_hd_mode             IN     VARCHAR2 --[EBerker20140326]Sinyale yeni HD Mode parametresi eklenmiştir.
                                           )
      RETURN NUMBER
   AS
      v_req_date            DATE := SYSDATE;
      v_req_type            NUMBER (3)
                               := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type      NUMBER (2);
      v_account_number      wiz_equip.account_number%TYPE;
      v_outlet_location     wiz_equip.outlet_location%TYPE;
      v_req_param           VARCHAR2 (1000);
      v_param               VARCHAR2 (1000);
      v_req_id              NUMBER (10);
      v_durum               VARCHAR2 (400);
      v_tra_id              NUMBER;
      v_enable_other_mode   VARCHAR2 (2);
      v_chipset             VARCHAR2 (20);
      v_msg_length          VARCHAR2 (4);
      v_all_msg_length      VARCHAR2 (4);
      v_destination         VARCHAR2 (4) := '0002';
      v_tag                 VARCHAR2 (2) := '50';
      input_exception       EXCEPTION;
      log_exception         EXCEPTION;
      v_hd_mode             VARCHAR2 (2); --[EBerker20140326] -STB other modda HD kanal kurulumu yaparken HDMode:0x01 , other modda SD kanal kurulumu için HDMode:0x00 olmalıdır.
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF    p_enable_other_mode IS NULL
         OR LENGTH (p_enable_other_mode) != 1
         OR (p_enable_other_mode <> '0' AND p_enable_other_mode <> '1')
      THEN
         p_errm := 'p_enable_other_mode alani "0" veya "1" olabilir!';
         RAISE input_exception;
      END IF;

      IF p_chipset IS NULL OR LENGTH (p_chipset) != 8
      THEN
         p_errm := 'p_chipset alani 8 karakter uzunlugunda olmalidir!';
         RAISE input_exception;
      END IF;

      IF    p_hd_mode IS NULL
         OR LENGTH (p_hd_mode) != 1
         OR (p_hd_mode <> '0' AND p_hd_mode <> '1')
      THEN
         p_errm := 'p_hd_mode alani "0" veya "1" olabilir!';
         RAISE input_exception;
      END IF;

      --p_enable_other_mode = '1' means OTHER-MODE is enabled , otherwise it is disabled
      --p_chipset = 'FFFFFFFF' means it will ignore the comparison with STB secure-chipset-id (CSSN) and do the operation..

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_enable_other_mode := RAWTOHEX (p_enable_other_mode);
      v_chipset := TRIM (dbms_numsystem_package.hex2asciihex (p_chipset));
      --[EBerker20140326] - HDMode:0 or 1 --> max:8 bits
      v_hd_mode := RAWTOHEX (p_hd_mode);

      v_param :=
            LPAD (v_enable_other_mode, 2, '0')
         || LPAD (v_chipset, 16, '0')
         || LPAD (v_hd_mode, 2, '0');
      v_param := v_param || '00';                            -- ReservedField1
      --v_param             := v_param || '00'; -- ReservedField2 --[EBerker20140326] - HDMode için ayrılmıştır

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION remote_tagging (
      p_req_dbs_type           IN     VARCHAR2,
      p_serial_number          IN     VARCHAR2,
      p_service_id             IN     NUMBER,
      p_ts_id                  IN     NUMBER,
      p_network_id             IN     NUMBER,
      p_channel_number         IN     NUMBER,
      p_start_date_time        IN     DATE,
      p_service_name           IN     VARCHAR2,
      p_valid_after            IN     DATE,
      p_req_user               IN     VARCHAR2,
      p_tra_id                 IN OUT NUMBER,
      p_errm                      OUT VARCHAR2,
      p_req_param                 OUT VARCHAR2,
      p_logla                  IN     CHAR DEFAULT 'E',
      p_req_id                 IN     NUMBER DEFAULT NULL,
      p_event_id               IN     NUMBER DEFAULT 0,
      p_duration               IN     NUMBER DEFAULT 0,
      p_time_offset            IN     NUMBER DEFAULT 0,
      p_event_name             IN     VARCHAR2 DEFAULT NULL,
      p_price                  IN     NUMBER DEFAULT -1,
      p_time_before            IN     NUMBER DEFAULT 0,
      p_time_after             IN     NUMBER DEFAULT 0,
      p_frequency              IN     NUMBER DEFAULT 1, -- 1:once; 2:daily; 3:weekly; 4:weekends; 5:weekdays
      p_expiration_date_time   IN     DATE DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date               DATE := SYSDATE;
      v_req_type               NUMBER (3);
      v_req_group_type         NUMBER (2);
      v_account_number         wiz_equip.account_number%TYPE;
      v_outlet_location        wiz_equip.outlet_location%TYPE;
      v_param                  VARCHAR2 (1000);
      v_req_id                 NUMBER (10);
      v_durum                  VARCHAR2 (400);
      v_tra_id                 NUMBER;

      v_ekipman_model          VARCHAR2 (10);
      v_is_ds265               BOOLEAN := FALSE;                /*PCSD-S9100*/

      v_time_diff              NUMBER;
      v_date_time_gmt          DATE;
      v_date_time_diff         NUMBER;

      v_start_date_time        VARCHAR2 (8);
      v_expiration_date_time   VARCHAR2 (8);
      v_event_name             VARCHAR2 (120);
      v_service_name           VARCHAR2 (60);
      v_price                  VARCHAR2 (8);

      v_msg_length             VARCHAR2 (4);
      v_all_msg_length         VARCHAR2 (4);
      v_destination            VARCHAR2 (4) := '0002';
      v_tag                    VARCHAR2 (2) := '05';

      input_exception          EXCEPTION;
      log_exception            EXCEPTION;
   BEGIN
      p_errm := '0';
      v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RETURN 0;
      END IF;

      IF p_start_date_time IS NULL
      THEN
         p_errm := 'Event başlangıç saati boş olamaz!';
         RETURN 0;
      ELSIF p_start_date_time <= SYSDATE
      THEN
         p_errm := 'Başlamış eventlere "remote tagging" yapılamaz!';
         RETURN 0;
      END IF;

      IF p_service_id IS NULL
      THEN
         p_errm := 'Service_id değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_ts_id IS NULL
      THEN
         p_errm := 'Ts_id değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_network_id IS NULL
      THEN
         p_errm := 'Network_id değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_channel_number IS NULL
      THEN
         p_errm := 'Channel_number değeri boş olamaz!';
         RETURN 0;
      END IF;

      IF p_service_name IS NULL
      THEN
         p_errm := 'Service_name değeri boş olamaz!';
         RETURN 0;
      END IF;

      p_errm := '0';

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      BEGIN
         SELECT TRIM (converter_model)
           INTO v_ekipman_model
           FROM wiz_equip
          WHERE     account_number = v_account_number
                AND outlet_location = v_outlet_location
                AND converter_type = 'ST';

         IF v_ekipman_model = 'PCSD-S9100'
         THEN
            v_is_ds265 := TRUE;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      v_service_name :=
         SUBSTR (
            dbs_addr.dbms_numsystem_package.hex2asciihex (p_service_name),
            1,
            60);

      v_event_name :=
         SUBSTR (dbs_addr.dbms_numsystem_package.hex2asciihex (p_event_name),
                 1,
                 120);

      v_time_diff :=
         dbs_addr_ppv_events_pack.get_time_difference (p_start_date_time);

      SELECT p_start_date_time - (v_time_diff / 24)
        INTO v_date_time_gmt
        FROM DUAL;

      SELECT ROUND (
                  (  v_date_time_gmt
                   - (TO_DATE ('01.01.1970 00:00:00',
                               'DD.MM.YYYY HH24:MI:SS')))
                * 3600
                * 24)
        INTO v_date_time_diff
        FROM DUAL;

      v_start_date_time :=
         dbs_addr.dbms_numsystem_package.dec2hex (v_date_time_diff);

      IF v_is_ds265
      THEN
         v_tag := '52';

         IF p_price = -1
         THEN
            v_price := 'FFFFFFFF';
         ELSE
            v_price :=
               LPAD (
                  NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_price), 0),
                  8,
                  '0');
         END IF;

         v_param :=
               LPAD (
                  NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_event_id),
                       0),
                  4,
                  '0')
            || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (p_service_id),
                     4,
                     '0')
            || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (p_ts_id),
                     4,
                     '0')
            || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (p_network_id),
                     4,
                     '0')
            || LPAD (v_start_date_time, 8, '0')
            || LPAD (
                  NVL (dbs_addr.dbms_numsystem_package.dec2hex (p_duration),
                       0),
                  8,
                  '0')
            || LPAD (
                  NVL (
                     dbs_addr.dbms_numsystem_package.dec2hex (p_time_offset),
                     0),
                  4,
                  '0')
            || SUBSTR (RPAD (NVL (v_event_name, 0), 36, '0'), 1, 36)
            || SUBSTR (RPAD (v_service_name, 22, '0'), 1, 22)
            || '01'                                                    -- flag
            || v_price;
      ELSE
         IF p_expiration_date_time IS NOT NULL
         THEN
            v_time_diff :=
               dbs_addr_ppv_events_pack.get_time_difference (
                  p_expiration_date_time);

            SELECT p_expiration_date_time - (v_time_diff / 24)
              INTO v_date_time_gmt
              FROM DUAL;

            SELECT ROUND (
                        (  v_date_time_gmt
                         - (TO_DATE ('01.01.1970 00:00:00',
                                     'DD.MM.YYYY HH24:MI:SS')))
                      * 3600
                      * 24)
              INTO v_date_time_diff
              FROM DUAL;

            v_expiration_date_time :=
               dbs_addr.dbms_numsystem_package.dec2hex (v_date_time_diff);
         END IF;

         v_param :=
               LPAD (
                  TO_CHAR (
                     dbs_addr.dbms_numsystem_package.dec2hex (
                        p_channel_number)),
                  4,
                  '0')
            || LPAD (v_start_date_time, 8, '0')
            || LPAD (p_frequency, 4, '0')
            || LPAD (NVL (v_expiration_date_time, 0), 8, '0')
            || LPAD (
                  TO_CHAR (
                     NVL (
                        dbs_addr.dbms_numsystem_package.dec2hex (
                           p_time_before),
                        0)),
                  8,
                  '0')
            || LPAD (
                  TO_CHAR (
                     NVL (
                        dbs_addr.dbms_numsystem_package.dec2hex (
                           p_time_after),
                        0)),
                  8,
                  '0')
            || SUBSTR (RPAD (TO_CHAR (v_service_name), 60, '0'), 1, 60)
            || SUBSTR (RPAD (TO_CHAR (NVL (v_event_name, 0)), 120, '0'),
                       1,
                       120);
      END IF;

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      p_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   p_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION remote_tagging_cancel (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_req_param       IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);

      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;

      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_ekipman_model     VARCHAR2 (10);
      v_is_ds265          BOOLEAN := FALSE;                     /*PCSD-S9100*/

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      p_errm := '0';
      v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RETURN 0;
      END IF;

      IF p_tra_id IS NULL
      THEN
         p_errm :=
            'İşlemi iptal edebilmek için işlemin belirtilmesi gerekmektedir!';
         RETURN 0;
      END IF;

      IF p_req_param IS NULL
      THEN
         p_errm :=
            'İşlemi iptal edebilmek için işlem parametresinin belirtilmesi gerekmektedir!';
         RETURN 0;
      END IF;

      DELETE dbs_addr_pisys_reqs
       WHERE     serial_number = p_serial_number
             AND req_type = v_req_type
             AND tra_id = p_tra_id;

      IF SQL%ROWCOUNT > 0
      THEN                                               -- iptal yapılmıştır.
         IF p_logla IS NULL OR p_logla = 'E'
         THEN
            log_pack.log_mesaj_takip (p_serial_number,
                                      NULL, --p_account_number              number,
                                      NULL, --p_prospect_number             number,
                                      NULL, --p_service_address_id          number,
                                      NULL, --p_equip_location_code         varchar2,
                                      p_req_user,
                                      v_req_date,
                                      p_req_dbs_type,
                                      NULL, --p_ppv_kredi_limiti            number,
                                      NULL, --p_msg_account_number          number,
                                      NULL, --p_msg_serial_number           varchar2,
                                      NULL, --p_mesaj_metni                 varchar2,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      p_tra_id,
                                      v_durum);

            IF v_durum <> '0'
            THEN
               p_errm := v_durum;
               RAISE log_exception;
            END IF;
         END IF;

         p_tra_id := NULL;
         RETURN 1;
      END IF;

      BEGIN
         SELECT TRIM (converter_model)
           INTO v_ekipman_model
           FROM wiz_equip
          WHERE     account_number = v_account_number
                AND outlet_location = v_outlet_location
                AND converter_type = 'ST';

         IF v_ekipman_model = 'PCSD-S9100'
         THEN
            v_is_ds265 := TRUE;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      IF NOT v_is_ds265
      THEN
         p_errm := 'Abone kutu modeli bu özelligi desteklememektedir!';
         RETURN 0;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param :=
            SUBSTR (p_req_param, 1, 124)
         || '00'
         || SUBSTR (p_req_param, 127, LENGTH (p_req_param));

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION display_easy_sms (p_req_dbs_type     IN     VARCHAR2,
                              p_serial_number    IN     VARCHAR2,
                              p_tms_attributes   IN     VARCHAR2,
                              p_event_id         IN     NUMBER,
                              p_event_is_gift    IN     CHAR  /* 'E' or 'H' */
                                                            ,
                              p_row              IN     NUMBER,
                              p_col              IN     NUMBER,
                              p_flashing         IN     CHAR, /*  'E' or 'H'  */
                              p_duration         IN     NUMBER,
                              p_text             IN     VARCHAR2,
                              p_valid_after      IN     DATE,
                              p_req_user         IN     VARCHAR2,
                              p_tra_id           IN OUT NUMBER,
                              p_errm                OUT VARCHAR2,
                              p_logla            IN     CHAR DEFAULT 'E',
                              p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_param             VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_sms_code          VARCHAR2 (16);
      v_row               VARCHAR2 (4);
      v_col               VARCHAR2 (4);
      v_flashing          VARCHAR2 (2);
      v_duration          VARCHAR2 (2);
      v_text_len          VARCHAR2 (2);
      v_length_of_text    NUMBER;
      v_text              VARCHAR2 (32767);

      v_msg_length        VARCHAR2 (4);
      v_all_msg_length    VARCHAR2 (4);
      v_destination       VARCHAR2 (4) := '0002';
      v_tag               VARCHAR2 (2) := '51';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;

      v_easy_sms_text     VARCHAR2 (100) := NULL;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      sms_dba.easy_sms_old_algorithm_pack.get_encoded_ird_message (
         p_event_id,
         p_event_is_gift,
         v_easy_sms_text,
         p_errm);

      IF p_errm <> 'SUCCESS'
      THEN
         RETURN 0;                                            -- hata olustu..
      END IF;

      IF v_easy_sms_text IS NULL
      THEN
         v_sms_code := '0000000000000000'; -- 8*8=64 bit ( fakat burda HEX olarak tutulacak )
      ELSE
         SELECT RAWTOHEX (v_easy_sms_text) INTO v_sms_code FROM DUAL;

         v_sms_code := LPAD (v_sms_code, 16, '0');
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_row IS NULL OR p_row = 0
      THEN
         v_row := '0000';
      ELSE
         v_row := LPAD (dbms_numsystem_package.dec2hex (p_row), 4, '0');
      END IF;

      IF p_col IS NULL OR p_col = 0
      THEN
         v_col := '0000';
      ELSE
         v_col := LPAD (dbms_numsystem_package.dec2hex (p_col), 4, '0');
      END IF;

      IF p_flashing IS NULL OR p_flashing = 'H'
      THEN
         v_flashing := '00';
      ELSIF p_flashing = 'E'
      THEN
         v_flashing := LPAD (dbms_numsystem_package.dec2hex (1), 2, '0');
      ELSE
         v_flashing := LPAD (dbms_numsystem_package.dec2hex (0), 2, '0');
      END IF;

      /*p_duration : e.g. 10 means 10 seconds*/
      IF p_duration IS NULL OR p_duration = 0
      THEN
         v_duration := '00';
      ELSE
         v_duration :=
            LPAD (dbms_numsystem_package.dec2hex (p_duration), 2, '0');
      END IF;

      SELECT RAWTOHEX (p_text) INTO v_text FROM DUAL;

      v_length_of_text := LENGTH (v_text) / 2;
      v_text_len :=
         LPAD (dbms_numsystem_package.dec2hex (v_length_of_text), 2, '0');
      v_param :=
            v_row
         || v_col
         || v_flashing
         || v_sms_code
         || v_duration
         || v_text_len
         || v_text;
      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_param := v_param || '|' || p_tms_attributes;
      END IF;

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                   varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   p_text, --p_mesaj_metni             varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                      lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION set_pvr_functionality (
      p_req_dbs_type    IN     VARCHAR2,
      p_enable_pvr      IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      v_ret               NUMBER (1);
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF    p_enable_pvr IS NULL
         OR LENGTH (p_enable_pvr) != 1
         OR (p_enable_pvr <> '0' AND p_enable_pvr <> '1')
      THEN
         p_errm := 'p_enable_pvr alani "0" veya "1" olabilir!';
         RAISE input_exception;
      END IF;

      IF p_enable_pvr = '1'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_add_master_session_key; --27
         v_req_param := 'ADD';
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_remove_master_session_key;   --39
         v_req_param := 'DELETE';
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      IF p_enable_pvr = '1'
      THEN
         v_ret :=
            create_entitlements (p_req_dbs_type,
                                 p_serial_number,
                                 '666',
                                 p_valid_after,
                                 p_req_user,
                                 v_tra_id,
                                 p_errm,
                                 'H');

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RETURN 0;
         END IF;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION find_ppv_add_products (p_serial_number       IN     VARCHAR2,
                                   o_add_product_codes   IN OUT VARCHAR2,
                                   p_error_msg              OUT VARCHAR2)
      RETURN NUMBER
   AS
      v_add_product_tags   VARCHAR2 (500) := '';
   BEGIN
      -- Adamin aldigi ve henuz suresi gecmemis olan OPPV event'lerin ProductTag bilgileri listeye dahil edilecek..
      FOR kayit
         IN (SELECT product_tag
               FROM dbs_addr_ppv_products a
              WHERE event_id IN (SELECT event_id
                                   FROM dbs_addr_oppv_film_istek b
                                  WHERE     serial_number = p_serial_number
                                        AND durum = 'O'
                                        AND mesaj_aktif_tarihi < SYSDATE
                                        AND EXISTS
                                               (SELECT 1
                                                  FROM wiz_ppv_events c
                                                 WHERE     c.event_id =
                                                              b.event_id
                                                       AND c.event_end_time >
                                                              SYSDATE)))
      LOOP
         IF LENGTH (v_add_product_tags) > 0
         THEN
            v_add_product_tags :=
               v_add_product_tags || ',' || kayit.product_tag;
         ELSE
            v_add_product_tags := kayit.product_tag;
         END IF;
      END LOOP;

      IF LENGTH (v_add_product_tags) > 0
      THEN
         IF LENGTH (o_add_product_codes) > 0
         THEN
            o_add_product_codes :=
               o_add_product_codes || ',' || v_add_product_tags;
         ELSE
            o_add_product_codes := v_add_product_tags;
         END IF;
      END IF;

      RETURN 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_error_msg := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/
   /********************************************************************************************************************/
   --mantis ve kino için geçici olarak kullanılmak üzere hazırlanmıştır...
   PROCEDURE temp_find_set_tms (
      p_serial_number             IN     VARCHAR2,
      p_req_user                  IN     VARCHAR2,
      p_out_tms                      OUT VARCHAR2,
      p_errm                         OUT VARCHAR2,
      p_out_cancel_product_list      OUT VARCHAR2,
      p_out_add_product_list         OUT VARCHAR2,
      p_tms_sablon                IN     VARCHAR2 := NULL,
      p_force_send                IN     CHAR DEFAULT 'H')
   AS
      v_serial_number            wiz_equip.serial_number%TYPE
                                    := TRIM (p_serial_number);
      v_account_number           wiz_equip.account_number%TYPE;
      v_service_address_id       wiz_equip.service_address_id%TYPE;
      v_outlet_location          wiz_equip.outlet_location%TYPE;
      v_bolge                    co_ulke.gca_descr%TYPE;
      v_ulke                     wiz_hp_description.ulke%TYPE;
      v_il                       wiz_hp_description.city%TYPE;
      v_ilce                     wiz_hp_description.suppl_addr_line_1%TYPE;
      v_franchise_code           wiz_customer_hp_life.franchise_code%TYPE;
      v_brand                    wiz_customer_hp_life.hp_cluster%TYPE;
      v_stb_type                 VARCHAR2 (25) := NULL;
      v_manufacturer             wiz_equip.manufacturer%TYPE;
      v_converter_model          wiz_equip.converter_model%TYPE;
      v_customer_type            wiz_customer_hp_life.customer_type%TYPE;
      v_ekran_mesaji_izleme      VARCHAR2 (5);
      v_birthdate                VARCHAR2 (10);
      v_btv                      VARCHAR2 (10);
      v_service_1                VARCHAR2 (10);

      v_satellite_service        VARCHAR2 (10);

      v_tms_bolge                VARCHAR2 (10);
      v_tms_bolge_old            VARCHAR2 (10);
      v_tms_ulke                 VARCHAR2 (10);
      v_tms_ulke_old             VARCHAR2 (10);
      v_tms_il                   VARCHAR2 (10);
      v_tms_il_old               VARCHAR2 (10);
      v_tms_franchise_code       VARCHAR2 (10);
      v_tms_franchise_code_old   VARCHAR2 (10);
      v_tms_customer_type        VARCHAR2 (10);
      v_tms_customer_type_old    VARCHAR2 (10);
      v_tms_display_msg          VARCHAR2 (10);
      v_tms_display_msg_old      VARCHAR2 (10);
      v_tms_stb_type             VARCHAR2 (10);
      v_tms_stb_type_old         VARCHAR2 (10);
      v_tms_brand                VARCHAR2 (10);
      v_tms_brand_old            VARCHAR2 (10);
      v_tms_birthday             VARCHAR2 (10);
      v_tms_birthday_old         VARCHAR2 (10);
      v_tms_btv                  VARCHAR2 (10);
      v_tms_btv_old              VARCHAR2 (10);
      v_tms_service_1            VARCHAR2 (10);
      v_tms_service_1_old        VARCHAR2 (10);
      v_tms_satellite_type       VARCHAR2 (10);
      v_tms_satellite_type_old   VARCHAR2 (10);
      v_tra_id                   NUMBER;
      v_req_date                 DATE := SYSDATE;
      v_req_dbs_type             NUMBER (2) := 11;
      v_durum                    VARCHAR2 (400);
      v_ret                      NUMBER;
      v_product_number           VARCHAR2 (6);
      v_add_product_list         VARCHAR2 (500) := NULL;
      v_cancel_product_list      VARCHAR2 (500) := NULL;
      v_abone_ozellik_23         NUMBER;
   BEGIN
      p_errm := '0';

      BEGIN
         SELECT account_number, service_address_id, outlet_location
           INTO v_account_number, v_service_address_id, v_outlet_location
           FROM wiz_equip
          WHERE wiz_equip.serial_number = v_serial_number;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_errm := 'find_tms: ekipman bilgisi bulunamadi!';
            RETURN;
      END;

      IF v_account_number IS NOT NULL AND v_account_number > 0
      THEN
         SELECT franchise_code,
                service_address_id,
                hp_cluster,
                customer_type
           INTO v_franchise_code,
                v_service_address_id,
                v_brand,
                v_customer_type
           FROM wiz_customer_hp_life
          WHERE account_number = v_account_number;

         SELECT ulke, city, suppl_addr_line_1
           INTO v_ulke, v_il, v_ilce
           FROM wiz_hp_description
          WHERE service_address_id = v_service_address_id;

         SELECT ulke.gca_descr
           INTO v_bolge
           FROM co_ulke ulke
          WHERE ulke.ad = v_ulke;

         SELECT DECODE (COUNT (1), '1', 'HAYIR', 'EVET')
           INTO v_ekran_mesaji_izleme
           FROM mb_abone_ozellik
          WHERE     account_number = v_account_number
                AND abone_ozellik_kodu =
                       (SELECT kod
                          FROM pr_abone_ozellik
                         WHERE aciklama = 'EKRAN MESAJI IZLEMEME');

         -- Abone ozellik kodu 23 olanlara GCA-TURKIYE gibi davranilacak..
         SELECT COUNT (1)
           INTO v_abone_ozellik_23
           FROM mb_abone_ozellik
          WHERE     account_number = v_account_number
                AND outlet_location = v_outlet_location
                AND abone_ozellik_kodu =
                       (SELECT kod
                          FROM pr_abone_ozellik
                         WHERE aciklama = 'GCA BOLGE TURKIYE');

         IF v_abone_ozellik_23 = 1
         THEN
            v_ulke := dbs_addr_sabit_pack.turkiye;
            v_bolge := dbs_addr_sabit_pack.turkiye;
            v_il := NULL; --tms_attributes prosedurunden default deger (0) donecek..
         END IF;

         BEGIN
            SELECT e.eq_ekipman_tip_matrix_id
              INTO v_stb_type
              FROM wiz_equip w, eq_ekipman_tip_matrix e
             WHERE     account_number = v_account_number
                   AND outlet_location = v_outlet_location
                   AND w.converter_type = 'ST'
                   AND w.converter_model <> 'DUMMY'
                   AND TRIM (w.manufacturer) = TRIM (e.manufacturer)
                   AND TRIM (w.converter_model) = TRIM (e.converter_model);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_stb_type := 0;
         END;

         BEGIN
            SELECT MIN (TO_CHAR (dogum_tarihi, 'DD.MM.YYYY'))
              INTO v_birthdate
              FROM mb_abone_detay_bilgi
             WHERE account_number = v_account_number;

            IF TO_DATE (v_birthdate, 'DD.MM.YYYY') BETWEEN TO_DATE (
                                                              '01.01.1900',
                                                              'DD.MM.YYYY')
                                                       AND SYSDATE
            THEN
               NULL;             --NOT BETWEEN ÇALISMADIGI IÇIN BÖYLE YAPILDI.
            ELSE
               v_tms_birthday := NULL;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_tms_birthday := NULL;
            WHEN OTHERS
            THEN
               v_tms_birthday := NULL;
         END;

         v_btv := kontrol_pack.btv_gca_bul (p_req_user, p_serial_number);

         tms_attributes ('BOLGEKODU', v_bolge, v_tms_bolge);
         tms_attributes ('COUNTRY', v_ulke, v_tms_ulke);
         tms_attributes ('CITYCODE', v_il, v_tms_il);
         tms_attributes ('FRANCHISE', v_franchise_code, v_tms_franchise_code);
         tms_attributes ('CUSTTYPE', v_customer_type, v_tms_customer_type);
         tms_attributes ('BRAND', v_brand, v_tms_brand);
         tms_attributes ('DISPLAYMSG',
                         v_ekran_mesaji_izleme,
                         v_tms_display_msg);
         tms_attributes ('STBMODEL', v_stb_type, v_tms_stb_type);
         tms_attributes ('BIRTH_DATE', v_birthdate, v_tms_birthday);
         tms_attributes ('BTVCOMPANY', v_btv, v_tms_btv);

         --  tms_attributes ( 'SERVICE_1',  v_service_1,          v_tms_service_1 ); -- service yapısı standarda uydurulursa, böyle olmalı.
         --  tms_attributes ( 'SATELLITE',  v_satellite_service,   v_tms_satellite_type );--TUNA GEREK KALMADI

         IF v_tms_il = '34'
         THEN
            v_tms_il :=
               TO_NUMBER (get_il_bolge (LPAD (v_tms_il, 3, '0'), v_ilce));
         END IF;

         v_service_1 :=
            dbs_addr_reqs_pack.find_product_type (v_account_number,
                                                  v_outlet_location,
                                                  v_brand);

         /*  0: PAKET        1:ZAP PAKET         2:ÇOCUK PAKETİ
             3:ZEUS PAKETİ           4:BCH SERVİSİ       5:BCS SERVİSİ
             6:BHS SERVİSİ           7:CHS SERVİSİ*/

         --     tms tablosuna gitmeden yapildi.
         v_tms_service_1 := v_service_1;
      ELSE
         --  Abone üzerinden düsürülmüs kartlarin TMS'lerinin hepsi default value'lara geri dönsün
         --  Bu arada karttaki filter product'lar da silinsin.
         --  Evirm Kayan, Ocak 2008
         v_tms_bolge := 0;
         v_tms_ulke := 0;
         v_tms_il := 0;
         v_tms_franchise_code := 0;
         v_tms_customer_type := 0;
         v_tms_brand := 0;
         v_tms_display_msg := 0;
         v_tms_stb_type := 0;
         v_tms_birthday := 0;
         v_tms_btv := 0;
         v_tms_service_1 := 0;
         v_tms_satellite_type := 0;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BOLGEKODU',
                                v_tms_bolge,
                                v_tms_bolge_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_bolge_old, 0) <> NVL (v_tms_bolge, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'BOLGEKODU';

         IF NVL (v_tms_bolge_old, 0) > 0
         THEN
            v_cancel_product_list :=
               dbs_addr.dbms_numsystem_package.dec2hex (
                    TO_NUMBER (v_product_number)
                  + TO_NUMBER (
                       dbs_addr.dbms_numsystem_package.dec2hex (
                          v_tms_bolge_old)));
         END IF;

         IF NVL (v_tms_bolge, 0) > 0
         THEN
            v_add_product_list :=
               dbs_addr.dbms_numsystem_package.dec2hex (
                    TO_NUMBER (v_product_number)
                  + TO_NUMBER (
                       dbs_addr.dbms_numsystem_package.dec2hex (v_tms_bolge)));
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'CITYCODE',
                                v_tms_il,
                                v_tms_il_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'COUNTRY',
                                v_tms_ulke,
                                v_tms_ulke_old,
                                p_errm,
                                p_out_tms);

      --Tuna:İNGİLTERE deki ekipmanlara BBC Prime (Entertainment) ve BBC World?ün Uk?de dağıtma hakkımız olmadığı için 31A0 productının eklenmesi gerekti
      IF NVL (v_tms_ulke_old, 0) <> NVL (v_tms_ulke, 0)
      THEN
         IF NVL (v_tms_ulke_old, 0) IN (7) OR v_tms_ulke IN (7)
         THEN
            SELECT product_number
              INTO v_product_number
              FROM dbs_addr_cas_filter_products
             WHERE code = 'COUNTRY'; --CNTYAYIN: ULKE BAZINDA KANAL KISITI KOYMAK ICIN KULLANILIYOR.

            --7:INGILTERE icin filter product
            IF v_tms_ulke_old = 7
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_ulke_old));
            ELSIF v_tms_ulke = 7
            THEN                        --ULKE:ingiltere olarak set ediliyorsa
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                     TO_NUMBER (v_product_number) + TO_NUMBER (v_tms_ulke));
            END IF;
         --7:INGILTERE icin filter product
         --ulke bazında eklenencek yeni filterproductlar olması durumunda aşağıdya eklenmelıdır.
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'FRANCHISE',
                                v_tms_franchise_code,
                                v_tms_franchise_code_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_franchise_code_old, 0) <> NVL (v_tms_franchise_code, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'FRANCHISE';

         IF NVL (v_tms_franchise_code_old, 0) > 0
         THEN
            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_franchise_code_old));
            ELSE
               v_cancel_product_list :=
                     v_cancel_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_franchise_code_old));
            END IF;
         END IF;

         IF NVL (v_tms_franchise_code, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_franchise_code));
            ELSE
               v_add_product_list :=
                     v_add_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_franchise_code));
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'CUSTTYPE',
                                v_tms_customer_type,
                                v_tms_customer_type_old,
                                p_errm,
                                p_out_tms);

      IF v_tms_customer_type IN (1, 3)
      THEN        --tuna 1:TICARI YADA OTEL:BLK ISE FILTER PRODUCT ÇIKILIYOR..
         IF NVL (v_tms_customer_type_old, 0) <> NVL (v_tms_customer_type, 0)
         THEN
            SELECT product_number
              INTO v_product_number
              FROM dbs_addr_cas_filter_products
             WHERE code = 'CUSTTYPE';

            IF NVL (v_tms_customer_type_old, 0) > 0
            THEN
               CASE v_tms_customer_type_old
                  WHEN 1
                  THEN
                     v_tms_customer_type_old := 0;   --TICARI ISE 3031+0->3031
                  WHEN 3
                  THEN
                     v_tms_customer_type_old := 1;   --OTEL ISE   3031+1->3032
                  ELSE
                     NULL;                                           --DEFAULT
               END CASE;

               IF v_cancel_product_list IS NULL
               THEN
                  v_cancel_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_customer_type_old));
               ELSE
                  v_cancel_product_list :=
                        v_cancel_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_customer_type_old));
               END IF;
            END IF;

            IF NVL (v_tms_customer_type, 0) > 0
            THEN
               CASE v_tms_customer_type
                  WHEN 1
                  THEN
                     v_tms_customer_type := 0;       --TICARI ISE 3031+0->3031
                  WHEN 2
                  THEN
                     v_tms_customer_type := 1;       --OTEL ISE   3031+1->3032
                  ELSE
                     NULL;                                           --DEFAULT
               END CASE;

               IF v_add_product_list IS NULL
               THEN
                  v_add_product_list :=
                     dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_customer_type));
               ELSE
                  v_add_product_list :=
                        v_add_product_list
                     || ','
                     || dbs_addr.dbms_numsystem_package.dec2hex (
                             TO_NUMBER (v_product_number)
                           + TO_NUMBER (v_tms_customer_type));
               END IF;
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BRAND',
                                v_tms_brand,
                                v_tms_brand_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'DISPLAYMSG',
                                v_tms_display_msg,
                                v_tms_display_msg_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'STBMODEL',
                                v_tms_stb_type,
                                v_tms_stb_type_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BIRTH_DATE',
                                v_tms_birthday,
                                v_tms_birthday_old,
                                p_errm,
                                p_out_tms);

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'BTVCOMPANY',
                                v_tms_btv,
                                v_tms_btv_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_btv_old, 0) <> NVL (v_tms_btv, 0)
      THEN
         IF NVL (v_tms_btv_old, 0) > 0
         THEN
            --Emine; 13/05/2009; filter product degerler sequential gitmedigi icin asagidaki satirlar commentlendi
            --SELECT PRODUCT_NUMBER INTO v_product_number FROM DBS_ADDR_CAS_FILTER_PRODUCTS WHERE CODE = 'BTVCOMPANY';
            SELECT gca
              INTO v_product_number
              FROM gca_pool
             WHERE gca_pool_id = v_tms_btv_old;

            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list := v_product_number;
            --v_cancel_product_list := DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_btv_old));
            ELSE
               v_cancel_product_list :=
                  v_cancel_product_list || ',' || v_product_number;
            --v_cancel_product_list := v_cancel_product_list||','|| DBS_ADDR.DBMS_NUMSYSTEM_PACKAGE.DEC2HEX(TO_NUMBER(v_product_number) + TO_NUMBER(v_tms_btv_old));
            END IF;
         END IF;

         IF NVL (v_tms_btv, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list := v_btv;
            ELSE
               v_add_product_list := v_add_product_list || ',' || v_btv;
            END IF;
         END IF;
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'SERVICE_01',
                                v_tms_service_1,
                                v_tms_service_1_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_service_1_old, 0) <> NVL (v_tms_service_1, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'SERVICE_01';

         IF NVL (v_tms_service_1_old, 0) > 0
         THEN
            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_service_1_old));
            ELSE
               v_cancel_product_list :=
                     v_cancel_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_service_1_old));
            END IF;
         END IF;

         IF NVL (v_tms_service_1, 0) > 0
         THEN
            IF v_add_product_list IS NULL
            THEN
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_service_1));
            ELSE
               v_add_product_list :=
                     v_add_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_service_1));
            END IF;
         END IF;
      END IF;

      v_tms_satellite_type :=
         abone_sorgu_pack.uye_uydusu (v_account_number, v_outlet_location);

      /*1:EutelSat 2:Turksat 3:Ortak, -1:Hatali durum*/
      IF v_tms_satellite_type < 0 OR v_tms_satellite_type = 3
      THEN               --Hatalı dönenler ve ortak uyduya sahip olanlar, tuna
         v_tms_satellite_type := 1;            --EUTALSAT OLARAK KABUL EDILIR.
      END IF;

      check_if_tms_attr_exists (p_serial_number,
                                p_req_user,
                                'SATELLITE',
                                v_tms_satellite_type,
                                v_tms_satellite_type_old,
                                p_errm,
                                p_out_tms);

      IF NVL (v_tms_satellite_type_old, 0) <> NVL (v_tms_satellite_type, 0)
      THEN
         SELECT product_number
           INTO v_product_number
           FROM dbs_addr_cas_filter_products
          WHERE code = 'SATELLITE';

         IF NVL (v_tms_satellite_type_old, 0) IN (1, 2)
         THEN
            CASE v_tms_satellite_type_old
               WHEN 1
               THEN
                  v_tms_satellite_type_old := 0;              --EUTALSAT: 3030
               WHEN 2
               THEN
                  v_tms_satellite_type_old := 3;              --TUKSAT  : 3033
               ELSE
                  v_tms_satellite_type_old := 0; --DEFAULT EUTALSAT FILTER PRODUCTI
            END CASE;

            IF v_cancel_product_list IS NULL
            THEN
               v_cancel_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_satellite_type_old));
            ELSE
               v_cancel_product_list :=
                     v_cancel_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_satellite_type_old));
            END IF;
         END IF;

         IF NVL (v_tms_satellite_type, 0) IN (1, 2)
         THEN
            CASE v_tms_satellite_type
               WHEN 1
               THEN
                  v_tms_satellite_type := 0;                   --EUTALSAT:3030
               WHEN 2
               THEN
                  v_tms_satellite_type := 3;                   --TUKSAT  :3033
               ELSE
                  v_tms_satellite_type := 0; --DEFAULT EUTALSAT FILTER PRODUCTI
            END CASE;

            IF v_add_product_list IS NULL
            THEN
               v_add_product_list :=
                  dbs_addr.dbms_numsystem_package.dec2hex (
                       TO_NUMBER (v_product_number)
                     + TO_NUMBER (v_tms_satellite_type));
            ELSE
               v_add_product_list :=
                     v_add_product_list
                  || ','
                  || dbs_addr.dbms_numsystem_package.dec2hex (
                          TO_NUMBER (v_product_number)
                        + TO_NUMBER (v_tms_satellite_type));
            END IF;
         END IF;
      END IF;

      p_out_cancel_product_list := v_cancel_product_list;
      p_out_add_product_list := v_add_product_list;

      IF p_out_tms IS NOT NULL AND p_force_send = 'E'
      THEN
         v_ret := 0;
         v_ret :=
            create_tms_attributes (v_req_dbs_type,
                                   p_serial_number,
                                   p_out_tms,
                                   v_req_date,
                                   p_req_user,
                                   v_tra_id,
                                   p_errm,
                                   'H');

         IF v_ret <> 1
         THEN
            p_errm := 'procedure find_tms: create_tms_attributes :' || p_errm;
         ELSE
            p_errm := '0';
         END IF;

         IF v_cancel_product_list IS NOT NULL AND p_force_send = 'E'
         THEN
            v_ret := 0;
            v_ret :=
               delete_entitlements (v_req_dbs_type,
                                    v_serial_number,
                                    v_cancel_product_list,
                                    SYSDATE,
                                    p_req_user,
                                    v_tra_id,
                                    p_errm,
                                    'H');

            IF v_ret <> 1
            THEN
               p_errm := 'procedure find_tms_add_product_for_bolge:' || p_errm;
            ELSE
               p_errm := '0';
            END IF;
         END IF;

         IF v_add_product_list IS NOT NULL AND p_force_send = 'E'
         THEN
            v_ret := 0;
            v_ret :=
               create_entitlements (v_req_dbs_type,
                                    v_serial_number,
                                    v_add_product_list,
                                    SYSDATE,
                                    p_req_user,
                                    v_tra_id,
                                    p_errm,
                                    'H');

            IF v_ret <> 1
            THEN
               p_errm := 'procedure find_tms_add_product_for_bolge:' || p_errm;
            ELSE
               p_errm := '0';
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_errm :=
            'procedure find_tms:p_out_tms:' || p_out_tms || ':' || SQLERRM;
   END;

   /********************************************************************************************************************/
   FUNCTION set_freetoair_limit (
      p_req_dbs_type       IN     VARCHAR2,
      p_serial_number      IN     VARCHAR2,
      p_enable_fta_limit   IN     VARCHAR2,
      p_valid_after        IN     DATE,
      p_req_user           IN     VARCHAR2,
      p_tra_id             IN OUT NUMBER,
      p_errm                  OUT VARCHAR2,
      p_chipset            IN     VARCHAR2 DEFAULT 'FFFFFFFF',
      p_daylimit           IN     VARCHAR2 DEFAULT '60',
      p_logla              IN     CHAR DEFAULT 'E',
      p_req_id             IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date           DATE := SYSDATE;
      v_req_type           NUMBER (3)
                              := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type     NUMBER (2);
      v_account_number     wiz_equip.account_number%TYPE;
      v_outlet_location    wiz_equip.outlet_location%TYPE;
      v_req_param          VARCHAR2 (1000);
      v_param              VARCHAR2 (1000);
      v_req_id             NUMBER (10);
      v_durum              VARCHAR2 (400);
      v_tra_id             NUMBER;
      v_enable_fta_limit   VARCHAR2 (2);
      v_chipset            VARCHAR2 (20);
      v_msg_length         VARCHAR2 (4);
      v_all_msg_length     VARCHAR2 (4);
      v_destination        VARCHAR2 (4) := '0002';
      v_tag                VARCHAR2 (2) := '54';
      v_daylimit           VARCHAR2 (2);
      input_exception      EXCEPTION;
      log_exception        EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF    p_enable_fta_limit IS NULL
         OR LENGTH (p_enable_fta_limit) != 1
         OR (p_enable_fta_limit <> '0' AND p_enable_fta_limit <> '1')
      THEN
         p_errm := 'p_enable_FTA_limit alani "0" veya "1" olabilir!';
         RAISE input_exception;
      END IF;

      IF p_chipset IS NULL OR LENGTH (p_chipset) != 8
      THEN
         p_errm := 'p_chipset alani 8 karakter uzunlugunda olmalidir!';
         RAISE input_exception;
      END IF;

      v_daylimit :=
         NVL (getdinamikkeyvalue ('FTA_60_SINYALI_GUN_LIMITI'), p_daylimit); -- varsa parametrik değeri kullan, yoksa default değeri

      --p_enable_other_mode = '1' means OTHER-MODE is enabled , otherwise it is disabled
      --p_chipset = 'FFFFFFFF' means it will ignore the comparison with STB secure-chipset-id (CSSN) and do the operation..

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                FALSE,
                                FALSE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_enable_fta_limit := RAWTOHEX (p_enable_fta_limit);
      v_chipset := TRIM (dbms_numsystem_package.hex2asciihex (p_chipset));

      v_param :=
         LPAD (v_enable_fta_limit, 2, '0') || LPAD (v_chipset, 16, '0');
      --v_param   := v_param || RAWTOHEX(p_DayLimit);
      v_param :=
            v_param
         || LPAD (dbs_addr_reqs_pack.to_hex (TO_NUMBER (v_daylimit)), 2, '0');
      v_param := v_param || '00';                            -- ReservedField1

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,   --p_prospect_number         number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date, --p_islem_tarihi            date,
                                   p_req_dbs_type, --p_islem_tipi             number,
                                   NULL,   --p_ppv_kredi_limiti        number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1           lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2           lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3           lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4           lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                       lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END set_freetoair_limit;

   /********************************************************************************************************************/

   FUNCTION finger_print_tms_msg_global (
      p_req_dbs_type     IN     VARCHAR2,
      p_tms_expression   IN     VARCHAR2,
      p_tms_duration     IN     NUMBER,
      p_tms_flashing     IN     CHAR,                            -- 'E' or 'H'
      p_tms_banner       IN     CHAR,                            -- 'E' or 'H'
      p_tms_coverage     IN     NUMBER,
      p_tms_overt        IN     CHAR,                            -- 'E' or 'H'
      p_valid_after      IN     DATE,
      p_req_user         IN     VARCHAR2,
      p_tra_id           IN OUT NUMBER,
      p_errm                OUT VARCHAR2,
      p_logla            IN     CHAR DEFAULT 'E',
      p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_req_type                NUMBER (3)
         := dbs_addr_pisys_msg_type_defs.m_t_fingerprint_tms_msg_global; --35;
      v_req_group_type          NUMBER (2);
      v_req_param               VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;

      v_gonderim_oneri_tarihi   DATE;
      v_valid_after             DATE := p_valid_after;
      v_allowed_valid_after     DATE := p_valid_after; --aynı zamanli global sinyallerin çıkılmasi PVR kutularda sürekli restart sorununa yol açtığından bu değişkene ihtiyaç duyuldu tuna 10.04.2012
      v_trying_cnt              NUMBER
         := TO_NUMBER (
               NVL (
                  dbs_addr.getdinamikkeyvalue (
                     'TRYING_COUNT_FOR_GLB_FINGER_PRINT'),
                  '1'));

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
      global_risk_exception     EXCEPTION;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF LENGTH (p_tms_expression) > 950
      THEN
         p_errm := 'p_tms_expression max 950 karakter olabilir!';
         RAISE input_exception;
      END IF;

      IF p_tms_duration IS NULL OR p_tms_duration <= 0
      THEN
         p_errm := 'p_tms_duration 0''dan buyuk bir deger (second) olabilir!';
         RAISE input_exception;
      END IF;

      IF p_tms_flashing IS NULL OR p_tms_flashing NOT IN ('E', 'H')
      THEN
         p_errm :=
            'p_tms_flashing parametresi ( ''E'' veya ''H'' ) olabilir !';
         RAISE input_exception;
      END IF;

      IF p_tms_banner IS NULL OR p_tms_banner NOT IN ('E', 'H')
      THEN
         p_errm := 'p_tms_banner parametresi ( ''E'' veya ''H'' ) olabilir !';
         RAISE input_exception;
      END IF;

      IF p_tms_coverage IS NULL OR p_tms_coverage < 0 OR p_tms_coverage > 100
      THEN
         p_errm :=
            'p_tms_coverage parametresi ( 0 - 100 ) araliginda olabilir !';
         RAISE input_exception;
      END IF;

      IF p_tms_overt IS NULL OR p_tms_overt NOT IN ('E', 'H')
      THEN
         p_errm := 'p_tms_overt parametresi ( ''E'' veya ''H'' ) olabilir !';
         RAISE input_exception;
      END IF;

      SELECT    p_tms_expression
             || '|'
             || TO_CHAR (p_tms_duration)
             || '|'
             || DECODE (p_tms_flashing, 'E', '0', '1')
             || '|'
             ||                              /* flashing : 0  ,  normal : 1 */
               DECODE (p_tms_banner, 'E', '1', '0')
             || '|'
             ||                              /* banner   : 1  ,  normal : 0 */
               TO_CHAR (p_tms_coverage)
             || '|'
             || DECODE (p_tms_overt, 'E', '0', '1') /* covert   : 1  ,  overt  : 0 */
        INTO v_req_param
        FROM DUAL;

      /*BEGIN GLOBAL SINYAL VALID_AFTER KONTROLU
      GLOBAL SINYAL GONDERIMLERINDE SORUN TESKIL EDEN SINYALLER ICIN, SINYAL GONDERIM ZAMANI(VALID_AFTER) AYNI ZAMANLI OLMAMALI.. tunahan 10.04.2012 */
      IF v_req_type =
            dbs_addr_pisys_msg_type_defs.m_t_fingerprint_tms_msg_global
      THEN
         p_errm :=
            dbs_dba.global_sinyal_kontrol (
               v_valid_after,
               dbs_addr_pisys_msg_type_defs.m_t_fingerprint_tms_msg_global,
               v_trying_cnt,
               v_allowed_valid_after --önerilen global sinyal valid after ı...
                                    );

         IF p_errm <> '0'
         THEN
            RAISE global_risk_exception;
         ELSE
            p_errm := NULL;

            IF v_allowed_valid_after IS NOT NULL
            THEN
               v_valid_after := v_allowed_valid_after;
            END IF;
         END IF;
      END IF;

      /*END GLOBAL SINYAL VALID_AFTER KONTROLU*/

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip ('99999999999', --p_serial_number        varchar2,
                                   NULL,      --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   SYSDATE,     --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id,    --out  lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;                                  -- hata mesaji
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   '99999999999',
                   0,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   SYSDATE                                        /*req-date*/
                          ,
                   v_valid_after,
                   v_req_param);

      RETURN 1;                                                     -- success
   EXCEPTION
      WHEN input_exception OR log_exception OR global_risk_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION set_ippv_debit_limit_threshold (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_threshold       IN     NUMBER,
      p_valid_after     IN     DATE,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_err_msg            OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_req_type                NUMBER (3)
                                   := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_param                   VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;

      v_msg_length              VARCHAR2 (4);
      v_all_msg_length          VARCHAR2 (4);
      v_destination             VARCHAR2 (4) := '0001';
      v_tag                     VARCHAR2 (2) := '05';
      v_len                     NUMBER;
      v_ekipman_tip_matrix_id   NUMBER (10);
      v_ekipman_ozellik         VARCHAR2 (3);

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;

      v_modem_destekli          BOOLEAN := FALSE;
      v_ethernet_destekli       BOOLEAN := FALSE;
   BEGIN
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_err_msg := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_err_msg := 'Serial-No parametresi hatali!';
         RAISE input_exception;
      END IF;

      IF p_threshold IS NULL OR p_threshold < 0 OR p_threshold > 100
      THEN
         p_err_msg := 'Threshold parametresi (0-100) araliginda olmalidir !';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_err_msg,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_err_msg IS NOT NULL AND p_err_msg <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_err_msg := NULL;
         -- 08/08/2011; Taner; sadece (modem veya ethernet) destekli kutulara IPPV yetkilerinin cikmasi isteniyor

         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       66                            /*modem*/
                                         ,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_modem_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         ekipman_pack.ekipman_ozellik (NULL,
                                       v_account_number,
                                       v_outlet_location,
                                       101                        /*ethernet*/
                                          ,
                                       v_ekipman_tip_matrix_id,
                                       v_ekipman_ozellik);
         v_ethernet_destekli :=
            (v_ekipman_ozellik IS NOT NULL AND v_ekipman_ozellik = 'E');

         IF v_modem_destekli = FALSE AND v_ethernet_destekli = FALSE
         THEN
            RETURN 1;              -- ne MODEM ne de ETHERNET destekli degil..
         END IF;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_param := LPAD (dbms_numsystem_package.dec2hex (p_threshold), 2, '0');

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);
      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   SYSDATE,     --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_err_msg := v_durum;                               -- hata mesaji
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   SYSDATE                                        /*req-date*/
                          ,
                   p_valid_after,
                   v_req_param);

      RETURN 1;                                                     -- success
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_err_msg := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION reset_bouquet_channel_order (
      p_req_dbs_type     IN     VARCHAR2,
      p_serial_number    IN     VARCHAR2,
      p_bouquet_id       IN     NUMBER DEFAULT 130,
      p_tms_attributes   IN     VARCHAR2 DEFAULT NULL,
      p_valid_after      IN     DATE,
      p_req_user         IN     VARCHAR2,
      p_tra_id           IN OUT NUMBER,
      p_errm                OUT VARCHAR2,
      p_logla            IN     CHAR DEFAULT 'E',
      p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3);
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_param                   VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;
      v_msg_length              VARCHAR2 (4);
      v_all_msg_length          VARCHAR2 (4);
      v_destination             VARCHAR2 (4) := '0002';
      v_tag                     VARCHAR2 (2) := '10';

      v_gonderim_oneri_tarihi   DATE;
      v_valid_after             DATE := p_valid_after;
      v_allowed_valid_after     DATE := p_valid_after; --aynı zamanli global sinyallerin çıkılmasi PVR kutularda sürekli restart sorununa yol açtığından bu değişkene ihtiyaç duyuldu tuna 10.04.2012
      v_trying_cnt              NUMBER
         := TO_NUMBER (
               NVL (
                  dbs_addr.getdinamikkeyvalue (
                     'TRYING_COUNT_FOR_GLB_BOUQUET'),
                  '30'));
      v_log_bouqet_type         VARCHAR2 (30);

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
      global_risk_exception     EXCEPTION;
   BEGIN
      IF p_serial_number = '99999999999'
      THEN
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_reset_bouqet_ch_ord_global;
      ELSE
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_reset_bouqet_ch_ord;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_bouquet_id IS NULL
      THEN
         p_errm := 'p_bouquet_id parametresi NULL olamaz!';
         RAISE input_exception;
      END IF;

      --TUNA 12.10.2011 EKLENDI.
      IF p_serial_number <> '99999999999'
      THEN
         SELECT NVL (account_number, 0)
           INTO v_account_number
           FROM wiz_equip
          WHERE serial_number = p_serial_number;
      END IF;

      v_param := TO_CHAR (p_bouquet_id);

      IF v_req_type =
            dbs_addr_pisys_msg_type_defs.m_t_reset_bouqet_ch_ord_global
      THEN
         v_req_param := v_param || '|' || p_tms_attributes;
      ELSE
         v_req_param := v_param;
      END IF;

      v_account_number := NVL (v_account_number, 0);

      /*BEGIN GLOBAL SINYAL VALID_AFTER KONTROLU
      GLOBAL SINYAL GONDERIMLERINDE SORUN TESKIL EDEN SINYALLER ICIN, SINYAL GONDERIM ZAMANI(VALID_AFTER) AYNI ZAMANLI OLMAMALI.. tunahan 10.04.2012 */
      IF v_req_type =
            dbs_addr_pisys_msg_type_defs.m_t_reset_bouqet_ch_ord_global
      THEN
         p_errm :=
            dbs_dba.global_sinyal_kontrol (
               v_valid_after,
               dbs_addr_pisys_msg_type_defs.m_t_reset_bouqet_ch_ord_global,
               v_trying_cnt,
               v_allowed_valid_after    --önerilen global sinyal valid after..
                                    );

         IF p_errm <> '0'
         THEN
            RAISE global_risk_exception;
         ELSE
            p_errm := NULL;

            IF v_allowed_valid_after IS NOT NULL
            THEN
               v_valid_after := v_allowed_valid_after;
            END IF;
         END IF;
      END IF;

      /*END GLOBAL SINYAL VALID_AFTER KONTROLU*/
      BEGIN
         SELECT key
           INTO v_log_bouqet_type
           FROM dbs_addr.dbs_addr_sabit
          WHERE VALUE = TO_CHAR (p_bouquet_id);
      EXCEPTION
         WHEN OTHERS
         THEN
            v_log_bouqet_type := NULL;
      END;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   v_log_bouqet_type, --p_mesaj_metni         varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                   lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   v_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception OR global_risk_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/
   FUNCTION test_mode_emm (p_req_dbs_type     IN     VARCHAR2,
                           p_serial_number    IN     VARCHAR2,
                           p_tms_attributes   IN     VARCHAR2,
                           p_valid_after      IN     DATE,
                           p_req_user         IN     VARCHAR2,
                           p_tra_id           IN OUT NUMBER,
                           p_errm                OUT VARCHAR2,
                           p_logla            IN     CHAR DEFAULT 'E',
                           p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_destination       VARCHAR2 (4) := '0001';
      v_tag               VARCHAR2 (2) := '08';
      v_lenght            VARCHAR2 (4) := '0002';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);
      /*IF p_errm IS NOT NULL AND p_errm <> '0' THEN
         RAISE INPUT_EXCEPTION;
      ELSE
         p_errm     := NULL;
      END IF;*/

      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_req_param :=
            '01000309000100093C00'
         || v_destination
         || v_tag
         || v_lenght
         || '0001';

      DBMS_OUTPUT.put_line ('v_param' || v_req_param);

      --01000309000100093C0000010800020001

      -- v_req_param := '01000309000100073C00'||v_destination||v_tag||'0000';

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_req_param := v_req_param || '|' || p_tms_attributes;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                 varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi           number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,    --p_mesaj_metni          varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION patch_smartcard (p_req_dbs_type    IN     VARCHAR2,
                             p_serial_number   IN     VARCHAR2,
                             p_valid_after     IN     DATE,
                             p_req_user        IN     VARCHAR2,
                             p_tra_id          IN OUT NUMBER,
                             p_errm               OUT VARCHAR2,
                             p_logla           IN     CHAR DEFAULT 'E',
                             p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3)
                             := dbs_addr_pisys_msg_type_defs.m_t_patch_smartcard; --88
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION set_data_mining_params (
      p_req_dbs_type       IN     VARCHAR2,
      p_serial_number      IN     VARCHAR2,
      p_tms_attributes     IN     VARCHAR2,
      p_phone_no           IN     VARCHAR2,
      p_ip_address         IN     VARCHAR2,
      p_port_no            IN     NUMBER,
      p_rating_date_time   IN     VARCHAR2,               /* special-format */
      p_username           IN     VARCHAR2,
      p_password           IN     VARCHAR2,
      p_valid_after        IN     DATE,
      p_req_user           IN     VARCHAR2,
      p_tra_id             IN OUT NUMBER,
      p_errm                  OUT VARCHAR2,
      p_logla              IN     CHAR DEFAULT 'E',
      p_req_id             IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_param             VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_msg_length        VARCHAR2 (4);
      v_all_msg_length    VARCHAR2 (4);
      v_destination       VARCHAR2 (4) := '0001';
      v_tag               VARCHAR2 (2) := '02';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;

      v_phone_no          VARCHAR2 (32);
      v_ip_address        VARCHAR2 (8);
      v_port_no           VARCHAR2 (4);

      v_rating_datetime   VARCHAR2 (16)
                             := NVL (p_rating_date_time, '9999.99.99.99.99');
      -- input NULL gelirse default olarak "scheduling" ozelligini DISABLE edecektir..

      v_year              VARCHAR (50);
      v_month             VARCHAR (50);
      v_day               VARCHAR (50);
      v_hour              VARCHAR (2);
      v_minute            VARCHAR (2);

      v_date_num          NUMBER;
      v_date_part         VARCHAR2 (10);
      v_time_part         VARCHAR2 (4);

      v_username          VARCHAR2 (20);
      v_password          VARCHAR2 (40);
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_phone_no IS NULL
      THEN
         v_phone_no := '00000000000000000000000000000000'; -- 16 byte  ( fakat burda HEX olarak tutulacak )
      ELSIF LENGTH (p_phone_no) > 16
      THEN
         p_errm := 'Telefon numarasi 16 haneden uzun olamaz !';
         RAISE input_exception;
      ELSE
         BEGIN
            IF TO_NUMBER (p_phone_no) IS NOT NULL
            THEN
               FOR i IN 1 .. LENGTH (p_phone_no)
               LOOP
                  v_phone_no :=
                        v_phone_no
                     || NVL (
                           dbs_addr.dbms_numsystem_package.dec2hex (
                              ASCII (SUBSTR (p_phone_no, i, 1))),
                           '0');
               END LOOP;

               v_phone_no := RPAD (v_phone_no, 32, '0');
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errm :=
                     'Gecersiz telefon numarasi bilgisi : '
                  || SUBSTR (SQLERRM, 1, 255);
               RAISE input_exception;
         END;
      END IF;

      IF p_ip_address IS NULL OR LENGTH (p_ip_address) < 7
      THEN
         p_errm := 'IP-Address parameter is NULL or INVALID !';
         RAISE input_exception;
      ELSE
         -- IpAddress : 4 byte ( octet'ler halinde toplam 32 bit eder , burada HEX tutulacak.. )
         DECLARE
            v_ip_block_1   NUMBER := NULL;
            v_ip_block_2   NUMBER := NULL;
            v_ip_block_3   NUMBER := NULL;
            v_ip_block_4   NUMBER := NULL;
         BEGIN
            v_ip_block_1 := TO_NUMBER (dbs_dba.split (p_ip_address, 1, '.'));
            v_ip_block_2 := TO_NUMBER (dbs_dba.split (p_ip_address, 2, '.'));
            v_ip_block_3 := TO_NUMBER (dbs_dba.split (p_ip_address, 3, '.'));
            v_ip_block_4 := TO_NUMBER (dbs_dba.split (p_ip_address, 4, '.'));
            v_ip_address :=
                  LPAD (dbms_numsystem_package.dec2hex (v_ip_block_1),
                        2,
                        '0')
               || LPAD (dbms_numsystem_package.dec2hex (v_ip_block_2),
                        2,
                        '0')
               || LPAD (dbms_numsystem_package.dec2hex (v_ip_block_3),
                        2,
                        '0')
               || LPAD (dbms_numsystem_package.dec2hex (v_ip_block_4),
                        2,
                        '0');
         EXCEPTION
            WHEN OTHERS
            THEN
               p_errm :=
                     'Gecersiz ip-address bilgisi : '
                  || SUBSTR (SQLERRM, 1, 255);
               RAISE input_exception;
         END;
      END IF;

      IF p_port_no IS NULL OR p_port_no < 0 OR p_port_no > 65535
      THEN
         p_errm := 'Port number  [ 0 - 65535 ] araliginda olmalidir !';
         RAISE input_exception;
      ELSE
         v_port_no :=
            LPAD (dbms_numsystem_package.dec2hex (p_port_no), 4, '0');
      END IF;

      IF v_rating_datetime IS NULL OR LENGTH (v_rating_datetime) <> 16
      THEN
         p_errm := 'Rating-Date-Time parameter is NULL or INVALID  !';
         RAISE input_exception;
      END IF;

      v_year :=
         TO_CHAR (
            dbms_numsystem_package.dec2bin (
               TO_NUMBER (SUBSTR (v_rating_datetime, 0, 4)) - 1990));

      IF SUBSTR (v_rating_datetime, 0, 4) = '2096'
      THEN                                           -- PERIODIC for EVERY DAY
         v_month := '0000';
         v_day := '00000';
      ELSE                                  --NONPERIODIC DATE-TIME IS DEFINED
         v_month :=
            TO_CHAR (
               dbms_numsystem_package.dec2bin (
                  SUBSTR (v_rating_datetime, 6, 2)));
         v_day :=
            TO_CHAR (
               dbms_numsystem_package.dec2bin (
                  SUBSTR (v_rating_datetime, 9, 2)));
      END IF;

      v_hour := SUBSTR (v_rating_datetime, 12, 2);
      v_minute := SUBSTR (v_rating_datetime, 15, 2);

      v_year := LPAD (v_year, 7, '0');
      v_month := LPAD (v_month, 4, '0');
      v_day := LPAD (v_day, 5, '0');
      v_hour := LPAD (v_hour, 2, '0');
      v_minute := LPAD (v_minute, 2, '0');

      v_date_num :=
         dbms_numsystem_package.bin2dec (v_year || v_month || v_day);
      v_date_part := dbms_numsystem_package.dec2hex (v_date_num); -- date calculation
      v_time_part := v_hour || v_minute;

      --dbms_output.put_line('DatePart = ' || v_date_part);
      --dbms_output.put_line('TimePart = ' || v_time_part);

      IF p_username IS NULL
      THEN
         v_username := '00000000000000000000'; -- 10 byte  ( fakat burda HEX olarak tutulacak )
      ELSIF LENGTH (p_username) > 10
      THEN
         p_errm := 'Username 10 haneden uzun olamaz !';
         RAISE input_exception;
      ELSE
         SELECT RAWTOHEX (p_username) INTO v_username FROM DUAL;

         v_username := RPAD (v_username, 20, '0');
      END IF;

      IF p_password IS NULL
      THEN
         v_password := '0000000000000000000000000000000000000000'; -- 20 byte  ( fakat burda HEX olarak tutulacak )
      ELSIF LENGTH (p_password) > 20
      THEN
         p_errm := 'Password 20 haneden uzun olamaz !';
         RAISE input_exception;
      ELSE
         SELECT RAWTOHEX (p_password) INTO v_password FROM DUAL;

         v_password := RPAD (v_password, 40, '0');
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      -- dbms_output.put_line('v_phone_no = ' || v_phone_no);
      -- dbms_output.put_line('v_ip_address = ' || v_ip_address);
      -- dbms_output.put_line('v_port_no = ' || v_port_no);
      -- dbms_output.put_line('v_date_part = ' || v_date_part);
      -- dbms_output.put_line('v_time_part = ' || v_time_part);
      -- dbms_output.put_line('v_username = ' || v_username);
      -- dbms_output.put_line('v_password = ' || v_password);

      v_param :=
            v_phone_no
         || v_ip_address
         || v_port_no
         || v_date_part
         || v_time_part
         || v_username
         || v_password;

      --v_msg_length      := LPAD(LENGTH(v_param) / 2, 4, 0); --MKECECI - bu parametre decimal olarak kalmış.hex dönüşümü yapıldı
      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_param := v_param || '|' || p_tms_attributes;
      END IF;

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION data_mining_setup (p_req_dbs_type     IN     VARCHAR2,
                               p_serial_number    IN     VARCHAR2,
                               p_tms_attributes   IN     VARCHAR2,
                               p_status           IN     VARCHAR2 /* 'E' or 'H' */
                                                                 ,
                               p_threshold        IN     NUMBER,
                               p_delay            IN     NUMBER,
                               p_valid_after      IN     DATE,
                               p_req_user         IN     VARCHAR2,
                               p_tra_id           IN OUT NUMBER,
                               p_errm                OUT VARCHAR2,
                               p_logla            IN     CHAR DEFAULT 'E',
                               p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3);
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_param             VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;

      v_msg_length        VARCHAR2 (4);
      v_all_msg_length    VARCHAR2 (8);
      v_destination       VARCHAR2 (4) := '0002';
      v_tag               VARCHAR2 (2) := '01';

      input_exception     EXCEPTION;
      log_exception       EXCEPTION;

      v_status            VARCHAR2 (2);
      v_threshold         VARCHAR2 (2);
      v_delay             VARCHAR2 (4);
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;

         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global; --109;
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF p_status IS NULL OR p_status NOT IN ('E', 'H')
      THEN
         p_errm := 'Status parametresi eksik veya gecersiz !';
         RAISE input_exception;
      ELSIF p_status = 'E'
      THEN
         v_status := '01';      -- 8-bit field is set to 0x01  ( HEXEDECIMAL )
      ELSIF p_status = 'H'
      THEN
         v_status := '00';                -- 8-bit field is set to otherwise..
      END IF;

      IF p_threshold IS NULL OR p_threshold < 0 OR p_threshold > 100
      THEN
         p_errm := 'Threshold parametresi (0-100) araliginda olmalidir !';
         RAISE input_exception;
      ELSE
         v_threshold :=
            LPAD (dbms_numsystem_package.dec2hex (p_threshold), 2, '0');
      END IF;

      IF p_delay IS NULL OR p_delay < 5 OR p_threshold > 3600
      THEN
         p_errm :=
            'Delay (zap-time) parametresi 5 ile 3600 saniye araliginda olmalidir !';
         RAISE input_exception;
      ELSE
         v_delay := LPAD (dbms_numsystem_package.dec2hex (p_delay), 4, '0');
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      -- dbms_output.put_line('v_status = ' || v_status);
      -- dbms_output.put_line('v_threshold = ' || v_threshold);
      -- dbms_output.put_line('v_delay = ' || v_delay);

      v_param := v_status || v_threshold || v_delay;
      v_msg_length := LPAD (LENGTH (v_param) / 2, 4, 0);

      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      IF     v_req_type =
                dbs_addr_pisys_msg_type_defs.m_t_download_user_data_global
         AND p_tms_attributes IS NOT NULL
         AND LENGTH (p_tms_attributes) > 0
      THEN
         v_param := v_param || '|' || p_tms_attributes;
      END IF;

      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION rating (p_req_dbs_type     IN     VARCHAR2,
                    p_serial_number    IN     VARCHAR2,
                    p_tms_attributes   IN     VARCHAR2,
                    p_status           IN     VARCHAR2        /* 'E' or 'H' */
                                                      ,
                    p_valid_after      IN     DATE,
                    p_req_user         IN     VARCHAR2,
                    p_tra_id              OUT NUMBER,
                    p_err_msg             OUT VARCHAR2)
      RETURN NUMBER
   IS
      v_tra_id             NUMBER;
      v_result             NUMBER (1);
      v_rating_date_time   VARCHAR2 (50);
      v_errm               VARCHAR2 (500);
      v_exists             NUMBER;
   BEGIN
      v_result :=
         data_mining_setup (p_req_dbs_type,
                            p_serial_number,
                            p_tms_attributes,
                            p_status,
                            75                                 /*  threshold*/
                              ,
                            60                                   /* seconds */
                              ,
                            p_valid_after,
                            p_req_user,
                            p_tra_id,
                            p_err_msg);

      --dbms_output.put_line('v_result-1 (data-mining-setup) ==> ' || to_char(v_result) );
      IF v_result = 0 OR p_status = 'H'
      THEN
         RETURN v_result;
      END IF;

      -- extradan SET_DATA_MINING_PARAMS sinyalini cikmaya calisalim asagida.. Ancak RETURN ederken ustteki sinyal sonucunu daha cok onemsiyoruz..

      BEGIN
         SELECT rating_date_time
           INTO v_rating_date_time
           FROM dbs_addr_equip
          WHERE     serial_number = p_serial_number
                AND rating_date_time IS NOT NULL;

         v_rating_date_time := SUBSTR (v_rating_date_time, 9); -- bu verinin sondaki 3 parcasi alinsin =   '2096.00.00.21.35' icin '00.21.35'
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_rating_date_time := NULL;
         WHEN OTHERS
         THEN
            v_rating_date_time := '99.99.99'; -- Scheduled-DateTime bilgisi cekilemediginden bu ozellik olmadan sinyal cikacak..
      END;

      IF v_rating_date_time IS NULL
      THEN -- Eger bu ekipman icin kayitli bir "scheduled-datetime" yoksa kaydetmeye calissin..
         v_result := get_rating_date_time (v_rating_date_time, v_errm);

         IF v_result = 0
         THEN
            v_rating_date_time := '99.99.99'; -- set edilecek bir periyodik zaman dilimi bulunamadi.. Scheduled reporting olmadan sinyal cikacak..
         ELSE
            BEGIN
               SELECT COUNT (1)
                 INTO v_exists
                 FROM dbs_addr_equip
                WHERE serial_number = p_serial_number;

               IF v_exists <> 1
               THEN -- yukaridaki tabloda tek kayıt varsa eger "scheduled-datetime" aktive edilecek , yoksa edilmeyecek..
                  v_rating_date_time := '99.99.99'; -- guncellenecek uygun kayit bulunamadigindan  "scheduled-reporting" olmadan sinyal cikacak..
               ELSIF v_exists = 1
               THEN -- Bunun icin eger gerekiyorsa daha oncesinde CallBack-DateTime bilgisi icin buraya INSERT atilmis olmali..
                  UPDATE dbs_addr_equip
                     SET rating_date_time =
                            '2096.00.' || TRIM (v_rating_date_time),
                         degistiren_kullanici = 'SYSTEM',
                         degistirme_tarihi = SYSDATE
                   WHERE serial_number = p_serial_number;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_rating_date_time := '99.99.99'; -- "scheduled-reporting" olmadan sinyal cikacak..
            END;
         END IF;
      END IF;

      IF v_rating_date_time IS NULL
      THEN
         v_rating_date_time := '9999.99.' || TRIM ('99.99.99');
      ELSIF v_rating_date_time = '99.99.99'
      THEN
         v_rating_date_time := '9999.99.' || TRIM (v_rating_date_time);
      ELSE
         v_rating_date_time := '2096.00.' || TRIM (v_rating_date_time); -- en basindaki 2096 degeri gunluk periyodik cikacagini isaret ediyor..
      END IF;

      v_result :=
         set_data_mining_params (p_req_dbs_type,
                                 p_serial_number,
                                 p_tms_attributes,
                                 NULL                           /* phone-no */
                                     ,
                                 '212.252.205.236',
                                 7785,
                                 v_rating_date_time,
                                 NULL                             /*username*/
                                     ,
                                 NULL                             /*password*/
                                     ,
                                 p_valid_after,
                                 p_req_user,
                                 p_tra_id,
                                 v_errm,
                                 'H'                               /* logla */
                                    );

      -- dbms_output.put_line('v_result-2 (data_mining_params) ==> ' || to_char(v_result) );
      /* IF v_result <> 1 THEN
          UPDATE DBS_ADDR_PISYS_REQS SET daemon_session_id = RPAD(substr(v_errm,1,40) , 40, ' ') WHERE tra_id = v_tra_id;
      END IF; */

      RETURN 1; -- basarili ( ilk sinyal basarili oldugundan bu noktada artik her halukarda basarili diyecegiz.. )
   EXCEPTION
      WHEN OTHERS
      THEN
         p_err_msg := SUBSTR (SQLERRM, 1, 255);
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION reset_ird_unique (p_req_dbs_type    IN     VARCHAR2,
                              p_serial_number   IN     VARCHAR2,
                              p_valid_after     IN     DATE,
                              p_req_user        IN     VARCHAR2,
                              p_tra_id          IN OUT NUMBER,
                              p_errm               OUT VARCHAR2,
                              p_logla           IN     CHAR DEFAULT 'E',
                              p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_req_date          DATE := SYSDATE;
      v_req_type          NUMBER (3) := dbs_addr_pisys_msg_type_defs.m_t_reset; --42
      v_req_group_type    NUMBER (2);
      v_account_number    wiz_equip.account_number%TYPE;
      v_outlet_location   wiz_equip.outlet_location%TYPE;
      v_req_param         VARCHAR2 (1000);
      v_req_id            NUMBER (10);
      v_durum             VARCHAR2 (400);
      v_tra_id            NUMBER;
      input_exception     EXCEPTION;
      log_exception       EXCEPTION;
   BEGIN
      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RAISE input_exception;
      ELSE
         p_errm := NULL;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number        varchar2,
                                   v_account_number, --p_account_number       number,
                                   NULL,      --p_prospect_number      number,
                                   NULL,      --p_service_address_id   number,
                                   NULL,    --p_equip_location_code  varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,  --p_islem_tarihi         date,
                                   p_req_dbs_type, --p_islem_tipi              number,
                                   NULL,      --p_ppv_kredi_limiti     number,
                                   NULL,      --p_msg_account_number   number,
                                   NULL,    --p_msg_serial_number    varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1        lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2        lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3        lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4        lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                    lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   p_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION rescan_all_networks (
      p_req_dbs_type     IN     VARCHAR2,
      p_serial_number    IN     VARCHAR2,
      p_tms_attributes   IN     VARCHAR2,
      p_valid_after      IN     DATE,
      p_req_user         IN     VARCHAR2,
      p_tra_id           IN OUT NUMBER,
      p_errm                OUT VARCHAR2,
      p_logla            IN     CHAR DEFAULT 'E',
      p_req_id           IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3);
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;

      v_gonderim_oneri_tarihi   DATE;
      v_valid_after             DATE := p_valid_after;
      v_allowed_valid_after     DATE := p_valid_after; --aynı zamanli global sinyallerin çıkılmasi PVR kutularda sürekli restart sorununa yol açtığından bu değişkene ihtiyaç duyuldu tuna 10.04.2012
      v_trying_cnt              NUMBER
         := TO_NUMBER (
               NVL (
                  dbs_addr.getdinamikkeyvalue (
                     'TRYING_COUNT_FOR_GLB_STANDBY'),
                  '10'));

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
      global_risk_exception     EXCEPTION;
   BEGIN
      IF p_serial_number <> '99999999999'
      THEN
         v_req_type := dbs_addr_pisys_msg_type_defs.m_t_rescan_all_networks; -- 40
         karta_sinyal_gidebilirmi (p_serial_number,
                                   v_account_number,
                                   v_outlet_location,
                                   v_req_type,
                                   p_errm,
                                   TRUE,
                                   TRUE,
                                   TRUE);

         IF p_errm IS NOT NULL AND p_errm <> '0'
         THEN
            RAISE input_exception;
         ELSE
            p_errm := NULL;
         END IF;
      ELSE
         v_req_type :=
            dbs_addr_pisys_msg_type_defs.m_t_rescan_all_networks_global; -- 41
         v_req_param := p_tms_attributes; -- parametre olarak sadece TMS attribute degeri sozkonusu..
         v_account_number := 0;
      END IF;

      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      IF LENGTH (p_serial_number) != 11
      THEN
         p_errm := 'Serial No hatali!';
         RAISE input_exception;
      END IF;

      /*BEGIN GLOBAL SINYAL VALID_AFTER KONTROLU
      GLOBAL SINYAL GONDERIMLERINDE SORUN TESKIL EDEN SINYALLER ICIN, SINYAL GONDERIM ZAMANI(VALID_AFTER) AYNI ZAMANLI OLMAMALI.. tunahan 10.04.2012 */
      IF v_req_type =
            dbs_addr_pisys_msg_type_defs.m_t_rescan_all_networks_global
      THEN
         p_errm :=
            dbs_dba.global_sinyal_kontrol (
               v_valid_after,
               dbs_addr_pisys_msg_type_defs.m_t_rescan_all_networks_global,
               v_trying_cnt,
               v_allowed_valid_after);

         IF p_errm <> '0'
         THEN
            RAISE global_risk_exception;
         ELSE
            p_errm := NULL;

            IF v_allowed_valid_after IS NOT NULL
            THEN
               v_valid_after := v_allowed_valid_after;
            END IF;
         END IF;
      END IF;

      /*END GLOBAL SINYAL VALID_AFTER KONTROLU*/

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,     --p_mesaj_metni         varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                   lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   p_req_user,
                   v_req_date,
                   v_valid_after,
                   v_req_param);

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception OR global_risk_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END;

   /********************************************************************************************************************/

   FUNCTION force_status_report (
      p_req_dbs_type    IN     VARCHAR2,
      p_serial_number   IN     VARCHAR2,
      p_phone_number    IN     VARCHAR2,
      p_ip_address      IN     VARCHAR2,
      p_port            IN     NUMBER,
      p_username        IN     VARCHAR2,
      p_password        IN     VARCHAR2,
      p_valid_after     IN     VARCHAR2,
      p_req_user        IN     VARCHAR2,
      p_tra_id          IN OUT NUMBER,
      p_errm               OUT VARCHAR2,
      p_logla           IN     CHAR DEFAULT 'E',
      p_req_id          IN     NUMBER DEFAULT NULL)
      RETURN NUMBER
   AS
      c_report_type    CONSTANT CHAR (4) := '01';    -- report format

      v_req_date                DATE := SYSDATE;
      v_req_type                NUMBER (3);
      v_req_group_type          NUMBER (2);
      v_account_number          wiz_equip.account_number%TYPE;
      v_outlet_location         wiz_equip.outlet_location%TYPE;
      v_req_param               VARCHAR2 (1000);
      v_param                   VARCHAR2 (1000);
      v_req_id                  NUMBER (10);
      v_durum                   VARCHAR2 (400);
      v_tra_id                  NUMBER;
      v_duration                NUMBER := 1;
      v_time_diff               VARCHAR2 (10);
      v_start_date_time_w_gmt   DATE;
      v_time_before             NUMBER (8);
      v_time_after              NUMBER (8);

      v_msg_length              VARCHAR2 (4);
      v_all_msg_length          VARCHAR2 (4);
      v_destination             VARCHAR2 (4) := '0001';
      v_tag                     VARCHAR2 (2) := '07';
      v_ip_address              VARCHAR2 (1000);

      input_exception           EXCEPTION;
      log_exception             EXCEPTION;
   BEGIN
      p_errm := '0';
      v_req_type := dbs_addr_pisys_msg_type_defs.m_t_download_user_data; --108;
      v_req_group_type := get_req_type_group (v_req_type);

      IF v_req_group_type = 0
      THEN
         p_errm := 'Bu mesaj tipi için mesaj grubu bulunamadi!';
         RAISE input_exception;
      END IF;

      karta_sinyal_gidebilirmi (p_serial_number,
                                v_account_number,
                                v_outlet_location,
                                v_req_type,
                                p_errm,
                                TRUE,
                                TRUE,
                                TRUE);

      IF p_errm IS NOT NULL AND p_errm <> '0'
      THEN
         RETURN 0;
      ELSE
         p_errm := '0';
      END IF;

      IF p_req_id IS NULL
      THEN
         SELECT seq_addr_req_id.NEXTVAL INTO v_req_id FROM DUAL;
      ELSE
         v_req_id := p_req_id;
      END IF;

      v_ip_address :=
            LPAD (dbms_numsystem_package.dec2hex (212), 2, 0)
         || LPAD (dbms_numsystem_package.dec2hex (252), 2, 0)
         || LPAD (dbms_numsystem_package.dec2hex (205), 2, 0)
         || LPAD (dbms_numsystem_package.dec2hex (236), 2, 0);

      v_param :=
            LPAD (
               NVL (
                  dbs_addr.dbms_numsystem_package.hex2asciihex (
                     p_phone_number),
                  0),
               32,
               '0')
         || LPAD (v_ip_address, 8, '0')
         || LPAD (dbs_addr.dbms_numsystem_package.dec2hex (p_port), 4, '0')
         || LPAD (
               NVL (
                  dbs_addr.dbms_numsystem_package.hex2asciihex (p_username),
                  0),
               40,
               '0')
         || LPAD (
               NVL (
                  dbs_addr.dbms_numsystem_package.hex2asciihex (p_password),
                  0),
               40,
               '0')
         || LPAD (c_report_type, 2, '0');

      v_msg_length :=
         LPAD (dbms_numsystem_package.dec2hex (LENGTH (v_param) / 2), 4, 0);
      v_all_msg_length :=
         LPAD (
            dbms_numsystem_package.dec2hex (
                 LENGTH (
                       '3C00'
                    || v_destination
                    || v_tag
                    || v_msg_length
                    || v_param)
               / 2),
            4,
            0);

      --dbms_output.put_line('v_msg_length :'||v_msg_length);
      --dbms_output.put_line('v_all_msg_length :'||v_all_msg_length);
      v_req_param :=
            '010003090001'
         || v_all_msg_length
         || '3C00'
         || v_destination
         || v_tag
         || v_msg_length
         || v_param;

      --dbms_output.put_line('v_req_param :'||v_req_param);

      IF p_logla IS NULL OR p_logla = 'E'
      THEN
         log_pack.log_mesaj_takip (p_serial_number, --p_serial_number       varchar2,
                                   v_account_number, --p_account_number      number,
                                   NULL,       --p_prospect_number     number,
                                   NULL,       --p_service_address_id  number,
                                   NULL,     --p_equip_location_code varchar2,
                                   p_req_user, --p_kisi                  varchar2,
                                   v_req_date,   --p_islem_tarihi        date,
                                   p_req_dbs_type, --p_islem_tipi          number,
                                   NULL,       --p_ppv_kredi_limiti    number,
                                   NULL,       --p_msg_account_number  number,
                                   NULL,     --p_msg_serial_number   varchar2,
                                   NULL,   --p_mesaj_metni           varchar2,
                                   NULL, --p_channel_map_1       lg_mesaj_takip.channel_map_1%type,
                                   NULL, --p_channel_map_2       lg_mesaj_takip.channel_map_2%type,
                                   NULL, --p_channel_map_3       lg_mesaj_takip.channel_map_3%type,
                                   NULL, --p_channel_map_4       lg_mesaj_takip.channel_map_4%type,
                                   NULL,                                 --gca
                                   v_tra_id, --out                     lg_mesaj_takip.id%type,
                                   v_durum);

         IF v_durum <> '0'
         THEN
            p_errm := v_durum;
            RAISE log_exception;
         END IF;

         p_tra_id := v_tra_id;
      ELSE
         v_tra_id := p_tra_id;
      END IF;

      INSERT INTO dbs_addr_pisys_reqs (tra_id,
                                       req_id,
                                       serial_number,
                                       account_number,
                                       req_dbs_type,
                                       req_group_type,
                                       req_type,
                                       req_user,
                                       req_date,
                                       valid_after,
                                       req_param,
                                       is_ird)
           VALUES (v_tra_id,
                   v_req_id,
                   p_serial_number,
                   v_account_number,
                   p_req_dbs_type,
                   v_req_group_type,
                   v_req_type,
                   dbs_sabit ('FORCED_STATUS_ADDR_USER'),
                   v_req_date,
                   p_valid_after,
                   v_req_param,
                   'Y');

      RETURN 1;
   EXCEPTION
      WHEN input_exception OR log_exception
      THEN
         RETURN 0;
      WHEN OTHERS
      THEN
         p_errm := SQLERRM;
         RETURN 0;
   END force_status_report;
END;
/
