CREATE OR REPLACE PACKAGE BODY DBS_DBA.kontrat_pack
IS
   PROCEDURE insert_dpaccountno (
      uyeno                    IN     dp_account_no.account_no%TYPE,
      sozno                    IN     dp_account_no.contract_no%TYPE,
      outlet                   IN     dp_account_no.outlet_location%TYPE,
      yetkilisatkod            IN     dp_account_no.dealer_code%TYPE,
      soztarih                 IN     dp_account_no.contract_date%TYPE,
      kurulumtarih             IN     dp_account_no.teknik_form%TYPE,
      wizopid                  IN     dp_account_no.giris_user%TYPE,
      gelistip                 IN     dp_account_no.sozlesme_sekli%TYPE,
      mdubu                    IN     dp_account_no.kontrat_unitebilgi%TYPE,
      genelkampanya            IN     dp_account_no.kamp_kod%TYPE,
      ipotansiyel_is_emri_id   IN     yk_dp_kontrat.potansiyel_is_emri_id%TYPE,
      status                      OUT VARCHAR2,
      in_stb_tipi              IN     dp_account_no.stb_tipi%TYPE,
      in_yk_dp_kontrat_id      IN     dp_account_no.yk_dp_kontrat_id%TYPE,
      ilnb_tipi_stok_kodu      IN     VARCHAR2)
   IS
      v_uyeno               dp_account_no.account_no%TYPE;
      v_sozno               dp_account_no.contract_no%TYPE;
      v_outlet              dp_account_no.outlet_location%TYPE;
      v_yetkilisatkod       dp_account_no.dealer_code%TYPE;
      v_soztarih            dp_account_no.contract_date%TYPE;
      v_kurulumtarih        dp_account_no.teknik_form%TYPE;
      v_wizopid             dp_account_no.giris_user%TYPE;
      v_depo_id             dp_account_no.depo_id%TYPE;
      v_gelistip            dp_account_no.sozlesme_sekli%TYPE;
      v_mdubu               dp_account_no.kontrat_unitebilgi%TYPE;
      v_genelkampanya       dp_account_no.kamp_kod%TYPE;
      v_kampanya_kodu       dp_account_no.kamp_kod%TYPE;
      v_faturalanacak       dp_account_no.faturalanacak%TYPE;
      v_fatura_kaynak       dp_account_no.fatura_kaynak%TYPE;
      vlnb_tipi_stok_kodu   VARCHAR2 (10);
      v_count               NUMBER (5);
   BEGIN
      status := '0';
      v_uyeno := NVL (TRIM (uyeno), ' ');
      v_sozno := TRIM (sozno);
      v_outlet := NVL (TRIM (outlet), ' ');
      v_yetkilisatkod := NVL (TRIM (yetkilisatkod), ' ');
      v_soztarih := NVL (TRIM (soztarih), '01.01.0001');
      v_kurulumtarih := NVL (TRIM (kurulumtarih), '01.01.0001');
      v_wizopid := NVL (TRIM (wizopid), 16);
      v_gelistip := NVL (TRIM (gelistip), ' ');
      v_mdubu := NVL (TRIM (mdubu), ' ');
      v_genelkampanya := NVL (TRIM (genelkampanya), ' ');
      vlnb_tipi_stok_kodu := ilnb_tipi_stok_kodu;

      IF TRIM (v_uyeno) IS NULL
      THEN
         status := 'UYE NO BOS';
      END IF;

      IF TRIM (v_sozno) IS NULL
      THEN
         status := 'SÖZLESME NO BOS';
      END IF;

      IF TRIM (v_outlet) IS NULL
      THEN
         status := 'OUTLET BOS';
      END IF;

      IF TRIM (v_yetkilisatkod) IS NULL
      THEN
         status := 'YETKILI SATICI KODU BOS';
      END IF;

      IF TRIM (v_gelistip) IS NULL
      THEN
         status := 'GELIS TIPI BOS';
      END IF;

      IF TRIM (v_mdubu) IS NULL
      THEN
         status := 'MDU BU BILGISI BOS';
      END IF;

      IF TRIM (v_genelkampanya) IS NULL
      THEN
         status := 'GENEL KAMPANYA BILGISI BOS';
      END IF;

      IF TRIM (v_mdubu) = 'M'
      THEN
         v_mdubu := 'MDU';
      ELSIF TRIM (v_mdubu) = 'B'
      THEN
         v_mdubu := 'BU';
      END IF;

      IF is_numeric (v_gelistip) = 1
      THEN
         BEGIN
            SELECT aciklama
              INTO v_gelistip
              FROM pr_form_gelis_tipi
             WHERE kod = v_gelistip AND form_tipi = '1';
         EXCEPTION
            WHEN OTHERS
            THEN
               status := 'GELIS TIPI HATALI';
               RETURN;
         END;
      END IF;

      IF status <> '0'
      THEN
         RETURN;
      ELSE
         ------------------------------
         --D2D IÇIN BILGILERI BUL
         ------------------------------
         IF TRIM (ipotansiyel_is_emri_id) IS NOT NULL
         THEN
            BEGIN
               SELECT i.tahsilat_yapildi,
                      DECODE (i.islem_tipi,  11, 'D2D',  1, 'YRD') -- YRD yurt disi....
                 INTO v_faturalanacak, v_fatura_kaynak
                 FROM ie_potansiyel_is_emri i
                WHERE i.id = ipotansiyel_is_emri_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  status := 'POTANSIYEL TETIK KAYDI BULUNAMADI.';
                  RETURN;
            END;
         END IF;

         SELECT dp_account_no_seq.NEXTVAL INTO v_depo_id FROM DUAL;

         INSERT INTO dp_account_no (account_no,
                                    contract_no,
                                    outlet_location,
                                    amount,
                                    dealer_code,
                                    contract_date,
                                    giris_date,
                                    update_date,
                                    giris_user,
                                    update_user,
                                    giris_machine,
                                    update_machine,
                                    spare_date,
                                    spare_char,
                                    spare_num,
                                    teknik_form,
                                    kontrat_form,
                                    depo_id,
                                    process_status,
                                    real_amount,
                                    sozlesme_sekli,
                                    sozlesme_tutari,
                                    kontrat_unitebilgi,
                                    teknik_unitebilgi,
                                    f_kont_ub_fatura,
                                    ts_fat_date,
                                    unite_fat_tutar,
                                    f_tek_ub_fatura,
                                    fark,
                                    fark_aciklama,
                                    unite_fat_ipt_date,
                                    unite_fat_ipt_kod,
                                    f_unite_fat_fark_pros,
                                    egitim_paket,
                                    ep_fat_tutar,
                                    ep_fat_date,
                                    ep_fat_ipt_kod,
                                    ep_fat_ipt_date,
                                    ep_kont_date,
                                    ep_kont_no,
                                    ep_dealer_code,
                                    ep_giris_date,
                                    f_ep_fatura,
                                    aktivasyon_tutar,
                                    kamp_kod,
                                    akt_iade,
                                    yts,
                                    dmg_flag,
                                    sinif,
                                    faturalanacak,
                                    fatura_kaynak,
                                    stb_tipi,
                                    yk_dp_kontrat_id,
                                    lnb_tipi_stok_id)
              VALUES (v_uyeno,
                      v_sozno,
                      v_outlet,
                      '-1',
                      v_yetkilisatkod,
                      v_soztarih,
                      SYSDATE,
                      '',
                      v_wizopid,
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      v_kurulumtarih,
                      TO_DATE ('01.01.0001', 'dd.mm.yyyy'),
                      v_depo_id,
                      '1',
                      '',
                      v_gelistip,
                      '0',
                      v_mdubu,
                      v_mdubu,
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      v_genelkampanya,
                      '',
                      '',
                      '',
                      '',
                      v_faturalanacak,
                      v_fatura_kaynak,
                      in_stb_tipi,
                      in_yk_dp_kontrat_id,
                      vlnb_tipi_stok_kodu);

         --Takibi Yapilan Kontratin Outleti Doldurulur
         SELECT COUNT (1)
           INTO v_count
           FROM yk_dp_kontrat
          WHERE sozlesme_no = sozno AND TRIM (outlet_location) IS NULL;

         IF v_count > 0
         THEN
            UPDATE yk_dp_kontrat
               SET outlet_location = v_outlet
             WHERE sozlesme_no = sozno;
         END IF;
      END IF;

      BEGIN
         SELECT kampanya_kodu
           INTO v_kampanya_kodu
           FROM yk_dp_servis
          WHERE sozlesme_no = v_sozno AND servis_kodu IN ('UH1', 'UH2');

         IF status = '0'
         THEN
            UPDATE dp_account_no
               SET ep_dealer_code = v_yetkilisatkod,
                   kamp_kod = v_kampanya_kodu
             WHERE contract_no = v_sozno;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            status := '0';
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         status := SQLERRM;
   END;

   FUNCTION satis_kontrolu ( /*Description: Girilen sözlesme için satis yapilabilir mi kontrolü.
                               Remarks: 01.02.2007 tarhindeki yapian toplantida eklendi.
                                        Eger yurt içi ise hangi durum olursa olsun sözlesme girilebilir.
                                        yurt disi için ya tetik kayid olmali yada bayiden satis kampanyasi olmali.
                               Returns: 1 evet,0 hayir .. diger olusabilecek kosullar için number yapildi.
                           */
      isozlesme_no       IN     yk_dp_kontrat.sozlesme_no%TYPE,
      igiren_kullanici   IN     yk_dp_kontrat.giren_kullanici%TYPE,
      iprospect_number   IN     yk_dp_kontrat.prospect_number%TYPE,
      durum                 OUT VARCHAR2)
      RETURN NUMBER
   IS
      v_franchise_code        yk_dp_kontrat.franchise_code%TYPE;
      v_count                 NUMBER (1);
      v_bayiden_satis         NUMBER (1);
      v_yurt_disi_tetik       NUMBER (1);
      v_ittp_order_int_open   NUMBER;
   BEGIN
      durum := '0';
      v_ittp_order_int_open :=
         billing_dbs_int.exclude_control_pkg.is_integration_active (
            'ITTP_ORDER_INT');

      SELECT franchise_code
        INTO v_franchise_code
        FROM yk_dp_kontrat
       WHERE sozlesme_no = isozlesme_no;

      -- franchise yurt disimi kontrol et...
      IF potansiyel_is_emri_pack.ie_is_em_yurtdisi_franchiseimi (
            v_franchise_code,
            igiren_kullanici,
            durum) = 0
      THEN
         -- yurt içi...
         -- yurt disi tetik olmamali ..
         SELECT COUNT (1)
           INTO v_count
           FROM ie_potansiyel_is_emri
          WHERE sozlesme_no = isozlesme_no AND durum = 'C' AND islem_tipi = 1;

         IF v_count = 1
         THEN
            durum := 'YURT IÇI SÖZLESMEDE YURT DISI TETIK GIRILEMEZ.';
            RETURN 0;
         ELSE
            SELECT COUNT (1)
              INTO v_count
              FROM ie_potansiyel_is_emri
             WHERE     prospect_number = iprospect_number
                   AND islem_tipi = 1
                   AND durum IN ('O', 'C');

            IF v_count > 0
            THEN
               durum :=
                  'YURT IÇI SÖZLESMEDE YURT DISI TETIGI OLAN  POTANSIYEL SEÇILEMEZ.';
               RETURN 0;
            ELSE
               RETURN 1;
            END IF;
         END IF;
      ELSE
         -- yurt disi
         -- bayiden satis yada yurt disi tetik olmali


         -- bayiden satismi kontrol et...
         SELECT COUNT (1)
           INTO v_bayiden_satis
           FROM wiz_campaign_codes c, yk_dp_kontrat y
          WHERE     c.campaign_code = y.campaign_code
                AND y.sozlesme_no = isozlesme_no
                AND c.campaign_sales_channel IN (2, 4);


         -- yurtdisi tetik kaydi varmi kontrol et...
         SELECT COUNT (1)
           INTO v_yurt_disi_tetik
           FROM ie_potansiyel_is_emri
          WHERE sozlesme_no = isozlesme_no AND islem_tipi = 1 AND durum = 'C';

         -- tetik kaydi varsa bunun franchise inin yurt disi olup olmadigini kontrol etmeye gerek yok zaten yurt disi kaydi franchise i için yurt disi tetigi açilabilir.
         IF (v_yurt_disi_tetik + v_bayiden_satis) = 1
         THEN
            RETURN 1;                                              -- BASARILI
         ELSE
            IF v_yurt_disi_tetik = 1 AND v_bayiden_satis = 1
            THEN
               durum :=
                  'YURT DISI SÖZLESMELERI IÇIN, HEM BAYIDEN SATIS HEMDE YURT DISI TETIK KAYIDI AÇILAMAZ.';
               RETURN 0;
            END IF;

            IF v_yurt_disi_tetik = 0 AND v_bayiden_satis = 0
            THEN
               durum :=
                  'YURT DISI SÖZLESMELERI IÇIN, BAYIDEN SATIS YADA YURT DISI TETIK KAYIDI AÇILMALIDIR.';
               RETURN 0;
            END IF;
         END IF;
      END IF;

      durum := '0';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := SQLERRM;
         RETURN 0;
   END;

   FUNCTION random_number
      RETURN NUMBER
   IS
   BEGIN
      RETURN ROUND (DBMS_RANDOM.VALUE (100000, 999999));
   END;

   PROCEDURE send_quick_sms (
      itelefon_no   IN     VARCHAR2,
      itext         IN     VARCHAR2,
      odurum           OUT VARCHAR2,
      ititle        IN     VARCHAR2 DEFAULT 'DlGlTURK')
   IS
      soap_request      VARCHAR2 (30000);
      soap_respond      VARCHAR2 (30000);
      http_req          UTL_HTTP.req;
      http_resp         UTL_HTTP.resp;
      ws_response_xml   XMLTYPE;
      ws_result         VARCHAR2 (500);

      namespacestring   VARCHAR2 (100);
      v_tmp             VARCHAR2 (500);
      v_sonuc_kod       CHAR (1);
      v_telefon_no      VARCHAR2 (100);
   BEGIN
      IF SUBSTR (itelefon_no, 1, 2) = '90'
      THEN
         v_telefon_no := SUBSTR (itelefon_no, 3);
      ELSE
         v_telefon_no := itelefon_no;
      END IF;

      odurum := '0';
      namespacestring := 'xmlns="http://irisadmin.turk.net/';
      soap_request := '<?xml version="1.0" encoding="utf-8"?>';
      soap_request :=
            soap_request
         || '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
      soap_request := soap_request || '<soap12:Body>';
      soap_request :=
            soap_request
         || '<HizliSmsGonderGSM xmlns="http://irisadmin.turk.net">';
      soap_request := soap_request || '<KullaniciAdi>turk</KullaniciAdi>';
      soap_request := soap_request || '<Sifre>turk852</Sifre>';
      --soap_request := soap_request || '<Baslik>DIGI-SOHO</Baslik>'; --MKECECI digisoho artik kullanilmiyor
      --soap_request := soap_request || '<Baslik>DlGlTURK </Baslik>';  --MKECECI baslikta turk yazarken i yerine küçük L yazman gerekiyor.sms gönderimini yapan firma öyle taniyor.
      soap_request := soap_request || '<Baslik>' || ititle || ' </Baslik>'; --MKECECI mesaj basligi
      --soap_request := soap_request || '<GonderilecekSms>';
      soap_request :=
         soap_request || '<TelefonNo>' || v_telefon_no || '</TelefonNo>';

      --MKECECI  - Asagidaki alan yoruma alindi artik mesaj metni parametre olarak gönderilmeye baslandi
      /*soap_request :=
         soap_request
         || '<SmsMesaj>turk%20tek%20seferlik%20aktivasyon%20sifreniz%20:%20'
         || isifre
         || '</SmsMesaj>';*/
      --</end> - MKECECI

      --MKECECI - mesaj metni parametre olarak gönderiliyor.
      --msaj metnindeki bosluklar soap in anlayacagi sekilde %20 ile replace ediliyor
      soap_request :=
            soap_request
         || '<SmsMesaj>'
         || REPLACE (itext, ' ', '%20')
         || '</SmsMesaj>';
      --</end> MKECECI

      soap_request := soap_request || '<UygulamaAdi>DBS_ORACLE</UygulamaAdi>';
      --soap_request := soap_request || '</GonderilecekSms>';
      soap_request := soap_request || '</HizliSmsGonderGSM>';
      soap_request := soap_request || '</soap12:Body>';
      soap_request := soap_request || '</soap12:Envelope>';
      http_req :=
         UTL_HTTP.begin_request (
            'http://212.252.205.228/webrequest/HizliSmsWS/service.asmx',
            'POST',
            UTL_HTTP.http_version_1_1);
      UTL_HTTP.set_header (http_req,
                           'Content-Type',
                           'application/soap+xml; charset=utf-8');
      UTL_HTTP.set_header (http_req, 'Content-Length', LENGTH (soap_request));
      UTL_HTTP.write_text (http_req, soap_request);
      http_resp := UTL_HTTP.get_response (http_req);
      UTL_HTTP.read_text (http_resp, soap_respond);
      UTL_HTTP.end_response (http_resp);
      ws_response_xml := xmltype.createxml (soap_respond);
      DBMS_OUTPUT.put_line (ws_response_xml.getstringval ());
      --      WS_RESPONSE_XML:= xmltype.EXTRACT(WS_RESPONSE_XML,'/HizliSmsGonderResponse/HizliSmsGonderResult',NamespaceString);
      --     DBMS_OUTPUT.PUT_LINE('EEE3 '|| WS_RESPONSE_XML.getstringval());
      --      IF WS_RESPONSE_XML IS NOT NULL THEN
      --         WS_RESPONSE_XML := xmltype.EXTRACT(WS_RESPONSE_XML,'/HizliSmsGonderResult/SonucKod/text()',NamespaceString);
      --         v_sonuc_kod := WS_RESPONSE_XML.getstringval();
      --         DBMS_OUTPUT.PUT_LINE('v_sonuc_kod '|| v_sonuc_kod);
      --         WS_RESPONSE_XML := xmltype.EXTRACT(XMLType.createXML(SOAP_RESPOND),'//HizliSmsGonderResponse/HizliSmsGonderResult/SonucMesaj/text()',NamespaceString);
      --         DBMS_OUTPUT.PUT_LINE('WS_RESPONSE_XML.getstringval() '|| WS_RESPONSE_XML.getstringval());
      --      ELSE
      --        DBMS_OUTPUT.PUT_LINE('---1---');
      --      END IF;

      DBMS_OUTPUT.put_line (odurum);
   EXCEPTION
      WHEN UTL_HTTP.request_failed
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.bad_argument
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.bad_url
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.protocol_error
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.unknown_scheme
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.header_not_found
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.end_of_body
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.illegal_call
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.http_client_error
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.http_server_error
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.too_many_requests
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.partial_multibyte_char
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.transfer_timeout
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN UTL_HTTP.init_failed
      THEN
         odurum := 'SMS GÖNDERILEMEDI HATA OLUSTU';
         RETURN;
      WHEN OTHERS
      THEN
         odurum := 'Sms Gönderirken Hata Olustu : ' || SQLERRM;
   END;

   PROCEDURE send_activation_sms (
      ifranchise_code    IN     wiz_customer_hp_life.franchise_code%TYPE,
      icustomer_type     IN     wiz_customer_hp_life.customer_type%TYPE,
      itel_ulke_kodu     IN     VARCHAR2,
      itel_alan_kodu     IN     VARCHAR2,
      itelefon_no        IN     VARCHAR2,
      iteknisyen_kodu    IN     VARCHAR2,
      itip_kodu          IN     NUMBER,
      igiren_kullanici   IN     VARCHAR2,
      odurum                OUT VARCHAR2,
      ikontrat_kamp      IN     VARCHAR2 DEFAULT NULL)
   IS
      v_franchise_code        wiz_customer_hp_life.franchise_code%TYPE;
      v_customer_type         wiz_customer_hp_life.customer_type%TYPE;
      --out_istek_id          NUMBER (10);
      v_sonuc_tip             NUMBER (1);
      --v_mesaj               VARCHAR2 (255)

      --:= 'turk tek kullanimlik aktivasyon sifreniz : <<SIFRE>> dir.';
      v_count                 NUMBER (10);
      --v_uygulama_islem_id   NUMBER := 154;
      v_sifre                 NUMBER;
      v_sms_gec_suresi        NUMBER;
      v_sms_tekrar_suresi     NUMBER;
      v_tel_aktivasyon_mktr   NUMBER;
      v_telefon_no            VARCHAR2 (50);
      out_err_code            VARCHAR2 (50);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      odurum := '0';
      v_telefon_no :=
         TRIM (itel_ulke_kodu) || TRIM (itel_alan_kodu) || TRIM (itelefon_no);

      IF TRIM (iteknisyen_kodu) IS NULL
      THEN
         odurum := 'Teknisyen Kodu bilgisi bos olamaz !...';
         ROLLBACK;
         RETURN;
      END IF;

      IF itip_kodu = 2 AND ikontrat_kamp IS NULL
      THEN
         odurum := 'Kontrat Kampanyasi alanini doldurunuz !...';
         ROLLBACK;
         RETURN;
      END IF;

      IF itip_kodu = 2
      THEN
         SELECT franchise_code, uye_tipi
           INTO v_franchise_code, v_customer_type
           FROM yk_dp_kmp_akt_gereksinim
          WHERE kontrat_kmp_kodu = ikontrat_kamp;
      ELSE
         v_franchise_code := ifranchise_code;
         v_customer_type := icustomer_type;
      END IF;

      IF v_franchise_code IS NULL OR v_customer_type IS NULL
      THEN
         odurum := 'Franchise ve Üye Tipi Bilgileri bos olamaz !...';
         ROLLBACK;
         RETURN;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM bt_bayi_ozellik
       WHERE sales_agent_code = iteknisyen_kodu AND bayi_ozellik_kodu = 249; -- sms gönderecek bayi özelligi

      IF    v_customer_type NOT IN ('NOR',
                                    'NOK',
                                    'TIC',
                                    'TIK',
                                    'YTI')
         OR v_franchise_code NOT IN ('F01', 'F02', 'F04')
         OR v_count = 0
      THEN
         odurum :=
            'Bu üye için sms gönderilmez, Lütfen sifre kismini bos birakiniz !...';
         ROLLBACK;
         RETURN;
      END IF;

      IF yetki_pack.yetkisi_varmi (igiren_kullanici,
                                   'AKTIVASYON_MUKERRER_CEPTEL_GIRIS') = 0 -- Bir cep tel numarasını ikiden fazla girme yetkisi yoksa..
      THEN
         SELECT COUNT (1)
           INTO v_tel_aktivasyon_mktr       -- Önceki aktivasyon miktarını bul
           FROM (SELECT DISTINCT asms.tel_no, dpk.uye_no
                   FROM yk_activation_sms asms, yk_dp_kontrat dpk
                  WHERE     asms.tel_no = v_telefon_no
                        AND asms.giris_tarihi > ADD_MONTHS (SYSDATE, -2)
                        AND asms.sozlesme_no = dpk.sozlesme_no
                        AND dpk.status IN (30, 80)
                        AND dpk.uye_no IS NOT NULL);

         IF v_tel_aktivasyon_mktr > 2
         THEN             --Daha önce ikiden fazla kez aktivasyon yapılmış mı?
            odurum :=
               'Bu telefon numarasi ile son iki ay içinde 2 (iki)''den fazla kez üye aktivasyonu yapilmis. Lütfen baska bir numara giriniz !...';
            ROLLBACK;                                           -- Gerekli mi?
            RETURN;
         END IF;
      END IF;

      IF dbs_sabit ('AKTIVASYON_SMS_GONDER') <> 'E'
      THEN
         odurum :=
            'Sms gönderimi ve Aktivasyon kontrolü suan için kapalidir, Lütfen sifre alanini bos birakiniz !...';
         ROLLBACK;
         RETURN;
      END IF;

      IF    TRIM (itel_alan_kodu) IS NULL
         OR TRIM (itelefon_no) IS NULL
         OR TRIM (itel_ulke_kodu) IS NULL
      THEN
         odurum :=
            'Lütfen Telefon Ülke Kodu, Alan Kodu ve Telefon No yu giriniz !...';
         ROLLBACK;
         RETURN;
      END IF;

      abone_telefon_pack.mb_abone_telefon_ins_upd_ctrl (NULL,
                                                        0, --in_account_number
                                                        itel_ulke_kodu, --in_ulke_kodu
                                                        itel_alan_kodu, --in_alan_kodu
                                                        itelefon_no, --in_telefon_no
                                                        NULL, --in_dahili_tel_no
                                                        3,   --in_telefon_tipi
                                                        1,          --in_durum
                                                        NULL, --in_arama_zamani
                                                        NULL, --      in_arama_saat_baslangic
                                                        NULL, --      in_arama_saat_bitis
                                                        NULL, --      in_arama_tarih_baslangic
                                                        NULL, --      in_arama_tarih_bitis
                                                        NULL, --      in_oncelik_sirasi
                                                        NULL, --      in_son_kontrol_tarihi
                                                        NULL, --      in_kontrol_yapan_kullanici
                                                        NULL, --      in_aciklama
                                                        igiren_kullanici,
                                                        odurum,
                                                        out_err_code);

      IF odurum <> '0'
      THEN
         ROLLBACK;
         RETURN;
      END IF;

      v_sifre := random_number;
      v_sms_gec_suresi := dbs_sabit ('AKTIVASYON_SMS_GECERLILIK_SURESI'); -- saat bazinda
      v_sms_tekrar_suresi :=
         dbs_sabit ('AKTIVASYON_SMS_TEKRAR_GONDERIM_BEKLEME_SURESI'); -- saniye bazinda

      SELECT COUNT (*)
        INTO v_count
        FROM yk_activation_sms
       WHERE     tel_no = v_telefon_no
             AND giris_tarihi > SYSDATE - (v_sms_tekrar_suresi / 86400);

      IF v_count > 0
      THEN
         odurum :=
               v_sms_tekrar_suresi
            || ' sn içinde tekrar sms gönderemezsiniz !...';
         ROLLBACK;
         RETURN;
      END IF;

      INSERT INTO yk_activation_sms (id,
                                     tel_no,
                                     sifre,
                                     expire_date,
                                     sozlesme_no,
                                     giren_kullanici,
                                     giris_tarihi,
                                     degistiren_kullanici,
                                     degistirme_tarihi)
           VALUES (yk_activation_sms_id_seq.NEXTVAL,
                   v_telefon_no,
                   v_sifre,
                   SYSDATE + v_sms_gec_suresi / 24,
                   NULL,
                   igiren_kullanici,
                   SYSDATE,
                   igiren_kullanici,
                   SYSDATE);

      --      sms_gonderim_istek_pack.istek_yarat (
      --         v_uygulama_islem_id,
      --         NULL,                                           ---out_istek_grup_id,
      --         'invisible',
      --         'dbsExtra43',
      --         TRIM (itel_alan_kodu) || TRIM (itelefon_no),
      --         v_mesaj,
      --         SYSDATE,
      --         out_istek_id,
      --         v_sonuc_tip,
      --         odurum,
      --         itel_ulke_kodu);

      /*MKECECI - send_quick_sms procedure nun eski hali
      send_quick_sms (TRIM (itel_alan_kodu) || TRIM (itelefon_no),
                      v_sifre,
                      odurum);*/
      --yeni hali
      send_quick_sms (
         itelefon_no   =>    TRIM (itel_ulke_kodu)
                          || TRIM (itel_alan_kodu)
                          || TRIM (itelefon_no),
         itext         =>    'turk tek seferlik aktivasyon sifreniz : '
                          || v_sifre,
         odurum        => odurum);

      --</end>MKECECI
      IF odurum <> '0'
      THEN
         --odurum := 'SMS gönderim istegi olusturulurken hata olustu !...';
         ROLLBACK;
         RETURN;
      ELSE
         --odurum := '0';
         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         odurum := 'AKTIVASYON_SMS_HATA: ' || SUBSTR (SQLERRM, 1, 200);
         ROLLBACK;
         RETURN;
   END;

   PROCEDURE activation_sms_kontrol (
      ifranchise_code    IN     wiz_customer_hp_life.franchise_code%TYPE,
      icustomer_type     IN     wiz_customer_hp_life.customer_type%TYPE,
      itelefon_no        IN     VARCHAR2,
      isifre_text        IN     VARCHAR2,
      isozlesme_no       IN     VARCHAR2,
      iteknisyen_kodu    IN     VARCHAR2,
      igiren_kullanici   IN     VARCHAR2,
      odurum                OUT VARCHAR2)
   IS
      v_count               NUMBER;
      v_bos_sifre_hata      BOOLEAN := FALSE;
      v_doldur_sifre_hata   BOOLEAN := FALSE;
      v_gecerli_ts          BOOLEAN := TRUE;
      v_gecerli_fr_ct       BOOLEAN := TRUE;
   BEGIN
      odurum := '0';

      --MKECECI aktivasyon SMS si F04 - NOT,NOK,TIC,TIK üyeler içinde gönderilsin istendi (F04,NOK,TIK eklendi)
      IF NOT (    ifranchise_code IN ('F01', 'F02', 'F04')
              AND icustomer_type IN ('NOR',
                                     'NOK',
                                     'TIC',
                                     'TIK',
                                     'YTI'))
      THEN
         v_gecerli_fr_ct := FALSE;
      END IF;

      IF     yetki_pack.yetkisi_varmi (igiren_kullanici,
                                       'AKTIVASYON_SMS_ZORUNLULUK_KALDIR') =
                0
         AND dbs_sabit ('AKTIVASYON_SMS_GONDER') = 'E'
      THEN
         v_doldur_sifre_hata := TRUE;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM bt_bayi_ozellik
       WHERE sales_agent_code = iteknisyen_kodu AND bayi_ozellik_kodu = 249; -- sms gönderecek bayi özelligi

      IF v_count = 0
      THEN
         v_gecerli_ts := FALSE;
      END IF;

      IF isifre_text IS NOT NULL
      THEN
         IF v_gecerli_fr_ct
         THEN
            IF v_gecerli_ts
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM yk_activation_sms s
                WHERE     s.tel_no = itelefon_no
                      AND s.sozlesme_no IS NULL
                      AND s.sifre = isifre_text
                      AND s.expire_date > SYSDATE;

               IF v_count = 0
               THEN
                  odurum := 'AKTIVASYON SMS SIFRENIZ YANLIS !...';
                  RETURN;
               END IF;
            ELSE
               v_bos_sifre_hata := TRUE;
            END IF;
         ELSE
            v_bos_sifre_hata := TRUE;
         END IF;
      ELSE
         IF v_doldur_sifre_hata AND v_gecerli_fr_ct AND v_gecerli_ts
         THEN
            odurum := 'AKTIVASYON SIFRESINI DOLDURUNUZ !...';
            RETURN;
         END IF;
      END IF;

      IF v_bos_sifre_hata
      THEN
         odurum := 'AKTIVASYON SIFRESI BOS GIRILMELIDIR !...';
         RETURN;
      END IF;
   END;

   PROCEDURE sms_ok (
      isozlesme_tipi                IN     yk_dp_kontrat.sozlesme_tipi%TYPE,
      iis_yeri_yetkilisi_1          IN     yk_dp_kontrat.is_yeri_yetkilisi_1%TYPE,
      iis_yeri_yetkilisi_2          IN     yk_dp_kontrat.is_yeri_yetkilisi_2%TYPE,
      idigikutu_bagli_tel           IN     yk_dp_kontrat.digikutu_bagli_tel%TYPE,
      idwelling_type                IN     yk_dp_kontrat.dwelling_type%TYPE,
      ibilling_frequency            IN     yk_dp_kontrat.billing_frequency%TYPE,
      iruhsat_yeri_id               IN     yk_dp_kontrat.ruhsat_yeri_id%TYPE,
      iruhsat_tarihi                IN     yk_dp_kontrat.ruhsat_tarihi%TYPE,
      iruhsat_verilme_ili           IN     yk_dp_kontrat.ruhsat_verilme_ili%TYPE,
      iruhsat_sicil_no              IN     yk_dp_kontrat.ruhsat_sicil_no%TYPE,
      iruhsat_belediye              IN     VARCHAR2,
      ifaaliyet_konusu              IN     yk_dp_kontrat.faaliyet_konusu%TYPE,
      ifatura_apt_adi               IN     yk_dp_kontrat.fatura_apt_adi%TYPE,
      ifatura_blok                  IN     yk_dp_kontrat.fatura_blok%TYPE,
      ifatura_apt_no                IN     yk_dp_kontrat.fatura_apt_no%TYPE,
      ifatura_semt                  IN     yk_dp_kontrat.fatura_semt%TYPE,
      ifatura_ilce                  IN     yk_dp_kontrat.fatura_ilce%TYPE,
      ifatura_il                    IN     yk_dp_kontrat.fatura_il%TYPE,
      ifatura_eyalet                IN     yk_dp_kontrat.fatura_eyalet%TYPE,
      ifatura_ulke                  IN     yk_dp_kontrat.fatura_ulke%TYPE,
      ifatura_daire_no              IN     yk_dp_kontrat.fatura_daire_no%TYPE,
      ifatura_posta_kodu            IN     yk_dp_kontrat.fatura_posta_kodu%TYPE,
      imdu_ceki                     IN     yk_dp_kontrat.mdu_ceki%TYPE,
      imdu_bu_ceki                  IN     yk_dp_kontrat.mdu_bu_ceki%TYPE,
      iteknisyen_kodu               IN     yk_dp_kontrat.teknisyen_kodu%TYPE,
      idaire_sayisi                 IN     yk_dp_kontrat.daire_sayisi%TYPE,
      ikat_sayisi                   IN     yk_dp_kontrat.kat_sayisi%TYPE,
      istb_seri_no                  IN     yk_dp_kontrat.stb_seri_no%TYPE,
      isc_seri_no                   IN     yk_dp_kontrat.sc_seri_no%TYPE,
      itelefon_ceki                 IN     yk_dp_kontrat.telefon_ceki%TYPE,
      ikk_tipi                      IN     yk_dp_kontrat.kk_tipi%TYPE,
      ikk_no                        IN     yk_dp_kontrat.kk_no%TYPE,
      ikk_son_tarihi                IN     yk_dp_kontrat.kk_son_tarihi%TYPE,
      ibayi_kodu                    IN     yk_dp_kontrat.bayi_kodu%TYPE,
      ikon_gel_tipi                 IN     yk_dp_kontrat.kon_gel_tipi%TYPE,
      ibuilding_id                  IN     yk_dp_kontrat.building_id%TYPE,
      iservice_address_id           IN     yk_dp_kontrat.service_address_id%TYPE,
      iservis_tarihi                IN     yk_dp_kontrat.servis_tarihi%TYPE,
      irevizyon                     IN     yk_dp_kontrat.revizyon%TYPE,
      ibatch                        IN     yk_dp_kontrat.batch%TYPE,
      iits_kayit_no                 IN     yk_dp_kontrat.its_kayit_no%TYPE,
      istatus                       IN     yk_dp_kontrat.status%TYPE,
      igiren_kullanici              IN     yk_dp_kontrat.giren_kullanici%TYPE,
      iuye_tipi                     IN     yk_dp_kontrat.uye_tipi%TYPE,
      ikimlik_cinsi                 IN     yk_dp_kontrat.kimlik_cinsi%TYPE,
      ibina_tipi                    IN     yk_dp_kontrat.bina_tipi%TYPE,
      ihub_code                     IN     yk_dp_kontrat.hub_code%TYPE,
      iprospect_number              IN     yk_dp_kontrat.prospect_number%TYPE,
      ifranchise_code               IN     yk_dp_kontrat.franchise_code%TYPE,
      ituttugu_takim_kodu           IN     yk_dp_kontrat.tuttugu_takim_kodu%TYPE,
      icampaign_code                IN     yk_dp_kontrat.campaign_code%TYPE,
      ivip                          IN     yk_dp_kontrat.vip%TYPE,
      isozlesme_no                  IN     yk_dp_kontrat.sozlesme_no%TYPE,
      isozlesme_tarihi              IN     yk_dp_kontrat.sozlesme_tarihi%TYPE,
      iyeni_mdu_no                  IN     yk_dp_kontrat.yeni_mdu_no%TYPE,
      ieski_mdu_no                  IN     yk_dp_kontrat.eski_mdu_no%TYPE,
      iis_emri_no                   IN     yk_dp_kontrat.is_emri_no%TYPE,
      iuye_no                       IN     yk_dp_kontrat.uye_no%TYPE,
      ieski_yeni_ceki               IN     yk_dp_kontrat.eski_yeni_ceki%TYPE,
      iad                           IN     yk_dp_kontrat.ad%TYPE,
      isoyad                        IN     yk_dp_kontrat.soyad%TYPE,
      ianne_kizlik_soyad            IN     yk_dp_kontrat.anne_kizlik_soyad%TYPE,
      idogum_yeri                   IN     yk_dp_kontrat.dogum_yeri%TYPE,
      idogum_tarihi                 IN     yk_dp_kontrat.dogum_tarihi%TYPE,
      icinsiyet                     IN     yk_dp_kontrat.cinsiyet%TYPE,
      imeslek                       IN     yk_dp_kontrat.meslek%TYPE,
      imeslek_id                    IN     yk_dp_kontrat.meslek_id%TYPE,
      ikimlik_yeri                  IN     yk_dp_kontrat.kimlik_yeri%TYPE,
      ikimlik_seri_no               IN     yk_dp_kontrat.kimlik_seri_no%TYPE,
      ikimlik_kayit_no              IN     yk_dp_kontrat.kimlik_kayit_no%TYPE,
      ikimlik_tarihi                IN     yk_dp_kontrat.kimlik_tarihi%TYPE,
      itabiyet                      IN     yk_dp_kontrat.tabiyet%TYPE,
      ivergi_dairesi                IN     yk_dp_kontrat.vergi_dairesi%TYPE,
      ivergi_no                     IN     yk_dp_kontrat.vergi_no%TYPE,
      iev_tel_ulke_alan             IN     yk_dp_kontrat.home_country_tel_code%TYPE,
      iev_tel_alan                  IN     yk_dp_kontrat.ev_tel_alan%TYPE,
      iev_tel_prefix                IN     yk_dp_kontrat.ev_tel_prefix%TYPE,
      iev_tel_no                    IN     yk_dp_kontrat.ev_tel_no%TYPE,
      iis_tel_ulke_alan             IN     yk_dp_kontrat.work_country_tel_code%TYPE,
      iis_tel_alan                  IN     yk_dp_kontrat.is_tel_alan%TYPE,
      iis_tel_prefix                IN     yk_dp_kontrat.is_tel_prefix%TYPE,
      iis_tel_no                    IN     yk_dp_kontrat.is_tel_no%TYPE,
      iis_tel_dahili                IN     yk_dp_kontrat.is_tel_dahili%TYPE,
      icep_tel_ulke_alan            IN     yk_dp_kontrat.mobile_country_tel_code%TYPE,
      icep_tel_alan                 IN     yk_dp_kontrat.cep_tel_alan%TYPE,
      icep_tel_prefix               IN     yk_dp_kontrat.cep_tel_prefix%TYPE,
      icep_tel_no                   IN     yk_dp_kontrat.cep_tel_no%TYPE,
      ifax_tel_ulke_alan            IN     yk_dp_kontrat.fax_country_tel_code%TYPE,
      ifax_tel_alan                 IN     yk_dp_kontrat.fax_tel_alan%TYPE,
      ifax_tel_prefix               IN     yk_dp_kontrat.fax_tel_prefix%TYPE,
      ifax_tel_no                   IN     yk_dp_kontrat.fax_tel_no%TYPE,
      iemail                        IN     yk_dp_kontrat.email%TYPE,
      ifatura_sirket_adi            IN     yk_dp_kontrat.fatura_sirket_adi%TYPE,
      ifatura_mahalle               IN     yk_dp_kontrat.fatura_mahalle%TYPE,
      ifatura_cadde                 IN     yk_dp_kontrat.fatura_cadde%TYPE,
      ifatura_sokak                 IN     yk_dp_kontrat.fatura_sokak%TYPE,
      ifatura_site_adi              IN     yk_dp_kontrat.fatura_site_adi%TYPE,
      idigikart_var_mi              IN     yk_dp_kontrat.digikart_varmi%TYPE,
      imdu_sistem_no                IN     yk_dp_kontrat.mdu_sistem_no%TYPE,
      imdu_yontem_no                IN     yk_dp_kontrat.mdu_yontem_no%TYPE,
      ibilling_cycle                IN     yk_dp_kontrat.billing_cycle%TYPE,
      iguvenlik_kodu                IN     yk_dp_kontrat.guvenlik_kodu%TYPE,
      ioutlet_location              IN     yk_dp_kontrat.outlet_location%TYPE,
      ipotansiyel_is_emri_id        IN     yk_dp_kontrat.potansiyel_is_emri_id%TYPE,
      in_ts_sifre_id                IN     lg_ekipman.lg_teknik_servis_sifre_id%TYPE,
      in_anne_adi                   IN     yk_dp_kontrat.anne_adi%TYPE,
      in_baba_adi                   IN     yk_dp_kontrat.baba_adi%TYPE,
      in_nufusa_kayitli_ilcesi      IN     yk_dp_kontrat.nufusa_kayitli_ilcesi%TYPE,
      in_nufusa_kayitli_ili         IN     yk_dp_kontrat.nufusa_kayitli_ili%TYPE,
      in_abone_ozellik_kodu         IN     yk_dp_kontrat.abone_ozellik_kodu%TYPE,
      in_uydu_tipi                  IN     yk_dp_kontrat.uydu_tipi%TYPE,
      in_modul_tipi                 IN     yk_dp_kontrat.modul_tipi%TYPE,
      in_ekipman_kutu_tipi          IN     yk_dp_kontrat.ekipman_kutu_tipi%TYPE,
      in_modul_seri_no              IN     yk_dp_kontrat.modul_seri_no%TYPE,
      ouye_no                          OUT yk_dp_kontrat.uye_no%TYPE,
      durum                            OUT VARCHAR2,
      in_stb_tipi                   IN     yk_dp_kontrat.stb_tipi%TYPE,
      ivatandaslikno                IN     yk_dp_kontrat.tc_kimlik_no%TYPE,
      iciltno                       IN     yk_dp_kontrat.cilt_no%TYPE,
      iailesirano                   IN     yk_dp_kontrat.aile_sira_no%TYPE,
      isirano                       IN     yk_dp_kontrat.sira_no%TYPE,
      ivatno_required               IN     VARCHAR2,
      icheck_payment_order_status   IN     NUMBER,
      v_uydu_tipi                   IN     VARCHAR2,
      v_yk_dp_kontrat_id            IN     NUMBER,
      isifre_text                   IN     yk_dp_kontrat.sifre_text%TYPE,
      iharddisk_seri_no             IN     yk_dp_kontrat.harddisk_seri_no%TYPE, --MKECECI- 10.10.2012
      imodem_seri_no                IN     yk_dp_kontrat.modem_seri_no%TYPE, --MKECECI
      irf_mdu_tipi                  IN     mb_abone_detay_bilgi.rf_mdu_tipi%TYPE --MKECECI
                                                                                )
   IS
      v_sozlesme_tipi                yk_dp_kontrat.sozlesme_tipi%TYPE;
      v_is_yeri_yetkilisi_1          yk_dp_kontrat.is_yeri_yetkilisi_1%TYPE;
      v_is_yeri_yetkilisi_2          yk_dp_kontrat.is_yeri_yetkilisi_2%TYPE;
      v_digikutu_bagli_tel           yk_dp_kontrat.digikutu_bagli_tel%TYPE;
      v_dwelling_type                yk_dp_kontrat.dwelling_type%TYPE;
      v_billing_frequency            yk_dp_kontrat.billing_frequency%TYPE;
      v_ruhsat_yeri_id               yk_dp_kontrat.ruhsat_yeri_id%TYPE;
      v_ruhsat_tarihi                yk_dp_kontrat.ruhsat_tarihi%TYPE;
      v_ruhsat_verilme_ili           yk_dp_kontrat.ruhsat_verilme_ili%TYPE;
      v_ruhsat_verilme_ili_ad        mb_abone_detay_bilgi.ruhsat_verilme_ili%TYPE;
      v_ruhsat_sicil_no              yk_dp_kontrat.ruhsat_sicil_no%TYPE;
      v_ruhsat_belediye              VARCHAR2 (50);
      v_faaliyet_konusu              yk_dp_kontrat.faaliyet_konusu%TYPE;
      v_fatura_apt_adi               yk_dp_kontrat.fatura_apt_adi%TYPE;
      v_fatura_blok                  yk_dp_kontrat.fatura_blok%TYPE;
      v_fatura_apt_no                yk_dp_kontrat.fatura_apt_no%TYPE;
      v_fatura_semt                  yk_dp_kontrat.fatura_semt%TYPE;
      v_fatura_ilce                  yk_dp_kontrat.fatura_ilce%TYPE;
      v_fatura_il                    yk_dp_kontrat.fatura_il%TYPE;
      v_fatura_daire_no              yk_dp_kontrat.fatura_daire_no%TYPE;
      v_fatura_posta_kodu            yk_dp_kontrat.fatura_posta_kodu%TYPE;
      v_mdu_ceki                     yk_dp_kontrat.mdu_ceki%TYPE;
      v_mdu_bu_ceki                  yk_dp_kontrat.mdu_bu_ceki%TYPE;
      v_teknisyen_kodu               yk_dp_kontrat.teknisyen_kodu%TYPE;
      v_daire_sayisi                 yk_dp_kontrat.daire_sayisi%TYPE;
      v_kat_sayisi                   yk_dp_kontrat.kat_sayisi%TYPE;
      v_stb_seri_no                  yk_dp_kontrat.stb_seri_no%TYPE;
      v_sc_seri_no                   yk_dp_kontrat.sc_seri_no%TYPE;
      v_telefon_ceki                 yk_dp_kontrat.telefon_ceki%TYPE;
      v_kk_tipi                      yk_dp_kontrat.kk_tipi%TYPE;
      v_kk_no                        yk_dp_kontrat.kk_no%TYPE;
      v_kk_son_tarihi                yk_dp_kontrat.kk_son_tarihi%TYPE;
      v_kon_gel_tipi                 yk_dp_kontrat.kon_gel_tipi%TYPE;
      v_building_id                  yk_dp_kontrat.building_id%TYPE;
      v_servis_tarihi                yk_dp_kontrat.servis_tarihi%TYPE;
      v_revizyon                     yk_dp_kontrat.revizyon%TYPE;
      v_batch                        yk_dp_kontrat.batch%TYPE;
      v_its_kayit_no                 yk_dp_kontrat.its_kayit_no%TYPE;
      v_status                       yk_dp_kontrat.status%TYPE;
      v_giren_kullanici              yk_dp_kontrat.giren_kullanici%TYPE;
      v_uye_tipi                     yk_dp_kontrat.uye_tipi%TYPE;
      v_kimlik_cinsi                 yk_dp_kontrat.kimlik_cinsi%TYPE;
      v_bina_tipi                    yk_dp_kontrat.bina_tipi%TYPE;
      v_hub_code                     yk_dp_kontrat.hub_code%TYPE;
      v_prospect_number              yk_dp_kontrat.prospect_number%TYPE;
      v_franchise_code               yk_dp_kontrat.franchise_code%TYPE;
      v_tuttugu_takim_kodu           yk_dp_kontrat.tuttugu_takim_kodu%TYPE;
      v_campaign_code                yk_dp_kontrat.campaign_code%TYPE;
      v_vip                          yk_dp_kontrat.vip%TYPE;
      v_sozlesme_no                  yk_dp_kontrat.sozlesme_no%TYPE;
      v_sozlesme_tarihi              yk_dp_kontrat.sozlesme_tarihi%TYPE;
      v_yeni_mdu_no                  yk_dp_kontrat.yeni_mdu_no%TYPE;
      v_eski_mdu_no                  yk_dp_kontrat.eski_mdu_no%TYPE;
      v_eski_yeni_ceki               yk_dp_kontrat.eski_yeni_ceki%TYPE;
      v_ad                           yk_dp_kontrat.ad%TYPE;
      v_soyad                        yk_dp_kontrat.soyad%TYPE;
      v_anne_kizlik_soyad            yk_dp_kontrat.anne_kizlik_soyad%TYPE;
      v_dogum_yeri                   yk_dp_kontrat.dogum_yeri%TYPE;
      v_dogum_tarihi                 yk_dp_kontrat.dogum_tarihi%TYPE;
      v_cinsiyet                     yk_dp_kontrat.cinsiyet%TYPE;
      v_meslek                       yk_dp_kontrat.meslek%TYPE;
      v_meslek_id                    yk_dp_kontrat.meslek_id%TYPE;
      v_kimlik_yeri                  yk_dp_kontrat.kimlik_yeri%TYPE;
      v_kimlik_seri_no               yk_dp_kontrat.kimlik_seri_no%TYPE;
      v_kimlik_kayit_no              yk_dp_kontrat.kimlik_kayit_no%TYPE;
      v_kimlik_tarihi                yk_dp_kontrat.kimlik_tarihi%TYPE;
      v_tabiyet                      yk_dp_kontrat.tabiyet%TYPE;
      v_vergi_dairesi                yk_dp_kontrat.vergi_dairesi%TYPE;
      v_vergi_no                     yk_dp_kontrat.vergi_no%TYPE;
      v_ev_tel_ulke_alan             yk_dp_kontrat.home_country_tel_code%TYPE;
      v_ev_tel_alan                  yk_dp_kontrat.ev_tel_alan%TYPE;
      v_ev_tel_prefix                yk_dp_kontrat.ev_tel_prefix%TYPE;
      v_ev_tel_no                    yk_dp_kontrat.ev_tel_no%TYPE;
      v_is_tel_ulke_alan             yk_dp_kontrat.work_country_tel_code%TYPE;
      v_is_tel_alan                  yk_dp_kontrat.is_tel_alan%TYPE;
      v_is_tel_prefix                yk_dp_kontrat.is_tel_prefix%TYPE;
      v_is_tel_no                    yk_dp_kontrat.is_tel_no%TYPE;
      v_is_tel_dahili                yk_dp_kontrat.is_tel_dahili%TYPE;
      v_cep_tel_ulke_alan            yk_dp_kontrat.mobile_country_tel_code%TYPE;
      v_cep_tel_alan                 yk_dp_kontrat.cep_tel_alan%TYPE;
      v_cep_tel_prefix               yk_dp_kontrat.cep_tel_prefix%TYPE;
      v_cep_tel_no                   yk_dp_kontrat.cep_tel_no%TYPE;
      v_fax_tel_ulke_alan            yk_dp_kontrat.fax_country_tel_code%TYPE;
      v_fax_tel_alan                 yk_dp_kontrat.fax_tel_alan%TYPE;
      v_fax_tel_prefix               yk_dp_kontrat.fax_tel_prefix%TYPE;
      v_fax_tel_no                   yk_dp_kontrat.fax_tel_no%TYPE;
      v_email                        yk_dp_kontrat.email%TYPE;
      v_fatura_sirket_adi            yk_dp_kontrat.fatura_sirket_adi%TYPE;
      v_fatura_mahalle               yk_dp_kontrat.fatura_mahalle%TYPE;
      v_fatura_cadde                 yk_dp_kontrat.fatura_cadde%TYPE;
      v_fatura_sokak                 yk_dp_kontrat.fatura_sokak%TYPE;
      v_fatura_site_adi              yk_dp_kontrat.fatura_site_adi%TYPE;
      v_digikart_var_mi              yk_dp_kontrat.digikart_varmi%TYPE;
      v_mdu_sistem_no                yk_dp_kontrat.mdu_sistem_no%TYPE;
      v_mdu_yontem_no                yk_dp_kontrat.mdu_yontem_no%TYPE;
      v_billing_cycle                yk_dp_kontrat.billing_cycle%TYPE;
      v_guvenlik_kodu                yk_dp_kontrat.guvenlik_kodu%TYPE;
      v_paramyko                     VARCHAR2 (3);
      v_mesaj                        VARCHAR2 (255);
      v_customer_status              wiz_customer_hp_life.customer_status%TYPE;
      v_trx_date                     DATE;
      v_ekipmanlokasyonsc            wiz_equip.equip_location_code%TYPE;

      v_ekipmanlokasyonstb           wiz_equip.equip_location_code%TYPE;
      v_ekipmanlokasyonhdd           eq_ekipman.equip_location_code%TYPE; --MKECECI
      v_ekipmanlokasyonmd            eq_ekipman.equip_location_code%TYPE; -- MKECECI
      v_ekipmanlokasyonmodem         eq_ekipman.equip_location_code%TYPE; --MKECECI
      v_mahalle                      VARCHAR2 (50);
      v_cadde                        VARCHAR2 (50);
      v_sokak                        VARCHAR2 (50);
      v_site                         VARCHAR2 (50);
      v_apt                          VARCHAR2 (50);
      v_blok                         VARCHAR2 (50);
      v_aptno                        VARCHAR2 (50);
      v_daire                        VARCHAR2 (50);
      v_semt                         VARCHAR2 (50);
      v_posta                        VARCHAR2 (10);
      v_il                           VARCHAR2 (40);
      v_ilce                         VARCHAR2 (50);
      v_full_name                    wiz_customer_bill_to.full_name%TYPE;
      v_adr_1                        wiz_customer_bill_to.addr_line_1%TYPE;
      v_adr_2                        wiz_customer_bill_to.addr_line_2%TYPE;
      v_adr_3                        wiz_customer_bill_to.addr_line_3%TYPE;
      v_fatura_ayni_kalsin_flag      VARCHAR2 (3);
      v_wiz_operator_id              co_kullanici.wiz_operator_id%TYPE;
      v_count                        NUMBER (10) := 0;
      v_sonuc                        VARCHAR2 (255);
      v_fatura_name                  VARCHAR2 (65);
      v_kayit_aktarilma_tarihi       yk_dp_kontrat.kayit_aktarilma_tarihi%TYPE;
      v_uye_no                       yk_dp_kontrat.uye_no%TYPE;
      v_service_address_id           yk_dp_kontrat.service_address_id%TYPE;
      v_wiz_employee_code            co_kullanici.wiz_employee_code%TYPE;
      v_bayi_kodu                    wiz_work_order.sales_agent_code%TYPE;
      v_islem_tipi                   NUMBER (1);
      v_is_emri_no                   yk_dp_kontrat.is_emri_no%TYPE;
      v_sonuc_num                    NUMBER (6);
      v_potansiyel_is_emri_id        yk_dp_kontrat.potansiyel_is_emri_id%TYPE;
      v_gelis_kod                    pr_form_gelis_tipi.kod%TYPE;
      v_proc_name                    VARCHAR2 (124);
      v_ts_sifre_id                  lg_ekipman.lg_teknik_servis_sifre_id%TYPE;
      v_uye_stb_tipi                 wiz_customer_hp_life.hp_cluster%TYPE;
      v_sozlesme_stb_tipi            wiz_customer_hp_life.hp_cluster%TYPE;
      v_yeni_vestel_uye              BOOLEAN := FALSE;
      v_asil_uye                     yk_dp_kontrat.uye_no%TYPE;
      v_out_new_service_address_id   yk_dp_kontrat.service_address_id%TYPE;
      v_anne_adi                     yk_dp_kontrat.anne_adi%TYPE;
      v_baba_adi                     yk_dp_kontrat.baba_adi%TYPE;
      v_nufusa_kayitli_ilcesi        yk_dp_kontrat.nufusa_kayitli_ilcesi%TYPE;
      v_nufusa_kayitli_ili           yk_dp_kontrat.nufusa_kayitli_ili%TYPE;
      v_abone_ozellik_kodu           yk_dp_kontrat.abone_ozellik_kodu%TYPE;
      v_modul_tipi                   yk_dp_kontrat.modul_tipi%TYPE;
      v_ekipman_kutu_tipi            yk_dp_kontrat.ekipman_kutu_tipi%TYPE;
      v_ekipman_harddisk_tipi        eq_ekipman.ekipman_tipi%TYPE; --   MKECECI
      v_ekipman_modem_tipi           eq_ekipman.ekipman_tipi%TYPE;   --MKECECI
      v_modul_seri_no                yk_dp_kontrat.modul_seri_no%TYPE;
      oyk_dp_pot_id                  NUMBER;
      v_ekipman_tipi                 NUMBER (10);
      v_ekipman_modul_tipi           NUMBER (10);
      v_eq_id                        NUMBER (10);
      v_ozellik_kod                  VARCHAR2 (30);
      p_statu                        mb_abone_statu.statu%TYPE;
      p_eski_statu                   mb_abone_statu.eski_statu%TYPE;
      p_detay_statu                  mb_abone_statu.detay_statu%TYPE;
      p_return_status                VARCHAR2 (1024);
      v_vatandaslikno                yk_dp_kontrat.tc_kimlik_no%TYPE;
      v_ciltno                       yk_dp_kontrat.cilt_no%TYPE;
      v_ailesirano                   yk_dp_kontrat.aile_sira_no%TYPE;
      v_sirano                       yk_dp_kontrat.sira_no%TYPE;
      v_outlet_location              NUMBER;
      v_fatura_eyalet                yk_dp_kontrat.fatura_eyalet%TYPE;
      v_fatura_ulke                  yk_dp_kontrat.fatura_ulke%TYPE;
      v_durum                        VARCHAR2 (100);
      v_tmp                          VARCHAR2 (100);
      v_debit_method                 CHAR (1) DEFAULT 'C';
      prospect_count                 NUMBER (1);
      v_harddisk_seri_no             yk_dp_kontrat.harddisk_seri_no%TYPE; --15.10.2012 MKECECI
      v_modem_seri_no                yk_dp_kontrat.modem_seri_no%TYPE; --MKECECI
      v_ozellik_destekli             VARCHAR2 (3) := NULL;           --MKECECI
      v_hdd_ekipman_tip_matrix_id    eq_ekipman_tip_matrix.eq_ekipman_tip_matrix_id%TYPE
         := NULL;                                                    --MKECECI
      v_sc_ekipman_tip_matrix_id     NUMBER (10);          -- 05102010 Falamur
      v_st_ekipman_tip_matrix_id     NUMBER (10);          -- 05102010 Falamur
      v_md_ekipman_tip_matrix_id     NUMBER (10);          -- 05102010 Falamur
      v_converter_model              eq_ekipman_tip_matrix.converter_model%TYPE;
      v_kitle_durum                  VARCHAR2 (255);
      v_kitle_iliski_say             NUMBER DEFAULT 0;
      v_islem_tarihi                 DATE;
      v_tarih_tmp                    DATE;
      v_tksrvs_il                    bt_bayi_teknik_servis.il%TYPE;
      v_tksrvs_ulke                  bt_bayi_teknik_servis.ulke%TYPE;
      v_arama_yonlendirme_id         bt_yts_arama_yonlendirme.id%TYPE;
      v_sales_agent_code             bt_uye_ts.sales_agent_code%TYPE;
      v_arama_yonlendirme_detay_id   bt_yts_arama_yonlendirme_detay.id%TYPE;
      v_result_type                  VARCHAR2 (10);
      v_result_code                  VARCHAR2 (50);
      v_result_message               VARCHAR2 (256);
      v_sifre_text                   yk_dp_kontrat.sifre_text%TYPE;
      v_van                          VARCHAR2 (50);
      v_abone_ozellik_aciklama       VARCHAR2 (100);
      v_rf_mdu_tipi                  mb_abone_detay_bilgi.rf_mdu_tipi%TYPE; --MKECECI

      CURSOR d2d_cur
      IS
             SELECT *
               FROM ie_potansiyel_is_emri
              WHERE id = v_potansiyel_is_emri_id
         FOR UPDATE OF degistirme_tarihi NOWAIT;

      CURSOR d2d_other_cur
      IS
             SELECT *
               FROM ie_potansiyel_is_emri
              WHERE     islem_tipi = 1
                    AND prospect_number IN (SELECT prospect_number
                                              FROM ie_potansiyel_is_emri
                                             WHERE id = v_potansiyel_is_emri_id)
                    AND id <> v_potansiyel_is_emri_id
         FOR UPDATE OF degistirme_tarihi NOWAIT;

      CURSOR cur_kontrat_ekipman
      IS
         SELECT *
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE yk_dp_kontrat_ekipman_bilgi.sozlesme_no = v_sozlesme_no;

      rec_kontrat_ekipman            cur_kontrat_ekipman%ROWTYPE;
      d2d_rec                        d2d_cur%ROWTYPE;
      v_mysozlesme_stb_tipi          VARCHAR2 (10);
      v_tk_kart_no                   yk_dp_kontrat.sc_seri_no%TYPE;
      v_fatura_adresi_yarat          BOOLEAN;
      v_stok_kodu                    VARCHAR2 (20);
      v_error_type                   NUMBER (1);
      v_error_code                   VARCHAR2 (10);
      v_error_text                   VARCHAR2 (512);
      v_uyari_mesaji                 VARCHAR2 (512);
      v_oda_sayisi                   mb_abone_detay_bilgi.daire_sayisi%TYPE;
      v_hata_kodu                    NUMBER;
      v_odeme_emri_sonuc             VARCHAR2 (10);
      v_payment_status               NUMBER;
      v_abone_ozellik_kategori       VARCHAR2 (50);
      v_sc_serial_number             VARCHAR2 (20);
      v_sc_durum                     VARCHAR2 (1);
      v_st_serial_number             VARCHAR2 (20);
      v_st_durum                     VARCHAR2 (1);
      v_sozlesme_no_stok             VARCHAR2 (20);
      v_sozlesme_durum               VARCHAR2 (1);
      v_modul_no                     VARCHAR2 (20);
      v_modul_durum                  VARCHAR2 (1);
      v_modul_tip                    VARCHAR2 (20);
      v_ch_serial_number             VARCHAR2 (20);
      v_chip_durum                   VARCHAR2 (1);
      v_stokkodu                     VARCHAR2 (20);
      v_eslenik_id                   NUMBER;
      v_ittp_order_int_open          NUMBER;
      --VCALOGLU<begin>
      v_avp_ozellik                  NUMBER;
      v_vergi_ozellik                NUMBER;
   --VCALOGLU<end>
   BEGIN
      v_ittp_order_int_open :=
         billing_dbs_int.exclude_control_pkg.is_integration_active (
            'ITTP_ORDER_INT');

      v_abone_ozellik_kodu := in_abone_ozellik_kodu;
      v_sozlesme_tipi := isozlesme_tipi;
      v_is_yeri_yetkilisi_1 := iis_yeri_yetkilisi_1;
      v_is_yeri_yetkilisi_2 := iis_yeri_yetkilisi_2;
      v_digikutu_bagli_tel := idigikutu_bagli_tel;
      v_dwelling_type := idwelling_type;
      v_billing_frequency := ibilling_frequency;
      v_ruhsat_yeri_id := iruhsat_yeri_id;
      v_ruhsat_tarihi := iruhsat_tarihi;
      v_ruhsat_verilme_ili := iruhsat_verilme_ili;
      v_ruhsat_sicil_no := iruhsat_sicil_no;
      v_ruhsat_belediye := iruhsat_belediye;
      v_faaliyet_konusu := ifaaliyet_konusu;
      v_fatura_apt_adi := ifatura_apt_adi;
      v_fatura_blok := ifatura_blok;
      v_fatura_apt_no := ifatura_apt_no;
      v_fatura_semt := ifatura_semt;
      v_fatura_ilce := ifatura_ilce;
      v_fatura_il := ifatura_il;
      v_fatura_daire_no := ifatura_daire_no;
      v_fatura_posta_kodu := ifatura_posta_kodu;
      v_mdu_ceki := imdu_ceki;
      v_mdu_bu_ceki := imdu_bu_ceki;
      v_teknisyen_kodu := iteknisyen_kodu;
      v_daire_sayisi := idaire_sayisi;
      v_kat_sayisi := ikat_sayisi;
      v_stb_seri_no := TRIM (istb_seri_no);
      v_sc_seri_no := isc_seri_no;
      v_telefon_ceki := itelefon_ceki;
      v_kk_tipi := ikk_tipi;
      v_kk_no := ikk_no;
      v_kk_son_tarihi := ikk_son_tarihi;
      v_outlet_location := TO_NUMBER (ioutlet_location);
      v_harddisk_seri_no := iharddisk_seri_no;            --15.10.2012 MKECECI
      v_modem_seri_no := imodem_seri_no;                             --MKECECI
      v_rf_mdu_tipi := irf_mdu_tipi;                                 --MKECECI

      IF RTRIM (ibayi_kodu) IS NULL
      THEN
         v_bayi_kodu := '        ';
      ELSE
         v_bayi_kodu := ibayi_kodu;
      END IF;

      v_kon_gel_tipi := ikon_gel_tipi;
      v_building_id := ibuilding_id;
      v_service_address_id := iservice_address_id;
      v_servis_tarihi := iservis_tarihi;
      v_revizyon := irevizyon;
      v_batch := ibatch;
      v_its_kayit_no := iits_kayit_no;
      v_status := istatus;
      v_giren_kullanici := igiren_kullanici;
      v_uye_tipi := iuye_tipi;
      v_kimlik_cinsi := ikimlik_cinsi;
      v_bina_tipi := ibina_tipi;
      v_hub_code := ihub_code;
      v_prospect_number := iprospect_number;
      v_franchise_code := ifranchise_code;
      v_tuttugu_takim_kodu := ituttugu_takim_kodu;
      v_campaign_code := icampaign_code;
      v_vip := ivip;
      v_sozlesme_no := isozlesme_no;
      v_sozlesme_tarihi := isozlesme_tarihi;
      v_yeni_mdu_no := iyeni_mdu_no;
      v_eski_mdu_no := ieski_mdu_no;
      v_is_emri_no := iis_emri_no;
      v_uye_no := iuye_no;
      v_eski_yeni_ceki := ieski_yeni_ceki;
      v_ad := iad;
      v_soyad := isoyad;
      v_anne_kizlik_soyad := ianne_kizlik_soyad;
      v_dogum_yeri := idogum_yeri;
      v_dogum_tarihi := idogum_tarihi;
      v_cinsiyet := icinsiyet;
      v_meslek := imeslek;
      v_meslek_id := imeslek_id;
      v_kimlik_yeri := ikimlik_yeri;
      v_kimlik_seri_no := ikimlik_seri_no;
      v_kimlik_kayit_no := ikimlik_kayit_no;
      v_kimlik_tarihi := ikimlik_tarihi;
      v_tabiyet := itabiyet;
      v_vergi_dairesi := ivergi_dairesi;
      v_vergi_no := ivergi_no;
      v_ev_tel_ulke_alan := iev_tel_ulke_alan;
      v_ev_tel_alan := iev_tel_alan;
      v_ev_tel_prefix := iev_tel_prefix;
      v_ev_tel_no := iev_tel_no;
      v_is_tel_ulke_alan := iis_tel_ulke_alan;
      v_is_tel_alan := iis_tel_alan;
      v_is_tel_prefix := iis_tel_prefix;
      v_is_tel_no := iis_tel_no;
      v_is_tel_dahili := iis_tel_dahili;
      v_cep_tel_ulke_alan := icep_tel_ulke_alan;
      v_cep_tel_alan := icep_tel_alan;
      v_cep_tel_prefix := icep_tel_prefix;
      v_cep_tel_no := icep_tel_no;
      v_fax_tel_ulke_alan := ifax_tel_ulke_alan;
      v_fax_tel_alan := ifax_tel_alan;
      v_fax_tel_prefix := ifax_tel_prefix;
      v_fax_tel_no := ifax_tel_no;
      v_email := iemail;
      v_fatura_sirket_adi := ifatura_sirket_adi;
      v_fatura_mahalle := ifatura_mahalle;
      v_fatura_cadde := ifatura_cadde;
      v_fatura_sokak := ifatura_sokak;
      v_fatura_site_adi := ifatura_site_adi;
      v_digikart_var_mi := idigikart_var_mi;
      v_mdu_sistem_no := imdu_sistem_no;
      v_mdu_yontem_no := imdu_yontem_no;
      v_billing_cycle := ibilling_cycle;
      v_guvenlik_kodu := iguvenlik_kodu;
      v_potansiyel_is_emri_id := ipotansiyel_is_emri_id;
      v_ts_sifre_id := in_ts_sifre_id;
      v_anne_adi := in_anne_adi;
      v_baba_adi := in_baba_adi;
      v_nufusa_kayitli_ilcesi := in_nufusa_kayitli_ilcesi;
      v_nufusa_kayitli_ili := in_nufusa_kayitli_ili;
      v_modul_tipi := in_modul_tipi;
      v_ekipman_kutu_tipi := in_ekipman_kutu_tipi;
      v_modul_seri_no := in_modul_seri_no;
      v_fatura_adresi_yarat := TRUE;
      v_mysozlesme_stb_tipi :=
         vestel_pack.abone_stb_tipi_from_sozlesme (v_sozlesme_no,
                                                   in_stb_tipi);
      v_fatura_ayni_kalsin_flag := NULL;
      v_sifre_text := isifre_text;

      IF iuye_no IS NULL
      THEN
         v_islem_tipi := 2;
      ELSE
         v_islem_tipi := 3;
      END IF;

      v_vatandaslikno := ivatandaslikno;
      v_ciltno := iciltno;
      v_ailesirano := iailesirano;
      v_sirano := isirano;
      v_fatura_eyalet := ifatura_eyalet;
      v_fatura_ulke := ifatura_ulke;

      IF TRIM (v_ts_sifre_id) = '' OR TRIM (v_ts_sifre_id) IS NULL
      THEN
         BEGIN
            SELECT id
              INTO v_ts_sifre_id
              FROM lg_teknik_servis_sifre
             WHERE sozlesme_no = v_sozlesme_no AND ROWNUM = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END IF;

      --kullanici kodu kontrolu
      IF igiren_kullanici IS NULL
      THEN
         durum := 'KULLANICI BILGISI DOLU OLMALIDIR!';
         RETURN;
      ELSE
         BEGIN
            SELECT wiz_operator_id, kod, wiz_employee_code
              INTO v_wiz_operator_id, v_giren_kullanici, v_wiz_employee_code
              FROM co_kullanici
             WHERE kod = igiren_kullanici;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               durum := 'HATALI KULLANICI KODU ';
               RETURN;
         END;
      END IF;

      IF ioutlet_location IS NULL
      THEN
         durum := 'OUTLET BILGISI YOK';
         RETURN;
      END IF;

      --yko deGerI parametrelerden gelIyor
      v_paramyko := dbs_sabit ('YENI_KONTRAT');

      IF v_sozlesme_tipi <> '5'
      THEN
         --ekipman bIlgIlerInI elde et..
         IF LTRIM (v_sc_seri_no) IS NOT NULL
         THEN
            BEGIN
               SELECT equip_location_code
                 INTO v_ekipmanlokasyonsc
                 FROM wiz_equip
                WHERE serial_number = v_sc_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                  RETURN;
            END;
         END IF;

         IF LTRIM (v_stb_seri_no) IS NOT NULL
         THEN
            BEGIN
               SELECT equip_location_code
                 INTO v_ekipmanlokasyonstb
                 FROM wiz_equip
                WHERE serial_number = v_stb_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                  RETURN;
            END;
         END IF;

         /*Modül bilgileri aliniyor - MKECECI*/
         IF (TRIM (v_modul_seri_no) IS NOT NULL)
         THEN
            BEGIN
               SELECT equip_location_code
                 INTO v_ekipmanlokasyonmd
                 FROM eq_ekipman
                WHERE serial_number = v_modul_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                  RETURN;
            END;
         END IF;

         /*Modem bilgileri Aliniyor - MKECECI*/
         IF (TRIM (v_modem_seri_no) IS NOT NULL)
         THEN
            BEGIN
               SELECT equip_location_code
                 INTO v_ekipmanlokasyonmodem
                 FROM eq_ekipman
                WHERE serial_number = v_modem_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                  RETURN;
            END;
         END IF;

         /*Hardisk Bilgileri aliniyor - MKECECI */
         IF (TRIM (v_harddisk_seri_no) IS NOT NULL)
         THEN
            BEGIN
               SELECT equip_location_code
                 INTO v_ekipmanlokasyonhdd
                 FROM eq_ekipman
                WHERE serial_number = v_harddisk_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := 'HDD EKIPMAN LOKASYONU BULUNAMADI';
                  RETURN;
            END;
         END IF;
      ELSE
         FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
         LOOP
            --ekipman bIlgIlerInI elde et..
            IF LTRIM (rec_kontrat_ekipman.kart_seri_no) IS NOT NULL
            THEN
               BEGIN
                  SELECT equip_location_code
                    INTO v_ekipmanlokasyonsc
                    FROM wiz_equip
                   WHERE serial_number = rec_kontrat_ekipman.kart_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                     RETURN;
               END;
            END IF;

            IF LTRIM (rec_kontrat_ekipman.kutu_seri_no) IS NOT NULL
            THEN
               BEGIN
                  SELECT equip_location_code
                    INTO v_ekipmanlokasyonstb
                    FROM wiz_equip
                   WHERE serial_number = rec_kontrat_ekipman.kutu_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                     RETURN;
               END;
            END IF;

            /*Modül bilgileri aliniyor - MKECECI*/
            IF (TRIM (v_modul_seri_no) IS NOT NULL)
            THEN
               BEGIN
                  SELECT equip_location_code
                    INTO v_ekipmanlokasyonmd
                    FROM eq_ekipman
                   WHERE serial_number = v_modul_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                     RETURN;
               END;
            END IF;

            /*Modem bilgileri Aliniyor - MKECECI*/
            IF (TRIM (v_modem_seri_no) IS NOT NULL)
            THEN
               BEGIN
                  SELECT equip_location_code
                    INTO v_ekipmanlokasyonmodem
                    FROM eq_ekipman
                   WHERE serial_number = v_modem_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                     RETURN;
               END;
            END IF;

            /*Hardisk Bilgileri aliniyor - MKECECI */
            IF (TRIM (v_harddisk_seri_no) IS NOT NULL)
            THEN
               BEGIN
                  SELECT equip_location_code
                    INTO v_ekipmanlokasyonhdd
                    FROM eq_ekipman
                   WHERE serial_number = rec_kontrat_ekipman.harddisk_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     durum := 'EKIPMAN LOKASYONU BULUNAMADI';
                     RETURN;
               END;
            END IF;
         END LOOP;
      END IF;

      /*--- Evren --- 20120213 --- begin ---*/
      activation_sms_kontrol (
         v_franchise_code,
         v_uye_tipi,
            v_cep_tel_ulke_alan
         || v_cep_tel_alan
         || v_cep_tel_prefix
         || v_cep_tel_no,
         v_sifre_text,
         v_sozlesme_no,
         v_teknisyen_kodu,
         v_giren_kullanici,
         durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      UPDATE yk_activation_sms s
         SET s.sozlesme_no = v_sozlesme_no
       WHERE     s.tel_no =
                       v_cep_tel_ulke_alan
                    || v_cep_tel_alan
                    || v_cep_tel_prefix
                    || v_cep_tel_no
             AND s.sozlesme_no IS NULL
             AND s.sifre = v_sifre_text
             AND s.expire_date > SYSDATE;

      /*--- Evren --- 20120213 --- end ---*/

      --adres satirlarinin oluSmasi gerekIyor mu??
      -- *** 24.08.2005
      -- *** Kontrat isleminde fatura adresi olusturma islemi kaldirildi.
      /*
       BEGIN
          SELECT hata_kod
            INTO v_fatura_ayni_kalsin_flag
            FROM YK_DP_KONTRAT_TS_HATAKOD
           WHERE sozlesme_no = v_sozlesme_no AND hata_kod = '500';
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             v_fatura_ayni_kalsin_flag := NULL;
       END;

       --adres satirlarini oluStur
       IF v_fatura_ayni_kalsin_flag IS NULL
       THEN
          --adres satirlarini oluStur
          IF     LENGTH (LTRIM (RTRIM (v_fatura_mahalle))) > 1
             AND LTRIM (RTRIM (v_fatura_mahalle)) <> '-'
             AND LTRIM (RTRIM (v_fatura_mahalle)) <> '*'
          THEN
             v_mahalle := SUBSTR (v_fatura_mahalle, 1, 45) || ' MAH.';
          ELSE
             v_mahalle := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_cadde))) > 1
             AND LTRIM (RTRIM (v_fatura_cadde)) <> '-'
             AND LTRIM (RTRIM (v_fatura_cadde)) <> '*'
          THEN
             v_cadde := SUBSTR (v_fatura_cadde, 1, 45) || ' CAD.';
          ELSE
             v_cadde := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_sokak))) >= 1
             AND LTRIM (RTRIM (v_fatura_sokak)) <> '-'
             AND LTRIM (RTRIM (v_fatura_sokak)) <> '*'
          THEN
             v_sokak := SUBSTR (v_fatura_sokak, 1, 45) || ' SOK.';
          ELSE
             v_sokak := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_site_adi))) >= 1
             AND LTRIM (RTRIM (v_fatura_site_adi)) <> '-'
             AND LTRIM (RTRIM (v_fatura_site_adi)) <> '*'
          THEN
             v_site := SUBSTR (v_fatura_site_adi, 1, 42) || ' SITESI ';
          ELSE
             v_site := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_blok))) >= 1
             AND LTRIM (RTRIM (v_fatura_blok)) <> '-'
             AND LTRIM (RTRIM (v_fatura_blok)) <> '*'
          THEN
             v_blok := SUBSTR (v_fatura_blok, 1, 45) || ' BLOK';
          ELSE
             v_blok := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_apt_no))) >= 1
             AND LTRIM (RTRIM (v_fatura_apt_no)) <> '-'
             AND LTRIM (RTRIM (v_fatura_apt_no)) <> '*'
          THEN
             v_aptno := ' NO:' || SUBSTR (v_fatura_apt_no, 1, 46);
          ELSE
             v_aptno := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_apt_adi))) >= 1
             AND LTRIM (RTRIM (v_fatura_apt_adi)) <> '-'
             AND LTRIM (RTRIM (v_fatura_apt_adi)) <> '*'
          THEN
             v_apt := SUBSTR (v_fatura_apt_adi, 1, 45) || ' APT.';
          ELSE
             v_apt := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_daire_no))) >= 1
             AND LTRIM (RTRIM (v_fatura_daire_no)) <> '-'
             AND LTRIM (RTRIM (v_fatura_daire_no)) <> '*'
          THEN
             v_daire := ' D:' || SUBSTR (v_fatura_daire_no, 1, 47);
          ELSE
             v_daire := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_semt))) > 1
             AND LTRIM (RTRIM (v_fatura_semt)) <> '-'
             AND LTRIM (RTRIM (v_fatura_semt)) <> '*'
          THEN
             v_semt := ' ' || SUBSTR (v_fatura_semt, 1, 49);
          ELSE
             v_semt := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_posta_kodu))) > 1
             AND LTRIM (RTRIM (v_fatura_posta_kodu)) <> '-'
             AND LTRIM (RTRIM (v_fatura_posta_kodu)) <> '*'
          THEN
             v_posta := ' ' || SUBSTR (v_fatura_posta_kodu, 1, 5);
          ELSE
             v_posta := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_il))) > 1
             AND LTRIM (RTRIM (v_fatura_il)) <> '-'
             AND LTRIM (RTRIM (v_fatura_il)) <> '*'
          THEN
             v_il := ' ' || SUBSTR (v_fatura_il, 1, 49);
          ELSE
             v_il := '';
          END IF;

          IF     LENGTH (LTRIM (RTRIM (v_fatura_ilce))) > 1
             AND LTRIM (RTRIM (v_fatura_ilce)) <> '-'
             AND LTRIM (RTRIM (v_fatura_ilce)) <> '*'
          THEN
             v_ilce := ' ' || SUBSTR (v_fatura_ilce, 1, 49);
          ELSE
             v_ilce := '';
          END IF;

          IF LENGTH (v_mahalle || v_cadde || v_sokak || v_site) <= 50
          THEN
             v_adr_1 := v_mahalle || v_cadde || v_sokak || v_site;
             v_adr_2 := v_apt;
             v_adr_3 := v_blok || v_aptno || v_daire;
          ELSIF LENGTH (v_mahalle || v_cadde || v_sokak) <= 50
          THEN
             v_adr_1 := v_mahalle || v_cadde || v_sokak;

             IF LENGTH (v_site || v_apt) <= 50
             THEN
                v_adr_2 := v_site || v_apt;
                v_adr_3 := v_blok || v_aptno || v_daire;
             ELSE
                v_adr_2 := v_site;

                IF LENGTH (v_apt || v_blok || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_apt || v_blok || v_aptno || v_daire;
                ELSE
                   v_adr_3 := v_blok || v_aptno || v_daire;
                END IF;
             END IF;
          ELSIF LENGTH (v_mahalle || v_cadde) <= 50
          THEN
             v_adr_1 := v_mahalle || v_cadde;

             IF LENGTH (v_sokak || v_site || v_apt) <= 50
             THEN
                v_adr_2 := v_sokak || v_site || v_apt;
                v_adr_3 := v_blok || v_aptno || v_daire;
             ELSIF LENGTH (v_sokak || v_site) <= 50
             THEN
                v_adr_2 := v_sokak || v_site;

                IF LENGTH (v_apt || v_blok || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_apt || v_blok || v_aptno || v_daire;
                ELSE
                   v_adr_3 := v_blok || v_aptno || v_daire;        --v_apt yok
                END IF;
             ELSE
                v_adr_2 := v_sokak;

                IF LENGTH (v_site || v_apt || v_blok || v_aptno || v_daire) <=
                                                                            50
                THEN
                   v_adr_3 := v_site || v_apt || v_blok || v_aptno || v_daire;
                ELSIF LENGTH (v_site || v_blok || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_site || v_blok || v_aptno || v_daire;
                                                                   --v_apt yok
                ELSIF LENGTH (v_site || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_site || v_aptno || v_daire;
                                                         --v_apt ve v_blok yok
                ELSIF LENGTH (v_site || v_aptno || v_daire) IS NULL
                THEN
                   durum := 'ADRES BILGILERI YETERSIZ.';
                   RETURN;
                ELSE
                   durum :=
                      'ADRES BILGILERI ÇOK UZUN. LÜTFEN ADRES BILGILERINI KISALTINIZ.';
                   RETURN;
                END IF;
             END IF;
          ELSE
             v_adr_1 := v_mahalle;

             IF LENGTH (v_cadde || v_sokak || v_site || v_apt) <= 50
             THEN
                v_adr_2 := v_cadde || v_sokak || v_site || v_apt;
                v_adr_3 := v_blok || v_aptno || v_daire;
             ELSIF LENGTH (v_cadde || v_sokak || v_site) <= 50
             THEN
                v_adr_2 := v_cadde || v_sokak || v_site;

                IF LENGTH (v_apt || v_blok || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_apt || v_blok || v_aptno || v_daire;
                ELSE
                   v_adr_3 := v_blok || v_aptno || v_daire;        --v_apt yok
                END IF;
             ELSIF LENGTH (v_cadde || v_sokak) <= 50
             THEN
                v_adr_2 := v_cadde || v_sokak;

                IF LENGTH (v_site || v_apt || v_blok || v_aptno || v_daire) <=
                                                                            50
                THEN
                   v_adr_3 := v_site || v_apt || v_blok || v_aptno || v_daire;
                ELSIF LENGTH (v_site || v_blok || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_site || v_blok || v_aptno || v_daire;
                                                                   --v_apt yok
                ELSIF LENGTH (v_site || v_aptno || v_daire) <= 50
                THEN
                   v_adr_3 := v_site || v_aptno || v_daire;
                                                         --v_apt ve v_blok yok
                ELSIF LENGTH (v_site || v_aptno || v_daire) IS NULL
                THEN
                   durum := 'ADRES BILGILERI YETERSIZ.';
                   RETURN;
                ELSE
                   durum :=
                      'ADRES BILGILERI ÇOK UZUN. LÜTFEN ADRES BILGILERINI KISALTINIZ.';
                   RETURN;
                END IF;
             ELSE
                v_adr_2 := v_cadde;

                IF LENGTH (   v_sokak
                           || v_site
                           || v_apt
                           || v_blok
                           || v_aptno
                           || v_daire
                          ) <= 50
                THEN
                   v_adr_3 :=
                      v_sokak || v_site || v_apt || v_blok || v_aptno
                      || v_daire;
                ELSIF LENGTH (v_sokak || v_site || v_blok || v_aptno || v_daire) <=
                                                                             50
                THEN
                   v_adr_3 :=
                             v_sokak || v_site || v_blok || v_aptno || v_daire;
                                                                   --v_apt yok
                ELSIF LENGTH (v_sokak || v_site || v_aptno || v_daire) <= 50
                THEN                                      --v_apt ve v_blok yok
                   v_adr_3 := v_sokak || v_site || v_aptno || v_daire;
                ELSIF LENGTH (v_sokak || v_site || v_aptno || v_daire) IS NULL
                THEN
                   IF v_mysozlesme_stb_tipi <> 'TK'
                   THEN
                      durum := 'ADRES BILGILERI YETERSIZ.';
                      RETURN;
                   ELSE
                      v_fatura_adresi_yarat := FALSE;
                   END IF;
                ELSE
                   durum :=
                      'ADRES BILGILERI ÇOK UZUN. LÜTFEN ADRES BILGILERINI KISALTINIZ.';
                   RETURN;
                END IF;
             END IF;
          END IF;
       END IF;
      */
      -- *** 24.08.2005
      -- *** Kontrat isleminde fatura adresi olusturma islemi kaldirildi.

      -----------------------------------------------------------------------------------------------
      --YENI ÜYE
      -----------------------------------------------------------------------------------------------
      --vestel akisi için eklendi
      --eger üye tipi ile sozlesme tipi farkli ise yeni üye numarasi yaratilacak
      ---------------------------------------------------------------------------
      IF LTRIM (iuye_no) IS NOT NULL
      THEN
         v_uye_stb_tipi := vestel_pack.abone_stb_tipi_bul (LTRIM (iuye_no));

         IF v_uye_stb_tipi = '-1'
         THEN
            durum := 'ÜYE STB TIPI BULUNAMADI.';
            RETURN;
         END IF;

         v_sozlesme_stb_tipi :=
            vestel_pack.abone_stb_tipi_from_sozlesme (v_sozlesme_no,
                                                      in_stb_tipi);

         IF     v_sozlesme_stb_tipi <> '-1'
            AND v_sozlesme_stb_tipi <> v_uye_stb_tipi
         THEN
            v_yeni_vestel_uye := TRUE;
         ELSE
            v_yeni_vestel_uye := FALSE;
         END IF;
      ELSE
         v_sozlesme_stb_tipi :=
            vestel_pack.abone_stb_tipi_from_sozlesme (v_sozlesme_no,
                                                      in_stb_tipi);

         IF v_sozlesme_stb_tipi = '-1'
         THEN
            v_sozlesme_stb_tipi := '  ';
         END IF;
      END IF;

      ---------------------------------------------------------------------------
      IF v_mysozlesme_stb_tipi = 'TK' AND v_sozlesme_tipi <> '5' -- zap sitelerde yok.
      THEN
         v_tk_kart_no := tk_pack.tk_kartno_bul (v_sozlesme_no, 'TK');

         IF v_sc_seri_no <> v_tk_kart_no OR TRIM (v_tk_kart_no) IS NULL
         THEN
            IF yetki_pack.yetkisi_varmi (
                  v_giren_kullanici,
                  'ISLEM_ZAP_KART_FARKLI_EKIPMAN_GIRISI') = 0
            THEN
               durum :=
                     'BU ÜYENIN SÖZLESMESI ILE EKIPMANI UYUSMAMAKTADIR.:'
                  || v_tk_kart_no;
               RETURN;
            END IF;
         END IF;

         v_stok_kodu := stok_dba.zapkart.stokkodu_bul (v_sc_seri_no);

         SELECT COUNT (1)
           INTO v_count
           FROM pr_servis_stok_tanim p, icr_dp_servis_default s
          WHERE     icr_dp_kod = s.kod
                AND s.franchise_code = v_franchise_code
                AND p.stok_kodu = v_stok_kodu
                AND s.campaign_code = v_campaign_code
                AND s.listeden_gizle = 'H'
                AND p.listeden_gizle = 'H'
                AND (s.stb_tipi IS NULL OR s.stb_tipi = v_mysozlesme_stb_tipi)
                AND (s.effective_date IS NULL OR s.effective_date <= SYSDATE)
                AND (s.expire_date IS NULL OR s.expire_date >= SYSDATE);

         IF v_count = 0
         THEN
            durum := 'Sözlesmenin kampanyasi hatalidir!';
            RETURN;
         END IF;
      END IF;

      -- VIP ozelligi olan abonelere sozlesme girisini sadece ABONE_OZELLIK_KATEGORI_XX
      -- yetkisine sahip olan kisiler yapabileceklerdir mcetinbag
      IF TRIM (iuye_no) IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.mb_abone_ozellik
          WHERE account_number = iuye_no AND abone_ozellik_kodu = 1;

         --aciklama = 'VIP'
         IF v_count > 0
         THEN
            BEGIN
               SELECT TRIM (TO_CHAR (kategori))
                 INTO v_abone_ozellik_kategori
                 FROM dbs_dba.pr_abone_ozellik
                WHERE kod = 1;                             -- aciklama = 'VIP'

               IF yetki_pack.yetkisi_varmi (
                     v_giren_kullanici,
                     'ABONE_OZELLIK_KATEGORI_' || v_abone_ozellik_kategori) =
                     0
               THEN
                  durum :=
                        'BU ÜYENIN SÖZLESMESINI GIREBILMEK IÇIN ABONE_OZELLIK_KATEGORI_'
                     || v_abone_ozellik_kategori
                     || ' YETKISINE SAHIP OLMALISINIZ!';
                  RETURN;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum :=
                     'VIP ozelligi icin ABONE_OZELLIK_KATEGORI yetkisi bulunamadi!';
                  RETURN;
            END;
         END IF;
      END IF;

      IF    LTRIM (iuye_no) IS NULL
         OR LTRIM (iuye_no) = ''
         OR v_yeni_vestel_uye = TRUE
      THEN
         IF v_yeni_vestel_uye = TRUE
         THEN
            uye_adres_pack.servis_adresi_yarat (v_service_address_id,
                                                v_giren_kullanici,
                                                v_out_new_service_address_id,
                                                durum);

            IF durum <> '0'
            THEN
               durum := 'YENI ADRES YARATILAMADI.';
               RETURN;
            END IF;

            v_service_address_id := v_out_new_service_address_id;
         END IF;

         /* ---- Evren --- 20100608 ----  begin ---*/
         /*yabanci franchise lar için kimlik tipi ve kimlik no zorunlu hale getirildi.*/
         IF v_franchise_code IS NOT NULL
         THEN
            IF dbs_dba.potansiyel_is_emri_pack.ie_is_em_yurtdisi_franchiseimi (
                  v_franchise_code,
                  v_giren_kullanici,
                  durum) = 1
            THEN
               --VCALOGLU<begin>
               IF v_service_address_id IS NOT NULL
               THEN
                  IF yetki_pack.yetkisi_varmi (
                        v_giren_kullanici,
                        'KONTRAT_AVRUPA_BIRLIGI_F04_YETKI') = 0
                  THEN
                     SELECT COUNT (1)
                       INTO v_avp_ozellik
                       FROM prod_dba.wiz_hp_description des,
                            dbs_dba.co_ulke co,
                            dbs_dba.co_il_ilce_ozellik co_oz,
                            dbs_dba.pr_genel_tip_detay pr
                      WHERE     des.service_address_id = v_service_address_id
                            AND des.ulke = co.ad
                            AND co_oz.ozel_kod = pr.id
                            AND pr.islem_kodu = 74
                            AND pr.tip_kodu = 4      --avrupa birliği özelliği
                            AND co_oz.ulke_id = co.id;

                     --Avrupa birliği özelliği varsa ve müşteri tipi  NOR veya TIC ise akış devam eder
                     IF v_avp_ozellik < 1
                     THEN
                        IF v_uye_tipi NOT IN ('NOK', 'TIK')
                        THEN
                           durum :=
                              'Bu sözleşme türü için uye tipi uyumsuz.';
                           RETURN;
                        END IF;
                     ELSE
                        IF v_uye_tipi NOT IN ('NOR', 'TIC')
                        THEN
                           durum :=
                              'Bu sözleşme türü için uye tipi uyumsuz.';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;

                  --VERGI_NO_ZORUNLU_ULKE kontrolu begin
                  IF v_vergi_no IS NULL
                  THEN
                     IF v_uye_tipi = 'TIK'
                     THEN
                        SELECT COUNT (1)
                          INTO v_vergi_ozellik
                          FROM prod_dba.wiz_hp_description des,
                               dbs_dba.co_ulke co,
                               dbs_dba.co_il_ilce_ozellik co_oz,
                               dbs_dba.pr_genel_tip_detay pr
                         WHERE     des.service_address_id =
                                      v_service_address_id
                               AND des.ulke = co.ad
                               AND co_oz.ozel_kod = pr.id
                               AND pr.islem_kodu = 74
                               AND pr.tip_kodu = 6 -- VERGI NO ZORUNLU ÜLKELER
                               AND co_oz.ulke_id = co.id;

                        IF v_vergi_ozellik > 0
                        THEN
                           durum :=
                              'Bu sozlesme türü için vergi no alanı zorunludur.';
                           RETURN;
                        END IF;
                     END IF;
                  END IF;
               --VERGI_NO_ZORUNLU_ULKE kontrolu end
               END IF;

               --VCALOGLU<end>

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_type_codes
                WHERE     abbrev = 1
                      AND privileged_flag = 'Y'
                      AND customer_type = v_uye_tipi;

               IF v_count > 0
               THEN
                  IF TRIM (v_kimlik_cinsi) IS NULL
                  THEN
                     durum := 'Lütfen Kimlik Tipi Alanini doldurunuz!...';
                     RETURN;
                  END IF;

                  IF TRIM (v_kimlik_seri_no) IS NULL
                  THEN
                     durum := 'Lütfen Kimlik Seri No Alanini doldurunuz!...';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         END IF;

         /* ---- Evren --- 20100608 ----  end ---*/
         sms_yeni_kontrat_pack.customer_descrip_insert (
            v_ad,
            v_soyad,
            v_kimlik_cinsi,
            v_kimlik_seri_no,
            v_sozlesme_no,
            v_cinsiyet,
            v_email,
            v_ev_tel_ulke_alan,
            v_ev_tel_alan,
            v_ev_tel_prefix || v_ev_tel_no,
            v_cep_tel_ulke_alan,
            v_cep_tel_alan,
            v_cep_tel_prefix || v_cep_tel_no,
            v_is_tel_ulke_alan,
            v_is_tel_alan,
            v_is_tel_prefix || v_is_tel_no,
            v_is_tel_dahili,
            v_fax_tel_ulke_alan,
            v_fax_tel_alan,
            v_fax_tel_prefix || v_fax_tel_no,
            v_vip,
            v_kimlik_kayit_no,
            v_wiz_operator_id,
            NULL,
            v_uye_no,
            durum);

         IF durum <> '0' OR (v_uye_no = '0' OR v_uye_no IS NULL)
         THEN
            --durum := 'UYE KAYDEDILEMEDI';
            RETURN;
         END IF;

         IF v_yeni_vestel_uye = TRUE
         THEN
            /*
                 v_asil_uye := Vestel_Pack.asil_uye_bul (TRIM (iuye_no));
                 Vestel_Pack.mb_abone_uyelik_insert (v_sozlesme_no,
                                                     v_uye_no,
                                                     v_asil_uye,
                                                     v_service_address_id,
                                                     v_giren_kullanici,
                                                     'YKO',
                                                     v_mb_abone_id,
                                                     durum
                                                    );*/
            -- Evrim Kasim 2006
            -- Yeni iye ile eski üye numarasinin kisi iliski kaydi
            ------------------------------------
            kisi_iliski_pack.kisi_iliski_insert (
               NULL,
               iuye_no,
               NULL,
               NULL,
               NULL,                    --DD_USER_ID (Digital_Dergi_Eklentisi)
               NULL,                      --BP_USER_ID (BP_Abonelik_Eklentisi)
               NULL,                        --DA_USER_ID (Digi_Aile Eklentisi)
               kisi_iliski_pack.iliski_tipi ('ABONELIK'),
               NULL,
               v_uye_no,
               NULL,
               v_giren_kullanici,
               sabit.kontrat_girisi,
               durum,
               v_hata_kodu,
               in_otomatik_giris   => 'E');

            -- v_hata_kodu = 0 ise basarili
            -- v_hata_kodu = 1 ise iliski daha önce yaratilmis
            -- v_hata_kodu > 1 ise hata mesajini gösterek çik.
            IF v_hata_kodu > 1
            THEN
               RETURN;
            END IF;
         END IF;

         sms_yeni_kontrat_pack.hp_life_insert (v_uye_no,
                                               v_service_address_id,
                                               v_billing_cycle,
                                               '',
                                               v_uye_tipi,
                                               v_mdu_bu_ceki,
                                               v_sozlesme_stb_tipi,
                                               v_sonuc,
                                               v_franchise_code -- Evrim !! Parametre gelen fr kodu burada kullanilmali
                                                               );

         IF v_sonuc <> '0'
         THEN
            durum := 'HP_LIFE_INSERT:' || v_sonuc;
            RETURN;
         END IF;

         abone_islem_pack.abone_islem (v_uye_no, v_sonuc, v_mesaj);

         IF v_sonuc <> '0'
         THEN
            durum := 'ABONE_ISLEM' || v_sonuc || v_mesaj;
            RETURN;
         END IF;

         work_order_pack.work_order_insert (v_uye_no,
                                            v_service_address_id,
                                            v_wiz_employee_code,
                                            v_bayi_kodu,
                                            v_islem_tipi,
                                            v_is_emri_no,
                                            v_sonuc_num);

         IF v_is_emri_no = 0 OR v_sonuc_num <> 0
         THEN
            durum := 'WORK_ORDER_INSERT' || v_sonuc_num;
            RETURN;
         END IF;
      ELSE
         -----------------------------------------------------------------------------------------------
         --mevcut Üye
         -----------------------------------------------------------------------------------------------
         abone_islem_pack.abone_islem (v_uye_no, v_sonuc, v_mesaj);

         IF v_sonuc <> '0'
         THEN
            durum := 'ABONE_ISLEM' || v_sonuc || v_mesaj;
            RETURN;
         END IF;

         abone_pack.customer_descrip_update (
            v_ad,
            v_soyad,
            v_kimlik_cinsi,
            v_kimlik_seri_no,
            v_sozlesme_no,
            v_cinsiyet,
            v_email,
            v_ev_tel_ulke_alan,
            v_ev_tel_alan,
            v_ev_tel_prefix || v_ev_tel_no,
            v_cep_tel_ulke_alan,
            v_cep_tel_alan,
            v_cep_tel_prefix || v_cep_tel_no,
            v_is_tel_ulke_alan,
            v_is_tel_alan,
            v_is_tel_prefix || v_is_tel_no,
            v_is_tel_dahili,
            v_fax_tel_ulke_alan,
            v_fax_tel_alan,
            v_fax_tel_prefix || v_fax_tel_no,
            v_vip,
            v_kimlik_kayit_no,
            v_wiz_operator_id,
            v_uye_no,
            v_sonuc,
            'TRUE');

         --TRUE, sözlsmeden geliyor demek.
         IF v_sonuc <> '0'
         THEN
            durum := 'CUSTOMER_DESCRIP_UPDATE:' || v_sonuc;
            RETURN;
         END IF;

         sms_yeni_kontrat_pack.hp_life_update (v_uye_no,
                                               v_mdu_bu_ceki,
                                               v_sonuc);

         IF v_sonuc <> '0'
         THEN
            durum := 'HP_LIFE_UPDATE' || v_sonuc;
            RETURN;
         END IF;

         BEGIN
            SELECT customer_status
              INTO v_customer_status
              FROM wiz_customer_hp_life
             WHERE account_number = iuye_no;
         EXCEPTION
            WHEN TOO_MANY_ROWS
            THEN
               v_customer_status := 'IN';
            WHEN OTHERS
            THEN
               durum := 'UYE STATUSU HATALI.';
               RETURN;
         END;

         IF LTRIM (v_customer_status) = 'IN'
         THEN
            v_islem_tipi := 2;
         END IF;
      END IF;

      BEGIN
         SELECT kod
           INTO v_gelis_kod
           FROM pr_form_gelis_tipi
          WHERE aciklama = 'TELEFON' AND form_tipi = 1 AND ROWNUM = 1;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_gelis_kod := '';
      END;

      -------------------------------------------------------------------------
      -- ekipman bilgisini üyeye ata...
      --------------------------------------------------------------------------
      /* -- Falamur 05102010 Bazi ekipmanlarin aktivasyon sirasinda verilmesinin engellenmesi
            IF v_stb_seri_no IS NOT NULL THEN
               SELECT eq_ekipman_tip_matrix_id, e.converter_model
                 INTO v_ekipman_tip_matrix_id, v_converter_model
                 FROM wiz_equip w,
                      eq_ekipman_tip_matrix e
                WHERE serial_number = v_stb_seri_no
                  AND TRIM (e.manufacturer) = TRIM (w.manufacturer)
                  AND TRIM (e.converter_model) = TRIM (w.converter_model);
            ELSIF TRIM (v_modul_seri_no) IS NOT NULL THEN
               SELECT eq_ekipman_tip_matrix_id, e.converter_model
                 INTO v_ekipman_tip_matrix_id, v_converter_model
                 FROM eq_ekipman w,
                      eq_ekipman_tip_matrix e
                WHERE serial_number = v_modul_seri_no
                  AND e.converter_type = '248'
                  AND NVL (w.ekipman_modul_tipi, -1) = NVL (e.converter_model, -1)
                  AND w.ekipman_tipi = e.converter_type;
            ELSE
               v_ekipman_tip_matrix_id := NULL;
            END IF;
      */

      /*Burada harddisk ile ilgili bir gelistirme yer almiycak*/
      BEGIN
         v_sc_ekipman_tip_matrix_id := NULL;
         v_st_ekipman_tip_matrix_id := NULL;
         v_md_ekipman_tip_matrix_id := NULL;

         IF TRIM (v_modul_seri_no) IS NOT NULL
         THEN
            SELECT eq_ekipman_tip_matrix_id, e.converter_model
              INTO v_md_ekipman_tip_matrix_id, v_converter_model
              FROM eq_ekipman w, eq_ekipman_tip_matrix e
             WHERE     serial_number = v_modul_seri_no
                   AND e.converter_type = '248'
                   AND NVL (w.ekipman_modul_tipi, -1) =
                          NVL (e.converter_model, -1)
                   AND TO_CHAR (w.ekipman_tipi) = e.converter_type;
         ELSE
            IF TRIM (v_stb_seri_no) IS NOT NULL
            THEN
               SELECT eq_ekipman_tip_matrix_id, e.converter_model
                 INTO v_st_ekipman_tip_matrix_id, v_converter_model
                 FROM wiz_equip w, eq_ekipman_tip_matrix e
                WHERE     serial_number = v_stb_seri_no
                      AND TRIM (e.manufacturer) = TRIM (w.manufacturer)
                      AND TRIM (e.converter_model) = TRIM (w.converter_model)
                      AND TRIM (e.converter_type) = TRIM (w.converter_type);
            END IF;
         END IF;

         IF TRIM (v_sc_seri_no) IS NOT NULL
         THEN
            SELECT eq_ekipman_tip_matrix_id
              INTO v_sc_ekipman_tip_matrix_id
              FROM wiz_equip w, eq_ekipman_tip_matrix e
             WHERE     serial_number = v_sc_seri_no
                   AND TRIM (e.manufacturer) = TRIM (w.manufacturer)
                   AND TRIM (e.converter_model) = TRIM (w.converter_model)
                   AND TRIM (e.converter_type) = TRIM (w.converter_type);
         END IF;

         SELECT COUNT (1)
           INTO v_count
           FROM TABLE (
                   split_table_fnc (
                      dbs_dba.dbs_sabit (
                         TRIM ('AKTIVASYONDA_EKIPMAN_KONTROLU'))))
          WHERE COLUMN_VALUE = v_franchise_code || ':' || v_uye_tipi;

         IF v_count > 0
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM pr_urun_ozellik_tanim
             WHERE     ozellik_kodu = 97
                   AND ekipman_tip_matrix_id = v_st_ekipman_tip_matrix_id;

            IF v_count > 0
            THEN
               durum := 'EKLENILEN KUTU AKTIVASYONDA KULLANILAMAZ. ';
               RETURN;
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM pr_urun_ozellik_tanim
             WHERE     ozellik_kodu = 97
                   AND ekipman_tip_matrix_id = v_md_ekipman_tip_matrix_id;

            IF v_count > 0
            THEN
               durum := 'EKLENILEN MODÜL AKTIVASYONDA KULLANILAMAZ. ';
               RETURN;
            END IF;

            SELECT COUNT (1)
              INTO v_count
              FROM pr_urun_ozellik_tanim
             WHERE     ozellik_kodu = 97
                   AND ekipman_tip_matrix_id = v_sc_ekipman_tip_matrix_id;

            IF v_count > 0
            THEN
               durum := 'EKLENILEN KART AKTIVASYONDA KULLANILAMAZ. ';
               RETURN;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      /*--- Evren --- 20110104 --- begin ---*/
      DECLARE
         v_ulke_kodu   co_ulke.id%TYPE;
         v_il_kodu     wiz_hp_description.city%TYPE;
      BEGIN
         SELECT a.id, NVL (b.kod, '-1')
           INTO v_ulke_kodu, v_il_kodu
           FROM (SELECT u.id, hp.city
                   FROM wiz_hp_description hp, co_ulke u
                  WHERE     hp.service_address_id = v_service_address_id
                        AND hp.ulke = u.ad) a,
                co_il b
          WHERE a.id = b.ulke_id(+) AND a.city = b.ad(+);

         SELECT MIN (
                   DECODE (
                      NVL (bayi_kodu, v_teknisyen_kodu),
                      v_teknisyen_kodu, DECODE (
                                           NVL (ulke, v_ulke_kodu),
                                           v_ulke_kodu, DECODE (
                                                           NVL (il,
                                                                v_il_kodu),
                                                           v_il_kodu, 0,
                                                           1),
                                           1),
                      1))
                   uygun_bayi
           INTO v_count
           FROM icr_dp_servis_default_bayi_det
          WHERE     (baslangic_tarihi IS NULL OR baslangic_tarihi <= SYSDATE)
                AND (bitis_tarihi IS NULL OR bitis_tarihi > SYSDATE)
                AND kampanya = v_campaign_code
                AND servis_default_kodu = -1;                       -- kontrat

         IF NVL (v_count, 0) = 1
         THEN
            durum :=
               'Sadece bu kampanya için tanimlanmis bayiler ile kontrat girisi yapilabilir !';
            RETURN;
         END IF;
      END;

      /*--- Evren --- 20110104 --- end ---*/
      IF v_sozlesme_tipi <> '5'
      THEN
         /*MKECECI Harddisk Özellik Kontrolü*/
         IF v_harddisk_seri_no IS NULL
         THEN
            ekipman_pack.ekipman_ozellik (v_stb_seri_no,
                                          NULL,
                                          NULL,
                                          121,
                                          v_hdd_ekipman_tip_matrix_id,
                                          v_ozellik_destekli);

            IF v_ozellik_destekli = 'E'
            THEN
               durum :=
                  'Seçilen Kutu tipi Harddisk Zorunlu özelligine sahiptir.Hard disk seri numarasi girmelisiniz!!';
               RETURN;
            END IF;
         ELSE
            IF TRIM (v_stb_seri_no) IS NULL
            THEN
               durum :=
                  'Sadece hard disk eklenemez.Kutu seri numarasi da girmelisiniz!';
               RETURN;
            END IF;

            IF TRIM (v_stb_seri_no) IS NOT NULL
            THEN
               ekipman_pack.ekipman_ozellik (v_stb_seri_no,
                                             NULL,
                                             NULL,
                                             121,
                                             v_hdd_ekipman_tip_matrix_id,
                                             v_ozellik_destekli);

               IF v_ozellik_destekli = 'H'
               THEN
                  durum :=
                     'Harddisk ekipmanini sadece Harddisk zorunlu özelligine sahip kutulara ekleyebilirsiniz!!';
                  RETURN;
               END IF;
            END IF;
         END IF;

         /*MKECECI - 30.10.2012*/

         IF LTRIM (v_sc_seri_no) IS NOT NULL
         THEN
            --kart datasi giris
            ekipman_pack.ekipman_ekle (v_uye_no,
                                       v_sc_seri_no,
                                       ioutlet_location,
                                       v_teknisyen_kodu,
                                       NULL,                      --ts_form_no
                                       v_paramyko,               --reason_code
                                       '',                            --depoya
                                       v_service_address_id,
                                       'N',             --kontratsiz aktifleme
                                       'N',                          --otel mi
                                       v_giren_kullanici,
                                       v_its_kayit_no,
                                       v_ts_sifre_id,
                                       v_sozlesme_no,
                                       'Yeni sözlesme girisi',
                                       v_sonuc,
                                       v_proc_name,
                                       v_is_emri_no,
                                       v_error_type,
                                       v_error_code,
                                       v_error_text);

            IF v_sonuc <> '0'
            THEN
               durum := 'EKIPMAN_EKLE_SC:' || v_sonuc;
               RETURN;
            END IF;
         END IF;

         -- Modül datasi girisi
         -- Önce kutu sonra modül ekleniyordu. suan modül öne çekildi ve kutu modülden daha sonra ekleniyor. (irdeto kart cyrpto kutu irdeto modül için)  -- FALAMUR  09.02.2011
         IF LTRIM (v_modul_seri_no) IS NOT NULL
         THEN
            SELECT id
              INTO v_ekipman_tipi
              FROM vv_ekipman_tipleri
             WHERE aciklama = 'MODÜL';

            eq_ekipman_pack.eq_ekipman_ekle (v_uye_no,
                                             v_paramyko,         --reason_code
                                             ioutlet_location,
                                             v_ekipman_tipi,
                                             NULL,         --ekipman_kutu_tipi
                                             v_modul_tipi,
                                             v_modul_seri_no,  --serial_number
                                             v_teknisyen_kodu,
                                             SYSDATE,         --kurulum_tarihi
                                             'Yeni sözlesme girisi',
                                             --aciklama
                                             v_giren_kullanici,
                                             SYSDATE,           --islem_tarihi
                                             'N',       --kontratsiz aktifleme
                                             'N',                   --otel mi?
                                             v_sozlesme_no,
                                             v_ts_sifre_id,
                                             v_its_kayit_no,
                                             NULL,                --ts_form_no
                                             v_eq_id,
                                             v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := 'EKIPMAN_EKLE_MODUL:' || v_sonuc;
               RETURN;
            END IF;
         END IF;

         -- kutu datasi girisi
         IF LTRIM (v_stb_seri_no) IS NOT NULL
         THEN
            /*
                        IF yetki_pack.yetkisi_varmi (v_giren_kullanici, 'ISLEM_ZAP_KART_FARKLI_EKIPMAN_GIRISI') =
                                                                                                              0
                        THEN
                           durum := 'BU ÜYENIN SÖZLESMESI ILE EKIPMANI UYUSMAMAKTADIR.:' || v_tk_kart_no;
                           RETURN;
                        END IF;
            */
            IF v_uydu_tipi = 'TÜRKSAT'
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE     ozellik_kodu = 73
                      AND (   ekipman_tip_matrix_id =
                                 v_st_ekipman_tip_matrix_id
                           OR ekipman_tip_matrix_id =
                                 v_md_ekipman_tip_matrix_id);

               -- 05102010 falamur
               IF     v_count = 0
                  AND yetki_pack.yetkisi_varmi (v_giren_kullanici,
                                                'MODEL_KUTU_TURKSAT_KISTI') =
                         0
               THEN
                  durum :=
                        v_converter_model
                     || ' model kutu TURKSAT uydusu üyelerine satilamaz';
                  RETURN;
               END IF;
            ELSIF v_uydu_tipi = 'EUTELSAT'
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE     ozellik_kodu = 74
                      AND (   ekipman_tip_matrix_id =
                                 v_st_ekipman_tip_matrix_id
                           OR ekipman_tip_matrix_id =
                                 v_md_ekipman_tip_matrix_id);

               -- 05102010 falamur
               IF     v_count = 0
                  AND yetki_pack.yetkisi_varmi (v_giren_kullanici,
                                                'MODEL_KUTU_EUTELSAT_KISTI') =
                         0
               THEN
                  durum :=
                        v_converter_model
                     || ' model kutu EUTELSAT uydusu üyelerine satilamaz';
                  RETURN;
               END IF;
            END IF;

            v_count := -1;

            IF v_sozlesme_stb_tipi = 'LG'
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_equip
                WHERE serial_number = v_stb_seri_no;
            END IF;

            IF v_count > 0 OR v_count = -1
            THEN
               --  LG brandine sahip ekipmanlarin bizim stoklarimizda ise ekipman ekle ile çalismasi saglanir,
               --  diger brandler için kosulsuz bu çagrilir . Önemli not: diger brandler için kutu bilgisi takibi sadece wiz_equip üzerinden oldu.
               ekipman_pack.ekipman_ekle (v_uye_no,
                                          v_stb_seri_no,
                                          ioutlet_location,
                                          v_teknisyen_kodu,
                                          NULL,                   --ts_form_no
                                          v_paramyko,            --reason_code
                                          '',                         --depoya
                                          v_service_address_id,
                                          'N',          --kontratsiz aktifleme
                                          'N',                       --otel mi
                                          v_giren_kullanici,
                                          v_its_kayit_no,
                                          v_ts_sifre_id,
                                          v_sozlesme_no,
                                          'Yeni sözlesme girisi',
                                          v_sonuc,
                                          v_proc_name,
                                          v_is_emri_no,
                                          v_error_type,
                                          v_error_code,
                                          v_error_text);

               IF v_sonuc <> '0'
               THEN
                  durum := 'EKIPMAN_EKLE_STB:' || v_error_text;
                  RETURN;
               END IF;
            ELSE
               SELECT id
                 INTO v_ekipman_tipi
                 FROM vv_ekipman_tipleri
                WHERE aciklama = 'DİGİKUTU';

               eq_ekipman_pack.eq_ekipman_ekle (v_uye_no,
                                                v_paramyko,      --reason_code
                                                ioutlet_location,
                                                v_ekipman_tipi,
                                                -- bu ayrim kutu, modüli kart ayriimini tutmaktadir.
                                                v_ekipman_kutu_tipi,
                                                -- bu ayrim ise kutu ise ne marka bir kutu oldugunu belirtir. ör: sunny
                                                NULL,
                                                v_stb_seri_no, --serial_number
                                                v_teknisyen_kodu,
                                                SYSDATE,      --kurulum_tarihi
                                                'Yeni sözlesme girisi',
                                                --aciklama
                                                v_giren_kullanici,
                                                SYSDATE,        --islem_tarihi
                                                'N',    --kontratsiz aktifleme
                                                'N',                --otel mi?
                                                v_sozlesme_no,
                                                v_ts_sifre_id,
                                                v_its_kayit_no,
                                                NULL,
                                                v_eq_id,
                                                v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := 'EKIPMAN_EKLE_STB:' || v_error_text;
                  RETURN;
               END IF;
            END IF;
         END IF;

         -- Hard disk datasi girisi -- MKECECI   10.10.2012
         IF (v_harddisk_seri_no IS NOT NULL)
         THEN
            SELECT id
              INTO v_ekipman_tipi
              FROM vv_ekipman_tipleri
             WHERE aciklama = 'HARDDİSK';

            SELECT e.ekipman_modul_tipi
              INTO v_ekipman_harddisk_tipi
              FROM eq_ekipman e
             WHERE e.serial_number = v_harddisk_seri_no;

            eq_ekipman_pack.eq_ekipman_ekle (v_uye_no,
                                             v_paramyko,         --reason_code
                                             ioutlet_location,
                                             v_ekipman_tipi, -- bu ayrim kutu, modül,kart,Hd ayriimini tutmaktadir.
                                             NULL,              --kutu seri no
                                             v_ekipman_harddisk_tipi, --modul veya hdd tipi
                                             v_harddisk_seri_no, --modül ve hdd serial_number
                                             v_teknisyen_kodu,
                                             SYSDATE,         --kurulum_tarihi
                                             'Yeni sözlesme girisi',
                                             v_giren_kullanici,
                                             SYSDATE,           --islem_tarihi
                                             'N',       --kontratsiz aktifleme
                                             'N',                   --otel mi?
                                             v_sozlesme_no,
                                             v_ts_sifre_id,
                                             v_its_kayit_no,
                                             NULL,
                                             v_eq_id,
                                             v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := 'EKIPMAN_EKLE_HDD:' || v_sonuc;
               RETURN;
            END IF;
         END IF;

         /*Hard disk datasi girisi -- MKECECI   10.10.2012 */

         /*Modem datasi girisi --  MKECECI     13.11.2012*/
         IF (v_modem_seri_no IS NOT NULL)
         THEN
            SELECT id
              INTO v_ekipman_tipi
              FROM vv_ekipman_tipleri
             WHERE aciklama = 'MODEM';

            SELECT x.ekipman_tipi
              INTO v_ekipman_modem_tipi
              FROM eq_ekipman x
             WHERE x.serial_number = v_modem_seri_no;

            eq_ekipman_pack.eq_ekipman_ekle (v_uye_no,
                                             v_paramyko,         --reason_code
                                             ioutlet_location,
                                             v_ekipman_tipi, -- bu ayrim kutu, modül,kart,Hd,modem ayriimini tutmaktadir.
                                             v_ekipman_modem_tipi, --!!!!buraya modem tipini girmek gerekirmi????
                                             NULL,
                                             v_modem_seri_no,  --serial_number
                                             v_teknisyen_kodu,
                                             SYSDATE,         --kurulum_tarihi
                                             'Yeni sözlesme girisi',
                                             --aciklama
                                             v_giren_kullanici,
                                             SYSDATE,           --islem_tarihi
                                             'N',       --kontratsiz aktifleme
                                             'N',                   --otel mi?
                                             v_sozlesme_no,
                                             v_ts_sifre_id,
                                             v_its_kayit_no,
                                             NULL,
                                             v_eq_id,
                                             v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := 'EKIPMAN_EKLE_MODEM:' || v_sonuc;
               RETURN;
            END IF;
         END IF;

         /* </end> Modem datasi girisl */

         --         IF LTRIM (v_sc_seri_no) IS NOT NULL
         --         THEN
         --            -- PH brandli F01-02 üyelerinin 9002 kutulari 16 nisandan itibaren TURKSAT'a kapali olmalidir.
         --            IF     v_stb_seri_no IS NOT NULL
         --               AND v_sc_seri_no IS NOT NULL
         --               AND v_sozlesme_stb_tipi = 'PH'
         --               AND v_franchise_code IN ('F01', 'F02')
         --            THEN
         --               SELECT COUNT (1)
         --                 INTO v_count
         --                 FROM DUAL
         --                WHERE v_ekipman_tip_matrix_id IN (
         --                                                 SELECT COLUMN_VALUE
         --                                                   FROM TABLE (split_table_fnc (dbs_sabit ('TURKSAT_KAPANACAK_MODELLER'))
         --                                                              ));
         --
         --               IF v_count > 0
         --               THEN
         --                  addressability_pack.setothermode (ouye_no, v_sc_seri_no, v_stb_seri_no, '0', igiren_kullanici, durum);
         --
         --                  IF durum <> '0'
         --                  THEN
         --                     RETURN;
         --                  END IF;
         --               END IF;
         --            END IF;
         --         END IF;

         IF v_kon_gel_tipi = TRIM (v_gelis_kod)
         THEN
            --IF v_sozlesme_tipi <> '5'
            --THEN
            addressability_pack.pin_kodu_sifirlama (v_sc_seri_no,
                                                    v_giren_kullanici,
                                                    v_sonuc);
         /*ELSE
            FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
            LOOP
               IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
               THEN
                  addressability_pack.pin_kodu_sifirlama (rec_kontrat_ekipman.kart_seri_no,
                                                          v_giren_kullanici,
                                                          v_sonuc
                                                         );
               END IF;
            END LOOP;
         END IF;*/
         END IF;

         --HDD için eslenik kontrolü yapilmiyor
         stok_dba.dp_stok_eslenik.eslenik_bul (TRIM (v_sc_seri_no),
                                               'SC',
                                               v_sc_serial_number,
                                               v_sc_durum,
                                               v_st_serial_number,
                                               v_st_durum,
                                               v_sozlesme_no_stok,
                                               v_sozlesme_durum,
                                               v_modul_no,
                                               v_modul_durum,
                                               v_modul_tip,
                                               v_ch_serial_number,
                                               v_chip_durum,
                                               v_stokkodu,
                                               v_eslenik_id,
                                               'K');

         IF v_sc_durum = 'E'
         THEN
            stok_dba.dp_stok_eslenik.eslenik_guncelle (v_eslenik_id,
                                                       v_sc_serial_number,
                                                       'SC',
                                                       'H',
                                                       v_giren_kullanici,
                                                       'H',
                                                       durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;

         IF v_st_durum = 'E'
         THEN
            stok_dba.dp_stok_eslenik.eslenik_guncelle (v_eslenik_id,
                                                       v_st_serial_number,
                                                       'ST',
                                                       'H',
                                                       v_giren_kullanici,
                                                       'H',
                                                       durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;

         IF v_sozlesme_durum = 'E'
         THEN
            stok_dba.dp_stok_eslenik.eslenik_guncelle (v_eslenik_id,
                                                       v_sozlesme_no_stok,
                                                       'SZ',
                                                       'H',
                                                       v_giren_kullanici,
                                                       'H',
                                                       durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;

         IF v_modul_durum = 'E'
         THEN
            stok_dba.dp_stok_eslenik.eslenik_guncelle (v_eslenik_id,
                                                       v_modul_no,
                                                       'MD',
                                                       'H',
                                                       v_giren_kullanici,
                                                       'H',
                                                       durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;

         IF v_chip_durum = 'E'
         THEN
            stok_dba.dp_stok_eslenik.eslenik_guncelle (v_eslenik_id,
                                                       v_ch_serial_number,
                                                       'CH',
                                                       'H',
                                                       v_giren_kullanici,
                                                       'H',
                                                       durum);

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         END IF;
      ELSE
         v_outlet_location := TO_NUMBER (ioutlet_location);

         /*Asagidaki loop ta site,lojman için ekipman datalarini giriyor.*/
         FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
         LOOP
            /*MKECECI Harddisk Özellik Kontrolü*/
            v_hdd_ekipman_tip_matrix_id := NULL;

            IF TRIM (rec_kontrat_ekipman.harddisk_seri_no) IS NULL
            THEN
               ekipman_pack.ekipman_ozellik (
                  rec_kontrat_ekipman.kutu_seri_no,
                  NULL,
                  NULL,
                  121,
                  v_hdd_ekipman_tip_matrix_id,
                  v_ozellik_destekli);

               IF v_ozellik_destekli = 'E'
               THEN
                  durum :=
                     'Seçilen Kutu tipi Harddisk Zorunlu özelligine sahiptir.Hard disk seri numarasi girmelisiniz!!';
                  RETURN;
               END IF;
            ELSE
               IF TRIM (rec_kontrat_ekipman.kutu_seri_no) IS NULL
               THEN
                  durum :=
                     'Sadece hard disk eklenemez.Kutu seri numarasi da girmelisiniz!';
                  RETURN;
               END IF;

               IF TRIM (rec_kontrat_ekipman.kutu_seri_no) IS NOT NULL
               THEN
                  ekipman_pack.ekipman_ozellik (
                     rec_kontrat_ekipman.kutu_seri_no,
                     NULL,
                     NULL,
                     121,
                     v_hdd_ekipman_tip_matrix_id,
                     v_ozellik_destekli);

                  IF v_ozellik_destekli = 'H'
                  THEN
                     durum :=
                        'Harddisk ekipmanini sadece Harddisk zorunlu özelligine sahip kutulara ekleyebilirsiniz!!';
                     RETURN;
                  END IF;
               END IF;
            END IF;

            /*MKECECI - 30.10.2012*/

            IF LTRIM (rec_kontrat_ekipman.kart_seri_no) IS NOT NULL
            THEN
               --kart datasi giris
               ekipman_pack.ekipman_ekle (
                  v_uye_no,
                  rec_kontrat_ekipman.kart_seri_no,
                     SUBSTR ('0000000000',
                             0,
                             3 - LENGTH (TO_CHAR (v_outlet_location)))
                  || TO_CHAR (v_outlet_location),
                  v_teknisyen_kodu,
                  NULL,                                           --ts_form_no
                  v_paramyko,                                    --reason_code
                  '',                                                 --depoya
                  v_service_address_id,
                  'N',                                  --kontratsiz aktifleme
                  'N',                                               --otel mi
                  v_giren_kullanici,
                  v_its_kayit_no,
                  v_ts_sifre_id,
                  v_sozlesme_no,
                  'Yeni sözlesme girisi',
                  v_sonuc,
                  v_proc_name,
                  v_is_emri_no,
                  v_error_type,
                  v_error_code,
                  v_error_text);

               IF v_sonuc <> '0'
               THEN
                  durum := 'EKIPMAN_EKLE_SC:' || v_sonuc;
                  RETURN;
               END IF;
            END IF;

            -- Modül datasi girisi
            -- Önce kutu sonra modül ekleniyordu. suan modül öne çekildi ve kutu modülden daha sonra ekleniyor. (irdeto kart cyrpto kutu irdeto modül için)  -- FALAMUR  09.02.2011
            IF LTRIM (rec_kontrat_ekipman.modul_seri_no) IS NOT NULL
            THEN
               SELECT id
                 INTO v_ekipman_tipi
                 FROM vv_ekipman_tipleri
                WHERE aciklama = 'MODÜL';

               eq_ekipman_pack.eq_ekipman_ekle (
                  v_uye_no,
                  v_paramyko,                                    --reason_code
                     SUBSTR ('0000000000',
                             0,
                             3 - LENGTH (TO_CHAR (v_outlet_location)))
                  || TO_CHAR (v_outlet_location),
                  v_ekipman_tipi,
                  NULL,                                    --ekipman_kutu_tipi
                  rec_kontrat_ekipman.modul_tipi,
                  rec_kontrat_ekipman.modul_seri_no,
                  --serial_number
                  v_teknisyen_kodu,
                  SYSDATE,                                    --kurulum_tarihi
                  'Yeni sözlesme girisi',
                  --aciklama
                  v_giren_kullanici,
                  SYSDATE,                                      --islem_tarihi
                  'N',                                  --kontratsiz aktifleme
                  'N',                                              --otel mi?
                  v_sozlesme_no,
                  v_ts_sifre_id,
                  v_its_kayit_no,
                  NULL,                                           --ts_form_no
                  v_eq_id,
                  v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := 'EKIPMAN_EKLE_MODUL:' || v_sonuc;
                  RETURN;
               END IF;
            END IF;

            -- kutu datasi girisi
            IF LTRIM (rec_kontrat_ekipman.kutu_seri_no) IS NOT NULL
            THEN
               v_count := -1;

               IF v_sozlesme_stb_tipi = 'LG'
               THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM wiz_equip
                   WHERE serial_number = rec_kontrat_ekipman.kutu_seri_no;
               END IF;

               IF v_count > 0 OR v_count = -1
               THEN
                  --  LG brandine sahip ekipmanlarin bizim stoklarimizda ise ekipman ekle ile çalismasi saglanir,
                  --  diger brandler için kosulsuz bu çagrilir . Önemli not: diger brandler için kutu bilgisi takibi sadece wiz_equip üzerinden oldu.
                  IF rec_kontrat_ekipman.kutu_seri_no IS NOT NULL
                  THEN
                     ekipman_pack.ekipman_ekle (
                        v_uye_no,
                        rec_kontrat_ekipman.kutu_seri_no,
                           SUBSTR ('0000000000',
                                   0,
                                   3 - LENGTH (TO_CHAR (v_outlet_location)))
                        || TO_CHAR (v_outlet_location),
                        v_teknisyen_kodu,
                        NULL,                                     --ts_form_no
                        v_paramyko,                              --reason_code
                        '',                                           --depoya
                        v_service_address_id,
                        'N',                            --kontratsiz aktifleme
                        'N',                                         --otel mi
                        v_giren_kullanici,
                        v_its_kayit_no,
                        v_ts_sifre_id,
                        v_sozlesme_no,
                        'Yeni sözlesme girisi',
                        v_sonuc,
                        v_proc_name,
                        v_is_emri_no,
                        v_error_type,
                        v_error_code,
                        v_error_text);
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'EKIPMAN_EKLE_STB:' || v_error_text;
                     RETURN;
                  END IF;
               ELSE
                  SELECT id
                    INTO v_ekipman_tipi
                    FROM vv_ekipman_tipleri
                   WHERE aciklama = 'DİGİKUTU';

                  IF rec_kontrat_ekipman.kutu_tipi IS NOT NULL
                  THEN
                     eq_ekipman_pack.eq_ekipman_ekle (
                        v_uye_no,
                        v_paramyko,                              --reason_code
                           SUBSTR ('0000000000',
                                   0,
                                   3 - LENGTH (TO_CHAR (v_outlet_location)))
                        || TO_CHAR (v_outlet_location),
                        v_ekipman_tipi,
                        -- bu ayrim kutu, modüli kart ayriimini tutmaktadir.
                        rec_kontrat_ekipman.kutu_tipi,
                        -- bu ayrim ise kutu ise ne marka bir kutu oldugunu belirtir. ör: sunny
                        NULL,
                        rec_kontrat_ekipman.kutu_seri_no,
                        --serial_number
                        v_teknisyen_kodu,
                        SYSDATE,                              --kurulum_tarihi
                        'Yeni sözlesme girisi',
                        --aciklama
                        v_giren_kullanici,
                        SYSDATE,                                --islem_tarihi
                        'N',                            --kontratsiz aktifleme
                        'N',                                        --otel mi?
                        v_sozlesme_no,
                        v_ts_sifre_id,
                        v_its_kayit_no,
                        NULL,
                        v_eq_id,
                        v_sonuc);
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'EKIPMAN_EKLE_STB:' || v_sonuc;
                     RETURN;
                  END IF;
               END IF;
            END IF;

            /*Harddisk datalari giriliyor - MKECECI -- 10.10.2012 */
            IF rec_kontrat_ekipman.harddisk_seri_no IS NOT NULL
            THEN
               SELECT id
                 INTO v_ekipman_tipi
                 FROM vv_ekipman_tipleri
                WHERE aciklama = 'HARDDİSK';

               SELECT e.ekipman_modul_tipi
                 INTO v_ekipman_harddisk_tipi
                 FROM eq_ekipman e
                WHERE e.serial_number =
                         TRIM (rec_kontrat_ekipman.harddisk_seri_no);

               eq_ekipman_pack.eq_ekipman_ekle (
                  v_uye_no,
                  v_paramyko,                                    --reason_code
                     SUBSTR ('0000000000',
                             0,
                             3 - LENGTH (TO_CHAR (v_outlet_location)))
                  || TO_CHAR (v_outlet_location),
                  v_ekipman_tipi,
                  NULL,                                    --ekipman_kutu_tipi
                  v_ekipman_harddisk_tipi,
                  rec_kontrat_ekipman.harddisk_seri_no,
                  --serial_number
                  v_teknisyen_kodu,
                  SYSDATE,                                    --kurulum_tarihi
                  'Yeni sözlesme girisi',
                  --aciklama
                  v_giren_kullanici,
                  SYSDATE,                                      --islem_tarihi
                  'N',                                  --kontratsiz aktifleme
                  'N',                                              --otel mi?
                  v_sozlesme_no,
                  v_ts_sifre_id,
                  v_its_kayit_no,
                  NULL,                                           --ts_form_no
                  v_eq_id,
                  v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := 'EKIPMAN_EKLE_HDD:' || v_sonuc;
                  RETURN;
               END IF;
            END IF;

            /*10.10.2012 -- MKECECI -- </end>*/

            /*Modem datalari girisi  -- MKECECI -- 13.11.2012 */
            IF rec_kontrat_ekipman.modem_seri_no IS NOT NULL
            THEN
               SELECT x.ekipman_tipi
                 INTO v_ekipman_modem_tipi
                 FROM eq_ekipman x
                WHERE x.serial_number = rec_kontrat_ekipman.modem_seri_no;

               eq_ekipman_pack.eq_ekipman_ekle (
                  v_uye_no,
                  v_paramyko,                                    --reason_code
                     SUBSTR ('0000000000',
                             0,
                             3 - LENGTH (TO_CHAR (v_outlet_location)))
                  || TO_CHAR (v_outlet_location),
                  v_ekipman_tipi,
                  NULL,                                    --ekipman_kutu_tipi
                  rec_kontrat_ekipman.modem_seri_no,
                  v_ekipman_modem_tipi,
                  --serial_number
                  v_teknisyen_kodu,
                  SYSDATE,                                    --kurulum_tarihi
                  'Yeni sözlesme girisi',
                  --aciklama
                  v_giren_kullanici,
                  SYSDATE,                                      --islem_tarihi
                  'N',                                  --kontratsiz aktifleme
                  'N',                                              --otel mi?
                  v_sozlesme_no,
                  v_ts_sifre_id,
                  v_its_kayit_no,
                  NULL,                                           --ts_form_no
                  v_eq_id,
                  v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := 'EKIPMAN_EKLE_MODEM:' || v_sonuc;
                  RETURN;
               END IF;
            END IF;

            /*</end> -----MKECECI -------*/

            IF v_kon_gel_tipi = TRIM (v_gelis_kod)
            THEN
               IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
               THEN
                  addressability_pack.pin_kodu_sifirlama (
                     rec_kontrat_ekipman.kart_seri_no,
                     v_giren_kullanici,
                     v_sonuc);
               END IF;
            END IF;

            v_outlet_location := v_outlet_location + 1;
         END LOOP;
      END IF;

      -- fatura adres bilgisini insert et
      -- *** 24.08.2005
      -- *** Kontrat isleminde fatura adresi olusturma islemi kaldirildi.
      /*
            v_count := NULL;

            IF v_fatura_ayni_kalsin_flag IS NULL
            THEN
               BEGIN
                  SELECT full_name
                    INTO v_full_name
                    FROM wiz_customer_bill_to
                   WHERE account_number = v_uye_no; -- AND adres_kaynak = 'FATURA'; --27.06.2005 Yusuf Ayvaz Fatura adres viewdan kontrol
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_full_name := v_fatura_sirket_adi;
               END;

               SELECT COUNT(*) --DECODE(adres_kaynak,'FATURA',1,0) --27.06.2005 Yusuf Ayvaz Fatura adres viewdan kontrol
                 INTO v_count
                 FROM wiz_customer_bill_to
                WHERE account_number = v_uye_no;

               IF RTRIM (v_fatura_sirket_adi) IS NOT NULL
               THEN
                  IF LENGTH (RTRIM (v_fatura_sirket_adi)) >= 4
                  THEN
                     v_fatura_name := RTRIM (v_fatura_sirket_adi);
                  ELSE
                     v_fatura_name := v_full_name;
                  END IF;
               ELSIF v_sozlesme_tipi = '2'
               THEN
                  v_fatura_name :=
                         SUBSTR ((v_is_yeri_yetkilisi_1 || ' ' || v_soyad), 1, 65);
               ELSE
                  v_fatura_name := SUBSTR (v_ad || ' ' || v_soyad, 1, 65);
               END IF;

               IF v_fatura_adresi_yarat
               THEN
                  IF v_count = 0
                  THEN
                     Abone_Detay_Pack.billing_address_insert (v_uye_no,
                                                              v_fatura_name,
                                                              v_adr_1,
                                                              v_adr_2,
                                                              v_adr_3,
                                                              v_semt,
                                                              v_ilce,
                                                              v_il,
                                                              v_posta,
                                                              v_giren_kullanici,
                                                              v_sonuc
                                                             );
                  ELSE
                     Abone_Detay_Pack.billing_address_update (v_uye_no,
                                                              v_fatura_name,
                                                              v_adr_1,
                                                              v_adr_2,
                                                              v_adr_3,
                                                              v_semt,
                                                              v_ilce,
                                                              v_il,
                                                              v_posta,
                                                              v_giren_kullanici,
                                                              v_sonuc
                                                             );
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'ADRES' || v_sonuc || v_adr_1 || v_adr_2 || v_adr_3;
                     RETURN;
                  END IF;
               END IF;
            END IF;
           */
      IF v_sozlesme_tipi = '2' AND LTRIM (v_ruhsat_verilme_ili) IS NOT NULL
      THEN
         BEGIN
            IF LENGTH (v_ruhsat_verilme_ili) = 2
            THEN
               SELECT ad
                 INTO v_ruhsat_verilme_ili_ad
                 FROM co_il
                WHERE kod = '0' || v_ruhsat_verilme_ili;
            ELSE
               SELECT ad
                 INTO v_ruhsat_verilme_ili_ad
                 FROM co_il
                WHERE kod = v_ruhsat_verilme_ili;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_sonuc := 'IL KODU BULUNAMADI';
               durum := v_sonuc;
               RETURN;
            WHEN TOO_MANY_ROWS
            THEN
               v_sonuc := 'AYNI ILE AIT BIRDEN FAZLA KAYIT VAR';
               durum := v_sonuc;
               RETURN;
         END;
      END IF;

      v_count := NULL;

      SELECT COUNT (1)
        INTO v_count
        FROM mb_abone_detay_bilgi
       WHERE account_number = v_uye_no;

      IF v_count = 0
      THEN
         IF v_sozlesme_tipi = '1'
         THEN
            abone_detay_pack.mb_abone_detay_bilgi_insert (
               v_sozlesme_tipi,
               v_uye_no,
               v_anne_kizlik_soyad,
               v_vergi_dairesi,
               v_vergi_no,
               SUBSTR (v_dogum_yeri, 1, 30),
               v_dogum_tarihi,
               v_meslek_id,
               v_meslek,
               v_tuttugu_takim_kodu,
               v_giren_kullanici,
               v_tabiyet,
               v_baba_adi,
               v_is_yeri_yetkilisi_1,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               v_sonuc,
               NULL,
               NULL,
               v_anne_adi,
               v_nufusa_kayitli_ili,
               v_nufusa_kayitli_ilcesi,
               v_vatandaslikno,               ---NULL, TODO: Bunu kontrol et..
               v_daire_sayisi,
               v_ciltno,
               v_ailesirano,
               v_sirano,
               NULL,
               ivatno_required);
         ELSE
            abone_detay_pack.mb_abone_detay_bilgi_insert (
               v_sozlesme_tipi,
               v_uye_no,
               NULL,
               v_vergi_dairesi,
               v_vergi_no,
               NULL,
               NULL,
               NULL,
               NULL,
               v_tuttugu_takim_kodu,
               v_giren_kullanici,
               v_tabiyet,
               NULL,
               v_is_yeri_yetkilisi_1,
               v_ruhsat_yeri_id,
               v_ruhsat_tarihi,
               v_ruhsat_verilme_ili_ad,
               v_ruhsat_sicil_no,
               v_ruhsat_belediye,
               v_dwelling_type,
               v_sonuc,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               v_vatandaslikno,
               v_daire_sayisi,
               v_ciltno,
               v_ailesirano,
               v_sirano,
               v_rf_mdu_tipi,
               'H');
         END IF;
      ELSE
         IF v_sozlesme_tipi = '1'
         THEN
            SELECT daire_sayisi
              INTO v_oda_sayisi
              FROM mb_abone_detay_bilgi
             WHERE account_number = v_uye_no;

            abone_detay_pack.mb_abone_detay_bilgi_update (
               v_sozlesme_tipi,
               v_uye_no,
               v_anne_kizlik_soyad,
               v_vergi_dairesi,
               v_vergi_no,
               SUBSTR (v_dogum_yeri, 1, 30),
               v_dogum_tarihi,
               v_meslek_id,
               v_meslek,
               v_tuttugu_takim_kodu,
               v_giren_kullanici,
               v_tabiyet,
               v_baba_adi,
               v_is_yeri_yetkilisi_1,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               v_sonuc,
               NULL,
               NULL,
               v_anne_adi,
               v_nufusa_kayitli_ili,
               v_nufusa_kayitli_ilcesi,
               v_vatandaslikno,
               v_oda_sayisi,
               v_ciltno,
               v_ailesirano,
               v_sirano,
               NULL,
               ivatno_required);
         ELSE
            abone_detay_pack.mb_abone_detay_bilgi_update (
               v_sozlesme_tipi,
               v_uye_no,
               NULL,
               v_vergi_dairesi,
               v_vergi_no,
               NULL,
               NULL,
               NULL,
               NULL,
               v_tuttugu_takim_kodu,
               v_giren_kullanici,
               v_tabiyet,
               NULL,
               v_is_yeri_yetkilisi_1,
               v_ruhsat_yeri_id,
               v_ruhsat_tarihi,
               v_ruhsat_verilme_ili_ad,
               v_ruhsat_sicil_no,
               v_ruhsat_belediye,
               v_dwelling_type,
               v_sonuc,
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               v_rf_mdu_tipi,
               v_vatandaslikno,
               v_daire_sayisi,
               NULL,
               NULL,
               v_rf_mdu_tipi,
               'H');
         END IF;
      END IF;

      IF v_sonuc <> '0'
      THEN
         durum := v_sonuc;
         RETURN;
      END IF;

      IF v_sozlesme_tipi <> '5'
      THEN
         insert_dpaccountno (v_uye_no,
                             v_sozlesme_no,
                             ioutlet_location,
                             v_bayi_kodu,
                             v_sozlesme_tarihi,
                             v_servis_tarihi,
                             v_wiz_operator_id,
                             v_kon_gel_tipi,
                             v_mdu_bu_ceki,
                             v_campaign_code,
                             v_potansiyel_is_emri_id,
                             v_sonuc,
                             v_sozlesme_stb_tipi,
                             v_yk_dp_kontrat_id,
                             NULL);

         IF v_sonuc <> '0'
         THEN
            durum := 'INSERT_DPACCOUNTNO1 :' || v_sonuc;
            RETURN;
         END IF;

         --bill accçolustur
         /* Begin ITTP Integration - MGOKSU*/
         BEGIN
            billing_dbs_int.onl_customer_ittp_pkg.account_crt_sp (
               i_dbs_account_number   => v_uye_no,
               o_result_type          => v_result_type,
               o_result_code          => v_result_code,
               o_result_message       => v_result_message);

            IF v_result_type = 1
            THEN
               durum := v_result_code || ':' || v_result_message;
               RETURN;
            END IF;
         END;

         /* End ITTP Integration */

         sms_yeni_kontrat_pack.mb_outlet_takip_insert (v_uye_no,
                                                       v_is_emri_no,
                                                       ioutlet_location,
                                                       v_paramyko,
                                                       v_giren_kullanici,
                                                       v_sonuc);

         IF v_sonuc <> '0'
         THEN
            durum := 'MB_OUTLET_TAKIP_INSERT' || v_sonuc;
            RETURN;
         END IF;

         --servis acc olustur
         /* Begin ITTP Integration - MGOKSU*/
         BEGIN
            billing_dbs_int.onl_customer_ittp_pkg.outlet_crt_sp (
               i_dbs_account_number    => v_uye_no,
               i_dbs_outlet_location   => ioutlet_location,
               i_sozlesme_no           => v_sozlesme_no,
               o_result_type           => v_result_type,
               o_result_code           => v_result_code,
               o_result_message        => v_result_message);

            IF v_result_type = 1
            THEN
               durum := v_result_code || ':' || v_result_message;
               RETURN;
            END IF;
         END;
      /* End ITTP Integration */
      ELSE
         v_outlet_location := TO_NUMBER (ioutlet_location);
         insert_dpaccountno (v_uye_no,
                             v_sozlesme_no,
                             ioutlet_location,
                             v_bayi_kodu,
                             v_sozlesme_tarihi,
                             v_servis_tarihi,
                             v_wiz_operator_id,
                             v_kon_gel_tipi,
                             v_mdu_bu_ceki,
                             v_campaign_code,
                             v_potansiyel_is_emri_id,
                             v_sonuc,
                             v_sozlesme_stb_tipi,
                             v_yk_dp_kontrat_id,
                             NULL);

         IF v_sonuc <> '0'
         THEN
            durum := 'INSERT_DPACCOUNTNO2 :' || v_sonuc;
            RETURN;
         END IF;

         --bill accçolustur
         /* Begin ITTP Integration - MGOKSU*/
         BEGIN
            billing_dbs_int.onl_customer_ittp_pkg.account_crt_sp (
               i_dbs_account_number   => v_uye_no,
               o_result_type          => v_result_type,
               o_result_code          => v_result_code,
               o_result_message       => v_result_message);

            IF v_result_type = 1
            THEN
               durum := v_result_code || ':' || v_result_message;
               RETURN;
            END IF;
         END;

         /* End ITTP Integration */
         FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
         LOOP
            sms_yeni_kontrat_pack.mb_outlet_takip_insert (
               v_uye_no,
               v_is_emri_no,
                  SUBSTR ('0000000000',
                          0,
                          3 - LENGTH (TO_CHAR (v_outlet_location)))
               || TO_CHAR (v_outlet_location),
               v_paramyko,
               v_giren_kullanici,
               v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := 'MB_OUTLET_TAKIP_INSERT' || v_sonuc;
               RETURN;
            END IF;

            --servis acc olustur
            /* Begin ITTP Integration - MGOKSU*/
            BEGIN
               billing_dbs_int.onl_customer_ittp_pkg.outlet_crt_sp (
                  i_dbs_account_number    => v_uye_no,
                  i_dbs_outlet_location   => ioutlet_location,
                  i_sozlesme_no           => v_sozlesme_no,
                  o_result_type           => v_result_type,
                  o_result_code           => v_result_code,
                  o_result_message        => v_result_message);

               IF v_result_type = 1
               THEN
                  durum := v_result_code || ':' || v_result_message;
                  RETURN;
               END IF;
            END;

            /* End ITTP Integration */
            v_outlet_location := v_outlet_location + 1;
         END LOOP;
      END IF;

      /* --- Begin --- ITTP Integration --- Evren ---*/
      FOR rec_ IN (SELECT id
                     FROM mb_abone_email
                    WHERE account_number = v_uye_no AND email = v_email)
      LOOP
         billing_dbs_int.onl_account_ittp_pkg.mb_abone_email_sv_sp (
            i_mb_abone_email_id   => rec_.id,
            i_dbs_kullanici       => v_giren_kullanici,
            o_result_type         => v_result_type,
            o_result_code         => v_result_code,
            o_result_message      => v_result_message);

         IF v_result_type = 1
         THEN
            durum := v_result_code || ':' || v_result_message;
            RETURN;
         END IF;
      END LOOP;

      /* --- End --- ITTP Integration --- Evren ---*/

      /* --- Begin --- ITTP Integration --- Evren ---*/
      FOR rec_ IN (SELECT id, giren_kullanici
                     FROM mb_abone_telefon
                    WHERE account_number = v_uye_no --AND telefon_no IN (phomephone,pmobilephone)
                                                   )
      LOOP
         billing_dbs_int.onl_account_ittp_pkg.mb_abone_telefon_sv_sp (
            i_mb_abone_telefon_id   => rec_.id,
            i_dbs_kullanici         => rec_.giren_kullanici,
            o_result_type           => v_result_type,
            o_result_code           => v_result_code,
            o_result_message        => v_result_message);

         IF v_result_type = 1
         THEN
            durum := v_result_code || ':' || v_result_message;
            RETURN;
         END IF;
      END LOOP;

      /* --- End --- ITTP Integration --- Evren ---*/

      /* Begin ITTP Integration - MGOKSU*/
      --      BEGIN
      --         billing_dbs_int.onl_merge_ittp_pkg.merge_prospect_account (i_account_number       => v_uye_no,
      --                                                                    i_prospect_number      => v_prospect_number,
      --                                                                    o_result_type          => v_result_type,
      --                                                                    o_result_code          => v_result_code,
      --                                                                    o_result_message       => v_result_message
      --                                                                   );

      --         IF v_result_type = 1
      --         THEN
      --            durum := v_result_code || ':' || v_result_message;
      --            RETURN;
      --         END IF;
      --      END;

      /* End ITTP Integration */

      -- *** 24.08.2005
      -- *** Kontrat isleminde fatura adresi olusturma islemi kaldirildi.
      IF LTRIM (v_kk_no) IS NOT NULL
      THEN
         IF v_guvenlik_kodu IS NULL
         THEN
            v_guvenlik_kodu := '   ';
         END IF;

         v_count := NULL;

         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_debit_auth
          WHERE account_number = v_uye_no;

         IF v_count = 0
         THEN
            IF v_sozlesme_tipi = '1'
            THEN
               abone_detay_pack.hp_debit_auth_insert (
                  v_uye_no,
                  v_service_address_id,
                  v_wiz_operator_id,
                  TO_CHAR (
                     NVL (v_kk_son_tarihi, TO_DATE ('01.2100', 'MM.YYYY')),
                     'mm.yyyy'),
                  '0',
                  v_kk_tipi,
                  v_kk_no,
                  SUBSTR (v_ad || ' ' || v_soyad, 1, 65),
                  v_giren_kullanici,
                  v_guvenlik_kodu,
                  v_sonuc,
                  v_debit_method);
            ELSE
               abone_detay_pack.hp_debit_auth_insert (
                  v_uye_no,
                  v_service_address_id,
                  v_wiz_operator_id,
                  TO_CHAR (
                     NVL (v_kk_son_tarihi, TO_DATE ('01.2100', 'MM.YYYY')),
                     'mm.yyyy'),
                  '0',
                  v_kk_tipi,
                  v_kk_no,
                  v_ad,
                  v_giren_kullanici,
                  v_guvenlik_kodu,
                  v_sonuc,
                  v_debit_method);
            END IF;
         ELSE
            IF v_sozlesme_tipi = '1'
            THEN
               abone_detay_pack.hp_debit_auth_update (
                  v_uye_no,
                  v_wiz_operator_id,
                  TO_CHAR (
                     NVL (v_kk_son_tarihi, TO_DATE ('01.2100', 'MM.YYYY')),
                     'mm.yyyy'),
                  '0',
                  v_kk_tipi,
                  v_kk_no,
                  SUBSTR (v_ad || ' ' || v_soyad, 1, 65),
                  v_giren_kullanici,
                  v_guvenlik_kodu,
                  v_sonuc);
            ELSE
               abone_detay_pack.hp_debit_auth_update (
                  v_uye_no,
                  v_wiz_operator_id,
                  TO_CHAR (
                     NVL (v_kk_son_tarihi, TO_DATE ('01.2100', 'MM.YYYY')),
                     'mm.yyyy'),
                  '0',
                  v_kk_tipi,
                  v_kk_no,
                  v_ad,
                  v_giren_kullanici,
                  v_guvenlik_kodu,
                  v_sonuc);
            END IF;
         END IF;

         IF v_sonuc <> '0'
         THEN
            durum := 'HP_DEBIT_AUTH_UPDATE' || v_sonuc;
            RETURN;
         END IF;
      END IF;

      v_count := NULL;

      SELECT COUNT (1)
        INTO v_count
        FROM ad_adres_detay_bilgi
       WHERE building_id = v_building_id;

      IF v_yeni_mdu_no IS NULL
      THEN
         v_yeni_mdu_no := v_eski_mdu_no;
      END IF;

      IF v_count = 0
      THEN
         sms_yeni_kontrat_pack.ad_adres_detay_bilgi_insert (
            v_building_id,
            v_yeni_mdu_no,
            v_kat_sayisi,
            v_daire_sayisi,
            v_mdu_ceki,
            v_bayi_kodu,
            v_paramyko,
            'YENI KONTRAT GIRISI-SYSTEM',
            v_giren_kullanici,
            v_mdu_sistem_no,
            v_mdu_yontem_no,
            v_sonuc);
      ELSE
         sms_yeni_kontrat_pack.ad_adres_detay_bilgi_update (
            v_building_id,
            v_yeni_mdu_no,
            v_kat_sayisi,
            v_daire_sayisi,
            v_mdu_ceki,
            v_bayi_kodu,
            v_paramyko,
            'YENI KONTRAT GIRISI-SYSTEM',
            v_giren_kullanici,
            v_mdu_sistem_no,
            v_mdu_yontem_no,
            '2',
            v_sonuc);
      END IF;

      IF v_sonuc <> '0'
      THEN
         durum := 'AD_ADRES_DETAY_BILGI_UPDATE' || v_sonuc;
         RETURN;
      END IF;

      IF v_sozlesme_tipi <> '5'
      THEN
         work_order_pack.close_wo (v_is_emri_no,
                                   NULL,
                                   ioutlet_location,
                                   NULL,
                                   NULL,
                                   NULL,
                                   SYSDATE,
                                   v_giren_kullanici,
                                   v_uyari_mesaji,
                                   v_sonuc);

         IF v_sonuc <> '0'
         THEN
            durum := 'CLOSE_WO' || v_sonuc;
            RETURN;
         END IF;

         UPDATE yk_dp_kontrat
            SET uye_no = v_uye_no,
                outlet_location = ioutlet_location,
                is_emri_no = v_is_emri_no,
                service_address_id = v_service_address_id
          WHERE sozlesme_no = v_sozlesme_no;

         abone_outlet_statu_pack.outlet_statu_update (v_uye_no,
                                                      ioutlet_location,
                                                      igiren_kullanici,
                                                      SYSDATE,
                                                      p_statu,
                                                      p_eski_statu,
                                                      p_detay_statu,
                                                      p_return_status);

         IF p_return_status <> '0'
         THEN
            durum := 'ABONE STATU PROBLEMI ' || p_return_status;
            RETURN;
         END IF;

         IF TRIM (v_abone_ozellik_kodu) IS NOT NULL
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM mb_abone_ozellik
             WHERE     abone_ozellik_kodu = v_abone_ozellik_kodu
                   AND account_number = v_uye_no;

            IF v_count = 0
            THEN
               abone_detay_pack.mb_abone_ozellik_insert (
                  v_uye_no,
                  ioutlet_location,
                  v_abone_ozellik_kodu,
                  v_giren_kullanici,
                  durum);

               IF durum <> '0'
               THEN
                  durum := 'ABONE_OZELLIK_INSERT' || durum;
                  RETURN;
               END IF;
            END IF;

            /*Mesut Keçecioglu - bayi gruplarinin kontrolü 24.05.2012*/
            SELECT COUNT (1)
              INTO v_count
              FROM bt_bayi_ozellik x, pr_abone_ozellik y
             WHERE     x.bayi_ozellik_kodu = y.kod
                   AND x.sales_agent_code = v_bayi_kodu
                   AND y.kod_grubu = 1;

            IF v_count > 0
            THEN
               SELECT COUNT (1) --Girilen özellik Kod grubu=1 özelligi mi diye kontrol ediliyor
                 INTO v_count
                 FROM pr_abone_ozellik pr
                WHERE pr.kod = v_abone_ozellik_kodu AND pr.kod_grubu = 1;

               IF v_count > 0
               THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM bt_bayi_ozellik x
                   WHERE     x.bayi_ozellik_kodu = v_abone_ozellik_kodu
                         AND x.sales_agent_code = v_bayi_kodu;

                  IF v_count = 0
                  THEN
                     SELECT x1.aciklama
                       INTO v_abone_ozellik_aciklama
                       FROM pr_abone_ozellik x1
                      WHERE x1.kod = v_abone_ozellik_kodu;

                     durum :=
                           v_abone_ozellik_aciklama
                        || ' grubundan islem yapma yetkiniz yoktur ';
                     RETURN;
                  END IF;
               END IF;
            END IF;
         /*Mesut Keçecioglu - bayi gruplarinin kontrolü*/
         END IF;
      ELSE
         v_outlet_location := TO_NUMBER (ioutlet_location);

         FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
         LOOP
            work_order_pack.close_wo (
               v_is_emri_no,
               NULL,
                  SUBSTR ('0000000000',
                          0,
                          3 - LENGTH (TO_CHAR (v_outlet_location)))
               || TO_CHAR (v_outlet_location),
               NULL,
               NULL,
               NULL,
               SYSDATE,
               v_giren_kullanici,
               v_uyari_mesaji,
               v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := 'CLOSE_WO' || v_sonuc;
               RETURN;
            END IF;

            UPDATE yk_dp_kontrat
               SET uye_no = v_uye_no,
                   outlet_location = ioutlet_location,
                   is_emri_no = v_is_emri_no,
                   service_address_id = v_service_address_id
             WHERE sozlesme_no = v_sozlesme_no;

            abone_outlet_statu_pack.outlet_statu_update (
               v_uye_no,
                  SUBSTR ('0000000000',
                          0,
                          3 - LENGTH (TO_CHAR (v_outlet_location)))
               || TO_CHAR (v_outlet_location),
               igiren_kullanici,
               SYSDATE,
               p_statu,
               p_eski_statu,
               p_detay_statu,
               p_return_status);

            IF p_return_status <> '0'
            THEN
               durum := 'ABONE STATU PROBLEMI ' || p_return_status;
               RETURN;
            END IF;

            IF TRIM (v_abone_ozellik_kodu) IS NOT NULL
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM mb_abone_ozellik
                WHERE     abone_ozellik_kodu = v_abone_ozellik_kodu
                      AND account_number = v_uye_no;

               IF v_count = 0
               THEN
                  abone_detay_pack.mb_abone_ozellik_insert (
                     v_uye_no,
                        SUBSTR ('0000000000',
                                0,
                                3 - LENGTH (TO_CHAR (v_outlet_location)))
                     || TO_CHAR (v_outlet_location),
                     v_abone_ozellik_kodu,
                     v_giren_kullanici,
                     durum);

                  IF durum <> '0'
                  THEN
                     durum := 'ABONE_OZELLIK_INSERT' || durum;
                     RETURN;
                  END IF;
               END IF;

               /*Mesut Keçecioglu - bayi gruplarinin kontrolü 24.05.2012*/
               SELECT COUNT (1)
                 INTO v_count
                 FROM bt_bayi_ozellik x, pr_abone_ozellik y
                WHERE     x.bayi_ozellik_kodu = y.kod
                      AND x.sales_agent_code = v_bayi_kodu
                      AND y.kod_grubu = 1;

               IF v_count > 0
               THEN
                  SELECT COUNT (1) --Girilen özellik Kod grubu=1 özelligi mi diye kontrol ediliyor
                    INTO v_count
                    FROM pr_abone_ozellik pr
                   WHERE pr.kod = v_abone_ozellik_kodu AND pr.kod_grubu = 1;

                  IF v_count > 0
                  THEN
                     SELECT COUNT (1)
                       INTO v_count
                       FROM bt_bayi_ozellik x
                      WHERE     x.bayi_ozellik_kodu = v_abone_ozellik_kodu
                            AND x.sales_agent_code = v_bayi_kodu;

                     IF v_count = 0
                     THEN
                        SELECT x1.aciklama
                          INTO v_abone_ozellik_aciklama
                          FROM pr_abone_ozellik x1
                         WHERE x1.kod = v_abone_ozellik_kodu;

                        durum :=
                              v_abone_ozellik_aciklama
                           || ' grubundan islem yapma yetkiniz yoktur ';
                        RETURN;
                     END IF;
                  END IF;
               END IF;
            /*Mesut Keçecioglu - bayi gruplarinin kontrolü*/
            END IF;

            v_outlet_location := v_outlet_location + 1;
         END LOOP;
      END IF;

      IF v_sozlesme_tipi <> '5'
      THEN
         log_pack.lg_abone_islem_takip_insert (
            v_uye_no,
            v_sozlesme_no || ',' || ioutlet_location,
            v_sc_seri_no,
            '27',
            v_giren_kullanici,
            v_sonuc);

         IF v_sonuc <> '0'
         THEN
            durum := 'LG_ABONE_ISLEM_TAKIP_INSERT' || v_sonuc;
            RETURN;
         END IF;
      ELSE
         v_outlet_location := TO_NUMBER (ioutlet_location);

         FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
         LOOP
            IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
            THEN
               log_pack.lg_abone_islem_takip_insert (
                  v_uye_no,
                     v_sozlesme_no
                  || ','
                  || SUBSTR ('0000000000',
                             0,
                             3 - LENGTH (TO_CHAR (v_outlet_location)))
                  || TO_CHAR (v_outlet_location),
                  rec_kontrat_ekipman.kart_seri_no,
                  '27',
                  v_giren_kullanici,
                  v_sonuc);
            END IF;

            IF v_sonuc <> '0'
            THEN
               durum := 'LG_ABONE_ISLEM_TAKIP_INSERT' || v_sonuc;
               RETURN;
            END IF;

            v_outlet_location := v_outlet_location + 1;
         END LOOP;
      END IF;

      --HDD için kitle kontrolü yapilmiyor
      ouye_no := v_uye_no;
      -- Kontrat kampanya için kitle kontrolü
      v_kitle_durum := '1';                                   --UYGUN DEGILDIR
      v_kitle_durum :=
         kitle_pack.kitleye_uygun_mu (
            NULL,                                           --UST_KAMPANYA_KOD
            icampaign_code,                                    --KAMPANYA_KODU
            NULL,                                                --SERVIS_KODU
            NULL,                                            --SERVIS_FREKANSI
            ouye_no,                                          --ACCOUNT_NUMBER
            LPAD (TO_CHAR (v_outlet_location), 3, '0'),
            --OUTLET_LOCATION
            NULL,                                            --PROSPECT_NUMBER
            NVL (v_md_ekipman_tip_matrix_id, v_st_ekipman_tip_matrix_id),
            --MATRIX_ID  -- Falamur 05102010
            NVL (v_modul_seri_no, v_stb_seri_no),
            -- null yerine;kutu,modul seri no   --SERIAL_NUMBER
            iuye_tipi,
            v_sozlesme_stb_tipi,
            ifranchise_code,
            SYSDATE,                                                   --TARIH
            igiren_kullanici,                                      --KULLANICI
            NULL,                                                  --TEKLIF_ID
            2                                                        --KONTRAT
             );

      IF v_kitle_durum <> '0'
      THEN
         --Kitlenin neden uymadigini döndürüyor.MKECECI
         --durum :=
         --   icampaign_code
         --   || ' Kontrat Kampanya kitlesi bu abone için uygun degildir!';
         durum := v_kitle_durum;
         RETURN;
      END IF;

      -- satis yapilabilirmi...
      IF satis_kontrolu (isozlesme_no,
                         igiren_kullanici,
                         iprospect_number,
                         durum) = 0
      THEN
         RETURN;
      END IF;

      IF v_potansiyel_is_emri_id IS NOT NULL
      THEN
         OPEN d2d_cur;

         FETCH d2d_cur INTO d2d_rec;

         IF d2d_cur%NOTFOUND
         THEN
            durum := 'POTANSIYEL TETIK KAYDI KAPATILAMADI.';
            RETURN;
         ELSE
            UPDATE ie_potansiyel_is_emri
               SET durum = 'P',
                   account_number = ouye_no,
                   degistiren_kullanici = v_giren_kullanici,
                   degistirme_tarihi = SYSDATE,
                   tam_kapanma_tarihi = SYSDATE
             WHERE CURRENT OF d2d_cur;

            INSERT INTO lg_potansiyel_is_emri (id,
                                               islem,
                                               kisi,
                                               tarih,
                                               potansiyel_is_emri_id,
                                               account_number,
                                               prospect_number,
                                               kisi_tipi,
                                               islem_tipi,
                                               service_address_id,
                                               yeni_service_address_id,
                                               sc_serial_number,
                                               st_serial_number,
                                               yeni_sc_serial_number,
                                               yeni_st_serial_number,
                                               service_code,
                                               campaign_code,
                                               promotion_code,
                                               durum,
                                               islem_tarihi,
                                               reason_code,
                                               sozlesme_no,
                                               sozlesme_kampanya,
                                               servis_frekansi,
                                               bayi_kodu,
                                               ekip_kodu,
                                               tahsilat_yapildi,
                                               aciklama,
                                               harddisk_seri_no)
                    VALUES (
                              lg_potansiyel_is_emri_id_seq.NEXTVAL,
                              'U',
                              v_giren_kullanici,
                              SYSDATE,
                              d2d_rec.id,
                              TRIM (ouye_no),
                              d2d_rec.prospect_number,
                              d2d_rec.kisi_tipi,
                              d2d_rec.islem_tipi,
                              d2d_rec.service_address_id,
                              d2d_rec.yeni_service_address_id,
                              d2d_rec.sc_serial_number,
                              d2d_rec.st_serial_number,
                              d2d_rec.yeni_sc_serial_number,
                              d2d_rec.yeni_st_serial_number,
                              d2d_rec.service_code,
                              d2d_rec.campaign_code,
                              d2d_rec.promotion_code,
                              'P',
                              d2d_rec.islem_tarihi,
                              d2d_rec.reason_code,
                              d2d_rec.sozlesme_no,
                              d2d_rec.sozlesme_kampanya,
                              d2d_rec.servis_frekansi,
                              d2d_rec.bayi_kodu,
                              d2d_rec.ekip_kodu,
                              d2d_rec.tahsilat_yapildi,
                                 TRIM (d2d_rec.aciklama)
                              || ' Sistem - Abone no güncellendi ve tetik sözlesme ile eslestiginde kapatildi.',
                              d2d_rec.harddisk_seri_no);

            FOR d2d_other_rec IN d2d_other_cur
            LOOP
               UPDATE ie_potansiyel_is_emri
                  SET account_number = ouye_no,
                      degistiren_kullanici = v_giren_kullanici,
                      degistirme_tarihi = SYSDATE
                WHERE id = d2d_other_rec.id;

               INSERT INTO lg_potansiyel_is_emri (id,
                                                  islem,
                                                  kisi,
                                                  tarih,
                                                  potansiyel_is_emri_id,
                                                  account_number,
                                                  prospect_number,
                                                  kisi_tipi,
                                                  islem_tipi,
                                                  service_address_id,
                                                  yeni_service_address_id,
                                                  sc_serial_number,
                                                  st_serial_number,
                                                  yeni_sc_serial_number,
                                                  yeni_st_serial_number,
                                                  service_code,
                                                  campaign_code,
                                                  promotion_code,
                                                  durum,
                                                  islem_tarihi,
                                                  reason_code,
                                                  sozlesme_no,
                                                  sozlesme_kampanya,
                                                  servis_frekansi,
                                                  bayi_kodu,
                                                  ekip_kodu,
                                                  tahsilat_yapildi,
                                                  aciklama,
                                                  harddisk_seri_no)
                       VALUES (
                                 lg_potansiyel_is_emri_id_seq.NEXTVAL,
                                 'U',
                                 v_giren_kullanici,
                                 SYSDATE,
                                 d2d_other_rec.id,
                                 TRIM (ouye_no),
                                 d2d_other_rec.prospect_number,
                                 d2d_other_rec.kisi_tipi,
                                 d2d_other_rec.islem_tipi,
                                 d2d_other_rec.service_address_id,
                                 d2d_other_rec.yeni_service_address_id,
                                 d2d_other_rec.sc_serial_number,
                                 d2d_other_rec.st_serial_number,
                                 d2d_other_rec.yeni_sc_serial_number,
                                 d2d_other_rec.yeni_st_serial_number,
                                 d2d_other_rec.service_code,
                                 d2d_other_rec.campaign_code,
                                 d2d_other_rec.promotion_code,
                                 d2d_other_rec.durum,
                                 d2d_other_rec.islem_tarihi,
                                 d2d_other_rec.reason_code,
                                 d2d_other_rec.sozlesme_no,
                                 d2d_other_rec.sozlesme_kampanya,
                                 d2d_other_rec.servis_frekansi,
                                 d2d_other_rec.bayi_kodu,
                                 d2d_other_rec.ekip_kodu,
                                 d2d_other_rec.tahsilat_yapildi,
                                    TRIM (d2d_other_rec.aciklama)
                                 || ' Sistem - Potansiyel silindigi için üye numarasi güncellendi',
                                 d2d_other_rec.harddisk_seri_no);
            END LOOP;

            IF d2d_rec.islem_tipi = 1
            THEN                                                  -- yurt disi
               potansiyel_is_emri_pack.lg_potansiyel_is_emri_det_save (
                  d2d_rec.id,
                  v_giren_kullanici,
                  'U',
                  v_sonuc);
               potansiyel_is_emri_pack.lg_potansiyel_is_emri_srv_save (
                  d2d_rec.id,
                  v_giren_kullanici,
                  'U',
                  v_sonuc);

               IF d2d_rec.prospect_number IS NOT NULL
               THEN
                  SELECT COUNT (1)
                    INTO prospect_count
                    FROM wiz_prospect_descrip
                   WHERE prospect_number = d2d_rec.prospect_number;

                  IF prospect_count = 1
                  THEN
                     UPDATE yk_dp_kontrat
                        SET prospect_number = d2d_rec.prospect_number
                      WHERE     sozlesme_no = v_sozlesme_no
                            AND prospect_number IS NULL;
                  END IF;
               END IF;
            END IF;
         END IF;

         CLOSE d2d_cur;

         -----------------------------------------------------------------------------
         -- begin ITTP
         -----------------------------------------------------------------------------
         -- Evrim Kayan, Subat 2012 , ITTP ödeme emri kapanmasi.
         -- ödeme emri kapanirken, UPS için collection kaydi olusur.
         -----------------------------------------------------------------------------
         billing_dbs_int.onl_order_dbs_pkg.close_payment_order (
            i_sozlesme_no   => isozlesme_no,
            i_tetik_id      => v_potansiyel_is_emri_id,
            o_durum         => durum);

         -----------------------------------------------------------------------------
         IF durum <> '0'
         THEN
            RETURN;
         END IF;

         -----------------------------------------------------------------------------
         -- Evrim Kayan, Subat 2012
         -- POTANSIYEL içni ITTP'de açilan bill_Account ile,  UYE için ITTP'de açilan bill_Account merge edilir. POT olan iptal edilir.
         -----------------------------------------------------------------------------
         billing_dbs_int.onl_prospect_ittp_pkg.tetik_pros_to_acc (
            i_tetik_id         => v_potansiyel_is_emri_id,
            i_account_number   => v_uye_no,
            o_result_type      => v_result_type,
            o_result_code      => v_result_code,
            o_result_message   => v_result_message);

         IF v_result_type = 1
         THEN
            durum := v_result_code || ':' || v_result_message;
            RETURN;
         END IF;

         -----------------------------------------------------------------------------
         -- Ekipmanlar için ITTP tarafinda PRODUCT olusur ve charging yapilir.
         -- DIGIPAKET bedeli, GONDERI bedeli için BI olusur ve  charging yapilir.
         -----------------------------------------------------------------------------
         billing_dbs_int.onl_order_dbs_pkg.yd_create_ittp_product (
            i_tetik_id          => v_potansiyel_is_emri_id,
            i_account_number    => v_uye_no,
            i_outlet_location   => ioutlet_location,
            o_durum             => durum);

         IF durum <> 0
         THEN
            durum := v_result_code || ':' || v_result_message;
            RETURN;
         END IF;
      -----------------------------------------------------------------------------
      -- end ittp
      -----------------------------------------------------------------------------
      END IF;


      SELECT COUNT (1)
        INTO v_count
        FROM wiz_campaign_codes c, yk_dp_kontrat y
       WHERE     c.campaign_code = y.campaign_code
             AND y.sozlesme_no = isozlesme_no
             AND c.campaign_sales_channel IN (2, 4);


      --  ozgur arslan van atamasin sorun icin koyuldu kaldirilcak
      dbs_dba.insert_tetik_debug ('KONTRAT_PACK',
                                  'SMS_OK çagrildi ve v_count =' || v_count,
                                  v_uye_no,
                                  v_potansiyel_is_emri_id);

      IF v_count > 0 AND v_franchise_code = 'F04'
      THEN
         billing_dbs_int.onl_order_dbs_pkg.assign_van (
            i_account_number   => v_uye_no,
            o_van              => v_van,
            o_durum            => durum);
         dbs_dba.insert_tetik_debug (
            'KONTRAT_PACK',
            'SMS_OK çagrildi ve durum= ' || v_durum,
            v_uye_no,
            v_potansiyel_is_emri_id);

         IF NVL (durum, 0) <> 0
         THEN
            RETURN;
         END IF;
      END IF;

      --      IF icheck_payment_order_status = 1
      --      THEN
      --         v_sonuc := '';
      --         fatura.yd_collection_pack.match_van (iprospect_number, ouye_no, v_sonuc, durum);

      --         IF durum <> '0'
      --         THEN
      --            RETURN;
      --         END IF;

      --         durum := '0';
      --         v_sonuc := '';
      ---- bayi borçlandir.. 26.01.2007 - YILMAZ SARIDEMIR. IBX0001197
      --         fatura.yd_payment_order_pack.ekipman_borclandir (isozlesme_no, igiren_kullanici, durum);

      --         IF durum <> '0'
      --         THEN
      --            RETURN;
      --         END IF;
      --      END IF;

      -- EKayan, Subat 2009
      -- Bazi kurulum kampanyalari kk ödemeli olabilecek.
      fatura.cari_islemler_pack.kontrat_kurulum_borclandir (ouye_no,
                                                            ioutlet_location,
                                                            isozlesme_no,
                                                            icampaign_code,
                                                            igiren_kullanici,
                                                            durum);

      IF durum <> '0'
      THEN
         RETURN;
      END IF;

      --F01 ise 181 nolu bayi ozelligi atanmamissa ,teknik servis ili ile adres ili ayni degilse ve arama yonlendirme yoksa uyar
      IF     v_franchise_code = 'F01'
         AND yetki_pack.yetkisi_varmi (
                v_giren_kullanici,
                'ISLEM_TEKNIK_SERVIS_FARKLI_BOLGE_AKTIVASYON') = 0
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM bt_bayi_ozellik
          WHERE     sales_agent_code = v_teknisyen_kodu
                AND bayi_ozellik_kodu = 181;

         IF v_count = 0                            --Bayi ozelligi atanmamissa
         THEN
            --teknik servisin ili
            BEGIN
               SELECT il, ulke
                 INTO v_tksrvs_il, v_tksrvs_ulke
                 FROM bt_bayi_teknik_servis
                WHERE     sales_agent_code = v_teknisyen_kodu
                      AND durum_kodu = 1
                      AND kurulus_kodu IN (12, 3);

               IF    v_fatura_il <> v_tksrvs_il
                  OR v_fatura_ulke <> v_tksrvs_ulke --iller farkliysa o bölgeye tanimli arama yönlendirme kaydi olmali
               THEN
                  bayi_arama_yonlendirme_pack.il_ilce_tanimlarini_bul (
                     v_fatura_il,
                     v_fatura_ilce,
                     v_fatura_mahalle,
                     in_stb_tipi,
                     1,
                     v_arama_yonlendirme_id,
                     durum,
                     v_fatura_ulke);

                  IF durum <> 0
                  THEN
                     durum :=
                        'Ilgili Teknik Servis, Bölgesi Disinda Aktivasyon Gerçeklestiremez!';
                     RETURN;
                  END IF;

                  --Kuran yts o bölgeye bakmali
                  SELECT COUNT (*)
                    INTO v_count
                    FROM bt_yts_arama_yonlendirme_detay
                   WHERE     arama_yonlendirme_id = v_arama_yonlendirme_id
                         AND sales_agent_code = v_teknisyen_kodu
                         AND listeden_gizle = 'H'
                         AND TRUNC (yonlendirme_baslama_tarihi) <=
                                TRUNC (SYSDATE)
                         AND (   TRUNC (yonlendirme_bitis_tarihi) >=
                                    TRUNC (SYSDATE)
                              OR TRUNC (yonlendirme_bitis_tarihi) IS NULL);

                  IF v_count = 0
                  THEN
                     durum :=
                        'Ilgili Teknik Servis, Bölgesi Disinda Aktivasyon Gerçeklestiremez!';
                     RETURN;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      --yeni aboneye insiyatif puan ekle
      SELECT COUNT (*)
        INTO v_count
        FROM wiz_customer_hp_life
       WHERE     customer_type IN ('NOR', 'SIT', 'LOJ')
             AND franchise_code = 'F01'
             AND hp_cluster NOT IN ('BB', 'TK', 'HK')
             AND account_number = v_uye_no;

      IF v_count > 0
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM ins_puan
          WHERE account_number = v_uye_no;

         IF v_count = 0
         THEN
            v_tarih_tmp :=
                 ADD_MONTHS (LAST_DAY (SYSDATE), -1)
               + TO_NUMBER (dbs_sabit ('INSIYATIF_PUAN_HESAPLAMA_GUNU'));

            IF TRUNC (SYSDATE) < TRUNC (v_tarih_tmp)
            THEN
               v_islem_tarihi := TRUNC (v_tarih_tmp);
            ELSE
               v_islem_tarihi :=
                    LAST_DAY (SYSDATE)
                  + TO_NUMBER (dbs_sabit ('INSIYATIF_PUAN_HESAPLAMA_GUNU'));
            END IF;

            v_islem_tarihi := ADD_MONTHS (v_islem_tarihi, 3);

            INSERT INTO ins_puan p (account_number,
                                    puan,
                                    kullanilan_puan,
                                    gecerlilik_tarihi,
                                    degistiren_kullanici,
                                    degistirme_tarihi)
                 VALUES (v_uye_no,
                         TO_NUMBER (dbs_sabit ('INSIYATIF_BASLANGIC_PUANI')),
                         0,
                         v_islem_tarihi,
                         'SYSTEM',
                         SYSDATE);
         END IF;
      END IF;

      /*Falamur 15112013 Eğer kontrat kampanyası sol internet özelliğine sahip ise üyeye sol denemesi bedava özelliği ekle.*/

      SELECT COUNT (1)
        INTO v_count
        FROM pr_urun_ozellik_tanim
       WHERE     listeden_gizle = 'H'
             AND urun_tipi = 1
             AND ozellik_kodu = 137
             AND urun_kodu IN (SELECT campaign_code
                                 FROM yk_dp_kontrat
                                WHERE sozlesme_no = isozlesme_no);

      IF v_count > 0
      THEN
         abone_detay_pack.mb_abone_ozellik_insert (v_uye_no,
                                                   ioutlet_location,
                                                   424,
                                                   'SYSTEM',
                                                   durum);

         IF NVL (durum, '0') <> '0'
         THEN
            RETURN;
         END IF;
      END IF;

      durum := '0';
   EXCEPTION
      WHEN OTHERS
      THEN
         durum :=
               'SMS_OK_SON:'
            || v_wiz_operator_id
            || SQLERRM
            || durum
            || '-'
            || v_sonuc
            || '-'
            || v_proc_name
            || '-'
            || v_is_emri_no;
         ouye_no := NULL;
         RETURN;
   END sms_ok;

   PROCEDURE yk_dp_kontrat_insert (
      isozlesme_tipi                IN     yk_dp_kontrat.sozlesme_tipi%TYPE,
      iis_yeri_yetkilisi_1          IN     yk_dp_kontrat.is_yeri_yetkilisi_1%TYPE,
      iis_yeri_yetkilisi_2          IN     yk_dp_kontrat.is_yeri_yetkilisi_2%TYPE,
      idigikutu_bagli_tel           IN     yk_dp_kontrat.digikutu_bagli_tel%TYPE,
      idwelling_type                IN     yk_dp_kontrat.dwelling_type%TYPE,
      ibilling_frequency            IN     yk_dp_kontrat.billing_frequency%TYPE,
      iruhsat_yeri_id               IN     yk_dp_kontrat.ruhsat_yeri_id%TYPE,
      iruhsat_tarihi                IN     yk_dp_kontrat.ruhsat_tarihi%TYPE,
      iruhsat_verilme_ili           IN     yk_dp_kontrat.ruhsat_verilme_ili%TYPE,
      iruhsat_sicil_no              IN     yk_dp_kontrat.ruhsat_sicil_no%TYPE,
      iruhsat_belediye              IN     VARCHAR2,
      ifaaliyet_konusu              IN     yk_dp_kontrat.faaliyet_konusu%TYPE,
      ifatura_apt_adi               IN     yk_dp_kontrat.fatura_apt_adi%TYPE,
      ifatura_blok                  IN     yk_dp_kontrat.fatura_blok%TYPE,
      ifatura_apt_no                IN     yk_dp_kontrat.fatura_apt_no%TYPE,
      ifatura_semt                  IN     yk_dp_kontrat.fatura_semt%TYPE,
      ifatura_ilce                  IN     yk_dp_kontrat.fatura_ilce%TYPE,
      ifatura_il                    IN     yk_dp_kontrat.fatura_il%TYPE,
      ifatura_eyalet                IN     yk_dp_kontrat.fatura_eyalet%TYPE,
      ifatura_ulke                  IN     yk_dp_kontrat.fatura_ulke%TYPE,
      ifatura_daire_no              IN     yk_dp_kontrat.fatura_daire_no%TYPE,
      ifatura_posta_kodu            IN     yk_dp_kontrat.fatura_posta_kodu%TYPE,
      imdu_ceki                     IN     yk_dp_kontrat.mdu_ceki%TYPE,
      imdu_bu_ceki                  IN     yk_dp_kontrat.mdu_bu_ceki%TYPE,
      iteknisyen_kodu               IN     yk_dp_kontrat.teknisyen_kodu%TYPE,
      idaire_sayisi                 IN     yk_dp_kontrat.daire_sayisi%TYPE,
      ikat_sayisi                   IN     yk_dp_kontrat.kat_sayisi%TYPE,
      istb_seri_no                  IN     yk_dp_kontrat.stb_seri_no%TYPE,
      isc_seri_no                   IN     yk_dp_kontrat.sc_seri_no%TYPE,
      itelefon_ceki                 IN     yk_dp_kontrat.telefon_ceki%TYPE,
      ikk_tipi                      IN     yk_dp_kontrat.kk_tipi%TYPE,
      ikk_no                        IN     yk_dp_kontrat.kk_no%TYPE,
      ikk_son_tarihi                IN     yk_dp_kontrat.kk_son_tarihi%TYPE,
      ibayi_kodu                    IN     yk_dp_kontrat.bayi_kodu%TYPE,
      ikon_gel_tipi                 IN     yk_dp_kontrat.kon_gel_tipi%TYPE,
      ibuilding_id                  IN     yk_dp_kontrat.building_id%TYPE,
      iservice_address_id           IN     yk_dp_kontrat.service_address_id%TYPE,
      iservis_tarihi                IN     yk_dp_kontrat.servis_tarihi%TYPE,
      irevizyon                     IN     yk_dp_kontrat.revizyon%TYPE,
      ibatch                        IN     yk_dp_kontrat.batch%TYPE,
      iits_kayit_no                 IN     yk_dp_kontrat.its_kayit_no%TYPE,
      istatus                       IN     yk_dp_kontrat.status%TYPE,
      igiren_kullanici              IN     yk_dp_kontrat.giren_kullanici%TYPE,
      iuye_tipi                     IN     yk_dp_kontrat.uye_tipi%TYPE,
      ikimlik_cinsi                 IN     yk_dp_kontrat.kimlik_cinsi%TYPE,
      ibina_tipi                    IN     yk_dp_kontrat.bina_tipi%TYPE,
      ihub_code                     IN     yk_dp_kontrat.hub_code%TYPE,
      iprospect_number              IN     yk_dp_kontrat.prospect_number%TYPE,
      ifranchise_code               IN     yk_dp_kontrat.franchise_code%TYPE,
      ituttugu_takim_kodu           IN     yk_dp_kontrat.tuttugu_takim_kodu%TYPE,
      icampaign_code                IN     yk_dp_kontrat.campaign_code%TYPE,
      ivip                          IN     yk_dp_kontrat.vip%TYPE,
      isozlesme_no                  IN     yk_dp_kontrat.sozlesme_no%TYPE,
      isozlesme_tarihi              IN     yk_dp_kontrat.sozlesme_tarihi%TYPE,
      iyeni_mdu_no                  IN     yk_dp_kontrat.yeni_mdu_no%TYPE,
      ieski_mdu_no                  IN     yk_dp_kontrat.eski_mdu_no%TYPE,
      iis_emri_no                   IN     yk_dp_kontrat.is_emri_no%TYPE,
      iuye_no                       IN     yk_dp_kontrat.uye_no%TYPE,
      ieski_yeni_ceki               IN     yk_dp_kontrat.eski_yeni_ceki%TYPE,
      iad                           IN     yk_dp_kontrat.ad%TYPE,
      isoyad                        IN     yk_dp_kontrat.soyad%TYPE,
      ianne_kizlik_soyad            IN     yk_dp_kontrat.anne_kizlik_soyad%TYPE,
      idogum_yeri                   IN     yk_dp_kontrat.dogum_yeri%TYPE,
      idogum_tarihi                 IN     yk_dp_kontrat.dogum_tarihi%TYPE,
      icinsiyet                     IN     yk_dp_kontrat.cinsiyet%TYPE,
      imeslek                       IN     yk_dp_kontrat.meslek%TYPE,
      imeslek_id                    IN     yk_dp_kontrat.meslek_id%TYPE,
      ikimlik_yeri                  IN     yk_dp_kontrat.kimlik_yeri%TYPE,
      ikimlik_seri_no               IN     yk_dp_kontrat.kimlik_seri_no%TYPE,
      ikimlik_kayit_no              IN     yk_dp_kontrat.kimlik_kayit_no%TYPE,
      ikimlik_tarihi                IN     yk_dp_kontrat.kimlik_tarihi%TYPE,
      itabiyet                      IN     yk_dp_kontrat.tabiyet%TYPE,
      ivergi_dairesi                IN     yk_dp_kontrat.vergi_dairesi%TYPE,
      ivergi_no                     IN     yk_dp_kontrat.vergi_no%TYPE,
      iev_tel_ulke_alan             IN     yk_dp_kontrat.home_country_tel_code%TYPE,
      iev_tel_alan                  IN     yk_dp_kontrat.ev_tel_alan%TYPE,
      iev_tel_prefix                IN     yk_dp_kontrat.ev_tel_prefix%TYPE,
      iev_tel_no                    IN     yk_dp_kontrat.ev_tel_no%TYPE,
      iis_tel_ulke_alan             IN     yk_dp_kontrat.work_country_tel_code%TYPE,
      iis_tel_alan                  IN     yk_dp_kontrat.is_tel_alan%TYPE,
      iis_tel_prefix                IN     yk_dp_kontrat.is_tel_prefix%TYPE,
      iis_tel_no                    IN     yk_dp_kontrat.is_tel_no%TYPE,
      iis_tel_dahili                IN     yk_dp_kontrat.is_tel_dahili%TYPE,
      icep_tel_ulke_alan            IN     yk_dp_kontrat.mobile_country_tel_code%TYPE,
      icep_tel_alan                 IN     yk_dp_kontrat.cep_tel_alan%TYPE,
      icep_tel_prefix               IN     yk_dp_kontrat.cep_tel_prefix%TYPE,
      icep_tel_no                   IN     yk_dp_kontrat.cep_tel_no%TYPE,
      ifax_tel_ulke_alan            IN     yk_dp_kontrat.fax_country_tel_code%TYPE,
      ifax_tel_alan                 IN     yk_dp_kontrat.fax_tel_alan%TYPE,
      ifax_tel_prefix               IN     yk_dp_kontrat.fax_tel_prefix%TYPE,
      ifax_tel_no                   IN     yk_dp_kontrat.fax_tel_no%TYPE,
      iemail                        IN     yk_dp_kontrat.email%TYPE,
      ifatura_sirket_adi            IN     yk_dp_kontrat.fatura_sirket_adi%TYPE,
      ifatura_mahalle               IN     yk_dp_kontrat.fatura_mahalle%TYPE,
      ifatura_cadde                 IN     yk_dp_kontrat.fatura_cadde%TYPE,
      ifatura_sokak                 IN     yk_dp_kontrat.fatura_sokak%TYPE,
      ifatura_site_adi              IN     yk_dp_kontrat.fatura_site_adi%TYPE,
      idigikart_var_mi              IN     yk_dp_kontrat.digikart_varmi%TYPE,
      imdu_sistem_no                IN     yk_dp_kontrat.mdu_sistem_no%TYPE,
      imdu_yontem_no                IN     yk_dp_kontrat.mdu_yontem_no%TYPE,
      ibilling_cycle                IN     yk_dp_kontrat.billing_cycle%TYPE,
      iguvenlik_kodu                IN     yk_dp_kontrat.guvenlik_kodu%TYPE,
      ioutlet_location              IN     yk_dp_kontrat.outlet_location%TYPE,
      iekip_kodu                    IN     yk_dp_kontrat.ekip_kodu%TYPE,
      ipotansiyel_is_emri_id        IN     yk_dp_kontrat.potansiyel_is_emri_id%TYPE,
      in_ts_sifre_id                IN     lg_ekipman.lg_teknik_servis_sifre_id%TYPE,
      in_anne_adi                   IN     yk_dp_kontrat.anne_adi%TYPE,
      in_baba_adi                   IN     yk_dp_kontrat.baba_adi%TYPE,
      in_nufusa_kayitli_ilcesi      IN     yk_dp_kontrat.nufusa_kayitli_ilcesi%TYPE,
      in_nufusa_kayitli_ili         IN     yk_dp_kontrat.nufusa_kayitli_ili%TYPE,
      in_abone_ozellik_kodu         IN     yk_dp_kontrat.abone_ozellik_kodu%TYPE,
      in_uydu_tipi                  IN     yk_dp_kontrat.uydu_tipi%TYPE,
      in_modul_tipi                 IN     yk_dp_kontrat.modul_tipi%TYPE,
      in_ekipman_kutu_tipi          IN     yk_dp_kontrat.ekipman_kutu_tipi%TYPE,
      in_modul_seri_no              IN     yk_dp_kontrat.modul_seri_no%TYPE,
      ouye_no                          OUT yk_dp_kontrat.uye_no%TYPE,
      durum                            OUT VARCHAR2,
      in_stb_tipi                   IN     yk_dp_kontrat.stb_tipi%TYPE,
      in_hk_seri_no                 IN     yk_dp_kontrat.hk_seri_no%TYPE,
      in_cep_kayitli                IN     yk_dp_kontrat.cep_kayitli%TYPE,
      ilnb_tipi_stok_kodu           IN     VARCHAR2,
      iciltno                       IN     yk_dp_kontrat.cilt_no%TYPE,
      iailesirano                   IN     yk_dp_kontrat.aile_sira_no%TYPE,
      isirano                       IN     yk_dp_kontrat.sira_no%TYPE := NULL,
      isitevillablokadedi           IN     yk_dp_kontrat.site_villa_blok_adedi%TYPE,
      isitedaireblokadedi           IN     yk_dp_kontrat.site_daire_blok_adedi%TYPE,
      isitetoplamkonutadedi         IN     yk_dp_kontrat.site_toplam_konut_adedi%TYPE,
      isitealtyapidestekbedeli      IN     yk_dp_kontrat.site_altyapi_destek_bedeli%TYPE,
      isozlesme_bitis_tarihi        IN     yk_dp_kontrat.sozlesme_bitis_tarihi%TYPE,
      iyts_personel                 IN     yk_dp_kontrat.yts_personel%TYPE,
      icheck_payment_order_status   IN     NUMBER := 1,
      ivatandaslikno                IN     yk_dp_kontrat.tc_kimlik_no%TYPE,
      ibanka_adi                    IN     yk_dp_kontrat.banka_adi%TYPE,
      idevirli_outlet_location      IN     yk_dp_kontrat.devirli_outlet_location%TYPE,
      imalzeme_onayli               IN     yk_dp_kontrat.malzeme_onayli%TYPE,
      isifre_text                   IN     yk_dp_kontrat.sifre_text%TYPE,
      iharddisk_seri_no             IN     yk_dp_kontrat.harddisk_seri_no%TYPE, --MKECECI
      imodem_seri_no                IN     yk_dp_kontrat.modem_seri_no%TYPE := NULL, -- MKECECI
      irf_mdu_tipi                  IN     mb_abone_detay_bilgi.rf_mdu_tipi%TYPE --MKECECI')
                                                                                )
   IS
      /*OGM ittp integration variables*/
      v_ittp_result_type            NUMBER;
      v_ittp_result_code            VARCHAR2 (512);
      v_ittp_result_message         VARCHAR2 (32000);
      /*OGM ittp integration variables*/
      v_sozlesme_tipi               yk_dp_kontrat.sozlesme_tipi%TYPE;
      v_is_yeri_yetkilisi_1         yk_dp_kontrat.is_yeri_yetkilisi_1%TYPE;
      v_is_yeri_yetkilisi_2         yk_dp_kontrat.is_yeri_yetkilisi_2%TYPE;
      v_digikutu_bagli_tel          yk_dp_kontrat.digikutu_bagli_tel%TYPE;
      v_dwelling_type               yk_dp_kontrat.dwelling_type%TYPE;
      v_billing_frequency           yk_dp_kontrat.billing_frequency%TYPE;
      v_ruhsat_yeri_id              yk_dp_kontrat.ruhsat_yeri_id%TYPE;
      v_ruhsat_tarihi               yk_dp_kontrat.ruhsat_tarihi%TYPE;
      v_ruhsat_verilme_ili          yk_dp_kontrat.ruhsat_verilme_ili%TYPE;
      v_ruhsat_verilme_ili_ad       mb_abone_detay_bilgi.ruhsat_verilme_ili%TYPE;
      v_ruhsat_sicil_no             yk_dp_kontrat.ruhsat_sicil_no%TYPE;
      v_ruhsat_belediye             VARCHAR2 (50);
      v_faaliyet_konusu             yk_dp_kontrat.faaliyet_konusu%TYPE;
      v_fatura_apt_adi              yk_dp_kontrat.fatura_apt_adi%TYPE;
      v_fatura_blok                 yk_dp_kontrat.fatura_blok%TYPE;
      v_fatura_apt_no               yk_dp_kontrat.fatura_apt_no%TYPE;
      v_fatura_semt                 yk_dp_kontrat.fatura_semt%TYPE;
      v_fatura_ilce                 yk_dp_kontrat.fatura_ilce%TYPE;
      v_fatura_il                   yk_dp_kontrat.fatura_il%TYPE;
      v_fatura_daire_no             yk_dp_kontrat.fatura_daire_no%TYPE;
      v_fatura_posta_kodu           yk_dp_kontrat.fatura_posta_kodu%TYPE;
      v_mdu_ceki                    yk_dp_kontrat.mdu_ceki%TYPE;
      v_mdu_bu_ceki                 yk_dp_kontrat.mdu_bu_ceki%TYPE;
      v_teknisyen_kodu              yk_dp_kontrat.teknisyen_kodu%TYPE;
      v_daire_sayisi                yk_dp_kontrat.daire_sayisi%TYPE;
      v_kat_sayisi                  yk_dp_kontrat.kat_sayisi%TYPE;
      v_stb_seri_no                 yk_dp_kontrat.stb_seri_no%TYPE;
      v_sc_seri_no                  yk_dp_kontrat.sc_seri_no%TYPE;
      v_telefon_ceki                yk_dp_kontrat.telefon_ceki%TYPE;
      v_kk_tipi                     yk_dp_kontrat.kk_tipi%TYPE;
      v_kk_no                       yk_dp_kontrat.kk_no%TYPE;
      v_kk_son_tarihi               yk_dp_kontrat.kk_son_tarihi%TYPE;
      v_bayi_kodu                   yk_dp_kontrat.bayi_kodu%TYPE;
      v_kon_gel_tipi                yk_dp_kontrat.kon_gel_tipi%TYPE;
      v_building_id                 yk_dp_kontrat.building_id%TYPE;
      v_service_address_id          yk_dp_kontrat.service_address_id%TYPE;
      v_servis_tarihi               yk_dp_kontrat.servis_tarihi%TYPE;
      v_revizyon                    yk_dp_kontrat.revizyon%TYPE;
      v_batch                       yk_dp_kontrat.batch%TYPE;
      v_its_kayit_no                yk_dp_kontrat.its_kayit_no%TYPE;
      v_status                      yk_dp_kontrat.status%TYPE;
      v_giren_kullanici             yk_dp_kontrat.giren_kullanici%TYPE;
      v_uye_tipi                    yk_dp_kontrat.uye_tipi%TYPE;
      v_kimlik_cinsi                yk_dp_kontrat.kimlik_cinsi%TYPE;
      v_bina_tipi                   yk_dp_kontrat.bina_tipi%TYPE;
      v_hub_code                    yk_dp_kontrat.hub_code%TYPE;
      v_prospect_number             yk_dp_kontrat.prospect_number%TYPE;
      v_franchise_code              yk_dp_kontrat.franchise_code%TYPE;
      v_tuttugu_takim_kodu          yk_dp_kontrat.tuttugu_takim_kodu%TYPE;
      v_campaign_code               yk_dp_kontrat.campaign_code%TYPE;
      v_vip                         yk_dp_kontrat.vip%TYPE;
      v_sozlesme_no                 yk_dp_kontrat.sozlesme_no%TYPE;
      v_sozlesme_tarihi             yk_dp_kontrat.sozlesme_tarihi%TYPE;
      v_yeni_mdu_no                 yk_dp_kontrat.yeni_mdu_no%TYPE;
      v_eski_mdu_no                 yk_dp_kontrat.eski_mdu_no%TYPE;
      v_is_emri_no                  yk_dp_kontrat.is_emri_no%TYPE;
      v_uye_no                      yk_dp_kontrat.uye_no%TYPE;
      v_eski_yeni_ceki              yk_dp_kontrat.eski_yeni_ceki%TYPE;
      v_ad                          yk_dp_kontrat.ad%TYPE;
      v_soyad                       yk_dp_kontrat.soyad%TYPE;
      v_anne_kizlik_soyad           yk_dp_kontrat.anne_kizlik_soyad%TYPE;
      v_dogum_yeri                  yk_dp_kontrat.dogum_yeri%TYPE;
      v_dogum_tarihi                yk_dp_kontrat.dogum_tarihi%TYPE;
      v_cinsiyet                    yk_dp_kontrat.cinsiyet%TYPE;
      v_meslek                      yk_dp_kontrat.meslek%TYPE;
      v_meslek_id                   yk_dp_kontrat.meslek_id%TYPE;
      v_kimlik_yeri                 yk_dp_kontrat.kimlik_yeri%TYPE;
      v_kimlik_seri_no              yk_dp_kontrat.kimlik_seri_no%TYPE;
      v_kimlik_kayit_no             yk_dp_kontrat.kimlik_kayit_no%TYPE;
      v_kimlik_tarihi               yk_dp_kontrat.kimlik_tarihi%TYPE;
      v_tabiyet                     yk_dp_kontrat.tabiyet%TYPE;
      v_vergi_dairesi               yk_dp_kontrat.vergi_dairesi%TYPE;
      v_vergi_no                    yk_dp_kontrat.vergi_no%TYPE;
      v_ev_tel_ulke_alan            yk_dp_kontrat.home_country_tel_code%TYPE;
      v_ev_tel_alan                 yk_dp_kontrat.ev_tel_alan%TYPE;
      v_ev_tel_prefix               yk_dp_kontrat.ev_tel_prefix%TYPE;
      v_ev_tel_no                   yk_dp_kontrat.ev_tel_no%TYPE;
      v_is_tel_ulke_alan            yk_dp_kontrat.work_country_tel_code%TYPE;
      v_is_tel_alan                 yk_dp_kontrat.is_tel_alan%TYPE;
      v_is_tel_prefix               yk_dp_kontrat.is_tel_prefix%TYPE;
      v_is_tel_no                   yk_dp_kontrat.is_tel_no%TYPE;
      v_is_tel_dahili               yk_dp_kontrat.is_tel_dahili%TYPE;
      v_cep_tel_ulke_alan           yk_dp_kontrat.mobile_country_tel_code%TYPE;
      v_cep_tel_alan                yk_dp_kontrat.cep_tel_alan%TYPE;
      v_cep_tel_prefix              yk_dp_kontrat.cep_tel_prefix%TYPE;
      v_cep_tel_no                  yk_dp_kontrat.cep_tel_no%TYPE;
      v_fax_tel_ulke_alan           yk_dp_kontrat.fax_country_tel_code%TYPE;
      v_fax_tel_alan                yk_dp_kontrat.fax_tel_alan%TYPE;
      v_fax_tel_prefix              yk_dp_kontrat.fax_tel_prefix%TYPE;
      v_fax_tel_no                  yk_dp_kontrat.fax_tel_no%TYPE;
      v_email                       yk_dp_kontrat.email%TYPE;
      v_fatura_sirket_adi           yk_dp_kontrat.fatura_sirket_adi%TYPE;
      v_fatura_mahalle              yk_dp_kontrat.fatura_mahalle%TYPE;
      v_fatura_cadde                yk_dp_kontrat.fatura_cadde%TYPE;
      v_fatura_sokak                yk_dp_kontrat.fatura_sokak%TYPE;
      v_fatura_site_adi             yk_dp_kontrat.fatura_site_adi%TYPE;
      v_digikart_var_mi             yk_dp_kontrat.digikart_varmi%TYPE;
      v_mdu_sistem_no               yk_dp_kontrat.mdu_sistem_no%TYPE;
      v_mdu_yontem_no               yk_dp_kontrat.mdu_yontem_no%TYPE;
      v_billing_cycle               yk_dp_kontrat.billing_cycle%TYPE;
      v_guvenlik_kodu               yk_dp_kontrat.guvenlik_kodu%TYPE;
      v_kayit_aktarilma_tarihi      yk_dp_kontrat.kayit_aktarilma_tarihi%TYPE;
      v_sonuc                       VARCHAR2 (512);
      v_outlet_location             yk_dp_kontrat.outlet_location%TYPE;
      v_ekip_kodu                   yk_dp_kontrat.ekip_kodu%TYPE;
      v_temp_ekip_kodu              yk_dp_kontrat.ekip_kodu%TYPE;
      v_ekip_tipi_kodu              bt_bayi_teknik_servis.tip_kodu%TYPE;
      v_potansiyel_is_emri_id       yk_dp_kontrat.potansiyel_is_emri_id%TYPE;
      v_count                       NUMBER (10);
      v_ts_sifre_id                 lg_ekipman.lg_teknik_servis_sifre_id%TYPE;
      v_stb_tipi                    yk_dp_kontrat.stb_tipi%TYPE;
      v_anne_adi                    yk_dp_kontrat.anne_adi%TYPE;
      v_baba_adi                    yk_dp_kontrat.baba_adi%TYPE;
      v_nufusa_kayitli_ilcesi       yk_dp_kontrat.nufusa_kayitli_ilcesi%TYPE;
      v_nufusa_kayitli_ili          yk_dp_kontrat.nufusa_kayitli_ili%TYPE;
      v_abone_ozellik_kodu          yk_dp_kontrat.abone_ozellik_kodu%TYPE;
      v_uydu_tipi                   yk_dp_kontrat.uydu_tipi%TYPE;
      v_modul_tipi                  yk_dp_kontrat.modul_tipi%TYPE;
      v_ekipman_kutu_tipi           yk_dp_kontrat.ekipman_kutu_tipi%TYPE;
      v_modul_seri_no               yk_dp_kontrat.modul_seri_no%TYPE;
      v_abbrev                      wiz_customer_type_codes.abbrev%TYPE;
      v_hk_seri_no                  yk_dp_kontrat.hk_seri_no%TYPE;
      v_cep_kayitli                 yk_dp_kontrat.cep_kayitli%TYPE;
      v_sonuc_tip                   NUMBER;
      v_sonuc_kod                   VARCHAR2 (512);
      v_sonuc_cevap                 VARCHAR2 (512);
      v_sonuc_aciklama              VARCHAR2 (512);
      v_vatandaslikno               yk_dp_kontrat.tc_kimlik_no%TYPE;
      v_ciltno                      yk_dp_kontrat.cilt_no%TYPE;
      v_ailesirano                  yk_dp_kontrat.aile_sira_no%TYPE;

      v_sirano                      yk_dp_kontrat.sira_no%TYPE;
      v_sitevillablokadedi          yk_dp_kontrat.site_villa_blok_adedi%TYPE;
      v_sitedaireblokadedi          yk_dp_kontrat.site_daire_blok_adedi%TYPE;
      v_sitetoplamkonutadedi        yk_dp_kontrat.site_toplam_konut_adedi%TYPE;
      v_sitealtyapidestekbedeli     yk_dp_kontrat.site_altyapi_destek_bedeli%TYPE;
      v_sozlesme_bitis_tarihi       yk_dp_kontrat.sozlesme_bitis_tarihi%TYPE;
      v_yts_personel                yk_dp_kontrat.yts_personel%TYPE;
      v_fatura_eyalet               yk_dp_kontrat.fatura_eyalet%TYPE;
      v_fatura_ulke                 yk_dp_kontrat.fatura_ulke%TYPE;
      v_validfranchise              NUMBER (1);
      v_banka_adi                   yk_dp_kontrat.banka_adi%TYPE;
      v_devirli_outlet_location     yk_dp_kontrat.devirli_outlet_location%TYPE;
      v_tmp                         NUMBER (2);
      v_wiz_operator_id             co_kullanici.wiz_operator_id%TYPE;
      v_son_adim                    CHAR (1) := 'H';
      v_tc_kimlik_no_zorunlu        VARCHAR2 (1);
      v_listeden_gizle              pr_form_gelis_tipi.listeden_gizle%TYPE;
      v_gelen_kontrat_adi           pr_form_gelis_tipi.aciklama%TYPE;
      v_yk_dp_kontrat_id            NUMBER;
      v_eskiborc_mesaj              VARCHAR2 (2000);
      vlnb_tipi_stok_kodu           VARCHAR2 (10);
      v_sifre_text                  yk_dp_kontrat.sifre_text%TYPE;
      v_harddisk_seri_no            yk_dp_kontrat.harddisk_seri_no%TYPE; --MKECECI
      v_modem_seri_no               yk_dp_kontrat.modem_seri_no%TYPE := NULL;
      v_rf_mdu_tipi                 mb_abone_detay_bilgi.rf_mdu_tipi%TYPE; --MKECECI

      CURSOR yk_dp_kontrat_cur
      IS
             SELECT *
               FROM yk_dp_kontrat
              WHERE sozlesme_no = v_sozlesme_no
         FOR UPDATE OF fatura_site_adi NOWAIT;

      CURSOR cur_kontrat_ekipman
      IS
         SELECT *
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE yk_dp_kontrat_ekipman_bilgi.sozlesme_no = v_sozlesme_no;

      CURSOR cur_kontrat_ekipman_kontrol
      IS
         SELECT kampanya_ozellik
           FROM vv_kampanya_ekipman
          WHERE     tip_aciklama IN ('MODÜL',
                                     'KUTU',
                                     'KART',
                                     'HARDDİSK',
                                     'MODEM')
                AND kampanya_kodu = v_campaign_code;

      rec_kontrat_ekipman           cur_kontrat_ekipman%ROWTYPE;
      rec_kontrat_ekipman_kontrol   cur_kontrat_ekipman_kontrol%ROWTYPE;
      yk_dp_kontrat_rec             yk_dp_kontrat_cur%ROWTYPE;
   BEGIN
      durum := '0';
      ouye_no := NULL;
      v_count := 0;
      vlnb_tipi_stok_kodu := ilnb_tipi_stok_kodu;

      IF v_status = '30'
      THEN
         IF ioutlet_location IS NULL
         THEN
            durum := 'OUTLET BILGISI YOK';
            RETURN;
         END IF;
      END IF;

      IF igiren_kullanici IS NULL
      THEN
         durum := 'KULLANICI BILGISI DOLU OLMALIDIR!';
         RETURN;
      END IF;

      IF is_valid_sozlesme_no (isozlesme_no, igiren_kullanici, in_stb_tipi) =
            0
      THEN
         durum :=
            'SÖZLESME NUMARASI ' || in_stb_tipi || ' TIPI IÇIN HATALI.';
         RETURN;
      END IF;

      IF in_stb_tipi = 'ZS' AND isozlesme_tipi = 1
      THEN
         BEGIN
            SELECT son_adim
              INTO v_son_adim
              FROM pr_form_gelis_tipi
             WHERE kod = ikon_gel_tipi;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_son_adim := 'H';
         END;

         IF v_son_adim = 'E'
         THEN
            IF TRIM (imalzeme_onayli) IS NULL
            THEN
               durum :=
                  'KONTRAT_PACK.YK_DP_KONTRAT_INSERT: Malzemenin onayli olup olmadigini girmelisiniz!.';
               RETURN;
            END IF;
         END IF;
      END IF;

      IF TRIM (ifranchise_code) = 'F01' AND vlnb_tipi_stok_kodu IS NULL
      THEN
         durum := 'LNB Tipi zorunludur!';
         RETURN;
      END IF;

      IF vlnb_tipi_stok_kodu IS NOT NULL
      THEN
         BEGIN
            SELECT 0
              INTO durum
              FROM DUAL
             WHERE EXISTS
                      (SELECT st.stok_kodu kod, st.stok_baslik aciklama
                         FROM stok_dba.vv_stok_malzeme_tanim st,
                              stok_dba.s_stok_grup_tanim gt,
                              stok_dba.s_stok_grup_detay gd
                        WHERE     st.aktif = 'E'
                              AND gt.grupadi = 'LNB'
                              AND gt.grupid = gd.grupid
                              AND gd.stokkodu = st.stok_kodu
                              AND st.stok_kodu = vlnb_tipi_stok_kodu);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               durum := 'Geçersiz LNB Tipi !';
               RETURN;
         END;
      END IF;

      IF LTRIM (RTRIM (ibayi_kodu)) IS NOT NULL
      THEN
         v_ekip_kodu := LTRIM (RTRIM (iekip_kodu));

         IF v_ekip_kodu = '000'
         THEN
            v_ekip_kodu := ibayi_kodu;
         ELSIF LTRIM (RTRIM (v_ekip_kodu)) IS NOT NULL
         THEN
            v_ekip_tipi_kodu := dbs_sabit ('EKIP_TIPI_KODU');

            BEGIN
               SELECT DISTINCT
                      DECODE (NVL (sales_agent_code, '?'),
                              '?', ust_kod,
                              sales_agent_code)
                 INTO v_temp_ekip_kodu
                 FROM vv_bayi_teknik_servis_sube
                WHERE     ust_kod = TRIM (ibayi_kodu)
                      AND SUBSTR (sales_agent_code, -3, 3) =
                             TRIM (v_ekip_kodu)
                      AND tip_kodu = v_ekip_tipi_kodu;

               v_ekip_kodu := v_temp_ekip_kodu;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum :=
                        'EKIP KODU TANIMLARI HATALI!'
                     || '-'
                     || v_ekip_kodu
                     || '-'
                     || ibayi_kodu;
                  RETURN;
            END;
         END IF;
      ELSE
         v_ekip_kodu := NULL;
      END IF;

      OPEN yk_dp_kontrat_cur;

      FETCH yk_dp_kontrat_cur INTO yk_dp_kontrat_rec;

      IF yk_dp_kontrat_cur%NOTFOUND
      THEN
         v_abone_ozellik_kodu := in_abone_ozellik_kodu;
         v_sozlesme_tipi := isozlesme_tipi;
         v_is_yeri_yetkilisi_1 := iis_yeri_yetkilisi_1;
         v_is_yeri_yetkilisi_2 := iis_yeri_yetkilisi_2;
         v_digikutu_bagli_tel := idigikutu_bagli_tel;
         v_dwelling_type := idwelling_type;
         v_billing_frequency := ibilling_frequency;
         v_ruhsat_yeri_id := iruhsat_yeri_id;
         v_ruhsat_tarihi := iruhsat_tarihi;
         v_ruhsat_verilme_ili := iruhsat_verilme_ili;
         v_ruhsat_sicil_no := iruhsat_sicil_no;
         v_ruhsat_belediye := iruhsat_belediye;
         v_faaliyet_konusu := ifaaliyet_konusu;
         v_fatura_apt_adi := ifatura_apt_adi;
         v_fatura_blok := ifatura_blok;
         v_fatura_apt_no := ifatura_apt_no;
         v_fatura_semt := ifatura_semt;
         v_fatura_ilce := ifatura_ilce;
         v_fatura_il := ifatura_il;
         v_fatura_daire_no := ifatura_daire_no;
         v_fatura_posta_kodu := ifatura_posta_kodu;
         v_mdu_ceki := imdu_ceki;
         v_mdu_bu_ceki := imdu_bu_ceki;
         v_teknisyen_kodu := iteknisyen_kodu;
         v_daire_sayisi := idaire_sayisi;
         v_kat_sayisi := ikat_sayisi;
         v_stb_seri_no := TRIM (istb_seri_no);
         v_sc_seri_no := isc_seri_no;
         v_telefon_ceki := itelefon_ceki;
         v_kk_tipi := ikk_tipi;
         v_kk_no := ikk_no;
         v_kk_son_tarihi := ikk_son_tarihi;
         v_bayi_kodu := ibayi_kodu;
         v_kon_gel_tipi := ikon_gel_tipi;
         v_building_id := ibuilding_id;
         v_service_address_id := iservice_address_id;
         v_servis_tarihi := iservis_tarihi;
         v_revizyon := irevizyon;
         v_batch := ibatch;
         v_its_kayit_no := iits_kayit_no;
         v_status := istatus;
         v_giren_kullanici := igiren_kullanici;
         v_uye_tipi := iuye_tipi;
         v_kimlik_cinsi := ikimlik_cinsi;
         v_bina_tipi := ibina_tipi;
         v_hub_code := ihub_code;
         v_prospect_number := iprospect_number;
         v_franchise_code := ifranchise_code;
         v_tuttugu_takim_kodu := ituttugu_takim_kodu;
         v_campaign_code := icampaign_code;
         v_vip := ivip;
         v_sozlesme_no := isozlesme_no;
         v_sozlesme_tarihi := isozlesme_tarihi;
         v_yeni_mdu_no := iyeni_mdu_no;
         v_eski_mdu_no := ieski_mdu_no;
         v_is_emri_no := iis_emri_no;
         v_uye_no := iuye_no;
         v_eski_yeni_ceki := ieski_yeni_ceki;
         v_ad := iad;
         v_soyad := isoyad;
         v_anne_kizlik_soyad := ianne_kizlik_soyad;
         v_dogum_yeri := idogum_yeri;
         v_dogum_tarihi := idogum_tarihi;
         v_cinsiyet := icinsiyet;
         v_meslek := imeslek;
         v_meslek_id := imeslek_id;
         v_kimlik_yeri := ikimlik_yeri;
         v_kimlik_seri_no := ikimlik_seri_no;
         v_kimlik_kayit_no := ikimlik_kayit_no;
         v_kimlik_tarihi := ikimlik_tarihi;
         v_tabiyet := TRIM (itabiyet);
         v_vergi_dairesi := ivergi_dairesi;
         v_vergi_no := ivergi_no;
         v_ev_tel_ulke_alan := iev_tel_ulke_alan;
         v_ev_tel_alan := iev_tel_alan;
         v_ev_tel_prefix := iev_tel_prefix;
         v_ev_tel_no := iev_tel_no;
         v_is_tel_ulke_alan := iis_tel_ulke_alan;
         v_is_tel_alan := iis_tel_alan;
         v_is_tel_prefix := iis_tel_prefix;
         v_is_tel_no := iis_tel_no;
         v_is_tel_dahili := iis_tel_dahili;
         v_cep_tel_ulke_alan := icep_tel_ulke_alan;
         v_cep_tel_alan := icep_tel_alan;
         v_cep_tel_prefix := icep_tel_prefix;
         v_cep_tel_no := icep_tel_no;
         v_fax_tel_ulke_alan := ifax_tel_ulke_alan;
         v_fax_tel_alan := ifax_tel_alan;
         v_fax_tel_prefix := ifax_tel_prefix;
         v_fax_tel_no := ifax_tel_no;
         v_email := iemail;
         v_fatura_sirket_adi := ifatura_sirket_adi;
         v_fatura_mahalle := ifatura_mahalle;
         v_fatura_cadde := ifatura_cadde;
         v_fatura_sokak := ifatura_sokak;
         v_fatura_site_adi := ifatura_site_adi;
         v_digikart_var_mi := idigikart_var_mi;
         v_mdu_sistem_no := imdu_sistem_no;
         v_mdu_yontem_no := imdu_yontem_no;
         v_billing_cycle := ibilling_cycle;
         v_guvenlik_kodu := iguvenlik_kodu;
         v_outlet_location := ioutlet_location;
         v_potansiyel_is_emri_id := ipotansiyel_is_emri_id;
         v_ts_sifre_id := in_ts_sifre_id;
         v_stb_tipi :=
            vestel_pack.abone_stb_tipi_from_sozlesme (v_sozlesme_no,
                                                      in_stb_tipi);
         v_anne_adi := in_anne_adi;
         v_baba_adi := in_baba_adi;
         v_nufusa_kayitli_ilcesi := in_nufusa_kayitli_ilcesi;
         v_nufusa_kayitli_ili := in_nufusa_kayitli_ili;
         v_uydu_tipi := in_uydu_tipi;
         v_modul_tipi := in_modul_tipi;
         v_ekipman_kutu_tipi := in_ekipman_kutu_tipi;
         v_modul_seri_no := in_modul_seri_no;
         v_hk_seri_no := in_hk_seri_no;
         v_cep_kayitli := in_cep_kayitli;
         v_vatandaslikno := NULL;
         v_sitevillablokadedi := isitevillablokadedi;
         v_sitedaireblokadedi := isitedaireblokadedi;
         v_sitetoplamkonutadedi := isitetoplamkonutadedi;
         v_sitealtyapidestekbedeli := isitealtyapidestekbedeli;
         v_sozlesme_bitis_tarihi := isozlesme_bitis_tarihi;
         v_ciltno := iciltno;
         v_ailesirano := iailesirano;
         v_sirano := isirano;
         v_yts_personel := iyts_personel;
         v_banka_adi := ibanka_adi;
         v_fatura_eyalet := ifatura_eyalet;
         v_fatura_ulke := ifatura_ulke;
         vlnb_tipi_stok_kodu := ilnb_tipi_stok_kodu;
         v_sifre_text := isifre_text;
         v_harddisk_seri_no := TRIM (iharddisk_seri_no);            -- MKECECI
         v_modem_seri_no := TRIM (imodem_seri_no);                   --MKECECI
         v_rf_mdu_tipi := TRIM (irf_mdu_tipi);

         IF idevirli_outlet_location IS NOT NULL
         THEN
            v_devirli_outlet_location := idevirli_outlet_location;
         ELSE
            IF v_outlet_location IS NULL OR TRIM (v_outlet_location) = ''
            THEN
               BEGIN
                  SELECT outlet_location
                    INTO v_devirli_outlet_location
                    FROM wiz_equip
                   WHERE serial_number = isc_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_devirli_outlet_location := '';
               END;
            END IF;

            IF     (   v_outlet_location IS NULL
                    OR TRIM (v_outlet_location) = '')
               AND (   v_devirli_outlet_location IS NULL
                    OR v_devirli_outlet_location = '')
            THEN
               BEGIN
                  SELECT outlet_location
                    INTO v_devirli_outlet_location
                    FROM wiz_equip
                   WHERE serial_number = v_stb_seri_no;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_devirli_outlet_location := '';
               END;
            ELSE
               v_devirli_outlet_location := v_outlet_location;
            END IF;
         END IF;

         IF v_devirli_outlet_location IS NOT NULL
         THEN
            SELECT COUNT (1)
              INTO v_tmp
              FROM dp_account_no
             WHERE     account_no = v_uye_no
                   AND outlet_location = v_devirli_outlet_location;

            IF v_outlet_location IS NULL AND v_tmp = 0
            THEN
               v_outlet_location := v_devirli_outlet_location;
            END IF;
         END IF;

         SELECT COUNT (1)
           INTO v_validfranchise
           FROM (SELECT COLUMN_VALUE AS franchise
                   FROM TABLE (wiz_fran_sys_pack.getvalidfranchiselist (
                                  iuye_no,
                                  v_bayi_kodu,
                                  v_service_address_id,
                                  '',
                                  '')))
          WHERE franchise = ifranchise_code;

         --         IF v_validfranchise = 0
         --         THEN
         --            durum :=
         --               'FRANCHISE BILGISI UYUMSUZ.' || CHR (13)
         --               || 'FRANCHISE,UYE FRANCHISE,ADRES FRANCHISE,BAYI FRANCHISE BILGILERI UYUMLU OLMALIDIR.';
         --            RETURN;
         --         END IF;

         IF TRIM (v_stb_tipi) = '-1'
         THEN
            durum := 'SÖZLESMEDEN ÜYE STB TIPI BULUNAMADI.';
            RETURN;
         END IF;

         -- Ekipman modül kontrol...
         FOR rec_kontrat_ekipman_kontrol IN cur_kontrat_ekipman_kontrol
         LOOP
            --IF rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'MODÜL' AND in_stb_tipi = 'LG' AND in_modul_seri_no = ''
            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'MODÜL'
               AND in_modul_seri_no = ''
            THEN
               durum := 'Bu kampanyada modül zorunludur.';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'KUTU'
               AND istb_seri_no = ''
            THEN
               durum := 'Bu kampanyada kutu zorunludur.';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'KART'
               AND isc_seri_no = ''
            THEN
               durum := 'Bu kampanyada kart zorunludur.';
               RETURN;
            END IF;

            --MKECECI HARDDISK - MODEM gelistirmeleri
            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'HARDDİSK'
               AND v_harddisk_seri_no = ''
            THEN
               durum := 'Bu kampanyada hard disk zorunludur';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'MODEM'
               AND v_harddisk_seri_no = ''
            THEN
               durum := 'Bu kampanyada modem zorunludur';
               RETURN;
            END IF;
         --MKECECI HARDDISK - MOCEM gelistirmeleri
         END LOOP;

         --kayit aktarilma tarihini set et...
         IF v_status = '30'
         THEN
            v_kayit_aktarilma_tarihi := SYSDATE;
         ELSE
            v_kayit_aktarilma_tarihi := NULL;
         END IF;

         IF v_kon_gel_tipi IS NOT NULL AND TRIM (v_kon_gel_tipi) IS NOT NULL
         THEN
            BEGIN
               SELECT listeden_gizle, aciklama
                 INTO v_listeden_gizle, v_gelen_kontrat_adi
                 FROM pr_form_gelis_tipi
                WHERE kod = v_kon_gel_tipi AND form_tipi = '1';

               IF v_listeden_gizle = 'E'
               THEN
                  durum :=
                        'Kontrat gelis tipi: '
                     || v_gelen_kontrat_adi
                     || ' olarak girilemez. Kullanimdan kaldirilmis kontrat tipi.';
                  RETURN;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  durum := 'Tanimsiz kontrat gelis tipi. ';
                  RETURN;
            END;
         END IF;

         SELECT dbs_dba.yk_dp_kontrat_id_seq.NEXTVAL
           INTO v_yk_dp_kontrat_id
           FROM DUAL;

         INSERT INTO yk_dp_kontrat (sozlesme_tipi,
                                    is_yeri_yetkilisi_1,
                                    is_yeri_yetkilisi_2,
                                    digikutu_bagli_tel,
                                    dwelling_type,
                                    billing_frequency,
                                    ruhsat_yeri_id,
                                    ruhsat_tarihi,
                                    ruhsat_verilme_ili,
                                    ruhsat_sicil_no,
                                    ruhsat_belediye,
                                    faaliyet_konusu,
                                    fatura_apt_adi,
                                    fatura_blok,
                                    fatura_apt_no,
                                    fatura_semt,
                                    fatura_ilce,
                                    fatura_il,
                                    fatura_eyalet,
                                    fatura_ulke,
                                    fatura_daire_no,
                                    fatura_posta_kodu,
                                    mdu_ceki,
                                    mdu_bu_ceki,
                                    teknisyen_kodu,
                                    daire_sayisi,
                                    kat_sayisi,
                                    stb_seri_no,
                                    sc_seri_no,
                                    telefon_ceki,
                                    kk_tipi,
                                    kk_no,
                                    kk_son_tarihi,
                                    bayi_kodu,
                                    kon_gel_tipi,
                                    building_id,
                                    service_address_id,
                                    giris_tarihi,
                                    servis_tarihi,
                                    revizyon,
                                    batch,
                                    its_kayit_no,
                                    status,
                                    kayit_aktarilma_tarihi,
                                    giren_kullanici,
                                    son_islem_yapan_kullanici,
                                    uye_tipi,
                                    kimlik_cinsi,
                                    bina_tipi,
                                    hub_code,
                                    prospect_number,
                                    franchise_code,
                                    tuttugu_takim_kodu,
                                    degistirme_tarihi,
                                    campaign_code,
                                    vip,
                                    sozlesme_no,
                                    sozlesme_tarihi,
                                    yeni_mdu_no,
                                    eski_mdu_no,
                                    is_emri_no,
                                    uye_no,
                                    eski_yeni_ceki,
                                    ad,
                                    soyad,
                                    anne_kizlik_soyad,
                                    dogum_yeri,
                                    dogum_tarihi,
                                    cinsiyet,
                                    meslek,
                                    meslek_id,
                                    kimlik_yeri,
                                    kimlik_seri_no,
                                    kimlik_kayit_no,
                                    kimlik_tarihi,
                                    tabiyet,
                                    vergi_dairesi,
                                    vergi_no,
                                    home_country_tel_code,
                                    ev_tel_alan,
                                    ev_tel_prefix,
                                    ev_tel_no,
                                    work_country_tel_code,
                                    is_tel_alan,
                                    is_tel_prefix,
                                    is_tel_no,
                                    is_tel_dahili,
                                    mobile_country_tel_code,
                                    cep_tel_alan,
                                    cep_tel_prefix,
                                    cep_tel_no,
                                    fax_country_tel_code,
                                    fax_tel_alan,
                                    fax_tel_prefix,
                                    fax_tel_no,
                                    email,
                                    fatura_sirket_adi,
                                    fatura_mahalle,
                                    fatura_cadde,
                                    fatura_sokak,
                                    fatura_site_adi,
                                    digikart_varmi,
                                    mdu_sistem_no,
                                    mdu_yontem_no,
                                    billing_cycle,
                                    guvenlik_kodu,
                                    outlet_location,
                                    ekip_kodu,
                                    potansiyel_is_emri_id,
                                    stb_tipi,
                                    anne_adi,
                                    baba_adi,
                                    nufusa_kayitli_ilcesi,
                                    nufusa_kayitli_ili,
                                    abone_ozellik_kodu,
                                    uydu_tipi,
                                    modul_tipi,
                                    ekipman_kutu_tipi,
                                    modul_seri_no,
                                    hk_seri_no,
                                    cep_kayitli,
                                    cilt_no,
                                    aile_sira_no,
                                    sira_no,
                                    site_villa_blok_adedi,
                                    site_daire_blok_adedi,
                                    site_toplam_konut_adedi,
                                    site_altyapi_destek_bedeli,
                                    sozlesme_bitis_tarihi,
                                    yts_personel,
                                    banka_adi,
                                    tc_kimlik_no,
                                    devirli_outlet_location,
                                    malzeme_onayli,
                                    yk_dp_kontrat_id,
                                    lnb_tipi_stok_id,
                                    sifre_text,
                                    harddisk_seri_no,
                                    modem_seri_no)
              VALUES (v_sozlesme_tipi,
                      v_is_yeri_yetkilisi_1,
                      v_is_yeri_yetkilisi_2,
                      v_digikutu_bagli_tel,
                      v_dwelling_type,
                      v_billing_frequency,
                      v_ruhsat_yeri_id,
                      v_ruhsat_tarihi,
                      v_ruhsat_verilme_ili,
                      v_ruhsat_sicil_no,
                      v_ruhsat_belediye,
                      v_faaliyet_konusu,
                      v_fatura_apt_adi,
                      v_fatura_blok,
                      v_fatura_apt_no,
                      v_fatura_semt,
                      v_fatura_ilce,
                      v_fatura_il,
                      v_fatura_eyalet,
                      v_fatura_ulke,
                      v_fatura_daire_no,
                      v_fatura_posta_kodu,
                      v_mdu_ceki,
                      v_mdu_bu_ceki,
                      v_teknisyen_kodu,
                      v_daire_sayisi,
                      v_kat_sayisi,
                      v_stb_seri_no,
                      v_sc_seri_no,
                      v_telefon_ceki,
                      v_kk_tipi,
                      v_kk_no,
                      v_kk_son_tarihi,
                      v_bayi_kodu,
                      v_kon_gel_tipi,
                      v_building_id,
                      v_service_address_id,
                      SYSDATE,
                      v_servis_tarihi,
                      v_revizyon,
                      v_batch,
                      v_its_kayit_no,
                      v_status,
                      v_kayit_aktarilma_tarihi,
                      v_giren_kullanici,
                      v_giren_kullanici,
                      v_uye_tipi,
                      v_kimlik_cinsi,
                      v_bina_tipi,
                      v_hub_code,
                      v_prospect_number,
                      v_franchise_code,
                      v_tuttugu_takim_kodu,
                      SYSDATE,
                      v_campaign_code,
                      v_vip,
                      v_sozlesme_no,
                      v_sozlesme_tarihi,
                      v_yeni_mdu_no,
                      v_eski_mdu_no,
                      v_is_emri_no,
                      v_uye_no,
                      v_eski_yeni_ceki,
                      v_ad,
                      v_soyad,
                      v_anne_kizlik_soyad,
                      v_dogum_yeri,
                      v_dogum_tarihi,
                      v_cinsiyet,
                      v_meslek,
                      v_meslek_id,
                      v_kimlik_yeri,
                      v_kimlik_seri_no,
                      v_kimlik_kayit_no,
                      v_kimlik_tarihi,
                      v_tabiyet,
                      v_vergi_dairesi,
                      v_vergi_no,
                      v_ev_tel_ulke_alan,
                      v_ev_tel_alan,
                      v_ev_tel_prefix,
                      v_ev_tel_no,
                      v_is_tel_ulke_alan,
                      v_is_tel_alan,
                      v_is_tel_prefix,
                      v_is_tel_no,
                      v_is_tel_dahili,
                      v_cep_tel_ulke_alan,
                      v_cep_tel_alan,
                      v_cep_tel_prefix,
                      v_cep_tel_no,
                      v_fax_tel_ulke_alan,
                      v_fax_tel_alan,
                      v_fax_tel_prefix,
                      v_fax_tel_no,
                      v_email,
                      v_fatura_sirket_adi,
                      v_fatura_mahalle,
                      v_fatura_cadde,
                      v_fatura_sokak,
                      v_fatura_site_adi,
                      v_digikart_var_mi,
                      v_mdu_sistem_no,
                      v_mdu_yontem_no,
                      v_billing_cycle,
                      v_guvenlik_kodu,
                      v_outlet_location,
                      v_ekip_kodu,
                      v_potansiyel_is_emri_id,
                      v_stb_tipi,
                      v_anne_adi,
                      v_baba_adi,
                      v_nufusa_kayitli_ilcesi,
                      v_nufusa_kayitli_ili,
                      v_abone_ozellik_kodu,
                      v_uydu_tipi,
                      v_modul_tipi,
                      v_ekipman_kutu_tipi,
                      v_modul_seri_no,
                      v_hk_seri_no,
                      v_cep_kayitli,
                      v_ciltno,
                      v_ailesirano,
                      v_sirano,
                      v_sitevillablokadedi,
                      v_sitedaireblokadedi,
                      v_sitetoplamkonutadedi,
                      v_sitealtyapidestekbedeli,
                      v_sozlesme_bitis_tarihi,
                      v_yts_personel,
                      v_banka_adi,
                      ivatandaslikno,
                      v_devirli_outlet_location,
                      imalzeme_onayli,
                      v_yk_dp_kontrat_id,
                      vlnb_tipi_stok_kodu,
                      v_sifre_text,
                      v_harddisk_seri_no,
                      v_modem_seri_no);                              --MKECECI

         IF TRIM (v_ts_sifre_id) <> ''
         THEN
            UPDATE lg_teknik_servis_sifre
               SET sozlesme_no = v_sozlesme_no
             WHERE id = v_ts_sifre_id;
         ELSIF TRIM (v_its_kayit_no) <> ''
         THEN
            UPDATE lg_teknik_servis_sifre
               SET sozlesme_no = v_sozlesme_no
             WHERE otorizasyon_no = v_its_kayit_no;
         END IF;

         /*v_status durumuna göre islemler yapiliyor.*/
         IF v_status = '40'
         THEN
            IF v_sozlesme_tipi <> '5'
            THEN
               log_pack.lg_abone_islem_takip_insert (
                  v_uye_no,
                  v_sozlesme_no || ',' || v_outlet_location,
                  v_sc_seri_no,
                  '53',
                  v_giren_kullanici,
                  v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := 'log_pack' || v_sonuc;
                  RETURN;
               END IF;
            ELSE
               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
                  THEN
                     log_pack.lg_abone_islem_takip_insert (
                        v_uye_no,
                        v_sozlesme_no || ',' || v_outlet_location,
                        rec_kontrat_ekipman.kart_seri_no,
                        '53',
                        v_giren_kullanici,
                        v_sonuc);
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'log_pack' || v_sonuc;
                     RETURN;
                  END IF;
               END LOOP;
            END IF;
         ELSIF v_status = '80'
         THEN
            IF v_sozlesme_tipi <> '5'
            THEN
               BEGIN
                  SELECT co_kullanici.wiz_operator_id
                    INTO v_wiz_operator_id
                    FROM co_kullanici
                   WHERE co_kullanici.kod = igiren_kullanici;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     durum := 'HATALI KULLANICI KODU ';
                     RETURN;
               END;

               SELECT COUNT (1)
                 INTO v_tmp
                 FROM dp_account_no
                WHERE     account_no = v_uye_no
                      AND outlet_location = v_devirli_outlet_location;

               IF v_tmp = 0
               THEN
                  insert_dpaccountno (v_uye_no,
                                      v_sozlesme_no,
                                      v_outlet_location,
                                      v_bayi_kodu,
                                      v_sozlesme_tarihi,
                                      v_servis_tarihi,
                                      v_wiz_operator_id,
                                      v_kon_gel_tipi,
                                      v_mdu_bu_ceki,
                                      v_campaign_code,
                                      v_potansiyel_is_emri_id,
                                      v_sonuc,
                                      v_stb_tipi,
                                      v_yk_dp_kontrat_id,
                                      vlnb_tipi_stok_kodu);

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'INSERT_DPACCOUNTNO3 :' || v_sonuc;
                     RETURN;
                  END IF;
               END IF;

               log_pack.lg_abone_islem_takip_insert (
                  v_uye_no,
                  v_sozlesme_no || ',' || v_outlet_location,
                  v_sc_seri_no,
                  '54',
                  v_giren_kullanici,
                  v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := 'log_pack' || v_sonuc;
                  RETURN;
               END IF;
            ELSE
               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
                  THEN
                     log_pack.lg_abone_islem_takip_insert (
                        v_uye_no,
                        v_sozlesme_no || ',' || v_outlet_location,
                        rec_kontrat_ekipman.kart_seri_no,
                        '54',
                        v_giren_kullanici,
                        v_sonuc);
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'log_pack' || v_sonuc;
                     RETURN;
                  END IF;
               END LOOP;
            END IF;

            fatura.etc_kontrol_pack.kontrat_ekle_degistir (
               v_uye_no,
               v_devirli_outlet_location,
               v_giren_kullanici,
               v_sonuc,
               durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.etc_kontrol_pack.KONTRAT_EKLE_DEGISTIR :' || durum;
               RETURN;
            END IF;

            --ogm: Taahhut islemi
            fatura.taa_taahhut_pack.abone_taahhut_kontrol (
               v_uye_no,
               v_devirli_outlet_location,
               'SI',
               v_sozlesme_no,
               v_giren_kullanici,
               v_sonuc,
               durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.taa_taahhut_pack.abone_taahhut_kontrol :' || durum;
               RETURN;
            END IF;

            /* ogm: ITTP Integration Start*/
            billing_dbs_int.onl_agreement_ittp_pkg.integrate_agreement (
               i_dbs_yk_dp_kontrat_id   => v_yk_dp_kontrat_id,
               i_dbs_account_number     => v_uye_no,
               o_result_type            => v_ittp_result_type,
               o_result_code            => v_ittp_result_code,
               o_result_message         => v_ittp_result_message);

            IF v_ittp_result_type = 1
            THEN
               durum := v_ittp_result_code || ':' || v_ittp_result_message;
               RETURN;
            END IF;

            /* ogm: ITTP Integration End*/

            /*27042010 Eger uye kontrat_aktivasyon_pack ile eklenmis ise ve üyede devir islemi yapmis ise o durumda
                servis ve ppv alamaz özelliklerini kaldiriyoruz.*/
            SELECT COUNT (1)
              INTO v_tmp
              FROM yk_dp_kontrat
             WHERE     uye_no = v_uye_no
                   AND devirli_outlet_location = v_devirli_outlet_location
                   AND status IN (30, 80)
                   AND campaign_code NOT IN (SELECT kontrat_kmp_kodu
                                               FROM yk_dp_kmp_akt_gereksinim);

            IF v_tmp > 0
            THEN
               SELECT COUNT (1)
                 INTO v_tmp
                 FROM mb_abone_ozellik mb
                WHERE     mb.account_number = v_uye_no --AND mb.outlet_location = v_devirli_outlet_location
                      AND mb.abone_ozellik_kodu = 129;

               IF v_tmp > 0
               THEN
                  abone_detay_pack.mb_abone_ozellik_delete (
                     v_uye_no,
                     NULL,
                     129,
                     v_giren_kullanici,
                     durum);

                  IF durum <> '0'
                  THEN
                     durum :=
                           'Üye PPV satin alamaz özelligi silinemedi. :'
                        || durum;
                     RETURN;
                  END IF;
               END IF;

               SELECT COUNT (1)
                 INTO v_tmp
                 FROM mb_abone_ozellik mb
                WHERE     mb.account_number = v_uye_no --AND mb.outlet_location = v_devirli_outlet_location
                      AND mb.abone_ozellik_kodu = 182;

               IF v_tmp > 0
               THEN
                  abone_detay_pack.mb_abone_ozellik_delete (
                     v_uye_no,
                     NULL,
                     182,
                     v_giren_kullanici,
                     durum);

                  IF durum <> '0'
                  THEN
                     durum :=
                        'Üye Servis alamaz özelligi silinemedi. :' || durum;
                     RETURN;
                  END IF;
               END IF;
            END IF;
         --sms e atma ISlemI
         ELSIF v_status = '30'
         THEN
            v_vatandaslikno := ivatandaslikno;
            --            SELECT DECODE (COUNT (1), 0, 'H', 'E')
            --              INTO v_tc_kimlik_no_zorunlu
            --              FROM (SELECT COLUMN_VALUE AS franchise
            --                      FROM TABLE (split_table_fnc (dbs_sabit ('TC_KIMLIK_NO_ZORUNLU'))))
            --             WHERE franchise = v_franchise_code;
            v_tc_kimlik_no_zorunlu :=
               webrequest_pack.tckn_zorunlu_mu (v_franchise_code,
                                                in_stb_tipi,
                                                v_uye_tipi,
                                                v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := v_sonuc;
               RETURN;
            END IF;

            --ayni cep telefonuyla 7 den fazla üyelik varsa uyari ver.
            SELECT COUNT (1)
              INTO v_count
              FROM mb_abone_telefon a
             WHERE     a.durum = 1
                   AND a.telefon_tipi = 3
                   AND    TRIM (a.ulke_kodu)
                       || TRIM (a.alan_kodu)
                       || TRIM (a.telefon_no) =
                             TRIM (v_cep_tel_ulke_alan)
                          || TRIM (v_cep_tel_alan)
                          || TRIM (v_cep_tel_prefix)
                          || TRIM (v_cep_tel_no)
                   AND EXISTS
                          (SELECT 1
                             FROM mb_outlet_takip b
                            WHERE     a.account_number = b.account_number
                                  AND b.outlet_in_tarihi IS NULL);

            IF     v_count >= 7
               AND yetki_pack.yetkisi_varmi (
                      v_giren_kullanici,
                      'ISLEM_UYELIK_AKTIVASYON_TEL_KISITI') = 0
            THEN
               durum :=
                  'Bu kisiye aktivasyon yapmak için bayi temsilcinize danisiniz..';
               RETURN;
            END IF;

            kontrat_pack.sms_ok (v_sozlesme_tipi,
                                 v_is_yeri_yetkilisi_1,
                                 v_is_yeri_yetkilisi_2,
                                 v_digikutu_bagli_tel,
                                 v_dwelling_type,
                                 v_billing_frequency,
                                 v_ruhsat_yeri_id,
                                 v_ruhsat_tarihi,
                                 v_ruhsat_verilme_ili,
                                 v_ruhsat_sicil_no,
                                 v_ruhsat_belediye,
                                 v_faaliyet_konusu,
                                 v_fatura_apt_adi,
                                 v_fatura_blok,
                                 v_fatura_apt_no,
                                 v_fatura_semt,
                                 v_fatura_ilce,
                                 v_fatura_il,
                                 v_fatura_eyalet,
                                 v_fatura_ulke,
                                 v_fatura_daire_no,
                                 v_fatura_posta_kodu,
                                 v_mdu_ceki,
                                 v_mdu_bu_ceki,
                                 v_teknisyen_kodu,
                                 v_daire_sayisi,
                                 v_kat_sayisi,
                                 v_stb_seri_no,
                                 v_sc_seri_no,
                                 v_telefon_ceki,
                                 v_kk_tipi,
                                 v_kk_no,
                                 v_kk_son_tarihi,
                                 v_bayi_kodu,
                                 v_kon_gel_tipi,
                                 v_building_id,
                                 v_service_address_id,
                                 v_servis_tarihi,
                                 v_revizyon,
                                 v_batch,
                                 v_its_kayit_no,
                                 v_status,
                                 v_giren_kullanici,
                                 v_uye_tipi,
                                 v_kimlik_cinsi,
                                 v_bina_tipi,
                                 v_hub_code,
                                 v_prospect_number,
                                 v_franchise_code,
                                 v_tuttugu_takim_kodu,
                                 v_campaign_code,
                                 v_vip,
                                 v_sozlesme_no,
                                 v_sozlesme_tarihi,
                                 v_yeni_mdu_no,
                                 v_eski_mdu_no,
                                 v_is_emri_no,
                                 v_uye_no,
                                 v_eski_yeni_ceki,
                                 v_ad,
                                 v_soyad,
                                 v_anne_kizlik_soyad,
                                 v_dogum_yeri,
                                 v_dogum_tarihi,
                                 v_cinsiyet,
                                 v_meslek,
                                 v_meslek_id,
                                 v_kimlik_yeri,
                                 v_kimlik_seri_no,
                                 v_kimlik_kayit_no,
                                 v_kimlik_tarihi,
                                 v_tabiyet,
                                 v_vergi_dairesi,
                                 v_vergi_no,
                                 v_ev_tel_ulke_alan,
                                 v_ev_tel_alan,
                                 v_ev_tel_prefix,
                                 v_ev_tel_no,
                                 v_is_tel_ulke_alan,
                                 v_is_tel_alan,
                                 v_is_tel_prefix,
                                 v_is_tel_no,
                                 v_is_tel_dahili,
                                 v_cep_tel_ulke_alan,
                                 v_cep_tel_alan,
                                 v_cep_tel_prefix,
                                 v_cep_tel_no,
                                 v_fax_tel_ulke_alan,
                                 v_fax_tel_alan,
                                 v_fax_tel_prefix,
                                 v_fax_tel_no,
                                 v_email,
                                 v_fatura_sirket_adi,
                                 v_fatura_mahalle,
                                 v_fatura_cadde,
                                 v_fatura_sokak,
                                 v_fatura_site_adi,
                                 v_digikart_var_mi,
                                 v_mdu_sistem_no,
                                 v_mdu_yontem_no,
                                 v_billing_cycle,
                                 v_guvenlik_kodu,
                                 v_outlet_location,
                                 v_potansiyel_is_emri_id,
                                 v_ts_sifre_id,
                                 v_anne_adi,
                                 v_baba_adi,
                                 v_nufusa_kayitli_ilcesi,
                                 v_nufusa_kayitli_ili,
                                 v_abone_ozellik_kodu,
                                 v_uydu_tipi,
                                 v_modul_tipi,
                                 v_ekipman_kutu_tipi,
                                 v_modul_seri_no,
                                 v_uye_no,
                                 v_sonuc,
                                 in_stb_tipi,
                                 v_vatandaslikno,
                                 v_ciltno,
                                 v_ailesirano,
                                 v_sirano,
                                 v_tc_kimlik_no_zorunlu,
                                 icheck_payment_order_status,
                                 v_uydu_tipi,
                                 v_yk_dp_kontrat_id,
                                 v_sifre_text,
                                 v_harddisk_seri_no,
                                 v_modem_seri_no,
                                 v_rf_mdu_tipi);                    -- MKECECI
            durum := v_sonuc;

            IF v_sonuc = '0' AND LTRIM (v_uye_no) IS NOT NULL
            THEN
               ouye_no := v_uye_no;
            ELSIF LTRIM (v_sonuc) <> '0'
            THEN
               durum := v_sonuc;
               RETURN;
            END IF;

            SELECT tc_kimlik_no
              INTO v_vatandaslikno
              FROM (  SELECT tc_kimlik_no
                        FROM (SELECT tc_kimlik_no
                                FROM mb_abone_detay_bilgi
                               WHERE     account_number = v_uye_no
                                     AND tc_kimlik_no_gecerli = 'V'
                              UNION ALL
                              SELECT NULL tc_kimlik_no FROM DUAL)
                    ORDER BY tc_kimlik_no NULLS LAST)
             WHERE ROWNUM = 1;

            UPDATE yk_dp_kontrat
               SET tc_kimlik_no = v_vatandaslikno
             WHERE sozlesme_no = v_sozlesme_no;

            -- AKTIVASYON ICIN GECMIS BORC SORGULA   SUBAT 2010 MUSLU
            IF v_vatandaslikno IS NOT NULL
            THEN
               tckn_ile_borcluluk_sorgulama (v_vatandaslikno,
                                             v_giren_kullanici,
                                             v_sonuc,
                                             v_eskiborc_mesaj);

               IF v_sonuc <> '0'
               THEN
                  durum := v_eskiborc_mesaj;
                  RETURN;
               END IF;
            END IF;

            --- KISI BILGI /ekipman bilgileri güncelleniyor..
            IF v_sozlesme_tipi = '5' OR v_sozlesme_tipi = '2'
            THEN
               kisi_bilgi_pack.transfer_from_kontrat (v_sozlesme_no, v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := v_sonuc;
                  RETURN;
               END IF;
            END IF;

            -- Cep register ise cep tesefonmu register islemi yapilir
            -- 0 ise Kayit edilmeyecek
            -- 1 ise kayit edilecek
            IF NVL (in_cep_kayitli, 0) = 1
            THEN
               abone_telefon_pack.abone_telefon_register_telno (
                  v_uye_no,
                  v_outlet_location,
                  3,                          --in_telefon_tipi (Cep telefonu)
                  v_cep_tel_ulke_alan,
                  v_cep_tel_alan,
                  TRIM (v_cep_tel_prefix) || TRIM (v_cep_tel_no),
                  v_giren_kullanici,
                  v_sonuc_tip,
                  v_sonuc_kod,
                  v_sonuc,
                  v_sonuc_aciklama);

               IF v_sonuc_tip <> 0
               THEN
                  IF v_sonuc_kod <> 'ERR266'
                  THEN
                     durum := v_sonuc;
                     RETURN;
                  END IF;
               END IF;
            END IF;

            BEGIN
               SELECT kutu_tipi
                 INTO v_ekipman_kutu_tipi
                 FROM eq_ekipman
                WHERE serial_number = v_stb_seri_no;

               UPDATE yk_dp_kontrat
                  SET ekipman_kutu_tipi = v_ekipman_kutu_tipi
                WHERE sozlesme_no = v_sozlesme_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            BEGIN
               SELECT ekipman_modul_tipi
                 INTO v_modul_tipi
                 FROM eq_ekipman
                WHERE serial_number = v_modul_seri_no;

               UPDATE yk_dp_kontrat
                  SET modul_tipi = v_modul_tipi
                WHERE sozlesme_no = v_sozlesme_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            IF v_sozlesme_tipi = '5'
            THEN
               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  IF rec_kontrat_ekipman.kutu_seri_no IS NOT NULL
                  THEN
                     BEGIN
                        SELECT kutu_tipi
                          INTO v_ekipman_kutu_tipi
                          FROM eq_ekipman
                         WHERE serial_number =
                                  rec_kontrat_ekipman.kutu_seri_no;

                        UPDATE yk_dp_kontrat
                           SET ekipman_kutu_tipi = v_ekipman_kutu_tipi
                         WHERE sozlesme_no = v_sozlesme_no;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END IF;

                  IF rec_kontrat_ekipman.modul_seri_no IS NOT NULL
                  THEN
                     BEGIN
                        SELECT ekipman_modul_tipi
                          INTO v_modul_tipi
                          FROM eq_ekipman
                         WHERE serial_number =
                                  rec_kontrat_ekipman.modul_seri_no;

                        UPDATE yk_dp_kontrat
                           SET modul_tipi = v_modul_tipi
                         WHERE sozlesme_no = v_sozlesme_no;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END IF;
               END LOOP;
            END IF;

            BEGIN
               SELECT tc_kimlik_no
                 INTO v_vatandaslikno
                 FROM mb_abone_detay_bilgi
                WHERE account_number = v_uye_no;

               UPDATE yk_dp_kontrat
                  SET tc_kimlik_no = v_vatandaslikno
                WHERE sozlesme_no = v_sozlesme_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            bt_uye_ts_pack.bt_uye_ts_guncel_feed (v_uye_no,
                                                  v_outlet_location,
                                                  v_teknisyen_kodu,
                                                  5,
                                                  'C',
                                                  NULL,         --IN_MEMO_KOD,
                                                  NULL,        --IN_SEBEP_KOD,
                                                  5,
                                                  v_giren_kullanici,
                                                  'KONTRAT',
                                                  durum);

            IF durum <> '0'
            THEN
               durum := 'Bt_Uye_Ts_Pack.BT_UYE_TS_GUNCEL_FEED :' || durum;
               RETURN;
            END IF;

            SELECT abbrev
              INTO v_abbrev
              FROM wiz_customer_type_codes
             WHERE customer_type = v_uye_tipi;

            IF TRIM (v_abbrev) = '2'
            THEN
               bt_uye_ts_pack.bt_uye_ts_guncel_feed (v_uye_no,
                                                     v_outlet_location,
                                                     v_teknisyen_kodu,
                                                     6,
                                                     'C',
                                                     NULL,      --IN_MEMO_KOD,
                                                     NULL,     --IN_SEBEP_KOD,
                                                     7,
                                                     v_giren_kullanici,
                                                     'KONTRAT',
                                                     durum);

               IF durum <> '0'
               THEN
                  durum := 'Bt_Uye_Ts_Pack.BT_UYE_TS_GUNCEL_FEED :' || durum;
                  RETURN;
               END IF;
            END IF;

            fatura.etc_kontrol_pack.kontrat_ekle_degistir (v_uye_no,
                                                           v_outlet_location,
                                                           v_giren_kullanici,
                                                           v_sonuc,
                                                           durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.etc_kontrol_pack.KONTRAT_EKLE_DEGISTIR :' || durum;
               RETURN;
            END IF;

            --ogm: Taahhut islemi
            fatura.taa_taahhut_pack.abone_taahhut_kontrol (v_uye_no,
                                                           v_outlet_location,
                                                           'SI',
                                                           v_sozlesme_no,
                                                           v_giren_kullanici,
                                                           v_sonuc,
                                                           durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.taa_taahhut_pack.abone_taahhut_kontrol :' || durum;
               RETURN;
            END IF;

            /* ogm: ITTP Integration Start*/
            billing_dbs_int.onl_agreement_ittp_pkg.integrate_agreement (
               i_dbs_yk_dp_kontrat_id   => v_yk_dp_kontrat_id,
               i_dbs_account_number     => v_uye_no,
               o_result_type            => v_ittp_result_type,
               o_result_code            => v_ittp_result_code,
               o_result_message         => v_ittp_result_message);

            IF v_ittp_result_type = 1
            THEN
               durum := v_ittp_result_code || ':' || v_ittp_result_message;
               RETURN;
            END IF;
         /* ogm: ITTP Integration End*/
         END IF;
      END IF;

      CLOSE yk_dp_kontrat_cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'YK_DP_KONTRAT_INSERT:' || SQLERRM;
   END;

   PROCEDURE yk_dp_kontrat_update (
      isozlesme_tipi                IN     yk_dp_kontrat.sozlesme_tipi%TYPE,
      iis_yeri_yetkilisi_1          IN     yk_dp_kontrat.is_yeri_yetkilisi_1%TYPE,
      iis_yeri_yetkilisi_2          IN     yk_dp_kontrat.is_yeri_yetkilisi_2%TYPE,
      idigikutu_bagli_tel           IN     yk_dp_kontrat.digikutu_bagli_tel%TYPE,
      idwelling_type                IN     yk_dp_kontrat.dwelling_type%TYPE,
      ibilling_frequency            IN     yk_dp_kontrat.billing_frequency%TYPE,
      iruhsat_yeri_id               IN     yk_dp_kontrat.ruhsat_yeri_id%TYPE,
      iruhsat_tarihi                IN     yk_dp_kontrat.ruhsat_tarihi%TYPE,
      iruhsat_verilme_ili           IN     yk_dp_kontrat.ruhsat_verilme_ili%TYPE,
      iruhsat_sicil_no              IN     yk_dp_kontrat.ruhsat_sicil_no%TYPE,
      iruhsat_belediye              IN     VARCHAR2,
      ifaaliyet_konusu              IN     yk_dp_kontrat.faaliyet_konusu%TYPE,
      ifatura_apt_adi               IN     yk_dp_kontrat.fatura_apt_adi%TYPE,
      ifatura_blok                  IN     yk_dp_kontrat.fatura_blok%TYPE,
      ifatura_apt_no                IN     yk_dp_kontrat.fatura_apt_no%TYPE,
      ifatura_semt                  IN     yk_dp_kontrat.fatura_semt%TYPE,
      ifatura_ilce                  IN     yk_dp_kontrat.fatura_ilce%TYPE,
      ifatura_il                    IN     yk_dp_kontrat.fatura_il%TYPE,
      ifatura_eyalet                IN     yk_dp_kontrat.fatura_eyalet%TYPE,
      ifatura_ulke                  IN     yk_dp_kontrat.fatura_ulke%TYPE,
      ifatura_daire_no              IN     yk_dp_kontrat.fatura_daire_no%TYPE,
      ifatura_posta_kodu            IN     yk_dp_kontrat.fatura_posta_kodu%TYPE,
      imdu_ceki                     IN     yk_dp_kontrat.mdu_ceki%TYPE,
      imdu_bu_ceki                  IN     yk_dp_kontrat.mdu_bu_ceki%TYPE,
      iteknisyen_kodu               IN     yk_dp_kontrat.teknisyen_kodu%TYPE,
      idaire_sayisi                 IN     yk_dp_kontrat.daire_sayisi%TYPE,
      ikat_sayisi                   IN     yk_dp_kontrat.kat_sayisi%TYPE,
      istb_seri_no                  IN     yk_dp_kontrat.stb_seri_no%TYPE,
      isc_seri_no                   IN     yk_dp_kontrat.sc_seri_no%TYPE,
      itelefon_ceki                 IN     yk_dp_kontrat.telefon_ceki%TYPE,
      ikk_tipi                      IN     yk_dp_kontrat.kk_tipi%TYPE,
      ikk_no                        IN     yk_dp_kontrat.kk_no%TYPE,
      ikk_son_tarihi                IN     yk_dp_kontrat.kk_son_tarihi%TYPE,
      ibayi_kodu                    IN     yk_dp_kontrat.bayi_kodu%TYPE,
      ikon_gel_tipi                 IN     yk_dp_kontrat.kon_gel_tipi%TYPE,
      ibuilding_id                  IN     yk_dp_kontrat.building_id%TYPE,
      iservice_address_id           IN     yk_dp_kontrat.service_address_id%TYPE,
      iservis_tarihi                IN     yk_dp_kontrat.servis_tarihi%TYPE,
      irevizyon                     IN     yk_dp_kontrat.revizyon%TYPE,
      ibatch                        IN     yk_dp_kontrat.batch%TYPE,
      iits_kayit_no                 IN     yk_dp_kontrat.its_kayit_no%TYPE,
      istatus                       IN     yk_dp_kontrat.status%TYPE,
      igiren_kullanici              IN     yk_dp_kontrat.giren_kullanici%TYPE,
      iuye_tipi                     IN     yk_dp_kontrat.uye_tipi%TYPE,
      ikimlik_cinsi                 IN     yk_dp_kontrat.kimlik_cinsi%TYPE,
      ibina_tipi                    IN     yk_dp_kontrat.bina_tipi%TYPE,
      ihub_code                     IN     yk_dp_kontrat.hub_code%TYPE,
      iprospect_number              IN     yk_dp_kontrat.prospect_number%TYPE,
      ifranchise_code               IN     yk_dp_kontrat.franchise_code%TYPE,
      ituttugu_takim_kodu           IN     yk_dp_kontrat.tuttugu_takim_kodu%TYPE,
      icampaign_code                IN     yk_dp_kontrat.campaign_code%TYPE,
      ivip                          IN     yk_dp_kontrat.vip%TYPE,
      isozlesme_no                  IN     yk_dp_kontrat.sozlesme_no%TYPE,
      isozlesme_tarihi              IN     yk_dp_kontrat.sozlesme_tarihi%TYPE,
      iyeni_mdu_no                  IN     yk_dp_kontrat.yeni_mdu_no%TYPE,
      ieski_mdu_no                  IN     yk_dp_kontrat.eski_mdu_no%TYPE,
      iis_emri_no                   IN     yk_dp_kontrat.is_emri_no%TYPE,
      iuye_no                       IN     yk_dp_kontrat.uye_no%TYPE,
      ieski_yeni_ceki               IN     yk_dp_kontrat.eski_yeni_ceki%TYPE,
      iad                           IN     yk_dp_kontrat.ad%TYPE,
      isoyad                        IN     yk_dp_kontrat.soyad%TYPE,
      ianne_kizlik_soyad            IN     yk_dp_kontrat.anne_kizlik_soyad%TYPE,
      idogum_yeri                   IN     yk_dp_kontrat.dogum_yeri%TYPE,
      idogum_tarihi                 IN     yk_dp_kontrat.dogum_tarihi%TYPE,
      icinsiyet                     IN     yk_dp_kontrat.cinsiyet%TYPE,
      imeslek                       IN     yk_dp_kontrat.meslek%TYPE,
      imeslek_id                    IN     yk_dp_kontrat.meslek_id%TYPE,
      ikimlik_yeri                  IN     yk_dp_kontrat.kimlik_yeri%TYPE,
      ikimlik_seri_no               IN     yk_dp_kontrat.kimlik_seri_no%TYPE,
      ikimlik_kayit_no              IN     yk_dp_kontrat.kimlik_kayit_no%TYPE,
      ikimlik_tarihi                IN     yk_dp_kontrat.kimlik_tarihi%TYPE,
      itabiyet                      IN     yk_dp_kontrat.tabiyet%TYPE,
      ivergi_dairesi                IN     yk_dp_kontrat.vergi_dairesi%TYPE,
      ivergi_no                     IN     yk_dp_kontrat.vergi_no%TYPE,
      iev_tel_ulke_alan             IN     yk_dp_kontrat.home_country_tel_code%TYPE,
      iev_tel_alan                  IN     yk_dp_kontrat.ev_tel_alan%TYPE,
      iev_tel_prefix                IN     yk_dp_kontrat.ev_tel_prefix%TYPE,
      iev_tel_no                    IN     yk_dp_kontrat.ev_tel_no%TYPE,
      iis_tel_ulke_alan             IN     yk_dp_kontrat.work_country_tel_code%TYPE,
      iis_tel_alan                  IN     yk_dp_kontrat.is_tel_alan%TYPE,
      iis_tel_prefix                IN     yk_dp_kontrat.is_tel_prefix%TYPE,
      iis_tel_no                    IN     yk_dp_kontrat.is_tel_no%TYPE,
      iis_tel_dahili                IN     yk_dp_kontrat.is_tel_dahili%TYPE,
      icep_tel_ulke_alan            IN     yk_dp_kontrat.mobile_country_tel_code%TYPE,
      icep_tel_alan                 IN     yk_dp_kontrat.cep_tel_alan%TYPE,
      icep_tel_prefix               IN     yk_dp_kontrat.cep_tel_prefix%TYPE,
      icep_tel_no                   IN     yk_dp_kontrat.cep_tel_no%TYPE,
      ifax_tel_ulke_alan            IN     yk_dp_kontrat.fax_country_tel_code%TYPE,
      ifax_tel_alan                 IN     yk_dp_kontrat.fax_tel_alan%TYPE,
      ifax_tel_prefix               IN     yk_dp_kontrat.fax_tel_prefix%TYPE,
      ifax_tel_no                   IN     yk_dp_kontrat.fax_tel_no%TYPE,
      iemail                        IN     yk_dp_kontrat.email%TYPE,
      ifatura_sirket_adi            IN     yk_dp_kontrat.fatura_sirket_adi%TYPE,
      ifatura_mahalle               IN     yk_dp_kontrat.fatura_mahalle%TYPE,
      ifatura_cadde                 IN     yk_dp_kontrat.fatura_cadde%TYPE,
      ifatura_sokak                 IN     yk_dp_kontrat.fatura_sokak%TYPE,
      ifatura_site_adi              IN     yk_dp_kontrat.fatura_site_adi%TYPE,
      idigikart_var_mi              IN     yk_dp_kontrat.digikart_varmi%TYPE,
      imdu_sistem_no                IN     yk_dp_kontrat.mdu_sistem_no%TYPE,
      imdu_yontem_no                IN     yk_dp_kontrat.mdu_yontem_no%TYPE,
      ibilling_cycle                IN     yk_dp_kontrat.billing_cycle%TYPE,
      iguvenlik_kodu                IN     yk_dp_kontrat.guvenlik_kodu%TYPE,
      ioutlet_location              IN     yk_dp_kontrat.outlet_location%TYPE,
      iekip_kodu                    IN     yk_dp_kontrat.ekip_kodu%TYPE,
      ipotansiyel_is_emri_id        IN     yk_dp_kontrat.potansiyel_is_emri_id%TYPE,
      in_anne_adi                   IN     yk_dp_kontrat.anne_adi%TYPE,
      in_baba_adi                   IN     yk_dp_kontrat.baba_adi%TYPE,
      in_nufusa_kayitli_ilcesi      IN     yk_dp_kontrat.nufusa_kayitli_ilcesi%TYPE,
      in_nufusa_kayitli_ili         IN     yk_dp_kontrat.nufusa_kayitli_ili%TYPE,
      in_abone_ozellik_kodu         IN     yk_dp_kontrat.abone_ozellik_kodu%TYPE,
      in_uydu_tipi                  IN     yk_dp_kontrat.uydu_tipi%TYPE,
      in_modul_tipi                 IN     yk_dp_kontrat.modul_tipi%TYPE,
      in_ekipman_kutu_tipi          IN     yk_dp_kontrat.ekipman_kutu_tipi%TYPE,
      in_modul_seri_no              IN     yk_dp_kontrat.modul_seri_no%TYPE,
      ouye_no                          OUT yk_dp_kontrat.uye_no%TYPE,
      out_taa_uyari                    OUT VARCHAR2,
      durum                            OUT VARCHAR2,
      in_stb_tipi                   IN     yk_dp_kontrat.stb_tipi%TYPE,
      in_hk_seri_no                 IN     yk_dp_kontrat.hk_seri_no%TYPE,
      in_cep_kayitli                IN     yk_dp_kontrat.cep_kayitli%TYPE,
      ilnb_tipi_stok_kodu           IN     VARCHAR2,
      iciltno                       IN     yk_dp_kontrat.cilt_no%TYPE,
      iailesirano                   IN     yk_dp_kontrat.aile_sira_no%TYPE,
      isirano                       IN     yk_dp_kontrat.sira_no%TYPE,
      isitevillablokadedi           IN     yk_dp_kontrat.site_villa_blok_adedi%TYPE,
      isitedaireblokadedi           IN     yk_dp_kontrat.site_daire_blok_adedi%TYPE,
      isitetoplamkonutadedi         IN     yk_dp_kontrat.site_toplam_konut_adedi%TYPE,
      isitealtyapidestekbedeli      IN     yk_dp_kontrat.site_altyapi_destek_bedeli%TYPE,
      isozlesme_bitis_tarihi        IN     yk_dp_kontrat.sozlesme_bitis_tarihi%TYPE,
      iyts_personel                 IN     yk_dp_kontrat.yts_personel%TYPE,
      icheck_payment_order_status   IN     NUMBER DEFAULT 1,
      ivatandaslikno                IN     yk_dp_kontrat.tc_kimlik_no%TYPE,
      ibanka_adi                    IN     yk_dp_kontrat.banka_adi%TYPE,
      idevirli_outlet_location      IN     yk_dp_kontrat.devirli_outlet_location%TYPE,
      ieski_sozlesme_no             IN     yk_dp_kontrat.sozlesme_no%TYPE,
      imalzeme_onayli               IN     yk_dp_kontrat.malzeme_onayli%TYPE,
      isifre_text                   IN     yk_dp_kontrat.sifre_text%TYPE,
      iharddisk_seri_no             IN     yk_dp_kontrat.harddisk_seri_no%TYPE, --MKECECI
      imodem_seri_no                IN     yk_dp_kontrat.modem_seri_no%TYPE := NULL, -- MKECECI
      irf_mdu_tipi                  IN     mb_abone_detay_bilgi.rf_mdu_tipi%TYPE)
   IS
      /*OGM ittp integration variables*/
      v_ittp_result_type            NUMBER;
      v_ittp_result_code            VARCHAR2 (512);
      v_ittp_result_message         VARCHAR2 (32000);
      /*OGM ittp integration variables*/
      v_sozlesme_tipi               yk_dp_kontrat.sozlesme_tipi%TYPE;
      v_is_yeri_yetkilisi_1         yk_dp_kontrat.is_yeri_yetkilisi_1%TYPE;
      v_is_yeri_yetkilisi_2         yk_dp_kontrat.is_yeri_yetkilisi_2%TYPE;
      v_digikutu_bagli_tel          yk_dp_kontrat.digikutu_bagli_tel%TYPE;
      v_dwelling_type               yk_dp_kontrat.dwelling_type%TYPE;
      v_billing_frequency           yk_dp_kontrat.billing_frequency%TYPE;
      v_ruhsat_yeri_id              yk_dp_kontrat.ruhsat_yeri_id%TYPE;
      v_ruhsat_tarihi               yk_dp_kontrat.ruhsat_tarihi%TYPE;
      v_ruhsat_verilme_ili          yk_dp_kontrat.ruhsat_verilme_ili%TYPE;
      v_ruhsat_verilme_ili_ad       mb_abone_detay_bilgi.ruhsat_verilme_ili%TYPE;
      v_ruhsat_sicil_no             yk_dp_kontrat.ruhsat_sicil_no%TYPE;
      v_ruhsat_belediye             VARCHAR2 (50);
      v_faaliyet_konusu             yk_dp_kontrat.faaliyet_konusu%TYPE;
      v_fatura_apt_adi              yk_dp_kontrat.fatura_apt_adi%TYPE;
      v_fatura_blok                 yk_dp_kontrat.fatura_blok%TYPE;
      v_fatura_apt_no               yk_dp_kontrat.fatura_apt_no%TYPE;
      v_fatura_semt                 yk_dp_kontrat.fatura_semt%TYPE;
      v_fatura_ilce                 yk_dp_kontrat.fatura_ilce%TYPE;
      v_fatura_il                   yk_dp_kontrat.fatura_il%TYPE;
      v_fatura_daire_no             yk_dp_kontrat.fatura_daire_no%TYPE;
      v_fatura_posta_kodu           yk_dp_kontrat.fatura_posta_kodu%TYPE;
      v_mdu_ceki                    yk_dp_kontrat.mdu_ceki%TYPE;
      v_mdu_bu_ceki                 yk_dp_kontrat.mdu_bu_ceki%TYPE;
      v_teknisyen_kodu              yk_dp_kontrat.teknisyen_kodu%TYPE;
      v_daire_sayisi                yk_dp_kontrat.daire_sayisi%TYPE;
      v_kat_sayisi                  yk_dp_kontrat.kat_sayisi%TYPE;
      v_stb_seri_no                 yk_dp_kontrat.stb_seri_no%TYPE;
      v_sc_seri_no                  yk_dp_kontrat.sc_seri_no%TYPE;
      v_telefon_ceki                yk_dp_kontrat.telefon_ceki%TYPE;
      v_kk_tipi                     yk_dp_kontrat.kk_tipi%TYPE;
      v_kk_no                       yk_dp_kontrat.kk_no%TYPE;
      v_kk_son_tarihi               yk_dp_kontrat.kk_son_tarihi%TYPE;
      v_bayi_kodu                   yk_dp_kontrat.bayi_kodu%TYPE;
      v_kon_gel_tipi                yk_dp_kontrat.kon_gel_tipi%TYPE;
      v_prev_kon_gel_tipi           yk_dp_kontrat.kon_gel_tipi%TYPE;
      v_building_id                 yk_dp_kontrat.building_id%TYPE;
      v_service_address_id          yk_dp_kontrat.service_address_id%TYPE;
      v_servis_tarihi               yk_dp_kontrat.servis_tarihi%TYPE;
      v_revizyon                    yk_dp_kontrat.revizyon%TYPE;
      v_batch                       yk_dp_kontrat.batch%TYPE;
      v_its_kayit_no                yk_dp_kontrat.its_kayit_no%TYPE;
      v_status                      yk_dp_kontrat.status%TYPE;
      v_prev_status                 yk_dp_kontrat.status%TYPE;
      v_giren_kullanici             yk_dp_kontrat.giren_kullanici%TYPE;
      v_uye_tipi                    yk_dp_kontrat.uye_tipi%TYPE;
      v_kimlik_cinsi                yk_dp_kontrat.kimlik_cinsi%TYPE;
      v_bina_tipi                   yk_dp_kontrat.bina_tipi%TYPE;
      v_hub_code                    yk_dp_kontrat.hub_code%TYPE;
      v_prospect_number             yk_dp_kontrat.prospect_number%TYPE;
      v_franchise_code              yk_dp_kontrat.franchise_code%TYPE;
      v_tuttugu_takim_kodu          yk_dp_kontrat.tuttugu_takim_kodu%TYPE;
      v_campaign_code               yk_dp_kontrat.campaign_code%TYPE;
      v_vip                         yk_dp_kontrat.vip%TYPE;
      v_sozlesme_no                 yk_dp_kontrat.sozlesme_no%TYPE;
      v_sozlesme_tarihi             yk_dp_kontrat.sozlesme_tarihi%TYPE;
      v_yeni_mdu_no                 yk_dp_kontrat.yeni_mdu_no%TYPE;
      v_eski_mdu_no                 yk_dp_kontrat.eski_mdu_no%TYPE;
      v_is_emri_no                  yk_dp_kontrat.is_emri_no%TYPE;
      v_uye_no                      yk_dp_kontrat.uye_no%TYPE;
      v_eski_yeni_ceki              yk_dp_kontrat.eski_yeni_ceki%TYPE;
      v_ad                          yk_dp_kontrat.ad%TYPE;
      v_soyad                       yk_dp_kontrat.soyad%TYPE;
      v_anne_kizlik_soyad           yk_dp_kontrat.anne_kizlik_soyad%TYPE;
      v_dogum_yeri                  yk_dp_kontrat.dogum_yeri%TYPE;
      v_dogum_tarihi                yk_dp_kontrat.dogum_tarihi%TYPE;
      v_cinsiyet                    yk_dp_kontrat.cinsiyet%TYPE;
      v_meslek                      yk_dp_kontrat.meslek%TYPE;
      v_meslek_id                   yk_dp_kontrat.meslek_id%TYPE;
      v_kimlik_yeri                 yk_dp_kontrat.kimlik_yeri%TYPE;
      v_kimlik_seri_no              yk_dp_kontrat.kimlik_seri_no%TYPE;
      v_kimlik_kayit_no             yk_dp_kontrat.kimlik_kayit_no%TYPE;
      v_kimlik_tarihi               yk_dp_kontrat.kimlik_tarihi%TYPE;
      v_tabiyet                     yk_dp_kontrat.tabiyet%TYPE;
      v_vergi_dairesi               yk_dp_kontrat.vergi_dairesi%TYPE;
      v_vergi_no                    yk_dp_kontrat.vergi_no%TYPE;
      v_ev_tel_ulke_alan            yk_dp_kontrat.home_country_tel_code%TYPE;
      v_ev_tel_alan                 yk_dp_kontrat.ev_tel_alan%TYPE;
      v_ev_tel_prefix               yk_dp_kontrat.ev_tel_prefix%TYPE;
      v_ev_tel_no                   yk_dp_kontrat.ev_tel_no%TYPE;
      v_is_tel_ulke_alan            yk_dp_kontrat.work_country_tel_code%TYPE;
      v_is_tel_alan                 yk_dp_kontrat.is_tel_alan%TYPE;
      v_is_tel_prefix               yk_dp_kontrat.is_tel_prefix%TYPE;
      v_is_tel_no                   yk_dp_kontrat.is_tel_no%TYPE;
      v_is_tel_dahili               yk_dp_kontrat.is_tel_dahili%TYPE;
      v_cep_tel_ulke_alan           yk_dp_kontrat.mobile_country_tel_code%TYPE;
      v_cep_tel_alan                yk_dp_kontrat.cep_tel_alan%TYPE;
      v_cep_tel_prefix              yk_dp_kontrat.cep_tel_prefix%TYPE;
      v_cep_tel_no                  yk_dp_kontrat.cep_tel_no%TYPE;
      v_fax_tel_ulke_alan           yk_dp_kontrat.fax_country_tel_code%TYPE;
      v_fax_tel_alan                yk_dp_kontrat.fax_tel_alan%TYPE;
      v_fax_tel_prefix              yk_dp_kontrat.fax_tel_prefix%TYPE;
      v_fax_tel_no                  yk_dp_kontrat.fax_tel_no%TYPE;
      v_email                       yk_dp_kontrat.email%TYPE;
      v_fatura_sirket_adi           yk_dp_kontrat.fatura_sirket_adi%TYPE;
      v_fatura_mahalle              yk_dp_kontrat.fatura_mahalle%TYPE;
      v_fatura_cadde                yk_dp_kontrat.fatura_cadde%TYPE;
      v_fatura_sokak                yk_dp_kontrat.fatura_sokak%TYPE;
      v_fatura_site_adi             yk_dp_kontrat.fatura_site_adi%TYPE;
      v_kayit_aktarilma_tarihi      yk_dp_kontrat.kayit_aktarilma_tarihi%TYPE;
      v_digikart_var_mi             yk_dp_kontrat.digikart_varmi%TYPE;
      v_mdu_sistem_no               yk_dp_kontrat.mdu_sistem_no%TYPE;
      v_mdu_yontem_no               yk_dp_kontrat.mdu_yontem_no%TYPE;
      v_billing_cycle               yk_dp_kontrat.billing_cycle%TYPE;
      v_guvenlik_kodu               yk_dp_kontrat.guvenlik_kodu%TYPE;
      v_sonuc                       VARCHAR2 (255);
      v_outlet_location             yk_dp_kontrat.outlet_location%TYPE;
      v_ekip_kodu                   yk_dp_kontrat.ekip_kodu%TYPE;
      v_temp_ekip_kodu              yk_dp_kontrat.ekip_kodu%TYPE;
      v_ekip_tipi_kodu              bt_bayi_teknik_servis.tip_kodu%TYPE;
      v_potansiyel_is_emri_id       yk_dp_kontrat.potansiyel_is_emri_id%TYPE;
      v_count                       NUMBER (10);
      v_stb_tipi                    yk_dp_kontrat.stb_tipi%TYPE;
      v_anne_adi                    yk_dp_kontrat.anne_adi%TYPE;
      v_baba_adi                    yk_dp_kontrat.baba_adi%TYPE;
      v_nufusa_kayitli_ilcesi       yk_dp_kontrat.nufusa_kayitli_ilcesi%TYPE;
      v_nufusa_kayitli_ili          yk_dp_kontrat.nufusa_kayitli_ili%TYPE;
      v_abone_ozellik_kodu          yk_dp_kontrat.abone_ozellik_kodu%TYPE;
      v_uydu_tipi                   yk_dp_kontrat.uydu_tipi%TYPE;
      v_modul_tipi                  yk_dp_kontrat.modul_tipi%TYPE;
      v_ekipman_kutu_tipi           yk_dp_kontrat.ekipman_kutu_tipi%TYPE;
      v_modul_seri_no               yk_dp_kontrat.modul_seri_no%TYPE;
      v_abbrev                      wiz_customer_type_codes.abbrev%TYPE;
      v_hk_seri_no                  yk_dp_kontrat.hk_seri_no%TYPE;
      v_cep_kayitli                 yk_dp_kontrat.cep_kayitli%TYPE;
      v_sonuc_tip                   NUMBER;
      v_sonuc_kod                   VARCHAR2 (512);
      v_sonuc_cevap                 VARCHAR2 (512);
      v_sonuc_aciklama              VARCHAR2 (512);
      v_vatandaslikno               yk_dp_kontrat.tc_kimlik_no%TYPE;
      v_ciltno                      yk_dp_kontrat.cilt_no%TYPE;
      v_ailesirano                  yk_dp_kontrat.aile_sira_no%TYPE;
      v_sirano                      yk_dp_kontrat.sira_no%TYPE;
      v_sitevillablokadedi          yk_dp_kontrat.site_villa_blok_adedi%TYPE;
      v_sitedaireblokadedi          yk_dp_kontrat.site_daire_blok_adedi%TYPE;
      v_sitetoplamkonutadedi        yk_dp_kontrat.site_toplam_konut_adedi%TYPE;
      v_sitealtyapidestekbedeli     yk_dp_kontrat.site_altyapi_destek_bedeli%TYPE;
      v_sozlesme_bitis_tarihi       yk_dp_kontrat.sozlesme_bitis_tarihi%TYPE;
      v_yts_personel                yk_dp_kontrat.yts_personel%TYPE;
      v_banka_adi                   yk_dp_kontrat.banka_adi%TYPE;
      v_fatura_eyalet               yk_dp_kontrat.fatura_eyalet%TYPE;
      v_fatura_ulke                 yk_dp_kontrat.fatura_ulke%TYPE;
      v_validfranchise              NUMBER (1);
      v_devirli_outlet_location     yk_dp_kontrat.devirli_outlet_location%TYPE;
      v_lg_id                       lg_yk_dp_kontrat.id%TYPE;
      v_son_adim                    CHAR (1) := 'H';
      v_taa_uyari                   VARCHAR2 (512);
      v_tc_kimlik_no_zorunlu        VARCHAR2 (1);
      v_listeden_gizle              pr_form_gelis_tipi.listeden_gizle%TYPE;
      v_gelen_kontrat_adi           pr_form_gelis_tipi.aciklama%TYPE;
      vlnb_tipi_stok_kodu           VARCHAR2 (10);
      v_sifre_text                  yk_dp_kontrat.sifre_text%TYPE;
      v_harddisk_seri_no            yk_dp_kontrat.harddisk_seri_no%TYPE; --MKECECI
      v_modem_seri_no               yk_dp_kontrat.modem_seri_no%TYPE; --MKECECI
      v_rf_mdu_tipi                 mb_abone_detay_bilgi.rf_mdu_tipi%TYPE; --MKECECI

      CURSOR yk_dp_kontrat_cur (vsozlesme VARCHAR2)
      IS
             SELECT *
               FROM yk_dp_kontrat
              WHERE sozlesme_no = vsozlesme
         FOR UPDATE OF fatura_site_adi NOWAIT;

      CURSOR cur_kontrat_ekipman
      IS
         SELECT *
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE yk_dp_kontrat_ekipman_bilgi.sozlesme_no = v_sozlesme_no;

      CURSOR cur_kontrat_ekipman_kontrol
      IS
         SELECT kampanya_ozellik
           FROM vv_kampanya_ekipman
          WHERE     tip_aciklama IN ('MODÜL',
                                     'KUTU',
                                     'KART',
                                     'HARDDİSK',
                                     'MODEM')
                AND kampanya_kodu = v_campaign_code;

      rec_kontrat_ekipman           cur_kontrat_ekipman%ROWTYPE;
      rec_kontrat_ekipman_kontrol   cur_kontrat_ekipman_kontrol%ROWTYPE;
      yk_dp_kontrat_rec             yk_dp_kontrat_cur%ROWTYPE;
      v_tmp                         NUMBER (2);
      v_stmp                        CHAR (1);

      v_wiz_operator_id             co_kullanici.wiz_operator_id%TYPE;
      v_eski_sozlesme_no            yk_dp_kontrat.sozlesme_no%TYPE;
   BEGIN
      durum := '0';
      ouye_no := NULL;
      v_count := 0;
      vlnb_tipi_stok_kodu := ilnb_tipi_stok_kodu;

      IF v_status = '30'
      THEN
         IF ioutlet_location IS NULL
         THEN
            durum := 'OUTLET BILGISI YOK';
            RETURN;
         END IF;
      END IF;

      IF igiren_kullanici IS NULL
      THEN
         durum := 'KULLANICI BILGISI DOLU OLMALIDIR!';
         RETURN;
      END IF;

      IF is_valid_sozlesme_no (isozlesme_no, igiren_kullanici, in_stb_tipi) =
            0
      THEN
         durum :=
            'SÖZLESME NUMARASI ' || in_stb_tipi || ' TIPI IÇIN HATALI.';
         RETURN;
      END IF;

      IF in_stb_tipi = 'ZS' AND isozlesme_tipi = 1
      THEN
         BEGIN
            SELECT son_adim
              INTO v_son_adim
              FROM pr_form_gelis_tipi
             WHERE kod = ikon_gel_tipi;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_son_adim := 'H';
         END;

         IF v_son_adim = 'E'
         THEN
            IF TRIM (imalzeme_onayli) IS NULL
            THEN
               durum :=
                  'KONTRAT_PACK.YK_DP_KONTRAT_UPDATE: Malzemenin onayli olup olmadigini girmelisiniz!.';
               RETURN;
            END IF;
         END IF;
      END IF;

      IF LTRIM (RTRIM (ibayi_kodu)) IS NOT NULL
      THEN
         v_ekip_kodu := LTRIM (RTRIM (iekip_kodu));

         IF v_ekip_kodu = '000'
         THEN
            v_ekip_kodu := TRIM (ibayi_kodu);
         ELSIF LTRIM (RTRIM (v_ekip_kodu)) IS NOT NULL
         THEN
            v_ekip_tipi_kodu := dbs_sabit ('EKIP_TIPI_KODU');

            BEGIN
               SELECT DISTINCT
                      DECODE (NVL (sales_agent_code, '?'),
                              '?', ust_kod,
                              sales_agent_code)
                 INTO v_temp_ekip_kodu
                 FROM vv_bayi_teknik_servis_sube
                WHERE     ust_kod = TRIM (ibayi_kodu)
                      AND SUBSTR (sales_agent_code, -3, 3) =
                             TRIM (v_ekip_kodu)
                      AND tip_kodu = v_ekip_tipi_kodu;

               v_ekip_kodu := v_temp_ekip_kodu;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum :=
                        'EKIP KODU TANIMLARI HATALI!'
                     || '-'
                     || v_ekip_kodu
                     || '-'
                     || ibayi_kodu;
                  RETURN;
            END;
         END IF;
      ELSE
         v_ekip_kodu := NULL;
      END IF;

      IF TRIM (ifranchise_code) = 'F01' AND vlnb_tipi_stok_kodu IS NULL
      THEN
         durum := 'LNB Tipi zorunludur!';
         RETURN;
      END IF;

      IF vlnb_tipi_stok_kodu IS NOT NULL
      THEN
         BEGIN
            SELECT 0
              INTO durum
              FROM DUAL
             WHERE EXISTS
                      (SELECT st.stok_kodu kod, st.stok_baslik aciklama
                         FROM stok_dba.vv_stok_malzeme_tanim st,
                              stok_dba.s_stok_grup_tanim gt,
                              stok_dba.s_stok_grup_detay gd
                        WHERE     gt.grupadi = 'LNB'
                              AND gt.grupid = gd.grupid
                              AND gd.stokkodu = st.stok_kodu
                              AND st.stok_kodu = vlnb_tipi_stok_kodu);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               durum := 'Geçersiz LNB Tipi !';
               RETURN;
         END;
      END IF;

      v_sozlesme_no := isozlesme_no;

      OPEN yk_dp_kontrat_cur (v_sozlesme_no);

      FETCH yk_dp_kontrat_cur INTO yk_dp_kontrat_rec;

      v_abone_ozellik_kodu := in_abone_ozellik_kodu;
      v_sozlesme_tipi := isozlesme_tipi;
      v_is_yeri_yetkilisi_1 := iis_yeri_yetkilisi_1;
      v_is_yeri_yetkilisi_2 := iis_yeri_yetkilisi_2;
      v_digikutu_bagli_tel := idigikutu_bagli_tel;
      v_dwelling_type := idwelling_type;
      v_billing_frequency := ibilling_frequency;
      v_ruhsat_yeri_id := iruhsat_yeri_id;
      v_ruhsat_tarihi := iruhsat_tarihi;
      v_ruhsat_verilme_ili := iruhsat_verilme_ili;
      v_ruhsat_sicil_no := iruhsat_sicil_no;
      v_ruhsat_belediye := iruhsat_belediye;
      v_faaliyet_konusu := ifaaliyet_konusu;
      v_fatura_apt_adi := ifatura_apt_adi;
      v_fatura_blok := ifatura_blok;
      v_fatura_apt_no := ifatura_apt_no;
      v_fatura_semt := ifatura_semt;
      v_fatura_ilce := ifatura_ilce;
      v_fatura_il := ifatura_il;
      v_fatura_eyalet := ifatura_eyalet;
      v_fatura_ulke := ifatura_ulke;
      v_fatura_daire_no := ifatura_daire_no;
      v_fatura_posta_kodu := ifatura_posta_kodu;
      v_mdu_ceki := imdu_ceki;
      v_mdu_bu_ceki := imdu_bu_ceki;
      v_teknisyen_kodu := iteknisyen_kodu;
      v_daire_sayisi := idaire_sayisi;
      v_kat_sayisi := ikat_sayisi;
      v_stb_seri_no := TRIM (istb_seri_no);
      v_sc_seri_no := isc_seri_no;
      v_telefon_ceki := itelefon_ceki;
      v_kk_tipi := ikk_tipi;
      v_kk_no := ikk_no;
      v_kk_son_tarihi := ikk_son_tarihi;
      v_banka_adi := ibanka_adi;

      IF RTRIM (ibayi_kodu) IS NULL
      THEN
         v_bayi_kodu := '        ';
      ELSE
         v_bayi_kodu := ibayi_kodu;
      END IF;

      v_kon_gel_tipi := ikon_gel_tipi;
      v_building_id := ibuilding_id;
      v_service_address_id := iservice_address_id;
      v_servis_tarihi := iservis_tarihi;
      v_revizyon := irevizyon;
      v_batch := ibatch;
      v_its_kayit_no := iits_kayit_no;
      v_status := istatus;
      v_giren_kullanici := igiren_kullanici;
      v_uye_tipi := iuye_tipi;
      v_kimlik_cinsi := ikimlik_cinsi;
      v_bina_tipi := ibina_tipi;
      v_hub_code := ihub_code;
      v_prospect_number := iprospect_number;
      v_franchise_code := ifranchise_code;
      v_tuttugu_takim_kodu := ituttugu_takim_kodu;
      v_campaign_code := icampaign_code;
      v_vip := ivip;
      v_sozlesme_tarihi := isozlesme_tarihi;
      v_yeni_mdu_no := iyeni_mdu_no;
      v_eski_mdu_no := ieski_mdu_no;
      v_is_emri_no := iis_emri_no;
      v_uye_no := iuye_no;
      v_eski_yeni_ceki := ieski_yeni_ceki;
      v_ad := iad;
      v_soyad := isoyad;
      v_anne_kizlik_soyad := ianne_kizlik_soyad;
      v_dogum_yeri := idogum_yeri;
      v_dogum_tarihi := idogum_tarihi;
      v_cinsiyet := icinsiyet;
      v_meslek := imeslek;
      v_meslek_id := imeslek_id;
      v_kimlik_yeri := ikimlik_yeri;
      v_kimlik_seri_no := ikimlik_seri_no;
      v_kimlik_kayit_no := ikimlik_kayit_no;
      v_kimlik_tarihi := ikimlik_tarihi;
      v_tabiyet := TRIM (itabiyet);
      v_vergi_dairesi := ivergi_dairesi;
      v_vergi_no := ivergi_no;
      v_ev_tel_ulke_alan := iev_tel_ulke_alan;
      v_ev_tel_alan := iev_tel_alan;
      v_ev_tel_prefix := iev_tel_prefix;
      v_ev_tel_no := iev_tel_no;
      v_is_tel_ulke_alan := iis_tel_ulke_alan;
      v_is_tel_alan := iis_tel_alan;
      v_is_tel_prefix := iis_tel_prefix;
      v_is_tel_no := iis_tel_no;
      v_is_tel_dahili := iis_tel_dahili;
      v_cep_tel_ulke_alan := icep_tel_ulke_alan;
      v_cep_tel_alan := icep_tel_alan;
      v_cep_tel_prefix := icep_tel_prefix;
      v_cep_tel_no := icep_tel_no;
      v_fax_tel_ulke_alan := ifax_tel_ulke_alan;
      v_fax_tel_alan := ifax_tel_alan;
      v_fax_tel_prefix := ifax_tel_prefix;
      v_fax_tel_no := ifax_tel_no;
      v_email := iemail;
      v_fatura_sirket_adi := ifatura_sirket_adi;
      v_fatura_mahalle := ifatura_mahalle;
      v_fatura_cadde := ifatura_cadde;
      v_fatura_sokak := ifatura_sokak;
      v_fatura_site_adi := ifatura_site_adi;
      v_digikart_var_mi := idigikart_var_mi;
      v_mdu_sistem_no := imdu_sistem_no;
      v_mdu_yontem_no := imdu_yontem_no;
      v_billing_cycle := ibilling_cycle;
      v_guvenlik_kodu := iguvenlik_kodu;
      v_outlet_location := ioutlet_location;
      v_potansiyel_is_emri_id := ipotansiyel_is_emri_id;
      v_stb_tipi :=
         vestel_pack.abone_stb_tipi_from_sozlesme (v_sozlesme_no,
                                                   in_stb_tipi);
      v_anne_adi := in_anne_adi;
      v_baba_adi := in_baba_adi;
      v_nufusa_kayitli_ilcesi := in_nufusa_kayitli_ilcesi;
      v_nufusa_kayitli_ili := in_nufusa_kayitli_ili;
      v_uydu_tipi := in_uydu_tipi;
      v_modul_tipi := in_modul_tipi;
      v_ekipman_kutu_tipi := in_ekipman_kutu_tipi;
      v_modul_seri_no := in_modul_seri_no;
      v_hk_seri_no := in_hk_seri_no;
      v_cep_kayitli := in_cep_kayitli;
      v_yts_personel := iyts_personel;
      v_banka_adi := ibanka_adi;
      v_eski_sozlesme_no := ieski_sozlesme_no;
      v_sifre_text := isifre_text;
      v_harddisk_seri_no := TRIM (iharddisk_seri_no);                --MKECECI
      v_modem_seri_no := TRIM (imodem_seri_no);                      --MKECECI
      v_rf_mdu_tipi := TRIM (irf_mdu_tipi);                          --MKECECI

      IF idevirli_outlet_location IS NOT NULL
      THEN
         v_devirli_outlet_location := idevirli_outlet_location;
      ELSE
         IF v_outlet_location IS NULL OR TRIM (v_outlet_location) = ''
         THEN
            BEGIN
               SELECT outlet_location
                 INTO v_devirli_outlet_location
                 FROM wiz_equip
                WHERE serial_number = isc_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_devirli_outlet_location := '';
            END;
         END IF;

         IF     (v_outlet_location IS NULL OR TRIM (v_outlet_location) = '')
            AND (   v_devirli_outlet_location IS NULL
                 OR v_devirli_outlet_location = '')
         THEN
            BEGIN
               SELECT outlet_location
                 INTO v_devirli_outlet_location
                 FROM wiz_equip
                WHERE serial_number = v_stb_seri_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_devirli_outlet_location := '';
            END;
         ELSE
            v_devirli_outlet_location := v_outlet_location;
         END IF;
      END IF;

      IF v_devirli_outlet_location IS NOT NULL
      THEN
         SELECT COUNT (1)
           INTO v_tmp
           FROM dp_account_no
          WHERE     account_no = v_uye_no
                AND outlet_location = v_devirli_outlet_location;

         IF v_outlet_location IS NULL AND v_tmp = 0
         THEN
            v_outlet_location := v_devirli_outlet_location;
         END IF;
      END IF;

      IF TRIM (v_stb_tipi) = '-1'
      THEN
         durum := 'SÖZLESMEDEN ÜYE STB TIPI BULUNAMADI.';
         RETURN;
      END IF;

      --kayit aktarilma tarihini set et...
      IF v_status = '30'
      THEN
         v_kayit_aktarilma_tarihi := SYSDATE;
      ELSE
         v_kayit_aktarilma_tarihi := NULL;
      END IF;

      IF     yk_dp_kontrat_cur%NOTFOUND
         AND v_status = '80'
         AND v_sozlesme_no <> v_eski_sozlesme_no
         AND v_eski_sozlesme_no IS NOT NULL
      THEN
         CLOSE yk_dp_kontrat_cur;

         OPEN yk_dp_kontrat_cur (v_eski_sozlesme_no);

         FETCH yk_dp_kontrat_cur INTO yk_dp_kontrat_rec;
      END IF;

      IF yk_dp_kontrat_cur%NOTFOUND
      THEN
         durum := 'KAYIT BULUNAMADI';
         RETURN;
      ELSE
         v_prev_status := yk_dp_kontrat_rec.status;
         v_prev_kon_gel_tipi := yk_dp_kontrat_rec.kon_gel_tipi;

         IF     RTRIM (LTRIM (yk_dp_kontrat_rec.status)) = '30'
            AND RTRIM (LTRIM (yk_dp_kontrat_rec.kayit_aktarilma_tarihi))
                   IS NOT NULL
         THEN
            durum := '0';
            RETURN;
         END IF;

         -- 17.07.2009 falamur burada bazi kontrat gelis tiplerinin kaldirimlasi sonucu degisiklik yapildi. Burada kaldirilan kontrat tiplerinin girisine engel olunuyor.
         -- sadece eger güncellenmek istenilen kayit kaldirilan bir kontrat tipine sahipse ve gelen kayit da ayni ise o zaman izin veriliyor.
         IF     v_kon_gel_tipi IS NOT NULL
            AND TRIM (v_kon_gel_tipi) IS NOT NULL
            AND v_kon_gel_tipi <> v_prev_kon_gel_tipi
         THEN
            BEGIN
               SELECT listeden_gizle, aciklama
                 INTO v_listeden_gizle, v_gelen_kontrat_adi
                 FROM pr_form_gelis_tipi
                WHERE kod = v_kon_gel_tipi AND form_tipi = '1';

               IF v_listeden_gizle = 'E'
               THEN
                  durum :=
                        'Kontrat gelis tipi: '
                     || v_gelen_kontrat_adi
                     || ' olarak girilemez. Kullanimdan kaldirilmis kontrat tipi.';
                  RETURN;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  durum := 'Tanimsiz kontrat gelis tipi. ';
                  RETURN;
            END;
         END IF;

         SELECT COUNT (1)
           INTO v_tmp
           FROM lg_yk_dp_kontrat
          WHERE     account_number = v_uye_no
                AND devirli_outlet_location = v_devirli_outlet_location
                AND (   (    sozlesme_no = v_sozlesme_no
                         AND v_eski_sozlesme_no IS NULL)
                     OR (    sozlesme_no = v_eski_sozlesme_no
                         AND v_eski_sozlesme_no IS NOT NULL));

         IF     v_tmp = 0
            AND RTRIM (LTRIM (v_status)) = '80'
            AND TRIM (v_prev_status) = '80'
         THEN
            -- 40 dan 80 e loglama...
            IF yk_dp_kontrat_rec.ekip_kodu = yk_dp_kontrat_rec.bayi_kodu
            THEN
               v_temp_ekip_kodu := '000';
            ELSE
               v_temp_ekip_kodu :=
                  SUBSTR (yk_dp_kontrat_rec.ekip_kodu,
                          LENGTH (yk_dp_kontrat_rec.ekip_kodu) - 2);
            END IF;

            lg_yk_dp_kontrat_pack.lg_yk_dp_kontrat_insert (
               yk_dp_kontrat_rec.uye_no,
               yk_dp_kontrat_rec.is_emri_no,
               'I',
               v_giren_kullanici,
               yk_dp_kontrat_rec.sozlesme_no,
               NULL,
               yk_dp_kontrat_rec.sozlesme_tarihi,
               yk_dp_kontrat_rec.yeni_mdu_no,
               yk_dp_kontrat_rec.eski_mdu_no,
               yk_dp_kontrat_rec.mdu_ceki,
               yk_dp_kontrat_rec.mdu_bu_ceki,
               yk_dp_kontrat_rec.bayi_kodu,
               yk_dp_kontrat_rec.teknisyen_kodu,
               yk_dp_kontrat_rec.kon_gel_tipi,
               yk_dp_kontrat_rec.servis_tarihi,
               yk_dp_kontrat_rec.revizyon,
               yk_dp_kontrat_rec.batch,
               yk_dp_kontrat_rec.campaign_code,
               yk_dp_kontrat_rec.digikart_varmi,
               yk_dp_kontrat_rec.kat_sayisi,
               yk_dp_kontrat_rec.daire_sayisi,
               v_temp_ekip_kodu,
               yk_dp_kontrat_rec.its_kayit_no,
               yk_dp_kontrat_rec.potansiyel_is_emri_id,
               v_lg_id,
               v_sonuc,
               v_taa_uyari,
               yk_dp_kontrat_rec.status,
               vlnb_tipi_stok_kodu,                      -- lnb tipi stok kodu
               yk_dp_kontrat_rec.outlet_location,
               yk_dp_kontrat_rec.devirli_outlet_location,
               imalzeme_onayli);

            IF v_sonuc <> '0'
            THEN
               durum := v_sonuc;
               RETURN;
            END IF;
         END IF;

         --------------------------------------------------------------------------------
         SELECT COUNT (1)
           INTO v_validfranchise
           FROM (SELECT COLUMN_VALUE AS franchise
                   FROM TABLE (wiz_fran_sys_pack.getvalidfranchiselist (
                                  iuye_no,
                                  v_bayi_kodu,
                                  v_service_address_id,
                                  '',
                                  '')))
          WHERE franchise = ifranchise_code;

         IF v_validfranchise = 0
         THEN
            durum :=
                  'FRANCHISE BILGISI UYUMSUZ.'
               || CHR (13)
               || 'FRANCHISE,UYE FRANCHISE,ADRES FRANCHISE,BAYI FRANCHISE BILGILERI UYUMLU OLMALIDIR.';
            RETURN;
         END IF;

         -- Ekipman modül kontrol...
         FOR rec_kontrat_ekipman_kontrol IN cur_kontrat_ekipman_kontrol
         LOOP
            --IF rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'MODÜL' AND in_stb_tipi = 'LG' AND in_modul_seri_no = ''
            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'MODÜL'
               AND in_modul_seri_no = ''
            THEN
               durum := 'Bu kampanyada modül zorunludur.';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'KUTU'
               AND istb_seri_no = ''
            THEN
               durum := 'Bu kampanyada kutu zorunludur.';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'KART'
               AND isc_seri_no = ''
            THEN
               durum := 'Bu kampanyada kart zorunludur.';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'HARDDİSK'
               AND iharddisk_seri_no = ''
            THEN
               durum := 'Bu kampanyada harddisk zorunludur.';
               RETURN;
            END IF;

            IF     rec_kontrat_ekipman_kontrol.kampanya_ozellik = 'MODEM'
               AND imodem_seri_no = ''
            THEN
               durum := 'Bu kampanyada modem zorunludur.';
               RETURN;
            END IF;
         END LOOP;

         v_ciltno := iciltno;
         v_ailesirano := iailesirano;
         v_sirano := isirano;
         v_sitevillablokadedi := isitevillablokadedi;
         v_sitedaireblokadedi := isitedaireblokadedi;
         v_sitetoplamkonutadedi := isitetoplamkonutadedi;
         v_sitealtyapidestekbedeli := isitealtyapidestekbedeli;
         v_sozlesme_bitis_tarihi := isozlesme_bitis_tarihi;

         UPDATE yk_dp_kontrat
            SET sozlesme_tipi = v_sozlesme_tipi,
                is_yeri_yetkilisi_1 = v_is_yeri_yetkilisi_1,
                is_yeri_yetkilisi_2 = v_is_yeri_yetkilisi_2,
                digikutu_bagli_tel = v_digikutu_bagli_tel,
                dwelling_type = v_dwelling_type,
                billing_frequency = v_billing_frequency,
                ruhsat_yeri_id = v_ruhsat_yeri_id,
                ruhsat_tarihi = v_ruhsat_tarihi,
                ruhsat_verilme_ili = v_ruhsat_verilme_ili,
                ruhsat_sicil_no = v_ruhsat_sicil_no,
                ruhsat_belediye = v_ruhsat_belediye,
                faaliyet_konusu = v_faaliyet_konusu,
                fatura_apt_adi = v_fatura_apt_adi,
                fatura_blok = v_fatura_blok,
                fatura_apt_no = v_fatura_apt_no,
                fatura_semt = v_fatura_semt,
                fatura_ilce = v_fatura_ilce,
                fatura_il = v_fatura_il,
                fatura_eyalet = v_fatura_eyalet,
                fatura_ulke = v_fatura_ulke,
                fatura_daire_no = v_fatura_daire_no,
                fatura_posta_kodu = v_fatura_posta_kodu,
                mdu_ceki = v_mdu_ceki,
                mdu_bu_ceki = v_mdu_bu_ceki,
                teknisyen_kodu = v_teknisyen_kodu,
                daire_sayisi = v_daire_sayisi,
                kat_sayisi = v_kat_sayisi,
                stb_seri_no = v_stb_seri_no,
                sc_seri_no = v_sc_seri_no,
                telefon_ceki = v_telefon_ceki,
                kk_tipi = v_kk_tipi,
                kk_no = v_kk_no,
                kk_son_tarihi = v_kk_son_tarihi,
                bayi_kodu = v_bayi_kodu,
                kon_gel_tipi = v_kon_gel_tipi,
                building_id = v_building_id,
                service_address_id = v_service_address_id,
                servis_tarihi = v_servis_tarihi,
                revizyon = v_revizyon,
                batch = v_batch,
                its_kayit_no = v_its_kayit_no,
                status = v_status,
                kayit_aktarilma_tarihi = v_kayit_aktarilma_tarihi,
                son_islem_yapan_kullanici = v_giren_kullanici,
                uye_tipi = v_uye_tipi,
                kimlik_cinsi = v_kimlik_cinsi,
                bina_tipi = v_bina_tipi,
                hub_code = v_hub_code,
                prospect_number = v_prospect_number,
                franchise_code = v_franchise_code,
                tuttugu_takim_kodu = v_tuttugu_takim_kodu,
                degistirme_tarihi = SYSDATE,
                campaign_code = v_campaign_code,
                vip = v_vip,
                sozlesme_no = v_sozlesme_no,
                sozlesme_tarihi = v_sozlesme_tarihi,
                yeni_mdu_no = v_yeni_mdu_no,
                eski_mdu_no = v_eski_mdu_no,
                is_emri_no = v_is_emri_no,
                uye_no = v_uye_no,
                eski_yeni_ceki = v_eski_yeni_ceki,
                ad = v_ad,
                soyad = v_soyad,
                anne_kizlik_soyad = v_anne_kizlik_soyad,
                dogum_yeri = v_dogum_yeri,
                dogum_tarihi = v_dogum_tarihi,
                cinsiyet = v_cinsiyet,
                meslek = v_meslek,
                meslek_id = v_meslek_id,
                kimlik_yeri = v_kimlik_yeri,
                kimlik_seri_no = v_kimlik_seri_no,
                kimlik_kayit_no = v_kimlik_kayit_no,
                kimlik_tarihi = v_kimlik_tarihi,
                tabiyet = v_tabiyet,
                vergi_dairesi = v_vergi_dairesi,
                vergi_no = v_vergi_no,
                home_country_tel_code = v_ev_tel_ulke_alan,
                ev_tel_alan = v_ev_tel_alan,
                ev_tel_prefix = v_ev_tel_prefix,
                ev_tel_no = v_ev_tel_no,
                work_country_tel_code = v_is_tel_ulke_alan,
                is_tel_alan = v_is_tel_alan,
                is_tel_prefix = v_is_tel_prefix,
                is_tel_no = v_is_tel_no,
                is_tel_dahili = v_is_tel_dahili,
                mobile_country_tel_code = v_cep_tel_ulke_alan,
                cep_tel_alan = v_cep_tel_alan,
                cep_tel_prefix = v_cep_tel_prefix,
                cep_tel_no = v_cep_tel_no,
                fax_country_tel_code = v_fax_tel_ulke_alan,
                fax_tel_alan = v_fax_tel_alan,
                fax_tel_prefix = v_fax_tel_prefix,
                fax_tel_no = v_fax_tel_no,
                email = v_email,
                fatura_sirket_adi = v_fatura_sirket_adi,
                fatura_mahalle = v_fatura_mahalle,
                fatura_cadde = v_fatura_cadde,
                fatura_sokak = v_fatura_sokak,
                fatura_site_adi = v_fatura_site_adi,
                digikart_varmi = v_digikart_var_mi,
                mdu_sistem_no = v_mdu_sistem_no,
                mdu_yontem_no = v_mdu_yontem_no,
                billing_cycle = v_billing_cycle,
                guvenlik_kodu = v_guvenlik_kodu,
                outlet_location = LTRIM (v_outlet_location),
                ekip_kodu = v_ekip_kodu,
                potansiyel_is_emri_id = v_potansiyel_is_emri_id,
                stb_tipi = v_stb_tipi,
                anne_adi = v_anne_adi,
                baba_adi = v_baba_adi,
                nufusa_kayitli_ilcesi = v_nufusa_kayitli_ilcesi,
                nufusa_kayitli_ili = v_nufusa_kayitli_ili,
                abone_ozellik_kodu = v_abone_ozellik_kodu,
                uydu_tipi = v_uydu_tipi,
                modul_tipi = v_modul_tipi,
                ekipman_kutu_tipi = v_ekipman_kutu_tipi,
                modul_seri_no = v_modul_seri_no,
                hk_seri_no = v_hk_seri_no,
                cep_kayitli = v_cep_kayitli,
                tc_kimlik_no = ivatandaslikno,
                cilt_no = v_ciltno,
                aile_sira_no = v_ailesirano,
                sira_no = v_sirano,
                site_villa_blok_adedi = v_sitevillablokadedi,
                site_daire_blok_adedi = v_sitedaireblokadedi,
                site_toplam_konut_adedi = v_sitetoplamkonutadedi,
                site_altyapi_destek_bedeli = v_sitealtyapidestekbedeli,
                sozlesme_bitis_tarihi = v_sozlesme_bitis_tarihi,
                yts_personel = v_yts_personel,
                banka_adi = v_banka_adi,
                devirli_outlet_location = v_devirli_outlet_location,
                malzeme_onayli = imalzeme_onayli,
                lnb_tipi_stok_id = vlnb_tipi_stok_kodu,
                sifre_text = isifre_text,
                harddisk_seri_no = v_harddisk_seri_no,
                modem_seri_no = v_modem_seri_no
          -- burasi güncellenmeli...
          WHERE CURRENT OF yk_dp_kontrat_cur;

         durum := '0';

         IF v_status = '40'
         THEN
            IF v_sozlesme_tipi <> '5'
            THEN
               log_pack.lg_abone_islem_takip_insert (
                  v_uye_no,
                  v_sozlesme_no || ',' || v_outlet_location,
                  v_sc_seri_no,
                  '53',
                  v_giren_kullanici,
                  v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := v_sonuc;
                  RETURN;
               END IF;
            ELSE
               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
                  THEN
                     log_pack.lg_abone_islem_takip_insert (
                        v_uye_no,
                        v_sozlesme_no || ',' || v_outlet_location,
                        rec_kontrat_ekipman.kart_seri_no,
                        '53',
                        v_giren_kullanici,
                        v_sonuc);
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := v_sonuc;
                     RETURN;
                  END IF;
               END LOOP;
            END IF;
         ELSIF v_status = '80'
         THEN
            IF v_sozlesme_tipi <> '5'
            THEN
               BEGIN
                  SELECT co_kullanici.wiz_operator_id
                    INTO v_wiz_operator_id
                    FROM co_kullanici
                   WHERE co_kullanici.kod = igiren_kullanici;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     durum := 'HATALI KULLANICI KODU ';
                     RETURN;
               END;

               SELECT COUNT (1)
                 INTO v_tmp
                 FROM dp_account_no
                WHERE     account_no = v_uye_no
                      AND outlet_location = v_devirli_outlet_location;

               IF v_tmp = 0 AND v_outlet_location IS NOT NULL
               THEN
                  insert_dpaccountno (v_uye_no,
                                      v_sozlesme_no,
                                      v_outlet_location,
                                      v_bayi_kodu,
                                      v_sozlesme_tarihi,
                                      v_servis_tarihi,
                                      v_wiz_operator_id,
                                      v_kon_gel_tipi,
                                      v_mdu_bu_ceki,
                                      v_campaign_code,
                                      v_potansiyel_is_emri_id,
                                      v_sonuc,
                                      yk_dp_kontrat_rec.stb_tipi,
                                      yk_dp_kontrat_rec.yk_dp_kontrat_id,
                                      vlnb_tipi_stok_kodu);

                  IF v_sonuc <> '0'
                  THEN
                     durum := 'INSERT_DPACCOUNTNO4 :' || v_sonuc;
                     RETURN;
                  END IF;
               END IF;

               IF v_outlet_location IS NOT NULL
               THEN
                  log_pack.lg_abone_islem_takip_insert (
                     v_uye_no,
                     v_sozlesme_no || ',' || v_outlet_location,
                     v_sc_seri_no,
                     '54',
                     v_giren_kullanici,
                     v_sonuc);

                  IF v_sonuc <> '0'
                  THEN
                     durum := v_sonuc;
                     RETURN;
                  END IF;
               END IF;

               IF TRIM (v_prev_status) = '80'
               THEN                                  -- 40 dan 80 e loglama...
                  IF v_ekip_kodu = v_bayi_kodu
                  THEN
                     v_ekip_kodu := '000';
                  ELSE
                     v_ekip_kodu :=
                        SUBSTR (v_ekip_kodu, LENGTH (v_ekip_kodu) - 2);
                  END IF;

                  SELECT COUNT (1)
                    INTO v_tmp
                    FROM lg_yk_dp_kontrat
                   WHERE     account_number = v_uye_no
                         AND devirli_outlet_location =
                                v_devirli_outlet_location;

                  SELECT DECODE (v_tmp, 0, 'I', 'U') INTO v_stmp FROM DUAL;

                  lg_yk_dp_kontrat_pack.lg_yk_dp_kontrat_insert (
                     v_uye_no,
                     v_is_emri_no,
                     v_stmp,
                     v_giren_kullanici,
                     v_sozlesme_no,
                     v_eski_sozlesme_no,
                     v_sozlesme_tarihi,
                     v_yeni_mdu_no,
                     v_eski_mdu_no,
                     v_mdu_ceki,
                     v_mdu_bu_ceki,
                     v_bayi_kodu,
                     v_teknisyen_kodu,
                     v_kon_gel_tipi,
                     v_servis_tarihi,
                     v_revizyon,
                     v_batch,
                     v_campaign_code,
                     v_digikart_var_mi,
                     v_kat_sayisi,
                     v_daire_sayisi,
                     v_ekip_kodu,
                     v_its_kayit_no,
                     v_potansiyel_is_emri_id,
                     v_lg_id,
                     v_sonuc,
                     v_taa_uyari,
                     v_status,
                     vlnb_tipi_stok_kodu,
                     -- lnb tipi stok kodu
                     LTRIM (v_outlet_location),
                     v_devirli_outlet_location,
                     imalzeme_onayli,
                     yk_dp_kontrat_rec.yk_dp_kontrat_id);

                  IF v_sonuc <> '0'
                  THEN
                     durum := v_sonuc;
                     RETURN;
                  END IF;
               END IF;
            ELSE
               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  IF rec_kontrat_ekipman.kart_seri_no IS NOT NULL
                  THEN
                     log_pack.lg_abone_islem_takip_insert (
                        v_uye_no,
                        v_sozlesme_no || ',' || v_outlet_location,
                        rec_kontrat_ekipman.kart_seri_no,
                        '54',
                        v_giren_kullanici,
                        v_sonuc);
                  END IF;

                  IF v_sonuc <> '0'
                  THEN
                     durum := v_sonuc;
                     RETURN;
                  END IF;
               END LOOP;
            END IF;

            fatura.etc_kontrol_pack.kontrat_ekle_degistir (
               v_uye_no,
               v_devirli_outlet_location,
               v_giren_kullanici,
               v_sonuc,
               durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.etc_kontrol_pack.KONTRAT_EKLE_DEGISTIR :' || durum;
               RETURN;
            END IF;

            --ogm: Taahhut islemi
            fatura.taa_taahhut_pack.abone_taahhut_kontrol (
               v_uye_no,
               v_devirli_outlet_location,
               'SI',
               v_sozlesme_no,
               v_giren_kullanici,
               out_taa_uyari,
               durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.taa_taahhut_pack.abone_taahhut_kontrol :' || durum;
               RETURN;
            END IF;

            IF TRIM (out_taa_uyari) IS NOT NULL
            THEN
               IF yetki_pack.yetkisi_varmi (
                     v_giren_kullanici,
                     'ISLEM_KURULUM_TAAHHUT_UYARI_GECME') = 0
               THEN
                  durum :=
                        'YK_DP_KONTRAT_UPDATE1:Taahhut tutari olustu ancak devam etmek için islem yetkiniz yok: '
                     || out_taa_uyari;
                  RETURN;
               END IF;

               out_taa_uyari :=
                     'Abonenin taahhütü bozuldu. Outlet: '
                  || v_outlet_location
                  || ', tutar:'
                  || out_taa_uyari;
            END IF;

            /* ogm: ITTP Integration Start*/
            billing_dbs_int.onl_agreement_ittp_pkg.integrate_agreement (
               i_dbs_yk_dp_kontrat_id   => yk_dp_kontrat_rec.yk_dp_kontrat_id,
               i_dbs_account_number     => v_uye_no,
               o_result_type            => v_ittp_result_type,
               o_result_code            => v_ittp_result_code,
               o_result_message         => v_ittp_result_message);

            IF v_ittp_result_type = 1
            THEN
               durum := v_ittp_result_code || ':' || v_ittp_result_message;
               RETURN;
            END IF;

            /* ogm: ITTP Integration End*/

            /*27042010 Eger uye kontrat_aktivasyon_pack ile eklenmis ise ve üyede devir islemi yapmis ise o durumda
                servis ve ppv alamaz özelliklerini kaldiriyoruz.*/
            SELECT COUNT (1)
              INTO v_tmp
              FROM yk_dp_kontrat
             WHERE     uye_no = v_uye_no
                   AND devirli_outlet_location = v_devirli_outlet_location
                   AND status IN (30, 80)
                   AND campaign_code NOT IN (SELECT kontrat_kmp_kodu
                                               FROM yk_dp_kmp_akt_gereksinim);

            IF v_tmp > 0
            THEN
               SELECT COUNT (1)
                 INTO v_tmp
                 FROM mb_abone_ozellik mb
                WHERE     mb.account_number = v_uye_no --AND mb.outlet_location = v_devirli_outlet_location
                      AND mb.abone_ozellik_kodu = 129;

               IF v_tmp > 0
               THEN
                  abone_detay_pack.mb_abone_ozellik_delete (
                     v_uye_no,
                     NULL,
                     129,
                     v_giren_kullanici,
                     durum);

                  IF durum <> '0'
                  THEN
                     durum :=
                           'Üye PPV satin alamaz özelligi silinemedi. :'
                        || durum;
                     RETURN;
                  END IF;
               END IF;

               SELECT COUNT (1)
                 INTO v_tmp
                 FROM mb_abone_ozellik mb
                WHERE     mb.account_number = v_uye_no --AND mb.outlet_location = v_devirli_outlet_location
                      AND mb.abone_ozellik_kodu = 182;

               IF v_tmp > 0
               THEN
                  abone_detay_pack.mb_abone_ozellik_delete (
                     v_uye_no,
                     NULL,
                     182,
                     v_giren_kullanici,
                     durum);

                  IF durum <> '0'
                  THEN
                     durum :=
                        'Üye Servis alamaz özelligi silinemedi. :' || durum;
                     RETURN;
                  END IF;
               END IF;
            END IF;
         ELSIF v_status = '30'
         THEN
            v_vatandaslikno := ivatandaslikno;
            --            SELECT DECODE (COUNT (1), 0, 'H', 'E')
            --              INTO v_tc_kimlik_no_zorunlu
            --              FROM (SELECT COLUMN_VALUE AS franchise
            --                      FROM TABLE (split_table_fnc (dbs_sabit ('TC_KIMLIK_NO_ZORUNLU'))))
            --             WHERE franchise = v_franchise_code;
            v_tc_kimlik_no_zorunlu :=
               webrequest_pack.tckn_zorunlu_mu (v_franchise_code,
                                                in_stb_tipi,
                                                v_uye_tipi,
                                                v_sonuc);

            IF v_sonuc <> '0'
            THEN
               durum := v_sonuc;
               RETURN;
            END IF;

            --ayni cep telefonuyla 7 den fazla üyelik varsa uyari ver.
            SELECT COUNT (1)
              INTO v_count
              FROM mb_abone_telefon a
             WHERE     a.durum = 1
                   AND a.telefon_tipi = 3
                   AND    TRIM (a.ulke_kodu)
                       || TRIM (a.alan_kodu)
                       || TRIM (a.telefon_no) =
                             TRIM (v_cep_tel_ulke_alan)
                          || TRIM (v_cep_tel_alan)
                          || TRIM (v_cep_tel_prefix)
                          || TRIM (v_cep_tel_no)
                   AND EXISTS
                          (SELECT 1
                             FROM mb_outlet_takip b
                            WHERE     a.account_number = b.account_number
                                  AND b.outlet_in_tarihi IS NULL);

            IF     v_count >= 7
               AND yetki_pack.yetkisi_varmi (
                      v_giren_kullanici,
                      'ISLEM_UYELIK_AKTIVASYON_TEL_KISITI') = 0
            THEN
               durum :=
                  'Bu kisiye aktivasyon yapmak için bayi temsilcinize danisiniz..';
               RETURN;
            END IF;

            kontrat_pack.sms_ok (v_sozlesme_tipi,
                                 v_is_yeri_yetkilisi_1,
                                 v_is_yeri_yetkilisi_2,
                                 v_digikutu_bagli_tel,
                                 v_dwelling_type,
                                 v_billing_frequency,
                                 v_ruhsat_yeri_id,
                                 v_ruhsat_tarihi,
                                 v_ruhsat_verilme_ili,
                                 v_ruhsat_sicil_no,
                                 v_ruhsat_belediye,
                                 v_faaliyet_konusu,
                                 v_fatura_apt_adi,
                                 v_fatura_blok,
                                 v_fatura_apt_no,
                                 v_fatura_semt,
                                 v_fatura_ilce,
                                 v_fatura_il,
                                 v_fatura_eyalet,
                                 v_fatura_ulke,
                                 v_fatura_daire_no,
                                 v_fatura_posta_kodu,
                                 v_mdu_ceki,
                                 v_mdu_bu_ceki,
                                 v_teknisyen_kodu,
                                 v_daire_sayisi,
                                 v_kat_sayisi,
                                 v_stb_seri_no,
                                 v_sc_seri_no,
                                 v_telefon_ceki,
                                 v_kk_tipi,
                                 v_kk_no,
                                 v_kk_son_tarihi,
                                 v_bayi_kodu,
                                 v_kon_gel_tipi,
                                 v_building_id,
                                 v_service_address_id,
                                 v_servis_tarihi,
                                 v_revizyon,
                                 v_batch,
                                 v_its_kayit_no,
                                 v_status,
                                 v_giren_kullanici,
                                 v_uye_tipi,
                                 v_kimlik_cinsi,
                                 v_bina_tipi,
                                 v_hub_code,
                                 v_prospect_number,
                                 v_franchise_code,
                                 v_tuttugu_takim_kodu,
                                 v_campaign_code,
                                 v_vip,
                                 v_sozlesme_no,
                                 v_sozlesme_tarihi,
                                 v_yeni_mdu_no,
                                 v_eski_mdu_no,
                                 v_is_emri_no,
                                 v_uye_no,
                                 v_eski_yeni_ceki,
                                 v_ad,
                                 v_soyad,
                                 v_anne_kizlik_soyad,
                                 v_dogum_yeri,
                                 v_dogum_tarihi,
                                 v_cinsiyet,
                                 v_meslek,
                                 v_meslek_id,
                                 v_kimlik_yeri,
                                 v_kimlik_seri_no,
                                 v_kimlik_kayit_no,
                                 v_kimlik_tarihi,
                                 v_tabiyet,
                                 v_vergi_dairesi,
                                 v_vergi_no,
                                 v_ev_tel_ulke_alan,
                                 v_ev_tel_alan,
                                 v_ev_tel_prefix,
                                 v_ev_tel_no,
                                 v_is_tel_ulke_alan,
                                 v_is_tel_alan,
                                 v_is_tel_prefix,
                                 v_is_tel_no,
                                 v_is_tel_dahili,
                                 v_cep_tel_ulke_alan,
                                 v_cep_tel_alan,
                                 v_cep_tel_prefix,
                                 v_cep_tel_no,
                                 v_fax_tel_ulke_alan,
                                 v_fax_tel_alan,
                                 v_fax_tel_prefix,
                                 v_fax_tel_no,
                                 v_email,
                                 v_fatura_sirket_adi,
                                 v_fatura_mahalle,
                                 v_fatura_cadde,
                                 v_fatura_sokak,
                                 v_fatura_site_adi,
                                 v_digikart_var_mi,
                                 v_mdu_sistem_no,
                                 v_mdu_yontem_no,
                                 v_billing_cycle,
                                 v_guvenlik_kodu,
                                 v_outlet_location,
                                 v_potansiyel_is_emri_id,
                                 NULL,
                                 v_anne_adi,
                                 v_baba_adi,
                                 v_nufusa_kayitli_ilcesi,
                                 v_nufusa_kayitli_ili,
                                 v_abone_ozellik_kodu,
                                 v_uydu_tipi,
                                 v_modul_tipi,
                                 v_ekipman_kutu_tipi,
                                 v_modul_seri_no,
                                 v_uye_no,
                                 v_sonuc,
                                 in_stb_tipi,
                                 v_vatandaslikno,
                                 v_ciltno,
                                 v_ailesirano,
                                 v_sirano,
                                 v_tc_kimlik_no_zorunlu,
                                 icheck_payment_order_status,
                                 v_uydu_tipi,
                                 yk_dp_kontrat_rec.yk_dp_kontrat_id,
                                 v_sifre_text,
                                 v_harddisk_seri_no,
                                 v_modem_seri_no,
                                 v_rf_mdu_tipi);
            durum := v_sonuc;

            IF v_sonuc = '0' AND LTRIM (v_uye_no) IS NOT NULL
            THEN
               ouye_no := v_uye_no;
            ELSIF v_sonuc <> '0'
            THEN
               durum := v_sonuc;
               RETURN;
            END IF;

            SELECT tc_kimlik_no
              INTO v_vatandaslikno
              FROM (  SELECT tc_kimlik_no
                        FROM (SELECT tc_kimlik_no
                                FROM mb_abone_detay_bilgi
                               WHERE     account_number = v_uye_no
                                     AND tc_kimlik_no_gecerli = 'V'
                              UNION ALL
                              SELECT NULL tc_kimlik_no FROM DUAL)
                    ORDER BY tc_kimlik_no NULLS LAST)
             WHERE ROWNUM = 1;

            -- AKTIVASYON ICIN GECMIS BORC SORGULA   SUBAT 2010 MUSLU
            IF v_vatandaslikno IS NOT NULL
            THEN
               tckn_ile_borcluluk_sorgulama (v_vatandaslikno,
                                             v_giren_kullanici,
                                             v_sonuc,
                                             durum);

               IF v_sonuc <> '0'
               THEN
                  RETURN;
               ELSE
                  durum := v_sonuc;
               END IF;
            END IF;

            UPDATE yk_dp_kontrat
               SET tc_kimlik_no = v_vatandaslikno
             WHERE CURRENT OF yk_dp_kontrat_cur;

            IF v_sozlesme_tipi = '5' OR v_sozlesme_tipi = '2'
            THEN
               kisi_bilgi_pack.transfer_from_kontrat (v_sozlesme_no, v_sonuc);

               IF v_sonuc <> '0'
               THEN
                  durum := v_sonuc;
                  RETURN;
               END IF;
            END IF;

            -- Cep register ise cep tesefonmu register islemi yapilir
            -- 0 ise Kayit edilmeyecek
            -- 1 ise kayit edilecek
            IF NVL (in_cep_kayitli, 0) = 1
            THEN
               abone_telefon_pack.abone_telefon_register_telno (
                  v_uye_no,
                  v_outlet_location,
                  3,                          --in_telefon_tipi (Cep telefonu)
                  v_cep_tel_ulke_alan,
                  v_cep_tel_alan,
                  TRIM (v_cep_tel_prefix) || TRIM (v_cep_tel_no),
                  v_giren_kullanici,
                  v_sonuc_tip,
                  v_sonuc_kod,
                  v_sonuc,
                  v_sonuc_aciklama);

               IF v_sonuc_tip <> 0
               THEN
                  IF v_sonuc_kod <> 'ERR266'
                  THEN
                     durum := v_sonuc;
                     RETURN;
                  END IF;
               END IF;
            END IF;

            BEGIN
               SELECT kutu_tipi
                 INTO v_ekipman_kutu_tipi
                 FROM eq_ekipman
                WHERE serial_number = v_stb_seri_no;

               UPDATE yk_dp_kontrat
                  SET ekipman_kutu_tipi = v_ekipman_kutu_tipi
                WHERE CURRENT OF yk_dp_kontrat_cur;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            BEGIN
               SELECT ekipman_modul_tipi
                 INTO v_modul_tipi
                 FROM eq_ekipman
                WHERE serial_number = v_modul_seri_no;

               UPDATE yk_dp_kontrat
                  SET modul_tipi = v_modul_tipi
                WHERE CURRENT OF yk_dp_kontrat_cur;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            IF v_sozlesme_tipi = '5'
            THEN
               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  IF rec_kontrat_ekipman.kutu_seri_no IS NOT NULL
                  THEN
                     BEGIN
                        SELECT kutu_tipi
                          INTO v_ekipman_kutu_tipi
                          FROM eq_ekipman
                         WHERE serial_number =
                                  rec_kontrat_ekipman.kutu_seri_no;

                        UPDATE yk_dp_kontrat
                           SET ekipman_kutu_tipi = v_ekipman_kutu_tipi
                         WHERE sozlesme_no = v_sozlesme_no;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END IF;

                  IF rec_kontrat_ekipman.modul_seri_no IS NOT NULL
                  THEN
                     BEGIN
                        SELECT ekipman_modul_tipi
                          INTO v_modul_tipi
                          FROM eq_ekipman
                         WHERE serial_number =
                                  rec_kontrat_ekipman.modul_seri_no;

                        UPDATE yk_dp_kontrat
                           SET modul_tipi = v_modul_tipi
                         WHERE sozlesme_no = v_sozlesme_no;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           NULL;
                     END;
                  END IF;
               END LOOP;
            END IF;

            BEGIN
               SELECT tc_kimlik_no
                 INTO v_vatandaslikno
                 FROM mb_abone_detay_bilgi
                WHERE account_number = v_uye_no;

               UPDATE yk_dp_kontrat
                  SET tc_kimlik_no = v_vatandaslikno
                WHERE sozlesme_no = v_sozlesme_no;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            bt_uye_ts_pack.bt_uye_ts_guncel_feed (v_uye_no,
                                                  v_outlet_location,
                                                  v_teknisyen_kodu,
                                                  5,
                                                  'C',
                                                  NULL,         --IN_MEMO_KOD,
                                                  NULL,        --IN_SEBEP_KOD,
                                                  5,
                                                  v_giren_kullanici,
                                                  'KONTRAT',
                                                  durum);

            IF durum <> '0'
            THEN
               durum := 'Bt_Uye_Ts_Pack.BT_UYE_TS_GUNCEL_FEED :' || durum;
               RETURN;
            END IF;

            SELECT abbrev
              INTO v_abbrev
              FROM wiz_customer_type_codes
             WHERE customer_type = v_uye_tipi;

            IF TRIM (v_abbrev) = '2'
            THEN
               bt_uye_ts_pack.bt_uye_ts_guncel_feed (v_uye_no,
                                                     v_outlet_location,
                                                     v_teknisyen_kodu,
                                                     6,
                                                     'C',
                                                     NULL,      --IN_MEMO_KOD,
                                                     NULL,     --IN_SEBEP_KOD,
                                                     7,
                                                     v_giren_kullanici,
                                                     'KONTRAT',
                                                     durum);

               IF durum <> '0'
               THEN
                  durum := 'Bt_Uye_Ts_Pack.BT_UYE_TS_GUNCEL_FEED :' || durum;
                  RETURN;
               END IF;
            END IF;

            fatura.etc_kontrol_pack.kontrat_ekle_degistir (v_uye_no,
                                                           v_outlet_location,
                                                           v_giren_kullanici,
                                                           v_sonuc,
                                                           durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.etc_kontrol_pack.KONTRAT_EKLE_DEGISTIR :' || durum;
               RETURN;
            END IF;

            --ogm: Taahhut islemi
            fatura.taa_taahhut_pack.abone_taahhut_kontrol (v_uye_no,
                                                           v_outlet_location,
                                                           'SI',
                                                           v_sozlesme_no,
                                                           v_giren_kullanici,
                                                           out_taa_uyari,
                                                           durum);

            IF durum <> '0'
            THEN
               durum :=
                  'fatura.taa_taahhut_pack.abone_taahhut_kontrol :' || durum;
               RETURN;
            END IF;

            IF TRIM (out_taa_uyari) IS NOT NULL
            THEN
               IF yetki_pack.yetkisi_varmi (
                     v_giren_kullanici,
                     'ISLEM_KURULUM_TAAHHUT_UYARI_GECME') = 0
               THEN
                  durum :=
                        'YK_DP_KONTRAT_UPDATE2:Taahhut tutari olustu ancak devam etmek için islem yetkiniz yok: '
                     || out_taa_uyari;
                  RETURN;
               END IF;

               out_taa_uyari :=
                     'Abonenin taahhütü bozuldu. Outlet: '
                  || v_outlet_location
                  || ', tutar:'
                  || out_taa_uyari;
            END IF;

            /* ogm: ITTP Integration Start*/
            billing_dbs_int.onl_agreement_ittp_pkg.integrate_agreement (
               i_dbs_yk_dp_kontrat_id   => yk_dp_kontrat_rec.yk_dp_kontrat_id,
               i_dbs_account_number     => v_uye_no,
               o_result_type            => v_ittp_result_type,
               o_result_code            => v_ittp_result_code,
               o_result_message         => v_ittp_result_message);

            IF v_ittp_result_type = 1
            THEN
               durum := v_ittp_result_code || ':' || v_ittp_result_message;
               RETURN;
            END IF;
         /* ogm: ITTP Integration End*/
         END IF;
      END IF;

      CLOSE yk_dp_kontrat_cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'YK_DP_KONTRAT_UPDATE' || SQLERRM || v_ekip_kodu;
   END;

   -------------------------------------------------
   PROCEDURE yeni_kontrat_yapilabilir (
      iaccount_number   IN     wiz_equip.account_number%TYPE,
      isozlesme_no      IN     yk_dp_kontrat.sozlesme_no%TYPE,
      ikontrat_tipi     IN     VARCHAR2,
      durum                OUT VARCHAR2)
   IS
   BEGIN
      durum := '0';

      IF LTRIM (iaccount_number) IS NOT NULL
      THEN
         uye_kontrol_pack.uye_icrada_mi (iaccount_number, durum);
      END IF;
   END yeni_kontrat_yapilabilir;

   PROCEDURE kontrat_sonu_kontrol (
      isozlesme_no       IN     yk_dp_kontrat.sozlesme_no%TYPE,
      ioutlet_location   IN     wiz_equip.outlet_location%TYPE,
      iaccount_number    IN     wiz_equip.account_number%TYPE,
      ikullanici_kodu    IN     co_kullanici.kod%TYPE,
      durum                 OUT VARCHAR2)
   IS
      v_ittp_order_int_open   NUMBER;
      v_count                 NUMBER;
      v_kod                   co_kullanici.kod%TYPE;
      v_durum                 VARCHAR2 (1000);
      v_taa_uyari             VARCHAR2 (512);
      v_uyelik_durum          VARCHAR2 (100);
      --dtvcaloglu - 24.03.2014
      v_service_account_id    NUMBER;
      o_process_status        NUMBER;
      o_return_code           VARCHAR2 (1000);
      o_return_message        VARCHAR2 (1000);
   BEGIN
      durum := '0';
      v_ittp_order_int_open :=
         billing_dbs_int.exclude_control_pkg.is_integration_active (
            'ITTP_ORDER_INT');

      IF v_ittp_order_int_open = 0
      THEN
         SELECT COUNT (*)
           INTO v_count
           FROM ie_uyelik_kapama
          WHERE account_number = iaccount_number AND durum = 'K';
      ELSIF v_ittp_order_int_open = 1
      THEN
         --dtvcaloglu - 24.03.2014<begin>
         /* dbs_dba.uye_kontrol_pack.uye_donmus_mu (iaccount_number,
                                                  NULL,
                                                  v_uyelik_durum);*/
         dbs_dba.uye_kontrol_pack.uye_sus_mu (iaccount_number,
                                              NULL,
                                              v_uyelik_durum);
         --dtvcaloglu - 24.03.2014<end>
         v_count := 0;

         IF v_uyelik_durum <> '0'
         THEN
            v_count := 1;
         END IF;
      END IF;

      IF v_count > 0
      THEN
         BEGIN
            SELECT deger
              INTO v_kod
              FROM pa_sabitler
             WHERE adi = 'KULLANICI_SYSTEM';
         EXCEPTION
            WHEN OTHERS
            THEN
               durum :=
                  'PA_SABITLER KULLANICI_SYSTEM PARAMETRESI BULUNAMADI !!';
               RETURN;
         END;

         --dtvcaloglu - 24.03.2014<begin>
         /* uyelik_kapama_pack.uyelik_kapama_kapat_outlet (iaccount_number,
                                                         ioutlet_location,
                                                         0,
                                                         v_kod,
                                                         SYSDATE,
                                                         durum,
                                                         v_taa_uyari);*/

         v_service_account_id :=
            billing_dbs_int.customer_ittp_pkg.get_service_account_id (
               iaccount_number,
               ioutlet_location,
               NULL);
         dt_bi_api.suspend_process_pkg.start_suspend (0,
                                                      v_service_account_id,
                                                      v_kod,
                                                      'SUS',
                                                      0,
                                                      o_process_status,
                                                      o_return_code,
                                                      o_return_message);

         IF o_process_status <> 0
         THEN
            durum := o_return_message;
         END IF;

         --dtvcaloglu - 24.03.2014<end>

         IF durum <> '0'
         THEN
            v_durum := durum;
            ROLLBACK;
            log_pack.log_uyelik_kapama_hata (NULL,
                                             iaccount_number,
                                             ioutlet_location,
                                             'K',
                                             v_kod,
                                             SYSDATE,
                                             'KONTRAT GIRISI ' || v_durum,
                                             durum);
            RETURN;
         END IF;

         durum :=
            '00:ÜYENIN YAYINI BORCUNDAN DOLAYI KAPATILMIS DURUMDA OLDUGUNDAN BU EKIPMANININ YAYINI DA KAPATILMISTIR ';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum :=
               'KONTRAT_PACK.KONTRAT_SONU_KONTROL : '
            || SUBSTR (SQLERRM, 1, 150);
   END kontrat_sonu_kontrol;

   PROCEDURE yeni_kontrat_unload_islemler (
      iaccount_number   IN     wiz_equip.account_number%TYPE,
      ioutlet           IN     wiz_equip.outlet_location%TYPE,
      isozlesme_no      IN     yk_dp_kontrat.sozlesme_no%TYPE,
      itelefon_ceki     IN     yk_dp_kontrat.telefon_ceki%TYPE,
      iserial_number    IN     wiz_equip.serial_number%TYPE,
      ikullanici        IN     co_kullanici.kod%TYPE,
      durum                OUT VARCHAR2,
      omesaj               OUT VARCHAR2)
   IS
      CURSOR cur_kontrat_ekipman
      IS
         SELECT *
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE yk_dp_kontrat_ekipman_bilgi.sozlesme_no = isozlesme_no;

      rec_kontrat_ekipman     cur_kontrat_ekipman%ROWTYPE;
      v_outlet                NUMBER;

      CURSOR svc_cur
      IS
         SELECT service_code,
                campaign_code,
                quantity,
                promotion_code,
                work_order_number,
                non_standard_service_rate,
                servis_frekansi,
                servis_fiyati,
                bayiden_satis,
                servis_dusurme_fiyati,
                fiyat_bitis_tarihi,
                promo_expire_date,
                currency,
                outlet_location
           FROM wiz_customer_hp_svc
          WHERE     account_number = iaccount_number
                AND outlet_location =
                          SUBSTR ('0000000000',
                                  0,
                                  3 - LENGTH (TO_CHAR (v_outlet)))
                       || TO_CHAR (v_outlet)
                AND 0 =
                       billing_dbs_int.exclude_control_pkg.is_integration_active (
                          'ITTP_ORDER_INT')
         UNION
         SELECT service_code,
                campaign_code,
                quantity,
                promotion_code,
                dbs_work_order_id work_order_number,
                non_standard_service_rate,
                servis_frekansi,
                TO_NUMBER (servis_fiyati) AS servis_fiyati,
                bayiden_satis,
                TO_NUMBER (servis_dusurme_fiyati) AS servis_dusurme_fiyati,
                fiyat_bitis_tarihi,
                pdate promo_expire_date,
                currency,
                outlet_location
           FROM dt_dbs_int_dba.vv_uye_ittp_servisler
          WHERE     account_number = iaccount_number
                AND outlet_location =
                          SUBSTR ('0000000000',
                                  0,
                                  3 - LENGTH (TO_CHAR (v_outlet)))
                       || TO_CHAR (v_outlet)
                AND 1 =
                       billing_dbs_int.exclude_control_pkg.is_integration_active (
                          'ITTP_ORDER_INT');

      svc_rec                 svc_cur%ROWTYPE;
      v_damga_vergisi         NUMBER;
      v_svccount              NUMBER := 0;
      v_count                 NUMBER;
      v_durum                 VARCHAR2 (512);
      v_son_mesaj             VARCHAR2 (512);
      v_sozlesme_tipi         yk_dp_kontrat.sozlesme_tipi%TYPE;
      v_prospect_number       yk_dp_kontrat.prospect_number%TYPE;
      v_mgm_tavsiye_edilen    NUMBER (10);
      v_mgm_sebep_kodu        CHAR (3);
      v_abone_pot_id          NUMBER (10);
      v_tahsilat_id           NUMBER (10);
      v_uye_aktif_tarihi      DATE;
      v_uye_uydusu            NUMBER (2);
      v_sc_serial_number      wiz_equip.serial_number%TYPE;
      v_st_serial_number      wiz_equip.serial_number%TYPE;
      v_turksat_yayinini_ac   BOOLEAN;
      v_setothermode_cik      BOOLEAN;
      v_ret                   NUMBER;
      v_tra_id                NUMBER;
      v_ittp_order_int_open   NUMBER;

      CURSOR ut_cur
      IS
         SELECT *
           FROM ut_uye_tavsiye
          WHERE    (    eden_sozlesme_no = isozlesme_no
                    AND eden_kisi_tipi = 2
                    AND eden_kayit_durumu NOT IN (2, 3, 7))
                OR (    edilen_sozlesme_no = isozlesme_no
                    AND edilen_kisi_tipi = 2
                    AND edilen_kayit_durumu NOT IN (2, 3, 7));

      ut_rec                  ut_cur%ROWTYPE;

      CURSOR mgm_pot_cur (
         p_sozlesme_no    VARCHAR2)
      IS                                  --sözlesmede ayni olan potansiyeller
         SELECT prospect_number
           FROM yk_dp_kontrat_abone_potansiyel, yk_dp_kontrat_potansiyel_log
          WHERE     yk_dp_kontrat_abone_potansiyel.id =
                       yk_dp_kontrat_potansiyel_log.yk_abone_potansiyel_id
                AND sozlesme_no = p_sozlesme_no;
   BEGIN
      v_turksat_yayinini_ac := FALSE;
      v_outlet := TO_NUMBER (ioutlet);
      durum := '0';
      v_durum := '-1';
      abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

      v_ittp_order_int_open :=
         billing_dbs_int.exclude_control_pkg.is_integration_active (
            'ITTP_ORDER_INT');

      IF v_durum <> '0'
      THEN
         durum := v_durum || omesaj;
         ROLLBACK;
         RETURN;
      END IF;

      /* ogm: ITTP Integration Start*/
      DECLARE
         v_yk_dp_kontrat_id      NUMBER;
         v_ittp_result_type      NUMBER;
         v_ittp_result_code      VARCHAR2 (255);
         v_ittp_result_message   VARCHAR2 (1000);
      BEGIN
         SELECT yk_dp_kontrat_id
           INTO v_yk_dp_kontrat_id
           FROM yk_dp_kontrat
          WHERE sozlesme_no = isozlesme_no;

         billing_dbs_int.onl_agreement_ittp_pkg.integrate_agreement_unload (
            i_dbs_yk_dp_kontrat_id   => v_yk_dp_kontrat_id,
            i_dbs_account_number     => iaccount_number,
            o_result_type            => v_ittp_result_type,
            o_result_code            => v_ittp_result_code,
            o_result_message         => v_ittp_result_message);

         IF v_ittp_result_type = 1
         THEN
            durum := v_ittp_result_code || ':' || v_ittp_result_message;
            ROLLBACK;
            RETURN;
         END IF;
      END;

      -- 19082010 falamur üyenin kutusunun türksata açilmasi veya açilmamasina karar verilmesi
      BEGIN
         SELECT COUNT (1)
           INTO v_count
           FROM wiz_customer_hp_life life
          WHERE     life.account_number = iaccount_number
                AND life.franchise_code IN ('F01', 'F02')
                AND EXISTS
                       (SELECT 1
                          FROM wiz_equip e,
                               eq_ekipman_tip_matrix m,
                               pr_urun_ozellik_tanim t
                         WHERE     e.account_number = iaccount_number
                               AND e.outlet_location = ioutlet
                               AND e.converter_type = 'ST'
                               AND TRIM (m.manufacturer) =
                                      TRIM (e.manufacturer)
                               AND TRIM (m.converter_model) =
                                      TRIM (e.converter_model)
                               AND TRIM (m.converter_type) =
                                      TRIM (e.converter_type)
                               AND t.urun_tipi = 6
                               AND m.eq_ekipman_tip_matrix_id =
                                      t.ekipman_tip_matrix_id
                               AND t.ozellik_kodu = 69);

         IF v_count > 0
         THEN
            BEGIN
               SELECT COUNT (1)
                 INTO v_count
                 FROM pr_urun_ozellik_tanim
                WHERE     listeden_gizle = 'H'
                      AND urun_tipi = 1
                      AND ozellik_kodu = 94
                      AND urun_kodu IN (SELECT campaign_code
                                          FROM yk_dp_kontrat
                                         WHERE sozlesme_no = isozlesme_no);

               IF v_count > 0
               THEN
                  v_turksat_yayinini_ac := TRUE;
               END IF;

               IF v_turksat_yayinini_ac = TRUE
               THEN
                  -- üye ozellligi ekle
                  abone_detay_pack.mb_abone_ozellik_insert (iaccount_number,
                                                            ioutlet,
                                                            166,
                                                            'SYSTEM',
                                                            durum);
               ELSE
                  v_uye_uydusu :=
                     abone_sorgu_pack.uye_uydusu (iaccount_number, ioutlet);
                  v_setothermode_cik := TRUE;

                  IF v_uye_uydusu = 1                              -- Eutelsat
                  THEN
                     -- Kapama sinyali gönder.
                     v_turksat_yayinini_ac := FALSE;
                  ELSIF v_uye_uydusu = 2                            -- Türksat
                  THEN
                     -- açma sinyali gönder.
                     v_turksat_yayinini_ac := TRUE;
                  ELSE
                     v_setothermode_cik := FALSE;
                  END IF;
               END IF;

               SELECT serial_number
                 INTO v_sc_serial_number
                 FROM wiz_equip e
                WHERE     e.account_number = iaccount_number
                      AND e.outlet_location = ioutlet
                      AND e.converter_type = 'SC'
                      AND ROWNUM = 1;

               SELECT serial_number
                 INTO v_st_serial_number
                 FROM wiz_equip e
                WHERE     e.account_number = iaccount_number
                      AND e.outlet_location = ioutlet
                      AND e.converter_type = 'ST'
                      AND ROWNUM = 1;

               -- Eger paket islemlerinden bu özellik girilmis ise burada eutelsat bile olsa  Türksata açma sinyali çikiliyor.
               SELECT COUNT (1)
                 INTO v_count
                 FROM dbs_dba.mb_abone_ozellik mb
                WHERE     mb.account_number = iaccount_number
                      AND mb.outlet_location = ioutlet
                      AND mb.abone_ozellik_kodu = 166;

               IF v_turksat_yayinini_ac OR v_count > 0
               THEN
                  -- açma sinyali gönder.
                  addressability_pack.setothermode (iaccount_number,
                                                    v_sc_serial_number,
                                                    v_st_serial_number,
                                                    1,
                                                    ikullanici,
                                                    durum);
               ELSIF v_setothermode_cik = TRUE
               THEN
                  -- v_setothermode_cik = false ise set other mode çikmadan devam et.
                  -- Kapama sinyali gönder.
                  addressability_pack.setothermode (iaccount_number,
                                                    v_sc_serial_number,
                                                    v_st_serial_number,
                                                    0,
                                                    ikullanici,
                                                    durum);
               END IF;

               IF durum <> '0'
               THEN
                  durum := '0';
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := '0';
            END;
         END IF;
      END;

      -- 07072011 Falamur
      -- irdeto kutularda çocuk paketi eklenmis ise kanal numaralarini düzenleyen sinyal çikacak.
      IF dbs_dba.dbs_sabit ('COCUK_BUKE_SINYAL_AKTIF') = 'H'
      THEN
         BEGIN
            IF v_ittp_order_int_open = 0
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_customer_hp_svc
                WHERE     account_number = iaccount_number
                      AND outlet_location = ioutlet
                      AND service_code = 'CCK';
            ELSIF v_ittp_order_int_open = 1
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM dt_dbs_int_dba.vv_uye_ittp_servisler
                WHERE     account_number = iaccount_number
                      AND outlet_location = ioutlet
                      AND service_code = 'CCK';
            END IF;

            IF v_count > 0
            THEN
               SELECT serial_number
                 INTO v_st_serial_number
                 FROM wiz_equip e
                WHERE     e.account_number = iaccount_number
                      AND e.outlet_location = ioutlet
                      AND e.converter_type = 'ST'
                      AND ROWNUM = 1;

               IF ekipman_pack.ekipman_irdeto_desteklimi (v_st_serial_number) =
                     'E'
               THEN
                  v_ret :=
                     dbs_addr_reqs_pisys_pack.reset_bouquet_channel_order (
                        23,                   --p_req_dbs_type    IN VARCHAR2,
                        iserial_number,     -- p_serial_number    IN VARCHAR2,
                        130,       -- p_bouquet_id    IN   NUMBER DEFAULT 130,
                        NULL, -- p_tms_attributes    IN   VARCHAR2 DEFAULT NULL,
                        SYSDATE,                 -- p_valid_after    IN  DATE,
                        'SYSTEM',    -- p_req_user         IN        VARCHAR2,
                        v_tra_id,               -- p_tra_id   IN OUT   NUMBER,
                        durum,                        -- p_errm  OUT VARCHAR2,
                        'E', -- p_logla            IN        CHAR     DEFAULT 'E',
                        NULL           -- p_req_id    IN   NUMBER DEFAULT NULL
                            );
                  -- Hata olursa aktivasyon kesilmesin. Job zaten bu sinyali çikacak.
                  durum := 0;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               durum := '0';
         END;
      END IF;

      BEGIN
         SELECT sozlesme_tipi
           INTO v_sozlesme_tipi
           FROM yk_dp_kontrat
          WHERE     sozlesme_no = isozlesme_no
                AND uye_no = iaccount_number
                AND status = '30';

         SELECT prospect_number
           INTO v_prospect_number
           FROM yk_dp_kontrat
          WHERE     sozlesme_no = isozlesme_no
                AND uye_no = iaccount_number
                AND status = '30';

         -- Yutdisi tetik varsa bu tetigin potansiyelide kapanir.
         IF v_prospect_number IS NULL
         THEN
            SELECT COUNT (1)
              INTO v_count
              FROM ie_potansiyel_is_emri
             WHERE     sozlesme_no = isozlesme_no
                   AND islem_tipi = 1
                   AND durum = 'P';

            IF v_count = 1
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM ie_potansiyel_is_emri i, wiz_prospect_descrip p
                WHERE     i.sozlesme_no = isozlesme_no
                      AND i.prospect_number = p.prospect_number
                      AND i.islem_tipi = 1
                      AND i.durum = 'P';

               IF v_count = 1
               THEN
                  SELECT i.prospect_number
                    INTO v_prospect_number
                    FROM ie_potansiyel_is_emri i, wiz_prospect_descrip p
                   WHERE     i.sozlesme_no = isozlesme_no
                         AND i.prospect_number = p.prospect_number
                         AND i.islem_tipi = 1
                         AND i.durum = 'P';
               END IF;
            END IF;
         END IF;

         IF LTRIM (v_sozlesme_tipi) IS NULL
         THEN
            durum := 'SOZLESMEDEN SOZLESME TIPI ELDE EDILEMEDI!';
            ROLLBACK;
            RETURN;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            durum := 'SOZLESMEDEN SOZLESME TIPI ELDE EDILEMEDI...';
            ROLLBACK;
            RETURN;
      END;

      DECLARE
         v_ittp_order_int_open   NUMBER;
         m_durum                 VARCHAR2 (512);
      BEGIN
         v_ittp_order_int_open :=
            billing_dbs_int.exclude_control_pkg.is_integration_active (
               'ITTP_ORDER_INT');

         SELECT COUNT (1)
           INTO v_svccount
           FROM yk_dp_servis
          WHERE sozlesme_no = isozlesme_no;

         IF v_svccount = 0
         THEN
            IF v_sozlesme_tipi <> '5'
            THEN
               OPEN svc_cur;

               LOOP
                  FETCH svc_cur INTO svc_rec;

                  IF     svc_cur%NOTFOUND
                     AND v_svccount = 0
                     AND v_sozlesme_tipi = '1'
                  THEN
                     -- mtonkus : 09/12/13 ( ie_uyelik_dondurma ) ittp entegrasyonu.
                     IF v_ittp_order_int_open = 0
                     THEN
                        SELECT COUNT (1)                       -- üye don mu ?
                          INTO v_svccount
                          FROM ie_uyelik_dondurma
                         WHERE     account_number = iaccount_number
                               AND outlet_location = ioutlet
                               AND durum = 'D';

                        IF v_svccount = 0
                        THEN
                           SELECT COUNT (1)
                             INTO v_svccount
                             FROM ie_uyelik_kapama
                            WHERE     account_number = iaccount_number
                                  AND outlet_location = ioutlet
                                  AND durum = 'K';
                        END IF;
                     ELSIF v_ittp_order_int_open = 1
                     THEN
                        dbs_dba.uye_kontrol_pack.uye_donmus_mu (
                           iaccount_number,
                           ioutlet,
                           m_durum);

                        IF m_durum <> '0'
                        THEN
                           v_svccount := 1;
                        END IF;

                        IF v_svccount = 0
                        THEN
                           dbs_dba.uye_kontrol_pack.uye_sus_mu (
                              iaccount_number,
                              ioutlet,
                              m_durum);

                           IF m_durum <> '0'
                           THEN
                              v_svccount := 1;
                           END IF;
                        END IF;
                     END IF;

                     IF v_svccount = 0
                     THEN
                        omesaj :=
                              'BU ABONENIN '
                           || ioutlet
                           || '. OUTLETI IÇIN SERVIS EKLENMEMISTIR.';
                        durum := '-1';
                        --ogm:buraya rollback eklendi
                        ROLLBACK;
                        RETURN;
                     --                     END IF;
                     END IF;
                  ELSIF     svc_cur%NOTFOUND
                        AND v_svccount = 0
                        AND (v_sozlesme_tipi = '2')
                  THEN
                     EXIT;
                  ELSIF svc_cur%NOTFOUND AND v_svccount > 0
                  THEN
                     EXIT;
                  ELSIF NOT svc_cur%NOTFOUND
                  THEN
                     v_svccount := v_svccount + 1;

                     --servIslerI Insert et
                     INSERT INTO yk_dp_servis (sozlesme_no,
                                               uye_no,
                                               servis_kodu,
                                               kampanya_kodu,
                                               job_code,
                                               quantity,
                                               promotion_code,
                                               work_order_number,
                                               non_standard_service_rate,
                                               servis_frekansi,
                                               servis_fiyati,
                                               bayiden_satis,
                                               servis_dusurme_fiyati,
                                               fiyat_bitis_tarihi,
                                               promosyon_bitis_tarihi,
                                               currency,
                                               outlet_location)
                          VALUES (isozlesme_no,
                                  iaccount_number,
                                  svc_rec.service_code,
                                  svc_rec.campaign_code,
                                  'ADD',
                                  svc_rec.quantity,
                                  svc_rec.promotion_code,
                                  svc_rec.work_order_number,
                                  svc_rec.non_standard_service_rate,
                                  svc_rec.servis_frekansi,
                                  svc_rec.servis_fiyati,
                                  svc_rec.bayiden_satis,
                                  svc_rec.servis_dusurme_fiyati,
                                  svc_rec.fiyat_bitis_tarihi,
                                  svc_rec.promo_expire_date,
                                  svc_rec.currency,
                                  svc_rec.outlet_location);
                  END IF;
               END LOOP;

               CLOSE svc_cur;
            ELSE
               v_outlet := TO_NUMBER (ioutlet);

               FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
               LOOP
                  SELECT COUNT (1)
                    INTO v_svccount
                    FROM yk_dp_servis
                   WHERE     sozlesme_no = isozlesme_no
                         AND outlet_location =
                                   SUBSTR ('0000000000',
                                           0,
                                           3 - LENGTH (TO_CHAR (v_outlet)))
                                || TO_CHAR (v_outlet);

                  OPEN svc_cur;

                  LOOP
                     FETCH svc_cur INTO svc_rec;

                     IF     svc_cur%NOTFOUND
                        AND v_svccount = 0
                        AND (v_sozlesme_tipi = '5')
                     THEN
                        EXIT;
                     ELSIF svc_cur%NOTFOUND AND v_svccount > 0
                     THEN
                        EXIT;
                     ELSIF NOT svc_cur%NOTFOUND
                     THEN
                        v_svccount := v_svccount + 1;

                        --servIslerI Insert et
                        INSERT INTO yk_dp_servis (sozlesme_no,
                                                  uye_no,
                                                  servis_kodu,
                                                  kampanya_kodu,
                                                  job_code,
                                                  quantity,
                                                  promotion_code,
                                                  work_order_number,
                                                  non_standard_service_rate,
                                                  servis_frekansi,
                                                  servis_fiyati,
                                                  bayiden_satis,
                                                  servis_dusurme_fiyati,
                                                  fiyat_bitis_tarihi,
                                                  promosyon_bitis_tarihi,
                                                  currency,
                                                  outlet_location)
                                VALUES (
                                          isozlesme_no,
                                          iaccount_number,
                                          svc_rec.service_code,
                                          svc_rec.campaign_code,
                                          'ADD',
                                          svc_rec.quantity,
                                          svc_rec.promotion_code,
                                          svc_rec.work_order_number,
                                          svc_rec.non_standard_service_rate,
                                          svc_rec.servis_frekansi,
                                          svc_rec.servis_fiyati,
                                          svc_rec.bayiden_satis,
                                          svc_rec.servis_dusurme_fiyati,
                                          svc_rec.fiyat_bitis_tarihi,
                                          svc_rec.promo_expire_date,
                                          svc_rec.currency,
                                             SUBSTR (
                                                '0000000000',
                                                0,
                                                  3
                                                - LENGTH (TO_CHAR (v_outlet)))
                                          || TO_CHAR (v_outlet));
                     END IF;
                  END LOOP;

                  CLOSE svc_cur;

                  v_outlet := v_outlet + 1;
               END LOOP;
            END IF;

            COMMIT;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            omesaj := 'UNLOAD_ISLEMLER:' || SQLERRM;
            durum := '-1';
            --ogm:buraya rollback eklendi
            ROLLBACK;
            RETURN;
      END;

      --dIGer ISlemler
      --------------------------------------------------------------------
      abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

      IF v_durum <> '0'
      THEN
         omesaj := omesaj;
         durum := v_durum || omesaj;
         ROLLBACK;
         RETURN;
      END IF;

      --kredi sifirlama
      IF itelefon_ceki = 'H'
      THEN
         IF v_sozlesme_tipi <> '5'
         THEN
            addressability_pack.kredi_degisikligi (iserial_number,
                                                   ikullanici,
                                                   0,
                                                   0,
                                                   v_durum);

            IF v_durum <> '0'
            THEN
               omesaj := 'PPV KREDISI ''0'' YAPILAMADI.' || v_durum;
               durum := v_durum;
               ROLLBACK;
               RETURN;
            END IF;
         ELSE
            FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
            LOOP
               addressability_pack.kredi_degisikligi (
                  rec_kontrat_ekipman.kart_seri_no,
                  ikullanici,
                  0,
                  0,
                  v_durum);

               IF v_durum <> '0'
               THEN
                  omesaj :=
                        'PPV KREDISI ''0'' YAPILAMADI.'
                     || rec_kontrat_ekipman.kart_seri_no
                     || ' - '
                     || v_durum;
                  durum := v_durum;
                  ROLLBACK;
                  RETURN;
               END IF;
            END LOOP;
         END IF;
      END IF;

      COMMIT;
      abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

      IF v_durum <> '0'
      THEN
         omesaj := omesaj;
         durum := v_durum || omesaj;
         ROLLBACK;
         RETURN;
      END IF;

      --ogm:damga vergisinin eski yeri

      /* Mustafa 09.09.2004
         --ramazan karademir mgm kayitlar için bir update 01.07.2002
         IF v_prospect_number IS NULL THEN
              v_mgm_tavsiye_edilen := iaccount_number;
         ELSE
              v_mgm_tavsiye_edilen := v_prospect_number;
         END IF;

         SELECT COUNT(DISTINCT tavsiye_eden)
         INTO v_count
         FROM MGM_ABONE_BILGI ,
            YK_DP_KONTRAT_ABONE_POTANSIYEL, YK_DP_KONTRAT_POTANSIYEL_LOG
            WHERE YK_DP_KONTRAT_ABONE_POTANSIYEL.id = YK_DP_KONTRAT_POTANSIYEL_LOG.yk_abone_potansiyel_id
            AND YK_DP_KONTRAT_ABONE_POTANSIYEL.sozlesme_no = isozlesme_no
         AND tavsiye_edilen = prospect_number
         AND tavsiye_edilen_tipi = 2 --potansIyel
         AND kayit_durumu NOT IN (2,3); --kapali,Iptal

         IF v_count = 1 THEN
              v_mgm_sebep_kodu := 'M01';

         ELSIF v_count > 1 THEN
              v_mgm_sebep_kodu := 'M02';

         ELSE
              v_mgm_sebep_kodu := NULL;
         END IF;

         FOR mgm_pot_rec IN mgm_pot_cur(isozlesme_no) LOOP

         Mgm_Pack.mgm_abone_bilgi_finalize(mgm_pot_rec.prospect_number,iaccount_number,ioutlet,
                                    v_mgm_sebep_kodu,isozlesme_no,ikullanici,durum);
         IF durum <> '0' THEN
              RETURN;
           END IF;
         END LOOP;

         v_mgm_sebep_kodu := NULL;
         Mgm_Pack.mgm_abone_bilgi_finalize(v_mgm_tavsiye_edilen,iaccount_number,ioutlet,v_mgm_sebep_kodu,
                                    isozlesme_no,ikullanici,durum);
         IF durum <> '0' THEN
              RETURN;
         END IF;
      */
      IF v_prospect_number IS NOT NULL
      THEN
         BEGIN
            SELECT id
              INTO v_tahsilat_id
              FROM kmp_taksit
             WHERE return_kod = '00' AND prospect_no = v_prospect_number;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_tahsilat_id := NULL;
         END;

         SELECT COUNT (1)
           INTO v_count
           FROM dbs_dba.vv_uye_prospect
          WHERE     uye_no = iaccount_number
                AND prospect_number = v_prospect_number;

         IF v_count = 0
         THEN
            yk_dp_abone_potansiyel_ins (NULL,                            --sid
                                        iaccount_number,
                                        ioutlet,
                                        isozlesme_no,
                                        ikullanici,
                                        v_prospect_number,
                                        'E',          --ieslestirme_tipi_abone
                                        'YKO',                   --isebep_kodu
                                        'POTANSIYEL ESLEME',       --iaciklama
                                        'KONTRAT',                   --ikaynak
                                        v_abone_pot_id,                  --oid
                                        v_durum,
                                        ikullanici,
                                        v_tahsilat_id);         --itahsilat_id

            IF v_durum <> '0'
            THEN
               omesaj := 'yeni_kontrat_unload_islemler :' || v_durum;
               durum := v_durum;
               ROLLBACK;
               RETURN;
            END IF;
         END IF;
      END IF;

      COMMIT;
      --      --sil
      --      durum := 'manuel hata 3';
      --      RETURN;
      --      --/sil
      abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

      IF v_durum <> '0'
      THEN
         omesaj := omesaj;
         durum := v_durum || omesaj;
         ROLLBACK;
         RETURN;
      END IF;

      IF v_prospect_number IS NULL AND TRIM (isozlesme_no) IS NOT NULL
      THEN
         OPEN ut_cur;

         LOOP
            FETCH ut_cur INTO ut_rec;

            IF ut_cur%FOUND
            THEN
               BEGIN
                  SELECT install_date
                    INTO v_uye_aktif_tarihi
                    FROM wiz_customer_hp_life
                   WHERE account_number = TRIM (iaccount_number);
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     omesaj := 'Eslestirilmeye çalisilan abone bulunamadi.';
                     durum := omesaj;
                     ROLLBACK;
                     RETURN;
               END;

               IF ut_rec.giris_tarihi <= v_uye_aktif_tarihi
               THEN
                  uye_tavsiye_pack.uye_tavsiye_finalize (NULL,
                                                         2,
                                                         isozlesme_no,
                                                         iaccount_number,
                                                         ioutlet,
                                                         'YKO',
                                                         ikullanici,
                                                         durum);

                  IF durum = '0'
                  THEN
                     EXIT;
                  END IF;
               ELSE
                  IF ut_rec.eden_sozlesme_no = isozlesme_no
                  THEN
                     uye_tavsiye_pack.uye_tavsiye_update (
                        ut_rec.ID,
                        ut_rec.kaynak,
                        ut_rec.eden_sozlesme_no,
                        3,
                        ut_rec.eden_account_number,
                        ut_rec.eden_outlet_location,
                        ut_rec.eden_kayit_tipi,
                        'M03',
                           TRIM (ut_rec.eden_aciklama)
                        || ' Sistem - Üye, Üye Tavsiye kaydindan önce sisteme girmis.',
                        ut_rec.eden_ts,
                        ut_rec.edilen_sozlesme_no,
                        ut_rec.edilen_kayit_durumu,
                        ut_rec.edilen_account_number,
                        ut_rec.edilen_outlet_location,
                        ut_rec.edilen_kayit_tipi,
                        ut_rec.edilen_sebep_kodu,
                        ut_rec.edilen_aciklama,
                        ut_rec.edilen_ts,
                        ikullanici,
                        durum);
                  ELSE
                     uye_tavsiye_pack.uye_tavsiye_update (
                        ut_rec.ID,
                        ut_rec.kaynak,
                        ut_rec.eden_sozlesme_no,
                        ut_rec.eden_kayit_durumu,
                        ut_rec.eden_account_number,
                        ut_rec.eden_outlet_location,
                        ut_rec.eden_kayit_tipi,
                        ut_rec.eden_sebep_kodu,
                        ut_rec.eden_aciklama,
                        ut_rec.eden_ts,
                        ut_rec.edilen_sozlesme_no,
                        3,
                        ut_rec.edilen_account_number,
                        ut_rec.edilen_outlet_location,
                        ut_rec.edilen_kayit_tipi,
                        'M03',
                           TRIM (ut_rec.edilen_aciklama)
                        || ' Sistem - Üye, Üye Tavsiye kaydindan önce sisteme girmis.',
                        ut_rec.edilen_ts,
                        ikullanici,
                        durum);
                  END IF;
               END IF;

               IF durum <> '0'
               THEN
                  omesaj := durum;
                  ROLLBACK;
                  RETURN;
               END IF;
            ELSE
               EXIT;
            END IF;
         END LOOP;

         CLOSE ut_cur;
      END IF;

      --ogm:damga vergisinin yeni yeri
      COMMIT;
      abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

      IF v_durum <> '0'
      THEN
         omesaj := omesaj;
         durum := v_durum || omesaj;
         ROLLBACK;
         RETURN;
      END IF;

      IF v_sozlesme_tipi <> '5'
      THEN
         kontrat_pack.kontrat_sonu_kontrol (isozlesme_no,
                                            ioutlet,
                                            iaccount_number,
                                            ikullanici,
                                            v_durum);

         IF v_durum <> '0' AND SUBSTR (LTRIM (v_durum), 1, 3) <> '00:'
         THEN
            omesaj := v_durum;
            durum := v_durum;
            ROLLBACK;
            RETURN;
         ELSIF SUBSTR (LTRIM (v_durum), 1, 3) = '00:'
         THEN
            v_son_mesaj := SUBSTR (LTRIM (v_durum), 3, LENGTH (v_durum));
            durum := '0';
            COMMIT;
            abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

            IF v_durum <> '0'
            THEN
               omesaj := omesaj || v_son_mesaj;
               durum := v_durum || omesaj;
               ROLLBACK;
               RETURN;
            END IF;
         --            --damga vergIsInI hesapla
         --            IF vestel_pack.abone_stb_tipi_bul (iaccount_number) <> 'TK'
         --            THEN
         --               damga_vergisi_pack.get_damga_vergi_proc (isozlesme_no,
         --                                                        ikullanici,
         --                                                        v_damga_vergisi,
         --                                                        v_durum);
         --
         --               --               --sil
         --               --               IF v_durum = '0' THEN
         --               --                  v_durum := 'manuel hata1';
         --               --               END IF;
         --               --               --/sil
         --               IF v_durum <> '0'
         --               THEN
         --                  durum :=
         --                        v_son_mesaj
         --                     || ' DAMGA VERGISI HESAPLANAMADI.'
         --                     || v_durum;
         --                  ROLLBACK;
         --                  RETURN;
         --               ELSE
         --                  omesaj :=
         --                        v_son_mesaj
         --                     || ' '
         --                     || v_damga_vergisi
         --                     || ' '                               --|| cur_default (2)
         --                     || cur_franchise (NULL, iaccount_number) --mcetinbag 2007-01-18
         --                     || ' LIK DAMGA VERGISI HESAPLANMISTIR.';
         --                  durum := v_durum;
         --               END IF;
         --               END IF;
         ELSE
            COMMIT;
            abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

            IF v_durum <> '0'
            THEN
               omesaj := omesaj;
               durum := v_durum || omesaj;
               ROLLBACK;
               RETURN;
            END IF;
         --            --damga vergIsInI hesapla
         --            IF vestel_pack.abone_stb_tipi_bul (iaccount_number) <> 'TK'
         --            THEN
         --               damga_vergisi_pack.get_damga_vergi_proc (isozlesme_no,
         --                                                        ikullanici,
         --                                                        v_damga_vergisi,
         --                                                        v_durum);
         --
         --               --            --sil
         --               --               IF v_durum = '0' THEN
         --               --                  v_durum := 'manuel hata2';
         --               --               END IF;
         --               --               --/sil
         --               IF v_durum <> '0'
         --               THEN
         --                  omesaj := 'DAMGA VERGISI HESAPLANAMADI.' || v_durum;
         --                  durum := v_durum;
         --                  ROLLBACK;
         --                  RETURN;
         --               ELSE
         --                  omesaj :=
         --                        v_damga_vergisi
         --                     || ' '                               --|| cur_default (2)
         --                     || cur_franchise (NULL, iaccount_number)
         --                     || ' LIK DAMGA VERGISI HESAPLANMISTIR.';
         --                  durum := v_durum;
         --               END IF;
         --               END IF;
         END IF;
      ELSE
         v_outlet := TO_NUMBER (ioutlet);
         v_damga_vergisi := 0;

         FOR rec_kontrat_ekipman IN cur_kontrat_ekipman
         LOOP
            --- burasi güncelleniyor...
            kontrat_pack.kontrat_sonu_kontrol (
               isozlesme_no,
                  SUBSTR ('0000000000', 0, 3 - LENGTH (TO_CHAR (v_outlet)))
               || TO_CHAR (v_outlet),
               iaccount_number,
               ikullanici,
               v_durum);

            IF v_durum <> '0' AND SUBSTR (LTRIM (v_durum), 1, 3) <> '00:'
            THEN
               omesaj := v_durum;
               durum := v_durum;
               ROLLBACK;
               RETURN;
            ELSIF SUBSTR (LTRIM (v_durum), 1, 3) = '00:'
            THEN
               v_son_mesaj := SUBSTR (LTRIM (v_durum), 3, LENGTH (v_durum));
            END IF;

            v_outlet := v_outlet + 1;
         END LOOP;

         durum := '0';
         COMMIT;
         abone_islem_pack.abone_islem (iaccount_number, v_durum, omesaj);

         IF v_durum <> '0'
         THEN
            omesaj := omesaj || v_son_mesaj;
            durum := v_durum || omesaj;
            ROLLBACK;
            RETURN;
         END IF;

         --         --damga vergIsInI hesapla
         --         IF vestel_pack.abone_stb_tipi_bul (iaccount_number) <> 'TK'
         --         THEN
         --            damga_vergisi_pack.get_damga_vergi_proc (isozlesme_no,
         --                                                     ikullanici,
         --                                                     v_damga_vergisi,
         --                                                     v_durum);
         --
         --            IF v_durum <> '0'
         --            THEN
         --               durum :=
         --                  v_son_mesaj || ' DAMGA VERGISI HESAPLANAMADI.' || v_durum;
         --               ROLLBACK;
         --               RETURN;
         --            END IF;
         --         END IF;

         omesaj :=
               v_son_mesaj
            || ' '
            || v_damga_vergisi
            || ' '                                        --|| cur_default (2)
            || cur_franchise (NULL, iaccount_number)
            || ' LIK DAMGA VERGISI HESAPLANMISTIR.';
         durum := v_durum;
      END IF;

      COMMIT;
   END yeni_kontrat_unload_islemler;

   PROCEDURE yk_dp_abone_potansiyel_ins ( /*Potansiyel - Potansiyel/Üye Eslesmesi
                                             Remarks:
                                             Note:
                                             Note:   Eslesen üyede ilgili sözlesme numarasi var. ve bu sözlesme status:30 da (sözlesme girilmis) bu durumda tetik kaydi p ye çeliliyor close odeme emri yapilmalimi?
                                             History:      -------------------
                                                           22.01.2007 - YILMAZ SARIDEMIR. IBX0001197
                                         */
      iid                      IN     yk_dp_kontrat_abone_potansiyel.id%TYPE,
      -- Mustafa 07.09.2004 Gereksiz parametre..
      iuye_no                  IN     yk_dp_kontrat_abone_potansiyel.uye_no%TYPE,
      ioutlet_location         IN     yk_dp_kontrat_abone_potansiyel.outlet_location%TYPE,
      isozlesme_no             IN     yk_dp_kontrat_abone_potansiyel.sozlesme_no%TYPE,
      ikisi                    IN     yk_dp_kontrat_abone_potansiyel.kisi%TYPE,
      iprospect_number         IN     wiz_prospect_descrip.prospect_number%TYPE,
      ieslestirme_tipi_abone   IN     CHAR,
      isebep_kodu              IN     pr_sebep_tanim.kod%TYPE,
      iaciklama                IN     yk_dp_kontrat_abone_potansiyel.aciklama%TYPE,
      ikaynak                  IN     VARCHAR2,
      oid                         OUT yk_dp_kontrat_abone_potansiyel.id%TYPE,
      --potansiyel_esleme
      durum                       OUT VARCHAR2,
      igiren_kullanici         IN     VARCHAR2 := NULL,
      itahsilat_id             IN     NUMBER := NULL)
   IS
      --kaynak
      --------------------------------------
      --KONTRAT
      --POTANSIYEL_TETIK
      --POTANSIYEL_ESLEME
      --POTANSIYEL_ARAMA
      --------------------------------------
      v_islem_tarihi                   DATE := SYSDATE;
      v_mgm_tavsiye_edilen             NUMBER (10);
      v_uye_aktif_tarihi               DATE := NULL;
      v_uye_no                         NUMBER (10) := NULL;
      v_potansiyel_no                  NUMBER (10) := NULL;
      v_eslesen_potansiyel_no          NUMBER (10) := NULL;
      v_toplam                         NUMBER (10);
      v_operator_id                    NUMBER (10);
      v_tahsilat_id                    NUMBER (10);
      enable_log                       BOOLEAN;
      out_id                           NUMBER (10);
      out_err_code                     VARCHAR2 (100);
      v_potansiyel_degistirme_tarihi   DATE := SYSDATE;
      v_result_type                    VARCHAR2 (10);
      v_result_code                    VARCHAR2 (50);
      v_result_message                 VARCHAR2 (256);
      v_kaynak                         NUMBER (2);

      /*dtvcaloglu - 10.07.2014 <BEGIN>*/
      v_lg_sf_urun_id                  NUMBER;
      v_durum                          VARCHAR2 (1000);

      /*dtvcaloglu - 10.07.2014 <END>*/

      CURSOR operator_id_cur
      IS
         SELECT wiz_operator_id
           FROM co_kullanici
          WHERE kod = igiren_kullanici;

      CURSOR yk_dp_abone_potansiyel_cur
      IS
         SELECT *
           FROM yk_dp_kontrat_abone_potansiyel
          WHERE id = iid;

      CURSOR wiz_potansiyel_cur
      IS
             SELECT *
               FROM wiz_prospect_descrip
              WHERE prospect_number = v_eslesen_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      CURSOR wiz_mevcut_potansiyel_cur
      IS
             SELECT *
               FROM wiz_prospect_descrip
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      /*Mustafa 18.09.2004
         CURSOR mgm_cur IS
            SELECT * FROM MGM_ABONE_BILGI
           WHERE tavsiye_edilen = v_potansiyel_no
           AND TAVSIYE_EDILEN_TIPI IN (2,3) --Mustafa 07.09.2004
           FOR UPDATE OF degistirme_tarihi NOWAIT;
      */
      CURSOR ut_cur
      IS
             SELECT *
               FROM ut_uye_tavsiye
              WHERE    (    (   NVL (eden_no, -1) = NVL (v_potansiyel_no, -2)
                             OR NVL (eden_sozlesme_no, '-1') =
                                   NVL (isozlesme_no, '-2'))
                        AND eden_kisi_tipi = 2
                        AND eden_kayit_durumu NOT IN (2, 3, 7))
                    OR (    (   NVL (edilen_no, -1) = NVL (v_potansiyel_no, -2)
                             OR NVL (edilen_sozlesme_no, '-1') =
                                   NVL (isozlesme_no, '-2'))
                        AND edilen_kisi_tipi = 2
                        AND edilen_kayit_durumu NOT IN (2, 3, 7))
         FOR UPDATE OF degistirme_tarihi NOWAIT;

      CURSOR anket_cur
      IS
             SELECT *
               FROM ab_abone_cevap
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      -- MUSLU, OCAK-2010
      CURSOR demografik_cur
      IS
             SELECT *
               FROM dg_demografik_abone_cevap
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      /*   cursor memo_cur is
            select * from co_memo_bilgi
           where potansiyel_kodu = v_potansiyel_no
           for update of potansiyel_kodu nowait; */
      CURSOR d2d_cur                                  -- yurtdisida eklendi...
      IS
             SELECT *
               FROM ie_potansiyel_is_emri
              WHERE prospect_number = v_potansiyel_no AND account_number IS NULL
         FOR UPDATE OF prospect_number NOWAIT;

      CURSOR pt_detay_cur
      IS
             SELECT *
               FROM pt_potansiyel_detay
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      /*dtvcaloglu - 25.04.2014 <BEGIN>*/
      CURSOR pt_params_cur
      IS
             SELECT *
               FROM dbs_dba.pt_potansiyel_params
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      /*dtvcaloglu - 25.04.2014 <END>*/

      /*dtvcaloglu - 26.05.2014 - sf_urun update <BEGIN>*/
      CURSOR sf_urun_cur
      IS
             SELECT *
               FROM dbs_dba.sf_urun
              WHERE reserved_prospect_number = v_potansiyel_no
         FOR UPDATE OF reserved_prospect_number NOWAIT;

      /*dtvcaloglu - 25.04.2014 - sf_urun update <END>*/


      CURSOR gonderi_cur
      IS
             SELECT *
               FROM gon_gonderi
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      CURSOR mesaj_cur
      IS
             SELECT *
               FROM mb_memo_mesaj_bilgi
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      CURSOR yorum_cur
      IS
             SELECT *
               FROM mb_yorum_bilgi
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      CURSOR todo_cur
      IS
             SELECT *
               FROM td_todo
              WHERE prospect_number = v_potansiyel_no
         FOR UPDATE OF prospect_number NOWAIT;

      CURSOR randevu_cur
      IS
             SELECT *
               FROM dp_yts_randevu
              WHERE prospect_no = v_potansiyel_no AND isprospect = 1
         FOR UPDATE OF prospect_no NOWAIT;

      CURSOR cur_bt
      IS
         SELECT *
           FROM bt_potansiyel_yts
          WHERE prospect_number = v_potansiyel_no;

      --ct_arama_listesi nok
      --ct_uye_arama_detay nok
      --prospect_to_fatura nok

      --gon_gonderi ok
      --mb_memo_mesaj_bilgi ok
      --mb_yorum_bilgi ok
      --td_todo ok
      --dp_yts_randevu ok
      ut_rec                           ut_cur%ROWTYPE;
      yk_dp_abone_potansiyel_rec       yk_dp_abone_potansiyel_cur%ROWTYPE;
      wiz_potansiyel_rec               wiz_potansiyel_cur%ROWTYPE;
      wiz_mevcut_potansiyel_rec        wiz_mevcut_potansiyel_cur%ROWTYPE;
      -- mgm_rec                  mgm_cur%ROWTYPE;
      anket_rec                        anket_cur%ROWTYPE;
      demografik_rec                   demografik_cur%ROWTYPE;
      -- memo_rec                 memo_cur%rowtype;
      d2d_rec                          d2d_cur%ROWTYPE;
      pt_detay_rec                     pt_detay_cur%ROWTYPE;
      /*dtvcaloglu - 25.04.2014 <BEGIN>*/
      pt_params_rec                    pt_params_cur%ROWTYPE;
      /*dtvcaloglu - 25.04.2014 <END>*/

      /*dtvcaloglu - 26.05.2014 - sf_urun update <BEGIN>*/
      sf_urun_rec                      sf_urun_cur%ROWTYPE;
      o_sonuc_bill_account_transfer    VARCHAR2 (2048);
      o_log_is_emri_hata               VARCHAR2 (1024);
      v_log_save                       BOOLEAN := FALSE;
      /*dtvcaloglu - 25.04.2014 - sf_urun update <END>*/


      gonderi_rec                      gonderi_cur%ROWTYPE;
      mesaj_rec                        mesaj_cur%ROWTYPE;
      yorum_rec                        yorum_cur%ROWTYPE;
      todo_rec                         todo_cur%ROWTYPE;
      randevu_rec                      randevu_cur%ROWTYPE;
      v_count                          NUMBER := 0;
      v_tmp                            VARCHAR2 (100);
      v_payment_status                 NUMBER;
      v_campaign_code                  yk_dp_kontrat.campaign_code%TYPE;
   BEGIN
      durum := '';

      OPEN operator_id_cur;

      FETCH operator_id_cur INTO v_operator_id;

      IF operator_id_cur%NOTFOUND
      THEN
         durum :=
               'Geçersiz Kullanici Kodu! '
            || 'Kullanici Kodu:'
            || igiren_kullanici;

         CLOSE operator_id_cur;

         RETURN;
      END IF;

      CLOSE operator_id_cur;

      IF TRIM (ieslestirme_tipi_abone) = 'E'
      THEN
         --v_potansiyel_no artik v_uye_no üyesi ile eslesmis
         v_uye_no := iuye_no;
         v_potansiyel_no := iprospect_number;
         v_eslesen_potansiyel_no := NULL;

         IF v_uye_no IS NULL
         THEN
            durum := 'Eslestirilen üye no bos.';
            RETURN;
         END IF;

         IF v_potansiyel_no IS NULL
         THEN
            durum := 'Potansiyel no bos.';
            RETURN;
         END IF;

         IF v_uye_no = v_potansiyel_no
         THEN
            durum :=
               'Eslesen potansiyel no ve eslestirilen üye no ayni olamaz.';
            RETURN;
         END IF;
      ELSE
         --v_potansiyel_no artik v_eslesen_potansiyel_no potansiyeli ile eslesmis
         v_uye_no := NULL;
         v_potansiyel_no := iprospect_number;
         v_eslesen_potansiyel_no := iuye_no;

         IF v_potansiyel_no IS NULL
         THEN
            durum := 'Eslestirilen potansiyel no bos.';
            RETURN;
         END IF;

         IF v_eslesen_potansiyel_no IS NULL
         THEN
            durum := 'Eslesen potansiyel no bos.';
            RETURN;
         END IF;

         IF v_potansiyel_no = v_eslesen_potansiyel_no
         THEN
            durum :=
               'Eslesen potansiyel no ve eslestirilen potansiyel no ayni olamaz.';
            RETURN;
         END IF;
      END IF;

      /*TAHSILAT KONTROLLERI */
      --03/07/2004 SGURE
      /*
         SELECT COUNT(*)
         INTO v_toplam
         FROM kmp_taksit
         WHERE PROSPECT_NO =iPROSPECT_NUMBER;

         IF v_toplam>0 THEN
            DURUM := 'TAHSILAT KAYDI BULUNMAKTADIR ESLESEMEZ!';
            RETURN;
         END IF;

         SELECT COUNT(*)
         INTO v_toplam
         FROM coll_dba.LIG_2001_2002_DIGI_PACK
         WHERE PROSPECT_NO =iPROSPECT_NUMBER;

         IF v_toplam>0 THEN
            DURUM := 'TAHSILAT KAYDI BULUNMAKTADIR ESLESEMEZ!';
            RETURN;
         END IF;
         SELECT COUNT(*)
         INTO v_toplam
         FROM coll_dba.LIG_2001_2002_DIGI_PACK_YKB
         WHERE PROSPECT_NO =iPROSPECT_NUMBER;

         IF v_toplam>0 THEN
            DURUM := 'TAHSILAT KAYDI BULUNMAKTADIR ESLESEMEZ! ';
            RETURN;
         END IF;
      */
      IF v_eslesen_potansiyel_no IS NOT NULL
      THEN
         OPEN wiz_potansiyel_cur;

         FETCH wiz_potansiyel_cur INTO wiz_potansiyel_rec;

         IF wiz_potansiyel_cur%NOTFOUND
         THEN
            durum := 'Eslestirilmeye çalisilan potansiyel bulunamadi.';

            CLOSE wiz_potansiyel_cur;

            RETURN;
         END IF;

         CLOSE wiz_potansiyel_cur;
      END IF;

      /*nefise --> bu kontrol yerine prospect'in kaydi abone_no ile update ediliyor.
        SELECT COUNT(1)
         INTO v_count
         FROM ct_arama_listesi
         WHERE prospect_number = v_potansiyel_no;

         IF v_count > 0 THEN
             durum := 'Bu potansiyele ait arama kaydi var. Eslestirme yapilamaz.';
             RETURN;
         END IF;

        SELECT COUNT(1)
         INTO v_count
         FROM ct_uye_arama_detay
         WHERE prospect_number = v_potansiyel_no;

         IF v_count > 0 THEN
             durum := 'Bu potansiyele ait üye arama kaydi var. Eslestirme yapilamaz.';
             RETURN;
         END IF;
      */
      SELECT COUNT (1)
        INTO v_count
        FROM ct_arama_listesi
       WHERE prospect_number = v_potansiyel_no;

      IF v_count > 0
      THEN
         IF v_uye_no IS NOT NULL
         THEN
            UPDATE ct_arama_listesi
               SET account_number = v_uye_no
             WHERE prospect_number = v_potansiyel_no;
         ELSIF v_eslesen_potansiyel_no IS NOT NULL
         THEN
            UPDATE ct_arama_listesi
               SET prospect_number = v_eslesen_potansiyel_no
             WHERE prospect_number = v_potansiyel_no;
         END IF;
      END IF;

      SELECT COUNT (1)
        INTO v_count
        FROM ct_uye_arama_detay
       WHERE prospect_number = v_potansiyel_no;

      IF v_count > 0
      THEN
         IF v_uye_no IS NOT NULL
         THEN
            UPDATE ct_uye_arama_detay
               SET account_number = v_uye_no
             WHERE prospect_number = v_potansiyel_no;
         ELSIF v_eslesen_potansiyel_no IS NOT NULL
         THEN
            UPDATE ct_uye_arama_detay
               SET prospect_number = v_eslesen_potansiyel_no
             WHERE prospect_number = v_potansiyel_no;
         END IF;
      END IF;

      /*tüm kayıtlara bakılması engellendi.
        Bunun yerine aşağıdaki sorgu eklendi.Sadece aktif akışlara bakması sağlandı-MKECECI
        SELECT COUNT (1)
          INTO v_count
          FROM DBS_DBA.DT_INTERNET_UYE_BASVURU
         WHERE prospect_number = v_potansiyel_no;
       */
      SELECT COUNT (1)
        INTO v_count
        FROM dbs_dba.wf_tb_uye_statu s,
             dbs_dba.wf_pr_statu_tanim t,
             dbs_dba.dt_internet_uye_basvuru b
       WHERE     s.statu_tanim_tip = 1
             AND t.tip = 1
             AND t.durum = 'A'
             AND s.durum = 'A'
             AND s.statu = t.statu
             AND s.potansiyel_number = b.prospect_number
             AND b.prospect_number = v_potansiyel_no;

      IF v_count > 0
      THEN
         IF v_uye_no IS NOT NULL
         THEN                                                 --Üyelik bulundu
            BEGIN
               --            --<MKECECI>
               SELECT yk.campaign_code --üyenin kontrat kampanyasi yakalaniyor.
                 INTO v_campaign_code
                 FROM yk_dp_kontrat yk
                WHERE     yk.uye_no = v_uye_no
                      AND yk.outlet_location = ioutlet_location;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_campaign_code := NULL;
            END;

            SELECT COUNT (1)
              INTO v_count
              FROM TABLE (
                      split_table_fnc (
                         dbs_sabit ('DIGINET_UYE_KONTRAT_KAMPANYASI_KOD')))
             WHERE SUBSTR (COLUMN_VALUE, 2, 3) = v_campaign_code;

            SELECT DECODE (TRIM (dt.source), 'TTN', 1, 2)
              INTO v_kaynak
              FROM dbs_dba.dt_internet_uye_basvuru dt
             WHERE prospect_number = v_potansiyel_no;

            /*üyenin kontrat kampanyasi internet kampanyasi ise asagidaki akisa girer*/
            --            IF v_count > 0
            --            THEN
            --               --               DBS_DBA.WF_ISLEM_PACK.WF_AKIS_BASLAT (
            --               --                  i_wf_tip               => 1,
            --               --                  i_account_number      => v_uye_no,
            --               --                  i_outlet_location     => ioutlet_location,
            --               --                  i_potansiyel_number   => NULL,
            --               --                  i_valid_after         => SYSDATE,
            --               --                  i_giren_kullanici     => igiren_kullanici,
            --               --                  o_durum               => durum);
            --               --
            --               --              IF durum <> '0'
            --               --               THEN
            --               --                  durum :=
            --               --                     'HATA - Basvur statüsüne geçilemedi - '
            --               --                     || durum;
            --               --                  RETURN;
            --               --               END IF;
            --
            --               dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (
            --                  i_wf_tip              => v_kaynak,
            --                  i_account_number      => NULL,
            --                  i_outlet_location     => NULL,
            --                  i_potansiyel_number   => v_potansiyel_no,
            --                  i_valid_after         => SYSDATE,
            --                  i_yeni_statu          => 2,
            --                  i_giren_kullanici     => igiren_kullanici,
            --                  o_durum               => durum);
            --
            --               IF durum <> '0'
            --               THEN
            --                  durum :=
            --                        'HATA - Üye olustur statüsüne geçilemedi - '
            --                     || durum;
            --                  RETURN;
            --               END IF;
            --
            --               dbs_dba.wf_islem_pack.wf_uye_potansiyel_degistir (
            --                  i_wf_tip                  => v_kaynak,
            --                  i_old_account_number      => NULL,
            --                  i_old_outlet_location     => NULL,
            --                  i_old_potansiyel_number   => v_potansiyel_no,
            --                  i_new_account_number      => v_uye_no,
            --                  i_new_outlet_location     => ioutlet_location,
            --                  i_new_potansiyel_number   => NULL,
            --                  i_yeni_statu              => NULL,
            --                  i_giren_kullanici         => igiren_kullanici,
            --                  o_durum                   => durum);
            --
            --               IF durum <> '0'
            --               THEN
            --                  durum :=
            --                     'Akis potansiyelden üye üzerine tasinamadi. ' || durum;
            --                  RETURN;
            --               END IF;
            --
            --               dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (
            --                  i_wf_tip              => v_kaynak,
            --                  i_account_number      => v_uye_no,
            --                  i_outlet_location     => ioutlet_location,
            --                  i_potansiyel_number   => NULL,
            --                  i_valid_after         => SYSDATE,
            --                  i_yeni_statu          => 3,
            --                  i_giren_kullanici     => igiren_kullanici,
            --                  o_durum               => durum);
            --
            --              IF durum <> '0'
            --               THEN
            --                  durum :=
            --                        'HATA - TTNET e gönder statüsüne geçilemedi - '
            --                     || durum;
            --                  RETURN;
            --               END IF;
            --            ELSE -- üyenin kampanyasi internet kampanyasi degilse ÜYE OLUSTUR statusunde kaliyor.
            --               --               DBS_DBA.WF_ISLEM_PACK.WF_AKIS_BASLAT (
            --               --                  i_wf_tip               => 1,
            --               --                  i_account_number      => v_uye_no,
            --               --                  i_outlet_location     => ioutlet_location,
            --               --                  i_potansiyel_number   => NULL,
            --               --                  i_valid_after         => SYSDATE,
            --               --                  i_giren_kullanici     => igiren_kullanici,
            --               --                  o_durum               => durum);
            --
            --               --               IF durum <> '0'
            --               --               THEN
            --               --                  durum :=
            --               --                     'HATA - Basvur statüsüne geçilemedi - ' || durum;
            --               --                  RETURN;
            --               --               END IF;
            --
            --               dbs_dba.wf_islem_pack.wf_uye_statusunu_degistir (
            --                  i_wf_tip              => v_kaynak,
            --                  i_account_number      => NULL,
            --                  i_outlet_location     => NULL,
            --                  i_potansiyel_number   => v_potansiyel_no,
            --                  i_valid_after         => SYSDATE,
            --                  i_yeni_statu          => 2,
            --                  i_giren_kullanici     => igiren_kullanici,
            --                  o_durum               => durum);
            --
            --               IF durum <> '0'
            --               THEN
            --                  durum :=
            --                        'HATA - Üye olustur  statüsüne geçilemedi - '
            --                     || durum;
            --                  RETURN;
            --               END IF;
            --
            --               dbs_dba.wf_islem_pack.wf_uye_potansiyel_degistir (
            --                  i_wf_tip                  => v_kaynak,
            --                  i_old_account_number      => NULL,
            --                  i_old_outlet_location     => NULL,
            --                  i_old_potansiyel_number   => v_potansiyel_no,
            --                  i_new_account_number      => v_uye_no,
            --                  i_new_outlet_location     => ioutlet_location,
            --                  i_new_potansiyel_number   => NULL,
            --                  i_yeni_statu              => NULL,
            --                  i_giren_kullanici     => igiren_kullanici,
            --                  o_durum               => durum);
            --
            --               IF durum <> '0'
            --               THEN
            --                  durum :=
            --                        'HATA - Akis potansiyelden üye üzerine aktarilamadi. '
            --                     || durum;
            --                  RETURN;
            --               END IF;
            --            END IF;

            UPDATE dbs_dba.dt_internet_uye_basvuru
               SET account_number = v_uye_no,
                   outlet_location = ioutlet_location,
                   prospect_number = NULL
             WHERE prospect_number = v_potansiyel_no;
         ELSIF v_eslesen_potansiyel_no IS NOT NULL
         THEN
            UPDATE dbs_dba.dt_internet_uye_basvuru
               SET prospect_number = v_eslesen_potansiyel_no
             WHERE prospect_number = v_potansiyel_no;
         --            dbs_dba.wf_islem_pack.wf_uye_potansiyel_degistir (
         --               i_wf_tip                  => v_kaynak,
         --               i_old_account_number      => NULL,
         --               i_old_outlet_location     => NULL,
         --               i_old_potansiyel_number   => v_potansiyel_no,
         --               i_new_account_number      => NULL,
         --               i_new_outlet_location     => NULL,
         --               i_new_potansiyel_number   => v_eslesen_potansiyel_no,
         --               i_yeni_statu              => NULL,
         --               i_giren_kullanici         => igiren_kullanici,
         --               o_durum                   => durum);
         --
         --            IF durum <> '0'
         --            THEN
         --               durum :=
         --                     'HATA - Akis potansiyelden baska bir potansiyele aktarilamadi. '
         --                  || durum;
         --               RETURN;
         --            END IF;
         END IF;
      END IF;

      OPEN yk_dp_abone_potansiyel_cur;

      FETCH yk_dp_abone_potansiyel_cur INTO yk_dp_abone_potansiyel_rec;

      IF yk_dp_abone_potansiyel_cur%NOTFOUND
      THEN
         SELECT yk_dp_abone_potansiyel_id_seq.NEXTVAL INTO oid FROM DUAL;

         INSERT INTO yk_dp_kontrat_abone_potansiyel (id,
                                                     uye_no,
                                                     outlet_location,
                                                     sozlesme_no,
                                                     kisi,
                                                     islem_tarihi,
                                                     potansiyel_no,
                                                     sebep_kodu,
                                                     aciklama)
              VALUES (oid,
                      TRIM (v_uye_no),
                      ioutlet_location,
                      isozlesme_no,
                      ikisi,
                      v_islem_tarihi,
                      TRIM (v_eslesen_potansiyel_no),
                      TRIM (isebep_kodu),
                      TRIM (iaciklama));

         durum := '0';
      ELSE
         durum := 'Bu kayit zaten var.';
         RETURN;
      END IF;

      CLOSE yk_dp_abone_potansiyel_cur;

      ---------------------------------------------------------
      --gonderi kayitlari
      ---------------------------------------------------------
      OPEN gonderi_cur;

      LOOP
         FETCH gonderi_cur INTO gonderi_rec;

         IF gonderi_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE gon_gonderi
                  SET prospect_number = v_eslesen_potansiyel_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                            || TRIM (v_potansiyel_no),
                            1,
                            1000)
                WHERE CURRENT OF gonderi_cur;
            ELSE
               UPDATE gon_gonderi
                  SET account_number = v_uye_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Abone no güncellendi.',
                            1,
                            1000)
                WHERE CURRENT OF gonderi_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE gonderi_cur;

      ---------------------------------------------------------
      --mesaj kayitlari
      ---------------------------------------------------------
      OPEN mesaj_cur;

      LOOP
         FETCH mesaj_cur INTO mesaj_rec;

         IF mesaj_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE mb_memo_mesaj_bilgi
                  SET prospect_number = v_eslesen_potansiyel_no
                WHERE CURRENT OF mesaj_cur;
            ELSE
               UPDATE mb_memo_mesaj_bilgi
                  SET account_number = v_uye_no
                WHERE CURRENT OF mesaj_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE mesaj_cur;

      ---------------------------------------------------------
      --yorum kayitlari
      ---------------------------------------------------------
      OPEN yorum_cur;

      LOOP
         FETCH yorum_cur INTO yorum_rec;

         IF yorum_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE mb_yorum_bilgi
                  SET prospect_number = v_eslesen_potansiyel_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                            || TRIM (v_potansiyel_no),
                            1,
                            255)
                WHERE CURRENT OF yorum_cur;
            ELSE
               UPDATE mb_yorum_bilgi
                  SET account_number = v_uye_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Abone no güncellendi.',
                            1,
                            255)
                WHERE CURRENT OF yorum_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE yorum_cur;

      ---------------------------------------------------------
      --todo kayitlari
      ---------------------------------------------------------
      OPEN todo_cur;

      LOOP
         FETCH todo_cur INTO todo_rec;

         IF todo_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE td_todo
                  SET prospect_number = v_eslesen_potansiyel_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                            || TRIM (v_potansiyel_no),
                            1,
                            255)
                WHERE CURRENT OF todo_cur;
            ELSE
               UPDATE td_todo
                  SET account_number = v_uye_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Abone no güncellendi.',
                            1,
                            255)
                WHERE CURRENT OF todo_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE todo_cur;

      ---------------------------------------------------------
      --yts randevu kayitlari
      ---------------------------------------------------------
      OPEN randevu_cur;

      LOOP
         FETCH randevu_cur INTO randevu_rec;

         IF randevu_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE dp_yts_randevu
                  SET prospect_no = v_eslesen_potansiyel_no,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - P.No güncelleme.Eski P.No: '
                            || TRIM (v_potansiyel_no),
                            1,
                            50)
                WHERE CURRENT OF randevu_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE randevu_cur;

      ---------------------------------------------------------
      --anket kayitlari
      ---------------------------------------------------------
      OPEN anket_cur;

      LOOP
         FETCH anket_cur INTO anket_rec;

         IF anket_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE ab_abone_cevap
                  SET prospect_number = v_eslesen_potansiyel_no
                WHERE CURRENT OF anket_cur;
            ELSE
               UPDATE ab_abone_cevap
                  SET account_number = v_uye_no
                WHERE CURRENT OF anket_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE anket_cur;

      ---------------------------------------------------------
      --demografik kayitlari , MUSLU, OCAK-2010
      ---------------------------------------------------------
      OPEN demografik_cur;

      LOOP
         FETCH demografik_cur INTO demografik_rec;

         IF demografik_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE dg_demografik_abone_cevap
                  SET prospect_number = v_eslesen_potansiyel_no
                WHERE CURRENT OF demografik_cur;
            ELSE
               UPDATE dg_demografik_abone_cevap
                  SET account_number = v_uye_no
                WHERE CURRENT OF demografik_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE demografik_cur;

      ---------------------------------------------------------
      --memo kayitlari
      ---------------------------------------------------------
      /* open memo_cur;
         loop
         fetch memo_cur into memo_rec;
           if memo_cur%found then
             if trim(v_eslesen_potansiyel_no) is not null then
                update co_memo_bilgi
              set potansiyel_kodu = trim(v_eslesen_potansiyel_no),
                  memo_aciklama = trim(memo_aciklama)|| ' Sistem - Potansiyel no güncellendi.Eski P.No: '||trim(v_potansiyel_no)
              where current of memo_cur;

            else
                update co_memo_bilgi
              set abone_kodu = trim(v_uye_no),
                  memo_aciklama = trim(memo_aciklama)|| ' Sistem - Abone no güncellendi.'
              where current of memo_cur;
            end if;
            else
             exit;
           end if;
         end loop;
         close memo_cur;
      */

      ---------------------------------------------------------
      --d2d kayitlari
      ---------------------------------------------------------
      OPEN d2d_cur;

      LOOP
         FETCH d2d_cur INTO d2d_rec;

         IF d2d_cur%FOUND
         THEN
            IF v_eslesen_potansiyel_no IS NOT NULL
            THEN
               UPDATE ie_potansiyel_is_emri
                  SET prospect_number = v_eslesen_potansiyel_no,
                      degistirme_tarihi = SYSDATE,
                      degistiren_kullanici = ikisi,
                      aciklama =
                         SUBSTR (
                               TRIM (aciklama)
                            || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                            || TRIM (v_potansiyel_no),
                            1,
                            255)
                WHERE CURRENT OF d2d_cur;

               INSERT INTO lg_potansiyel_is_emri (id,
                                                  islem,
                                                  kisi,
                                                  tarih,
                                                  potansiyel_is_emri_id,
                                                  account_number,
                                                  prospect_number,
                                                  kisi_tipi,
                                                  islem_tipi,
                                                  service_address_id,
                                                  yeni_service_address_id,
                                                  sc_serial_number,
                                                  st_serial_number,
                                                  yeni_sc_serial_number,
                                                  yeni_st_serial_number,
                                                  service_code,
                                                  campaign_code,
                                                  promotion_code,
                                                  durum,
                                                  islem_tarihi,
                                                  reason_code,
                                                  sozlesme_no,
                                                  sozlesme_kampanya,
                                                  servis_frekansi,
                                                  bayi_kodu,
                                                  ekip_kodu,
                                                  tahsilat_yapildi,
                                                  aciklama)
                       VALUES (
                                 lg_potansiyel_is_emri_id_seq.NEXTVAL,
                                 'U',
                                 ikisi,
                                 SYSDATE,
                                 d2d_rec.id,
                                 d2d_rec.account_number,
                                 TRIM (v_eslesen_potansiyel_no),
                                 d2d_rec.kisi_tipi,
                                 d2d_rec.islem_tipi,
                                 d2d_rec.service_address_id,
                                 d2d_rec.yeni_service_address_id,
                                 d2d_rec.sc_serial_number,
                                 d2d_rec.st_serial_number,
                                 d2d_rec.yeni_sc_serial_number,
                                 d2d_rec.yeni_st_serial_number,
                                 d2d_rec.service_code,
                                 d2d_rec.campaign_code,
                                 d2d_rec.promotion_code,
                                 d2d_rec.durum,
                                 d2d_rec.islem_tarihi,
                                 d2d_rec.reason_code,
                                 d2d_rec.sozlesme_no,
                                 d2d_rec.sozlesme_kampanya,
                                 d2d_rec.servis_frekansi,
                                 d2d_rec.bayi_kodu,
                                 d2d_rec.ekip_kodu,
                                 d2d_rec.tahsilat_yapildi,
                                 SUBSTR (
                                       TRIM (d2d_rec.aciklama)
                                    || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                                    || TRIM (v_potansiyel_no),
                                    1,
                                    255));

               IF d2d_rec.islem_tipi = 1
               THEN
                  billing_dbs_int.onl_prospect_ittp_pkg.merge_pros_to_pros (
                     i_tetik_id              => d2d_rec.id,
                     i_new_prospect_number   => v_eslesen_potansiyel_no,
                     o_result_type           => v_result_type,
                     o_result_code           => v_result_code,
                     o_result_message        => v_result_message);

                  IF v_result_type = 1
                  THEN
                     durum := v_result_code || ':' || v_result_message;
                     RETURN;
                  END IF;
               END IF;
            ELSE                             -- Eslestiridigimiz kayidimiz üye
               IF     TRIM (d2d_rec.sozlesme_no) IS NOT NULL
                  AND (   TRIM (d2d_rec.islem_tipi) = 11
                       OR TRIM (d2d_rec.islem_tipi) = 1)
                  AND TRIM (d2d_rec.durum) = 'C' -- sadece kapali ise iseleme devam et.
               THEN
                  SELECT COUNT (1)
                    INTO v_count
                    FROM dp_account_no
                   WHERE contract_no = TRIM (d2d_rec.sozlesme_no);

                  IF v_count = 0
                  THEN
                     --Üye eslesmesi var, fakat tetikte yazan sözlesme sisteme henüz girilmemis
                     -----------------------------------------------------------------------------------------------------
                     --           vazgeçtik eslesme yapilacak fakat kapali ve üye noso dolu olanlara dokunulmayacak
                     -----------------------------------------------------------------------------------------------------
                     --             durum := 'Potansiyelin açik D2D potansiyel tetik kaydi var.Eslesme yapilamaz.';
                     --             return;
                     UPDATE ie_potansiyel_is_emri
                        SET account_number = v_uye_no,
                            degistirme_tarihi = SYSDATE,
                            degistiren_kullanici = ikisi,
                            aciklama =
                               SUBSTR (
                                     TRIM (aciklama)
                                  || ' Sistem - Abone no güncellendi.',
                                  1,
                                  255)
                      WHERE CURRENT OF d2d_cur;

                     INSERT
                       INTO lg_potansiyel_is_emri (id,
                                                   islem,
                                                   kisi,
                                                   tarih,
                                                   potansiyel_is_emri_id,
                                                   account_number,
                                                   prospect_number,
                                                   kisi_tipi,
                                                   islem_tipi,
                                                   service_address_id,
                                                   yeni_service_address_id,
                                                   sc_serial_number,
                                                   st_serial_number,
                                                   yeni_sc_serial_number,
                                                   yeni_st_serial_number,
                                                   service_code,
                                                   campaign_code,
                                                   promotion_code,
                                                   durum,
                                                   islem_tarihi,
                                                   reason_code,
                                                   sozlesme_no,
                                                   sozlesme_kampanya,
                                                   servis_frekansi,
                                                   bayi_kodu,
                                                   ekip_kodu,
                                                   tahsilat_yapildi,
                                                   aciklama)
                        VALUES (
                                  lg_potansiyel_is_emri_id_seq.NEXTVAL,
                                  'U',
                                  ikisi,
                                  SYSDATE,
                                  d2d_rec.id,
                                  TRIM (v_uye_no),
                                  d2d_rec.prospect_number,
                                  d2d_rec.kisi_tipi,
                                  d2d_rec.islem_tipi,
                                  d2d_rec.service_address_id,
                                  d2d_rec.yeni_service_address_id,
                                  d2d_rec.sc_serial_number,
                                  d2d_rec.st_serial_number,
                                  d2d_rec.yeni_sc_serial_number,
                                  d2d_rec.yeni_st_serial_number,
                                  d2d_rec.service_code,
                                  d2d_rec.campaign_code,
                                  d2d_rec.promotion_code,
                                  d2d_rec.durum,
                                  d2d_rec.islem_tarihi,
                                  d2d_rec.reason_code,
                                  d2d_rec.sozlesme_no,
                                  d2d_rec.sozlesme_kampanya,
                                  d2d_rec.servis_frekansi,
                                  d2d_rec.bayi_kodu,
                                  d2d_rec.ekip_kodu,
                                  d2d_rec.tahsilat_yapildi,
                                  SUBSTR (
                                        TRIM (d2d_rec.aciklama)
                                     || ' Sistem - Abone no güncellendi.',
                                     1,
                                     255));
                  -- Evrim Kayan, Subat 2012,  merge_prospect_account içinde VAN tasinior olmali.
                  --
                  -- fatura.yd_collection_pack.match_van (v_potansiyel_no, v_uye_no, v_tmp, durum);
                  ELSE
                     -- üye dolu , potansiyelinde sölesmesi sistemde girilmis. Ve durum O
                     UPDATE ie_potansiyel_is_emri
                        SET account_number = v_uye_no,
                            durum = 'P',
                            degistirme_tarihi = SYSDATE,
                            tam_kapanma_tarihi = SYSDATE,
                            degistiren_kullanici = ikisi,
                            aciklama =
                               SUBSTR (
                                     TRIM (aciklama)
                                  || ' Sistem - Abone no güncellendi ve tetik sözlesme ile eslestiginde kapatildi.',
                                  1,
                                  255)
                      WHERE CURRENT OF d2d_cur;

                     INSERT
                       INTO lg_potansiyel_is_emri (id,
                                                   islem,
                                                   kisi,
                                                   tarih,
                                                   potansiyel_is_emri_id,
                                                   account_number,
                                                   prospect_number,
                                                   kisi_tipi,
                                                   islem_tipi,
                                                   service_address_id,
                                                   yeni_service_address_id,
                                                   sc_serial_number,
                                                   st_serial_number,
                                                   yeni_sc_serial_number,
                                                   yeni_st_serial_number,
                                                   service_code,
                                                   campaign_code,
                                                   promotion_code,
                                                   durum,
                                                   islem_tarihi,
                                                   reason_code,
                                                   sozlesme_no,
                                                   sozlesme_kampanya,
                                                   servis_frekansi,
                                                   bayi_kodu,
                                                   ekip_kodu,
                                                   tahsilat_yapildi,
                                                   aciklama)
                        VALUES (
                                  lg_potansiyel_is_emri_id_seq.NEXTVAL,
                                  'U',
                                  ikisi,
                                  SYSDATE,
                                  d2d_rec.id,
                                  TRIM (v_uye_no),
                                  d2d_rec.prospect_number,
                                  d2d_rec.kisi_tipi,
                                  d2d_rec.islem_tipi,
                                  d2d_rec.service_address_id,
                                  d2d_rec.yeni_service_address_id,
                                  d2d_rec.sc_serial_number,
                                  d2d_rec.st_serial_number,
                                  d2d_rec.yeni_sc_serial_number,
                                  d2d_rec.yeni_st_serial_number,
                                  d2d_rec.service_code,
                                  d2d_rec.campaign_code,
                                  d2d_rec.promotion_code,
                                  'P',
                                  d2d_rec.islem_tarihi,
                                  d2d_rec.reason_code,
                                  d2d_rec.sozlesme_no,
                                  d2d_rec.sozlesme_kampanya,
                                  d2d_rec.servis_frekansi,
                                  d2d_rec.bayi_kodu,
                                  d2d_rec.ekip_kodu,
                                  d2d_rec.tahsilat_yapildi,
                                  SUBSTR (
                                        TRIM (d2d_rec.aciklama)
                                     || ' Sistem - Abone no güncellendi ve tetik sözlesme ile eslestiginde kapatildi.',
                                     1,
                                     255));

                     -----------------------------------------------------------------------------
                     -- Evrim Kayan, Subat 2012 , ITTP ödeme emri kapanmasi.
                     -- ödeme emri kapanirken, UPS için collection kaydi olusur.
                     -----------------------------------------------------------------------------
                     billing_dbs_int.onl_order_dbs_pkg.close_payment_order (
                        i_sozlesme_no   => NULL,
                        i_tetik_id      => d2d_rec.id,
                        o_durum         => durum);
                  -----------------------------------------------------------------------------
                  END IF;
               ELSIF     TRIM (d2d_rec.account_number) IS NOT NULL
                     AND TRIM (d2d_rec.sozlesme_no) IS NOT NULL
                     AND (   TRIM (d2d_rec.islem_tipi) = 11
                          OR TRIM (d2d_rec.islem_tipi) = 1)
                     AND TRIM (d2d_rec.durum) = 'P'
               THEN
                  NULL;
               ELSE
                  UPDATE ie_potansiyel_is_emri
                     SET account_number = v_uye_no,
                         degistirme_tarihi = SYSDATE,
                         degistiren_kullanici = ikisi,
                         aciklama =
                            SUBSTR (
                                  TRIM (aciklama)
                               || ' Sistem - Abone no güncellendi.',
                               1,
                               255)
                   WHERE CURRENT OF d2d_cur;

                  INSERT INTO lg_potansiyel_is_emri (id,
                                                     islem,
                                                     kisi,
                                                     tarih,
                                                     potansiyel_is_emri_id,
                                                     account_number,
                                                     prospect_number,
                                                     kisi_tipi,
                                                     islem_tipi,
                                                     service_address_id,
                                                     yeni_service_address_id,
                                                     sc_serial_number,
                                                     st_serial_number,
                                                     yeni_sc_serial_number,
                                                     yeni_st_serial_number,
                                                     service_code,
                                                     campaign_code,
                                                     promotion_code,
                                                     durum,
                                                     islem_tarihi,
                                                     reason_code,
                                                     sozlesme_no,
                                                     sozlesme_kampanya,
                                                     servis_frekansi,
                                                     bayi_kodu,
                                                     ekip_kodu,
                                                     tahsilat_yapildi,
                                                     aciklama)
                          VALUES (
                                    lg_potansiyel_is_emri_id_seq.NEXTVAL,
                                    'U',
                                    ikisi,
                                    SYSDATE,
                                    d2d_rec.id,
                                    TRIM (v_uye_no),
                                    d2d_rec.prospect_number,
                                    d2d_rec.kisi_tipi,
                                    d2d_rec.islem_tipi,
                                    d2d_rec.service_address_id,
                                    d2d_rec.yeni_service_address_id,
                                    d2d_rec.sc_serial_number,
                                    d2d_rec.st_serial_number,
                                    d2d_rec.yeni_sc_serial_number,
                                    d2d_rec.yeni_st_serial_number,
                                    d2d_rec.service_code,
                                    d2d_rec.campaign_code,
                                    d2d_rec.promotion_code,
                                    d2d_rec.durum,
                                    d2d_rec.islem_tarihi,
                                    d2d_rec.reason_code,
                                    d2d_rec.sozlesme_no,
                                    d2d_rec.sozlesme_kampanya,
                                    d2d_rec.servis_frekansi,
                                    d2d_rec.bayi_kodu,
                                    d2d_rec.ekip_kodu,
                                    d2d_rec.tahsilat_yapildi,
                                    SUBSTR (
                                          TRIM (d2d_rec.aciklama)
                                       || ' Sistem - Abone no güncellendi.',
                                       1,
                                       255));
               END IF;

               ----------------------------------------------
               -- begin ittp
               -- Evrim Kayan, Subat 2012
               -- pot-uye eslesmesi kodu, alta alindi.
               -- ITTP'deki tetik bazinda pot acc açma entegrasyonu saglandi
               -- billing_dbs_int.onl_prospect_ittp_pkg.merge_pros_acc
               IF d2d_rec.islem_tipi = 1
               THEN
                  billing_dbs_int.onl_prospect_ittp_pkg.merge_pros_to_acc (
                     i_tetik_id         => d2d_rec.id,
                     i_account_number   => v_uye_no,
                     o_result_type      => v_result_type,
                     o_result_code      => v_result_code,
                     o_result_message   => v_result_message);

                  IF v_result_type = 1
                  THEN
                     durum := v_result_code || ':' || v_result_message;
                     RETURN;
                  END IF;
               END IF;
            -- end ittp
            --------------------------------------------
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE d2d_cur;

      -- LG_POTANSIYEL_IS_EMRI
      --  bütün tetikler update p-> p için ok
      --  p-->a açik tetik varsa kapatma islem hata
      --  eslesen d2d ler kapali olmali
      --  adamin d2d disinda ki tetikleri ne oluyor veya silinme olayi????
      -- açiklama eklenecek

      ---------------------------------------------------------------
      --pt_potansiyel_detay kayitlari
      ---------------------------------------------------------------
      IF TRIM (v_eslesen_potansiyel_no) IS NOT NULL
      THEN
         OPEN pt_detay_cur;

         LOOP
            FETCH pt_detay_cur INTO pt_detay_rec;

            IF pt_detay_cur%FOUND
            THEN
               SELECT COUNT (1)
                 INTO v_count
                 FROM pt_potansiyel_detay
                WHERE prospect_number = TRIM (v_eslesen_potansiyel_no);

               IF v_count = 0
               THEN
                  UPDATE pt_potansiyel_detay
                     SET prospect_number = TRIM (v_eslesen_potansiyel_no)
                   WHERE CURRENT OF pt_detay_cur;
               END IF;
            ELSE
               EXIT;
            END IF;
         END LOOP;

         CLOSE pt_detay_cur;
      END IF;

      /*dtvcaloglu - 25.04.2014 <BEGIN>*/
      OPEN pt_params_cur;

      LOOP
         FETCH pt_params_cur INTO pt_params_rec;

         IF pt_params_cur%FOUND
         THEN
            IF TRIM (v_eslesen_potansiyel_no) IS NOT NULL
            THEN
               UPDATE dbs_dba.pt_potansiyel_params
                  SET prospect_number = v_eslesen_potansiyel_no,
                      degistiren_kullanici = igiren_kullanici,
                      degistirme_tarihi = SYSDATE
                WHERE CURRENT OF pt_params_cur;
            ELSE
               UPDATE dbs_dba.pt_potansiyel_params
                  SET account_number = v_uye_no,
                      degistiren_kullanici = igiren_kullanici,
                      degistirme_tarihi = SYSDATE,
                      outlet_location = ioutlet_location
                WHERE CURRENT OF pt_params_cur;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE pt_params_cur;

      /*dtvcaloglu - 25.04.2014 <END>*/

      /*dtvcaloglu - 26.05.2014 - sf_urun update <BEGIN>*/
      IF TRIM (v_eslesen_potansiyel_no) IS NOT NULL
      THEN
         OPEN sf_urun_cur;

         LOOP
            FETCH sf_urun_cur INTO sf_urun_rec;

            IF sf_urun_cur%FOUND
            THEN
               sf_pack.sf_urun_update_for_prospect (
                  in_seri_no               => sf_urun_rec.seri_no,
                  in_durum                 => sf_urun_rec.durum,
                  in_detay_durum           => sf_urun_rec.detay_durum,
                  in_prospect_number       => v_eslesen_potansiyel_no,
                  in_equip_location_code   => sf_urun_rec.equip_location_code,
                  in_kaynak                => sf_urun_rec.kaynak,
                  in_aciklama              => sf_urun_rec.aciklama,
                  in_kullanici             => igiren_kullanici,
                  out_lg_sf_urun_id        => v_lg_sf_urun_id,
                  out_durum                => v_durum);
            ELSE
               EXIT;
            END IF;
         END LOOP;

         CLOSE sf_urun_cur;

         BEGIN
            dt_billing_api.collection_pkg.bill_account_transfer_sp (
               i_from_prospect_number   => v_potansiyel_no,
               i_to_prospect_number     => v_eslesen_potansiyel_no,
               i_to_account_number      => NULL,
               i_kullanici              => igiren_kullanici,
               o_status                 => o_sonuc_bill_account_transfer);

            IF o_sonuc_bill_account_transfer <> '0'
            THEN
               v_log_save := TRUE;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               o_sonuc_bill_account_transfer := SUBSTR (SQLERRM, 1, 300);
               v_log_save := TRUE;
         END;
      ELSE
         --
         --          OPEN sf_urun_cur;
         --
         --          LOOP
         --             FETCH sf_urun_cur INTO sf_urun_rec;
         --
         --             IF sf_urun_cur%NOTFOUND
         --             THEN
         --                UPDATE dbs_dba.sf_urun
         --                   SET account_number = v_uye_no,
         --                       degistiren_kullanici = igiren_kullanici,
         --                       degistirme_tarihi = SYSDATE,
         --                       outlet_location = ioutlet_location
         --                 WHERE CURRENT OF sf_urun_cur;
         --             END IF;
         --          END LOOP;
         --
         --          CLOSE sf_urun_cur;
         BEGIN
            dt_billing_api.collection_pkg.bill_account_transfer_sp (
               i_from_prospect_number   => v_potansiyel_no,
               i_to_prospect_number     => NULL,
               i_to_account_number      => v_uye_no,
               i_kullanici              => igiren_kullanici,
               o_status                 => o_sonuc_bill_account_transfer);


            IF o_sonuc_bill_account_transfer <> '0'
            THEN
               v_log_save := TRUE;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               o_sonuc_bill_account_transfer := SUBSTR (SQLERRM, 1, 300);
               v_log_save := TRUE;
         END;
      END IF;

      IF v_log_save
      THEN
         DBS_DBA.LOG_PACK.LOG_IS_EMRI_HATA (
            P_WORK_ORDER_NUMBER      => NULL,
            P_ADRES_DEGISIKLIGI_ID   => NULL,
            P_UYELIK_IPTAL_ID        => NULL,
            P_UYELIK_DONDURMA_ID     => NULL,
            P_UYELIK_KAPAMA_ID       => NULL,
            P_ISLEM_TIPI             => 'H',
            P_GIREN_KULLANICI        => igiren_kullanici,
            P_GIRIS_TARIHI           => SYSDATE,
            P_DURUM                  => 'O',
            P_ACIKLAMA               =>    'KONTRAT_PACK.YK_DP_ABONE_POTANSIYEL_INS => dt_billing_api.collection_pkg.bill_account_transfer_sp:'
                                        || o_sonuc_bill_account_transfer
                                        || 'potansiyel_no='
                                        || v_potansiyel_no
                                        || ' - eslesen_potansiyel_no='
                                        || v_eslesen_potansiyel_no
                                        || ' - v_uye_no='
                                        || v_uye_no,
            P_RETURN_STATUS          => o_log_is_emri_hata);
      END IF;

      /*dtvcaloglu - 25.04.2014 - sf_urun update <END>*/
      ---------------------------------------------------------------
      --mgm,lider kayitlari
      ---------------------------------------------------------------
      OPEN ut_cur;

      LOOP
         FETCH ut_cur INTO ut_rec;

         IF ut_cur%FOUND
         THEN
            IF TRIM (v_uye_no) IS NULL
            THEN
               --potansiyel ile potansiyel eslesiyor
               IF ut_rec.eden_no = v_potansiyel_no
               THEN
                  UPDATE ut_uye_tavsiye
                     SET eden_no = TRIM (v_eslesen_potansiyel_no),
                         degistiren_kullanici = ikisi,
                         degistirme_tarihi = SYSDATE,
                         eden_aciklama =
                            SUBSTR (
                                  TRIM (eden_aciklama)
                               || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                               || TRIM (v_potansiyel_no),
                               1,
                               240)
                   WHERE CURRENT OF ut_cur;
               ELSIF ut_rec.edilen_no = v_potansiyel_no
               THEN
                  UPDATE ut_uye_tavsiye
                     SET edilen_no = TRIM (v_eslesen_potansiyel_no),
                         degistiren_kullanici = ikisi,
                         degistirme_tarihi = SYSDATE,
                         edilen_aciklama =
                            SUBSTR (
                                  TRIM (edilen_aciklama)
                               || ' Sistem - Potansiyel no güncellendi.Eski P.No: '
                               || TRIM (v_potansiyel_no),
                               1,
                               240)
                   WHERE CURRENT OF ut_cur;
               END IF;
            ELSE
               --potansiyel üye ile eslesiyor...
               SELECT COUNT (*)
                 INTO v_count
                 FROM ut_uye_tavsiye
                WHERE    (    eden_kayit_tipi = 4
                          AND edilen_kayit_tipi <> 4
                          AND edilen_kayit_durumu = 2
                          AND edilen_account_number = TRIM (v_uye_no))
                      OR     (    edilen_kayit_tipi = 4
                              AND eden_kayit_tipi <> 4
                              AND eden_kayit_durumu = 2
                              AND eden_account_number = TRIM (v_uye_no))
                         AND kampanya_kodu = ut_rec.kampanya_kodu;

               IF v_count = 0
               THEN
                  SELECT COUNT (*)
                    INTO v_count
                    FROM (  SELECT no
                              FROM (SELECT DECODE (edilen_account_number,
                                                   TRIM (v_uye_no), edilen_no,
                                                   eden_no)
                                              no
                                      FROM ut_uye_tavsiye
                                     WHERE    (    eden_kayit_tipi <> 4
                                               AND edilen_kayit_tipi <> 4
                                               AND edilen_kayit_durumu = 2
                                               AND edilen_account_number =
                                                      TRIM (v_uye_no))
                                           OR     (    edilen_kayit_tipi <> 4
                                                   AND eden_kayit_tipi <> 4
                                                   AND eden_kayit_durumu = 2
                                                   AND eden_account_number =
                                                          TRIM (v_uye_no))
                                              AND kampanya_kodu =
                                                     ut_rec.kampanya_kodu)
                          GROUP BY no
                            HAVING COUNT (*) > 1);
               END IF;

               IF v_count = 0
               THEN
                  BEGIN
                     SELECT install_date
                       INTO v_uye_aktif_tarihi
                       FROM wiz_customer_hp_life
                      WHERE account_number = TRIM (v_uye_no);
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        durum := 'Eslestirilmeye çalisilan abone bulunamadi.';
                        RETURN;
                  END;

                  IF ut_rec.giris_tarihi <= v_uye_aktif_tarihi
                  THEN
                     uye_tavsiye_pack.uye_tavsiye_finalize (
                        TRIM (v_potansiyel_no),
                        2,
                        isozlesme_no,
                        TRIM (v_uye_no),
                        ioutlet_location,
                        isebep_kodu,
                        ikisi,
                        durum);

                     IF durum = '0'
                     THEN
                        EXIT;
                     END IF;
                  ELSE
                     IF    NVL (ut_rec.eden_no, -1) =
                              NVL (v_potansiyel_no, -2)
                        OR NVL (ut_rec.eden_sozlesme_no, '-1') =
                              NVL (isozlesme_no, '-2')
                     THEN
                        uye_tavsiye_pack.uye_tavsiye_update (
                           ut_rec.id,
                           ut_rec.kaynak,
                           ut_rec.eden_sozlesme_no,
                           3,
                           ut_rec.eden_account_number,
                           ut_rec.eden_outlet_location,
                           ut_rec.eden_kayit_tipi,
                           'M03',
                           SUBSTR (
                                 TRIM (ut_rec.eden_aciklama)
                              || ' Sistem - Üye, Üye Tavsiye kaydindan önce sisteme girmis.',
                              1,
                              240),
                           ut_rec.eden_ts,
                           ut_rec.edilen_sozlesme_no,
                           ut_rec.edilen_kayit_durumu,
                           ut_rec.edilen_account_number,
                           ut_rec.edilen_outlet_location,
                           ut_rec.edilen_kayit_tipi,
                           ut_rec.edilen_sebep_kodu,
                           ut_rec.edilen_aciklama,
                           ut_rec.edilen_ts,
                           ikisi,
                           durum);
                     ELSE
                        uye_tavsiye_pack.uye_tavsiye_update (
                           ut_rec.id,
                           ut_rec.kaynak,
                           ut_rec.eden_sozlesme_no,
                           ut_rec.eden_kayit_durumu,
                           ut_rec.eden_account_number,
                           ut_rec.eden_outlet_location,
                           ut_rec.eden_kayit_tipi,
                           ut_rec.eden_sebep_kodu,
                           ut_rec.eden_aciklama,
                           ut_rec.eden_ts,
                           ut_rec.edilen_sozlesme_no,
                           3,
                           ut_rec.edilen_account_number,
                           ut_rec.edilen_outlet_location,
                           ut_rec.edilen_kayit_tipi,
                           'M03',
                           SUBSTR (
                                 TRIM (ut_rec.edilen_aciklama)
                              || ' Sistem - Üye, Üye Tavsiye kaydindan önce sisteme girmis.',
                              1,
                              240),
                           ut_rec.edilen_ts,
                           ikisi,
                           durum);
                     END IF;
                  END IF;
               ELSE
                  IF    NVL (ut_rec.eden_no, -1) = NVL (v_potansiyel_no, -2)
                     OR NVL (ut_rec.eden_sozlesme_no, '-1') =
                           NVL (isozlesme_no, '-2')
                  THEN
                     uye_tavsiye_pack.uye_tavsiye_update (
                        ut_rec.id,
                        ut_rec.kaynak,
                        ut_rec.eden_sozlesme_no,
                        3,
                        ut_rec.eden_account_number,
                        ut_rec.eden_outlet_location,
                        ut_rec.eden_kayit_tipi,
                        'M04',
                        SUBSTR (
                              TRIM (ut_rec.eden_aciklama)
                           || ' Sistem - Üye, farkli potansiyel nolara sahip fakat ayni potansiyeli iki kere tavsiye etmis.',
                           1,
                           240),
                        ut_rec.eden_ts,
                        ut_rec.edilen_sozlesme_no,
                        ut_rec.edilen_kayit_durumu,
                        ut_rec.edilen_account_number,
                        ut_rec.edilen_outlet_location,
                        ut_rec.edilen_kayit_tipi,
                        ut_rec.edilen_sebep_kodu,
                        ut_rec.edilen_aciklama,
                        ut_rec.edilen_ts,
                        ikisi,
                        durum);
                  ELSE
                     uye_tavsiye_pack.uye_tavsiye_update (
                        ut_rec.id,
                        ut_rec.kaynak,
                        ut_rec.eden_sozlesme_no,
                        ut_rec.eden_kayit_durumu,
                        ut_rec.eden_account_number,
                        ut_rec.eden_outlet_location,
                        ut_rec.eden_kayit_tipi,
                        ut_rec.eden_sebep_kodu,
                        ut_rec.eden_aciklama,
                        ut_rec.eden_ts,
                        ut_rec.edilen_sozlesme_no,
                        3,
                        ut_rec.edilen_account_number,
                        ut_rec.edilen_outlet_location,
                        ut_rec.edilen_kayit_tipi,
                        'M04',
                        SUBSTR (
                              TRIM (ut_rec.edilen_aciklama)
                           || ' Sistem - Üye, farkli potansiyel nolara sahip fakat ayni potansiyeli iki kere tavsiye etmis.',
                           1,
                           240),
                        ut_rec.edilen_ts,
                        ikisi,
                        durum);
                  END IF;
               END IF;
            END IF;

            IF durum <> '0'
            THEN
               RETURN;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      CLOSE ut_cur;

      /*Mustafa 18.09.2004
         OPEN mgm_cur;
         LOOP
         FETCH mgm_cur INTO mgm_rec;
          IF mgm_cur%FOUND THEN
            IF trim(v_uye_no) IS NULL THEN
                --potansiyel ile potansiyel eslesiyor
                UPDATE MGM_ABONE_BILGI
               SET tavsiye_edilen = trim(v_eslesen_potansiyel_no),
                  degistiren_kullanici = ikisi,
                 degistirme_tarihi = SYSDATE,
                 aciklama = trim(aciklama)|| ' Sistem - Potansiyel no güncellendi.Eski P.No: '||trim(v_potansiyel_no)
               WHERE CURRENT OF mgm_cur;
             ELSE
             --potansiyel abone ile eslesiyor...
             --Mustafa 07.09.2004
               SELECT COUNT(*)
               INTO v_count
               FROM MGM_ABONE_BILGI
                WHERE TAVSIYE_EDILEN_TIPI IN (2,3)
               AND KAYIT_DURUMU = 2
               AND MGM_ACCOUNT_NUMBER = trim(v_uye_no);

               IF v_count = 0 THEN
                  BEGIN
                    SELECT install_date
                    INTO v_uye_aktif_tarihi
                    FROM wiz_customer_hp_life
                    WHERE account_number = trim(v_uye_no);

                  EXCEPTION WHEN OTHERS THEN
                      durum := 'Eslestirilmeye çalisilan abone bulunamadi.';
                      RETURN;
                  END;

                   IF mgm_rec.giris_tarihi <= v_uye_aktif_tarihi THEN
                     Mgm_Pack.mgm_abone_bilgi_finalize(trim(v_potansiyel_no),trim(v_uye_no),ioutlet_location,isebep_kodu,isozlesme_no,ikisi,durum); --Mustafa 07.09.2004
                  ELSE
                     Mgm_Pack.mgm_abone_bilgi_update(mgm_rec.id,
                                          3,
                                       mgm_rec.atanan_ts,
                                       mgm_rec.mgm_kayit_tipi,
                                       mgm_rec.mgm_account_number,
                                       mgm_rec.mgm_outlet_location,
                                       mgm_rec.kaynak,
                                       trim(mgm_rec.aciklama)|| ' Sistem - Üye MGM kaydindan önce sisteme girmis.',
                                       mgm_rec.mgm_kampanya_kodu,
                                       ikisi,
                                       durum,
                                       'M03'); -- 'MPI');
                   END IF;
               ELSE
                  Mgm_Pack.mgm_abone_bilgi_update(mgm_rec.id,
                                          3,
                                       mgm_rec.atanan_ts,
                                       mgm_rec.mgm_kayit_tipi,
                                       mgm_rec.mgm_account_number,
                                       mgm_rec.mgm_outlet_location,
                                       mgm_rec.kaynak,
                                       trim(mgm_rec.aciklama)|| ' Sistem - Üye, farkli potansiyel nolara sahip fakat ayni potansiyeli iki kere tavsiye etmis.',
                                       mgm_rec.mgm_kampanya_kodu,
                                       ikisi,
                                       durum,
                                       'M04');
               END IF;
            END IF;
            IF durum <> '0' THEN
                  RETURN;
             END IF;
          ELSE
             EXIT;
          END IF;
         END LOOP;
          CLOSE mgm_cur;
         */

      /*
      Tahsilat islemleri
      */
      IF itahsilat_id IS NOT NULL
      THEN
         DECLARE
            v_oraerrno    NUMBER (10);
            v_oraerrmsg   VARCHAR2 (300);
            v_usrerrno    NUMBER (10);
         BEGIN
            coll_dba.lig_2001_2002_pkg.match_prospect (iuye_no,
                                                       ioutlet_location,
                                                       v_operator_id,
                                                       itahsilat_id,
                                                       v_oraerrno,
                                                       v_oraerrmsg,
                                                       v_usrerrno);

            IF v_usrerrno = 0
            THEN
               durum := '0';
            ELSE
               durum := v_oraerrmsg;
               RETURN;
            END IF;
         END;
      END IF;

      OPEN wiz_mevcut_potansiyel_cur;

      FETCH wiz_mevcut_potansiyel_cur INTO wiz_mevcut_potansiyel_rec;

      IF wiz_mevcut_potansiyel_cur%NOTFOUND
      THEN
         durum :=
               'Mevcut potansiyel bulunamadi.'
            || ' - v_potansiyel_no:'
            || v_potansiyel_no
            || ' - iprospect_number:'
            || iprospect_number
            || ' eslesen:'
            || ieslestirme_tipi_abone;
         RETURN;
      END IF;

      INSERT INTO yk_dp_kontrat_potansiyel_log (id,
                                                yk_abone_potansiyel_id,
                                                prospect_number,
                                                ssn,
                                                first_name,
                                                middle_i,
                                                last_name,
                                                title,
                                                title_post,
                                                home_area_code,
                                                home_exchange,
                                                home_number,
                                                work_area_code,
                                                work_exchange,
                                                work_number,
                                                work_extension,
                                                mobile_number,
                                                mobile_area_code,
                                                mobile_exchange,
                                                service_address_id,
                                                street_number,
                                                street_fraction,
                                                street_name,
                                                street_descr,
                                                street_direction_pre,
                                                street_direction_post,
                                                suppl_addr_line,
                                                unit_number,
                                                entrance,
                                                FLOOR,
                                                city,
                                                state,
                                                zip,
                                                carrier_route,
                                                suppl_addr_line_1,
                                                suppl_addr_line_2,
                                                suppl_addr_line_3,
                                                suppl_addr_line_4,
                                                comments_62,
                                                comments_62_2,
                                                comments_62_3,
                                                date_created,
                                                date_updated,
                                                updating_user,
                                                home_country_tel_code,
                                                work_country_tel_code,
                                                mobile_country_tel_code,
                                                ulke,
                                                tckn,
                                                nufus_il,
                                                nufus_ilce,
                                                nufus_baba_adi,
                                                nufus_ana_adi,
                                                nufus_cilt_no,
                                                nufus_aile_sira,
                                                nufus_birey_sira,
                                                tc_kimlik_no_gecerli,
                                                nufus_dogum_tar,
                                                nufus_tabiyet)
           VALUES (yk_dp_potansiyel_log_id_seq.NEXTVAL,
                   oid,
                   wiz_mevcut_potansiyel_rec.prospect_number,
                   wiz_mevcut_potansiyel_rec.ssn,
                   wiz_mevcut_potansiyel_rec.first_name,
                   wiz_mevcut_potansiyel_rec.middle_i,
                   wiz_mevcut_potansiyel_rec.last_name,
                   wiz_mevcut_potansiyel_rec.title,
                   wiz_mevcut_potansiyel_rec.title_post,
                   TRIM (wiz_mevcut_potansiyel_rec.home_area_code),
                   TRIM (wiz_mevcut_potansiyel_rec.home_exchange),
                   TRIM (wiz_mevcut_potansiyel_rec.home_number),
                   TRIM (wiz_mevcut_potansiyel_rec.work_area_code),
                   TRIM (wiz_mevcut_potansiyel_rec.work_exchange),
                   TRIM (wiz_mevcut_potansiyel_rec.work_number),
                   TRIM (wiz_mevcut_potansiyel_rec.work_extension),
                   TRIM (wiz_mevcut_potansiyel_rec.mobile_number),
                   TRIM (wiz_mevcut_potansiyel_rec.mobile_area_code),
                   TRIM (wiz_mevcut_potansiyel_rec.mobile_exchange),
                   wiz_mevcut_potansiyel_rec.service_address_id,
                   wiz_mevcut_potansiyel_rec.street_number,
                   wiz_mevcut_potansiyel_rec.street_fraction,
                   wiz_mevcut_potansiyel_rec.street_name,
                   wiz_mevcut_potansiyel_rec.street_descr,
                   wiz_mevcut_potansiyel_rec.street_direction_pre,
                   wiz_mevcut_potansiyel_rec.street_direction_post,
                   wiz_mevcut_potansiyel_rec.suppl_addr_line,
                   wiz_mevcut_potansiyel_rec.unit_number,
                   wiz_mevcut_potansiyel_rec.entrance,
                   wiz_mevcut_potansiyel_rec.FLOOR,
                   wiz_mevcut_potansiyel_rec.city,
                   wiz_mevcut_potansiyel_rec.state,
                   wiz_mevcut_potansiyel_rec.zip,
                   wiz_mevcut_potansiyel_rec.carrier_route,
                   wiz_mevcut_potansiyel_rec.suppl_addr_line_1,
                   wiz_mevcut_potansiyel_rec.suppl_addr_line_2,
                   wiz_mevcut_potansiyel_rec.suppl_addr_line_3,
                   wiz_mevcut_potansiyel_rec.suppl_addr_line_4,
                   wiz_mevcut_potansiyel_rec.comments_62,
                   wiz_mevcut_potansiyel_rec.comments_62_2,
                   wiz_mevcut_potansiyel_rec.comments_62_3,
                   wiz_mevcut_potansiyel_rec.date_created,
                   wiz_mevcut_potansiyel_rec.date_updated,
                   wiz_mevcut_potansiyel_rec.updating_user,
                   TRIM (wiz_mevcut_potansiyel_rec.home_country_tel_code),
                   TRIM (wiz_mevcut_potansiyel_rec.work_country_tel_code),
                   TRIM (wiz_mevcut_potansiyel_rec.mobile_country_tel_code),
                   wiz_mevcut_potansiyel_rec.ulke,
                   wiz_mevcut_potansiyel_rec.tckn,
                   wiz_mevcut_potansiyel_rec.nufus_il,
                   wiz_mevcut_potansiyel_rec.nufus_ilce,
                   wiz_mevcut_potansiyel_rec.nufus_baba_adi,
                   wiz_mevcut_potansiyel_rec.nufus_ana_adi,
                   wiz_mevcut_potansiyel_rec.nufus_cilt_no,
                   wiz_mevcut_potansiyel_rec.nufus_aile_sira,
                   wiz_mevcut_potansiyel_rec.nufus_birey_sira,
                   wiz_mevcut_potansiyel_rec.tc_kimlik_no_gecerli,
                   wiz_mevcut_potansiyel_rec.nufus_dogum_tar,
                   wiz_mevcut_potansiyel_rec.nufus_tabiyet);

      IF TRIM (ieslestirme_tipi_abone) = 'E'
      THEN
         -- mevcut telefonlari sisteme aktar.
         --         abone_telefon_pack.abone_telefon_guncelle
         --                                        (v_uye_no,
         --                                         TRIM (wiz_mevcut_potansiyel_rec.home_country_tel_code),
         --                                         TRIM (wiz_mevcut_potansiyel_rec.home_area_code),
         --                                            TRIM (wiz_mevcut_potansiyel_rec.home_exchange)
         --                                         || TRIM (wiz_mevcut_potansiyel_rec.home_number),
         --                                         TRIM (wiz_mevcut_potansiyel_rec.mobile_country_tel_code),
         --                                         TRIM (wiz_mevcut_potansiyel_rec.mobile_area_code),
         --                                            TRIM (wiz_mevcut_potansiyel_rec.mobile_exchange)
         --                                         || TRIM (wiz_mevcut_potansiyel_rec.mobile_number),
         --                                         TRIM (wiz_mevcut_potansiyel_rec.work_country_tel_code),
         --                                         TRIM (wiz_mevcut_potansiyel_rec.work_area_code),
         --                                            TRIM (wiz_mevcut_potansiyel_rec.work_exchange)
         --                                         || TRIM (wiz_mevcut_potansiyel_rec.work_number),
         --                                         TRIM (wiz_mevcut_potansiyel_rec.work_extension),
         --                                         NULL,
         --                                         NULL,
         --                                         NULL,
         --                                         ikisi,
         --                                         durum
         --                                        );
         FOR ii IN 1 .. 3
         LOOP
            SAVEPOINT telefon_insert;
            abone_telefon_pack.mb_abone_telefon_insert (
               v_uye_no,
               CASE ii
                  WHEN 1                                                  --ev
                  THEN
                     TRIM (wiz_mevcut_potansiyel_rec.home_country_tel_code)
                  WHEN 2                                                  --is
                  THEN
                     TRIM (wiz_mevcut_potansiyel_rec.work_country_tel_code)
                  WHEN 3                                                 --cep
                  THEN
                     TRIM (wiz_mevcut_potansiyel_rec.mobile_country_tel_code)
               END,
               CASE ii
                  WHEN 1                                                  --ev
                  THEN
                     TRIM (wiz_mevcut_potansiyel_rec.home_area_code)
                  WHEN 2                                                  --is
                  THEN
                     TRIM (wiz_mevcut_potansiyel_rec.work_area_code)
                  WHEN 3                                                 --cep
                  THEN
                     TRIM (wiz_mevcut_potansiyel_rec.mobile_area_code)
               END,
               CASE ii
                  WHEN 1                                                  --ev
                  THEN
                        TRIM (wiz_mevcut_potansiyel_rec.home_exchange)
                     || TRIM (wiz_mevcut_potansiyel_rec.home_number)
                  WHEN 2                                                  --is
                  THEN
                        TRIM (wiz_mevcut_potansiyel_rec.work_exchange)
                     || TRIM (wiz_mevcut_potansiyel_rec.work_number)
                  WHEN 3                                                 --cep
                  THEN
                        TRIM (wiz_mevcut_potansiyel_rec.mobile_exchange)
                     || TRIM (wiz_mevcut_potansiyel_rec.mobile_number)
               END,
               CASE ii
                  WHEN 2 THEN TRIM (wiz_mevcut_potansiyel_rec.work_extension)
                  ELSE ''
               END,
               ii,                                                 --EV,is,cep
               1,                                         --durum default acik
               NULL,                                        --in_arama_zamani,
               NULL,                                --in_arama_saat_baslangic,
               NULL,                                    --in_arama_saat_bitis,
               NULL,                               --in_arama_tarih_baslangic,
               NULL,                                   --in_arama_tarih_bitis,
               NULL,                                      --in_oncelik_sirasi,
               NULL,                                  --in_son_kontrol_tarihi,
               NULL,                             --in_kontrol_yapan_kullanici,
               'Kontrat esnasinda potansiyelden otomatik aktarim',
               --in_aciklama,
               ikisi,
               out_id,
               durum,
               out_err_code,
               1);

            IF durum <> '0'
            THEN
               ROLLBACK TO telefon_insert;
               durum := '0';
            ELSE
               BEGIN
                  SELECT MIN (a.degistirme_tarihi)
                    INTO v_potansiyel_degistirme_tarihi
                    FROM dbs_dba.mb_abone_telefon a
                   WHERE     a.account_number = v_uye_no
                         AND a.telefon_tipi = ii
                         AND a.kisi_tipi = 1
                         AND a.durum = 1
                         AND a.id <> out_id;

                  -- kontrattan gelen telefon var 1 dakika daha önceki tarihe guncelle
                  IF v_potansiyel_degistirme_tarihi IS NOT NULL
                  THEN
                     UPDATE dbs_dba.mb_abone_telefon
                        SET degistirme_tarihi =
                               v_potansiyel_degistirme_tarihi - 1 / (24 * 60)
                      WHERE id = out_id;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     ROLLBACK TO telefon_insert;
                     durum := '0';
               END;
            END IF;
         END LOOP;

         SAVEPOINT mail_insert;

         IF wiz_mevcut_potansiyel_rec.title_post IS NOT NULL
         THEN
            iletisim_mail_pack.insert_mb_abone_email (
               v_uye_no,
               1,                                            --kisi tipi 1-nor
               1,                                       --mail tipi 1-nor 2-is
               TRIM (wiz_mevcut_potansiyel_rec.title_post),            --email
               1,                                            --1 acik, 3 iptal
               'Kontrat esnasinda potansiyelden otomatik aktarim',
               ikisi,
               out_id,
               durum,
               'H',                                           --ilk siradan mi
               'E',                                      --oncelik eklensin mi
               1);                                         --ent kodu calistir
         END IF;

         IF durum <> '0'
         THEN
            ROLLBACK TO mail_insert;
            durum := '0';
         END IF;

         durum := '0';
      ELSE
         durum := '0';

         OPEN wiz_potansiyel_cur;

         FETCH wiz_potansiyel_cur INTO wiz_potansiyel_rec;

         IF wiz_potansiyel_cur%FOUND
         THEN
            BEGIN
               enable_log := FALSE;

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_prospect_descrip
                WHERE     prospect_number = v_eslesen_potansiyel_no
                      AND (   TRIM (home_area_code) = ''
                           OR TRIM (home_area_code) IS NULL)
                      AND (   TRIM (home_exchange) = ''
                           OR TRIM (home_exchange) IS NULL)
                      AND (   TRIM (home_number) = ''
                           OR TRIM (home_number) IS NULL)
                      AND (   TRIM (home_country_tel_code) = ''
                           OR TRIM (home_country_tel_code) IS NULL);

               IF v_count = 1
               THEN
                  enable_log := TRUE;

                  UPDATE wiz_prospect_descrip
                     SET home_area_code =
                            TRIM (wiz_mevcut_potansiyel_rec.home_area_code),
                         home_exchange =
                            TRIM (wiz_mevcut_potansiyel_rec.home_exchange),
                         home_number =
                            TRIM (wiz_mevcut_potansiyel_rec.home_number),
                         home_country_tel_code =
                            TRIM (
                               wiz_mevcut_potansiyel_rec.home_country_tel_code)
                   WHERE CURRENT OF wiz_potansiyel_cur;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_prospect_descrip
                WHERE     prospect_number = v_eslesen_potansiyel_no
                      AND (   TRIM (work_area_code) = ''
                           OR TRIM (work_area_code) IS NULL)
                      AND (   TRIM (work_exchange) = ''
                           OR TRIM (work_exchange) IS NULL)
                      AND (   TRIM (work_number) = ''
                           OR TRIM (work_number) IS NULL)
                      AND (   TRIM (work_country_tel_code) = ''
                           OR TRIM (work_country_tel_code) IS NULL);

               IF v_count = 1
               THEN
                  enable_log := TRUE;

                  UPDATE wiz_prospect_descrip
                     SET work_area_code =
                            TRIM (wiz_mevcut_potansiyel_rec.work_area_code),
                         work_exchange =
                            TRIM (wiz_mevcut_potansiyel_rec.work_exchange),
                         work_number =
                            TRIM (wiz_mevcut_potansiyel_rec.work_number),
                         work_country_tel_code =
                            TRIM (
                               wiz_mevcut_potansiyel_rec.work_country_tel_code),
                         work_extension =
                            TRIM (wiz_mevcut_potansiyel_rec.work_extension)
                   WHERE CURRENT OF wiz_potansiyel_cur;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_prospect_descrip
                WHERE     prospect_number = v_eslesen_potansiyel_no
                      AND (   TRIM (mobile_area_code) = ''
                           OR TRIM (mobile_area_code) IS NULL)
                      AND (   TRIM (mobile_exchange) = ''
                           OR TRIM (mobile_exchange) IS NULL)
                      AND (   TRIM (mobile_number) = ''
                           OR TRIM (mobile_number) IS NULL)
                      AND (   TRIM (mobile_country_tel_code) = ''
                           OR TRIM (mobile_country_tel_code) IS NULL);

               IF v_count = 1
               THEN
                  enable_log := TRUE;

                  UPDATE wiz_prospect_descrip
                     SET mobile_area_code =
                            TRIM (wiz_mevcut_potansiyel_rec.mobile_area_code),
                         mobile_exchange =
                            TRIM (wiz_mevcut_potansiyel_rec.mobile_exchange),
                         mobile_number =
                            TRIM (wiz_mevcut_potansiyel_rec.mobile_number),
                         mobile_country_tel_code =
                            TRIM (
                               wiz_mevcut_potansiyel_rec.mobile_country_tel_code)
                   WHERE CURRENT OF wiz_potansiyel_cur;
               END IF;

               SELECT COUNT (1)
                 INTO v_count
                 FROM wiz_prospect_descrip
                WHERE     prospect_number = v_eslesen_potansiyel_no
                      AND TRIM (title_post) IS NULL; --(TRIM (title_post) = ' ' OR

               IF     v_count = 1
                  AND iletisim_mail_pack.is_valid_email (
                         wiz_mevcut_potansiyel_rec.title_post)
               THEN
                  enable_log := TRUE;

                  UPDATE wiz_prospect_descrip
                     SET title_post =
                            TRIM (wiz_mevcut_potansiyel_rec.title_post)
                   WHERE CURRENT OF wiz_potansiyel_cur;
               END IF;

               IF enable_log
               THEN
                  BEGIN
                     INSERT
                       INTO yk_dp_kontrat_potansiyel_log (
                               id,
                               yk_abone_potansiyel_id,
                               prospect_number,
                               ssn,
                               first_name,
                               middle_i,
                               last_name,
                               title,
                               title_post,
                               home_area_code,
                               home_exchange,
                               home_number,
                               work_area_code,
                               work_exchange,
                               work_number,
                               work_extension,
                               mobile_number,
                               mobile_area_code,
                               mobile_exchange,
                               service_address_id,
                               street_number,
                               street_fraction,
                               street_name,
                               street_descr,
                               street_direction_pre,
                               street_direction_post,
                               suppl_addr_line,
                               unit_number,
                               entrance,
                               FLOOR,
                               city,
                               state,
                               zip,
                               carrier_route,
                               suppl_addr_line_1,
                               suppl_addr_line_2,
                               suppl_addr_line_3,
                               suppl_addr_line_4,
                               comments_62,
                               comments_62_2,
                               comments_62_3,
                               date_created,
                               date_updated,
                               updating_user,
                               home_country_tel_code,
                               work_country_tel_code,
                               mobile_country_tel_code,
                               ulke,
                               tckn,
                               nufus_il,
                               nufus_ilce,
                               nufus_baba_adi,
                               nufus_ana_adi,
                               nufus_cilt_no,
                               nufus_aile_sira,
                               nufus_birey_sira,
                               tc_kimlik_no_gecerli,
                               nufus_dogum_tar,
                               nufus_tabiyet)
                        VALUES (
                                  yk_dp_potansiyel_log_id_seq.NEXTVAL,
                                  oid,
                                  wiz_potansiyel_rec.prospect_number,
                                  wiz_potansiyel_rec.ssn,
                                  wiz_potansiyel_rec.first_name,
                                  wiz_potansiyel_rec.middle_i,
                                  wiz_potansiyel_rec.last_name,
                                  wiz_potansiyel_rec.title,
                                  wiz_potansiyel_rec.title_post,
                                  TRIM (wiz_potansiyel_rec.home_area_code),
                                  TRIM (wiz_potansiyel_rec.home_exchange),
                                  TRIM (wiz_potansiyel_rec.home_number),
                                  TRIM (wiz_potansiyel_rec.work_area_code),
                                  TRIM (wiz_potansiyel_rec.work_exchange),
                                  TRIM (wiz_potansiyel_rec.work_number),
                                  TRIM (wiz_potansiyel_rec.work_extension),
                                  TRIM (wiz_potansiyel_rec.mobile_number),
                                  TRIM (wiz_potansiyel_rec.mobile_area_code),
                                  TRIM (wiz_potansiyel_rec.mobile_exchange),
                                  wiz_potansiyel_rec.service_address_id,
                                  wiz_potansiyel_rec.street_number,
                                  wiz_potansiyel_rec.street_fraction,
                                  wiz_potansiyel_rec.street_name,
                                  wiz_potansiyel_rec.street_descr,
                                  wiz_potansiyel_rec.street_direction_pre,
                                  wiz_potansiyel_rec.street_direction_post,
                                  wiz_potansiyel_rec.suppl_addr_line,
                                  wiz_potansiyel_rec.unit_number,
                                  wiz_potansiyel_rec.entrance,
                                  wiz_potansiyel_rec.FLOOR,
                                  wiz_potansiyel_rec.city,
                                  wiz_potansiyel_rec.state,
                                  wiz_potansiyel_rec.zip,
                                  wiz_potansiyel_rec.carrier_route,
                                  wiz_potansiyel_rec.suppl_addr_line_1,
                                  wiz_potansiyel_rec.suppl_addr_line_2,
                                  wiz_potansiyel_rec.suppl_addr_line_3,
                                  wiz_potansiyel_rec.suppl_addr_line_4,
                                  wiz_potansiyel_rec.comments_62,
                                  wiz_potansiyel_rec.comments_62_2,
                                  wiz_potansiyel_rec.comments_62_3,
                                  wiz_potansiyel_rec.date_created,
                                  wiz_potansiyel_rec.date_updated,
                                  wiz_potansiyel_rec.updating_user,
                                  TRIM (
                                     wiz_potansiyel_rec.home_country_tel_code),
                                  TRIM (
                                     wiz_potansiyel_rec.work_country_tel_code),
                                  TRIM (
                                     wiz_potansiyel_rec.mobile_country_tel_code),
                                  wiz_potansiyel_rec.ulke,
                                  wiz_mevcut_potansiyel_rec.tckn,
                                  wiz_mevcut_potansiyel_rec.nufus_il,
                                  wiz_mevcut_potansiyel_rec.nufus_ilce,
                                  wiz_mevcut_potansiyel_rec.nufus_baba_adi,
                                  wiz_mevcut_potansiyel_rec.nufus_ana_adi,
                                  wiz_mevcut_potansiyel_rec.nufus_cilt_no,
                                  wiz_mevcut_potansiyel_rec.nufus_aile_sira,
                                  wiz_mevcut_potansiyel_rec.nufus_birey_sira,
                                  wiz_mevcut_potansiyel_rec.tc_kimlik_no_gecerli,
                                  wiz_mevcut_potansiyel_rec.nufus_dogum_tar,
                                  wiz_mevcut_potansiyel_rec.nufus_tabiyet);
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  durum := '0';
            END;
         ELSE
            durum := 'Potansiyel bilgilerine ulasilamadi.';

            CLOSE wiz_potansiyel_cur;

            RETURN;
         END IF;

         CLOSE wiz_potansiyel_cur;
      END IF;

      DELETE FROM wiz_prospect_descrip
            WHERE prospect_number = v_potansiyel_no;

      CLOSE wiz_mevcut_potansiyel_cur;

      IF NVL (TRIM (v_potansiyel_no), 0) <> 0
      THEN
         FOR rec IN cur_bt
         LOOP
            bayi_arama_yonlendirme_pack.lg_bt_potansiyel_yts_insert (
               rec.id,
               'D',
               ikisi,
               rec.prospect_number,
               rec.sales_agent_code,
               rec.stb_tipi,
               rec.is_tipi,
               rec.islem_tablo_adi,
               rec.islem_tablo_id,
               rec.old_sales_agent_code,
               rec.yts_degisiklik_tarihi,
               rec.reason_code,
               rec.aciklama,
               rec.listeden_gizle,
               durum);

            IF durum = '0'
            THEN
               DELETE FROM bt_potansiyel_yts
                     WHERE id = rec.id;
            ELSE
               durum := 'POTANSIYELE AIT BAYI YONLENDIRMELERI loga atilamadi!';
               RETURN;
            END IF;
         END LOOP;
      END IF;

      FOR rec
         IN (SELECT *
               FROM sf_urun
              WHERE     reserved_prospect_number = v_potansiyel_no
                    AND durum IN ('R', 'V'))
      LOOP
         IF TRIM (v_uye_no) IS NOT NULL
         THEN
            UPDATE sf_urun
               SET reserved_account_number = v_uye_no,
                   reserved_prospect_number = NULL,
                   reserved_outlet_location = ioutlet_location,
                   degistirme_tarihi = SYSDATE,
                   degistiren_kullanici = igiren_kullanici
             WHERE seri_no = rec.seri_no;


            INSERT INTO lg_sf_urun (id,
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
                                    depodan,
                                    depoya,
                                    kaynak,
                                    aciklama,
                                    reserved_account_number,
                                    reserved_outlet_location,
                                    reserved_prospect_number,
                                    reserved_gizli_no)
                 VALUES (dbs_dba.lg_sf_urun_id_seq.NEXTVAL,
                         igiren_kullanici,
                         'U',
                         SYSDATE,
                         rec.seri_no,
                         rec.gizli_no,
                         rec.durum,
                         rec.detay_durum,
                         rec.effective_date,
                         rec.expire_date,
                         rec.urun_grup_kod,
                         rec.urun_tasarim_id,
                         rec.account_number,
                         rec.outlet_location,
                         rec.equip_location_code,
                         rec.equip_location_code,
                         rec.kaynak,
                         rec.aciklama,
                         v_uye_no,
                         ioutlet_location,
                         NULL,
                         rec.reserved_gizli_no);
         ELSE
            UPDATE sf_urun
               SET reserved_prospect_number = v_eslesen_potansiyel_no,
                   degistirme_tarihi = SYSDATE,
                   degistiren_kullanici = igiren_kullanici
             WHERE seri_no = rec.seri_no;


            INSERT INTO lg_sf_urun (id,
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
                                    depodan,
                                    depoya,
                                    kaynak,
                                    aciklama,
                                    reserved_account_number,
                                    reserved_outlet_location,
                                    reserved_prospect_number,
                                    reserved_gizli_no)
                 VALUES (dbs_dba.lg_sf_urun_id_seq.NEXTVAL,
                         igiren_kullanici,
                         'U',
                         SYSDATE,
                         rec.seri_no,
                         rec.gizli_no,
                         rec.durum,
                         rec.detay_durum,
                         rec.effective_date,
                         rec.expire_date,
                         rec.urun_grup_kod,
                         rec.urun_tasarim_id,
                         rec.account_number,
                         rec.outlet_location,
                         rec.equip_location_code,
                         rec.equip_location_code,
                         rec.kaynak,
                         rec.aciklama,
                         rec.reserved_account_number,
                         rec.reserved_outlet_location,
                         v_eslesen_potansiyel_no,
                         rec.reserved_gizli_no);
         END IF;
      END LOOP;

      IF TRIM (v_uye_no) IS NOT NULL
      THEN
         memo_pack.pot_abone_oldu_memo_update_et (TRIM (v_uye_no), durum);
      ELSE
         memo_pack.pot_pot_oldu_memo_update_et (
            TRIM (v_eslesen_potansiyel_no),
            durum);
      END IF;

      IF durum <> '0'
      THEN
         RETURN;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := 'YK_DP_ABONE_POTANSIYEL_INS: ' || SQLERRM;
   END;

   FUNCTION sozlesme_kisi_ara (
      in_sozlesme_no              IN     yk_dp_kontrat_kisi_bilgi.sozlesme_no%TYPE,
      in_adi                      IN     gl_kisi_bilgi.adi%TYPE,
      in_soyadi                   IN     gl_kisi_bilgi.soyadi%TYPE,
      in_babaadi                  IN     gl_kisi_bilgi.babaadi%TYPE,
      in_anaadi                   IN     gl_kisi_bilgi.anaadi%TYPE,
      in_dogumtarihi              IN     gl_kisi_bilgi.dogumtarihi%TYPE,
      in_cinsiyeti                IN     gl_kisi_bilgi.cinsiyeti%TYPE,
      in_il                       IN     gl_kisi_bilgi.il%TYPE,
      in_ilce                     IN     gl_kisi_bilgi.ilce%TYPE,
      in_tabiyeti                 IN     gl_kisi_bilgi.tabiyeti%TYPE,
      in_kisi_tipi                IN     gl_kisi_bilgi.kisi_tipi%TYPE,
      in_vatandaslikno            IN     gl_kisi_bilgi.n_tckimlikno%TYPE,
      out_kontrat_kisi_bilgi_id   IN OUT yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id%TYPE,
      durum                          OUT VARCHAR2,
      search_yourself             IN     VARCHAR DEFAULT 'H')
      RETURN NUMBER
   IS
      v_adi           gl_kisi_bilgi.adi%TYPE;
      v_soyadi        gl_kisi_bilgi.soyadi%TYPE;
      v_babaadi       gl_kisi_bilgi.babaadi%TYPE;
      v_anaadi        gl_kisi_bilgi.anaadi%TYPE;
      v_dogumtarihi   gl_kisi_bilgi.dogumtarihi%TYPE;
      v_cinsiyeti     gl_kisi_bilgi.cinsiyeti%TYPE;
      v_il            gl_kisi_bilgi.il%TYPE;
      v_ilce          gl_kisi_bilgi.ilce%TYPE;
      v_tabiyeti      gl_kisi_bilgi.tabiyeti%TYPE;
      v_sozlesme_no   yk_dp_kontrat_kisi_bilgi.sozlesme_no%TYPE;

      CURSOR kimlikno_cur
      IS
         SELECT kontrat_kisi_bilgi_id, sozlesme_no
           FROM (  SELECT kontrat_kisi_bilgi_id, sozlesme_no
                     FROM (                       -- search for cotrat kisi id
                           SELECT kontrat_kisi_bilgi_id,
                                  sozlesme_no,
                                  4 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     kontrat_kisi_bilgi_id =
                                         out_kontrat_kisi_bilgi_id
                                  AND out_kontrat_kisi_bilgi_id IS NOT NULL
                           UNION ALL
                           -- if not found search vat no
                           SELECT kontrat_kisi_bilgi_id,
                                  sozlesme_no,
                                  3 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NOT NULL
                                       AND n_tckimlikno = in_vatandaslikno)
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND sozlesme_no = v_sozlesme_no
                           UNION ALL
                           -- if not found search from other sozlesme
                           SELECT kontrat_kisi_bilgi_id,
                                  sozlesme_no,
                                  2 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NOT NULL
                                       AND n_tckimlikno = in_vatandaslikno)
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND sozlesme_no <> v_sozlesme_no
                                  AND search_yourself = 'H'
                           UNION ALL
                           -- if not found saerch with other data in sozlesme
                           SELECT kontrat_kisi_bilgi_id,
                                  sozlesme_no,
                                  3 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NULL
                                       AND adi = v_adi
                                       AND soyadi = v_soyadi
                                       AND (   (    (babaadi IS NULL)
                                                AND (v_babaadi IS NULL))
                                            OR (babaadi = v_babaadi))
                                       AND (   (    (anaadi IS NULL)
                                                AND (v_anaadi IS NULL))
                                            OR (anaadi = v_anaadi))
                                       AND (   (    (dogumtarihi IS NULL)
                                                AND (v_dogumtarihi IS NULL))
                                            OR (dogumtarihi = v_dogumtarihi))
                                       AND (   (    (cinsiyeti IS NULL)
                                                AND (v_cinsiyeti IS NULL))
                                            OR (cinsiyeti = v_cinsiyeti))
                                       AND (   (    (il IS NULL)
                                                AND (v_il IS NULL))
                                            OR (il = v_il))
                                       AND (   (    (ilce IS NULL)
                                                AND (v_ilce IS NULL))
                                            OR (ilce = v_ilce)))
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND sozlesme_no = v_sozlesme_no
                           UNION ALL
                           -- if not found searh with other data from other sozlesme
                           SELECT kontrat_kisi_bilgi_id,
                                  sozlesme_no,
                                  1 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NULL
                                       AND adi = v_adi
                                       AND soyadi = v_soyadi
                                       AND (   (    (babaadi IS NULL)
                                                AND (v_babaadi IS NULL))
                                            OR (babaadi = v_babaadi))
                                       AND (   (    (anaadi IS NULL)
                                                AND (v_anaadi IS NULL))
                                            OR (anaadi = v_anaadi))
                                       AND (   (    (dogumtarihi IS NULL)
                                                AND (v_dogumtarihi IS NULL))
                                            OR (dogumtarihi = v_dogumtarihi))
                                       AND (   (    (cinsiyeti IS NULL)
                                                AND (v_cinsiyeti IS NULL))
                                            OR (cinsiyeti = v_cinsiyeti))
                                       AND (   (    (il IS NULL)
                                                AND (v_il IS NULL))
                                            OR (il = v_il))
                                       AND (   (    (ilce IS NULL)
                                                AND (v_ilce IS NULL))
                                            OR (ilce = v_ilce)))
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND sozlesme_no <> v_sozlesme_no
                                  AND search_yourself = 'H')
                    WHERE kontrat_kisi_bilgi_id IS NOT NULL
                 ORDER BY sort_order DESC)
          WHERE ROWNUM = 1;

      kimlik_rec      kimlikno_cur%ROWTYPE;
   BEGIN
      v_adi := in_adi;
      v_soyadi := in_soyadi;
      v_babaadi := in_babaadi;
      v_anaadi := in_anaadi;
      v_dogumtarihi := in_dogumtarihi;
      v_cinsiyeti := in_cinsiyeti;
      v_il := in_il;
      v_ilce := in_ilce;
      v_tabiyeti := in_tabiyeti;
      v_sozlesme_no := in_sozlesme_no;

      OPEN kimlikno_cur;

      FETCH kimlikno_cur INTO kimlik_rec;

      IF kimlikno_cur%NOTFOUND
      THEN
         kimlik_rec := NULL;
      END IF;

      CLOSE kimlikno_cur;

      IF kimlik_rec.kontrat_kisi_bilgi_id IS NULL
      THEN
         RETURN 0;
      ELSE
         out_kontrat_kisi_bilgi_id := kimlik_rec.kontrat_kisi_bilgi_id;

         IF v_sozlesme_no <> kimlik_rec.sozlesme_no
         THEN
            RETURN 1;
         ELSE
            RETURN 2;
         END IF;
      END IF;

      RETURN -1;
   END;

   FUNCTION tetik_kisi_ara (
      in_ie_potansiyel_is_emri_id   IN     yk_dp_kontrat_kisi_bilgi.ie_potansiyel_is_emri_id%TYPE,
      in_adi                        IN     gl_kisi_bilgi.adi%TYPE,
      in_soyadi                     IN     gl_kisi_bilgi.soyadi%TYPE,
      in_babaadi                    IN     gl_kisi_bilgi.babaadi%TYPE,
      in_anaadi                     IN     gl_kisi_bilgi.anaadi%TYPE,
      in_dogumtarihi                IN     gl_kisi_bilgi.dogumtarihi%TYPE,
      in_cinsiyeti                  IN     gl_kisi_bilgi.cinsiyeti%TYPE,
      in_il                         IN     gl_kisi_bilgi.il%TYPE,
      in_ilce                       IN     gl_kisi_bilgi.ilce%TYPE,
      in_tabiyeti                   IN     gl_kisi_bilgi.tabiyeti%TYPE,
      in_kisi_tipi                  IN     gl_kisi_bilgi.kisi_tipi%TYPE,
      in_vatandaslikno              IN     gl_kisi_bilgi.n_tckimlikno%TYPE,
      out_kontrat_kisi_bilgi_id     IN OUT yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id%TYPE,
      durum                            OUT VARCHAR2,
      search_yourself               IN     VARCHAR DEFAULT 'H')
      RETURN NUMBER
   IS
      v_adi                        gl_kisi_bilgi.adi%TYPE;
      v_soyadi                     gl_kisi_bilgi.soyadi%TYPE;
      v_babaadi                    gl_kisi_bilgi.babaadi%TYPE;
      v_anaadi                     gl_kisi_bilgi.anaadi%TYPE;
      v_dogumtarihi                gl_kisi_bilgi.dogumtarihi%TYPE;
      v_cinsiyeti                  gl_kisi_bilgi.cinsiyeti%TYPE;
      v_il                         gl_kisi_bilgi.il%TYPE;
      v_ilce                       gl_kisi_bilgi.ilce%TYPE;
      v_tabiyeti                   gl_kisi_bilgi.tabiyeti%TYPE;
      v_sozlesme_no                yk_dp_kontrat_kisi_bilgi.sozlesme_no%TYPE;
      v_ie_potansiyel_is_emri_id   yk_dp_kontrat_kisi_bilgi.ie_potansiyel_is_emri_id%TYPE;

      CURSOR kimlikno_cur
      IS
         SELECT kontrat_kisi_bilgi_id, ie_potansiyel_is_emri_id
           FROM (  SELECT kontrat_kisi_bilgi_id, ie_potansiyel_is_emri_id
                     FROM (                       -- search for cotrat kisi id
                           SELECT kontrat_kisi_bilgi_id,
                                  ie_potansiyel_is_emri_id,
                                  4 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     kontrat_kisi_bilgi_id =
                                         out_kontrat_kisi_bilgi_id
                                  AND out_kontrat_kisi_bilgi_id IS NOT NULL
                           UNION ALL
                           -- if not found search vat no
                           SELECT kontrat_kisi_bilgi_id,
                                  ie_potansiyel_is_emri_id,
                                  3 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NOT NULL
                                       AND n_tckimlikno = in_vatandaslikno)
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND ie_potansiyel_is_emri_id =
                                         v_ie_potansiyel_is_emri_id
                           UNION ALL
                           -- if not found search from other sozlesme
                           SELECT kontrat_kisi_bilgi_id,
                                  ie_potansiyel_is_emri_id,
                                  2 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NOT NULL
                                       AND n_tckimlikno = in_vatandaslikno)
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND ie_potansiyel_is_emri_id <>
                                         v_ie_potansiyel_is_emri_id
                                  AND search_yourself = 'H'
                           UNION ALL
                           -- if not found saerch with other data in sozlesme
                           SELECT kontrat_kisi_bilgi_id,
                                  ie_potansiyel_is_emri_id,
                                  3 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NULL
                                       AND adi = v_adi
                                       AND soyadi = v_soyadi
                                       AND (   (    (babaadi IS NULL)
                                                AND (v_babaadi IS NULL))
                                            OR (babaadi = v_babaadi))
                                       AND (   (    (anaadi IS NULL)
                                                AND (v_anaadi IS NULL))
                                            OR (anaadi = v_anaadi))
                                       AND (   (    (dogumtarihi IS NULL)
                                                AND (v_dogumtarihi IS NULL))
                                            OR (dogumtarihi = v_dogumtarihi))
                                       AND (   (    (cinsiyeti IS NULL)
                                                AND (v_cinsiyeti IS NULL))
                                            OR (cinsiyeti = v_cinsiyeti))
                                       AND (   (    (il IS NULL)
                                                AND (v_il IS NULL))
                                            OR (il = v_il))
                                       AND (   (    (ilce IS NULL)
                                                AND (v_ilce IS NULL))
                                            OR (ilce = v_ilce)))
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND ie_potansiyel_is_emri_id =
                                         v_ie_potansiyel_is_emri_id
                           UNION ALL
                           -- if not found searh with other data from other sozlesme
                           SELECT kontrat_kisi_bilgi_id,
                                  ie_potansiyel_is_emri_id,
                                  1 sort_order
                             FROM yk_dp_kontrat_kisi_bilgi
                            WHERE     (    n_tckimlikno IS NULL
                                       AND adi = v_adi
                                       AND soyadi = v_soyadi
                                       AND (   (    (babaadi IS NULL)
                                                AND (v_babaadi IS NULL))
                                            OR (babaadi = v_babaadi))
                                       AND (   (    (anaadi IS NULL)
                                                AND (v_anaadi IS NULL))
                                            OR (anaadi = v_anaadi))
                                       AND (   (    (dogumtarihi IS NULL)
                                                AND (v_dogumtarihi IS NULL))
                                            OR (dogumtarihi = v_dogumtarihi))
                                       AND (   (    (cinsiyeti IS NULL)
                                                AND (v_cinsiyeti IS NULL))
                                            OR (cinsiyeti = v_cinsiyeti))
                                       AND (   (    (il IS NULL)
                                                AND (v_il IS NULL))
                                            OR (il = v_il))
                                       AND (   (    (ilce IS NULL)
                                                AND (v_ilce IS NULL))
                                            OR (ilce = v_ilce)))
                                  AND out_kontrat_kisi_bilgi_id IS NULL
                                  AND ie_potansiyel_is_emri_id <>
                                         v_ie_potansiyel_is_emri_id
                                  AND search_yourself = 'H')
                    WHERE kontrat_kisi_bilgi_id IS NOT NULL
                 ORDER BY sort_order DESC)
          WHERE ROWNUM = 1;

      kimlik_rec                   kimlikno_cur%ROWTYPE;
   BEGIN
      v_adi := in_adi;
      v_soyadi := in_soyadi;
      v_babaadi := in_babaadi;
      v_anaadi := in_anaadi;
      v_dogumtarihi := in_dogumtarihi;
      v_cinsiyeti := in_cinsiyeti;
      v_il := in_il;
      v_ilce := in_ilce;
      v_tabiyeti := in_tabiyeti;
      v_ie_potansiyel_is_emri_id := in_ie_potansiyel_is_emri_id;

      OPEN kimlikno_cur;

      FETCH kimlikno_cur INTO kimlik_rec;

      IF kimlikno_cur%NOTFOUND
      THEN
         kimlik_rec := NULL;
      END IF;

      CLOSE kimlikno_cur;

      IF kimlik_rec.kontrat_kisi_bilgi_id IS NULL
      THEN
         RETURN 0;
      ELSE
         out_kontrat_kisi_bilgi_id := kimlik_rec.kontrat_kisi_bilgi_id;

         IF v_ie_potansiyel_is_emri_id <> kimlik_rec.ie_potansiyel_is_emri_id
         THEN
            RETURN 1;
         ELSE
            RETURN 2;
         END IF;
      END IF;

      RETURN -1;
   END;

   -- kisi bigileri geçici olarak buraya kaydediliyor...

   PROCEDURE kontrat_kisi_bilgi_save (
      in_kisi_tipi                  IN     gl_kisi_bilgi.kisi_tipi%TYPE,
      in_unvani                     IN     gl_kisi_bilgi.unvani%TYPE,
      in_adi                        IN     gl_kisi_bilgi.adi%TYPE,
      in_soyadi                     IN     gl_kisi_bilgi.soyadi%TYPE,
      in_babaadi                    IN     gl_kisi_bilgi.babaadi%TYPE,
      in_anaadi                     IN     gl_kisi_bilgi.anaadi%TYPE,
      in_dogumyeri                  IN     gl_kisi_bilgi.dogumyeri%TYPE,
      in_dogumtarihi                IN     gl_kisi_bilgi.dogumtarihi%TYPE,
      in_cinsiyeti                  IN     gl_kisi_bilgi.cinsiyeti%TYPE,
      in_il                         IN     gl_kisi_bilgi.il%TYPE,
      in_ilce                       IN     gl_kisi_bilgi.ilce%TYPE,
      in_mahallekoy                 IN     gl_kisi_bilgi.mahallekoy%TYPE,
      in_ciltno                     IN     gl_kisi_bilgi.ciltno%TYPE,
      in_ailesirano                 IN     gl_kisi_bilgi.ailesirano%TYPE,
      in_sirano                     IN     gl_kisi_bilgi.sirano%TYPE,
      in_kangrubu                   IN     gl_kisi_bilgi.kangrubu%TYPE,
      in_n_seri                     IN     gl_kisi_bilgi.n_seri%TYPE,
      in_n_no                       IN     gl_kisi_bilgi.n_no%TYPE,
      in_n_medenihali               IN     gl_kisi_bilgi.n_medenihali%TYPE,
      in_n_dini                     IN     gl_kisi_bilgi.n_dini%TYPE,
      in_n_verildigiyer             IN     gl_kisi_bilgi.n_verildigiyer%TYPE,
      in_n_verilisnedeni            IN     gl_kisi_bilgi.n_verilisnedeni%TYPE,
      in_n_kayitno                  IN     gl_kisi_bilgi.n_kayitno%TYPE,
      in_n_verilistarihi            IN     gl_kisi_bilgi.e_verilistarihi%TYPE,
      in_n_oncekisoyadi             IN     gl_kisi_bilgi.n_oncekisoyadi%TYPE,
      in_e_verildigiyer             IN     gl_kisi_bilgi.e_verildigiyer%TYPE,
      in_e_belgeno                  IN     gl_kisi_bilgi.e_belgeno%TYPE,
      in_e_verilistarihi            IN     gl_kisi_bilgi.e_verilistarihi%TYPE,
      in_e_sinifi                   IN     gl_kisi_bilgi.e_sinifi%TYPE,
      in_e_kullancihaz              IN     gl_kisi_bilgi.e_kullancihaz%TYPE,
      in_tabiyeti                   IN     gl_kisi_bilgi.tabiyeti%TYPE,
      in_user                       IN     gl_kisi_bilgi.giren_kullanici%TYPE,
      in_sozlesme_no                IN     yk_dp_kontrat.sozlesme_no%TYPE,
      in_ie_potansiyel_is_emri_id   IN     yk_dp_kontrat_kisi_bilgi.ie_potansiyel_is_emri_id%TYPE,
      in_eslestirme_tipi            IN     yk_dp_kontrat_kisi_bilgi.eslestirme_tipi%TYPE,
      out_tc_kimlik_no              IN OUT gl_kisi_bilgi.n_tckimlikno%TYPE,
      out_kisi_bilgi_id             IN OUT gl_kisi_bilgi.kisi_bilgi_id%TYPE,
      out_kontrat_kisi_bilgi_id     IN OUT yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id%TYPE,
      out_durum                        OUT VARCHAR2)
   IS
      v_kisi_bilgi_id       gl_kisi_bilgi.kisi_bilgi_id%TYPE;
      v_user                gl_kisi_bilgi.giren_kullanici%TYPE;
      v_status              NUMBER (1);
      v_tmp                 yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id%TYPE;
      v_durum               VARCHAR2 (100);
      v_il                  VARCHAR (100);
      v_ilce                VARCHAR (100);
      v_tc_kimlik_gecerli   gl_kisi_bilgi.tc_kimlik_no_gecerli%TYPE;
      v_tmp_vatandaslikno   gl_kisi_bilgi.n_tckimlikno%TYPE;
      v_tmp_durum           VARCHAR2 (100);
      v_dummy_kisi_durum    VARCHAR2 (10);

      -- bu kisi daha önce eklenmismi
      CURSOR yk_dp_kontrat_kisi_bilgi_cur
      IS
         SELECT yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id
           FROM yk_dp_kontrat_kisi_bilgi
          WHERE     kontrat_kisi_bilgi_id = out_kontrat_kisi_bilgi_id
                AND sozlesme_no = in_sozlesme_no;

      v_kontrat             yk_dp_kontrat_kisi_bilgi_cur%ROWTYPE;
      is_sozlesme           BOOLEAN;
      v_count               NUMBER (3);
   BEGIN
      out_durum := '0';

      IF    (    in_ie_potansiyel_is_emri_id IS NULL
             AND in_sozlesme_no IS NOT NULL)
         OR (    in_ie_potansiyel_is_emri_id IS NOT NULL
             AND in_sozlesme_no IS NULL)
      THEN
         IF in_sozlesme_no IS NOT NULL
         THEN
            is_sozlesme := TRUE;
         ELSE
            is_sozlesme := FALSE;
         END IF;
      ELSE
         out_durum := 'Kisi sözlesme yada tetik için tanimlanmalidir.';
         RETURN;
      END IF;

      IF NVL (LTRIM (in_kisi_tipi), '') = ''
      THEN
         out_durum := '1';
      END IF;

      IF NVL (LTRIM (in_sozlesme_no), '') = ''
      THEN
         out_durum := '2';
      END IF;

      IF in_user IS NULL
      THEN
         out_durum := '3';
      END IF;

      v_user := in_user;

      IF out_durum = '0'
      THEN
         v_tc_kimlik_gecerli := NULL;

         IF in_kisi_tipi = 1 AND (in_tabiyeti = '001' OR in_tabiyeti IS NULL)
         THEN
            IF out_kisi_bilgi_id IS NOT NULL
            THEN
               SELECT tc_kimlik_no_gecerli
                 INTO v_tc_kimlik_gecerli
                 FROM yk_dp_kontrat_kisi_bilgi
                WHERE kisi_bilgi_id = out_kisi_bilgi_id;

               SELECT COUNT (*)
                 INTO v_count
                 FROM yk_dp_kontrat_kisi_bilgi
                WHERE     kisi_bilgi_id = out_kisi_bilgi_id
                      AND (   n_tckimlikno IS NULL
                           OR n_tckimlikno <> out_tc_kimlik_no
                           OR adi <> in_adi
                           OR soyadi <> in_soyadi
                           OR TO_CHAR (dogumtarihi, 'YYYY') <>
                                 TO_CHAR (in_dogumtarihi, 'YYYY')
                           OR anaadi <> in_anaadi
                           OR babaadi <> in_babaadi
                           OR cinsiyeti <> in_cinsiyeti
                           OR il <> in_il
                           OR ilce <> in_ilce
                           OR ciltno <> in_ciltno
                           OR ailesirano <> in_ailesirano
                           OR sirano <> in_sirano);
            ELSE
               v_count := 1;
            END IF;

            IF v_count > 0
            THEN
               v_tmp_vatandaslikno := out_tc_kimlik_no;
               v_tc_kimlik_gecerli := 'F';

               IF    out_tc_kimlik_no IS NULL
                  OR (NOT webrequest_pack.check_vatandaslikno (
                             in_adi,
                             in_soyadi,
                             TO_CHAR (in_dogumtarihi, 'YYYY'),
                             out_tc_kimlik_no,
                             v_tmp_durum,
                             v_dummy_kisi_durum))
               THEN
                  webrequest_pack.get_vatandaslikno1 (in_adi,
                                                      in_soyadi,
                                                      in_anaadi,
                                                      in_babaadi,
                                                      in_dogumtarihi,
                                                      in_cinsiyeti,
                                                      --in_il,
                                                      --in_ilce,
                                                      v_user,
                                                      out_tc_kimlik_no,
                                                      out_durum,
                                                      'H',
                                                      'U',
                                                      v_dummy_kisi_durum);
               --                  IF out_tc_kimlik_no IS NULL
               --                  THEN
               --                     v_durum := '0';
               --                     webrequest_pack.get_vatandaslikno2 (in_adi,
               --                                                         in_soyadi,
               --                                                         in_ciltno,
               --                                                         in_ailesirano,
               --                                                         in_sirano,
               --                                                         in_il,
               --                                                         in_ilce,
               --                                                         in_user,
               --                                                         out_tc_kimlik_no,
               --                                                         v_durum,
               --                                                         'H',
               --                                                         'U'
               --                                                        );
               --
               --                     IF v_durum = '0'
               --                     THEN
               --                        out_durum := '0';
               --                     END IF;
               --                  END IF;
               END IF;

               IF     out_tc_kimlik_no IS NULL
                  AND v_tmp_vatandaslikno IS NOT NULL
               THEN
                  IF LENGTH (v_tmp_durum) > 4
                  THEN
                     out_durum :=
                           'Vatandaslik No bilgisi dogrulanamadi. Lütfen Ad, Soyad, Dogum Tarihi ve Vatandaslik No bilgilerini kontrol ediniz.'
                        || CHR (13)
                        || CHR (10)
                        || 'Önerilen Kimlik bilgileri asagidaki gibidir.'
                        || CHR (13)
                        || CHR (10)
                        || 'Adi Soyadi: '
                        || SUBSTR (TRIM (v_tmp_durum),
                                   1,
                                   LENGTH (TRIM (v_tmp_durum)) - 4)
                        || ' Dogum Yili:'
                        || SUBSTR (TRIM (v_tmp_durum),
                                   LENGTH (TRIM (v_tmp_durum)) - 4,
                                   LENGTH (TRIM (v_tmp_durum)));
                  ELSE
                     out_durum :=
                        'Vatandaslik No bilgisi dogrulanamadi. Lütfen Vatandaslik No bilgisini kontrol ediniz.';
                  END IF;
               ELSIF out_tc_kimlik_no <> v_tmp_vatandaslikno
               THEN
                  out_durum :=
                        'Vatandaslik No bilgisi dogrulanamadi. Önerilen Vatandaslik No: '
                     || out_tc_kimlik_no;
               END IF;

               IF out_durum <> '0'
               THEN
                  RETURN;
               END IF;

               IF dbs_sabit ('TC_KIMLIK_NO_KONTROL_ET') <> 'E'
               THEN
                  --IF out_tc_kimlik_no IS NOT NULL
                  --THEN
                  v_tc_kimlik_gecerli := 'E';
               --END IF;
               ELSE
                  IF out_tc_kimlik_no IS NOT NULL
                  THEN
                     v_tc_kimlik_gecerli := 'V';
                  END IF;
               END IF;
            END IF;
         END IF;

         IF is_sozlesme
         THEN
            -- sözlesmeden ara
            v_status :=
               sozlesme_kisi_ara (in_sozlesme_no,
                                  in_adi,
                                  in_soyadi,
                                  in_babaadi,
                                  in_anaadi,
                                  in_dogumtarihi,
                                  in_cinsiyeti,
                                  in_il,
                                  in_ilce,
                                  in_tabiyeti,
                                  in_kisi_tipi,
                                  out_tc_kimlik_no,
                                  out_kontrat_kisi_bilgi_id,
                                  out_durum);
         ELSE
            -- tetikten ara
            v_status :=
               tetik_kisi_ara (in_ie_potansiyel_is_emri_id,
                               in_adi,
                               in_soyadi,
                               in_babaadi,
                               in_anaadi,
                               in_dogumtarihi,
                               in_cinsiyeti,
                               in_il,
                               in_ilce,
                               in_tabiyeti,
                               in_kisi_tipi,
                               out_tc_kimlik_no,
                               out_kontrat_kisi_bilgi_id,
                               out_durum);
         END IF;

         IF v_status = 0
         THEN
            IF out_durum <> '0'
            THEN
               RETURN;
            END IF;

            SELECT yk_dp_kontrat_kisi_bilgi_seq.NEXTVAL
              INTO out_kontrat_kisi_bilgi_id
              FROM DUAL;

            -- eger kayit bulunamaissa yeni bir kayit olustur
            INSERT INTO yk_dp_kontrat_kisi_bilgi (kontrat_kisi_bilgi_id,
                                                  sozlesme_no,
                                                  kisi_tipi,
                                                  unvani,
                                                  adi,
                                                  soyadi,
                                                  babaadi,
                                                  anaadi,
                                                  dogumyeri,
                                                  dogumtarihi,
                                                  cinsiyeti,
                                                  il,
                                                  ilce,
                                                  mahallekoy,
                                                  ciltno,
                                                  ailesirano,
                                                  sirano,
                                                  kangrubu,
                                                  n_seri,
                                                  n_no,
                                                  n_tckimlikno,
                                                  n_medenihali,
                                                  n_dini,
                                                  n_verildigiyer,
                                                  n_verilisnedeni,
                                                  n_kayitno,
                                                  n_verilistarihi,
                                                  n_oncekisoyadi,
                                                  e_verildigiyer,
                                                  e_belgeno,
                                                  e_verilistarihi,
                                                  e_sinifi,
                                                  e_kullancihaz,
                                                  giren_kullanici,
                                                  giris_tarihi,
                                                  tabiyeti,
                                                  eslestirme_tipi,
                                                  kisi_bilgi_id,
                                                  degistiren_kullanici,
                                                  degistirme_tarihi,
                                                  tc_kimlik_no_gecerli,
                                                  ie_potansiyel_is_emri_id)
                 VALUES (out_kontrat_kisi_bilgi_id,
                         in_sozlesme_no,
                         in_kisi_tipi,
                         in_unvani,
                         in_adi,
                         in_soyadi,
                         in_babaadi,
                         in_anaadi,
                         in_dogumyeri,
                         in_dogumtarihi,
                         in_cinsiyeti,
                         in_il,
                         in_ilce,
                         in_mahallekoy,
                         in_ciltno,
                         in_ailesirano,
                         in_sirano,
                         in_kangrubu,
                         in_n_seri,
                         in_n_no,
                         out_tc_kimlik_no,
                         in_n_medenihali,
                         in_n_dini,
                         in_n_verildigiyer,
                         in_n_verilisnedeni,
                         in_n_kayitno,
                         in_n_verilistarihi,
                         in_n_oncekisoyadi,
                         in_e_verildigiyer,
                         in_e_belgeno,
                         in_e_verilistarihi,
                         in_e_sinifi,
                         in_e_kullancihaz,
                         v_user,
                         SYSDATE,
                         in_tabiyeti,
                         in_eslestirme_tipi,
                         v_kisi_bilgi_id,
                         v_user,
                         SYSDATE,
                         v_tc_kimlik_gecerli,
                         in_ie_potansiyel_is_emri_id);
         END IF;

         IF v_status = 1
         THEN
            -- eger kayit farkli sözlesme de varsa eksik bilgilerini ordan getir
            v_tmp := out_kontrat_kisi_bilgi_id;

            SELECT yk_dp_kontrat_kisi_bilgi_seq.NEXTVAL
              INTO out_kontrat_kisi_bilgi_id
              FROM DUAL;

            INSERT INTO yk_dp_kontrat_kisi_bilgi (kontrat_kisi_bilgi_id,
                                                  sozlesme_no,
                                                  kisi_tipi,
                                                  unvani,
                                                  adi,
                                                  soyadi,
                                                  babaadi,
                                                  anaadi,
                                                  dogumyeri,
                                                  dogumtarihi,
                                                  cinsiyeti,
                                                  il,
                                                  ilce,
                                                  mahallekoy,
                                                  ciltno,
                                                  ailesirano,
                                                  sirano,
                                                  kangrubu,
                                                  n_seri,
                                                  n_no,
                                                  n_tckimlikno,
                                                  n_medenihali,
                                                  n_dini,
                                                  n_verildigiyer,
                                                  n_verilisnedeni,
                                                  n_kayitno,
                                                  n_verilistarihi,
                                                  n_oncekisoyadi,
                                                  e_verildigiyer,
                                                  e_belgeno,
                                                  e_verilistarihi,
                                                  e_sinifi,
                                                  e_kullancihaz,
                                                  giren_kullanici,
                                                  giris_tarihi,
                                                  tabiyeti,
                                                  eslestirme_tipi,
                                                  kisi_bilgi_id,
                                                  degistiren_kullanici,
                                                  degistirme_tarihi,
                                                  tc_kimlik_no_gecerli,
                                                  ie_potansiyel_is_emri_id)
               SELECT out_kontrat_kisi_bilgi_id,
                      in_sozlesme_no,
                      in_kisi_tipi,
                      NVL (in_unvani, unvani),
                      in_adi,
                      in_soyadi,
                      in_babaadi,
                      in_anaadi,
                      NVL (in_dogumyeri, dogumyeri),
                      in_dogumtarihi,
                      in_cinsiyeti,
                      NVL (in_il, il),
                      NVL (in_ilce, ilce),
                      NVL (in_mahallekoy, mahallekoy),
                      NVL (in_ciltno, ciltno),
                      NVL (in_ailesirano, ailesirano),
                      NVL (in_sirano, sirano),
                      NVL (in_kangrubu, kangrubu),
                      NVL (in_n_seri, n_seri),
                      NVL (in_n_no, n_no),
                      out_tc_kimlik_no,
                      NVL (in_n_medenihali, n_medenihali),
                      NVL (in_n_dini, n_dini),
                      NVL (in_n_verildigiyer, n_verildigiyer),
                      NVL (in_n_verilisnedeni, n_verilisnedeni),
                      NVL (in_n_kayitno, n_kayitno),
                      NVL (in_n_verilistarihi, n_verilistarihi),
                      NVL (in_n_oncekisoyadi, n_oncekisoyadi),
                      NVL (in_e_verildigiyer, e_verildigiyer),
                      NVL (in_e_belgeno, e_belgeno),
                      NVL (in_e_verilistarihi, e_verilistarihi),
                      NVL (in_e_sinifi, e_sinifi),
                      NVL (in_e_kullancihaz, e_kullancihaz),
                      v_user,
                      SYSDATE,
                      NVL (in_tabiyeti, tabiyeti),
                      in_eslestirme_tipi,
                      v_kisi_bilgi_id,
                      v_user,
                      SYSDATE,
                      v_tc_kimlik_gecerli,
                      in_ie_potansiyel_is_emri_id
                 FROM yk_dp_kontrat_kisi_bilgi
                WHERE kontrat_kisi_bilgi_id = v_tmp;
         END IF;

         IF v_status = 2
         THEN
            IF out_durum <> '0'
            THEN
               RETURN;
            END IF;

            -- kayit bulunmussa güncelle
            UPDATE yk_dp_kontrat_kisi_bilgi
               SET kisi_tipi = NVL (in_kisi_tipi, kisi_tipi),
                   unvani = NVL (in_unvani, unvani),
                   adi = NVL (in_adi, adi),
                   soyadi = NVL (in_soyadi, soyadi),
                   babaadi = NVL (in_babaadi, babaadi),
                   anaadi = NVL (in_anaadi, anaadi),
                   dogumyeri = NVL (in_dogumyeri, dogumyeri),
                   dogumtarihi = NVL (in_dogumtarihi, dogumtarihi),
                   cinsiyeti = NVL (in_cinsiyeti, cinsiyeti),
                   il = NVL (in_il, il),
                   ilce = NVL (in_ilce, ilce),
                   mahallekoy = NVL (in_mahallekoy, mahallekoy),
                   ciltno = NVL (in_ciltno, ciltno),
                   ailesirano = NVL (in_ailesirano, ailesirano),
                   sirano = NVL (in_sirano, sirano),
                   kangrubu = NVL (in_kangrubu, kangrubu),
                   n_seri = NVL (in_n_seri, n_seri),
                   n_no = NVL (in_n_no, n_no),
                   n_tckimlikno = out_tc_kimlik_no,
                   n_medenihali = NVL (in_n_medenihali, n_medenihali),
                   n_dini = NVL (in_n_dini, n_dini),
                   n_verildigiyer = NVL (in_n_verildigiyer, n_verildigiyer),
                   n_verilisnedeni = NVL (in_n_verilisnedeni, n_verilisnedeni),
                   n_kayitno = NVL (in_n_kayitno, n_kayitno),
                   n_verilistarihi = NVL (in_n_verilistarihi, n_verilistarihi),
                   n_oncekisoyadi = NVL (in_n_oncekisoyadi, n_oncekisoyadi),
                   e_verildigiyer = NVL (in_e_verildigiyer, e_verildigiyer),
                   e_belgeno = NVL (in_e_belgeno, e_belgeno),
                   e_verilistarihi = NVL (in_e_verilistarihi, e_verilistarihi),
                   e_sinifi = NVL (in_e_sinifi, e_sinifi),
                   e_kullancihaz = NVL (in_e_kullancihaz, e_kullancihaz),
                   degistiren_kullanici = v_user,
                   degistirme_tarihi = SYSDATE,
                   tabiyeti = NVL (in_tabiyeti, tabiyeti),
                   eslestirme_tipi = in_eslestirme_tipi,
                   kisi_bilgi_id = v_kisi_bilgi_id,
                   tc_kimlik_no_gecerli = v_tc_kimlik_gecerli
             WHERE kontrat_kisi_bilgi_id = out_kontrat_kisi_bilgi_id;
         END IF;
      ELSE
         IF is_sozlesme
         THEN
            v_status :=
               sozlesme_kisi_ara (in_sozlesme_no,
                                  in_adi,
                                  in_soyadi,
                                  in_babaadi,
                                  in_anaadi,
                                  in_dogumtarihi,
                                  in_cinsiyeti,
                                  in_il,
                                  in_ilce,
                                  in_tabiyeti,
                                  in_kisi_tipi,
                                  out_tc_kimlik_no,
                                  out_kontrat_kisi_bilgi_id,
                                  out_durum);
         ELSE
            -- tetikten ara
            v_status :=
               tetik_kisi_ara (in_ie_potansiyel_is_emri_id,
                               in_adi,
                               in_soyadi,
                               in_babaadi,
                               in_anaadi,
                               in_dogumtarihi,
                               in_cinsiyeti,
                               in_il,
                               in_ilce,
                               in_tabiyeti,
                               in_kisi_tipi,
                               out_tc_kimlik_no,
                               out_kontrat_kisi_bilgi_id,
                               out_durum);
         END IF;

         OPEN yk_dp_kontrat_kisi_bilgi_cur;

         FETCH yk_dp_kontrat_kisi_bilgi_cur INTO v_kontrat;

         out_kisi_bilgi_id := v_kisi_bilgi_id;

         IF yk_dp_kontrat_kisi_bilgi_cur%NOTFOUND
         THEN
            -- eger kayit kisi tablosunda yaratilmissa eksik bilgileri burdan alarak yeni bir kayit olustur
            SELECT yk_dp_kontrat_kisi_bilgi_seq.NEXTVAL
              INTO out_kontrat_kisi_bilgi_id
              FROM DUAL;

            INSERT INTO yk_dp_kontrat_kisi_bilgi (kontrat_kisi_bilgi_id,
                                                  kisi_bilgi_id,
                                                  sozlesme_no,
                                                  kisi_tipi,
                                                  unvani,
                                                  adi,
                                                  soyadi,
                                                  babaadi,
                                                  anaadi,
                                                  dogumyeri,
                                                  dogumtarihi,
                                                  cinsiyeti,
                                                  il,
                                                  ilce,
                                                  mahallekoy,
                                                  ciltno,
                                                  ailesirano,
                                                  sirano,
                                                  kangrubu,
                                                  n_seri,
                                                  n_no,
                                                  n_tckimlikno,
                                                  n_medenihali,
                                                  n_dini,
                                                  n_verildigiyer,
                                                  n_verilisnedeni,
                                                  n_kayitno,
                                                  n_verilistarihi,
                                                  n_oncekisoyadi,
                                                  e_verildigiyer,
                                                  e_belgeno,
                                                  e_verilistarihi,
                                                  e_sinifi,
                                                  e_kullancihaz,
                                                  giren_kullanici,
                                                  giris_tarihi,
                                                  tabiyeti,
                                                  eslestirme_tipi,
                                                  degistiren_kullanici,
                                                  degistirme_tarihi,
                                                  tc_kimlik_no_gecerli,
                                                  ie_potansiyel_is_emri_id)
               SELECT out_kontrat_kisi_bilgi_id,
                      kisi_bilgi_id,
                      in_sozlesme_no,
                      kisi_tipi,
                      NVL (unvani, in_unvani),
                      adi,
                      soyadi,
                      babaadi,
                      anaadi,
                      NVL (dogumyeri, in_dogumyeri),
                      dogumtarihi,
                      cinsiyeti,
                      NVL (il, in_il),
                      NVL (ilce, in_ilce),
                      NVL (mahallekoy, in_mahallekoy),
                      NVL (ciltno, in_ciltno),
                      NVL (ailesirano, in_ailesirano),
                      NVL (sirano, in_sirano),
                      NVL (kangrubu, in_kangrubu),
                      NVL (n_seri, in_n_seri),
                      NVL (n_no, in_n_no),
                      out_tc_kimlik_no,
                      NVL (n_medenihali, in_n_medenihali),
                      NVL (n_dini, in_n_dini),
                      NVL (n_verildigiyer, in_n_verildigiyer),
                      NVL (n_verilisnedeni, in_n_verilisnedeni),
                      NVL (n_kayitno, in_n_kayitno),
                      NVL (n_verilistarihi, in_n_verilistarihi),
                      NVL (n_oncekisoyadi, in_n_oncekisoyadi),
                      NVL (e_verildigiyer, in_e_verildigiyer),
                      NVL (e_belgeno, in_e_belgeno),
                      NVL (e_verilistarihi, in_e_verilistarihi),
                      NVL (e_sinifi, in_e_sinifi),
                      NVL (e_kullancihaz, in_e_kullancihaz),
                      v_user,
                      SYSDATE,
                      NVL (tabiyeti, in_tabiyeti),
                      in_eslestirme_tipi,
                      v_user,
                      SYSDATE,
                      v_tc_kimlik_gecerli,
                      in_ie_potansiyel_is_emri_id
                 FROM gl_kisi_bilgi
                WHERE kisi_bilgi_id = out_kisi_bilgi_id;
         ELSE
            -- eger bu sözlesme için kayit olusturulmus vise eksik bilgileri güncelle
            UPDATE yk_dp_kontrat_kisi_bilgi
               SET kisi_tipi = NVL (in_kisi_tipi, kisi_tipi),
                   kisi_bilgi_id = v_kisi_bilgi_id,
                   unvani = NVL (in_unvani, unvani),
                   adi = NVL (in_adi, adi),
                   soyadi = NVL (in_soyadi, soyadi),
                   babaadi = NVL (in_babaadi, babaadi),
                   anaadi = NVL (in_anaadi, anaadi),
                   dogumyeri = NVL (in_dogumyeri, dogumyeri),
                   dogumtarihi = NVL (in_dogumtarihi, dogumtarihi),
                   cinsiyeti = NVL (in_cinsiyeti, cinsiyeti),
                   il = NVL (in_il, il),
                   ilce = NVL (in_ilce, ilce),
                   mahallekoy = NVL (in_mahallekoy, mahallekoy),
                   ciltno = NVL (in_ciltno, ciltno),
                   ailesirano = NVL (in_ailesirano, ailesirano),
                   sirano = NVL (in_sirano, sirano),
                   kangrubu = NVL (in_kangrubu, kangrubu),
                   n_seri = NVL (in_n_seri, n_seri),
                   n_no = NVL (in_n_no, n_no),
                   n_tckimlikno = out_tc_kimlik_no,
                   n_medenihali = NVL (in_n_medenihali, n_medenihali),
                   n_dini = NVL (in_n_dini, n_dini),
                   n_verildigiyer = NVL (in_n_verildigiyer, n_verildigiyer),
                   n_verilisnedeni = NVL (in_n_verilisnedeni, n_verilisnedeni),
                   n_kayitno = NVL (in_n_kayitno, n_kayitno),
                   n_verilistarihi = NVL (in_n_verilistarihi, n_verilistarihi),
                   n_oncekisoyadi = NVL (in_n_oncekisoyadi, n_oncekisoyadi),
                   e_verildigiyer = NVL (in_e_verildigiyer, e_verildigiyer),
                   e_belgeno = NVL (in_e_belgeno, e_belgeno),
                   e_verilistarihi = NVL (in_e_verilistarihi, e_verilistarihi),
                   e_sinifi = NVL (in_e_sinifi, e_sinifi),
                   e_kullancihaz = NVL (in_e_kullancihaz, e_kullancihaz),
                   degistiren_kullanici = v_user,
                   degistirme_tarihi = SYSDATE,
                   tabiyeti = NVL (in_tabiyeti, tabiyeti),
                   eslestirme_tipi = NVL (in_eslestirme_tipi, eslestirme_tipi),
                   tc_kimlik_no_gecerli = v_tc_kimlik_gecerli
             WHERE kontrat_kisi_bilgi_id = v_kontrat.kontrat_kisi_bilgi_id;
         END IF;
      END IF;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'KONTRAT_KISI_BILGI_INSERT: ' || SQLERRM;
   END;

   PROCEDURE kontrat_kisi_bilgi_delete (
      in_kontrat_kisi_bilgi_id   IN     yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id%TYPE,
      out_durum                     OUT VARCHAR2)
   IS
      v_kontrat_kisi_bilgi_id   yk_dp_kontrat_kisi_bilgi.kontrat_kisi_bilgi_id%TYPE;
   BEGIN
      SELECT kontrat_kisi_bilgi_id
        INTO v_kontrat_kisi_bilgi_id
        FROM yk_dp_kontrat_kisi_bilgi
       WHERE kontrat_kisi_bilgi_id = in_kontrat_kisi_bilgi_id;

      out_durum := '0';

      IF v_kontrat_kisi_bilgi_id IS NOT NULL
      THEN
         DELETE FROM yk_dp_kontrat_kisi_bilgi
               WHERE kontrat_kisi_bilgi_id = in_kontrat_kisi_bilgi_id;

         COMMIT;
      ELSE
         out_durum := 'Böyle bir kayit mevcut degil.';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'KONTRAT_KISI_BILGI_SAVE: ' || SQLERRM;
   END;

   PROCEDURE kontrat_ekipman_bilgi_save (
      in_kutu_tipi                   IN     yk_dp_kontrat_ekipman_bilgi.kutu_tipi%TYPE,
      in_kutu_seri_no                IN     yk_dp_kontrat_ekipman_bilgi.kutu_seri_no%TYPE,
      in_modul_tipi                  IN     yk_dp_kontrat_ekipman_bilgi.modul_tipi%TYPE,
      in_modul_seri_no               IN     yk_dp_kontrat_ekipman_bilgi.modul_seri_no%TYPE,
      in_kart_seri_no                IN     yk_dp_kontrat_ekipman_bilgi.kart_seri_no%TYPE,
      in_harddisk_seri_no            IN     yk_dp_kontrat_ekipman_bilgi.harddisk_seri_no%TYPE, --MKECECI
      in_modem_seri_no               IN     yk_dp_kontrat_ekipman_bilgi.modem_seri_no%TYPE,
      in_sozlesme_no                 IN     yk_dp_kontrat_ekipman_bilgi.sozlesme_no%TYPE,
      out_kontrat_ekipman_bilgi_id   IN OUT yk_dp_kontrat_ekipman_bilgi.kontrat_ekipman_bilgi_id%TYPE,
      out_durum                         OUT VARCHAR2)
   IS
      v_kutu_tipi                  yk_dp_kontrat_ekipman_bilgi.kutu_tipi%TYPE;
      v_kutu_seri_no               yk_dp_kontrat_ekipman_bilgi.kutu_seri_no%TYPE;
      v_modul_tipi                 yk_dp_kontrat_ekipman_bilgi.modul_tipi%TYPE;
      v_modul_seri_no              yk_dp_kontrat_ekipman_bilgi.modul_seri_no%TYPE;
      v_kart_seri_no               yk_dp_kontrat_ekipman_bilgi.kart_seri_no%TYPE;
      v_sozlesme_no                yk_dp_kontrat_ekipman_bilgi.sozlesme_no%TYPE;
      v_kontrat_ekipman_bilgi_id   yk_dp_kontrat_ekipman_bilgi.kontrat_ekipman_bilgi_id%TYPE;
      v_harddisk_seri_no           yk_dp_kontrat_ekipman_bilgi.harddisk_seri_no%TYPE; --MKECECI
      v_modem_seri_no              yk_dp_kontrat_ekipman_bilgi.modem_seri_no%TYPE; --MKECECI

      CURSOR cur_kontrat_ekipman
      IS
         SELECT kontrat_ekipman_bilgi_id
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE    kontrat_ekipman_bilgi_id = out_kontrat_ekipman_bilgi_id
                OR (    sozlesme_no = v_sozlesme_no
                    AND kutu_tipi = v_kutu_tipi
                    AND kutu_seri_no = v_kutu_seri_no
                    AND modul_tipi = v_modul_tipi
                    AND modul_seri_no = v_modul_seri_no
                    AND kart_seri_no = v_kart_seri_no
                    AND harddisk_seri_no = v_harddisk_seri_no
                    AND modem_seri_no = v_modem_seri_no);            --MKECECI

      v_datafound                  NUMBER;
   BEGIN
      v_kutu_tipi := in_kutu_tipi;
      v_kutu_seri_no := in_kutu_seri_no;
      v_modul_tipi := in_modul_tipi;
      v_modul_seri_no := in_modul_seri_no;
      v_kart_seri_no := in_kart_seri_no;
      v_sozlesme_no := in_sozlesme_no;
      v_kontrat_ekipman_bilgi_id := out_kontrat_ekipman_bilgi_id;
      v_harddisk_seri_no := in_harddisk_seri_no;                     --MKECECI
      v_modem_seri_no := in_modem_seri_no;                           --MKECECI

      OPEN cur_kontrat_ekipman;

      FETCH cur_kontrat_ekipman INTO v_kontrat_ekipman_bilgi_id;

      IF cur_kontrat_ekipman%NOTFOUND
      THEN
         SELECT COUNT (1)
           INTO v_datafound
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE    (    sozlesme_no = v_sozlesme_no
                    AND (   kutu_seri_no = v_kutu_seri_no
                         OR modul_seri_no = v_kutu_seri_no
                         OR kart_seri_no = v_kutu_seri_no
                         OR harddisk_seri_no = v_kutu_seri_no
                         OR modem_seri_no = v_kutu_seri_no))         --MKECECI
                OR (    sozlesme_no = v_sozlesme_no
                    AND (   kutu_seri_no = v_modul_seri_no
                         OR modul_seri_no = v_modul_seri_no
                         OR kart_seri_no = v_modul_seri_no
                         OR harddisk_seri_no = v_modul_seri_no
                         OR modem_seri_no = v_modul_seri_no))        --MKECECI
                OR (    sozlesme_no = v_sozlesme_no
                    AND (   kutu_seri_no = v_kart_seri_no
                         OR modul_seri_no = v_kart_seri_no
                         OR kart_seri_no = v_kart_seri_no
                         OR harddisk_seri_no = v_kart_seri_no
                         OR modem_seri_no = v_kart_seri_no))
                OR (    sozlesme_no = v_sozlesme_no --MKECECI (Asagisi yeni eklendi)
                    AND (   kutu_seri_no = v_harddisk_seri_no
                         OR modul_seri_no = v_harddisk_seri_no
                         OR kart_seri_no = v_harddisk_seri_no
                         OR harddisk_seri_no = v_harddisk_seri_no
                         OR modem_seri_no = v_harddisk_seri_no))
                OR (    sozlesme_no = v_sozlesme_no --MKECECI (Asagisi yeni eklendi)
                    AND (   kutu_seri_no = v_modem_seri_no
                         OR modul_seri_no = v_modem_seri_no
                         OR kart_seri_no = v_modem_seri_no
                         OR harddisk_seri_no = v_modem_seri_no
                         OR modem_seri_no = v_modem_seri_no));

         IF v_datafound = 0
         THEN
            SELECT yk_dp_kontrat_ekipmanbilgi_seq.NEXTVAL
              INTO v_kontrat_ekipman_bilgi_id
              FROM DUAL;

            INSERT
              INTO yk_dp_kontrat_ekipman_bilgi (kontrat_ekipman_bilgi_id,
                                                sozlesme_no,
                                                kutu_tipi,
                                                kutu_seri_no,
                                                modul_tipi,
                                                modul_seri_no,
                                                kart_seri_no,
                                                harddisk_seri_no,
                                                modem_seri_no)
            VALUES (v_kontrat_ekipman_bilgi_id,
                    v_sozlesme_no,
                    v_kutu_tipi,
                    v_kutu_seri_no,
                    v_modul_tipi,
                    v_modul_seri_no,
                    v_kart_seri_no,
                    v_harddisk_seri_no,
                    v_modem_seri_no);
         ELSE
            out_durum := v_kart_seri_no || ' Bu kayit listede var.';
         END IF;
      ELSE
         UPDATE yk_dp_kontrat_ekipman_bilgi
            SET sozlesme_no = v_sozlesme_no,
                kutu_tipi = v_kutu_tipi,
                kutu_seri_no = v_kutu_seri_no,
                modul_tipi = v_modul_tipi,
                modul_seri_no = v_modul_seri_no,
                kart_seri_no = v_kart_seri_no,
                harddisk_seri_no = v_harddisk_seri_no,
                modem_seri_no = v_modem_seri_no
          WHERE kontrat_ekipman_bilgi_id = v_kontrat_ekipman_bilgi_id;
      END IF;

      CLOSE cur_kontrat_ekipman;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'KONTRAT_EKIPMAN_BILGI_SAVE: ' || SQLERRM;
   END;

   PROCEDURE kontrat_ekipman_bilgi_delete (
      in_kontrat_ekipman_bilgi_id   IN     yk_dp_kontrat_ekipman_bilgi.kontrat_ekipman_bilgi_id%TYPE,
      out_durum                        OUT VARCHAR2)
   IS
   BEGIN
      DELETE FROM yk_dp_kontrat_ekipman_bilgi
            WHERE kontrat_ekipman_bilgi_id = in_kontrat_ekipman_bilgi_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'KONTRAT_EKIPMAN_BILGI_DELETE: ' || SQLERRM;
   END;

   PROCEDURE kontrat_ke_update_sozlesme (
      in_prev_sozlesme   IN     yk_dp_kontrat.sozlesme_no%TYPE,
      in_next_sozlesme   IN     yk_dp_kontrat.sozlesme_no%TYPE,
      out_durum             OUT VARCHAR2)
   IS
      v_count   NUMBER (10) := 0;
   BEGIN
      SELECT COUNT (1)
        INTO v_count
        FROM yk_dp_kontrat
       WHERE sozlesme_no = in_prev_sozlesme AND (status = 30 OR status = 80);

      IF v_count = 0
      THEN
         SELECT COUNT (1)
           INTO v_count
           FROM yk_dp_kontrat
          WHERE     sozlesme_no = in_next_sozlesme
                AND (status = 30 OR status = 80);

         IF v_count = 0
         THEN
            kontrat_ke_backup (in_next_sozlesme, out_durum);

            DELETE FROM yk_dp_kontrat_kisi_bilgi
                  WHERE sozlesme_no = in_next_sozlesme;

            DELETE FROM yk_dp_kontrat_ekipman_bilgi
                  WHERE sozlesme_no = in_next_sozlesme;

            UPDATE yk_dp_kontrat_kisi_bilgi
               SET sozlesme_no = in_next_sozlesme
             WHERE     sozlesme_no = in_prev_sozlesme
                   AND ie_potansiyel_is_emri_id IS NOT NULL;

            UPDATE yk_dp_kontrat_ekipman_bilgi
               SET sozlesme_no = in_next_sozlesme
             WHERE sozlesme_no = in_prev_sozlesme;

            kontrat_ke_restore (in_prev_sozlesme, out_durum);
         ELSE
            out_durum := ' Nolu sözlesmede islem yapamazsiniz.';
         END IF;
      ELSE
         out_durum := ' Nolu sözlesmede islem yapamazsiniz.';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'kontrat_ke_update_sozlesme: ' || SQLERRM;
   END;

   --Site yönetici/ekipmanlari için sözlesme numarasi degistiginde kayitlari günceller.

   PROCEDURE kontrat_ke_update_tetik (
      in_prev_is_emri_id   IN     yk_dp_kontrat_kisi_bilgi.ie_potansiyel_is_emri_id%TYPE,
      in_next_is_emri_id   IN     yk_dp_kontrat_kisi_bilgi.ie_potansiyel_is_emri_id%TYPE,
      out_durum               OUT VARCHAR2)
   IS
   BEGIN
      out_durum := '0';

      UPDATE yk_dp_kontrat_kisi_bilgi
         SET ie_potansiyel_is_emri_id = in_next_is_emri_id
       WHERE ie_potansiyel_is_emri_id = in_prev_is_emri_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'kontrat_ke_update_tetik : ' || SQLERRM;
   END;

   PROCEDURE kontrat_ke_backup (
      in_sozlesme   IN     yk_dp_kontrat.sozlesme_no%TYPE,
      out_durum        OUT VARCHAR2)
   IS
   BEGIN
      DELETE FROM yk_dp_kontrat_kisi_bilgi
            WHERE sozlesme_no = 'TMP' || in_sozlesme;

      DELETE FROM yk_dp_kontrat_ekipman_bilgi
            WHERE sozlesme_no = 'TMP' || in_sozlesme;

      INSERT INTO yk_dp_kontrat_kisi_bilgi (kisi_bilgi_id,
                                            sozlesme_no,
                                            kisi_tipi,
                                            unvani,
                                            adi,
                                            soyadi,
                                            babaadi,
                                            anaadi,
                                            dogumyeri,
                                            dogumtarihi,
                                            cinsiyeti,
                                            il,
                                            ilce,
                                            mahallekoy,
                                            ciltno,
                                            ailesirano,
                                            sirano,
                                            kangrubu,
                                            n_seri,
                                            n_no,
                                            n_tckimlikno,
                                            n_medenihali,
                                            n_dini,
                                            n_verildigiyer,
                                            n_verilisnedeni,
                                            n_kayitno,
                                            n_verilistarihi,
                                            n_oncekisoyadi,
                                            e_verildigiyer,
                                            e_belgeno,
                                            e_verilistarihi,
                                            e_sinifi,
                                            e_kullancihaz,
                                            giren_kullanici,
                                            giris_tarihi,
                                            tabiyeti,
                                            kontrat_kisi_bilgi_id,
                                            degistiren_kullanici,
                                            degistirme_tarihi,
                                            ie_potansiyel_is_emri_id)
         SELECT kisi_bilgi_id,
                'TMP' || sozlesme_no,
                kisi_tipi,
                unvani,
                adi,
                soyadi,
                babaadi,
                anaadi,
                dogumyeri,
                dogumtarihi,
                cinsiyeti,
                il,
                ilce,
                mahallekoy,
                ciltno,
                ailesirano,
                sirano,
                kangrubu,
                n_seri,
                n_no,
                n_tckimlikno,
                n_medenihali,
                n_dini,
                n_verildigiyer,
                n_verilisnedeni,
                n_kayitno,
                n_verilistarihi,
                n_oncekisoyadi,
                e_verildigiyer,
                e_belgeno,
                e_verilistarihi,
                e_sinifi,
                e_kullancihaz,
                giren_kullanici,
                giris_tarihi,
                tabiyeti,
                yk_dp_kontrat_kisi_bilgi_seq.NEXTVAL,
                degistiren_kullanici,
                degistirme_tarihi,
                ie_potansiyel_is_emri_id
           FROM yk_dp_kontrat_kisi_bilgi
          WHERE sozlesme_no = in_sozlesme;

      INSERT INTO yk_dp_kontrat_ekipman_bilgi (kontrat_ekipman_bilgi_id,
                                               sozlesme_no,
                                               kutu_tipi,
                                               kutu_seri_no,
                                               modul_tipi,
                                               modul_seri_no,
                                               kart_seri_no)
         SELECT yk_dp_kontrat_ekipmanbilgi_seq.NEXTVAL,
                'TMP' || sozlesme_no,
                kutu_tipi,
                kutu_seri_no,
                modul_tipi,
                modul_seri_no,
                kart_seri_no
           FROM yk_dp_kontrat_ekipman_bilgi
          WHERE sozlesme_no = in_sozlesme;
   END;

   PROCEDURE kontrat_ke_restore (
      in_sozlesme   IN     yk_dp_kontrat.sozlesme_no%TYPE,
      out_durum        OUT VARCHAR2)
   IS
   BEGIN
      DELETE FROM yk_dp_kontrat_kisi_bilgi
            WHERE sozlesme_no = in_sozlesme;

      DELETE FROM yk_dp_kontrat_ekipman_bilgi
            WHERE sozlesme_no = in_sozlesme;

      UPDATE yk_dp_kontrat_kisi_bilgi
         SET sozlesme_no = REPLACE (sozlesme_no, 'TMP', '')
       WHERE sozlesme_no = 'TMP' || in_sozlesme;

      UPDATE yk_dp_kontrat_ekipman_bilgi
         SET sozlesme_no = REPLACE (sozlesme_no, 'TMP', '')
       WHERE sozlesme_no = 'TMP' || in_sozlesme;
   END;

   PROCEDURE kontrat_ke_clear (
      in_sozlesme   IN     yk_dp_kontrat.sozlesme_no%TYPE,
      out_durum        OUT VARCHAR2)
   IS
   BEGIN
      DELETE FROM yk_dp_kontrat_kisi_bilgi
            WHERE sozlesme_no = 'TMP' || in_sozlesme;

      DELETE FROM yk_dp_kontrat_ekipman_bilgi
            WHERE sozlesme_no = 'TMP' || in_sozlesme;
   END;

   PROCEDURE get_pottetikdetails (
      in_sozlesme                 IN     yk_dp_kontrat.sozlesme_no%TYPE,
      oie_potansiyel_is_emri_id      OUT ie_potansiyel_is_emri.id%TYPE,
      okisi_tipi                     OUT ie_potansiyel_is_emri.kisi_tipi%TYPE,
      oislem_tipi                    OUT ie_potansiyel_is_emri.islem_tipi%TYPE,
      oservice_address_id            OUT ie_potansiyel_is_emri.service_address_id%TYPE,
      osc_serial_number              OUT ie_potansiyel_is_emri.sc_serial_number%TYPE,
      ost_serial_number              OUT ie_potansiyel_is_emri.st_serial_number%TYPE,
      ocampaign_code                 OUT ie_potansiyel_is_emri.campaign_code%TYPE,
      osozlesme_tarihi               OUT ie_potansiyel_is_emri.islem_tarihi%TYPE,
      osozlesme_kampanya             OUT ie_potansiyel_is_emri.sozlesme_kampanya%TYPE,
      osales_agent_code              OUT ie_potansiyel_is_emri.bayi_kodu%TYPE,
      obayi_kodu                     OUT ie_potansiyel_is_emri.bayi_kodu%TYPE,
      oekip_kodu                     OUT ie_potansiyel_is_emri.ekip_kodu%TYPE,
      otahsilat_yapildi              OUT ie_potansiyel_is_emri.tahsilat_yapildi%TYPE,
      oeski_yeni_ceki                OUT ie_potansiyel_is_emri_detay.eski_yeni_ceki%TYPE,
      oanne_kizlik_soyad             OUT ie_potansiyel_is_emri_detay.anne_kizlik_soyad%TYPE,
      odogum_yeri                    OUT ie_potansiyel_is_emri_detay.dogum_yeri%TYPE,
      odogum_tarihi                  OUT ie_potansiyel_is_emri_detay.dogum_tarihi%TYPE,
      omeslek                        OUT ie_potansiyel_is_emri_detay.meslek%TYPE,
      omeslek_id                     OUT ie_potansiyel_is_emri_detay.meslek_id%TYPE,
      okimlik_yeri                   OUT ie_potansiyel_is_emri_detay.kimlik_yeri%TYPE,
      okimlik_seri_no                OUT ie_potansiyel_is_emri_detay.kimlik_seri_no%TYPE,
      okimlik_kayit_no               OUT ie_potansiyel_is_emri_detay.kimlik_kayit_no%TYPE,
      okimlik_tarihi                 OUT ie_potansiyel_is_emri_detay.kimlik_tarihi%TYPE,
      otabiyet                       OUT ie_potansiyel_is_emri_detay.tabiyet%TYPE,
      overgi_dairesi                 OUT ie_potansiyel_is_emri_detay.vergi_dairesi%TYPE,
      overgi_no                      OUT ie_potansiyel_is_emri_detay.vergi_no%TYPE,
      omodul_tipi                    OUT ie_potansiyel_is_emri_detay.modul_tipi%TYPE,
      omodul_seri_no                 OUT ie_potansiyel_is_emri_detay.modul_seri_no%TYPE,
      okon_gel_tipi                  OUT ie_potansiyel_is_emri_detay.kon_gel_tipi%TYPE,
      oservis_tarihi                 OUT ie_potansiyel_is_emri_detay.servis_tarihi%TYPE,
      orevizyon                      OUT ie_potansiyel_is_emri_detay.revizyon%TYPE,
      obatch                         OUT ie_potansiyel_is_emri_detay.batch%TYPE,
      ouye_tipi                      OUT ie_potansiyel_is_emri_detay.uye_tipi%TYPE,
      okimlik_cinsi                  OUT ie_potansiyel_is_emri_detay.kimlik_cinsi%TYPE,
      ofranchise_code                OUT ie_potansiyel_is_emri_detay.franchise_code%TYPE,
      otuttugu_takim_kodu            OUT ie_potansiyel_is_emri_detay.tuttugu_takim_kodu%TYPE,
      osozlesme_tipi                 OUT ie_potansiyel_is_emri_detay.sozlesme_tipi%TYPE,
      ois_yeri_yetkilisi_1           OUT ie_potansiyel_is_emri_detay.is_yeri_yetkilisi_1%TYPE,
      ois_yeri_yetkilisi_2           OUT ie_potansiyel_is_emri_detay.is_yeri_yetkilisi_2%TYPE,
      odigikutu_bagli_tel            OUT ie_potansiyel_is_emri_detay.digikutu_bagli_tel%TYPE,
      odwelling_type                 OUT ie_potansiyel_is_emri_detay.dwelling_type%TYPE,
      obilling_frequency             OUT ie_potansiyel_is_emri_detay.billing_frequency%TYPE,
      oruhsat_yeri_id                OUT ie_potansiyel_is_emri_detay.ruhsat_yeri_id%TYPE,
      oruhsat_tarihi                 OUT ie_potansiyel_is_emri_detay.ruhsat_tarihi%TYPE,
      oruhsat_verilme_ili            OUT ie_potansiyel_is_emri_detay.ruhsat_verilme_ili%TYPE,
      oruhsat_sicil_no               OUT ie_potansiyel_is_emri_detay.ruhsat_sicil_no%TYPE,
      oruhsat_belediye               OUT ie_potansiyel_is_emri_detay.ruhsat_belediye%TYPE,
      ofaaliyet_konusu               OUT ie_potansiyel_is_emri_detay.faaliyet_konusu%TYPE,
      ooutlet_location               OUT ie_potansiyel_is_emri_detay.outlet_location%TYPE,
      ostb_tipi                      OUT ie_potansiyel_is_emri_detay.stb_tipi%TYPE,
      obaba_adi                      OUT ie_potansiyel_is_emri_detay.baba_adi%TYPE,
      oanne_adi                      OUT ie_potansiyel_is_emri_detay.anne_adi%TYPE,
      onufusa_kayitli_ili            OUT ie_potansiyel_is_emri_detay.nufusa_kayitli_ili%TYPE,
      onufusa_kayitli_ilcesi         OUT ie_potansiyel_is_emri_detay.nufusa_kayitli_ilcesi%TYPE,
      oabone_ozellik_kodu            OUT ie_potansiyel_is_emri_detay.abone_ozellik_kodu%TYPE,
      ouydu_tipi                     OUT ie_potansiyel_is_emri_detay.uydu_tipi%TYPE,
      otc_kimlik_no                  OUT ie_potansiyel_is_emri_detay.tc_kimlik_no%TYPE,
      ocilt_no                       OUT ie_potansiyel_is_emri_detay.cilt_no%TYPE,
      oaile_sira_no                  OUT ie_potansiyel_is_emri_detay.aile_sira_no%TYPE,
      osira_no                       OUT ie_potansiyel_is_emri_detay.sira_no%TYPE,
      ogonderim_kanali               OUT ie_potansiyel_is_emri_detay.gonderim_kanali%TYPE,
      ogonderim_bedeli               OUT ie_potansiyel_is_emri_detay.gonderim_bedeli%TYPE,
      ogonderim_currency             OUT ie_potansiyel_is_emri_detay.gonderim_currency%TYPE,
      osc_model                      OUT ie_potansiyel_is_emri_detay.sc_model%TYPE,
      osc_manufacturer               OUT ie_potansiyel_is_emri_detay.sc_manufacturer%TYPE,
      ost_model                      OUT ie_potansiyel_is_emri_detay.st_model%TYPE,
      ost_manufacturer               OUT ie_potansiyel_is_emri_detay.st_manufacturer%TYPE,
      omodul_seri_no_varmi           OUT ie_potansiyel_is_emri_detay.modul_seri_no_varmi%TYPE,
      ogonderim_no                   OUT ie_potansiyel_is_emri_detay.gonderim_no%TYPE,
      ostb_seri_no_varmi             OUT ie_potansiyel_is_emri_detay.stb_seri_no_varmi%TYPE,
      omodul_manufacturer            OUT ie_potansiyel_is_emri_detay.modul_manufacturer%TYPE,
      oad                            OUT VARCHAR2,
      osoyad                         OUT VARCHAR2,
      ocinsiyet                      OUT VARCHAR2,
      /*
      <ogm> WIRECARD
      */
      opayment_method                OUT ie_potansiyel_is_emri_detay.payment_method%TYPE,
      opayment_bank_code             OUT ie_potansiyel_is_emri_detay.payment_bank_code%TYPE,
      opayment_no                    OUT ie_potansiyel_is_emri_detay.payment_no%TYPE,
      opayment_cvv                   OUT ie_potansiyel_is_emri_detay.payment_cvv%TYPE,
      opayment_expire_date           OUT ie_potansiyel_is_emri_detay.payment_expire_date%TYPE,
      opayment_name                  OUT ie_potansiyel_is_emri_detay.payment_name%TYPE,
      /*
      <ogm> WIRECARD
      */

      --<MKECECI> Harddisk,modem gelistirmeleri
      oharddisk_seri_no              OUT ie_potansiyel_is_emri.harddisk_seri_no%TYPE,
      omodem_seri_no                 OUT ie_potansiyel_is_emri.modem_seri_no%TYPE,
      --<</end> MKECECI>
      out_msg                        OUT VARCHAR2,
      out_durum                      OUT VARCHAR2)
   IS
      v_ie_potansiyel_is_emri_id   ie_potansiyel_is_emri.id%TYPE;
      v_kisi_tipi                  ie_potansiyel_is_emri.kisi_tipi%TYPE;
      v_islem_tipi                 ie_potansiyel_is_emri.islem_tipi%TYPE;
      v_service_address_id         ie_potansiyel_is_emri.service_address_id%TYPE;
      v_sc_serial_number           ie_potansiyel_is_emri.sc_serial_number%TYPE;
      v_st_serial_number           ie_potansiyel_is_emri.st_serial_number%TYPE;
      v_campaign_code              ie_potansiyel_is_emri.campaign_code%TYPE;
      v_sozlesme_tarihi            ie_potansiyel_is_emri.islem_tarihi%TYPE;
      v_sozlesme_kampanya          ie_potansiyel_is_emri.sozlesme_kampanya%TYPE;
      v_sales_agent_code           ie_potansiyel_is_emri.bayi_kodu%TYPE;
      v_bayi_kodu                  ie_potansiyel_is_emri.bayi_kodu%TYPE;
      v_ekip_kodu                  ie_potansiyel_is_emri.ekip_kodu%TYPE;
      v_tahsilat_yapildi           ie_potansiyel_is_emri.tahsilat_yapildi%TYPE;
      v_eski_yeni_ceki             ie_potansiyel_is_emri_detay.eski_yeni_ceki%TYPE;
      v_anne_kizlik_soyad          ie_potansiyel_is_emri_detay.anne_kizlik_soyad%TYPE;
      v_dogum_yeri                 ie_potansiyel_is_emri_detay.dogum_yeri%TYPE;
      v_dogum_tarihi               ie_potansiyel_is_emri_detay.dogum_tarihi%TYPE;
      v_meslek                     ie_potansiyel_is_emri_detay.meslek%TYPE;
      v_meslek_id                  ie_potansiyel_is_emri_detay.meslek_id%TYPE;
      v_kimlik_yeri                ie_potansiyel_is_emri_detay.kimlik_yeri%TYPE;
      v_kimlik_seri_no             ie_potansiyel_is_emri_detay.kimlik_seri_no%TYPE;
      v_kimlik_kayit_no            ie_potansiyel_is_emri_detay.kimlik_kayit_no%TYPE;
      v_kimlik_tarihi              ie_potansiyel_is_emri_detay.kimlik_tarihi%TYPE;
      v_tabiyet                    ie_potansiyel_is_emri_detay.tabiyet%TYPE;
      v_vergi_dairesi              ie_potansiyel_is_emri_detay.vergi_dairesi%TYPE;
      v_vergi_no                   ie_potansiyel_is_emri_detay.vergi_no%TYPE;
      v_modul_tipi                 ie_potansiyel_is_emri_detay.modul_tipi%TYPE;
      v_modul_seri_no              ie_potansiyel_is_emri_detay.modul_seri_no%TYPE;
      v_kon_gel_tipi               ie_potansiyel_is_emri_detay.kon_gel_tipi%TYPE;
      v_servis_tarihi              ie_potansiyel_is_emri_detay.servis_tarihi%TYPE;
      v_revizyon                   ie_potansiyel_is_emri_detay.revizyon%TYPE;
      v_batch                      ie_potansiyel_is_emri_detay.batch%TYPE;
      v_uye_tipi                   ie_potansiyel_is_emri_detay.uye_tipi%TYPE;
      v_kimlik_cinsi               ie_potansiyel_is_emri_detay.kimlik_cinsi%TYPE;
      v_franchise_code             ie_potansiyel_is_emri_detay.franchise_code%TYPE;
      v_tuttugu_takim_kodu         ie_potansiyel_is_emri_detay.tuttugu_takim_kodu%TYPE;
      v_sozlesme_tipi              ie_potansiyel_is_emri_detay.sozlesme_tipi%TYPE;
      v_is_yeri_yetkilisi_1        ie_potansiyel_is_emri_detay.is_yeri_yetkilisi_1%TYPE;
      v_is_yeri_yetkilisi_2        ie_potansiyel_is_emri_detay.is_yeri_yetkilisi_2%TYPE;
      v_digikutu_bagli_tel         ie_potansiyel_is_emri_detay.digikutu_bagli_tel%TYPE;
      v_dwelling_type              ie_potansiyel_is_emri_detay.dwelling_type%TYPE;
      v_billing_frequency          ie_potansiyel_is_emri_detay.billing_frequency%TYPE;
      v_ruhsat_yeri_id             ie_potansiyel_is_emri_detay.ruhsat_yeri_id%TYPE;
      v_ruhsat_tarihi              ie_potansiyel_is_emri_detay.ruhsat_tarihi%TYPE;
      v_ruhsat_verilme_ili         ie_potansiyel_is_emri_detay.ruhsat_verilme_ili%TYPE;
      v_ruhsat_sicil_no            ie_potansiyel_is_emri_detay.ruhsat_sicil_no%TYPE;
      v_ruhsat_belediye            ie_potansiyel_is_emri_detay.ruhsat_belediye%TYPE;
      v_faaliyet_konusu            ie_potansiyel_is_emri_detay.faaliyet_konusu%TYPE;
      v_outlet_location            ie_potansiyel_is_emri_detay.outlet_location%TYPE;
      v_stb_tipi                   ie_potansiyel_is_emri_detay.stb_tipi%TYPE;
      v_baba_adi                   ie_potansiyel_is_emri_detay.baba_adi%TYPE;
      v_anne_adi                   ie_potansiyel_is_emri_detay.anne_adi%TYPE;
      v_nufusa_kayitli_ili         ie_potansiyel_is_emri_detay.nufusa_kayitli_ili%TYPE;
      v_nufusa_kayitli_ilcesi      ie_potansiyel_is_emri_detay.nufusa_kayitli_ilcesi%TYPE;
      v_abone_ozellik_kodu         ie_potansiyel_is_emri_detay.abone_ozellik_kodu%TYPE;
      v_uydu_tipi                  ie_potansiyel_is_emri_detay.uydu_tipi%TYPE;
      v_tc_kimlik_no               ie_potansiyel_is_emri_detay.tc_kimlik_no%TYPE;
      v_cilt_no                    ie_potansiyel_is_emri_detay.cilt_no%TYPE;
      v_aile_sira_no               ie_potansiyel_is_emri_detay.aile_sira_no%TYPE;
      v_sira_no                    ie_potansiyel_is_emri_detay.sira_no%TYPE;
      v_gonderim_kanali            ie_potansiyel_is_emri_detay.gonderim_kanali%TYPE;
      v_gonderim_bedeli            ie_potansiyel_is_emri_detay.gonderim_bedeli%TYPE;
      v_gonderim_currency          ie_potansiyel_is_emri_detay.gonderim_currency%TYPE;
      v_sc_model                   ie_potansiyel_is_emri_detay.sc_model%TYPE;
      v_sc_manufacturer            ie_potansiyel_is_emri_detay.sc_manufacturer%TYPE;
      v_st_model                   ie_potansiyel_is_emri_detay.st_model%TYPE;
      v_st_manufacturer            ie_potansiyel_is_emri_detay.st_manufacturer%TYPE;
      v_modul_seri_no_varmi        ie_potansiyel_is_emri_detay.modul_seri_no_varmi%TYPE;
      v_gonderim_no                ie_potansiyel_is_emri_detay.gonderim_no%TYPE;
      v_stb_seri_no_varmi          ie_potansiyel_is_emri_detay.stb_seri_no_varmi%TYPE;
      v_modul_manufacturer         ie_potansiyel_is_emri_detay.modul_manufacturer%TYPE;
      v_num                        VARCHAR2 (50);
      v_account_number             VARCHAR2 (50);
      v_prospect_number            VARCHAR2 (50);
      v_ad                         VARCHAR2 (100);
      v_soyad                      VARCHAR2 (100);
      v_cinsiyet                   VARCHAR2 (10);
      v_tmp                        NUMBER (1);
      /*
      <OGM> WIRECARD
      */
      v_payment_method             ie_potansiyel_is_emri_detay.payment_method%TYPE;
      v_payment_bank_code          ie_potansiyel_is_emri_detay.payment_bank_code%TYPE;
      v_payment_no                 ie_potansiyel_is_emri_detay.payment_no%TYPE;
      v_payment_cvv                ie_potansiyel_is_emri_detay.payment_cvv%TYPE;
      v_payment_expire_date        ie_potansiyel_is_emri_detay.payment_expire_date%TYPE;
      v_payment_name               ie_potansiyel_is_emri_detay.payment_name%TYPE;
      /*
      <OGM> WIRECARD
      */

      --<MKECECI>
      v_harddisk_seri_no           ie_potansiyel_is_emri.harddisk_seri_no%TYPE;
      v_modem_seri_no              ie_potansiyel_is_emri.modem_seri_no%TYPE;
   --</MKECECI>
   BEGIN
      out_msg := '';

      SELECT cnt
        INTO out_durum
        FROM (SELECT DECODE (COUNT (1), 0, '1', '0') cnt
                FROM ie_potansiyel_is_emri
               WHERE     sozlesme_no = in_sozlesme
                     AND durum IN ('C')
                     AND (islem_tipi = 11 OR islem_tipi = 1));

      --door2door
      IF out_durum = '1'
      THEN
         RETURN;
      END IF;

      SELECT i.id ie_potansiyel_is_emri_id,
             i.kisi_tipi,
             i.islem_tipi,
             i.sc_serial_number,
             i.st_serial_number,
             i.campaign_code,
             i.islem_tarihi,
             i.sozlesme_kampanya,
             i.bayi_kodu,
             i.ekip_kodu,
             i.tahsilat_yapildi,
             d.eski_yeni_ceki,
             d.anne_kizlik_soyad,
             d.dogum_yeri,
             d.dogum_tarihi,
             d.meslek,
             d.meslek_id,
             d.kimlik_yeri,
             d.kimlik_seri_no,
             d.kimlik_kayit_no,
             d.kimlik_tarihi,
             d.tabiyet,
             d.vergi_dairesi,
             d.vergi_no,
             d.modul_tipi,
             d.modul_seri_no,
             d.kon_gel_tipi,
             d.servis_tarihi,
             d.revizyon,
             d.batch,
             d.uye_tipi,
             d.kimlik_cinsi,
             d.franchise_code,
             d.tuttugu_takim_kodu,
             d.sozlesme_tipi,
             d.is_yeri_yetkilisi_1,
             d.is_yeri_yetkilisi_2,
             d.digikutu_bagli_tel,
             d.dwelling_type,
             d.billing_frequency,
             d.ruhsat_yeri_id,
             d.ruhsat_tarihi,
             d.ruhsat_verilme_ili,
             d.ruhsat_sicil_no,
             d.ruhsat_belediye,
             d.faaliyet_konusu,
             d.outlet_location,
             d.stb_tipi,
             d.baba_adi,
             d.anne_adi,
             d.nufusa_kayitli_ili,
             d.nufusa_kayitli_ilcesi,
             d.abone_ozellik_kodu,
             d.uydu_tipi,
             d.tc_kimlik_no,
             d.cilt_no,
             d.aile_sira_no,
             d.sira_no,
             d.gonderim_kanali,
             d.gonderim_bedeli,
             d.gonderim_currency,
             d.sc_model,
             d.sc_manufacturer,
             d.st_model,
             d.st_manufacturer,
             d.modul_seri_no_varmi,
             d.gonderim_no,
             d.stb_seri_no_varmi,
             d.modul_manufacturer,
             --d.hesaplanan_toplam_bedel,
             NVL (i.prospect_number, i.account_number),
             i.account_number,
             i.prospect_number,
             d.payment_method,
             d.payment_bank_code,
             d.payment_no,
             d.payment_cvv,
             d.payment_expire_date,
             d.payment_name,
             i.harddisk_seri_no,
             i.modem_seri_no
        INTO v_ie_potansiyel_is_emri_id,
             v_kisi_tipi,
             v_islem_tipi,
             v_sc_serial_number,
             v_st_serial_number,
             v_campaign_code,
             v_sozlesme_tarihi,
             v_sozlesme_kampanya,
             v_bayi_kodu,
             v_ekip_kodu,
             v_tahsilat_yapildi,
             v_eski_yeni_ceki,
             v_anne_kizlik_soyad,
             v_dogum_yeri,
             v_dogum_tarihi,
             v_meslek,
             v_meslek_id,
             v_kimlik_yeri,
             v_kimlik_seri_no,
             v_kimlik_kayit_no,
             v_kimlik_tarihi,
             v_tabiyet,
             v_vergi_dairesi,
             v_vergi_no,
             v_modul_tipi,
             v_modul_seri_no,
             v_kon_gel_tipi,
             v_servis_tarihi,
             v_revizyon,
             v_batch,
             v_uye_tipi,
             v_kimlik_cinsi,
             v_franchise_code,
             v_tuttugu_takim_kodu,
             v_sozlesme_tipi,
             v_is_yeri_yetkilisi_1,
             v_is_yeri_yetkilisi_2,
             v_digikutu_bagli_tel,
             v_dwelling_type,
             v_billing_frequency,
             v_ruhsat_yeri_id,
             v_ruhsat_tarihi,
             v_ruhsat_verilme_ili,
             v_ruhsat_sicil_no,
             v_ruhsat_belediye,
             v_faaliyet_konusu,
             v_outlet_location,
             v_stb_tipi,
             v_baba_adi,
             v_anne_adi,
             v_nufusa_kayitli_ili,
             v_nufusa_kayitli_ilcesi,
             v_abone_ozellik_kodu,
             v_uydu_tipi,
             v_tc_kimlik_no,
             v_cilt_no,
             v_aile_sira_no,
             v_sira_no,
             v_gonderim_kanali,
             v_gonderim_bedeli,
             v_gonderim_currency,
             v_sc_model,
             v_sc_manufacturer,
             v_st_model,
             v_st_manufacturer,
             v_modul_seri_no_varmi,
             v_gonderim_no,
             v_stb_seri_no_varmi,
             v_modul_manufacturer,
             --v_hesaplanan_toplam_bedel,
             v_num,
             v_account_number,
             v_prospect_number,
             v_payment_method,
             v_payment_bank_code,
             v_payment_no,
             v_payment_cvv,
             v_payment_expire_date,
             v_payment_name,
             v_harddisk_seri_no,
             v_modem_seri_no
        FROM ie_potansiyel_is_emri i, ie_potansiyel_is_emri_detay d
       WHERE     i.id = d.ie_potansiyel_is_emri_id(+)
             AND sozlesme_no = in_sozlesme
             AND durum IN ('C')
             AND (islem_tipi = 11 OR islem_tipi = 1);

      v_service_address_id :=
         potansiyel_is_emri_pack.ie_pot_get_service_id (
            v_ie_potansiyel_is_emri_id,
            'SYSTEM');
      --door2door
      out_msg :=
            'Bu sözlesme için potansiyel tetik kaydi vardir. <E> Bu tetik kaydindaki bilgilerle sozlesme tarihi,kampanya,bayi kodu ve ekip kodu bilgileri degisecektir.<E>Potansiyel/Abone No: '
         || v_num
         || '<E>Bu islemi onayliyor musunuz? Onaylamiyorsaniz sözlesme noyu degistiriniz.';
      osozlesme_tarihi := v_sozlesme_tarihi;
      osozlesme_kampanya := v_sozlesme_kampanya;
      obayi_kodu := v_bayi_kodu;

      IF v_bayi_kodu = v_ekip_kodu
      THEN
         oekip_kodu := '000';
      ELSE
         oekip_kodu := v_ekip_kodu;
      END IF;

      SELECT COUNT (1)
        INTO v_tmp
        FROM DUAL
       WHERE ts_is_tipi_getir (v_bayi_kodu, 1) LIKE '%1%';

      IF v_tmp = 1 OR v_islem_tipi = 11
      THEN
         v_sales_agent_code := v_bayi_kodu;
      ELSE
         v_sales_agent_code := TO_NUMBER (dbs_sabit ('YURT_DISI_DEFAULT_TS'));
      END IF;

      IF v_prospect_number IS NOT NULL
      THEN
         SELECT MAX (first_name),
                MAX (last_name),
                MAX (DECODE (title,  'BAY', 'BAY',  'BAYAN', 'BAYAN',  ''))
           INTO v_ad, v_soyad, v_cinsiyet
           FROM wiz_prospect_descrip
          WHERE prospect_number = v_prospect_number;
      END IF;

      IF v_account_number IS NOT NULL
      THEN
         SELECT first_name,
                last_name,
                DECODE (title,  'BAY', 'BAY',  'BAYAN', 'BAYAN',  '')
           INTO v_ad, v_soyad, v_cinsiyet
           FROM wiz_customer_descrip
          WHERE account_number = v_account_number;
      END IF;

      osales_agent_code := v_sales_agent_code;
      oie_potansiyel_is_emri_id := v_ie_potansiyel_is_emri_id;
      okisi_tipi := v_kisi_tipi;
      oislem_tipi := v_islem_tipi;
      oservice_address_id := v_service_address_id;
      osc_serial_number := v_sc_serial_number;
      ost_serial_number := v_st_serial_number;
      ocampaign_code := v_campaign_code;
      otahsilat_yapildi := v_tahsilat_yapildi;
      oeski_yeni_ceki := v_eski_yeni_ceki;
      oanne_kizlik_soyad := v_anne_kizlik_soyad;
      odogum_yeri := v_dogum_yeri;
      odogum_tarihi := v_dogum_tarihi;
      omeslek := v_meslek;
      omeslek_id := v_meslek_id;
      okimlik_yeri := v_kimlik_yeri;
      okimlik_seri_no := v_kimlik_seri_no;
      okimlik_kayit_no := v_kimlik_kayit_no;
      okimlik_tarihi := v_kimlik_tarihi;
      otabiyet := v_tabiyet;
      overgi_dairesi := v_vergi_dairesi;
      overgi_no := v_vergi_no;
      omodul_tipi := v_modul_tipi;
      omodul_seri_no := v_modul_seri_no;
      okon_gel_tipi := v_kon_gel_tipi;
      oservis_tarihi := v_servis_tarihi;
      orevizyon := v_revizyon;
      obatch := v_batch;
      ouye_tipi := v_uye_tipi;
      okimlik_cinsi := v_kimlik_cinsi;
      ofranchise_code := v_franchise_code;
      otuttugu_takim_kodu := v_tuttugu_takim_kodu;
      osozlesme_tipi := v_sozlesme_tipi;
      ois_yeri_yetkilisi_1 := v_is_yeri_yetkilisi_1;
      ois_yeri_yetkilisi_2 := v_is_yeri_yetkilisi_2;
      odigikutu_bagli_tel := v_digikutu_bagli_tel;
      odwelling_type := v_dwelling_type;
      obilling_frequency := v_billing_frequency;
      oruhsat_yeri_id := v_ruhsat_yeri_id;
      oruhsat_tarihi := v_ruhsat_tarihi;
      oruhsat_verilme_ili := v_ruhsat_verilme_ili;
      oruhsat_sicil_no := v_ruhsat_sicil_no;
      oruhsat_belediye := v_ruhsat_belediye;
      ofaaliyet_konusu := v_faaliyet_konusu;
      ooutlet_location := v_outlet_location;
      ostb_tipi := v_stb_tipi;
      obaba_adi := v_baba_adi;
      oanne_adi := v_anne_adi;
      onufusa_kayitli_ili := v_nufusa_kayitli_ili;
      onufusa_kayitli_ilcesi := v_nufusa_kayitli_ilcesi;
      oabone_ozellik_kodu := v_abone_ozellik_kodu;
      ouydu_tipi := v_uydu_tipi;
      otc_kimlik_no := v_tc_kimlik_no;
      ocilt_no := v_cilt_no;
      oaile_sira_no := v_aile_sira_no;
      osira_no := v_sira_no;
      ogonderim_kanali := v_gonderim_kanali;
      ogonderim_bedeli := v_gonderim_bedeli;
      ogonderim_currency := v_gonderim_currency;
      osc_model := v_sc_model;
      osc_manufacturer := v_sc_manufacturer;
      ost_model := v_st_model;
      ost_manufacturer := v_st_manufacturer;
      omodul_seri_no_varmi := v_modul_seri_no_varmi;
      ogonderim_no := v_gonderim_no;
      ostb_seri_no_varmi := v_stb_seri_no_varmi;
      omodul_manufacturer := v_modul_manufacturer;
      oad := v_ad;
      osoyad := v_soyad;
      ocinsiyet := v_cinsiyet;
      --<OGM> WIRECARD
      opayment_method := v_payment_method;
      opayment_bank_code := v_payment_bank_code;
      opayment_no := v_payment_no;
      opayment_cvv := v_payment_cvv;
      opayment_expire_date := v_payment_expire_date;
      opayment_name := v_payment_name;
      --</OGM>

      --<MKECECI>
      oharddisk_seri_no := v_harddisk_seri_no;
      omodem_seri_no := v_modem_seri_no;
   --</MKECECI>
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := 'get_pottetikdetails: ' || SQLERRM;
   END get_pottetikdetails;

   FUNCTION is_valid_sozlesme_no ( /*Description: Girilen Sözlesme numarasini sistemde tanimlimi diye kontrol eder.
                                     Remarks:  PR_STB_TIPI tablosundan verilere bakar. stb_tipi null yada PH ise PH dir. PH kayitlar sadece numeric veri alabiliriler.
                                     Returns: 1 evet,0 hayir .. diger olusabilecek kosullar için number yapildi.
                                 */
                                  isozlesme_no        VARCHAR2,
                                  igiren_kullanici    VARCHAR2,
                                  istb_tipi           VARCHAR2 DEFAULT NULL)
      RETURN NUMBER
   IS
      v_stb_tipi   pr_stb_tipi.stb_tipi%TYPE;
      v_soz_alf    pr_stb_tipi.sozlesme_no_1%TYPE;
      v_soz_num    pr_stb_tipi.sozlesme_no_1%TYPE;
      v_soz1_alf   pr_stb_tipi.sozlesme_no_1%TYPE;
      v_soz1_num   pr_stb_tipi.sozlesme_no_1%TYPE;
      v_soz2_alf   pr_stb_tipi.sozlesme_no_1%TYPE;
      v_soz2_num   pr_stb_tipi.sozlesme_no_1%TYPE;
   BEGIN
      --tüm sözlesmeler 10 karakter olmalidir.
      IF LENGTH (isozlesme_no) <> 10
      THEN
         RETURN 0;
      END IF;

      v_stb_tipi := NVL (istb_tipi, 'PH');

      IF v_stb_tipi = 'PH'
      THEN
         IF is_numeric (isozlesme_no) = 0
         THEN
            RETURN 0;
         END IF;

         v_soz_num := isozlesme_no;
         v_soz_alf := NULL;

         FOR rec IN (  SELECT *
                         FROM pr_stb_tipi
                        WHERE listeden_gizle = 'H' AND stb_tipi <> v_stb_tipi
                     ORDER BY sozlesme_no_1)
         LOOP
            v_soz1_num := NULL;
            v_soz1_alf := rec.sozlesme_no_1;
            v_soz2_num := NULL;
            v_soz2_alf := rec.sozlesme_no_2;

            FOR i IN 1 .. LENGTH (isozlesme_no)
            LOOP
               IF     v_soz1_num IS NULL
                  AND is_numeric (SUBSTR (rec.sozlesme_no_1, i)) = 1
               THEN
                  v_soz1_num := SUBSTR (rec.sozlesme_no_1, i);
                  v_soz1_alf := SUBSTR (rec.sozlesme_no_1, 1, i - 1);
               END IF;

               IF     v_soz2_num IS NULL
                  AND is_numeric (SUBSTR (rec.sozlesme_no_2, i)) = 1
               THEN
                  v_soz2_num := SUBSTR (rec.sozlesme_no_2, i);
                  v_soz2_alf := SUBSTR (rec.sozlesme_no_2, 1, i - 1);
               END IF;
            END LOOP;

            IF     NVL (v_soz_num, '-1') >= NVL (v_soz1_num, '-1')
               AND NVL (v_soz_alf, '-1') = NVL (v_soz1_alf, '-1')
               AND NVL (v_soz_num, '-1') <= NVL (v_soz2_num, '-1')
               AND NVL (v_soz_alf, '-1') = NVL (v_soz2_alf, '-1')
            THEN
               RETURN 0;
            END IF;
         END LOOP;

         RETURN 1;
      ELSE
         IF     is_numeric (isozlesme_no) = 0
            AND dbs_sabit ('KONTRAT_SOZLESMENO_ALFANUMERIC_MI') = 'H'
         THEN
            RETURN 0;
         END IF;

         v_soz_num := NULL;
         v_soz_alf := isozlesme_no;

         FOR i IN 1 .. LENGTH (isozlesme_no)
         LOOP
            IF     v_soz_num IS NULL
               AND is_numeric (SUBSTR (isozlesme_no, i)) = 1
            THEN
               v_soz_num := SUBSTR (isozlesme_no, i);
               v_soz_alf := SUBSTR (isozlesme_no, 1, i - 1);
            END IF;
         END LOOP;

         FOR rec IN (  SELECT *
                         FROM pr_stb_tipi
                        WHERE listeden_gizle = 'H' AND stb_tipi = v_stb_tipi
                     ORDER BY sozlesme_no_1)
         LOOP
            v_soz1_num := NULL;
            v_soz1_alf := rec.sozlesme_no_1;
            v_soz2_num := NULL;
            v_soz2_alf := rec.sozlesme_no_2;

            FOR i IN 1 .. LENGTH (isozlesme_no)
            LOOP
               IF     v_soz1_num IS NULL
                  AND is_numeric (SUBSTR (rec.sozlesme_no_1, i)) = 1
               THEN
                  v_soz1_num := SUBSTR (rec.sozlesme_no_1, i);
                  v_soz1_alf := SUBSTR (rec.sozlesme_no_1, 1, i - 1);
               END IF;

               IF     v_soz2_num IS NULL
                  AND is_numeric (SUBSTR (rec.sozlesme_no_2, i)) = 1
               THEN
                  v_soz2_num := SUBSTR (rec.sozlesme_no_2, i);
                  v_soz2_alf := SUBSTR (rec.sozlesme_no_2, 1, i - 1);
               END IF;
            END LOOP;

            IF     NVL (v_soz_num, '-1') >= NVL (v_soz1_num, '-1')
               AND NVL (v_soz_alf, '-1') = NVL (v_soz1_alf, '-1')
               AND NVL (v_soz_num, '-1') <= NVL (v_soz2_num, '-1')
               AND NVL (v_soz_alf, '-1') = NVL (v_soz2_alf, '-1')
            THEN
               RETURN 1;
            END IF;
         END LOOP;

         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   PROCEDURE kargoya_verilis_tarihi_gunc ( /*Description: Arsiv Girisinden gelen, Kargoya verilis tarihini günceller.
                                         */
      isozlesme_no             IN     yk_dp_kontrat.sozlesme_no%TYPE,
      ikargo_seri_no           IN     yk_dp_kontrat.kargo_seri_no%TYPE,
      ikargoya_teslim_tarihi   IN     yk_dp_kontrat.kargoya_teslim_tarihi%TYPE,
      igiren_kullanici         IN     yk_dp_kontrat.giren_kullanici%TYPE,
      iupdate_warning          IN     NUMBER,
      durum                       OUT VARCHAR2,
      durum_code                  OUT NUMBER)
   IS
      v_count    NUMBER (1);
      v_status   VARCHAR2 (5);
   BEGIN
      durum := '0';
      durum_code := 0;

      BEGIN
         SELECT status
           INTO v_status
           FROM yk_dp_kontrat
          WHERE sozlesme_no = isozlesme_no;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            durum_code := -1;
            durum := 'Sözlesme bulunamadi.';
            RETURN;
      END;

      SELECT COUNT (1)
        INTO v_count
        FROM yk_dp_kontrat
       WHERE sozlesme_no = isozlesme_no AND kargo_seri_no IS NOT NULL;

      IF    iupdate_warning > 1
         OR v_count = 0
         OR (iupdate_warning > 0 AND (v_status = '20' OR v_status = '40'))
      THEN
         UPDATE yk_dp_kontrat
            SET kargo_seri_no = ikargo_seri_no,
                kargoya_teslim_tarihi = ikargoya_teslim_tarihi,
                kargo_seri_no_degist_kullanici = igiren_kullanici,
                kargo_seri_no_degistirme_tar = SYSDATE
          WHERE sozlesme_no = isozlesme_no;
      ELSE
         IF v_status = '20' OR v_status = '40'
         THEN
            durum :=
               'Kargo seri numarasi mevcut. Fakat <<sozlesme_no>> nolu sözlesme hatali konumda. Güncellemek istiyormusunuz.';
            durum_code := 1;
         ELSE
            IF yetki_pack.yetkisi_varmi (
                  igiren_kullanici,
                  'GIRILMIS_SOZLESME_KARGO_TARIHI_GUNCELLE') = 0
            THEN
               durum :=
                  'Kargo seri numarasi mevcut.<<sozlesme_no>> nolu sözlesme kapatilmis. Güncelleme yapamazsiniz.';
            ELSE
               durum :=
                  'Kargo seri numarasi mevcut.<<sozlesme_no>> nolu sözlesme kapatilmis. Güncellemek istiyormusunuz.';
            END IF;

            durum_code := 2;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         durum := SQLERRM;
         durum_code := -1;
   END;

   PROCEDURE tckn_ile_borcluluk_sorgulama (in_tckn     IN     VARCHAR2,
                                           in_user     IN     VARCHAR2,
                                           out_durum      OUT VARCHAR2,
                                           out_mesaj      OUT VARCHAR2)
   IS
      tmp_sonuckod                NUMBER;
      tmp_sonucmesaj              VARCHAR2 (4000);
      tmp_uyeadet                 NUMBER;
      tmp_toplamborc              NUMBER;
      vlimitliaktivasyonyetkisi   NUMBER;
      p_vadesi_gecmis_borc        NUMBER;
      p1                          NUMBER;
      p2                          NUMBER;
      p3                          NUMBER;
      p4                          NUMBER;
      p5                          NUMBER;
      p6                          NUMBER;
      p7                          NUMBER;
      p8                          NUMBER;
      p9                          NUMBER;
      p10                         NUMBER;

      CURSOR hesaplar
      IS
         SELECT account_number
           FROM dbs_dba.mb_abone_detay_bilgi
          WHERE tc_kimlik_no = in_tckn;

      CURSOR yetki_cursor
      IS
         SELECT yetki_adi, deger1
           FROM co_yetki_tanim
          WHERE yetki_adi LIKE 'YETKI_BORCLU_UYE_AKTIVASYON_%';
   BEGIN
      tmp_sonuckod := 0;
      tmp_sonucmesaj := 'Bu kisiye aktivasyon yapilabilir.';
      tmp_toplamborc := 0;

      -- tc kimlik numarasina ait toplam borç bilgisini al
      FOR varcurhesaplar IN hesaplar
      LOOP
         bilgi_pack.abone_cari_bilgileri (varcurhesaplar.account_number,
                                          1,
                                          p1,
                                          p2,
                                          p3,
                                          p4,
                                          p5,
                                          p6,
                                          p7,
                                          p8,
                                          p9,
                                          p10,
                                          p_vadesi_gecmis_borc);
         tmp_toplamborc := tmp_toplamborc + NVL (p_vadesi_gecmis_borc, 0);
      END LOOP;

      IF tmp_toplamborc > 0
      THEN
         vlimitliaktivasyonyetkisi := 0;

         -- kisinin herhangi bir borcu varsa isleme izin verme
         FOR yetki_rec IN yetki_cursor
         LOOP
            IF yetki_pack.yetkisi_varmi (in_user, yetki_rec.yetki_adi) <> 0
            THEN
               IF tmp_toplamborc < TO_NUMBER (yetki_rec.deger1)
               THEN
                  vlimitliaktivasyonyetkisi := 1;
               END IF;
            END IF;
         END LOOP;

         IF vlimitliaktivasyonyetkisi = 0
         THEN
            tmp_sonuckod := 1;
            tmp_sonucmesaj :=
                  'Bu kisinin, son ödeme tarihi geçmis faturalarindan '
               || tmp_toplamborc
               || ' TL borcu bulunmaktadir. Faturalar ödenmeden aktivasyon yapilamaz.';
         END IF;
      END IF;

      IF tmp_sonuckod = 0
      THEN
         -- kisinin üyelik adet bilgisini al
         SELECT COUNT (1)
           INTO tmp_uyeadet
           FROM (SELECT DISTINCT account_number
                   FROM mb_outlet_takip a
                  WHERE     EXISTS
                               (SELECT 1
                                  FROM mb_abone_detay_bilgi x
                                 WHERE     x.tc_kimlik_no = in_tckn
                                       AND x.account_number =
                                              a.account_number)
                        AND (   a.outlet_in_tarihi IS NULL
                             OR a.outlet_in_tarihi >
                                   SYSDATE - NUMTOYMINTERVAL (1, 'year')));

         -- 5 den fazla üyeligi varsa uyari ver
         IF     tmp_uyeadet > 5
            AND yetki_pack.yetkisi_varmi (
                   in_user,
                   'ISLEM_UYELIK_AKTIVASYON_FAZLA_ADET') = 0
         THEN
            tmp_sonuckod := 1;
            tmp_sonucmesaj :=
               'Bu kisiye aktivasyon yapmak için bayi temsilcinize danisiniz.';
         END IF;
      END IF;

      out_durum := TO_CHAR (tmp_sonuckod);
      out_mesaj := tmp_sonucmesaj;
   EXCEPTION
      WHEN OTHERS
      THEN
         out_durum := '1';
         out_mesaj := 'Bir hata olustu. Lütfen yeniden deneyiniz.';
   END;
-- 01.09.2005 Kullanilmadigi için kaldirildi.
/*
   PROCEDURE sms_fatura_adres_duzelt (
      iilk_kayit_aktarilma_tarihi   IN   YK_DP_KONTRAT.kayit_aktarilma_tarihi%TYPE,
      ison_kayit_aktarilma_tarihi   IN   YK_DP_KONTRAT.kayit_aktarilma_tarihi%TYPE
   )
   IS
      v_fatura_apt_adi        YK_DP_KONTRAT.fatura_apt_adi%TYPE;
      v_fatura_blok           YK_DP_KONTRAT.fatura_blok%TYPE;
      v_fatura_apt_no         YK_DP_KONTRAT.fatura_apt_no%TYPE;
      v_fatura_semt           YK_DP_KONTRAT.fatura_semt%TYPE;
      v_fatura_ilce           YK_DP_KONTRAT.fatura_ilce%TYPE;
      v_fatura_il             YK_DP_KONTRAT.fatura_il%TYPE;
      v_fatura_daire_no       YK_DP_KONTRAT.fatura_daire_no%TYPE;
      v_fatura_posta_kodu     YK_DP_KONTRAT.fatura_posta_kodu%TYPE;
      v_fatura_sirket_adi     YK_DP_KONTRAT.fatura_sirket_adi%TYPE;
      v_fatura_mahalle        YK_DP_KONTRAT.fatura_mahalle%TYPE;
      v_fatura_cadde          YK_DP_KONTRAT.fatura_cadde%TYPE;
      v_fatura_sokak          YK_DP_KONTRAT.fatura_sokak%TYPE;
      v_fatura_site_adi       YK_DP_KONTRAT.fatura_site_adi%TYPE;
      v_sozlesme_no           YK_DP_KONTRAT.sozlesme_no%TYPE;
      v_uye_no                YK_DP_KONTRAT.uye_no%TYPE;
      v_ad                    YK_DP_KONTRAT.ad%TYPE;
      v_soyad                 YK_DP_KONTRAT.soyad%TYPE;
      v_sozlesme_tipi         YK_DP_KONTRAT.sozlesme_tipi%TYPE;
      v_is_yeri_yetkilisi_1   YK_DP_KONTRAT.is_yeri_yetkilisi_1%TYPE;
      v_giren_kullanici       YK_DP_KONTRAT.giren_kullanici%TYPE;
      v_fatura_name           VARCHAR2 (65);
      v_mahalle               VARCHAR2 (50);
      v_cadde                 VARCHAR2 (50);
      v_sokak                 VARCHAR2 (50);
      v_site                  VARCHAR2 (50);
      v_apt                   VARCHAR2 (50);
      v_blok                  VARCHAR2 (50);
      v_aptno                 VARCHAR2 (50);
      v_daire                 VARCHAR2 (50);
      v_semt                  VARCHAR2 (50);
      v_posta                 VARCHAR2 (10);
      v_il                    VARCHAR2 (40);
      v_ilce                  VARCHAR2 (50);
      v_sonuc                 VARCHAR2 (255);
      v_count                 NUMBER (6)                               := 0;
      v_full_name             wiz_customer_bill_to.full_name%TYPE;
      v_adr_1                 wiz_customer_bill_to.addr_line_1%TYPE;
      v_adr_2                 wiz_customer_bill_to.addr_line_2%TYPE;
      v_adr_3                 wiz_customer_bill_to.addr_line_3%TYPE;

      CURSOR yk_dp_kontrat_cur
      IS
         SELECT *
           FROM YK_DP_KONTRAT
          WHERE (    kayit_aktarilma_tarihi >= iilk_kayit_aktarilma_tarihi
                 AND kayit_aktarilma_tarihi < ison_kayit_aktarilma_tarihi
                )
            AND status = '30'
            AND uye_no IS NOT NULL
            AND (   LENGTH (LTRIM (fatura_apt_no)) = 1
                 OR LENGTH (LTRIM (fatura_daire_no)) = 1
                 OR LENGTH (LTRIM (fatura_blok)) = 1
                 OR LENGTH (LTRIM (fatura_site_adi)) = 1
                 OR LENGTH (RTRIM (fatura_apt_adi)) = 1
                 OR LENGTH (LTRIM (fatura_sokak)) = 1
                );

      yk_dp_kontrat_rec       yk_dp_kontrat_cur%ROWTYPE;
   BEGIN
      FOR yk_dp_kontrat_rec IN yk_dp_kontrat_cur
      LOOP
         v_giren_kullanici := LTRIM (yk_dp_kontrat_rec.giren_kullanici);
         v_fatura_sirket_adi := LTRIM (yk_dp_kontrat_rec.fatura_sirket_adi);
         v_fatura_mahalle := LTRIM (yk_dp_kontrat_rec.fatura_mahalle);
         v_fatura_cadde := LTRIM (yk_dp_kontrat_rec.fatura_cadde);
         v_fatura_sokak := LTRIM (yk_dp_kontrat_rec.fatura_sokak);
         v_fatura_site_adi := LTRIM (yk_dp_kontrat_rec.fatura_site_adi);
         v_fatura_apt_adi := LTRIM (yk_dp_kontrat_rec.fatura_apt_adi);
         v_fatura_blok := LTRIM (yk_dp_kontrat_rec.fatura_blok);
         v_fatura_apt_no := LTRIM (yk_dp_kontrat_rec.fatura_apt_no);
         v_fatura_semt := LTRIM (yk_dp_kontrat_rec.fatura_semt);
         v_fatura_ilce := LTRIM (yk_dp_kontrat_rec.fatura_ilce);
         v_fatura_il := LTRIM (yk_dp_kontrat_rec.fatura_il);
         v_fatura_daire_no := LTRIM (yk_dp_kontrat_rec.fatura_daire_no);
         v_fatura_posta_kodu := LTRIM (yk_dp_kontrat_rec.fatura_posta_kodu);
         v_sozlesme_no := LTRIM (yk_dp_kontrat_rec.sozlesme_no);
         v_uye_no := LTRIM (yk_dp_kontrat_rec.uye_no);
         v_ad := LTRIM (yk_dp_kontrat_rec.ad);
         v_soyad := LTRIM (yk_dp_kontrat_rec.soyad);
         v_sozlesme_tipi := LTRIM (yk_dp_kontrat_rec.sozlesme_tipi);
         v_is_yeri_yetkilisi_1 :=
                                LTRIM (yk_dp_kontrat_rec.is_yeri_yetkilisi_1);

         --adres satirlarini oluStur
         IF     LENGTH (LTRIM (RTRIM (v_fatura_mahalle))) > 1
            AND LTRIM (RTRIM (v_fatura_mahalle)) <> '-'
            AND LTRIM (RTRIM (v_fatura_mahalle)) <> '*'
         THEN
            v_mahalle := SUBSTR (v_fatura_mahalle, 1, 45) || ' MAH.';
         ELSE
            v_mahalle := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_cadde))) > 1
            AND LTRIM (RTRIM (v_fatura_cadde)) <> '-'
            AND LTRIM (RTRIM (v_fatura_cadde)) <> '*'
         THEN
            v_cadde := SUBSTR (v_fatura_cadde, 1, 45) || ' CAD.';
         ELSE
            v_cadde := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_sokak))) >= 1
            AND LTRIM (RTRIM (v_fatura_sokak)) <> '-'
            AND LTRIM (RTRIM (v_fatura_sokak)) <> '*'
         THEN
            v_sokak := SUBSTR (v_fatura_sokak, 1, 45) || ' SOK.';
         ELSE
            v_sokak := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_site_adi))) >= 1
            AND LTRIM (RTRIM (v_fatura_site_adi)) <> '-'
            AND LTRIM (RTRIM (v_fatura_site_adi)) <> '*'
         THEN
            v_site := SUBSTR (v_fatura_site_adi, 1, 43) || ' SITESI ';
         ELSE
            v_site := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_blok))) >= 1
            AND LTRIM (RTRIM (v_fatura_blok)) <> '-'
            AND LTRIM (RTRIM (v_fatura_blok)) <> '*'
         THEN
            v_blok := SUBSTR (v_fatura_blok, 1, 45) || ' BLOK';
         ELSE
            v_blok := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_apt_no))) >= 1
            AND LTRIM (RTRIM (v_fatura_apt_no)) <> '-'
            AND LTRIM (RTRIM (v_fatura_apt_no)) <> '*'
         THEN
            v_aptno := ' NO:' || SUBSTR (v_fatura_apt_no, 1, 46);
         ELSE
            v_aptno := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_apt_adi))) >= 1
            AND LTRIM (RTRIM (v_fatura_apt_adi)) <> '-'
            AND LTRIM (RTRIM (v_fatura_apt_adi)) <> '*'
         THEN
            v_apt := SUBSTR (v_fatura_apt_adi, 1, 45) || ' APT.';
         ELSE
            v_apt := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_daire_no))) >= 1
            AND LTRIM (RTRIM (v_fatura_daire_no)) <> '-'
            AND LTRIM (RTRIM (v_fatura_daire_no)) <> '*'
         THEN
            v_daire := ' D:' || SUBSTR (v_fatura_daire_no, 1, 47);
         ELSE
            v_daire := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_semt))) > 1
            AND LTRIM (RTRIM (v_fatura_semt)) <> '-'
            AND LTRIM (RTRIM (v_fatura_semt)) <> '*'
         THEN
            v_semt := ' ' || SUBSTR (v_fatura_semt, 1, 49);
         ELSE
            v_semt := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_posta_kodu))) > 1
            AND LTRIM (RTRIM (v_fatura_posta_kodu)) <> '-'
            AND LTRIM (RTRIM (v_fatura_posta_kodu)) <> '*'
         THEN
            v_posta := ' ' || SUBSTR (v_fatura_posta_kodu, 1, 5);
         ELSE
            v_posta := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_il))) > 1
            AND LTRIM (RTRIM (v_fatura_il)) <> '-'
            AND LTRIM (RTRIM (v_fatura_il)) <> '*'
         THEN
            v_il := ' ' || SUBSTR (v_fatura_il, 1, 49);
         ELSE
            v_il := '';
         END IF;

         IF     LENGTH (LTRIM (RTRIM (v_fatura_ilce))) > 1
            AND LTRIM (RTRIM (v_fatura_ilce)) <> '-'
            AND LTRIM (RTRIM (v_fatura_ilce)) <> '*'
         THEN
            v_ilce := ' ' || SUBSTR (v_fatura_ilce, 1, 49);
         ELSE
            v_ilce := '';
         END IF;

---------------------------------------------------------------------------
         IF LENGTH (v_mahalle || v_cadde || v_sokak || v_site) <= 50
         THEN
            v_adr_1 := v_mahalle || v_cadde || v_sokak || v_site;
            v_adr_2 := v_apt;
            v_adr_3 := v_blok || v_aptno || v_daire;
---------------------------------------------------------------------------
         ELSIF LENGTH (v_mahalle || v_cadde || v_sokak) <= 50
         THEN
            v_adr_1 := v_mahalle || v_cadde || v_sokak;

            IF LENGTH (v_site || v_apt) <= 50
            THEN
               v_adr_2 := v_site || v_apt;
               v_adr_3 := v_blok || v_aptno || v_daire;
            ELSE
               v_adr_2 := v_site;

               IF LENGTH (v_apt || v_blok || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_apt || v_blok || v_aptno || v_daire;
               ELSE
                  v_adr_3 := v_blok || v_aptno || v_daire;
               END IF;
            END IF;
---------------------------------------------------------------------------
         ELSIF LENGTH (v_mahalle || v_cadde) <= 50
         THEN
            v_adr_1 := v_mahalle || v_cadde;

            IF LENGTH (v_sokak || v_site || v_apt) <= 50
            THEN
               v_adr_2 := v_sokak || v_site || v_apt;
               v_adr_3 := v_blok || v_aptno || v_daire;
            ELSIF LENGTH (v_sokak || v_site) <= 50
            THEN
               v_adr_2 := v_sokak || v_site;

               IF LENGTH (v_apt || v_blok || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_apt || v_blok || v_aptno || v_daire;
               ELSE
                  v_adr_3 := v_blok || v_aptno || v_daire;        --v_apt yok
               END IF;
            ELSE
               v_adr_2 := v_sokak;

               IF LENGTH (v_site || v_apt || v_blok || v_aptno || v_daire) <=
                                                                           50
               THEN
                  v_adr_3 := v_site || v_apt || v_blok || v_aptno || v_daire;
               ELSIF LENGTH (v_site || v_blok || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_site || v_blok || v_aptno || v_daire;
                                                                  --v_apt yok
               ELSIF LENGTH (v_site || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_site || v_aptno || v_daire;
                                                        --v_apt ve v_blok yok
               ELSE
                  v_adr_3 := v_blok || v_aptno || v_daire;
                                              --v_apt ve v_blok ve v_site yok
               END IF;
            END IF;
---------------------------------------------------------------------------
         ELSE
            v_adr_1 := v_mahalle;

            IF LENGTH (v_cadde || v_sokak || v_site || v_apt) <= 50
            THEN
               v_adr_2 := v_cadde || v_sokak || v_site || v_apt;
               v_adr_3 := v_blok || v_aptno || v_daire;
            ELSIF LENGTH (v_cadde || v_sokak || v_site) <= 50
            THEN
               v_adr_2 := v_cadde || v_sokak || v_site;

               IF LENGTH (v_apt || v_blok || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_apt || v_blok || v_aptno || v_daire;
               ELSE
                  v_adr_3 := v_blok || v_aptno || v_daire;        --v_apt yok
               END IF;
            ELSIF LENGTH (v_cadde || v_sokak) <= 50
            THEN
               v_adr_2 := v_cadde || v_sokak;

               IF LENGTH (v_site || v_apt || v_blok || v_aptno || v_daire) <=
                                                                           50
               THEN
                  v_adr_3 := v_site || v_apt || v_blok || v_aptno || v_daire;
               ELSIF LENGTH (v_site || v_blok || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_site || v_blok || v_aptno || v_daire;
                                                                  --v_apt yok
               ELSIF LENGTH (v_site || v_aptno || v_daire) <= 50
               THEN
                  v_adr_3 := v_site || v_aptno || v_daire;
                                                        --v_apt ve v_blok yok
               ELSE
                  v_adr_3 := v_blok || v_aptno || v_daire;
                                              --v_apt ve v_blok ve v_site yok
               END IF;
            ELSE
               v_adr_2 := v_cadde;

               IF LENGTH (   v_sokak
                          || v_site
                          || v_apt
                          || v_blok
                          || v_aptno
                          || v_daire
                         ) <= 50
               THEN
                  v_adr_3 :=
                     v_sokak || v_site || v_apt || v_blok || v_aptno
                     || v_daire;
               ELSIF LENGTH (v_sokak || v_site || v_blok || v_aptno || v_daire) <=
                                                                            50
               THEN
                  v_adr_3 :=
                            v_sokak || v_site || v_blok || v_aptno || v_daire;
                                                                  --v_apt yok
               ELSIF LENGTH (v_sokak || v_site || v_aptno || v_daire) <= 50
               THEN                                      --v_apt ve v_blok yok
                  v_adr_3 := v_sokak || v_site || v_aptno || v_daire;
               ELSIF LENGTH (v_sokak || v_site || v_aptno) <= 50
               THEN
                  v_adr_3 := v_sokak || v_site || v_aptno;
                                             --v_apt ve v_blok ve v_daire yok
               ELSIF LENGTH (v_sokak || v_aptno) <= 50
               THEN
                  v_adr_3 := v_sokak || v_aptno;
                                   --v_site ve v_apt ve v_blok ve v_daire yok
               ELSE
                  v_adr_3 := v_sokak;
               END IF;
            END IF;
         END IF;

-----------------------------------------------------------------------------------------------
--mevcut Üye
-----------------------------------------------------------------------------------------------
         BEGIN
            SELECT full_name
              INTO v_full_name
              FROM wiz_customer_bill_to
             WHERE account_number = v_uye_no; -- AND adres_kaynak = 'FATURA'; --27.06.2005 Yusuf Ayvaz Fatura adres viewdan kontrol
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_full_name := v_fatura_sirket_adi;
         END;

         IF RTRIM (v_fatura_sirket_adi) IS NOT NULL
         THEN
            IF LENGTH (RTRIM (v_fatura_sirket_adi)) >= 4
            THEN
               v_fatura_name := RTRIM (v_fatura_sirket_adi);
            ELSE
               v_fatura_name := v_full_name;
            END IF;
         ELSIF v_sozlesme_tipi = '2'
         THEN
            v_fatura_name :=
                   SUBSTR ((v_is_yeri_yetkilisi_1 || ' ' || v_soyad), 1, 65);
         ELSE
            v_fatura_name := SUBSTR (v_ad || ' ' || v_soyad, 1, 65);
         END IF;

         Abone_Detay_Pack.billing_address_update (v_uye_no,
                                                  v_fatura_name,
                                                  v_adr_1,
                                                  v_adr_2,
                                                  v_adr_3,
                                                  v_semt,
                                                  v_ilce,
                                                  v_il,
                                                  v_posta,
                                                  v_giren_kullanici,
                                                  v_sonuc
                                                 );

         IF v_sonuc <> '0'
         THEN
            RETURN;
         END IF;

         v_count := v_count + 1;
      END LOOP;

   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN;
   END sms_fatura_adres_duzelt;
*/
-- 01.09.2005 Kullanilmadigi için kaldirildi
/*
   PROCEDURE abone_potansiyel_geri_al (
      in_yk_abone_potansiyel_id   IN       YK_DP_KONTRAT_POTANSIYEL_LOG.yk_abone_potansiyel_id%TYPE,
      out_durum                   OUT      VARCHAR2
   )
   IS
      v_account_number   NUMBER (10);
      v_potansiyel_no    NUMBER (10);

      CURSOR yk_dp_kontrat_potansiyel_cur
      IS
         SELECT *
           FROM YK_DP_KONTRAT_POTANSIYEL_LOG
          WHERE yk_abone_potansiyel_id = in_yk_abone_potansiyel_id;
   BEGIN
      FOR yk_dp_kontrat_potansiyel_rec IN yk_dp_kontrat_potansiyel_cur
      LOOP
         -- Potansiyel Kaydini tekrar yarat
         SELECT uye_no
           INTO v_account_number
           FROM YK_DP_KONTRAT_ABONE_POTANSIYEL
          WHERE ID = in_yk_abone_potansiyel_id;

         v_potansiyel_no := yk_dp_kontrat_potansiyel_rec.prospect_number;
         Uye_Adres_Pack.prospect_insert_istenen_no_ile
                          (yk_dp_kontrat_potansiyel_rec.prospect_number,
                           yk_dp_kontrat_potansiyel_rec.ssn,
                           yk_dp_kontrat_potansiyel_rec.first_name,
                           yk_dp_kontrat_potansiyel_rec.middle_i,
                           yk_dp_kontrat_potansiyel_rec.last_name,
                           yk_dp_kontrat_potansiyel_rec.title,
                           yk_dp_kontrat_potansiyel_rec.title_post,
                           yk_dp_kontrat_potansiyel_rec.home_area_code,
                           yk_dp_kontrat_potansiyel_rec.home_exchange,
                           yk_dp_kontrat_potansiyel_rec.home_number,
                           yk_dp_kontrat_potansiyel_rec.work_area_code,
                           yk_dp_kontrat_potansiyel_rec.work_exchange,
                           yk_dp_kontrat_potansiyel_rec.work_number,
                           yk_dp_kontrat_potansiyel_rec.work_extension,
                           yk_dp_kontrat_potansiyel_rec.mobile_number,
                           yk_dp_kontrat_potansiyel_rec.mobile_area_code,
                           yk_dp_kontrat_potansiyel_rec.mobile_exchange,
                           yk_dp_kontrat_potansiyel_rec.service_address_id,
                           yk_dp_kontrat_potansiyel_rec.street_number,
                           yk_dp_kontrat_potansiyel_rec.street_fraction,
                           yk_dp_kontrat_potansiyel_rec.street_name,
                           yk_dp_kontrat_potansiyel_rec.street_descr,
                           yk_dp_kontrat_potansiyel_rec.street_direction_pre,
                           yk_dp_kontrat_potansiyel_rec.street_direction_post,
                           yk_dp_kontrat_potansiyel_rec.suppl_addr_line,
                           yk_dp_kontrat_potansiyel_rec.unit_number,
                           yk_dp_kontrat_potansiyel_rec.entrance,
                           yk_dp_kontrat_potansiyel_rec.FLOOR,
                           yk_dp_kontrat_potansiyel_rec.city,
                           yk_dp_kontrat_potansiyel_rec.state,
                           yk_dp_kontrat_potansiyel_rec.zip,
                           yk_dp_kontrat_potansiyel_rec.carrier_route,
                           yk_dp_kontrat_potansiyel_rec.suppl_addr_line_1,
                           yk_dp_kontrat_potansiyel_rec.suppl_addr_line_2,
                           yk_dp_kontrat_potansiyel_rec.suppl_addr_line_3,
                           yk_dp_kontrat_potansiyel_rec.suppl_addr_line_4,
                           yk_dp_kontrat_potansiyel_rec.comments_62,
                           yk_dp_kontrat_potansiyel_rec.comments_62_2,
                           yk_dp_kontrat_potansiyel_rec.comments_62_3,
                           yk_dp_kontrat_potansiyel_rec.updating_user,
                           out_durum
                          );

         IF out_durum <> '0'
         THEN
            out_durum := 'ABONE_POTANSIYEL_GERI_AL : ' || out_durum;
         END IF;

         -- cti arama listesi
         UPDATE ct_arama_listesi
            SET account_number = NULL
          WHERE prospect_number = v_potansiyel_no
            AND account_number = v_account_number;

         -- arama detay
         UPDATE ct_uye_arama_detay
            SET account_number = NULL
          WHERE prospect_number = v_potansiyel_no
            AND account_number = v_account_number;

         -- gonderi update
         UPDATE GON_GONDERI
            SET account_number = NULL,
                aciklama = NULL
          WHERE prospect_number = v_potansiyel_no
            AND account_number = v_account_number;

         UPDATE MB_MEMO_MESAJ_BILGI
            SET account_number = NULL
          WHERE prospect_number = v_potansiyel_no;

         UPDATE MB_YORUM_BILGI
            SET account_number = NULL,
                kisi_tipi = 2,
                aciklama = TRIM (aciklama)
          WHERE prospect_number = v_potansiyel_no
            AND account_number = v_account_number;

         UPDATE TD_TODO
            SET account_number = NULL,
                aciklama = NULL
          WHERE prospect_number = v_potansiyel_no
            AND account_number = v_account_number;

         UPDATE AB_ABONE_CEVAP
            SET account_number = NULL
          WHERE prospect_number = v_potansiyel_no
            AND account_number = v_account_number;
      END LOOP;
   END abone_potansiyel_geri_al;
*/
/*Mustafa 29.08.2006 Kullanilmayan function
   FUNCTION getmerniscode (sehir VARCHAR2, ilce VARCHAR2)
      RETURN VARCHAR
   IS
      v_deger   CO_ILCE.mernis_id%TYPE;

      CURSOR co_mernis_cur
      IS
         SELECT CO_ILCE.mernis_id
           FROM CO_IL, CO_ILCE
          WHERE CO_IL.kod = CO_ILCE.kod AND CO_IL.ad = sehir AND CO_ILCE.ad = ilce;
   BEGIN
      OPEN co_mernis_cur;

      FETCH co_mernis_cur
       INTO v_deger;

      IF co_mernis_cur%NOTFOUND
      THEN
         v_deger := NULL;
      END IF;

      CLOSE co_mernis_cur;

      RETURN v_deger;
   END;
*/

END;
/
